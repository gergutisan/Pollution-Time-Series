function expResults = func_02_executeExperiments_ANN4TS_v04 ( parameters                   , ...
                                                              fileFactorLevelCombination , ...
                                                              tsOriginalDataFileRoots) 
%% execute the experiment for a time series and a factor level combination
%{
%  Input parameters
%     fileFactorsLevelsCombination - relative full path. 
%                  text file for the combination of level values.
%     tsDataFileRoot: for filename for the original time series observations
                      'ts_'tsDataFileRoot'.dat'
                      strcat('ts_',tsDataFileRoot,'.dat')
%
% Detailed information: ...
%}
    
    %% RESET --------------------------------------------------------
    clc; close all; fclose('all'); 
    % delete(gcp) 
    % note: Get current parallel pool - MATLAB gcp - MathWorks
    
    
    %% LOCAL PARAMETERS 
    
    % tsTypesCellArray      = { 'raw', 'dif' , 'inc' };
    % resultsFolderPrefix   = 'Results_';
    
    tsTypesCellArray      = parameters.tsTypesCellArray;
    resultsFolderPrefix   = parameters.resultsFolderPrefix;

        

    %% SET WORKING DIRECTORY ---------------------------------------------
    if (~isdeployed)
      s1 = mfilename('fullpath'); s2 = which(s1) ; s3 = fileparts(s2) ; cd(s3)
      % cd(fileparts(which(mfilename('fullpath'))));
      clear s*;
    end

    %% CLEAN PREVIOUS FILES FOR RESULTS
    % clear; % -> erase the workspace (but not the parpool or the working directory)
    [ stat , mess , id ] = rmdir( strcat( parameters.resultsFolderPrefix2 , '*' ) , 's');
        
    delete( strcat( '*.' , parameters.fileExtensionResults ) ) ;

    %% TIME SERIES  ============================================================
    
    % Time Series: Dowjones, Mackeyglass01 Quebec Temperature
    % Time Series 4 Test: ts4Test01.dat (written by the tester), ts4Test02.dat (written by the tester), ts4Test03.dat (sin funct)
    
    % FOR TEST  -----------------------------------------------------------
    % tsNamesCellArray = {'4Test03'};                % sinusoidal function.
    % tsNamesCellArray = {'Temperature'};
    % tsNamesCellArray = {'4Test01','4Test03','Temperature'};
    % tsNamesCellArray = {'Dowjones', 'Temperature'};
    % tsTypesCellArray = {'raw', 'dif'};
    % tsTypesCellArray = {'raw', 'dif', 'inc'};
    % tsName = 'MackeyGlass01';  tsType = 'raw';

    % FOR REGULAR EXPERIMENTS / WORKS ----------------------------------------
    % SMC2016 + IWANN2017 + ITISE2017
    % tsNamesCellArray = {'Dowjones','Mackeyglass01','Quebec', 'Temperature'};
    
    % ===========================================
    % Special ISSUE NPL+IWANN2017  + ASC (applied Soft Computing)  
    % tsNamesCellArray = {'NO2-FedzLadreda-16-12','NO2-PzCastilla-16-10',...
    %                      'O3-JuanCarlosI-16-07', 'PM25-MendezAlvaro-16-10' };
    
    % ===========================================
    % tsNamesCellArray = { tsOriginalDataFileRoot }; 
    
    tsNamesCellArray = cell( numel( tsOriginalDataFileRoots ) , 1 );
    
    for k = 1:numel(tsOriginalDataFileRoots) 
        tsNamesCellArray{k} = tsOriginalDataFileRoots{k}; 
    end
    clear k
    
    %% FACTOR & LEVELS FILENAME ****************************************************************
    %{
        % This was for an old version --------------------------------------
        % factorsLevelsFilename  = 'domAny_setParameters_test_01.dat';    % ->    1 combinations
        % factorsLevelsFilename  = 'domAny_setParameters_test_03.dat';    % ->    3 combinations
        % factorsLevelsFilename  = 'domAny_setParameters_test_18.dat';    % ->   18 combinations
        % -----------------------
        % factorsLevelsFilename  = 'domAny_setParameters01_FF.dat';       % -> 1024 combinations
        % factorsLevelsFilename  = 'domAny_setParameters01_FF.dat';       % -> 3584 combinations

        % POLLUTION ------------------------------------------------------------------------------
        % factorsLevelsFilename  = 'domAny_setParameters02_FF.dat';         % POLLUTION Try 01

        % -----------------------

        % factorsLevelsFilename  = 'domAny_setParameters01_L16x2.dat';    % ->   32 combinations
        %FL_filename = strcat(factorsLevelsFolder,'/',factorsLevelsFilename);
    
        factorsLevelsFilename  = fileFactorsLevelsCombination;
        factorsLevelsFolder    = 'TablesFactorsAndLevels';
        FL_filename = fullfile(factorsLevelsFolder,factorsLevelsFilename);

        %}
    
    FL_filename = fileFactorLevelCombination; 
        
    %% Create [Cell] Array for ALL times series (tsName1_tsType1, ....  => #tsName x #tsType ) 
    
    tsNameTypeCellArray = cell( numel( tsNamesCellArray ) * numel( tsTypesCellArray) , 2 );
    for j = 1:numel(tsTypesCellArray)
        for i = 1:numel(tsNamesCellArray)
            row = ( ( j - 1 ) * numel( tsNamesCellArray) ) + i;
            tsNameTypeCellArray {row,1} = tsNamesCellArray{ i };
            tsNameTypeCellArray {row,2} = tsTypesCellArray{ j };
        end
    end
    clear row i j ;
    % -----------------------
    
    %% SET RESULTS FOLDER   ===================================================================
    resultsFolder = strcat(resultsFolderPrefix,'00');
    
    mkdir(resultsFolder);


    %% EXECUTE EXPERIMENTS  ===================================================================
    
    initID             = 1;  
    % debugLevel         = 0;
    debugLevel         = parameters.debugging;
    numInitializations = parameters.numInitializations;   % numInitializations = 10;
    sumPartialTime     = 0;
    numTsNameType      = size(tsNameTypeCellArray,1);

    initTime4WholeExp  = tic; 
    % parfor indexTsNameTsType = 1:numTsNameType

    filesOfResGenCA = cell( numInitializations * numTsNameType , 1 );
    
    expResults = cell(numTsNameType,numInitializations);
    
    % ---------------------------------------------------------------------
    % EACH TIME SERIES TS_NAME and TS_Type ( raw , dif , inc )-------------
        
    % parfor   indexTsNameTsType = 1:numTsNameType     % For Testing Reasons   
    for   indexTsNameTsType = 1:numTsNameType         % For Testing Reasons 
        
        tsName = tsNameTypeCellArray { indexTsNameTsType , 1};
        tsType = tsNameTypeCellArray { indexTsNameTsType , 2};
           
        fprintf('\n*********************\n');
        fprintf('\n*** tsName: %s ; tsType: %s \n\n', tsName, tsType);
        fprintf('\n*********************\n');
    
        % ---------------------------------------------------------------------
        % EACH INITIALIZATION ------------------
        % parfor   initID = 1:numInitializations
        for initID = 1:numInitializations
                
            % pause(1); % pause( initID * 2 );
            fprintf('\n*********************\n');
            fprintf('\n*** initID: %2d      \n', initID);
            fprintf('\n*********************\n');

            % generate name for the FILE FOR RESULTS OF THE TSNAME, TSTYPE, and INIT
            % genFileRes = strcat(tsName,'_',tsType,'_',sprintf('%02d',initID),parameters.fileExtensionResults);
            genFileRes = strcat(tsName,'_',tsType,'_init_',sprintf('%03d',initID),'.csv');
            genFileRes = fullfile(resultsFolder,genFileRes);
            
            fid = fopen(genFileRes,'w'); fclose(fid);  % <- erasing any previous conten

            % i = (initID - 1) * numTsNameType + indexTsNameTsType;
            % i = i+1;
            % filesOfResGenCA{i} =  genFileRes;

            % ----------------------------------------------------------------------------------
            partialInitTime = tic; 
            
            % ==================================================================================
            %% THIS executes the FactorLevelCombinations of ANN parameter for a single Time Series Forecasting 
            result = func_03_ann4tsf_experiments_v05( genFileRes    , ...
                                                      tsName, ...
                                                      tsType, ...
                                                      parameters.fileFactorLevelCombination, ...
                                                      initID, ...
                                                      parameters);

            expResults{ indexTsNameTsType , initID } = result;
                                                  
            partialTime    = toc(partialInitTime);
            sumPartialTime = sumPartialTime + partialTime;
            % % ==================================================================================
            % cont = cont + 1;
            % timeOfExperiment{cont,1}= tsName;
            % timeOfExperiment{cont,2}= tsType;
            % timeOfExperiment{cont,3}= initId;
            % timeOfExperiment{cont,4}= partialTime;

        end

    end
    
    % Save the whole results into a matlab binary file
    save( fullfile( parameters.folderAllResults,parameters.filesOfResGenCompleteMat),'expResults' );
    
    % End of experiments    ===============================================
    fprintf('\nEnd of experiments\n')

    %% COPY FILES OF RES in this directory ----------------------------------------------------------
    
    % % files = dir(strcat('00_res*.dat') );
    % files = dir(strcat('00_res*.',parameters.fileExtensionResults) );
    % 
    % for i=1:numel(files)
    % %for i=1:(numInitializations*numTsNameType)
    %    filesOfResGenCA{i} = files(i).name;
    % end
    % if ( numel(files) > 0 )
    %   copyFiles(filesOfResGenCA);
    % end
    % clear i;

    %% TIME OF THE EXPERIMENT  ====================================================================
    wholeExpTotalTime_par = toc(initTime4WholeExp);
    wholeExpTotalTime_nopar = sumPartialTime;
    % wholeExpTotalTime_nopar = 0;
    % for i = 1:size(timeOfExperiment,1)
    %     wholeExpTotalTime_nopar = wholeExpTotalTime_nopar + timeOfExperiment{i,4};
    % end;

    fprintf('\nwholeExpTotalTime PAR -> %6.2f seconds %6.2f hours\n',...
        wholeExpTotalTime_par,wholeExpTotalTime_par/3600); 
    fprintf(  'wholeExpTotalTime NO PAR-> %6.2f seconds %6.2f hours\n',...
        wholeExpTotalTime_nopar,wholeExpTotalTime_nopar/3600); 
    % 
    %% CLOSE FIGURES AND FILES =====================================================================
    close all; fclose('all'); 

    %% CLOSE MATLAB -----------------
    % exit; 
        
    % ********************************************************************************************    
    %% LOCAL FUNCTIONS *************************************************************************** 
    function [filesOfResGenComplete] = copyFiles( fileOfResGen, ...
                                                  parameters  )

        % filesOfResGenComplete = '00_results_all.dat'; 
        filesOfResGenComplete = parameters.filesOfResGenComplete; 
        f_new = fopen(filesOfResGenComplete,'w');

        for p = 1:length(fileOfResGen)
            f_old  = fopen(fileOfResGen{p},'r');
            f_line = fgetl(f_old); 
            if p > 1
                % Jump the first line as header
                f_line = fgetl(f_old); 
            end
            while ischar(f_line)
                % (for excel) CHANGE . AS SEPARATOR FOR DECIMALS , 
                f_line = strrep(f_line, '.', ','); 
                fprintf( f_new,'%s',f_line);
                fprintf( f_new,'\n');
                f_line = fgetl(f_old);
            end
            fclose(f_old);
        end

        fclose(f_new);

    end
end