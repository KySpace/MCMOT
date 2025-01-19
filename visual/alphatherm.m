function alphatherm(sc, v_rel_log, neutr, alpha_neutr)
arguments
    sc
    v_rel_log
    neutr       = 0
    alpha_neutr = 0.5
end
    sc.AlphaData = truncatecond(- (v_rel_log - neutr), 0, 5) * alpha_neutr;
    sc.MarkerFaceAlpha = "flat";
end