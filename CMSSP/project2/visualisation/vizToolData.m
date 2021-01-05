classdef vizToolData < handle
    
    properties (SetAccess = public)
        
        plot_fnc = @(x,y )plot(x,y)
        update_fnc = @(x,y )plot(x,y)
        domain_data = {};
        plot_data = {};              % [1 x nd cell{[nx x ny x nl]}] 
        plot_lables = {};            % [1 x nd cell{char}] array
        slider_data = [];            % [1 x nl] array
        slider_label = '';           % [char]
        title = '';                  % [char]
        
        nd = 1;
        dimd = 1;
        ax = [];
        
    end
    
    methods (Access = public)
        
        function this = vizToolData(varargin)
            
            ip = inputParser();
            ip.addRequired('nd')
            ip.addRequired('DomainData', @(x) iscell(x));
            ip.addRequired('PlotFnc', @(x )isa(x, 'function_handle'));
            ip.addRequired('PlotLabels', @(x) iscell(x) );
            ip.addParameter('SliderLabel', 'Slide');
            ip.addParameter('Title', []);
            ip.addParameter('UpdateFnc',[],  @(x )isa(x, 'function_handle'));
            ip.parse(varargin{:})
            
            % data size 
            if ip.Results.nd > 3 
                error('plot function is not allowed to use more than 3 data inputs')
            elseif ip.Results.nd < 1
                error('plot function is not allowed to less than than 1 data inputs')
            end
            this.nd = ip.Results.nd;
            
            % domain and dimension
            domain = ip.Results.DomainData;     
            dim_domain = length(domain);
            if dim_domain > 2
                error('data dimension can not be larger than 2')
            end
            this.dimd = dim_domain;
            this.domain_data = domain;
            
            % plot function
            this.setPlotFnc(ip.Results.PlotFnc)
            
            % update fnc
            this.setUpdateFnc(ip.Results.UpdateFnc)
            
            % plot labels
            if length(ip.Results.PlotLabels) == this.nd + this.dimd
                this.plot_lables = ip.Results.PlotLabels;
            elseif length(ip.Results.PlotLabels) > this.nd + this.dimd
                error('Too  many labels')
            else
                error('Not enough labels')
            end          
            this.title = ip.Results.Title;
            this.slider_label = ip.Results.SliderLabel;
            
        end %constructor
        
        function addData(this, slider_data, varargin)
            
            if isempty(this.slider_data)
                this.slider_data = slider_data;
                this.plot_data = varargin;
            else
                if length(varargin) > this.nd
                     error('To many arguments')
                elseif length(varargin) < this.nd
                     error('To few arguments')
                end
                
                this.slider_data(end+1) = slider_data;
                
                if this.dimd == 1
                    for idx_d = 1:this.nd
                        this.plot_data{idx_d}(1,:,end+1) = varargin{idx_d};
                    end
                elseif this.dimd == 2
                    for idx_d = 1:this.nd
                        this.plot_data{idx_d}(:,:, end+1) = varargin{idx_d};
                    end
                end

            end
            
        end %addData
        
        %%% Setter Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setTitle(this, title)
            
           this.title = title;
           
        end %setTilte
        
        function setLabels(this, varargin)
            
           if length(varargin) > this.nd+1
               error('To many labels')
           end
           if ~isempty(varargin{1})
               this.slider_label
           end
           for idx_d = 2:length(varargin)
               if ~isempty(varargin{idx_d})
                    this.label{idx_d} = varargin{idx_d};
               end
           end
        end %setLabels
        
        function setPlotFnc(this, fnc)
            
            if this.validifyFnc(fnc)
                this.plot_fnc = fnc;
            else
                error("Input 'PlotFunction' is not vallid")
            end
            
        end %setPlotFnc
        
        function setUpdateFnc(this, fnc)
            
            if isempty(fnc)
                if this.dimd == 1
                    if this.nd == 1
                        this.update_fnc = @(ax, x, y) updateFunction1D(ax, 1, x, y);
                    elseif this.nd == 2
                        this.update_fnc = @(ax, x, y1, y2) updateFunction1D(ax, 2, x, y1, y2);
                    elseif this.nd == 3
                         this.update_fnc = @(ax, x, y1, y2, y3) updateFunction1D(ax, 3, x, y1, y2, y3);
                    end  
                    
                else
                    if this.nd == 1
                        this.update_fnc = @(ax, x, y, z) updateFunction2D(ax, 1, x, y, z);
                    elseif this.nd == 2
                        this.update_fnc = @(ax, x, y, z1, z2) updateFunction2D(ax, 2, x, y, z1, z2);
                    elseif this.nd == 3
                        this.update_fnc = @(ax, x, y, z1, z2, z3) updateFunction2D(ax, 3, x, y, z1, z2, z3);
                    end  
                    
                end
                
            elseif this.validifyFnc(fnc)
                this.plot_fnc = fnc;
            else
                error("Input 'UpdateFunction' is not vallid")
            end
            
        end %setUpdateFnc
        
        % plot functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function plotf(this, varargin)
            
            ip = inputParser();
            ip.addOptional('ax', gca(), @(x) isa(x, 'matlab.graphics.axis.Axes'))
            ip.addOptional('slider_idx', 1)
            ip.parse(varargin{:})           
            
            this.plot(ip.Results.ax, ip.Results.slider_idx);
            this.plotTitle(ip.Results.ax)
            this.plotLabels(ip.Results.ax)
            
        end
        
        function plot(this, varargin)
            
            ip = inputParser();
            ip.addOptional('ax', gca(), @(x) isa(x, 'matlab.graphics.axis.Axes'))
            ip.addOptional('slider_idx', 1)
            ip.parse(varargin{:})           
            this.ax = ip.Results.ax;
            
            if isempty(this.plot_data)
                error('No data to plot! Please add data.')
            end
            if ip.Results.slider_idx > length(this.slider_data)
                error('Index out of Range! No slider data available.')
            end
            
            % get data
            idx_s = ip.Results.slider_idx;
            data = cell(1, this.nd);
            for idx_d = 1:this.nd
                data{idx_d} = this.plot_data{idx_d}(:,:,idx_s);
            end
            
            % plot data
            this.exeForDim(this.plot_fnc, this.ax, data)
   
        end %updatePlot
        
        function updatePlot(this, varargin)
            
            ip = inputParser();
            ip.addOptional('ax', this.ax, @(x) isa(x, 'matlab.graphics.axis.Axes'))
            ip.addOptional('slider_idx', 1)
            ip.parse(varargin{:})           
            ax_ = ip.Results.ax;
            
            if isempty(this.plot_data)
                error('No data to plot! Please add data.')
            end
            if ip.Results.slider_idx > length(this.slider_data)
                error('Index out of Range! No slider data available.')
            end
            
            % get data
            idx_s = ip.Results.slider_idx;
            data = cell(1, this.nd);
            for idx_d = 1:this.nd
                data{idx_d} = this.plot_data{idx_d}(:,:,idx_s);
            end
            
            % update plot
            this.exeForDim(this.update_fnc, ax_, data)

        end
        
        function plotTitle(this, ax)
            
            title_obj = get(ax, 'Title');
            set(title_obj, 'String', this.title)
        end
        
        function plotLabels(this, ax)
            
            xlabel(ax, this.plot_lables{1})
            ylabel(ax, this.plot_lables{2})           
            if this.dimd >= 2
                zlabel(ax, this.plot_lables{3})   
            end
        end
        
    end
    
    methods (Access = private)
        
        function exeForDim(this, fnc, ax, data)
            
           n_data = length(data); 
           if this.dimd == 1
                if n_data == 1
                    fnc(ax, this.domain_data{1}, data{1});
                elseif n_data == 2
                    fnc(ax, this.domain_data{1}, data{1}, data{2});
                elseif n_data == 3
                    fnc(ax, this.domain_data{1}, data{1}, data{2}, data{3});
                end  
            else
                if n_data == 1
                    fnc(ax, this.domain_data{1}, this.domain_data{2}, data{1});
                elseif n_data == 2
                    fnc(ax, this.domain_data{1}, this.domain_data{2}, data{1}, data{2});
                elseif n_data == 3
                    fnc(ax, this.domain_data{1}, this.domain_data{2}, data{1}, data{2}, data{3});
                end  
            end
        end
        
        function test = validifyFnc(this, fnc)
            
            fig = figure();
            ax_ = axes(fig);
            
            test_data = {};
            for idx_d = 1:this.nd
                test_data{idx_d} = zeros(size(this.domain_data{1}));
            end
            
            try
                this.exeForDim(fnc, ax_, test_data)
                test = true;
            catch err
                disp('The following went wrong while testing plot_fnc:')
                disp(err.message)
                test = false;
            end
            
            close(fig)
            
        end
        
    end
    
end

%%% subroutines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateFunction1D(ax, n_obj, varargin)

    graphic_obj = ax.Children();
    for idx_obj = 1:n_obj
        set(graphic_obj(idx_obj), 'YData', varargin{idx_obj+1});
    end
end

function updateFunction2D(ax, n_obj, varargin)

    graphic_obj = ax.Children();
    for idx_obj = 1:n_obj
        set(graphic_obj(idx_obj), 'ZData', varargin{idx_obj+2});
    end

end


