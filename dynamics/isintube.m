function isin = isintube(t, pos)
    pos_trsvsq = pos(:,1) .^ 2 + pos(:,2) .^ 2;
    dr_sq = t.r ^ 2;
    isin = pos_trsvsq < dr_sq & pos(:,3) > t.start_z & pos(:,3) < t.range_z(2);
end