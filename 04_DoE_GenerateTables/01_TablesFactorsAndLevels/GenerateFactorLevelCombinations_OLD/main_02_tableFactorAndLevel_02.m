clear; clc; close all; fclose('all');

%% INFO     =============================================================================
% THIS SCRIPT GENERATES THE TABLE FOR THE FULL FACTORIAL COMBINATION
% OF FACTOR-LEVEL TABLE (factor: attribute/parameter ; level: its available values);
% =======================================================================================

%% LIST OF FACTOR AND IT LEVELS     =====================================================

%listNumInputs = [ 5 , 10 , 15, 20 ];                        % listNumInputs = minInputs:maxOutputs;
%listHiddenLayersSize = [ 5 , 10 , 15, 20, 25, 30, 35, 40 ]; % listHiddenLayersSize = ...;

% Pollution Data 
listNumInputsHiddeLayerSize = { 14 , [06 09 12 18 24 36 48 50] ; ...
                                28 , [06 12 18 24 36 48 50 62] ; ...
                                40 , [12 18 24 30 36 48 54 60] ; ...
                                52 , [24 30 36 42 48 54 60 66] ; ...
                                64 , [30 36 42 48 54 60 66 72] ; ...
                                76 , [36 42 48 54 60 66 72 78] ; ...
                                96 , [42 48 54 60 66 72 78 84] };

% listLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
listLearnAlg  = {'trainlm', 'trainrp', 'trainscg' };
listLR        = [0.01 , 0.05 , 0.1 , 0.2  ];
listTrCyc     = [1000 , 2000, 5000 , 1000 ] ;

%% --------------------------------------------------------------------
counter = 0;

s = 0;
for i = 1:size(listNumInputsHiddeLayerSize,1)
  s = s + size(listNumInputsHiddeLayerSize{i,2},2);
end;
nSim = s * size(listLearnAlg,2) *  size(listLR ,2) * size(listTrCyc ,2);
%% --------------------------------------------------------------------
factorLevelFilename = strcat('factorLevelsTable_PollutionData.txt');
fid = fopen(factorLevelFilename,'w');

fprintf(fid,'%% nSim -> %7i\n',nSim);
fprintf(fid,'%%%10s %10s %10s %10s %10s %10s\n', ...
            'nExp', 'nIn' , 'hLS' , 'trFcn', 'lr' , 'trC');


%% --------------------------------------------------------------------

inputLevel = 0;
for a = 1:size(listNumInputsHiddeLayerSize,1)
  listNumInputs(a) = listNumInputsHiddeLayerSize{a,1};
end
clear a;

for i = listNumInputs
    parameters.nInputs = i;
    inputLevel = inputLevel + 1;
    % listHiddenLayersSize = getListHiddenLayersSize(parameters.nInputs);
    listHiddenLayersSize = listNumInputsHiddeLayerSize{inputLevel,2};
    
    for j = listHiddenLayersSize
        parameters.hiddenLayersSize = j;
        
        for learnAlg = listLearnAlg
            parameters.trainFcn = learnAlg{1};
        
            for lr = listLR
                parameters.learningRate = lr;
            
                for trC = listTrCyc 
                    parameters.trCycles = trC * 10^3;
            
                    counter = counter + 1;
                    parameters.counter = counter;
                    
                    % fprintf('\n #%06i\n',counter);
                    
                    fprintf(fid,' %10i %10i %10i %10s %10.2f %10d\n',...
                             counter,...
                             parameters.nInputs,...
                             parameters.hiddenLayersSize,...
                             parameters.trainFcn,...
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

    
