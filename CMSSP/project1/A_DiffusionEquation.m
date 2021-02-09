% Diffusion Equation
%
% This script tries to solve the diffusion equation
% with a first order forward in time and symetrical second order in space
% approximation
%
% The Diffusion euqation is given by
%
%   du/dt - k du^2/dx^2  = 0 , k > 0
%
% with zero boundary conditions
%   
%   u(t, x_0) = u(t, x_N) 
% 
% and the inital condition
% 
%   u(0, x) = sin(pi*n*x)
%
% The investigated spacial interval is (0,1)
% The investigated time interval is (0,1)
%
% Analyitcal solution:
%
% u(t,x) = exp(-k*pi^2*n^2*t)*sin(pi*n*x)
%

%%% prepare Matlab
clearvars solution f ;

%%% exact solution and problem set
T = 1;

q = 0;
p = 1;
L = p-q;

k = 0.3;
f = @(t,x,n) exp(-k*pi^2*n^2*t)*sin(pi*n*x);
u = @(t,x) f(t,x,1);

%%% descritization parameters
prompt = {...
    'Enter n_x for intervals for x-discretization:',...
    'Enter n_t for intervals for t-discretization:'};
dlgtitle = 'Discretization parameters';
dims = [1 35];
definput = {'100', num2str(2*k*T/L^2*10000)};
answer = inputdlg(prompt,dlgtitle,dims,definput);

n_x = str2double(answer(1));
n_t = str2double(answer(2));

%%% discretize space-time
t = linspace(0, T, n_t+1);
t = t(1:end);
dt = t(2)-t(1);

x = linspace(q, p, n_x+1);
x = x(2:end-1);
dx = x(2)-x(1);

s = k*dt/dx^2;
disp(['dx = ' num2str(dx)])
disp(['dt = ' num2str(dt)])
disp(['s = ' num2str(s)])

%%% solve and visualize equation

%init solution struct
solution = struct(...
    'FDS', 'fotSos', ...
    't', t ,...
    'x', x, ...
    'u_n', u(0,x) ,...
    'E_A', 0, ...
    'E_L2', 0, ...
    'E_max', 0);
    
u_n = solution.u_n;
for i_t = 2:length(t)

    %finite difference sceme
    u_n = DiffusionEq.fotSos(u_n, s, 0, 0);
    
    % update solution
    solution.u_n(i_t, :) = u_n; 

    solution.E_A(i_t) = trapz(x, u_n - u(t(i_t),x));
    solution.E_L2(i_t) = sqrt(trapz(x, (u_n - u(t(i_t),x)).^2));
    solution.E_max(i_t) = max(abs((u_n - u(t(i_t),x))));

end   

