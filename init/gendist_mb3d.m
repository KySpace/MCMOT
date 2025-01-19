% Generate maxwell boltzman distribution
function [v, nd_trunc] = gendist_mb3d(n, v_T, trunc)
arguments
    n       (1,1)       % sample number
    v_T     (1,1)       % speed at one σ
    trunc               = @id
end
    nd = makedist("Normal", "mu", 0, "sigma", v_T);
    nd_trunc = trunc(nd);
    v = random(nd_trunc, [n, 3]);
end