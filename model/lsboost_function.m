function [trainedModel, validationPredictions, bestHyperparameters, featuresImportanceTable] = ...
    lsboost_function(trainingDataset,targetFeatureName,maxObjectiveEvaluations, kFold)
%LSBOOST_FUNCTION Function to train a lsboost regression model
%  Input:
%  1) trainingDataset: 
%  Table containing the predictors and response columns
%  
%  2) targetFeatureName: 
%  String with the name of the target feature in the trainingData table.
%  
%  3) max_objective_evaluations:
%  Maximum number of objective functions to be evaluated in the
%  optimization process     
%
%  4) k-fold to use in cross-validation
%
%  Output:
%  1) trainedModel:
%  Struct containing the trained regression model. The
%  struct contains various fields with information about the trained
%  model. 
%  trainedModel.predictFcn: A function to make predictions on new data.
%       
%  2) validationPredictions: 
%  Vector with the predected values with respect the observed values in the
%  trainingDataset
%
%  3) bestHyperparameters:
%  Table with the optimized hyperparameters obtained by auto-tuning
%  procedure
%
%  4)featuresImportanceTable, or "NOT AVAILABLE" if the model doesn't support it:
%  Table with features and score which indicates how important is each 
%  feature to train the model. Features have been ordered from the most 
%  important to the least important.

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
lsboost_settings_optimized = fitrensemble( ...
    predictors, ...
    response, ...
    'Method', 'LSBoost', ...
    'OptimizeHyperParameters',...
    {'NumLearningCycles','LearnRate','MinLeafSize','MaxNumSplits'}, ...
    "HyperparameterOptimizationOptions", ...
    struct(...
    "Optimizer", "bayesopt",...
    "AcquisitionFunctionName","expected-improvement-per-second-plus", ...
    "MaxObjectiveEvaluations", maxObjectiveEvaluations,...
    'CVPartition', crossValidationSettings, ...
    "Repartition", false,...
    "UseParallel", true));

%% Save all the optimized hyperparameters
bestHyperparameters = cell(1,4);
bestHyperparameters{1,1} = lsboost_settings_optimized.ModelParameters.NLearn;
bestHyperparameters{1,2} = lsboost_settings_optimized.ModelParameters.LearnRate;
modelParams = ...
    struct(lsboost_settings_optimized.ModelParameters.LearnerTemplates{1,1});
bestHyperparameters{1,3} = modelParams.ModelParams.MinLeaf;
bestHyperparameters{1,4} = modelParams.ModelParams.MaxSplits;

bestHyperparameters = cell2table(bestHyperparameters,'VariableNames',...
   {'NumLearningCycles','LearnRate','MinLeafSize','MaxNumSplits'}); 

%% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
ensemblePredictFcn = @(x) predict(lsboost_settings_optimized, x);
trainedModel.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));

%% Add additional fields to the result struct
trainedModel.RequiredVariables = trainingDataset.Properties.VariableNames;
trainedModel.RegressionEnsemble = lsboost_settings_optimized;
trainedModel.About = 'This struct is a lsboost optimized trained model.';
trainedModel.HowToPredict = ...
    sprintf(['To make predictions on a new table, T, use: ' ...
    '\n  yfit = trainedModel.predictFcn(T) \n' ...
    '\n \nThe table, T, must contain the variables returned by: ' ...
    '\n  trainedModel.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype)' ...
    ' must match the original training data. \nAdditional variables are ignored. ' ...
    '\n \nFor more information, ' ...
    'see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ' ...
    '''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.']);

%% Perform cross-validation with k = 5
partitionedModel = crossval(trainedModel.RegressionEnsemble, 'KFold', kFold);
validationPredictions = kfoldPredict(partitionedModel);

%% Compute features importance
featureImportance = predictorImportance(lsboost_settings_optimized);
featuresImportanceTable = table('Size', [width(predictorNames) 1], 'VariableTypes',...
    {'double'}, 'VariableNames', {'score'},'RowNames', string(predictorNames'));
    featuresImportanceTable.score = featureImportance';
featuresImportanceTable = sortrows(featuresImportanceTable,'score','descend');
end