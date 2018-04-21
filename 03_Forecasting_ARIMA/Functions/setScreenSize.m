%% SCREEN SIZE FUNCTION

function setScreenSize( leftBottomCornerPos , rateScreenSize )
    
    %  screensize: left bottom  widthScreen heightScreen
    %  screensize <- 1  1  1680  1050
    screensize = get(0,'ScreenSize');  % -> left bottom corner: left <-1; bottom <-1
    
    % position = [ left bottom width height ];
    leftFig  = screensize(3) * leftBottomCornerPos;  bottomFig = screensize(4) * leftBottomCornerPos; 
    widthFig = screensize(3) * rateScreenSize ; heightFig = screensize(4) * rateScreenSize;
    position = [ leftFig , bottomFig , widthFig , heightFig ];
    set(0, 'DefaultFigurePosition', position);
end