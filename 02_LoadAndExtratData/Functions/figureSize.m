function [position percentageOnScreen] = figureSize(percentageOnScreen)    

    % CHECK and recompute the value of input parameter
    if ( percentageOnScreen > 100) 
        percentageOnScreen = 70;
    elseif ( ( percentageOnScreen < 20) && ( percentageOnScreen > 1) )    
        percentageOnScreen = 20;
    elseif ( percentageOnScreen < 1) 
        percentageOnScreen = percentageOnScreen * 100;
    end;
      
   
    % SCREEN SIZE 
    screensize = get(0,'ScreenSize');  % -> left bottom corner: left <-1; bottom <-1
                                       %  screensize: left bottom  widthScreen heightScreen
                                       % [a b c d]: 
                                       %   a & b are the coordenates of left bottom cornet of the screen
                                       %   c is the width of the screen
                                       %   d is the height of the screen
                                  
    % percentageOnScreen  
    % position = [ left bottom width height ];
    
    % leftFig = screensize(3) * 0.1;  bottomFig = screensize(4) * 0.1; 
    % widthFig = screensize(3)* 0.8 ; heightFig= screensize(4) * 0.8;
        
    leftFig   = ( screensize(3) / 2) * ( 100 - percentageOnScreen)/100;
    bottomFig = ( screensize(4) / 2) * ( 100 - percentageOnScreen)/100; 
    widthFig  = screensize(3) * percentageOnScreen / 100 ; 
    heightFig = screensize(4) * percentageOnScreen / 100 ;
    
    
    position = [ leftFig bottomFig widthFig heightFig ];
    set(0, 'DefaultFigurePosition', position);
    
end