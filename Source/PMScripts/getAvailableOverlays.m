function [cmdout] = getAvailableOverlays(modelName, nDim, PM)
% Mustafa Al Ibrahim @ 2018, Stanford BPSM
% Email:    Mustafa.Geoscientist@outlook.com
% Linkedin: https://www.linkedin.com/in/mosgeo/ 

scriptFolder = fullfile(fileparts(fileparts(PM.PMDirectory)), 'scripts');
scriptName   = 'demo_opensim_output_3rd_party_format'; 
[cmdout, status] = PM.runScript(modelName, nDim, scriptName, '100000', false, false, scriptFolder);

end