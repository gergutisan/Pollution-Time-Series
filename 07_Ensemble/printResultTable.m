clc;
clearvars -except doeResults allEnsembleResults; 


folderResultsEnsembleBackups = fullfile( fileparts(mfilename('fullpath')),'Results_Ensemble_Backup');

path( folderResultsEnsembleBackups  , path );

subFix = 0;
tableResEnsembleFilenamePrefix = 'tableResEnsembleFilename';
num = 1;numStr = num2str(num,'%02d');
tableResEnsembleFilename = strcat(tableResEnsembleFilenamePrefix,'_',numStr,'.csv');
while ( exist(fullfile(folderResultsEnsembleBackups,tableResEnsembleFilename)) == 2 )
            num = num + 1; numStr = num2str(num,'%02d');
            tableResEnsembleFilename = strcat(tableResEnsembleFilenamePrefix,'_',numStr,'.csv');
end

fId = fopen(fullfile(folderResultsEnsembleBackups,tableResEnsembleFilename),'w');
if (fId < 3)
    fprintf('\nError opening file %s \n',tableResEnsembleFilename);
    return;
end

for iTs = 1:4
paramSet = 0;
for incRound   = 0:1
	for bestByRMSE = 0:1
		paramSet = paramSet + 1;
		for wRmse = 0:1
			% wSmape => ensembleWBySmape <- 0 => ensembleWByRmse <- 1;  
            fprintf('%3d%3d%3d', incRound, bestByRMSE, wRmse);
            fprintf( fId , '%3d%3d%3d', incRound, bestByRMSE, wRmse);
            

            for indexEnsembleCombination = 1:4
                ensembleResults = allEnsembleResults(paramSet,indexEnsembleCombination);

                % VALIDATION ERRORS 
                if ( indexEnsembleCombination == 1 )
                    % Parameters 	
                    fprintf('%3d%3d', ensembleResults.parameters.incRound, ...
                                       ensembleResults.parameters.bestByRMSE);
                    fprintf( fId , '%3d%3d', ensembleResults.parameters.incRound, ...
                                       ensembleResults.parameters.bestByRMSE);
                                   
                fprintf('%3d', wRmse);
                fprintf( fId , '%3d', wRmse);
                % if ( wSmape == 1 ) %% wRmse = 0
                %         fprintf('%3d', ~wSmape);	
                % else
                %         fprintf('%3d', wSmape);		
                % end	
                    % Val error for model raw, model dif and model inc	
                    fprintf('%8.3f', ensembleResults.Elements_rmseVal(iTs,1) );
                    fprintf('%8.3f', ensembleResults.Elements_rmseVal(iTs,2) );
                    fprintf('%8.3f', ensembleResults.Elements_rmseVal(iTs,3) );
                    
                    fprintf( fId , '%8.3f', ensembleResults.Elements_rmseVal(iTs,1) );
                    fprintf( fId , '%8.3f', ensembleResults.Elements_rmseVal(iTs,2) );
                    fprintf( fId , '%8.3f', ensembleResults.Elements_rmseVal(iTs,3) );
                    
                    
                end
                if (wRmse == 0)
                    err2show = ensembleResults.rmseValEnsembleWRmse(iTs);
                else
                    err2show = ensembleResults.rmseValEnsembleWSmape(iTs);
                end
                fprintf('%8.3f', err2show);
                fprintf( fId , '%8.3f', err2show);
                
                % TEST ERRORS 
                if ( indexEnsembleCombination == 1 )
                    % Parameters 	
                    %fprintf('%3d%3d', ensembleResults.parameters.incRound, ...
                    %                  ensembleResults.parameters.bestByRMSE);
                    % if ( wSmape == 1 ) %% wRmse = 0
                    %         fprintf('%3d', ~wSmape);	
                    % else
                    %         fprintf('%3d', wSmape);		
                    % end	
                    % Val error for model raw, model dif and model inc	
                    fprintf('%8.3f', ensembleResults.Elements_rmseTest(iTs,1) );
                    fprintf('%8.3f', ensembleResults.Elements_rmseTest(iTs,2) );
                    fprintf('%8.3f', ensembleResults.Elements_rmseTest(iTs,3) );
                    
                    fprintf( fId , '%8.3f', ensembleResults.Elements_rmseTest(iTs,1) );
                    fprintf( fId , '%8.3f', ensembleResults.Elements_rmseTest(iTs,2) );
                    fprintf( fId , '%8.3f', ensembleResults.Elements_rmseTest(iTs,3) );                    
                    
                end
                if (wRmse == 0)
                    err2show = ensembleResults.rmseTestEnsembleWRmse(iTs);
                else
                    err2show = ensembleResults.rmseTestEnsembleWSmape(iTs);
                end
                fprintf('%8.3f', err2show);
                fprintf( fId , '%8.3f', err2show);

            end
            fprintf('\n');
            fprintf( fId , '\n');
        end
    end
end
fprintf('\n');
fprintf( fId , '\n');
end


