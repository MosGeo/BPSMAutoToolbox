%% Testing mixer

clear all

% Define parameters (NEED TO BE UPDATED TO MATCH YOUR PC LOCATION)
PMDirectory = 'C:\Program Files\Schlumberger\PetroMod 2018.2\WIN64\bin';
PMProjectDirectory = 'C:\Users\malibrah\Desktop\T18';

% Open the project
PM = PetroMod(PMDirectory, PMProjectDirectory);

% Check the current parameter of the lithology
PM.loadLithology()
lithoInfo = PM.Litho.getLithologyInfo('Shale (typical)');
[PetroModId, id]   = PM.Litho.getLithologyId('Shale (typical)');

mixer = LithoMixer('H');
sourceLithologies = {'Sandstone (typical)','Shale (typical)'};
fractions         = [.6, .4];
PM.Litho.mixLitholgies(sourceLithologies, fractions, 'MosMix' , mixer);

PM.saveLithology();

