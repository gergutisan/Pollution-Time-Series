function [rmse, smape] = getTsErrors_v1 (tsTarget,tsForecasted, periods) 

    rmse = -1; smape = -1; errorMsg = '';     

    nTargets    = numel(tsTarget);
    nForecasted = numel(tsForecasted);

    % ================================================================
    % Check Input Parameters
    
    if (nTargets ~= nForecasted )    
        msg = 'Error at function call. The size of the arrays mus be the same.';
        fprintf('\n%s\n',msg);
        % error(msg);
        return;
    end
    
    if nargin == 2
        periods = nForecasted;
        
    elseif nargin == 3
        % periods already defined
        
        if ( periods ~= nForecasted)
            msg = 'Error at function call. periods and length of the vectors must be the same.';
        fprintf('\n%s\n',msg);
        % error(msg);
        return;
        end
    else
        msg = 'Error at function call. Wrong num input arguments';
        error(msg);
    end
    
    % ================================================================
    
    s2 = sum( ( tsTarget - tsForecasted ).^2 );
    rmse =  (1/periods)* ( (s2 )^(0.5) ); %clear s2; 

    s3  = sum ( ( abs(tsTarget - tsForecasted) )./ ...
                ( ( abs(tsTarget) + abs(tsForecasted) ) ) );

    smape = 100 * 2* (1/periods) * s3;

end