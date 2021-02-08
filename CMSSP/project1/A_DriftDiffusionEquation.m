% Drift Diffusion Equation
%
% This script tries to solve the diffusion equation
% with a first order forward in time and first order in space
% approximation.
%
% The Diffusion euqation is given by
%
%   du/dt + c du/dx - k du^2/dx^2  = 0 , k > 0
%
% with periodic boundary conditions
%   
%   u(t, x_0) = u(t, x_N) 
% 
% and the inital condition
% 
%   u(0, x) = A*exp(-(x-1/2)^2/sigma^2)
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
addpath([pwd, '..\project2\visualisation'])

%%% exact solution and problem set
T = 1;

q = 0;
p = 1;
L = p-q;

c = 1;
k = 0.1;
f = @(t,x,n) exp(-k*pi^2*n^2*t)*sin(pi*n*x);
u = @(t,x) f(t,x,1);

%%% descritization parameters
prompt = {...
    'Enter n_x for intervals for x-discretization:',...
    'Enter n_t for intervals for t-discretization:'};
dlgtitle = 'Discretization parameters';
dims = [1 35];
definput = {'100', num2str(ceil(T/((L/100)^2/(c*L/100 + 2*k))))};
answer = inputdlg(prompt,dlgtitle,dims,definput);

n_x = str2double(answer(1));
n_t = str2double(answer(2));

%%% discretize space-time
t = linspace(0, T, n_t+1);
t = t(1:end);
dt = t(2)-t(1);

x = linspace(q, p, n_x+1);
x = x(1:end-1);
dx = x(2)-x(1);

r = c*dt/dx;
s = k*dt/dx^2;
disp(['dx = ' num2str(dx)])
disp(['dt = ' num2str(dt)])
disp(['r = ' num2str(r)])
disp(['s = ' num2str(s)])
if dt <= dx^2/(c*dx + 2*k)
    disp('dt < dx^2/(c*dx + 2k) holds true')
else
    disp('dt < dx^2/(c*dx + 2k) does not hold')
end
%%% inital conditions
Amp = 1;
sigma = 0.3;
u0 = Amp*exp(-(x-1/2).^2/sigma^2);

%%% solve and visualize equation

%init solution struct
solution = struct(...
    'FDS', 'fotfos', ...
    't', t ,...
    'x', x, ...
    'u_n', u0 ,...
    'E_A', nan, ...
    'E_L2', nan, ...
    'E_max', nan);
    
u_n = solution.u_n;
A_excat = trapz(x, u0);

for i_t = 2:length(t)

    %finite difference sceme
    u_n = DriftDiffusionEq.fotFos(u_n, r, s, u_n(end), u_n(1));
    
    % update solution
    solution.u_n(i_t, :) = u_n;
    
    % exact solution unknown 
    solution.E_A(i_t) = (1 - abs(trapz(x, u_n))/A_excat);
    solution.E_L2(i_t) = nan;
    solution.E_max(i_t) = nan;

end   

%% evaluate result %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Evaluating Results:')
time = solution.t;
x = solution.x;
l2max_error = max([solution.E_A,solution.E_L2]);

vtd_result  = vizToolData(1, {x}, ...
    @(ax,x, y) plotResult(ax, x, y),...
    {'x / -', 'y / -'}, ...
    'SliderLabel', 's', ...
    'Title', 'Numeric Solution');
vtd_LA_errors = vizToolData(1, {}, ...
    @(ax, E1 ) errorPlot(ax, E1, time, [min(solution.E_A),max(solution.E_A)]),...
    {'Error '},...
    'SliderLabel', 's', ...
    'Title', 'Change in Area under curve');

prog = 0;

for idx_t = 1:length(time)
    
    % display progrss
    prog_new = idx_t/length(time);
    if prog_new - prog >= 0.1
        disp([num2str(prog*100,'%.0f') '% '])
        prog = prog_new;
    end
    
    t = time(idx_t);
    
    % Errors
    E_A   = solution.E_A;
    E_L2  = solution.E_L2;
    E_max = solution.E_max;
    E_A(idx_t+1:end) = NaN;
    E_L2(idx_t+1:end) = NaN;
    E_max(idx_t+1:end) = NaN;
    
    % solution
    sol_u = solution.u_n(idx_t, :);
    
    vtd_result.addData(t, sol_u);
    vtd_LA_errors.addData(t, E_A)
    end

disp([num2str(100,'%.0f') '% '])
vizTool(vtd_result, vtd_LA_errors, vtd_LA_errors)

%% subroutines for plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotResult(ax, x, y, y_exact)

    plot(ax, x, y, '-r')
    
    legend('numeric solution', 'exact solution')
    ylim(ax, ylim(ax))
end

function errorPlot(ax, E, time, y_limits)
    
    plot(ax, time, E, '-b');
    xlim(ax, [time(1),time(end)])
    ylim(ax, y_limits)
    xlabel(ax, 'time')
end

