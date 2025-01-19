classdef SimuMCMOT < Iterator
    properties (Constant)
        paramsnames     = ["n" "dt" "dr" "boundaries" "tube" "initstate" ...
                            "coolings" "magnetic" "gravity" "inter_scatter_rate" ...
                            "v_lim" "mode_B" "mode_L" "iter_max" "vel_trunc" ...
                            "guard" "scatter" "collect" "transition" "gmum"]
        confignames     = []
        datanames       = ["pos", "vel", "iter_now", "active", "boundaries"]
    end
    properties (Constant)
        % constants
        phys        = PhysicsConstants;        
    end
    % Implemented
    properties
        iter_max 
        iter_now
        ioupdater   = QueueUnit()
        toproceed   = const(true)
    end
    % loaded parameters, in SI units
    properties        
        n           = 1E6
        dt          
        dr     
        boundaries      {mustHaveField(boundaries, ["hw" "hl" "wallmode" "T_wall"])}
        tube            {mustHaveField(tube, ["r"])}
        initstate       {mustHaveField(initstate, ["mode"])}
        v_lim        
        inter_scatter_rate
        mode_B
        mode_L
        vel_trunc   = Inf
        transition
        gmum

        guard           {mustBeFunctionHandle}
        scatter         {mustBeFunctionHandle}
        collect         {mustBeFunctionHandle}
        
    end
    % derived properties
    properties
        coolings        (:,:)     FieldSettings
        magnetic        (:,:)     FieldSettings
        gravity         (1,1)     FieldSettings
        pos_init        {mustBeFunctionHandle} = @trivial
        vel_init        {mustBeFunctionHandle} = @trivial
        B_env           EnvMagnetic = EnvMagnetic()
        L_env           EnvLight    = EnvLight()
        distr_T_wall    = makedist("Normal", "mu", 0, "sigma", 0);
        distr_T_limit   = makedist("Normal", "mu", 0, "sigma", 0);  
        hitwall         {mustBeFunctionHandle} = @trivial
        respawn         {mustBeFunctionHandle}
        veldisttrunc    = @id;
    end
    % transient properties
    properties
        pos 
        vel
        acl
        active
        collected
        respawned       % just respawned
        n_acc_sample
    end
    % Getters
    methods        
        function t = VtoT(o, v); t = v^2 / o.phys.k_B * o.transition.M; end
        function v = TtoV(o, t); v = sqrt(o.phys.k_B * t / o.transition.M);  end  
    end
    methods
        function reset(o)
            o.iter_now = 1;   
            o.pos = o.pos_init();
            o.vel = o.vel_init(); 
            o.acl = zeros([o.n 3]);
            % all particles are active and marked as just spawned
            o.active    = true([o.n, 1]);
            o.collected = false([o.n 1]);
            o.respawned = true([o.n, 1]);
            o.n_acc_sample = o.n;
        end
        function ready(o)     
            o.veldisttrunc = @(pd) truncate(pd, -o.vel_trunc, o.vel_trunc);
            b = o.boundaries;
            st = o.initstate;
            switch b.wallmode
                case "thermal"
                    o.distr_T_wall = makedist("Normal", "mu", 0, "sigma", o.TtoV(b.T_wall));
                    o.distr_T_wall = o.veldisttrunc(o.distr_T_wall);
                    o.hitwall = @(pos, vel) walltemp(o.distr_T_wall, b.hw, b.hl, pos, vel);
                    o.respawn = @id;
                case "reflective"
                    o.distr_T_wall = [];
                    o.hitwall = @(pos, vel) wallrefl(b.hw, b.hl, pos, vel);
                    o.respawn = @id;
                case "through"
                    o.distr_T_wall = [];
                    o.hitwall = @id;
                    o.respawn = @id;
                case "respawnflow"
                    o.distr_T_wall = [];
                    o.hitwall = @id;
                    o.respawn = @(p, ~) gendist_uniflow(size(p, 1), b.hw, b.hl, o.TtoV(st.T), o.vel_trunc);
            end
            switch st.mode
                case "Prefill"
                    o.pos_init = @() gendist_uni3d(o.n, b.hw, b.hl);
                    o.vel_init = @() gendist_mb3d(o.n, o.TtoV(st.T), o.veldisttrunc);
                case "Stream"
                    [o.pos_init, o.vel_init] = genstream(o.n, st); 
                case "Boundary"
                    [pos_0, vel_0] = gendist_uniflow(o.n, b.hw, b.hl, o.TtoV(st.T), o.vel_trunc);
                    o.pos_init = @() pos_0;
                    o.vel_init = @() vel_0;
                case "BoundarySelected"
                    [pos_0, vel_0] = gendist_uniflow(o.n, b.hw, b.hl, o.TtoV(st.T), o.vel_trunc);
                    o.pos_init = @() pos_0;
                    o.vel_init = @() vel_0;
            end     
            o.distr_T_limit = makedist("Normal", "mu", 0, "sigma", o.VtoT(o.v_lim));                           
            o.B_env.mode = o.mode_B;
            o.L_env.mode = o.mode_L;
            o.B_env.loadsettings(o.magnetic, o.phys);
            o.L_env.loadsettings(o.coolings, o.transition);
            o.B_env.ready(o.boundaries, [o.coolings.units]);
            o.L_env.ready(o.boundaries, [o.coolings.units]);
            o.reset; 
        end
        function iter(o)
            % dynamics part
            B = o.B_env.calc(o.pos);
            B = reshape(B, [o.n, 3]) .* isinbound(o.boundaries, o.pos);     % this makes sure that no magnetic field outside bound is used
            dv = o.L_env.drc * o.transition.v_rec;
            % relative velocity along each beam direction
            v = o.vel * o.L_env.drc';
            % For each beam, calculate the Zeeman shift by the B field
            det_zmn = B * o.L_env.pol' * o.gmum / o.transition.semilw;
            % For each beam, calculate the Doppler shift
            det_dpl = v / o.transition.v_gam;
            % position relative to the center of the beam projected to the
            % normal plane of the beam, normalized with the waist.
            I_rel = o.L_env.calc(o.pos) .* isinbound(o.boundaries, o.pos);
            det = ones([o.n, 1]) * o.L_env.det' - det_zmn - det_dpl;
            rate = o.transition.semilw * I_rel ./ (1 + I_rel + det.^2);
            o.acl = rate * dv + o.gravity.units .* isinbound(o.boundaries, o.pos);
            rec = random(o.distr_T_limit, [o.n, 3]);
            o.vel = o.vel + o.acl * o.dt + rec;
            o.pos = o.pos + o.vel * o.dt;
            [o.pos, o.vel] = o.hitwall(o.pos, o.vel); 


            % only manage the out-of-bound ones that are active. Ignore the inactive part
            is_out       = o.active & ~o.guard(o.boundaries, o.tube, o.pos);
            is_scattered = o.scatter(o.pos, o.vel);
            % respawn the particles that are seen as out and scattered, but
            % only active ones, so that collected ones are gaurunteed to be
            % kept
            rsp = (is_out | is_scattered) & o.active;
            [o.pos(rsp,:), o.vel(rsp,:)] = o.respawn(o.pos(rsp,:), o.vel(rsp,:)); 
            o.respawned = rsp;
            o.n_acc_sample = o.n_acc_sample + sum(rsp);
            
            % collected ones are no longer active 
            % this contains all newly collected particles and historical ones
            % one must compare to the track record to find the truely newly collected ones
            o.collected = o.collected | o.collect(o.pos, o.vel);
            % guard a second time, if the particle is still out of bound,
            % mark as inactive, but all the respawned particles just added
            % are active
            o.active = (o.active & ~o.collected & o.guard(o.boundaries, o.tube, o.pos)) | o.respawned;   
        end
        function wrapup(~);  end
        function o = SimuMCMOT()
            o.ioupdater.clear;
        end
    end
end