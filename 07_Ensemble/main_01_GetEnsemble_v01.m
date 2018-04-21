%{
 
	Data structure for expResults. 
    expResults: 12 x k cell array 
    	each colum is each iteration (from k =10 iterations, k = 2 for debugginh )
     
        each row is for each time series each combination of raw, dif, inc by each
        
            if #timeSeries is nTS => first  #timeSeries are for raw ts Data 
                                     second #timeSeries are for dif ts Data
                                     third  #timeSeries are for inc ts Data

    In each element of this cell array, there is a (1-D) cell array for each 
    result for Factor Level Combination with the errors and the forecasted 
    values (as arrays).

%}

%% RESET      =============================================================================
close all; fclose('all'); clc; 
% clear; 
clearvars -except doeResults; 
clear 

%% SET FOLDERs AND PATH     ===============================================================
cd(fileparts(mfilename('fullpath')));    % does not work if executed by Run Section [and advance]
folderFunctions       = fullfile( fileparts(mfilename('fullpath')),'Functions');
folderTimeSeries      = fullfile( fileparts(mfilename('fullpath')),'TimeSeries');
folderFigures         = fullfile( fileparts(mfilename('fullpath')),'Figures');
folderResultsDoE      = fullfile( fileparts(mfilename('fullpath')),'Results_DoE');
folderResultsEnsemle  = fullfile( fileparts(mfilename('fullpath')),'Results_Ensemble');
folderFactorLevelComb = fullfile( fileparts(mfilename('fullpath')),'TablesFactorsAndLevels');

path( folderFunctions       , path );
path( folderTimeSeries      , path );
path( folderFigures         , path );
path( folderResultsDoE      , path );
path( folderResultsEnsemle  , path );
path( folderFactorLevelComb , path );

%% SCREEN SIZE              ==============================================================
setScreenSize( 0.1 , 0.8 ); % leftBottomCornerPos <- 0.1; rateScreenSize <- 0.8;
% h = figure(); % for debugging purposes

%% READ PARAMETER FILE      ==============================================================
% paramExpFilename = 'parametersExperiment.dat';
% paramExp = readParametersExperimentFile(paramExpFilename);

%% DEBUGGING    ==========================================================================

%parameters.doeResultsFilename = 'expResultsAll_00.mat'; 
parameters.doeResultsFilename = 'expResultsAll_01.mat'; 


parameters.debugging   = 0;  % 1/0
parameters.incRound    = 1;  % 1/0
parameters.bestByRMSE  = 0;  % 1/0
parameters.bestBySMAPE = 1;  % 0/1 
parameters.ensembleCombination =  1;  % -> values: 1 2 3 12 23 13 123

parameters.testPrct  = 0.1;
parameters.valPrct   = 0.1;
parameters.trainPrct = 0.8;


fprintf('%-40s %40s\n', 'parameters.doeResultsFilename'  , parameters.doeResultsFilename   );
fprintf('%-40s %5d\n' , 'parameters.debugging'           , parameters.debugging   );
fprintf('%-40s %5d\n' , 'parameters.incRound'            , parameters.incRound    );
fprintf('%-40s %5d\n' , 'parameters.bestByRMSE'          , parameters.bestByRMSE  );
fprintf('%-40s %5d\n' , 'parameters.bestBySMAPE'         , parameters.bestBySMAPE );
fprintf('%-40s %5d\n' , 'parameters.ensembleCombination' , parameters.ensembleCombination );
% fprintf('%40s %5d\n', 'parameters. ' , parameters.  );   % Template 


%% DATA      =============================================================================

% DATA NAMES   
if ( parameters.debugging == 1 )
    tsNamesCellArray = {'NO2-FedzLadreda-16-12' , ...
                        'NO2-PzCastilla-16-10'  , ...
                        'O3-JuanCarlosI-16-07'  , ... 
                        'PM25-MendezAlvaro-16-10'};
elseif ( parameters.debugging == 0 )
    tsNamesCellArray = {'NO2-FedzLadreda-16-12' , ...
                        'NO2-PzCastilla-16-10'  , ...
                        'O3-JuanCarlosI-16-07'  , ... 
                        'PM25-MendezAlvaro-16-10'};
end

% SPLIT THE TASK
tsTypesCellArray = {'raw', 'dif', 'inc'};

% -----------------------------------------------
% Create list CellArry of tsName & tsType
%             e.g. {'Dowjones','raw'}  
tsName_tsType_CellArray = createTsNameTsTypeCellArray( tsNamesCellArray , tsTypesCellArray );
% filename = 'tsName_tsType_CellArray.mat'; save(filename, 'tsName_tsType_CellArray');
% filename = 'tsName_tsType_CellArray.mat';   % ONLY IF WE HAVE ALL THE EXPERIMENTS
% load('-mat', filename);

% LOAD DATA from DoE Results     =========================================================

% load( fullfile( 'Results_DoE','expResultsAll.mat') );



if ( exist('doeResults', 'var') == 1 ) 
    fprintf('\n doeResults previously loaded.\n');
else
    fprintf('\n Loading DoE Results -> doeResults  ... ');
    initTimeTic = tic;
    
    S = load( fullfile( folderResultsDoE ,parameters.doeResultsFilename) );
    doeResults = S.expResults; clear S;

    finalTimeTic     = toc(initTimeTic) - initTimeTic;
    fprintf('\n %s loaded and copied\n', 'S.expResults');
    fprintf('%-30s %10.3f\n'   , 'finalTimeTic' , finalTimeTic     );

    
end


%% =============================================================================================
% folderResults_Prefix            = 'Results';
% fileResults_Prefix              = 'results';
% fileTheBestResults_Prefix       = 'results';
% fileTheBestResults_Suffix       = 'Best';
% fileMedian10bestResults_Suffix  = 'Median10best';

%% =============================================================================================
% maxInit <- ????? 
% maxInit = 10; 

nTsNames    = numel( tsNamesCellArray );
nTsTypes    = numel( tsTypesCellArray );
nExp        = size( doeResults , 2 );
nDoeResults = size( doeResults , 1 );
nTimeSeries  = nDoeResults / nTsTypes;

%% FOR EACH TIME SERIES *****************************************************************************

%for iterExp = 1:nExp
for iterExp = 1:1    
    for iTsType = 1:nTsTypes
        for indexTsName = 1:nTimeSeries  
        
            r = (iTsType -1)*(nTimeSeries) + indexTsName;
            c = iterExp;
            
            tsName = doeResults{r, c}{ 1 , 1}.tsName;
            tsType = doeResults{r, c}{ 1 , 1}.tsType;
            
            fprintf('%20s  %10s\n' , tsName, tsType);
            fprintf('r %3d  c %3d\n' , r, c);
        
            % Lets find the best result for this Factor level combinations
            % doeResults{r,c}
            
            bestSMAPEIndexFLC = 1; 
            bestSMAPE         = doeResults{r,c}{1}.smapeValH2Error; 
            bestRMSEIndexFLC  = 1; 
            bestRMSE          = doeResults{r,c}{1}.rmseValH2Error; 
            for iFLC = 2:numel(doeResults{r,c})
                
                if ( bestSMAPE > doeResults{r,c}{iFLC}.smapeValH2Error )
                    bestSMAPEIndexFLC = iFLC; 
                    bestSMAPE         = doeResults{r,c}{iFLC}.smapeValH2Error; 
                end
                if ( bestRMSE > doeResults{r,c}{iFLC}.rmseValH2Error )
                    bestRMSEIndexFLC = iFLC; 
                    bestRMSE         = doeResults{r,c}{iFLC}.rmseValH2Error; 
                end
            end
            
            fprintf('bestSMAPEIndexFLC %3d   bestSMAPE %10.5f \n' , bestSMAPEIndexFLC , bestSMAPE );
            fprintf('bestRMSEIndexFLC  %3d   bestRMSE  %10.5f \n' , bestRMSEIndexFLC , bestRMSE  );
            
            
            r2 = ( indexTsName - 1 )*( nTsTypes ) + iTsType ;
            c2 = c;
            if ( ( parameters.bestByRMSE == 0 ) &&  (parameters.bestBySMAPE == 1 ) )           
                bestFLModelTable_v01{r,c}   =  doeResults{r, c}{bestSMAPEIndexFLC};  
                bestFLModelTable_v02{r2,c2} =  doeResults{r, c}{bestSMAPEIndexFLC};  
            elseif ( ( parameters.bestByRMSE == 1 ) &&  (parameters.bestBySMAPE == 0 ) )            
                bestFLModelTable_v01{r,c} =  doeResults{r, c}{bestRMSEIndexFLC};  
                bestFLModelTable_v02{r2,c2} =  doeResults{r, c}{bestRMSEIndexFLC};  
            else     
                bestFLModelTable_v01{r,c} =  doeResults{r, c}{bestRMSEIndexFLC}; 
                bestFLModelTable_v02{r2,c2} =  doeResults{r, c}{bestRMSEIndexFLC};  
            end
            
            
            % KEEP THIS 
            % if ( ( parameters.bestByRMSE == 0 ) &&  (parameters.bestBySMAPE == 1 ) )           
            %     bestFLModelTable_v01{r,c} =  doeResults{r, c}{bestSMAPEIndexFLC};  
            % elseif ( ( parameters.bestByRMSE == 1 ) &&  (parameters.bestBySMAPE == 0 ) )            
            %     bestFLModelTable_v01{r,c} =  doeResults{r, c}{bestRMSEIndexFLC};  
            % else     
            %     bestFLModelTable_v01{r,c} =  doeResults{r, c}{bestRMSEIndexFLC};  
            % end
            % 
            % r2 = ( indexTsName - 1 )*( nTsTypes ) + iTsType ;
            % c2 = c;
            % bestFLModelTable_v02{r2,c2} =  doeResults{r, c}{bestSMAPEIndexFLC};  
            
            clear bestSMAPEIndexFLC bestSMAPE bestRMSEIndexFLC bestRMSE;
            
            fprintf('\n ---------------  \n' );
            
        end
        fprintf('\n ============\n' );
    end
    
    %% LETS GET THE ELEMENTS OF THE ENSEMBLE
    
    ensembleElementsAllTsAllIter = bestFLModelTable_v02;
    
    %% SHOW THE RESULTS OF TIME SERIES FOR EACH elements ofthe ensemble (i.e. Best DoE Results )
    for indexTsName = 1:nTimeSeries
        
        h1 = figure('Name', tsNamesCellArray{indexTsName});
        
        for iTsType = 1:nTsTypes
            
            % r = (iTsType -1)*(nTimeSeries) + indexTsName;
            r = (indexTsName -1)*(nTsTypes) + iTsType;
            c = iterExp;
            
            tsValForecast = bestFLModelTable_v02{r,c}.valH2Outputs;
            tsValTarget   = bestFLModelTable_v02{r,c}.valTargets;
            
            tsTestForecast = bestFLModelTable_v02{r,c}.testH2Outputs;
            tsTestTarget   = bestFLModelTable_v02{r,c}.testTargets;
            
            tVal  = bestFLModelTable_v02{r,c}.trainRecord.valInd;
            tTest = bestFLModelTable_v02{r,c}.trainRecord.testInd;
           
            subplot(2,2,iTsType);
            if ( iTsType == 1 ) || (  iTsType == 2  )
                plot(tVal,tsValTarget    ,'k'); hold on;
                plot(tVal,tsValForecast  ,'m');
                plot(tTest,tsTestTarget  ,'k');
                plot(tTest,tsTestForecast,'r');
                hold off;
            else
                plot(tVal,tsValTarget,'ok','MarkerSize', 6); hold on;
                plot(tVal,tsValForecast,'xm','MarkerSize', 10); 
                plot(tTest,tsTestTarget,'ok','MarkerSize', 6);
                plot(tTest,tsTestForecast,'xr','MarkerSize', 10);
                
                hold off;
            end
            title( strcat( tsNamesCellArray{indexTsName}," - model for ",tsTypesCellArray{iTsType} ) );
            
        end
        filename = fullfile(folderFigures,strcat('bR_FLC_',tsNamesCellArray{indexTsName},'.fig'));
        saveas ( h1 , filename ); 
        
        filename = fullfile(folderFigures,strcat('bR_FLC_',tsNamesCellArray{indexTsName},'.png'));
        saveas ( h1 , filename ); 
    end
    
    %fprintf('Program paused. Press any key ...');  pause; fprintf('\n');
    % close('all');
    
    
    
    %% LETS COMPUTE THE RESULTS OF EACH ELEMENT OF THE ENSEMBLE FOR ORIGINAL OBSERVATIONS 
    
    for indexTsName = 1:nTimeSeries      
        
        % raw, dif, inc
        r = (indexTsName - 1 ) * nTsTypes + 1;
        c = iterExp;
        
        tsRawData = load( fullfile( folderTimeSeries , strcat('ts-',tsNamesCellArray{indexTsName},'.csv') ) );
        
        nTimes = numel(tsRawData);
        
        indexLastTrain = ceil( nTimes * parameters.trainPrct );
        indexLastVal   = ceil( nTimes * (parameters.trainPrct + parameters.valPrct) );
                        
        valTarget4RawData{  indexTsName } = tsRawData( ( indexLastTrain + 1 ):indexLastVal);
        testTarget4RawData{ indexTsName } = tsRawData( ( indexLastVal   + 1 ):end);
       
        origLastTrain = tsRawData(indexLastTrain);
        origLastValid = tsRawData(indexLastVal);
        
        timesVal  = numel(valTarget4RawData{indexTsName});
        timesTest = numel(testTarget4RawData{indexTsName});
        
        for iTsType = 1:nTsTypes
            fprintf('compute result each element of the ensemble %3d (tsNumber) %3d (tsType)\n',indexTsName, iTsType);
            
            r = (indexTsName - 1 ) * nTsTypes + iTsType;
            
            valForecast4RawData{  indexTsName , iTsType } = zeros( timesVal , 1 );
            testForecast4RawData{ indexTsName , iTsType } = zeros( timesTest, 1 );
            
            switch iTsType 
                case 1 
                    
                    tsData = load( fullfile( folderTimeSeries , strcat('ts-',tsNamesCellArray{indexTsName},'-raw.csv') ) );
                    
                    net = ensembleElementsAllTsAllIter{r,c}.net;
                    strTtype = "raw"; tsRawData; parameters;
                    [valForecast4RawData_01 , testForecast4RawData_01] = getANNForecastResults_v02( net , tsData, parameters ); 
                    
                    valForecast4RawData{  indexTsName , iTsType } =  valForecast4RawData_01';
                    testForecast4RawData{ indexTsName , iTsType } =  testForecast4RawData_01';
                    
                    
                    
                
                case 2
                    % Validation subset
                    tsData = load( fullfile( folderTimeSeries , strcat('ts-',tsNamesCellArray{indexTsName},'-dif.csv') ) );
                    net = ensembleElementsAllTsAllIter{r,c}.net;
                    [difValForecast_01 , difTestForecast_01] = getANNForecastResults_v02( net , tsData, parameters ); 
                    
                    difValForecast = difValForecast_01';
                    valPreviousValue = origLastTrain;
                    
                    for i = 1:timesVal 
                        valForecast4RawData{ indexTsName , iTsType }(i) = difValForecast(i) + valPreviousValue; 
                        valPreviousValue = valForecast4RawData{ indexTsName , iTsType }(i);
                    end
                    
                    % Test subset 
                    difTestForecast = difTestForecast_01';
                    testPreviousValue = origLastValid;
                    
                    for i = 1:timesTest 
                        testForecast4RawData{ indexTsName , iTsType }(i) = difTestForecast(i) + testPreviousValue; 
                        testPreviousValue = testForecast4RawData{ indexTsName , iTsType }(i);
                    end
                    
                    % forecast4RawData{ r , iTsType } =  ensembleElementsAllTsAllIter{r,c}.testH2Outputs;
                case 3
                    
                    tsData = load( fullfile( folderTimeSeries , strcat('ts-',tsNamesCellArray{indexTsName},'-inc.csv') ) );
                    net = ensembleElementsAllTsAllIter{r,c}.net;
                    [incValForecast_01 , incTestForecast_01] = getANNForecastResults_v02( net , tsData, parameters ); 
                    
                    % Validation subset
                    incValForecast   = incValForecast_01';
                    difValForecast   = difValForecast_01';
                    valPreviousValue = origLastTrain;
                    
                    for i = 1:timesVal 
                        
                        if ( parameters.incRound == 1 )
                            ensembleIncElemOutput = roundIncElementEnsemble( incValForecast(i) );
                        elseif ( parameters.incRound == 0 ) 
                            ensembleIncElemOutput = incValForecast(i);
                        end
                        
                        valForecast4RawData{ indexTsName , iTsType }(i) = ensembleIncElemOutput * abs(difValForecast(i)) + valPreviousValue;
                        valPreviousValue = valForecast4RawData{ indexTsName , iTsType }(i);
                    end
                    
                    % Test subset 
                    incTestForecast = incTestForecast_01';
                    difTestForecast = difTestForecast_01';
                    testPreviousValue = origLastValid;
                    
                    for i = 1:timesTest 
                        
                        if ( parameters.incRound == 1 )
                            ensembleIncElemOutput = roundIncElementEnsemble( incTestForecast(i) );
                        elseif ( parameters.incRound == 0 ) 
                            ensembleIncElemOutput = incTestForecast(i);
                        end
                        testForecast4RawData{ indexTsName , iTsType }(i) = ensembleIncElemOutput * abs(difTestForecast(i)) + testPreviousValue; 
                        testPreviousValue = testForecast4RawData{ indexTsName , iTsType }(i);
                    
                    end
                    % forecast4RawData{ r , iTsType } =  ensembleElementsAllTsAllIter{r,c}.testH2Outputs;
                    
            end
    
        end
        
    end
    
    clear valForecast4RawData_01 testForecast4RawData_01;
    
    fprintf('---\n');  
%     for indexTsName = 1:nTimeSeries  
%         for iTsType = 1:nTsTypes
%             valForecast4RawData{  indexTsName , iTsType } = ( valForecast4RawData{ indexTsName , iTsType } )';
%             testForecast4RawData{ indexTsName , iTsType } = ( testForecast4RawData{ indexTsName , iTsType })';
%         end
%     end

    %% LETS SHOW THE VAL AND TEST FORECAST MADE BY EACH ELEMENT OF THE ENSEMBLE ON VAL AND TEST SET
    % valTarget4RawData   valForecast4RawData
    % testTarget4RawData  testForecast4RawData 
    
     for indexTsName = 1:nTimeSeries  
         
        h2 = figure('Name', tsNamesCellArray{indexTsName}); 
        
        for iTsType = 1:nTsTypes
            
            targetVal  = valTarget4RawData{indexTsName};
            tVal = 1:numel(targetVal); 
            targetTest = testTarget4RawData{indexTsName};
            tTest = (1:numel(targetTest)) + numel(targetVal);
            
            forecastVal  = valForecast4RawData{indexTsName,iTsType};
            forecastTest = testForecast4RawData{indexTsName,iTsType};
            
            
            strMarkerValTarget    = 'k';
            strMarkerValForecast  = 'm';
            strMarkerTestTarget   = 'k';
            strMarkerTestForecast = 'r';                

            subplot(2,2,iTsType);
            plot(tVal,targetVal    , strMarkerValTarget    ); hold on;
            plot(tVal,forecastVal  , strMarkerValForecast  );
            plot(tTest,targetTest  , strMarkerTestTarget   );
            plot(tTest,forecastTest, strMarkerTestForecast );
            hold off;           
            title( strcat( tsNamesCellArray{indexTsName},' - ','EE from ',tsTypesCellArray{iTsType}, 'model' ) );
            
        end
        
        filename = fullfile(folderFigures,strcat('EE_Results_',tsNamesCellArray{indexTsName},'.fig'));
        saveas (h2 , filename ); 
        
        filename = fullfile(folderFigures,strcat('EE_Results_',tsNamesCellArray{indexTsName},'.png'));
        saveas (h2 , filename ); 
        
     end   
    
    
    
    
    
    %%  LETS COMPUTE THE ERRROR ON ORIGINAL OBSERVATION OF EACH ELEMENT OF THE ENSEMBLE  ========
    for indexTsName = 1:nTimeSeries  
        for iTsType = 1:nTsTypes
            
             % VALIDATION ============================================================
             targets  = valTarget4RawData{ indexTsName};
             forecast = valForecast4RawData{ indexTsName , iTsType};

             rmseTmp  = ( 1/numel( targets ) ) * sqrt( sum( ( targets -  forecast ).^2 ) );
             errorEachPeriod = ( abs( forecast - targets ) ) ./ ( abs(forecast) + abs(targets) );
             smapeTmp = 100 * ( 2* sum(errorEachPeriod ) ) / numel( targets );  

             rmseVal(  indexTsName , iTsType ) = rmseTmp;
             smapeVal( indexTsName , iTsType ) = smapeTmp;

             % TEST       ============================================================
             targets  = testTarget4RawData{ indexTsName};
             forecast = testForecast4RawData{ indexTsName , iTsType};

             rmseTmp  = ( 1/numel( targets ) ) * sqrt( sum( ( targets -  forecast ).^2 ) );
             errorEachPeriod = ( abs( forecast - targets ) ) ./ ( abs(forecast) + abs(targets) );
             smapeTmp = 100 * ( 2* sum(errorEachPeriod ) ) / numel( targets );  

             rmseTest(  indexTsName , iTsType ) = rmseTmp;
             smapeTest( indexTsName , iTsType ) = smapeTmp;

         end
    end
     
     fprintf('ERROR on original observations for each tsName (row) and modelFromTsType (col)\n'); 
     fprintf('rmse  Val\n');  disp(rmseVal)
     fprintf('rmse  Test\n'); disp(rmseTest)
     fprintf('smape Val\n');  disp(smapeVal)
     fprintf('smape Test\n'); disp(smapeTest)
          
     
    
     
    %% LETS COMPUTE THE WEIGHT FROM ERROR ON VALIDATION ORIGINAL OBSERVATIONS 
    
    
    
    for indexTsName = 1:nTimeSeries  
         
        sumRmseVal  = 0; 
        sumSmapeVal = 0; 
        
        switch parameters.ensembleCombination
            case 1
                vecEnsembleComb = [ 1 0 0];
            case 2
                vecEnsembleComb = [ 0 1 0];            
            case 3
                vecEnsembleComb = [ 0 0 1];            
            case 12
                vecEnsembleComb = [ 1 1 0];            
            case 13
                vecEnsembleComb = [ 1 0 1];            
            case 23
                vecEnsembleComb = [ 0 1 1];            
            case 123
                vecEnsembleComb = [ 1 1 1];
        end
        
        for iTsType = 1:nTsTypes
            sumRmseVal  = sumRmseVal  + ( vecEnsembleComb(iTsType) * rmseVal(   indexTsName , iTsType ) );
            sumSmapeVal = sumSmapeVal + ( vecEnsembleComb(iTsType) * smapeVal(  indexTsName , iTsType ) );
        end
        
        numTs4Weights = sum(vecEnsembleComb);
        for iTsType = 1:nTsTypes
            
            
            if ( numTs4Weights == 1 )
                weightsRmse( indexTsName , iTsType )   = vecEnsembleComb(iTsType);
                weightsSmape( indexTsName , iTsType ) = vecEnsembleComb(iTsType);
            else
                errEnsembleElement = rmseVal( indexTsName , iTsType );
                weightsRmse( indexTsName , iTsType ) = ( vecEnsembleComb(iTsType) ) * ( 1/(numTs4Weights- 1) ) * ((sumRmseVal - errEnsembleElement )/sumRmseVal);
            
                errEnsembleElement = smapeVal( indexTsName , iTsType );
                weightsSmape( indexTsName , iTsType ) = ( vecEnsembleComb(iTsType) )* ( 1/(numTs4Weights-1) ) * ((sumSmapeVal - errEnsembleElement )/sumSmapeVal);
            
            end
        end
    end
    
    fprintf('W rmse  Val\n');  disp(weightsRmse);
    fprintf('W smape Val\n');  disp(weightsSmape);
    
    %fprintf('Pause. Press any key ... '); pause;fprintf('\n');
    
    
    
    %% LETs Combine the results from the ensemble ======================================
    % For each Time Series and each tsType we got the best model from DoE FL combinations
    
    
    %combined with weightsRmse    ------------------------------------------------------
    
    
    ensembleForecast = cell(1,nTimeSeries);
    
    for indexTsName = 1:nTimeSeries  
        
        
        % Compute the output of the ensemble 
        % testForecast4RawData{nTimeSeries , nTsTypes};
        nTestTime = numel( testForecast4RawData{indexTsName , 1} );
        ensembleForecast{indexTsName} = zeros( nTestTime, 1 );
                
        for iTsType = 1:nTsTypes
            
            ensembleForecast{indexTsName} = ensembleForecast{indexTsName} + ...
                                            weightsRmse( indexTsName , iTsType ) * testForecast4RawData{ indexTsName , iTsType } ;
        end
        
        % Compute the error ON TEST from output of the ensemble 
        % TEST       ============================================================
        targets  = testTarget4RawData{ indexTsName};
        forecast = ensembleForecast{   indexTsName};

        rmseTmp  = ( 1/numel( targets ) ) * sqrt( sum( ( targets -  forecast ).^2 ) );
        errorEachPeriod = ( abs( forecast - targets ) ) ./ ( abs(forecast) + abs(targets) );
        smapeTmp = 100 * ( 2* sum(errorEachPeriod ) ) / numel( targets );  

        rmseTestEnsemble(  indexTsName ) = rmseTmp;
        smapeTestEnsemble( indexTsName ) = smapeTmp;
        
        clear rmseTmp smapeTmp targets forecast;

    end
    
    fprintf('combined with weightsRMSE\n');
    fprintf('Ensemble rmse  Test\n');  disp(rmseTestEnsemble);
    fprintf('Ensemble smape Test\n');  disp(smapeTestEnsemble);
    
    %fprintf('Pause. Press any key ... '); pause;fprintf('\n');
    
    h4 = figure( 'Name' , 'Ensemble Forecast on test subset with weightsRMSE' );
    for indexTsName = 1:nTimeSeries  
        subplot(2,2,indexTsName);
        
        target   = testTarget4RawData{indexTsName}; 
        forecast = ensembleForecast{indexTsName}; 
        
        t = 1:numel(target);
        subplot(2,2,indexTsName); 
        plot(t, target   ,'-k');hold on;
        plot(t, forecast ,'-r');hold off;
        
        title(tsNamesCellArray{indexTsName});
        
    end
    
    
    %combined with weightsSmape ------------------------------------------------------
    
    ensembleForecast = cell(1,nTimeSeries);
    
    for indexTsName = 1:nTimeSeries  
        
        
        % Compute the output of the ensemble 
        % testForecast4RawData{nTimeSeries , nTsTypes};
        nTestTime = numel( testForecast4RawData{indexTsName , 1} );
        ensembleForecast{indexTsName} = zeros( nTestTime, 1 );
                
        for iTsType = 1:nTsTypes
            
            ensembleForecast{indexTsName} = ensembleForecast{indexTsName} + ...
                                            weightsSmape( indexTsName , iTsType ) * testForecast4RawData{ indexTsName , iTsType } ;
        end
        
        % Compute the error ON TEST from output of the ensemble 
        % TEST       ============================================================
        targets  = testTarget4RawData{ indexTsName};
        forecast = ensembleForecast{   indexTsName};

        rmseTmp         = ( 1/numel( targets ) ) * sqrt( sum( ( targets -  forecast ).^2 ) );
        errorEachPeriod = ( abs( forecast - targets ) ) ./ ( abs(forecast) + abs(targets) );
        smapeTmp        = 100 * ( 2* sum(errorEachPeriod ) ) / numel( targets );  

        rmseTestEnsemble(  indexTsName ) = rmseTmp;
        smapeTestEnsemble( indexTsName ) = smapeTmp;
        
        clear rmseTmp smapeTmp targets forecast;

    end
    
    fprintf('combined with weightsSMAPE\n');
    fprintf('Ensemble rmse  Test\n');  disp(rmseTestEnsemble);
    fprintf('Ensemble smape Test\n');  disp(smapeTestEnsemble);
    
    % fprintf('Pause. Press any key ... '); pause;fprintf('\n');
    
    
    
    h4 = figure( 'Name' , 'Ensemble Forecast on test subset with weightsSMAPE' );
    for indexTsName = 1:nTimeSeries  
        subplot(2,2,indexTsName);
        
        target   = testTarget4RawData{indexTsName}; 
        forecast = ensembleForecast{indexTsName}; 
        
        t = 1:numel(target);
        subplot(2,2,indexTsName); 
        plot(t, target   ,'-k');hold on;
        plot(t, forecast ,'-r');hold off;
        
        title(tsNamesCellArray{indexTsName});
        
    end
    
end


 
    
    
    
    



%% TO STOP the script 
return;


%% PREVIOUS SOURCE CODE

%% (LOCAL) FUNCTIONS *****************************************************************************
% ================================================================================================
function showOptionsInFile(filename , valPrctg , testPrctg , roundANNIncOutput , weightsOption )
    if ( strcmp('screen',filename) == 1)
        fid = 1;
    else
        fid = fopen(filename);
    end;
    
    fprintf(fid,'==========================\n');
    fprintf(fid,'%20s  %02d\n','valPrctg      ' ,valPrctg);
    fprintf(fid,'%20s  %02d\n','testPrctg     ' ,testPrctg);
    fprintf(fid,'%20s  %02d\n','roundANNIncOutput ' ,roundANNIncOutput);
    fprintf(fid,'%20s  %02d\n','weightsOption ' ,weightsOption);       
    %fprintf(fid,'----\n');

end
% ================================================================================================
function tsName_tsType_CellArray = createTsNameTsTypeCellArray( tsNamesCellArray , tsTypesCellArray)
    
    tsName_tsType_CellArray = cell( numel(tsNamesCellArray) * numel(tsTypesCellArray), 2 );
    % e.g. -> tsNameTypeCellArray{1,1-2} = {'Dowjones','raw'}
    %         tsNameTypeCellArray{2,1-2} = {'Dowjones','dif'}
    for i = 1:numel( tsNamesCellArray )
      for j = 1:numel( tsTypesCellArray )
            row = ( (i-1) * numel( tsTypesCellArray ) ) + j;
            tsName_tsType_CellArray {row,1} = tsNamesCellArray{i};
            tsName_tsType_CellArray {row,2} = tsTypesCellArray{j};    
      end
    end

end

% ================================================================================================
function [tsDifData, tsIncData] = generateDifIncTS (tsRawData)

    lengthTS = numel(tsRawData);
    tsDifData = zeros(lengthTS,1); tsIncData = zeros(lengthTS,1);
    tsDifData(1)= 0; tsIncData(1)= 0;
    for i = 2:lengthTS
        % Dif Time Series
        tsDifData( i ) = tsRawData( i ) - tsRawData( i - 1 );
        % Inc Time Series
        if (tsRawData( i ) > tsRawData( i - 1 ))
            tsIncData( i ) = +1;
        elseif (tsRawData( i ) < tsRawData( i - 1 ) )
            tsIncData( i ) = -1;
        else             
            tsIncData( i ) = 0;
        end;
    end;
end

% ================================================================================================

function hTSs = plotTSsSingle_RawDifInc_01(tsRawData, tsDifData, tsIncData, tsTestIndex, tsName, tsTypesCellArray, superTitle)

    hTSs = figure;  t = 1:numel(tsRawData);
    indexFirstElement = 1;
    
    % ----------------------------------------------------------------------------------------
    subplot(2,2,1); 
    plot( t( indexFirstElement:(tsTestIndex-1) ) , tsRawData( indexFirstElement:(tsTestIndex-1) ),'-b.', 'MarkerSize',7 ); 
    hold on; 
    plot( t (tsTestIndex:numel(tsRawData) ), tsRawData( tsTestIndex:numel(tsRawData) ),'-k.', 'MarkerSize',10); 
    % hold;
    title('raw data');
    % title( strcat(tsName,'-',tsTypesCellArray{1}) );
    grid; grid MINOR;
    hold off;
    
    % ----------------------------------------------------------------------------------------
    subplot(2,2,2);title('dif data'); 
    indexFirstElement = 2;
    plot(t(2:(tsTestIndex-1)),tsDifData(indexFirstElement:(tsTestIndex-1)),'-b.', 'MarkerSize',7); 
    hold on; 
    plot(t(tsTestIndex:numel(tsRawData)),tsDifData(tsTestIndex:numel(tsRawData)),'-k.', 'MarkerSize',10); 
    % hold; 
    title('dif data');
    % title( strcat(tsName,'-',tsTypesCellArray{2}) ); 
    grid; grid MINOR;
    hold off;
    
    % ----------------------------------------------------------------------------------------
    subplot(2,2,3);title('inc data'); 
    indexFirstElement = 2;
    plot(t(indexFirstElement:(tsTestIndex-1)),tsIncData(indexFirstElement:(tsTestIndex-1)),'b.', 'MarkerSize',7); 
    hold on; 
    plot(t(tsTestIndex:numel(tsRawData)),tsIncData(tsTestIndex:numel(tsRawData)),'k.', 'MarkerSize',10); 
    % hold; 
    title('inc data');
    %title( strcat(tsName,'-',tsTypesCellArray{3}) ); 
    grid; grid MINOR;
    hold off;
    
    % ---------------------------------------------------------------------------------------- 
    suptitle(superTitle);

end

% ================================================================================================
                
function hTSs = plotTS_TargetAndForecasted_onRawData_01( tsRawTargetData , ...
                                                         tsRawForecastData, tsDifForecastData, tsIncForecastData , ...
                                                         tsName, tsTypesCellArray, superTitle)

    hTSs = figure;  t = 1:numel(tsRawTargetData);
    iFirstElement = 1; iLastElement = numel(tsRawTargetData);
    
    
    % ----------------------------------------------------------------------------------------
    subplot(2,2,1); 
    plot( t( iFirstElement:iLastElement ) , tsRawTargetData(  iFirstElement:iLastElement ), '-k.', 'MarkerSize',10 ); 
    hold on; 
    plot( t( iFirstElement:iLastElement ) , tsRawForecastData( iFirstElement:iLastElement ), '-r.', 'MarkerSize',10); 
    % hold;
    title('raw forecasted data from raw ANN');
    % title( strcat(tsName,'-',tsTypesCellArray{1}) );
    grid; grid MINOR;
    hold off;
    
    % ----------------------------------------------------------------------------------------
    subplot(2,2,2);title('dif data'); 
    
    plot( t( iFirstElement:iLastElement ) , tsRawTargetData(   iFirstElement:iLastElement ), '-k.', 'MarkerSize',10 ); 
    hold on; 
    plot( t( iFirstElement:iLastElement ) , tsDifForecastData( iFirstElement:iLastElement ), '-r.', 'MarkerSize',10); 
    % hold;
    title('raw forecasted data from dif ANN');
    hold off;
    % title( strcat(tsName,'-',tsTypesCellArray{2}) ); 
    grid; grid MINOR;
    
    % ----------------------------------------------------------------------------------------
    subplot(2,2,3);title('inc data'); 
    
    plot( t( iFirstElement:iLastElement ) , tsRawTargetData(   iFirstElement:iLastElement ), '-k.', 'MarkerSize',10 ); 
    hold on; 
    plot( t( iFirstElement:iLastElement ) , tsIncForecastData( iFirstElement:iLastElement ), '-r.', 'MarkerSize',10); 
    % hold;
    title('raw forecasted data from inc ANN');
    %title( strcat(tsName,'-',tsTypesCellArray{3}) ); 
    grid; grid MINOR;
    hold off;
    
    % ---------------------------------------------------------------------------------------- 
    suptitle(superTitle);

end
% ================================================================================================

function hTSs = plotTS_TargetAndForecasted_onRawData_02( tsTest, ...
                                                         tsRawForecastData, tsDifForecastData, tsIncForecastData, ...
                                                         testOuputRawFromEnsemble, ...
                                                         tsName, tsTypesCellArray, superTitle)

    hTSs = figure;  t = 1:numel(tsTest);
    iFirstElement = 1; iLastElement = numel(tsTest);
    
    yAxesMax = max( max( [tsRawForecastData tsDifForecastData tsIncForecastData testOuputRawFromEnsemble] ) );
    yAxesMin = min( min( [tsRawForecastData tsDifForecastData tsIncForecastData testOuputRawFromEnsemble] ) );
    d = yAxesMax - yAxesMin; 
    yAxesMax = yAxesMax + (0.1 * d);
    yAxesMin = yAxesMin - (0.1 * d);
    
    xAxesMin = iFirstElement - 1;
    xAxesMax = iLastElement;
    % ----------------------------------------------------------------------------------------
    ax1 = subplot(2,2,1); 
    plot( t( iFirstElement:iLastElement ) , tsTest(  iFirstElement:iLastElement ), '-k.', 'MarkerSize',10 ); 
    hold on; 
    plot( t( iFirstElement:iLastElement ) , tsRawForecastData( iFirstElement:iLastElement ), '-r.', 'MarkerSize',10); 
    % hold;
    title('raw forecasted data from raw ANN');
    % title( strcat(tsName,'-',tsTypesCellArray{1}) );
    grid; grid MINOR;
    hold off;
    
    % ----------------------------------------------------------------------------------------
    ax2 = subplot(2,2,2);title('dif data'); 
    
    plot( t( iFirstElement:iLastElement ) , tsTest(   iFirstElement:iLastElement ), '-k.', 'MarkerSize',10 ); 
    hold on; 
    plot( t( iFirstElement:iLastElement ) , tsDifForecastData( iFirstElement:iLastElement ), '-r.', 'MarkerSize',10); 
    % hold;
    title('raw forecasted data from dif ANN');
    % title( strcat(tsName,'-',tsTypesCellArray{2}) ); 
    grid; grid MINOR;
    hold off;
    % ----------------------------------------------------------------------------------------
    ax3 = subplot(2,2,3);title('inc data'); 
    
    plot( t( iFirstElement:iLastElement ) , tsTest(   iFirstElement:iLastElement ), '-k.', 'MarkerSize',10 ); 
    hold on; 
    plot( t( iFirstElement:iLastElement ) , tsIncForecastData( iFirstElement:iLastElement ), '-r.', 'MarkerSize',10); 
    % hold;
    title('raw forecasted data from inc ANN');
    %title( strcat(tsName,'-',tsTypesCellArray{3}) ); 
    grid; grid MINOR;
    hold off;
    % ---------------------------------------------------------------------------------------- 
    ax4 = subplot(2,2,4);title('Ensemble data'); 
    
    plot( t( iFirstElement:iLastElement ) , tsTest(   iFirstElement:iLastElement ), '-k.', 'MarkerSize',10 ); 
    hold on; 
    plot( t( iFirstElement:iLastElement ) , testOuputRawFromEnsemble( iFirstElement:iLastElement ), '-r.', 'MarkerSize',10); 
    % hold;
    title('raw forecasted data from Ensemble');
    %title( strcat(tsName,'-',tsTypesCellArray{3}) ); 
    grid; grid MINOR;
    hold off;
    
    % ---------------------------------------------------------------------------------------- 
    axis([ax1 ax2 ax3 ax4],[xAxesMin xAxesMax yAxesMin*0.9 yAxesMax*1.05])    
    suptitle(superTitle);

end
    

% ================================================================================================
function dataBest = getDataFromFileBetterResults(fileBestResultsName)
  % This initial version is for just one single line
  % e.g. of the content
  % Results_Temperature_dif_010	23	 10	 35	 6	 0.01	 5000	 1.51241
  
  % Var initialization
  dataBest.tsName        = '-';
  dataBest.tsType        = '-';
  dataBest.initNumber    = 0;
  dataBest.FL_CombNumber = 0;
  dataBest.n_inputs      = 0;
  dataBest.n_hidden      = 0;
  dataBest.n_learningAlg = 0;
  dataBest.learningRate  = 0;
  dataBest.trCycle       = 0;
  dataBest.rmseVa        = 0;
  
  % -----------------------------------------------
 
  fid = fopen(fileBestResultsName);
  stringLine      = fgetl(fid);
  lengthSL = numel(stringLine); 
  
  index = 0;
  [dataBest.tsName       ,~, ~,nextIndex] = sscanf(stringLine,'%s',1);
  index = index + nextIndex;
  [dataBest.tsType       ,~, ~,nextIndex] = sscanf(stringLine(index:lengthSL),'%s',1);
  index = index + nextIndex;
  [dataBest.initNumber      ,~, ~,nextIndex] = sscanf(stringLine(index:lengthSL),'%d',1);
  index = index + nextIndex;
  [dataBest.FL_CombNumber  ,~, ~,nextIndex] = sscanf(stringLine(index:lengthSL),'%d',1);
  index = index + nextIndex;
  [dataBest.n_inputs       ,~, ~,nextIndex] = sscanf(stringLine(index:lengthSL),'%d',1);
  index = index + nextIndex;
  [dataBest.n_hidden       ,~, ~,nextIndex] = sscanf(stringLine(index:lengthSL),'%d',1);
  index = index + nextIndex;
  [dataBest.n_learningAlg  ,~, ~,nextIndex] = sscanf(stringLine(index:lengthSL),'%d',1);
  index = index + nextIndex;
  [dataBest.learningRate   ,~, ~,nextIndex] = sscanf(stringLine(index:lengthSL),'%f',1);
  index = index + nextIndex;
  [dataBest.trCycle        ,~, ~,nextIndex] = sscanf(stringLine(index:lengthSL),'%d',1);
  index = index + nextIndex;
  [dataBest.rmseVa         ,~, ~,~] = sscanf(stringLine(index:lengthSL),'%f',1);
 
  fclose(fid); 

end

% ================================================================================================
function net =   getModelFromDataResult(dataTheBest,fileDataResultsName)

    % Go to the folder of results
    dataOfResults = load(fileDataResultsName);
    net =  dataOfResults.resultsCellArray{dataTheBest.FL_CombNumber};
    net.trainRecord = '-';

end

% ================================================================================================


function   [validPatternsTargets, validPatterns, validTargets]= getValidPatternsTargets ( tsData, tsValidIndex , nValidTimes , nInputs , nOutputs)

    validPatternsTargets = zeros( nValidTimes , nInputs );
    
    for i = 1:nValidTimes
        index = tsValidIndex + i - 1;
        validPatternsTargets( i , nInputs + nOutputs ) = tsData( index ); 
        for j = 1:( nInputs + nOutputs - 1 )
            index = tsValidIndex + i - 1 - j ;
            validPatternsTargets( i , nInputs + nOutputs - j ) = tsData( index );
        end;
    end;
    
    % Preallocation is not recomended by MATLAB
    % testPatterns = zeros( nTestTimes , nInputs);
    % testTargets  = zeros( nTestTimes , nOutputs);
    
    validPatterns = validPatternsTargets( :, 1:nInputs );
    validTargets = validPatternsTargets( :, ( nInputs+1 ):( nInputs + nOutputs) );
 
end



% ================================================================================================
function   [testPatternsTargets, testPatterns, testTargets]= getTestPatternsTargets ( tsData, tsTestIndex , nTestTimes , nInputs , nOutputs)

    testPatternsTargets = zeros( nTestTimes , nInputs );
    
    for i = 1:nTestTimes
        index = tsTestIndex + i - 1;
        testPatternsTargets( i , nInputs + nOutputs ) = tsData( index ); 
        for j = 1:( nInputs + nOutputs - 1 )
            index = tsTestIndex + i - 1 - j ;
            testPatternsTargets( i , nInputs + nOutputs - j ) = tsData( index );
        end;
    end;
    
    % Preallocation is not recomended by MATLAB
    % testPatterns = zeros( nTestTimes , nInputs);
    % testTargets  = zeros( nTestTimes , nOutputs);
    
    testPatterns = testPatternsTargets( :, 1:nInputs );
    testTargets = testPatternsTargets( :, ( nInputs+1 ):( nInputs + nOutputs) );
 
end

% ================================================================================================
                                            
function [erANNRaw,erANNDif,erANNInc] = getForecastError( tsRawData ,tsOuputFromRaw, testOutputFromDif, testOutputFromInc)
    % ----
    targets = tsRawData;
    outputs = tsOuputFromRaw;
    [ mseANNRaw , rmseANNRaw , maeANNRaw , smapeANNRaw] = getTSErrors ( targets , outputs );
    erANNRaw = [ mseANNRaw , rmseANNRaw , maeANNRaw , smapeANNRaw] ;
    % ----
    targets = tsRawData;
    outputs = testOutputFromDif;
    [ mseANNDif , rmseANNDif , maeANNDif , smapeANNDif] = getTSErrors ( targets , outputs );
    erANNDif = [ mseANNDif , rmseANNDif , maeANNDif , smapeANNDif];
    % ----
    targets = tsRawData;
    outputs = testOutputFromInc;
    [ mseANNInc , rmseANNInc , maeANNInc , smapeANNInc] = getTSErrors ( targets , outputs );
    erANNInc = [ mseANNInc , rmseANNInc , maeANNInc , smapeANNInc];                                                               
    
    % ----
                                                                   
end

% ===================================================================================================
function [ mse , rmse , mae , smape] = getTSErrors ( targets , outputs )
    mse   = sum( ( outputs - targets ).^2 ) / size(targets, 1 );
    rmse  = sqrt( mse );
    mae   = sum( ( abs(outputs - targets) ) ) /  size( targets,1 ); 
    smape = sum(  200*( ( abs(outputs - targets ) ./ ( abs(outputs) + abs(targets) ) ) ) / size( targets , 1));

end

% ===================================================================================================
function error = showErrorsInFile01 (filename, partTS ,tsName,erANNRaw,erANNDif,erANNInc)
    error = 0;
    
    if ( strcmp('screen',filename) == 1)
        fid = 1;
    else
        fid = fopen(filename);
    end;
    fprintf(fid,'--- %20s %20s\n', tsName , partTS);
    fprintf(fid,'  ERRORS  %10s %10s %10s %10s\n','mse', 'rmse','mae','smape');
    fprintf(fid,'erANNRaw  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNRaw);
    fprintf(fid,'erANNDif  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNDif);
    fprintf(fid,'erANNInc  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNInc);
    % fprintf(fid,'-----\n');
    
    %fprintf(fid,'erANNRaw  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNRaw(1),erANNRaw(2),erANNRaw(3),erANNRaw(4));
    %fprintf(fid,'erANNDif  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNDif(1),erANNDif(2),erANNDif(3),erANNDif(4));
    %fprintf(fid,'erANNInc  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNInc(1),erANNInc(2),erANNInc(3),erANNInc(4));
    
end
% ==================================================================================================
function error = showErrorsInFile02 (filename, partTS ,tsName,erANNRaw,erANNDif,erANNInc,erANNEnsemble, s)
    error = 0;
    
    if ( strcmp('screen',filename) == 1)
        fid = 1;
    else
        fid = fopen(filename);
    end;
    fprintf(fid,'---- %20s %20s\n', tsName , partTS);
    fprintf(fid,'  ERRORS  %10s %10s %10s %10s\n','mse', 'rmse','mae','smape');
    fprintf(fid,'erANNRaw  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNRaw(1:4));
    fprintf(fid,'erANNDif  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNDif(1:4));
    fprintf(fid,'erANNInc  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNInc(1:4));
    fprintf(fid,'erEnsemb  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNEnsemble(1:4));
    fprintf(fid,'sumOfWeights: %+6.3f  %+6.3f  %+6.3f %+6.3f\n' ,s);
    %fprintf(fid,'-----\n');
    
    %fprintf(fid,'erANNRaw  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNRaw(1),erANNRaw(2),erANNRaw(3),erANNRaw(4));
    %fprintf(fid,'erANNDif  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNDif(1),erANNDif(2),erANNDif(3),erANNDif(4));
    %fprintf(fid,'erANNInc  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNInc(1),erANNInc(2),erANNInc(3),erANNInc(4));
    %fprintf(fid,'erANNInc  %+10.5f %+10.5f %+10.5f %+10.5f\n' ,erANNEnsemble(1),erANNEnsemble(2),erANNEnsemble(3),erANNEnsemble(4));
    
end

%% (LOCAL) FUNCTION FOR ENSEMBLE *******************************************************************
function [ testOuputRawFromEnsemble, errorEnsemble, s ] = ...
                                 COMPUTE_ENSEMBLE_01( ensembleOption01, weightsOption , ensembleOptionError, tsTest, ...
                                                     testOutputsRawFromRaw, testOutputsRawFromDif , testOutputsRawFromInc , ...
                                                     erANNRaw , erANNDif, erANNInc)
   indexError = 2;                    
   if weightsOption == 1
   
   
       erANNInc = [10^5 ,10^5 ,10^5, 10^5];
       sumOfErrors = erANNRaw + erANNDif ; 
       weightANNRaw = ( sumOfErrors - erANNRaw ) ./ sumOfErrors;
       weightANNDif = ( sumOfErrors - erANNDif ) ./ sumOfErrors;
       weightANNInc = [0 , 0 , 0, 0];
       
   elseif weightsOption == 2 
         
       sumOfErrors  = erANNRaw + erANNDif + erANNInc; 
       weightANNRaw = (1/2)*( sumOfErrors - erANNRaw ) ./ sumOfErrors;
       weightANNDif = (1/2)*( sumOfErrors - erANNInc ) ./ sumOfErrors;
       weightANNInc = (1/2)*( sumOfErrors - erANNDif ) ./ sumOfErrors;
   
   elseif weightsOption == 3 
       erANNDif = [10^5 ,10^5 ,10^5, 10^5];
       sumOfErrors = erANNRaw + erANNInc ; 
       weightANNRaw = ( sumOfErrors - erANNRaw ) ./ sumOfErrors;
       weightANNDif = [0 , 0 , 0, 0];
       weightANNInc = ( sumOfErrors - erANNInc ) ./ sumOfErrors;
       
   end;
   s = weightANNRaw + weightANNDif + weightANNInc;
   
   if (strcmp(ensembleOptionError,'rmse') == 1)
       indexError = 2;
   end;
   
   if (ensembleOption01 == 1)
       
       outputEn = ( weightANNRaw(indexError) * testOutputsRawFromRaw ) + ...
                  ( weightANNDif(indexError) * testOutputsRawFromDif ) + ... 
                  ( weightANNInc(indexError) * testOutputsRawFromInc );
       
   end;
        
   [errorEnMSE,errorEnRMSE, errorEnMAE, errorEnSMAPE ] = getTSErrors (tsTest,outputEn);
   
   errorEnsemble = [errorEnMSE,errorEnRMSE, errorEnMAE, errorEnSMAPE ];
   testOuputRawFromEnsemble = outputEn;
   
end



%% LOCAL FUNCTIONS    =======================================================================

function outparam = roundIncElementEnsemble( inputparam )

    threshold_1 =  0.1;
    threshold_2 = -0.1;
    
    if ( inputparam >= threshold_1 )
        outparam = 1;
    elseif (inputparam <= threshold_2)
        outparam = -1;
    else 
        outparam = 0;
    end




end

