
%% ADD THE FOLDER FOR FUNTIONS TO THE PATH --------------------
funcFolder = 'Functions';
fullFuncFolder = strcat(pathStr,'\',funcFolder); % [ pathStr, name , ext] = fileparts(mfilename('fullpath'));
path(fullFuncFolder, path);

%% 