S = load( fullfile( folderResultsDoE ,doeResultsFilename) );
doeResults = S.expResults;



doeResults   
     doeResults{ row , iExp } 
          row: 1 2 3 4 are for the raw time series 
          row: 5 6 7 8 are for the dif time series 
          row: 9 10 11 12 are for the inc time series 
          
          each element contains all the results from the Factor&Level Combination

bestFLModelTable_v02

	contains the best model (based on SMAPE error ) from 
    each FactorLevel combination from a iteration of DoE experiment

ensembleElementsAllTsOneIter  <- bestFLModelTable_v02  
	contains the best model from each FactorLevel combination  
	from a iteration of DoE experiment ... 
	which turn into the elements of the ensemble for raw, dif and inc module


      
testTarget4RawData 

testForecast4RawData{ nTimeSeries , nTsTypes } 
      The test Forecast on original observation given 
      by each element of the ensemble
      
      rmseVal{  indexTsName , iTsType } 
      smapeVal{ indexTsName , iTsType } 
      
      rmseTest{  indexTsName , iTsType } 
      smapeTest{ indexTsName , iTsType } 
      
================================================================
    



================================================================

testTarget4RawData {  indexTsName } 


valForecast4RawData  {  indexTsName , iTsType }
testForecast4RawData {  indexTsName , iTsType }
      The test Forecast on original observation given 
      by each element of the ensemble


=================================================================


ensembleResults.ensembleElementsAllTsOneIter      

ensembleResults.Elements_valTarget4RawData  	% <- valTarget4RawData{indexTsName};
ensembleResults.Elements_testTarget4RawData     % <- testTarget4RawData{indexTsName};

ensembleResults.Elements_valForecast4RawData  	% <- valForecast4RawData{indexTsName , iTsType}
ensembleResults.Elements_testForecast4RawData 	% <- testForecast4RawData{indexTsName , iTsType};

ensembleResults.Elements_rmseVal   = rmseVal;   % <- Elements_rmseVal(  indexTsName , iTsType ) 
ensembleResults.Elements_rmseTest  = rmseTest;  % <- Elements_rmseTest( indexTsName , iTsType )
ensembleResults.Elements_smapeVal  = smapeVal;  % <- Elements_smapeVal( indexTsName , iTsType )
ensembleResults.Elements_smapeTest = smapeTest; % <- Elements_smapeTest( indexTsName , iTsType )

ensembleResults.weightsRmse = weightsRmse;
ensembleResults.weightsRmse = weightsSmape;

ensembleResults.ensembleWRmseValForecast  = ensembleValForecast;  %  <- ensembleValForecast{indexTsName}
ensembleResults.ensembleWRmseTestForecast = ensembleTestForecast;  %  <- ensembleTestForecast{indexTsName}

ensembleResults.rmseValEnsembleWRmse   = rmseValEnsemble;        % <- rmseValEnsemble(indexTsName)
ensembleResults.smapeValEnsembleWRmse  = smapeValEnsemble;       % <- smapeValEnsemble(indexTsName)
ensembleResults.rmseTestEnsembleWRmse  = rmseTestEnsemble;       % <- rmseTestEnsemble(indexTsName)
ensembleResults.smapeTestEnsembleWRmse = smapeTestEnsemble;      % <- smapeTestEnsemble(indexTsName)

ensembleResults.ensembleWSmapeValForecast  = ensembleValForecast;  %  <- ensembleValForecast{indexTsName}
ensembleResults.ensembleWSmapeTestForecast = ensembleTestForecast;  %  <- ensembleTestForecast{indexTsName}
ensembleResults.rmseValEnsembleWSmape   = rmseValEnsemble;        % <- rmseValEnsemble(indexTsName)
ensembleResults.smapeValEnsembleWSmape  = smapeValEnsemble;       % <- smapeValEnsemble(indexTsName)
ensembleResults.rmseTestEnsembleWSmape  = rmseTestEnsemble;       % <- rmseTestEnsemble(indexTsName)
ensembleResults.smapeTestEnsembleWSmape = smapeTestEnsemble;      % <- smapeTestEnsemble(indexTsName)    



Note: the time series data must be in it correspondent Folder (TimeSeries/)

