function [dist, sample_rate, cdf] = randgenfrompdf(pdf, range, step, range_full)
arguments
    pdf     {mustBeFunctionHandle}
    range   (1,2)
    step    (1,1)
    range_full
end
    x = linspace(range(1), range(2), step); 
    p = pdf(x);
    c = cumsum(p); c = [0, c / c(end)];
    x = [x (x(end)+step)];
    step_full = round((range_full(2) - range_full(1)) / (range(2) - range(1)) * step);
    x_full = linspace(range_full(1), range_full(2), step_full); 
    p_full = pdf(x_full);
    c_full = cumsum(p_full); c_full = [0, c_full / c_full(end)];
    x_full = [x_full (x_full(end) + step_full)];
    cdf = griddedInterpolant(x_full, c_full, "linear");
    sample_rate = cdf(range(2)) - cdf(range(1));
    dist = makedist("PiecewiseLinear", x=x, Fx=c);
end