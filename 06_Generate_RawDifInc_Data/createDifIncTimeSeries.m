clear; clc; close all;
fclose('all');
%% SET WORKING DIRECTORY
if (~isdeployed)
  s1 = mfilename('fullpath'); s2 = which(s1) ; s3 = fileparts(s2) ; cd(s3)
  % cd(fileparts(which(mfilename('fullpath'))));
end
%%  FOLDERS 
cd( fileparts( mfilename( 'fullpath' ) ) );    % does not work if executed by Run Section [and advance]

parameters.folderFunctions  = fullfile( fileparts(mfilename('fullpath')),'Functions');
% parameters.tsFolder         = fullfile( fileparts(mfilename('fullpath')),'TimeSeries_Academic_02');
parameters.tsFolder         = fullfile( fileparts(mfilename('fullpath')),'TimeSeries_Academic_03');
addpath(    parameters.folderFunctions  ,  parameters.tsFolder );

parameter.regExp4TsFile = 'ts-*.csv';

%% FOLDER 
parameters.folder_TS  =  'TimeSeries';             % parameters.folder_TS  =  '';
parameters.folder_TS  =  'TimeSeries_Academic_03'; % parameters.folder_TS  =  '';

%%  &  FILENAMES
% ==========================================================

% filenamesInitData  = {'tsMackeyglass01.dat'; ...
%                       'tsTemperature.dat'; ...
%                       'tsDowjones.dat'; ...
%                       'ts4Test01'; ...
%                       'ts4Test02' ; ...
%                       'ts4Test03'; ...
%                       'tsQuebec.dat'};
%                   
% tsnames  = {'Mackeyglass01';'Temperature';'Dowjones';'Quebec'; '4Test01'; '4Test02'; '4Test03'};

% ==========================================================
% filenamesInitData  = {  'ts_PC_08_SC_28079050_D_F03.dat';...
%                         'ts_PC_08_SC_28079056_D_F03.dat';...
%                         'ts_PC_09_SC_28079050_D_F03.dat';...
%                         'ts_PC_14_SC_28079056_D_F03.dat'};
% 
% tsnames  = {'PC_08_SC_28079050_D_F03';...
%             'PC_08_SC_28079056_D_F03';...
%             'PC_09_SC_28079050_D_F03';...
%             'PC_14_SC_28079056_D_F03'};
%        
% ==========================================================% 
% filenamesInitData  = {  'ts_PC_08_SC_28079050_H_F03.dat';...
%                         'ts_PC_08_SC_28079056_H_F03.dat';...
%                         'ts_PC_09_SC_28079050_H_F03.dat';...
%                         'ts_PC_14_SC_28079056_H_F03.dat'};
% 
% tsnames  = {'PC_08_SC_28079050_H_F03';...
%             'PC_08_SC_28079056_H_F03';...
%             'PC_09_SC_28079050_H_F03';...
%             'PC_14_SC_28079056_H_F03'};
%         
% ==========================================================        
% filenamesInitData  = {  'ts_PC_08_SC_28079050_D_F03.dat';...
%                         'ts_PC_08_SC_28079056_D_F03.dat';...
%                         'ts_PC_09_SC_28079050_D_F03.dat';...
%                         'ts_PC_14_SC_28079056_D_F03.dat';...
%                         'ts_PC_08_SC_28079050_H_F03.dat';...
%                         'ts_PC_08_SC_28079056_H_F03.dat';...
%                         'ts_PC_09_SC_28079050_H_F03.dat';...
%                         'ts_PC_14_SC_28079056_H_F03.dat'};
% 
% tsnames  = {'PC_08_SC_28079050_D_F03';...
%             'PC_08_SC_28079056_D_F03';...
%             'PC_09_SC_28079050_D_F03';...
%             'PC_14_SC_28079056_D_F03';...
%             'PC_08_SC_28079050_H_F03';...
%             'PC_08_SC_28079056_H_F03';...
%             'PC_09_SC_28079050_H_F03';...
%             'PC_14_SC_28079056_H_F03'};
%                
        

% ==========================================================

% Paper 2017 - November NEPL Special Issue IWANN2017  

% ts-NO2-FedzLadreda-16-12.csv
% ts-NO2-PzCastilla-16-10.csv
% ts-O3-JuanCarlosI-16-07.csv
% ts-PM25-MendezAlvaro-16-10.csv


% filenamesInitData  = {  'ts-NO2-FedzLadreda-16-12.csv'  ;...
%                         'ts-NO2-PzCastilla-16-10.csv'   ;...
%                         'ts-O3-JuanCarlosI-16-07.csv'   ;...
%                         'ts-PM25-MendezAlvaro-16-10.csv' };

parameters.extensionStr = '.csv';
parameters.regExp = 'ts-*.csv';
[ filenamesInitData , tsNames ] = readAndGetFilenameTimeSeries (parameters.folder_TS,  parameters.regExp ); 

% tsnames             = { 'NO2-FedzLadreda-16-12'   ;...
%                         'NO2-PzCastilla-16-10'    ;...
%                         'O3-JuanCarlosI-16-07'    ;...
%                         'PM25-MendezAlvaro-16-10' };


                   
% ==========================================================
rawSufix = 'raw'; 
difSufix = 'dif';
incSufix = 'inc';
filenames = cell(size(filenamesInitData,1),3);            

for i = 1:(size(tsNames,1))
  filenames{i,1} = strcat('ts-',tsNames {i},'-',rawSufix,parameters.extensionStr);
  filenames{i,2} = strcat('ts-',tsNames {i},'-',difSufix,parameters.extensionStr);
  filenames{i,3} = strcat('ts-',tsNames {i},'-',incSufix,parameters.extensionStr);
end

% ==============================================================
%{
  filenames  = {'tsMackeyglass01_raw.dat', 'tsMackeyglass01_dif.dat', 'tsMackeyglass01_inc.dat';
                'tsTemperature_raw.dat',   'tsTemperature_dif.dat',   'tsTemperature_inc.dat'  ; ...
                'tsDowjones_raw.dat',      'tsDowjones_dif.dat',      'tsDowjones_inc.dat'     ; ...
                'tsQuebec.dat',            'tsQuebec_dif.dat',        'tsQuebec_inc.dat' };
%}            
            
%% READ RAW, and show its figure

for i = 1:( numel(filenamesInitData) )
    
    scrsz = get(groot,'ScreenSize'); % [left bottom width height].
    fig = figure('Position',[ (20+ 20*i) (100+20*i) scrsz(3)/1.5 scrsz(4)/1.5]); 
    
    filename = filenamesInitData{i};
    filename = fullfile( parameters.folder_TS , filename );
    tsRawData = load(filename);
    
    t = 1:numel(tsRawData);
    plot(t,tsRawData,'-b.','MarkerSize',10);
    title( tsNames{i} );
        
    filenameFig = fullfile(parameters.folder_TS,strcat( tsNames{i},'-Orig'));
    fig.PaperPositionMode = 'auto';       % set(gcf,'PaperPositionMode','auto')
    fig.PaperOrientation  = 'landscape';  % set(gcf,'PaperOrientation','landscape')
        
    
    % Print to pdf pr png ??? -> pdf is longer in time 
    % print( '-bestfit' , filenameFig , '-dpdf' , '-r0' );  % print('-fillpage',filename,'-dpdf','-r0')
    print( filenameFig , '-dpng' , '-noui' );  % print('-fillpage',filename,'-dpdf','-r0')
    
end

%% READ RAW, and COMPUTE DIF and INC     

generateDifInc = 3;  % 0  -> dif and inc data were created in previous executions 
                     % 1  -> dif data are created in previous executions (needs to create inc data ) 
                     % 2  -> inc data are created in previous executions (needs to create dif data )
                     % 3  -> no dif or inc were created, needs to create both dif and inc data
                 
if ( generateDifInc ~= 0 )
    delete(strcat(parameters.folder_TS,'*raw',parameters.extensionStr));
    delete(strcat(parameters.folder_TS,'*dif',parameters.extensionStr));
    delete(strcat(parameters.folder_TS,'*inc',parameters.extensionStr));
    
    % Copy the ts initial file to new files with subfix raw 
    for k = 1:(size(filenamesInitData,1)) 
        file_TS  = strcat('ts-',tsNames{k},parameters.extensionStr);
        filename = strcat('ts-',tsNames{k},'-',rawSufix,parameters.extensionStr);
        file_TS  = fullfile( parameters.folder_TS , file_TS );
        filename = fullfile( parameters.folder_TS , filename );
        copyfile(file_TS,filename);
    end

    
    for k = 1:(size(filenamesInitData,1)) 
       
        % get raw data ----------------------------------------------------
        file_TS  = filenames{k,1};
        filename = fullfile( parameters.folder_TS , file_TS );
        tsRawData = load(filename);  % ts <- column vector
        ntimes = size(tsRawData,1);  % Number of values for initial(raw data)

        % preallocation for dif and inc time series data ------------------
        tsDifData = zeros(ntimes,1); 
        tsIncData = zeros(ntimes,1);
        
        % Generate dif and inc data ---------------------------------------
        tsDifData(1) = 0;
        tsIncData(1) = 0;
        for i = 2:ntimes     
            
            tsDifData(i) = tsRawData(i) - tsRawData(i-1) ;
            
            if ( tsDifData (i) > 0 )
                tsIncData (i) = +1;
            elseif (tsDifData (i) < 0)   
                tsIncData (i) = -1;
            else % tsDiffData (i-1) == 0)
                tsIncData (i) = 0;
            end
        end
        tsDifData(1) = median(tsDifData);
        tsIncData(1) = median(tsIncData);
        
        
        % SHOW FIGURES 
        
        titleRoot = tsNames{k};
        
        scrsz = get(groot,'ScreenSize'); % [left bottom width height].
        fig = figure('Position',[ (20+ 20*k) (100+20*k) scrsz(3)/1.5 scrsz(4)/1.5]); 
        
        s(1) = subplot(2,2,1);
        t = 1:numel(tsRawData);
        plot(t,tsRawData,'-r.','MarkerSize',10);
        
        
        s(2) = subplot(2,2,2);
        t = 1:numel(tsDifData);
        plot([1,t+1],[0,tsDifData'],'-b.','MarkerSize',10);
        
        s(3) = subplot(2,2,3);                
        t = 1:numel(tsIncData);
        axis([ 0 numel(tsIncData) -0.2  1.2]);
        plot([1,t+1],[0,tsIncData'],'k.','MarkerSize',10);
        
        title( s(1) , strcat( titleRoot, ' raw' ), 'Interpreter','none' );
        title( s(2) , strcat( titleRoot, ' dif' ), 'Interpreter','none' );
        title( s(3) , strcat( titleRoot, ' inc' ), 'Interpreter','none' );
        
        filenameFig02 = strcat(titleRoot);
        filenameFig02 = fullfile(parameters.folder_TS,filenameFig02);
        fig.PaperPositionMode = 'auto';
        fig.PaperOrientation  = 'landscape'; 
        % print('-bestfit',filenameFig02,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')
        print( filenameFig02,'-dpng' , '-noui' );  
        
        

       
        % save dif data into its file
        if (generateDifInc == 1) || (generateDifInc == 3) 
            filename = strcat('ts-',tsNames{k},'-',difSufix,parameters.extensionStr);
            filename = fullfile(parameters.folder_TS, filename);
            %save(filename,'tsDiffData','-ascii');
            %type(filename);
            fid = fopen(filename,'w');
            for i = 1:(ntimes)
                % fprintf(fid,'%+10.5f\n',tsDifData(i));
                fprintf(fid,'%12.5f\n',tsDifData(i));
            end
            fclose(fid);
        end

        % save dif data into its file
        if (generateDifInc == 2) || (generateDifInc == 3) 
            filename = strcat('ts-',tsNames{k},'-',incSufix,parameters.extensionStr);
            filename = fullfile(parameters.folder_TS, filename);
            %save(filename,'tsIncData','-ascii');
            %type(filename);
            fid = fopen(filename,'w');
            for i = 1:(ntimes)
               fprintf(fid,'%+03.1d\n',tsIncData(i));
            end
            fclose(fid);
        end
    end
end
%% --------------------------------------------------------------------
close all; fclose('all');

%% MOVE THE NEW FILES AND FIGURES TO A FOLDER FOR RESULTS 

mkdir( parameters.tsFolder , 'Results' );
folderResults = fullfile( parameters.tsFolder , 'Results');

[status,message,messageId] = movefile( fullfile( parameters.tsFolder , '*raw.csv' ) , folderResults, 'f');
[status,message,messageId] = movefile( fullfile( parameters.tsFolder , '*dif.csv' ) , folderResults, 'f');
[status,message,messageId] = movefile( fullfile( parameters.tsFolder , '*inc.csv' ) , folderResults, 'f');

[status,message,messageId] = movefile( fullfile( parameters.tsFolder , '*.pdf' ) , folderResults, 'f');
[status,message,messageId] = movefile( fullfile( parameters.tsFolder , '*.png' ) , folderResults, 'f');


%% END OF THE PROGRAM
msg = 'Program Finish. Press any key.'; fprintf('\n\n - %s -\n',msg); 

