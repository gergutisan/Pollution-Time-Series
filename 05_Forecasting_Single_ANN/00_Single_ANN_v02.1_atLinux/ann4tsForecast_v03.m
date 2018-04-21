function [result] = ann4tsForecast_v02( annParameters )

  %ann4tsForecast_v02 Compute the learning algorithm of an ANN applied to
  %                   time series
  %   Detailed explanation should go here

  result.comment = '-'; 
  strNumExp = sprintf('%06i',annParameters.iCombFactLevel);

  %% (TS, ANN, etc) Parameters   ===========================================================
  %folder_TS  = 'Timeseries'; 
  folder_TS   = annParameters.tsFolder;
  % file_TS   = 'ts_mackeyglass01.dat'; % file_TS   = 'ts_temperature.dat';
  file_TS     = annParameters.tsFilename;
  tsName = annParameters.tsName;
  tsType = annParameters.tsType;

  folder_Results = annParameters.folder_Results;

  % ==========================================================================================
  nOutputs          = annParameters.nOutputs; % nOutputs  = 1;
  nInputs           = annParameters.nInputs;  % nInputs   = 10;  
  hiddenLayersSize  = annParameters.hiddenLayersSize;  %hiddenLayerSizes = [10]; % hiddenLayerSizes = [10 5]; 
  trCycles          = annParameters.trCycles;          %trCycles       = 1000    % 500 1000 2000 5000
  learningRate      = annParameters.learningRate;      %learningRate   = 0.1;    % 0.2 0.1 0.05 0.01                          
  % Train Function as a number and as a String
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
  trainPrctg        = annParameters.trainPrctg;     %trainPrctg = 60; 
  valPrctg          = annParameters.valPrctg;       % valPrctg   = 20;
  testPrctg         = 100 - trainPrctg - valPrctg;
    % ----------------------------------------
  trainGoal         = annParameters.trainGoal;         %trainGoal      = 0.0001; % mse = 0.001 ??<Az
  times2seeTrain    = annParameters.times2seeTrain;    %times2seeTrain = 5;

  %% Load Time Series and get Time Series Pattern Set 
  filename          = strcat(folder_TS,'/',file_TS);

  % tsData = load(filename);  % ts <- column vector
  tsData            = load(filename,'-ascii');  % ts <- column vector

  b = size(tsData,1);
  % a = round( ( b - nInputs) *( 1 - testPrctg/100 ) +  nInputs );
  % a = floor( ( b - nInputs) *( 1 - testPrctg/100 ) +  nInputs );
  a = ceil(  ( b - nInputs) *( 1 - testPrctg/100 ) +  nInputs );

  learning_tsData = tsData(1:(a));
  test_tsData = tsData((a+1):b);

  patterns = ts2Patterns( tsData, nInputs, nOutputs );
  % learningPatterns = ts2Patterns( learning_tsData, nInputs, nOutputs );

  %% Clear some vars
  clear folder_TS filename a b 
  % clearvars -except tsData learning_tsData test_tsData patterns  nInputs nOutputs

  %% ARTIFICIAL NEURAL NETWORK 
  % https://es.mathworks.com/help/nnet/ug/create-configure-and-initialize-multilayer-neural-networks.html

  % help nnet/Contents.m

  % =========================================================================
  % Input patterns (x) and target (t)
  patterns_inputs  = patterns(:,1:nInputs);
  patterns_targets = patterns(:,(nInputs+1):(nInputs+nOutputs));

  % patterns_inputs  = learningPatterns(:,1:nInputs);
  % patterns_targets = learningPatterns(:,(nInputs+1):(nInputs+nOutputs));

  x = patterns_inputs';
  t = patterns_targets';

  % =========================================================================
  % Create the ANN   --------------------------------------------------------
  net01 = feedforwardnet(hiddenLayersSize,trainFcnStr); 
  net01.userdata.note = 'ann for TS forecasting';
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

  net01.layers{1}.transferFcn = transferFcn;
  net01.layers{2}.transferFcn = transferFcn;

  net01 = configure(net01,x,t);

  if (annParameters.showOnScreen)
      fprintf('\n -> net01.inputs{1}.size: %i -- size(x,1): %i \n', ... 
               net01.inputs{1}.size, size(x,1));
  end;
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
  net01.divideFcn  = annParameters.divideFcn ;    % net01.divideFcn ='divideblock'; 
  net01.divideMode = annParameters.divideMode;    % net01.divideMode = 'sample'; 

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

  net01.trainParam.min_grad = annParameters.trainParam.min_grad; 
                                                % net01.trainParam.min_grad   = 0;
  net01.trainParam.time     = annParameters.trainParam.time;
                                                % net01.trainParam.time       = Inf;

  net01.trainParam.showWindow       = true;
  net01.trainParam.showCommandLine  = true;
  net01.trainParam.show             = int64(trCycles/times2seeTrain);

  % ========================================================================================
  %%  TRAIN THE ANN by MATLAB                                                  =============
  
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
  if (annParameters.showTrainRecord)
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
  if (annParameters.netView) 
      netView = view(net01);
      % fprintf('\nPuase. Press any key to continue. ');pause();fprintf('\n');close(net01View);
  end

  %% SIMULATE the ANN
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
  if (annParameters.showOnScreen)
      fprintf('test_tsData -> size(...): %d %d \n',size(test_tsData,1),size(test_tsData,2));
      fprintf('testOutputs -> size(...): %d %d \n',size(testOutputs,1),size(testOutputs,2));
      fprintf('test_tsData & testOutputs are ');
      if ( sum( test_tsData ~= testOutputs ) ) 
        fprintf('Equal.\n\n');
      else
        fprintf('NOT equal.\n\n');
      end;
  end;

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
  
  %% COMPUTE ERRORS -----------------------------------------------------
  %{
    Neural network performance: mae | mse | patternnet | sae | softmax | sse |crossentropy
    Forecast accuracy https://www.otexts.org/fpp/2/5
    Errors on percentage errors by robjhyndman
    SMAPE: http://robjhyndman.com/hyndsight/smape/
    Three definitions for SMAPE

  %}

  % MSE  (mean squared error)
  mseTrainError =  sum( ( trainOutputs - trainTargets ).^2 ) / size(trainTargets, 1 ); 
  mseValError   =  sum( ( valOutputs   - valTargets   ).^2 ) / size(valTargets  , 1 ); 
  mseTestError  =  sum( ( testOutputs  - testTargets  ).^2 ) / size(testTargets , 1 ); 
  
  % RMSE  (root mean squared error)
  rmseTrainError = sqrt(mseTrainError);
  rmseValError   = sqrt(mseValError);
  rmseTestError  = sqrt(mseTestError);
  % MAE  (mean absolute error)
  maeTrainError = sum( ( abs(trainOutputs - trainTargets) ) ) /  size(trainTargets,1 ); 
  maeValError   = sum( ( abs(valOutputs - valTargets) ) )     /  size(valTargets  ,1 ); 
  maeTestError  = sum( ( abs(testOutputs - testTargets) ) )   /  size(testTargets ,1 ); 
  % SMAPE 
  % http://robjhyndman.com/hyndsight/smape/
  smapeTrainError = sum(  200*( ( abs(trainOutputs - trainTargets ) ./ ( abs(trainOutputs) + abs(trainTargets) ) ) ) / size(trainTargets , 1));
  smapeValError   = sum(  200*( ( abs(valOutputs   - valTargets   ) ./ ( abs(valOutputs)   + abs(valTargets)   ) ) ) / size(valTargets   , 1));
  smapeTestError  = sum(  200*( ( abs(testOutputs  - testTargets  ) ./ ( abs(testOutputs)  + abs(testTargets)  ) ) ) / size(testTargets  , 1));

  % WMAPE (Weighted Mean Absolute Percent Error).

  % WAPE

  %% Show Errors ------------------------------------------
  if (annParameters.showOnScreen)
      fprintf('%i\n',annParameters.iCombFactLevel);
      fprintf('Error   %12s  %12s  %12s\n','TRAIN','VAL','TEST');
      fprintf('mse     %12.5f  %12.5f  %12.5f\n'     , mseTrainError   ,mseValError   ,mseTestError);
      fprintf('rmse    %12.5f  %12.5f  %12.5f\n'     , rmseTrainError  ,rmseValError  ,rmseTestError);
      fprintf('mae     %12.5f  %12.5f  %12.5f\n'     , maeTrainError   ,maeValError   ,maeTestError);
      fprintf('smape   %12.2f  %12.2f  %12.2f\n'     , smapeTrainError ,smapeValError ,smapeTestError);
  end
  %{
      fid = fopen(strcat(parameters.resultsFolder,parameters.resultFilename));
      if (fid == -1)
          fprintf('\nError opening\n');
      else
          fclose(fid);
      end;
  %}

  %% Show Target & Outputs -------------------------
  if (annParameters.showTrainValTestTargetOutput)
      
      scrsz = get(groot,'ScreenSize'); % [left bottom width height].
      hTrVaTe_TargetOutput = figure('Position',[ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5],...
                                    'visible', annParameters.figVisible);   % 'visible', figVisible
      
      b = size(trainTargets,1) + size(valTargets,1) + size(testTargets,1);
      t = 1:b; 
      clear b;
      % As [train/val/test]Targets [train/val/test]Outputs are row vector
      trainValTestTargets = [ trainTargets ; valTargets ; testTargets];
      trainValTestOutputs = [ trainOutputs ; valOutputs ; testOutputs];
      
      plot(t,trainValTestTargets, 'go--'); hold on
      plot(t,trainValTestOutputs, 'bo--'); 
      
      grid on; grid minor
      
      legend('target','output')
      title(strcat('(Train + Val + Test)','--', annParameters.tsFilename));
      title(strcat('(Train + Val + Test)','--', annParameters.tsFilename));
      
      clear trainValTestTarget trainValTestOutput;
      
      TrVaTeTargetOutputFigFilename = strcat(annParameters.folder_Results,'/',...
                                             tsName,'-TrVaTe+TarOut-',strNumExp);
      
      %savefig( hTrVaTe_TargetOutput , TrVaTeTargetOutputFigFilename , 'compact');
      %saveas(  hTrVaTe_TargetOutput , TrVaTeTargetOutputFigFilename , 'png');    %saveas(gcf,'Barchart.png') 
      print( hTrVaTe_TargetOutput , TrVaTeTargetOutputFigFilename,    '-dpng','-r300');    
      
      % ---
      % TrVaTeTargetOutputFigFilename = strcat(parameters.folder_Results,'/',...
      %                                        tsName,'-TrVaTe+TarOut-',strNumExp,'.pdf');
      % saveas( hTrVaTe_TargetOutput , TrVaTeTargetOutputFigFilename )
      
      close(hTrVaTe_TargetOutput);
  end
  
  if (annParameters.showValTargetOutput)
      
      scrsz = get(groot,'ScreenSize'); % [left bottom width height].
      hValTargetOutput = figure('Position',[ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5], ...
                                'visible', annParameters.figVisible );
      
      t = 1:size(valTargets,1); 
      plot(t,valTargets, 'bo--'); hold on
      plot(t,valOutputs, 'ro--'); 
      
      grid on; grid minor
      
      legend('target','output'); 
      title(strcat('(Validation)','--',annParameters.tsFilename));
       
      testTargetOutputFigFilename = strcat(annParameters.folder_Results,'/',...
                                           tsName,'-Val+TarOut-',strNumExp);
      
	  % savefig( hValTargetOutput , testTargetOutputFigFilename , 'compact');
      % saveas(  hValTargetOutput , testTargetOutputFigFilename, 'png');
      print( hValTargetOutput , testTargetOutputFigFilename,'-dpng','-r300');  
      % ---
      %testTargetOutputFigFilename = strcat(parameters.folder_Results,'/',...
      %                                     tsName,'-Te+TarOut-',strNumExp,'.pdf');
      %saveas(hTestTargetOutput,testTargetOutputFigFilename)
      close(hValTargetOutput);
      
  end

  if (annParameters.showTestTargetOutput)
      
      scrsz = get(groot,'ScreenSize'); % [left bottom width height].
      hTestTargetOutput = figure('Position', [ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5], ...
                                 'visible' , annParameters.figVisible );
      
      t = 1:size(testTargets,1); 
      plot(t,testTargets, 'go--'); hold on
      plot(t,testOutputs, 'bo--'); 
      
      grid on; grid minor
      legend('target','output'); 
      title( strcat( '(Test)','--' , annParameters.tsFilename ) );
       
      testTargetOutputFigFilename = strcat(annParameters.folder_Results,'/',...
                                           tsName,'-Te+TarOut-',strNumExp,'.fig');
     
      %savefig( hTestTargetOutput ,  testTargetOutputFigFilename ,  'compact');
      %saveas(  hTestTargetOutput , testTargetOutputFigFilename, 'png');
      print( hTestTargetOutput , testTargetOutputFigFilename,'-dpng','-r300');  
      
      %testTargetOutputFigFilename = strcat(parameters.folder_Results,'/',...
      %                                     tsName,'-Te+TarOut-',strNumExp,'.pdf');
      %saveas(hTestTargetOutput,testTargetOutputFigFilename)
      close( hTestTargetOutput );
      
  end

  %% RESULTS -------------------------------------------------

  result.ts_filename      = annParameters.tsFilename;
  result.tsName           = tsName;  
  result.tsType           = tsType;
  % ----------------------------------------
  result.nOutputs         = nOutputs;
  % ----------------------------------------
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
  result.trainOutputs     = trainOutputs;
  result.trainTargets     = trainTargets;
  result.valOutputs       = valOutputs;
  result.valTargets       = valTargets;
  result.testOutputs      = testOutputs;
  result.testTargets      = testTargets;
  % ----------------------------------------
  % ERRORS
  result.mseTrainError    = mseTrainError;
  result.rmseTrainError   = rmseTrainError;
  result.maeTrainError    = maeTrainError;
  result.smapeTrainError  = smapeTrainError;
  % --
  result.mseValError      = mseValError;
  result.rmseValError     = rmseValError;
  result.maeValError      = maeValError;
  result.smapeValError    = smapeValError;
  % --
  result.mseTestError     = mseTestError;
  result.rmseTestError    = rmseTestError;
  result.maeTestError     = maeTestError;
  result.smapeTestError   = smapeTestError;
  % ----------------------------------------
  result.net              = net01;
  result.trainRecord      = trainRecord;  


  %% END OF THE FUNCTION
  % pause;

end

