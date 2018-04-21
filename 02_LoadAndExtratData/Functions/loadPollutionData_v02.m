function [ pollutionData , numAllMeasures] = loadPollutionData_v02(params) 
%{
  To complete
%}

    
if     (params.kindData2Read == 'D')     
    %% READING THE DAILY DATA
    
    index = 0;
    initYear = params.yearsCellArray{1};
    lastYear = params.yearsCellArray{numel(params.yearsCellArray)};
    for yearIndex = initYear:lastYear
        anioFolder = strcat(params.rootAnioFolder,num2str(yearIndex));
        yearLong = num2str(yearIndex);
        yearShort = str2num(yearLong(3:4));
        
        yearFilename = fullfile(params.dailyDataFolder,anioFolder,strcat('anio',yearLong,'.txt'));
        
        fid = fopen(yearFilename,'r');
        if (fid >= 3)
            
            if (params.debuggingLevel >= 2)
                fprintf('File %s is open, reading it...\n',yearFilename);
            end
            while (feof(fid) ~= 1)
                    tline = fgetl(fid);
                    % disp(tline);
                    index = index + 1;                  

                    pollutionData(index).codStationP1  = str2num( tline( 01:02 ) );  % number
                    pollutionData(index).codStationP2  = str2num( tline( 03:05 ) );  % number
                    pollutionData(index).codStationP3  = str2num( tline( 06:08 ) );  % number
                    pollutionData(index).codMeasure    = str2num( tline( 09:10 ) );  % number
                    pollutionData(index).codTechnique  = str2num( tline( 11:12 ) );  % number
                    pollutionData(index).codPeriod     = str2num( tline( 13:14 ) );  % number %note: 02 -> hourly data;  04 -> daily data
                    
                    pollutionData(index).codDate.year  = str2num( tline( 15:16 ) );  % number year 
                    pollutionData(index).codDate.month = str2num( tline( 17:18 ) );  % number month
                    if (yearIndex < 2011)
                        tmpCode = str2num( tline( 19:20 ) );   % 00 eliminated from 2011
                        dig = 21;
                    else 
                        dig = 19;
                    end
                    
                    
                    year  = pollutionData(index).codDate.year;
                    month = pollutionData(index).codDate.month;
                    nDaysMonth = getNumDaysMonth( year , month );
                    clear year month
                    
                    pollutionData(index).codDate.day = cell(nDaysMonth,1); 
                    
                    for iDay = 1:nDaysMonth
                        str = tline( dig:(dig + 4) );
                        pollutionData(index).codDate.day{iDay}.value = str2double(str); % number VALUE OF THE MEASURE
                        %pollutionData(index).codDate.days{iDay}.value = str2double( tline( dig:(dig + 4) ) ); % number VALUE OF THE MEASURE
                        pollutionData(index).codDate.day{iDay}.valid = tline( dig + 5);                      % alphanumeric
                        dig = ((dig + 4) + 1) + 1;
                    end

             end % end of the file for a month

            fclose(fid);
            if (params.debuggingLevel >= 2)
                fprintf('File %s already closed\n',yearFilename);
            end
            
        end
    end
    
    numAllMeasures = index; 
    clear index;    

elseif (params.kindData2Read == 'H')
    %% READING THE HOURLY DATA
    index = 0;
    initYear = params.yearsCellArray{1};
    lastYear = params.yearsCellArray{numel(params.yearsCellArray)};
    

    for yearIndex = initYear:lastYear
        anioFolder = strcat(params.rootAnioFolder,num2str(yearIndex));
        str = num2str(yearIndex);
        yearShort = str2num(str(3:4));
      
        
        for iMonth = 1:numel(params.monthsCellArray)
            monthStr = params.monthsCellArray{iMonth};
            monthFilename = fullfile(params.hourlyDataFolder,anioFolder,strcat(monthStr,'_mo',sprintf('%2i',yearShort),'.txt'));

            fid = fopen(monthFilename,'r');
            if (fid >= 3)
                if (params.debuggingLevel >= 2)
                    fprintf('File %s is open, reading it...\n',monthFilename);
                end

                while (feof(fid) ~= 1)
                    tline = fgetl(fid);
                    % disp(tline);
                    index = index + 1;                  

                    
                    pollutionData(index).codStationP1  = str2num( tline( 01:02 ) );  % number
                    pollutionData(index).codStationP2  = str2num( tline( 03:05 ) );  % number
                    pollutionData(index).codStationP3  = str2num( tline( 06:08 ) );  % number
                    
                    pollutionData(index).codMeasure    = str2num( tline( 09:10 ) );  % number
                    pollutionData(index).codTechnique  = str2num( tline( 11:12 ) );  % number
                    
                    pollutionData(index).codPeriod     = str2num( tline( 13:14 ) );  % number %note: 02 -> hourly data;  04 -> daily data
                   
                    pollutionData(index).codDate.year  = str2num( tline( 15:16 ) );  % number year 
                    pollutionData(index).codDate.month = str2num( tline( 17:18 ) );  % number month
                    pollutionData(index).codDate.day   = str2num( tline( 19:20 ) );  % number day
                    
                    dig = 21;
                    
                    for h = 1:24
                        pollutionData(index).hour(h).value = str2double( tline( dig:(dig + 4) ) ); % number VALUE OF THE MEASURE
                        pollutionData(index).hour(h).valid = tline( dig + 5);        % alphanumeric
                        dig = ((dig + 4) + 1) + 1;
                    end

                end % end of the file for a month

                fclose(fid);
                if (params.debuggingLevel >= 2)
                    fprintf('File %s already closed\n',monthFilename);
                end

            end

        end % end of all the month

    end % end of all the years
    numAllMeasures = index; clear index;
end

    
    

end


%% LOCAL FUNCTIONS 
function nDaysMonth = getNumDaysMonth( year , month )

    switch month 
        case {1,3,5,7,8,10,12}
            nDaysMonth = 31;
            
        case {4,6,9,11}
            nDaysMonth = 30;
            
        case {2}
           if checkIsLeapYear(year) == 0  % built-in function from R2006a   
               nDaysMonth = 28;
           else
               nDaysMonth = 29;
           end
            
    end

end

