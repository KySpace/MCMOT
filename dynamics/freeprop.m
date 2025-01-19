function M_prop = freeprop(dt)
arguments; dt (1,1); end
M_prop = eye(6) + [zeros(3) zeros(3); eye(3) zeros(3)] * dt;
end