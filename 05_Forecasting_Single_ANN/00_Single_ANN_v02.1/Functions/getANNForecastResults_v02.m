function forecastResults = getANNForecastResults_v02( net , trainRecord , x , t )

    % x <- all ts data as patterns (to be the inputs of the net)
    % t <- all ts data as targests (to be the ouput of the net)
    % ------------------------------------
    % Set the inputs from the patters for TRIAN, VALIDATION, and TEST subsets 
    trainPatterns = x(:,trainRecord.trainInd);
    valPatterns   = x(:,trainRecord.valInd);
    testPatterns  = x(:,trainRecord.testInd);
    
    % Set the target outputs from the test patters for TRIAN, VALIDATION, and TEST subsets 
    trainTargets  = t(:,trainRecord.trainInd);
    valTargets    = t(:,trainRecord.valInd);
    testTargets   = t(:,trainRecord.testInd);
    % ------------------------------------
    if ( size(trainTargets,1) == 1 ) 
        % univ TS data as a ROW VECTOR 

    elseif (size(trainTargets,2) == 1)
        % univ TS data as a COLUMN VECTOR => get the transpose
        trainTargets = trainTargets';
        valTargets   = valTargets'  ;
        testTargets  = testTargets' ;        
    end
    %% HORIZON TYPE 1     **************************************************************************
    % 
    % FOR HORIZON 1 TO nOuputs ( => IF nOuputs = 1 then horizon is 1 )  
    % AND USING THE REAL (not the forecasted) VALUES TO MAKE FOLLOWING FORECAST
    % SIMULATE the ANN 
    
    trainOutputs   = sim(net,trainPatterns);    
    valHT1Outputs  = sim(net,valPatterns);
    testHT1Outputs = sim(net,testPatterns);
    
    % This piece of source code will work with row vectors, because a individual pattern
    % for the nntool MUST BE A COLUM VECTOR

    knownTrTargets      = trainTargets;  
    knownValTargets     = valTargets;  
    knownTeTargets      = testTargets;  
    knownTrValTeTargets = cat( 2 , trainTargets , valTargets , testTargets );
    knownTrValTargets   = cat( 2 , trainTargets , valTargets );     

    
    %% HORIZON TYPE 2         **********************************************************************
    % 
    % COMPUTING THE FORECAST VALUES FOR VALIDATION AND TEST SUBSET USING 
    % PREVIOUSLY FORECASTED VALUES
    
    nInputs = net.inputs{1}.size;

    % for VALIDATION subset
    inputPattern = knownTrTargets( (end - nInputs + 1):end) ;
    for iVal = 1:numel(valTargets)
        % a individual input pattern must be a colum vector => get the transpose
        outputNet = sim(net,inputPattern'); 
        target    = knownValTargets(iVal); 

        valHT2Targets(iVal) = target;
        valHT2Outputs(iVal) = outputNet;

        % new input pattern 
        v = inputPattern(2:end); 
        inputPattern = cat( 2 , v , outputNet ); clear v;

    end
    clear output target inputPattern

    % for TEST subset
    inputPattern = knownTrValTargets( (end - nInputs + 1):end) ;
    for iTe = 1:numel(testTargets)
        % a individual input pattern must be a colum vector => get the transpose
        outputNet   = sim(net,inputPattern'); 
        target      = knownTeTargets(iTe); 

        testH2Targets(iTe) = target;
        testH2Outputs(iTe) = outputNet;

        % new input pattern 
        v = inputPattern(2:end); 
        inputPattern = cat( 2 , v , outputNet ); clear v;

    end
    clear output target inputPattern
     
    %% COMPUTE THE ERRORS       =========================================================
    % For H Type 1 (using real values to carry out the forecast through the val and test errors  )
    % trainTargets,  valTargets , valH1Outputs , testTargets   , testH1Outputs
    
    % RMSE --------------- 
    rmseTrain          = ( 1/numel( trainTargets ) ) * sqrt( sum( ( trainTargets -  trainOutputs ).^2 ) );
    rmseValHT1Forecast  = ( 1/numel(   valTargets ) ) * sqrt( sum( (   valTargets -  valHT1Outputs ).^2 ) );
    rmseTestHT1Forecast = ( 1/numel(  testTargets ) ) * sqrt( sum( (  testTargets - testHT1Outputs ).^2 ) );
    
    % SMAPE --------------
    errorEachPeriod     = ( abs( trainOutputs - trainTargets ) ) ./ ( abs(trainOutputs) + abs(trainTargets) );
    smapeTrain          = 100 * ( 2* sum(errorEachPeriod ) ) / numel( trainTargets ); 
    
    errorEachPeriod     = ( abs( valHT1Outputs - valTargets ) ) ./ ( abs(valHT1Outputs) + abs(valTargets) );
    smapeValHT1Forecast  = 100 * ( 2* sum(errorEachPeriod  ) ) / numel( valTargets ); 
    
    errorEachPeriod     = ( abs( testHT1Outputs - testTargets ) ) ./ ( abs(testHT1Outputs) + abs(testTargets) );
    smapeTestHT1Forecast = 100 * ( 2* sum(errorEachPeriod ) ) / numel( testTargets );
        
    % For H > 1)
    % trainTargets, valH2Targets, valH2Outputs , testH2Targets , testH2Outputs
    
    rmseValHT2Forecast  = sqrt( sum ( ( valHT2Outputs - valHT2Targets).^2 ) / numel( valTargets ) );
    errorEachPeriod    = ( abs(valHT2Outputs - valHT2Targets) ) ./ ( abs(valHT2Outputs) + abs(valHT2Targets) );
    smapeValHT2Forecast = 100 * ( 2* sum(errorEachPeriod) ) / numel( valTargets ); 
    clear errorEachPeriod;
        
    rmseTestHT2Forecast  = sqrt( sum ( ( testH2Outputs - testH2Targets).^2 ) / numel( testTargets ) );
    errorEachPeriod   = ( abs(testH2Outputs - testH2Targets) ) ./ ( abs(testH2Outputs) + abs(testH2Targets) );
    smapeTestHT2Forecast = 100 * ( 2* sum(errorEachPeriod) ) / numel( testTargets ); 
    clear errorEachPeriod;
    
    %% OUPUT DATA       ===================================================================
    
    forecastResults.trainTargets = trainTargets;
    forecastResults.valTargets   = valTargets; 
    forecastResults.testTargets  = testTargets;
    
    forecastResults.trainOutputs  = trainOutputs;
    forecastResults.valHT1Outputs  = valHT1Outputs;
    forecastResults.testHT1Outputs = testHT1Outputs;
        
    forecastResults.valHT2Targets  = valHT2Targets; 
    forecastResults.valHT2Outputs  = valHT2Outputs;
    
    forecastResults.testHT2Targets = testH2Targets;
    forecastResults.testHT2Outputs = testH2Outputs;
    
    forecastResults.rmseTrain           = rmseTrain;
    forecastResults.rmseValHT1Forecast  = rmseValHT1Forecast; 
    forecastResults.rmseTestHT1Forecast = rmseTestHT1Forecast; 
    forecastResults.rmseValHT2Forecast  = rmseValHT2Forecast; 
    forecastResults.rmseTestHT2Forecast = rmseTestHT2Forecast; 
    
    forecastResults.smapeTrain           = smapeTrain;
    forecastResults.smapeValHT1Forecast  = smapeValHT1Forecast; 
    forecastResults.smapeTestHT1Forecast = smapeTestHT1Forecast; 
    forecastResults.smapeValHT2Forecast  = smapeValHT2Forecast; 
    forecastResults.smapeTestHT2Forecast = smapeTestHT2Forecast;
    
    
    

end % END OF THE FUNCTION