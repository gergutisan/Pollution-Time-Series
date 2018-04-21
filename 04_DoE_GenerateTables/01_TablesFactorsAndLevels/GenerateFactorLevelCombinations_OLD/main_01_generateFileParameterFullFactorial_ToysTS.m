%%  CLEAR
clear; clc; close all; fclose('all');

%% Cell Array of Factors and their Levels
% row: one factor, and at their columns their levels
% factorAndLevels{i}[j]

setFactorLevels = 1; % 1,2,3 ... 

switch  setFactorLevels 
    case 0 
        %For Debugging purposes 
        factorAndLevels{1}= [ 1 , 2 , 3 ];
        factorAndLevels{2}= [ 4 , 5 , 6 ];
        factorAndLevels{3}= [ 7 , 8 ];
        
    case 1
        factorAndLevels{1}= [ 5 , 10 , 15 , 20];                      % num of input nodes 
        factorAndLevels{2}= [ 5 , 10 , 15 , 20 , 25, 30 , 35 , 40 ];  % num of hidden nodes
        factorAndLevels{3}= [ 5 , 6];                                 % num of learning Algorith   
        factorAndLevels{4}= [ 0.2 , 0.1 , 0.05 , 0.01];               % learning rate
        factorAndLevels{5}= [ 1 5 10 20];                             % trainning cycle  

    case 2
        factorAndLevels{1}= [ 5 , 10 , 15 , 20];                      % num of input nodes 
        factorAndLevels{2}= [ 5 , 10 , 15 , 20 , 25, 30 , 35 , 40 ];  % num of hidden nodes
        factorAndLevels{3}= [ 1 , 2 , 3, 4 , 5 , 6 , 7];                  % num of learning Algorith   
        factorAndLevels{4}= [ 0.2 , 0.1 , 0.05 , 0.01];               % learning rate
        factorAndLevels{5}= [ 1 5 10 20];                             % trainning cycle  
    
        
        % LEARNING ALGORITHMS
            % (#1) 'trainlm'   - Levenberg-Marquardt optimization, fastest backpropagation alg in the toolbox
            % (#2)'traingd'   - Gradient descent backpropagation.
            % (#3)'traingda'  - Gradient descent with adaptive lr backpropagation.
            % (#4)'traingdx'  - Variable Learning Rate Gradient Descent
            % (#5)'trainrp'   - RPROP Resilient Backpropagation.
            % (#6)'trainscg'  - Scaled conjugate gradient backpropagatio
            % (#7)'traingdm'  - Gradient Descent with Momentum

end;

%% FULL FACTORIAL 

% function to apply: fullfact([numLevelFactor1,numLevelFactor2, ...])
numFactors = size(factorAndLevels,2);
numLevels = zeros(1,numFactors);
for i = 1:numFactors
    numLevels(i) = size(factorAndLevels{i},2);
end;
matrix = fullfact(numLevels);
numCombinations = size(matrix,1);

if (size(matrix,2) ~= numFactors)
    errorMessage ='The number of factors and columns for \" full factorial \" matrix is not the same'; 
    error(message(errorMessage));
end;

matrixFactorLevel = zeros(numCombinations, numFactors);
for i = 1:numCombinations
    for j = 1:numFactors
      matrixFactorLevel(i,j) = factorAndLevels{j}(matrix(i,j)); 
   end;
end;

matrixFactorLevel = sortrows(matrixFactorLevel);

% filename = 'domAny_arrayParameters_FF.dat';
filename = strcat('domAny_setParameters',...
                   num2str(setFactorLevels,'%02d'),'_FF.dat');
fid = fopen(filename,'w');
for i = 1:numCombinations
    for j = 1:numFactors
        fprintf(    ' %6.2f', matrixFactorLevel(i,j));
        fprintf(fid,' %6.2f', matrixFactorLevel(i,j));
   end;
   fprintf('\n');
   fprintf(fid,'\n');
end;
fclose(fid);
 
 %% SOURCE CODE FOR EXECUTIONS
 %{
 
 for i = factorAndLevels{1}
      parameters.nInputs = i;
      inputLevel = inputLevel + 1;
      % listHiddenLayersSize = getListHiddenLayersSize(parameters.nInputs);
      listHiddenLayersSize = listNumInputsHiddeLayerSize{inputLevel,2};

      for j = listHiddenLayersSize
          parameters.hiddenLayersSize = j;

          for learnAlg = listLearnAlg
              % parameters.trainFcn = learnAlg{1};  % ->  listLearnAlg = {'train??',...,'train??'}
              % parameters.trainFcn = LEARNINGALGORITHMS{arrayOfParameters(i_run,4)};
              parameters.trainFcn = learnAlg;

              for lr = listLR
                  parameters.learningRate = lr;

                  for trC = listTrCyc 
                      parameters.trCycles = trC * 10^3;



                      counter = counter + 1;
                      parameters.counter = counter;

                      % fprintf('\n #%06i\n',counter);
                      fprintf(fidLog,'\n------------------\n\n');
                      fprintf(fidLog,'%06i ',counter);
                      % fprintf(fidLog,'%3i %4i %10s %5.2f %6i\n Learning ...\n ',...% ->  listLearnAlg = {'train??',...,'train??'}
                      fprintf(fidLog,'%3i %4i %5i %5.2f %6i\n Learning ...\n ',...
                               parameters.nInputs,...
                               parameters.hiddenLayersSize,...
                               parameters.trainFcn,...
                               parameters.learningRate,...
                               parameters.trCycles);

                      fprintf(fid,'%6i ',counter);
                      %fprintf(fid,'%3i %4i %10s %5.2f %6i',...
                      fprintf(fid,'%3i %4i %5i %5.2f %6i\n Learning ...\n ',...
                               parameters.nInputs,...
                               parameters.hiddenLayersSize,...
                               parameters.trainFcn,...
                               parameters.learningRate,...
                               parameters.trCycles);

                      tstart = tic;      

                      [result] = ann4tsForecast( parameters );

                      telapsed = toc(tstart);
                      minTime = min(telapsed,minTime);
                      maxTime = max(telapsed,minTime);
                      fprintf(fidLog,'finished.\n');    

                      resultsCellArray{counter} = result;                  
                      %delete(resultsCellArrayFilename);
                      %save(resultsCellArrayFilename,'resultsCellArray'); 


                      fprintf(fidLog,'Tr %10.5f %10.5f %10.5f %7.2f\n', ...
                                  result.mseTrainError,...
                                  result.rmseTrainError,...
                                  result.maeTrainError,...
                                  result.smapeTrainError);

                      fprintf(fidLog,'Va %10.5f %10.5f %10.5f %7.2f\n', ...
                                  result.mseValError,...
                                  result.rmseValError,...
                                  result.maeValError,...
                                  result.smapeValError);

                      fprintf(fidLog,'Te %10.5f %10.5f %10.5f %7.2f\n', ...
                                  result.mseTestError,...
                                  result.rmseTestError,...
                                  result.maeTestError,...
                                  result.smapeTestError);
                      % fprintf(fidLog,'\n');

                      fprintf(fid,'%10.5f %10.5f %10.5f %7.2f', ...
                                  result.mseTrainError,...
                                  result.rmseTrainError,...
                                  result.maeTrainError,...
                                  result.smapeTrainError);

                      fprintf(fid,'%10.5f %10.5f %10.5f %7.2f', ...
                                  result.mseValError,...
                                  result.rmseValError,...
                                  result.maeValError,...
                                  result.smapeValError);

                      fprintf(fid,'%10.5f %10.5f %10.5f %7.2f', ...
                                  result.mseTestError,...
                                  result.rmseTestError,...
                                  result.maeTestError,...
                                  result.smapeTestError);
                      fprintf(fid,'\n');        

                  end;
              end;            
          end;
      end;
  end;
 %}

