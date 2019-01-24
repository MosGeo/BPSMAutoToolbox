function [data, layerNames] = loadOutputOverlays(modelName, nDim, PM, overlayNumbers)

scriptFolder = fullfile(fileparts(fileparts(PM.PMDirectory)), 'scripts');

data = []; 
layerNames=[];
for iLayer = 1:numel(overlayNumbers)
    [cmdout, status] = PM.runScript(modelName, nDim, 'demo_opensim_output_3rd_party_format', num2str(overlayNumbers(iLayer)), false, false, scriptFolder); 
    [id, value, layer, unit] = readDemoScriptOutput('demo_1.txt');
    delete demo_1.txt
    data = [data, value];
    layerNames{iLayer} = layer;
end

end