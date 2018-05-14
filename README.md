# The Stanford BPSM Petromod Toolbox

This is an effort to automate creation and modification of models used in the Schlumberger PetroMod software. 
Currently, it is focused on modifying the lithologies.

## What has been done?
A project is loaded into Matlab. Lithologies can be modified (addition of new lithologies will be implemented next). Models can be duplicated and simulated directly from Matlab.

## How to start
- Create your "template project"
- Simulate your template project and make sure it works.
- See the "main.m" for the procedure to load your template project in Matlab, modify parameters, duplicate models and simulate them in Matlab.

## What is next?
The basic framework is implemented now and is validated. The whole process can be automated in Matlab.  I am going to start focusing on specific things that are needed for some of my research:

- The ability to add new lithologies. 
- The ability to define "main input" in 1D model.

## This is input, how about output?
- Check out scripts folder in PetroMod 2016.2 (e.g., "C:\Program Files\Schlumberger\PetroMod 2016.2\scripts"). You will need to write your own scripts that export your specific needed data automatically after the simulator.
- To activate your script, in the Simulator window, choose "Output", "Open Simulator" and select your script. Make sure your script run in the template project.
- Save the simulator window.
