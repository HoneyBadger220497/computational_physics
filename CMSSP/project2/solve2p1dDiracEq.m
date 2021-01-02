function [sol_u, sol_v] = solve2p1dDiracEq(varargin)
% DESCRIPTION: 
% this function solves the (2+1)d dirac equation with a explicit staggerd 
% grid leapfrog finite difference sceme.
% The values of the spinor are stored on two staggerd layers.
% The v layers are always at time t_i. 
% The u_layers are stored at times t_i + 0.5*dt 
% In the places in between the u and v values, which are not used by the
% sceme, the mass/potential terms are stored.
%
% DATA STORAGE:
% When reducing it to a 1-d layering structer the storage matrices vm and
% um look the following
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
%
% INPUT:
% um0         [nx x ny complex]  
% vp0         [nx x ny complex]
% xx          [nx x ny double]
% yy          [nx x ny double]
% time        [ 1 x nt double]
% bc          [string]
% M_plus     [function_handle] potential+mass term 
% M_minus    [function_handle] potential-mass term 


%%% input parse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ip = inputParser();
ip.addRequired('um0', @(x) isEvenSize(x));
ip.addRequired('vp0', @(x) isEvenSize(x));
ip.addRequired('xx', @(x) isEvenSize(x));
ip.addRequired('yy', @(x) isEvenSize(x));
ip.addRequired('time');
ip.addParameter('bc', 't', @(x) ischar(x) && any(strcmp(x, {'0','t'})));
ip.addParameter('M_plus', []);
ip.addParameter('M_minus'), []);
ip.parse(varargin{:})

xx = ip.Results.xx;
yy = ip.Results.yy;
time = ip.Results.time;
M_plus = ip.Results.M_plus;
M_minus = ip.Results.M_minus;
bc = ip.Results.bc;

%check input values
if ~all(size(xx) == sizey(yy))
    error('xx and yy must have the same size')
end
if ~all(size(M_plus) == size(xx))
    error('M_plus and xx must have the same size')
end
if ~all(size(M_minus) == size(xx))
    error('M_minus and xx must have the same size')
end
if any(abs(real(M_plus)) > eps) || any(abs(real(M_minues)) > eps)
   warning('The mass terms are thought to be purly imaginary') 
end

%%% init required parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dx = xx(1,2) - xx(1,1);
dy = yy(2,1) - yy(1,1);
dt = time(2)- time(1);

rx = dt/dx;
ry = dt/dy;

%%% init solution structures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init um_n chess matrix at time: t_n - 0.5*dt
% relevant spinor entries (u) stored in x_field
% relevant mass terms (M_minus) stored in o_field
um_n = ChessMat(ip.Results.um0, 'bc', bc);
um_n.oWrite(M_minus);

% init vp_n chess matrix at time: t_n 
% relevant spinor entries (v) stored in o_field
% relevant mass terms (M_plus) stored in x_field
vp_n = ChessMat(ip.Results.vp0, 'bc', bc);
vp_n.xWrite(M_plus); 

%%% init solution structures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sol_u = Fds2DSolution(xx, yy);
sol_u.changeUnits('l_p', 't_p/c');

sol_v = Fds2DSolution(xx, yy);
sol_v.changeUnits('l_p', 't_p/c');

%%% solve equation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
um_np1 = ChessMat(zeros(size(xx)), 'bc', bc);
um_np1.oWrite(M_minus);

time(end+1) = time(end) + dt; % elongate time because interpolation of u

for idx_t = 1:length(time)
    
    %%% store solution of v
    t = time(idx_t); % idx_t == 1 --> t == 0;
    [~, sol_vp_n] = vp_n.xInterp();
    sol_v.appendSolution(this, t, sol_vp_n);
    
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
    t = time(idx_t); % idx_t == 1 --> t == 0;
    [~, sol_um_n]   = um_n.oInterp();
    [~, sol_um_np1] = um_np1.oInterp();
    sol_u.appendSolution(this, t, 0.5*(sol_um_n+ sol_um_np1)); % time interpolation
    
    %%% update um_n
    um_n.setXField(um_np1.getXField()); % the mass terms do not change over time
    
end

end

% subroutines
function val = isEvenSize(M)
s = size(M);
if mod(s(1),2) == 0 && mod(s(2),2) == 0 
    val = true;
else
    val = false;
end

end
