%%% prepare Matlab
clc;
clear all;
close all;

addpath([pwd '\..\project2\visualisation'])
%% setup szenario
% particle params
mass = 0;
c = 0.01;

% time domain
T = 40;
dt = 0.0005;

n_t = T/dt;
time = linspace(0,T,n_t+1);

dt = time(2) - time(1);

% spacial domain
L0 = -10;
L1 = 10;
dx = 0.005;

n_x = (L1-L0)/dx;
x = linspace(L0,L1,2*n_x+1);
x = x(1:end-1);

% computaional domain
L0_c = -6;
L1_c = 6;

idx_ll = x < L0_c; % index of lower layer
idx_ul = x > L1_c; % index of upper layer 

pml_fnc = @(x) 0.1*x.^2;
sigma = zeros(size(x));
sigma(idx_ll) = pml_fnc(x(idx_ll)- L0_c);
sigma(idx_ul) = pml_fnc(L1_c - x(idx_ul));

% potetial
pot = 0;
potential = pot * ones(size(x)); 
%% inital condition
k = 100;
b = 1;
[u_init, v_init] = diracEq1D.constructGaussianDirty(...
    x, ...
    k, ...
    b, ...
    'x0', 0, ...
    'mass', mass, ...
    'c', c ,...
    'potential', pot, ...
    'volumen', L1_c-L0_c,...
    'normalize', false);

%% solve pde
[sol_u, sol_v] = diracEq1D.solveEquationPml(...
    u_init, ...
    v_init, ...
    x, ...
    time, ...
    sigma, ...
    potential, ...
    'c', c , ...
    'mass', mass);

%% visualize

disp('Evaluating Results:')
time = sol_u.time;

vtd_w  = vizToolData(1, {sol_u.xx}, ...
    @(ax,x,y) plotplus(ax,x,y),...
    {'x', 'w'}, ...
    'SliderLabel', 'e-16 s', ...
    'Title', 'Probability density');

prog = 0;
for idx_t = 1:length(time)
    
    % display progrss
    prog_new = idx_t/length(time);
    if prog_new - prog >= 0.1
        disp([num2str(prog,'%.2f') '% '])
        prog = prog_new;
    end
    
    t = time(idx_t)*6.58212;
    u = sol_u.solution(:,idx_t).';
    v = sol_v.solution(:,idx_t).';

    % probability density
    w = abs(u).^2 + abs(v).^2;
    vtd_w.addData(t, w);
    
end

vizTool(vtd_w, vtd_w, vtd_w)

%% subroutines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotplus(ax,x,y)
    
    plot(ax,x,y)
    ylim(ax,ylim(ax))
end


