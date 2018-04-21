clearvars -EXCEPT pollutionData_daily pollutionData_hourly % to be faster while debugging
clc; close all; fclose('all');

%% FOLDERS AND FILENAMES ---------------------------------
params.dailyDataFolder  = 'Data_Daily';
params.hourlyDataFolder = 'Data_Hourly';
params.rootAnioFolder   = 'Anio';

params.pollutantsFolder = 'Pollutants';

%% VARIABLES ---------------------------------------------
params.debuggingLevel = 5;
params.kindData2Read = 'D'; 
params.kindData2Read = 'H';
% Data filenames
% 'pollutionData_hourly_2012-2015.mat'
% 'pollutionData_daily_2012-2015.mat'
filenameDaily  = fullfile(params.hourlyDataFolder, 'pollutionData_hourly_2012-2015.mat');
filenameHourly = fullfile(params.dailyDataFolder , 'pollutionData_daily_2012-2015.mat');

%% LOAD DATA  

if ( exist('pollutionData_daily','var') ~= 1 )
    fprintf('Loading pollutionData_daily ... ');  
    initTime = tic;
    load(filenameDaily);     % load -> pollutionData_daily
                        % the only content of the *.mat file is the variable which name is pollutionData
    fprintf(' It takes %6.6f s\n',toc(initTime)); clear initTime;               
end;


if ( exist('pollutionData_hourly','var') ~= 1 )
    fprintf('Loading pollutionData_hourly ... ');  
    initTime = tic;
    load(filenameHourly);     % load -> pollutionData_hourly
                        % the only content of the *.mat file is the variable which name is pollutionData
    fprintf(' It takes %6.6f s\n',toc(initTime)); clear initTime;               
end;


%% POLLUTANTS INFORMATION ------------------------------------------
% Interesting Pollutants: PM < 2.5 micras; Ozone (O3); NO2 (nitrogen dioxide)
% NO2 (nitrogen dioxide) -> http://www.mambiente.munimadrid.es/opencms/export/sites/default/calaire/Anexos/Protocolo_NO2.pdf
%   Protocolo de medidas a adoptar durante episodios de alta contaminación por dióxido de nitrógeno
%   Aprobado por la Junta de Gobierno de la ciudad de Madrid de 21 de enero de 2016.
%       http://www.mambiente.munimadrid.es/opencms/export/sites/default/calaire/Anexos/Protocolo_NO2.pdf

%  PM < 2.5 micras  (µg/m3)        -> code 09 
%  Ozone (O3)       (µg/m3)        -> code 14
%  NO2 (nitrogen dioxide) (µg/m3)  -> code 08

%% SHOW THE POLLUTANTS WHICH MEASURES ARE WITHIN THE DATA ----------------

% Daily Data------------------------------------------

numAllMeasuresDaily = numel(pollutionData_daily);
vec_hourly = zeros(1,numAllMeasuresDaily);
for index = 1:numAllMeasuresDAily 
    vec_hourly(index) = pollutionData_Daily(index).codMeasure;
end;
measures = unique(vec_hourly); clear index
fprintf('\nDaily data - codMeasure \n');
for index = 1:numel(measures)
    fprintf('codMeasure %3i\n',measures(index))
end;
clear index;

% Hourly Data------------------------------------------

numAllMeasuresHourly = numel(pollutionData_hourly);
vec_hourly = zeros(1,numAllMeasuresHourly);
for index = 1:numAllMeasuresHourly 
    vec_hourly(index) = pollutionData_hourly(index).codMeasure;
end;
fprintf('\nHourly data - codMeasure \n');
measures = unique(vec_hourly); clear index
for index = 1:numel(measures)
    fprintf('codMeasure %3i\n',measures(index))
end;
clear index;

%% GET DATA FOR SPECIFIC POLLUTANTS & STATION ----------------------------
pollutantCode = 08;        % NO2 micrograms/m3  
pollutantCode = 09;        % Particles < 2.5 micra  
pollutantCode = 14;        % O3 micrograms/m3  

stationCode   = 28079050;  % Plaza de Castilla  -> Alta.- 08/02/2010 (00:00 h.)
stationCode   = 28079056;  % Pza. Fdez. Ladreda -> Alta.- 18/01/2010 (12:00 h.)




%% ---------------------------------------------------------------------------------------------
stationCode   = 28079056;
pollutantCode = 08;

params.kindData2Read = 'H';

[ pollutantAndStationData, tsPollutSta ] = extractDataPollution_v01( pollutionData_hourly, ...
                                                                     params.kindData2Read,...
                                                                     pollutantCode,...
                                                                     stationCode);

%Save data in CSV file, in format 01 & 02 -------------------------------------------------------
% each line is the data for the hourly data of one day of one pollutant in one statation 
pollutantCodeStr = sprintf('%02i',pollutantCode);
stationCodeStr   = sprintf('%02i',stationCode);

% Save data in a CSV file, in format 01
% each line is the data for the hourly data of one day of one pollutant in one statation 
filenameF01 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_F01.csv'));  

% Save data in a CSV file, in format 02
% each line is the data of one hour of one day of one pollutant in one statation 
filenameF02 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_F02.csv'));  

filenameF03 = fullfile(params.pollutantsFolder,strcat('ts_PC_',pollutantCodeStr,'_SC_',stationCodeStr,'_F03.csv'));  

saveDataPollutantStation(pollutantAndStationData,tsPolSta,filenameF01,filenameF02, filenameF03);
    
% SHOW GRAPHICS ---------------------------------------------------------------------------------

filenameFig01 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_figure_01'));  
filenameFig02 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_figure_02'));  

showFiguresDataPollutantStation(tsPolSta,filenameFig01,filenameFig02);
%% ----------------------------------------------------------------------------------
%{
pollutantCode = 08;        % NO2 micrograms/m3  
pollutantCode = 09;        % Particles < 2.5 micra  
pollutantCode = 14;        % O3 micrograms/m3  

stationCode   = 28079050;  % Plaza de Castilla  -> Alta.- 08/02/2010 (00:00 h.)
stationCode   = 28079056;  % Pza. Fdez. Ladreda -> Alta.- 18/01/2010 (12:00 h.)
%}


%% SHOW GRAPHICS






