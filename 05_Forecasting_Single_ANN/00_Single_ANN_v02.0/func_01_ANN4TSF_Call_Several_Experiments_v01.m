function error = func_01_ANN4TSF_Call_Several_Experiments_v01 (FLCombinations )
    %% LINKS  ----------------------------------------------------------
    % https://icme.hpc.msstate.edu/mediawiki/index.php/MATLAB_Tutorials
    % http://datos.gob.es/recurso/sector-publico/org/Organismo/L01280796
    % Calidad del aire. Tiempo real
    %    http://datos.madrid.es/egob/catalogo/212531-7916318-calidad-aire-tiempo-real.txt


    %% RESET      ==========================================================================
    % clear; clc; close all; fclose('all');
    %% INIT       ==========================================================================
    error = 1;

    %% SET FOLDERs AND PATH     ============================================================
    cd(fileparts(mfilename('fullpath')));    % does not work if executed by Run Section [and advance]
    folderFunctions       = fullfile( fileparts(mfilename('fullpath')),'Functions');
    folderTimeSeries      = fullfile( fileparts(mfilename('fullpath')),'TimeSeries_Pollution');
    folderFigures         = fullfile( fileparts(mfilename('fullpath')),'Figures');
    folderResults         = fullfile( fileparts(mfilename('fullpath')),'Results');
    folderFactorLevelComb = fullfile( fileparts(mfilename('fullpath')),'TablesFactorsAndLevels');

    path( folderFunctions       , path );
    path( folderTimeSeries      , path );
    path( folderFigures         , path );
    path( folderResults         , path );
    path( folderFactorLevelComb , path );

    %% PARAMETERS       =====================================================================

    parameters.debugging    = 0;   % 0/1/2
    parameters.parallelWork = 1;   % parallelWork = 1; 
    parameters.GpuWork      = 0;   % GpuWork      = 1; 
    % -----------------
    parameters.FLCombinations = FLCombinations;  
            % 0 (default value) => 'factorLevelsTable_Pollution_Tinny.txt'   
            % 1                 => 'factorLevelsTable_Pollution_L50_v01.txt'; 
            % 2                 => 'factorLevelsTable_Pollution_StepWise.txt'
            % 3                 => 'factorLevelsTable_Pollution_FullFactorial.txt' 
    % ------------------
    parameters.tsTypesCellArray = { 'raw', 'dif' , 'inc' };
    %parameters.tsTypesCellArray = { 'inc' };
    % ------------------
    parameters.tsFolder                     = folderTimeSeries;     % = 'Timeseries';

    % ------------------
    parameters.folderAllResults             = 'Results_ALL';
    parameters.resultsFolderPrefix          = 'Results_';
    parameters.resultsFilesPrefix           = 'results_'; 
    parameters.fileExtensionResults         = 'dat';
    parameters.fileExtensionResultsBinary   = 'mat';
    parameters.tsFilesPrefix                = 'ts-';
    parameters.tsFilesExtension             = 'csv';
    parameters.filesOfResGenComplete        = '00_results_all.dat'; 
    parameters.filesOfResGenCompleteMat     = 'expResultsAll.mat'; 
    parameters.logFilePrefix                = 'aa_execlogFile_';

    % ------------------
    % Num initializations 
    if ( parameters.debugging == 2 )
        parameters.numInitializations = 3;

    elseif ( parameters.debugging == 1 )
        parameters.numInitializations = 2;


    elseif ( parameters.debugging == 0 )
        %parameters.numInitializations = 10;
        %parameters.numInitializations = 5;
        parameters.numInitializations = 10;

    end
    % ------------------------------------
    % Factor Level Comb Folder and Files 
    parameters.folderFactorLevelComb = folderFactorLevelComb;
    parameters.fileFactorLevelCombination = 'factorLevelsTable_Pollution_Tinny.txt';

    %% FACTOR LEVEL COMBINATIONS ===================================================

    % fileFactorLevelCombination = 'factorLevelsTable_L16x2_v01.txt';    % FOR IWANN2017  
    % fileFactorLevelCombination = 'factorLevelsTable_FF_v01.txt';       % FOR IWANN2017  + FULL FACTORIAL

    if ( parameters.debugging == 2 )
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_L50_debugging_v00.txt';  % For debugging    
        % parameters.fileFactorLevelCombination = 'factorLevelsTable_Pollution_Tinny.txt';   % For debugging    
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_Tinny.txt';   % For debugging    
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_StepWise_short.txt';   % For debugging
        fileFactorLevelCombination = 'factorLevelsTable_Pollution_L50_v01.txt';

        parameters.folderAllResults             = 'Results_ALL';
        parameters.resultsFolderPrefix          = 'Results_';



    elseif ( parameters.debugging == 1 )

        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_L50_debugging_v01.txt';  % For debugging
        % parameters.fileFactorLevelCombination = 'factorLevelsTable_Pollution_Tinny.txt';   % For debugging    
        fileFactorLevelCombination = 'factorLevelsTable_Pollution_StepWise_short.txt';   % For debugging    

        parameters.folderAllResults             = 'Results_ALL';
        parameters.resultsFolderPrefix          = 'Results_';

    elseif ( parameters.debugging == 0 )

        % fileFactorLevelCombination = 'factorLevelsTable_L16x2_v01.txt';        % For experimentation
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_L50_v01.txt';  % For experimentation
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_FullFactorial.txt';
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_StepWise.txt';
        fileFactorLevelCombination = 'factorLevelsTable_Pollution_L50_v01.txt';

        switch parameters.FLCombinations
            case 0
                strFLCom = 'Tinny';
            case 1
                strFLCom = 'L50_v01';
            case 2
                strFLCom = 'StepWise';
            case 3 
                strFLCom = 'FullFactorial';
        end

        parameters.folderAllResults             = strcat('Results_',strFLCom,'_ALL');
        parameters.resultsFolderPrefix          = strcat('Results_',strFLCom,'_');
        fileFactorLevelCombination              = strcat('factorLevelsTable_Pollution_',strFLCom,'.txt');



        % parameters.fileFactorLevelCombination = 'factorLevelsTable_Pollution_FullFactorial.txt';
        % parameters.fileFactorLevelCombination = 'factorLevelsTable_Pollution_StepWise.txt';
        % parameters.fileFactorLevelCombination = 'factorLevelsTable_Pollution_L50_v01.txt';

    end
    % ---------------------------------------
    fileFactorsLevelsCombination = fullfile(folderFactorLevelComb, fileFactorLevelCombination); 
    %% NAMES OF THE TIME SERIES 2017 - 07
    % tsOriginalDataFileRoot       = 'PC_08_SC_28079050_D_F03'; 
    % tsOriginalDataFileRoots       = {'PC_08_SC_28079050_D_F03' , 'PC_09_SC_28079050_D_F03'};

    % tsOriginalDataFileRoots       = {'PC_08_SC_28079050_D_F03', ...
    %                                  'PC_09_SC_28079050_D_F03', ... 
    %                                  'PC_08_SC_28079056_D_F03', ... 
    %                                  'PC_14_SC_28079056_D_F03'};


    % ts_PC_08_SC_28079050_D_F03.dat
    % ts_PC_08_SC_28079056_D_F03.dat
    % ts_PC_09_SC_28079050_D_F03.dat
    % ts_PC_14_SC_28079056_D_F03.dat

    % ts_PC_08_SC_28079050_H_F03.dat
    % ts_PC_08_SC_28079056_H_F03.dat
    % ts_PC_09_SC_28079050_H_F03.dat
    % ts_PC_14_SC_28079056_H_F03.dat

    % filenamesInitData  = {  'ts_PC_08_SC_28079050_D_F03.dat';...
    %                         'ts_PC_08_SC_28079056_D_F03.dat';...
    %                         'ts_PC_09_SC_28079050_D_F03.dat';...
    %                         'ts_PC_14_SC_28079056_D_F03.dat'};
    % 
    % tsnames  = {'PC_08_SC_28079050_D_F03';...
    %             'PC_08_SC_28079056_D_F03';...
    %             'PC_09_SC_28079050_D_F03';...
    %             'PC_14_SC_28079056_D_F03'};
    %        
    % 
    % filenamesInitData  = {  'ts_PC_08_SC_28079050_H_F03.dat';...
    %                         'ts_PC_08_SC_28079056_H_F03.dat';...
    %                         'ts_PC_09_SC_28079050_H_F03.dat';...
    %                         'ts_PC_14_SC_28079056_H_F03.dat'};
    % 
    % tsnames  = {'PC_08_SC_28079050_H_F03';...
    %             'PC_08_SC_28079056_H_F03';...
    %             'PC_09_SC_28079050_H_F03';...
    %             'PC_14_SC_28079056_H_F03'};

    %% NAMES OF THE TIME SERIES 2017 - 11  

    if ( parameters.debugging == 2 )

        tsOriginalDataFileRoots       = {'NO2-FedzLadreda-16-12'};

        %tsOriginalDataFileRoots       = {'NO2-FedzLadreda-16-12', ...
        %                                 'NO2-PzCastilla-16-10' , };


    elseif ( parameters.debugging == 1 )
        tsOriginalDataFileRoots       = {'NO2-FedzLadreda-16-12', ...
                                         'NO2-PzCastilla-16-10',...
                                         'O3-JuanCarlosI-16-07', ... 
                                         'PM25-MendezAlvaro-16-10'};

    elseif ( parameters.debugging == 0 )

        tsOriginalDataFileRoots = {'NO2-FedzLadreda-16-12', ...
                                   'NO2-PzCastilla-16-10', ... 
                                   'O3-JuanCarlosI-16-07', ... 
                                   'PM25-MendezAlvaro-16-10'};

    %      tsOriginalDataFileRoots = {'Dowjones', ...
    %                                 'Mackeyglass01', ... 
    %                                 'Quebec', ... 
    %                                 'Temperature'};

    end




    % Note: the name of the time series will be: 
    %                                            ts-tsOriginalDataFileRoots{i}.csv                             
    %                                            ts-tsOriginalDataFileRoots{i}-raw.csv                             
    %                                            ts-tsOriginalDataFileRoots{i}-dif.csv                             
    %                                            ts-tsOriginalDataFileRoots{i}-ind.csv                             


     %% PARALELL TOOLBOX 
        fprintf('\nCheck Parallel Poll \n');
        % --------------------------------
        %parameters.parallelWork = 0;  % parameters.parallelWork = 1; 

        if ( parameters.parallelWork == 1 )
            % delete(gcp('nocreate'));    % delete(gcp)

            p = gcp('nocreate');
            if isempty(p)
                % WINDOWS
                % parpool('local',2);  % parpool(2) 
                % JUNO -> Linux
                % parpool('local',16); % parpool(16) 
                % GENERAL
                presentCluster  = parcluster();
                nWorkersMax     = presentCluster.NumWorkers;
                % ---------------------------------------        
                % nWorkers = fix( nWorkersMax * 0.7 );
                % nWorkers = ceil( nWorkersMax * 1 );
                nWorkers = nWorkersMax;        

                parpool( 'local' , nWorkers ); 
            else
                nWorkers = p.NumWorkers;
            end

            fprintf( '\nnWorkers: %d\n' , nWorkers );

            % ---------------------------------------
            % if nWorkers <= 12 
            %    parpool('local',nWorkers); 
            % else
            %    % parpool('local',nWorkers); 
            %    parpool('local',nWorkers - 1);         
            % end
        elseif ( parameters.parallelWork == 0 )
            delete(gcp('nocreate'));
        end


    %% 
    initTotalTime = tic; 
    % func_02_executeExperiments_ANN4TS_v03( parameters ,  fileFactorsLevelsCombination , tsOriginalDataFileRoots  ); 
    expResults = func_02_executeExperiments_ANN4TS_v04( parameters ,  fileFactorsLevelsCombination , tsOriginalDataFileRoots  ); 

    fprintf('\n\ntotal time : %d s\n',toc(initTotalTime)); clear initTotalTime;
    
    error = 0;

end