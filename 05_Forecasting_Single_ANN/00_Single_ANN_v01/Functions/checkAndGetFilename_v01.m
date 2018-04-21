function [ filename ] = checkAndGetFilename_v01( folder , filename )

    num = 0;
    while ( exist(strcat(folder,'\',filename),'file' ) == 2 ) 
                num = num + 1;
                filename2 = strcat( filename(1:( end - 6 )  ),...
                                    num2str( num , '%02d'  ), ...
                                    filename( (end-3):end ) );

                filename  = filename2;              
    end
    

end

