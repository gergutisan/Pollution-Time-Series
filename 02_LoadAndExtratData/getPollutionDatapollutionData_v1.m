function [ tsDataF1 , tsDataF2 , nValues ] = getPollutionDatapollutionData_v1(...
                         pollutionData_dh, stationCode, pollutantCode, year, month, DH)
                     
                     
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%{
    pollutionData_hourly{i}.codStationP3  <- e.g. 47 50 56 59
    pollutionData_hourly{i}.codMeasure    <- e.g. 08 09 14

    Daily 
    pollutionData_hourly{i}.codDate.year  <- e.g. 2016 
    pollutionData_hourly{i}.codDate.month <- e.g. 11
    pollutionData_hourly{i}.codDate.day{1:numDayOfMonth} <- e.g. 11
    Hourly 
    pollutionData_hourly{i}.codDate.year  <- e.g. 2016 
    pollutionData_hourly{i}.codDate.month <- e.g. 11
    pollutionData_hourly{i}.codDate.day   <- e.g. 14
    pollutionData_hourly{i}.codDate.hour{1:24}.value 
    pollutionData_hourly{i}.codDate.hour{1:24}.valid
%}
    
    
    % HOURLY (DH == 'H')
    nIndexes = numel(pollutionData_dh);
    indexCounter = 0;
    
    
    for index = 1:nIndexes
        
        sc = pollutionData_dh(index).codStationP3;
        pc = pollutionData_dh(index).codMeasure;
        yy = pollutionData_dh(index).codDate.year;
        mm = pollutionData_dh(index).codDate.month;
        dd = pollutionData_dh(index).codDate.day;
        
        if month == 0 
            dataFound = ( sc == stationCode ) && (pc == pollutantCode) && ... 
                        ( yy == year );
        
        elseif (month <=12 ) && (month >= 1 ) 
            dataFound = ( sc == stationCode ) && (pc == pollutantCode) && ... 
                        ( yy == year ) && ( mm == month );
                
        end
        if (dataFound)
            % take the whole data (24h) for the day    
            for indexHour = 1:24
              indexCounter = indexCounter + 1;
              
              value = pollutionData_dh(index).hour(indexHour).value; 
              valid = pollutionData_dh(index).hour(indexHour).valid; 
              tsDataF1(indexCounter) = value; 
              
              tsDataF2(indexCounter).year   = yy;
              tsDataF2(indexCounter).mounth = mm;
              tsDataF2(indexCounter).day    = dd;
              tsDataF2(indexCounter).hour   = indexHour - 1;
              tsDataF2(indexCounter).value  = value ;
              tsDataF2(indexCounter).valid  = valid ;
              
            end
            
        end
        
        
    end
    nValues = indexCounter;
    tsDataF1 = tsDataF1';
    tsDataF2 = tsDataF2';
    



end

