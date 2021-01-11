classdef Fds1DSolution < handle
    % Class that stores the solutions of a 1d finite difference sceme 
    % 
    
    properties (SetAccess = public)
        
        xx = []         % x-values of domain
        
        time = []       % timestapms of solutions
        solution = []   % array of solutions
        
        units = struct('space', 'm', 'time', 's')
        
    end
    
    methods (Access = public)
        
        function this = Fds1DSolution(varargin)
            
            ip = inputParser();
            ip.addRequired('xx', @(x) isnumeric(x));
            ip.addOptional('unitSpace', 'm', @(x) ischar(x));
            ip.addOptional('unitTime', 's', @(x) ischar(x));
            ip.parse(varargin{:})
            
            this.xx = ip.Results.xx;
            
            unit = struct(...
                'space', ip.Results.unitSpace, ...
                'time' , ip.Results.unitTime);
            this.units = unit;
            
            this.time = [];
            this.solution = [];
            
        end %constructor
        
        function appendSolution(this, t, sol)
            % appends a solution at time t to the Fds2DSolution object
            %            
            % INPUT:
            %   t       [1 x 1 double] timestamp of solution
            %           Attention: t must be greater than the latest time step!
            %   sol     [n x m double] solution of 2d fds
            %  
            
            if ~isempty(this.solution)
                if t > this.time(end)
                    this.time(end+1) = t;
                    this.solution(:, end+1) = sol;
                    
                else
                    error(['t is smaller than latest timestamp! ' ...
                           'If this is intended use "insertSolution" ' ...
                           'instead.'])
                end
                
            else
                this.time = t;
                this.solution = sol(:);
                
            end
            
        end %appendSolution
        
        function insertSolution(this, t, sol)
            % Inserts a solution at time t to the Fds2DSolution object
            %            
            % INPUT:
            %   t       [1 x 1 double] timestamp of solution
            %           Attention: there must no exist already an solution
            %           at time t!
            %   sol     [n x m double] solution of 2d fds
            %  
            
            if ~isempty(this.solution)
                if any(t == this.time)
                    error(['There is already a solution to this time t!' ...
                          'If this is intended use "replaceSolution" ' ...
                          'instead.'])
                else
                    idx = find(t < this.time, 'last');
                    
                    this.time(idx+1:(end+1)) = this.time(idx:end);
                    this.time(idx) = t;
                    
                    this.solution(:,idx+1:(end+1)) = this.solution(:,idx:end);
                    this.solution(:,idx) = sol;
                    
                end
                
            else
                this.time = t;
                this.solution = sol;
            end
            
            
        end %insertSolution
        
        function replaceSolution(this, t, sol)
            % Replaces a solution at time t to the Fds2DSolution object
            %            
            % INPUT:
            %   t       [1 x 1 double] timestamp of solution
            %           Attention: there must already exist an solution
            %           at time t!
            %   sol     [n x m double] solution of 2d fds
            %  
            
            if ~isempty(this.solution)
                idx = find(t == this.time);
                
                if lenth(idx) == 1
                    this.solution(:,idx) = sol;
                    
                else
                    error('There is not exactly one entry for t!')
                    
                end
                
            else
                this.time = t;
                this.solution = sol;
                
            end
            
        end %insertSolution
        
        function sol = getSolution(idx)
            % gets the solution at slide with index idx.
            % returns it as a row vector
            %
            
            sol = this.solution(:,idx);
            sol = sol(:).';
            
        end
        
        function changeUnits(this, space_unit, time_unit)
            % Changes the untis of the solution 
            %
            % INPUTS:
            %   space_unit  [string] Unit of space    
            %   time_unit   [string] Unit of time
            
            if ~isempty(space_unit)
                this.units.space = space_unit;
            end
            
            if ~isempty(time_unit)
                this.units.time = time_unit;
            end
        
        end
        
    end
    

end