function gwp = constructGaussianPol(varargin)
% This function constructs a gaussian wave packet out of a superpostion of
% plane wave solutions of the (2+1)d dirac equation. 
%
% The used plane wave solutions all have k-vectors within a shiftet sphere
% in discrete k-space.
%
% INPUTS:
% required:
%   kx          [ 1 x 1 double ] mean x-component of wavepacket
%   ky          [ 1 x 1 double ] mean x-component of wavepacket
%   b           [ 1 x 1 double ] halfwidht of gausspeak in real space
%   rk          [ 1 x 1 double ] radius of sphere in k-space
%   dkx         [ 1 x 1 double ] x-discretisation of grid in k-space
%   dky         [ 1 x 1 double ] y-discretisation of grid in k-space
% parameter:
%   t0          [ 1 x 1 double ] time origin for gaussian peak.
%   x0          [ 1 x 1 double ] x-coordinate of center of gaussian peak 
%               at time t0. 
%   y0          [ 1 x 1 double ] y-coordinate of center of gaussian peak 
%               at time t0. 
%   potential   [ 1 x 1 double] potential, constant potential is
%               assumed to have plane wave solutions.
%   mass        [ 1 x 1 double] mass, constant mass is assumed 
%   c           [ 1 x 1 double] average particle speed
%   solution    [ -1 or +1] specifies wether positive or negative 
%               mass plane wave solution should be created
%   volumen     [1 x 1 double] area of the 2d domain (Default: 1) 
%               important to calculate normaized plane wave solutions and
%               further normalize the solution of the superposition
%               correctly.
%
% OUTPUTS:
%   A           [ 2 x 1 double] eigenspinor of the DiracOperator
%   E           [ 1 x 1 double] Energy of the plane wave solution
%
% Note: The peak will only have the desired half widht b, if the radius of 
% the k-space sphere is sufficently large (to aproximate the 
% fourier-integral correctly).
%
% ToDo: Normalisation of the plane wave does not seem to work properly jet.
%

% input parse
ip = inputParser();
ip.addRequired('kx');
ip.addRequired('ky');
ip.addRequired('b');
ip.addRequired('rk');
ip.addRequired('dkx');
ip.addRequired('dky');
ip.addParameter('t0', 0);
ip.addParameter('x0', 0);
ip.addParameter('y0', 0);
ip.addParameter('potential', 0)
ip.addParameter('mass', 0, @(x) x>=0)
ip.addParameter('c', 1, @(x) x>0)
ip.addParameter('solution', 1)
ip.addParameter('volumen', 1)
ip.parse(varargin{:})

k0 = [ip.Results.kx;ip.Results.ky];
rk  = ip.Results.rk;
dkx = ip.Results.dkx;
dky = ip.Results.dky;
b = ip.Results.b;

% construct wave numbers and amplitudes
% find number max of points in sphere in each direction
nkx = ceil(rk/dkx);
nky = ceil(rk/dky);

% calculate all k-Values within sphere in k-space
[kxx,kyy] = meshgrid(linspace(-rk,rk,nkx),linspace(-rk,rk,nky));
idx_insphere = kxx.^2+kyy.^2 <= rk.^2;
kkxx = kxx(idx_insphere);
kkyy = kyy(idx_insphere);
k = [kkxx(:).';kkyy(:).'];

% gaussian weights for plane waves
a = exp(-(b).^2*sum(k.^2,1));
N = sqrt(sum(abs(a(:)).^2));
a = a/N; % normalize amplitudes

k = k + k0;  % shift k-vectors 

% create wavepacket
gwp = diracEq2D.DiracWavepacket(...
    k, ...
    a, ...
    't0', ip.Results.t0,...
    'x0', ip.Results.x0,...
    'y0', ip.Results.y0,...
    'potential', ip.Results.potential,...
    'mass', ip.Results.mass,...
    'c', ip.Results.c,...
    'solution', ip.Results.solution, ...
    'volumen', ip.Results.volumen);

end
