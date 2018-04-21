function [ annParameters ] = annParamInitialization( parameters )
 
    %annParamInitialization -> create/assign initial & default values of an ANN

    
    % -----------------------------------------------------------------
    % Initially it is applied some default values, 
    % but the following parameters will be got from a file
    
    annParameters.iExperiment      = 0;         % read value from file of parameters
    annParameters.iCombFactLevel   = 0; 
    
    annParameters.nInputs          = 10;        % read value from file of parameters
    annParameters.hiddenLayersSize = [10];      % read value from file of parameters
                                             % e.g. -> [10] one hidden layer [5 5] 2 hidden layer
                                             % fix(parameters.nInputs/2):(parameters.nInputs * 2)
    annParameters.trainFcn        = 'traingda'; % read value from file of parameters  
                                             % 'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'
                                             % (#1) 'trainlm'  - Levenberg-Marquardt optimization, fastest backpropagation alg in the toolbox
                                             % (#2) 'traingd'  - Gradient descent backpropagation.
                                             % (#3) 'traingda' - Gradient descent with adaptive lr backpropagation.
                                             % (#4) 'traingdx' - Variable Learning Rate Gradient Descent
                                             % (#5) 'trainrp'  - RPROP Resilient Backpropagation.
                                             % (#6) 'trainscg' - Scaled conjugate gradient backpropagatio
                                             % (#7) 'traingdm' - Gradient Descent with Momentum
                                             % https://es.mathworks.com/help/nnet/ug/train-and-apply-multilayer-neural-networks.html

    annParameters.learningRate   = 0.01;        % read value from file of parameters
                                             % 0.2 0.1 0.05 0.01  % SMALL ENOUGGH   => but not FIXED
    annParameters.trCycles       = 1 * 10^3;   % read value from file of parameters
                                            % 1000 5 10 20 50       % BIG ENOUGGH     => but not FIXED

                                            
    
    % -----------------------------------------------------------------
    % ANN topology & architecture
    annParameters.transferFcn  = parameters.transferFcn;       % annParameters.transferFcn  = 'tansig'; % (up to now) FIXED
    annParameters.nOutputs     = parameters.ForecastOutput;  
    
    %==============================================================================
    % TRAIN, VALIDATION, TEST SUBSETS 
    
    % Default values -----------------
    annParameters.trainPrctg = -1;
    annParameters.valPrctg   = -1;  
    annParameters.testPrctg  = -1;
    
    annParameters.trainElements = -1;
    annParameters.valElements   = -1;  
    annParameters.testElements  = -1;
    
    annParameters.SplitPatternSetByPrctg    = parameters.SplitPatternSetByPrctg;
    annParameters.SplitPatternSetByElements = parameters.SplitPatternSetByElements;
    
    if ( parameters.SplitPatternSetByPrctg )
        % annParameters.trainPrctg   = 70;   % (up to now) FIXED
        % annParameters.valPrctg     = 15;   % (up to now) FIXED
        % annParameters.testPrctg    = 100 - annParameters.trainPrctg - annParameters.valPrctg; % FIXED

        annParameters.trainPrctg   = parameters.trainPrctg;     % (up to now) FIXED
        annParameters.valPrctg     = parameters.valPrctg;       % (up to now) FIXED
        annParameters.testPrctg    = 100 - annParameters.trainPrctg - annParameters.valPrctg; % FIXED
        
    elseif ( parameters.SplitPatternSetByElements )
        
        annParameters.trainElements = parameters.trainElements;
        annParameters.valElements   = parameters.valElements;
        annParameters.testElements  = parameters.testElements;
        
    end

    %{ 
      To EVALUATE Algorithms/Methods: train, val and test subset are known
      For TIME SERIES COMPETITION (etc.)  Test subset is the one to be forecasted
    
      % This values should be set from the number of times to be forecasted
        parameters.trainPrctg = 70; 
        parameters.valPrctg   = 100 - parameters.trainPrctg;
        parameters.testPrctg  = 0    
    %}
    annParameters.divideMode   = 'sample';        % (up to now) FIXED

    if ( parameters.SplitPatternSetByPrctg )
        annParameters.divideFcn    = 'divideblock';   % (up to now) FIXED

    elseif ( parameters.SplitPatternSetByElements )
        annParameters.divideFcn    = 'divideind';   % (up to now) FIXED
        
    end
    
    
    % To stop the learning process before the training cycles
    annParameters.trainGoal             = 0.0000001; % mse = 0.0000001 ??
    annParameters.trainParam.min_grad   = 0;
    annParameters.trainParam.time       = Inf;
    % The param forearly stoping is done out of this function
    % -----------------------------------------------------------------
    % PARAMETERS to see the learning process of the ANN

    annParameters.times2seeTrain              = 1;
    annParameters.trainParam.show             = int64( annParameters.trCycles / annParameters.times2seeTrain );
    
    annParameters.trainParam.showWindow       = parameters.trainParam.showWindow;
    annParameters.trainParam.showCommandLine  = parameters.trainParam.showCommandLine;

    
    annParameters.showOnScreen         = false;
    annParameters.netView              = false;
    annParameters.showTrainRecord      = parameters.showTrainRecord;
    
    annParameters.figVisible           = parameters.figVisible;

    annParameters.showTrainTargetOutput = false;
    annParameters.showValTargetOutput   = true;
    annParameters.showTestTargetOutput  = false;
    annParameters.showTrainValTestTargetOutput = false;
    
    
    annParameters.elapsedTime = 0;

end

