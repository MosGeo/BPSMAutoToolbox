# ExtractOutput
#
# Demonstration of PetroMod python access - using pmpy to write out PetroMod
# output data in a 3rd-party format.
#
# Task: Write present-day values of a given overlay to a text file.

import sys
import time

start_time = time.clock()

print 'PetroMod project path is', pm_project
print 'PetroMod model path is', pm_model

# For input, expect a single overlay number
#   (The PetroMod project and model will already be available as pm_project
#    and pm_model, respectively.)
overlayNum = None

if len(pm_script_args) == 1:
    try:
        overlayNum = int(pm_script_args[0])
    except:
        print "Script argument is not an integer number."

if not overlayNum:
    print "Error: Script expects a single overlay number as input."
    sys.exit(3)

# Open the model output
#   Note that the module pmpy will already be available.
print "Accessing model", pm_model, "..."
try:
    model = pmpy.OutputModel(pm_model)
except Exception as ex:
    print "Error loading model:", ex
    sys.exit(1)

# Access the overlay with the given number
overlay = None
for ovl in model.overlays:
    if ovl.number == overlayNum:
        overlay = ovl
        break

if not overlay:
    print "Error: The model does not contain an overlay number", overlayNum
    print "The following overlays are available:"
    print "  Number    Name"
    for ovl in model.overlays:
        print ovl.number, "   ", ovl.name
    sys.exit(2)

print "Overlay", overlayNum, "is", overlay.name

# Check that overlay has data for the last event
lastEvent = model.events[-1].number
hasData = False
for event in overlay.events():
    if event == lastEvent:
        hasData = True
if not hasData:
    print "Error: Specified overlay has no data for last model event"
    sys.exit(4)

# Open output file and write data
filename = 'demo_1.txt'
try:
    print "Writing output to", filename
    f = open(filename, 'w')
except:
    print "Error: Failed to open output file for writing."
    sys.exit(5)

f.write("# demo_1 output\n#\n")
f.write("# model: " + model.path + "\n")
f.write("# event: " + str(lastEvent) + "\n")
f.write("# overlay: " + ovl.name + "\n")
f.write("# unit: " + ovl.unit + "\n#\n")
f.write("# [element_id] [value]:\n")

# write one overlay value for each active element
#   Note: We get overlay values for node 0, which is ignored for overlays with geometry ELEM
for element in model.active_elements(lastEvent):
    f.write(str(element) + " " + str(overlay[lastEvent, element, 0]) + "\n")

f.close()

# End model access
model.close()

print "Execution time:", time.clock() - start_time, "seconds"



