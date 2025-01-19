function c = logmagcalc(op)
arguments
    op      string      {mustBeMember(op, ["whole" "trsv" "long"])}
end
    switch op
        case "whole"
            projector = @(v) v(:,1) + v(:,2) + v(:,3);
        case "trsv"
            projector = @(v) v(:,1) + v(:,2);
        case "long"
            projector = @(v) v(:,3);
    end
    function o = calc(vel)
        velsq = vel .* vel;
        o = log(sqrt(projector(velsq)));
    end
    c = @calc;
end