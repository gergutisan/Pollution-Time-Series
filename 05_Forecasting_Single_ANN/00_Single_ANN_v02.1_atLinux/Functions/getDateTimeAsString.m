% Get the date and time as an string 
function strDateTime = getDateTimeAsString ( delimiterChar )

    dateTime = clock;

    yy = num2str(dateTime(1) , '%04d' );
    mo = num2str(dateTime(2) , '%02d' );
    dd = num2str(dateTime(3) , '%02d' );
    hh = num2str(dateTime(4) , '%02d' );
    mi = num2str(dateTime(5) , '%02d' );
    ss = num2str( fix( dateTime(6) ) , '%02d' );

    delimiterChar = string(delimiterChar);
    delimiterArray = [ delimiterChar , delimiterChar , delimiterChar , "_" , "_" ] ;

    dateTime = [ string(yy) ,string( mo ) , string(dd) , string(hh) , string(mi) , string(ss) ];
    strDateTime = join( dateTime , delimiterArray);
    fprintf('\n\n --> subString %s \n' , strDateTime );

end