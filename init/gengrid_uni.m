% generate meshgrids         
function [X, Y, Z] = gengrid_uni(hw, hl, gp)
arguments
    hw      (1,1)       % half width
    hl      (1,1)       % half length
    gp      (1,1)       % grid period
end
    x_arr = -hw : gp : hw;
    y_arr = -hw : gp : hw;
    z_arr = -hl : gp : hl;
    [X, Y, Z] = meshgrid(x_arr, y_arr, z_arr);
end