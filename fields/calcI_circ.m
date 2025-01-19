% calculate the intensity of a circular uniform beam
function I = calcI_circ(ctr, drc, w_0, I_max, pos)
    rho = projvec(pos - ctr, drc) / w_0;
    I = I_max * (sum(rho.^2, 2) < 1); 
end