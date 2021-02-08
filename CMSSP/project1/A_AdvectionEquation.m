% Acvection Equation
%
% This script tries to solve the advection equation
% with different Finit Difference Scemes and compare the results to a known
% exact solution
%
% The Advection is given by
%
%   du/dt + c du/dx  = 0 , v > 0
%
% with periodic boundary conditions
%   
%   u(t, x_0) = u(t, x_N) 
% 
% and the inital condition
% 
%   u(0, x) = sin(pi*x)^2 * exp(-x^2/4)
%
% The investigated spacial interval is (0,1)
% The investigated time interval is (0,1)
%
% Analyitcal solution:
%
% f(t,x) = sin(2*pi*(x - c*t))^2 * exp(-(x - c*t)^2/4)
% f(0,0) = 0 = f(0,1)
%

%%% prepare Matlab
clearvars solution f ;

%%% exact solution and problem set
T = 1;

q = 0;
p = 1;
L = p-q;

%f = @(t,x) sin(pi*(x - c*t)).^2;
c = 1;
%u = @(t,x) exp(-(x-c*t-1/2).^2/0.1);
u = @(t,x) exp(-(1-sin(pi*(x-c*t)).^2/0.5))/3;
%u = @ (t,x) round((1-cos(x-c*t))/2)
%%% descritization parameters
prompt = {...
    'Enter n_x for intervals for x-discretization:',...
    'Enter n_t for intervals for t-discretization:'};
dlgtitle = 'Discretization parameters';
dims = [1 35];
definput = {'1000', num2str(c*T/L*1000)};
answer = inputdlg(prompt,dlgtitle,dims,definput);

n_x = str2double(answer(1));
n_t = str2double(answer(2));

%%% discretize space-time
t = linspace(0, T, n_t+1);
t = t(1:end-1);
dt = t(2)-t(1);

x = linspace(q, p, n_x+1);
x = x(1:end-1);
dx = x(2)-x(1);

r = c*dt/dx;
disp(['dx = ' num2str(dx)])
disp(['dt = ' num2str(dt)])
disp(['r = ' num2str(r)])

%%% solve and visualize equation
fds_methods = {...
    'Downwind-Sceme', ...
    'Lax-Wendroff-Sceme', ...
    'Lax-Friedrich-Sceme', ...
    'Leapfrog-Sceme', ...
    'Crank-Nikolson-Sceme'};
[method_indx] = listdlg(...
    'PromptString','Select a Method',...
    'SelectionMode','single',...
    'ListString', fds_methods);

%init solution struct
solution = struct(...
    'FDS', '', ...
    't', [] ,...
    'x', [], ...
    'u_n', [] ,...
    'E_L1', [], ...
    'E_L2', [], ...
    'E_max', []);

for i_method = 1:length(method_indx)
    
      solution(i_method).FDS = [fds_methods{method_indx(i_method)}, ' with r = ', num2str(r)];
      solution(i_method).u_n = u(0,x);
      solution(i_method).t = t;
      solution(i_method).x = x;
      solution(i_method).E_A = 0;
      solution(i_method).E_L2 = 0;
      solution(i_method).E_max = 0;
    
      u_n = solution(i_method).u_n;
      u_nm1 = u(-dt,x); % for leapfrog sceme as inital condition
      
      
      if method_indx == 5
        % prepare System Matrix
        % LU Decomposition

        n = length(u_n);
        A = diag(4*ones(1,n)) + diag(r*ones(1,n-1),1) - diag(r*ones(1,n-1),-1); 
        A(1,end) = -r;
        A(end,1) = r;

        [L,U] = lu(A);
      
      end
      
      for i_t = 2:length(t)
          
        switch method_indx
            case 1 % Downwind
                u_n = AdvectionEq.downwindFDS(u_n, r, u_n(end));
                
            case 2 % LaxWendroff
                u_n = AdvectionEq.laxWendroffFDS(u_n, r, u_n(end), u_n(1));
                
            case 3 % LaxFriedrich
                u_n = AdvectionEq.laxFriedrichFDS(u_n, r, u_n(end), u_n(1));
                
            case 4 % LeapFrog
                u_np1 = AdvectionEq.leapFrogFDS(u_n, u_nm1, r, u_n(end), u_n(1));
                u_nm1 = u_n;
                u_n = u_np1;
                
            case 5 % Crank Nikolson
                u_n = AdvectionEq.crankNicolsonLu(u_n, r, L,U);
                
        end
        solution(i_method).u_n(i_t, :) = u_n; 
        
        solution(i_method).E_A(i_t) = trapz(x, u_n - u(t(i_t),x));
        solution(i_method).E_L2(i_t) = sqrt(trapz(x, (u_n - u(t(i_t),x)).^2));
        solution(i_method).E_max(i_t) = max(abs((u_n - u(t(i_t),x))));
          
      end   

end


