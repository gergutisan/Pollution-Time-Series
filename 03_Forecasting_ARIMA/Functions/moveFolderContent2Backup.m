function moveFolderContent2Backup(folderFigures)
    % AIM ofthe function (to be completed)
    % Inputs (to be completed)

    % example ofthe calling:  moveFolderContent2Backup('Figures')
    
    % example : folderFigures <- 'Figures';
    
    folderBackupFigures = strcat(folderFigures,'_Backup');

    % Create/Reset the file for testing this source code
    fullFilename4Test = strcat(folderFigures,'\','prueba.txt');
    fId = fopen( fullFilename4Test,'w'); 
    fclose(fId);

    % ----------------------------------------------------------------------
    counter = 0;
    if ( exist( folderFigures,'dir') == 7 )
        % lets move its content ...

        % Check the folder name where folder content will be moved
        counter = counter + 1; 
        counterStr = num2str(counter,'%02d');
        folderName = strcat(folderBackupFigures,'\',folderFigures,'_',counterStr);
        while ( exist( folderName,'dir') == 7 ) 
            % the name already exists, so lets try next 
            counter = counter + 1; 
            counterStr = num2str(counter,'%02d');
            folderName = strcat(folderBackupFigures,'\',folderFigures,'_',counterStr);
        end

        % Got a name for the new backup folder
        status = mkdir(folderName); 
            % status should be one, because have check previously that the folder

        % oldFolder = cd(newFolder) 
        oldFolder = cd( folderName );
        %lets move file content  
        movefile( strcat( oldFolder , '\' , folderFigures,'\','*' ) );
        cd( oldFolder );


    else
        % do nothing 
    end

    fprintf('\nEnd of the program to move folders\n')

end