function [ output_args ] = func_03_ann4tsf_experiments_v05(  geneneralFileRes,...
                                                             tsName, ...
                                                             tsType ,...
                                                             factorsLevelsFilename, ...
                                                             initId,...
                                                             debugLevel, ...
                                                             parameters)
    %    AIM OF THE FUNCTION (i.e. functionality)
    %    execute the experiments (Factor-Level Combinations) for 
    %              a given time series (tsName), 
    %              a given type of TS (raw, dif, inc)
    %       
    %    INPUTS : 
    %       genFileRes
    %       tsName
    %       tsType
    %       the file which contains the sequence of factor and level combinations,
    %       the experiment ID, and the debug level, and parameters
    % 
    % For instance:  
    %    tsName ->  'Mackeyglass01', 'Temperature','tsDowjones','Quebec'
    %    tsType ->  'Raw','Dif','Inc'
    %    factorsLevelsFilename ->  full filename (path & filename)
    %    expId  ->  weight initialization index 
    %    debugLevel -> 0,1,2,3 

    strInitId = sprintf('%03i',initId);

    %% FOLDER % FILE(S) where to save the RESULTS   ----------------------------

    % folder_Results  =  strcat('Results_',tsName,'_',tsType);               
    % folder_Results  =  strcat('Results_',tsName,'_',tsType,'_',strInitId);
    % folder_Results  =  strcat('01_Results/Results_',tsName,'_',tsType,'_',strInitId);
    %folder_Results  =  strcat( parameters.folderAllResults, '\',...
    %                           parameters.resultsFolderPrefix, ...
    %                           tsName,'_',tsType,'_',strInitId);
                           
    folder_Results   = fullfile( parameters.folderAllResults, ...
                                 strcat( parameters.resultsFolderPrefix, tsName , '_',tsType,'_init_',strInitId ) );
    
    mkdir( folder_Results );
    delete( fullfile( folder_Results,'*') );


    % resultsFilename             = strcat( folder_Results,'/','results_',tsName,'_',tsType,'_',strInitId,'.dat');
    % resultsInCellArrayFilename  = strcat( folder_Results,'/','results_',tsName,'_',tsType,'_',strInitId,'.mat');
    % logFilename                 = strcat( folder_Results,'/','aa_execlogFile_',tsName,'_',tsType,'_',strInitId,'.txt');
    % resultsFilename             = strcat( folder_Results,'/',parameters.resultsFilesPrefix, ...
    %                                       tsName,'_',tsType,'_',strInitId,'.dat');
    % resultsInCellArrayFilename  = strcat( folder_Results,'/',parameters.resultsFilesPrefix,...
    %                                       tsName,'_',tsType,'_',strInitId,'.mat');
    
    resultsFilename             = strcat( parameters.resultsFilesPrefix , tsName , '_' , tsType, ...
                                          '_init_',strInitId,'.',parameters.fileExtensionResults);                                                                    
                                      
    resultsFilename             = fullfile(folder_Results, resultsFilename );                                      

    %resultsInCellArrayFilename  = strcat( parameters.resultsFilesPrefix , tsName , '_' , tsType , ...
    %                                      '_',strInitId,'.',parameters.fileExtensionResultsBinary );

    %resultsInCellArrayFilename  = fullfile( folder_Results , resultsInCellArrayFilename );

    logFilename                 = strcat( folder_Results,'/',parameters.logFilePrefix,tsName,'_',tsType,'_init_',strInitId,'.txt');




    %% TIME SERIES FOLDER & FILENAMES   -----------------------------------------

    % tsFolder   =  'Timeseries';
    tsFolder              = parameters.tsFolder;
    % tsFilename = strcat('ts_' , tsName , '-' , tsType , '.dat' );
    % tsFilename = strcat('ts-' , tsName , '-' , tsType , '.csv' );
    tsFilename = strcat( parameters.tsFilesPrefix,tsName,'-',tsType,'.',parameters.tsFilesExtension);


    %{
     rawPrefix = 'Raw';
     difPrefix = 'Dif';  
     incPrefix = 'Inc';
    %}

    %% ANN PARAMETERS -> DEFAULT (FIXED) VALUES ************************************
    % These are the defualt values for the parameters that will have an effect
    % on the ANN performances (i.e. its accuracy)
    % e.g.  trainPrctg, validPrctg, testPrctg

    % annParameters = annParamInitialization();


    % OTHER PARAMETERS  ***********************************************************
    % annParameters.tsFolder       = tsFolder;
    % annParameters.tsFilename     = tsFilename;  % already include the TSName & TSType
    % annParameters.tsName         = tsName;      % %annParameters.tsName         = tsFilename(1:(numel(tsFilename)-4));
    % annParameters.tsType         = tsType;
    % annParameters.initId         = initId;
    % annParameters.folder_Results = folder_Results;


    % ===================================================================================
    % Read (or generate) an array (matrix) 
    % with the values for the set of factor level combination

    % DATA for ann parameters which will change the ann parameters
    switch debugLevel
        % ----------------------------------
        % case 3
        %     % listNumInputs = [ 10 ];        % listNumInputs = minInputs:maxOutputs;
        %     % listHiddenLayersSize = [ 10 ]; % listHiddenLayersSize = ...;
        %     listNumInputsHiddeLayerSize = { 10, [ 10] };
        % 
        %     %listLearnAlg = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
        %     %listLearnAlg  = {'trainlm', 'traingd'};
        % 
        %     listLearnAlg  = [ 1 , 2 ];
        % 
        %     listLR        = [ 0.05 ];
        %     listTrCyc     = [ 1000 ];
        % ----------------------------------
        % case 2
        %     % listNumInputs = [ 10 , 15 ];                        % listNumInputs = minInputs:maxOutputs;
        %     % listHiddenLayersSize = [ 5 , 10 , 15, 20 ]; % listHiddenLayersSize = ...;
        %     listNumInputsHiddeLayerSize = { 10, [5 10 20] ; ...
        %                                     15, [5 10 2]  };
        % 
        %     %listLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
        %     %listLearnAlg  = {'trainlm', 'traingda', 'traingdx'};
        %     listLearnAlg  = [1,3,4];
        % 
        %     listLR        = [0.2 , 0.01 ];
        %     listTrCyc     = [ 1000 , 2000 ];    
        % ----------------------------------
        % case 1
        %     %listNumInputs = [ 5 , 10 , 15, 20 ];                        % listNumInputs = minInputs:maxOutputs;
        %     %listHiddenLayersSize = [ 5 , 10 , 15, 20, 25, 30, 35, 40 ]; % listHiddenLayersSize = ...;
        %     listNumInputsHiddeLayerSize = { 5 , [2 5 10]               ; ...
        %                                     10, [5 10 15 20]           ; ...
        %                                     15, [5 10 15 20 25 30]     ; ...
        %                                     20, [10 15 20 25 30 35 40] };
        %     %listLearnAlg  = {'trainlm', 'traingd', 'traingda', 'traingdx', 'trainrp', 'trainscg', 'traingdm'};
        % 
        %     listLearnAlg  = [1,2,3,4,5,6,7];
        %     %{
        %         (#1) trainlm  ->  1
        %         (#2) traingd  ->  2
        %         (#3) traingda ->  3
        %         (#4) traingdx ->  4
        %         (#5) trainrp  ->  5
        %         (#6) trainscg ->  6
        %         (#7) traingdm ->  7
        %     %}
        %     listLR        = [ 0.2 , 0.1 , 0.05 , 0.01 ];
        %     listTrCyc     = [ 500 , 1000 , 2000 , 5000];   

        case {3,2,1,0} % debugging is set with FL combinations file 

            % Read the parameters from the file
            % factorsLevelsFolder = 'TablesFactorsAndLevels';
            % factorsLevelsFilename = 'domAny_setParameters01_FF.dat'; 
            % factorsLevelsFullFilename = strcat(factorsLevelsFolder,'/',factorsLevelsFilename);
            factorsLevelsFullFilename = factorsLevelsFilename;
            arrayFactorLevelParam     = readFactorLevelParam_01(factorsLevelsFullFilename);

    end


    %% LOOP to simulate the sequence of ANN learning process  ***********************************
    % given the sequence of factor&levels combinations
    nSim = size(arrayFactorLevelParam,1);
    resultsCellArray = cell(nSim,1);
    trainRecords     = cell(nSim,1);

    % ------------------------------------
    fidGeneralRes   = fopen( geneneralFileRes      , 'a' );
    fidLocalRes = fopen( resultsFilename , 'w' );
    fidLog      = fopen( logFilename     , 'w' ); 
    % fidLog = 1; % -> screen
    % ------------------------------------

    showHeader02( fidGeneralRes , 'res'); 
    showHeader01( fidLog        , 'log' , nSim); 
    showHeader01( fidLocalRes   , 'res' , nSim);
    
    % ------------------------------------
    initTime = tic; 
    %% ******************************************************************************************
    
    
    
    
    % Pre-allocation for Parameters 
    for iExperiment = 1:nSim 
        annParameters{iExperiment} = annParamInitialization();
        % -----------------------------------------
        annParameters{iExperiment}.tsFolder       = tsFolder;
        annParameters{iExperiment}.tsFilename     = tsFilename;  % already include the TSName & TSType
        %annParameters{iCombinationFactorLevels}.tsName         = tsFilename(1:(numel(tsFilename)-4));
        annParameters{iExperiment}.tsName         = tsName;
        annParameters{iExperiment}.tsType         = tsType;
        annParameters{iExperiment}.initId         = initId;
        annParameters{iExperiment}.folder_Results = folder_Results;

        %------------------------------------------
        annParameters{iExperiment}.iExperiment = iExperiment;
        %------------------------------------------
        
        annParameters{iExperiment}.iCombFactLevel   = arrayFactorLevelParam( iExperiment , 1 );
        annParameters{iExperiment}.nInputs          = arrayFactorLevelParam( iExperiment , 2 );
        annParameters{iExperiment}.hiddenLayersSize = arrayFactorLevelParam( iExperiment , 3 );

        annParameters{iExperiment}.trainFcn         = arrayFactorLevelParam( iExperiment , 4 );
        annParameters{iExperiment}.trainFcnStr      = learningAlgorithmNum2Str( annParameters{iExperiment}.trainFcn );

        annParameters{iExperiment}.learningRate     = arrayFactorLevelParam( iExperiment , 5 );

        annParameters{iExperiment}.trCycles         = arrayFactorLevelParam( iExperiment , 6 );
        % annParameters.trCycles         = annParameters.trCycles * 10^2;      % <- Got from the file of parameters (Full factorial or L16x32)
        % annParameters.trCycles         = annParameters.trCycles;           % <- fix to a value set in a previous source code file 
        %------------------------------------------
                
        % Seed  ------------------------
        % v = (int32(clock)); seed = v(5) + v(6);  clear v;
        % seed = fix(cputime*1000);
        % rng(seed);  % fprintf('Seed: %03d\n',seed); % seed is the second for time 
        % annParameters{iCombinationFactorLevels}.rngSeed  = seed;  clear seed;
        
        annParameters{iExperiment}.rngSeed  = fix( cputime * 1000 );
        rng(annParameters{iExperiment}.rngSeed);
               
        % ---------------------------------------------------------
        scrsz{iExperiment} = get( groot ,'ScreenSize'); % [left bottom width height].
        
    end
    %% FOR PARALELIZATION    ========================================================
    %  for iExperiment_B = 1:nSim
    parfor iExperiment_B = 1:nSim
        
        % ============================================================================
        % TRAIN THE ANN and get the result of the train, validation and test
        % ============================================================================
        tStart = tic;      
        
        % This function ann4tsForecast_v02 should not write into a file (because par pool)
        resultsCellArray{iExperiment_B} = ann4tsForecast_v02( annParameters{iExperiment_B} );

        tElapsed    = toc(tStart);
        resultsCellArray{iExperiment_B}.time = tElapsed;
        
        % -------------------------------------------------------------------------------
        % Print on the screen some results on 
        fprintf('\n%4d %4d %4d %4d %6.2f %6d -> %12.5f (rmseValH2Error) %12.5f (smapeValH2Error)\n',...
                annParameters{iExperiment_B}.iCombFactLevel    ,...
                annParameters{iExperiment_B}.nInputs           ,...
                annParameters{iExperiment_B}.hiddenLayersSize  ,...
                annParameters{iExperiment_B}.trainFcn          ,...  
                annParameters{iExperiment_B}.learningRate      ,...
                annParameters{iExperiment_B}.trCycles          ,...
                resultsCellArray{iExperiment_B}.rmseValH2 ,...
                resultsCellArray{iExperiment_B}.smapeValH2);  
        
        fprintf('\n ------------------------------------------------------ \n')    
        
    end
    
    fprintf('\n\n*** All FL combinations for ANNs have been trained. ****\n\n');
    
    
    %% ========================================================================
    fprintf(fidLog,'finished.\n');    
    for iExperiment = 1:nSim 
        
        showParam01Values( fidGeneralRes   , 'res' , annParameters{iExperiment} );
        showParam01Values( fidLog          , 'log' , annParameters{iExperiment} );
        showParam01Values( fidLocalRes     , 'res' , annParameters{iExperiment} );
        
        
        
        showResults01Values(fidGeneralRes , 'res',resultsCellArray{iExperiment} );
        showResults01Values(fidLog        , 'log',resultsCellArray{iExperiment} );
        showResults01Values(fidLocalRes   , 'res',resultsCellArray{iExperiment} );
                
    end
    
    %resultsInCellArrayFilename = fullfile(folder_Results,strcat(parameters.resultsFilesPrefix, ...
    %                                      tsName,'_',tsType,'_',strInitId,'.mat') );              
    resultsInCellArrayFilename = fullfile( parameters.folderAllResults, strcat( parameters.resultsFilesPrefix, ...
                                           tsName , '_', tsType , '_' , strInitId , ...
                                           '.',parameters.fileExtensionResultsBinary ) );

    save(resultsInCellArrayFilename,'resultsCellArray');
    %save(resultsInCellArrayFilename,'resultsCellArray','-append');
    %save(resultsInCellArrayFilename,'resultsCellArray{iCombinationFactorLevels}');
    % If a variable already exists in a MAT-file, then save overwrites it
    
    fprintf('\n\n*** All FL combinations for ANNs have been save in csv file and mat files. ****\n\n');

    %% =======================================================================
    
    fprintf('\n\n*** All FL combinations for ANNs are going to be show in figures. ****\n\n');
    
    parfor iExperiment = 1:nSim 
    %  for iExperiment = 1:nSim 
    
        fprintf('STEP 00\n');
        
        singleANNParameters  = annParameters{iExperiment};
        trainRecord = resultsCellArray{iExperiment}.trainRecord;
        result      = resultsCellArray{iExperiment};
        net01       = resultsCellArray{iExperiment}.net;
        %scrSize     = scrsz{iCombinationFactorLevels};
        
        fprintf('STEP 01\n');
        % Show the learning process error -----------------------------------------
        if (singleANNParameters.showTrainRecord)
            
            fprintf('\tSTEP 01.1 %d \n', result.strNumExp);
            
            h1 = figure;
            plotperform( trainRecord );
            %title( strcat('ann learning process perfomance',result.tsName,'_',result.tsType,'_',result.strNumExp ) );

            annTrainPerformanceFilename = fullfile (singleANNParameters.folder_Results, ...
                                                  strcat(result.tsName,'_',result.tsType, ...
                                                  '_init_',strInitId, ...
                                                  '_iFL_', result.strNumExp, ... 
                                                  '_trainPerformance_v1', '.fig') );
            savefig(annTrainPerformanceFilename);
            
            
            
            fprintf('\tSTEP 01.2\n');
            fprintf(' net01.trainParam.epochs: %d\n numel(trainRecord.perf): %d\n numel(trainRecord.vperf): %d\n numel(trainRecord.tperf): %d\n', ...
                      net01.trainParam.epochs , numel(trainRecord.perf) , numel(trainRecord.vperf) , numel(trainRecord.tperf) );

            h2 = figure;
            plot( 1:( numel(trainRecord.perf) ),trainRecord.perf);  hold on;
            plot( 1:( numel(trainRecord.perf) ),trainRecord.vperf); hold on;
            plot( 1:( numel(trainRecord.perf) ),trainRecord.tperf); 
            title( strcat('ann learning process perfomance v2',result.tsName,'-',result.tsType,'-',result.strNumExp ) );

            annTrainPerformanceFilename = fullfile (singleANNParameters.folder_Results, ...
                                                    strcat(result.tsName,'_',result.tsType,...
                                                    '_init_',strInitId, ...
                                                    '_iFL_', result.strNumExp, ... 
                                                    '_trainPerformance_v2', '.fig') );
            savefig(annTrainPerformanceFilename);
            
            close(h1);
            close(h2);
            
%             h = figure;
%             t = result.testTargets;
%             x = zeros(10,5);
%             y = net01(x);
%             plotregression(t,y,'Regression');            
%             annTrainPerformanceFilename = fullfile (singleANNParameters.folder_Results, ...
%                                                     strcat(result.tsName,'_',result.tsType,'_',num2str(singleANNParameters.iExperiment,'%4d'),'_',...
%                                                     'regression', '.fig') );


        end 
        % ------------------------------------------------------------------------
        % ------------------------------------------------------------------------
        % Are test_tsData & testOutputs the same vector with the same values ??
        if (singleANNParameters.showOnScreen)
            fprintf('test_tsData                   -> size(...): %d %d \n',...
                     size( result.test_tsData ,1 ) ,  size(result.test_tsData  ,2 ) );
            fprintf('forecastResults.testH2Outputs -> size(...): %d %d \n',...
                     size( result.testH2Outputs , 1 ), size( result.testH2Outputs , 2 ) );
            fprintf('test_tsData & testOutputs are same size?? \n');
        end
        result.test_tsData; 
        fprintf('STEP 03\n');
        % ------------------------------------------------------------------------
        % Show Errors 
        if (singleANNParameters.showOnScreen)
            fprintf('InitId %i - iFL%i - iExp%i \n',strInitId, singleANNParameters.iCombFactLevel, singleANNParameters.iExperiment);
            
            fprintf('Error   %3s %12s  %12s  %12s\n'       ,'Hx','TRAIN','VAL','TEST');
            fprintf('rmse    %3s %12.5f  %12.5f  %12.5f\n'     , ...
                    'H1',    result.rmseTrain  , result.rmseValH1  , result.rmseTestH1);
            fprintf('smape   %3s %12.2f  %12.2f  %12.2f\n'     , ...
                    'H1',    result.smapeTrain , result.smapeValH1 , result.smapeTestH1);
            fprintf('rmse    %3s %12.5f  %12.5f  %12.5f\n'     , ... 
                     'H2',   result.rmseTrain  , result.rmseValH2  , result.rmseTestH2);
            fprintf('smape   %3s %12.2f  %12.2f  %12.2f\n'     , ...
                     'H2',   result.smapeTrain , result.smapeValH2 , result.smapeTestH2);

        end
        fprintf('STEP 04\n');
        
        % Show Target & Outputs ------------------------------------------------
        if ( singleANNParameters.showTrainValTestTargetOutput )
            fprintf('-Step 04.1-');
      
            scrsz = get( groot ,'ScreenSize'); % [left bottom width height].
            hTrVaTe_TargetOutput = figure('Position', ...
                                           [ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5]); 
            fprintf('-Step 04.2-');

            a = size(result.trainTargets,2);
            b = size(result.trainTargets,2) + size(result.valTargets,2);
            c = size(result.trainTargets,2) + size(result.valTargets,2) + size(result.testTargets,2);
            t = 1:c;
            tVal  = (a+1):b; 
            tTest = (b+1):c;
            fprintf('-Step 04.3-');

            % As [train/val/test]Targets [train/val/test]Outputs are row vector

            plot( t     ,[ result.trainTargets , result.valTargets , result.testTargets] , 'ko--', 'MarkerSize' , 3); hold on
            plot( tVal  , result.valH1Outputs               , 'bo:', 'MarkerSize' , 5); 
            plot( tVal  , result.valH2Outputs               , 'ro:', 'MarkerSize' , 5); 
            plot( tTest , result.testH1Outputs              , 'bx:', 'MarkerSize' , 5); 
            plot( tTest , result.testH2Outputs              , 'rx:', 'MarkerSize' , 5); 
            fprintf('-Step 04.4-');
            grid on; grid minor
            legend('targets','valOutputH1','valOutputH2','testOutputsH1', 'testOutputsH2');
            title(strcat('(Train + Val + Test)','--', singleANNParameters.tsFilename,'-init-',strInitId  ));
            
            fprintf('-Step 04.5-');
            %clear t a b c tVal tTest ;
            %saveas(gcf,'Barchart.png')
            fprintf('-Step 04.6-' );

            
            TrVaTeTargetOutputFigFilename = fullfile (singleANNParameters.folder_Results, ...
                                                      strcat(result.tsName,'_',result.tsType,...
                                                      '_init_',strInitId, ...
                                                      '_iFL_',result.strNumExp,'_',...
                                                      'TrVaTe+TarOutH1H2', '.fig'));
            
            savefig(TrVaTeTargetOutputFigFilename);
            
            % TrVaTeTargetOutputFigFilename = fullfile (singleANNParameters.folder_Results, ...
            %                                           strcat(result.tsName,'_',result.tsType,'_',result.strNumExp,'_',...
            %                                           'TrVaTe+TarOutH1H2-', result.strNumExp , '.pdf') );
            % 
            % print( hTrVaTe_TargetOutput , TrVaTeTargetOutputFigFilename , '-dpdf','-fillpage','-r0')
            
            %clear filename;
            close(hTrVaTe_TargetOutput);
            fprintf('-Step 04.7-');
        end
        fprintf('\nSTEP 05\n');
        if ( singleANNParameters.showValTargetOutput )
            scrsz = get(groot,'ScreenSize'); % [left bottom width height].
            hValTargetOutput = figure('Position',[ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5]);
            
            a = size(result.trainTargets,2);
            b = size(result.trainTargets,2) + size(result.valTargets,2);
            c = size(result.trainTargets,2) + size(result.valTargets,2) + size(result.testTargets,2);
            
            tValTest = ( a + 1 ):c;
            tVal     = ( a + 1 ):b; 
            tTest    = ( b + 1 ):c;
            
            % As [train/val/test]Targets [train/val/test]Outputs are row vector
            
            plot( tValTest ,[ result.valTargets , result.testTargets] , 'ko--', 'MarkerSize' , 3); hold on
            plot( tVal  , result.valH1Outputs   , 'bo:', 'MarkerSize' , 5); 
            plot( tVal  , result.valH2Outputs   , 'ro:', 'MarkerSize' , 5); 
            plot( tTest , result.testH1Outputs  , 'bx:', 'MarkerSize' , 5); 
            plot( tTest , result.testH2Outputs  , 'rx:', 'MarkerSize' , 5); 
            grid on; grid minor
            legend('targets','valOutputH1','valOutputH2','testOutputsH1', 'testOutputsH2');
            
            title(strcat('Val + Test)','--', singleANNParameters.tsFilename));
            %clear a b c tValTest tVal tTest ; % NOT AT a PARFOR            
      
            vaTeTargetOutputFigFilename = fullfile( singleANNParameters.folder_Results , ...
                                                    strcat( result.tsName,'_',result.tsType,...
                                                    '_init_',strInitId, ...    
                                                    '_iFL_',result.strNumExp,'_',...
                                                    'VaTe+TarOutH1H2','.fig' ) ); 
            savefig(vaTeTargetOutputFigFilename);

            
            % vaTeTargetOutputFigFilename = fullfile( singleANNParameters.folder_Results , ...
            %                                         strcat( result.tsName,'_',result.tsType,'_',result.strNumExp,'_',...
            %                                         'VaTe+TarOutH1H2-' , result.strNumExp , '.pdf' ) ); 
            % 
            % print( hValTargetOutput , vaTeTargetOutputFigFilename , '-dpdf','-fillpage','-r0')
                        
            close(hValTargetOutput);
      
        end
        fprintf('STEP 06\n');
        if ( singleANNParameters.showTestTargetOutput )
            scrsz = get(groot,'ScreenSize'); % [left bottom width height].
            hTestTargetOutput = figure('Position',[ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5] );
            
            a = size(result.trainTargets,2) + size(result.valTargets,2); 
            b = size(result.trainTargets,2) + size(result.valTargets,2) + size(result.testTargets,2);
            tTest = (a+1):b;
            % As [train/val/test]Targets [train/val/test]Outputs are row vector
            
            plot( tTest , result.testTargets                   , 'ko--', 'MarkerSize' , 3); hold on
            plot( tTest , result.testH1Outputs , 'bx:', 'MarkerSize' , 5); 
            plot( tTest , result.testH2Outputs , 'rx:', 'MarkerSize' , 5); 
      
            grid on; grid minor
            legend( 'targets' , 'testOutputsH1' , 'testOutputsH2');
            title( strcat('Test','--', singleANNParameters.tsFilename));
            %clear a b tTest ;
      
            %saveas(gcf,'Barchart.png');
            TrVaTeTargetOutputFigFilename = fullfile( singleANNParameters.folder_Results, ...
                                                      strcat(result.tsName,'_',result.tsType, ...
                                                      '_init_',strInitId, ...    
                                                      '_iFL_',result.strNumExp,'_', ...
                                                      'Te+TarOutH1H2','.fig') );
            savefig(TrVaTeTargetOutputFigFilename);
            
            % TrVaTeTargetOutputFigFilename = fullfile( singleANNParameters.folder_Results, ...
            %                                           strcat( result.tsName,'_',result.tsType,'_',result.strNumExp,'_', ...
            %                                           'Te+TarOutH1H2','.pdf') ) ;
            % print( hTestTargetOutput , TrVaTeTargetOutputFigFilename , '-dpdf','-fillpage','-r0')
           
            close(hTestTargetOutput);
    
        end
        fprintf('STEP 07\n');
    end
    
    fprintf('\n\n--- All FL combinations for ANNs have been shown in figures. ----\n\n');
    %% ===================================================================================
    totalTime = toc(initTime);   % avgTime   = totalTime/ iCombinationFactorLevels;
    fprintf(fidLog,'\n\ntotalTime %6.1f seconds %6.1f hours\n',totalTime,totalTime/3600); 
    fprintf(fidLog,'\n\n ======== EXP %s %s %2d ========\n\n',tsName,tsType,initId);    

    % **************************************************************************************

    if (fidLog > 2 )
        fclose(fidLog);
    end
    fclose(fidGeneralRes);
    fclose(fidLocalRes);

    output_args = resultsCellArray;

    % quit;

 end
    % END OF THE MAIN FUNCTION   aa_ann4tsf_experiments_v0x



    %%  FUNCTIONS TO SHOW PARAM & RESULTS  ************************************************************
function showHeader01(fid,fileType,nSim)

    fprintf(fid, '%% nSim -> %5i\n',nSim);
    fprintf(fid, '%25s','tsName');
    fprintf(fid, '%10s' ,'Type');
    fprintf(fid, '%10s','In');
    fprintf(fid, '%10s','seed');
    fprintf(fid, '%10s','nFLC');
    fprintf(fid, '%10s','nIn');
    fprintf(fid, '%10s','hLS');
    fprintf(fid, '%10s','trFn');
    fprintf(fid, '%10s','lr');
    fprintf(fid, '%10s','trC');
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    fprintf(fid, '%10s','rmseTr');
    fprintf(fid, '%10s','smapeTr');
    
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % VAL & TEST H1
    fprintf(fid, '%10s','rmseVaH1');
    fprintf(fid, '%10s','smapeVaH1');
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    fprintf(fid, '%10s','rmseTeH1');
    fprintf(fid, '%10s','smapeTeH1');
          
    if (strcmp(fileType,'log') == 1)
       fprintf(fid,'\n');  
    end
    
    % VAL & TEST H2
    fprintf(fid, '%10s','rmseVaH2');
    fprintf(fid, '%10s','smapeVaH2');
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    fprintf(fid, '%10s','rmseTeH2');
    fprintf(fid, '%10s','smapeTeH2');
          
    if (strcmp(fileType,'log') == 1)
       fprintf(fid,'\n');  
    end
    
    
    fprintf(fid,'%9s','time');
    
    fprintf(fid,'\n'); 
end

% --------------------------------------------
function showHeader02(fid,fileType)
    % example for the call: showHeader02(fidGenRes,'res');

    fprintf(fid, '%25s','tsName');
    fprintf(fid, '%10s' ,'Type');
    fprintf(fid, '%10s','In');
    fprintf(fid, '%10s','seed');
    fprintf(fid, '%10s','nFLC');

    fprintf(fid, '%10s','nIn');
    fprintf(fid, '%10s','hLS');
    fprintf(fid, '%10s','trFn');
    fprintf(fid, '%10s','lr');
    fprintf(fid, '%10s','trC');

    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end

    % TRAIN 
    fprintf(fid, '%10s','rmseTr');
    fprintf(fid, '%10s','smapTr');
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % VAL H1 
    fprintf(fid, '%10s','rmseVaH1');
    fprintf(fid, '%10s','smapVaH1');
    
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % TEST H1
    fprintf(fid, '%10s','rmseTeH1');
    fprintf(fid, '%10s','smapTeH1');
        
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % VAL H2
    fprintf(fid, '%10s','rmseVaH2');
    fprintf(fid, '%10s','smapVaH2');
    
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % TEST H2
    fprintf(fid, '%10s','rmseTeH2');
    fprintf(fid, '%10s','smapTeH2');
    
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    
    fprintf(fid,'%10s','time');

    fprintf(fid,'\n'); 

end

% ------------------------------------------------------------------
function showParam01Values(fid,fileType,parameters)

    % the file is already open to write by the one which call this function
    fprintf(fid,'%25s',parameters.tsName);
    fprintf(fid,'%10s',parameters.tsType);
    fprintf(fid,'%10i',parameters.initId);
    fprintf(fid,'%10i',parameters.rngSeed);
    fprintf(fid,'%10i',parameters.iCombFactLevel);
    fprintf(fid,'%10i%10i%10i%10.2f%10i',...
                    parameters.nInputs,...
                    parameters.hiddenLayersSize,...
                    parameters.trainFcn,...
                    parameters.learningRate,...
                    parameters.trCycles);

    if (strcmp(fileType,'log') == 1)
      fprintf(fid,'\n Learning ...\n\n');  
    elseif (strcmp(fileType,'res') == 1)  
      fprintf(fid,'');  
    end             

end

    % --------------------------------------------
function showResults01Values(fid,fileType, result)

    %   fprintf(fid,'%12.5f%10.5f%12.5f%7.2f', ...
    %                  result.mseTrain,...
    %                  result.rmseTrain,...
    %                  result.maeTrain,...
    %                  result.smapeTrain);

    fprintf(fid,'%10.5f%10.2f', ...
                 result.rmseTrain,...
                 result.smapeTrain);

    if ( strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    elseif (strcmp(fileType,'res') == 1)  
        fprintf(fid,'');
    else
        % do nothing 
    end   

    %   fprintf(fid,'%12.5f%12.5f%12.5f%12.2f', ...
    %                  result.mseValError,...
    %                  result.rmseValError,...
    %                  result.maeValError,...
    %                  result.smapeValError);

    fprintf(fid,'%10.5f%10.2f', ...
                 result.rmseValH1,...
                 result.smapeValH1);
    fprintf(fid,'%10.5f%10.2f', ...
                 result.rmseTestH1,...
                 result.smapeTestH1);
                     
             
    if ( strcmp(fileType,'log') == 1 )
        fprintf(fid,'\n');  
    elseif (strcmp(fileType,'res') == 1)  
        fprintf(fid,'');  
    else
        % do nothing 
    end   

    %   fprintf(fid,'%12.5f%12.5f%12.5f%12.2f', ...
    %                  result.mseTestError,...
    %                  result.rmseTestError,...
    %                  result.maeTestError,...
    %                  result.smapeTestError);
    %     
    
    fprintf(fid,'%10.5f%10.2f', ...
                 result.rmseValH2,...
                 result.smapeValH2);
             
    fprintf(fid,'%10.5f%10.2f', ...
                 result.rmseTestH2,...
                 result.smapeTestH2);
             
             
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    elseif (strcmp(fileType,'res') == 1)  
        fprintf(fid,'');  
    end
    fprintf(fid,'%10.2f', result.trainTimeElapsed);
    fprintf(fid,'\n'); 

end

% --------------------------------------------


