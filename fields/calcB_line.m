function B = calcB_line(ctr, drc, head, tail, jvec, pos)    
    n = size(pos, 1);
    rho = projvec(pos - ctr, drc);
    j_rep = repmat(jvec, [n 1]);
    rho_mag_sq = sum(rho .^ 2, 2);
    dist_tail = sum(dotvec(pos - tail, drc), 2);
    dist_head = sum(dotvec(pos - head, drc), 2);
    ang_coeff = dist_tail ./ sqrt(dist_tail.^2 + rho_mag_sq) ...
              - dist_head ./ sqrt(dist_head.^2 + rho_mag_sq);
    B =  - 1 ./ rho_mag_sq .* cross(rho, j_rep) .* ang_coeff;
end