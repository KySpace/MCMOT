classdef CurrUnit
    properties
        shape
        drc
        ctr
        size
        mag
    end
    methods
        function curr = CurrUnit(shape, drc, ctr, size, mag)
            arguments
                shape       {mustBeMember(shape, ["line" "circle"])}
                drc         (1,3)
                ctr         (1,3)
                size        (1,1)
                mag         (1,1)
            end
            curr.shape = shape;
            curr.drc   = drc  ; 
            curr.ctr   = ctr  ; 
            curr.size  = size ; 
            curr.mag   = mag  ;  
        end
    end
end