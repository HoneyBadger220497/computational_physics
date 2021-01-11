% A_FreeGaussianWavepacketDirty
% Simulation of a free dirac fermion on a 2d-topological insolater surface.
% 
% The fermion is  loaclized at a position at the beginning and has a
% certain momentum
% The fermion is represented by a gaussian wavepacket, which is created in
% a dirt
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
params = setupDiscretisation(1,3,3);
ctime = linspace(0, params.cT, params.nt+1); %[time]

x0 = -2; % [distance] 
x = linspace(x0, x0 + params.Lx, 2*params.nx+1);
x = x(1:end-1);

y0 = -2; % [distance]
y = linspace(y0, y0 + params.Ly, 2*params.ny+1);
y = y(1:end-1);

[xx, yy] = meshgrid(x,y);

%% medium, mass, potetial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c = 1;           % average speed of particel [velocity]                
m = 2;        % massterm      [energy]
pot = 0;   % potetial      [energy] 

mass  = m*ones(size(xx));  
potential = pot*ones(size(xx)); 

time = ctime./c;
%% initial conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('constructing inital condition')

[u_init, v_init] = diracEq2D.constructGaussianDirty(...
    xx, ... %xx
    yy, ... %yy
    3, ...%kx0
    3, ...%ky0
    0.2 , ... %bx
    0.2 , ... %by
    'x0',  -0.5, ...
    'y0',  -0.5, ...
    'potential', pot, ...
    'mass', m, ...
    'c', c, ...
    'solution', 1, ...
    'normalize', true);

%% solve pde %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('start numerical solution process')

[sol_u, sol_v] = diracEq2D.solveEquation(...
    u_init, ...
    v_init, ...
    xx, ...
    yy, ...
    time, ...
    'c', c,...
    'mass', mass ,...
    'potential', potential);

disp('pde solved!')












