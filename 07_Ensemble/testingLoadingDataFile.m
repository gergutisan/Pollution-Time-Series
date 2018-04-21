
folderResultsDoE = fullfile( fileparts(mfilename('fullpath')),'Results_DoE');

parameters.doeResultsFilename = 'expResultsAll_01.mat'; 

initTimeTic = tic;
initCpuTime = int64(cputime);
fprintf('Loading %s ...', fullfile( folderResultsDoE ,parameters.doeResultsFilename) );

S = load( fullfile( folderResultsDoE ,parameters.doeResultsFilename) );

intermediateTimeTic     = toc(initTimeTic);
intermediateTimeCpuTime = int64(cputime) - initCpuTime;
tempCpuTime = int64(cputime);

fprintf('\n %s loaded\n', fullfile( folderResultsDoE ,parameters.doeResultsFilename) );
fprintf('%-30s %10.3f\n', 'intermediateTimeTic'     , intermediateTimeTic     );
fprintf('%-30s %10.3f\n', 'intermediateTimeCpuTime' , intermediateTimeCpuTime );

fprintf('Copying %s ...', 'S.expResults');
doeResults = S.expResults; clear S;

finalTimeTic     = toc(initTimeTic) - intermediateTimeTic;
finalTimeCpuTime = int64(cputime) - tempCpuTime;

fprintf('\n %s copied\n', 'S.expResults');
fprintf('%-30s %10.3f\n'   , 'finalTimeTic'            , finalTimeTic     );
fprintf('%-30s %10.3f\n'   , 'intermediateTimeCpuTime' , finalTimeCpuTime );

