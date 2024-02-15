function singlethreadedmedipicas = importfile(filename, dataLines)


% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [1, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 14);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ["\t", "   ", ",", ":", "=", "[", "]", "ms"];

% Specify column names and types
opts.VariableNames = ["Statistics", "data", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14"];
opts.SelectedVariableNames = ["Statistics", "data"];
opts.VariableTypes = ["categorical", "double", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";

% Specify variable properties
opts = setvaropts(opts, ["Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Statistics", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "data", "ThousandsSeparator", ",");

% Import the data
singlethreadedmedipicas = readtable(filename, opts);

end