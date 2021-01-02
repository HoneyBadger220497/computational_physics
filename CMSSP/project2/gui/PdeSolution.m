classdef PdeSolution < handle

    properties (SetAccess = public)
        dim = 1
        domain = []
        time = []
        f = []
        units = struct('space', 'm', 'time', 's')
        
    end
    
    methods (Access = public)
        
        function this = PdeSolution(varargin)
            
            ip = inputParser();
            ip.addRequired('x', @(x) isnumeric(x));
            ip.addOptional('y', [], @(x) isnumeric(x));
            ip.addOptional('unitSpace', 'm', @(x) ischar(x));
            ip.addOptional('unitTime', 's', @(x) ischar(x));
            ip.parse(varargin{:})
            
            this.time = [];
            this.domain = ip.Results.x;
            if ~isempty(ip.Results.y)
                this.dim = 2;
                if size(ip.Results.y) == size(ip.Results.x)
                    this.domain(:,:,2) = ip.Results.y;
                else
                    error('Data of x and y domain has to be the same')
                end
            else
                this.dim = 1;
            end
            
            unit = struct(...
                'space', ip.Results.unitSpace, ...
                'time' , ip.Results.unitTime);
            this.units = unit;
            
            this.time = NaN;
            this.f = [];
            
        end
        
        function addSolution(this, t, sol)
            
            if all(isnan(this.time))
                this.time = t;
                this.f = sol;
            else
                if size(sol) == size(this.domain(:,:,1))
                    if t > this.time(end) 
                        this.time(end+1) = t;
                    else
                        error('Time must be increasing!')
                    end
                    
                    if this.dim == 1
                        this.f(:,end+1) = sol;
                    elseif this.dim == 2
                        this.f(:,:,end+1) = sol;
                    end
                    
                else
                    error('Solution array does not support size of domain!')
                end
            end
        end
        
        function changeUnits(this, space_unit, time_unit)
        
            if ~isempty(space_unit)
                this.units.space = space_unit;
            end
            
            if ~isempty(time_unit)
                this.units.time = time_unit;
            end
        
        end
        
        function visualize(this)
            
            if this.dim == 2
                vizTool2D(this)
            else
                error('No visualization supportet')
            end
        end
        
    end
    

end