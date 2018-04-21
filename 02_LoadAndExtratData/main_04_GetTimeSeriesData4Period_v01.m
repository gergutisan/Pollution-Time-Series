%% Note of the author
%{
  if Data_Daily/pollutionData_hourly_2012-201x.mat and
     Data_Hourly/pollutionData_daily_2012-201x.mat 
    
  do not exist then execute:   main_01_LoadPollutionData_v0X.m   (X = 1 or 2, 2 best)

%}

%% 
clearvars -EXCEPT pollutionData_daily pollutionData_hourly year month % to be faster while debugging
clc; close all; fclose('all');
%% SET THE PATH -------------------------------------------------------------------
restoredefaultpath; clear RESTOREDEFAULTPATH_EXECUTED;

%% PAHT & FOLDERS ----------------------------------------------------------------
cd(fileparts(mfilename('fullpath')));    % does not work if executed by Run Section [and advance]
folderFunctions  = strcat(fileparts(mfilename('fullpath')) , '\Functions');
% d:\DriveGoogle\00_SW_Projects\2017_PollutionMadrid_TimeSeries_01\SourceCode\02_Arima\TimeSeries\
folderTimeSeries = strcat(fileparts(mfilename('fullpath')) , '\TimeSeries');
folderFigures    = strcat(fileparts(mfilename('fullpath')) , '\Figures');
folderPollutants = strcat(fileparts(mfilename('fullpath')) , '\Pollutants');

oldpath = path; path(folderFunctions,oldpath);
oldpath = path; path(folderTimeSeries,oldpath);
oldpath = path; path(folderFigures,oldpath);
oldpath = path; path(folderPollutants,oldpath);
clear oldpath

%% POLLUTANTS AND STATIONS

%{
pollutantCode = 08;        % NO2 micrograms/m3  
pollutantCode = 09;        % Particles < 2.5 micra  
pollutantCode = 14;        % O3 micrograms/m3  

stationCode   = 28079047;  % Mendez Alvaro      -> Alta.- 08/02/2010 (00:00 h.)
stationCode   = 28079056;  % Pza. Fdez. Ladreda -> Alta.- 18/01/2010 (12:00 h.)
stationCode   = 28079056;  % Pza. Fdez. Ladreda -> Alta.- 18/01/2010 (12:00 h.)
stationCode   = 28079059;  % Juan Carlos I      -> Alta.- 18/01/2010 (12:00 h.)
%}

pollutantsCodesCellArray = {08 , 09 , 14};
stationsCodesCellArray   = {047 , 050 ,  056 , 059};   % {28079050 ,  28079056};

computationStep = [ 1 1 1 ];  % Explain this ....

        % Step 1 computationStep(1)
        % Step 2 computationStep(2)
        % Step 3 computationStep(3)
        % Step 4 computationStep(4)
 
%% FOLDERS AND FILENAMES ---------------------------------
params.dailyDataFolder  = 'Data_Daily';
params.hourlyDataFolder = 'Data_Hourly';
params.rootAnioFolder   = 'Anio';

params.pollutantsFolder = 'Pollutants';
params.pollutantsFolder = folderPollutants;

%% VARIABLES ---------------------------------------------
params.debuggingLevel = 5;
params.kindData2Read = 'D'; 
params.kindData2Read = 'H';
% Data filenames
%    'pollutionData_hourly_2012-2015.mat'
%    'pollutionData_daily_2012-2015.mat'
filenameHourly  = fullfile(params.hourlyDataFolder, 'pollutionData_hourly_2012-2016.mat');
filenameDaily   = fullfile(params.dailyDataFolder , 'pollutionData_daily_2012-2016.mat');

%% STEP 1 - LOAD DATA (all data)

if (computationStep(1) == 1 )
    
    initTime = cputime;
    fprintf('Loading (daily/hourly) data ... \n');  
    if ( exist('pollutionData_daily','var') ~= 1 )
        fprintf('Loading pollutionData_daily ... ');  
    
        % Improve 2 be done : check if filenameDaily exists, 
        %                     if not call: 
        %                     params.kindData2Read = 'D'; 
        %                     [ pollutionData_daily, numAllMeasures]  = loadPollutionData_v02(params);   % the content that as seq of digits is read as a number

        load(filenameDaily);     % load -> pollutionData_daily
                                 % the only content of the *.mat file is the variable which name is pollutionData
        
    end

    if ( exist('pollutionData_hourly','var') ~= 1 )
        fprintf('Loading pollutionData_hourly ... ');  
        % Improve 2 be done : check if filenameDaily exists, 
        %                     if not call: 
        %                     params.kindData2Read = 'H'; 
        %                     [ pollutionData_hourly, numAllMeasures]  = loadPollutionData_v02(params);   % the content that as seq of digits is read as a number

        load(filenameHourly);     % load -> pollutionData_hourly
                            % the only content of the *.mat file is the variable which name is pollutionData
            
    end
    fprintf(' It takes %6.6f s\n',cputime - initTime); clear initTime;               

end

% ---------------------------------------------------------------
pollutionData_daily;
pollutionData_hourly;
% ---------------------------------------------------------------

tsPCSC = {08 47 ; 08 50 ; 08 56 ; 08 59; 09 47 ; 09 50; 14 56 ; 14 59 };   % PC SC ... k(#timeSeries) rows 

tsNamesCellArray = { "NO2-MendezAlvaro"  , "NO2-PzCastilla"  , "NO2-FedzLadreda" , "NO2-JuanCarlosI", ...
                     "PM25-MendezAlvaro" , "PM25-PzCastilla" , "O3-FezLadreda"   , "O3-JuanCarlosI" };
                 
tsInfoCellArray = {"NO2" , "NO2" ,"NO2" ,"NO2" ,...
                   "PM25" ,"PM25" ,"O3" ,"O3" ,};                


% LOAD WHOLE DATA and seve it in a cell array --- 
filenameTS = {'ts-PC-08-SC-47-H-F03.dat' , ... 
              'ts-PC-08-SC-50-H-F03.dat' , ...
              'ts-PC-08-SC-56-H-F03.dat' , ...
              'ts-PC-08-SC-59-H-F03.dat' , ...
              'ts-PC-09-SC-47-H-F03.dat' , ...
              'ts-PC-09-SC-50-H-F03.dat' , ...
              'ts-PC-14-SC-56-H-F03.dat' , ...
              'ts-PC-14-SC-59-H-F03.dat' };
    
% ---------------------------------------------------------------

% Defined out of this script
%     year          = 16;  % 20yy;
%     month         = 00;
    DH            = 'H';

%% STEP 2
% getPollutionDatapollutionData_hourly., year, month
%{
    pollutionData_hourly.codStationP3  <- 47 50 56 59
    pollutionData_hourly.codMeasure    <- 08 09 14
    pollutionData_hourly.codDate.year
    pollutionData_hourly.codDate.month
    pollutionData_hourly.codDate.day{indexDay}.value 
    pollutionData_hourly.codDate.day{indexDay}.valid
%}

% pollutionData_hourly;

nTs = size(tsPCSC,1);

for iTs = 1:nTs
    
    %stationCode   = 56; 
    %pollutantCode = 08;
    
    stationCode   = tsPCSC{iTs,2}; 
    pollutantCode = tsPCSC{iTs,1}; 
    tsName =  tsNamesCellArray{iTs};
    

    initTime = cputime;
    fprintf('\n--------------------------------\n');  
    fprintf('Searching for Data from a period (%2d & %2d) (daily/hourly) data at %s... \n',year,month,tsName);  

    [ tsDataF1 , tsDataF2 , nValues ] = getPollutionDatapollutionData_v1(...
                                        pollutionData_hourly, stationCode, pollutantCode, year, month, DH);

    fprintf('   It takes %6.6f s\n',cputime - initTime); clear initTime;                        
    
    % ================================================================
    % COMPUTE THE MEAN
    % ================================================================
    
    tsInfo = tsInfoCellArray{iTs};
    fprintf('tsName %s %s \n', tsName,tsInfo);
    
    % MONTHLY MEAN ---------------------------------------------------
    monthMean = mean(tsDataF1);
    
    % DAILY MEAN  ---------------------------------------------------
    day = 0; 
    index = 0;
    clear oneDayMean dailyMean;
    while ( index < numel(tsDataF1) ) 
        
        day = day + 1; 
        oneDayMean(day) = 0;
        partialSum = 0;
        for h = 1:24
            index = index + 1;
            partialSum = partialSum + tsDataF1(index);
        end
        oneDayMean(day) = partialSum /24;
        
    end
    
    meanDailyMean    = mean(oneDayMean);
    maxDailyMean     = max(oneDayMean);
    medianDailyMean  = median(oneDayMean);
    
    % 8-H MEAN  ---------------------------------------------------
    period = 0; day = 0;
    index = 0;
    clear onePeriodMean oneDay8hMean;
    
    while ( index < numel(tsDataF1) ) 
        
        index = index + 1;
        
        period = period + 1; 
        
        onePeriodMean(period) = 0;
        
        if (index + 7) < numel(tsDataF1)
            partialSum = 0;
            for h = 0:7
               partialSum = partialSum + tsDataF1(index + h);
            end
            onePeriodMean(period)  = partialSum /8;
        end
        if mod(index,24) ==0
           day = day + 1;
           oneDay8hMean(day)= mean(onePeriodMean( ( period - 23):period)); 
        end
        
        
    end
    
    maxDaily8hMean   = max(onePeriodMean);
    meanDaily8hMean   = mean(oneDay8hMean);
    medianDaily8hMean = median(oneDay8hMean);
    
    % NO2 Limits -------------------------------------------------
    if ( tsInfo == "NO2" ) 
        nAboveLimit = 0;
        index = 0;
        while ( index < numel(tsDataF1) ) 
            index = index + 1;
            aboveLimit = ( tsDataF1(index) >= 200 );
            if aboveLimit
               nAboveLimit = nAboveLimit + 1 ;
            end
            
        end    
    
    end
    
    
    
    % -------------------------------------------------------------------
    fId = fopen(strcat(params.pollutantsFolder,'\','summaryData.txt'),'a');
    fprintf(fId,'\n--------------------------\n'); 
    fprintf(fId,'%s\n%s\nyy %2d mm %2d\n', tsName,tsInfo,year,month);
        
    if ( tsInfo == "NO2" ) 
        fprintf(fId,' %30s %12d\n','AboveLimit(NO2)', nAboveLimit);           
    end
    fprintf(fId,' %30s %12.3f\n %30s %12.3f\n %30s %12.3f\n', ...
                'monthMean'           , monthMean , ...
                '(max) dailyMean'     , maxDailyMean ,...
                '(mean)dailyMean'     , meanDailyMean,...
                '(median)dailyMean'   , medianDailyMean,...
                '(max)daily8hMean'    , maxDaily8hMean,...
                '(mean)daily8hMean'   , meanDaily8hMean,...  
                '(median)daily8hMean' , medianDaily8hMean );

    fclose(fId);
    % fprintf('Program Paused. Press Any key. ');pause(); fprintf('\n');
    % ================================================================
    
    strYear  = num2str(year ,'%02d');
    strMonth = num2str(month,'%02d');
    
    % ================================================================
    sep     = '-';
    fileExt = '.csv';
    
    filename = strcat('ts',sep,tsName,sep,strYear,sep,strMonth,fileExt);
    fullFilename = strcat (params.pollutantsFolder ,'\',filename);
    t = tic;
    fprintf('Saving data into %s  ... ',filename); 
    
    error = saveDataUnivariateTSValue(tsDataF1, fullFilename);
    
    fprintf('took  %.4f (s) \n',toc(t) - t); clear t; 
    
    % ---------------------------------------------------------------
    sep            = '-';
    strStationCode = num2str(stationCode  ,'%02d');
    strPollutantCode  = num2str(pollutantCode,'%02d');
    fileExt = '.dat';
    
    filename = strcat('ts',sep,'PC',sep,strPollutantCode,sep,'SC',sep,strStationCode,sep,strYear,sep,strMonth,fileExt);
    fullFilename = strcat (params.pollutantsFolder ,'\',filename);
    t = tic;
    fprintf('Saving data into %s  ... ',filename); 
    
    error = saveDataUnivariateTSValue(tsDataF1, fullFilename);
    
    fprintf('took  %.4f (s) \n',toc(t) - t); clear t; 
    
    % ================================================================
    

end
