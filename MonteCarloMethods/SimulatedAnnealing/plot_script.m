load('simulatedAnnealing.mat')

figure(1)
plot(inital_state(:,1),inital_state(:,2), 'ob')
hold on
plot(configs{end}(:,1), configs{end}(:,2))
hold off

figure(2)
plot(beta, cost_min, '--b')
hold on
plot(beta, cost_max, '--g')
plot(beta, cost_avg, '-r')
hold off

