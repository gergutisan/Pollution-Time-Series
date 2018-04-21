clc;clearvars -except doeResults;

parameters.ResultsEnsemblesFilename = 'resultsEnsembles.txt';

folderResultsEnsemble        = 'Results_Ensemble';
folderResultsEnsembleBackup  = 'Backup';

path( fullfile(folderResultsEnsemble,folderResultsEnsembleBackup) , path );

folder = fullfile(folderResultsEnsemble,folderResultsEnsembleBackup);
num = 1;
backupFilename = strcat( 'backup' , num2str(num,'%02d') , parameters.ResultsEnsemblesFilename);
while ( exist(fullfile(folder,backupFilename)) == 2 )
    num = num + 1;
    backupFilename = strcat('backup',num2str(num,'%02d'),parameters.ResultsEnsemblesFilename);
end

source = fullfile(folderResultsEnsemble,parameters.ResultsEnsemblesFilename);
destination = fullfile(folder,backupFilename);
copyfile(source, destination);
