function v = gendist_flow3d_trunc(n, v_T, truncv)
arguments
    n       (1,1)       % sample number
    v_T     (1,1)       % speed at one σ
    truncv  (1,1)
end
    v_norm = randn(n, 3);
    v_unit = v_norm ./ sqrt(sum(v_norm .* v_norm, 2));
    pdf = @(v) v.^3 .* exp(- (v/v_T).^2 / 2);
    td = randgenfrompdf(pdf, [0, truncv], 40, 2000);
    v = random(td, [n, 1]) .* v_unit;
end