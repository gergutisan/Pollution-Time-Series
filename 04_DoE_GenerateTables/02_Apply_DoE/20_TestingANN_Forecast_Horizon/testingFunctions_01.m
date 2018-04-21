%% INITIALIZATIONS
% clear; clc;close('all'); fclose('all');
clear; close('all'); fclose('all');
cd(fileparts(mfilename('fullpath')));    % does not work if executed by Run Section [and advance]
folderFunctions  = strcat(fileparts(mfilename('fullpath')),'\Functions');
folderTimeSeries = strcat(fileparts(mfilename('fullpath')),'\TimeSeries');
folderFigures    = strcat(fileparts(mfilename('fullpath')),'\Figures');

path( folderFunctions  , path );
path( folderTimeSeries , path );
path( folderTimeSeries , path );

% set the left corner position and the size of the figures
% setScreenSize (10, 0.4);

%% SET THE PARAMETERS 
% Seed
v = (int32(clock)); seed = v(6); clear v; rng(seed);  fprintf('Seed: %03d\n',seed); % seed is the second for time 


parameters.horizon             = 2;            
parameters.rngSeed             = seed;            clear v seed;
parameters.showOnScreen        = 1;
parameters.divideMode          = 'sample';        % (up to now) FIXED
parameters.divideFcn           = 'divideblock';   % (up to now) FIXED
parameters.trainParam.min_grad = 0;
parameters.trainParam.time     = Inf;
parameters.times2seeTrain      = 5;
parameters.netView             = 0;
parameters.showTrainRecord     = 1;

hiddenLayersSize = [20];  % One hidden layer  with 20 neurons
trainFcnStr      = 'trainscg'; % 
                                          % (#1) 'trainlm'  - Levenberg-Marquardt optimization, fastest backpropagation alg in the toolbox
                                         % (#2) 'traingd'  - Gradient descent backpropagation.
                                         % (#3) 'traingda' - Gradient descent with adaptive lr backpropagation.
                                         % (#4) 'traingdx' - Variable Learning Rate Gradient Descent
                                         % (#5) 'trainrp'  - RPROP Resilient Backpropagation.
                                         % (#6) 'trainscg' - Scaled conjugate gradient backpropagatio
                                         % (#7) 'traingdm' - Gradient Descent with Momentum

transferFcn      = 'tansig';
trainPrctg       = 80;   % (up to now) FIXED
valPrctg         = 10;   % (up to now) FIXED
testPrctg        = 100 - trainPrctg - valPrctg; % FIXED

trCycles     = 10^3;
learningRate = 0.2;
trainGoal    = 0.0000001; 

times2seeTrain = 5;

%% LOAD DATA ================================================================

%--- Examples of data file for time series data
% Data_Accidental.mat
% Data_Airline.mat
% Data_Overshort.mat
% Data_PowerConsumption.mat
% ccr.mat
% SharePrices.mat

% ----------------------------------------------------------------------------
% parameters.tsName = 'Mackey-Glass'; load mgdata.dat;            tsData = mgdata(:,2); % plot(tsData);
% parameters.tsName = 'Return';       load predict_ret_data.mat;  tsData = sdata(1:end); plot(tsData); 
parameters.tsName = 'SharePrices.mat;'; load SharePrices.mat;  tsData = data(:,1); %plot(tsData); 
   % Training with TRAINGD completed: Minimum gradient reached.

% parameters.tsName = 'NO2-FedzLadreda-16-12'; tsData = load(strcat(folderTimeSeries,'\','ts-NO2-FedzLadreda-16-12.csv')); % plot(tsData); 
% ----------------------------------------------------------------------------   

nInputs  = 28;
nOutputs = 1;
patterns = ts2Patterns( tsData, nInputs, nOutputs );

%% PATTERNS and Targets 
patterns_inputs  = patterns(:,1:nInputs);
patterns_targets = patterns(:,(nInputs+1):(nInputs+nOutputs));

x = patterns_inputs';
t = patterns_targets';
 % ( patters, or matrix for input patterns )
%% Create the ANN   --------------------------------------------------------
net01 = feedforwardnet(hiddenLayersSize,trainFcnStr); 
net01.userdata.note = 'ann for TS forecasting';
%{
f = view(net01);
fprintf('\nPuase. Press any key to continue. ');pause();fprintf('\n')
close(f);
%}

% ANN Configuration (transfer functions each layer)
%{
 Configuration is the process of setting network input and output sizes 
 and ranges, input preprocessing settings and output postprocessing settings,
 and weight initialization settings to match input and target data.

 Configuration must happen before a network's weights and biases can be initialized. 
 Unconfigured networks are automatically configured and initialized the first time train 
 is called. Alternately, a network can be configured manually either by calling this function 
 or by setting a network's input and output sizes, ranges, processing settings, and initialization 
 settings properties manually.
%}

%{
Inputs of the ANN (in NN Matlab Toolbox )

The number of network inputs and the size of a network input are not
the same thing. The number of inputs (net.numInputs) defines how many sets of vectors
the network receives as input. The size of each input (i.e., the number
of elements in each input vector) is determined by the input size
(net.inputs{i}.size).

Most networks have only one input, whose size is determined by the
problem.

net01.numInputs
net01.inputs{1}.size

%}

net01.layers{1}.transferFcn = transferFcn;
net01.layers{2}.transferFcn = transferFcn;

net01 = configure(net01,x,t);

if (parameters.showOnScreen)
  fprintf('\n -> net01.inputs{1}.size: %i -- size(x,1): %i \n', ... 
           net01.inputs{1}.size, size(x,1));
end

%% INITIALIZATION OF THE NET
net01 = init(net01);

%{
f = view(net01);
fprintf('\nPuase. Press any key to continue. ');pause();fprintf('\n')
close(f);
%}
%{
net02 = network;
f = view(net02);
fprintf('\nPuase. Press any key to continue. ');pause();fprintf('\n')
close(f);
%}
%{
net.numLayers -> num of Layers
net.layers -> numLayers-by-1 cell => array net.layers{i} is a structure defining layer i. 
    net.layers{1}
        net.layers{1}.name

    net.layers{1}.initFcn    ('initw': )
    net.layers{1}.netInputFunction ('netsum')

    net.layers{1}.range(1);  % defines the output range of each neuron of the ith layer
    net.layers{1}.range(2);

    net.layers{1}.dimensions  % -> the physical dimensions of the ith layer's neurons.   Being able to arrange a layer's neurons in a  multidimensional manner is important for self-organizing maps.
    net.layers{1}.size;       % -> the number of neurons in the ith layer. It can be set to 0 or a positive integer  

  net.layers{2}
    net.layers{2}.name
    net.layers{2}.dimensions

net.b{i} bias values for the layer i

%}

%% SET THE PARAMETERs AND INFORMATION TO TRAIN the ANN
% Split data set into train, validation, and test subsets
net01.divideFcn  = parameters.divideFcn ;    % net01.divideFcn ='divideblock'; 
net01.divideMode = parameters.divideMode;    % net01.divideMode = 'sample'; 

% net01.divideParam
net01.divideParam.trainRatio = trainPrctg/100; 
net01.divideParam.valRatio   = valPrctg/100;
net01.divideParam.testRatio  = testPrctg/100;

%{
    Trainning Algorithm -> help nntrain  or help(net01.trainFcn) 
    trainFcn = 'traingd'; 
               % 'traingd'   - Gradient descent backpropagation.
               % 'traingda'  - Gradient descent with adaptive lr backpropagation.
               % 'trainrp'   - RPROP backpropagation.
               % 'trainscg'  - Scaled conjugate gradient backpropagatio
%}

net01.trainParam.epochs     = trCycles;
net01.trainParam.lr         = learningRate;
net01.trainParam.goal       = trainGoal;      % is the performance goal, in terms of the network's performance function
net01.trainParam.max_fail   = trCycles;       % is maximum number of validation checks before training is stopped.
                                            % The training continued until the validation error failed to decrease  for .trainParam.max_fail iterations (validation stop).    

net01.trainParam.min_grad = parameters.trainParam.min_grad; 
                                            % net01.trainParam.min_grad   = 0;
net01.trainParam.time     = parameters.trainParam.time;
                                            % net01.trainParam.time       = Inf;

net01.trainParam.showWindow       = true;
net01.trainParam.showCommandLine  = true;
net01.trainParam.show             = int64(trCycles/parameters.times2seeTrain );

%%  TRAIN THE ANN by MATLAB  ===========================================================

% REGULARIZATION ?? -> trainRecord.performParam.regularization
% NORMALIZATION ?? -> trainRecord.performParam.normalization

% Calling train  -> Calculation mode: MEX
% parameters.trainParam.showWindow 
net01.trainParam.showWindow=0;
[net01,trainRecord] = train(net01,x,t);
%[net01,trRecord] = train(net01,x,t,'useParallel','yes','showResources','yes');
% =======================================================================================

%{
INFORMATION 
    x = patterns_inputs';  (WHOLE PATTERNS)
    t = patterns_targets'; (WHOLE PATTERNS)
    parameters  : parameters.tsName, parameters.tsType, parameters.nInputs, parameters.nOutputs
    trainRecord : trainInd, valInd, testInd (indexes for train, valid and test from the whole patterns data set) 
    net01       : none
%}

% Show the learning process error 
if (parameters.showTrainRecord)
  h = figure;
  plotperform(trainRecord);
  title('ann learning process perfomance');
end
%{ 
h = figure;
plot(1:(net01.trainParam.epochs + 1),trRecord.perf);  hold on;
plot(1:(net01.trainParam.epochs + 1),trRecord.vperf); hold on;
plot(1:(net01.trainParam.epochs + 1),trRecord.tperf); 
title('ann learning process perfomance');
%}

%% View the ANN 
if (parameters.netView) 
  netView = view(net01);
  % fprintf('\nPuase. Press any key to continue. ');pause();fprintf('\n');close(net01View);
end

%% SIMULATE the ANN to get the Outputs for each subset Tr Val Te
% pat    = rand(nInputs,1); % colum vector
% output = sim(net01,pat);

% testPatterns = (x(:,trRecord.testInd))';
% testTargets  = (t(:,trRecord.testInd))';

% arrays for Matlab ANN Toolbox (row means attribute; col means sample)
trainPatterns = x(:,trainRecord.trainInd);
trainTargets  = t(:,trainRecord.trainInd);
trainOutputs  = sim(net01,trainPatterns);

valPatterns   = x(:,trainRecord.valInd);
valTargets    = t(:,trainRecord.valInd);
valOutputs    = sim(net01,valPatterns);

testPatterns  = x(:,trainRecord.testInd);
testTargets   = t(:,trainRecord.testInd);
testOutputs   = sim(net01,testPatterns);

% Get transpose arrays (=> row means sample; col means attribute)
trainPatterns = trainPatterns';
trainTargets  = trainTargets';
trainOutputs  = trainOutputs';

valPatterns   = valPatterns';
valTargets    = valTargets';
valOutputs    = valOutputs';

testPatterns  = testPatterns';
testTargets   = testTargets';
testOutputs   = testOutputs';

% Are test_tsData & testOutputs the same vector with the same values ??
% if (parameters.showOnScreen)
%     fprintf('test_tsData -> size(...): %d %d \n',size(test_tsData,1),size(test_tsData,2));
%     fprintf('testOutputs -> size(...): %d %d \n',size(testOutputs,1),size(testOutputs,2));
%     fprintf('test_tsData & testOutputs are ');
%     if ( sum( test_tsData ~= testOutputs ) ) 
%         fprintf('Equal.\n\n');
%     else
%         fprintf('NOT equal.\n\n');
%     end;
% end;
%% COMPUTE THE ERRORS 

rmseTrain = ( 1/numel( trainTargets ) ) * sqrt( sum( ( trainTargets - trainOutputs ).^2 ) );
rmseVal   = ( 1/numel(   valTargets ) ) * sqrt( sum( (   valTargets -   valOutputs ).^2 ) );
rmseTest  = ( 1/numel(  testTargets ) ) * sqrt( sum( (  testTargets -  testOutputs ).^2 ) );


fprintf('rmseTrain %12.5f\n', rmseTrain);
fprintf('rmseVal   %12.5f\n', rmseVal  );
fprintf('rmseTest  %12.5f\n', rmseTest );

%% 

% ------------------------------------------------
% PLOT THE RESIDUAL FOR TRAIN - VALIDATION AND TEST 

h1 = figure('Name', 'data & residuals Tr Va Te');
hold on

plot( trainRecord.trainInd , trainTargets , '-bs' , 'MarkerSize' , 3 ); 
plot( trainRecord.trainInd , trainOutputs , ':bx' , 'MarkerSize' , 6 ); 

plot( trainRecord.valInd   , valTargets   , '-ms' , 'MarkerSize' , 3  ); 
plot( trainRecord.valInd   , valOutputs   , ':mx' , 'MarkerSize' , 6  ); 

plot( trainRecord.testInd  , testTargets  , '-rs' , 'MarkerSize' , 3 ); 
plot( trainRecord.testInd  , testOutputs  , ':rx' , 'MarkerSize' , 6 ); 

% trainRecord.trainInd
% trainRecord.valInd
% trainRecord.testInd 
% 
% trainTargets 
% trainOutputs
% 
% valTargets
% valOutputs
% 
% testTargets
% testOutputs

title( strcat( parameters.tsName , ' data & residuals Tr Va Te', ' h = 1(real value) ') );
hold off 

%% LETS CARRY OUT FORECASTING FUTURE VALUE FOR A DIFFERENT HORIZON THAN H = 1

if (horizon == 1 )
    % Do nothing 
elseif ( horizon > 1 )
      trainPatterns = x(:,trainRecord.trainInd);
      trainTargets  = t(:,trainRecord.trainInd);
      valPatterns   = x(:,trainRecord.valInd);
      valTargets    = t(:,trainRecord.valInd);

      %knowPatterns = x 

      %initialInput =  


end