function [ pollutionData , numAllMeasures] = loadPollutionData_v01(params) 

    %% READING THE DAILY DATA
    index = 0;
    initYear = params.yearsCellArray{1};
    lastYear = params.yearsCellArray{numel(params.yearsCellArray)};

    for yearLong = initYear:lastYear
        anioFolder = strcat(params.rootAnioFolder,num2str(yearLong));
        str = num2str(yearLong);
        yearShort = str2num(str(3:4));

        for iMonth = 1:12
            monthStr = params.monthsCellArray{iMonth};
            monthFilename = fullfile(params.hourlyDataFolder,anioFolder,strcat(monthStr,'_mo',sprintf('%2i',yearShort),'.txt'));

            fid = fopen(monthFilename,'r');
            if (fid >= 3)
                if (params.debuggingLevel >= 2)
                    fprintf('File %s is open, reading it...\n',monthFilename);
                end;

                while (feof(fid) ~= 1)
                    tline = fgetl(fid);
                    % disp(tline);
                    index = index + 1;                  

                    pollutionData(index).codStation    = tline( 01:08 );  % number
                    pollutionData(index).codMeasure    = tline( 09:10 );  % number
                    pollutionData(index).codTechnique  = tline( 11:12 );  % number
                    pollutionData(index).codPeriod     = tline( 13:14 );  % number %note: 02 -> hourly data;  04 -> daily data
                    pollutionData(index).codDate.year  = tline( 15:16 );  % number year 
                    pollutionData(index).codDate.month = tline( 17:18 );  % number month
                    pollutionData(index).codDate.day   = tline( 19:20 );  % number day
                    dig = 21;
                    for h = 1:24
                        pollutionData(index).hour(h).value = tline( dig:(dig + 4) ); % number VALUE OF THE MEASURE
                        pollutionData(index).hour(h).valid = tline( dig + 5);        % alphanumeric
                        dig = (dig + 4) + 1 + 1;
                    end;

                end; % end of the file for a month

                fclose(fid);
                if (params.debuggingLevel >= 2)
                    fprintf('File %s already closed\n',monthFilename);
                end;

            end;

        end; % end of all the month

    end; % end of all the years
    numAllMeasures = index; clear index;

end