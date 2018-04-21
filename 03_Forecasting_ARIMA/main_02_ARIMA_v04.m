 %% RESET;
clearvars -EXCEPT pollutionData_daily pollutionData_hourly % to be faster while debugging
clc; close('all'); fclose('all');
% clear; close('all'); fclose('all'); % NO clear screen

% Delete Previous pdf files
% folder = 'Figures'; %delete(strcat(folder ,'\*.pdf')); clear folder

%% SET STRUCT OF PARAMETERS      ============================================================

% SHOWING FIGURES
parameter.showScatterLag    = 1;  % 0/1
parameter.showTsAcfPacf     = 1;  % 0/1
paramenter.preProcessTSData = 1;  % 0/1
parameter.showTsTRansformed = paramenter.preProcessTSData;  % 0/1

parameter.showTrainValTest  = 1;  % 0/1
parameter.showValTest       = 1;  % 0/1

parameter.showModelResidual             = 1;  % 0/1
parameter.showModelTrainValTestForecast = 1;  % 0/1
parameter.showModelValTestForecast      = 1;  % 0/1

% SAVING FIGURES
parameter.savingFiguresTS  = 0;  % for train,val,test ... ACF+PAFC, etc
parameter.savingFiguresTSF = 0;  % for forecast results 

% TRAIN VALID TEST 
parameter.prctTrain = 0.70;
parameter.prctValid = 0.15; 
% prctTest = 1 - prctTrain - prctValid

%% Set Matlab(R) initial path ===================================================
%restoredefaultpath 
%clear RESTOREDEFAULTPATH_EXECUTED;

%% PAHT & FOLDERS    ============================================================
% note: mfilename('fullpath')   does not work, up to now (2017 nov -Matlab 2017b)  
% in Live scripts
pwd; 
% SET FOLDER (functions, figures, time sereis)

% folderFunctions  = '\Functions';
% folderTimeSeries = '\TimeSeries';
% folderFigures    = '\Figures';

%cd(fileparts(mfilename('fullpath')))    % does not work if executed by Run Section [and advance]
%folderFunctions  = strcat( fileparts(mfilename('fullpath')),'\Functions');
%folderTimeSeries = strcat( fileparts(mfilename('fullpath')),'\TimeSeries');
%folderFigures    = strcat( fileparts(mfilename('fullpath')),'\Figures');

folderFunctions  = strcat( pwd,'\Functions');
folderTimeSeries = strcat( pwd,'\TimeSeries');
folderFigures    = strcat( pwd,'\Figures');

oldpath = path; path(folderFunctions,oldpath)
oldpath = path; path(folderTimeSeries,oldpath)
oldpath = path; path(folderFigures,oldpath)
clear oldpath;
% --------------------------------------------------------------------------------

%% COMPUTATION STEPS ============================================================
%
computationSteps = [1 1];   
        % first  value (1/0) for analysis: TS,ACF, PACF, [ SCATTER PLOTS ]
        % second value (1/0) to set/fit and forecast the ARIMA MODEL

%% SET LOCAL PARAMETERS
% showTsTRansformed = 0;  % 0/1
% showScatterLag    = 0;  % 0/1
% showTsAcfPacf     = 0;  % 0/1
% 
% showTrainValTest  = 0;  % 0/1
% showValTest       = 0;  % 0/1
% 
% showModelResidual = 0;  % 0/1
% showModelForecast = 0;  % 0/1

showScatterLag    = parameter.showScatterLag;
showTsAcfPacf     = parameter.showTsAcfPacf;

preProcessTSData  = paramenter.preProcessTSData;
showTsTRansformed = parameter.showTsTRansformed;

showTrainValTest  = parameter.showTrainValTest;
showValTest       = parameter.showValTest;

showModelResidual             = parameter.showModelResidual;
showModelTrainValTestForecast = parameter.showModelTrainValTestForecast;
showModelValTestForecast      = parameter.showModelValTestForecast;

savingFiguresTS    = parameter.savingFiguresTS;    % for train,val,test ... ACF+PAFC
savingFiguresTSF   = parameter.savingFiguresTSF ;  % for forecast results 

%% LOAD DATA EXAMPLE 1 (Examples from economics Toolbox)            =============
% 
% 1.- DATA: Examples from economics Tool box
% % -----------------------------------------------
% tsFilename = 'Data_Airline.mat'; 
% tsName     = tsFilename( 6:(numel(tsFilename) - 4 ) ); % Airline
% load(fullfile(matlabroot,'examples','econ',tsFilename));
% Constant = 1; D = 1; Seasonality = 12; MALags = 12; SMALags = 12;
% setARIMAOpt = 2;

% -----------------------------------------------
% tsFilename = 'Data_Accidental.mat';   
% tsName     = tsFilename( 6:(numel(tsFilename) - 4 ) ); % Airline
% load(fullfile(matlabroot,'examples','econ',tsFilename));
% Constant = 1; D = 1; Seasonality = 12; MALags = 12; SMALags = 12;
% setARIMAOpt = 2;

% % -----------------------------------------------
% tsFilename = 'Data_PowerConsumption';   
% tsName     = tsFilename( 6:(numel(tsFilename) - 4 ) );
% load(fullfile(matlabroot,'examples','econ',tsFilename));
% % Constant = 1; D = 0; Seasonality = 1; MALags = 3; SMALags = 0;
% p = 1; D = 2; q = 0;
% setARIMAOpt = 1;
% Data = Data(:,2); % Data = Data(:,3); Data = Data(:,4);

% % -----------------------------------------------
% tsFilename = 'Data_Overshort';   
% tsName     = tsFilename( 6:(numel(tsFilename) - 4 ) );
% load(fullfile(matlabroot,'examples','econ',tsFilename));
% % Constant = 1; D = 1; Seasonality = 12; MALags = 24; SMALags = 24;
% p = 4; D = 0; q = 3;
% setARIMAOpt = 1;

%% LOAD DATA EXAMPLE 2 (Examples from Madrid pollution data)        ============
% 2.- DATA: load DATA FROM MADRID POLLUTION DATA
%
% % LOAD WHOLE DATA and seve it in a cell array --- 
%  
% tsInfoCellArray = {"NO2" , "NO2" ,"NO2" ,"NO2" ,...
%                    "PM25" ,"PM25" ,"O3" ,"O3" ,};                
% 
% filenameTS = {'ts-PC-08-SC-47-H-pproc.dat' , ... 
%               'ts-PC-08-SC-50-H-pproc.dat' , ...
%               'ts-PC-08-SC-56-H-pproc.dat' , ...
%               'ts-PC-08-SC-59-H-pproc.dat' , ...
%               'ts-PC-09-SC-47-H-pproc.dat' , ...
%               'ts-PC-09-SC-50-H-pproc.dat' , ...
%               'ts-PC-14-SC-56-H-pproc.dat' , ...
%               'ts-PC-14-SC-59-H-pproc.dat' };          
% 
% % NO2FdzLadreda          
% % tsFilename = 'ts_PC_08_SC_56_H_pproc.dat'; 
% tsFilename = filenameTS{3}; 
% tsName     = tsFilename( 4:(numel(tsFilename) - 12 ) );        
% Data       = load( strcat( folderTimeSeries, '\', tsFilename) );
% Constant = 1; D = 1; Seasonality = 12; MALags = 12; SMALags = 12;
% setARIMAOpt = 2;

%---------------------------------------------------------

%% LOAD DATA EXAMPLE 3 ([More] Examples from Madrid pollution data )  ==========
% tsInfoCellArray = {"NO2" , "NO2" ,"NO2" ,"NO2" ,...
%                    "PM25" ,"PM25" ,"O3" ,"O3" ,};                
% 
% filenameTS = {'ts-PC-08-SC-47-16-08.dat' , ... 
%               'ts-PC-08-SC-50-16-08.dat' , ...
%               'ts-PC-08-SC-56-16-08.dat' , ...
%               'ts-PC-08-SC-59-16-08.dat' , ...
%               'ts-PC-09-SC-47-16-08.dat' , ...
%               'ts-PC-09-SC-50-16-08.dat' , ...
%               'ts-PC-14-SC-56-16-08.dat' , ...
%               'ts-PC-14-SC-59-16-08.dat' };
% 
% nY = 16; nM = 08; % data not needed

%% LOAD DATA EXAMPLE 4 ([More] Examples from Madrid pollution data )  ==========
% 4.- DATA: LOAD DATA FROM MADRID POLLUTION DATA: 2016 - 11 -----------------------------------------------------
%
tsInfoCellArray = {"NO2" , "NO2" ,"O3", "PM25" };                

filenameTS = {'ts-NO2-FedzLadreda-16-12.csv'  , ... 
              'ts-NO2-PzCastilla-16-10.csv'   , ...
              'ts-O3-JuanCarlosI-16-07.csv'   , ...
              'ts-PM25-MendezAlvaro-16-10.csv'};
              
% tsNames =  {'NO2-FedzLadreda-16-12', ... 
%             'NO2-PzCastilla-16-10' , ...
%             'O3-JuanCarlosI-16-07' , ...
%             'PM25-MendezAlvaro-16-10'};          
% nY = 16; nM = 11; % data not needed    

%% SETTING THE tsName [cell] Array   ===================================================
for i = 1:numel( filenameTS )

    strName    = filenameTS{i};
    nChar      = numel( filenameTS{i} );
    tsNames{i} = strName(4:(nChar-4));

end
clear nChar;

%% CLEAR FOLDER for FIGURES (moving automatically its content)
% 
%moveFolderContent2Backup(folderFigures);
%delete(strcat(folderFigures,'\','*.pdf'));

%% (ANALYSIS AND MODEL OF EACH OF THE TIME SERIES) ===========================================
% ============================================================================================
% 
% |      ANALYSIS, AND MODEL OF EACH OF THE TIME SERIES|
% 
% ============================================================================================ 
% ============================================================================================

%% LOOP FOR EACH OF THE TIME SERIES OF THE STUDY
%for indexTs = 1:numel(filenameTS)
%for indexTs = 1:1
%for indexTs = 2:2
%for indexTs = 3:3
%for indexTs = 4:4
for indexTs = 1:4
        
    close('all'); fclose('all');
    
    % File and tsName of the time series -------------------------------------------
    % NO2FdzLadreda  % tsFilename = 'ts_PC_08_SC_56_H_pproc.dat'; 
                     % tsFilename = 'ts-NO2-FedzLadreda-16-12.csv'
    
    tsFilename = filenameTS{indexTs}; 
    tsName     = tsNames{indexTs};   % tsName     = tsFilename( 4:(numel(tsFilename) - 4 ) ); 
    
    % LOADING THE DATA                  -------------------------------------------- 
    Data       = load( strcat( folderTimeSeries, '\', tsFilename) );
    
    % Init ( Null ) values for ARIMA Model
    Constant = 1;
    p = 0; D = 0; q = 0;
    Seasonality = 0;
    MALags      = 0;
    SMALags     = 0;
    
    %  SET THE MODEL TO BE ESTIMATED ---------------------------------------------
    setARIMAOpt = 0;
    switch tsName
        case 'NO2-FedzLadreda-16-12'
            %Constant = 1; 
            D = 0; 
            Seasonality = 24; %MALags = 24; SMALags = 24;
            %Seasonality = 48; MALags = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24]; SMALags = 20;
            %Seasonality = 24; MALags = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]; SMALags = 2;
            %Seasonality = 24; MALags = 24; SMALags = 24;
            %setARIMAOpt = 2; 
            
            %p = 24; D = 1; q = 24;
            p = 48; D = 1; q = 3;
            setARIMAOpt = 1;
        
        case 'NO2-PzCastilla-16-10'
            Constant = 1; D = 0; 
            %Seasonality = 24; MALags = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]; SMALags = 24;
            %setARIMAOpt = 2; 
            
            p = 24; D = 0; q = 3;
            setARIMAOpt = 1;
        
        case 'O3-JuanCarlosI-16-07'
            %Constant = 1; D = 1; Seasonality = 24; MALags = 24; SMALags = 24;
            %setARIMAOpt = 2; 
            
            p = 24; D = 0; q = 0;
            setARIMAOpt = 1;
        
        case 'PM25-MendezAlvaro-16-10'
            %Constant = 1; D = 0; Seasonality = 24; MALags = 24; SMALags = 24;
            %setARIMAOpt = 2; 
            
            p = 24; D = 0; q = 2;
            setARIMAOpt = 1;
    end
    
    % PRINT THE PARAMETERS
    fprintf('\n\n-----------------------------\n');
    fprintf('%s\n',tsName);
        
    fprintf('%15s : ', 'p');
    fprintf('%3d  '  ,  p );fprintf('\n')
    
    fprintf('%15s : ', 'D');
    fprintf('%3d  '  ,  D );fprintf('\n')
    
    fprintf('%15s : ', 'q');
    fprintf('%3d  '  ,  q );fprintf('\n')
    
    fprintf('%15s : ', 'Seasonality');
    fprintf('%3d  '  ,  Seasonality );fprintf('\n')
    
    fprintf('%15s : ', 'MALags');
    fprintf('%3d  ',  MALags );     fprintf('\n')
    
    fprintf('%15s : ', 'SMALags')
    fprintf('%3d  ',  SMALags);     fprintf('\n')
    
    fprintf('%15s : ','setARIMAOpt')
    fprintf('%3d  ', setARIMAOpt ); fprintf('\n')
    
%% SET DATA for the script and define TRAIN, TEST, VALIDATION
    % fprintf('-> SET DATA for the script and define TRAIN, TEST, VALIDATION\n');
    %{
       ARIMA & validation. ARIMA itself has not validation subset. 
       So, to be able to make a comparison between ARIMA and ANN, we stablished
         - train     : to estimate the coeficients of the model
         - validation: to evaluate the generalization capability of the model estimaded
         - test      : answer given on values to be forecasted
    %}
    % -----------------------------------------------------------------------
    ts_Data00  = Data;  clear Data;
    nTs        = numel(ts_Data00);
    
    % TRAIN, VALIDATION, TEST percentages  ----------------------------------
    % prctTrain = 0.8;
    % prctValid = 0.1;                         
    % prctTest  = 1 - prctValid - prctTrain;   % This prctg must the same than 

    prctTrain = parameter.prctTrain;
    prctValid = parameter.prctValid;
    prctTest  = 1 - prctValid - prctTrain;   % This prctg must the same than 
        
    % TRAIN, VALIDATION, TEST data         ----------------------------------
    
    % indexes  
    tsLastIndexTrain = fix(nTs*prctTrain);
    tsLastIndexValid = tsLastIndexTrain + fix(nTs*prctValid);
    
    % periods
    trainTimes =                      1:tsLastIndexTrain;
    validTimes = (tsLastIndexTrain + 1):tsLastIndexValid;
    testTimes  = (tsLastIndexValid + 1):nTs;
    
    % ts Train Valid and Test values
    ts_Data01       = ts_Data00; 
    ts_Data01_Train = ts_Data00(trainTimes);  
    ts_Data01_Valid = ts_Data00(validTimes);
    ts_Data01_Test  = ts_Data00(testTimes);
    
    % for ACF & PACF ----------------------------------------------------------
    numLags   = numel(ts_Data01_Valid);   % numLags   = 75; % ~3 days
        
%% PROCESS THE TIME SERIES DATA, only to show figures        ============================
% ============================================================================= 
% Note: nothing about 
% Process: logarithm ; diff( (1-L)y_t ); (1-L)y_t) - (1-L)Ly_t = 1 -2Ly_t + L^2_y_t 
% L y(t) = y(t-1)
%
    % fprintf('-> PROCESS THE TIME SERIES DATA, only to show figures\n');
    % preProcessTSData = 1; % preProcessTSData is set above

    if preProcessTSData 
        ts_Data01_Log = log(ts_Data01);
        nTsLog = numel(ts_Data01_Log);

        ts_Data01_Dif = ts_Data01(2:nTs) - ts_Data01(1:(nTs-1));
        nTsDif = numel(ts_Data01_Dif);

        ts_Data01_Dif2 = ts_Data01_Dif(2:nTsDif) - ts_Data01_Dif(1:(nTsDif-1));
        nTsDif2 = numel(ts_Data01_Dif2);

        ts_Data01_LogDif = ts_Data01_Log(2:nTsLog) - ts_Data01_Log(1:(nTsLog-1));
        nTsLogDif = numel(ts_Data01_LogDif);

        % Log of a difference is a bad idea, because we should log a negative values ...
        % ts_Data01_DifLog = log(ts_Data01_Dif);
        % nTsDifLog = numel(ts_Data01_DifLog);

        % Show the time series and its processing -------------------------------------------------------------
        if ( showTsTRansformed ) 
            h0a = figure('Name',tsFilename( 1:numel(tsFilename) ) );
            subplot(3,2,1); plot(ts_Data01,        '-cs','MarkerSize',3); title(tsName);
            subplot(3,2,2); plot(ts_Data01_Log,    '-cs','MarkerSize',3); title('TS log');
            subplot(3,2,3); plot(ts_Data01_Dif,    '-cs','MarkerSize',3); title('TS (1-L)y_t');
            subplot(3,2,4); plot(ts_Data01_LogDif, '-cs','MarkerSize',3); title('TS ( (1-L)Log(y_t) )');
            subplot(3,2,5); plot(ts_Data01_Dif2,   '-cs','MarkerSize',3); title('TS ( (1-L)y_t) - (1-L)Ly_t ) )');

            % Log of a difference is a bad idea, because we should log a negative values ...
            subplot(3,2,6); plot(0,0, '-s','MarkerSize',3); title('TS ( Log( (1-L)y_t) ) -> bad idea');

            filename = strcat(tsName,'_transformed');
            format = '-dpdf'; folder = folderFigures;
            [ error ] = saveFigure( h0a , format, folder , filename , savingFiguresTS);
        end
        
    end

    if preProcessTSData
        showScatterPlot  = 1;
        showACFPACFPlot  = 0;

        if ( showScatterLag ) 
            %sInfo <- type of Pollutant (for the limit ofthe axes in the figures) 
            sInfo = tsInfoCellArray{indexTs}; % sInfo = ''; 
            [ACF, lagsACF, boundsACF, PACF, lagsPACF , boundsPACF , ... 
             hScatter, hAcf, hPacf] = getLagScatterPlot_ACF_PACF_v01( ts_Data01 , tsName, sInfo, numLags, showScatterPlot, showACFPACFPlot );

            filename = strcat(tsName,'_scatter_Lag');
            format = '-dpdf'; folder = folderFigures;
            [ error ] = saveFigure( hScatter , format, folder , filename , savingFiguresTS );
        end
    end

    % ------------------------------------------------------
    % Show the TS and the ACF y PACF of TS Data
    
    if showTsAcfPacf 
        h0b = figure('Name',tsFilename( 1:numel(tsFilename) ) );
        subplot(2,2,1:2); plot(ts_Data01,'-cs','MarkerSize',3); title( tsName );
        subplot(2,2,3);   autocorr(ts_Data01,numLags);         title( 'ACF');
        subplot(2,2,4);   parcorr(ts_Data01,numLags);          title( 'PACF');
        
        filename = strcat(tsName,'_TS+ACF+PACF');
        format = '-dpdf'; folder = folderFigures;
        [ error ] = saveFigure( h0b , format, folder , filename , savingFiguresTS );
    end
    
%% GET A MODEL, EVALUATE THE MODEL , FORECAST with the model ============================
%  ======================================================================================
    %fprintf('-> GET A MODEL, EVALUATE THE MODEL , FORECAST with the model\n'); 
   
%% COMPUTATION STEP 2 (Get, check model)?
    if (computationSteps(2) == 0)
        continue
    end
    % fprintf('--------------\ntsName %s\n',tsName);
    
%% STEP 01 - SPECIFY THE MODEL    -------------------------------------------------------
%  --------------------------------------------------------------------------------------
    % fprintf('-> STEP 01 - SPECIFY THE MODEL\n'); 
    %{
    filenameTS = {'ts-NO2-FedzLadreda-16-12.csv' , ... 
                  'ts-NO2-PzCastilla-16-10.csv' , ...
                  'ts-O3-JuanCarlosI-16-07.csv' , ...
                  'ts-PM25-MendezAlvaro-16-10.csv'};

    %}
    % p = 6; D = 1; q = 6; % P = 26; D = 2; q = 26;
    % toEstMd1 = arima(p,D,q);
    % Constant = 1; D = 1; Seasonality = 12; MALags = 24; SMALags = 24;
     if     ( setARIMAOpt == 1)
        
        toEstMd1 = arima(p,D,q);
     
     elseif ( setARIMAOpt == 2) 
     
        %toEstMd1 = arima('Constant',Constant,'D',D,'Seasonality',Seasonality, 'MALags',MALags,'SMALags',SMALags);
        toEstMd1 = arima( 'D' , D , 'Seasonality' , Seasonality );
     
     end

    % +++++++++++++++++++++++++++++++++++++++++++
    % Seed
    v = (int32(clock)); seed = v(5) + v(6); clear v; 
    rng(seed);  % seed is the second for time 
    fprintf('%15s : %03d\n', 'Seed' , seed);
    
%% STEP 02 - ESTIMATE THE MODEL USING PRESAMPLE DATA.   =================================
%  --------------------------------------------------------------------------------------
    %fprintf('-> STEP 02 - ESTIMATE THE MODEL USING PRESAMPLE DATA\n'); 

    % num initial values of the observations to be taken as initial values
    % pSt = 13; % example value for one of the time series
    pSt = max(toEstMd1.P,toEstMd1.Q);
    %pSt = min(toEstMd1.P,toEstMd1.Q);

    % PRESAMPLE TIME & PRESAMPLE DATA 
    preSampleTimes = 1:pSt;
    y0 = ts_Data01( preSampleTimes );

    % train, Valid and Test Times (we want colum vectors ... ) 
    trainTimes = ( ( preSampleTimes( end ) + 1):tsLastIndexTrain )';
    validTimes = ( ( tsLastIndexTrain + 1 ):tsLastIndexValid     )';
    testTimes  = ( ( tsLastIndexValid + 1 ):nTs                  )';
    
    ts_Data01_Presample = ts_Data01( preSampleTimes) ; 
    ts_Data01_Train     = ts_Data01( trainTimes) ; 
    ts_Data01_Valid     = ts_Data01( validTimes) ; 
    ts_Data01_Test      = ts_Data01( testTimes ) ;
    
    nTs_Valid  = numel(trainTimes) + numel(preSampleTimes);
    nTs_Valid  = numel(validTimes);
    nTs_Test   = numel(testTimes );

    
    % SHOW Y0 values - TRAIN VALIDATION  TEST --------------------------
    h1a = figure('Name',tsFilename( 1:numel(tsFilename) ) );
    plot( preSampleTimes , y0              , '-sg','MarkerSize',3); hold on ;
    plot( trainTimes     , ts_Data01_Train , '-sk','MarkerSize',3); hold on;
    plot( validTimes     , ts_Data01_Valid , '-sc','MarkerSize',3); hold on;
    plot( testTimes      , ts_Data01_Test  , '-sb','MarkerSize',3); 
    title(tsName);
    % savingg pdf ---------------------------------
    filename = strcat(tsName,'_train-valid-test_subsets');
    format = '-dpdf'; folder = folderFigures;
    [ error ] = saveFigure( h1a , format, folder , filename , savingFiguresTS );
    
    % residualsTrain_0 = infer(toEstMd1,ts_Data01_Train,'Y0',y0);
    % h1a_2 = figure('Name',strcat( tsFilename( 1:end), 'train target(b) output(g)'  ) );
    % plot( preSampleTimes , y0              , '-sg','MarkerSize',3); hold on ;
    % plot( trainTimes   , ts_Data01_Train , '-sk','MarkerSize',3); hold on;
    % plot( trainTimes   , ts_Data01_Train + residualsTrain, '-sm','MarkerSize',3); hold on;
    % title(strcat(tsName,' residuals toEstMdl '));
    % % savingg pdf 

    t = tic;
    fprintf('Estimating ARIMA Model ... '); 
    [EstMd1,EstParamCov, logL, info] = estimate( toEstMd1 , ts_Data01_Train, 'Y0' , y0,...
                                                 'Display','off'); % Class: arima
    fprintf('%6.2f seg \n', toc(t) ); 
    % ======================================================================
    
%% STEP 03 - INFER [and show ]THE RESIDUAL FROM THE FITTED MODEL 
    
    % fprintf('-> STEP 03 - INFER [and show ]THE RESIDUAL FROM THE FITTED MODEL\n'); 
    
    residualsTrain = infer(EstMd1,ts_Data01_Train,'Y0',y0);
    numObs = numel(ts_Data01_Train);

    [trainRMSE, trainSMAPE] = getTsErrors_v1 (ts_Data01_Train, (ts_Data01_Train + residualsTrain), numObs); 
    fprintf('\n%s\n',strcat( tsName , ' Train (residuals)') );
    fprintf('\nTrain (residuals) times %d\n%12s %12s\n%12.5f %12.5f\n\n',...
             numObs,'rmse', 'smape',trainRMSE, trainSMAPE);

    
    % SHOW TRAIN RESIDUALS  ---------------------------
    if (showModelResidual)              
        h1b       = figure('Name',strcat( tsFilename( 1:end ), 'train target(b) output(g)'  ) );
        plot( preSampleTimes , y0                              , '-sg','MarkerSize',3 ); hold on ;
        plot( trainTimes     , ts_Data01_Train                 , '-sk','MarkerSize',3 ); hold on;
        plot( trainTimes     , ts_Data01_Train + residualsTrain, ':+m','MarkerSize',3 ); hold on;
        title( strcat( tsName, ' train & residuals') );
        % Saving pdf ------------- 
        filename  = strcat( tsName , '_trainResiduals' );
        format    = '-dpdf'; 
        folder    = folderFigures;
        [ error ] = saveFigure( h1b , format, folder , filename , savingFiguresTSF );
    end
    % [ ts_Data_01_Train_Ouptut , E ] = simulate(EstMd1,numObs,'Y0',y0, 'NumPaths', 100); 
    % h1c = figure('Name',strcat( tsFilename( 1:end), 'train target(b) output(g)'  ) );
    % plot( trainTimes   , ts_Data_01_Train_Ouptut  , '-sg','MarkerSize',3); 
    
%% STEP 04 - FORECAST ON VALIDATION DATA (Forecast) ======================================            

    %fprintf('-> STEP 04 - FORECAST ON VALIDATION DATA (Forecast)\n'); 
    
    pStValForec    = max(EstMd1.P,EstMd1.Q);
    periodsValid   = length(ts_Data01_Valid); 
    
    % Pre-samples for VALIDATION forecast
    preSampleTimesVal = trainTimes( ( end - pStValForec ):end );
    %Y04ValF           = ts_Data01_Train( ( end - pStValForec ):end );  % This work if pStValForec is smallet that length for validation subset
    Y04ValF = ts_Data01( (tsLastIndexTrain - pStValForec):tsLastIndexTrain);
    
    
    % GET THE FORECAST ON VALIDATION times, H = 1 & USING THE FORESCATED VALUES ( h = 1b )
    [ ts_Data01_ValForecasted , ts_Data01ValMSE , V ] = forecast( EstMd1 , periodsValid , 'Y0' , Y04ValF );
    
    % ------------------------------------------
    [ valForecastRMSE , valForecastSMAPE ] = getTsErrors_v1 (ts_Data01_Valid, ...
                                                             ts_Data01_ValForecasted, ...
                                                             periodsValid); 
    
    fprintf('\n%s\n',strcat( tsName , ' Validation Forecast') );
    fprintf('forecasted times %d\n%12s %12s\n%12.5f %12.5f\n',...
             periodsValid,'rmse', 'smape',valForecastRMSE, valForecastSMAPE);
    fprintf('\n');         

                                                         
    % GET THE FORECAST ON VALIDATION times, H = 1 & USING THE (REAL) VALIDATION VALUES (h = 1a)
    % To be completed
 
%% STEP 05 - FORECAST ON TEST DATA (Forecast)       ======================================

    %fprintf('-> STEP 05 - FORECAST ON TEST DATA (Forecast)\n'); 
     
    % From the periods to be forecasted (Validation), i.e. horizon h, then 
    pStValForec = max(EstMd1.P,EstMd1.Q);   % pStF = max(EstMd1.P,EstMd1.Q);
    periods     = length(ts_Data01_Test); 
    
    % Pre-samples for TEST forecast
    preSampleTimesTest = validTimes( (end - pStValForec):end );
    % Y04F             = ts_Data01_Valid((end - pStF):end);         % This work if pStValForec is smallet that length for validation subset
    Y04TestF           = ts_Data01( (tsLastIndexValid - pStValForec):tsLastIndexValid);
    
    % GET THE FORECAST ON VALIDATION times, H = 1 & USING THE FORESCATED VALUES (h = 1b)
    [ ts_Data01_TestForecasted , ts_Data01TestMSE , V ] = forecast( EstMd1 , periods, 'Y0',Y04TestF);

    % ------------------------------------------
    [testForecastRMSE , testForecastSMAPE ] = getTsErrors_v1 (ts_Data01_Test, ...
                                                              ts_Data01_TestForecasted, ... 
                                                              periods ); 
    
    fprintf('\n%s\n',strcat( tsName , ' Test Forecast') );
    fprintf('forecasted times %d\n%12s %12s\n%12.5f %12.5f\n',...
             periods,'rmse', 'smape',testForecastRMSE, testForecastSMAPE);
    fprintf('\n');         
    
    % GET THE FORECAST ON VALIDATION times, H = 1 & USING THE (REAL) VALIDATION VALUES (h = 1a)
    % To be completed
    
%% SHOW FORECAST for VALIDATION & AND TEST 
    
    %fprintf('-> SHOW FORECAST for VALIDATION & AND TEST\n'); 
    % -------------------------------------------
    if (showModelTrainValTestForecast)
        a = trainTimes(end) + 1; b = trainTimes(end)+periods; 
        forecastedTimes = ( a:b); clear a b;

        h1d = figure('Name',strcat( tsFilename( 1:end), '  train val target(b) forecast (r)'  ) );
        plot( preSampleTimes , y0                               , '-sg','MarkerSize',5); hold on ;
        plot( trainTimes     , ts_Data01_Train                  , '-sk','MarkerSize',3); hold on;
        plot( trainTimes     , ts_Data01_Train + residualsTrain , ':+m','MarkerSize',3); hold on;
        
        plot( preSampleTimesVal , Y04ValF                       , ':sg','MarkerSize',5); hold on ;
        plot( validTimes     , ts_Data01_Valid                  , '-sc','MarkerSize',3); hold on;
        plot( validTimes     , ts_Data01_ValForecasted          , '-sm','MarkerSize',3); hold on;
        
        plot( preSampleTimesTest , Y04TestF                     , ':sg','MarkerSize',5); hold on ;
        plot( testTimes      , ts_Data01_Test                   , '-sb','MarkerSize',3); hold on;
        plot( testTimes      , ts_Data01_TestForecasted         , '-sm','MarkerSize',3); hold on;
        title(strcat( tsName, ' train & (val test) Forecast'));

        % Saving pdf ------------- 
        
        filename = strcat(tsName,'_TrainValTest_forecast'); 
        format = '-dpdf'; folder = folderFigures;
        [ error ] = saveFigure( h1d , format, folder , filename , savingFiguresTSF );

    end
    % fprintf('\nEnd of this section - %s\n', tsName);
    % return;
        
    % -------------------------------------------
    
    if ( showModelValTestForecast )
        
        a = trainTimes(end) + 1; b = trainTimes(end)+periods; 
        forecastedTimes = ( a:b); clear a b;

        h1d = figure('Name',strcat( tsFilename( 1:end), '  target(b) forecast (r)'  ) );
                
        plot( preSampleTimesVal , Y04ValF                       , ':sg','MarkerSize',5); hold on ;
        plot( validTimes     , ts_Data01_Valid                  , '-sc','MarkerSize',3); hold on;
        plot( validTimes     , ts_Data01_ValForecasted          , '-sm','MarkerSize',3); hold on;
        
        plot( preSampleTimesTest , Y04TestF                     , ':sg','MarkerSize',5); hold on ;
        plot( testTimes      , ts_Data01_Test                   , '-sb','MarkerSize',3); hold on;
        plot( testTimes      , ts_Data01_TestForecasted         , '-sm','MarkerSize',3); hold on;
        title(strcat( tsName, ' (val test) Forecast'));

        % Saving pdf ------------- 
        filename = strcat(tsName,'_TrainValTest_forecast');
        format = '-dpdf'; folder = folderFigures;
        [ error ] = saveFigure( h1d , format, folder , filename , savingFiguresTSF );

    end
    
    %% END of the TIME SERIES i
    fprintf('\nEnd of - %s\n', tsName);
    % return;
    
end