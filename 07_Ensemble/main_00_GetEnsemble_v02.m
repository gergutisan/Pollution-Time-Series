%% RESET        =============================================================
recycle('on');
close all; fclose('all'); clc; 
% clear; 
clearvars -except doeResults;

% THIS FILE CALL SEVERAL TIMES main_01_GetEnsemble_v02, 
% so, they share the workspace;

%% PARAMETERS 
folderResultsEnsemble        = fullfile( fileparts(mfilename('fullpath')),'Results_Ensemble');
folderResultsEnsembleBackups = fullfile( fileparts(mfilename('fullpath')),'Results_Ensemble_Backup');
folderFigures          = fullfile( fileparts(mfilename('fullpath')),'Figures');

parameters.iTerDoE     = 4;
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

%% DELETE PREVIOUS INFORMATION ==========================

delete(fullfile(folderFigures,'*.*'));
rmdir(folderFigures,'s'); mkdir(folderFigures);
delete(fullfile(folderResultsEnsemble,'*.*'));
% delete(fullfile(folderResultsEnsembleBackups,'*.*'));
delete('listOptions.txt');

%% ====================================================
paramSet = 0;
fId0 = fopen('listOptions.txt','w'); 
if (fId0 < 3) 
    return;
else 
    fprintf(fId0,'%20s %20s %30s \n', ...
                      'incRound', 'bestByRMSE', 'ensembleCombination' );
end

for incRound   = 0:1
for bestByRMSE = 0:1
    paramSet = paramSet + 1;
    strparamSet = num2str(paramSet,'%02d');
    for ensembleCombination = [ 12 13 23 123]   
        
        strEnsembleCombination = num2str(ensembleCombination,'%03d');

        parameters.bestByRMSE          = bestByRMSE; 
        parameters.bestBySMAPE         = ~bestByRMSE;
        parameters.ensembleCombination = ensembleCombination;
        parameters.incRound            = incRound;  % 1/0

        %%

        fprintf(fId0,'%20d %20d %30d \n', ...
                      incRound, bestByRMSE, ensembleCombination );

        %%     ------------------------------------
        
        matFileResEnsemble = strcat(matFileResEnsemblePrefix,'_',strparamSet,'_',strEnsembleCombination,'.mat');

        subFix = 01;
        while ( exist(fullfile(folderResultsEnsemble,matFileResEnsemble)) == 2 )
            subFix = subFix + 1;
            strsubFix = num2str(subFix,'%02d');
            matFileResEnsemble = strcat(matFileResEnsemblePrefix,'_',strparamSet,'_',strEnsembleCombination,'_',strsubFix,'.mat');
        end

        %%     ------------------------------------
        main_01_GetEnsemble_v02;   %-> get array struct ensembleResults
        
        switch ensembleCombination
            case 12
                indexEnsembleCombination = 1;
            case 13
                indexEnsembleCombination = 2;    
            case 23
                indexEnsembleCombination = 3;    
            case 123
                indexEnsembleCombination = 4;            
        end
        allEnsembleResults( paramSet , indexEnsembleCombination ) = ensembleResults;

        fprintf('%-40s %5d\n' , 'parameters.incRound'            , parameters.incRound    );
        %fprintf('Program Paused. Press any key ... '); pause(); 
        fprintf('\n');

        %% Make a copy of the figures 
        strparamSet = num2str(paramSet,'%02d');
        folderFigures2CopyPrefix  = 'Figures';
        FolderFigures2Copy = strcat(folderFigures2CopyPrefix ,'_',strparamSet,'_',strEnsembleCombination);
        subFix = 01;
        while ( exist(fullfile(folderFigures,FolderFigures2Copy)) == 7 )
            subFix = subFix + 1;
            strsubFix = num2str(subFix,'%02d');
            FolderFigures2Copy = strcat(folderFigures2CopyPrefix,'_',strparamSet,'_',strEnsembleCombination,'_',strsubFix);
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
end
end    
fclose(fId0);

printResultTable

