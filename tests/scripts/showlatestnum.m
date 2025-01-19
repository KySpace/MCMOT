testpath = "C:/Users/ky/Dropbox (GaTech)/Parker-Group/SimuMOT/[2024.05.16].ReflImbalance/57.Block.SubOptimized.[refl=0.75].1/";
% testpath = io.devices.savepath + "/";
ioconfig = loadioconfig(testpath + "ioconfig.yaml", "[TestRunner]/convert/ioconfig.convrules.yaml");

testpath = sprintf("%s/%s/%s/", testrootdir, ioconfig.SavePath.TestFolder, ioconfig.SavePath.TestName);
load(testpath + "Nan.SchemeInfo.mat", "saveddata"); testscheme = saveddata;

i_vary_act = [];

for i_v = 1 : numel(testscheme.fn_vary)
    sz_vary_i = testscheme.sz_vary(i_v);
    if sz_vary_i > 1; i_vary_act = [i_vary_act i_v]; end
end

sz_vary_act = testscheme.sz_vary(i_vary_act);
if numel(sz_vary_act) < 2; sz_vary_act = [sz_vary_act 1]; end
ratio_tab_collected = nan(sz_vary_act);
ratio_tab_slow = nan(sz_vary_act);

for j_variation = 1 : testscheme.n_variation
    sub_j = cell([1 testscheme.n_variable]);
    sub_act_j = cell([1 numel(i_vary_act)]);
    [sub_j{:}] = ind2sub(testscheme.sz_vary, j_variation);
    [sub_act_j{:}] = sub_j{i_vary_act};
    sub_act_j = cell2mat(sub_act_j);
    load(sprintf("%s%i.%s", testpath, j_variation, "StatResult.mat"), "saveddata"); stat = saveddata;
    ratio_tab_collected(j_variation) = stat.n_collect_iter_now / stat.n_sample_iter_now;
    ratio_tab_slow(j_variation) = stat.ratio_accept_iter_now;
end


