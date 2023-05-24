function [results] = compute_metrics(obs, pred, algorithm_names)
%COMPUTE_METRICS This function compute 7 different metrics to evaluate regression models performance
%   obs: real values
%   pred: predicted values from regression model
%   algorithm_names: names of the regression model used
%   results: table to store performance
        
    if(istable(obs))
        obs = table2array(obs);
    end

    if(istable(pred))
        pred = table2array(pred);
    end
    
    results = table('Size', [1 7], ...
    'VariableTypes', {'double','double','double','double', 'double', 'double', 'double'}, ...
    'VariableNames', {'RMSE','NRMSE', 'MAE', 'Corr Coeff', 'Mean Obs', 'Mean Pred', 'Bias'},...
    'RowNames', mlAlgName);

    results(algorithm_names,'RMSE') = {computeRMSE(obs, pred)}; 
    results(algorithm_names,'NRMSE') = {computeNRMSE(obs, pred)}; 
    results(algorithm_names,'MAE') = {computeMAE(obs, pred)}; 
    results(algorithm_names,'Corr Coeff') = {computeCorrCoef(obs, pred)}; 
    results(algorithm_names,'Mean Obs') = {mean(obs)}; 
    results(algorithm_names,'Mean Pred') = {mean(pred)}; 
    results(algorithm_names,'Bias') = {computeBias(obs, pred)}; 
end

function [rmse] = computeRMSE(obs, pred)
    rmse = sqrt(sum((obs - pred).^2)/height(obs));
end

function [nrmse] = computeNRMSE(obs, pred)
    nrmse = computeRMSE(obs, pred) / max(obs);
end

function [mae] = computeMAE(obs, pred)
    mae = (sum(abs(pred-obs)))/height(obs);
end

function [bias] = computeBias (obs, pred)
    bias = mean(obs - pred);
end

function [r] = computeCorrCoef(obs, pred)
    corr_coeff_matrix = corrcoef(obs, pred);
    r = corr_coeff_matrix(1,2);
end