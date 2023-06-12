%RUN_STATISTICAL_ANALYSIS This script create some statistical plot on the available dataset.

%% Add to path subdirectory
addpath(genpath("data\"));
addpath(genpath("utils\"));

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

%% Retrive dataset
all_dataset = sortrows([storedDataset.TrainingDataset{5,1}; ...
    storedDataset.TestDataset{5,1}], 1);
all_dataset = all_dataset(:,["BranchName","Qll","Qriver","Qtidef","Sll","LxObs"]);

%% Plot boxchart
plot_boxplot_by_branch(all_dataset);

%% Plot corrplot
figure;
corrplot(all_dataset(:,2:6));

%% Function to plot a boxchart
function [] = plot_boxplot_by_branch (dataset)
    n_feat = width(dataset);
    f = figure;
    f.Position = [0 0 1150 954];
    t = tiledlayout(3,2);
    
    for i = 2:n_feat
        nexttile;
        boxchart(categorical(table2array(dataset(:,1))), table2array(dataset(:,i)));
        title(dataset.Properties.VariableNames(i));
    end
    title(t,"Boxplot of input and output features for ALL branches");
end