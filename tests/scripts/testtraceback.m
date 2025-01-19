testpath = "C:\Users\ky\Dropbox (GaTech)\Parker-Group\SimuMOT\[2023.12.19].2D\32.Block.VaryTube.1\";
for idx = 1:2
load(testpath + num2str(idx) + ".SimuResult.mat", "saveddata");
ic = saveddata.initcache;
b = saveddata.boundaries;
load(testpath + num2str(idx) + ".StatResult.mat", "saveddata");
st = saveddata;
thru = st.mask_thru;
ax = setaxis(3, "init");
[rot, edges, vtx] = calcboundaries(b); 
openax(ax)
pos_0 = ic.pos(thru, :) * rot';
vel_0 = ic.vel(thru, :) * rot';
scale = 0.00005;
cuvette = plot3(ax, edges{:}); 
qv = quiver3(ax, pos_0(:,1), pos_0(:,2), pos_0(:,3), vel_0(:,1)*scale, vel_0(:,2)*scale, vel_0(:,3)*scale, "off");
arrayfun(@(l) set(l, "Color", [0 0 0]), cuvette);
shutax(ax)
daspect(ax, [1 1 1]); view(ax, [-216,30]); grid(ax, "on");

vel_edges_ext = conv([-Inf st.vel_stamps Inf], [0.5, 0.5]);
vel_edges = vel_edges_ext(2:end-1);
ax_hist = setaxis(4, "velocities");
openax(ax_hist)
histogram(ax_hist, BinEdges=vel_edges, BinCounts=sum(st.v_long_stamp, 1));
histogram(ax_hist, BinEdges=vel_edges, BinCounts=sum(st.v_trsv_stamp, 1));
shutax(ax_hist)
saveas(ax, testpath + num2str(idx) + ".Backtrace.1.fig", "fig");
saveas(ax, testpath + num2str(idx) + ".Backtrace.1.png", "png");
view(ax, [-181,7.6]);
saveas(ax, testpath + num2str(idx) + ".Backtrace.2.png", "png");
saveas(ax_hist, testpath + num2str(idx) + ".Vel.png", "png");

S = calcsurfarea(b);
N_I = size(ic.pos, 1);
N_IFe = sum(ic.pos(:,3) <= -b.hl);
N_IFr = sum(ic.pos(:,3) <= b.hl - 0.02);
N_INr = sum(ic.pos(:,3) > b.hl - 0.02);
N_AFr = sum(ic.pos(thru,3) <= b.hl - 0.02);
N_ANr = sum(ic.pos(thru,3) > b.hl - 0.02);
N_A = sum(thru);
disp(table(N_I, N_IFe, N_IFr, N_INr, N_AFr, N_ANr, N_A));
end