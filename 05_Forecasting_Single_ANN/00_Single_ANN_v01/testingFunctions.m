%% RESET            =========================================================================
clear; clc; close('all'); fclose('all'); 
% clearvars -EXCEPT ....

%% ---------------------------------------------------------------------------
folderFunctions   = fullfile( fileparts(mfilename('fullpath')),'Functions');
folderParameters  = fullfile( fileparts(mfilename('fullpath')),'Parameters');
path( folderFunctions  , path );
path( folderParameters  , path );

filename       = fullfile( folderParameters, 'parameters_00.txt' );
[ parameters ] = readANNParam( filename );