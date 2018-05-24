clear all

% Define parameters
petroModFolder = 'C:\Program Files\Schlumberger\PetroMod 2016.2\WIN64\bin';
projectFolder = 'C:\Users\malibrah\Desktop\TestPetromod2';

nDim = 1;   % is your model 1D, 2D, or 3D
templateModel = 'M1D';
newModel ='UpdatedModel';

% Open the project
PM = PetroMod(petroModFolder, projectFolder);

% Check the current parameter of the lithology (curves are showed as id)
PM.Litho.getLithologyInfo('Sandstone (clay rich)')

% Get some parameters (works on both scaler and curve)
athysFactor = PM.Litho.getValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)')
heatCapacityCurve = PM.Litho.getValue('Sandstone (clay rich)', 'Heat Capacity Curve')

% Change some parameters (one scaler, and one curve)
PM.Litho.changeValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)', .9);
PM.Litho.changeValue('Sandstone (clay rich)', 'Heat Capacity Curve', [0 10; 10 100]);

% Add and delete lithology
PM.Litho.dublicateLithology('Sandstone (clay rich)', 'Mos Lithology7')
PM.Litho.deleteLithology('Mos Lithology');

% Update lithology file 
PM.updateProject();

% Curves
petroModIds = PM.Litho.curve.getPetroModId();


% Create a new model and simulate
PM.copyModel(templateModel, newModel, nDim);
[output] = PM.simModel(newModel, nDim, true);

% Restore lithology file (does not restore models)
PM.restoreProject();
