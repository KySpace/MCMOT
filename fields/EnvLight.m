classdef EnvLight < EnvField
    properties
        settings         
        mode           
        src_norm   
        count           = []
        calc            = @trivial
        ntpl       
        funs            = {}
        normalize       = @makebeam
        % other parameters
        drc         (:,3)
        pol         (:,3)
        det         (:,1)
    end
    methods 
        function setbake(o, X, Y, Z)
            sz = size(X);
            pos = [X(:) Y(:) Z(:)];  
            % Group up the beams according to these fields
            % For each beam, calculate it's intensity at the grid points and add
            % them up
            [beams_grouped, vals] = groupbyfields(["det", "drc", "pol"], o.src_norm);
            bake_grp = @(bs) fold_a(@(b, I) I + b.calcI(pos), 0, bs);
            count_grp = length(beams_grouped);
            
            % Calculate the intensity for each group
            I_grouped = map_c(bake_grp, beams_grouped);
            I_baked = reshape(cell2mat(I_grouped), [sz count_grp]);
            
            o.count = count_grp;
            % Other parameters for each part of the light field
            o.drc = reshape([vals.drc], [3, count_grp,])';
            o.pol = reshape([vals.pol], [3, count_grp,])';
            o.det = reshape([vals.det], [1, count_grp,])';
            % Convert the baked field to interpolant function
            o.ntpl = griddedInterpolant(X, Y, Z, I_baked, "linear", "linear");
            o.funs = [];
            o.calc = @(pos) reshape(o.ntpl(pos(:,1), pos(:,2), pos(:,3)), [size(pos, 1), count_grp]);
        end
        function setinsitu(o)
            len = length(o.src_norm);
            beamfuns = {o.src_norm.calcI};

            o.count = len;            
            
            o.drc = reshape([o.src_norm.drc], [3, len])';
            o.pol = reshape([o.src_norm.pol], [3, len])';
            o.det = reshape([o.src_norm.det], [1, len])';

            o.ntpl = []; 
            o.funs = beamfuns;

            function I = applyfuns(pos)
                I = zeros([size(pos, 1) len]);
                % non-paralell performs better here
                for i = 1 : len
                    I(:,i) = beamfuns{i}(pos);
                end
            end

            o.calc = @applyfuns;
        end
        function o = EnvLight()
            o.settings        = FieldSettings();
            o.mode            = [];
            o.src_norm        = [];
            o.count           = 0;
            o.calc            = @trivial;
            o.ntpl            = [];
            o.funs            = {};
            o.normalize       = @makebeam;
            o.drc             = nan([0, 3]);
            o.pol             = nan([0, 3]);
            o.det             = nan([0, 1]);
        end
    end
end