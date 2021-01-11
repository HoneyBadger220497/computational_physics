function [u, v, E] = constructGaussianDirty(varargin)
% This function constructs a gaussian wave packet in a dirty way, by taking
% a plane wave solution and localizing it by multiplication with a gaussian
% weight in position. 
%
% The output of this function are the spinorcomponent-values u and v
% evaluated at the gridpoints xx and yy.
%
% INPUTS:
% required:
%   x          [ 1 x 1 double ] x-coordinate of grid for calculation
%   k          [ 1 x 1 double ] mean wavenumber
%   b           [ 1 x 1 double ] halfwidht of gausspeak in x-direction
% parameter:
%   x0          [ 1 x 1 double ] x-coordinate of center of gaussian peak 
%   potential   [ 1 x 1 double] potential, constant potential is
%               assumed to have plane wave solutions.
%   mass        [ 1 x 1 double] mass, constant mass is assumed 
%   c           [ 1 x 1 double] average particle speed
%   solution    [ -1 or +1] specifies wether positive or negative 
%               mass plane wave solution should be created
%   normalize   [true or false] try to normalize wavefunction with
%               numerical integration.
%
% OUTPUTS:
%   u           [ 2 x 1 double] u-component-values of the spinor 
%   v           [ 1 x 1 double] u-component-values of the spinor
%
% NOTE: The Gaussian might not be normalized!
%

% input parse
ip = inputParser();
ip.addRequired('x');
ip.addRequired('k');
ip.addRequired('b');
ip.addParameter('x0', 0);
ip.addParameter('potential', 0)
ip.addParameter('mass', 0, @(x) x>=0)
ip.addParameter('c', 1, @(x) x>0)
ip.addParameter('solution', 1)
ip.addParameter('volumen', 1)
ip.addParameter('normalize', true)
ip.parse(varargin{:})
 
x = ip.Results.x;
k = ip.Results.k;
b = ip.Results.b;
x0 = ip.Results.x0;

% calculate eigenspinor solution
[A, E] = diracEq1D.planeWaveSolution(...
    k, ...
    ip.Results.potential,...
    ip.Results.mass,...
    ip.Results.c,...
    ip.Results.solution, ...
    1); % volumen set to one because else nomralized two times!

% calculate spacial wave function
phase = exp(1i*k*(x-x0));
weight = exp(-(x-x0).^2/b.^2);
spacial_wave = phase .* weight;

% normalize
if ip.Results.normalize
    dx = x(1,2) - x(1,1);
    normalisation = sqrt(trapz(dx, abs(spacial_wave).^2)); 
else
    normalisation = 1;
end

% calculate spinor
u = A(1) * spacial_wave / normalisation; 
v = A(2) * spacial_wave / normalisation;     
