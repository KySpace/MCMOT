% calculate normalized parameters for beams
function b = makebeam(consts, p)
    function calc = choosecalc(p)
        switch p.profile
            case "gaussian"
                I_max_rel = 2*p.power/(pi*p.w_0^2) / consts.I_sat_iso;
                calc = @(pos) calcI_gau(p.ctr, p.drc, p.w_0, I_max_rel, pos);
            case "circuni"
                I_max_rel = p.power/ (pi*p.w_0^2)/ consts.I_sat_iso;
                calc = @(pos) calcI_circ(p.ctr, p.drc, p.w_0, I_max_rel, pos);
            otherwise; calc = @trivial; warning("Profile not supported yet");     
        end
    end
    b.drc = p.drc;
    b.pol = p.pol;
    b.det = p.det / consts.semilw;
    b.calcI = choosecalc(p);    
end

