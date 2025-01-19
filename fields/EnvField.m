classdef EnvField < handle
    properties (Abstract)
        settings    (:,:)   FieldSettings 
        mode        {mustHaveField(mode, ["bake" "gridtype" "sampling"])}
        src_norm   % beams or current normalized for calculation
        count       {mustBeInteger}             
        calc        {mustBeFunctionHandle} % pos -> field     
        ntpl        % interpolants
        funs        {mustBeFunctionHandleCell}  
        normalize   {mustBeFunctionHandle}
    end
    methods (Abstract)
        setbake
        setinsitu
    end
    methods 
        function loadsettings(o, settings, c)
            o.settings = settings;
            o.src_norm = arrayfun(@(p) o.normalize(c, p), [o.settings.units]);
        end
        function ready(o, boundaries, beamunits)
            arguments
                o
                boundaries
                beamunits 
            end
            m = o.mode; b = boundaries; 
            switch m.gridtype 
                case "bybeams"
                    [X, Y, Z] = gengrid_beams(b.hw, b.hl, beamunits, m.sampling);
                case "uniform"
                    [X, Y, Z] = gengrid_uni(b.hw, b.hl, m.sampling);
            end
            if m.bake;  o.setbake(X,Y,Z);
            else;       o.setinsitu;
            end
        end
    end
end