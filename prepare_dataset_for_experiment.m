%% Add to path subdirectory
addpath(genpath("data\"));
addpath(genpath("utils\"));

%% Set import dataset settings
% load dataset
filepath = "data\final\Lx_Dataset_EstuarIO_Final_Training_Test_Data.xlsx";
nVars = 10;
dataRange = ["A2:J31", "A2:J21", "A2:J17", "A2:J20", "A2:J86"];
sheetName = ["GORO", "GNOCCA", "TOLLE", "DRITTA", "ALL"];
varNames = ["ID","Date","Doy", "BranchName", "Qriver", "Qll", "Qtidef", "Sll", "LxObs", "DatasetType"]; 
varTypes = ["int16","datetime","int16", "string", "double", "double", "double","double","double","string"];

% define the cell array to store all the dataset 
nrows = numel(sheetName);
ncols = 3;
storedDataset = cell(nrows, ncols);

%% Read the dataset
% for each sheet (branch), read the data, split into training and test,
% store in the cell array 
for i = 1:nrows
    dataset = import_dataset(filepath, nVars, dataRange(i), sheetName(i), varNames, varTypes);
    trainingDataset = dataset(dataset.DatasetType=="TRAINING",:);
    testDataset = dataset(dataset.DatasetType=="TEST",:);
    storedDataset{i,1} = sheetName(i);
    storedDataset{i,2} = trainingDataset;
    storedDataset{i,3} = testDataset;
end

% cast the cell array into a table
storedDataset = cell2table(storedDataset,'VariableNames', {'Branch', 'TrainingDataset', 'TestDataset'});

%% Save the compact table with all data
save('data/final/training_test_dataset_compact.mat','storedDataset');
fprintf("----------------------------------------------------------------\n" + ...
    "Dataset stored in 'data/final/training_test_dataset_compact.mat'\n");