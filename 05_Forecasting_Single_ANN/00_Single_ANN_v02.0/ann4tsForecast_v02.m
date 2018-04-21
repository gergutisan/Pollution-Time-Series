function result = ann4tsForecast_v02( parameters )

  %ann4tsForecast_v02 Compute the learning algorithm of an ANN applied to
  %                   time series
  %   Detailed explanation should go here

  result.comment = '-'; 
  strNumExp = sprintf('%04i',parameters.iCombFactLevel);

  %% parameters (TS, ANN, etc)  ===========================================================
  
  %folder_TS  = 'Timeseries'; 
  folder_TS     = parameters.tsFolder;
  % file_TS       = 'ts_mackeyglass01.dat'; % file_TS   = 'ts_temperature.dat';
  file_TS       = parameters.tsFilename;
  tsName        = parameters.tsName;
  tsType        = parameters.tsType;
  initId        = parameters.initId;

  folder_Results    = parameters.folder_Results;
  % ---------------------------------------------------------------------------------------
  % ANN PARAMETERS 
  nOutputs          = parameters.nOutputs; % nOutputs  = 1;
  nInputs           = parameters.nInputs;  % nInputs   = 10;  
  hiddenLayersSize  = parameters.hiddenLayersSize;  % hiddenLayerSizes = [10]; % hiddenLayerSizes = [10 5]; 
  trCycles          = parameters.trCycles;          % trCycles       = 1000    % 500 1000 2000 5000
  learningRate      = parameters.learningRate;      % learningRate   = 0.1;    % 0.2 0.1 0.05 0.01                          º
  % Train Function as a Number and as a String
  trainFcn          = parameters.trainFcn;
  trainFcnStr       = parameters.trainFcnStr;
  % trainFcnStr  = 'trainrp'; % 
                           % 'trainlm'   - Levenberg-Marquardt optimization, fastest backpropagation alg in the toolbox
                           % 'traingd'   - Gradient descent backpropagation.
                           % 'traingda'  - Gradient descent with adaptive lr backpropagation.
                           % 'trainrp'   - RPROP backpropagation.
                           % 'trainscg'  - Scaled conjugate gradient backpropagatio
  
  % --------------------------------                           
  transferFcn       = parameters.transferFcn;       %transferFcn = 'tansig';
  % --------------------------------
  trainPrctg        = parameters.trainPrctg;     %trainPrctg = 60; 
  valPrctg          = parameters.valPrctg;       % valPrctg   = 20;
  testPrctg         = 100 - trainPrctg - valPrctg;
    % ----------------------------------------
  trainGoal         = parameters.trainGoal;         %trainGoal      = 0.0001; % mse = 0.001 ??<Az
  times2seeTrain    = parameters.times2seeTrain;    %times2seeTrain = 5;

  %% Load Time Series and get Time Series Pattern Set 
  filename          = fullfile(folder_TS,file_TS);

  % tsData = load(filename);  % ts <- column vector
  tsData            = load(filename,'-ascii');  % ts <- column vector

  b = size(tsData,1);
  % a = round( ( b - nInputs) *( 1 - testPrctg/100 ) +  nInputs );
  % a = floor( ( b - nInputs) *( 1 - testPrctg/100 ) +  nInputs );
  a = ceil(  ( b - nInputs) *( 1 - testPrctg/100 ) +  nInputs );
  a = ceil(  ( b *( 1 - testPrctg/100 ) +  nInputs ) );

  learning_tsData = tsData(1:(a));
  test_tsData = tsData((a+1):b);

  patterns = ts2Patterns( tsData, nInputs, nOutputs );
  % learningPatterns = ts2Patterns( learning_tsData, nInputs, nOutputs );

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

  % ANN Configuration
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
  rng(parameters.rngSeed);
  net01 = init(net01);
  
  if (parameters.showOnScreen)
      fprintf( '\n -> net01.inputs{1}.size: %i -- size(x,1): %i \n', ... 
               net01.inputs{1}.size , size(x,1) );
      fprintf( '\n -> seed  %i\n', parameters.rngSeed );     
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
  net01.trainParam.show             = int64(trCycles/times2seeTrain);

  %%  TRAIN THE ANN by MATLAB  *************************************************************
  % Calling train  -> Calculation mode: MEX
  % parameters.trainParam.showWindow 
  net01.trainParam.showWindow=0;
  
  initTrainingTime = tic;
  [net01,trainRecord] = train(net01,x,t);
  %[net01,trainRecord] = train(net01,x,t,'useParallel','yes','showResources','yes');
  trainTimeElapsed = toc(initTrainingTime); clear initTrainingTime;
  
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
  if ( parameters.netView ) 
      netView = view( net01 );
      % fprintf('\nPuase. Press any key to continue. ');pause();fprintf('\n');close(net01View);
  end

  %% Forecast VALIDATION and TEST forecast using real values ( H = 1 ) or prev. forecast values ( H > 1)
  
  % Get VALIDATION and TEST outpus(forecast) using real values ( H = 1 ) or prev. forecast values ( H > 1 )
  
  H = 2;
  
  % Train Validation Test targets as row vectors 
  trainTargets    = t(:,trainRecord.trainInd );
  valTargets      = t(:,trainRecord.valInd   );
  testTargets     = t(:,trainRecord.testInd  );
  % forecastResults = getANNForecastResults( net01 , trainRecord , x , t  );
  forecastResults = getANNForecastResults_v02( net01 , trainRecord , x , t  );
 
  
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
  
  %% Show Errors (Done out of this function )  ------------------------------------------
%   if (parameters.showOnScreen)
%       fprintf('%i\n',parameters.iCombFactLevel);
%       fprintf('Error   %3s %12s  %12s  %12s\n'       ,'Hx','TRAIN','VAL','TEST');
%       fprintf('rmse    %3s %12.5f  %12.5f  %12.5f\n'     , ...
%               'H1', forecastResults.rmseTrain  , forecastResults.rmseValH1Forecast  , forecastResults.rmseTestH1Forecast);
%       fprintf('smape   %3s %12.2f  %12.2f  %12.2f\n'     , ...
%               'H1', forecastResults.smapeTrain , forecastResults.smapeValH1Forecast , forecastResults.smapeTestH1Forecast);
%       fprintf('rmse    %3s %12.5f  %12.5f  %12.5f\n'     , ... 
%               'H2', forecastResults.rmseTrain  , forecastResults.rmseValH2Forecast  , forecastResults.rmseTestH2Forecast);
%       fprintf('smape   %3s %12.2f  %12.2f  %12.2f\n'     , ...
%               'H2', forecastResults.smapeTrain , forecastResults.smapeValH2Forecast , forecastResults.smapeTestH2Forecast);
%       
%   end

  %% Show Target & Outputs (Done out of this function )  -------------------------
%   if (parameters.showTrainValTestTargetOutput) % (Done out of this function ) 
%       
%       scrsz = get( groot ,'ScreenSize');    % [left bottom width height]
%       hTrVaTe_TargetOutput = figure( 'Position', [ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5]); 
%       
%       a = size(trainTargets,2);
%       b = size(trainTargets,2) + size(valTargets,2);
%       c = size(trainTargets,2) + size(valTargets,2) + size(testTargets,2);
%       t = 1:c;
%       tVal  = (a+1):b; 
%       tTest = (b+1):c;
%       
%       % As [train/val/test]Targets [train/val/test]Outputs are row vector
%             
%       plot( t     ,[ trainTargets , valTargets , testTargets] , 'ko--', 'MarkerSize' , 3); hold on
%       plot( tVal  ,forecastResults.valH1Outputs               , 'bo:', 'MarkerSize' , 5); 
%       plot( tVal  ,forecastResults.valH2Outputs               , 'ro:', 'MarkerSize' , 5); 
%       plot( tTest ,forecastResults.testH1Outputs              , 'bx:', 'MarkerSize' , 5); 
%       plot( tTest ,forecastResults.testH2Outputs              , 'rx:', 'MarkerSize' , 5); 
%       
%       grid on; grid minor
%       legend('targets','valOutputH1','valOutputH2','testOutputsH1', 'testOutputsH2');
%       title(strcat('(Train + Val + Test)','--', parameters.tsFilename));
%            
%       clear t a b c tVal tTest ;
%       
%       %saveas(gcf,'Barchart.png')
%       
%       TrVaTeTargetOutputFigFilename = strcat(parameters.folder_Results,'/',...
%                                              tsName,'-TrVaTe+TarOutH1H2-',strNumExp,'.fig');
%                                          
%       filename = strcat(tsName,'_',tsType,'_',strNumExp,'_','-TrVaTe+TarOutH1H2-','.fig');
%       TrVaTeTargetOutputFigFilename = fullfile( parameters.folder_Results, filename); clear filename; 
%                                                                  
%       savefig(TrVaTeTargetOutputFigFilename);
%       
%       % TrVaTeTargetOutputFigFilename = strcat(parameters.folder_Results,'/',...
%       %                                        tsName,'-TrVaTe+TarOut-',strNumExp,'.pdf');
%       % saveas(hTrVaTe_TargetOutput,TrVaTeTargetOutputFigFilename)
%       
%       close(hTrVaTe_TargetOutput);
%   end
  
%   if (parameters.showValTargetOutput) % (Done out of this function )
%       
%       scrsz = get(groot,'ScreenSize'); % [left bottom width height].
%       hValTargetOutput = figure('Position',[ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5]);
%       
%       a = size(trainTargets,2);
%       b = size(trainTargets,2) + size(valTargets,2);
%       c = size(trainTargets,2) + size(valTargets,2) + size(testTargets,2);
%       
%       tValTest = (a+1):c;
%       tVal     = (a + 1):b; 
%       tTest    = (b + 1):c;
%       
%       % As [train/val/test]Targets [train/val/test]Outputs are row vector
%             
%       plot( tValTest ,[ valTargets , testTargets] , 'ko--', 'MarkerSize' , 3); hold on
%       plot( tVal  ,forecastResults.valH1Outputs   , 'bo:', 'MarkerSize' , 5); 
%       plot( tVal  ,forecastResults.valH2Outputs   , 'ro:', 'MarkerSize' , 5); 
%       plot( tTest ,forecastResults.testH1Outputs  , 'bx:', 'MarkerSize' , 5); 
%       plot( tTest ,forecastResults.testH2Outputs  , 'rx:', 'MarkerSize' , 5); 
%       
%       grid on; grid minor
%       legend('targets','valOutputH1','valOutputH2','testOutputsH1', 'testOutputsH2');
%       title(strcat('Val + Test)','--', parameters.tsFilename));
%            
%       clear a b c tValTest tVal tTest ;
%       
%       %saveas(gcf,'Barchart.png')
%       
%       vaTeTargetOutputFigFilename = strcat(parameters.folder_Results,'/',...
%                                              tsName,'-VaTe+TarOutH1H2-',strNumExp,'.fig');
%       savefig(vaTeTargetOutputFigFilename);
%       
%       % vaTeTargetOutputFigFilename = strcat(parameters.folder_Results,'/',...
%       %                                        tsName,'-TrVaTe+TarOut-',strNumExp,'.pdf');
%       % saveas( hTrVaTe_TargetOutput , vaTeTargetOutputFigFilename )
%       
%       close(hValTargetOutput);     
%       
%   end

%   if (parameters.showTestTargetOutput) % (Done out of this function ) 
%       
%       scrsz = get(groot,'ScreenSize'); % [left bottom width height].
%       hTestTargetOutput = figure('Position',[ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5]);
%       
%       a = size(trainTargets,2) + size(valTargets,2); 
%       b = size(trainTargets,2) + size(valTargets,2) + size(testTargets,2);
%       tTest = (a+1):b;
%       
%       % As [train/val/test]Targets [train/val/test]Outputs are row vector
%             
%       plot( tTest , testTargets                   , 'ko--', 'MarkerSize' , 3); hold on
%       plot( tTest , forecastResults.testH1Outputs , 'bx:', 'MarkerSize' , 5); 
%       plot( tTest , forecastResults.testH2Outputs , 'rx:', 'MarkerSize' , 5); 
%       
%       grid on; grid minor
%       legend('targets','testOutputsH1', 'testOutputsH2');
%       title(strcat('Test)','--', parameters.tsFilename));
%            
%       clear a b tTest ;
%       
%       %saveas(gcf,'Barchart.png')
%       
%       TrVaTeTargetOutputFigFilename = strcat(parameters.folder_Results,'/',...
%                                              tsName,'-VaTe+TarOutH1H2-',strNumExp,'.fig');
%       savefig(TrVaTeTargetOutputFigFilename);
%       
%       % teTargetOutputFigFilename = strcat(parameters.folder_Results,'/',...
%       %                                        tsName,'-TrVaTe+TarOut-',strNumExp,'.pdf');
%       % saveas( hTrVaTe_TargetOutput , teTargetOutputFigFilename)
%       close(hTestTargetOutput);
%       
%   end

  %% RESULTS         ********************************************************************

  result.ts_filename      = parameters.tsFilename;
  result.tsName           = tsName;  
  result.tsType           = tsType;
  % ----------------------------------------
  result.nOutputs         = nOutputs;
  % ----------------------------------------
  result.initId           = initId;
  result.strNumExp        = strNumExp;
  result.rngSeed          = parameters.rngSeed;
  
  % FACTOR - LEVEL PARAMETERS
  result.nInputs          = nInputs;
  result.hiddenLayersSize = hiddenLayersSize;
  result.trainFcn         = trainFcn;
  result.trainFcnStr      = trainFcnStr;
  result.trCycles         = trCycles;
  result.learningRate     = learningRate;
  % ----------------------------------------
  result.transferFcn      = transferFcn;
  result.trainPrctg       = trainPrctg;
  result.valPrctg         = valPrctg;
  result.testPrctg        = testPrctg;
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
  
  result.valH1Outputs     = forecastResults.valH1Outputs;
  result.testH1Outputs    = forecastResults.testH1Outputs;
  
  result.valH2Outputs     = forecastResults.valH2Outputs;
  result.testH2Outputs    = forecastResults.testH2Outputs;

  % TRAIN REACORD --------------------------
  
  result.trainRecord = trainRecord;
  % ----------------------------------------
  % ERRORS
  
  result.rmseTrain   = forecastResults.rmseTrain;
  result.smapeTrain  = forecastResults.smapeTrain;
  % -- Val H1
  result.rmseValH1     = forecastResults.rmseValH1Forecast;
  result.smapeValH1    = forecastResults.smapeValH1Forecast;
  % -- Test H1
  result.rmseTestH1    = forecastResults.rmseTestH1Forecast;
  result.smapeTestH1   = forecastResults.smapeTestH1Forecast;
  
  % -- Val H2
  result.rmseValH2     = forecastResults.rmseValH2Forecast;
  result.smapeValH2    = forecastResults.smapeValH2Forecast;
  % -- Test H2
  result.rmseTestH2    = forecastResults.rmseTestH2Forecast; 
  result.smapeTestH2   = forecastResults.smapeTestH2Forecast;
  % ----------------------------------------
  result.net              = net01;
  result.trainRecord      = trainRecord;  
  result.trainTimeElapsed = trainTimeElapsed; 


  %% END OF THE FUNCTION
  % pause;

end

