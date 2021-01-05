% A_FreeGaussianWavepacket
% Simulation of a free dirac fermion on a 2d-topological insolater surface.
% 
% The fermion is  loaclized at a position at the beginning and has a
% certain momentum
% The fermion is represented by a gaussian wavepacket, which is formed by a
% superposition of analytical plane wave solutions.
%
% NATURAL UNITS:
% units where: 
%   h_bar = 1   (planck constant)
%   c     = 1   (speed of light)
% 
% tabular of units:
% quantitiy     |  unit |     actual unit     |     SI unit
%   energy         1eV           1eV              1.60218e-19 J
%   time          1/1eV       h_bar / 1eV         6.58212e-16 s
%   distace       1/1eV     c * h_bar / 1eV       1.97327e-7  m
%   mass           1eV        1eV / c^2           1.78266e-36 kg
%   velocity        1             c               2.99792e+9  m/s
%   wavenumber     1eV      1ev / c * h_bar       
%

%% prepare matlab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;
addpath([pwd '\gui'])
addpath([pwd '\visualisation'])

%% setup computational domain %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = setupDiscretisation();
time = linspace(0, params.T, params.nt+1); %[time]

x0 = -1; % [distance] 
x = linspace(x0, x0 + params.Lx, 2*params.nx+1);
x = x(1:end-1);

y0 = -1; % [distance]
y = linspace(y0, y0 + params.Ly, 2*params.ny+1);
y = y(1:end-1);

[xx, yy] = meshgrid(x,y);

%% medium, mass, potetial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c = 1;           % average speed of particel [velocity]                
mass = 2;        % massterm      [energy]
pot = 0;   % potetial      [energy] 

M_plus  = (pot + mass)/(1i*c)*ones(size(xx));  
M_minus = (pot - mass)/(1i*c)*ones(size(xx)); 

%% initial conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('constructing inital condition')

gwp = diracEq2D.constructGaussianPol(...
    3, ...  %kx0
    3, ...  %ky0
    0.05 , ... %b
    30*pi, ...
    1*pi/(params.Lx), ...
    1*pi/(params.Ly), ...
    't0',  0, ...
    'x0',  -0.5, ...
    'y0',  -0.5, ...
    'potential', pot, ...
    'mass', mass(1), ...
    'c', c, ...
    'solution', 1, ...
    'volumen', params.Lx*params.Ly);

[u_init, v_init] = gwp.getComponent(xx, yy, 0);
% ToDo: construct u_init at time t = -dt.

figure(1)
surf(xx,yy, abs(u_init).^2 + abs(v_init).^2)
view(0,90)
shading interp
title('Inital Condition')
colorbar()

%% solve pde %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('start numerical solution process')

[sol_u, sol_v] = diracEq2D.solveEquation(...
    u_init, ...
    v_init, ...
    xx, ...
    yy, ...
    time, ...
    'M_plus', M_plus,...
    'M_minus', M_minus);

%% evaluate result %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('pde solved! Evaluating Results')
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













