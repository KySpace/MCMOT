function [fig, updaters, gobj] = setfigvel(stat, cmax)
    arguments
        stat        MOTStatistics
        cmax        (1,1) {mustBeNumeric}
    end
    fig = setfigsifnone(102, ["annotation"]);
    ax_trsv = axes(fig);
    ax_long = axes(fig);
    ax_trsv.Position = [0.1 0.10 0.8 0.40];
    ax_long.Position = [0.1 0.55 0.8 0.40];    
    xLim = [min(stat.vel_stamps) - stat.v_step/2, max(stat.vel_stamps) + stat.v_step/2];
    yLim = [min(stat.t_stamps) - stat.dt*stat.num_acc/2, max(stat.t_stamps) + stat.dt*stat.num_acc/2];
    
    long = imagesc(ax_long, stat.vel_stamps, stat.t_stamps, stat.v_long_stat);
    trsv = imagesc(ax_trsv, stat.vel_stamps, stat.t_stamps, stat.v_trsv_stat);
    view(ax_long, [0 90]);
    view(ax_trsv, [0 90]);
    ax_long.XLim = xLim; ax_long.YLim = yLim; ylabel(ax_long, "longitudinal");
    ax_trsv.XLim = xLim; ax_trsv.YLim = yLim; ylabel(ax_trsv, "transverse");
    clrbarifnone(ax_trsv);
    clrbarifnone(ax_long);
    clim(ax_trsv, [0 cmax]);
    clim(ax_long, [0 cmax]);
    ann = annotation(fig, "textbox", [0 0 1 0.06], LineStyle="none", String="time:", ...
        FontName="Cascadia Mono");
    function updatevel()
        long.CData = stat.v_long_stat;
        trsv.CData = stat.v_trsv_stat;
    end
    function updateann()
        ann.String = sprintf("time: %.5f s | step : %03i | slow count: %7i (log(v_{rel;trsv}) < %2.2f) | active : %7i | respawned : %7i | \n" + ...
            "sample number : %i | slow rate : %f | collected : %i", ...
            stat.iter_now * stat.dt, stat.iter_now, stat.n_slow_iter_now, stat.v_rel_log_max, ...
            stat.n_active_iter_now, stat.n_respawned_iter_now, ...
            stat.n_sample_iter_now, stat.ratio_accept_iter_now, stat.n_collect_iter_now);
    end
    updaters.veldistr = @updatevel;
    updaters.ann_vel = @updateann;
    gobj.ann_vel = ann;
    gobj.ax_long = ax_long;
    gobj.ax_trsv = ax_trsv;
    gobj.surf_long = long;
    gobj.surf_trsv = trsv;
end