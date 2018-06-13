# demo_opensim_output_3rd_party_format
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


overlayNum = None
model = pmpy.OutputModel(pm_model)
overlay = None
for ovl in model.overlays:
    overlay = oval.name
    overlayNum = oval.number
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
    filename = 'Output.txt' + overlay.name
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



