function [ parameters ] = annParamInitialization( input_args )
 
    %annParamInitialization -> create/assign initial & default values of an ANN

    % -----------------------------------------------------------------
    % Initially it is applied some default values, 
    % but the following parameters will be got from a file
    parameters.nInputs          = 10;        % read value from file of parameters
    parameters.hiddenLayersSize = [10];      % read value from file of parameters
                                             % e.g. -> [10] one hidden layer [5 5] 2 hidden layer
                                             % fix(parameters.nInputs/2):(parameters.nInputs * 2)
    parameters.trainFcn        = 'traingda'; % read value from file of parameters  
                                             % 'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'
                                             % (#1) 'trainlm'  - Levenberg-Marquardt optimization, fastest backpropagation alg in the toolbox
                                             % (#2) 'traingd'  - Gradient descent backpropagation.
                                             % (#3) 'traingda' - Gradient descent with adaptive lr backpropagation.
                                             % (#4) 'traingdx' - Variable Learning Rate Gradient Descent
                                             % (#5) 'trainrp'  - RPROP Resilient Backpropagation.
                                             % (#6) 'trainscg' - Scaled conjugate gradient backpropagatio
                                             % (#7) 'traingdm' - Gradient Descent with Momentum
                                             % https://es.mathworks.com/help/nnet/ug/train-and-apply-multilayer-neural-networks.html

    parameters.learningRate   = 0.01;        % read value from file of parameters
                                             % 0.2 0.1 0.05 0.01  % SMALL ENOUGGH   => but not FIXED
    parameters.trCycles       = 1 * 10^3;   % read value from file of parameters
                                            % 1000 5 10 20 50       % BIG ENOUGGH     => but not FIXED

    % -----------------------------------------------------------------
    % ANN topology & architecture
    parameters.transferFcn  = 'tansig'; % (up to now) FIXED
    parameters.nOutputs     = 1;        % (up to now) FIXED

    % -----------------------------------------------------------------
    % TRAIN, VALIDATION, TEST SUBSETS 

    % To EVALUATE Algorithms/Methods: train, val and test subset are known
    parameters.trainPrctg   = 70;   % (up to now) FIXED
    parameters.valPrctg     = 15;   % (up to now) FIXED
    parameters.testPrctg    = 100 - parameters.trainPrctg - parameters.valPrctg; % FIXED

    % For TIME SERIES COMPETITION (etc.)  Test subset is the one to be forecasted
    %{
        % This values should be set from the number of times to be forecasted
        parameters.trainPrctg = 70; 
        parameters.valPrctg   = 100 - parameters.trainPrctg;
        parameters.testPrctg  = 0    
    %}
    parameters.divideMode   = 'sample';        % (up to now) FIXED
    parameters.divideFcn    = 'divideblock';   % (up to now) FIXED

    % To step the learning process before the training cycles
    parameters.trainGoal             = 0.0000001; % mse = 0.0000001 ??
    parameters.trainParam.min_grad   = 0;
    parameters.trainParam.time       = Inf;
    % -----------------------------------------------------------------
    % PARAMETERS to see the learning process of the ANN

    parameters.times2seeTrain              = 5;
    parameters.trainParam.show             = int64( parameters.trCycles / parameters.times2seeTrain );
    parameters.trainParam.showWindow       = false;
    parameters.trainParam.showCommandLine  = false;

    parameters.showOnScreen         = true;
    parameters.netView              = false;
    parameters.showTrainRecord      = false;

    parameters.showTrainTargetOutput = false;
    parameters.showValTargetOutput   = false;
    parameters.showTestTargetOutput  = true;
    parameters.showTrainValTestTargetOutput = true;

end

