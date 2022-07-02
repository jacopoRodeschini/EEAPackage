function  timeseries = EEAImportfile(filename,TimeZone, dataLines)
%IMPORTFILE Import data from a text file
% Dosent remove nan value;

%% Input handling

% % If dataLines is not specified, define defaults
% if nargin < 2
%     dataLines = [1, Inf];
% end
% 
% %% Set up the Import Options and import the data
% % Specify range and delimiter
% 
% opts = delimitedTextImportOptions("NumVariables", 17);
% 
% % Specify column names and types
% opts.VariableNames = ["Countrycode", "Namespace", "AirQualityNetwork", "AirQualityStation", "AirQualityStationEoICode", "SamplingPoint", "SamplingProcess", "Sample", "AirPollutant", "AirPollutantCode", "AveragingTime", "Concentration", "UnitOfMeasurement", "DatetimeBegin", "DatetimeEnd", "Validity", "Verification"];
% opts.SelectedVariableNames = ["Countrycode", "AirQualityStation", "SamplingPoint", "AirPollutant", "Concentration", "DatetimeBegin", "DatetimeEnd", "Validity", "Verification"];
% opts.VariableTypes = ["categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "string", "categorical", "double", "string", "datetime", "datetime", "double", "double"];
% 
% % Specify variable properties
% 
% opts = setvaropts(opts, ["Countrycode", "Namespace", "AirQualityNetwork", "AirQualityStation", "AirQualityStationEoICode", "SamplingPoint", "SamplingProcess", "Sample", "AirPollutant", "AirPollutantCode", "AveragingTime", "UnitOfMeasurement"], "EmptyFieldRule", "auto");
% opts = setvaropts(opts, ["AirPollutantCode", "UnitOfMeasurement"], "WhitespaceRule", "preserve");
% opts = setvaropts(opts, "DatetimeBegin", "InputFormat", "yyyy-MM-dd HH:mm:ss +01:00");
% opts = setvaropts(opts, "DatetimeEnd", "InputFormat", "yyyy-MM-dd HH:mm:ss +01:00");
% opts = setvaropts(opts, ["Concentration", "Validity", "Verification"], "ThousandsSeparator", ",");
% 
% % Specify range and delimiter
% opts.DataLines = [2, Inf];
% opts.Delimiter = ["\t", ","];
% 
% % Specify file level properties
% opts.ExtraColumnsRule = "ignore";
% opts.EmptyLineRule = "read";
% opts.ConsecutiveDelimitersRule = "join";

% Specify file level properties
%opts.ImportErrorRule = "omitrow";
%opts.MissingRule = "omitrow";
%opts.ExtraColumnsRule = "ignore";
%opts.EmptyLineRule = "read";
%opts.ConsecutiveDelimitersRule = "join";

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 3
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 17);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ["\t", ","];

% Specify column names and types
opts.VariableNames = ["Countrycode", "Var2", "Var3", "AirQualityStation", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Concentration", "Var13", "Var14", "DatetimeEnd", "Validity", "Verification"];
opts.SelectedVariableNames = ["Countrycode", "AirQualityStation", "Concentration", "DatetimeEnd", "Validity", "Verification"];
opts.VariableTypes = ["categorical", "string", "string", "categorical", "string", "string", "string", "string", "string", "string", "string", "double", "string", "datetime", "datetime", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var2", "Var3", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var13"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Countrycode", "Var2", "Var3", "AirQualityStation", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var13"], "EmptyFieldRule", "auto");
% opts = setvaropts(opts, "DatetimeBegin", "InputFormat", "yyyy-MM-dd HH:mm:ss +01:00");
opts = setvaropts(opts, "DatetimeEnd", "InputFormat", "yyyy-MM-dd HH:mm:ss xxx",'TimeZone',TimeZone); 

 

% Import the data
timeseries = readtable(filename, opts);

end
