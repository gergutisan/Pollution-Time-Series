clearvars -EXCEPT pollutionData_daily pollutionData_hourly % to be faster while debugging
clc; close all; fclose('all');
% Delete Preious pdf files
folder = 'Figures';
%delete(strcat(folder ,'\*.pdf'));

%% SET THE PATH -------------------------------------------------------------------
restoredefaultpath; clear;

%% PAHT & FOLDERS ----------------------------------------------------------------
cd(fileparts(mfilename('fullpath')));    % does not work if executed by Run Section [and advance]

folderFunctions  = strcat(fileparts(mfilename('fullpath')),'\Functions');
% d:\DriveGoogle\00_SW_Projects\2017_PollutionMadrid_TimeSeries_01\SourceCode\02_Arima\TimeSeries\
folderTimeSeries = strcat(fileparts(mfilename('fullpath')),'\TimeSeries');

folderFigures = strcat(fileparts(mfilename('fullpath')),'\Figures');


oldpath = path; path(folderFunctions,oldpath);
oldpath = path; path(folderTimeSeries,oldpath);
clear oldpath

%% SCREEN SIZE  -----------------
setScreenSize( 0.1 , 0.8 ) % leftBottomCornerPos <- 0.1; rateScreenSize <- 0.8;

%% TIME SERIES NAMEs and FILENAMES 
%{
    %MendezAlvaro      SC: 47 (28079047)
    %Plaza-de-Castilla SC: 50 (28079050)
    %Pza-Fdez-Ladreda  SC: 56(28079056)
    %JuanCarlosI       SC: 59(28079059)
    stationCode   = 28 079 047;  % Mendez Alvaro      -> Alta.- 08/02/2010 (00:00 h.)
    stationCode   = 28 079 050;  % Castilla           -> Alta.- 18/01/2010 (12:00 h.)
    stationCode   = 28 079 056;  % Pza. Fdez. Ladreda -> Alta.- 18/01/2010 (12:00 h.)
    stationCode   = 28 079 059;  % Juan Carlos I      -> Alta.- 18/01/2010 (12:00 h.)
    
    %Pollutant NO2   PC: 08
    %Pollutant PM2.5 PC: 09
    %Pollutant O3    PC: 14
    pollutantCode = 08;        % NO2 micrograms/m3  
    pollutantCode = 09;        % PM2.5 Particles < 2.5 micra  
    pollutantCode = 14;        % O3 micrograms/m3  
%}

%{
    % Original Data (valid and not valid)
    ts_PC_08_SC_47_H_F03.dat     NO2_MendezAlvaro
    ts_PC_08_SC_50_H_F03.dat     NO2_PzCastilla
    ts_PC_08_SC_56_H_F03.dat     NO2_FedzLadreda
    ts_PC_08_SC_59_H_F03.dat     NO2_JuanCarlosI
    ts_PC_09_SC_47_H_F03.dat     PM25_MendezAlvaro
    ts_PC_09_SC_50_H_F03.dat     PM25_PzCastilla
    ts_PC_14_SC_56_H_F03.dat     O3_FezLadreda
    ts_PC_14_SC_59_H_F03.dat     03_JuanCarlosI

    % Preprocessed Data (PProc: the mean till the time of the ~"V labeled data/value)
    
    ts_PC_08_SC_47_H_pproc.dat
    ts_PC_08_SC_50_H_pproc.dat
    ts_PC_08_SC_56_H_pproc.dat
    ts_PC_08_SC_59_H_pproc.dat
    ts_PC_09_SC_47_H_pproc.dat
    ts_PC_09_SC_50_H_pproc.dat
    ts_PC_14_SC_56_H_pproc.dat
    ts_PC_14_SC_59_H_pproc.dat
%}

% TS NAMES ----------------------------
% tsNamesCellArray = { 'PC-08-SC-28079050-H-F03' , 'PC-08-SC-28079056-H-F03' , 'PC-09-SC-28079050-H-F03', 'PC-14-SC-28079056-H-F03'};
% tsNamesCellArray = { 'NO2 PzCastilla' , 'N02 PzFezLadreda' , 'PM2.5 PzCastilla', 'O3 PzFezLadreda'};

tsPCSC = {08 47 ; 08 50 ; 08 56 ; 08 59; 09 47 ; 09 50; 14 56 ; 14 59 };   % PC SC ... k(#timeSeries) rows 

tsNamesCellArray = { "NO2-MendezAlvaro" , "NO2-PzCastilla" , "NO2-FedzLadreda" , "NO2-JuanCarlosI", ...
                     "PM25-MendezAlvaro" , "PM25-PzCastilla" , "O3-FezLadreda" , "O3-JuanCarlosI"};
                 
tsInfoCellArray = {"NO2" , "NO2" ,"NO2" ,"NO2" ,...
                   "PM25" ,"PM25" ,"O3" ,"O3" ,};                

               
% LOAD WHOLE DATA and seve it in a cell array --- 
filenameTS = {'ts-PC-08-SC-47-16-11.dat' , ... 
              'ts-PC-08-SC-50-16-11.dat' , ...
              'ts-PC-08-SC-56-16-11.dat' , ...
              'ts-PC-08-SC-59-16-11.dat' , ...
              'ts-PC-09-SC-47-16-11.dat' , ...
              'ts-PC-09-SC-50-16-11.dat' , ...
              'ts-PC-14-SC-56-16-11.dat' , ...
              'ts-PC-14-SC-59-16-11.dat' };

nY = 16; nM = 11;

%% PARAMETERS ============================================

hoursPerDay = 24;
daysPerWeek = 7 ; 
daysBack1Year = 365;      % 52 * 7 = 364
daysBack2Years = 365 * 2;  % 52 * 7 * 2 = 728

% parameters to get data -----------------------
% parameters for ACF and PACF  -----------------
numWeeks           = 2;
weeksBackLastMonth = 5;
numWeeksACF_PAFC   = 2;
numWeeks = numWeeksACF_PAFC;
% 
% note: -> 24 * 7 * 2 -> 336 periods; 
%  numLags2 = 200;
daysBackLastMonth = daysPerWeek * weeksBackLastMonth;
numLags = hoursPerDay * daysPerWeek * numWeeks;  % e.g. 2 weeks: 2352 times

%% LOAD TIME SERIES ==================================================================
%{
    Hourly data (24 per day) from 12 01 01 to 16 12 31 
%}

t1 = cputime;

% TS NAMES ----------------------------
tsNamesCellArray;

% TS DATA filesname in a cell array --- 
filenameTS;

% Load ALL DATA into a cell array. Each element of the cell array, is an array with the Time Series data
for i = 1:numel(filenameTS)  
  tsDataCellArray{i} = load( strcat( folderTimeSeries , '\' , filenameTS{i} ) );
end


fprintf('\nLOAD TIME SERIES -  matlab process time -> %.2f s\n\n',cputime - t1);  

%% TS FIGURES + HISTOGRAMS 
% % ts data - histogram - probability distribution(?)  - variace(?)
% % mean, var, std, cov, corrcoef.
% %     note: The standard deviation is the square root of the variance (VAR).
% 
% for i=1:length(tsAllDataCellArray) 
%     
%     tsData = tsDataCellArray{1,i};
%     tsName = string(tsNamesCellArray{1,i});
%     
%     h1 = figure('Name','TS last year raw data + hist'); % figure;
%     subplot(2,2, [1 2]), plot(tsData),  title(strcat( string(tsName), ' data + hist')); 
%     subplot(2,2,3), histogram(tsData,10); 
%     subplot(2,2,4), histogram(tsData,100)
%     variance = var(tsData);
%     
%     % suptitle(strcat( ts-Name, ' data + histograms')); 
%     
% end
% clear h1 tsData tsName variance;

%% PLOT THE K TIME SERIES ==========================================================
t1 = cputime;

% Note for developers. This piece of code is ad hoc for the number of time series ( 4 , 8 )
% fprintf('\nPlot the time series\n');

tsDataCellArray;

YY = 16; MM = 11;

for i = 1:length(tsDataCellArray)

    tsData = tsDataCellArray{i};
    tsName = tsNamesCellArray{1,i}; % R2017b 
    fprintf('tsName: %s nY: %d; nM: %d; \n', tsName , YY, MM);

    if i == 1
        h1 = figure('Name','TS raw data 1'); % h1 = figure;
        kFig = 1; grid on;
    elseif i == 5         
        %h2 = figure('Name','TS raw data 2'); % h2 = figure;
        h1 = figure('Name','TS raw data 2'); % h1 = figure;
        kFig = 2; grid on;
    end    


    switch i
        case {1,2,3,4}
            numSubplot = i;
        case {5,6,7,8}
            numSubplot = i - 4;
    end

    % ylimit 
    switch i
        case {1,2,3,4} 
            % NO2
            ylimit = 300; 
        case {5,6}
            % PM2.5
            ylimit = 100;
        case {7,8}
            % O3
            ylimit = 300;
    end

    ax = subplot(2,2,numSubplot);
    plot(tsData);  
    ylim(ax,[0 ylimit]);
    grid(ax,'on')
    % a = min(tsData)*(0.95); b =  max(tsData)*(0.5));   a = 0; b = meanTsData + 6*stdDev;      axis( [0 length(tsData) a b ] );
    
    title(strcat( tsName,' ',num2str(YY,'%02d'),' ',num2str(MM,'%02d') ) );
    

    meanTsData = mean(tsData);
    stdDev = std(tsData);



    if ( mod(i,4) == 0)
        folder = 'Figures';
        filename = strcat( "timeSeriesPollutionMadrid",num2str(YY,'%02d'),'_',num2str(MM,'%02d'),'_',num2str(kFig));
        error = saveFigure( h1, '-dpdf' , folder, filename);
    end

end

clear h1 h2 tsData tsName variance;

fprintf('\nPlot Time Series => matlab process -> %.2f s\n\n',cputime - t1);     

pause(1);

%% TS TRANSFORMATION LOGARITHM -----------------------------

% % Transformations as logarithms can help to stabilize the variance of a time series
% 
% 
% h1 = figure('Name','TS last year log data'); % h4 = figure;
% for i=1:length(tsLastYearDataCellArray)
%     
%     tsDataLogCellArray{i} = log10(tsLastYearDataCellArray{i});
%     
%     tsData = tsDataLogCellArray{1,i};
%     tsName = string(tsNamesCellArray{1,i});
%     
%     subplot(2,2,i), plot(tsData);  
%     h3_gca = gca; 
%     % h3_gca.YScale = 'log';
%     title( string(tsName) + ' log data' );
%     variance = var(tsData);
%    
% end
% clear h1 tsData tsName variance;

%% TS ANALYSIS NOTES ==================================================================
%{
    Final objective: get an ARIMA based model, and use it to forestcast values for 24h, 48h, 36h, k*24 hours 

    ARIMA MODELS IN MATLAB: 
        
        Econometrics Tollbox

           (STARTING POINT)
            https://es.mathworks.com/help/econ/getting-started-with-econometrics-toolbox.html
    
            https://es.mathworks.com/help/econ/arima-model.html 
            https://www.mathworks.com/help/econ/arima.estimate.html

    
        System Identification Toolbox
            System Identification Toolbox™ provides MATLAB® functions, Simulink® blocks, 
            and an app for constructing mathematical models of dynamic systems from measured input-output data. 
            It lets you create and use models of dynamic systems not easily modeled from first principles or specifications.

            https://es.mathworks.com/help/ident/ug/estimating-arima-models.html
        
        Statistics and Machine Learning Toolbox
            https://es.mathworks.com/help/stats/specify-the-response-and-design-matrices.html?searchHighlight=time%20series%20forecast&s_tid=doc_srchtitle
            
            To fit a multivariate linear regression model using mvregress, you must set up your response matrix and design matrices in a particular way.
            mvregress -> can handle a variety of multivariate regression problems.
            See: Vector Autoregressive Model VAR(p) seems to be similiar to AR(p) SO .. do not try this in this work.
           

   Trend-Stationary vs. Difference-Stationary Processes 
        https://es.mathworks.com/help/econ/trend-stationary-vs-difference-stationary.html
          
%}
%{
    2nd data in data list in Cell Array
    Pza-Fdez-Ladreda SC: 56(28079056)
    Pollutant NO2   PC: 08
    ts-PC-08-SC-28079056-H-F03.csv

    
%}
%{
  Autocorrelation
    source: wikipedia
    "Unit root processes, trend stationary processes, autoregressive processes, and moving average processes 
    are specific forms of processes with autocorrelation."

    source: Hyndam FPP Ed2 
    "Just as correlation measures the extent of a linear relationship between two variables, 
    autocorrelation measures the linear relationship between lagged values of a time series."

    Autocorrelation Plot, section 1.3.3. NIST/SEMATECH e-Handbook of Statistical Methods, http://www.itl.nist.gov/div898/handbook/, Nov. 2017.
    http://www.itl.nist.gov/div898/handbook/eda/section3/autocopl.htm
  

  Autocorrelation and Partial Autocorrelation
    Documentation in   
    https://es.mathworks.com/help/econ/autocorrelation-and-partial-autocorrelation.html
%}

%% TS ANALYSIS ACF and PACF  Version for 4 TS  -------------------------------------------------------------
% 
% % Lags : 3 days -  7 days (1 week) - several weeks 
% numLagsVector = [ (24 * 3) (24 * 7) (24 * 7 * numWeeksACF_PAFC)  ];
% 
% for i = 1:length(numLagsVector)
%     % --------------------------------------
%     numLags = numLagsVector(i); %  fprintf('numLags %d\n',numLags);
%     
%     %% TS ANALYSIS 01 - 4 TS - Last Year  - AFC 
%     t1 = cputime;
%     
%     %tsData = tsAllDataCellArray;
%     tsData = ts2LastYearsDataCellArray;
%     %tsData = tsLastYearsDataCellArray;
%     %tsData = tsLastMonthDataCellArray;
% 
%     folder = 'Figures';  
%     filename = strcat ('ts_PollutionMadrid_2LastYearData_ACF','_','lags_',num2str(numLags));
%     fprintf('\n---------\nACF for Time Series 2 Last Year Data, numLags %d\n',numLags);
%     figureName = '2 last year data ACF';
%     [ ACF_01{i}, lags_01{i}, bounds_01{i}, h_01{i}, errorMsg_01{i},errorV_01{i} ] = ... 
%                 studyAutocorrelation_V2(  tsData, tsNamesCellArray , numLags,...
%                                           folder, filename, figureName );
%     fprintf('\n matlab process time -> %.2f s\n\n',cputime - t1);
%     
%     pause(1); h01{i}.Visible = 'off'; 
%     
%     % --------------------------------------
%     %% TS ANALYSIS 02 - 4 TS - Last Year  - PAFC
%     t1 = cputime;
%     
%     folder = 'Figures'; 
%     %filename = 'timeSeriesPollutionMadrid_LastYearData_PACF';
%     filename = strcat ('timeSeriesPollutionMadrid_LastYearData_PACF','_','lags_',num2str(numLags));
% 
%     figureName = 'last year data PACF';
% 
%     fprintf('\n---------\nPACF for Time Series Last Year Data, numLags %d\n',numLags);
%     [ PACF_02{i}, lags_02{i}, bounds02{i}, h02{i} , errorMsg02, errorV02{i} ] = ... 
%         studyPartialAutocorrelation_V2(  tsData, tsNamesCellArray , numLags,...
%                                          folder, filename, figureName );
% 
%     fprintf('\n matlab process time -> %.2f s\n\n',cputime - t1);        
% 
%     pause(1); h02{i}.Visible = 'off'; 
%     % --------------------------------------
%     %% TS ANALYSIS 03 - 4 TS - Last Month - AFC 
%     t1 = cputime;
%     
%     folder = 'Figures'; 
%     filename = 'timeSeriesPollutionMadrid_LastMonthDAta_ACF';
%     filename = strcat ('timeSeriesPollutionMadrid_LastMonthData_ACF','_','lags_',num2str(numLags));
% 
%     figureName = 'last month data ACF';
% 
%     fprintf('\n---------\nACF for Time Series Last Month Data, numLags %d\n',numLags');
%     [ ACF_03{i}, lags_03{i}, bounds_03{i}, h_03{i} , errorMsg_03{i}, errorV_03{i} ] = ... 
%         studyAutocorrelation_V2(  tsData, tsNamesCellArray , numLags,...
%                                          folder, filename, figureName );
% 
%     fprintf('\n matlab process time -> %.2f s\n\n',cputime - t1);  
% 
%     pause(1); h03{i}.Visible = 'off';     
%     
%     % --------------------------------------
%     %% TS ANALYSIS 04 - 4 TS - Last Month - PAFC
%     t1 = cputime;
%     
%     folder = 'Figures'; 
%     %filename = 'timeSeriesPollutionMadrid_LastMonthData_PACF';
%     filename = strcat ('timeSeriesPollutionMadrid_LastMonthData_PACF','_','lags_',num2str(numLags));
% 
%     figureName = 'last month data PACF';
%     fprintf('\n---------\nPACF for Time Series Last Month Data, numLags %d\n',numLags');
%     [ PACF_04{i}, lags_04{i}, bounds_04{i}, h_04{i} , errorMsg_04{i},errorV_04{i} ] = ... 
%         studyPartialAutocorrelation_V2(  tsData, tsNamesCellArray , numLags,...
%                                          folder, filename, figureName );
% 
%     fprintf('\n matlab process time -> %.2f s\n\n',cputime - t1);
% 
%     pause(1); h04{i}.Visible = 'off'; 
%     
%     
%     % --------------------------------------
% end

%% TS Analysis Lagged Scatter plot + ACf + PACF - for K TS
% 
% numLagsVector = [ 75 ];
% % numLagsVector = [ 18 ];
% folderFigures = 'Figures';  
% counter = 0;
% 
% showScatterPlot = 1;
% showACFPACFPlot = 0;
% 
% for iLag = 1:length(numLagsVector)
%     
%     numLags = numLagsVector(iLag);
%     
%     numData = { 1 2 3 4};
%     % numData = { 1 };
%     % numData = { 2 3 4};
%     % numData = { 1 2 };
%     % numData = { 3 };
%     
%     for j = 1:length(numData)
%     
%         nD = numData{j};
%         nDStr = num2str(nD);
% 
%         switch nD 
%             case 1
%                 tsDataCellArray = tsLastMonthDataCellArray;
%             case 2
%                 tsDataCellArray = tsLastYearDataCellArray;
%             case 3
%                 tsDataCellArray = ts2LastYearsDataCellArray;
%             case 4
%                 tsDataCellArray = tsAllDataCellArray;
%         end
%             
%         nTs = length(tsDataCellArray);
%         for k = 1:nTs    
%             counter = counter + 1;
%             
%             % for each time series
%             tsName = tsNamesCellArray{k};
%             tsData = tsDataCellArray{k};
%             
%             fprintf('Counter: %03d - %s \nnD %d   nLags %d \n',counter,tsName,numel(tsData),numLags);
%             t1 = cputime;
% 
%             
%             sInfo = tsInfoCellArray{k}; % sInfo = nDStr;
%             [ACF{counter}, lagsACF{counter}, boundsACF{counter}, PACF{counter}, lagsPACF{counter}, boundsPACF{counter} , ... 
%              h1_scatter{counter}, h1_acf{counter}, h1_pacf{counter}] = getLagScatterPlot_ACF_PACF_v01( tsData , tsName, sInfo, numLags, showScatterPlot, showACFPACFPlot );               
%             
%             pause(1);            
%             
%             if ( showScatterPlot )
%                 h1_scatter{counter}.Visible = 'off';
%                 filenameScatter = strcat ('ts_',tsName,'_nD_',nDStr,'_Scatter','_','lags_',num2str(numLags));
%                 fprintf('Saving %s ... ',filenameScatter); t2 = tic;
%                 errorV = saveFigure( h1_scatter{counter}, '-dpdf' , folderFigures, filenameScatter);
%                 fprintf('... %5.2f\n',toc(t2));
%             end
%             if ( showACFPACFPlot ) 
%                 h1_acf{counter}.Visible     = 'off';
%                 h1_pacf{counter}.Visible    = 'off';
%                 filenameACF     = strcat ('ts_',tsName,'_nD_',nDStr,'_ACF','_','lags_',num2str(numLags));
%                 filenamePACF    = strcat ('ts_',tsName,'_nD_',nDStr,'_PACF','_','lags_',num2str(numLags));
%                     
%                 fprintf('Saving %s ...',filenameACF); t2 = tic;
%                 errorV = saveFigure( h1_acf{counter}, '-dpdf' , folderFigures, filenameACF);
%                 fprintf('... %5.2f\n',toc(t2));
% 
%                 fprintf('Saving %s ...',filenamePACF); t2 = tic;
%                 errorV = saveFigure( h1_pacf{counter}, '-dpdf' , folderFigures, filenamePACF);
%                 fprintf('... %5.2f\n',toc(t2));
%             end
%             
%             fprintf('\nmatlab process time -> %.2f s\n',cputime - t1);   
%             fprintf('\n ----------------------------------------\n\n');   
% 
%         end
%     end
% end

%% TS ANALYSIS 01 ACF and PACF  Version for K TS  -------------------------------------------------------------

% 
% % Lags : 3 days -  7 days (1 week) - several weeks 
% numLagsVector = [ (24 * 3) (24 * 7) (24 * 7 * numWeeksACF_PAFC)  ];
% 
% folderFigures = 'Figures';  
% counter = 0;
% 
% for i = 1:length(numLagsVector)
%     % --------------------------------------
%     numLags = numLagsVector(i); %  fprintf('numLags %d\n',numLags);
%     
%     numData = { 1 2 3 4};
%     
%     
%     
%     %% TS ANALYSIS 01 - 4 TS - Last Year  - AFC 
%     
%     for j = 1:length(numData)
%         nD = numData{j};
%         nDStr = num2str(nD);
%         
%         switch j 
%             case 1
%                 tsDataCellArray = tsLastMonthDataCellArray;
%             case 2
%                 tsDataCellArray = tsLastYearDataCellArray;
%             case 3
%                 tsDataCellArray = ts2LastYearsDataCellArray;
%             case 4
%                 tsDataCellArray = tsAllDataCellArray;
%         end
%         
%         nTs = length(tsDataCellArray);
%         for k = 1:nTs
%             
%             counter = counter + 1;
%             
%             % for each time series
%             tsName = tsNamesCellArray{k};
%             tsData = tsDataCellArray{k};
%             
%             fprintf('nLags: %d - nD: %d - TS: %s\n',numLags,numel(tsData),tsName);
%             t1 = cputime;
%                        
%             
%             filenameACF = strcat ('ts_',tsName,'_nD',nDStr,'ACF','_','lags_',num2str(numLags));
%             fprintf('tsName %s nD %s ACF  lags %d\n',tsName, nDStr, numLags);
%             figureName = strcat ('ts_',tsName,'_nD',nDStr,'ACF','_','lags_',num2str(numLags));
%             
%             % folderFigures created at the beginning
%             
%             
%             [ ACF{counter}, lagsACF{counter}, boundsACF{counter}, ...
%               h_ACF{counter}, errorMsg_ACF{counter},errorV_ACF{counter} ] = studyAutocorrelation_V3( tsData, tsName , numLags,...
%                                                                                                folderFigures, filenameACF, figureName );
%             
%             pause(1); h_ACF{counter}.Visible = 'off';                                                           
%             
%             filenamePACF = strcat ('ts_',tsName,'_nD',nDStr,'PACF','_','lags_',num2str(numLags));
%             fprintf('tsName %s nD %s PACF lags %d\n',tsName, nDStr , numLags);
%             figureName = strcat ('ts_',tsName,'_nD',nDStr,'PACF','_','lags_',num2str(numLags));
%                                                   
%             [ PACF{counter}, lagsPACF{counter}, boundsPACF{counter}, ...
%               h_PACF{counter} , errorMsg_PACF{counter}, errorV_PACF{counter} ] = studyPartialAutocorrelation_V3( tsData, tsName , numLags,...
%                                                                                                                  folderFigures, filenamePACF, figureName );
%                           
%             pause(1); h_PACF{counter}.Visible = 'off';   
%             
%             fprintf('matlab process time -> %.2f s\n',cputime - t1);   
%             fprintf('\n ----------------------------------------\n\n');   
%             
%             analysis(counter).tsName  = tsName;
%             analysis(counter).tsData  = tsData;
%             analysis(counter).nData   = numel(tsData) ;
%             analysis(counter).numLags = numLags;
%             analysis(counter).ACF_filename  = filenameACF;
%             analysis(counter).PACF_filename = filenamePACF;           
%             analysis(counter).ACF     = ACF;
%             analysis(counter).PACF    = PACF;
%         end
%         
%     end    
% end

%% TS ANALYSIS 02 (4 subplot/image) ACF and PACF  Version for K TS  -------------------------------------------------------------
folderFigures = 'Figures';  
counter = 0;
showACFPACFPlot = 1;

numLagsVector = {75};
for iLag = 1:length(numLagsVector)
    
    numLags = numLagsVector{iLag};
    
    numData = { 1 2 3 4};
    % numData = { 1 2 4};
    % numData = { 3};
    
    for inD = 1:numel(numData) 
        
        nD = numData{inD};   
        nDStr = num2str(nD);
        
        switch nD 
            case 1
                tsDataCellArray = tsLastMonthDataCellArray;
            case 2
                tsDataCellArray = tsLastYearDataCellArray;
            case 3
                tsDataCellArray = ts2LastYearsDataCellArray;
            case 4
                tsDataCellArray = tsAllDataCellArray;
        end
        % --------------------------------
                %     tsNamesCellArray = { "NO2-MendezAlvaro" , "NO2-PzCastilla" , "NO2-FedzLadreda" , "NO2-JuanCarlosI", ...
        %                      "PM25-MendezAlvaro" , "PM25-PzCastilla" , "O3-FezLadreda" , "O3-JuanCarlosI"};
        %                  
        %     tsInfoCellArray = { "NO2" , "NO2" ,"NO2" ,"NO2" ,...
        %                         "PM25" ,"PM25" ,"O3" ,"O3"};
        
        % ---------------------------------------------
        nTs = length(tsDataCellArray);
        
        % ACF for all the TS of nD{..} and nLags,
        for k = 1:nTs
            
            % for each time series
            tsName = tsNamesCellArray{k};
            tsData = tsDataCellArray{k};
            counter = counter + 1;
            fprintf('Counter: %03d - %s \nnD %d   nLags %d \n',counter,tsName,numel(tsData),numLags);
            t1 = cputime;
            
            
            if k == 1
                h1ACF  = figure('Name','TS ACF raw data'); % h1 = figure;
                h1PACF = figure('Name','TS PACF raw data'); % h1 = figure;
                kFig = 1; grid on;
                              
                
            elseif k == 5         
                h2ACF  = figure('Name','TS ACF raw data'); % h1 = figure;
                h2PACF = figure('Name','TS PACF raw data'); % h1 = figure;
                kFig = 2; grid on;
             end    

            
            
            % autocorrelation function

            %[ ACF , lagsACF , boundsACF ] = autocorr( tsData , numLags );     
            % Correlogram
            if ( showACFPACFPlot )
                if (k <= 4)
                    figure(h1ACF);
                    subplot(2,2,k)                    
                else
                    figure(h2ACF);
                    subplot(2,2,k-4)
                end
                
                % h1_acf = figure('Name',strcat(tsName,' ',sInfo ,' ',' ACF ( lags ',num2str(numLags),' )' ) );
                % autocorr(y) plots the sample autocorrelation function (ACF) 
                % of the univariate, stochastic time series y with confidence bounds.
                autocorr(tsData,numLags); 
                title(strcat(tsName,' ACF ( lags ',num2str(numLags),'-','nD ', nDStr,')' ));
            end
            
            % ---------------------------------------------------------------------
                % Partial autocorrelation function
            %[ PACF , lagsPACF , boundsPACF ] = parcorr( tsData , numLags );     
            % Correlogram
            if ( showACFPACFPlot ) 
                if (k <= 4)
                    figure(h1PACF);
                    subplot(2,2,k)
                else
                    figure(h2PACF);
                    subplot(2,2,k-4)
                end
                
                %h1_pacf = figure('Name',strcat(tsName,' ',sInfo ,' ',' PACF ( lags ',num2str(numLags),' )' ) );
                % autocorr(y) plots the sample autocorrelation function (ACF) 
                % of the univariate, stochastic time series y with confidence bounds.
                
                parcorr(tsData,numLags); 
                title(strcat(tsName,' PACF ( lags ',num2str(numLags),'-','nD ', nDStr,')' ));

            end
            
            

            fprintf('\nmatlab process time -> %.2f s\n',cputime - t1);   
            fprintf('\n ----------------------------------------\n\n'); 

        end
        
        % ----------------------------------------------------------------------------
        % Save each figure ACF  1 & 2 - PACF 1 & 2  => h1ACF, h1PACF, h2ACF, h2PACF
        
        t2 = cputime; 
        fprintf('\nSaving 4 figures to pdf files\n');   
        
        format = '-dpdf';        
        
        filename = strcat('acf_01_nD_',nDStr,'_lags_',num2str(numLags));
        [ error ] = saveFigure( h1ACF , format, folderFigures , filename );
        
        filename = strcat('acf_02_nD_',nDStr,'_lags_',num2str(numLags));
        [ error ] = saveFigure( h2ACF , format, folderFigures , filename );
        
        filename = strcat('pacf_01_nD_',nDStr,'_lags_',num2str(numLags));
        [ error ] = saveFigure( h1PACF , format, folderFigures , filename );
        
        filename = strcat('pacf_02_nD_',nDStr,'_lags_',num2str(numLags));
        [ error ] = saveFigure( h2PACF , format, folderFigures , filename );
        
        fprintf('\nmatlab process time -> %.2f s\n',cputime - t2);   
        
        % ----------------------------------------------------------------------------
        close(h1ACF,h2ACF ,h1PACF,h2PACF);
        
        
    end
    
end


%% --------------

clear t1 folder filename figureName numLags