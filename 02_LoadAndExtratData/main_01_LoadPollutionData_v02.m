
%% CLEAR --------------------------------------------
clearvars -EXCEPT pollutionData_daily pollutionData_hourly % to be faster while debugging
% clear; 
clc; close all; fclose('all');

%% ADD Folder for funtions to the path ---------------------------------------------------
funcFolder = 'Functions';
pathStr = fileparts(mfilename('fullpath'));  % [ pathStr, name , ext] = fileparts(mfilename('fullpath'));
fullFuncFolder = strcat(pathStr,'\',funcFolder);
path(fullFuncFolder, path); 
clear funcFolder


%% FOLDERS AND FILENAMES ---------------------------------
params.dailyDataFolder  = 'Data_Daily';
params.hourlyDataFolder = 'Data_Hourly';
params.rootAnioFolder   = 'Anio';

%% VARIABLES ---------------------------------------------
params.debuggingLevel = 5;

params.yearsCellArray  = {2012,2013,2014,2015,2016};

% params.monthsCellArray = { 'ene'}; params.yearsCellArray  = { 2012 };   
params.monthsCellArray = {  'ene','feb','mar',...
                            'abr','may','jun',...
                            'jul','ago','sep',...
                            'oct','nov','dic'};

params.kindData2Read = 'D'; % params.kindData2Read = 'D'; % params.kindData2Read = 'H';

%% LOAD POLLUTION DATA ------------------------------

% Load data from csv file, or mat file (what should be previoulsy generated)

% DAILY DATA -----------------------------------------
params.kindData2Read = 'D';

t = cputime;
if ( exist('pollutionData_daily','var') ~= 1 )
    filename = fullfile(params.dailyDataFolder,'pollutionData_daily.mat');
    if ( exist(filename,'file') == 2 )
        fprintf('Loading pollutionData_daily ... ');  
        initTime = tic;
        load(filename);     % load -> pollutionData 
                            % the only content of the *.mat file is the variable which name is ensemblesRmse
        fprintf('. It takes %6.6f s\n',toc(initTime)); clear initTime;               
    else
        % [ pollutionData, numAllMeasures]  = loadPollutionData_v01(params); % all the content are chars/arrays of chars
        
        [ pollutionData_daily, numAllMeasures]  = loadPollutionData_v02(params);   % the content that as seq of digits is read as a number
        save(fullfile(params.dailyDataFolder,'pollutionData_daily_2012-2016.mat'),'pollutionData_daily') 
        % Note, for example two years means 11Mb ...
    end
end

fprintf(' Reading Daily data has taken %.2f s\n', cputime - t ); clear t

% HOURLY DATA -----------------------------------------
params.kindData2Read = 'H';

t = cputime;
if ( exist('pollutionData_hourly','var') ~= 1 )
    filename         = fullfile(params.hourlyDataFolder,'pollutionData_hourly.mat');
    if ( exist(filename,'file') == 2 )
        fprintf('Loading pollutionData_hourly ... ');  
        initTime = tic;
        load(filename);     % load -> pollutionData 

                            % the only content of the *.mat file is the variable which name is ensemblesRmse
        fprintf('. It takes %6.6f s\n',toc(initTime)); clear initTime;               
    else
        % [ pollutionData, numAllMeasures]  = loadPollutionData_v01(params); % all the content are chars/arrays of chars
        [ pollutionData_hourly, numAllMeasures]  = loadPollutionData_v02(params);   % the content that as seq of digits is read as a number
       
        save(fullfile(params.hourlyDataFolder,'pollutionData_hourly_2012-2016.mat'),'pollutionData_hourly') 
        % Note, for example two years means 11Mb ...
    end
end
fprintf(' Reading Hourly data has taken %.2f s\n', cputime - t ); clear t


%% PRIME ANALYSIS
% Note: the values withint pollutionData structure are number (not arrays of chars)
%       functions: unique, histc, accumarray
% --------------------------------------------
% DAILY DATA - MEASURES + STATIONS

    numAllMeasuresDay = numel(pollutionData_daily);
    vecMeasures = zeros(1,numAllMeasuresDay);
    vecStations = zeros(1,numAllMeasuresDay);
    
    for index = 1:numAllMeasuresDay 
        vecMeasures(index) = pollutionData_daily(index).codMeasure;
        vecStations(index) = pollutionData_daily(index).codStationP3;
    end
    clear index;
    measures = unique(vecMeasures); 
    stations = unique(vecStations);
    
    fprintf('Daily data - codMeasures\n');
    for i = 1:numel(measures)
        fprintf('codMeasure %3i\n',measures(i))
    end
    fprintf('\n');
    
    fprintf('Daily data - codStations\n');
    for i = 1:numel(stations)
        fprintf('codStation %3i\n',stations(i))
    end
    fprintf('\n');
    
    clear i vecMeasures vecStations;

% --------------------------------------------
% HOURLY DATA - MEASURES + STATIONS
    numAllMeasuresDay = numel(pollutionData_hourly);
    
    vecMeasures = zeros(1,numAllMeasuresDay);
    vecStations = zeros(1,numAllMeasuresDay);
    
    for index = 1:numAllMeasuresDay 
        vecMeasures(index) = pollutionData_hourly(index).codMeasure;
        vecStations(index) = pollutionData_hourly(index).codStationP3;
    end
    clear index
    
    measures = unique(vecMeasures); 
    stations = unique(vecStations);
    
    fprintf('Hourly data - codMeasures\n');
    for i = 1:numel(measures)
        fprintf('codMeasure %3i\n',measures(i))
    end
    fprintf('\n');
    
    fprintf('Hourly data - codStations\n');
    for i = 1:numel(stations)
        fprintf('codStation %3i\n',stations(i))
    end
    fprintf('\n');
    
    clear i vecMeasures vecStations;;




