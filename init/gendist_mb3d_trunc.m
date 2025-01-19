function v = gendist_mb3d_trunc(n, v_T, truncv)
arguments
    n       (1,1)       % sample number
    v_T     (1,1)       % speed at one σ
    truncv  (1,1)
end
    nd = makedist("Normal", "mu", 0, "sigma", v_T);
    nd_trunc = truncate(nd, -truncv, truncv);
    v = random(nd_trunc, [n, 3]);
end