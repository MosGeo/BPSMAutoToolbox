% Mustafa Al Ibrahim @ 2018, Stanford BPSM
% Email:    Mustafa.Geoscientist@outlook.com
% Linkedin: https://www.linkedin.com/in/mosgeo/ 

clear all

% Define parameters (NEED TO BE UPDATED TO MATCH YOUR PC LOCATION)
PMDirectory = 'C:\Program Files\Schlumberger\PetroMod 2018.2\WIN64\bin';
PMProjectDirectory = 'C:\Users\Musta\Documents\GitHub\BPSMAutoToolbox\Workshop\PM18 Workshop Project\';

nDim = 1;   % is your model 1D, 2D, or 3D
templateModel = 'Workshop1D';
newModel      = 'UpdatedModel';

% Open the project
PM = PetroMod(PMDirectory, PMProjectDirectory);

% Check the current parameter of the lithology
PM.loadLithology()
lithoInfo = PM.Litho.getLithologyInfo('Shale (typical)');
[PetroModId, id]   = PM.Litho.getLithologyId('Shale (typical)');

% Get some parameters (works on both scaler and curve)
athysFactor = PM.Litho.getValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)')
heatCapacityCurve = PM.Litho.getValue('Sandstone (clay rich)', 'Heat Capacity Curve')

% Change some parameters (one scaler, and one curve)
PM.Litho.changeValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)', .4);
PM.Litho.changeValue('Sandstone (clay rich)', 'Heat Capacity Curve', [0 10; 10 100]);

% Dublicate lithology
%PM.Litho.dublicateLithology('Sandstone (clay rich)', 'Mos Lithology', 'MainGroup', 'SubGroup')
PM.Litho.duplicateLithology('Sandstone (clay rich)', 'Mos Lithology')

% Change lithology group of an existing lithology
PM.Litho.changeLithologyGroup('Mos Lithology', 'MainGroup', 'SubGroup')

% Delete lithology
PM.Litho.deleteLithology('Mos Lithology');

% Create a lithology mix
mixer = LithoMixer('H'); % H or V
sourceLithologies = {'Sandstone (typical)','Shale (typical)'};
fractions         = [.6, .4];
PM.Litho.mixLitholgies(sourceLithologies, fractions, 'MosMix' , mixer);

% Update lithology file (needed if you change the lithology file)
PM.saveLithology();

% Create a new model and delete model
PM.duplicateModel(templateModel, newModel, nDim);

% Update model
% - See below (next cell)

% Simulate model
[output] = PM.simModel(newModel, nDim, true);

% Run a custom demo script
[cmdout, status] = PM.runScript(newModel, nDim, 'demo_opensim_output_3rd_party_format', '4', true);

% Run a custom script by in a none standard script folder (requires Open Simulator license)
scriptFolder   = 'C:\Users\Musta\Documents\GitHub\BPSMAutoToolbox\Source\PMScripts';
scriptName     = 'TestScript';
scriptArgument = '';
[cmdout, status] = PM.runScript(newModel, nDim, scriptName, scriptArgument, true, false, scriptFolder);

% Special scripts to get data from output based on demo script
[cmdout] = getAvailableOverlays(newModel, nDim, PM);
overlayNumbers = [4,5, 6];
[data, layerNames] = loadOutputOverlays(newModel, nDim, PM, overlayNumbers);

% Delete model
PM.deleteModel(newModel, nDim);

% Restore lithology file (does not restore models)
PM.restoreProject();

%% Model Operations (1D)

% Load Model
model = Model1D('Workshop1D', PMProjectDirectory);

% Get the names of data tables
model.getTableNames()

% Update the some table data (matrix table) and check if it is updated
model.printTable('Heat Flow');
data = model.getData('Heat Flow');
data(:,2) = data(:,2)*2;
model.updateData('Heat Flow', data);
model.printTable('Heat Flow');

% Some tables have some titles, you can just give the update data the key
% (title) of the updated value to update it. Or you can get all the data
% and update it manually and then pass it without the key as above
model.printTable('Simulation');
model.updateData('Simulation', [20 30], 'Oeve');
model.printTable('Simulation');

% Update the model and to the files
model.updateModel();

model.printTable('Main');
data = model.getData('Main');

%% Model Operations (2D)

% Load Model
model = Model2D('Structural2D', PMProjectDirectory);

% Get the names of data tables
model.getTableNames()

% Update the some table data (matrix table) and check if it is updated
model.printTable('SWIT Trend');
data = model.getData('SWIT Trend');
data(:,3) = data(:,3) + 10;
model.updateData('SWIT Trend', data);
model.printTable('SWIT Trend');

% Maps (vectors in 2D). In 3D they are surfaces reshaped as vectors
data = model.getData('Heat Flow Map');
data(:,300:400) = data(:,300:400) + 500;
model.updateData('Heat Flow Map', data);

% Update the model and to the files
model.updateModel();

