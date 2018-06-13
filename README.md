# The Stanford BPSM Petromod Toolbox

This is an effort to automate creation and modification of models used in the Schlumberger PetroMod software. 
Currently, it is focused on modifying the lithologies.

## What has been done?
- A project is loaded into Matlab. 
- Lithologies can be modified (addition of new lithologies will be implemented next). Lithology mixer is mostly working. 
- Models can be duplicated, deleted, and simulated directly from Matlab. 
- 1D models can be modified.

## How to start
- Create your PetroMod 2017.1 "template project" (2016.2 should also work but I swtiched to testing on 2017.1 to increase the probablity of future compatiblity).
- Create your output script in python to export output if needed (see below).
- Simulate your template project and make sure everything works.
- See the "main.m" for the procedure to load your template project in Matlab, modify parameters, duplicate models and simulate them in Matlab.

## Tips
- Save your PetroMod project in a folder that does not require administrator privileges.
- It is better to create all the required lithologies in one go before updating the project as writing the lithology files takes relatively long time (a couple of seconds), i.e., do not update the project in a for loop.
- If you are using lithology mixing, it is better to make sure everything is consistant by create the some mixes manually and comparing it to the mixes created by Matlab.

## What is next?
The basic framework is implemented now and is validated. The whole process can be automated in Matlab.  I am going to start focusing on specific things that are needed for some of my research:

- Lithology mixer (mostly done)

## This is input, how about output?
- Check out scripts folder in PetroMod 2016.2 (e.g., "C:\Program Files\Schlumberger\PetroMod 2016.2\scripts"). You will need to write your own scripts that export your specific needed data automatically after the simulator.
- To activate your script, in the Simulator window, choose "Output", "Open Simulator" and select your script. Make sure your script run in the template project.
- Save the simulator window.

## This is great, but can I run this on a cluster?
Technically yes but I have not tested it. We need to install PetroMod on the cluster. Last time I was trying that with Best, we had lots of issues mainly because we do not have admin previlages to install required packages. I do not know the current status. Since then, I figured all the required packages and tested the procedure of installing it on linux in a desktop machine. The same workflow can be done in the cluster. You can see the "Linux PetroMod" folder in the BPSM folder for instructions on how to install PetroMod in Linux.
