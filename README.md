# The Stanford BPSM Petromod Toolbox

This is an effort to automate creation and modification of models used in the Schlumberger PetroMod software.

## What has been done?
- A project is loaded into Matlab. 
- Lithologies can be duplicated, modified, and deleted. Lithology mixer is mostly working. 
- Models can be duplicated, deleted, and simulated directly from Matlab. 
- 1D models can be modified.
- Custom open simulator scripts can be ran (pending license issues)

## How to start
- Create your PetroMod 2017.1 "template project" (2016.2 should also work but I swtiched to testing on 2017.1 to increase the probablity of future compatiblity).
- Create your output script in python to export output if needed (see below).
- Simulate your template project and make sure everything works.
- See the "main.m" for the procedure to load your template project in Matlab, modify parameters, duplicate models and simulate them in Matlab.

## Tips
- Save your PetroMod project in a folder that does not require administrator privileges.
- It is better to create all the required lithologies in one go before updating the project as writing the lithology files takes relatively long time (a couple of seconds), i.e., do not update the project in a for loop.
- If you are using lithology mixing, it is better to make sure everything is consistant by create the some mixes manually and comparing it to the mixes created by Matlab.
- Some parameters are internally saved with different unit than the one that is displayed in PetroMod

## What is next?
The basic framework is implemented now. The whole process can be automated in Matlab. Feature addition is on hold for now. I a going to focus on using the framework for my research. At the same time, I will be cleaning, organizing, refactoring, and commenting the code. 

## This is input, how about output?
NOTE: current Stanford license does not support custom scripts.
- Check out scripts folder in PetroMod 2016.2 (e.g., "C:\Program Files\Schlumberger\PetroMod 2016.2\scripts"). You will need to write your own scripts that export your specific needed data automatically after the simulator.
- To activate your script, in the Simulator window, choose "Output", "Open Simulator" and select your script. Make sure your script run in the template project. Save the simulator window.
- Another option is to run the written script directly from matlab as given in the example file.

## Are you using this code?
I would love to hear from you. What are the functionalities that you use the most? What are the things that you cannot do with it? Do you have a bug to report? You can create an Issue on GitHub or reach me directly at Mustafa.Geoscientist@outlook.com

## This is great, but can I run this on a cluster?
Technically yes but I have not tested it. We need to install PetroMod on the cluster. Last time I was trying that with Best, we had lots of issues mainly because we do not have admin previlages to install required packages. I do not know the current status. Since then, I figured all the required packages and tested the procedure of installing it on linux in a desktop machine. The same workflow can be done in the cluster. You can see the "Linux PetroMod" folder in the BPSM folder for instructions on how to install PetroMod in Linux.
