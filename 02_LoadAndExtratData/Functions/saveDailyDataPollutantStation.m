function [ funcError ] = saveDailyDataPollutantStation( pollutantAndStationData,tsPolSta,...
                                                   filenameF01,filenameF02, filenameF03, filenameF04)

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    funcError = 0;
   
    %%  Save data in a CSV file, in format 01
    % each line is the data for the hourly data of one day of one pollutant in one statation 
    fid = fopen(filenameF01,'w');
    if (fid > -1)
        tsIndex = 0;
        for index = 1:numel(    pollutantAndStationData)
            s = pollutantAndStationData(index);

            fprintf(fid,'%08i',s.codStationP3);
            fprintf(fid,' %02i',s.codMeasure);
            fprintf(fid,' %02i',s.codTechnique);
            fprintf(fid,' %02i',s.codPeriod);
            fprintf(fid,' %02i',s.codDate.year);
            fprintf(fid,' %02i',s.codDate.month);
            
            nDaysMonth = getNumDaysMonth( s.codDate.year , s.codDate.month );
            
            for d = 1:nDaysMonth
                fprintf(fid,' %05i',s.codDate.day{d}.value);
                %fprintf(fid,' %1s' ,s.codDate.day{d}.valid);
            end
            fprintf(fid,'\n');

        end
        fclose(fid);

    else 
        fprintf('\nError opening file   %s\n',filenameF01);
    end

    
    %%  Save data in a CSV file, in format 02
    % each line is the data of one hour of one day of one pollutant in one statation 
    
    fid = fopen(filenameF02,'w');

    if (fid > -1)
        tsIndex = 0;
        for index = 1:numel(tsPolSta)
            s = tsPolSta(index);

            fprintf(fid,'%08i',s.codStationP3);
            fprintf(fid,' %02i',s.codMeasure);
            fprintf(fid,' %02i',s.codTechnique);
            fprintf(fid,' %02i',s.codPeriod);
            fprintf(fid,' %02i',s.codDate.year);
            fprintf(fid,' %02i',s.codDate.month);
            fprintf(fid,' %02i',s.codDate.day);
            fprintf(fid,' %05i',s.value);
            fprintf(fid,' %1s' ,s.valid);

            fprintf(fid,'\n');

        end
        fclose(fid);
    else 
        fprintf('\nError opening file   %s\n',filenameF02);
    end
    
     %%  Save data in a CSV file, in format 03
     
    fid = fopen(filenameF03,'w');

    if (fid > -1)
        tsIndex = 0;
        for index = 1:numel(tsPolSta)
            s = tsPolSta(index);

            %fprintf(fid,'%08i',s.codStationP3);
            %fprintf(fid,' %02i',s.codMeasure);
            %fprintf(fid,' %02i',s.codTechnique);
            %fprintf(fid,' %02i',s.codPeriod);
            %fprintf(fid,' %02i',s.codDate.year);
            %fprintf(fid,' %02i',s.codDate.month);
            %fprintf(fid,' %02i',s.codDate.day);
            fprintf(fid,' %05i',s.value);
            %fprintf(fid,' %1s' ,s.valid);

            fprintf(fid,'\n');

        end
        fclose(fid);
    else 
        fprintf('\nError opening file   %s\n',filenameF03);
    end
     %%  Save data in a CSV file, in format 04
    fid = fopen(filenameF04,'w');

    if (fid > -1)
        tsIndex = 0;
        for index = 1:numel(tsPolSta)
            s = tsPolSta(index);

            %fprintf(fid,'%08i',s.codStationP3);
            %fprintf(fid,' %02i',s.codMeasure);
            %fprintf(fid,' %02i',s.codTechnique);
            %fprintf(fid,' %02i',s.codPeriod);
            %fprintf(fid,' %02i',s.codDate.year);
            %fprintf(fid,' %02i',s.codDate.month);
            %fprintf(fid,' %02i',s.codDate.day);
            fprintf(fid,' %05i',s.value);
            fprintf(fid,' %1s' ,s.valid);

            fprintf(fid,'\n');

        end
        fclose(fid);
    else 
        fprintf('\nError opening file   %s\n',filenameF04);
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