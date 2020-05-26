function [cmdout] = getAvailableOverlays(modelName, nDim, PM)

scriptFolder = fullfile(fileparts(fileparts(PM.PMDirectory)), 'scripts');
[cmdout, status] = PM.runScript(modelName, nDim, 'demo_opensim_output_3rd_party_format', '100000', false, false, scriptFolder);

end