%% CLEAR -------------------------------------------------
clearvars -EXCEPT pollutionData % to be faster while debugging
clc; close all; fclose('all');


%% FOLDERS AND FILENAMES ---------------------------------
params.dailyDataFolder  = 'Data_Daily';
params.hourlyDataFolder = 'Data_Hourly';
params.rootAnioFolder   = 'Anio';
%% VARIABLES ---------------------------------------------
params.debuggingLevel = 5;

% params.monthsCellArray = { 'ene'}; params.yearsCellArray  = { 2012 };   
params.monthsCellArray = {  'ene','feb','mar',...
                            'abr','may','jun',...
                            'jul','ago','sep',...
                            'oct','nov','dic'};
params.yearsCellArray  = {2012,2013,2014,2015};
                        
                     


%% LOAD POLLUTION DATA 
% ---



%% PRIME ANALYSIS
% Note: the values withint pollutionData structure are number (not arrays of chars)
%       functions: unique, histc, accumarray
numAllMeasuresDay = numel(pollutionData);
vec = zeros(1,numAllMeasuresDay);
for index = 1:numAllMeasuresDay 
    vec(index) = pollutionData(index).codMeasure;
end;
measures = unique(vec); clear index
for i = 1:numel(measures)
    fprintf('codMeasure %3i\n',measures(i))
end;
clear i;
 





