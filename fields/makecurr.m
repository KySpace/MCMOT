function c = makecurr(consts, p)    
    function calc = choosecalc(p)
        switch p.shape
            case "line"
                head = p.ctr + p.drc * p.size;
                tail = p.ctr - p.drc * p.size;
                jvec = p.drc * p.mag;
                calc = @(pos) consts.mu_0 / (2*pi) * calcB_line(p.ctr, p.drc, head, tail, jvec, pos);
            case "circle"
                calc = @(pos) consts.mu_0 * calcB_circ(p.ctr, p.drc, p.size, p.mag, pos);
            otherwise; error("Segment shape not supported yet.");    
        end
    end
    c.calcB = choosecalc(p);
end