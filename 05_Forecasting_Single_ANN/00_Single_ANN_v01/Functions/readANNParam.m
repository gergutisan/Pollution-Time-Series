function [ parameters ] = readAnnParam ( filename )

%readAnnParam: read some (those than can change) ANN parameters for a specific time series
%              indicated in a plain text file 

    % Default Parameters             -----------------------------
    parameters.nInputsArray          = 10;
    parameters.hiddenLayersSizeArray = { 5 5 };
    parameters.nValues4HiddenLayers  = numel(parameters.hiddenLayersSizeArray);
    parameters.trainFcnStrArray      = {'traingd'};     % Gradient descent backpropagation.
    parameters.trCycles              = { 1000 };
    parameters.learningRateArray     = { 0.05 };

    % Opening a reading a file   ----------------------------------
    
    fid = fopen(filename, 'r');
    if ( fid < 3) 
       fprintf('\nError trying to open the file %s \n', filename ); 
       return;
    else
        % Reading the file        ------------------------------------ç
        contentMatrix  = fscanf(fid,' % s %d',[2,inf]);
              
       
    end

    % output        ----------------------------------------------- 
    parameters;



end

