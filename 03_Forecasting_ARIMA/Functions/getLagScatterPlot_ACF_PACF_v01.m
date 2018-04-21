function [ACF, lagsACF, boundsACF, PACF, lagsPACF , boundsPACF , ... 
          h1_scatter, h1_acf, h1_pacf] = getLagScatterPlot_ACF_PACF_v01( tsData , tsName, sInfo, numLags, showScatterPlot, showACFPACFPlot )

    % http://www.itl.nist.gov/div898/handbook/eda/section3/autocopl.htm
    
    h1_scatter = 0;  % <-- plot 1 (showPlot1)
    h1_acf = 0;      % <-- plot 2 (showPlot2)
    h1_pacf = 0;

    n = ceil(sqrt(numLags)); 
    
    maxRC = 7;
    if ( n <= maxRC )
        n2 = n;
        numLags2 = numLags;        
    else
        n2 = maxRC;
        numLags2 = maxRC^2;
        
        
    end 
    
    tsMin = 0;
    % tsMax = 0;
    % tsMax = max(tsData);
    % tsMax = ( median(tsData) * 3 );
    
    switch sInfo
        case "NO2"
            tsMax = 300;
        case "PM25"
            tsMax = 100;
        case "O3"
            tsMax = 200;
    end
    
    
    % ---------------------------------------------------------------------
    % Lagged Scatter plot ( y_t vs y_(t-k) )
    if ( showScatterPlot )
        h1_scatter = figure('Name',strcat(tsName,' ',sInfo ,' ',' lagged (', num2str(numLags2), ') scatter plot' ) );
        title(strcat(tsName,'-',sInfo));
        lengthTsData = length(tsData);
        
        for k = 1:numLags2
            lengthTsDataLagged = length(tsData) - k;
            tsDataLagged = zeros( 1, lengthTsDataLagged );

            
            for i = 1:lengthTsDataLagged 
                % Difference: y' = y_t - y_(t-k)
                % tsDataLagged( i - k ) = tsData( i ) - ( tsData( i - k ) ); 
                
                % Lagged y_(t-k)
                tsDataLagged( i ) =  tsData( i );
                
            end
            
            subplot(n2,n2,k);
            
            firstElement = k + 1; 
            plot( tsData(firstElement:lengthTsData),tsDataLagged, 'b.');
            
            xlim([0 tsMax]); ylim([0 tsMax])
            
            if (k == 1)
                title(strcat('\fontsize{8} ',tsName,' lag', num2str(k)));
            else
                title(strcat('\fontsize{8} lag ', num2str(k)));
            end
            
           
            
            clear lengthTsDataLagged tsDataLagged

        end
    end
    
    % ---------------------------------------------------------------------
    % autocorrelation function
    
    [ ACF , lagsACF , boundsACF ] = autocorr( tsData , numLags );     
    % Correlogram
    if ( showACFPACFPlot )        
        h1_acf = figure('Name',strcat(tsName,' ',sInfo ,' ',' ACF ( lags ',num2str(numLags),' )' ) );
        % autocorr(y) plots the sample autocorrelation function (ACF) 
        % of the univariate, stochastic time series y with confidence bounds.
        autocorr(tsData,numLags); 
        title(strcat(tsName,' ACF ( lags ',num2str(numLags),' )' ));
    end
    
    % ---------------------------------------------------------------------
    % Partial autocorrelation function
    [ PACF , lagsPACF , boundsPACF ] = parcorr( tsData , numLags );     
    % Correlogram
    if ( showACFPACFPlot )        
        h1_pacf = figure('Name',strcat(tsName,' ',sInfo ,' ',' PACF ( lags ',num2str(numLags),' )' ) );
        % autocorr(y) plots the sample autocorrelation function (ACF) 
        % of the univariate, stochastic time series y with confidence bounds.
        parcorr(tsData,numLags); 
        title(strcat(tsName,' PACF ( lags ',num2str(numLags),' )' ));
    end

end