function patterns = ts2Patterns( tsData, nInputs, nOutputs )

% ts2pattern Turn a univariate time series into a pattern set 
%   ts -> pattern set, needs #inputs and #outputs

    % Get length/size 
    nTimes = numel(tsData);  % Univariate Time Series 
    
    % Patterns
    numPatterns = nTimes - (nInputs + nOutputs) + 1;

    % Preallocation
    patterns = zeros( numPatterns, nInputs + nOutputs);
    
    for i = 1: numPatterns
        a = i; 
        b = i + nInputs + nOutputs - 1;  
        patterns(i,:)= tsData(a:b); 
    end

end

