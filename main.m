clear all

% Define parameters
petroModFolder = 'C:\Program Files\Schlumberger\PetroMod 2016.2\WIN64\bin';
projectFolder = 'C:\Users\malibrah\Desktop\TestPetromod2';

nDim = 2;   % is your model 1D, 2D, or 3D
templateModel = 'LayerCake2';
newModel ='UpdatedModel';

% Open the project and create a new Model
PM = PetroMod(petroModFolder, projectFolder);

% Check the current parameter of the lithology
PM.Lithology.getLithologyInfo('Sandstone (clay rich)')

% Change some parameters (one scaler, and one curve)
PM = PM.changeLithoValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)', 0.49);
PM = PM.changeLithoCurve('Sandstone (clay rich)', 'Heat Capacity Curve', [0 10; 10 100]);
PM.updateProject();

% Create a new model and simulate
PM.copyModel(templateModel, newModel, nDim);
[output] = PM.simModel(newModel, nDim, true);