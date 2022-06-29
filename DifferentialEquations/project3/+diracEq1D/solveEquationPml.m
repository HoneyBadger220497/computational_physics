function [sol_u, sol_v] = solveEquationPml(varargin)
% DESCRIPTION: 
% this function solves the (1+1)d dirac equation with a explicit staggerd 
% grid leapfrog finite difference sceme.
%
% TRANSPARENT BOUNDARIES:
% transparent boundary conditions are simulated with a Perfectly Matched
% Layer. 
%
% LEAPFROG SCEME ON STAGGERD GRID:
% The values of the spinor are stored on two staggerd layers.
% The v layers are always at time t_i. 
% The u_layers are stored at times t_i + 0.5*dt 
% In the places in between the u and v values, which are not used by the
% sceme, the mass/potential terms are stored.
%
% INPUT:
% required:
%  u_init      [nx x ny complex] inital condition u-component of spinor  
%  v_init      [nx x ny complex] inital condition v-component of spinor
%  x           [nx x ny double][distance]
%  time        [ 1 x nt double][time]
%  sigma       [nx x ny double] pml damping function
%  potential   [nx x ny double][energy]   potential-mass term 
% parameter:
%  c           [ 1 x  1 double][velocity] average particle speed
%  mass        [ 1 x  1 double][mass]     potential term 
%
% OUTPUT:
%  sol_u       [diracEq2D.FdsSolution] solution for u-component of spinor
%  sol_V       [diracEq2D.FdsSolution] solution for v-component of spinor
%
% NOTE: DATA STORAGE ------------------------------------------------------
% When reducing it to a 1-d layering structer one gets
%
% t_3 + 0.5 dt : - u - - - u - - - u - - - u - - -  <- req. for time interp
% t_3          : - - - v - - - v - - - v - - - v -  <- last timestep 
% t_2 + 0.5 dt : - u - - - u - - - u - - - u - - - 
% t_2          : - - - v - - - v - - - v - - - v -
% t_1 + 0.5 dt : - u - - - u - - - u - - - u - - - 
% t_1          : - - - v - - - v - - - v - - - v -
%  0  + 0.5 dt : - u - - - u - - - u - - - u - - - 
%  0           : - - - v - - - v - - - v - - - v -  <- v inital cond.
%  0  - 0.5 dt : - u - - - u - - - u - - - u - - -  <- u inital cond.
%
% NOTE:  NATURAL UNITS USED! ----------------------------------------------
% units where the follwoing holds are used: 
%   h_bar = 1   (planck constant)
%   c     = 1   (speed of light)
% 
% There relevant units are concretely tabularized here:
% quantitiy     |   unit  |     actual unit     |     SI unit
%  [energy]         1eV            1eV              1.60218e-19 J
%  [time]          1/1eV        h_bar / 1eV         6.58212e-16 s
%  [distace]       1/1eV      c * h_bar / 1eV       1.97327e-7  m
%  [mass]           1eV         1eV / c^2           1.78266e-36 kg
%  [velocity]        1              c               2.99792e+9  m/s
%  [wavenumber]     1eV       1ev / c * h_bar       
%

% input parse
ip = inputParser();
ip.addRequired('u_init', @(x) mod(length(x),2) == 0);
ip.addRequired('v_init', @(x) mod(length(x),2) == 0);
ip.addRequired('x', @(x) mod(length(x),2) == 0);
ip.addRequired('time');
ip.addRequired('sigma');
ip.addRequired('potential');
ip.addParameter('c', 1);
ip.addParameter('mass', 0);
ip.parse(varargin{:})

x = ip.Results.x;
time = ip.Results.time;
mass = ip.Results.mass;
potential = ip.Results.potential;
c = ip.Results.c;

sigma = ip.Results.sigma;
 
% descritisation params
dx = x(2)-x(1); %assume constant discretisation
dt = time(2)-time(1);

% init staggerd grid fields
n_x = length(x)/2;
idx_even = 2:2:2*n_x;
idx_odd = 1:2:2*n_x;
u_nmh = ip.Results.u_init(idx_odd); % u at time t_0 - dt/2
v_n = ip.Results.v_init(idx_even);  % v at time t_0 

% init auxilary functions
pq_init = zeros(size(x)); % init as zero
p_nmh = pq_init(idx_odd); % p at time t_0 - dt/2
q_n = pq_init(idx_even);  % q at time t_0 

% init solution structure
% we are only interested in the odd positions
sol_u = diracEq1D.Fds1DSolution(x(idx_odd));
sol_v = diracEq1D.Fds1DSolution(x(idx_odd));

% calculate space dependend mass, sigma and potential terms
Mp = dt/(2i*c)*(potential(idx_odd) + mass); 
Mm = dt/(2i*c)*(potential(idx_even) - mass);
K = dt*(1i*potential + sigma)/2;
G = dt*sigma;
rx = dt/dx;

% solution loop
for idx_t = 1:length(time)
    
    % u,p live on the odd grid points
    delta_v_n = v_n - [0, v_n(1:end-1)];
    
    % calculate p at time t_n + dt/2
    % v_n , p_nmh --> p_nph 
    p_nph = ((1 - K(idx_odd)).*p_nmh + rx*delta_v_n) ./ (1 + K(idx_odd));
    
    % calculate u at time t_n + dt/2
    % u_nmh, v_n , p_nmh , p_nph --> u_nph
    p_n = (p_nph + p_nmh)/2; % interp p_n linear in time
    u_nph = ((1 + Mp).*u_nmh - rx*delta_v_n + G(idx_odd).*p_n) ./ (1 - Mp);
    
    % v,q live on the even grid points
    delta_u_nph = [u_nph(2:end), 0] - u_nph; 
    
    % calculate q at time t_n + dt 
    % u_nph , q_n --> p_np1 
    q_np1 = ((1 - K(idx_even)).*q_n + rx*delta_u_nph) ./ (1 + K(idx_even));
    
    % calculate v at time t_n + dt
    % v_n , q_n , q_np1 --> v_np1 
    q_nph = (q_np1 + q_n)/2; % interp q_nph linear in time
    v_np1 = ((1+Mm).*v_n - rx*delta_u_nph + G(idx_even).*q_nph) ./ (1 - Mm);

    % interpolate solution and add to output structure
    u_n = (u_nph + u_nmh)/2;               % linear interpolate in time on odd positions
    v_n_odd = (v_n + [0, v_n(1:end-1)])/2; % linear interpolate in space on odd position
    
    sol_v.appendSolution(time(idx_t),v_n_odd);
    sol_u.appendSolution(time(idx_t),u_n);
    % prepare new cylce
    u_nmh = u_nph;
    p_nmh = p_nph;
    v_n = v_np1;
    q_n = q_np1;
    
    % display simulation time progress
    disp(['t_n = ' num2str(time(idx_t)), ' t_p'])
end

disp('Pde Solved!')

