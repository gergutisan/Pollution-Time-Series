function [ filenamesInitData , tsnames ] = readAndGetFilenameTimeSeries ( folder_TS,  regExp )

    % parameter.folder_TS 
    % parameter.regExp4TsFile
      
    
    % dir or ls the content of the folder and Read the folder 
    
    % content = dir(fullfile( folder_TS , 'ts-*.csv' ) );
    content = dir(fullfile( folder_TS , regExp ) );
    
    counter = 0;
    for i = 1:numel(content)
        if (content(i).isdir == 0 ) % The content element is a file 
            
            counter = counter + 1;
            filenamesInitData(counter,1) = string( content(i).name  );
            
            % 'ts-02-annual-common-stock-price-us-187.csv' --> '02-annual-common-stock-price-us-187'
            tsnames(counter,1) = string( content(i).name(4:(end-4)) );
            
            
        end
       
    end
    


end