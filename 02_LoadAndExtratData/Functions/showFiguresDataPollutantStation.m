function [ funcError ] = showFiguresDataPollutantStation( tsPolSta, kind , filenameFig01,filenameFig02)

    funcError = 0;
    figureSize(80); 
    
    pollutantCodeStr = sprintf('%02i',tsPolSta(1).codMeasure);
    stationCodeP3Str   = sprintf('%02i',tsPolSta(1).codStationP3);

    t = 1:numel(tsPolSta);
    for tsIndex = 1:numel(tsPolSta)
        s = tsPolSta(tsIndex);
        TS(tsIndex) = s.value;
    end
    

    fig = figure(); 
    plot(t,TS,'.-k');
    if (kind == 'd')
        kindStr = 'daily';
    elseif (kind == 'h')  
        kindStr = 'hourly';
    end
    title( [ kindStr,' PC ', pollutantCodeStr , '  ' , ' SC ', stationCodeP3Str , ' long (all periods)'] );
        
    fig.PaperPositionMode = 'auto';
    fig.PaperOrientation  = 'landscape';
    print('-bestfit',filenameFig01,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')
    
    % saveas(h,filename);
    
    if (kind == 'd')
        fig = figure(); 
        numDays =  365; years = 2; 
        plot(t(1:(years*numDays)),TS(1:(years*numDays)), '.-b');
        kindStr = 'daily';       
        title( [kindStr ,' - PC ', pollutantCodeStr , ' - ' , ' SC ', stationCodeP3Str, ' short (2 years)' ] );

        fig.PaperPositionMode = 'auto';
        fig.PaperOrientation  = 'landscape'; 
        print('-bestfit',filenameFig02,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')
        % saveas(h,filename);    
        
    elseif (kind == 'h')    

        fig = figure(); 
        hoursPerDay = 24; numDays = 30;
        plot(t(1:(hoursPerDay*numDays)),TS(1:(hoursPerDay*numDays)), '.-b');
        kindStr = 'hourly';
        title( [kindStr,'- PC ', pollutantCodeStr , ' - ' , ' SC ', stationCodeP3Str, ' short (1 month)' ] );

        fig.PaperPositionMode = 'auto';
        fig.PaperOrientation  = 'landscape'; 
        print('-bestfit',filenameFig02,'-dpdf','-r0');  % print('-fillpage',filename,'-dpdf','-r0')
        % saveas(h,filename);    
    
    end
    
    

end
