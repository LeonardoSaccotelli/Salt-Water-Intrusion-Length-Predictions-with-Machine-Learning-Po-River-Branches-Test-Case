%% Add to path subdirectory
addpath(genpath("data\"));
addpath(genpath("utils\"));
addpath(genpath("model\"));
addpath(genpath("result\"));

%% Check if datasets exist
try
    load("data\final\training_test_dataset_compact.mat");
catch ME
    if (strcmp(ME.identifier,'MATLAB:load:couldNotReadFile'))
          msg = ['Unable to find file or directory "data\\final\\training_test_dataset_compact.mat".\n'...
              'Please run "prepare_dataset_for_experiment.m" before "run_experiment_EstuarIO_All_Branch.m"'];
            causeException = MException('MATLAB:load:couldNotReadFile',msg);
            ME = addCause(ME,causeException);
   end
       rethrow(ME)
end

%% If datasets exist, then load e run the experiments
fprintf("------------------------------------------------\n" + ...
    "The following datasets have been loaded: \n\n")
disp(storedDataset);
fprintf("------------------------------------------------\n");

%% Define the cell array and table to store all the experimental results
algorithmNames = {'RF', 'LSBoost'};
nAlgorithm = numel(algorithmNames);
nBranch = height(storedDataset);
experimentalResults = cell(nBranch, 3);

%% Setting parameters for experiment
% Set target feature 
targetFeatureName = "LxObs";

% Set maxObjectiveEvaluations as maximum number of objective functions to
%  be evaluated in the optimization process
maxObjectiveEvaluations = 2;

% Set k to be use in k-fold cross validation
kfold = 5;

%% d
for i = 1:nBranch
    j = 1;
    branchResults = cell(nAlgorithm, 7);
    branchName = storedDataset.Branch(i);

    trainingDataset = storedDataset.TrainingDataset{i};
    trainingPredictionResult = trainingDataset(:,["ID","Date","Doy","BranchName","DatasetType","LxObs"]);

    testDataset = storedDataset.TestDataset{i};
    testPredictionResult = testDataset(:,["ID","Date","Doy","BranchName","DatasetType","LxObs"]);

    %% Run the ML training process with Random Forest
    fprintf("================================================================\n");
    fprintf(strcat("Training ",algorithmNames(j), " on: ", branchName, " branch \n"));
    fprintf("================================================================\n");
    
    [branchResults, j, trainingPredictions, testPredictions] = ...
        run_ML_algorithm( ...
        @random_forest_function, ...
        algorithmNames(j), ...
        trainingDataset(:,["Qriver","Qtidef","Qll","Sll","LxObs"]), ...
        testDataset, ...
        targetFeatureName, ...
        maxObjectiveEvaluations, ...
        kfold, ...
        branchResults, ...
        j);
    
    trainingPredictionResult.RFPredictions = trainingPredictions;
    testPredictionResult.RFPredictions = testPredictions;

    %% Run the ML training process with LSBoost
    fprintf("================================================================\n");
    fprintf(strcat("Training ",algorithmNames(j), " on: ", branchName, " branch \n"));
    fprintf("================================================================\n");

    [branchResults, j, trainingPredictions, testPredictions] = ...
        run_ML_algorithm( ...
        @lsboost_function, ...
        algorithmNames(j), ...
        trainingDataset(:,["Qriver","Qtidef","Qll","Sll","LxObs"]), ...
        testDataset, ...
        targetFeatureName, ...
        maxObjectiveEvaluations, ...
        kfold, ...
        branchResults, ...
        j);

    trainingPredictionResult.LSBoostPredictions = trainingPredictions;
    testPredictionResult.LSBoostPredictions = testPredictions;

    mlPredictions = [trainingPredictionResult; testPredictionResult];
    mlPredictions = sortrows(mlPredictions,"ID");

    branchResults = cell2table(branchResults, "VariableNames",["ModelName", ...
        "Model", "BestHyperparametrs", "TrainingEvaluation", ...
        "TestEvaluation", "PWBTable", "FeatureImportance"]);

    experimentalResults{i,1} = storedDataset{i,"Branch"};
    experimentalResults{i,2} = branchResults;
    experimentalResults{i,3} = mlPredictions;

    close all
end

experimentalResults = cell2table(experimentalResults, "VariableNames", ["Branch", "Experiment", "MLPredictions"]);
clc

%% Show the results of the ML models
for i = 1:nBranch
    display_ml_results(experimentalResults, experimentalResults.Branch(i));
end


%% Save the experiment result
save("result\experiment_result_EstuarIO.mat","experimentalResults");
fprintf("Result stored in 'result\\experiment_result_EstuarIO.mat'\n" + ...
    "----------------------------------------------------------------\n");

%% Function to run a single ML algorithm and store the results
function [branchResults, j, trainingPredictions, testPredictions] = ...
    run_ML_algorithm (mlAlg, mlAlgName, trainingDataset, testDataset, targetFeatureName, maxObjectiveEvaluations, kfold, branchResults, j)
   
    % train the model with hyperparameters optimization
    [model, trainingPredictions, bestHyperparameters, featuresImportanceTable] = ...
        mlAlg(trainingDataset(:,["Qriver","Qtidef","Qll","Sll","LxObs"]), ...
        targetFeatureName, maxObjectiveEvaluations, kfold);
    
    % test the model on test dataset
    testPredictions = model.predictFcn(testDataset);
    
    % store all the results
    branchResults{j,1} = mlAlgName;
    branchResults{j,2} = model;
    branchResults{j,3} = bestHyperparameters;
    branchResults{j,4} = compute_metrics(trainingDataset(:, targetFeatureName), trainingPredictions, mlAlgName);
    branchResults{j,5} = compute_metrics(testDataset(:, targetFeatureName), testPredictions, mlAlgName);
    branchResults{j,6} = create_pwb_table(testDataset(:, targetFeatureName), testPredictions, mlAlgName);
    branchResults{j,7} = featuresImportanceTable;
    
    j = j+1;
end


%% Function to display the results
function display_ml_results (experimentalResults, branchName)
    experiment = experimentalResults(experimentalResults.Branch == branchName, :);
    experiment = experiment.Experiment{1,1};  
    
    fprintf("================================================================\n");
    fprintf(strcat("Results on: ", branchName, " branch\n"));
    fprintf("================================================================\n");
    
    fprintf("Performance on training dataset: \n");
    fprintf("----------------------------------------------------------------\n");
    t = table();
    for j = 1: height(experiment)
        t = [t; experiment.TrainingEvaluation(j,["RMSE","MAE","Corr Coeff"])];
    end
    disp(t)

    fprintf("================================================================\n");
    fprintf("Performance on test dataset: \n");
    fprintf("----------------------------------------------------------------\n");
    t = table();
    for j = 1: height(experiment)
        t = [t; experiment.TestEvaluation(j,["RMSE","MAE","Corr Coeff"])];
    end
    disp(t)

    fprintf("================================================================\n");
    fprintf("PWB Table on test dataset: \n");
    fprintf("----------------------------------------------------------------\n");
    t = table();
    for j = 1: height(experiment)
        t = [t experiment.PWBTable{j,1}];
    end
    disp(t)
    fprintf("================================================================\n");
end