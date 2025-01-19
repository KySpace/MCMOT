function Av = projvec(A, v)
arguments
    A       (:,3)
    v       (1,3)
end
    Av = A - sum(A .* v, 2) * v;
end