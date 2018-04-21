clear; clc; close all; fclose('all');


trainCyclesBase        = 10^2;
factorsAndLevelsOption = 5;  
                             % POLLUTION TIME SERIES
                             % #0 -> small/tinny combination for Debugging following source code
                             % #1 -> full factorial and L16 Taguchi Orthogonal Vector    
                             % #2 -> Stepwise selection of the # input nodes and 
                             %       the # number of nodes in the single hidden layer.
                             % ACADEMIC 01 TIME SERIES
                             % #3 -> full factorial for Academic 01
                             % #4 -> full factorial for Academic 02

listAllLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};                             
                                

%% FACTOR AND LEVEL values      ================================================================
switch  factorsAndLevelsOption
    
    case 0 % -----------------------------------------------------------------
    
        % Small/tinny combination for Debugging following source code
        
        listNumInputsHiddeLayerSize = {  28, [ 12 24 ] ; ...
                                         52, [ 24 48 ] };
                                     
        listLearnAlg  = {'trainrp', 'trainscg'};
        listLR        = [ 0.2  , 0.05 ];
        listTrCyc     = [ 1000 , 2000];   % POLLUTION DATA
        
        % NAME OF THE Factor Level Combination
        factorLevelFilename = strcat( 'factorLevelsTable_Tinny_v', ... 
                               num2str(factorsAndLevelsOption,'%02d'),'.txt');

    
    case 1 % -----------------------------------------------------------------
        listNumInputs        = [ 14 , 28 , 40 , 52 , 64 , 76 , 96 ];
        % listNumInputs = minInputs:maxOutputs;
        
        listHiddenLayersSize = [ 06 , 09 , 12 , 18 , 24 , 30 , 36 , ...
                                 42 , 48 , 54 , 60 , 66 , 72 , 78 , ...
                                 84 ]; % listHiddenLayersSize = ...;

        listNumInputsHiddeLayerSize = cell(numel(listNumInputs),2);

        for i = 1:numel(listNumInputs)
            listNumInputsHiddeLayerSize{i,1} = listNumInputs(i);
            listNumInputsHiddeLayerSize{i,2} = listHiddenLayersSize;
        end

        %{ 
          listNumInputsHiddeLayerSize = {  5 , listHiddenLayersSize; ... 
                                          10 , listHiddenLayersSize; ...
                                          15 , listHiddenLayersSize; ...
                                          20 , listHiddenLayersSize };
        %}
        %listALLLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
        
        listLearnAlg  = {'trainlm','trainrp', 'trainscg'};
        listLR        = [ 0.2  , 0.1  , 0.05 , 0.01 ];
        listTrCyc     = [ 1000 , 2000 , 5000 , 1000];   % POLLUTION DATA
        
        % NAME OF THE Factor Level Combination
        factorLevelFilename = strcat( 'factorLevelsTable_FFPollution_v', ... 
                               num2str(factorsAndLevelsOption,'%02d'),'.txt');

    
    case 2  % -----------------------------------------------------------------
    
        % Stepwise selection of the # input nodes and the # number of nodes in
        % the single hidden layer.

        % POLLUTION DATA 
        listNumInputsHiddeLayerSize = { 14 , [06 09 12 18 24 36 48 50] ; ...
                                        28 , [06 12 18 24 36 48 50 62] ; ...
                                        40 , [12 18 24 30 36 48 54 60] ; ...
                                        52 , [24 30 36 42 48 54 60 66] ; ...
                                        64 , [30 36 42 48 54 60 66 72] ; ...
                                        76 , [36 42 48 54 60 66 72 78] ; ...
                                        96 , [42 48 54 60 66 72 78 84] };

        % NAME OF THE Factor Level Combination
        factorLevelFilename = strcat( 'factorLevelsTable_StepWisePollution_v', ... 
                               num2str(factorsAndLevelsOption,'%02d'),'.txt');

  
     case 3  % -----------------------------------------------------------------
    
        % Stepwise selection of the # input nodes and the # number of nodes in
        % the single hidden layer.

        % ACACEMIC TIME SERIES INPUT DATA & HIDDEN LAYER SIZE
        listNumInputsHiddeLayerSize = { 5  , [02 03 04 05 06 07 08 09 10 ] ; ...
                                        10 , [05 07 08 09 10 12 15 18 20 ] ; ...
                                        15 , [05 08 10 12 15 18 20 25 30 ] ; ...
                                        20 , [10 12 15 18 20 25 30 35 40 ] ; ...
                                        25 , [10 12 15 20 25 30 40 45 50 ]  ; ...
                                        30 , [15 20 25 28 30 35 40 50 60] };

        % listLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
        listLearnAlg  = { 'trainrp', 'trainscg'};
        listLR        = [ 0.2  , 0.1  , 0.05 , 0.01 ];
        listTrCyc     = [ 1000 , 2000 , 5000 ];
       
        % NAME OF THE Factor Level Combination
        factorLevelFilename = strcat( 'factorLevelsTable_' , 'Academic_StepWise_v', ... 
                               num2str(factorsAndLevelsOption,'%02d'),'.txt');

      case { 4 , 5 }  % -----------------------------------------------------------------                           
          
        listNumInputs        = [ 05 , 10 , 15 , 20 , 25 , 30 ];
        % listNumInputs = minInputs:maxOutputs;
        
        listHiddenLayersSize = [ 03 , 04 , 05 , 08 , 10 , 12 , 15 , 18 , 20 , ... 
                                 25 , 30 , 35 , 40 , 45 , 50 , 55 , 60 ]; 
                             % listHiddenLayersSize = ...;

        listNumInputsHiddeLayerSize = cell(numel(listNumInputs),2);

        for i = 1:numel(listNumInputs)
            listNumInputsHiddeLayerSize{i,1} = listNumInputs(i);
            listNumInputsHiddeLayerSize{i,2} = listHiddenLayersSize;
        end
        listLearnAlg  = { 'trainrp', 'trainscg'};
        listLR        = [ 0.2  , 0.1  , 0.05 , 0.01 ];
        % listTrCyc     = [ 1000 , 2000 , 5000 ];
        listTrCyc     = 5000;

        % NAME OF THE Factor Level Combination
        factorLevelFilename = strcat( 'factorLevelsTable_Academic_FFv', ... 
                               num2str(factorsAndLevelsOption,'%02d'),'.txt');

% -----------------------------------------------------------------------------------------------
% listLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
% listLearnAlg  = {'trainlm', 'trainrp', 'trainscg'};
%         listLR        = [ 0.2  , 0.1  , 0.05 , 0.01 ];
%         listTrCyc     = [ 1000 , 2000 , 5000 , 1000 ];
        
  otherwise
    
    message = '\n\n ERROR: wrong value for factorsAndLevelsOption (the type of set for factors and their levels.\n\n';
    fprintf(message);

    
    
end


%% Number of combinations ----------------------------------------------

s = 0;
for i = 1:size(listNumInputsHiddeLayerSize,1)
  s = s + size(listNumInputsHiddeLayerSize{i,2},2);
end
nSim = s * size( listLearnAlg , 2 ) *  size( listLR , 2 ) * size( listTrCyc , 2 );

%% -------------------------------------------------------------------
% NAME OF THE Factor Level Combination
% Already done above

%% OPEN THE FILE                            
fid = fopen(factorLevelFilename,'w');

% fprintf(fid,'  nSim  Fact01  Fact02   Fact03    Fact04    Fact05\n');
% fprintf(fid,'%2s nSim -> %7i\n','%%',nSim);
% fprintf(fid,'%2snExp  nIn  hLS trFcn    lr    trC\n','%%');
% fprintf(fid,'\n');        

%% HEADER    ----------------------------------------------------------

fprintf('%% nSim -> %7i\n',nSim);
fprintf('%%%10s %10s %10s %10s %10s %10s\n', ...
            'nExp', 'nIn' , 'hLS' , 'trFcn', 'lr' , 'trC');


fprintf(fid,'%% nSim -> %7i\n',nSim);
fprintf(fid,'%%%10s %10s %10s %10s %10s %10s\n', ...
            'nExp', 'nIn' , 'hLS' , 'trFcn', 'lr' , 'trC');

        
%% --------------------------------------------------------------------

inputLevel = 0;
for a = 1:size(listNumInputsHiddeLayerSize,1)
  listNumInputs(a) = listNumInputsHiddeLayerSize{a,1};
end
clear a;

iExp = 0;
for i = 1:(size(listNumInputsHiddeLayerSize,1))
    % first factor 
    parameters.nInputs = listNumInputsHiddeLayerSize{i,1};

    listHiddenLayersSize = listNumInputsHiddeLayerSize{i,2};
    
    for j = 1:( numel( listHiddenLayersSize) )
        % second factor 
        parameters.hiddenLayersSize = listHiddenLayersSize(j);
        
        
        % for iLearnAlg = listLearnAlg
        % for iLearnAlg = listLearnAlg{5:6}
        for iLearnAlg = 1:numel( listLearnAlg ) 
            % third factor
            parameters.trainFcnStr  = listLearnAlg{iLearnAlg};
            parameters.trainFcnCode = getTrainFcnCode( parameters.trainFcnStr );
            
            for lr = listLR  
                
                % fourth factor
                parameters.learningRate = lr;
                            
                for trC = listTrCyc 
                    % fith factor
                    
                    % parameters.trCycles = trC * trainCyclesBase;
                    parameters.trCycles = trC;
                    
                    iExp = iExp + 1;
                    parameters.iExp = iExp;

                    % fprintf('\n #%06i\n',counter);
                    % parameters.stringId = ;
                    fprintf(fid,'%10i %10i %10i %10i %10.2f %10d\n',...
                             parameters.iExp,...
                             parameters.nInputs,...
                             parameters.hiddenLayersSize,...
                             parameters.trainFcnCode, ... % parameters.trainFcn,...
                             parameters.learningRate,...
                             parameters.trCycles);
                    
                    fprintf('% 10i %10i %10i %10i %10.2f %10d\n',...
                             parameters.iExp,...
                             parameters.nInputs,...
                             parameters.hiddenLayersSize,...
                             parameters.trainFcnCode, ... % parameters.trainFcn,...
                             parameters.learningRate,...
                             parameters.trCycles);                
                end
            end         
        end
    end
end
fclose(fid);
fprintf('\n --- End of Program\n');
% quit;   


%% LOCAL FUNCTIONS   =======================================================================

function trainFcnCode = getTrainFcnCode( trainFcnStr , listAllLearnAlg , listLearnAlg )

    trainFcnCode = 0;
    i = 1;
    while ( trainFcnCode == 0 ) && ( i <= numel(listAllLearnAlg) )
        
        if ( strcmp ( listLearnAlg{i}, trainFcnStr ) ) 
            trainFcnCode = i;
        else 
            i = i + 1 ;
        end
        
    end

  
end

