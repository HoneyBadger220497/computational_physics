% A_KleinStep
% Simulation of a dirac fermion on a 2d-topological insolater surface
% interaction with a Klein-step. (Potenital step at x == 0).
% 
% The fermion is  loaclized at a position at the beginning and has a
% certain momentum
%
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
x0 = -1; % [distance]
y0 =  -0.5; % [distance]
params = setupDiscretisation(1, 2, 1); %default values: (T, Lx, Ly)

ctime = linspace(0, params.cT, params.nt+1); %[time]

x = linspace(x0, x0 + params.Lx, 2*params.nx+1);
x = x(1:end-1);

y = linspace(y0, y0 + params.Ly, 2*params.ny+1);
y = y(1:end-1);

[xx, yy] = meshgrid(x,y);

%% medium, mass, potetial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c = 1e-4;  % average speed of particel [velocity]                
m = 0;  % massterm      [energy]
pot1 = 0;  % potetial      [energy] [ev]
pot2 = 0.009; % potetial      [energy] [ev]

potential = pot1*ones(size(xx));
potential(xx > 0) = pot2; 
mass = m*ones(size(xx));

time = ctime./c;
%% initial conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('constructing inital condition')

gwp = diracEq2D.constructGaussianPol(...
    100, ...   %kx0
    0, ...    %ky0
    0.05 , ... %b
    30*pi, ...
    1*pi/(params.Lx), ...
    1*pi/(params.Ly), ...
    't0',  0, ...
    'x0', -0.3, ...
    'y0', 0, ...
    'potential', pot1, ...
    'mass', m, ...
    'c', c, ...
    'solution', 1, ...
    'volumen', params.Lx*params.Ly);
[u_init, v_init] = gwp.getComponent(xx, yy, 0);
% ToDo: construct u_init at time t = -dt.

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

disp('Pde solved!')







