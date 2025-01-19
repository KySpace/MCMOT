function [fig, updaters, gobj] = setparticleplotter(b, t, pos, alpha, sz, view_init, scale, rot_per_frame)
    arguments
        b
        t
        pos
        alpha
        sz
        view_init
        scale           = 1
        rot_per_frame   = 0.5
    end
    fig = setfigsifnone(101, ["annotation"]);
    ax = axes(fig);
    [rot, edges, vtx] = calcboundaries(b);
    vtx_tube_sample = linspace(0,2*pi,40)';
    vtx_tube_in = [t.r*cos(vtx_tube_sample), t.r*sin(vtx_tube_sample), b.hl        *ones(40,1)];
    vtx_tube_c1 = [t.r*cos(vtx_tube_sample), t.r*sin(vtx_tube_sample), t.range_z(1)*ones(40,1)];
    vtx_tube_c2 = [t.r*cos(vtx_tube_sample), t.r*sin(vtx_tube_sample), t.range_z(2)*ones(40,1)];
    tubes = [vtx_tube_in; vtx_tube_c1; vtx_tube_c2; [-t.r,0,t.range_z(2)]; [-t.r,0,b.hl]] * rot';
    m_vtx = [min([vtx;tubes])' max([vtx;tubes])'] * scale; 
    daspect(ax, [1 1 1]); view(ax, view_init);
    grid(ax, "on");
    pos = pos * rot';
    X = pos(:,1);
    Y = pos(:,2);
    Z = pos(:,3);

    keepax(ax);
    sc = scatter3(ax, X, Y, Z, "filled", AlphaData=alpha, SizeData=sz);    
    cuvette = plot3(ax, edges{:});     
    tube_in = plot3(ax, tubes(:,1), tubes(:,2), tubes(:,3));
    shutax(ax);

    ann = annotation(fig, "textbox", [0 0 0.94000 0.0600], LineStyle="none", String="time:");
    ax.XLim = m_vtx(1,:); ax.YLim = m_vtx(2,:); ax.ZLim = m_vtx(3,:);  
    arrayfun(@(l) set(l, "Color", [0 0 0]), cuvette);
    arrayfun(@(l) set(l, "Color", [0 0 0]), tube_in);
    function updatepos(pos)
        pos = pos * rot';
        sc.XData = pos(:,1);
        sc.YData = pos(:,2);
        sc.ZData = pos(:,3);
    end
    function updateann(step, dt, active, collected)
        ann.String = sprintf("time: %.5f s | step : %03i | active : %7i | collected : %7i | \n collected + active : %7i", ...
            step * dt, step, sum(active), sum(collected), sum(active) + sum(collected));
    end
    function updatealpha(vel_rel_log)
        alphatherm(sc, vel_rel_log, 4);
    end
    function updateclr(vel_rel_log)
        clrtherm(sc, vel_rel_log);
    end
    function updateclrforce(acl)
        neutr = -5;
        acl_log = log(sum(acl.*acl, 2))/2;
        sc.CData = truncatecond((acl_log - neutr) * [-0.2 0.05 0.1] + [0.5 0.5 0.5], 0, 1);
    end
    function updateclractive(active)
        clractivity(sc, active, 0.8);
    end
    function updateszactive(active)
        sizeactivity(sc, active, sz, 1);
    end
    function rotateview()
        view(ax, ax.View + [rot_per_frame, 0])
    end
    function plotvec(vec, pos, varargin)
        vec = vec * rot';
        pos = pos * rot';
        keepax(ax)
            quiver3(ax, pos(:,1), pos(:,2), pos(:,3), vec(:,1), vec(:,2), vec(:,3), 3, varargin{:});
        shutax(ax)
    end
    updaters.pos = @updatepos;
    updaters.ann = @updateann;
    updaters.alpha = @updatealpha;
    updaters.clractive = @updateclractive;
    updaters.szactivity = @updateszactive;
    updaters.clr = @updateclr;
    updaters.clrforce = @updateclrforce;
    updaters.plotvec = @plotvec;
    updaters.viewrot = @rotateview;
    gobj.ax = ax;
    gobj.ann = ann;
    gobj.sc = sc;
    gobj.cuvette = cuvette;
end