ax = tmpax;
runwith("tests/ioconfig.yaml", "[TestRunner]/convert/ioconfig.convrules.yaml", mode="testat");
simu = io.runner.simu;
tp = io.testparams.get(1);
hw_coil = tp.B_params{1}.hw_coil;
hl_coil = tp.B_params{1}.hl_coil;
[X,Y,Z] = gengrid_uni(0.5 * hw_coil, 0.0 * hl_coil, 0.002);
pos = [X(:), Y(:), Z(:)];
B = simu.B_env.calc(pos);

openax(ax)
for i_b = 1 : size(B, 1)
quiver3(ax, pos(i_b,1), pos(i_b,2), pos(i_b,3), B(i_b,1), B(i_b,2), B(i_b,3), 0.03, LineWidth=8, Color=[0.1 0.4 0.5])
end
daspect([1,1,1]);
xlabel("")
shutax(ax)

% for i_c = 1 : length(currs)
%     c = currs(i_c);
%     pos = [c.ctr - c.size/2; c.ctr + c.size/2];
%     vec = c.ctr * c.mag;
%     % plot3(ax, pos(:,1), pos(:,2), pos(:,3), LineWidth=4, Color=[0.1 0.4 0.5]);
%     quiver3(ax, c.ctr(1), c.ctr(2), c.ctr(3), vec(1), vec(2), vec(3), 0.003, LineWidth=8, Color=[0.1 0.4 0.5]);    
% end