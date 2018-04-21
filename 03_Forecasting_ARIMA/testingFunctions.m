%% ----------------------------------------------------------------
clear; clc; close('all')

% % DATA ***********************************************************
% % For debuggin pursposes
% Data = 1:100; series{1,1} = 'TS Test 1';

% % For debuggin pursposes
%  t = 1:0.5:100; 
%  A = 5; w = 10.2; 
%  noise_A = 0.2*A;
%  Data = A * sin(t) + (A/10)*randn(1,length(t)); series{1,1} = 'TS Test 2';

% % For debuggin pursposes
% load(fullfile(matlabroot,'examples','econ','Data_Airline.mat'));
% load(fullfile(matlabroot,'examples','econ','Data_Accidental.mat'));
% load(fullfile(matlabroot,'examples','econ','Data_Overshort.mat'));
% load(fullfile(matlabroot,'examples','econ','Data_PowerConsumption.mat')); series{1,1} = 'Power Consumption Kwh'; Data = Data(:,4);
% % Data (array); DataTable; dates; description (22x54) char array; series  1x1 cell array ("(PSSG) Airline Passengers")

% % For Debugging Purposes
% p = 2; D = 1; q = 2; 
% model = arima('AR',{0.2 0.2 0.3},'ARLags',[ 1 2 3], 'Constant',0.05, 'Variance',0.02); 
% numObs = 100;
% [Data,E] = simulate(model,numObs);
% series{1,1} = 'Arima Test';



% % ******************************************************************

% % lag = 1,2,3  --------------------
% Data2 = Data(2:length(Data)) - Data(1:(length(Data)-1));
% Data3 = Data(3:length(Data)) - Data(1:(length(Data)-2));
% Data4 = Data(4:length(Data)) - Data(1:(length(Data)-3));
% 
% h = figure; 
% subplot(2,2,1); plot( Data,  'b.-'); title(series{1,1});
% subplot(2,2,2); plot( Data2, 'r.-'); title(strcat(series{1,1},' lag 1'));
% subplot(2,2,3); plot( Data3, 'k.-'); title(strcat(series{1,1},' lag 2'));
% subplot(2,2,4); plot( Data4, 'g.-'); title(strcat(series{1,1},' lag 3'));
% 
% % Lag operator = L^1, L^2, L^3 ----
% Data2 = Data(2:length(Data)) - Data(1:(length(Data)-1));
% Data3 = Data2(2:length(Data2)) - Data2(1:(length(Data2)-1));
% Data4 = Data3(2:length(Data3)) - Data3(1:(length(Data3)-1));
% h = figure; 
% subplot(2,2,1); plot( Data,  'b.-'); title(series{1,1});
% subplot(2,2,2); plot( Data2, 'r.-'); title(strcat(series{1,1},' L^1'));
% subplot(2,2,3); plot( Data3, 'k.-'); title(strcat(series{1,1},' L^2'));
% subplot(2,2,4); plot( Data4, 'g.-'); title(strcat(series{1,1},' L^3'));
% 
% % ---------------------------------
% h = figure;
% numLags = 40; 
% autocorr(Data,numLags); 
% title( strcat('autocorr',series{1,1} ) );
% % ----------------------------------
% tsData = Data;
% tsName = series{1,1};
% numLags = 49; 
% showPlot = 1;
% 
% [ACF,lags,bounds] = studyAutocorrelation( tsData , tsName, numLags, showPlot );

%% -------------------------------------------------------------------

% % % SAVE A FIGURE to a pdf/image  file
% clear; clc;  close('all');
% 
% h = figure('Name', 'Example of figure');
% t = 1:100; A = 5; w = 0.2; y = A * sin(w*t); plot( t, y );
% pause(2); h.Visible = 'off';
% clear t A w y 
% 
% folder   = 'Figures';
% filename = 'figureTest'; 
% format = '-dpdf';  %   '-dpdf' -> format for print function
% 
% delete(strcat(folder,'\',filename,'.pdf'));
% 
% error = saveFigure( h , format , folder, filename);

% %% -------------------------------------------------------------------------
% % Testing getLagScatterPlot_01 
% nTimes = 200; A = randi([1,2],1,1)*rand();
% t = 1:nTimes; w = 0.1;
% tsData = A*sin(w*t);
% h0 = figure;
% plot(t,tsData);
% 
% tsName = 'ts4Test';
% numLags = 50;
% showScatterPlot = 1; 
% showACFPACFPlot = 1;
% sInfo = 'prueba';
% 
% [ACF, lagsACF, boundsACF, PACF, lagsPACF , boundsPACF , ... 
%           h1_scatter, h1_acf, h1_pacf] = getLagScatterPlot_ACF_PACF_v01( tsData , tsName, sInfo, numLags, showScatterPlot, showACFPACFPlot );

%% -------------------------------------------------------------------------
% Testing moveFolderContent2Backup (origFolder)
%      e.g.  moveFolderContent2Backup('Figures')

moveFolderContent2Backup('Figures');

%% -------------------------------------------------------------------------
% nTimes = 200; A = randi([1,2],1,1)*rand();
% t = 1:nTimes; w = 0.1;
% tsData = A*sin(w*t);