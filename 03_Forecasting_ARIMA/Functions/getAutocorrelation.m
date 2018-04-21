function [ACF,lags,bounds] = getAutocorrelation(tsData, tsName, numLags, showPlot )

    
    
    [ACF,lags,bounds] = autocorr(tsData,numLags);     
    
    % Correlogram
    if ( showPlot )
        
        h1 = figure('Name',strcat(tsName,' ACF lags ',num2str(numLags) ) );
        % autocorr(y) plots the sample autocorrelation function (ACF) 
        % of the univariate, stochastic time series y with confidence bounds.
        autocorr(tsData,numLags); 
        title(strcat(tsName,' ACF lags ',num2str(numLags)));
    end

end