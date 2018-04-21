clear; clc; close all; fclose('all');


trainCyclesBase        = 10^2;
factorsAndLevelsOption = 0;  
                             % #0 -> small/tinny combination for Debugging following source code
                             % #1 -> full factorial and L16 Taguchi Orthogonal Vector    
                             % #2 -> Stepwise selection of the # input nodes and 
                             %       the # number of nodes in the single hidden layer.

%% FACTOR AND LEVEL values      ================================================================
 %{
        %         (#1) trainlm  ->  1
        %         (#2) traingd  ->  2
        %         (#3) traingda ->  3
        %         (#4) traingdx ->  4
        %         (#5) trainrp  ->  5
        %         (#6) trainscg ->  6
        %         (#7) traingdm ->  7
 %}

switch  factorsAndLevelsOption
    % POLLUTION DATA
    
    case 0 % -----------------------------------------------------------------
    
        % Small/tinny combination for Debugging following source code
        
        listNumInputsHiddeLayerSize = {  14, [ 12 24 ] ; ...
                                         28, [ 24 48 ] };
        
        
        %listNumInputsHiddeLayerSize = {  07 , [03 06 12] ; ...
        %                                 14, [ 12 24 ] ; ...
        %                                 28, [ 24 48 ] };
                                     
        listLearnAlgStr  = {'trainrp', 'trainscg'};
        listLearnAlg  = {5 , 6 };
        listLR        = [0.1];
        listTrCyc     = [1000];   
    
    case 1 % -----------------------------------------------------------------
        
        % FULL FACTORIAL SELECTION
        listNumInputs        = [ 07, 14 , 28 , 40 , 52 , 64 , 76 , 88 , 100 ];
        % listNumInputs = minInputs:maxOutputs;
        
        listHiddenLayersSize = [ 03 , 04 , 06 , 09 , 12 , 18 , 24 , 30 , 36 , ...
                                 42 , 48 , 54 , 60 , 66 , 72 , 78 , 84 ]; % listHiddenLayersSize = ...;

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
        %listLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
        
        listLearnAlgStr  = {'trainlm','trainrp', 'trainscg'};
        listLearnAlg  = {1,5,6};
        listLR        = [ 0.2  , 0.1  , 0.05 ];
        listTrCyc     = [ 1000 , 2000 , 5000 ];   % POLLUTION DATA
    
    case 2  % -----------------------------------------------------------------
    
        % STEPWISE SELECTION of the # input nodes and the # number of nodes in
        % the single hidden layer.

        % POLLUTION RAW DATA
        listNumInputsHiddeLayerSize = { 07 , [03 04 06 09 12 18 21 24 ] ; ...
                                        14 , [06 09 12 18 24 30 36 42 ] ; ...
                                        28 , [09 12 18 24 30 36 42 48 ] ; ...
                                        40 , [12 18 24 30 36 42 48 54 ] ; ...
                                        52 , [18 24 30 36 42 48 54 60 ] ; ...
                                        64 , [24 30 36 42 48 54 60 66 ] ; ...
                                        76 , [36 42 48 54 60 66 72 78 ] ; ...
                                        88 , [42 48 54 60 66 72 78 84 ] ; ...
                                       100 , [42 48 54 60 66 72 78 84 ] };

        % listLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
        listLearnAlgStr  = {'trainlm', 'trainrp', 'trainscg'};
        listLearnAlg  = {1,5,6};
        
        listLR        = [ 0.2  , 0.1  , 0.05 ];
        listTrCyc     = [ 1000 , 2000 , 5000 ];
  
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

%% ------------------------------------------------------------------
strType_FLComb = '';            % default value 
switch factorsAndLevelsOption
    case 0
        strType_FLComb = 'Tinny';
    case 1
        strType_FLComb = 'FullFactorial';
    case 2
        strType_FLComb = 'StepWise';
end

factorLevelFilename = strcat( 'factorLevelsTable_Pollution_', strType_FLComb,'.txt');
                           
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
        for iLearnAlg = 1:numel(listLearnAlg ) 
            % third factor
            parameters.trainFcnStr  = listLearnAlgStr{iLearnAlg};
            parameters.trainFcnCode = listLearnAlg{iLearnAlg};
            
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

    
