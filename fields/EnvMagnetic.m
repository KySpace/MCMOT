classdef EnvMagnetic < EnvField
    properties
        settings   
        mode       
        src_norm   
        count           = []
        calc       
        ntpl       
        funs
        normalize       = @makecurr
        rcrds           = struct();
    end
    methods 
        function setbake(o, X, Y, Z)
            sz = size(X);
            pos = [X(:) Y(:) Z(:)];  
            B_baked = fold_a(@(c, B) B + c.calcB(pos), 0, o.src_norm);
            o.rcrds.pos = pos; o.rcrds.B = B_baked;
            B_baked = reshape(B_baked, [sz 3]);            
            % Convert the baked field to interpolant function
            o.ntpl = griddedInterpolant(X, Y, Z, B_baked, "linear", "linear");
            o.funs = [];
            o.calc = @(pos) reshape(o.ntpl(pos(:,1), pos(:,2), pos(:,3)), [size(pos, 1), 3]);
        end
        function setinsitu(o)
            len = length(o.src_norm);
            currfuns = {o.src_norm.calcB};

            o.count = len;    
            o.ntpl = []; 
            o.funs = currfuns;

            function B = applyfuns(pos)
                B = zeros([size(pos, 1) 3 len]);
                parfor i = 1 : len
                    B(:,:,i) = currfuns{i}(pos);
                end
                B = sum(B, 3);
            end

            o.calc = @applyfuns;
        end
        function o = EnvMagnetic()
            o.settings        = FieldSettings();
            o.mode            = [];
            o.src_norm        = [];
            o.count           = 0;
            o.calc            = @trivial;
            o.ntpl            = [];
            o.funs            = {};
            o.normalize       = @makecurr;
        end
    end
end