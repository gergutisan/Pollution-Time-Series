clear; clc; close('all'); fclose('all');
% Delete Preious pdf files
folder = 'Figures';
%delete(strcat(folder ,'\*.pdf'));

%% SET THE PATH -------------------------------------------------------------------
restoredefaultpath; clear;

%% PAHT & FOLDERS ----------------------------------------------------------------
cd(fileparts(mfilename('fullpath')));    % does not work if executed by Run Section [and advance]

folderFunctions  = strcat(fileparts(mfilename('fullpath')),'\Functions');
% d:\DriveGoogle\00_SW_Projects\2017_PollutionMadrid_TimeSeries_01\SourceCode\02_Arima\TimeSeries\
folderTimeSeries = strcat(fileparts(mfilename('fullpath')),'\TimeSeries');

folderFigures = strcat(fileparts(mfilename('fullpath')),'\Figures');


oldpath = path; path(folderFunctions,oldpath);
oldpath = path; path(folderTimeSeries,oldpath);
clear oldpath

%% SCREEN SIZE  -----------------
setScreenSize( 0.1 , 0.8 ) % leftBottomCornerPos <- 0.1; rateScreenSize <- 0.8;

%% TIME SERIES NAMEs and FILENAMES 
%{
    %MendezAlvaro      SC: 47 (28079047)
    %Plaza-de-Castilla SC: 50 (28079050)
    %Pza-Fdez-Ladreda  SC: 56(28079056)
    %JuanCarlosI       SC: 59(28079059)
    stationCode   = 28 079 047;  % Mendez Alvaro      -> Alta.- 08/02/2010 (00:00 h.)
    stationCode   = 28 079 050;  % Castilla           -> Alta.- 18/01/2010 (12:00 h.)
    stationCode   = 28 079 056;  % Pza. Fdez. Ladreda -> Alta.- 18/01/2010 (12:00 h.)
    stationCode   = 28 079 059;  % Juan Carlos I      -> Alta.- 18/01/2010 (12:00 h.)
    
    %Pollutant NO2   PC: 08
    %Pollutant PM2.5 PC: 09
    %Pollutant O3    PC: 14
    pollutantCode = 08;        % NO2 micrograms/m3  
    pollutantCode = 09;        % PM2.5 Particles < 2.5 micra  
    pollutantCode = 14;        % O3 micrograms/m3  
%}

%{
    % Original Data (valid and not valid)
    ts_PC_08_SC_47_H_F03.dat     NO2_MendezAlvaro
    ts_PC_08_SC_50_H_F03.dat     NO2_PzCastilla
    ts_PC_08_SC_56_H_F03.dat     NO2_FedzLadreda
    ts_PC_08_SC_59_H_F03.dat     NO2_JuanCarlosI
    ts_PC_09_SC_47_H_F03.dat     PM25_MendezAlvaro
    ts_PC_09_SC_50_H_F03.dat     PM25_PzCastilla
    ts_PC_14_SC_56_H_F03.dat     O3_FezLadreda
    ts_PC_14_SC_59_H_F03.dat     03_JuanCarlosI

    % Preprocessed Data (PProc: the mean till the time of the ~"V labeled data/value)
    
    ts_PC_08_SC_47_H_pproc.dat
    ts_PC_08_SC_50_H_pproc.dat
    ts_PC_08_SC_56_H_pproc.dat
    ts_PC_08_SC_59_H_pproc.dat
    ts_PC_09_SC_47_H_pproc.dat
    ts_PC_09_SC_50_H_pproc.dat
    ts_PC_14_SC_56_H_pproc.dat
    ts_PC_14_SC_59_H_pproc.dat
%}

% TS NAMES ----------------------------
% tsNamesCellArray = { 'PC-08-SC-28079050-H-F03' , 'PC-08-SC-28079056-H-F03' , 'PC-09-SC-28079050-H-F03', 'PC-14-SC-28079056-H-F03'};
% tsNamesCellArray = { 'NO2-PzCastilla' , 'N02-PzFezLadreda' , 'PM2.5-PzCastilla', 'O3-PzFezLadreda'};

tsPCSC = {08 47 ; 08 50 ; 08 56 ; 08 59; 09 47 ; 09 50; 14 56 ; 14 59 };   % PC SC ... k(#timeSeries) rows 

tsNamesCellArray = { "NO2-MendezAlvaro" , "NO2-PzCastilla" , "NO2-FedzLadreda" , "NO2-JuanCarlosI", ...
                     "PM25-MendezAlvaro" , "PM25-PzCastilla" , "O3-FezLadreda" , "O3-JuanCarlosI"};


% LOAD WHOLE DATA and seve it in a cell array --- 
filenameTS = {'ts_PC_08_SC_47_H_F03.dat' , ... 
              'ts_PC_08_SC_50_H_F03.dat' , ...
              'ts_PC_08_SC_56_H_F03.dat' , ...
              'ts_PC_08_SC_59_H_F03.dat' , ...
              'ts_PC_09_SC_47_H_F03.dat' , ...
              'ts_PC_09_SC_50_H_F03.dat' , ...
              'ts_PC_14_SC_56_H_F03.dat' , ...
              'ts_PC_14_SC_59_H_F03.dat' };
          
%% PARAMETERS ============================================

hoursPerDay = 24;
daysPerWeek = 7 ; 
daysBack1Year = 365;      % 52 * 7 = 364
daysBack2Years = 365 * 2;  % 52 * 7 * 2 = 728

% parameters to get data -----------------------
% parameters for ACF and PACF  -----------------
numWeeks           = 2;
weeksBackLastMonth = 5;
numWeeksACF_PAFC   = 2;
numWeeks = numWeeksACF_PAFC;
% 
% note: -> 24 * 7 * 2 -> 336 periods; 
%  numLags2 = 200;
daysBackLastMonth = daysPerWeek * weeksBackLastMonth;
numLags = hoursPerDay * daysPerWeek * numWeeks;  % e.g. 2 weeks: 2352 times

%% LOAD TIME SERIES ==================================================================
%{
    Hourly data (24 per day) from 12 01 01 to 16 12 31 
%}

t1 = cputime;

% TS NAMES ----------------------------
tsNamesCellArray;

% TS DATA filesname in a cell array --- 
filenameTS;

% Load ALL DATA into a cell array. Each element of the cell array, is an array with the Time Series data
for i = 1:numel(filenameTS)  
  tsAllDataCellArray{i} = load( strcat( folderTimeSeries , '\' , filenameTS{i} ) );
end


% TS 2 LAST YEAR DATA -------------------
ts2LastYearDataCellArray = cell(1,length(tsAllDataCellArray));
for i = 1:length(tsAllDataCellArray) 
    % daysBack2Years
    firstIndex = (numel(tsAllDataCellArray{i}) - (hoursPerDay*daysBack2Years) );
    lastIndex  = numel(tsAllDataCellArray{i});
    
    ts2LastYearsDataCellArray{i} = tsAllDataCellArray{i}(  firstIndex:lastIndex );
    
end
clear firstIndex lastIndex;
% TS LAST YEAR DATA -------------------
tsLastYearDataCellArray = cell(1,length(tsAllDataCellArray));
for i = 1:length(tsAllDataCellArray) 
    
    firstIndex = (numel(tsAllDataCellArray{i}) - hoursPerDay*daysBack1Year);
    lastIndex  = numel(tsAllDataCellArray{i});
    
    tsLastYearDataCellArray{i} = tsAllDataCellArray{i}(  firstIndex:lastIndex );
    
end
clear firstIndex lastIndex;



% TS LAST (MONTH) X = 5 WEEKS DATA ------------------
tsLastMonthDataCellArray = cell(1,length(tsAllDataCellArray));

for i = 1:length(tsAllDataCellArray) 
    firstIndex = ( numel( tsAllDataCellArray{i} ) - hoursPerDay*daysBackLastMonth );
    lastIndex  = numel(tsAllDataCellArray{i});
    tsLastMonthDataCellArray{i} = tsAllDataCellArray{i}(  firstIndex:lastIndex );
end
clear firstIndex lastIndex;


fprintf('\nLOAD TIME SERIES -  matlab process time -> %.2f s\n\n',cputime - t1);  

%% GET MAX VALUES 24 h



tsLastMonthDataCellArray; 
%tsLastYearDataCellArray;
%ts2LastYearDataCellArray;
tsAllDataCellArray;


nTs = length(tsLastMonthDataCellArray); % nTs = length(tsDataCellArray);
for k = 1:nTs    
    % each time series
    lengthTS
    iTs = 1;
    while iTs
    for h = 1:24

        max = 0;
        while ( )

        end


    end


end


% 
% numData = { 1 2 3 4};
% for j = 1:length(numData)
%         
%         nD = numData{j}; nDStr = num2str(nD);
% 
%         switch nD 
%             case 1
%                 tsDataCellArray = tsLastMonthDataCellArray;
%             case 2
%                 tsDataCellArray = tsLastYearDataCellArray;
%             case 3
%                 tsDataCellArray = ts2LastYearsDataCellArray;
%             case 4
%                 tsDataCellArray = tsAllDataCellArray;
%         end         
%         
%         
%         
% end