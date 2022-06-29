% Script for visualization of results of Fds for MassStep- and KleinStep
% szenarions. 
%
% see also: A_KleinStep, A_MassStep 
% 

%% evaluate result %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Evaluating Results:')
time = sol_u.time;

xx_rescaled = xx*197.327; %nm
yy_rescaled = yy*197.327; %nm
vtd_w  = vizToolData(1, {xx_rescaled, yy_rescaled}, ...
    @(ax,x,y,z) surfw(ax,x,y,z,[0,90]),...
    {'x / nm', 'y / nm', 'w'}, ...
    'SliderLabel', 'e-16 s', ...
    'Title', 'Probability density');
vtd_jx = vizToolData(1, {xx_rescaled, yy_rescaled}, ...
   @(ax,x,y,z) surfj(ax,x,y,z,[0,90]),...
   {'x / nm', 'y / nm', 'jx'},...
   'SliderLabel', 'e-16 s', ...
   'Title', 'Current density j_x in x-direction');
vtd_jy = vizToolData(1, {xx_rescaled, yy_rescaled}, ...
    @(ax,x,y,z) surfj(ax,x,y,z,[0,90]),...
    {'x / nm', 'y / nm', 'jy'},...
    'SliderLabel', 'e-16 s', ...
    'Title', 'Current density j_y in y-direction');
vtd_p = vizToolData(3, {}, ...
    @(ax, p1, p2, p3) probabilityPlot(ax, p1, p2, p3, time),...
    {'time ', 'p'},...
    'SliderLabel', 'e-16 s', ...
    'Title', 'Probability to find the particle');
vtd_phi = vizToolData(3, {xx_rescaled, yy_rescaled}, ...
    @(ax,x,y,z,r,g) spinorPhasePlot(ax,x,y,z,r,g),...
    {'x / nm', 'y / nm', 'w'}, ...
    'SliderLabel', 'e-16 s', ...
    'Title', 'Probability density with phase information',...
    'UpdateFnc', @(ax, x, y, w, r, g) spinorPhaseUpdate(ax, x, y, w, r, g));

prog = 0;
idx_domain1 = xx <= 0;
idx_domain2 = xx >= 0;
p1 = NaN(size(time));
p2 = NaN(size(time));
dx = x(2)-x(1);
dy = y(2)-y(1);
for idx_t = 1:length(time)
    
    % display progrss
    prog_new = idx_t/length(time);
    if prog_new - prog >= 0.1
        disp([num2str(prog*100,'%.0f') '% '])
        prog = prog_new;
    end
    
    t = time(idx_t)*6.58212;
    u = sol_u.solution(:,:,idx_t);
    v = sol_v.solution(:,:,idx_t);

    % probability density
    w = abs(u).^2 + abs(v).^2;
    vtd_w.addData(t, w);
    
    phi = angle(u);
    [r,g] = mapSpinorPhaseToRGB(w,phi);
    vtd_phi.addData(t, w, r, g);
    
    % current density in x direction
    % jx = -2*c*imag(conj(u).*v);
    % vtd_jx.addData(t, jx);
    
    % current density in y direction
    % jy = 2*c*real(conj(u).*v);
    % vtd_jy.addData(t, jy);
    
    % probability
    w1 = w;
    w1(idx_domain2) = 0;
    w2 = w;
    w2(idx_domain1) = 0;
    p1(idx_t) = trapz(dy,trapz(dx, w1,2));
    p2(idx_t) = trapz(dy,trapz(dx, w2,2));
    vtd_p.addData(t, p1, p2, p1+p2);
end

disp([num2str(100,'%.0f') '% '])
vizTool(vtd_phi, vtd_w, vtd_p)

%% subroutines for plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function surfw(ax,x,y,z,v)
     
     % plot3(ax, [0,0], [-1.5, 1.5], [30,30], '-r')
     zl = zlim(ax);
     y0 = y(1,1);
     y1 = y(end,1);
     fill3(ax, [0,0,0,0,0],[y0,y1,y1,y0,y0],[0,0,1,1,0]*zl(2),'r','FaceAlpha',0.5)
     
     hold(ax, 'on')
     surf(ax,x,y,z, 'EdgeColor', 'None');
     % shading(ax, 'interp')
     view(ax, v(1),v(2))
     if all(v == [0,90])
             axis(ax, 'square') % equal axis
             xlim(ax, xlim(ax))
             ylim(ax, ylim(ax))
     end
     zlim(ax, zlim(ax))
     caxis(ax, zlim(ax))       % fix_colormap
     colormap(ax, 'Default')
     hold(ax, 'off')
     
end

function surfj(ax,x,y,z,v)
    
    surf(ax,x,y,z);
    shading(ax, 'interp')
    view(ax, v(1),v(2))
    if all(v == [0,90])
            axis(ax, 'square') % equal axis
            xlim(ax, xlim(ax))
            ylim(ax, ylim(ax))
    end
    zlim(ax, [-3,8])          % fix_axis
    caxis(ax, zlim(ax))       % fix_colormap
    colormap(ax, 'Default')
end

function probabilityPlot(ax, p1, p2, p3, t)
    
    plot(ax, t, ones(size(t)),'--k');
    hold(ax, 'on')
        plot(ax, t, 0*ones(size(t)),'--k');
        p3 = plot(ax, t, p3 , '-k');
        p2 = plot(ax, t, p2, '-b');
        p1 = plot(ax, t, p1, '-r');
    hold(ax, 'off')
    
    legend(...
        [p1,p2,p3],{'Particle left', 'Particle right', 'total probability'},...
        'Location','West')
    xlim(ax, [t(1),t(end)])
    ylim(ax, [-0.1,1.1])
end

function [r,g] = mapSpinorPhaseToRGB(w,phi)

    w = w./max(w(:));
    [r,g] = deal(cos(phi)) ;
    r(r>0) = 0; % red -> negative phase
    g(g<0) = 0; % green -> positve phase
    r = 1-abs(r).*w;
    g = 1-abs(g).*w;
end

function spinorPhasePlot(ax, x, y, w, r, g)

    c = r;
    c(:,:,2) = g;
    c(:,:,3) = 1-w./max(w(:));

    surf(ax, x, y, w , c, 'EdgeColor', 'None');
    % shading(ax, 'interp')
    view(ax, 0,90)
    axis(ax, 'square') % equal axis
    xlim(ax, xlim(ax))
    ylim(ax, ylim(ax))
    zl = zlim(ax);
    zlim(ax, zl)

    hold(ax, 'on')
    y0 = y(1,1);
    y1 = y(end,1);
    fill3(ax, [0,0,0,0,0],[y0,y1,y1,y0,y0],[0,0,1,1,0]*zl(2),'r','FaceAlpha',0.5)
    hold(ax, 'off')
    
end

function spinorPhaseUpdate(ax, x, y, w, r, g)

    c = r;
    c(:,:,2) = g;
    c(:,:,3) = 1-w./max(w(:));
    
    graphic_obj = ax.Children();
    
    set(graphic_obj(2), 'ZData', w);
    set(graphic_obj(2), 'CData', c);  
end

