function [ PACF, lags, bounds, h , errorMsg,errorV] = studyPartialAutocorrelation_V3(  tsDataCellArray, ...
                                                                     tsNamesCellArray,...
                                                                     numOfLags,...
                                                                     folder, ...
                                                                     filename, ...
                                                                     figureName )
%studyPartialAutocorrelation_V2 
%   Get data for ACF of a set of time series,  it aslo can show and/or a figure
 
%{

    Source: https://es.mathworks.com/help/econ/parcorr.html 

            Partial Autocorrelation Function.
            Measures the correlation between yt and yt + k after adjusting for the linear effects 
            of yt + 1,...,yt + k – 1. 
            The estimation of the PACF involves solving the Yule-Walker equations with respect 
            to the autocorrelations. However, the software estimates the PACF by fitting successive 
            autoregressive models of orders 1, 2,... using ordinary least squares. 
            For details, see [1], Chapter 3.
            [1] Box, G. E. P., G. M. Jenkins, and G. C. Reinsel. Time Series Analysis: Forecasting 
                and Control. 3rd ed. Englewood Cliffs, NJ: Prentice Hall, 1994.

    Inputs 
            tsDataCellArray: a cell array with the time series data. Each element of the 
                             cell array will be the data for a univariate time series

            tsNamesCellArray: a cell array with the names of each time series. Eas elements 
                              of the cell array will be the name of each time seris 

            numOfLags:        num of las for the ACF 

            Folder:           folder where the figure (as a -dpdf format) is going to be saved

            Filename:         filename for pdf file where the figure (as a -dpdf format) is going to be saved

            FigureName:       name of the figure (window)

    Outputs
            h1: the figure 
            (source: https://es.mathworks.com/help/econ/parcorr.html)
            ACF:    Sample ACF of the univariate time series y, returned as a vector of 
                    length numLags + 1. The elements of pacf correspond to lags 0, 1, 2,... numLags.
                    The first element, which corresponds to lag 0, is unity (i.e., pacf(1) = 1). 
                    This corresponds to the coefficient of y regressed onto itself.
            
            lags:   Sample PACF lags, returned as a vector. Specifically, lags = 0:numLags. 
 
            bounds: Approximate confidence bounds of the PACF assuming y is an AR(numAR) process, 
                    returned as a two-element vector. bounds is approximate for lags > numAR. 

%}
    % initialization    
    ACF = 0; lags = 0; bounds = 0; h = 0;errorMsg = ''; errorV = 0;
    
    % Check the number of time series
    numTS = length(tsDataCellArray); 
    if ( numTS > 4 ) 
        errorV = 1;
        errorMsg = 'The nummber of time series must be at most 4';
        return
    end
    
    % Set the subplot elements (just 1 o 4)
    if ( numTS == 1 )
        nSubPlot = 1;
    else
        nSubPlot = 2;
    end
    
    % ----------------------------------------------
    PACF = cell( 1 ,  length(tsDataCellArray));
    lags = cell( 1 ,  length(tsDataCellArray));
    bounds = cell( 1 ,  length(tsDataCellArray));
    
    fprintf('%20s %12s %12s %12s\n', 'Name','Mean','stdDev','Var');
    h = figure('Name',figureName'); 
    for i = 1:length(tsDataCellArray)
        % Get data 
        tsData = tsDataCellArray{1,i};
        tsName = tsNamesCellArray{1,i}; % R2017b 
        
        % Indicate the subplot
        subplot(nSubPlot,nSubPlot,i); 

        % Get the Partial Autocorrelation data (no plot)
        [ PACF , lags , bounds] = parcorr(tsData,numOfLags); 
        
        % plot 
        autocorr(tsData,numOfLags);
        
        title(strcat(tsName,' ACF lags ',num2str(numOfLags)));

        meanTsData   = mean(tsData);
        stdDevTsData = std(tsData);
        varTsData    = var(tsData);

        fprintf('%20s %12.5f %12.5f %12.5f\n', ...
                 tsName,meanTsData,stdDevTsData,varTsData);

        % a = min(tsData)*(0.95); b =  max(tsData)*(0.5));
        % a = 0; b = meanTsData + 6*stdDev; 
        % axis( [0 length(tsData) a b ] );

    end
       
    errorV = saveFigure( h, '-dpdf' , folder, filename);
    
end

