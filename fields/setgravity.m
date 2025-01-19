function gravity = setgravity(boundaries, acc)
    r = boundaries.rotation;
    gravity = FieldSettings;
    gravity.type = "gravity";
    gravity.info = struct( ...
        "acceleration", acc...
        );
    gravity.units = acc * [0,0,-1] * rotmat(deg2rad(r.roll), deg2rad(r.pitch), deg2rad(r.inhori));
end