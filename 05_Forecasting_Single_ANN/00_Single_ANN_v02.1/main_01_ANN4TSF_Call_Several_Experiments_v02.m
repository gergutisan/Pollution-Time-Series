 %% LINKS  ----------------------------------------------------------
% https://icme.hpc.msstate.edu/mediawiki/index.php/MATLAB_Tutorials
% http://datos.gob.es/recurso/sector-publico/org/Organismo/L01280796
%    Calidad del aire. Tiempo real
%    http://datos.madrid.es/egob/catalogo/212531-7916318-calidad-aire-tiempo-real.txt

%% RESET      ==========================================================================
clear; clc; close all; fclose('all');

%% SET FOLDERs, PATH and FILEPREFIX and FILENAME     ============================================================
cd( fileparts( mfilename( 'fullpath' ) ) );    % does not work if executed by Run Section [and advance]

parameters.folderFunctions       = fullfile( fileparts(mfilename('fullpath')),'Functions');

parameters.tsFolder              = fullfile( fileparts(mfilename('fullpath')),'TimeSeries_Pollution');

parameters.folderFactorLevelComb = fullfile( fileparts(mfilename('fullpath')),'TablesFactorsAndLevels');
parameters.folderFigures         = fullfile( fileparts(mfilename('fullpath')),'Figures');
parameters.folderResults         = fullfile( fileparts(mfilename('fullpath')),'Results');


% ADDING TO PATH ---------------------------
% This is too slow: path( folder2Add2Path , path );
% Faster option to add to the path: function addpath
addpath(    parameters.folderFunctions  , ...
            parameters.tsFolder , ...
            parameters.folderFigures    , ...
            parameters.folderResults    , ...
            parameters.folderFactorLevelComb);

% -----------------
parameters.folderAllResults             = 'Results_ALL';
parameters.resultsFolderPrefix          = 'Results_';
parameters.resultsFilesPrefix           = 'results_'; 
parameters.fileExtensionResults         = 'dat';
parameters.fileExtensionResultsBinary   = 'mat';
parameters.tsFilesPrefix                = 'ts-';
parameters.tsFilesExtension             = 'csv';
parameters.filesOfResGenComplete        = '00_results_all.dat'; 
parameters.filesOfResGenCompleteMat     = 'expResultsAll.mat'; 
parameters.logFilePrefix                = 'aa_execlogFile_';        
        
%% PARAMETERS FOR EXPERIMENTATION   ===============================================================
% -------------------------------------
% FORECASTING HORIZON
% parameters.ForecastHorizon    = 1;   % => number of forecasted values generated 
parameters.ForecastHorizon    = 24;   % => number of forecasted values generated 

% -------------------------------------
% FORECASTING OUTPUT 
parameters.ForecastOutput     = 1;   % => i.e. number of ANN (or model) output

% -------------------------------------
% USING Predicted vs Real Values for the next step within forecast horizon
% THIS PARAMETER IS NOT NEEDED because the system computes both options
% parameters.usingPredictedOrReal = 1; % => 1: using predicted value ; 2: using real values  

% -------------------------------------
% TRANSFER FUNCTION OF EACH NEURON
parameters.transferFcn  = 'tansig';

% --------------------------------------------
% TRAIN VALIDATION and TEST Subsets PARAMETERS 
parameters.SplitPatternSetByPrctg    = false; % false <--> logical(0)
parameters.SplitPatternSetByElements = ~(parameters.SplitPatternSetByPrctg); 

if parameters.SplitPatternSetByPrctg 
    parameters.trainPrctg   = 70;
    parameters.valPrctg     = 15;
    parameters.testPrctg    = 100 - parameters.valPrctg - parameters.trainPrctg;
    
elseif (parameters.SplitPatternSetByElements)
    parameters.trainElements   = -1; % This cannot be known till reading the time series data file
    parameters.valElements     = parameters.ForecastHorizon;
    parameters.testElements    = parameters.ForecastHorizon;
else 
    % ERROR 
    fprintf('\n -- ERROR defining the Program parameters for TRAIN VALIDATION and TEST Subsets PARAMETERS -- \n')
end

% ---------------------------------------------
% EARLY STOPPING  
% note: early stopping is the default set in network creation functions,
%       even for feedforwardnet
%       There is no straightforward way to avoid (switch off) the early stoping 
%       To do so, it needs to set to 0 (empty) the validation and test subset
parameters.earlyStopping            = 1; 
parameters.max_fail_TrainCyclesPrct = 100;  % If 100% train till the max number of cycles, 
                                            % but get the weight for the best error ...
% ---------------------------------------------                                            
% REGULARIZATION
% net.performParam.regularization
% 'trainlm'   - Levenberg-Marquardt optimization, fastest backpropagation alg in the toolbox
% parameters.regularization = 1;
% Up to this version the is not applaied because for large networks it takes a lot of time

% ---------------------------------------------
% NORMALIZATION  
% net.performParam.normalization 
% parameters.normalization = 0; 
% Normalization is when you have several output which value ranges are different
% In univariate time series forecating with ANN, normalization (in the ANN outputs are not needed)

%% PARAMETERS FOR EXPERIMENTATION  THAT DEPENDS on DEBUG LEVEL

% -------------------------------------
% DEFAULTS VALUES 
% NUMBER OF INITIALIZATIONS  
parameters.numInitializations = 1; % 1, 3, 5, 10
% FACTOR LEVEL COMBINATIONS FILE 
        % 0 (default value) => 'factorLevelsTable_Pollution_Tinny.txt'   
        % 1                 => 'factorLevelsTable_Pollution_L50_v01.txt'; 
        % 2                 => 'factorLevelsTable_Pollution_StepWise_short.txt'
        % 3                 => 'factorLevelsTable_Pollution_StepWise.txt'
        % 4                 => 'factorLevelsTable_Pollution_FullFactorial.txt' 

parameters.FLCombinations = 0;  % 0, 1, 2, 3, 4

% TYPES OF TIME SERIES
parameters.tsTypesCellArray = { 'raw' };
% parameters.tsTypesCellArray = { 'raw', 'dif' , 'inc' };
% ---------------------------------------------------
% NAMES OF THE TIME SERIES 
% Note: the name of the time series will be: 
%        ts-tsOriginalDataFileRoots{i}.csv                             
%        ts-tsOriginalDataFileRoots{i}-raw.csv                             
%        ts-tsOriginalDataFileRoots{i}-dif.csv                             
%        ts-tsOriginalDataFileRoots{i}-ind.csv                             

% ----------------------------------------
% VALUES SET DEPENDING ON DEBUG LEVEL
%% DEBUGGUING ?
parameters.debugging    = 'D_1003';   % done (but needs to be reviewd)
% parameters.debugging    = 'D_1002';   % done (but needs to be reviewd)
% parameters.debugging    = 'D_1001';   % done (but needs to be reviewd)
% parameters.debugging    = 'D_1000';   % done (but needs to be reviewd)

% parameters.debugging    = 'D_0103';   % done (but needs to be reviewd)
% parameters.debugging    = 'D_0102';   % done (but needs to be reviewd)
% parameters.debugging    = 'D_0101';   % done (but needs to be reviewd)

% parameters.debugging    = 'D_0000';   % done (but needs to be reviewd)

parameters.debugging    = 'D_A02_0003';   % done (but needs to be reviewd)



switch parameters.debugging
    
    % -----------------------------------------------------------------------
    
    case 'D_1003'
        parameters.numInitializations = 1;
        parameters.FLCombinations = 0;
        parameters.tsTypesCellArray = { 'raw' };
        parameters.tsOriginalDataFileRoots = {'NO2-FedzLadreda-16-12'};
    case 'D_1002'
        parameters.numInitializations = 1;
        parameters.FLCombinations = 0;
        parameters.tsTypesCellArray = { 'raw'};
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...   
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};
    case 'D_1000'
        parameters.numInitializations = 1;
        parameters.FLCombinations = 0;
        parameters.tsTypesCellArray = { 'raw' , 'dif', 'inc' };
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};
    % -----------------------------------------------------------------------    
    case 'D_0103'
        parameters.numInitializations = 1;
        parameters.FLCombinations = 0;
        parameters.tsTypesCellArray = { 'raw' , 'dif', 'inc' };
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};        

    case 'D_0102'
        parameters.numInitializations = 1;
        parameters.FLCombinations = 1;
        parameters.tsTypesCellArray = { 'raw' , 'dif', 'inc' };
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};     

    case 'D_0101'
        parameters.numInitializations = 1;
        parameters.FLCombinations = 3;
        parameters.tsTypesCellArray = { 'raw' , 'dif', 'inc' };
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};  
    case 'D_0100'
        parameters.numInitializations = 1;
        parameters.FLCombinations = 4;
        parameters.tsTypesCellArray = { 'raw' , 'dif', 'inc' };
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};                                              
    % -----------------------------------------------------------------------                                            
    case 'D_0012'
        parameters.numInitializations = 5;
        parameters.FLCombinations = 1;
        parameters.tsTypesCellArray = { 'raw' , 'dif', 'inc' };
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};  

    case 'D_0011'
        parameters.numInitializations = 5;
        parameters.FLCombinations = 3;
        parameters.tsTypesCellArray = { 'raw' , 'dif', 'inc' };
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};  
                                            
    case 'D_0010'
        parameters.numInitializations = 5;    
        parameters.FLCombinations = 4;  
        parameters.tsTypesCellArray = { 'raw'};
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};

    % -----------------------------------------------------------------------                                            
    case 'D_0000'
        parameters.numInitializations = 10;    
        parameters.FLCombinations = 4;  
        parameters.tsTypesCellArray = { 'raw' , 'dif', 'inc' };
        % parameters.tsTypesCellArray = { 'inc' };
        parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                                'NO2-PzCastilla-16-10',...
                                                'O3-JuanCarlosI-16-07', ... 
                                                'PM25-MendezAlvaro-16-10'};
                                            
    % ============================================================================
    % ============================================================================
    case 'D_A02_0003'
        parameters.tsFolder           = fullfile( fileparts( mfilename('fullpath') ), ... 
                                                           'TimeSeries_Academic_02' );
        addpath( parameters.tsFolder );
        
        parameters.numInitializations = 10;
        parameters.FLCombinations     = 5;
        parameters.tsTypesCellArray   = { 'raw' , 'dif', 'inc' };
        parameters.tsOriginalDataFileRoots = {  '01-international-airline-passengers' , ...
                                                '02-annual-common-stock-price-us-187' , ...
                                                '03-annual-flows-colorado-river-lees' , ...
                                                '04-weekly-closings-of-the-dowjones'  , ...
                                                '05-monthly-av-residential-electrici' , ...
                                                '06-ibm-common-stock-closing-prices'  , ...
                                                '07-monthly-lake-erie-levels-1921-19' , ...
                                                '08-annual-number-of-lynx-trapped-ma' , ...
                                                '10-monthly-shipment-of-pollution-eq' , ...
                                                '11-monthly-australian-wine-sales-th' , ...
                                                '12-wolfs-sunspot-numbers-1700-1988'  , ...
                                                '13-accidental-deaths-in-usa-monthly' };
                                            
end

% -----------------------------------------------------------------------------
% FACTOR LEVEL COMBINATIONS 
% Depends on one of the parameters that depend on debug level

% strFLCom = 'L16x2_v01'; parameters.fileFactorLevelCombination = strcat('factorLevelsTable_Pollution_',strFLCom,'.txt');  % FOR IWANN2017  
% strFLCom = 'FF_v01';    parameters.fileFactorLevelCombination = strcat('factorLevelsTable_Pollution_',strFLCom,'.txt');  % FOR IWANN2017  + FULL FACTORIAL
% strFLCom = 'Tinny';     parameters.fileFactorLevelCombination = strcat('factorLevelsTable_Pollution_',strFLCom,'.txt');
% ------------------------------------
% Factor Level Combinations File (step 01)
switch parameters.FLCombinations
    case 0
        strFLCom = 'Pollution_Tinny';
    case 1
        strFLCom = 'Pollution_L50_v01';
    case 2    
        strFLCom = 'Pollution_StepWise_short';
    case 3
        strFLCom = 'Pollution_StepWise';
    case 4 
        strFLCom = 'Pollution_FullFactorial';
    case 5 
        strFLCom = 'AcademicTS_FFv05';
        % strFLCom = 'AcademicTS_FFv05_1';
        
    
end
parameters.fileFactorLevelCombination = strcat('factorLevelsTable_',strFLCom,'.txt');
% Factor Level Comb Folder and Files  (step 02 ) ----------------------------------------------
parameters.fileFactorLevelCombination =  fullfile( parameters.folderFactorLevelComb, ... 
                                                   parameters.fileFactorLevelCombination); 
% Results Folders    ----------------------------------------------

% OLD 
% parameters.folderAllResults    = strcat('Results_',strFLCom,'_ALL');
% parameters.resultsFolderPrefix = strcat('Results_',strFLCom,'_');

% Get the date and time as an string
delimiterChar = '_';
strDateTime = getDateTimeAsString ( delimiterChar );  clear delimiterChar
fprintf('\n\n --> subString %s \n' , strDateTime );  % for debugging purposes

strDebug = parameters.debugging;
parameters.folderAllResults     = char(  strcat('Results_', strDebug, '_', strFLCom ,'_' , strDateTime,'_ALL') );
parameters.resultsFolderPrefix  = char ( strcat('Results_', strDebug, '_', strFLCom ,'_' , strDateTime,'_') );
parameters.resultsFolderPrefix2 = char ( strcat('Results_', strDebug, '_', strFLCom ,'_' ) );

clear delimiterChar strDateTime

%% PARAMETERS FOR EXECUTION AND DEBUG  ====================================================
% --------------
parameters.parallelWork = 1;   % parallelWork = 1; 
parameters.GpuWork      = 0;   % GpuWork      = 1; 
% --------------
% Visualizing Data and Figures
parameters.trainParam.showWindow      = 0;  % To see the window for learning process
parameters.trainParam.showCommandLine = 0;  % To see the learning process in the command line
parameters.showTrainRecord            = 1;  % To see the figure for error through learning process
parameters.showOnScreen               = 0;  % To see on screen some info
parameters.figVisible                 = 'off'; % 'on' To visualize or not the figure when it is created with figure + plotting 
% -----------------
% To be able to get different seed for random number generation
parameters.waitingTime  = 0.03; % 
% ---------------------------------------

%% PARALELL TOOLBOX  =====================================================================
fprintf('\nCheck Parallel Poll \n');
% --------------------------------
%parameters.parallelWork = 0;  % parameters.parallelWork = 1; 

if ( parameters.parallelWork == 1 )
    % delete(gcp('nocreate'));    % delete(gcp)

    p = gcp('nocreate');
    if isempty(p)
        % WINDOWS
        % parpool('local',2);  % parpool(2) 
        % JUNO -> Linux
        % parpool('local',16); % parpool(16) 
        % GENERAL
        presentCluster  = parcluster();
        nWorkersMax     = presentCluster.NumWorkers;
        % ---------------------------------------        
        % nWorkers = fix( nWorkersMax * 0.7 );
        % nWorkers = ceil( nWorkersMax * 1 );
        nWorkers = nWorkersMax;        

        parpool( 'local' , nWorkers ); 
    else
        nWorkers = p.NumWorkers;
    end

    fprintf( '\nnWorkers: %d\n' , nWorkers );

    % ---------------------------------------
    % if nWorkers <= 12 
    %    parpool('local',nWorkers); 
    % else
    %    % parpool('local',nWorkers); 
    %    parpool('local',nWorkers - 1);         
    % end
elseif ( parameters.parallelWork == 0 )
    delete(gcp('nocreate'));
end


%% EXECUTING EXPERIMENTS ANNs for TIME SERIES FORECASTING
initTotalTime = tic; 

% func_02_executeExperiments_ANN4TS_v03( parameters ,  fileFactorsLevelsCombination , tsOriginalDataFileRoots  ); 
expResults = func_02_executeExperiments_ANN4TS_v04( parameters, ...
                                                    parameters.fileFactorLevelCombination, ...
                                                    parameters.tsOriginalDataFileRoots); 

fprintf('\n\n--> Total time: %d s\n',int64( toc(initTotalTime) ) ); clear initTotalTime;

%% MOVING THE RESULTS --------------
%  to the folder for Results
movefile( strcat( parameters.resultsFolderPrefix2 , '*' ) , 'Results', 'f');