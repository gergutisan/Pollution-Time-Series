function [ validForecast , testForecast ] = getANNForecastResults_v02( net , tsData , parameters )

    
    trainPrct = parameters.trainPrct;
    valPrct   = parameters.valPrct;
    testPrct  = parameters.testPrct;
    
    nTs = numel(tsData);
    
    lastIndexTrain = ceil( trainPrct * nTs );
    lastIndexVal   = ceil( ( trainPrct + valPrct) * nTs);
    
    trainTargets = tsData( 1:(lastIndexTrain));
    valTargets   = tsData( (lastIndexTrain + 1):lastIndexVal);
    testTargets  = tsData( (lastIndexVal + 1):end); 
        
    knownTrTargets      = trainTargets;  
    knownValTargets     = valTargets;  
    knownTeTargets      = testTargets;  
    knownTrValTeTargets = cat( 1 , trainTargets , valTargets , testTargets );
    knownTrValTargets   = cat( 1 , trainTargets , valTargets );     
    
    nInputs  = net.inputs{1}.size;
    %%  Computing the forecast values (using previously forecast values )  ----------------
    % IMPROVEMENTS, where is this on -> net.inputs{1}.size    
            
    % for VALIDATION subset      ------------------------------
   
    b = lastIndexTrain; a = lastIndexTrain - nInputs + 1;
    
    inputPattern = knownTrTargets( (end - nInputs + 1):end) ;
    for iVal = 1:numel(valTargets)
        % a individual input pattern must be a colum vector => get the transpose
        outputNet = sim(net,inputPattern); 
        target = knownValTargets(iVal); 

        validTarget(iVal)   = target;
        validForecast(iVal) = outputNet;

        % new input pattern 
        v = inputPattern(2:end); 
        inputPattern = cat( 1 , v , outputNet ); clear v;

    end
    clear output target inputPattern

    % for TEST subset           ------------------------------
    
    inputPattern = knownTrValTargets( (end - nInputs + 1):end) ;
    for iTe = 1:numel(testTargets)
        % a individual input pattern must be a colum vector => get the transpose
        outputNet   = sim(net,inputPattern); 
        target       = knownTeTargets(iTe); 

        testTarget(iTe)   = target;
        testForecast(iTe) = outputNet;

        % new input pattern 
        v = inputPattern(2:end); 
        inputPattern = cat( 1 , v , outputNet ); clear v;

    end
    
       







%% OUPUT DATA       ===================================================================
    

end % END OF THE FUNCTION






















































