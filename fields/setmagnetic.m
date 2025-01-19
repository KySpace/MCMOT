function magnetic = setmagnetic(type, d_cent_coil, mag_curr, rect, circle)
arguments
    type            (1,1)  {mustBeMember(type, ["cage_antihh_eq_rect" "cage_antihh_bias_rect" "tb_hh_eq_circle" "tb_antihh_eq_circle"])}    
    d_cent_coil
    mag_curr
    rect.hw_coil
    rect.hl_coil
    rect.bias_ud
    rect.bias_lr
    circle.radius
end
    magnetic = FieldSettings;
    magnetic.type = "magnetic";
    magnetic.info = struct( ...
                "type"                ,     type        , ...     
                "d_cent"              ,     d_cent_coil , ...
                "curr_mag"            ,     mag_curr    );
    d = d_cent_coil;
    switch type
        case "cage_antihh_eq_rect"   
            magnetic.info.hw = rect.hw_coil;
            magnetic.info.hl = rect.hl_coil;
            r = rect.hw_coil;
            f = rect.hl_coil;
            % side segments: Ru Ur Ul Lu Ld Dl Dr Rd, into the z direction
            Ru = CurrUnit("line", [0 0 1], [+d +r  0], f, +mag_curr);
            Ur = CurrUnit("line", [0 0 1], [+r +d  0], f, +mag_curr);
            Ul = CurrUnit("line", [0 0 1], [-r +d  0], f, -mag_curr);
            Lu = CurrUnit("line", [0 0 1], [-d +r  0], f, -mag_curr);    
            Ld = CurrUnit("line", [0 0 1], [-d -r  0], f, +mag_curr);
            Dl = CurrUnit("line", [0 0 1], [-r -d  0], f, +mag_curr);
            Dr = CurrUnit("line", [0 0 1], [+r -d  0], f, -mag_curr);
            Rd = CurrUnit("line", [0 0 1], [+d -r  0], f, -mag_curr);
            % end segments: Rm Um Lm Dm Rp Up Lp Dp , in the clockwise direct
            Rm = CurrUnit("line", [ 0 +1 0], [+d  0 -f], r, +mag_curr);
            Um = CurrUnit("line", [-1  0 0], [ 0 +d -f], r, -mag_curr);
            Lm = CurrUnit("line", [ 0 -1 0], [-d  0 -f], r, +mag_curr);
            Dm = CurrUnit("line", [+1  0 0], [ 0 -d -f], r, -mag_curr);
            Rp = CurrUnit("line", [ 0 +1 0], [+d  0 +f], r, -mag_curr);
            Up = CurrUnit("line", [-1  0 0], [ 0 +d +f], r, +mag_curr);
            Lp = CurrUnit("line", [ 0 -1 0], [-d  0 +f], r, -mag_curr);
            Dp = CurrUnit("line", [+1  0 0], [ 0 -d +f], r, +mag_curr);
            % currents of the coil segments
            magnetic.units = [Ru Ur Ul Lu Ld Dl Dr Rd Rm Um Lm Dm Rp Up Lp Dp];
        case "cage_antihh_bias_rect"   
            magnetic.info.hw = rect.hw_coil;
            magnetic.info.hl = rect.hl_coil;
            r = rect.hw_coil;
            f = rect.hl_coil;
            mag_curr_u = mag_curr * (1 + rect.bias_ud);
            mag_curr_d = mag_curr * (1 - rect.bias_ud);
            mag_curr_l = mag_curr * (1 + rect.bias_lr);
            mag_curr_r = mag_curr * (1 - rect.bias_lr);
            % side segments: Ru Ur Ul Lu Ld Dl Dr Rd, looking into the z direction
            Ru = CurrUnit("line", [0 0 1], [+d +r  0], f, +mag_curr_r);
            Ur = CurrUnit("line", [0 0 1], [+r +d  0], f, +mag_curr_u);
            Ul = CurrUnit("line", [0 0 1], [-r +d  0], f, -mag_curr_u);
            Lu = CurrUnit("line", [0 0 1], [-d +r  0], f, -mag_curr_l);    
            Ld = CurrUnit("line", [0 0 1], [-d -r  0], f, +mag_curr_l);
            Dl = CurrUnit("line", [0 0 1], [-r -d  0], f, +mag_curr_d);
            Dr = CurrUnit("line", [0 0 1], [+r -d  0], f, -mag_curr_d);
            Rd = CurrUnit("line", [0 0 1], [+d -r  0], f, -mag_curr_r);
            % end segments: Rm Um Lm Dm Rp Up Lp Dp , in the clockwise direct
            Rm = CurrUnit("line", [ 0 +1 0], [+d  0 -f], r, +mag_curr_r);
            Um = CurrUnit("line", [-1  0 0], [ 0 +d -f], r, -mag_curr_u);
            Lm = CurrUnit("line", [ 0 -1 0], [-d  0 -f], r, +mag_curr_l);
            Dm = CurrUnit("line", [+1  0 0], [ 0 -d -f], r, -mag_curr_d);
            Rp = CurrUnit("line", [ 0 +1 0], [+d  0 +f], r, -mag_curr_r);
            Up = CurrUnit("line", [-1  0 0], [ 0 +d +f], r, +mag_curr_u);
            Lp = CurrUnit("line", [ 0 -1 0], [-d  0 +f], r, -mag_curr_l);
            Dp = CurrUnit("line", [+1  0 0], [ 0 -d +f], r, +mag_curr_d);
            % currents of the coil segments
            magnetic.units = [Ru Ur Ul Lu Ld Dl Dr Rd Rm Um Lm Dm Rp Up Lp Dp];
        case "tb_hh_eq_circle"
            r = circle.radius;            
            T = CurrUnit("circle", [0 0 +1], [0 0 +d], r, mag_curr);
            B = CurrUnit("circle", [0 0 +1], [0 0 -d], r, mag_curr);
            magnetic.units = [T B];  
        case "tb_antihh_eq_circle"
            r = circle.radius;            
            T = CurrUnit("circle", [0 0 +1], [0 0 +d], r, mag_curr);
            B = CurrUnit("circle", [0 0 -1], [0 0 -d], r, mag_curr);
            magnetic.units = [T B];  
    end
end