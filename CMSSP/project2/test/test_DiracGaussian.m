% Test script for the Class: DiracGaussian
% Test script fot the function: constructGaussianCart
% Test script fot the function: constructGaussianPol

%% diracGaussianCart
disp('testint: DiracGaussianCart')
%%% Setup szeanrio %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m = 0;
c = 1;
v = 0;

% set up spacial domain of area 4
x0 = -1;
x1 = 1;
x = linspace(x0, x1, 1000);
y0 = -1;
y1 = 1;
y = linspace(y0, y1, 1000);
[xx, yy] = meshgrid(x,y);

% construct wave packet
gwp = constructGaussianCart(...
    3, ...  %kx0
    3, ...  %ky0
    0.05, ... %b
    'nk', 41, ...
    'mk', 20*pi, ...
    't0',  0, ...
    'x0',  -0.5, ...
    'y0',  -0.5, ...
    'potential', 0, ...
    'mass', 0, ...
    'c', c, ...
    'solution', 1, ...
    'volumen', (x1-x0)*(y1-y0));


%%% test if solutions are correct %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_result = zeros(1, length(gwp.energies));
prec = 1e-13;
for i_k = 1:length(gwp.energies)
    
    k = gwp.wavenumbers(:,i_k);
    M = 1i*c*[(v+m)/(1i*c), k(1)-1i*k(2);  -k(1)-1i*k(2), (v-m)/(1i*c)];
    E = gwp.energies(i_k) ;
    A = gwp.eigenspinors(:,i_k);
    test_result(i_k) = norm(M*A - E*A) <= prec;

end

if all(test_result)
    disp('Test 1: passed')
else
    disp('Test 1: failed')
    disp(find(~test_result))
end

%%% test2: test if mean is correct %%%%%%%%%%%%
[k_avg, E_avg] = gwp.estimateEnergeticProperties();
prec = 1e-13;
if all(abs(k_avg - [3;3])<= prec) 
    disp('Test 2: passed')
else
    disp('Test 2: failed')
    disp(abs(k_avg - [3;3]))
end

%%% test if normalisation is correct %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[u, v] = gwp.getComponent(xx,yy,0);
w = abs(u)^2 + abs(v)^2;
prec = 1e-13;
p = trapz2D(x, y, w);
if abs(p-1)<prec
        disp('Test 2: passed')
else
    disp('Test 2: failed')
    disp(abs(p-1))

end

%%% visualize wave packet %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
surf(xx,yy, w);
shading interp
view(0,90)
axis square

%% diracGaussianPol
disp('testint: DiracGaussianPol')
%%% Setup szeanrio %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m = 0;
c = 1;
v = 0;

% set up spacial domain of area 4
x0 = -1;
x1 = 1;
x = linspace(x0, x1, 1000);
y0 = -1;
y1 = 1;
y = linspace(y0, y1, 1000);
[xx, yy] = meshgrid(x,y);

% construct wave packet
gwp = constructGaussianPol(...
    3, ...  %kx0
    3, ...  %ky0
    0.05, ... %b
    8*pi, ...
    1*pi/(x1-x0), ...
    1*pi/(y1-y0), ...
    't0',  0, ...
    'x0',  -0.5, ...
    'y0',  -0.5, ...
    'potential', 0, ...
    'mass', 0, ...
    'c', c, ...
    'solution', 1, ...
    'volumen', (x1-x0)*(y1-y0));

%%% test if solutions are correct %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_result = zeros(1, length(gwp.energies));
prec = 1e-13;
for i_k = 1:length(gwp.energies)
    
    k = gwp.wavenumbers(:,i_k);
    M = 1i*c*[(v+m)/(1i*c), k(1)-1i*k(2);  -k(1)-1i*k(2), (v-m)/(1i*c)];
    E = gwp.energies(i_k) ;
    A = gwp.eigenspinors(:,i_k);
    test_result(i_k) = norm(M*A - E*A) <= prec;

end

if all(test_result)
    disp('Test 1: passed')
else
    disp('Test 1: failed')
    disp(find(~test_result))
end

%%% test2: test if mean is correct %%%%%%%%%%%%
[k_avg, E_avg] = gwp.estimateEnergeticProperties();
prec = 1e-13;
if all(abs(k_avg - [3;3])<= prec) 
    disp('Test 2: passed')
else
    disp('Test 2: failed')
    disp(abs(k_avg - [3;3]))
end

%%% test if normalisation is correct %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[u, v] = gwp.getComponent(xx,yy,0);
w = abs(u)^2 + abs(v)^2;
prec = 1e-13;
p = trapz2D(x, y, w);
if abs(p-1)<prec
        disp('Test 2: passed')
else
    disp('Test 2: failed')
    disp(abs(p-1))

end

%%% visualize wave packet %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
surf(xx,yy, w);
shading interp
view(0,90)
axis square

