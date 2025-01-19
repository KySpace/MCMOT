% generate meshgrids with the beam centers denser
function [X, Y, Z] = gengrid_beams(hw, hl, beams, samp_norm)
arguments
    hw      (1,1)           % half width
    hl      (1,1)           % half length
    beams  (1,:)  BeamUnit  % beams that we may care about
    samp_norm (1,:)  {mustBeNonnegative} = [0 0.2 1]      % positive sampling points normalized
end   
    function arr = folder(b, arr)
        switch b.profile
            case "gaussian"
                fullsample_norm = [samp_norm -samp_norm];
                steps = repmat(fullsample_norm',3) * b.w_0;
                arr = [arr; b.ctr + steps];
            case "circuni"
                fullsample_norm = [samp_norm -samp_norm];
                steps = repmat(fullsample_norm',3) * b.w_0;
                arr = [arr; b.ctr + steps];
            otherwise
                error("Other profiles not supported");
        end
    end
    xyz = fold_a(@folder, [0 0 0], beams);
    x_arr = [xyz(:, 1)' hw -hw];
    y_arr = [xyz(:, 2)' hw -hw];
    z_arr = [xyz(:, 3)' hl -hl];
    x_arr = sort(unique(x_arr));
    y_arr = sort(unique(y_arr));
    z_arr = sort(unique(z_arr));
    [X, Y, Z] = ndgrid(x_arr, y_arr, z_arr);
end