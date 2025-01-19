function Av = dotvec(A, v)
arguments
    A       (:,3)
    v       (1,3)
end
    Av = sum(A .* v, 2);
end