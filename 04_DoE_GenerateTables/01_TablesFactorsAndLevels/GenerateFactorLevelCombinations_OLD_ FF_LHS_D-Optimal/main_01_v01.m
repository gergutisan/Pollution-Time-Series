%%  Sources: 
%           https://es.mathworks.com/help/stats/lhsdesign.html

%% RESET    ==================================================================================
clear; clc; close all; fclose('all');


%% PARAMETERS 
filename = 'factorLevel_Combinations_Pollution.txt';

delete(filename);

%% FULL FACTORIAL COMBINATIONS     ==========================================================
% factorsLevels_v01  = {  [1 2 3 4 5 6 ] , ...
%                         [1 2 3 4 5 6 7 8 9 10 11 12] , ...
%                         [1 2 3] , ...
%                         [1 2 3] , ...
%                         [1 2 3] };  
factorsLevels_v01  = {  [01 02 03 ] , ...
                        [01 02 03 04 05] , ...
                        [01 02]    , ...
                        [01 02 03] , ...
                        [01 02 03] }; 
% THIS DOES NOT WORK
% factorsLevels_v01  = {  ["A" "B" "C" ] , ...
%                         ["A" "B" "C" "D" "E"] , ...
%                         ["A" "B"]    , ...
%                         ["A" "B" "C"] , ...
%                         ["A" "B" "C"] };     

levels = zeros(1, numel(factorsLevels_v01));
for i = 1:numel(factorsLevels_v01)
    levels(i) = numel( factorsLevels_v01{i} );
end
table_FF = fullfact(levels);



fprintf('FULL FACTORIAL design  ---- \n')
printMatrix2Screen ( table_FF )

msg = strcat ( 'FULL FACTORIAL design - \ ', num2str(size(table_FF,1), ' %04d'), ' runs');
printMatrix2File(table_FF, filename , msg);


%% Latin hypercube sample    =================================================================

% iteratively generates latin hypercube samples to find the best one according to criterion, 
% which can be 'none'(no iteration), 'maximin' (Maximize minimum distance between points. 
% This is the default.), or 'correlation' (reduce correlation).


levels    = 6; % levels = 12;
nFactors   = 5;
criterion = 'correlation';
k         = 50; % iterations to try to acomplsih the criterios 

LHS_table = lhsdesign(levels, nFactors , ...
                  'smooth',    'on', ...
                  'criterion',  criterion,...
                  'iterations', k);

LHS_table = fix(LHS_table * levels) + 1;              
   
fprintf('LHS sample  design  ---- \n')
%printMatrix2Screen(LHS_table);

msg = strcat ( 'LHS sample design - ', num2str(size(LHS_table,1), ' %04d'), ' runs');
printMatrix2File(LHS_table, filename , msg );

%% Taguchi design with rowexch   ==========================================================

% Source: https://es.mathworks.com/help/stats/rowexch.html
% https://en.wikipedia.org/wiki/Orthogonal_array
% strength-(nLevels, nFactors, index)   => (e.g)  2 -( 12 , 5 , 1 ) 

% Bounds of the factor level:  lowest <-1 ; greatest <- num of Levels
% bounds = [01 01 01 01 01; ...    
%           06 12 03 04 04];
% 
% factorsLevels_v01  = {  [01 02 03 04 05 06 ] , ...
%                         [01 02 03 04 05 06 07 08 09 10 11 12] , ...
%                         [01 02 03] , ...
%                         [01 02 03] , ...
%                         [01 02 03] };  

% Bounds of the factor level:  lowest <-1 ; greatest <- num of Levels
% bounds = [01 01 01 01 01; ...    
%           06 12 03 04 04];

% % strength-(nLevels, nFactors, index)  ---------------------------- 
% strength = 2;                
% index    = 2;                
% nFactors = 5;
% nLevels  = [ 6 , 12 , 3 , 3 , 3];
% 

% factorsLevels_v01  = {  [01 02 03 ] , ...
%                         [01 02 03 04 05] , ...
%                         [01 02]    , ...
%                         [01 02 03] , ...
%                         [01 02 03] };  
                    
% factorsLevels_v01  = {  ["A" "B" "C" ] , ...
%                         ["A" "B" "C" "D" "E"] , ...
%                         ["A" "B"]    , ...
%                         ["A" "B" "C"] , ...
%                         ["A" "B" "C"] };     
%                     
%  strength-(nLevels, nFactors, index)  ---------------------------- 
strength = 1;                
index    = 3;                
nFactors = 5;
nLevels  = [ 3 , 5 , 2 , 3 , 3];
% nruns  = index (lambda) * nLevels^strength   % (index is lambda)
nruns    = index * (max(nLevels)^strength);     % Runs = index (lambda) * nLevels^strength  
model    = 'linear';
[dRE] = rowexch( nFactors , nruns, model, 'cat' , 1:nFactors , 'bounds', factorsLevels_v01 ,  'tries' , 100 );


% -------------------------------------
% [dRE_B,X] = rowexch( nFactors , nruns, model, 'cat' , 1:nFactors , 'levels', [ 6 12 03 04 04 ] ,  'tries' , 100 );
% fprintf('D-optimal design  BBBB---- \n')
% printMatrix2Screen(dRE_B);
% msg = 'D-optimal design BBBB';
% printMatrix2File(dRE_B, filename , msg );
% ------------------------------------

fprintf('D-optimal design Sorted  ---- \n')
% Then sort rows 
dRESort = sortrows(dRE);
%printMatrix2Screen(dRESort);
msg = strcat ( 'D-optimal design Sort -\ ', num2str(nruns, ' %04d'), ' runs');
printMatrix2File(dRESort, filename ,  msg );

%% LOCAL FUNCTIONS   ===========================================================================

%% Print Matrix  Screen       -----------------------------------------
function printMatrix2Screen ( matrix )

    r = size(matrix,1); 
    c = size(matrix,2);
    for i = 1:r 
        for j = 1:c
            fprintf( ' %5d' , matrix( i , j ) );

        end
        fprintf('\n')
    end
    fprintf('\n')

end


%% Print Matrix         -----------------------------------------
function printMatrix2File ( matrix , filename , msg )
    
    fId = fopen(filename, 'a');

    if ( fId >=3 )
        
        fprintf(fId , '%s\n' , msg );
        
        r = size(matrix,1); 
        c = size(matrix,2);
        for i = 1:r 
            for j = 1:c
                fprintf(fId , ' %5d' , matrix( i , j ) );
            end
            fprintf(fId , '\n');
        end
        fprintf(fId , '\n\n')
        fclose(fId);
    end

end