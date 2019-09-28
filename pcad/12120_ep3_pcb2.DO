# ACCEL PCB V19.02.9589 Auto-Generated DO File
# Sat Feb 09 23:16:40 2008
# 
# Initialize units and grid
unit mil
grid place 50.0
place_rule pcb (spacing 50.0)
# 
# Use component origins (not centroids)
change work_origin origin
# 
# Place the large components
initplace 
# 
# Place the small components
autodiscrete (type small)
# 
# Reduce distances (interchange/rotate)
interchange 10 (type all)
autorotate (type all)
# 
# Create placement data file and status report
write session $\12120_ep3_pcb2.ses
report place_status $\12120_ep3_pcb2.sts
