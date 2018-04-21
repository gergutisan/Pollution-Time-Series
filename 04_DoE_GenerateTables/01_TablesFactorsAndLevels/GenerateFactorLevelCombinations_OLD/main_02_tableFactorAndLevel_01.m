clear; clc; close all; fclose('all');

factorsAndLevelsOption = 1;  % #1 -> full factorial and L16 Taguchi Orthogonal Vector 

switch  factorsAndLevelsOption
  
  case 1
    listNumInputs = [ 5 , 10 , 15, 20 ];                        % listNumInputs = minInputs:maxOutputs;
    listHiddenLayersSize = [ 5 , 10 , 15, 20, 25, 30, 35, 40 ]; % listHiddenLayersSize = ...;
    
    listNumInputsHiddeLayerSize = cell(numel(listNumInputs),2);
    
    for i = 1:numel(listNumInputs)
        listNumInputsHiddeLayerSize{i,1} = listNumInputs(i);
        listNumInputsHiddeLayerSize{i,2} = listHiddenLayersSize;
    end;
    
    %{ 
      listNumInputsHiddeLayerSize = {  5 , listHiddenLayersSize; ... 
                                      10 , listHiddenLayersSize; ...
                                      15 , listHiddenLayersSize; ...
                                      20 , listHiddenLayersSize };
    %}
                                 
                                 
    
  case 2
    
    % Stepwise selection of the # input nodes and the # number of nodes in
    % the single hidden layer.
    listNumInputsHiddeLayerSize = {  5, [2 5 10]               ; ...
                                    10, [5 10 15 20]           ; ...
                                    15, [5 10 15 20 25 30]     ; ...
                                    20, [10 15 20 25 30 35 40] };
  
  otherwise
    
    message = '\n\n ERROR: wrong value for factorsAndLevelsOption (the type of set for factors and their levels.\n\n';
    fprintf(message);
    
    
end;

  
if ( factorsAndLevelsOption == 1 )
  
  
elseif ( factorsAndLevelsOption == 2 )
  
%{
  
%} 

else
  
end;
  
listLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
listLR        = [0.2 , 0.1 , 0.05 , 0.01 ];
listTrCyc     = [ 1 , 5 , 10 , 20 , 50];

%% Number of combinations ----------------------------------------------

counter = 0;  s = 0;
for i = 1:size(listNumInputsHiddeLayerSize,1)
  s = s + size(listNumInputsHiddeLayerSize{i,2},2);
end;
nSim = s * size(listLearnAlg,2) *  size(listLR ,2) * size(listTrCyc ,2);


%% --------------------------------------------------------------------
factorLevelFilename = strcat('factorLevelsTable_FullFactorial.txt');
fid = fopen(factorLevelFilename,'w');
fprintf(fid,'%% nSim -> %7i\n',nSim);
% fprintf(fid,'  nSim  Fact01  Fact02   Fact03    Fact04    Fact05\n');
fprintf(fid,'  nExp  nIn  hLS      trFcn    lr    trC\n');
fprintf(fid,'\n');        

%% --------------------------------------------------------------------

inputLevel = 0;
for a = 1:size(listNumInputsHiddeLayerSize,1)
  listNumInputs(a) = listNumInputsHiddeLayerSize{a,1};
end;
clear a;

for i = 1:(size(listNumInputsHiddeLayerSize,1))
    % first factor 
    parameters.nInputs = listNumInputsHiddeLayerSize{i,1};

    listHiddenLayersSize = listNumInputsHiddeLayerSize{i,2};
    
    for j = 1:( size( listNumInputsHiddeLayerSize( i, 2 ) ) )
        % second factor 
        parameters.hiddenLayersSize = listNumInputsHiddeLayerSize{j,2}(j);
        
        for learnAlg = listLearnAlg
            % third factor
            parameters.trainFcn = learnAlg{1};
        
            for lr = listLR
                % fourth factor
                parameters.learningRate = lr;
            
                for trC = listTrCyc 
                    % fith factor
                    parameters.trCycles = trC * 10^3;
                                
                    counter = counter + 1;
                    parameters.counter = counter;
                    
                    
                    
                    parameters.stringId = ;
                    
                    % fprintf('\n #%06i\n',counter);
                    
                    fprintf(fid,'%6i %3i %4i %10s %5.2f %6i\n',...
                             parameters.counter,...                             
                             parameters.nInputs,...
                             parameters.hiddenLayersSize,...
                             parameters.trainFcn,...
                             parameters.learningRate,...
                             parameters.trCycles);
                           
                
                end;
            end;            
        end;
    end;
end
fclose(fid);
fprintf('\n --- End of Program\n');
% quit;

    
