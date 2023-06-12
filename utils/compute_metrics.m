function [results] = compute_metrics(obs, pred, mlAlgName)
%COMPUTE_METRICS This function compute 8 different metrics to evaluate regression models performance
%   Input:
%   1) obs:
%   The observed values
%  
%   2) pred:
%   The predicted values from regression model
%   
%   3) algorithm_names:
%   Names of the regression model used
%   
%   4) results:
%   Table to store performance
%
%   Output:
%   1) results:
%   Table with the computed metrics

        
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

    results(mlAlgName,'RMSE') = {computeRMSE(obs, pred)}; 
    results(mlAlgName,'NRMSE') = {computeNRMSE(obs, pred)}; 
    results(mlAlgName,'MAE') = {computeMAE(obs, pred)}; 
    results(mlAlgName,'Corr Coeff') = {computeCorrCoef(obs, pred)}; 
    results(mlAlgName,'Mean Obs') = {mean(obs)}; 
    results(mlAlgName,'Mean Pred') = {mean(pred)}; 
    results(mlAlgName,'Bias') = {computeBias(obs, pred)}; 
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