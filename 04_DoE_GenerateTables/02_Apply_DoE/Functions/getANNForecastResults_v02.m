function forecastResults = getANNForecastResults_v02( net , trainRecord , x , t )

    % x <- all ts data as patterns
    % t <- all ts data as targests 
    
    trainPatterns = x(:,trainRecord.trainInd);
    valPatterns   = x(:,trainRecord.valInd);
    testPatterns  = x(:,trainRecord.testInd);
    
    trainTargets  = t(:,trainRecord.trainInd);
    valTargets    = t(:,trainRecord.valInd);
    testTargets   = t(:,trainRecord.testInd);
    
    if ( size(trainTargets,1) == 1 ) 
        % univ TS data as a ROW VECTOR 

    elseif (size(trainTargets,2) == 1)
        % univ TS data as a COLUMN VECTOR => get the transpose
        trainTargets = trainTargets';
        valTargets   = valTargets'  ;
        testTargets  = testTargets' ;        
    end

    trainOutputs  = sim(net,trainPatterns);    
    valH1Outputs  = sim(net,valPatterns);
    testH1Outputs = sim(net,testPatterns);
    
    % This piece of source code will work with row vectors, because a individual pattern
    % for the nntool MUST BE A COLUM VECTOR

    knownTrTargets      = trainTargets;  
    knownValTargets     = valTargets;  
    knownTeTargets      = testTargets;  
    knownTrValTeTargets = cat( 2 , trainTargets , valTargets , testTargets );
    knownTrValTargets   = cat( 2 , trainTargets , valTargets );     

    %%  Computing the forecast values (using previously forecast values )  ----------------
    
    % IMPROVEMENTS, where is this on -> net.inputs{1}.size
    %nInputs = size(x,1);   
    nInputs = net.inputs{1}.size;

    % for VALIDATION subset
    inputPattern = knownTrTargets( (end - nInputs + 1):end) ;
    for iVal = 1:numel(valTargets)
        % a individual input pattern must be a colum vector => get the transpose
        outputNet = sim(net,inputPattern'); 
        target = knownValTargets(iVal); 

        valH2Targets(iVal) = target;
        valH2Outputs(iVal) = outputNet;

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
        target       = knownTeTargets(iTe); 

        testH2Targets(iTe) = target;
        testH2Outputs(iTe) = outputNet;

        % new input pattern 
        v = inputPattern(2:end); 
        inputPattern = cat( 2 , v , outputNet ); clear v;

    end
    clear output target inputPattern
     
    %% COMPUTE THE ERRORS       =========================================================
    % For H = 1
    % trainTargets,  valTargets , valH1Outputs , testTargets   , testH1Outputs
     rmseTrain          = ( 1/numel( trainTargets ) ) * sqrt( sum( ( trainTargets -  trainOutputs ).^2 ) );
    rmseValH1Forecast  = ( 1/numel(   valTargets ) ) * sqrt( sum( (   valTargets -  valH1Outputs ).^2 ) );
    rmseTestH1Forecast = ( 1/numel(  testTargets ) ) * sqrt( sum( (  testTargets - testH1Outputs ).^2 ) );
    
    errorEachPeriod     = ( abs( trainOutputs - trainTargets ) ) ./ ( abs(trainOutputs) + abs(trainTargets) );
    smapeTrain          = 100 * ( 2* sum(errorEachPeriod ) ) / numel( trainTargets ); 
    
    errorEachPeriod     = ( abs( valH1Outputs - valTargets ) ) ./ ( abs(valH1Outputs) + abs(valTargets) );
    smapeValH1Forecast  = 100 * ( 2* sum(errorEachPeriod  ) ) / numel( valTargets ); 
    
    errorEachPeriod     = ( abs( testH1Outputs - testTargets ) ) ./ ( abs(testH1Outputs) + abs(testTargets) );
    smapeTestH1Forecast = 100 * ( 2* sum(errorEachPeriod ) ) / numel( testTargets );
        
    % For H > 1)
    % trainTargets, valH2Targets, valH2Outputs , testH2Targets , testH2Outputs
    
    rmseValH2Forecast  = sqrt( sum ( ( valH2Outputs - valH2Targets).^2 ) / numel( valTargets ) );
    errorEachPeriod    = ( abs(valH2Outputs - valH2Targets) ) ./ ( abs(valH2Outputs) + abs(valH2Targets) );
    smapeValH2Forecast = 100 * ( 2* sum(errorEachPeriod) ) / numel( valTargets ); 
    clear errorEachPeriod;
        
    rmseTeH2Forecast  = sqrt( sum ( ( testH2Outputs - testH2Targets).^2 ) / numel( testTargets ) );
    errorEachPeriod   = ( abs(testH2Outputs - testH2Targets) ) ./ ( abs(testH2Outputs) + abs(testH2Targets) );
    smapeTeH2Forecast = 100 * ( 2* sum(errorEachPeriod) ) / numel( testTargets ); 
    clear errorEachPeriod;
    
    %% OUPUT DATA       ===================================================================
    
    forecastResults.trainTargets = trainTargets;
    forecastResults.valTargets   = valTargets; 
    forecastResults.testTargets  = testTargets;
    
    forecastResults.trainOutputs  = trainOutputs;
    forecastResults.valH1Outputs  = valH1Outputs;
    forecastResults.testH1Outputs = testH1Outputs;
    
    forecastResults.valH2Targets  = valH2Targets; 
    forecastResults.valH2Outputs  = valH2Outputs;
    
    forecastResults.testH2Targets = testH2Targets;
    forecastResults.testH2Outputs = testH2Outputs;
    
    forecastResults.rmseTrain          = rmseTrain;
    forecastResults.rmseValH1Forecast  = rmseValH1Forecast; 
    forecastResults.rmseTestH1Forecast = rmseTestH1Forecast; 
    forecastResults.rmseValH2Forecast  = rmseValH2Forecast; 
    forecastResults.rmseTeH2Forecast   = rmseTeH2Forecast; 
    
    forecastResults.smapeTrain          = smapeTrain;
    forecastResults.smapeValH1Forecast  = smapeValH1Forecast; 
    forecastResults.smapeTestH1Forecast = smapeTestH1Forecast; 
    forecastResults.smapeValH2Forecast  = smapeValH2Forecast; 
    forecastResults.smapeTeH2Forecast   = smapeTeH2Forecast;

end % END OF THE FUNCTION