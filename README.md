# The Stanford BPSM Automation Toolbox

The Stanford BPSM Automation toolbox isa library to automate the creation, modification, and running of models used in the Schlumberger PetroMod software.

## What can be done with the library?
- A template PetroMod project can be loaded into Matlab. 
- Lithologies can be duplicated, mixed, modified, and deleted. 
- Models can be duplicated, deleted, and simulated directly from Matlab. 
- 1D, 2D, and 3D models can be modified.
- Custom open simulator scripts can be ran (OpenSimulator license is required)

## How to start?
- Create your PetroMod 2017.2 or newer "template project" (recent older versions should work too).
- Create your output script in python to export output if needed (see below).
- Simulate your template project and make sure everything works.
- See the "main.m" for the procedure to load your template project in Matlab, modify parameters, duplicate models and simulate them in Matlab.

## Tips?
- Save your PetroMod project in a folder that does not require administrator privileges.
- It is better to create all the required lithologies in one go before updating the project as writing the lithology files takes relatively long time (a couple of seconds), i.e., do not update the project in a for loop.
- If you are using lithology mixing, it is better to make sure everything is consistant by creating some mixes manually and comparing it to the mixes created by Matlab.
- Some parameters are internally saved with different unit than the one that is displayed in the PetroMod GUI.

## What is next?
The basic framework is implemented now. The whole process can be automated in Matlab. Feature addition is on hold for now and new features will be added as needed. If you have suggestions, bugs, or feedback, please contact me through Github or Email. I would love to hear from you. What are the functionalities that you use the most? What are the things that you cannot do with it? Do you have a bug to report? You can create an Issue on GitHub or reach me directly at Mustafa.Geoscientist@outlook.com

## This is input, how about output?
- Check out scripts folder in PetroMod (e.g., "C:\Program Files\Schlumberger\PetroMod 2016.2\scripts"). You will need to write your own scripts that export your specific needed data automatically after the simulator.
- To activate your script, in the Simulator window, choose "Output", "Open Simulator" and select your script. Make sure your script run in the template project. Save the simulator window.
- Another option is to run the written script directly from matlab as given in the example file.

## Referencing this work
