function uvec = normalizevec(v)
    uvec = v ./ calcnormvec(v);
end