function [outputData ] = forecast_singleANN4TSF_01 ( parameters )

    %% RESET ===============================================================================
    close('all'); fclose('all');
    % clc; close('all'); fclose('all');
    % clear; clc; close('all'); fclose('all');
    % clear; close('all'); fclose('all');
    %% COUNTING TIME 
    initTotalExecTime = tic;
    
    %% set the left corner position and the size of the figures
    % setScreenSize (10, 0.4);

    %% SET STRUCT FOR PARAMETERS  ==========================================================

    % THIS PARAMETERS ARE SET OUT AND BEFORE THE FUNCTION CALL
    
    % parameters.folderFunctions  = strcat(fileparts(mfilename('fullpath')),'\Functions');
    % parameters.folderTimeSeries = strcat(fileparts(mfilename('fullpath')),'\TimeSeries');
    % parameters.folderFigures    = strcat(fileparts(mfilename('fullpath')),'\Figures');
    
    % THIS MUST BE SET OUT OF THE FUNCTION
    % % path( parameters.folderFunctions  , path );
    % % path( parameters.folderTimeSeries , path );
    % % path( parameters.folderFigures    , path );
    
    % % ANN PARMETERS -------------------
    % 
    % % DROPOUT ??
    % % REGULARIZATION ??
    % 
    % parameters.nInputs          = 28;
    % parameters.hiddenLayersSize = [20 10];  % One hidden layer  with 20 neurons
    % parameters.nOutputs         = 1;
    % 
    % parameters.trainFcnStr      = 'trainscg'; % 
    %              % (#1) 'trainlm'  - Levenberg-Marquardt optimization, 
    %              %                   fastest backpropagation alg in the toolbox
    %              % (#2) 'traingd'  - Gradient descent backpropagation.
    %              % (#3) 'traingda' - Gradient descent with adaptive lr backpropagation.
    %              % (#4) 'traingdx' - Variable Learning Rate Gradient Descent
    %              % (#5) 'trainrp'  - RPROP Resilient Backpropagation.
    %              % (#6) 'trainscg' - Scaled conjugate gradient backpropagatio
    %              % (#7) 'traingdm' - Gradient Descent with Momentum
    % 
    % parameters.transferFcn    = 'tansig';
    % 
    % parameters.trainPrctg     = 70;   % (up to now) FIXED
    % parameters.valPrctg       = 15;   % (up to now) FIXED
    % parameters.testPrctg      = 100 - parameters.trainPrctg - parameters.valPrctg; % FIXED
    % 
    % parameters.divideMode     = 'sample';        % (up to now) FIXED
    % parameters.divideFcn      = 'divideblock';   % (up to now) FIXED
    % 
    % parameters.trCycles       = 2 * 10^3;
    % parameters.learningRate   = 0.1;
    % parameters.trainGoal      = 0.0000001; 
    % 
    % parameters.trainParam.min_grad = 0;
    % parameters.trainParam.time     = Inf;
    % 
    % 
    %  parameters.horizon       = 2;
    % 
    % % Seed  ------------------------
    % v = (int32(clock)); seed = v(5) + v(6); clear v;
    % rng(seed);  fprintf('Seed: %03d\n',seed); % seed is the second for time 
    % 
    % parameters.rngSeed          = seed;     
    % 
    % % What to show  ----------------------------------
    % parameters.times2seeTrain   = 5;
    % parameters.trainParam.showWindow = 0;
    % parameters.showOnScreenNet  = 0;
    % parameters.netView          = 0;
    % parameters.showTrainRecord  = 0;
    % 
    % 
    % % HOW TO CARRY OUT THE FORECAST FOR TIME SERIES FORECASTING ---------------
    % parameters.ValhorizonComp   = 2;% if h > 1 => using real values for y_t+2 (1) or forecast values (2)
    % parameters.TesthorizonComp  = 2;% if h > 1 => using real values for y_t+2 (1) or forecast values (2)
    % 
    % % TIME SERIES -------------------------------------------------------------
    % %--- Examples of data file for time series data
    % % Data_Accidental.mat
    % % Data_Airline.mat
    % % Data_Overshort.mat
    % % Data_PowerConsumption.mat
    % % ccr.mat
    % % SharePrices.mat
    % 
    % % ----------------------------------------------------------------------------
    % % parameters.tsName = 'Mackey-Glass'; load mgdata.dat;            tsData = mgdata(:,2); % plot(tsData);
    % % parameters.tsName = 'Return';       load predict_ret_data.mat;  tsData = sdata(1:end); plot(tsData); 
    % % parameters.tsName = 'SharePrices.mat;'; load SharePrices.mat;  tsData = data(:,1); %plot(tsData); 
    %         % Training with TRAINGD completed: Minimum gradient reached.
    % 
    % % -----------------------------------------------------------------------------        
    % parameters.tsFilename = 'ts-NO2-FedzLadreda-16-12.csv';
    % % parameters.tsFilename = 'ts-NO2-PzCastilla-16-10.csv';
    % % parameters.tsFilename = 'ts-O3-JuanCarlosI-16-07.csv';
    % % parameters.tsFilename = 'ts-PM25-MendezAlvaro-16-10.csv';
    % parameters.tsName     = parameters.tsFilename(4:(end-4)); 

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    ouputData.parameters = parameters;

    %% SET LOCAL PARAMETERS     ============================================================
    
    folderFunctions     = parameters.folderFunctions;
    folderTimeSeries    = parameters.folderTimeSeries;
    folderFigures       = parameters.folderFigures;
    folderResults       = parameters.folderResults;
    
    filenameResults     = parameters.filenameResults;

    nInputs             = parameters.nInputs;
    nOutputs            = parameters.nOutputs;
    hiddenLayersSize    = parameters.hiddenLayersSize;
    transferFcn         = parameters.transferFcn;
    trainFcnStr         = parameters.trainFcnStr;

    tsName              = parameters.tsName;

    trainPrctg          = parameters.trainPrctg;   % (up to now) FIXED
    valPrctg            = parameters.valPrctg;     % (up to now) FIXED
    %testPrctg          = parameters.testPrctg     % (up to now) FIXED
    testPrctg           = 100 - trainPrctg - valPrctg; % FIXED

    trCycles            = parameters.trCycles;
    learningRate        = parameters.learningRate;
    trainGoal           = parameters.trainGoal;

    divideFcn           = parameters.divideFcn ;
    divideMode          = parameters.divideMode;
    trainParam.min_grad = parameters.trainParam.min_grad; 
    trainParam.time     = parameters.trainParam.time;

    horizon             = parameters.horizon;

    trainParam.showWindow = parameters.trainParam.showWindow;
    trainParam.showCommandLine = parameters.trainParam.showCommandLine;
    times2seeTrain        = parameters.times2seeTrain;
    showOnScreenNet       = parameters.showOnScreenNet;
    showTrainRecord       = parameters.showTrainRecord;
    netView               = parameters.netView;

    ValhorizonComp      = parameters.ValhorizonComp;
    TesthorizonComp     = parameters.TesthorizonComp;
    
    %% LOAD DATA                ============================================================

    tsData = load(strcat(folderTimeSeries,'\','ts-NO2-FedzLadreda-16-12.csv'));
    % plot(tsData); 
    
    outputData.tsData  = tsData;

    %% SET PATTERNS and TARGETS        =====================================================
    patterns         = ts2Patterns( tsData, nInputs, nOutputs );
    patterns_inputs  = patterns( : , 1:nInputs);
    patterns_targets = patterns( : , (nInputs+1):(nInputs+nOutputs));

    % The following vector/matrices are for the instruction to configure the NET 
    x = patterns_inputs';
    t = patterns_targets';
     % ( patters, or matrix for input patterns )

     %% Create the ANN          ============================================================
    net01 = feedforwardnet(hiddenLayersSize, ...
                           trainFcnStr); 
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

    % Set transfer function each layer             ---------------------------------------------
    neuronLayers = numel(hiddenLayersSize) + 1;   % hidden layers + output layer
    for i = 1:neuronLayers
        net01.layers{i}.transferFcn = transferFcn;
    end


    net01 = configure( net01 , x , t );   % x <- pattern inputs;  t <- pattern targets;

    if (showOnScreenNet)
      fprintf('\n -> net01.inputs{1}.size: %i -- size(x,1): %i \n', ... 
               net01.inputs{1}.size, size(x,1));
    end

    %% INITIALIZATION OF THE NET      ======================================================
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

    %% SET THE PARAMETERs AND INFORMATION TO TRAIN the ANN    ==============================
    % Split data set into train, validation, and test subsets
    net01.divideFcn  = divideFcn ;    % net01.divideFcn  = 'divideblock'; 
    net01.divideMode = divideMode;    % net01.divideMode = 'sample'; 

    % net01.divideParam
    net01.divideParam.trainRatio = trainPrctg / 100; 
    net01.divideParam.valRatio   = valPrctg   / 100;
    net01.divideParam.testRatio  = testPrctg  / 100;

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

    net01.trainParam.min_grad = trainParam.min_grad; 
                                                % net01.trainParam.min_grad   = 0;
    net01.trainParam.time     = trainParam.time;
                                                % net01.trainParam.time       = Inf;

    net01.trainParam.showWindow       = true;
    net01.trainParam.showCommandLine  = trainParam.showCommandLine;
    net01.trainParam.show             = int64(trCycles/times2seeTrain );

    %% TRAIN THE ANN by MATLAB  ============================================================

    % REGULARIZATION ?? -> trainRecord.performParam.regularization
    % NORMALIZATION ?? -> trainRecord.performParam.normalization

    % Calling train  -> Calculation mode: MEX
    % trainParam.showWindow 
    net01.trainParam.showWindow = trainParam.showWindow ;
    [net01,trainRecord] = train( net01 , x , t );
    %[net01,trRecord] = train(net01,x,t,'useParallel','yes','showResources','yes');
    % =======================================================================================

    %{
    INFORMATION 
        x = patterns_inputs';  (WHOLE PATTERNS)
        t = patterns_targets'; (WHOLE PATTERNS)
        parameters  : tsName , tsType , nInputs , nOutputs
        trainRecord : trainInd, valInd, testInd (indexes for train, valid and test from the whole patterns data set) 
        net01       : none
    %}

    % Show the learning process error 
    if (showTrainRecord)
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

    %% View the ANN             ============================================================
    if (netView) 
      netView = view(net01);
      % fprintf('\nPuase. Press any key to continue. ');pause();fprintf('\n');close(net01View);
    end

    %% SIMULATE the ANN to get the Outputs for each subset Tr Val Te  (Horizon = 1) ========
    % pat    = rand(nInputs,1); % colum vector
    % output = sim(net01,pat);

    % testPatterns = (x(:,trRecord.testInd))';
    % testTargets  = (t(:,trRecord.testInd))';

    % arrays for Matlab ANN Toolbox (row means attribute; col means sample)

    % ------------------------------------------------------------------------------
    % Remember, for nntool at Matlab, the matrix for patterns data is as following: 
    %               each row is for each feature (i.e. ANN input)
    %               each colum if for each patter (record)
    %           so, is the transpose of common case

    % Simulate the Model/NET for TRAIN PATTERNS
    trainPatterns = x(:,trainRecord.trainInd);
    trainTargets  = t(:,trainRecord.trainInd);
    trainOutputs  = sim(net01,trainPatterns);

    % Simulate the Model/NET for VAL PATTERNS
    valPatterns   = x(:,trainRecord.valInd);
    valTargets    = t(:,trainRecord.valInd);
    valOutputs    = sim(net01,valPatterns);

    % Simulate the Model/NET for TEST PATTERNS
    testPatterns  = x(:,trainRecord.testInd);
    testTargets   = t(:,trainRecord.testInd);
    testOutputs   = sim(net01,testPatterns);

    % Get transpose arrays (=> row means sample; col means attribute)
    trainPatterns = trainPatterns';
    trainTargets  = trainTargets';
    trainOutputs  = trainOutputs';

    valPatterns   = valPatterns';
    valTargets    = valTargets';
    valH1Outputs    = valOutputs';

    testPatterns  = testPatterns';
    testTargets   = testTargets';
    testH1Outputs   = testOutputs';

    % Are test_tsData & testOutputs the same vector with the same values ??
    % if (showOnScreen)
    %     fprintf('test_tsData -> size(...): %d %d \n',size(test_tsData,1),size(test_tsData,2));
    %     fprintf('testOutputs -> size(...): %d %d \n',size(testOutputs,1),size(testOutputs,2));
    %     fprintf('test_tsData & testOutputs are ');
    %     if ( sum( test_tsData ~= testOutputs ) ) 
    %         fprintf('Equal.\n\n');
    %     else
    %         fprintf('NOT equal.\n\n');
    %     end;
    % end;
    
    % outputData.trainPatterns = trainPatterns:
    
    outputData.trainTargets  = trainTargets;
    outputData.trainOutputs  = trainOutputs;
    
    outputData.valTargets   = valTargets;
    outputData.testTargets  = testTargets;
    
    %% COMPUTE THE ERRORS for Horizon = 1      =============================================

    rmseTrain = ( 1/numel( trainTargets ) ) * sqrt( sum( ( trainTargets - trainOutputs ).^2 ) );
    rmseValH1Forecast  = ( 1/numel(   valTargets ) ) * sqrt( sum( (   valTargets -   valH1Outputs ).^2 ) );
    rmseTestH1Forecast = ( 1/numel(  testTargets ) ) * sqrt( sum( (  testTargets -  testH1Outputs ).^2 ) );
    
    outputData.rmseTrain          = rmseTrain;
    outputData.rmseValH1Forecast  = rmseValH1Forecast;
    outputData.rmseTestH1Forecast = rmseTestH1Forecast;
    
    % SMAPE 
    
    errorEachPeriod     = ( abs(trainOutputs - trainTargets) ) ./ ( abs(trainOutputs) + abs(trainTargets) );
    smapeTrain  = 100 * ( 2* sum(errorEachPeriod) ) / numel( trainTargets ); 
    
    errorEachPeriod     = ( abs(valH1Outputs - valTargets) ) ./ ( abs(valH1Outputs) + abs(valTargets) );
    smapeValH1Forecast  = 100 * ( 2* sum(errorEachPeriod) ) / numel( valTargets ); 
    
    errorEachPeriod      = ( abs(testH1Outputs - testTargets) ) ./ ( abs(testH1Outputs) + abs(testTargets) );
    smapeTestH1Forecast  = 100 * ( 2* sum(errorEachPeriod) ) / numel( testTargets ); 
    
    outputData.smapeTrain          = smapeTrain;
    outputData.smapeValH1Forecast  = smapeValH1Forecast;
    outputData.smapeTestH1Forecast = smapeTestH1Forecast;
        

    
    
    %% PLOT THE RESIDUAL FOR TRAIN - VALIDATION AND TEST       ============================ 

    % ------------------------------------------------
    % PLOT THE RESIDUAL FOR TRAIN - VALIDATION AND TEST 

    h1 = figure('Name', 'data & residuals Tr Va Te');
    hold on

    plot( trainRecord.trainInd , trainTargets , '-bs' , 'MarkerSize' , 3 ); 
    plot( trainRecord.trainInd , trainOutputs , ':bx' , 'MarkerSize' , 6 ); 

    plot( trainRecord.valInd   , valTargets   , '-ms' , 'MarkerSize' , 3  ); 
    plot( trainRecord.valInd   , valH1Outputs   , ':mx' , 'MarkerSize' , 6  ); 

    plot( trainRecord.testInd  , testTargets  , '-rs' , 'MarkerSize' , 3 ); 
    plot( trainRecord.testInd  , testH1Outputs  , ':rx' , 'MarkerSize' , 6 ); 


    title( strcat( tsName , ' data & residuals Tr Va Te', ' h = 1(real value) ') );
    hold off 

    %% PLOT THE RESIDUAL FOR VALIDATION AND TEST       ==================================== 

    % ------------------------------------------------
    % PLOT THE RESIDUAL FOR TRAIN - VALIDATION AND TEST 

    h2 = figure('Name', 'data & residuals Tr Va Te');
    hold on

    plot( trainRecord.valInd   , valTargets   , '-ms' , 'MarkerSize' , 3  ); 
    plot( trainRecord.valInd   , valH1Outputs   , ':mx' , 'MarkerSize' , 6  ); 

    plot( trainRecord.testInd  , testTargets  , '-rs' , 'MarkerSize' , 3 ); 
    plot( trainRecord.testInd  , testH1Outputs  , ':rx' , 'MarkerSize' , 6 ); 


    title( strcat( tsName , ' data & residuals Tr Va Te', ' h = 1(real value) ') );
    hold off 

    %% LETS CARRY OUT FORECASTING FUTURE VALUE FOR A DIFFERENT HORIZON THAN H = 1   ========

    if horizon == 2
        horizon = numel(testTargets);
    end

    if ( horizon == 1 )
        % Do nothing, as it was already done at previous source code
    elseif ( horizon > 1 )

        % THE MODEL IS GOT USING TRAIN ALGORITHM
        % x <- input patterns
        % t <- target patterns

        % TRain Validation Test targets as row vectors 
        trainTargets  = t(:,trainRecord.trainInd );
        valTargets    = t(:,trainRecord.valInd   );
        testTargets   = t(:,trainRecord.testInd  );

        % Note: see the execution of the following 
        %       v1 = [1 2 3;4 5 6 ]; v2 = [7 8 9; 10 11 13]; v3 = [ v1 ,v2 ]
        %       v1 = [1 2; 3 4 ; 5 6 ]; v2 = [7 8; 9 10; 11 12]; v3 = [ v1 ; v2 ]

        % UNIVARIATE TIME SERIES  ---------------------------------------------

        if ( size(trainTargets,1) == 1 ) 
            % univ TS data as a ROW VECTOR 

        elseif (size(trainTargets,2) == 1)
            % univ TS data as a COLUMN VECTOR => get the transpose
            trainTargets = trainTargets';
            valTargets   = valTargets'  ;
            testTargets  = testTargets' ;        
        end

        % This piece of source code will work with row vectors, because a individual pattern
        % forthe nntool MUST BE A COLUM VECTOR
        knownTrValTeTargets = cat( 2 , trainTargets , valTargets , testTargets );
        knownTrTargets      = trainTargets;  
        knownTrValTargets   = cat( 2 , trainTargets , valTargets );  
        knownValTargets     = valTargets;  
        knownTeTargets      = testTargets;  

        % Computing the forecast values (using previously forecast values )  ---------------------------
        % for VALIDATION subset
        inputPattern = knownTrTargets( (end - nInputs + 1):end) ;
        for iVal = 1:numel(valTargets)
            % a individual input pattern must be a colum vector => get the transpose
            outputNet = sim(net01,inputPattern'); 
            target = knownValTargets(iVal); 

            valH2Targets(iVal) = target;
            valH2Outputs(iVal) = outputNet;

            % new input pattern 
            v = inputPattern(2:end); 
            inputPattern = cat( 2 , v , outputNet ); clear v;


        end
        clear output target inputPattern

        % Computing the forecast values (using previously forecast values ) ---------------------------
        % for TEST subset

        inputPattern = knownTrValTargets( (end - nInputs + 1):end) ;
        for iTe = 1:numel(testTargets)
            % a individual input pattern must be a colum vector => get the transpose
            outputNet   = sim(net01,inputPattern'); 
            target       = knownTeTargets(iTe); 

            testH2Targets(iTe) = target;
            testH2Outputs(iTe) = outputNet;

            % new input pattern 
            v = inputPattern(2:end); 
            inputPattern = cat( 2 , v , outputNet ); clear v;

        end
        clear output target inputPattern
        
        % TAKE DATA FOR THE OUPUT  ---------------------------------------------------------------
        outputData.valH2Outputs  = valH2Outputs;
        outputData.testH2Outputs = testH2Outputs;

        % COLUMN VECTOR 
        % knownTargets = cat( 1 , trainTargets , valTargets);  
        % To be developed

        % MULTI-VARIATE TIME SERIES  ---------------------------------------------
        % To be developed 

        % ======================================================================================
        % Compute the VALIDATION error 
        % note: first three instructions were for debugging purposes
        %rmseValForecast_01 = sqrt( sum ( ( valH2Targets - valTargets).^2 )   / numel( valTargets ) );
        %rmseValForecast_02 = sqrt( sum ( ( valH2Outputs - valTargets).^2 )   / numel( valTargets ) );
        %rmseValForecast_03 = sqrt( sum ( ( valH2Outputs - valH2Targets).^2 )   / numel( valTargets ) );
        
        rmseValH2Forecast = sqrt( sum ( ( valH2Outputs - valH2Targets).^2 ) / numel( valTargets ) );
        errorEachPeriod     = ( abs(valH2Outputs - valH2Targets) ) ./ ( abs(valH2Outputs) + abs(valH2Targets) );
        smapeValH2Forecast  = 100 * ( 2* sum(errorEachPeriod) ) / numel( valTargets ); 
        clear errorEachPeriod;



        % Compute the TEST error 
        % note: first three instructions were for debugging purposes
        %rmseTeForecast_01 = sqrt( sum ( ( testH2Targets - testTargets).^2 )   / numel( testTargets ) );
        %rmseTeForecast_02 = sqrt( sum ( ( testH2Outputs - testTargets).^2 )   / numel( testTargets ) );
        %rmseTeForecast_03  = sqrt( sum ( ( testH2Outputs - testH2Targets).^2 ) / numel( testTargets ) );
        
        rmseTeH2Forecast  = sqrt( sum ( ( testH2Outputs - testH2Targets).^2 ) / numel( testTargets ) );
        errorEachPeriod   = ( abs(testH2Outputs - testH2Targets) ) ./ ( abs(testH2Outputs) + abs(testH2Targets) );
        smapeTeH2Forecast = 100 * ( 2* sum(errorEachPeriod) ) / numel( testTargets ); 
        clear errorEachPeriod;

        % ----------------------------------------------
        outputData.rmseValH2Forecast  = rmseValH2Forecast;
        outputData.smapeValH2Forecast = rmseValH2Forecast;
        outputData.rmseTeH2Forecast   = rmseValH2Forecast;
        outputData.smapeTeH2Forecast  = rmseValH2Forecast;

        % ======================================================================================
        % Show the error on the screen
        %fprintf('If Horizon > 1\n');
        %fprintf('\tValidation error\n');
        %fprintf('\tRMSE ( vTargets vs valTargets, should be 0)  %12.5f \n', rmseValForecast_01 ); 
        %fprintf('\tRMSE ( vOutputs vs valTargets,            )  %12.5f \n', rmseValForecast_02 ); 
        %fprintf('\tRMSE ( vOutputs vs vTargets  ,            )  %12.5f \n', rmseValForecast_03 );

        % fprintf('\tRMSE  %12.5f \n', rmseValH2Forecast  ); 
        % fprintf('\tSMAPE %12.5f \n', smapeValH2Forecast ); 
        % fprintf('\t------\n');

        fprintf('\tTest error\n');
        %fprintf('\tRMSE ( vTargets vs testTargets, should be 0)  %12.5f \n', rmseTeForecast_01 ); 
        %fprintf('\tRMSE ( vOutputs vs testTargets,            )  %12.5f \n', rmseTeForecast_02 ); 
        %fprintf('\tRMSE ( vOutputs vs vTargets   ,            )  %12.5f \n', rmseTeForecast_03 ); 

        % fprintf('\tRMSE  %12.5f \n', rmseTeH2Forecast    ); 
        % fprintf('\tSMAPE %12.5f \n', smapeTeH2Forecast ); 
        % fprintf('\t------\n');
       
        
        % Plot the values --------------------------------------------------------
        h3 = figure('Name', 'data & residuals Tr Va Te');

        plot( trainRecord.valInd   , valTargets    , '-ms' , 'MarkerSize' , 3 ); hold on 
        plot( trainRecord.testInd  , testTargets   , '-bs' , 'MarkerSize' , 3 ); 

        plot( trainRecord.valInd  , valH1Outputs ,  ':rx' , 'MarkerSize' , 4 );
        plot( trainRecord.valInd  , valH2Outputs ,  ':ro' , 'MarkerSize' , 4 );

        plot( trainRecord.testInd  , testH1Outputs ,  ':rx' , 'MarkerSize' , 4 );
        plot( trainRecord.testInd  , testH2Outputs ,  ':ro' , 'MarkerSize' , 4 );

        strTitle = strcat('Forecast ', ...
                           tsName,...
                           num2str(hiddenLayersSize,'-%02d-hn'),...
                           num2str(nInputs,'-%02d-in'),...
                           '');
                       % \x20 <- Space \xN N is hexadecimal code of the character
        title(strTitle); clear strTitle;
        legend('valTargets','testTargets','valH1Outputs','valH2Outputs','testH1Outputs','testH2Outputs')
        hold off;  


        % -----------------------------------------------------------------------------------------

        fprintf('Saving a figure ... ');
        num = 1;
        filename = strcat(tsName,...
                          num2str(hiddenLayersSize,'_%02d-hn'),...
                          num2str(nInputs,'-%02d-in'),...
                          num2str(num,'_%02d'),...
                          '.pdf');

        while ( exist(strcat(folderFigures,'\',filename),'file' ) == 2 ) 
            num = num + 1;
            filename = strcat(tsName,...
                              num2str(hiddenLayersSize,'_%02d-hn'),...
                              num2str(nInputs,'-%02d-in'),...
                              num2str(num,'_%02d'),...
                              '.pdf');

        end

        t = tic;
        saveFigure( h3 , '-dpdf', folderFigures , filename );    
        fprintf(' (%10.3f s)\n',toc(t) );


    end

    %% SHOWING RESULTS                     =================================================
    
    % ======================================================================================
    % Show the error on the screen
    
    fprintf('If Horizon = 1\n' );
    fprintf('\trmseTrain           %12.5f\n', rmseTrain);
    fprintf('\trmseValH1Forecast   %12.5f\n', rmseValH1Forecast  );
    fprintf('\trmseTestH1Forecast  %12.5f\n', rmseTestH1Forecast );
    fprintf('\n' );
    fprintf('\tsmapeTrain           %12.5f\n', smapeTrain);
    fprintf('\tsmapeValH1Forecast   %12.5f\n', smapeValH1Forecast  );
    fprintf('\tsmapeTestH1Forecast  %12.5f\n', smapeTestH1Forecast );
    fprintf('\n' );
    
    
    fprintf('If Horizon > 1\n' );
    fprintf('\tRMSE error\n');
    fprintf('\tTrain %12.5f\n', rmseTrain);
    fprintf('\tValid %12.5f \n', rmseValH2Forecast  ); 
    fprintf('\tTest  %12.5f \n', rmseTeH2Forecast    );
    fprintf('\n');
    
    fprintf('\tSMAPE error\n');
    fprintf('\tTrain %12.5f\n', smapeTrain);
    fprintf('\tValid %12.5f \n', smapeValH2Forecast ); 
    fprintf('\tTest  %12.5f \n', smapeTeH2Forecast ); 
    fprintf('\t------\n');
    % ---------------------------------------------------------------------------------------
    if ( parameters.resultOnFile == 1 )
    
        fId = fopen( strcat(folderResults ,'\' , filenameResults) , 'a' );

        if fId < 1 
            % error 
            return; 
        else 
            fprintf(fId ,' %20s' , tsName);
            fprintf(fId ,' %3d'  , nInputs);
            fprintf(fId ,' %3d'  , hiddenLayersSize );
            fprintf(fId ,' %3d'  , nOutputs);
            fprintf(fId ,' %10s' , trainFcnStr );
            fprintf(fId ,' %6d'  , trCycles );
            fprintf(fId ,' %6.2f', learningRate );
            fprintf(fId ,' %6.2f', learningRate );

            fprintf(fId , ' %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f \n', ...
                      rmseTrain         , smapeTrain         , ...
                      rmseValH2Forecast , smapeValH2Forecast , ...
                      rmseTeH2Forecast  , smapeTeH2Forecast );         

            fclose(fId);

        end
    end
    %% SHOWING TOTAL EXECUTION TIME        =================================================

    fprintf('Total Execution Time: %10.3f s\n\n',toc(initTotalExecTime)); clear initTotalExecTime;

end % END OF THE FUNCTION