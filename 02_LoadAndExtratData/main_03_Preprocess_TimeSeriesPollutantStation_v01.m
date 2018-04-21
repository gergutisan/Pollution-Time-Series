%% ---------------------------------------------------------------------------------------
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
%    'pollutionData_hourly_2012-2015.mat'
%    'pollutionData_daily_2012-2015.mat'
filenameHourly  = fullfile(params.hourlyDataFolder, 'pollutionData_hourly_2012-2016.mat');
filenameDaily   = fullfile(params.dailyDataFolder , 'pollutionData_daily_2012-2016.mat');

%% pre-process hourly data ---------------------------------------------------------------
% Lets pre-process hourly data (valid and not valid values)

fprintf('Pre-process hourly data\n')
pollutantsCodesCellArray = {08  , 09 ,  14};
stationsCodesCellArray   = {047 ,050 ,056 , 059};   % {28079050 , 28079056, 28079059};

filenamePreprocess = 'filePreprocess.txt';
fId = fopen(strcat(params.pollutantsFolder,'/', filenamePreprocess),'w');


numYearsBack = 0; 
numYearsBackStr = sprintf('%02d',numYearsBack);

for pIndex = 1:numel(pollutantsCodesCellArray)
    
    pollutantCode    = pollutantsCodesCellArray{pIndex};
    pollutantCodeStr = sprintf('%02i',pollutantCode);

    h1 = figure('Name',strcat("TS raw data PC ", pollutantCodeStr," ", numYearsBackStr," years back "  ) );
    h2 = figure('Name',strcat("TS preprocessed raw data PC ", pollutantCodeStr," ", numYearsBackStr," years back "  ) );

    for sIndex = 1:numel(stationsCodesCellArray)

        stationCodeP3 = stationsCodesCellArray{sIndex};
        stationCodeP3Str = sprintf('%02i',stationCodeP3);
        
        fprintf('Pre-process PC %s  SC %s  yB %d \n', pollutantCodeStr , stationCodeP3Str, numYearsBack );
        fprintf(fId,'Pre-process PC %s  SC %s  yB %d \n', pollutantCodeStr , stationCodeP3Str, numYearsBack );         
                         

        % Hourly Data  ---------------------------------------------------------------------------------
        params.kindData2Read = 'H';
        clear pollutantAndStationData tsPollutSta
        [ pollutantAndStationData, tsPollutSta_H, numElements01, numElements02  ] = ...
                                           extractDataPollution_v01( pollutionData_hourly, ...
                                                                     params.kindData2Read,...
                                                                     pollutantCode,...
                                                                     stationCodeP3);
        
        % Hourly Data  ---------------------------------------------------------------------------------

        if ( numElements02 > 0 ) % && ( numElements02 > (365*24*numYearsBack) )

            if (numYearsBack == 0 )
                tsPollutantStation_H = tsPollutSta_H( (1:numElements02));
            else
                tsPollutantStation_H = tsPollutSta_H( (numElements02 - (365*24*numYearsBack)):numElements02);
            end
            
            clear tsPollutSta_H;
            
            ts_Data = zeros(1,numel(tsPollutantStation_H) );
            ts_Data_2 = zeros(1,numel(tsPollutantStation_H) );
                %ts_Data = struct('value', cell( 1,numel(tsPollutantStation_H) ) ,...
                %                 'valid', cell( 1,numel(tsPollutantStation_H) ) );

            nNotValid = 0;
            fprintf('\t%6s %2s %2s %2s %2s\n', 'value', 'yy', 'mm', 'dd', 'hh');
            fprintf(fId,'\t%6s %2s %2s %2s %2s\n', 'value', 'yy', 'mm', 'dd', 'hh');
            
            mean = 0; k = 0;
            for i = 1:numel(tsPollutantStation_H)
                
                ts_DataStruct(i) = tsPollutantStation_H(i);
                
                ts_Data(i) = tsPollutantStation_H(i).value;
                valid = tsPollutantStation_H(i).valid;
                
                if ( valid == 'V' )
                    ts_Data_2(i) = ts_Data(i);
                    mean = mean*(k/(k+1)) + ts_Data(i)/(k+1);  % recursive version ofthe mean
                    k = k + 1;
                
                elseif ( valid ~= 'V' )
                    
                    ts_DataStruct(i) = tsPollutantStation_H(i);
                    
                    nNotValid = nNotValid + 1;
                    value = ts_Data(i);
                    yy = tsPollutantStation_H(i).codDate.year;
                    mm = tsPollutantStation_H(i).codDate.month;
                    dd = tsPollutantStation_H(i).codDate.day;
                    hh = tsPollutantStation_H(i).codDate.hour;
                    fprintf('\t%06.0f %2d %2d %2d %2d\n', value, yy, mm, dd, hh);
                    fprintf(fId,'\t%06.0f %2d %2d %2d %2d\n', value, yy, mm, dd, hh);    
                    
                    ts_Data_2(i) = mean;
                    ts_DataStruct(i).value = mean;
                    ts_DataStruct(i).valid = 'P';
                    
                
                end
                % change ts_Data(i).value = ...
            end
            figure(h1);
            subplot(2,2,sIndex); plot(ts_Data);
            title(strcat("PC ", pollutantCodeStr ," ", ...
                         "SC ", stationCodeP3Str ) );
            
            figure(h2);
            subplot(2,2,sIndex); plot(ts_Data_2);
            title(strcat("PreProc PC ", pollutantCodeStr ," ", ...
                         "SC ", stationCodeP3Str ) );

                     
            fprintf('   -> notV %07d of %07d (%.2f prctg)\n',... 
                     nNotValid , numel(tsPollutantStation_H) ,...
                     100*(nNotValid/numel(tsPollutantStation_H) ) );
            fprintf(fId,'   -> notV %07d of %07d (%.2f prctg)\n',... 
                     nNotValid , numel(tsPollutantStation_H) ,...
                     100*(nNotValid/numel(tsPollutantStation_H) ) );     
            clear ts_Data;
            
            % -------------------------------------------
            filenamePreprocessData = strcat(params.pollutantsFolder,'/',...
                                            "ts_PC_",pollutantCodeStr,"_SC_",stationCodeP3Str,"_H_preprocessed.dat");
            fId2 =fopen(filenamePreprocessData,'w'); 
            
            for i = 1:numel(ts_Data_2)
                fprintf(fId2,'%08.2f\n',ts_Data_2(i)); 
            
            end
            fclose(fId2);
            
            % ---------------------------------------------
            filenamePreprocessData = strcat(params.pollutantsFolder,'/',...
                                            "ts_PC_",pollutantCodeStr,"_SC_",stationCodeP3Str,"_H_preprocessed_Format01.dat");
            fId3 =fopen(filenamePreprocessData,'w'); 
            
            for i = 1:numel(ts_Data_2)
                
                yy = ts_DataStruct(i).codDate.year;
                mm = ts_DataStruct(i).codDate.month;
                dd = ts_DataStruct(i).codDate.day;
                hh = ts_DataStruct(i).codDate.hour;
                value = ts_DataStruct(i).value;
                fprintf(fId3,'%02d %02d %02d %02d %05d\n',yy , mm , dd ,  hh , value); 
            end
            fclose(fId3);
                
                
                
        
        else
            t = 1:numel(tsPollutantStation_H);
            %ts_Data = zeros(1,numel(tsPollutantStation_H));
            
            figure(h1);
            subplot(2,2,sIndex);plot(t,0);
            title(strcat("PC ", pollutantCodeStr ," not measured at ", ...
                         'SC ', stationCodeP3Str ) );

            figure(h2);
            subplot(2,2,sIndex);plot(t,0);
            title(strcat("PreProc PC ", pollutantCodeStr ," not measured at ", ...
                         'SC ', stationCodeP3Str ) );                     
                     
        end
        
        clear ts_Data ts_Data_2;
    fprintf('\n');
    

    end
    figure(h1)
    filename = strcat(params.pollutantsFolder,'/','ts_PC',pollutantCodeStr,"_",numYearsBackStr,"yB");
    h1.PaperPositionMode = 'auto';
    h1.PaperOrientation  = 'landscape';
    print('-bestfit',filename,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')
    
    figure(h2)
    filename = strcat(params.pollutantsFolder,'/','ts_PC',pollutantCodeStr,"_",numYearsBackStr,"yB_preprocessed");
    h2.PaperPositionMode = 'auto';
    h2.PaperOrientation  = 'landscape';
    print('-bestfit',filename,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')
    
    
    % fprintf('Program paused. Press any key.');
    % pause;fprintf('\n');
    
    close all
    
    
end

fclose(fId);

close all;



%% -------------------------------------------------------------------------------------
%     
% for pIndex = 1:numel(pollutantsCodesCellArray)
%     
%     pollutantCode = pollutantsCodesCellArray{pIndex};
%     pollutantCodeStr = sprintf('%02i',pollutantCode);
% 
%     h1 = figure('Name',strcat("TS raw data PC ", pollutantCodeStr," ", numYearsBackStr," years back "  ) );
% 
%     for sIndex = 1:numel(stationsCodesCellArray)
% 
%         stationCodeP3 = stationsCodesCellArray{sIndex};
%         stationCodeP3Str = sprintf('%02i',stationCodeP3);
% 
%         % Hourly Data  ---------------------------------------------------------------------------------
%         params.kindData2Read = 'H';
%         clear pollutantAndStationData tsPollutSta
%         [ pollutantAndStationData, tsPollutSta_H, numElements ] = ...
%                                            extractDataPollution_v01( pollutionData_hourly, ...
%                                                                      params.kindData2Read,...
%                                                                      pollutantCode,...
%                                                                      stationCodeP3);
%         % Hourly Data  
% 
%         if ( numElements > 0 ) && ( numElements > (365*numYearsBack) )
% 
%             tsPollutantStation_H = tsPollutSta_H( (numElements - (365*numYearsBack)):numElements);
% 
%             ts_Data = struct('value', cell( 1,numel(tsPollutantStation_H));
%             for i = 1:numel(tsPollutantStation_H)
%                 ts_Data(i) = tsPollutantStation_H(i).value;
%             end
% 
%             subplot(2,2,sIndex); plot(ts_Data);
%             title(strcat("PC ", pollutantCodeStr ," ", ...
%                          "SC ", stationCodeP3Str ) );
% 
%             clear ts_Data;    
%         else
%             t = 1:numel(tsPollutantStation_H);
%             %ts_Data = zeros(1,numel(tsPollutantStation_H));
%             subplot(2,2,sIndex);plot(t,0);
%             title(strcat("PC ", pollutantCodeStr ," not measured at ", ...
%                          'SC ', stationCodeP3Str ) );
% 
%         end
% 
%     end
%     
%     filename = strcat(params.pollutantsFolder,'/','ts_PC',pollutantCodeStr,"_",numYearsBackStr,"yB");
%     h1.PaperPositionMode = 'auto';
%     h1.PaperOrientation  = 'landscape';
%     print('-bestfit',filename,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')
%     
% end
% 
% close all;

