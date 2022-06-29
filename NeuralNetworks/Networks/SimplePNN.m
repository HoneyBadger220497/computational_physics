% Simple Neural-Network trained with backpropagation algorithm, using a 
% quadratic cost function and the sigmoid function as activation function.
% 
% Creation ideas mainly from:
%   http://neuralnetworksanddeeplearning.com/index.html
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author:  Joachim Pomper
% created: 19.09.2019
% updated: 20.09.2019 
% by:      Joachim Pomper
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef SimplePNN < handle

    properties (SetAccess = public)
        
        % network parameters
        weights = {}; % [1 x n_layer cell] wigths of the network
        biases = {};  % [1 x n_layer cell] biases of the network      
        
        % network sizes
        n_layer = []; % due to matlab indexing it is differred between 
        n_input = []; % the inputlayer and the other layers
        layout = [];   
        
        % activation function1
        activation_fnc = @(z) 1./(1 + exp(-z));
        der_activation_fnc = @(z) exp(-z)./(1 + exp(-z)).^2;
        
        % cost function
        cost_fnc = @(a, y) sum((y - a).^2)/2
        der_cost_fnc = @(a, y) y - a % derivative with respect to a 
        
    end %publicProperties
    
    methods (Access = protected)
        
        function updateNetwork(this, minibatch, eta)
             
            % updates weights and biases of the Network with gradient
            % descent. The gradient is calulated with backpropagation.
            %
            % INPUT
            % minibatch [minibatch_size x (n_input + n_output) double]
            %               see also method .sGD. This is just a part of
            %               the trainingdata used in .sGD.
            % eta       [1 x 1 double] learning rate
            %
            
            % init cell arrays containing zero matrices same size as 
            % the biases and weights
            n_samples = size(minibatch,1);
            nabla_b = cellfun(@(x) 0.*x, this.biases,... 
                              'UniformOutput', false);
            nabla_w = cellfun(@(x) 0.*x, this.weights, ...
                              'UniformOutput', false);
            
            
            % caclulate gradient for each training sample of minibatch
            for i_sample = 1:n_samples 
                x = minibatch(i_sample, 1:this.n_input).'; % x and y must 
                y = minibatch(i_sample, this.n_input+1:end).'; % be cloumns 
                
                [nabla_w_sample, nabla_b_sample] = this.backpropagate(x, y);
                
                nabla_b = cellfun(@(x,y) x+y, nabla_b, nabla_b_sample, ...
                                  'UniformOutput', false); 
                nabla_w = cellfun(@(x,y) x+y, nabla_w, nabla_w_sample, ...
                                  'UniformOutput', false);     
            end
            
            % update biases and weights with calculated gradient
            this.biases = cellfun(@(b,c) b - eta/n_samples.*c, ...
                                  this.biases, nabla_b, ...
                                  'UniformOutput', false); 
            this.weights = cellfun(@(w,c) w - eta/n_samples.*c, ... 
                                   this.weights, nabla_w, ...
                                   'UniformOutput', false);
            
            
        end %updateNetwork
        
        function [nabla_w, nabla_b] =  backpropagate(this, x, y)
            
            % uses the backpropaghation equations to calculate corrections
            % partial derivatives of the costfunction in respect to the 
            % weights and biases. 
            %
            % INPUT
            % x     
            % y
            
            delta = cell(1,this.n_layer);
            
            % calc activations and weighted inputs
            [a, activations, weighted_inputs] = this.feedForward(x);
            
            % calc outputerror vector 
            z = weighted_inputs{this.n_layer};
            delta{this.n_layer} = this.der_cost_fnc(y,a) .* ...
                                  this.der_activation_fnc(z);
                              
            % back propagate error
            for i_layer = this.n_layer-1:-1:1
                z = weighted_inputs{i_layer};
                delta{i_layer} = (this.weights{i_layer+1}.' * ...
                                      delta{i_layer+1}) .* ...
                                      this.der_activation_fnc(z);
            end
            
            % calculate gradients from errors and activations
            nabla_b = delta;
            nabla_w = cellfun(@(a,d) d.*a.', activations, delta, ...
                                   'UniformOutput', false);
            
        end %backPropagation
        
    end %protectedMethods
    
    methods (Access = public)
        
        function this = SimplePNN(n_input, layout)
            
            % Constructor 
            %
            % INPUT
            % required:
            % n_input   [1 x 1 double] number of expected neurons
            % layout    [1 x n_layer double] vector where each component 
            %               corresponds to a layer of the network, with the 
            %               value representing the number of neurons in the
            %               layer. The last componenet is the output layer. 
            %               The other entries correspond to the hidden 
            %               layers. Note that the input layer is discribed
            %               seperately by the first constuctor argument.
            %
            % Example:
            %   NN = PerceptronNeuralNetwork(1,[20,10,1])
            %
            
            % init properties of network
            this.n_input = n_input;
            this.n_layer = length(layout); 
            this.layout = layout;
                            
            this.weights = cell(1, this.n_layer);
            this.biases = cell(1, this.n_layer);
            
            % generate network with random weights and biases 
            net_design = [n_input, layout];
            for i_layer = 1:this.n_layer % input layer has index 1 
                this.weights{i_layer} = rand(net_design(i_layer + [1,0]));
                this.biases{i_layer} = rand(net_design(i_layer+1), 1);
            end
            
        end %constructor
        
        function [a, activations, weighted_inputs] = feedForward(this, a)
            
            % Method calculates activations of output layer from 
            % activations of the input layer by feeding dem through the
            % Network. If requested it also stores all the activations and 
            % weighted inputs of the hidden layer.
            %
            % INPUT
            % a             [n_layer(1) x 1 double] input activations 
            %                   vector. Has to contain of values between
            %                   0 and 1.
            % 
            % OUTPUT
            % a             [layer(end) x 1 double] output activations
            % activations   [1 x n_layer cell] cell containing the 
            %                   activation vectors of the hidden layer and
            %                   the input activations (wich are stored in
            %                   activations {1}).
            % weighted_inputs [1 x n_layer cell] cell containing the 
            %                   weighted inputs of all layer and
            %                   except the inpt layer, because this one has
            %                   no weights
            %
            
            % input parse
            if any(a > 1 | a < 0); error(['All values of "a" have to', ...
                'be in interval [0,1]!']); end
            
            a = a(:); % a has to be a columnvector
            
            if nargout > 1 % document all activations and weighted inputs
               
                activations = cell(1, this.n_layer); 
                weighted_inputs = cell(1, this.n_layer);
                
                for i_layer = 1:this.n_layer
                    activations{i_layer} = a;
                    z = this.weights{i_layer} * a + this.biases{i_layer};
                    weighted_inputs{i_layer} = z;
                    a = this.activation_fnc(z);
                end
                
            else % just calculate the output activations
                
                for i_layer = 1:this.n_layer
                    z = this.weights{i_layer} * a + this.biases{i_layer};
                    a = this.activation_fnc(z);
                end   
                
            end
            
        end %feedForward
        
        function sGD(this, training_data, n_epochs, minibatch_size, eta, test_data)
            
            % Uses stochastic gradient descent method to calculate the 
            % weights and biases of the network
            %
            % INPUT
            %   training_data   [n_samples x (n_input + n_output) double]
            %                       Matrix, where each row corresponds to
            %                       a sample for training the network.
            %                       the first n_input entries of each row
            %                       resemble the input activations, the
            %                       remaining entries are the expected
            %                       output activations. all values have to
            %                       be between 0 and 1.
            %  n_epochs         [1 x 1 double] Number of how often the 
            %                       complete trainingdata is run throug,
            %                       for training.
            %  minibatch_size   [1 x 1 double] Size of a data batch, used
            %                       by the stochastic gradient method to 
            %                       aproximate the gradient. 
            %               
            %  eta              [1 x 1 double] learning rate
            %                       ToDo: How choose learning rate ? 
            %
            % see also: http://neuralnetworksanddeeplearning.com/chap1.html
            %
            
            size_data = size(training_data,1);
            n_batches = floor(size_data/minibatch_size);
            if n_batches*minibatch_size < size_data || n_batches < 1
                warning('minibatch_size migth not fit the size of data')
            end
            
            for i_epoch  = 1:n_epochs
                % generate minibatches training epoch
                idx_rand = randperm(size_data(1));
                epoch = training_data(idx_rand, :);
                
                idx_batch = 1:minibatch_size;
                for i_batch = 1:n_batches
                    batch = epoch((i_batch-1)*minibatch_size + idx_batch,:);
                    this.updateNetwork(batch, eta);
                end
                
                if nargin == 6 && ~isempty(test_data)
                    this.testNetwork(test_data, true);
                end
                
                disp(['Finished Epoch ', num2str(i_epoch),...
                      ' / ',num2str(n_epochs), ' : Training completed ', ...
                      num2str(fix(i_epoch/n_epochs*100), '%d'), '%'])
                  disp(' ')
            
            end

        end
        
        function mean_error = testNetwork(this, test_data, show)
            
            % This mehtod calculates a mean_error using the implementet 
            % cost funtion of the network.
            %
            % this funktion is likely to be redefined by an subclass.
            % always make shure that there is a flag for visual output,
            % because function is used inside method sGD and output cannot
            % be accessed.
            %
            
            error = 0;
            for sample = test_data
                a = this.feedForward(sample(1:this.n_input));
                cost = this.cost_fnc(a, sample(this.n_input+1:end));
                error = error + cost;
            end
            
            mean_error = error/size(test_data,1);
            
            if show
                disp(['Mean_error: ', num2str(mean_error)])
            end
            
        end
        
    end %publicMethods

end %NeutalNetwork