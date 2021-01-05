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
%   xx          [ 1 x 1 double ] y-coordinate of grid for calculation
%   yy          [ 1 x 1 double ] y-coordinate of grid for calculation
%   kx          [ 1 x 1 double ] mean x-component of wavepacket
%   ky          [ 1 x 1 double ] mean x-component of wavepacket
%   bx           [ 1 x 1 double ] halfwidht of gausspeak in x-direction
%   by           [ 1 x 1 double ] halfwidht of gausspeak in y-direction
% parameter:
%   x0          [ 1 x 1 double ] x-coordinate of center of gaussian peak 
%   y0          [ 1 x 1 double ] y-coordinate of center of gaussian peak 
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
ip.addRequired('xx');
ip.addRequired('yy');
ip.addRequired('kx');
ip.addRequired('ky');
ip.addRequired('bx');
ip.addRequired('by');
ip.addParameter('x0', 0);
ip.addParameter('y0', 0);
ip.addParameter('potential', 0)
ip.addParameter('mass', 0, @(x) x>=0)
ip.addParameter('c', 1, @(x) x>0)
ip.addParameter('solution', 1)
ip.addParameter('volumen', 1)
ip.addParameter('normalize', true)
ip.parse(varargin{:})
 
xx = ip.Results.xx;
yy = ip.Results.yy;
kx = ip.Results.kx; 
ky = ip.Results.ky;
bx = ip.Results.bx;
by = ip.Results.by;
x0 = ip.Results.x0;
y0 = ip.Results.y0;

% calculate eigenspinor solution
[A, E] = diracEq2D.planeWaveSolution(...
    kx, ...
    ky, ...
    ip.Results.potential,...
    ip.Results.mass,...
    ip.Results.c,...
    ip.Results.solution, ...
    1); % volumen set to one because else nomralized two times!

% calculate spacial wave function
phase = exp(1i*kx*(xx-x0)) .* exp(1i*ky*(yy-y0));
weight = exp(-(xx-x0).^2/bx.^2) .* exp(-(yy-y0).^2/by.^2);
spacial_wave = phase .* weight;

% normalize
if ip.Results.normalize
    dx = xx(1,2) - xx(1,1);
    dy = yy(2,1) - yy(1,1);
    normalisation = sqrt(trapz(dy, trapz(dx, abs(spacial_wave).^2,2))); 
else
    normalisation = 1;
end

% calculate spinor
u = A(1) * spacial_wave / normalisation; 
v = A(2) * spacial_wave / normalisation;                    
                    
                    