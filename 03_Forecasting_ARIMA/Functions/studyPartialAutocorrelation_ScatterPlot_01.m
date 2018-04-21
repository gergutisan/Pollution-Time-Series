function [PACF,lags,bounds, h1_scatter, h2_acf] = getLagScatterPlot( tsData , tsName, sInfo, numLags, showPlot1, showPlot2 )

    % http://www.itl.nist.gov/div898/handbook/eda/section3/autocopl.htm
    
    h1_scatter = 0;
    h2_acf = 0;


    n = ceil(sqrt(numLags)); 
    
    maxRC = 7;
    if ( n <= maxRC )
        n2 = n;
        numLags2 = numLags;        
    else
        n2 = maxRC;
        numLags2 = maxRC^2;
        
        
    end 
    
    % ---------------------------------------------------------------------
    if ( showPlot1 )
        h1_scatter = figure('Name',strcat(tsName,' ',sInfo ,' ',' PACF lags-',num2str(numLags2) ) );
        lengthTsData = length(tsData);
        for k = 1:numLags2

            lengthTsDataLagged = length(tsData) - k;
            tsDataLagged = zeros( 1, lengthTsDataLagged );

            firstElement = k + 1; 
            for i = firstElement:lengthTsData 
                tsDataLagged( i - k ) = tsData( i ) - ( tsData( i - k ) );
            end
            subplot(n2,n2,k); 
            plot( tsData(firstElement:lengthTsData),tsDataLagged, 'b.');
            title(strcat('lag ', num2str(k)));

        end
    end
    
    % ---------------------------------------------------------------------
    
    [PACF,lags,bounds] = parcorr(tsData,numLags);     
    % Correlogram
    if ( showPlot2 )        
        h2_acf = figure('Name',strcat(tsName,' ',sInfo ,' ',' PACF lags-',num2str(numLags) ) );
        % autocorr(y) plots the sample autocorrelation function (ACF) 
        % of the univariate, stochastic time series y with confidence bounds.
        parcorr(tsData,numLags); 
        title(strcat(tsName,' PACF lags ',num2str(numLags)));
    end

end