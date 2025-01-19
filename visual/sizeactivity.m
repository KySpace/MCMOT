function sizeactivity(sc, active, sz_active, sz_inactive)
arguments
    sc
    active
    sz_active
    sz_inactive
end
    sc.SizeData = active * sz_active + (~active * sz_inactive);
end