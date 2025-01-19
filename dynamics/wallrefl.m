function [pos, vel] = wallrefl(hw, hl, pos, vel)
    boundary = [hw hw hl];
    % make pos go from -bouandary to +3boundary (no offset)
    % to each dimension respectively,
    % modpos < boundary for inside the boundary
    % modpos >= boundary for over the boundary on either sides
    modpos = mod(pos + boundary, 4 * boundary) - boundary;
    free = (modpos < boundary); refl = 1 - free;
    pos = (free - refl) .* modpos + 2 * refl .* boundary;
    vel = (free - refl) .* vel;
end