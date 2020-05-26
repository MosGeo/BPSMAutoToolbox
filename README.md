# The BPSM Automation Toolbox for Probabilistic Interactions

The BPSM Automation toolbox is a library to automate the creation, modification, and running of models used in the Schlumberger PetroMod software. The code is written in MATLAB (Octave support has not been tested).

<div align="center">
    <img width=800 src="https://github.com/MosGeo/BPSMAutoToolbox/blob/master/ReadmeFigures/Workflow.png" alt="TopImage" title="Image of particle pack"</img>
</div>

## Capabilities
- A template PetroMod project can be loaded into Matlab. 
- Lithologies can be duplicated, mixed, modified, and deleted. 
- Models can be duplicated, deleted, and simulated directly from Matlab. 
- 1D, 2D, and 3D models can be modified.
- Custom open simulator scripts can be ran (OpenSimulator license is required). Using this, results can be read back into Matlab.

## Getting started
- Create your PetroMod 2017.2 or newer "template project" (recent older versions should work too).
- Create your output script in python to export output if needed (see below).
- Simulate your template project and make sure everything works.
- See the "main.m" for the procedure to load your template project in Matlab, modify parameters, duplicate models and simulate them in Matlab. You can also read the report accomponied in the repository and the workshop material included.

## General tips
- Save your PetroMod project in a folder that does not require administrator privileges.
- It is better to create all the required lithologies in one go before updating the project as writing the lithology files takes relatively long time (a couple of seconds), i.e., do not update the project in a for loop.
- If you are using lithology mixing, it is better to make sure everything is consistant by creating some mixes manually and comparing it to the mixes created by Matlab.
- Some parameters are internally saved with different unit than the one that is displayed in the PetroMod GUI.

## Open Simulator scripts tips
- Open Simulator requires Python to be installed in the system. The version of required Python in 2018 or older is 2.7.
- Check out scripts folder in PetroMod script folder for example (e.g., "C:\Program Files\Schlumberger\PetroMod 2016.2\scripts")
- To activate your script, in the Simulator window, choose "Output", "Open Simulator" and select your script. Make sure your script run in the template project. Save the simulator window.
- Another option is to run the written script directly from matlab as given in the example file.

## Future plans
The basic framework is implemented now. Most needed functionalites can be automated in Matlab. Feature addition is on hold for now and new features will be added as needed. If you have suggestions, bugs, or feedback, please contact me through Github or Email. I would love to hear from you. What are the functionalities that you use the most? What are the things that you cannot do with it? Do you have a bug to report? You can create an Issue on GitHub or reach me directly at Mustafa.Geoscientist@outlook.com

## Referencing
Al Ibrahim, M. A., 2019, Petroleum system modeling of heterogeneous organic-rich mudrocks, PhD Thesis, Stanford University, p. 131-135.
