% roll >> pitch >> inhori
function m = rotmat(roll, pitch, inhori)
    m = rotxy(inhori) * rotxz(pitch) * rotxy(roll);
end

function m = rot2d(rad)
    m = [   cos(rad) -sin(rad); ...
            sin(rad)  cos(rad)      ];
end

function m = rotxy(rad)
    m = blkdiag(rot2d(rad), 1);
end

function m = rotxz(rad)
    swapyz = blkdiag(1, [0 1; 1 0]);
    m = swapyz' * blkdiag(rot2d(rad), 1) * swapyz;
end