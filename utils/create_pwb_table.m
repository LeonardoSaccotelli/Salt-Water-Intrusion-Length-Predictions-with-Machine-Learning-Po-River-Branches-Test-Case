function [pwbTable] = create_pwb_table(obs, pred, mlAlgName)
%CREATE_PWB_TABLE This function compute the pwb Table
%   Input:
%   1) obs:
%   The observed values
%
%   2) pred:
%   The predicted values from regression model
%
%   3) pwbTable:
%   Empty table in which save the results
%   
%   4) algorithm_name:
%   The name of the algorithm for which we want to compute the pwbTable
%
%   5) pwbX:
%   The different threshold in the pwbTable
%
%   Output:
%   1) pwbTable:
%   The table with the results updated
   
    if istable(obs)
        obs = table2array(obs);
    end
    if istable(pred)
        pred = table2array(pred);
    end

    pwbX = [1 5 10 20 30];
    pwbXRowNames = string();
    
    for i = 1:numel(pwbX)
        pwbXRowNames(i) = strcat('PWB', num2str(pwbX(i)));
    end
    
    pwbTable = table('Size',[numel(pwbX) 1],...
        'VariableTypes', repmat({'double'}, 1, 1), ...
        'VariableNames', mlAlgName,...
        'RowNames', pwbXRowNames);

    for i=1:height(pwbTable)
        pwbTable(i,mlAlgName) = {round(computePWBTable(obs, pred, pwbX(i)),2)};
    end
end
    
function [pwbTest] = computePWBTable (obs, pred, threshold)
    minBound = obs - (obs*threshold/100);
    maxBound = obs + (obs*threshold/100);
    countInBound = sum(pred>= minBound & pred<=maxBound);
    pwbTest = countInBound*100/numel(obs);
end
