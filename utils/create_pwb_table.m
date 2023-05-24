function [pwbTable] = create_pwb_table(obs, pred, mlAlgName)
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
        pwbTable(i,algorithm_name) = {round(computePWBTable(obs, pred, pwbX(i)),2)};
    end
end
    
function [pwbTest] = computePWBTable (obs, pred, threshold)
    minBound = obs - (obs*threshold/100);
    maxBound = obs + (obs*threshold/100);
    countInBound = sum(pred>= minBound & pred<=maxBound);
    pwbTest = countInBound*100/numel(obs);
end
