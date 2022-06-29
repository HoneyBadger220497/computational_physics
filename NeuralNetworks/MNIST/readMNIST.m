function [imgs, labels] = readMNIST(imgFile, labelFile, n_digits, offset)

% Description:
% Read digits and labels from raw MNIST data files
% File format as specified on http://yann.lecun.com/exdb/mnist/
% Note: The 4 pixel padding around the digits will be remove
%       Pixel values will be normalised to the [0...1] range
%
% Syntax:
% [imgs, labels] = readMNIST(imgFile, labelFile, n_digits, offset)
%
% INPUT
% required: 
% imgFile     [char] name of the image file
% labelFile   [char] name of the label file
% n_digits  [1x1 double] number of digits to be read
%               default: All pictures
%
% optional:
% offset      [1x1 double] skips the first offset number of digits before,
%               reading starts. Default: 0
%
% OUTPUT
% imgs = 20 x 20 x n_digits sized matrix of digits
% labels = n_digits x 1 matrix containing labels for each digit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author:  Siddharth Hegde (http://yann.lecun.com/exdb/mnist/)
% created: 20.05.2010
% updated: 23:09:2019 
% by:      Joachim Pomper 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

    %%% Input parse%%%
    if nargin < 4 || isempty(offset);  offset = 0; end        
    
    %%% Read digits %%%
    fid = fopen(imgFile, 'r', 'b');
    header = fread(fid, 1, 'int32');
    if header ~= 2051
        error('Invalid image file header');
    end
    count = fread(fid, 1, 'int32');
    if count < n_digits+offset
        error('Trying to read too many digits');
    end
    
    h = fread(fid, 1, 'int32');
    w = fread(fid, 1, 'int32');
    
    if offset > 0
        fseek(fid, w*h*offset, 'cof');
    end
    
    imgs = zeros([h w n_digits]);
    
    for i=1:n_digits
        for y=1:h
            imgs(y,:,i) = fread(fid, w, 'uint8');
        end
    end
    
    fclose(fid);
    % Read digit labels
    fid = fopen(labelFile, 'r', 'b');
    header = fread(fid, 1, 'int32');
    if header ~= 2049
        error('Invalid label file header');
    end
    count = fread(fid, 1, 'int32');
    if count < n_digits+offset
        error('Trying to read too many digits');
    end
    
    if offset > 0
        fseek(fid, offset, 'cof');
    end
    
    labels = fread(fid, n_digits, 'uint8');
    fclose(fid);
    
    % Calc avg digit and count
    % imgs = trimDigits(imgs, 4);
    imgs = normalizePixValue(imgs);
    %[avg num stddev] = getDigitStats(imgs, labels);
    
end

%%% Subroutines %%% 
function digits = trimDigits(digitsIn, border)
    dSize = size(digitsIn);
    digits = zeros([dSize(1)-(border*2) dSize(2)-(border*2) dSize(3)]);
    for i=1:dSize(3)
        digits(:,:,i) = digitsIn(border+1:dSize(1)-border, border+1:dSize(2)-border, i);
    end
end
function digits = normalizePixValue(digits)
    digits = double(digits);
    for i=1:size(digits, 3)
        digits(:,:,i) = digits(:,:,i)./255.0;
    end
end
