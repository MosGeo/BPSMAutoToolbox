function [id, value, layer, unit, status] = readDemoScriptOutput(fileName, isDeleteFile, isReportFailure)
%% READDEMOSCRIPTOUTPUT   Read demo script output
%
% filename:                 Filename
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('isDeleteFile', 'var'); isDeleteFile = true; end
if ~exist('isReportFailure', 'var'); isReportFailure = false; end

% Assertions
assert(exist('fileName', 'var')== true, 'Valid filename must be provided');

%% Main

if exist(fileName, 'file') ~= 2
    if (isReportFailure==true)
        status = false;
        id = []; value = []; layer = []; unit = [];
        return
    else
        error('Valid filename must be provided');
    end
end

rawData = importdata(fileName, ' ', 8);

layer = strsplit(rawData.textdata{5},': ');
layer = layer{2};

unit = strsplit(rawData.textdata{6},': ');
unit = unit{2};

[id] = rawData.data(:,1);
[value] = rawData.data(:,2);

% Delete file
if isDeleteFile
    delete(fileName);
end

status = true; 

end