function [petroModIds, ids] = patchMixer(fractions, sourceLithologies, PM, mixerType, outputPrefix, groupName, subGroupName)
%% PATCHMIXER   Create multiple lithologies from fraction table
%
% fractions:                Fractions (each row is one rock, i.e. add up to 1)
% lithologyNames:           Lithology name for each column in fractions
% PM:                       PetroModObject
% groupName:                Main group name
% subGroupName:             Subgroup name
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('groupName' , 'var'); groupName = 'BPSMToolBox'; end
if ~exist('subGroupName', 'var'); subGroupName = 'PatchMixer'; end
if ~exist('mixerType', 'var'); mixerType = 'H'; end
if ~exist('outputPrefix', 'var'); outputPrefix = 'Litho'; end

% Assertions
assert(exist('fractions', 'var')== true && isnumeric(fractions), 'fractions must be a numeric matrix');
assert(exist('sourceLithologies', 'var')== true, 'sourceLithologies must be provided');
assert(iscell(sourceLithologies) && all(cellfun(@ischar, sourceLithologies)), 'sourceLithologies must be a cell array of strings');
assert(isa(PM, 'PetroMod'), 'PM must be a PetroMod object');
assert(size(fractions,2) == numel(sourceLithologies), 'Number of columns in fractions must be equal to number of source lithologies');
assert(mixerType=='H' || mixerType == 'V', 'mixerType must be H or V');
assert(ischar(outputPrefix), 'outputPrefix must be a string');
assert(~isempty(PM.Litho), 'Load lithology file first');

%% Main

% Get the number of rocks
nRocks = size(fractions,1);

% Initialize the output
petroModIds = cell(nRocks,1);
ids = cell(nRocks,1);

mixer = LithoMixer(mixerType);

% Go over rocks and create them,
for i = 1:nRocks
    
  rockName = [outputPrefix, '_' , num2str(i)];
  fractionsUsed = fractions(i,:)/ sum(fractions(i,:));
  PM.Litho.mixLitholgies(sourceLithologies, fractionsUsed, rockName , mixer);
  PM.Litho.changeLithologyGroup(rockName, groupName, subGroupName)
  [PetroModId, id]   = PM.Litho.getLithologyID(rockName);
  petroModIds{i} = PetroModId;
  ids{i} = id;
  
end



end