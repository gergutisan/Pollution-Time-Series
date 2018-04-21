clearvars -EXCEPT pollutionData % to be faster while debugging
clc; close all; fclose('all');

%% FOLDERS AND FILENAMES ---------------------------------
params.dailyDataFolder  = 'Data_Daily';
params.hourlyDataFolder = 'Data_Hourly';
params.rootAnioFolder   = 'Anio';

params.pollutantsFolder = 'Pollutants';

%% VARIABLES ---------------------------------------------
params.debuggingLevel = 5;
filename  = fullfile(params.hourlyDataFolder,'pollutionData_2012-2015.mat');

%% LOAD DATA  

if ( exist('pollutionData','var') ~= 1 )
    fprintf('Loading pollutionData ... ');  
    initTime = tic;
    load(filename);     % load -> pollutionData
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

%% Show the pollutants which measures are within the data ----------------
numAllMeasuresDay = numel(pollutionData);
vec = zeros(1,numAllMeasuresDay);
for index = 1:numAllMeasuresDay 
    vec(index) = pollutionData(index).codMeasure;
end;
measures = unique(vec); clear index
for i = 1:numel(measures)
    fprintf('codMeasure %3i\n',measures(i))
end;
clear i;

%% GET DATA FOR SPECIFIC POLLUTANTS & STATION ----------------------------
pollutantCode = 08;
stationCode   = 28079050;  % Plaza de Castilla  -> Alta.- 08/02/2010 (00:00 h.)
stationCode   = 28079056;  % Pza. Fdez. Ladreda -> Alta.- 18/01/2010 (12:00 h.)

numAllMeasuresDay = numel(pollutionData);

indexPollutantAndStation = 0;
for index = 1:numAllMeasuresDay 
    
    if ( pollutionData(index).codMeasure == pollutantCode) && ...
       ( pollutionData(index).codStation == stationCode ) 
        indexPollutantAndStation = indexPollutantAndStation + 1;
        pollutantAndStationData(indexPollutantAndStation) = pollutionData(index); 
            % THE 24 HOURLY DATA FOR A POLLUTANT AT A STATION IN ONE DAY

    end;
end;

%% TRANSFORM DATA IN Time Series format (one element of an array for each value taken from sensors)
% but store all the information for that value: station code, pollutant code, etc
s = pollutantAndStationData(1);  
% pollutantCodeStr = sprintf('%02i',s.codMeasure);
% stationCodeStr   = sprintf('%02i',s.codStation);

% Pre-Allocation & Initialization --------
lengthTS = numel( pollutantAndStationData ) * 24;
tsPolSta = struct( 'codMeasure',    cell(1,lengthTS),...
                   'codStation',    cell(1,lengthTS),...
                   'codTechnique',  cell(1,lengthTS),...
                   'codPeriod',     cell(1,lengthTS),...
                   'codDate',       cell(1,lengthTS),...
                   'value',         cell(1,lengthTS),...
                   'valid',         cell(1,lengthTS) );
for i =1:lengthTS
   
    tsPolSta(i).codMeasure    = 0;
    tsPolSta(i).codStation    = 0;
    tsPolSta(i).codTechnique  = 0;
    tsPolSta(i).codPeriod     = 0;
    
    tsPolSta(i).codDate.year  = 0;
    tsPolSta(i).codDate.month = 0;
    tsPolSta(i).codDate.day   = 0;
    tsPolSta(i).codDate.hour  = 0;
    
    tsPolSta(i).value    = 0;
    tsPolSta(i).valid    = 0;
    
end;

% -------------------------------------
iValue = 0;
for index = 1:numel( pollutantAndStationData)
        
    s = pollutantAndStationData(index);  
    
    for h = 1:24
        iValue = iValue + 1;
        
        tsPolSta(iValue).codMeasure     = s.codMeasure;
        tsPolSta(iValue).codStation     = s.codStation;
        tsPolSta(iValue).codTechnique   = s.codTechnique;
        tsPolSta(iValue).codPeriod      = s.codPeriod;
        tsPolSta(iValue).codDate.year   = s.codDate.year;
        tsPolSta(iValue).codDate.month  = s.codDate.month;
        tsPolSta(iValue).codDate.day    = s.codDate.day;
        % ---
        tsPolSta(iValue).codDate.hour   = h;
        tsPolSta(iValue).value          = s.hour(h).value;
        tsPolSta(iValue).valid          = s.hour(h).valid;
        
    end;
end;

%%  Save data in a CSV file, in format 01
% each line is the data for the hourly data of one day of one pollutant in one statation 
pollutantCodeStr = sprintf('%02i',pollutantCode);
stationCodeStr   = sprintf('%02i',stationCode);

filename = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_F01.csv'));  

fid = fopen(filename,'w');

if (fid > -1)
    tsIndex = 0;
    for index = 1:numel(    pollutantAndStationData)
        s = pollutantAndStationData(index);
        
        fprintf(fid,'%08i',s.codStation);
        fprintf(fid,' %02i',s.codMeasure);
        fprintf(fid,' %02i',s.codTechnique);
        fprintf(fid,' %02i',s.codPeriod);
        fprintf(fid,' %02i',s.codDate.year);
        fprintf(fid,' %02i',s.codDate.month);
        fprintf(fid,' %02i',s.codDate.day);
        for h = 1:24
            fprintf(fid,' %05i',s.hour(h).value);
            %fprintf(fid,' %1s' ,s.hour(h).valid);
        end;
        fprintf(fid,'\n');
        
    end;
    fclose(fid);
        
else 
    fprintf('\nError opening file   %s\n',filename);
end;


%%  Save data in a CSV file, in format 02
% each line is the data of one hour of one day of one pollutant in one statation 

pollutantCodeStr = sprintf('%02i',tsPolSta(1).codMeasure);
stationCodeStr   = sprintf('%02i',tsPolSta(1).codStation);

filename = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_F02.csv'));  
fid = fopen(filename,'w');

if (fid > -1)
    tsIndex = 0;
    for index = 1:numel(tsPolSta)
        s = tsPolSta(index);
        
        fprintf(fid,'%08i',s.codStation);
        fprintf(fid,' %02i',s.codMeasure);
        fprintf(fid,' %02i',s.codTechnique);
        fprintf(fid,' %02i',s.codPeriod);
        fprintf(fid,' %02i',s.codDate.year);
        fprintf(fid,' %02i',s.codDate.month);
        fprintf(fid,' %02i',s.codDate.day);
        fprintf(fid,' %02i',s.codDate.hour);
        fprintf(fid,' %05i',s.value);
        fprintf(fid,' %1s' ,s.valid);
        
        fprintf(fid,'\n');
        
    end;
    fclose(fid);
    
%% SHOW GRAPHICS

    figureSize(80); 
    
    pollutantCodeStr = sprintf('%02i',tsPolSta(1).codMeasure);
    stationCodeStr   = sprintf('%02i',tsPolSta(1).codStation);

    t = 1:numel(tsPolSta);
    for tsIndex = 1:numel(tsPolSta)
        s = tsPolSta(tsIndex);
        TS(tsIndex) = s.value;
    end;
    

    fig = figure(); 
    plot(t,TS,'.-k');
    title( ['PC ', pollutantCodeStr , ' --- ' , ' SC ', stationCodeStr ] );
    
    filename = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_figure_01'));  
    fig.PaperPositionMode = 'auto';
    fig.PaperOrientation  = 'landscape';
    print('-bestfit',filename,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')
    % saveas(h,filename);
    
    fig = figure(); 
    hoursPerDay = 24; numDays = 30;
    plot(t(1:(hoursPerDay*numDays)),TS(1:(hoursPerDay*numDays)), '.-b');
    title( ['PC ', pollutantCodeStr , ' --- ' , ' SC ', stationCodeStr ] );
    
    filename = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_figure_02.pdf'));  
    fig.PaperPositionMode = 'auto';
    fig.PaperOrientation  = 'landscape'; 
    print('-bestfit',filename,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')
    % saveas(h,filename);    
    
        
else 
    fprintf('\nError opening file   %s\n',filename);
end;

%% SHOW GRAPHICS





