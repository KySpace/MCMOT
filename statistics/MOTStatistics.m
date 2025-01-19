classdef MOTStatistics < DataObserver
    properties (Constant)
        paramsnames         = ["transition" "v_rel_log_rng" "v_rel_log_max" "v_gam_log" "v_step" "dt" "num_acc" "num_stat" "dostat" "iter_max" "n"]
        datanames           = ["v_rel_log_rng" "v_gam_log" "v_step" "dt" "n" "num_acc" "num_stat" "vel_edges" "t_stamps" "vel_stamps" ...
                                "v_trsv_stat" "v_long_stat" ...
                                "n_collect_iter" "n_sample_iter" "n_slow_iter" "ratio_accept_iter" ...
                                "n_collect_iter_now" "n_slow_iter_now" "n_sample_iter_now" "ratio_accept_iter_now" ...
                                "iter_now" "stat_now" "mask_collected" "mask_active" ...
                                "initcache"]
        confignames         = []
    end
    properties
        % num marks the numbers in statistic settings, e.g. number of bins
        % etc.     
        transition
        num_stat
        num_acc
        num_bin
        iter_max
        n
        dt
        v_rel_log_rng       = [-2,8]
        v_rel_log_max       = Inf               % the maximum longitudinal velocity to be considered slow enough
        v_step              = 0.5
        v_gam_log
        vel_edges
        dostat
    end
    properties
        % n marks the number of particles being counted
        iter_now
        stat_now

        t_stamps
        vel_stamps
        
        % accumulation results, to be updated per iter, cleared per rcrd
        %        1  × num_bin
        v_trsv_acc
        v_long_acc
        % statistical results, to be updated per rcrd
        % numn_stat × num_bin
        v_trsv_stat
        v_long_stat
        
        % updated per iter
        % iter_max × 1
        n_collect_iter       % number of all particles collected
        n_sample_iter        % total number of particles ever created
        n_slow_iter          % slow particles collected
        ratio_accept_iter    % acceptance rate as of now  
        n_active_iter    
        n_respawned_iter 

        mask_collected      % 1 is the particles that are already collected
        mask_active         % 1 is the particles within track
        initcache

        % transient, latest numbers
        n_collect_iter_now 
        n_slow_iter_now
        n_sample_iter_now
        ratio_accept_iter_now
        n_active_iter_now    
        n_respawned_iter_now 
    end
    % Settings
    methods (Static)
        function ds = mkdovelstat()
            function [collected_next, active_next, n_new, vel_trsv_sq, vel_long_sq] = velstat(~, vel, active, collected, collected_last, active_last)
                active_last = active_last & active;
                vel_sq = vel .^ 2;
                vel_trsv_sq = vel_sq(:,1) + vel_sq(:,2);
                vel_long_sq = vel_sq(:,3);
                collected_still = collected;
                collected_onlynew = collected_still & ~collected_last;
                collected_next = collected_still | collected_last;
                n_new = sum(collected_onlynew,1);
                vel_trsv_sq = vel_trsv_sq(collected_onlynew);  
                vel_long_sq = vel_long_sq(collected_onlynew); 
                active_next = active_last & ~collected_next;
            end
            ds = @velstat;
        end    
        function ds = mkcrosssectionstat(z_surf)
            arguments
                z_surf    (1,1)
            end
            % only counts from negative to positive
            function [thru_next, track_next, n, vel_trsv_sq, vel_long_sq] = thru(pos, vel, active, thru_last, track_last)
                % everthing to the + size of z_surf is masked as untrack
                if isempty(thru_last)
                    thru_last = false([o.n, 1]);
                    track_last = ~(pos(:,3) > z_surf) & active;
                end                                
                vel_sq = vel .^ 2;
                vel_trsv_sq = vel_sq(:,1) + vel_sq(:,2);
                vel_long_sq = vel_sq(:,3);
                thru = pos(:,3) > z_surf & track_last & active;
                thru_onlynew = thru & ~thru_last;
                thru_next = thru | thru_last;
                n = sum(thru_onlynew,1);
                vel_trsv_sq = vel_trsv_sq(thru_onlynew);  
                vel_long_sq = vel_long_sq(thru_onlynew);
                % We no longer track those that has already gone through
                track_next = ~thru & track_last & active;
            end
            ds = @thru;
        end
    end
    methods
        function clearacc(o)
            o.v_trsv_acc      = zeros([1 o.num_bin]);
            o.v_long_acc      = zeros([1 o.num_bin]);
            o.n_collect_iter           = 0;
            o.n_slow_iter      = 0;
        end        
        function rcrdacc(o)
            o.stat_now = o.stat_now + 1;
            o.v_trsv_stat (o.stat_now,:) = o.v_trsv_acc;   
            o.v_long_stat (o.stat_now,:) = o.v_long_acc;   
            o.clearacc;            
        end
    end
    % Implementation
    methods
        function init(~); end
        function ready(o, ~, ~)
            o.vel_edges     = o.v_rel_log_rng(1) : o.v_step : o.v_rel_log_rng(2);
            o.vel_stamps    = o.vel_edges(2:end) - o.v_step / 2;
            o.num_bin       = length(o.vel_edges) - 1;
            o.mask_collected = false([o.n 1]);
            o.mask_active    = false([o.n 1]);
        end
        function clear(o)
            o.iter_now               = 0;
            o.stat_now               = 0;
            o.t_stamps        = (1 : o.num_stat) * o.dt * o.num_acc;
            o.clearacc;     
            o.v_trsv_stat    = zeros([o.num_stat  o.num_bin]);      
            o.v_long_stat    = zeros([o.num_stat  o.num_bin]);      
            
            o.n_collect_iter     = zeros([o.iter_max 1]); 
            o.n_sample_iter      = zeros([o.iter_max 1]); 
            o.n_slow_iter        = zeros([o.iter_max 1]); 
            o.ratio_accept_iter  = nan([o.iter_max 1]); 
            o.n_active_iter      = zeros([o.iter_max 1]);
            o.n_respawned_iter   = zeros([o.iter_max 1]);

            o.n_collect_iter_now    = 0;
            o.n_slow_iter_now       = 0;
            o.n_sample_iter_now     = 0;
            o.ratio_accept_iter_now = nan;
        end
        function update(o, pos, vel, active, respawned, collected, n_acc_sample, iter_now)            
            o.iter_now = iter_now;            
            % record the initial state of the newly respawned ones
            o.initcache.pos = pos(respawned, :);
            o.initcache.vel = vel(respawned, :);

            [o.mask_collected, o.mask_active, n_collect_new, vel_trsv_sq_new, vel_long_sq_new] = o.dostat(pos, vel, active, collected, o.mask_collected, o.mask_active);          
            n_slow_new = sum(log(vel_long_sq_new)/2 - o.v_gam_log < o.v_rel_log_max);
            o.v_trsv_acc       = o.v_trsv_acc + histcounts(log(vel_trsv_sq_new)/2 - o.v_gam_log, o.vel_edges);  
            o.v_long_acc       = o.v_long_acc + histcounts(log(vel_long_sq_new)/2 - o.v_gam_log, o.vel_edges); 

            o.n_collect_iter_now    = o.n_collect_iter_now    + n_collect_new;  
            o.n_slow_iter_now       = o.n_slow_iter_now       + n_slow_new;
            o.n_sample_iter_now     = n_acc_sample;
            o.ratio_accept_iter_now = o.n_slow_iter_now / o.n_sample_iter_now;

            o.n_active_iter_now     = sum(active);
            o.n_respawned_iter_now  = sum(respawned);

            if iter_now < 1; return; end

            % per iteration recordings
            o.n_collect_iter    (o.iter_now) = o.n_collect_iter_now;
            o.n_sample_iter     (o.iter_now) = o.n_sample_iter_now;
            o.ratio_accept_iter (o.iter_now) = o.ratio_accept_iter_now;

            o.n_slow_iter       (o.iter_now) = n_slow_new; 
            o.n_active_iter     (o.iter_now) = o.n_active_iter_now    ;
            o.n_respawned_iter  (o.iter_now) = o.n_respawned_iter_now ;

            if mod(o.iter_now, o.num_acc) == 0; o.rcrdacc; end
        end
        function final(~); end
        function o = MOTStatistics()
        end
    end
end