% RESET;
%clear; clc; close('all'); fclose('all');
clear; close('all'); fclose('all');
% Delete Previous pdf files
% folder = 'Figures'; %delete(strcat(folder ,'\*.pdf')); clear folder

%% SET THE PATH -------------------------------------------------------------------
restoredefaultpath; clear RESTOREDEFAULTPATH_EXECUTED;

%% PAHT & FOLDERS ----------------------------------------------------------------
cd(fileparts(mfilename('fullpath')));    % does not work if executed by Run Section [and advance]
folderFunctions  = strcat(fileparts(mfilename('fullpath')),'\Functions');
folderTimeSeries = strcat(fileparts(mfilename('fullpath')),'\TimeSeries');
folderFigures    = strcat(fileparts(mfilename('fullpath')),'\Figures');

oldpath = path; path(folderFunctions,oldpath);
oldpath = path; path(folderTimeSeries,oldpath);
clear oldpath;
% --------------------------------------------------------------------------------

%%  Examples from economics Tool box

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
tsFilename = 'Data_Overshort';   
tsName     = tsFilename( 6:(numel(tsFilename) - 4 ) );
load(fullfile(matlabroot,'examples','econ',tsFilename));
% Constant = 1; D = 1; Seasonality = 12; MALags = 24; SMALags = 24;
p = 4; D = 0; q = 3;
setARIMAOpt = 1;



% -----------------------------------------------------------------------
ts_Data01  = Data;  clear Data;
nTs        = numel(ts_Data01);

prctTrain = 0.8;
prctValid = 0.0;
prctTest  = 1 - prctValid - prctTrain;

numLags    = 36;       % 3 years


%%  process the time series Data % ============================================
% =============================================================================
% Process: logarithm ; diff( (1-L)y_t );  (1-L)y_t) - (1-L)Ly_t =  1 -2Ly_t + L^2_y_t
%   L y(t) = y(t-1)
preProcessTSData = 1;

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
    h0a = figure('Name',tsFilename( 1:numel(tsFilename) ) );
    subplot(3,2,1); plot(ts_Data01,        '-s','MarkerSize',3); title(tsName);
    subplot(3,2,2); plot(ts_Data01_Log,    '-s','MarkerSize',3); title('TS log');
    subplot(3,2,3); plot(ts_Data01_Dif,    '-s','MarkerSize',3); title('TS (1-L)y_t');
    subplot(3,2,4); plot(ts_Data01_LogDif, '-s','MarkerSize',3); title('TS ( (1-L)Log(y_t) )');
    subplot(3,2,5); plot(ts_Data01_Dif2,   '-s','MarkerSize',3); title('TS ( (1-L)y_t) - (1-L)Ly_t ) )');

    % Log of a difference is a bad idea, because we should log a negative values ...
    subplot(3,2,6); plot(0,0, '-s','MarkerSize',3); title('TS ( Log( (1-L)y_t) ) -> bad idea');

end

% ------------------------------------------------------
% Show the TS and the ACF y PACF of TS Data
show_TSData_ACF_PACF = 1;
if show_TSData_ACF_PACF 
    h0b = figure('Name',tsFilename( 1:numel(tsFilename) ) );
    subplot(2,2,1:2); plot(ts_Data01,'-s','MarkerSize',3); title( tsName );
    subplot(2,2,3);   autocorr(ts_Data01,numLags);         title( 'ACF');
    subplot(2,2,4);   parcorr(ts_Data01,numLags);          title( 'PACF');
end


%% GET A MODEL, EVALUATE THE MODEL , FORECAST with the model  ============================
% ========================================================================================
fprintf('--------------\ntsName %s\n',tsName);
% ++++++++++++++++++++++++++++
% Step 01 - Specify the model 

% p = 6; D = 1; q = 6; % P = 26; D = 2; q = 26;
% toEstMd1 = arima(p,D,q);
% Constant = 1; D = 1; Seasonality = 12; MALags = 24; SMALags = 24;
 if ( setARIMAOpt == 1)
    toEstMd1 = arima(p,D,q);
 elseif ( setARIMAOpt == 1) 
    toEstMd1 = arima('Constant',Constant,'D',D,'Seasonality',Seasonality, 'MALags',MALags,'SMALags',SMALags);
 end

% +++++++++++++++++++++++++++++++++++++++++++
% Seed
v = (int32(clock)); seed = v(6); clear v; rng(seed);  % seed is the second for time 
fprintf('Seed: %03d\n',seed);

% ++++++++++++++++++++++++++++
% Step 02 -  Estimate the Model Using Presample Data.


pSt            = 13;   % num initial values of the observations to be taken as initial values
pSt = max(toEstMd1.P,toEstMd1.Q);
%pSt = min(toEstMd1.P,toEstMd1.Q);

preSampleTimes = 1:pSt;
y0 = ts_Data01(preSampleTimes);

nTsTrain = fix(nTs * prctTrain) ;

trainTimes = ( ( preSampleTimes( end ) + 1):nTsTrain );
testTimes  = ( ( trainTimes( end ) + 1 ):( nTs ));

nTs_Valid = 0;
nTs_Test = numel(testTimes );

ts_Data01_Presample = ts_Data01( preSampleTimes) ; 
ts_Data01_Train = ts_Data01( trainTimes) ; 
ts_Data01_Test  = ts_Data01( testTimes ) ;

h1a = figure('Name',tsFilename( 1:numel(tsFilename) ) );
plot( preSampleTimes , y0              , '-sk','MarkerSize',3); hold on ;
plot( trainTimes     , ts_Data01_Train , '-sb','MarkerSize',3); hold on;
plot( testTimes      , ts_Data01_Test  , '-sr','MarkerSize',3); 
title(tsName);
% savingg pdf 


% residualsTrain_0 = infer(toEstMd1,ts_Data01_Train,'Y0',y0);
% h1a_2 = figure('Name',strcat( tsFilename( 1:end), 'train target(b) output(g)'  ) );
% plot( preSampleTimes , y0              , '-sk','MarkerSize',3); hold on ;
% plot( trainTimes   , ts_Data01_Train , '-sb','MarkerSize',3); hold on;
% plot( trainTimes   , ts_Data01_Train + residualsTrain, '-sr','MarkerSize',3); hold on;
% title(strcat(tsName,' residuals toEstMdl '));
% % savingg pdf 


[EstMd1,EstParamCov, logL, info] = estimate( toEstMd1 , ts_Data01_Train, 'Y0' , y0,...
                                             'Display','off'); % Class: arima


% ++++++++++++++++++++++++++++
% Step 03 -  Infer the residuals from the fitted model. 

residualsTrain = infer(EstMd1,ts_Data01_Train,'Y0',y0);
numObs = numel(ts_Data01_Train);

[trainRMSE, trainSMAPE] = getTsErrors_v1 (ts_Data01_Train, (ts_Data01_Train + residualsTrain), numObs); 

fprintf('\nTrain residuals results - times %d\n%12s %12s\n%12.5f %12.5f\n\n',...
         numObs,'rmse', 'smape',trainRMSE, trainSMAPE);


h1b = figure('Name',strcat( tsFilename( 1:end), 'train target(b) output(g)'  ) );
plot( preSampleTimes , y0              , '-sk','MarkerSize',3); hold on ;
plot( trainTimes   , ts_Data01_Train , '-sb','MarkerSize',3); hold on;
plot( trainTimes   , ts_Data01_Train + residualsTrain, ':+m','MarkerSize',3); hold on;
title(strcat( tsName, ' train & residuals'));

% [ ts_Data_01_Train_Ouptut , E ] = simulate(EstMd1,numObs,'Y0',y0, 'NumPaths', 100); 
% h1c = figure('Name',strcat( tsFilename( 1:end), 'train target(b) output(g)'  ) );
% plot( trainTimes   , ts_Data_01_Train_Ouptut  , '-sg','MarkerSize',3); 

% ++++++++++++++++++++++++++++
% Step 04 - Forecast 

% From the periods to be forecasted, i.e. horizon h, then 
periods = length(ts_Data01_Test); 
pStF = max(EstMd1.P,EstMd1.Q);
preSampleTimes = trainTimes((end - pStF):end);
Y04F = ts_Data01_Train((end - pStF):end);

[ ts_Data01_Forecasted , ts_Data01MSE , V ] = forecast(EstMd1,periods, 'Y0',Y04F);

% ------------------------------------------
[forecastRMSE , forecastSMAPE ] = getTsErrors_v1 (ts_Data01_Test,ts_Data01_Forecasted, periods); 
fprintf('\nforecasted times %d\n%12s %12s\n%12.5f %12.5f\n\n',...
         periods,'rmse', 'smape',forecastRMSE, forecastSMAPE);

% -------------------------------------------
a = trainTimes(end) + 1; b = trainTimes(end)+periods; 
forecastedTimes = ( a:b); clear a b;

h1d = figure('Name',strcat( tsFilename( 1:end), '  train target(b) forecast (g)'  ) );
plot( preSampleTimes    , Y04F                 , '-sg','MarkerSize',5); hold on ;
plot( trainTimes        , ts_Data01_Train      , '-sk','MarkerSize',3); hold on;
plot( trainTimes        , ts_Data01_Train + residualsTrain, ':+m','MarkerSize',3); hold on;
plot( testTimes         , ts_Data01_Test       , '-sb','MarkerSize',3); hold on;
plot( forecastedTimes   , ts_Data01_Forecasted , '-sr','MarkerSize',3); hold on;
title(strcat( tsName, ' Forecast'));


fprintf('\nEnd of this section - Airline data.\n');
return;

%%  Example for Mackey-Glass 
% Load (and plot) the Time Series Data 

% numLags = 50;
% tsFilename = 'ts_Mackey-Glass.dat';
% ts_Data    = load(tsFilename); 
% h1 = figure('Name',tsFilename( 4:numel(tsFilename) ) );
% subplot(2,2,1:2);
% plot(ts_Data,'-s','MarkerSize',3); title( tsFilename( 4:numel(tsFilename) ) );
% subplot(2,2,3);
% autocorr(ts_Data,numLags); 
% title( 'ACF');
% subplot(2,2,4);
% parcorr(ts_Data,numLags); 
% title( 'PACF');
% 
% % -----------------
% p = 5; D = 1; q = 5;    Mdl = arima( p , D , q );
% p = 20; D = 1; q = 5;  Md2 = arima( p , D , q );
% %Mdl = arima( 'Constant', 0 , 'D' , D , 'Seasonality' , 12 , 'MALags' , 1 , 'SMALags' , 12 );
% % Estimate the model
% 
% [EstMdl,EstParamCov1,logL1,info1] = estimate(Mdl,ts_Data);
% numParams1 = sum(any(EstParamCov1));
% 
% [EstMd2,EstParamCov2,logL2,info2] = estimate(Md2,ts_Data);
% numParams2 = sum(any(EstParamCov2));



%% ARIMA MODELLING  

% Create a ARIMA MODEL
%{
   p: degree of the non-seasonal auto-regressive polynomial 
   D: degree of the non-seasonal differencing polynomial  (default -> 0)
   q: degree of the non-seasonal moving average polynomial 

   'Seasonality'  A nonnegative integer indicating the degree of the seasonal
                  differencing polynomial. If unspecified, the default is zero.

   D => ARLags = [1 2 3 ... D] , but ARLags can be: [1 3 5 .. D]  
   q => MALags = [1 2 3 ... q] , but MALags can be: [1 3 5 .. D] 
        SMA = [1 2 3, ] seasonal moving average polynomial

   Note: there are non-seasonal and seasonal
   SAR: {1, ... } seasonal auto-regressive polynomial
%}

%{
    Cyclic ARMA models.
    The class of ARMA models can handle both seasonality and cyclic behaviour. An ARIMA(p,q) 
    model can be cyclic if p > 1 although there are some conditions on the parameters 
    in order to obtain cyclicity. 

    A seasonal ARMA model requires additional seasonal terms. 
%}

%{
    Additive and Multiplicative ARIMA Models
    
    Estimate Multiplicative ARIMA Models
    https://es.mathworks.com/help/econ/fit-multiplicative-seasonal-model-to-airline-passenger-data.html
%}





