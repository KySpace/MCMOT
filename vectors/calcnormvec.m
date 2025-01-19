function n = calcnormvec(v)
    n = sqrt(sum(v .* v, 2));
end