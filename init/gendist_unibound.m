function pos = gendist_unibound(n, hw, hl)
arguments
    n       (1,1)       % sample number
    hw      (1,1)       % half width
    hl      (1,1)       % half length
end
    % 0      markz/2      markz      1
    % | -- ±x -- | -- ±y -- | - ±z - |
    area_tot = hw*hw + 2*hl*hw;
    markz = 1 - hw*hw/area_tot; markxy = markz / 2;
    ud_one = rand([n 2]);
    dir = ud_one(:,1);
    sgn = (ud_one(:,2) > 0.5) * 1 + (ud_one(:,2) <= 0.5) * (-1);
    direction = [dir <= markxy, dir <= markz & dir > markxy, dir > markz];
    mult_surf2d = [1,1,1] - direction;
    proj_offset = direction .* sgn;

    udtrsv = makedist("Uniform", "lower", -hw, "upper", hw);
    udlgtd = makedist("Uniform", "lower", -hl, "upper", hl);
    pos(:, 1:2) = random(udtrsv, [n 2]);
    pos(:, 3)   = random(udlgtd, [n 1]);

    pos = pos .* mult_surf2d + proj_offset .* [hw hw hl];
end