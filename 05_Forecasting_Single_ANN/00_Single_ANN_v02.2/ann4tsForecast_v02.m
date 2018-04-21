function result = ann4tsForecast_v02( annParameters )

    %{
    input: annParameters 
        is a struct (record) with the following 
    %}

    %ann4tsForecast_v02 Compute the learning algorithm of an ANN applied to
    %                   time series
    %   Detailed explanation should go here

    result.comment = '-'; 
    

  %% parameters (TS, ANN, etc)  ===========================================================
  
    %folder_TS  = 'Timeseries'; 
    folder_TS     = annParameters.tsFolder;
    % file_TS       = 'ts_mackeyglass01.dat'; % file_TS   = 'ts_temperature.dat';
    file_TS       = annParameters.tsFilename;
    tsName        = annParameters.tsName;
    tsType        = annParameters.tsType;

    % initId        = annParameters.initId;
    %folder_Results    = annParameters.folder_Results;
    
    % ---------------------------------------------------------------------------------------
    % ANN PARAMETERS 
    nOutputs          = annParameters.nOutputs; % nOutputs  = 1;
    nInputs           = annParameters.nInputs;  % nInputs   = 10;  
    hiddenLayersSize  = annParameters.hiddenLayersSize;  % hiddenLayerSizes = [10]; % hiddenLayerSizes = [10 5]; 
    trCycles          = annParameters.trCycles;          % trCycles       = 1000    % 500 1000 2000 5000
    learningRate      = annParameters.learningRate;      % learningRate   = 0.1;    % 0.2 0.1 0.05 0.01                          �
    % Train Function as a Number and as a String
    trainFcn          = annParameters.trainFcn;
    trainFcnStr       = annParameters.trainFcnStr;
    % trainFcnStr  = 'trainrp'; % 
                           % 'trainlm'   - Levenberg-Marquardt optimization, fastest backpropagation alg in the toolbox
                           % 'traingd'   - Gradient descent backpropagation.
                           % 'traingda'  - Gradient descent with adaptive lr backpropagation.
                           % 'trainrp'   - RPROP backpropagation.
                           % 'trainscg'  - Scaled conjugate gradient backpropagatio

    % --------------------------------                           
    transferFcn       = annParameters.transferFcn;       %transferFcn = 'tansig';
    % --------------------------------
    trainGoal         = annParameters.trainGoal;         %trainGoal      = 0.0001; % mse = 0.001 ??<Az
    times2seeTrain    = annParameters.times2seeTrain;    %times2seeTrain = 5;
    %% 
    % The parameters for trainPrctg, valPrctg, testPrctg or 
    % trainElements, valElements, testElements 
    % are already done/set at annParamInitialization
    %{
    if ( annParameters.SplitPatternSetByPrctg )
        % annParameters.trainPrctg   = 70;   % (up to now) FIXED
        % annParameters.valPrctg     = 15;   % (up to now) FIXED
        % annParameters.testPrctg    = 100 - annParameters.trainPrctg - annParameters.valPrctg; % FIXED

        annParameters.trainPrctg   = parameters.trainPrctg;     % (up to now) FIXED
        annParameters.valPrctg     = parameters.valPrctg;       % (up to now) FIXED
        annParameters.testPrctg    = 100 - annParameters.trainPrctg - annParameters.valPrctg; % FIXED

    elseif ( annParameters.SplitPatternSetByElements )

        annParameters.trainElements = parameters.trainElements;
        annParameters.valElements   = parameters.valElements;
        annParameters.testElements  = parameters.testElements;

    end

    %}
    %% Load Time Series and get Time Series Pattern Set 
    filename          = fullfile(folder_TS,file_TS);
    % tsData = load(filename);  % ts <- column vector
    tsData            = load(filename,'-ascii');  % ts <- column vector
    b = size(tsData,1);

    if ( annParameters.SplitPatternSetByPrctg )
        % a = round(  b * ( 1 - annParameters.testPrctg/100 )  );
        % a = floor(  b * ( 1 - annParameters.testPrctg/100 )  );
        % a = ceil(   b * ( 1 - annParameters.testPrctg/100 )  );
        a = ceil(  b * ( 1 - annParameters.testPrctg/100 ) );

    elseif ( annParameters.SplitPatternSetByElements )      
        a = b - annParameters.testElements;  
    end

    fprintf('numel(tsData) %d  - a: %d ; b: %d\n' , numel(tsData) , a , b );    
    
    learning_tsData = tsData( 1:a );
    test_tsData     = tsData( (a+1):b);

    % -------------------------------------------------------------
    patterns = ts2Patterns( tsData, annParameters.nInputs, annParameters.nOutputs );
    % learningPatterns = ts2Patterns( learning_tsData, annParameters.nInputs, annParameters.nOutputs );

    %% Clear some vars
    clear folder_TS filename a b 
    % clearvars -except tsData learning_tsData test_tsData patterns  nInputs nOutputs

    %% ARTIFICIAL NEURAL NETWORK      =====================================================
    % https://es.mathworks.com/help/nnet/ug/create-configure-and-initialize-multilayer-neural-networks.html

    % help nnet/Contents.m

    % 
    % Input patterns (x) and target (t)
    patterns_inputs  = patterns(:,1:nInputs);
    patterns_targets = patterns(:,(nInputs+1):(nInputs+nOutputs));

    % patterns_inputs  = learningPatterns(:,1:nInputs);
    % patterns_targets = learningPatterns(:,(nInputs+1):(nInputs+nOutputs));

    x = patterns_inputs';
    t = patterns_targets';

    %% Create the ANN      ================================================================

    net01 = feedforwardnet( hiddenLayersSize , trainFcnStr ); 
    net01.userdata.note = strcat( 'ann for TS forecasting - ', tsName ,' - ' , tsType );
    %{
        f = view(net01);
        fprintf('\nPuase. Press any key to continue. ');pause();fprintf('\n')
        close(f);
    %}

    %% ANN Configuration   ================================================================
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

    %  net01.layers{1}.transferFcn = transferFcn;
    %  net01.layers{2}.transferFcn = transferFcn;
    for i = 1:numel(net01.layers)
      net01.layers{i}.transferFcn = transferFcn;
    end


    net01 = configure(net01,x,t);
    rng(annParameters.rngSeed);
    net01 = init(net01);
      
    if (annParameters.showOnScreen)
      fprintf( '\n -> net01.inputs{1}.size: %i -- size(x,1): %i \n', ... 
               net01.inputs{1}.size , size(x,1) );
      fprintf( '\n -> seed  %i\n', annParameters.rngSeed );     
    end

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

  % % =============================================================================================
    %% SET THE PARAMETERs AND INFORMATION TO TRAIN the ANN

    % Split data set into train, validation, and test subsets --------------------------------------
    net01.divideMode = annParameters.divideMode;    % net01.divideMode = 'sample'; 

    net01.divideFcn  = annParameters.divideFcn ;    % net01.divideFcn ='divideblock';   % ACADEMIC TIME SERIES 
                                                    % net01.divideFcn ='divideind';     % POLLUTION TIME SERIES / COMPETITION

    if   ( annParameters.divideFcn    == string( 'divideblock' ) )
        % net01.divideParam 
        net01.divideParam.trainRatio = annParameters.trainPrctg / 100; 
        net01.divideParam.valRatio   = annParameters.valPrctg   / 100;
        net01.divideParam.testRatio  = annParameters.testPrctg  / 100;


    elseif ( annParameters.divideFcn    == string( 'divideind' ) )
        
        numPatterns = size(patterns,1);
        
        % net01.divideParam 
        % train:  a -> b; val: b+1 -> c; test: c+1 -> d
        a = 1;
        b = numPatterns - ( annParameters.valElements + annParameters.testElements);
        c = numPatterns - annParameters.testElements;
        d = numPatterns;
        
        net01.divideParam.trainInd =        a:b;
        net01.divideParam.valInd   = ( b + 1):c;
        net01.divideParam.testInd  = ( c + 1):d;
        
        clear a b c d;
    end

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
    
    % ---------------------------------------------------------------------------------------------
    % EARLY STOPPING 
    % is the maximum number of validation checks before training is stopped.
    % The training continued until the validation error failed to decrease 
    % for .trainParam.max_fail iterations (validation stop).    
    
    % net01.trainParam.max_fail   = trCycles; % => no early stopping ()
    net01.trainParam.max_fail  = (annParameters.max_fail_TrainCyclesPrct / 100) * annParameters.trCycles;                        
    
    % ---------------------------------------------------------------------------------------------

    net01.trainParam.min_grad = annParameters.trainParam.min_grad; 
                                                % net01.trainParam.min_grad   = 0;
    net01.trainParam.time     = annParameters.trainParam.time;
                                                % net01.trainParam.time       = Inf;

  % ****************************************************************************************
  %%  TRAIN THE ANN by MATLAB  *************************************************************
  %                            *************************************************************
  % Setting a new seed 
  rng( annParameters.rngSeed );
  
  % to see or not the training 
  net01.trainParam.showWindow       = annParameters.trainParam.showWindow;
  net01.trainParam.showCommandLine  = annParameters.trainParam.showCommandLine;
  net01.trainParam.show             = int64(trCycles/times2seeTrain);
  
  
  initTrainingTime = tic;
  
  % CALLING THE TRAIN FUNCTION  -> Calculation mode: MEX
  % note: x and t are the input and out patterns for the whole ... train, valid and test 
  [ net01 , trainRecord ] = train(net01,x,t);
  %[net01,trainRecord] = train(net01,x,t,'useParallel','yes','showResources','yes');
  
  trainTimeElapsed = toc( initTrainingTime ); clear initTrainingTime;
  
  
  % NOTE: the results(errors) in training/learning process means prediction with Horizon = 1 to nOuputs
  
  % ****************************************************************************************
  
  %% =======================================================================================
  %{
    INFORMATION 
        x = patterns_inputs';  (WHOLE PATTERNS)
        t = patterns_targets'; (WHOLE PATTERNS)
        parameters  : parameters.tsName, parameters.tsType, parameters.nInputs, parameters.nOutputs
        trainRecord : trainInd, valInd, testInd (indexes for train, valid and test from the whole patterns data set) 
        net01       : none
  %}

  %{ 
    h = figure;
    plot(1:(net01.trainParam.epochs + 1),trRecord.perf);  hold on;
    plot(1:(net01.trainParam.epochs + 1),trRecord.vperf); hold on;
    plot(1:(net01.trainParam.epochs + 1),trRecord.tperf); 
    title('ann learning process perfomance');
  %}

  %% View the ANN 
  if ( annParameters.netView ) 
      netView = view( net01 );
      % fprintf('\nPuase. Press any key to continue. ');pause();fprintf('\n');close(net01View);
  end

  %% Forecast VALIDATION and TEST subsets using 
  %  real values ( HT1) parameters.usingPredictedOrReal = 1; 
  %  prev. forecast values ( HT2) parameters.usingPredictedOrReal = 1; 
  
  % --------------------------------------
  %% Train Validation Test targets as row vectors 
  % up to 08/03/2018 not used 
  % trainTargets    = t(:,trainRecord.trainInd );
  % valTargets      = t(:,trainRecord.valInd   );
  % testTargets     = t(:,trainRecord.testInd  );
  
  %% Get VALIDATION and TEST outputs(forecast)  --------------------------------------
  % using real values ( H = 1 ) or prev. forecast values ( H > 1 )
  % forecastResults = getANNForecastResults( net01 , trainRecord , x , t  );
  forecastResults = getANNForecastResults_v02( net01 , trainRecord , x , t  );
  
    % Plot the performnace of the learning process ------------------------------------
    % This is done later, out of this funcion
    % if annParameters.showTrainRecord 
    %    plotperform(    trainRecord); 
    %    % myPlotregression_net(forecastResults , net01, trainRecord, x , t );
    % end 
  
  %% ERRORS -----------------------------------------------------
  %{
    Neural network performance: mae | mse | patternnet | sae | softmax | sse |crossentropy
    Forecast accuracy https://www.otexts.org/fpp/2/5
    Errors on percentage errors by robjhyndman
    SMAPE: http://robjhyndman.com/hyndsight/smape/
    Three definitions for SMAPE

  %}

  % MSE    (mean squared error)
  % RMSE   (root mean squared error)
  % MAE    (mean absolute error)
  % SMAPE  % http://robjhyndman.com/hyndsight/smape/
  % WMAPE (Weighted Mean Absolute Percent Error).
  % WAPE


  %% Show Target & Outputs (Done out of this function )  -------------------------------

  %% RESULTS         ********************************************************************

  result.ts_filename      = annParameters.tsFilename;
  result.tsName           = annParameters.tsName;  
  result.tsType           = annParameters.tsType;
  % ----------------------------------------
  result.nOutputs         = annParameters.nOutputs;
  % ----------------------------------------
  result.initId           = annParameters.initId;
  result.iExp             = annParameters.iExperiment;
  result.strIndExp        = sprintf('%04i',annParameters.iCombFactLevel); 
  result.rngSeed          = annParameters.rngSeed;
  
  % FACTOR - LEVEL PARAMETERS
  result.nInputs          = nInputs;
  result.hiddenLayersSize = hiddenLayersSize;
  result.trainFcn         = trainFcn;
  result.trainFcnStr      = trainFcnStr;
  result.trCycles         = trCycles;
  result.learningRate     = learningRate;
  % ----------------------------------------
  result.transferFcn      = transferFcn;
  % ----------------------------------------
  if   ( annParameters.divideFcn  == string( 'divideblock' ) )
       
    result.trainPrctg = net01.divideParam.trainRatio;
    result.valPrctg   = net01.divideParam.valRatio;
    result.testPrctg  = net01.divideParam.testRatio;
       
    %  result.trainPrctg       = annParameters.trainPrctg;
    %  result.valPrctg         = annParameters.valPrctg;
    %  result.testPrctg        = annParameters.testPrctg;
    
    result.trainIndexes     = -1;
    result.valIndexes       = -1;
    result.testIndexes      = -1;    

  elseif ( annParameters.divideFcn  == string( 'divideind' ) )
    result.trainIndexes     = net01.divideParam.trainInd;
    result.valIndexes       = net01.divideParam.valInd;
    result.testIndexes      = net01.divideParam.testInd;
    
    result.trainPrctg = -1;
    result.valPrctg   = -1;
    result.testPrctg  = -1;

  end

  % ----------------------------------------
  % TS DATA
  result.tsData           = tsData;
  result.learning_tsData  = learning_tsData; 
  result.test_tsData      = test_tsData;

  % ----------------------------------------
  % PATTERN DATA
  result.trainTargets     = forecastResults.trainTargets;
  result.valTargets       = forecastResults.valTargets;
  result.testTargets      = forecastResults.testTargets;
  
  result.trainOutputs     = forecastResults.trainOutputs;
  
  result.valHT1Outputs     = forecastResults.valHT1Outputs;
  result.testHT1Outputs    = forecastResults.testHT1Outputs;
  
  result.valHT2Outputs     = forecastResults.valHT2Outputs;
  result.testHT2Outputs    = forecastResults.testHT2Outputs;

  % TRAIN RECORD --------------------------
  
  result.trainRecord = trainRecord;
  % ----------------------------------------
  % ERRORS
  
  result.rmseTrain   = forecastResults.rmseTrain;
  result.smapeTrain  = forecastResults.smapeTrain;
  % -- Val HT1
  result.rmseValHT1     = forecastResults.rmseValHT1Forecast;
  result.smapeValHT1    = forecastResults.smapeValHT1Forecast;
  % -- Test HT1
  result.rmseTestHT1    = forecastResults.rmseTestHT1Forecast;
  result.smapeTestHT1   = forecastResults.smapeTestHT1Forecast;
  
  % -- Val HT2
  result.rmseValHT2     = forecastResults.rmseValHT2Forecast;
  result.smapeValHT2    = forecastResults.smapeValHT2Forecast;
  % -- Test HT2
  result.rmseTestHT2    = forecastResults.rmseTestHT2Forecast; 
  result.smapeTestHT2   = forecastResults.smapeTestHT2Forecast;
  % ----------------------------------------
  result.net              = net01;
  result.trainRecord      = trainRecord;  
  result.trainTimeElapsed = trainTimeElapsed; 


  %% END OF THE FUNCTION
  % pause;

end

