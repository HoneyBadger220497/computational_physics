function [A, E] = planeWaveSolution(k, varargin)
% this function calculates the eigenvalues and eigenvectors of the
% dirac hamilton operator for a given wavevector k, when using a plane wave
% ansatz.
%
% For plane wave solution a homogenous space is assumed (constant mass and
% potetial).
% The Dirac operator has two types of plane-wave-solutions. Such with
% positive mass behavior and such with negative mass behavior (particle and
% antiparticle solutions).
%
% INPUTS:
% required:
%   k          [ 1 x 1 double ] x-component of wave vector for 
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
m_plus  = (v + m) / (1i*c);
m_minus = (v - m) / (1i*c);


H_dirac = [m_plus, -1i*k; -1i*k, m_minus];
[A,E] = eig(H_dirac);
E = real(1i*c*diag(E));

switch ip.Results.solution
    case {1,'+'}
        [~,idx_sol] = max(E);
    case {-1,'-'}
        [~,idx_sol] = min(E);
end

E = E(idx_sol);
A = A(:,idx_sol);
A = A./norm(A)./sqrt(ip.Results.volumen); % normailsation

end