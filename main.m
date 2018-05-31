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
lithoInfo = PM.Litho.getLithologyInfo('Shale (typical)')

% Get some parameters (works on both scaler and curve)
athysFactor = PM.Litho.getValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)')
heatCapacityCurve = PM.Litho.getValue('Sandstone (clay rich)', 'Heat Capacity Curve')

% Change some parameters (one scaler, and one curve)
PM.Litho.changeValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)', .7);
PM.Litho.changeValue('Sandstone (clay rich)', 'Heat Capacity Curve', [0 10; 10 100]);

% Add and delete lithology
PM.Litho.dublicateLithology('Sandstone (clay rich)', 'Mos Lithology')
PM.Litho.deleteLithology('Mos Lithology');

% Create a lithology mix
PM.Litho.deleteLithology('MosMix');
mixer = LithoMixer('H');
sourceLithologies = {'Sandstone (typical)','Shale (typical)'};
fractions         = [.5, .5];
PM.Litho.mixLitholgies(sourceLithologies, fractions, 'MosMix' , mixer);
lithoInfo = PM.Litho.getLithologyInfo('MosMix');

% Update lithology file (needed if you change the lithology file)
PM.updateProject();

% Create a new model and simulate
PM.copyModel(templateModel, newModel, nDim);
[output] = PM.simModel(newModel, nDim, true);

% Restore lithology file (does not restore models)
PM.restoreProject();

%% Load Model
model = Model1D(templateModel, projectFolder);

% Get the names of data tables
tableNames = model.getTableNames()

% Print whole table
model.printTable('Heat Flow');

% Update the some table data (matrix table) and check if it is updated
data = model.getData('Heat Flow')
data(1,2) = 300;
model.updateData('Heat Flow', data);
data = model.getData('Heat Flow')

% Update some other table data (cell table)
data = model.getData('Tools')
data{1,2} = 0
model.updateData('Tools', data);
data = model.getData('Tools')

model.updateModel();

