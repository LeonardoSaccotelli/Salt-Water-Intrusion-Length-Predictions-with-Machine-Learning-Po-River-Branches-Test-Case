%% Function to train and test a SVM regression model
%% Input:
%  1) trainingDataset: 
%  Table containing the same predictor and response columns as those 
%  imported into the app.
%  
%  2) targetFeatureName: 
%  String with the name of the target feature in the trainingData table.
%  
%  3) max_objective_evaluations:
%  Maximum number of objective functions to be evaluated in the
%  optimization process     
%
%  4) k-fold to use in cross-validation

%% Output:
%  Compact structure with the following data:
%  
%  1) trainedModel:
%  Struct containing the trained regression model. The
%  struct contains various fields with information about the trained
%  model. 
%  trainedModel.predictFcn: A function to make predictions on new data.
%
%  2) validationRMSE: 
%  Double containing the RMSE which measure the performance of the trained
%  model.
%       
%  3) validationPredictions: 
%  Vector with the predected values with respect the observed values in the
%  trainingDataset
%      
%  4)featuresImportanceTable:
%  Table with features and score which indicates how important is each 
%  feature to train the model. Features have been ordered from the most 
%  important to the least important.
%
%  5) tuningResult:
%  Table with the optimized hyperparameters obtained by auto-tuning
%  procedure

function [trainedModel, validationPredictions, bestHyperparameters, featuresImportanceTable] = ...
    svm_function(trainingDataset, targetFeatureName, maxObjectiveEvaluations, kFold)

%% Extract predictors and response
inputTable = trainingDataset;

% Retrive all the features to be used in the training process
predictorNames = inputTable.Properties.VariableNames;
predictorNames(:,(strncmp(predictorNames, targetFeatureName,...
        strlength(targetFeatureName)))) = [];
predictors = inputTable(:, predictorNames);

% Retrive the target feature
response = inputTable(:, targetFeatureName);

% Set configuration for k-fold cross validation
crossValidationSettings = cvpartition(height(response),'KFold',kFold);

%% Set parameters to be optimized during the auto-tuning procedure
svm_settings_optimized = fitrsvm( ...
    predictors, ... 
    response, ...
    'OptimizeHyperParameters',...
    {'BoxConstraint','KernelScale','Epsilon','KernelFunction', 'PolynomialOrder', 'Standardize'}, ...
    "HyperparameterOptimizationOptions", ...
    struct(...
    "Optimizer", "bayesopt",...
    "AcquisitionFunctionName","expected-improvement-per-second-plus", ...
    'CVPartition', crossValidationSettings, ...
    "MaxObjectiveEvaluations", maxObjectiveEvaluations,...
    "Repartition", false,...
    "UseParallel", true));

%% Save all the best hyperparameters
bestHyperparameters = cell(1,6);

bestHyperparameters{1,1} = svm_settings_optimized.ModelParameters.BoxConstraint;
bestHyperparameters{1,2} = svm_settings_optimized.ModelParameters.KernelScale;
bestHyperparameters{1,3} = svm_settings_optimized.ModelParameters.Epsilon;
bestHyperparameters{1,4} = svm_settings_optimized.ModelParameters.KernelFunction;
bestHyperparameters{1,5} = svm_settings_optimized.ModelParameters.KernelPolynomialOrder;
bestHyperparameters{1,6} = svm_settings_optimized.ModelParameters.StandardizeData;

bestHyperparameters = cell2table(bestHyperparameters,'VariableNames',...
   {'BoxConstraint','KernelScale','Epsilon','KernelFunction', 'PolynomialOrder', 'Standardize'});

%% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
ensemblePredictFcn = @(x) predict(svm_settings_optimized, x);
trainedModel.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));

%% Add additional fields to the result struct
trainedModel.RequiredVariables = trainingDataset.Properties.VariableNames;
trainedModel.RegressionEnsemble = svm_settings_optimized;
trainedModel.About = 'This struct is a svm optimized trained model.';
trainedModel.HowToPredict = ...
    sprintf(['To make predictions on a new table, T, use: ' ...
    '\n  yfit = trainedModel.predictFcn(T) \n' ...
    '\n \nThe table, T, must contain the variables returned by: ' ...
    '\n  trainedModel.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype)' ...
    ' must match the original training data. \nAdditional variables are ignored. ' ...
    '\n \nFor more information, ' ...
    'see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ' ...
    '''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.']);

%% Perform cross-validation with k fold
partitionedModel = crossval(trainedModel.RegressionEnsemble, 'KFold', kFold);
validationPredictions = kfoldPredict(partitionedModel);

%% Compute features importance
featuresImportanceTable = "NOT AVAILABLE";
end