% Script for visualization of results of Fds for MassStep- and KleinStep
% szenarions with open boundary condition in x-direction
%
% see also: A_KleinStep, A_MassStep 
% 

%% evaluate result %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Evaluating Results:')
time = sol_u.time;

[xx,yy] = meshgrid(x,y);
xx_rescaled = xx*197.327; %nm
yy_rescaled = yy*197.327; %nm
vtd_w  = vizToolData(1, {xx_rescaled, yy_rescaled}, ...
    @(ax,x,y,z) surfw(ax,x,y,z,[0,90], sigma),...
    {'x / nm', 'y / nm', 'w'}, ...
    'SliderLabel', 'e-16 s', ...
    'Title', 'Probability density');
vtd_p = vizToolData(1, {}, ...
    @(ax, p) probabilityPlot(ax, p, time),...
    {'p'},...
    'SliderLabel', 'e-16 s', ...
    'Title', 'Probability to find the particle');
vtd_phi = vizToolData(3, {xx_rescaled, yy_rescaled}, ...
    @(ax,x,y,z,r,g) spinorPhasePlot(ax,x,y,z,r,g, sigma),...
    {'x / nm', 'y / nm', 'w'}, ...
    'SliderLabel', 'e-16 s', ...
    'Title', 'Probability density with phase information',...
    'UpdateFnc', @(ax, x, y, w, r, g) spinorPhaseUpdate(ax, x, y, w, r, g));

prog = 0;
idx_picture_frame = sigma == 0;
p = NaN(size(time));
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
    
    % probability
    w(~idx_picture_frame) = 0;
    p(idx_t) = trapz(dy,trapz(dx, w,2));
    vtd_p.addData(t, p);
end

disp([num2str(100,'%.0f') '% '])
vizTool(vtd_w, vtd_w, vtd_p)

%% subroutines for plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function surfw(ax,x,y,z,v, sigma)
     
     % plot3(ax, [0,0], [-1.5, 1.5], [30,30], '-r')
     zl = zlim(ax);
     sigma(sigma > 0) = max(z(:));
     sigma(sigma == 0) = NaN;
     C = ones(size(x));
     C(:,:,2) = zeros(size(x));
     C(:,:,3) = zeros(size(x));
     surf(ax, x, y, sigma, C,'FaceAlpha',0.3, 'EdgeColor', 'None' )
     
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

function probabilityPlot(ax, p, t)
    
    plot(ax, t, ones(size(t)),'--k');
    hold(ax, 'on')
        plot(ax, t, 0*ones(size(t)),'--k');
        plot(ax, t, p , '-k');
    hold(ax, 'off')
    
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

function spinorPhasePlot(ax, x, y, w, r, g, sigma)

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
    sigma(sigma > 0) = max(w(:));
    sigma(sigma == 0) = NaN;
    C = ones(size(x));
    C(:,:,2) = zeros(size(x));
    C(:,:,3) = zeros(size(x));
    surf(ax, x, y, sigma, C,'FaceAlpha',0.3, 'EdgeColor', 'None')
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

