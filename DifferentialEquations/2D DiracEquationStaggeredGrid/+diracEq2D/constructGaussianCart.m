function [gwp] = constructGaussianCart(varargin)
% This function constructs a gaussian wave packet out of a superpostion of
% plane wave solutions of the (2+1)d dirac equation. 
%
% The used plane wave solutions all have k-vectors within a shiftet square
% box in discrete k_space
%
% INPUTS:
% required:
%   kx          [ 1 x 1 double ] mean x-component of wavepacket
%   ky          [ 1 x 1 double ] mean y-component of wavepacket
%   b           [ 1 x 1 double ] halfwidht of gausspeak in real space
%   nk         [ 1 x 1 double ] number of wavenumbers in each direction
%   mk         [ 1 x 1 double ] specifies maximum half side-lenght of box
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
ip.addParameter('nk', 10);
ip.addParameter('mk', 1);
ip.addParameter('t0', 0);
ip.addParameter('x0', 0);
ip.addParameter('y0', 0);
ip.addParameter('potential', 0)
ip.addParameter('mass', 0, @(x) x>=0)
ip.addParameter('c', 1, @(x) x>0)
ip.addParameter('solution', 1)
ip.addParameter('volumen', 1)
ip.parse(varargin{:})

% required
k0 = [ip.Results.kx;ip.Results.ky];
b  = ip.Results.b;

% parameters
nk = ip.Results.nk;
mk = ip.Results.mk;

% construct wave numbers and amplitudes
k = zeros(2,nk^2);
a = zeros(1,nk^2);

ki = linspace(-mk,mk,nk);

idx = 1; % index of current plane wave solution
for i_kx = 1:nk
    for i_ky = 1:nk
        % wavenumber
        k(:,idx) = [ki(i_kx) + k0(1); ki(i_ky) + k0(2)];
        % amplitudes
        a(idx) = exp(-b.^2*norm(k(:,idx) - k0).^2);
        %raise index
        idx = idx + 1;
    end
end
N = sqrt(sum(abs(a(:)).^2));
a = a/N; % normalize amplitudes

% cosntruct wavepacket.
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
