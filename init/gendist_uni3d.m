% Generate maxwell boltzman distribution
function pos = gendist_uni3d(n, hw, hl)
arguments
    n       (1,1)       % sample number
    hw      (1,1)       % half width
    hl      (1,1)       % half length
end
    udtrsv = makedist("Uniform", "lower", -hw, "upper", hw);
    udlgtd = makedist("Uniform", "lower", -hl, "upper", hl);
    pos(:, 1:2) = random(udtrsv, [n 2]);
    pos(:, 3)   = random(udlgtd, [n 1]);
end