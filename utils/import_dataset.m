function [dataset] = import_dataset(filepath, nVars, dataRange, sheetName, varNames, varTypes)
%IMPORT_DATASET This function is used to read dataset from an xlsx file and save in into a table.
%   Input: 
%   1) filepath:
%   Path of dataset
%   
%   2) nVars:
%   Number of variables in the table
%
%   3) dataRange:
%   Start and ending range of excel file
%
%   4) sheetName:
%   Name of sheet from which to read the data
%
%   5) varNames:
%   Name of variables in the table
%   
%   6) varTypes:
%   Datatype of each variables
%
%   Output:
%   1) dataset:
%   The table read from the path

opts = spreadsheetImportOptions("NumVariables", nVars);

% Specify sheet and range
opts.DataRange = dataRange;
opts.Sheet = sheetName;

% Specify column names and types
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

% Specify variable properties
opts = setvaropts(opts, varNames, "EmptyFieldRule", "auto");

% Import the data
dataset = readtable(filepath, opts, "UseExcel", false);
end