function clrtherm(sc, active, value)
arguments
    sc
    active
    value       = 0.8
end
    clr = sc.CData;
    clr(~active,:) = value;
    sc.CData = clr;
end