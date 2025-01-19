testpath = "C:\Users\ky\Dropbox (GaTech)\Parker-Group\SimuMOT\[2023.12.19].2D\38.StrongField.1";

% dist, B field, power
n_tot = nan(3,4,4);

for i_t = 1 : 48
load(sprintf("%s\\%i.StatResult.mat", testpath, i_t), "saveddata");
stat = saveddata;
n_tot(i_t) = sum(stat.n_tot);
end

compr = cell(4,4);
power = nan(4,4);
field = nan(4,4);

for i_b = 1 : 4
    for i_p = 1 : 4
        compr(i_b, i_p) = {sprintf("%i,%i,%i", n_tot(:, i_b, i_p))};
    end
end