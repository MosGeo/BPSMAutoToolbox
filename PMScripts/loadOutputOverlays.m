function [data, layerNames, units] = loadOutputOverlays(modelName, nDim, PM, overlayNumbers)

scriptFolder = fullfile(fileparts(fileparts(PM.PMDirectory)), 'scripts');

data = []; 
layerNames=[];
for iLayer = 1:numel(overlayNumbers)
    [cmdout, status] = PM.runScript(modelName, nDim, 'demo_opensim_output_3rd_party_format', num2str(overlayNumbers(iLayer)), false, false, scriptFolder);
    if PM.version >= 2018
        outputFileName =  fullfile(PM.getModelFolder(modelName, nDim),'out','demo_1.txt') ;
    else
        outputFileName = 'demo_1.txt';
    end
    [id, value, layer, unit] = readDemoScriptOutput(outputFileName, true);  
    data = [data, value];
    layerNames{iLayer} = layer;
    units{iLayer} = unit;
end

end