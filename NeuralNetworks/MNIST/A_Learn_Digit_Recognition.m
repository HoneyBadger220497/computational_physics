% Skript for training the network to be able of digit recognition
%

% prepare matlab
addpath([pwd,'\..\Networks'])

% init network
carl = HaWiDiRe(28*28,[30,10]);

% prepare data
[imgs, labels] = readMNIST('t10k-images.idx3-ubyte', ...
                           't10k-labels.idx1-ubyte', 10000);
test_data = carl.MNIST2data(imgs, labels);

[imgs, labels] = readMNIST('train-images.idx3-ubyte', ... 
                           'train-labels.idx1-ubyte', 50000);
training_data = carl.MNIST2data(imgs, labels);

% start training
disp('Carl has begun to train!')
n_epochs = 30; minibatch_size = 10; eta = 3 ;
carl.sGD(training_data, n_epochs, minibatch_size, eta, test_data)

