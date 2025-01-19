% Input     ctr: center position of the circle
%           drc: direction vector of the magnetic field on axis
%           rad: radius
%           mag: current magnitude
%           pos: position
function B = calcB_circ(ctr, drc, rad, mag, pos)
    n = size(pos, 1);
    dis = pos - ctr;
    vec_z = dis - projvec(dis, drc); z = dotvec(vec_z, drc);
    vec_h = dis - vec_z; h = calcnormvec(vec_h);
    uvec_h = vec_h ./ h; uvec_h(h == 0, :) = repmat([0 0 0], [sum(h == 0), 1]);
    uvec_z = drc;
    % n × 1, z^2 + r^2 + h^2
    U = z.^2 + h.^2 + rad^2;
    % n × 1
    W = 4 * h.^2 * rad^2 ./ U.^2;
    function f = fact1(x); f = factorial(x); end
    function f = fact2(x); f = prod(x:-2:1); end 
    function B_kh =  B_kh(k)
        B_kh = fact2(4*k+3) / (fact1(k)^2 * (k+1) * 4^(2*k)) * ...
                W .^ k;
    end
    function B_kz = B_kz(k)
        B_kz = 2*rad^2 * fact2(4*k+1) / (fact1(k)^2 * 4^(2*k)) * W.^k ./ U ...
                - fact2(4*k+3) / (fact1(k)^2 * (k+1) * 4^(2*k)) /4 * W.^(k+1);
    end
    B = mag ./ sqrt(U) /2 .* ( ...
                uvec_h .* z * rad^2 .*h ./ (2 * U.^2) .* fold_a(@(k, B) B+B_kh(k), 0, 0:10) ...
            +   uvec_z                                .* fold_a(@(k, B) B+B_kz(k), 0, 0:10) ...
        );
end