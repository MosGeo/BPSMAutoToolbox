function [id, value, layer, unit] = readDemoScriptOutput(fileName)
%% READDEMOSCRIPTOUTPUT   Read demo script output
%
% filename:                 Filename
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Assertions
assert(exist('fileName', 'var')== true && exist(fileName, 'file') == 2, 'Valid filename must be provided');

%% Main


rawData = importdata(fileName, ' ', 8);

layer = strsplit(rawData.textdata{5},': ');
layer = layer{2};

unit = strsplit(rawData.textdata{6},': ');
unit = unit{2};

[id] = rawData.data(:,1);
[value] = rawData.data(:,2);



end