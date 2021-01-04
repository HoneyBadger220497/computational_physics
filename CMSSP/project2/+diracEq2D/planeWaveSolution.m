function [A, E] = planeWaveSolution(kx, ky, varargin)
% this function calculates the eigenvalues and eigenvectors of the
% dirac hamilton operator for a given wavevector k, when using a plane wave
% ansatz.
%
% For plane wave solution a homogenous space is assumed (constant mass and
% potetial).
% The Dirac operator has two types o plane-wave-solutions. Such with
% positive mass behavior and such with negative mass behavior (particle and
% antiparticle solutions).
%
% INPUTS:
% required:
%   kx          [ 1 x 1 double ] x-component of wave vector for 
%               plane-wave-solution
%   ky          [ 1 x 1 double ] y-component of wave vector for 
%               plane-wave-solution
% optional:
%  potential    [ 1 x 1 double] potential, constant potential is
%               assumed to have plane wave solutions.
%  mass         [ 1 x 1 double] mass, constant mass is assumed 
%  c            [ 1 x 1 double] average particle speed
%  solution     [ -1 or +1] specifies wether positive or negative 
%               mass plane wave solution should be created
%  volumen      [1 x 1 double] area of the 2d domain (Default: 1)
%
% OUTPUTS:
%   A           [ 2 x 1 double] eigenspinor of the DiracOperator
%   E           [ 1 x 1 double] Energy of the plane wave solution
%
% Note: The plane waves are normalised to the given volumen of the 2d
% domain. If this input is not handed it is set to 1 and the solution might
% not be properly normalized.
%

ip = inputParser();
ip.addOptional('potential', 0)
ip.addOptional('mass', 0, @(x) x>=0)
ip.addOptional('c', 1, @(x) x>0)
ip.addOptional('solution', 1)
ip.addOptional('volumen', 1)
ip.parse(varargin{:})

m = ip.Results.mass;
v = ip.Results.potential;
c = ip.Results.c;
m_plus  = (v + m) / (1i*ip.Results.c);
m_minus = (v - m) / (1i*ip.Results.c);
kk = kx.^2 + ky.^2;

switch ip.Results.solution
    case {'+',1} %positive mass solution
        if kx == 0 && ky == 0
            E = m_plus;
            A = [1;0];
        else
            E = v + sqrt(m^2 + c^2*kk);
            A = [1;0];
            A(2) = (E/(1i*c) - m_plus)/(kx - 1i*ky);
        end
        
    case {'-',-1} % neagtive mass solutions
        if kx == 0 && ky == 0
            E = m_minus;
            A = [0;1];
        else
            E = v - sqrt(m^2 + c^2*kk);
            A = [1;0];
            A(2) = (E/(1i*c) - m_plus)/(kx - 1i*ky);
        end
        
    otherwise
        error('last input must be 1 or -1')
end

A = A./norm(A)./sqrt(ip.Results.volumen); % normailsation

end