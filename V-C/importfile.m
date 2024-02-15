function overheaddebug = importfile1(filename, dataLines)
%IMPORTFILE1 Import data from a text file
%  OVERHEADDEBUG = IMPORTFILE1(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the data as a table.
%
%  OVERHEADDEBUG = IMPORTFILE1(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  overheaddebug = importfile1("/home/daniel/Dropbox/UCR/rtenlab/emsoft_revision/overhead/overhead_debug.csv", [1, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 29-Oct-2023 14:36:16

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [1, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Var1", "time"];
opts.SelectedVariableNames = "time";
opts.VariableTypes = ["string", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Var1", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Var1", "EmptyFieldRule", "auto");

% Import the data
overheaddebug = readtable(filename, opts);

end