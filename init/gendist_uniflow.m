function [pos, vel, sample_rate, vel_ratio] = gendist_uniflow(n, hw, hl, v_T, truncv)
    arguments
        n       (1,1)       % sample number
        hw      (1,1)       % half width
        hl      (1,1)       % half length
        v_T     (1,1)       % speed at one σ
        truncv  (1,1)
    end
        % 0      markz/2      markz      1
        % | -- ±x -- | -- ±y -- | - ±z - |
        area_tot = hw*hw + 2*hl*hw;
        markz = 1 - hw*hw/area_tot; markxy = markz / 2;
        % n × 2
        ud_one = rand([n 2]);
        % n × 1
        dir = ud_one(:,1);
        % n × 1
        sgn = (ud_one(:,2) > 0.5) * 1 + (ud_one(:,2) <= 0.5) * (-1);
        % n × 3
        direction = [dir <= markxy, dir <= markz & dir > markxy, dir > markz];
        % n × 3
        mult_surf2d = [1,1,1] - direction;
        % n × 3
        proj_offset = direction .* sgn;
        unit_norm = - proj_offset;
        unit_para = mult_surf2d;
    
        distr_trsv = makedist("Uniform", "lower", -hw, "upper", hw);
        distr_lgtd = makedist("Uniform", "lower", -hl, "upper", hl);
        % pdf_flow = @(v) abs(v) .* exp(- (v/v_T).^2 / 2);
        % pdf_para = @(v) exp(- (v/v_T).^2 / 2);
        cdf_flow = @(v) 1 - exp(-(v/v_T).^2/2);
        cdf_para = @(v) (1 + erf(v/v_T/sqrt(2)))/2;
        invcdf_flow = @(x) v_T * sqrt(-2*log(1-x));
        invcdf_para = @(x) erfinv(2*x - 1) * sqrt(2) * v_T;
        [vel_norm, ratio_flow] = genrandfrominvcdf(cdf_flow, invcdf_flow, [0, truncv]      , [n 1]);
        [vel_para, ratio_para] = genrandfrominvcdf(cdf_para, invcdf_para, [-truncv, truncv], [n 3]);
        % n × 3
        pos(:, 1:2) = random(distr_trsv, [n 2]);
        pos(:, 3)   = random(distr_lgtd, [n 1]);
    
        pos = pos .* mult_surf2d + proj_offset .* [hw hw hl];
        vel = vel_norm .* unit_norm + vel_para .* unit_para;
        sample_rate = ratio_flow * ratio_para^2;
        vel_ratio.flow = ratio_flow;
        vel_ratio.para = ratio_para;
    end