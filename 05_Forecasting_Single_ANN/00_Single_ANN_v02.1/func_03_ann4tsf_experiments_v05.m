function [ output_args ] = func_03_ann4tsf_experiments_v05(  geneneralFileRes,...
                                                             tsName, ...
                                                             tsType ,...
                                                             factorsLevelsFullFilename, ...
                                                             initId,...
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
    % folder_Results  =  strcat( parameters.folderAllResults, '\',...
    %                            parameters.resultsFolderPrefix, ...
    %                            tsName,'_',tsType,'_',strInitId);
                           
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
    
    arrayFactorLevelParam     = readFactorLevelParam_01(factorsLevelsFullFilename);

    
    %% LOOP to simulate the sequence of ANN learning process  ***********************************
    % given the sequence of factor&levels combinations
    nFLComb = size(arrayFactorLevelParam,1);
    resultsCellArray = cell(nFLComb,1);
    trainRecords     = cell(nFLComb,1);

    % ------------------------------------
    fidGeneralRes   = fopen( geneneralFileRes      , 'a' );
    fidLocalRes = fopen( resultsFilename , 'w' );
    fidLog      = fopen( logFilename     , 'w' ); 
    % fidLog = 1; % -> screen
    % ------------------------------------

    showHeader02( fidGeneralRes , 'res'); 
    showHeader01( fidLog        , 'log' , nFLComb); 
    showHeader01( fidLocalRes   , 'res' , nFLComb);
    
    % ------------------------------------
    initTime = tic; 
    %% ******************************************************************************************
    
    % Pre-allocation for Parameters 
    fprintf('\nPre-allocating annParameters{...}\n');
    for iExperiment = 1:nFLComb 
        
        fprintf(' %6d', iExperiment);
        if ( mod(iExperiment,10) == 0 )
            fprintf('\n');
        end
        
        annParameters{iExperiment}                = annParamInitialization(parameters);
        % -----------------------------------------
        annParameters{iExperiment}.tsFolder       = tsFolder;
        annParameters{iExperiment}.tsFilename     = tsFilename;  % already include the TSName & TSType
        %annParameters{iCombinationFactorLevels}.tsName         = tsFilename(1:(numel(tsFilename)-4));
        annParameters{iExperiment}.tsName         = tsName;
        annParameters{iExperiment}.tsType         = tsType;
        annParameters{iExperiment}.initId         = initId;
        annParameters{iExperiment}.folder_Results = folder_Results;
        % -----------------------------------------
        % HORIZONS
        
        annParameters{iExperiment}.ForecastHorizon      = parameters.ForecastHorizon;
        annParameters{iExperiment}.ForecastOutput       = parameters.ForecastOutput;
        
        % THIS PARAMETER IS NOT NEEDED because the system computes both options
        % annParameters{iExperiment}.usingPredictedOrReal = parameters.usingPredictedOrReal;
        
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
        % EARLY STOPPING
        annParameters{iExperiment}.earlyStopping             = parameters.earlyStopping;
        annParameters{iExperiment}.max_fail_TrainCyclesPrct  = parameters.max_fail_TrainCyclesPrct;
        
                
        %% COMPUTING A RANDOM SEED =================================================================
        
        % Version 01
        % The following get the same seed for some of the consequitive iterations of the loop
        % v = (int32(clock)); seed = v(5) + v(6);  clear v;
        % seed = fix(cputime*1000);
        % rng(seed);  % fprintf('Seed: %03d\n',seed); % seed is the second for time 
        % annParameters{iExperiment}.rngSeed  = seed;  clear seed;
        % ----------
        % Version 02
        % Computing a "random" (from the Current date and time(microseconds included) of the computer)
        % pause(0.02);  % for this option, this puase is not needed
        
        pause(parameters.waitingTime);
        DT = clock;         
        DT(6) = DT(6)*1000; 
        DT = int64(DT);
        
        newSeed = sum(DT);  % newSeed = DT(1) + DT(2) + DT(3) + DT(4) + DT(5) + DT(6);
        
        annParameters{iExperiment}.rngSeed  = newSeed;
        % annParameters{iExperiment}.rngSeed  = fix( cputime * 1000 );        
        % rng(annParameters{iExperiment}.rngSeed);
        
        % =========================================================================================
               
        %%  ---------------------------------------------------------
        scrsz{iExperiment} = get( groot ,'ScreenSize'); % [left bottom width height].
        
    end
    fprintf('\nPre-allocated annParameters{...}\n');
    
    %% FOR PARALELIZATION (each Factor Level Combination(i.e from 1 to nSim) )  ====================
    fprintf('EXECUTING THE TRAINING AND FORECAST for each FACTOR LEVEL COMB ... \n');
    
    % parfor iExperiment_B = 1:nFLComb
    for iExperiment_B = 1:nFLComb     
        
        % ============================================================================
        % TRAIN THE ANN and get the result of the train, validation and test
        % ============================================================================
        tStart = tic;      
        
        % This function ann4tsForecast_v02 should not write into a file (because par pool)
        resultsCellArray{iExperiment_B} = ann4tsForecast_v02( annParameters{iExperiment_B} );
        % ---------------------------------------------------------------------------------
        % taking the time of execution of the learning process
        resultsCellArray{iExperiment_B}.elapsedTime = toc(tStart);
        
        % -------------------------------------------------------------------------------
        % Print on the screen some results on 
        
        %fprintf('\n');
        fprintf('%06d %4d %4d %4d %4d %4d %6.2f %6d ',...
                annParameters{iExperiment_B}.rngSeed           ,...                    
                annParameters{iExperiment_B}.ForecastHorizon   ,...        
                annParameters{iExperiment_B}.iCombFactLevel    ,...
                annParameters{iExperiment_B}.nInputs           ,...
                annParameters{iExperiment_B}.hiddenLayersSize  ,...
                annParameters{iExperiment_B}.trainFcn          ,...  
                annParameters{iExperiment_B}.learningRate      ,...
                annParameters{iExperiment_B}.trCycles          );  
        
        % fprintf(' -> ');
        fprintf('\n');
        
        fprintf('rmseValHT1 %10.5f   smapValHT1 %10.5f   rmseValHT2 %10.5f   smapValHT2 %10.5f\ntime %10.2f sec',...
                resultsCellArray{iExperiment_B}.rmseValHT1     ,...
                resultsCellArray{iExperiment_B}.smapeValHT1    ,...  
                resultsCellArray{iExperiment_B}.rmseValHT2     ,...
                resultsCellArray{iExperiment_B}.smapeValHT2    , ...
                resultsCellArray{iExperiment_B}.elapsedTime    );  
               
        fprintf('\n ------------------------------------------------------ \n')    
        % --------------------------------------------------------------------------
        
    end
    
    fprintf('\n*** All FL combinations for ANNs have been trained. ****\n');
    % --------------------------------------------------------------------------------
    fprintf(fidLog,'\n*** All FL combinations for ANNs have been trained. ****\n');    
    
    % ================================================================================
    %% SAVING RESULTS in (General, Local, Log) CSV FILES   ===========================
    fprintf(fidLog,'\n*** Saving results in (General, Local, Log) CSV FILES ***\n');
    % THIS CANNOT BE PARALIZED because is working with just one file 
    for iExperiment = 1:nFLComb 
        
        showParam01Values( fidGeneralRes   , 'res' , annParameters{ iExperiment } );
        showParam01Values( fidLog          , 'log' , annParameters{ iExperiment } );
        showParam01Values( fidLocalRes     , 'res' , annParameters{ iExperiment } );
        
        showResults01Values( fidGeneralRes , 'res' , resultsCellArray{ iExperiment } );
        showResults01Values( fidLog        , 'log' , resultsCellArray{ iExperiment } );
        showResults01Values( fidLocalRes   , 'res' , resultsCellArray{ iExperiment } );
                
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
    
    fprintf('\n*** All FL combinations for ANNs have been save in csv file and mat files. ****\n');

        
    %% SHOWING FIGURES ====================================================================
    
    fprintf('*** All FL combinations for ANNs are going to be shown in figures. ****\n\n');
    
    parfor iExperiment = 1:nFLComb  % see transparency 
    %for iExperiment = 1:nFLComb 
    
        % Getting Data 
        % fprintf('STEP 00\n');
        
        singleANNParameters  = annParameters{iExperiment};
        trainRecord          = resultsCellArray{iExperiment}.trainRecord;
        result               = resultsCellArray{iExperiment};
        net01                = resultsCellArray{iExperiment}.net;
        %scrSize             = scrsz{iCombinationFactorLevels};
        
        
        % SHOW THE LEARNING PROCESS ERROR -----------------------------------------
        if (singleANNParameters.showTrainRecord)
            
            % fprintf('IndExp %s - STEP 01.1 \n', result.strIndExp);    
            
            % ---------------------------------------------------------------------
            h1 = figure;
            plotperform( trainRecord );
            %title( strcat('ann learning process perfomance',result.tsName,'_',result.tsType,'_',result.strIndExp ) );

            % annTrainPerformanceFilename = fullfile ( singleANNParameters.folder_Results, ...
            %                                          strcat(result.tsName,'_',result.tsType, ...
            %                                         '_init_',strInitId, ...
            %                                         '_iFL_', result.strIndExp, ... 
            %                                         '_trainPerformance_v1', '.fig') );
            annTrainPerformanceFilename = fullfile ( singleANNParameters.folder_Results, ...
                                                     strcat(result.tsName,'_',result.tsType, ...
                                                     '_init_',strInitId, ...
                                                     '_iFL_', result.strIndExp, ... 
                                                     '_trainPerformance_v1') );

            
            % savefig(h1 , annTrainPerformanceFilename, 'compact');
            % saveas( h1 , annTrainPerformanceFilename, 'png');
            print(  h1,  annTrainPerformanceFilename, '-dpng','-r300');
            close(h1); h1 = [];
            % clear h1; % you cannot clear variables from a workspace by executing clear 
                        % inside a parfor. Instead: set to empty: h1 = [];
            
            
            
            % ---
            % Showing num of training cycles and performance
            % fprintf('IndExp %s - STEP 01.2 \n', result.strIndExp);    
            fprintf(' net01.trainParam.epochs: %d -- numel(trainRecord.perf): %d -- numel(trainRecord.vperf): %d -- numel(trainRecord.tperf): %d\n', ...
                      net01.trainParam.epochs , numel(trainRecord.perf) , numel(trainRecord.vperf) , numel(trainRecord.tperf) );
            
            % ---------------------------------------------------------------------
            
            % h2 = figure;
            % plot( 1:( numel(trainRecord.perf) ),trainRecord.perf);  hold on;
            % plot( 1:( numel(trainRecord.perf) ),trainRecord.vperf); hold on;
            % plot( 1:( numel(trainRecord.perf) ),trainRecord.tperf); 
            % title( strcat('ann learning process perfomance v2',result.tsName,'-',result.tsType,'-',result.strIndExp ) );
            % 
            % annTrainPerformanceFilename = fullfile (singleANNParameters.folder_Results, ...
            %                                         strcat(result.tsName,'_',result.tsType,...
            %                                         '_init_',strInitId, ...
            %                                         '_iFL_', result.strIndExp, ... 
            %                                         '_trainPerformance_v2', '.fig') );
            % savefig( h2 , annTrainPerformanceFilename, 'compact');
            % saveas(  h2 , annTrainPerformanceFilename, 'png');
            % print(  h2,  annTrainPerformanceFilename, '-dpng','-r300');
            % close(h2); clear h2
            % ---------------------------------------------------------------------
            
            % h3 = figure;
            % t = result.testTargets;
            % x = zeros(10,5);
            % y = net01(x);
            % plotregression(t,y,'Regression');            
            % annTrainPerformanceFilename = fullfile (singleANNParameters.folder_Results, ...
            %                                         strcat(result.tsName,'_',result.tsType,'_',num2str(singleANNParameters.iExperiment,'%4d'),'_',...
            %                                         'regression',);
            % savefig( h3 , annTrainPerformanceFilename, 'compact');
            % saveas(  h3 , annTrainPerformanceFilename, 'png');
            % print(  h3,  annTrainPerformanceFilename, '-dpng','-r300');
            % close(h3); clear h3
            


        end 
        % ------------------------------------------------------------------------
        % ------------------------------------------------------------------------
        % Are test_tsData & testOutputs the same vector with the same values ??
        
        if (singleANNParameters.showOnScreen)
            % fprintf('IndExp %s - STEP 02 \n', result.strIndExp);    
            fprintf('test_tsData                   -> size(...): %d %d \n',...
                     size( result.test_tsData ,1 ) ,  size(result.test_tsData  ,2 ) );
            fprintf('forecastResults.testHT2Outputs -> size(...): %d %d \n',...
                     size( result.testHT2Outputs , 1 ), size( result.testHT2Outputs , 2 ) );
            fprintf('test_tsData & testOutputs are same size?? \n');
        end
        result.test_tsData; 
        
        % ------------------------------------------------------------------------
        % SHOW ERRORS ON THE SCREEN
        % fprintf('STEP 04\n');
        if (singleANNParameters.showOnScreen)
            % fprintf('IndExp %s - STEP 03 \n', result.strIndExp);    
            
            fprintf('InitId %i - iFL%i - iExp%i \n',strInitId, singleANNParameters.iCombFactLevel, singleANNParameters.iExperiment);
            
            fprintf('Error   %3s %12s  %12s  %12s\n'       ,'Hx','TRAIN','VAL','TEST');
            fprintf('rmse    %3s %12.5f  %12.5f  %12.5f\n'     , ...
                    'HT1',    result.rmseTrain  , result.rmseValHT1  , result.rmseTestHT1);
            fprintf('smape   %3s %12.2f  %12.2f  %12.2f\n'     , ...
                    'HT1',    result.smapeTrain , result.smapeValHT1 , result.smapeTestHT1);
            fprintf('rmse    %3s %12.5f  %12.5f  %12.5f\n'     , ... 
                     'HT2',   result.rmseTrain  , result.rmseValHT2  , result.rmseTestHT2);
            fprintf('smape   %3s %12.2f  %12.2f  %12.2f\n'     , ...
                     'HT2',   result.smapeTrain , result.smapeValHT2 , result.smapeTestHT2);

        end
        
        % SHOW TARGETS AND OUTPUTS  ------------------------------------------------
        if ( singleANNParameters.showTrainValTestTargetOutput )
            % fprintf('IndExp %s - STEP 04 \n', result.strIndExp);    
            
            scrsz = get( groot ,'ScreenSize'); % [left bottom width height].
            hTrVaTe_TargetOutput = figure(  'Position', [ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5],  ...
                                            'visible', parameters.figVisible);
            

            a = size(result.trainTargets,2);
            b = size(result.trainTargets,2) + size(result.valTargets,2);
            c = size(result.trainTargets,2) + size(result.valTargets,2) + size(result.testTargets,2);
            t = 1:c;
            tVal  = (a+1):b; 
            tTest = (b+1):c;
            
            
            % As [train/val/test]Targets [train/val/test]Outputs are row vector

            plot( t     ,[ result.trainTargets , result.valTargets , result.testTargets] , 'ko-.', 'MarkerSize' , 3,'MarkerFaceColor','k','LineWidth',1); hold on
            plot( tVal  , result.valHT1Outputs               , 'bo:', 'MarkerSize' , 5,'MarkerFaceColor','b','LineWidth',1); 
            plot( tVal  , result.valHT2Outputs               , 'ro:', 'MarkerSize' , 5,'MarkerFaceColor','r','LineWidth',1); 
            plot( tTest , result.testHT1Outputs              , 'bx:', 'MarkerSize' , 5,'MarkerFaceColor','b','LineWidth',1); 
            plot( tTest , result.testHT2Outputs              , 'rx:', 'MarkerSize' , 5,'MarkerFaceColor','r','LineWidth',1); 
            
            grid on; grid minor
            legend('targets','valOutputHT1','valOutputHT2','testOutputsHT1', 'testOutputsHT2');
            title(strcat('(Train + Val + Test)','--', singleANNParameters.tsFilename,'-init-',strInitId  ));
            
            % clear t a b c tVal tTest ; % you cannot clear variables from a workspace 
                                         % by executing clear inside a parfor. Alternatively, 
                                         % you can free up memory used by a variable by setting 
                                         % its value to empty var = []; when it is no longer needed. 
            % saveas(gcf,'Barchart.png')
            
            %fprintf('\t-Step 05.6-' );
            TrVaTeTargetOutputFigFilename = fullfile (singleANNParameters.folder_Results, ...
                                                      strcat(result.tsName,'_',result.tsType,...
                                                      '_init_',strInitId, ...
                                                      '_iFL_',result.strIndExp,'_',...
                                                      'TrVaTe+TarOutHT1HT2'));
            
            %savefig( hTrVaTe_TargetOutput , TrVaTeTargetOutputFigFilename , 'compact');
            %saveas( hTrVaTe_TargetOutput , TrVaTeTargetOutputFigFilename, 'png');
            print(  hTrVaTe_TargetOutput,  TrVaTeTargetOutputFigFilename, '-dpng','-r300');
            
            % TrVaTeTargetOutputFigFilename = fullfile (singleANNParameters.folder_Results, ...
            %                                           strcat(result.tsName,'_',result.tsType,'_',result.strIndExp,'_',...
            %                                           'TrVaTe+TarOutHT1HT2-', result.strIndExp , '.pdf') );
            % 
            % print( hTrVaTe_TargetOutput , TrVaTeTargetOutputFigFilename , '-dpdf','-fillpage','-r300')
            
            %clear filename;% you cannot clear variables from a workspace 
                            % by executing clear inside a parfor. Alternatively, 
                            % you can free up memory used by a variable by setting 
                            % its value to empty var = []; when it is no longer needed. 
            close(hTrVaTe_TargetOutput);
            
        end
        % ---------------------
        
        if ( singleANNParameters.showValTargetOutput )
           % fprintf('IndExp %s - STEP 05 \n', result.strIndExp);    
            scrsz = get(groot,'ScreenSize'); % [left bottom width height].
            hValTargetOutput = figure('Position',[ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5], ...
                                      'visible', parameters.figVisible);
            
            a = size(result.trainTargets,2);
            b = size(result.trainTargets,2) + size(result.valTargets,2);
            c = size(result.trainTargets,2) + size(result.valTargets,2) + size(result.testTargets,2);
            
            tValTest = ( a + 1 ):c;
            tVal     = ( a + 1 ):b; 
            tTest    = ( b + 1 ):c;
            
            % As [train/val/test]Targets [train/val/test]Outputs are row vector
            
            plot( tValTest ,[ result.valTargets , result.testTargets] , 'ko--', 'MarkerSize' , 3,'MarkerFaceColor','k','LineWidth',1); hold on
            plot( tVal  , result.valHT1Outputs   , 'bo:', 'MarkerSize' , 5,'MarkerFaceColor','b','LineWidth',1); 
            plot( tVal  , result.valHT2Outputs   , 'ro:', 'MarkerSize' , 5,'MarkerFaceColor','r','LineWidth',1); 
            plot( tTest , result.testHT1Outputs  , 'bx:', 'MarkerSize' , 5,'MarkerFaceColor','b','LineWidth',1); 
            plot( tTest , result.testHT2Outputs  , 'rx:', 'MarkerSize' , 5,'MarkerFaceColor','r','LineWidth',1); 
            grid on; grid minor
            legend('targets','valOutputHT1','valOutputHT2','testOutputsHT1', 'testOutputsHT2');
            
            title(strcat('Val + Test)','--', singleANNParameters.tsFilename));
            %clear a b c tValTest tVal tTest ; % NOT AT a PARFOR            
      
            vaTeTargetOutputFigFilename = fullfile( singleANNParameters.folder_Results , ...
                                                    strcat( result.tsName,'_',result.tsType,...
                                                    '_init_',strInitId, ...    
                                                    '_iFL_',result.strIndExp,'_',...
                                                    'VaTe+TarOutHT1HT2' ) ); 
            
            %savefig( hValTargetOutput , vaTeTargetOutputFigFilename , 'compact');
            %saveas( hValTargetOutput , vaTeTargetOutputFigFilename , 'png');
            print(  hValTargetOutput,  vaTeTargetOutputFigFilename, '-dpng','-r300');
            
            % vaTeTargetOutputFigFilename = fullfile( singleANNParameters.folder_Results , ...
            %                                         strcat( result.tsName,'_',result.tsType,'_',result.strIndExp,'_',...
            %                                         'VaTe+TarOutHT1HT2-' , result.strIndExp , '.pdf' ) ); 
            % 
            % print( hValTargetOutput , vaTeTargetOutputFigFilename , '-dpdf','-fillpage','-r300')
                        
            close(hValTargetOutput);
      
        end
        % ------------------------
        
        if ( singleANNParameters.showTestTargetOutput )
            % fprintf('IndExp %s - STEP 06 \n', result.strIndExp);    
            scrsz = get(groot,'ScreenSize'); % [left bottom width height].
            hTestTargetOutput = figure('Position',[ (20) (100) scrsz(3)/1.5 scrsz(4)/1.5], ...
                                       'visible', parameters.figVisible );
            
            a = size(result.trainTargets,2) + size(result.valTargets,2); 
            b = size(result.trainTargets,2) + size(result.valTargets,2) + size(result.testTargets,2);
            tTest = (a+1):b;
            % As [train/val/test]Targets [train/val/test]Outputs are row vector
            
            plot( tTest , result.testTargets                   , 'ko--', 'MarkerSize' , 3,'MarkerFaceColor','k','LineWidth',1); hold on
            plot( tTest , result.testHT1Outputs , 'bx:', 'MarkerSize' , 5,'LineWidth',1); 
            plot( tTest , result.testHT2Outputs , 'rx:', 'MarkerSize' , 5,'LineWidth',1); 
      
            grid on; grid minor
            legend( 'targets' , 'testOutputsHT1' , 'testOutputsHT2');
            title( strcat('Test','--', singleANNParameters.tsFilename));
            %clear a b tTest ; % NOT AT a PARFOR 
      
            %saveas(gcf,'Barchart.png');
            TrVaTeTargetOutputFigFilename = fullfile( singleANNParameters.folder_Results, ...
                                                      strcat(result.tsName,'_',result.tsType, ...
                                                      '_init_',strInitId, ...    
                                                      '_iFL_',result.strIndExp,'_', ...
                                                      'Te+TarOutHT1HT2') );
            
            %savefig( hTestTargetOutput , TrVaTeTargetOutputFigFilename , 'compact' );
            %saveas(  hTestTargetOutput , TrVaTeTargetOutputFigFilename , 'png');
            print(   hTestTargetOutput , TrVaTeTargetOutputFigFilename , '-dpdf','-fillpage','-r300');
            
            % TrVaTeTargetOutputFigFilename = fullfile( singleANNParameters.folder_Results, ...
            %                                           strcat( result.tsName,'_',result.tsType,'_',result.strIndExp,'_', ...
            %                                           'Te+TarOutHT1HT2') ) ;
            % print( hTestTargetOutput , TrVaTeTargetOutputFigFilename , '-dpdf','-fillpage','-r300')
           
            close(hTestTargetOutput);
    
        end
        % fprintf('End IndExp %s ----\n', result.strIndExp);    
    end
    
    fprintf('--- All FL combinations for ANNs have been shown in figures. ----\n');
    %% ===================================================================================
    totalTime = toc(initTime);   % avgTime   = totalTime/ iCombinationFactorLevels;
    
    fprintf( fidLog, '\ntotalTime %6.1f seconds %6.1f hours\n',totalTime,totalTime/3600); 
    fprintf( fidLog, '======== EXP %s %s %2d ========\n',tsName,tsType,initId);    

    % **************************************************************************************
    % Close file identifiers
    if (fidLog > 2 )
        fclose(fidLog);
    end
    if (fidLog > 2 )
        
    end
    if (fidLog > 2 )
        
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
    fprintf(fid, '%6s' ,'Type');
    fprintf(fid, '%6s','In');
    fprintf(fid, '%8s','seed');
    fprintf(fid, '%8s','nFLC');

    fprintf(fid, '%6s','nIn');
    fprintf(fid, '%6s','hLS');
    fprintf(fid, '%6s','trFn');
    fprintf(fid, '%6s','lr');
    fprintf(fid, '%8s','trC');
    
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    fprintf(fid, '%12s','rmseTr');
    fprintf(fid, '%12s','smapeTr');
    
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % VAL & TEST HT1
    fprintf(fid, '%12s','rmseVaHT1');
    fprintf(fid, '%12s','smapeVaHT1');
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    fprintf(fid, '%12s','rmseTeHT1');
    fprintf(fid, '%12s','smapeTeHT1');
          
    if (strcmp(fileType,'log') == 1)
       fprintf(fid,'\n');  
    end
    
    % VAL & TEST HT2
    fprintf(fid, '%12s','rmseVaHT2');
    fprintf(fid, '%12s','smapeVaHT2');
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    fprintf(fid, '%12s','rmseTeHT2');
    fprintf(fid, '%12s','smapeTeHT2');
          
    if (strcmp(fileType,'log') == 1)
       fprintf(fid,'\n');  
    end
    
    
    fprintf(fid,'%12s','time');
    
    fprintf(fid,'\n'); 
end

% --------------------------------------------
function showHeader02(fid,fileType)
    % example for the call: showHeader02(fidGenRes,'res');

    fprintf(fid, '%25s','tsName');
    fprintf(fid, '%6s' ,'Type');
    fprintf(fid, '%6s','In');
    fprintf(fid, '%8s','seed');
    fprintf(fid, '%8s','nFLC');

    fprintf(fid, '%6s','nIn');
    fprintf(fid, '%6s','hLS');
    fprintf(fid, '%6s','trFn');
    fprintf(fid, '%6s','lr');
    fprintf(fid, '%8s','trC');

    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end

    % TRAIN 
    fprintf(fid, '%12s','rmseTr');
    fprintf(fid, '%12s','smapTr');
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % VAL HT1 
    fprintf(fid, '%12s','rmseVaHT1');
    fprintf(fid, '%12s','smapVaHT1');
    
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % TEST HT1
    fprintf(fid, '%12s','rmseTeHT1');
    fprintf(fid, '%12s','smapTeHT1');
        
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % VAL HT2
    fprintf(fid, '%12s','rmseVaHT2');
    fprintf(fid, '%12s','smapVaHT2');
    
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    end
    
    % TEST HT2
    fprintf(fid, '%12s','rmseTeHT2');
    fprintf(fid, '%12s','smapTeHT2');
    
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
    fprintf(fid,'%6s',parameters.tsType);
    fprintf(fid,'%6i',parameters.initId);
    fprintf(fid,'%8i',parameters.rngSeed);
    fprintf(fid,'%8i',parameters.iCombFactLevel);
    fprintf(fid,'%6i%6i%6i%6.2f%8i',...
                    parameters.nInputs,...
                    parameters.hiddenLayersSize,...
                    parameters.trainFcn,...
                    parameters.learningRate,...
                    parameters.trCycles);

    if (strcmp(fileType,'log') == 1)
      fprintf(fid,'\n');  
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

    
    if (strcmp(fileType,'log') == 1)
      fprintf(fid,'%12s\n',' RESULTS');  
    elseif (strcmp(fileType,'res') == 1)  
      fprintf(fid,'');  
    end             

    
    % ----------------------------------
    fprintf(fid,'%12.5f%12.2f', ...
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

    % ----------------------------------
    fprintf(fid,'%12.5f%12.2f', ...
                 result.rmseValHT1,...
                 result.smapeValHT1);

    if ( strcmp(fileType,'log') == 1 )
        fprintf(fid,'\n');  
    elseif (strcmp(fileType,'res') == 1)  
        fprintf(fid,'');  
    else
        % do nothing 
    end 
    
    % ----------------------------------
    fprintf(fid,'%12.5f%12.2f', ...
                 result.rmseTestHT1,...
                 result.smapeTestHT1);
             
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
    
    % ----------------------------------
    fprintf(fid,'%12.5f%12.2f', ...
                 result.rmseValHT2,...
                 result.smapeValHT2);
    if ( strcmp(fileType,'log') == 1 )
        fprintf(fid,'\n');  
    elseif (strcmp(fileType,'res') == 1)  
        fprintf(fid,'');  
    else
        % do nothing 
    end
    
    % ----------------------------------
    fprintf(fid,'%12.5f%12.2f', ...
                 result.rmseTestHT2,...
                 result.smapeTestHT2);
    
             
    if (strcmp(fileType,'log') == 1)
        fprintf(fid,'\n');  
    elseif (strcmp(fileType,'res') == 1)  
        fprintf(fid,'');  
    end
    
    % ----------------------------------
    fprintf(fid,'%12.2f', result.trainTimeElapsed);
    fprintf(fid,'\n'); 
    
    if ( strcmp(fileType,'log') == 1 )
        fprintf(fid,'\n\n');  
    elseif (strcmp(fileType,'res') == 1)  
        fprintf(fid,'');  
    else
        % do nothing 
    end

end

% --------------------------------------------


