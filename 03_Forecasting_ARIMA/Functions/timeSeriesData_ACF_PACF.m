function [h1] = timeSeriesData_ACF_PACF( tsDataCellArray , numLags)
%numLags = 24 * 7 * 3;


fprintf('\nACF for Time Series Last Year Data\n');

fprintf('\n Name - Mean - stdDev - Var\n');
h1 = figure('Name','TS last year raw data'); % h1 = figure;
for i = 1:length(tsLastYearDataCellArray)
    
    tsData = tsLastYearDataCellArray{1,i};
    tsName = tsNamesCellArray{1,i}; % R2017b 
        
    subplot(2,2,i); 
    
    autocorr(tsData,numLags); 
    title(strcat(tsName,' ACF lags ',num2str(numLags)));
        
    meanTsData = mean(tsData);
    stdDevTsData = std(tsData);
    varTsDAta = var(tsData);
    
    fprintf('\n %s  %12.5f  %12.5f  %12.5f\n',tsName,meanTsData,stdDevTsData,varTsDAta);
    
    % a = min(tsData)*(0.95); b =  max(tsData)*(0.5));
    % a = 0; b = meanTsData + 6*stdDev; 
    % axis( [0 length(tsData) a b ] );
    
end
end

