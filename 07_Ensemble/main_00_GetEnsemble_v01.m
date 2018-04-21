%% RESET        =============================================================
close all; fclose('all'); clc; 
% clear; 
clearvars -except doeResults;

% THIS FILE CALL SEVERAL TIMES main_01_GetEnsemble_v02, 
% so, they share the workspace;

%% PARAMETERS 
folderResultsEnsemble  = fullfile( fileparts(mfilename('fullpath')),'Results_Ensemble');
folderFigures          = fullfile( fileparts(mfilename('fullpath')),'Figures');

parameters.iTerDoE     = 1;
parameters.incRound    = 0;  % 1/0
parameters.bestByRMSE  = 0;  % 1/0
parameters.bestBySMAPE = 1;  % 0/1 
parameters.ensembleCombination =  12;  % -> values: [1 2 3] 12 23 13 123

parameters.testPrct  = 0.15;
parameters.valPrct   = 0.15;
parameters.trainPrct = 0.7;

matFileResEnsemblePrefix = 'matFileResEnsemble'; 
folderFigures2CopyPrefix  = 'Figures';
num = 1;

paramSet = 0;

for incRound = 1:-1:0
    
    paramSet = paramSet + 1;
    parameters.incRound  = incRound;  % 1/0

     %%     ------------------------------------
    strparamSet = num2str(paramSet,'%02d');
    matFileResEnsemble = strcat(matFileResEnsemblePrefix,'_',strparamSet,'.mat');

    subFix = 01;
    while ( exist(fullfile(folderResultsEnsemble,matFileResEnsemble)) == 2 )
        subFix = subFix + 1;
        strsubFix = num2str(subFix,'%02d');
        matFileResEnsemble = strcat(matFileResEnsemblePrefix,'_',strparamSet,'_',strsubFix,'.mat');
    end

    %%     ------------------------------------
    main_01_GetEnsemble_v02

    fprintf('%-40s %5d\n' , 'parameters.incRound'            , parameters.incRound    );
    %fprintf('Program Paused. Press any key ... '); pause(); 
    fprintf('\n');
    
    %% Make a copy of the figures 
    strparamSet = num2str(paramSet,'%02d');
    folderFigures2CopyPrefix  = 'Figures';
    FolderFigures2Copy = strcat(folderFigures2CopyPrefix ,'_',strparamSet);
    subFix = 01;
    while ( exist(fullfile(folderFigures,FolderFigures2Copy)) == 7 )
        subFix = subFix + 1;
        strsubFix = num2str(subFix,'%02d');
        FolderFigures2Copy = strcat(folderFigures2CopyPrefix,'_',strparamSet,'_',strsubFix);
    end    
    mkdir(fullfile(folderFigures,FolderFigures2Copy));
    
    source      = fullfile(folderFigures,'*.fig');
    destination = fullfile(folderFigures,FolderFigures2Copy);
    copyfile(source, destination);
    movefile(source, destination);

    source      = fullfile(folderFigures,'*.png');
    destination = fullfile(folderFigures,FolderFigures2Copy);
    copyfile(source, destination);
    movefile(source, destination);
    
    close('all');
    
end    

