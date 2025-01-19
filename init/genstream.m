function [pos_gen, vel_gen] = genstream(n, src)
    arguments
        n       (1,1)       {mustBeInteger}
        src     (1,1)       {mustHaveField(src, ["rng_delay" "vel_trsv" "vel_long" "pos_src" "offset_pos"])}
    end
    % Based on the source position, find the longitudinal direction and
    % transverse direction and unit normal distribution
    vec_long = - normalizevec(src.pos_src);    
    nd = makedist("Normal", "mu", 0, "sigma", 1);
    timedistr = ifthel(src.rng_delay(1) == src.rng_delay(2), ...
        @() makedist("Normal", "mu", src.rng_delay(1), "sigma", 0), ...
        @() makedist("Uniform", "lower", src.rng_delay(1), "upper", src.rng_delay(2)));
    rand_trsv = projvec(random(nd, [n 3]), vec_long);
    % The position of the stream with offset
    pos = repmat(src.pos_src, [n 1]) + rand_trsv * src.offset_pos;
    % The velocity distribution uniform in longitudinal and random in
    % transverse
    vel = vec_long * src.vel_long + rand_trsv * src.vel_trsv;
    % Create the delay effect
    pos = pos - vel .* random(timedistr, [n 1]);
    pos_gen = @() pos;
    vel_gen = @() vel;
end