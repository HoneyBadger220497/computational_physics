addpath([pwd, '..\project2\visualisation'])

%% evaluate result %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Evaluating Results:')
time = solution.t;
x = solution.x;
l2max_error = max([solution.E_A,solution.E_L2]);

vtd_result  = vizToolData(2, {x}, ...
    @(ax,x, y, y_exact) plotResult(ax, x, y, y_exact),...
    {'x / -', 'y / -'}, ...
    'SliderLabel', 's', ...
    'Title', 'Numeric and Exact Solution');
vtd_L2_errors = vizToolData(1, {}, ...
    @(ax, E1) errorPlot(ax, E1, time, [0,max(solution.E_L2)]),...
    {'Error'},...
    'SliderLabel', 's', ...
    'Title', 'L2 Error Estimate');
vtd_LA_errors = vizToolData(1, {}, ...
    @(ax, E1 ) errorPlot(ax, E1, time, [min(solution.E_A),max(solution.E_A)]),...
    {'Error '},...
    'SliderLabel', 's', ...
    'Title', 'Difference in Area under Curve');

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
    u_exact = u(t, x); % exact solution
    
    vtd_result.addData(t, sol_u, u_exact);
    vtd_L2_errors.addData(t, E_L2);
    vtd_LA_errors.addData(t, E_A)
    end

disp([num2str(100,'%.0f') '% '])
vizTool(vtd_result, vtd_L2_errors, vtd_LA_errors)

%% subroutines for plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotResult(ax, x, y, y_exact)

    plot(ax, x, y, '-r')
    hold(ax, 'on')
    plot(ax, x, y_exact, '-b')
    hold(ax, 'off')
    
    legend('numeric solution', 'exact solution')
    ylim(ax, ylim(ax))
end

function errorPlot(ax, E, time, y_limits)
    
    plot(ax, time, E, '-b');
    xlim(ax, [time(1),time(end)])
    ylim(ax, y_limits)
    xlabel(ax, 'time')
end


