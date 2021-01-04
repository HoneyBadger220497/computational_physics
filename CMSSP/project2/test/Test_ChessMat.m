% Test script for the Class: ChessMat

%% create szeanrio %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CM = ChessMat(zeros(4,6));
CM.setXField(ones(4,3))
CM.setOField(2*ones(4,3))

%% Test 1 (set and get methods) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M_ref = [1,2,1,2,1,2; 2,1,2,1,2,1; 1,2,1,2,1,2; 2,1,2,1,2,1];

if all(CM.getMat() == M_ref)
    disp('Test 1: passed')
else
    disp('Test 1: falied')
end

%% Test 2 interpolation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_interp = CM.xInterp();
o_interp = CM.oInterp();

if all((x_interp == 2*ones(4,3) & (o_interp == ones(4,3))))
    disp('Test 2: passed')
else
    disp('Test 2: falied')
end