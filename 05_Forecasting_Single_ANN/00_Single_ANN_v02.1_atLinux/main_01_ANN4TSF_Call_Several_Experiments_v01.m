 %% LINKS  ----------------------------------------------------------
% https://icme.hpc.msstate.edu/mediawiki/index.php/MATLAB_Tutorials
% http://datos.gob.es/recurso/sector-publico/org/Organismo/L01280796
%    Calidad del aire. Tiempo real
%    http://datos.madrid.es/egob/catalogo/212531-7916318-calidad-aire-tiempo-real.txt

%% RESET      ==========================================================================
clear; clc; close all; fclose('all');
%% DEBUGGUING ?
parameters.debugging    = 0;   % 0/1/2

%% SET FOLDERs, PATH and FILEPREFIX and FILENAME     ============================================================
cd( fileparts( mfilename( 'fullpath' ) ) );    % does not work if executed by Run Section [and advance]

parameters.folderFunctions       = fullfile( fileparts(mfilename('fullpath')),'Functions');
parameters.tsFolder              = fullfile( fileparts(mfilename('fullpath')),'TimeSeries_Pollution');
parameters.folderFactorLevelComb = fullfile( fileparts(mfilename('fullpath')),'TablesFactorsAndLevels');
parameters.folderFigures         = fullfile( fileparts(mfilename('fullpath')),'Figures');
parameters.folderResults         = fullfile( fileparts(mfilename('fullpath')),'Results');
parameters.tsOriginalDataFileRoots

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
% FORECASTING HORIZON ------------------
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


% -------------------------------------
% TYPES OF TIME SERIES
parameters.tsTypesCellArray = { 'raw', 'dif' , 'inc' };
%parameters.tsTypesCellArray = { 'inc' };


% -------------------------------------
% NUMBER OF INITIALIZATIONS 
if     ( parameters.debugging == 2 )
    parameters.numInitializations = 3;

elseif ( parameters.debugging == 1 )
    parameters.numInitializations = 3;

elseif ( parameters.debugging == 0 )
    % parameters.numInitializations = 5;
    parameters.numInitializations = 10;    
end
% -------------------------------------
% FACTOR LEVEL COMBINATIONS FILE 
        % 0 (default value) => 'factorLevelsTable_Pollution_Tinny.txt'   
        % 1                 => 'factorLevelsTable_Pollution_L50_v01.txt'; 
        % 2                 => 'factorLevelsTable_Pollution_StepWise_short.txt'
        % 3                 => 'factorLevelsTable_Pollution_StepWise.txt'
        % 4                 => 'factorLevelsTable_Pollution_FullFactorial.txt' 
parameters.FLCombinations = 3;  

% TRAIN VALIDATION and TEST Subsets PARAMETERS ----------------
parameters.SplitPatternSetByPrctg = false; % false <--> logical(0)
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
parameters.max_fail_TrainCyclesPrct = 20;

% --------------------------------------------------------------------------------------


% FACTOR LEVEL COMBINATIONS ===================================================

% strFLCom = 'L16x2_v01'; parameters.fileFactorLevelCombination = strcat('factorLevelsTable_Pollution_',strFLCom,'.txt');  % FOR IWANN2017  
% strFLCom = 'FF_v01';    parameters.fileFactorLevelCombination = strcat('factorLevelsTable_Pollution_',strFLCom,'.txt');  % FOR IWANN2017  + FULL FACTORIAL
% strFLCom = 'Tinny';     parameters.fileFactorLevelCombination = strcat('factorLevelsTable_Pollution_',strFLCom,'.txt');
% ------------------------------------
% Factor Level Combinations File (step 01)
switch parameters.FLCombinations
    case 0
        strFLCom = 'Tinny';
    case 1
        strFLCom = 'L50_v01';
    case 2    
        strFLCom = 'StepWise_short';
    case 3
        strFLCom = 'StepWise';
    case 4 
        strFLCom = 'FullFactorial';
end
parameters.fileFactorLevelCombination = strcat('factorLevelsTable_Pollution_',strFLCom,'.txt');
    

% Factor Level Comb Folder and Files  (step 02 ) ----------------------------------------------
parameters.fileFactorLevelCombination =  fullfile( parameters.folderFactorLevelComb, ... 
                                                   parameters.fileFactorLevelCombination); 


% --------------------------------------------------------------------------------------
% NAMES OF THE TIME SERIES   ===========================================================

% 2016 (academic time series)
%{
    tsOriginalDataFileRoots = {'Dowjones', ...
                               'Mackeyglass01', ... 
                               'Quebec', ... 
                               'Temperature'};
%}
% 2017 - 07  PC_xx_SC_xxxxxxxx_D/H_F03.dat
%{
    tsOriginalDataFileRoot  = 'PC_08_SC_28079050_D_F03'; 
    tsOriginalDataFileRoots = {'PC_08_SC_28079050_D_F03' , 'PC_09_SC_28079050_D_F03'};

    tsOriginalDataFileRoots = {'PC_08_SC_28079050_D_F03', ...
                               'PC_09_SC_28079050_D_F03', ... 
                               'PC_08_SC_28079056_D_F03', ... 
                               'PC_14_SC_28079056_D_F03'};
                             
                             
                                % ts_PC_08_SC_28079050_D_F03.dat
                                % ts_PC_08_SC_28079056_D_F03.dat
                                % ts_PC_09_SC_28079050_D_F03.dat
                                % ts_PC_14_SC_28079056_D_F03.dat
                                % 
                                % ts_PC_08_SC_28079050_H_F03.dat
                                % ts_PC_08_SC_28079056_H_F03.dat
                                % ts_PC_09_SC_28079050_H_F03.dat
                                % ts_PC_14_SC_28079056_H_F03.dat

    % filenamesInitData  = {  'ts_PC_08_SC_28079050_D_F03.dat';...
    %                         'ts_PC_08_SC_28079056_D_F03.dat';...
    %                         'ts_PC_09_SC_28079050_D_F03.dat';...
    %                         'ts_PC_14_SC_28079056_D_F03.dat'};
 
    % tsnames  = {'PC_08_SC_28079050_D_F03';...
    %             'PC_08_SC_28079056_D_F03';...
    %             'PC_09_SC_28079050_D_F03';...
    %             'PC_14_SC_28079056_D_F03'};
       
 
    % filenamesInitData  = {  'ts_PC_08_SC_28079050_H_F03.dat';...
    %                         'ts_PC_08_SC_28079056_H_F03.dat';...
    %                         'ts_PC_09_SC_28079050_H_F03.dat';...
    %                         'ts_PC_14_SC_28079056_H_F03.dat'};
 
    % tsnames  = {'PC_08_SC_28079050_H_F03';...
    %             'PC_08_SC_28079056_H_F03';...
    %             'PC_09_SC_28079050_H_F03';...
    %             'PC_14_SC_28079056_H_F03'};
%}

% NAMES OF THE TIME SERIES 2017 - 11  

if ( parameters.debugging == 2 )
    parameters.tsOriginalDataFileRoots = {'NO2-FedzLadreda-16-12'};
    % parameters.tsOriginalDataFileRoots       = {'NO2-FedzLadreda-16-12', ...
    %                                             'NO2-PzCastilla-16-10' , };
                                      
elseif ( parameters.debugging == 1 )
    parameters.tsOriginalDataFileRoots = {  'NO2-FedzLadreda-16-12', ...
                                            'NO2-PzCastilla-16-10',...
                                            'O3-JuanCarlosI-16-07', ... 
                                            'PM25-MendezAlvaro-16-10'};
  
elseif ( parameters.debugging == 0 )
    parameters.tsOriginalDataFileRoots = { 'NO2-FedzLadreda-16-12', ...
                                           'NO2-PzCastilla-16-10', ... 
                                           'O3-JuanCarlosI-16-07', ... 
                                           'PM25-MendezAlvaro-16-10'};


end



                            
                             
% Note: the name of the time series will be: 
%        ts-tsOriginalDataFileRoots{i}.csv                             
%        ts-tsOriginalDataFileRoots{i}-raw.csv                             
%        ts-tsOriginalDataFileRoots{i}-dif.csv                             
%        ts-tsOriginalDataFileRoots{i}-ind.csv                             

%% PARAMETERS FOR EXECUTION AND DEBUG  ===========================================================

% --------------
parameters.parallelWork = 1;   % parallelWork = 1; 
parameters.GpuWork      = 0;   % GpuWork      = 1; 

% --------------
parameters.trainParam.showWindow      = 0;  % To see the window for learning process
parameters.trainParam.showCommandLine = 1;  % To see the learning process in the command line
parameters.showTrainRecord            = 1;  % To see the figure for error through learning process

% -----------------
% To be able to get different seed for random number generation
parameters.waitingTime  = 0.03; % 

 


% RESULTS FOLDERS ------------------------------------------------------------------------------
    
switch parameters.FLCombinations
    case 0
        strFLCom = 'Tinny';
    case 1
        strFLCom = 'L50_v01';
    case 2
        strFLCom = 'StepWise';
    case 3 
        strFLCom = 'FullFactorial';
end

parameters.folderAllResults             = strcat('Results_',strFLCom,'_ALL');
parameters.resultsFolderPrefix          = strcat('Results_',strFLCom,'_');


% ---------------------------------------

 %% PARALELL TOOLBOX 
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


%% 
initTotalTime = tic; 
% func_02_executeExperiments_ANN4TS_v03( parameters ,  fileFactorsLevelsCombination , tsOriginalDataFileRoots  ); 
expResults = func_02_executeExperiments_ANN4TS_v04( parameters, ...
                                                    parameters.fileFactorLevelCombination, ...
                                                    parameters.tsOriginalDataFileRoots); 
fprintf('\n\ntotal time : %d s\n',toc(initTotalTime)); clear initTotalTime;