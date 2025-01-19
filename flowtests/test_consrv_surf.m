%   ┌─↓─↓──┬┬
%   →      ││⇢
%   →      ││⇢
%   └─↑─↑──┴┴
%   flow from other boundaries ending up the target boundary forms the same
%   positional / velocity distribution
% Does the initial condition of: uniform density × MB vel 
%           yields the expected weighted MB distribution on any surface?

v_max = 100;   % 500 is a good value , m/s 
v_T = 137;
hw = 1;    % m
w = 2*hw;
l = 2; hl = l / 2;

is_within_w = @(pos) abs(pos(:,1)) < hw & abs(pos(:,2)) < hw;

clear pos vel
n = 1E7;   % number of particles in each iteration
iter_max = 1;
area_source = 2*w^2 + 4*w*l;
density_2d_src = n / area_source;
distr_pos_xy = makedist("Uniform", "lower", -hw, "upper", hw);
distr_pos_z  = makedist("Uniform", "lower", 0, "upper", l);
distr_vel    = makedist("Normal", "mu", 0, "sigma", v_T);

clear pos vel
[pos, vel, sample_rate, vel_ratio] = gendist_uniflow(n, hw*0.99, hl*0.99, v_T, v_max);  % so that the bottom source will not be counted
pos(:,3) = pos(:,3) + hl;
[xy, t] = cross_z_by(pos, vel);
mask_within_into = is_within_w(xy) & (t > 0);
xy_sel  = xy(mask_within_into, :) ;
t_sel   = t(mask_within_into, :)  ;
vel_sel = vel(mask_within_into, :);
pos_sel = pos(mask_within_into, :);

%% Is the target spatial distribution uniform?
ax_pos = setaxis(102, "xy position");
scatter(ax_pos, xy_sel(:,1), xy_sel(:,2), 1, "filled");
daspect(ax_pos, [1 1 1]); xlim(ax_pos, [-hw, hw]); ylim(ax_pos, [-hw, hw]);
%% What's the velocity distribution?
fig = figure(101); fig.Units = "normalized";
dv_bin = 5;
f_T = @(v) 1/(v_T*sqrt(2*pi)) * exp(-1/2*(v/v_T).^2);
f_T_weighted = @(v) abs(v) .* exp(-1/2*(v/v_T).^2) / v_T^2;
v_samp_xy = linspace(-v_max, v_max, 1000);
v_samp_z  = linspace(0, v_max, 1000);
n_target_exp = density_2d_src * w^2; % if the density of the target is the same as source surfaces
n_target = sum(mask_within_into);
N_xy = f_T(v_samp_xy)         / vel_ratio.para * dv_bin * n_target_exp;
N_z  = f_T_weighted(v_samp_z) / vel_ratio.flow * dv_bin * n_target_exp;
clearfigs(fig, "annotation");
ax_xy = axes(fig); ax_xy.Position = [0.08 0.1 0.38 0.8]; ax_xy.Box = "on";
ax_z = axes(fig) ; ax_z.Position = [0.54 0.1 0.38 0.8]; ax_z.Box = "on";
keepax(ax_xy)
histogram(ax_xy, vel_sel(:,1), BinWidth=dv_bin);
histogram(ax_xy, vel_sel(:,2), BinWidth=dv_bin);
plot(ax_xy, v_samp_xy, N_xy, LineWidth=2);
title(ax_xy, "xy");
shutax(ax_xy)
keepax(ax_z)
histogram(ax_z, -vel_sel(:,3), BinWidth=dv_bin);
plot(ax_z, v_samp_z, N_z, LineWidth=2);
title(ax_z, "z");
shutax(ax_z)
id =  char(randi([48 57],1,8));
an = annotation(fig, "textbox", LineStyle="none", ...
    String=sprintf("v_max=%f | v_T=%f | hw=%f | l=%f | n=%i | dv_bin=%f | n_target_exp=%f || n_target=%i | sample_rate=%f", ...
    v_max, v_T, hw, l, n, dv_bin, n_target_exp, n_target, sample_rate), Units="pixels", Interpreter="none");
an.Position = [20, 0, 1000, 40];
%%
saveas(ax_pos, sprintf("Trials/BoundarywMB.%s.PosDistr.svg", id));
saveas(fig, sprintf("Trials/BoundarywMB.%s.VelDistr.svg", id));
save(sprintf("Trials/BoundarywMB.%s.Vars.mat", id), "v_max", "v_T", "hw", "n", "density_2d_src", "area_source", "dv_bin");
function [xy, t] = cross_z_by(pos, vel)
    t = pos(:,3) ./ (-vel(:,3));
    xy = pos(:,1:2) + vel(:,1:2) .* t;
end