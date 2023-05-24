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

