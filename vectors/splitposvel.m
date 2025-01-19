function [pos, vel] = splitposvel(posvel)
arguments
    posvel      (:,6)
end
pos = posvel(:,1:3); vel = posvel(:, 4:6);
end