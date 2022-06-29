function [sol_u, sol_v] = solveEquation(varargin)
% DESCRIPTION: 
% this function solves the (2+1)d dirac equation with a explicit staggerd 
% grid leapfrog finite difference sceme.
% The values of the spinor are stored on two staggerd layers.
% The v layers are always at time t_i. 
% The u_layers are stored at times t_i + 0.5*dt 
% In the places in between the u and v values, which are not used by the
% sceme, the mass/potential terms are stored.
%
% INPUT:
% required:
%  um0         [nx x ny complex]  
%  vp0         [nx x ny complex]
%  xx          [nx x ny double]
%  yy          [nx x ny double]
%  time        [ 1 x nt double]
% parameter:
%  bc          [string]
%  mass        [nx x ny complex] complex potential+mass term 
%  potential   [nx x ny complex] complex potential-mass term 
%  c
%
% OUTPUT:
%  sol_u       [diracEq2D.FdsSolution] solution for u-component of spinor
%  sol_V       [diracEq2D.FdsSolution] solution for v-component of spinor
%
% NOTE: DATA STORAGE ------------------------------------------------------
% When reducing it to a 1-d layering structer the storage matrices um and
% vm look the following
%
% t_3 + 0.5 dt : - u - M - u - M - u - M - u - M -  <- req. for time interp
% t_3          : - M - v - M - v - M - v - M - v -  <- last timestep 
% t_2 + 0.5 dt : - u - M - u - M - u - M - u - M - 
% t_2          : - M - v - M - v - M - v - M - v -
% t_1 + 0.5 dt : - u - M - u - M - u - M - u - M - 
% t_1          : - M - v - M - v - M - v - M - v -
%  0  + 0.5 dt : - u - M - u - M - u - M - u - M - 
%  0           : - M - v - M - v - M - v - M - v -  <- vp0 inital cond.
%  0  - 0.5 dt : - u - M - u - M - u - M - u - M -  <- um0 inital cond.
%
% NOTE:  NATURAL UNITS USED! ----------------------------------------------
% units where the follwoing holds are used: 
%   h_bar = 1   (planck constant)
%   c     = 1   (speed of light)
% 
% There relevant units are concretely tabularized here:
% quantitiy     |  unit |     actual unit     |     SI unit
%   energy         1eV           1eV              1.60218e-19 J
%   time          1/1eV       h_bar / 1eV         6.58212e-16 s
%   distace       1/1eV     c * h_bar / 1eV       1.97327e-7  m
%   mass           1eV        1eV / c^2           1.78266e-36 kg
%   velocity        1             c               2.99792e+9  m/s
%   wavenumber     1eV      1ev / c * h_bar       
%

%%% input parse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ip = inputParser();
ip.addRequired('um0', @(x) isEvenSize(x));
ip.addRequired('vp0', @(x) isEvenSize(x));
ip.addRequired('xx', @(x) isEvenSize(x));
ip.addRequired('yy', @(x) isEvenSize(x));
ip.addRequired('time');
ip.addParameter('bc', 't', @(x) ischar(x) && any(strcmp(x, {'0','t'})));
ip.addParameter('mass', 0);
ip.addParameter('potential', 0);
ip.addParameter('c', 1);
ip.addParameter('N', 200);
ip.parse(varargin{:})

xx = ip.Results.xx;
yy = ip.Results.yy;
time = ip.Results.time;
bc = ip.Results.bc;

if all(size(ip.Results.mass) == [1,1])
    mass = ip.Results.mass*ones(size(xx));
elseif all(size(ip.Results.mass) == size(xx))
    mass = ip.Results.mass;
else
    error('mass and xx must have the same size')
end
if all(size(ip.Results.potential) == [1,1])
    potential = ip.Results.potential*ones(size(xx));
elseif all(size(ip.Results.potential) == size(xx))
    potential = ip.Results.potential;
else
    error('potential and xx must have the same size')
end

c = ip.Results.c;

N_sol = ip.Results.N;
%%% init required parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dx = 2*(xx(1,2) - xx(1,1));
dy = 2*(yy(2,1) - yy(1,1));
dt = c*(time(2)- time(1));

rx = dt/dx;
ry = dt/dy;

%%% init solution structures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init um_n chess matrix at time: t_n - 0.5*dt
% relevant spinor entries (u) stored in x_field
% relevant mass terms (M_minus) stored in o_field
um_n = diracEq2D.ChessMat(ip.Results.um0, bc);
um_n.oWrite((potential - mass)/(1i*c));

% init vp_n chess matrix at time: t_n 
% relevant spinor entries (v) stored in o_field
% relevant mass terms (M_plus) stored in x_field
vp_n = diracEq2D.ChessMat(ip.Results.vp0, bc);
vp_n.xWrite((potential + mass)/(1i*c)); 

%%% init solution structures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sol_u = diracEq2D.Fds2DSolution(xx, yy);
sol_u.changeUnits('l_p', 't_p/c');

sol_v = diracEq2D.Fds2DSolution(xx, yy);
sol_v.changeUnits('l_p', 't_p/c');

%%% solve equation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
um_np1 = diracEq2D.ChessMat(zeros(size(xx)), bc);
um_np1.oWrite((potential - mass)/(1i*c));

time(end+1) = time(end) + dt; % elongate time because interpolation of u

for idx_t = 1:length(time)
    
    %%% store solution of v
    t = time(idx_t); % idx_t == 1 --> t == 0;
    if idx_t ==1 || idx_t ==length(time) || mod(idx_t, floor(length(time)/N_sol)) == 0
        [~, sol_vp_n] = vp_n.xInterp();
        sol_v.appendSolution(t, sol_vp_n);
    end
    
    %%% um_n + vp_n -> um_np1
    % u is stored as x_flieds -> get x neighbours
    [vp_n_mx, vp_n_px, vp_n_my, vp_n_py] = vp_n.getXNeighbourhood();       
    M = dt/2*vp_n.getXField();                                                
    
    um_np1.setXField(...
         ((1+M).*um_n.getXField() ...
          - ry*(vp_n_py - vp_n_my) ...
          -1i*rx*(vp_n_px - vp_n_mx) ) ./ (1-M)...
          );
      
    %%% vp_n + um_np1 -> v_np1
    % v is stored as o_flieds -> get o neighbours
    [um_np1_mx, um_np1_px, um_np1_my, um_np1_py] = um_np1.getONeighbourhood();
    M = dt/2*um_np1.getOField(); 
    
    vp_n.setOField(...
        ((1+M).*vp_n.getOField() ...
         - ry*(um_np1_py - um_np1_my) ...
         +1i*rx*(um_np1_px - um_np1_mx) ) ./ (1-M) ...
        );
    
    %%% store solution of u
    t = time(idx_t); % idx_t == 1 --> t == 0
    if idx_t ==1 || idx_t ==length(time) || mod(idx_t, floor(length(time)/N_sol)) == 0
        [~, sol_um_n]   = um_n.oInterp();
        [~, sol_um_np1] = um_np1.oInterp();
        sol_u.appendSolution(t, 0.5*(sol_um_n + sol_um_np1)); % time interpolation
    end
    
    %%% update um_n
    um_n.setXField(um_np1.getXField()); % the mass terms do not change over time
    
    disp(['t = ', num2str(t)])
end

end

%% ------------------------------------------------------------------------
% subroutines 

function val = isEvenSize(M)
s = size(M);
if mod(s(1),2) == 0 && mod(s(2),2) == 0 
    val = true;
else
    val = false;
end

end
