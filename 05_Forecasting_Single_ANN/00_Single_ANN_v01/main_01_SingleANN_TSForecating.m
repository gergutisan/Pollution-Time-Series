%% RESET            =========================================================================
clear; clc; close('all'); fclose('all'); 
% clearvars -EXCEPT ....

%% DEBUGGING        ==========================================================================
isDebugging = 0;  % 1/0

%% COMPUTING TIME 
initTotalExecTime = tic;

%% LIST OF TIME SERIES          ==============================================================

if ( isDebugging > 0 )
    tsFilename = 'ts-Mackeyglass01.csv';
    tsFilename = 'ts-Temperature.csv';
elseif( isDebugging == 0 )
    tsFilename; 'ts-NO2-FedzLadreda-16-12.csv';
end

%% SET FOLDERs AND PATH 
cd(fileparts(mfilename('fullpath')));    % does not work if executed by Run Section [and advance]
folderFunctions  = fullfile( fileparts(mfilename('fullpath')),'Functions');
folderTimeSeries = fullfile( fileparts(mfilename('fullpath')),'TimeSeries');
folderFigures    = fullfile( fileparts(mfilename('fullpath')),'Figures');
folderResults    = fullfile( fileparts(mfilename('fullpath')),'Results');

path( folderFunctions  , path );
path( folderTimeSeries , path );
path( folderFigures    , path );
path( folderResults    , path );

% ToDo (check if the folders already exits)
% ...

%% SET THE SCREEN SIZE      ================================================================
% set the left corner position and the size of the figures
setScreenSize (10, 0.4);

%% DELETE THE CONTENT OF FIGURES AND RESULT FOLDERS   ======================================

delete( fullfile( folderResults , '*.*' ) ) ;
delete( fullfile( folderFigures , '*.*' ) ) ;

%% PARAMETERS                   ============================================================

% Experiments ID----------------------------------
parameters.idExp   = 01;     
parameters.iterExp = 01;     


parameters.folderFunctions  = folderFunctions;
parameters.folderTimeSeries = folderTimeSeries;
parameters.folderFigures    = folderFigures;
parameters.folderResults    = folderResults;
parameters.filenameResults  = 'results_01.dat';

% ANN PARAMETERS -------------------

% DROPOUT        ??
% REGULARIZATION ??

% Topology      ----------------------------------------------------------------------------
parameters.nInputs          = 28;
parameters.hiddenLayersSize = [20 10];  % One hidden layer  with 20 neurons
parameters.nOutputs         = 1;
parameters.transferFcn      = 'tansig';
parameters.trainFcnStr      = 'trainscg'; % 
             
             % (#1) 'trainlm'  - Levenberg-Marquardt optimization, 
             %                   fastest backpropagation alg in the toolbox
             % (#2) 'traingd'  - Gradient descent backpropagation.
             % (#3) 'traingda' - Gradient descent with adaptive lr backpropagation.
             % (#4) 'traingdx' - Variable Learning Rate Gradient Descent
             % (#5) 'trainrp'  - RPROP Resilient Backpropagation.
             % (#6) 'trainscg' - Scaled conjugate gradient backpropagatio
             % (#7) 'traingdm' - Gradient Descent with Momentum

parameters.trainPrctg     = 70;   % (up to now) FIXED
parameters.valPrctg       = 15;   % (up to now) FIXED
parameters.testPrctg      = 100 - parameters.trainPrctg - parameters.valPrctg; % FIXED

parameters.divideMode     = 'sample';        % (up to now) FIXED
parameters.divideFcn      = 'divideblock';   % (up to now) FIXED

parameters.trCycles       = 2 * 10^2;
parameters.learningRate   = 0.1;
parameters.trainGoal      = 0.0000001; 

parameters.trainParam.min_grad = 0;
parameters.trainParam.time     = Inf;

% Seed  ------------------------
v = (int32(clock)); seed = v(5) + v(6); clear v;
rng(seed);  fprintf('Seed: %03d\n',seed); % seed is the second for time 
parameters.rngSeed          = seed; clear seed;


% What to show  ----------------------------------
parameters.trainParam.showCommandLine = 0;
parameters.times2seeTrain             = 5;
parameters.trainParam.showWindow      = 0;
parameters.showOnScreenNet            = 0;
parameters.netView                    = 0;
parameters.showTrainRecord            = 0;
parameters.resultOnFile               = 0;  % ???

% HOW TO CARRY OUT THE FORECAST FOR TIME SERIES FORECASTING ---------------
parameters.horizon          = 2;  % if h > 1 => using real values for y_t+2 (1) or forecast values (2) 
parameters.ValhorizonComp   = 2;  % if h > 1 => using real values for y_t+2 (1) or forecast values (2)
parameters.TesthorizonComp  = 2;  % if h > 1 => using real values for y_t+2 (1) or forecast values (2)

% TIME SERIES -------------------------------------------------------------
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
% parameters.tsName = 'SharePrices.mat;'; load SharePrices.mat;  tsData = data(:,1); %plot(tsData); 
        % Training with TRAINGD completed: Minimum gradient reached.

% -----------------------------------------------------------------------------        
parameters.tsFilename = tsFilename;
% parameters.tsFilename = 'ts-NO2-PzCastilla-16-10.csv';
% parameters.tsFilename = 'ts-O3-JuanCarlosI-16-07.csv';
% parameters.tsFilename = 'ts-PM25-MendezAlvaro-16-10.csv';
parameters.tsName     = parameters.tsFilename(4:(end-4)); 

%% PREALLOCATION  =============================================================================

%% CALL function to try ANN for time series forecasting  ======================================

% Time Series List   -------------------------------------------------------- 

% Parameters to Change -------------------------------------------------------
% parameters.nInputs
% parameters.hiddenLayersSize 
% parameters.trainFcnStr      % <- 'trainrp' , 'trainscg' , 'trainlm' , 'traingd' , 'traingda'
% parameters.trCycles         % <- several values 
% parameters.learningRate     % <- 0.3 0.2 0.1 0.05 0.01
% parameters.tsFilename       % <- tsFilenameCellArray

if ( isDebugging == 1 )
    % ----------------------------------------------------------------------------------
    % FOR DEBUGGING 
    
    %tsFilenameCellArray = {'ts-NO2-FedzLadreda-16-12.csv'};
    %tsFilenameCellArray = {'ts-NO2-FedzLadreda-16-12.csv',...
    %                       'ts-NO2-PzCastilla-16-10.csv'};
    tsFilenameCellArray = tsFilename;
    nInputsArray          = {16 28};
    hiddenLayersSizeArray = { 8 16 ; 14 28  };  
    nValues4HiddenLayers  =  2;  

    % trainFcnStrArray    = {'trainrp' , 'trainscg' , 'trainlm' , 'traingd' , 'traingda'};
    trainFcnStrArray      = {'trainrp' , 'trainscg' };
    trCycles              = {   50 100 };
    learningRateArray     = { 0.05 0.1 };

    nSim                  = 2;

    
elseif ( isDebugging == 0 )
    % ----------------------------------------------------------------------------------
    % REAL & EXPERIMENTATION VALUES
    nInputsArray          = { 28 52 76 };
    hiddenLayersSizeArray = { 06 12 24 36  48 ;...
                              12 24 48 72  96 ;...
                              24 48 72 96 120 };  
    nValues4HiddenLayers  = 3;  
    
    % trainFcnStrArray    = {'trainrp' , 'trainscg' , 'trainlm' , 'traingd' , 'traingda'};
    trainFcnStrArray      = {'trainrp' , 'trainscg' };
    trCycles              = { 1000  2000  5000};
    learningRateArray     = { 0.05   0.1   0.2};

    nSim                  = 10;

    tsFilenameCellArray = {'ts-NO2-FedzLadreda-16-12.csv', ...
                           'ts-NO2-PzCastilla-16-10.csv' , ...
                           'ts-O3-JuanCarlosI-16-07.csv' , ...
                           'ts-PM25-MendezAlvaro-16-10.csv' };
    
end


% PREALLOCATION      -------------------------------------------------------
fprintf('\n\n ---- CounterExp %d (its result is used for preallocation) -----\n\n', 0);

oldTrCycles = parameters.trCycles;
parameters.trCycles = 100;

[ oneNet4TSF_Data , ...
  netTrained      , ...
  parameters2     ] = forecast_singleANN4TSF_v02( parameters );

parameters.trCycles  = oldTrCycles;


delete(fullfile( parameters.folderFigures,'*.pdf'));
delete( fullfile( parameters.folderResults,parameters.filenameResults ) );

nExps = numel( nInputsArray )   * nValues4HiddenLayers * ...
        numel( trainFcnStrArray) * numel( trCycles )  * numel( learningRateArray ) * ...
        nSim;

% -----------------------------------------------------------------------
fprintf('\n\n NUMBER OF EXPEREIMENTS %d  (expected time: %5.1f min)\n\n', ... 
         nExps , (nExps * 10)/60 );

%fprintf('Press any key to continue ... '); pause; fprintf('\n');


%% EXECUTE THE EXPERIMENTS   ====================================================================

% -----------------------------------------------------------------------------------------------
num = 0;

 while ( exist( fullfile( parameters.folderFigures , parameters.filenameResults ) , 'file' ) == 2 ) 
            num = num + 1;
            filenameResults = strcat(parameters.filenameResults(1:(end-6)),...
                              num2str(num,'_%02d'), ...
                              parameters.filenameResults(end-3): end);
            
            parameters.filenameResults = filenameResults;               
               
end

% -----------------------------------------------------------------------------------------------

% for iTs = 1:numel(tsFilenameCellArray)
nets4TSF_DataList = repmat( oneNet4TSF_Data, [numel(tsFilenameCellArray) , nExps ] );  
parametersList    = repmat( parameters2    , [numel(tsFilenameCellArray) , nExps ] );  
% netTrainedList    = repmat( netTrained     , [numel(tsFilenameCellArray) , nExps ] ); 

netTrainedList = cell( numel(tsFilenameCellArray) , nExps );
for i = 1:numel(tsFilenameCellArray)
    for j = 1:nExps
        netTrainedList{i,j} = netTrained;
    end
end


for iTs = 1:numel(tsFilenameCellArray)
    
    CounterExp = 0;
    idExp      = 0; 
    tsName = tsFilenameCellArray{iTs}(4:(end-4));
    
    for i_nInputs = 1:numel(nInputsArray)
    
        for i_hLayers = 1:size(hiddenLayersSizeArray , 2)
            
        
            for i_trainFunc = 1:numel(trainFcnStrArray)
               
        
                for i_trCycles = 1:numel(trCycles)
                    
    
                    for i_learningRate = 1:numel(learningRateArray)
                        
                        idExp  = idExp + 1;
                        iter   = 0;    
                        for iSim = 1:nSim
                            
                            CounterExp = CounterExp + 1;
                            iter = iter + 1; 
                            
                            fprintf('---- iTs: %3d  - CounterExp %10d -----\n', iTs, CounterExp);
                            
                            filenameResults = strcat( tsName , '_' , parametersList( iTs, CounterExp ).filenameResults );
                            filenameResults = checkAndGetFilename_v01( parametersList( iTs, CounterExp ).folderResults , filenameResults );
                            
                            parametersList( iTs, CounterExp ).idExp   = idExp;     
                            parametersList( iTs, CounterExp ).iterExp = iter;     
                            
                            parametersList( iTs, CounterExp ).filenameResults  = filenameResults;
                            parametersList( iTs, CounterExp ).tsFilename       = tsFilenameCellArray{iTs};
                            parametersList( iTs, CounterExp ).nInputs          = nInputsArray{i_nInputs};
                            parametersList( iTs, CounterExp ).hiddenLayersSize = hiddenLayersSizeArray{i_nInputs, i_hLayers };
                            parametersList( iTs, CounterExp ).trainFcnStr      = trainFcnStrArray{i_trainFunc};
                            parametersList( iTs, CounterExp ).trCycles         = trCycles{i_trCycles};
                            parametersList( iTs, CounterExp ).learningRate     = learningRateArray{i_learningRate};
                                                        
                            % [ nets4TSF_Data( iTs, CounterExp ) ] = forecast_singleANN4TSF_01 ( parameters( iTs, CounterExp ) );
                            % https://es.mathworks.com/help/distcomp/batch.html
                            % p = parameters( iTs, CounterExp );
                            % j = batch( forecast_singleANN4TSF_01,  1 , { p } );
                            % delete(j)
                            
                            % If save data  ---------------------------------------------------
                            
                            % If print data of plain text file   ------------------------------
                        end
                    end
                end
            end
        end
    end

end
% ----------------------------------------------------------------------------------------------
fprintf('\n\n NUMBER OF EXPEREIMENTS %d  (expected time: %5.1f min)\n\n', ... 
         nExps , (nExps * 10)/60 );

% SETTING THE PARALLEL POOL     
% nets4TSF_Data
% pool = parpool;

if isempty(gcp)
    myPool = parpool(3);
end

for iTs = 1:numel(tsFilenameCellArray)
    
    nets4TSF_Data_Temp = struct();
    parfor iExp = 1:CounterExp
    % for iExp = 1:CounterExp
        fprintf('\n\n ----- iTs %d iExp %d -----\n\n', iTs, iExp);
        %nets4TSF_Data_Temp = struct();
        %nets4TSF_Data_Temp = forecast_singleANN4TSF_01 ( parameters( iTs, CounterExp ) );
        %[ nets4TSF_Data( iTs, CounterExp ) ] = nets4TSF_Data_Temp;
        [ nets4TSF_DataList( iTs, iExp ) , ...
          netTrainedList{ iTs, iExp } , ... 
          parametersList( iTs, iExp ) ] = forecast_singleANN4TSF_v02 ( parametersList( iTs, iExp ) );
    end
   
    % ------------------------------------------------------------------------------
    tsName = tsFilenameCellArray{iTs};
    tsName = tsName( 4:(end-4) );
    filenameResults     = strcat( 'results_',tsName,'.dat');
    fullFilenameResults = fullfile( folderResults , filenameResults);
    
    fId = fopen( fullfile(folderResults , filenameResults ) , 'w' );
    
    if fId < 1 
        % error 
        return; 
    else
        fprintf(fId ,' %25s' , 'tsName'   );
        fprintf(fId ,' %6s'  , 'idExp'   );
        fprintf(fId ,' %7s'  , 'iterExp'   );
        fprintf(fId ,' %3s'  , 'nIn'      );
        fprintf(fId ,' %3s'  , 'hsz'      );
        fprintf(fId ,' %3s'  , 'nOu'      );
        fprintf(fId ,' %10s' , 'trainFcn' );
        fprintf(fId ,' %6s'  , 'trCycl'   );
        fprintf(fId ,' %6s'  , 'lr'       );
        fprintf(fId ,' %5s'  , 'seed'     );

        fprintf(fId , ' %12s', 'rmseTr'     );
        fprintf(fId , ' %12s', 'smapeTr'    );                               
        fprintf(fId , ' %12s', 'rmseValH2'  );
        fprintf(fId , ' %12s', 'smapeValH2' );                               
        fprintf(fId , ' %12s', 'rmseTeH2'   );
        fprintf(fId , ' %12s', 'smapeTeH2'  );
        fprintf(fId , '\n');    

        
        for iExp = 1:CounterExp

            tsName           = parametersList( iTs, iExp ).tsName; 
            idExp            = parametersList( iTs, iExp ).idExp; 
            iterExp          = parametersList( iTs, iExp ).iterExp; 
            nInputs          = parametersList( iTs, iExp ).nInputs;
            hiddenLayersSize = parametersList( iTs, iExp ).hiddenLayersSize;
            nOutputs         = parametersList( iTs, iExp ).nOutputs;   
            trainFcnStr      = parametersList( iTs, iExp ).trainFcnStr;  
            trCycles         = parametersList( iTs, iExp ).trCycles;
            learningRate     = parametersList( iTs, iExp ).learningRate;
            seed             = parametersList( iTs, iExp ).rngSeed;

            rmseTrain          = nets4TSF_DataList( iTs, iExp ).rmseTrain; 
            smapeTrain         = nets4TSF_DataList( iTs, iExp ).smapeTrain; 
            rmseValH2Forecast  = nets4TSF_DataList( iTs, iExp ).rmseValH2Forecast; 
            smapeValH2Forecast = nets4TSF_DataList( iTs, iExp ).smapeValH2Forecast; 
            rmseTeH2Forecast   = nets4TSF_DataList( iTs, iExp ).rmseTeH2Forecast; 
            smapeTeH2Forecast  = nets4TSF_DataList( iTs, iExp ).smapeTeH2Forecast;

            fprintf(fId ,' %25s' , tsName);
            fprintf(fId ,' %6d' , idExp);
            fprintf(fId ,' %7d' , iterExp);
            fprintf(fId ,' %3d'  , nInputs);
            fprintf(fId ,' %3d'  , hiddenLayersSize );
            fprintf(fId ,' %3d'  , nOutputs);
            fprintf(fId ,' %10s' , trainFcnStr );
            fprintf(fId ,' %6d'  , trCycles );
            fprintf(fId ,' %6.2f', learningRate );
            fprintf(fId ,' %5d'  , seed );

            fprintf(fId , ' %12.5f', rmseTrain );
            fprintf(fId , ' %12.5f', smapeTrain );                               
            fprintf(fId , ' %12.5f', rmseValH2Forecast  );
            fprintf(fId , ' %12.5f', smapeValH2Forecast );                               
            fprintf(fId , ' %12.5f', rmseTeH2Forecast   );
            fprintf(fId , ' %12.5f', smapeTeH2Forecast  );                               

            fprintf(fId , '\n');

        end
        fclose(fId);

    end
    
end

%%  SAVE OUTPUT DATA INTO A MAT FILE    ========================================================
% nets4TSF_DataList( iTs, iExp )
% netTrainedList{ iTs, iExp }
% parametersList( iTs, iExp )

dateStr = datestr(now,'yyyy_mm_dd_HH_MM');
filenameExpResults = strcat('expResults','_',dateStr);
fullfilenameExpResults = fullfile( folderResults , filenameExpResults);
save(fullfilenameExpResults, 'nets4TSF_DataList' , 'netTrainedList' , 'parametersList' );





% ----------------------------------------------------------------------------------------------
% Print ALL THE RESULTS TOGETHER:


fprintf('\n\nTotal Execution Time: %10.3f s\n\n',toc(initTotalExecTime)); clear initTotalExecTime;