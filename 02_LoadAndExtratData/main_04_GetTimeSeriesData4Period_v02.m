clearvars -EXCEPT pollutionData_daily pollutionData_hourly year month % to be faster while debugging
clc; close all; fclose('all');

delete('Pollutants\summaryData.txt');

year = 16;
for month = [00 06 07 08 09 10 11 12]
    
    fprintf('\n YEAR %2d MONTH %2d %2d\n',year, month)
    
    main_04_GetTimeSeriesData4Period_v01

end




