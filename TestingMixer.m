%% Testing mixer

clear

% Define parameters (NEED TO BE UPDATED TO MATCH YOUR PC LOCATION)
PMDirectory = 'C:\Program Files\Schlumberger\PetroMod 2018.2\WIN64\bin';
PMProjectDirectory = 'C:\Users\malibrah\Desktop\T18';

% Open the project
PM = PetroMod(PMDirectory, PMProjectDirectory);

% Check the current parameter of the lithology
PM.loadLithology()
lithoInfo = PM.Litho.getLithologyInfo('Sandstone (typical)');
[PetroModId, id]   = PM.Litho.getLithologyId('Shale (typical)');

mixer = LithoMixerMos('H');
sourceLithologies = {'Sandstone (typical)','Shale (typical)'};
fractions         = [.6, .4];
distLithoName     = 'MosMix';
PM.Litho.mixLitholgies(sourceLithologies, fractions, distLithoName, mixer);

lithoInfo1 = PM.Litho.getLithologyInfo(distLithoName);
lithoInfo2 = PM.Litho.getLithologyInfo('Default');
lithoInfo2 = PM.Litho.getLithologyInfo('DefaultII');
lithoInfo2 = PM.Litho.getLithologyInfo('Sandstone (typical)');

PM.saveLithology();
PM.restoreProject();
