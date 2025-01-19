function isin = isinboundortube(b, t, pos)
    isin = isinbound(b, pos) | isintube(t, pos);
end