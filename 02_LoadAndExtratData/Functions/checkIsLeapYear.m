function isLeapYear = checkIsLeapYear(year)

    isLeapYear = false;
    
    if ( mod(year,4) == 0)
    
        if (mod(year,100) == 0)
            if (mod(year,400) == 0)
                isLeapYear = true;
            end
        else
            isLeapYear = true;
        end
        
    end
end