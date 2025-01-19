classdef BeamUnit 
    properties
        profile
        power
        w_0
        det
        ctr
        drc
        pol
    end
    methods
        function beam = BeamUnit(profile, power, w_0, det, ctr, drc, sig)
            arguments
                profile        {mustBeMember(profile, ["gaussian", "circuni"])}
                power          (1,1) 
                w_0            (1,1) 
                det            (1,1)                  
                ctr            (1,3)
                drc            (1,3)
                sig            {mustBeMember(sig, ["+" "-"])}
            end
            beam.profile    = profile;     
            beam.power      = power;  
            beam.w_0        = w_0;
            beam.det        = det;
            beam.ctr        = ctr;
            beam.drc        = drc;
            beam.pol        = drc * tern(sig == "+", 1, -1);
        end
    end
end