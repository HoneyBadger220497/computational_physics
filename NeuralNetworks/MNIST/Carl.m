% NeuralNetwork for HAndWrIten DIgit REcognition
% base on simple FeedForward network Perceptron Neural Network (PNN)

classdef Carl < SimplePNN
    
    properties (SetAccess = public)
        
        c_matrix = []; % confusion matrix of network
        
    end 
    
    methods (Access = public)
        
        function this = Carl(n_input, layout)
            
            % Constructor 
            %
            % INPUT
            % required:
            % n_input   [1 x 1 double] number of expected pixel
            % layout    [1 x n_layer double] vector where each component 
            %               corresponds to a layer of the network, with the 
            %               value representing the number of neurons in the
            %               layer. The last componenet is the output layer. 
            %               The other entries correspond to the hidden 
            %               layers. Note that the input layer is discribed
            %               seperately by the first constuctor argument.
            %
            % Example:
            %   carl = Carl(1,[20,10,1])
            
            % call superclass constructor
            this = this@SimplePNN(n_input, layout);
            % this.weights = cellfun(@(x) x./this.n_input, this.weights, ...
            %                          'UniformOutput', false); 
                          
            % init confusion matrix
            this.c_matrix = rand(this.layout(end));
            
            % activation function function
            sigmoid = @(z) 1./(1 + exp(-z));
            this.activation_fnc = @(z) sigmoid(z/10);
            sigmoid_prime = @(z) exp(-z)./(1 + exp(-z)).^2;
            this.der_activation_fnc = @(z) sigmoid_prime(z/10)*1/10;
            
        end
        
        function [success, error] = testNetwork(this, test_data, show)
            
            % init 
            error = 0;
            success = 0;
            c_mat = zeros(this.layout(end) + [1,0] ); % init c_matrix            
            
            for sample =  test_data.' % iteration over columns
                
                a_in = sample(1:this.n_input);
                y = sample(this.n_input+1:end);
                
                a = this.feedForward(a_in);
                
                error = error + this.cost_fnc(a, y);
                
                [~, recognised] = max(a); % ToDo: improve syntax here
                expected = find( y == 1 );
                success = success + (recognised == expected ); 
                
                % collect data for calclulation confusion_matrix
                c_mat(:, expected) = c_mat(:, expected) + [y(:); 1];
                
            end
            
            % averaging c_matrix
            for idx_c = 1:this.layout(end)
                c_mat(1:end-1,idx_c) = c_mat(1:end-1,idx_c) / ...
                                          c_mat(end, idx_c);  
            end
            
            % update c_matrix
            this.c_matrix = c_mat(1:end-1, :);    
            
            % avarage error and success
            n_samples = size(test_data,1);
            success = success/n_samples * 100;
            error = error/n_samples;
            
            if show  
                disp(['Error: ', num2str(error), '  Success: ', ...
                      num2str(fix(success),'%d'), ' %'])
            end
            
        end
        
        function dispCMatrix(this)
            
            gcf;
            image(this.c_matrix*100)
            colormap('bone')
            
        end
        
        function askCarl(this, img)
            
            gcf;
            image((1-img)*100)
            colormap('Bone')
            disp('User: What number is it Carl?')
            
            a = this.feedForward(img(:));            
            [~, carls_guess] = max(a);
            carls_convenience = 2*a(carls_guess) - sum(a); 

            carls_guess = carls_guess-1;           
            if carls_convenience > 0.9 
                disp(['Carl: I am absolutley shure it is ', num2str(carls_guess)])
            elseif carls_convenience > 0.7  
                disp(['Carl: It is ', num2str(carls_guess)])
            elseif carls_convenience > 0.5   
                disp(['Carl: I am pretty shure it is ', num2str(carls_guess)])
            elseif carls_convenience > 0.4   
                disp(['Carl: I am not quite shure, is it ', num2str(carls_guess), ' ?'])
            elseif carls_convenience > 0.1
                disp(['Carl: If i had to guess, i would say it is ', num2str(carls_guess)])
            else
                disp(['Carl: I hav no idea! Is it ' , num2str(carls_guess), ' ?'])
            end
            disp('Carl: you got another one for me?')
            disp(' ')
        end
        
    end
    
    methods(Static)
        
        function [data] = MNIST2data(imgs, lables)
            
            s_imgs = size(imgs);
            img_data = reshape(imgs, s_imgs(1)*s_imgs(2), s_imgs(3)).';
            lable_data = double([0:9]==lables(:));
            
            data = [img_data, lable_data];
        end
        
        
        
    end
end
