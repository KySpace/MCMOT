function [pos, vel] = walltemp(vel_distr, hw, hl, pos, vel)    
    sz = size(vel);
    randv = random(vel_distr, sz);
    hitpos = pos >  [hw hw hl];
    hitneg = pos < -[hw hw hl];
    hit = any(hitpos | hitneg, 2);
    flip = (randv > 0) & hitpos | (randv < 0) & hitneg;
    % make sure the newly generated velocity are towards the inner part of the chamber
    hit_coeff = hit .* (ones(sz) - 2 * flip);
    pos = (~hit - hit) .* pos + 2 * hitpos .* [hw hw hl] - 2 * hitneg .* [hw hw hl]; 
    vel = hit_coeff .* randv + ~hit .* vel;
end