
---------------------------------

Information: 

dataFileStructure.txt  Information about the codification (i.e. format) of the information in data files (Data_Daily, Data_Hourly)

----------------------------------

STARTING POINT First Step 

  main_01_LoadPollutionData_v02.m 
      -> call loadPollutionData_v02.
              -> call checkIsLeapYear

      This script get the following array of structs 

                pollutionData_hourly(i)

                    struct with fields:

                        codStationP1: 28   -> Same value for all the station within the Region of (the city of Madrid is within the region of Madrid)
                        codStationP2: 079  -> Same value for all the station within the city of Madrid
                        codStationP3: 004  -> The code for statation
                        codMeasure: 1
                      codTechnique: 38
                         codPeriod: 2
                           codDate: [1×1 struct]    -> year, month, day
                              hour: [1×24 struct]   -> array of 24 structs -> value,valid 

                    e.g for the pollutant value: pollutionData_hourly(i).hour(1).value.valid 
                    e.g for the pollutant code:  pollutionData_hourly(i).codMeasure   

     The arrays of structs, the data, i.e. for daily and hourly data, are stored 
     in two *.mat file (binary files where you can save the variables from your workspace in Matlab(R))
          pollutionData_hourly_2012-2015.mat   (for var pollutionData_hourly, array of structs ...)
          pollutionData_daily_2012-2015.mat    (for var pollutionData_daily, array of structs ...)

Second step

main_02_GetTimeSeriesPollutStation_v03.m     
     
     FROM A SET/LIST OF POLLUTANTS (OUTER LOOP) AND A SET OF STATIONS (INNER LOOP)

         daily data --> extractDataPollution_v01.m
         hourly data --> extractDataPollution_v01.m
    
     saveHourlyDataPollutantStation.m
     saving it in three formats: 
                - table (in the same way that the file from munimadrid.es)
                - Time Series List (with all the information for the values of easch time/period)
                - Time Seris List, just with the single values 
                - Time Seris List, just with the single values, and if they are valid (V) or not (...) 

Third Step 

main_03_Preprocess_TimeSeriesPollutantStation_v01

     FROM A SET/LIST OF POLLUTANTS (OUTER LOOP) AND A SET OF STATIONS (INNER LOOP)

         daily data --> extractDataPollution_v01.m
         hourly data --> extractDataPollution_v01.m

         compute the number of values with a label different than V (valid)

=============================================================================

=============================================================================

1 .- 

  main_01_LoadPollutionData_v01.m 
  main_01_LoadPollutionData_v02.m 

  first check if the data ("pollutionData_daily" or "pollutionData_hourly") are NOT in the workspace, 
              then check if the *mat file exists ('pollutionData_daily.mat' or 'pollutionData_hourly.mat')
                         then load them
                         else call loadPollutionData_v02.m
                              save the data in the *.mat file
                         

1.2 loadPollutionData_v02  

    Read the csv (plain text file) file (daily and hour ly data

2.- 

   main_02_GetTimeSeriesPollutStation_v03.m

   improvement to be done : check if filenameDaily/filenameHourly exists, if not call: 
                                            %  params.kindData2Read = 'D'; 
                                            %  [ pollutionData_daily, numAllMeasures]  = loadPollutionData_v02(params);   % the content that as seq of digits is read as a number

                                            %  params.kindData2Read = 'H'; 
                                            %  [ pollutionData_hourly, numAllMeasures]  = loadPollutionData_v02(params);   % the content that as seq of digits is read as a number



      -> extractDataPollution_v01
      -> saveHourlyDataPollutantStation.m