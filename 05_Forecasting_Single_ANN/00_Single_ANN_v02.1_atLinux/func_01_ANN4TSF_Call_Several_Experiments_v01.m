function error = func_01_ANN4TSF_Call_Several_Experiments_v01 ( parameters )
    %% LINKS  ----------------------------------------------------------
    % https://icme.hpc.msstate.edu/mediawiki/index.php/MATLAB_Tutorials
    % http://datos.gob.es/recurso/sector-publico/org/Organismo/L01280796
    % Calidad del aire. Tiempo real
    %    http://datos.madrid.es/egob/catalogo/212531-7916318-calidad-aire-tiempo-real.txt

    %% INIT       ==========================================================================
    error = 1;

    %% PARAMETERS       =====================================================================
    

   
    % ------------------------------------
    % Factor Level Comb Folder and Files 
    parameters.folderFactorLevelComb = folderFactorLevelComb;
    % default value 
    parameters.fileFactorLevelCombination = 'factorLevelsTable_Pollution_Tinny.txt';

    %% FACTOR LEVEL COMBINATIONS ===================================================

    % ------------------------------------------
    % fileFactorLevelCombination = 'factorLevelsTable_L16x2_v01.txt';    % FOR IWANN2017  
    % fileFactorLevelCombination = 'factorLevelsTable_FF_v01.txt';       % FOR IWANN2017  + FULL FACTORIAL
    % ------------------------------------------
    

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
        fileFactorLevelCombination = 'factorLevelsTable_Pollution_StepWise_short.txt';       

        parameters.folderAllResults             = 'Results_ALL';
        parameters.resultsFolderPrefix          = 'Results_';

    elseif ( parameters.debugging == 0 )

        % fileFactorLevelCombination = 'factorLevelsTable_L16x2_v01.txt';        % For experimentation
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_L50_v01.txt';  % For experimentation
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_FullFactorial.txt';
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_StepWise.txt';
        % fileFactorLevelCombination = 'factorLevelsTable_Pollution_L50_v01.txt';

        strFLCom = 'Tinny'; % default value
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
    parameters.fileFactorLevelCombination = fileFactorsLevelsCombination;
    
    %% NAMES OF THE TIME SERIES 2017 07 ====================================================
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

    %% NAMES OF THE TIME SERIES 2017 - 11   ============================

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


    %% CALL TO EXECUTE ALL THE EXPERIMENTATION ==================================
    initTotalTime = tic; 
    
    % func_02_executeExperiments_ANN4TS_v03( parameters ,  fileFactorsLevelsCombination , tsOriginalDataFileRoots  ); 
    expResults = func_02_executeExperiments_ANN4TS_v04( parameters ,  fileFactorsLevelsCombination , tsOriginalDataFileRoots  ); 

    fprintf('\n\ntotal time : %d s\n',toc(initTotalTime)); clear initTotalTime;
    
    error = 0;
    
    %% STOP PARALLEL POOL    ======================================================
    
    if ( parameters.parallelWork == 1 )
        p = gcp('nocreate');
        if ( ~isempty(p) )
            delete(gcp);
        end
    end
    % -----------------------------------


end