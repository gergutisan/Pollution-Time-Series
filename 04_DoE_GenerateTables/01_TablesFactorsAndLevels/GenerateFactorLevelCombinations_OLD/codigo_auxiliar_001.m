clear; clc;
maxValue = 10000
minValue = 0;
n =  -1;
while n~= 0 
  gaps = 0;
  n = randi( [minValuem maxValue] , 1 );
  a = n; tries = 0;
  while ( a >= 1 )
    k = mod( a , 2 );
    fprintf('%i' , k ); % K is the digit
    tries = tries + 1; 
    if ( k == 0 )
      x = logical(true);
    end;
    
    if ( k == 1 ) && ( x == logical(true) )
      x = logical(true);
    end;
    
    if ( k == 1 ) && ( x == logical(true) ) && (previous == 1)
      after = 1;
    end;
  
  end;
end;