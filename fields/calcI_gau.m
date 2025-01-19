% calculate the intensity of a gaussian beam
function I = calcI_gau(ctr, drc, w_0, I_max, pos)
    rho = projvec(pos - ctr, drc) / w_0;
    I = I_max * exp(- 2 * sum(rho.^2, 2)); 
end