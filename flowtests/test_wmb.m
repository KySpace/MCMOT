% Does the initial condition of: uniform density × MB vel 
%           yields the expected weighted MB distribution on any surface?

v_max = 500;   % 500 is a good value , m/s 
v_T = 137;
duration = 0.1;  % s
R = duration * v_max; % 100
w = 1;    % m

is_within_R = @(pos) sum(pos.^2, 2) < R^2;
is_within_w = @(pos) abs(pos(:,1)) < w & abs(pos(:,2)) < w;

clear pos vel
n = 1E8;   % number of particles in each iteration
iter_max = 10;
density_3d = n / R^3 / 4;
distr_pos_xy = makedist("Uniform", "lower", -R, "upper", R);
distr_pos_z  = makedist("Uniform", "lower", 0, "upper", R);
distr_vel = makedist("Normal", "mu", 0, "sigma", v_T);

xy_sel  = []; 
t_sel   = [];    
vel_sel = [];
pos_sel = [];

for j = 1 : iter_max
clear pos vel
pos(:,1:2) = random(distr_pos_xy, [n 2]); 
pos(:,3)   = random(distr_pos_z , [n 1]); % Is it the same as generating 3 randoms and then scale on each?
mask_within_R = is_within_R(pos);
pos = pos(mask_within_R,:);
vel = random(distr_vel, [n 3]);
vel = vel(mask_within_R,:);
[xy, t] = cross_z_by(pos, vel);
mask_within_into = is_within_w(xy) & (t > 0) & (t < duration);
xy_sel  = [ xy_sel  ; xy(mask_within_into, :) ];
t_sel   = [ t_sel   ; t(mask_within_into, :)  ];
vel_sel = [ vel_sel ; vel(mask_within_into, :)];
pos_sel = [ pos_sel ; pos(mask_within_into, :)];

end
ratio_r_R = sqrt(sum(pos_sel.^2, 2) / R^2);
%% Where is the origin of the particles that hit the target area?
% scatter3(pos_sel(:,1), pos_sel(:,2), pos_sel(:,3), 1);
% xlim([-R, R]); ylim([-R, R]); zlim([0, R]);
% daspect([1 1 1]);
%% Is the target spatial distribution uniform?
% scatter(xy_sel(:,1), xy_sel(:,2), 1, "filled");
% daspect([1 1 1]); xlim([-w, w]); ylim([-w, w]);
%% Do we sample a large enough v_max?
% histogram(ratio_r_R);
%% What's the velocity distribution?
fig = figure(101); fig.Units = "normalized";
dv_bin = 20;
f_T = @(v) 1/(v_T*sqrt(2*pi)) * exp(-1/2*(v/v_T).^2);
v_samp_xy = linspace(-v_max, v_max, 1000);
v_samp_z = linspace(0, v_max, 1000);
dens_area_duration = iter_max * density_3d * (4*w^2) * duration;
N_xy = f_T(v_samp_xy) * v_T      * dv_bin * dens_area_duration / sqrt(2*pi);
N_z  = f_T(v_samp_z) .* v_samp_z * dv_bin * dens_area_duration;
clearfigs(fig);
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
saveas(fig, sprintf("flowtests/TotalFreeMB.%s.VelDistr.svg", id));
save(sprintf("flowtests/TotalFreeMB.%s.Vars.mat", id), "v_max", "v_T", "duration", "R", "w", "n", "iter_max", "density_3d", "dens_area_duration", "dv_bin");
function [xy, t] = cross_z_by(pos, vel)
    t = pos(:,3) ./ (-vel(:,3));
    xy = pos(:,1:2) + vel(:,1:2) .* t;
end