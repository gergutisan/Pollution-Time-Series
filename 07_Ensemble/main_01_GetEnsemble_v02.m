% %% RESET        =============================================================
% close all; fclose('all'); clc; 
% % clear; 
% clearvars -except doeResults matFileResEnsemble;

%% SET FOLDERs AND PATH     ===============================================================
cd(fileparts(mfilename('fullpath')));    % does not work if executed by Run Section [and advance]
folderFunctions       = fullfile( fileparts(mfilename('fullpath')),'Functions');
folderTimeSeries      = fullfile( fileparts(mfilename('fullpath')),'TimeSeries');
folderFigures         = fullfile( fileparts(mfilename('fullpath')),'Figures');
folderResultsDoE      = fullfile( fileparts(mfilename('fullpath')),'Results_DoE');
folderResultsEnsemble  = fullfile( fileparts(mfilename('fullpath')),'Results_Ensemble');
folderResultsEnsembleBackup  = fullfile( fileparts(mfilename('fullpath')),'Results_Ensemble_Backup');
folderFactorLevelComb = fullfile( fileparts(mfilename('fullpath')),'TablesFactorsAndLevels');

path( folderFunctions       , path );
path( folderTimeSeries      , path );
path( folderFigures         , path );
path( folderResultsDoE      , path );
path( folderResultsEnsemble  , path );
path( folderResultsEnsembleBackup , path );
path( folderFactorLevelComb , path );

%% PARAMETERS       =======================================================

parameters.ResultsEnsemblesFilename = 'resultsEnsembles.txt';

parameters.debugging   = 0;  % 1/0

%parameters.doeResultsFilename = 'expResultsAll_00.mat'; 
parameters.doeResultsFilename = 'expResultsAll_01.mat'; 

tsNamesCellArray = {'NO2-FedzLadreda-16-12' , ...
                    'NO2-PzCastilla-16-10'  , ...
                    'O3-JuanCarlosI-16-07'  , ... 
                    'PM25-MendezAlvaro-16-10'};

% parameters.iTerDoE     = 1;
% parameters.incRound    = 0;  % 1/0
% parameters.bestByRMSE  = 0;  % 1/0
% parameters.bestBySMAPE = 1;  % 0/1 
% parameters.ensembleCombination =  12;  % -> values: 1 2 3 12 23 13 123
% 
% parameters.testPrct  = 0.15;
% parameters.valPrct   = 0.15;
% parameters.trainPrct = 0.7;



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

ensembleResults = func_01_GetEnsemble( tsNamesCellArray, parameters , doeResults , parameters.iTerDoE );
fprintf('\nEnsemble Computed\n');

%% Save Ensemble Results    ==============================================================

save(fullfile(folderResultsEnsemble,matFileResEnsemble),'ensembleResults' );

%% Show results of the ensemble   ========================================================

fId = fopen(fullfile(folderResultsEnsemble, ...
                     parameters.ResultsEnsemblesFilename), 'a' );
if fId < 3 
    fprintf('\nerror openning the file %s \n', parameters.ResultsEnsemblesFilename);
    return;
end

fprintf(fId, '\n ------ \n');
% PRINT THE PARAMETERS 

fprintf(fId, '%-40s %5d\n', 'parameters.incRound ' , parameters.incRound );
fprintf(fId, '%-40s %5d\n', 'parameters.bestByRMSE ' , parameters.bestByRMSE );
fprintf(fId, '%-40s %5d\n', 'parameters.bestBySMAPE ' , parameters.bestBySMAPE );
fprintf(fId, '%-40s %5d\n', 'parameters.ensembleCombination ' , parameters.ensembleCombination );
fprintf(fId, '%-40s %5.2f\n', 'parameters.testPrct '  , parameters.testPrct );
fprintf(fId, '%-40s %5.2f\n', 'parameters.valPrct '   , parameters.valPrct );
fprintf(fId, '%-40s %5.2f\n', 'parameters.trainPrct ' , parameters.trainPrct );
fprintf(fId, '\n');

fprintf(fId, '\n (ValErr) RawModel DifModel IncModel EnsembleW  (TestErr) RawModel DifModel IncModel EnsembleW \n');
fprintf('\n (ValErr) RawModel DifModel IncModel EnsembleW  (TestErr) RawModel DifModel IncModel EnsembleW \n');

nTsNames = numel(tsNamesCellArray);
fprintf(fId,'EnsembleWRmse --- \n');
fprintf('EnsembleWRmse --- \n');
for indexTsName = 1:nTsNames
    
    % Val Error each (raw, dif, inc) model 
    for iTsType = 1:3 
        fprintf(fId,' %10.3f ', ensembleResults.Elements_rmseVal( indexTsName , iTsType ) );
        fprintf( ' %10.3f ', ensembleResults.Elements_rmseVal( indexTsName , iTsType ) );
    end
    % Val Error Ensemble
    fprintf(fId,' %10.3f ',ensembleResults.rmseValEnsembleWRmse( indexTsName ) );
    fprintf(' %10.3f ', ensembleResults.rmseValEnsembleWRmse( indexTsName ) );
    
    
    % Test Error each (raw, dif, inc) model 
    for iTsType = 1:3 
        fprintf(fId,' %10.3f ', ensembleResults.Elements_rmseTest( indexTsName , iTsType ) );
        fprintf(' %10.3f ', ensembleResults.Elements_rmseTest( indexTsName , iTsType ) );
    end
    % Test Error Ensemble
    fprintf(fId,' %10.3f ',ensembleResults.rmseTestEnsembleWRmse( indexTsName ) );
    fprintf(' %10.3f ', ensembleResults.rmseTestEnsembleWRmse( indexTsName ) );
    
    fprintf(fId,'\n');
    fprintf('\n');
end
% --------------------------------------

fprintf(fId,'EnsembleWSmape --- \n');
fprintf('EnsembleWSmape --- \n');
for indexTsName = 1:nTsNames
    
    % Val Error each (raw, dif, inc) model 
    for iTsType = 1:3 
        fprintf(fId,' %10.3f ', ensembleResults.Elements_rmseVal( indexTsName , iTsType ) );
        fprintf(' %10.3f ', ensembleResults.Elements_rmseVal( indexTsName , iTsType ) );
    end
    fprintf(fId,' %10.3f ',ensembleResults.rmseValEnsembleWSmape( indexTsName ) );
    fprintf(' %10.3f ', ensembleResults.rmseValEnsembleWSmape( indexTsName ) );
    
    % Test Error each (raw, dif, inc) model 
    for iTsType = 1:3 
        fprintf(fId,' %10.3f ', ensembleResults.Elements_rmseTest( indexTsName , iTsType ) );
        fprintf(' %10.3f ', ensembleResults.Elements_rmseTest( indexTsName , iTsType ) );
    end
    fprintf(fId,' %10.3f ',ensembleResults.rmseTestEnsembleWSmape( indexTsName ) );
    fprintf(' %10.3f ', ensembleResults.rmseTestEnsembleWSmape( indexTsName ) );
    
    fprintf(fId,'\n');
    fprintf('\n');
    
end

fclose(fId);


%% ---------------------------------------
clc;


%parameters.ResultsEnsemblesFilename = 'resultsEnsembles.txt';
%folderResultsEnsemble        = 'Results_Ensemble';
%folderResultsEnsembleBackup  = 'Backup';

folder = folderResultsEnsembleBackup;
num = 1;
backupFilename = strcat( 'bu_' , num2str(num,'%02d_') , parameters.ResultsEnsemblesFilename);
while ( exist(fullfile(folder,backupFilename)) == 2 )
    num = num + 1;
    backupFilename = strcat('bu_',num2str(num,'%02d_'),parameters.ResultsEnsemblesFilename);
end

source = fullfile(folderResultsEnsemble,parameters.ResultsEnsemblesFilename);
destination = fullfile(folder,backupFilename);
copyfile(source, destination);




