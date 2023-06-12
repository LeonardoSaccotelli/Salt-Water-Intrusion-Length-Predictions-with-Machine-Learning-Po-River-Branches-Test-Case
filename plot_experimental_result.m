%PLOT_EXPERIMENTAL_RESULT This script plot the results obtained by different ML models with all the different branches of Po River.

%% Add to path subdirectory
addpath(genpath("data\"));
addpath(genpath("utils\"));
addpath(genpath("model\"));
addpath(genpath("result\"));

%% Check if results exist
try
    load("result\experiment_result_EstuarIO.mat");
catch ME
    if (strcmp(ME.identifier,'MATLAB:load:couldNotReadFile'))
          msg = ['Unable to find file or directory "result\\experiment_result_EstuarIO.mat".\n'...
              'Please run "prepare_dataset_for_experiment.m" and "run_experiment_EstuarIO_All_Branch.m" '...
              'before "plot_experimental_result.m"'];
            causeException = MException('MATLAB:load:couldNotReadFile',msg);
            ME = addCause(ME,causeException);
   end
       rethrow(ME)
end

%% If results exist, then load e plot them
fprintf("------------------------------------------------\n" + ...
    "The following data have been loaded: \n\n")
disp(experimentalResults);
fprintf("------------------------------------------------\n");

algorithm_names = {'EBM', 'SVM', 'RF', 'LSBoost'};
response = 'LxObs';
nBranch = height(experimentalResults);

for i = 1:nBranch
    tb = experimentalResults.MLPredictions{i,1};
    if (experimentalResults.Branch(i) == "ALL")
        training_table_results = tb(tb.DatasetType == "TRAINING",["BranchName","LxObs", "EbmPredictions","SvmPredictions","RFPredictions","LSBoostPredictions"]);
        test_table_results = tb(tb.DatasetType == "TEST",["BranchName", "LxObs","EbmPredictions", "SvmPredictions","RFPredictions","LSBoostPredictions"]);

        create_perfect_fit(training_table_results,algorithm_names,true,30, strcat("Training on: Po ", experimentalResults.Branch(i)), true);
        create_perfect_fit(test_table_results,algorithm_names,true,30, strcat("Test on: Po ", experimentalResults.Branch(i)), true);
    else
        training_table_results = tb(tb.DatasetType == "TRAINING",["LxObs", "EbmPredictions","SvmPredictions","RFPredictions","LSBoostPredictions"]);
        test_table_results = tb(tb.DatasetType == "TEST",["LxObs","EbmPredictions","SvmPredictions", "RFPredictions","LSBoostPredictions"]);
        create_perfect_fit(training_table_results,algorithm_names,true,30, strcat("Training on: Po ", experimentalResults.Branch(i)), false);
        create_perfect_fit(test_table_results,algorithm_names,true,30, strcat("Test on: Po ", experimentalResults.Branch(i)), false);
    end
end 