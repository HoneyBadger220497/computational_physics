% testscript for visualisation tool 

clear, clc, close

%% set up sezanrio
time = linspace(0,3,100);

x = linspace(0,2*pi,100);
[xx,yy] = meshgrid(x,x);

%% setup data structures

vtd  = vizToolData(1, {xx,yy},...
    @(ax, xx,yy,zz) surfM(ax, xx,yy, zz),...
    {'x', 'y', 'z'}   ,   ...
    'SliderLabel', 's', ...
    'Title', 'Damped Wavefunction');

vtd2 = vizToolData(1, {x}, ...
    @(ax, x, y) plotM(ax, x, y) , ...
    {'x', 'z'},...
    'SliderLabel', 's', ...
    'Title', 'X-Z cut of wave');  

vtd3 = vizToolData(1, {},...
    @(ax, y) plotT(ax, x, time) , ...
    {'amplitude'}, ...
    'SliderLabel', 's', ...
    'Title', 'Amplitude of wave');  

% visualize
a = NaN(size(time));
for idx_t = 1:length(time)
    t = time(idx_t);
    a(idx_t) = exp(-t)*exp(1);
    vtd.addData(t, a(idx_t)*cos(xx+yy-t)); 
    vtd2.addData(t, a(idx_t)*cos(x-t)); 
    vtd3.addData(t, a);
end

vizTool(vtd, vtd2, vtd3)

%% subroutines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function surfM(ax, xx, yy, zz)
    surf(ax,xx,yy,zz)
    shading(ax, 'interp')
    view(ax, 45,15)
    zlim(ax, [-8,8])
    colormap(ax, 'Winter')
    caxis(ax, zlim());
    axis(ax, 'equal');
    xlim(ax, [0,2*pi])
    ylim(ax, [0,2*pi])
    zlim(ax, zlim(ax)) % fix zlimits
end

function plotM(ax, x, y)
    plot(ax, [0,2*pi],[0.0,0.0], '--k')
    hold(ax,'on')
    p1 = plot(ax, x, y, '-b');
    hold(ax, 'off')
    legend(p1,'f(x)')
    ylim(ax, exp(1)*[-1,1])
end

function plotT(ax, y, time)
    plot(ax, time, y, '-k');
    xlim(ax, [time(1),time(end)])
    ylim(ax, [0,exp(1)])
end