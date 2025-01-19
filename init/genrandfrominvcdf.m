function [samples, sample_rate] = genrandfrominvcdf(cdf, invcdf, range, sz)
arguments
    cdf        {mustBeFunctionHandle}    
    invcdf     {mustBeFunctionHandle}
    range       (1,2)
    sz
end
    range_c = cdf(range);
    c = unifrnd(range_c(1), range_c(2), sz);
    samples = invcdf(c);
    sample_rate = range_c(2) - range_c(1);
end