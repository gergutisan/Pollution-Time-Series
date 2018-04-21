function [ pollutantAndStationData, tsPolSta , numElements_01,  numElements_02] = extractDataPollution_v01( pollutionData, ...
                                                                           kindData2Read, ... 
                                                                           pollutantCode,...
                                                                           stationCodeP3)
                                                                       


    % -------------------------------------------------------
    % EXTRACT THE DATA FOR AN SPECIFIC POLLUTANT         
    % This source code works for both kindData2Read ('H' & 'D')
    numAllMeasuresDay = numel(pollutionData);
    

    indexPollutantAndStation = 0;
    for index = 1:numAllMeasuresDay 

        if ( pollutionData(index).codMeasure == pollutantCode) && ...
           ( pollutionData(index).codStationP3 == stationCodeP3 ) 
            
            indexPollutantAndStation = indexPollutantAndStation + 1;
            pollutantAndStationData(indexPollutantAndStation) = pollutionData(index); 
                % THE 28/29/30/31 DAILY DATA FOR A POLLUTANT AT A STATION IN ONE MONTH or 
                % THE 24 HOURLY DATA FOR A POLLUTANT AT A STATION IN ONE DAY, 
                

        end
    end
    
    numElements_01 = indexPollutantAndStation;
    if ( numElements_01 == 0 )
        
        pollutantAndStationData = 0;
        tsPolSta = 0;
        numElements_02 = 0;
        return;
        
    end
    
    % -------------------------------------------------------
    %% TRANSFORM DATA IN Time Series format 
    % i.e. one element (hour data or day data ) of an array for each value taken from sensors
    % but store all the information for that value: station code, pollutant code, etc
    
    s = pollutantAndStationData(1);  
    pollutantCodeStr = sprintf('%02i',s.codMeasure);
    stationCodeStr   = sprintf('%02i',s.codStationP3);
    
    
    if  (kindData2Read == 'D')
    % DAILY DATA     
        % Pre-Allocation & Initialization --------
        lengthTS = numel( pollutantAndStationData ) * 30;  % CHANGE THIS (28, 29, 30 32)
        
        tsPolSta = struct( 'codMeasure',    cell(1,lengthTS),...
                           'codStationP1',  cell(1,lengthTS),...
                           'codStationP2',  cell(1,lengthTS),...
                           'codStationP3',  cell(1,lengthTS),...
                           'codTechnique',  cell(1,lengthTS),...
                           'codPeriod',     cell(1,lengthTS),...
                           'codDate',       cell(1,lengthTS),...
                           'value',         cell(1,lengthTS),...
                           'valid',         cell(1,lengthTS) );
    
        
        for i =1:lengthTS
            tsPolSta(i).codMeasure    = 0;
            tsPolSta(i).codStationP1  = 0;
            tsPolSta(i).codStationP2  = 0;
            tsPolSta(i).codStationP3  = 0;
            tsPolSta(i).codTechnique  = 0;
            tsPolSta(i).codPeriod     = 0;
            tsPolSta(i).codDate.year  = 0;
            tsPolSta(i).codDate.month = 0;
            
            tsPolSta(i).codDate.day   = 0;

            tsPolSta(i).value    = 0;
            tsPolSta(i).valid    = 0;

        end
        
        % Get the time series data ----
        iValue = 0;
        for index = 1:numel(pollutantAndStationData)

            s = pollutantAndStationData(index);  
            
            nDaysMonth = getNumDaysMonth( s.codDate.year, ...
                                          s.codDate.month);

            for iDay = 1:nDaysMonth
                iValue = iValue + 1;

                tsPolSta(iValue).codMeasure     = s.codMeasure;
                tsPolSta(iValue).codStationP1   = s.codStationP1;
                tsPolSta(iValue).codStationP2   = s.codStationP2;
                tsPolSta(iValue).codStationP3   = s.codStationP3;
                tsPolSta(iValue).codTechnique   = s.codTechnique;
                tsPolSta(iValue).codPeriod      = s.codPeriod;
                tsPolSta(iValue).codDate.year   = s.codDate.year;
                tsPolSta(iValue).codDate.month  = s.codDate.month;
                
                tsPolSta(iValue).codDate.day    = iDay;
                % ---
                % pollutionData(index).codDate.day{iDay}.value
                tsPolSta(iValue).value          = s.codDate.day{iDay}.value;
                tsPolSta(iValue).valid          = s.codDate.day{iDay}.valid;

            end
        end
        numElements_02 = iValue;
    % ---------------------------------------------------------------    
    % HOURLY DATA   -------------------------------------------------  
    elseif ( kindData2Read == 'H')
        % Pre-Allocation & Initialization --------
        lengthTS = numel( pollutantAndStationData ) * 24;
        tsPolSta = struct( 'codMeasure',    cell(1,lengthTS),...
                           'codStationP1',  cell(1,lengthTS),...
                           'codStationP2',  cell(1,lengthTS),...
                           'codStationP3',  cell(1,lengthTS),...
                           'codTechnique',  cell(1,lengthTS),...
                           'codPeriod',     cell(1,lengthTS),...
                           'codDate',       cell(1,lengthTS),...
                           'value',         cell(1,lengthTS),...
                           'valid',         cell(1,lengthTS) );
    
        
        for i =1:lengthTS
            tsPolSta(i).codMeasure    = 0;
            tsPolSta(i).codStationP1  = 0;
            tsPolSta(i).codStationP2  = 0;
            tsPolSta(i).codStationP3  = 0;
            tsPolSta(i).codTechnique  = 0;
            tsPolSta(i).codPeriod     = 0;
            tsPolSta(i).codDate.year  = 0;
            tsPolSta(i).codDate.month = 0;
            tsPolSta(i).codDate.day   = 0;
            tsPolSta(i).codDate.hour  = 0;

            tsPolSta(i).value    = 0;
            tsPolSta(i).valid    = 0;

        end
        
        % Get the time series data ----
        iValue = 0;
        for index = 1:numel( pollutantAndStationData)

            s = pollutantAndStationData(index);  

            for h = 1:24
                iValue = iValue + 1;

                tsPolSta(iValue).codMeasure     = s.codMeasure;
                tsPolSta(iValue).codStationP1   = s.codStationP1;
                tsPolSta(iValue).codStationP2   = s.codStationP2;
                tsPolSta(iValue).codStationP3   = s.codStationP3;
                tsPolSta(iValue).codTechnique   = s.codTechnique;
                tsPolSta(iValue).codPeriod      = s.codPeriod;
                tsPolSta(iValue).codDate.year   = s.codDate.year;
                tsPolSta(iValue).codDate.month  = s.codDate.month;
                tsPolSta(iValue).codDate.day    = s.codDate.day;
                % ---
                tsPolSta(iValue).codDate.hour   = h;
                tsPolSta(iValue).value          = s.hour(h).value;
                tsPolSta(iValue).valid          = s.hour(h).valid;
            
            end
        end
        numElements_02 = iValue;
    end

    
    % -------------------------------------

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
