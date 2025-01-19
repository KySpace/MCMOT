function alphainactive(sc, active, alpha_active, alpha_inactive)
arguments
    sc
    active
    alpha_active
    alpha_inactive
end
    sc.AlphaData = active * alpha_active + (~active * alpha_inactive);
    sc.MarkerFaceAlpha = "flat";
end