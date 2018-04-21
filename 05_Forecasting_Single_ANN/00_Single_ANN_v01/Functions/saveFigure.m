function [ error ] = saveFigure( fig , format, folder , filename )

%saveFigure save a matlab figure in an specific format 
%    
%   saveFigure( h1 , '-dpdf', 'Figures' , 'prueba.pdf' )
%   input: the format (pdf, jpg, etc.)
%          the filaname without extension  
%   see https://es.mathworks.com/help/matlab/ref/saveas.html#inputarg_formattype



%{
  format examples: 
      'jpeg', 'png', 'tiff', 'bmp', 'ppm'  (bitmap images ), 
      'pdf', 'svg' (vector grpahis files)
      '-dpdf'
       
        Only PDF and PS formats use the PaperOrientation property of the figure 
        and the left and bottom elements of the PaperPosition property. 
        Other formats ignore these values.
        
        To control the size or resolution when you save a figure, use the print function instead.
%}
     
     orient(fig,'landscape')
     set(fig,'PaperPositionMode','auto')
     
     
     % saveas(fig,filename,format)
     % print(fig,'dpdf','-bestfit','-r300','-opengl')
     % print(fig, '-opengl','-bestfit', '-r300', figureFilename, '-dpdf');
     print(fig, '-opengl','-bestfit', '-r300', strcat(folder,'\',filename), format);
     
     error = 0;
     
end

