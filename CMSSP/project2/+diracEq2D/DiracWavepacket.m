classdef DiracWavepacket < handle
    % Class implementing a object representing a superposition of plane
    % wave solutions of the dirac equation.
    % Alows multiple evaluations on different grids.
    %
    
    properties (SetAccess = protected)
        
        amplitudes;   % [2 x nk double] coefficients used for the superpostion (schould be normailzed)
        wavenumbers;  % [2 x nk double] wavevectors of plane wave solutions that are used in the superpostion 
        eigenspinors;  % [2 x nk double] eigenvectors of the dirac operator to correspondig wave vector 
        energies;     % [2 x nk double] eigenvalues of the dirac operator to correspondig wave vector 
         
        x0 = 0; % coordinate origin for center of wavepacket
        y0 = 0; % coordinate origin for center of wavepacket
        t0 = 0; % starting time when wavepacket was created
        
        particle = true; % if true, positive energy solutions are used
        
        k_avg = 0; % average wave number of wave packet
        E_avg = 0; % average energy of wave packed
        
    end

    methods (Access = public)

        function this = DiracWavepacket(varargin)
            % CONSTRUCTOR
            % 
            % INPUTS:
            % required:
            %  k           [2 x nk double] wave-vectors for superposition
            %  a           [2 x nk compplex] coefficients for superposition
            % optional:
            %  t0          [1 x 1 double] starting time
            %  x0          [1 x 1 double] interference center
            %  y0          [1 x 1 double] interference center
            %  potential   [1 x 1 double] potential, constant potential is
            %              assumed to have plane wave solutions.
            %  mass        [1 x 1 double] mass, constant mass is assumed 
            %  c           [1 x 1 double] average particle speed
            %  solution    [-1 or +1] specifies wether positive or negative 
            %              energy plane wave solution should be supperposed
            %  volumen     [1 x 1 double] area of the 2d domain
            %
            
            % input parse
            ip = inputParser();
            ip.addRequired('k')
            ip.addRequired('a')
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
            this.wavenumbers = ip.Results.k;
            this.amplitudes = ip.Results.a;
            
            if (sum(this.amplitudes(:).^2)-1) >=1e-15
            	warning('Wavepacket will not be normalized')
            end
            
            % parameters
            this.x0  = ip.Results.x0;
            this.y0  = ip.Results.y0;
            this.t0  = ip.Results.t0;

            % construct plane wave solutions
            nk = length(this.amplitudes);
            A = zeros(2,nk);
            E = zeros(1,nk);

            n_k = length(this.wavenumbers(1,:));
            for idx_k = 1:n_k
                    % amplitudes and energy
                    [A(:,idx_k), E(idx_k)] = diracEq2D.planeWaveSolution(...
                        this.wavenumbers(1,idx_k), ...
                        this.wavenumbers(2,idx_k), ...
                        ip.Results.potential,...
                        ip.Results.mass,...
                        ip.Results.c,...
                        ip.Results.solution, ...
                        ip.Results.volumen);

            end
            this.eigenspinors = A;
            this.energies = E;

            % "partice"/"antiparticle" eigenfunctions
            if ip.Results.solution < 0
                this.particle = false; % eigenfunction with negativ mass behavior
            else
                this.particle = true; % eigenfunction with positive mass behavior
            end
            
            [this.k_avg, this.E_avg] = this.estimateEnergeticProperties(); 
            
        end     
        
        function  [u,v] = getComponent(this, xx, yy, t)
            % calculates the components of u and v of the spinor at given 
            % x and y positions at time t.
            %
            % INPUT:
            % required:
            %   xx      [nx x ny double] x-gridpoints for evaluation 
            %   yy      [nx x ny double] y-gridpoints for evaluation 
            %   t       [ 1 x  1 double] timestamp of evaluation
            % 
            % OUTPUT:
            %   u       [nx x ny complex] u-component of spinor  
            %   v       [nx x ny complex] v-component of spinor 
            %
        
            n_k = length(this.energies);
            a = zeros(1,n_k);
            
            this.x0; this.y0;
            
            u = zeros(size(xx));
            v = zeros(size(xx));
            for i_k = 1:n_k
                k = this.wavenumbers(:,i_k);
                
                A = this.eigenspinors(:,i_k);
                E = this.energies(:,i_k);
                
                a_k = this.amplitudes(i_k);
                a(i_k) = a_k;
                
                phi = exp(1i*k(1)*(xx-this.x0));
                phi = phi.*exp(1i*k(2)*(yy-this.y0));
                phi = phi.*exp(-1i*E*t);
                u = u + a_k*A(1)*phi;
                v = v + a_k*A(2)*phi;
                
            end
        
        end %getComponent
        
        function plotWavenumbers(this,parent)
            % plots all wavevectors of the plane wave solutions used in the
            % superpostion as points in the 2d-plane
            %
            
            if ~exist('parent','var') || isempty(parent)
                parent = gca();
            end
            
            plot(parent, this.wavenumbers(1,:), this.wavenumbers(2,:), '.b');
            title('Wavevectors in Superposition')    
        
        end %plotWavenumbers
        
        function [k, E] = estimateEnergeticProperties(this)
            % calculates the mean wave-vector and the mean energy of the
            % superposition. 
            %
            % This works since it is a linear combination of plane waves
            % which are eigenfuncktion to the momentum and Hamilton
            % operator.
            %
            
            a = this.amplitudes / sqrt(sum(abs(this.amplitudes).^2));
            
            k = sum(abs(a).^2.*this.wavenumbers,2);
            E = sum(abs(a).^2.*this.energies);
            
        end %estimateEnergeticProperties
        
    end
    
end