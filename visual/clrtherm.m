function clrtherm(sc, v_rel_log, clrcool, neutr, clrneutr)
arguments
    sc
    v_rel_log
    clrcool         = [-0.2 0.05 0.1] 
    neutr           = 2
    clrneutr        = [0.5 0.5 0.5]
end
    sc.CData = truncatecond(- (v_rel_log - neutr) * clrcool + clrneutr, 0, 1);
end