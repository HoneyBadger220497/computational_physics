% Test script for the function: planeWaveSolution

addpath([pwd, '\..'])

%% create szenario

% setup parametes
m = 24   ;
v = 10;
kx = 1;
ky = 0;
c = 1;

% set up spacial domain of area 4
x0 = -1;
x1 = 1;
x = linspace(x0, x1, 1000);
y0 = -1;
y1 = 1;
y = linspace(y0, y0 + 2, 1000);
[xx, yy] = meshgrid(x,y);

% calculate plane wave solutions
[A1,E1] = diracEq2D.planeWaveSolution(kx,ky,v, m,c,1,(x1-x0)*(y1-y0));
[A2,E2] = diracEq2D.planeWaveSolution(kx,ky,v,m,c,-1,(x1-x0)*(y1-y0));

%% test 1 eigenspinor of positive solution %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prec = 10^-13;
M = 1i*c*[(v+m)/(1i*c), kx-1i*ky;  -kx-1i*ky, (v-m)/(1i*c)];
if all(norm(M*A1 - E1*A1) <= prec)
    disp('Test 1: passed')
else
    disp('Test 1: failed')
    disp(norm(M*A1 - E1*A1))
end

%% test 2 eigenspinor of negativ solution %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M = 1i*c*[(v+m)/(1i*c), kx-1i*ky;  -kx-1i*ky, (v-m)/(1i*c)];
if all(norm(M*A2 - E2*A2) <= prec)
    disp('Test 2: passed')
else
    disp('Test 2: failed')
end

%% test 3 energie %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if E2 < E1
    disp('Test 3: passed')
else
    disp('Test 4: failed')
end

%% test normailsation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
u = A1(1).*exp(1i*kx*xx+1i*ky*yy);
v = A1(2).*exp(1i*kx*xx+1i*ky*yy);
w = abs(u).^2 + abs(v).^2;

p = trapz(y,  trapz(x , w, 2)); % numerical integrate over domain

prec = 1e-3;
if abs(p-1  )<prec
        disp('Test 4: passed')
else
    disp('Test 4: failed')
    disp(abs(p-1))
end

