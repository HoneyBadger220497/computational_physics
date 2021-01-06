% Script for the visualisation of the results of the calculations of free
% particles.
%
% also see: A_FreeGaussianWavepacket.m, A_FreeGaussianWavePacketDirty.m
%

%% evaluate result %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Evaluating Results:')
time = sol_u.time;

vtd_w  = vizToolData(1, {xx, yy}, ...
    @(ax,x,y,z) surfplus(ax,x,y,z,[0,90]),...
    {'x', 'y', 'w'}, ...
    'SliderLabel', 'e-16 s', ...
    'Title', 'Probability density');
vtd_jx = vizToolData(1, {xx, yy}, ...
    @(ax,x,y,z) surfplus(ax,x,y,z,[0,90]),...
    {'x', 'y', 'jx'},...
    'Title', 'Current density j_x in x-direction');
vtd_jy = vizToolData(1, {xx, yy}, ...
    @(ax,x,y,z) surfplus(ax,x,y,z,[0,90]),...
    {'x', 'y', 'jy'},...
    'Title', 'Current density j_y in y-direction');

prog = 0;
for idx_t = 1:length(time)
    
    % display progrss
    prog_new = idx_t/length(time);
    if prog_new - prog >= 0.1
        disp([num2str(prog,'%.2f') '% '])
        prog = prog_new;
    end
    
    t = time(idx_t)*6.58212;
    u = sol_u.solution(:,:,idx_t);
    v = sol_v.solution(:,:,idx_t);

    % probability density
    w = abs(u).^2 + abs(v).^2;
    vtd_w.addData(t, w);
    
    % current density in x direction
    jx = -2*c*imag(conj(u).*v);
    vtd_jx.addData(t, jx);
    
    % current density in y direction
    jy = 2*c*real(conj(u).*v);
    vtd_jy.addData(t, jy);
    
end

vizTool(vtd_w, vtd_jx, vtd_jy)

%% subroutines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function surfplus(ax,x,y,z,v)
    
    surf(ax,x,y,z);
    shading(ax, 'interp')
    view(ax, v(1),v(2))
    if all(v == [0,90])
            axis(ax, 'equal') % equal axis
            xlim(ax, xlim(ax))
            ylim(ax, ylim(ax))
    end
    zlim(ax, zlim(ax))
    caxis(ax, zlim(ax))       % fix_colormap
    colormap(ax, 'Default')
end

