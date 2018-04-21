
clear; clc; close all; fclose('all');
% Page for Dowload Historical Data
% http://gestiona.madrid.org/azul_internet/html/web/InformExportacionAccion.icm?ESTADO_MENU=8
% url = 'http://gestiona.madrid.org/azul_internet/html/web/ExportacionAccion.icm?mes=01&anio=2017';
% data = webread(url);
% url2 = '../../../ICMdownload/201701MMA.dat';
% data = webread(url);

%{
    http://gestiona.madrid.org/azul_internet/html/web/ExportacionAccion.icm?mes=01&anio=2017/../../../ICMdownload/201701MMA.dat
    http://gestiona.madrid.org/ICMdownload/201701MMA.dat   -> This work
    http://gestiona.madrid.org/ICMdownload/201601MMA.dat
    http://gestiona.madrid.org/azul_internet/ICMdownload/201701MMA.dat -> This does not work
   
%}

%{
  outfilename = websave(filename,url)
  e.g. 
        url = 'http://www.mathworks.com/matlabcentral/fileexchange/';
        filename = 'simulink_search.html';
        outfilename = websave(filename,url,'term','simulink','duration',7)

        url = 'http://heritage.stsci.edu/2007/14/images/p0714aa.jpg';
        filename = 'jupiter_aurora.jpg';
        outfilename = websave(filename,url)
%}





%% TEST for one file -----------------------------------------------------------------------
% options = weboptions('ContentType','text');
% urlFile = 'http://gestiona.madrid.org/ICMdownload/201701MMA.dat';
%           %  http://gestiona.madrid.org/ICMdownload/201601MMA.dat
% outFileContent = webread( urlFile,options );
% 
% urlFile = 'http://gestiona.madrid.org/ICMdownload/201602MMA.dat';
% outFilename = websave('pollutData_201602MMA.dat',urlFile,options);
% 
% % ----------------------
%  folderData = 'Data_MadridOrg';
% 
% 
% localFile = strcat(folderData,'/','prueba.txt');
% delete(localFile);
% 
% fId = fopen(localFile,'w');
% for cIndex = 1:numel(outFileContent)
%     fprintf(fId,'%1s',outFileContent(cIndex));
%     
%     if ( mod(cIndex,100000) == 0 )
%         fprintf('%20s - numChar %010d\n','prueba.txt', cIndex );
%     end
% end
% fclose(fId);

%% --------------------------------------------------------------------------------------------
folderData = 'Data_MadridOrg';

for yy = 2015:2017
    
    switch yy
        case 2017
            initMonth = 01;
            lastMonth = 09;
        case 2015
            % month 04 -> does exist the required month + year
            initMonth = 05;
            lastMonth = 12;
        otherwise
            initMonth = 01;
            lastMonth = 12;
            
    end
    
    
    
    
    for mm = initMonth:lastMonth
        
        strYY = sprintf('%04d',yy);
        strMM = sprintf('%02d',mm);
        
        localFilename_01 = strcat('query_',strYY,strMM,'MMA.dat');
        localFilename_02 = strcat('data_',strYY,strMM,'MMA.dat');
        webFilename = strcat(strYY,strMM,'MM.dat');
        
        % -----------------------------------------------
                
        % urlFile = 'http://gestiona.madrid.org/ICMdownload/201701MMA.dat';
        %      http://gestiona.madrid.org/ICMdownload/201601MMA.dat
        
        url_01_P01 = 'http://gestiona.madrid.org/azul_internet/html/web/ExportacionAccion.icm?mes=';
        url_01_P02 = '&anio=';
        % e.g. -> 'http://gestiona.madrid.org/azul_internet/html/web/ExportacionAccion.icm?mes=05&anio=2016'
        
        url_01 = strcat(url_01_P01 , strMM , url_01_P02 , strYY);
                
        url_02 = 'http://gestiona.madrid.org/ICMdownload';
        
        dataFilename = strcat(strYY,strMM,'MMA.dat');
        urlFile = strcat(url_02,'/',dataFilename);
        
        % ------------------------------------------------
        fprintf('\nyyyy: %04d    mm: %02d \n',yy , mm );
        fprintf('\tReady to read ... \n  %s \n',urlFile);
        options = weboptions('ContentType','text');
        % Step A
        % http://gestiona.madrid.org/azul_internet/html/web/ExportacionAccion.icm?mes=05&anio=2016
        % Step B
        % http://gestiona.madrid.org/ICMdownload/201605MMA.dat
        
        localFilename_01 = strcat(folderData,'/',localFilename_01);
        outFilenameTmp = websave(localFilename_01,url_01,options);
        
        fprintf('Waiting for downloading  ...\n '); pause(2);
        
        % outFileContent = webread( urlFile,options );
        
        localFilename_02 = strcat(folderData,'/',localFilename_02);
        outFilename = websave(localFilename_02,urlFile,options);
        
        
        
        % ------------------------------------------------
        
        % localFile = strcat( folderData,'/',strcat('pollution_CAM_Network_',strYY,strMM,'.dat') );
        % 
        % fprintf('filename %20s \n', localFile);
        % fId = fopen(localFile,'w');
        % for cIndex = 1:numel(outFileContent)
        %     fprintf(fId,'%1s',outFileContent(cIndex));
        % 
        %     if ( mod(cIndex,100000) == 0 )
        %         fprintf('%20s - numChar %010d\n',localFile, cIndex );
        %     end
        % end
        % fclose(fId);
        
        % ----------------------------------------------
        fprintf('\t\tyyyy %04d mm %02d GENERATED \n',yy , mm );
        
        
    end
    
end