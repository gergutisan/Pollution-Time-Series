%% Note of the author
%{
  if Data_Daily/pollutionData_hourly_2012-201x.mat and
     Data_Hourly/pollutionData_daily_2012-201x.mat 
    
  do not exist then execute:   main_01_LoadPollutionData_v0X.m   (X = 1 or 2, 2 best)

%}

%% 
clearvars -EXCEPT pollutionData_daily pollutionData_hourly % to be faster while debugging
clc; close all; fclose('all');

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

%% VARIABLES ---------------------------------------------
params.debuggingLevel = 5;
params.kindData2Read = 'D'; 
params.kindData2Read = 'H';
% Data filenames
%    'pollutionData_hourly_2012-2015.mat'
%    'pollutionData_daily_2012-2015.mat'
filenameHourly  = fullfile(params.hourlyDataFolder, 'pollutionData_hourly_2012-2016.mat');
filenameDaily   = fullfile(params.dailyDataFolder , 'pollutionData_daily_2012-2016.mat');

%% STEP 1 - LOAD DATA STEP

if (computationStep(1) == 1 )

    if ( exist('pollutionData_daily','var') ~= 1 )
        fprintf('Loading pollutionData_daily ... ');  
        initTime = cputime;

        % Improve 2 be done : check if filenameDaily exists, 
        %                     if not call: 
        %                     params.kindData2Read = 'D'; 
        %                     [ pollutionData_daily, numAllMeasures]  = loadPollutionData_v02(params);   % the content that as seq of digits is read as a number

        load(filenameDaily);     % load -> pollutionData_daily
                                 % the only content of the *.mat file is the variable which name is pollutionData
        fprintf(' It takes %6.6f s\n',cputime - initTime); clear initTime;               
    end


    if ( exist('pollutionData_hourly','var') ~= 1 )
        fprintf('Loading pollutionData_hourly ... ');  
        initTime = cputime;

        % Improve 2 be done : check if filenameDaily exists, 
        %                     if not call: 
        %                     params.kindData2Read = 'H'; 
        %                     [ pollutionData_hourly, numAllMeasures]  = loadPollutionData_v02(params);   % the content that as seq of digits is read as a number


        load(filenameHourly);     % load -> pollutionData_hourly
                            % the only content of the *.mat file is the variable which name is pollutionData
        fprintf(' It takes %6.6f s\n',cputime - initTime); clear initTime;               
    end

end

%% POLLUTANTS INFORMATION ------------------------------------------
% Interesting Pollutants: PM < 2.5 micras; Ozone (O3); NO2 (nitrogen dioxide)
% NO2 (nitrogen dioxide) -> http://www.mambiente.munimadrid.es/opencms/export/sites/default/calaire/Anexos/Protocolo_NO2.pdf
%   Protocolo de medidas a adoptar durante episodios de alta contaminación por dióxido de nitrógeno
%   Aprobado por la Junta de Gobierno de la ciudad de Madrid de 21 de enero de 2016.
%       http://www.mambiente.munimadrid.es/opencms/export/sites/default/calaire/Anexos/Protocolo_NO2.pdf

%  PM < 2.5 micras  (µg/m3)        -> code 09 
%  Ozone (O3)       (µg/m3)        -> code 14
%  NO2 (nitrogen dioxide) (µg/m3)  -> code 08

%% SHOW THE POLLUTANTS WHICH MEASURES ARE IN THE DATA ----------------

% Note: the values within pollutionData structure are numbers (not arrays of chars)
%       functions: unique, histc, accumarray

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
    
    clear i;
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
    
    clear i;    

%% GET DATA FOR SPECIFIC POLLUTANTS & STATION ----------------------------
pollutantCode = 08;        % NO2 micrograms/m3  
pollutantCode = 09;        % PM2.5 Particles < 2.5 micra  
pollutantCode = 14;        % O3 micrograms/m3  

stationCode   = 28079050;  % Plaza de Castilla  -> Alta.- 08/02/2010 (00:00 h.)
stationCode   = 28079056;  % Pza. Fdez. Ladreda -> Alta.- 18/01/2010 (12:00 h.)

%% extractDataPollution_v01            ---------------------------------------
%{
    % pollutantCode = 08;        % NO2 micrograms/m3  
    % pollutantCode = 09;        % PM2.5 Particles < 2.5 micra  
    % pollutantCode = 14;        % O3 micrograms/m3  

    % stationCode   = 28079050;  % Plaza de Castilla  -> Alta.- 08/02/2010 (00:00 h.)
    % stationCode   = 28079056;  % Pza. Fdez. Ladreda -> Alta.- 18/01/2010 (12:00 h.)

    stationCode   = 056;  % 28079056 -> 28 079 056
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

    saveHourlyDataPollutantStation(pollutantAndStationData,tsPollutSta,filenameF01,filenameF02, filenameF03);

    % SHOW GRAPHICS ---------------------------------------------------------------------------------

    filenameFig01 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_figure_01'));  
    filenameFig02 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeStr,'_figure_02'));  

    showFiguresDataPollutantStation(tsPollutSta,'daily',filenameFig01,filenameFig02);
%}

%% STEP 2 TRANSLATE ARRAY OF STRUCTS IN TS DATA AND ITS FIGURES---------------------------------

if (computationStep(2) == 1 )

    for pIndex = 1:numel(pollutantsCodesCellArray)

        pollutantCode = pollutantsCodesCellArray{pIndex};

        for sIndex = 1:numel(stationsCodesCellArray)

            stationCodeP3 = stationsCodesCellArray{sIndex};

            pollutantCodeStr = sprintf('%02i',pollutantCode);
            stationCodeP3Str = sprintf('%02i',stationCodeP3);

            fprintf('\npollutantCodeStr %s  --  stationCodeStr %s \n',pollutantCodeStr,stationCodeP3Str);
            close('all');


            % Daily Data  ---------------------------------------------------------------------------------
            params.kindData2Read = 'D';
            clear pollutantAndStationData tsPollutSta

            [ pollutantAndStationData, tsPollutSta_D, numElements_01, numElements_02 ] = extractDataPollution_v01( pollutionData_daily, ...
                                                                                 params.kindData2Read,...
                                                                                 pollutantCode,...
                                                                                 stationCodeP3);
            if (numElements_01 == 0)

                fprintf('\n No data for pollutantCode %s   & stationCode %s\n',pollutantCodeStr,stationCodeP3Str);
                continue;

            end

            %Save data in CSV file, in format 01 & 02  & 03 & 04 -------------------------------------------------------
            % each line is the data for the hourly data of one day of one pollutant in one statation 
            pollutantCodeStr = sprintf('%02i',pollutantCode);
            stationCodeP3Str = sprintf('%02i',stationCodeP3);

            % Save data in a CSV file, in format 01
            % each line is the data for the hourly data of one day of one pollutant in one statation 
            filenameF01 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeP3Str,'_',params.kindData2Read ,'_tableFormat.dat'));  
            % Save data in a CSV file, in format 02
            % each line is the data of one hour of one day of one pollutant in one statation 
            filenameF02 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeP3Str,'_',params.kindData2Read ,'_tsFormat_02.dat'));  

            % Save data in a CSV file, in format 03
            filenameF03 = fullfile(params.pollutantsFolder,strcat('ts_PC_',pollutantCodeStr,'_SC_',stationCodeP3Str,'_',params.kindData2Read ,'_tsFormat_03.dat'));  

            % Save data in a CSV file, in format 04
            filenameF04 = fullfile(params.pollutantsFolder,strcat('ts_PC_',pollutantCodeStr,'_SC_',stationCodeP3Str,'_',params.kindData2Read ,'_tsFormat_04.dat'));  

            saveDailyDataPollutantStation(pollutantAndStationData,tsPollutSta_D,filenameF01,filenameF02, filenameF03, filenameF04);

            % show grpahics  ---------------------------------------------------------------------------------

            filenameFig01 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeP3Str,'_',params.kindData2Read ,'_figure_01'));  
            filenameFig02 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeP3Str,'_',params.kindData2Read ,'_figure_02'));  
            showFiguresDataPollutantStation(tsPollutSta_D,'d',filenameFig01,filenameFig02);                                                                 


            % ------------------------------------------------------------------------------------------------
            % Hourly Data  ---------------------------------------------------------------------------------

            params.kindData2Read = 'H';
            clear pollutantAndStationData tsPollutSta
            [ pollutantAndStationData, tsPollutSta_H,numElements_01, numElements_02 ] = extractDataPollution_v01( pollutionData_hourly, ...
                                                                         params.kindData2Read,...
                                                                         pollutantCode,...
                                                                         stationCodeP3);

            %Save data in CSV file, in format 01 & 02 & 03 & 04  -------------------------------------------------------
            % each line is the data for the hourly data of one day of one pollutant in one statation 
            pollutantCodeStr = sprintf('%02i',pollutantCode);
            stationCodeP3Str   = sprintf('%02i',stationCodeP3);

            % Save data in a CSV file, in format 01
            % each line is the data for the hourly data of one day of one pollutant in one statation 
            filenameF01 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeP3Str,'_',params.kindData2Read ,'_tableFormat.dat'));  
            % Save data in a CSV file, in format 02
            % each line is the data of one hour of one day of one pollutant in one statation 
            filenameF02 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeP3Str,'_',params.kindData2Read ,'_tsFormat_02.dat'));  

            % Save data in a CSV file, in format 03
            filenameF03 = fullfile(params.pollutantsFolder,strcat('ts_PC_',pollutantCodeStr,'_SC_',stationCodeP3Str,'_',params.kindData2Read ,'_tsFormat_03.dat'));  

            % Save data in a CSV file, in format 04
            filenameF04 = fullfile(params.pollutantsFolder,strcat('ts_PC_',pollutantCodeStr,'_SC_',stationCodeP3Str,'_',params.kindData2Read ,'_tsFormat_04.dat')); 
            saveHourlyDataPollutantStation(pollutantAndStationData,tsPollutSta_H,filenameF01,filenameF02, filenameF03, filenameF04);

            % SHOW GRAPHICS ---------------------------------------------------------------------------------

            filenameFig01 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeP3Str,'_',params.kindData2Read ,'_figure_01'));  
            filenameFig02 = fullfile(params.pollutantsFolder,strcat('pollutant_',pollutantCodeStr,'_Station_',stationCodeP3Str,'_',params.kindData2Read ,'_figure_02'));  
            showFiguresDataPollutantStation(tsPollutSta_H,'h',filenameFig01,filenameFig02);   


        end
    end

end

close all;

%% -----------------------------------------

% Lets SHOW hourly data from 1 year Back to several years back
if computationStep(3) == 1
    
    for numYearsBack = 1:5
        numYearsBackStr = sprintf('%02d',numYearsBack);
        for pIndex = 1:numel(pollutantsCodesCellArray)

            pollutantCode = pollutantsCodesCellArray{pIndex};
            pollutantCodeStr = sprintf('%02i',pollutantCode);

            h1 = figure('Name',strcat("TS raw data PC ", pollutantCodeStr," ", numYearsBackStr," years back "  ) );
            for sIndex = 1:numel(stationsCodesCellArray)

                stationCodeP3 = stationsCodesCellArray{sIndex};
                stationCodeP3Str = sprintf('%02i',stationCodeP3);
                
                % 
                fprintf('yB %02d  PC %2d  SC %03\n',numYearsBackStr );

                % Hourly Data  ---------------------------------------------------------------------------------
                params.kindData2Read = 'H';
                clear pollutantAndStationData tsPollutSta
                [ pollutantAndStationData, tsPollutSta_H, numElements_01, numElements_02 ] = extractDataPollution_v01( pollutionData_hourly, ...
                                                                             params.kindData2Read,...
                                                                             pollutantCode,...
                                                                             stationCodeP3);

                if ( numElements_02 > 0 ) && ( numElements_02 > 365*24*numYearsBack )

                    tsPollutantStation_H = tsPollutSta_H( (numElements_02 - (365*24*numYearsBack)):numElements_02);

                    ts_Data = zeros(1,numel(tsPollutantStation_H));
                    for i = 1:numel(tsPollutantStation_H)
                        ts_Data(i) = tsPollutantStation_H(i).value;
                    end

                    subplot(2,2,sIndex); plot(ts_Data);
                    title(strcat("PC ", pollutantCodeStr ," ", ...
                                 "SC ", stationCodeP3Str ) );

                    clear ts_Data;    
                else
                    t = 1:numel(tsPollutantStation_H);
                    %ts_Data = zeros(1,numel(tsPollutantStation_H));
                    subplot(2,2,sIndex);plot(t,0);
                    title(strcat("PC ", pollutantCodeStr ," not measured at ", ...
                                 'SC ', stationCodeP3Str ) );

                end

            end


            filename = strcat(params.pollutantsFolder,'/','ts_PC',pollutantCodeStr,"_",numYearsBackStr,"yB");
            h1.PaperPositionMode = 'auto';
            h1.PaperOrientation  = 'landscape';
            print('-bestfit',filename,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')

        end
        close all
    end
end

%% -----------------------------------------
clearvars -EXCEPT pollutionData_daily pollutionData_hourly % to be faster while debugging
close all;
fprintf('\n END OF PROGRAM \n');






