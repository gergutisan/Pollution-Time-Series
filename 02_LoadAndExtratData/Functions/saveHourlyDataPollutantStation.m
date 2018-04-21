function [ funcError ] = saveDataPollutantStation( pollutantAndStationData,tsPolSta,...
                                                   filenameF01,filenameF02, filenameF03, filenameF04 )

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

            fprintf(fid,' %02i',s.codStationP1);
            fprintf(fid,' %03i',s.codStationP2);
            fprintf(fid,' %03i',s.codStationP3);
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
        fprintf('\nError opening file   %s\n',filenameF01);
    end;

    
    %%  Save data in a CSV file, in format 02
    % each line is the data of one hour of one day of one pollutant in one statation 
    
    fid = fopen(filenameF02,'w');

    if (fid > -1)
        tsIndex = 0;
        for index = 1:numel(tsPolSta)
            s = tsPolSta(index);

            fprintf(fid,' %02i',s.codStationP1);
            fprintf(fid,' %03i',s.codStationP2);
            fprintf(fid,' %03i',s.codStationP3);
            
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

            %fprintf(fid,' %02i',s.codStationP1);
            %fprintf(fid,' %03i',s.codStationP2);  
            %fprintf(fid,' %03i',s.codStationP3);
            %fprintf(fid,' %02i',s.codMeasure);
            %fprintf(fid,' %02i',s.codTechnique);
            %fprintf(fid,' %02i',s.codPeriod);
            %fprintf(fid,' %02i',s.codDate.year);
            %fprintf(fid,' %02i',s.codDate.month);
            %fprintf(fid,' %02i',s.codDate.day);
            %fprintf(fid,' %02i',s.codDate.hour);
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

            %fprintf(fid,' %02i',s.codStationP1);
            %fprintf(fid,' %03i',s.codStationP2);  
            %fprintf(fid,' %03i',s.codStationP3);
            %fprintf(fid,' %02i',s.codMeasure);
            %fprintf(fid,' %02i',s.codTechnique);
            %fprintf(fid,' %02i',s.codPeriod);
            %fprintf(fid,' %02i',s.codDate.year);
            %fprintf(fid,' %02i',s.codDate.month);
            %fprintf(fid,' %02i',s.codDate.day);
            %fprintf(fid,' %02i',s.codDate.hour);
            fprintf(fid,' %05i',s.value);
            fprintf(fid,' %1s' ,s.valid);

            fprintf(fid,'\n');

        end
        fclose(fid);
    else 
        fprintf('\nError opening file   %s\n',filenameF04);
    end
    

end

