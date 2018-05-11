clear all
% Define the template file
lithoFileName = 'Lithologies.xml';

% Read the lithology file
LithoFile = LithologyFile(lithoFileName);

% Write the lithology file
LithoFile.writeLithologyFile('OutputTest.xml')

%% Running a PetroMod model

petroModFolder = 'C:\Program Files\Schlumberger\PetroMod 2016.2\WIN64\bin';
projectFolder = 'C:\Users\malibrah\Desktop\TestPetromod2';

nDim = 2;
modelsToRun = {'LayerCake'};

i = 1;
hermesFileName  = fullfile(petroModFolder, 'hermes.exe');
modelFileName   = fullfile(projectFolder,['pm', num2str(nDim), 'd'], modelsToRun{i});
commandToRun    = ['"' hermesFileName '" -model "' modelFileName '"'];
[status,cmdout]  = system(commandToRun, '-echo');

