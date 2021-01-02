classdef ChessMat < handle
    % Class for a 2n x 2m matrix which has the additional structure of a 
    % chessboard. The values at the x-positions and the o-postios can be 
    % adressed seperatley. 
    %   
    % GRAPHICAL SCEMEATICS OF HOW VALUES ARE STORED INTERNALY
    % 
    %   x o x o x o      x   x   x           o   o   o
    %   o x o x o x        x   x   x       o   o   o  
    %   x o x o x o -->  x   x   x     +     o   o   o
    %   o x o x o x        x   x   x       o   o   o  
    %   x o x o x o      x   x   x           o   o   o
    %   o x o x o x        x   x   x       o   o   o  
    %  
    %                         |                 |
    %                         v                 v
    %
    % n-1 shifts lefts   x x x             o o o   n shifts left
    %   n shifts lefts   x x x             o o o   n-1 shifts lefts
    % n-1 shifts lefts   x x x             o o o   n shifts left
    %   n shifts lefts   x x x             o o o   n-1 shifts lefts 
    % n-1 shifts lefts   x x x             o o o   n shifts left
    %   n shifts lefts   x x x             o o o   n-1 shifts lefts
    %
    
    properties (SetAccess = protected)

        % properties of matrix
        dims = [0,0] % size of the wohle matrix. Is of dim 2n x 2m. 
        x_field = [] % all values at x-positions
        o_field = [] % all values at o-positions

        % boundary conditions (for neighbourhoods)
        bc = 't' % t -> for periodic boundary conditions (torus)
                 % 0 -> for zero boundary conditions   

    end

    methods (Access = public)

        function this = ChessMat(M, varargin)

            if mod(size(M,1),2) ~= 0 || mod(size(M,1),2) ~= 0
                error("M must be a 2n x 2m matrix")
            else
                this.dims = size(M); 
            end

            this.x_field = zeros(this.dims(1), this.dims(2)/2);
            this.x_field(1:2:end,:) = M(1:2:end, 1:2:end);
            this.x_field(2:2:end,:) = M(2:2:end, 2:2:end);

            this.o_field = zeros(this.dims(1), this.dims(2)/2);
            this.o_field(1:2:end,:) = M(1:2:end, 2:2:end);
            this.o_field(2:2:end,:) = M(2:2:end, 1:2:end);

            ip = inputParser();
            ip.addOptional('bc', 't', @(x) ischar(x) )
            ip.parse(varargin{:});
            
            bc = ip.Results.bc;
            if strcmp(bc, 't')
                this.bc = bc;
            elseif strcmp(bc, '0')
                this.bc = bc;
            else
                error('Second input is not a valid boundary condition!')
            end
            
        end %constructor

        function setOField(this, M)
            % sets the property o_field
            %
            % SYNTAX
            %   this.setOField(M)
            %
            % INPUTS
            %   M    [nxm double] matrix to set as value for o_field
            %
            
            if all(size(M) == size(this.o_field))
                this.o_field = M;
            else
                error('Can not write. Size does not agree!')
            end
            
        end %setOField

        function setXField(this, M)
            % sets the property x_field
            %
            % SYNTAX
            %   this.setXField(M)
            %
            % INPUTS
            %   M    [nxm double] matrix to set as value for x_field
            %
            
            if all(size(M) == size(this.x_field))
                this.x_field = M;
            else
                error('Can not write. Size does not agree!')
            end
            
        end % setXField
        
        function x_field = getXField(this)
            % returns the property x_field
            %
            % SYNTAX
            %  x_field = this.getXField()
            %
            % Outputs
            %   x_field    [nxm double] value of x_field property
            %
            
            x_field = this.x_field;
            
        end %getXField

        function o = getOField(this)
            % returns the property o_field
            %
            % SYNTAX
            %   o_field = this.getXField()
            %
            % Outputs
            %   o_field    [nxm double] value of o_field property
            %
            
            o = this.o_field;
            
        end %getOField
        
        function oWrite(this, M)
            % overwrites o_fields of the chessmat with the corresponding
            % entries of M
            %
            % SYNTAX
            %   this.oWrite(M)
            %
            % INPUTS
            %   M   [2n x 2m] Matrix of the sames size as the ChessMat
            %
            
            if all(size(M) == this.dims)
                
                this.o_field(1:2:end,:) = M(1:2:end, 2:2:end);
                this.o_field(2:2:end,:) = M(2:2:end, 1:2:end);

            else
                error('Can not write. Size does not agree!')
            end
        end %oWrite

        function xWrite(this, M)
            % overwrites x_fields of the chessmat with the corresponding
            % entries of M
            %
            % SYNTAX
            %   this.xWrite(M)
            %
            % INPUTS
            %   M   [2n x 2m] Matrix of the sames size as the ChessMat
            %
            
            if all(size(M) == this.dims)
                
                this.x_field(1:2:end,:) = M(1:2:end, 1:2:end);
                this.x_field(2:2:end,:) = M(2:2:end, 2:2:end);
                
            else
                error('Can not write. Size does not agree!')
                
            end
            
        end %xWrite
        
        function M = getMat(this)
            % returns the whole Chessmatrix as a regular matrix
            %
            % SYNTAX
            %
            % 
            
            M = zeros(this.dims);
            M(1:2:end, 1:2:end) = this.x_field(1:2:end,:);
            M(2:2:end, 2:2:end) = this.x_field(2:2:end,:);
            M(1:2:end, 2:2:end) = this.o_field(1:2:end,:);
            M(2:2:end, 1:2:end) = this.o_field(2:2:end,:);
            
        end
        
        function disp(this)
            % Overloading of disp() method
            %
            
            M = this.getMat();
            disp(M)
            
        end %disp
        
        function [L,R,U,D] = getONeighbourhood(this)
            % function that returns four matrices containing the left, 
            % right, up and down neighbours in the chessmat of the  
            % elements of the o_field. All of these neighbours are elemts 
            % of the x_field. 
            %
            % VISUALISATION OF NEIGHBOURHOOG LABELING:
            %
            %  odd row neighbourhood rules
            %
            %    o o o        x x x
            %    o o o        x u x        
            %    o p o   ->   x l r
            %    o o o        x d x
            %    o o o        x x x
            %    o o o        x x x
            %
            %  even row neighbourhood rules
            %
            %    o o o        x x x
            %    o o o        x x x        
            %    o o o        x u x
            %    o p o   ->   l r x
            %    o o o        x d x
            %    o o o        x x x
            %
            % SYNTAX:
            % [L,R,U,D] = thsi.getONeighbourhood()
            % 
            % OUTPUTS:
            %   L   [nx2m double] Left neighbourhood
            %   R   [nx2m double] right neighbourhood
            %   U   [nx2m double] up neighbourhood
            %   D   [nx2m double] down neighbourhood
            % 

            n = size(this.x_field, 1); 
            idx_odd = 1:2:(n-1); % odd rows 
            idx_even = 2:2:n;    % even rows  

            [R, L] = deal(this.x_field);
            
            switch this.bc
                case 't' % periodic bc
                    % left neighbourhood matrix
                    L(idx_even,:) = [L(idx_even,end), L(idx_even,1:end-1)];
                    
                    % right neigbourhood matrix
                    R(idx_odd,:) = [R(idx_odd,2:end),R(idx_odd,1)];
                    
                    % up neigbourhood matrix
                    U = [this.x_field(end,:); this.x_field(1:end-1,:)];
                    
                    % down neighbourhood matrix
                    D = [this.x_field(2:end,:); this.x_field(1,:)];
                    
                case {'0'} % zero bc
                    % left neighbourhood matrix
                    L(idx_even,2:end) = L(idx_even,1:end-1);
                    L(:,1) = 0;
                    
                    % right neigbourhood matrix
                    R(idx_odd,1:end-1) = R(idx_odd,2:end);
                    R(:,end) = 0;
                    
                    % up neigbourhood matrix
                    U = [0*this.x_field(end,:); this.x_field(1:end-1,:)];
                    
                    % down neighbourhood matrix
                    D = [this.x_field(2:end,:); 0*this.x_field(1,:)];    
            end      

        end %getONeighbourhood

        function [L,R,U,D] = getXNeighbourhood(this)
            % function that returns four matrices containing the left, 
            % right, up and down neighbours in the chessmat of the  
            % elements of the x_field. All of these neighbours are elemts 
            % of the o_field. 
            %
            % VISUALISATION OF NEIGHBOURHOOG LABELING:
            %
            %  odd row neighbourhood rules
            %
            %    x x x        o o o
            %    x x x        o u o        
            %    x p x   ->   l r o
            %    x x x        o d o
            %    x x x        o o o
            %    x x x        o o o
            %
            %  even row neighbourhood rules
            %
            %    x x x        o o o
            %    x x x        o o o        
            %    x x x        o u o
            %    x p x   ->   o l r
            %    x x x        o d o
            %    x x x        o o o
            %
            % SYNTAX:
            % [L,R,U,D] = thsi.getXNeighbourhood()
            % 
            % OUTPUTS:
            %   L   [nx2m double] Left neighbourhood
            %   R   [nx2m double] right neighbourhood
            %   U   [nx2m double] up neighbourhood
            %   D   [nx2m double] down neighbourhood
            % 
            
            n = size(this.o_field, 1); 
            idx_odd = 1:2:(n-1); % odd rows 
            idx_even = 2:2:n;    % even rows  

            [R, L] = deal(this.o_field);
            
            switch this.bc
                case 't' % periodic bc
                    % left neighbourhood matrix
                    L(idx_odd,:) = [L(idx_odd,end), L(idx_odd,1:end-1)];
                    
                    % right neigbourhood matrix
                    R(idx_even,:) = [R(idx_even,2:end),R(idx_even,1)];
                    
                    % up neigbourhood matrix
                    U = [this.o_field(end,:); this.o_field(1:end-1,:)];
                    
                    % down neighbourhood matrix
                    D = [this.o_field(2:end,:); this.o_field(1,:)];
                    
                case {'0'} % zero bc
                    % left neighbourhood matrix
                    L(idx_odd,2:end) = L(idx_odd,1:end-1);
                    L(:,1) = 0;
                    
                    % right neigbourhood matrix
                    R(idx_even,1:end-1) = R(idx_even,2:end);
                    R(:,end) = 0;
                    
                    % up neigbourhood matrix
                    U = [0*this.o_field(end,:); this.o_field(1:end-1,:)];
                    
                    % down neighbourhood matrix
                    D = [this.o_field(2:end,:); 0*this.o_field(1,:)];  
                    
            end      

        end %getXNeighbourhood

        function [o_interp, M_interp] = oInterp(this)
            % calculates new values for the elements of the o_field using
            % linear interpolation and the four neighbouring values of the
            % x_field.
            % This function does not change the ChessMat itself
            %
            % SYNTAX:
            %   [o_interp, M_interp] = this.oInterp()
            %
            % OUTPUT:
            %   o_interp    [ n x 2m double] interpolated values
            %   M_interp    [2n x 2m double] Whole Matrix with interpolated
            %               o_filed values and old x_field values.
            %
            
            [Lo,Ro,Uo,Do] = this.getONeighbourhood();
            o_interp = (Lo + Ro + Uo + Do)/4;
            
            if nargout == 2
                M_interp = zeros(this.dims);
                M_interp(1:2:end, 1:2:end) = this.x_field(1:2:end,:);
                M_interp(2:2:end, 2:2:end) = this.x_field(2:2:end,:);
                M_interp(1:2:end, 2:2:end) = o_interp(1:2:end,:);
                M_interp(2:2:end, 1:2:end) = o_interp(2:2:end,:);
            end     
            
        end
        
        function [x_interp, M_interp] = xInterp(this)
            % calculates new values for the elements of the x_field using
            % linear interpolation and the four neighbouring values of the
            % o_field.
            % This function does not change the ChessMat itself
            %
            % SYNTAX:
            %   [x_interp, M_interp] = this.xInterp()
            %
            % OUTPUT:
            %   x_interp    [ n x 2m double] interpolated values
            %   M_interp    [2n x 2m double] Whole Matrix with interpolated
            %               x_filed values and old o_field values.
            %
            
            [Lx,Rx,Ux,Dx] = this.getXNeighbourhood();
            x_interp = (Lx + Rx + Ux + Dx)/4;
            
            if nargout == 2
                M_interp = zeros(this.dims);
                M_interp(1:2:end, 1:2:end) = x_interp(1:2:end,:);
                M_interp(2:2:end, 2:2:end) = x_interp(2:2:end,:);
                M_interp(1:2:end, 2:2:end) = this.o_field(1:2:end,:);
                M_interp(2:2:end, 1:2:end) = this.o_field(2:2:end,:);
            end     
            
        end
        
%         function setBoundaryConditions(this, bc)
%             % Sets boundary condition property
%             %
%             
%             switch bc
%                 case {'t', '0'}
%                     this.bc = bc;
%                 case 0
%                     this.bc = '0';
%                 otherwise
%                     error('Not a valid boundary condition')
%             end    
%             
%         end    
        
    end
   
end

