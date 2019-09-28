# ACCEL PCB V19.02.9589 Auto-Generated DO File
# Tue Apr 08 10:35:35 2008
#
bestsave on $\best.w
status_file $\progress.sts
#
unit mil
#
grid wire 1.000000 
grid via 1.000000 
#
#protect all wires
unselect all vias
select via d05d10
#
rule pcb (width 7.9)
#
bus diagonal
route 50
clean 4
route 50 16
clean 4
filter 5
route 100 16
clean 2
delete conflicts
#
write wire $\12120_ep3_pcb4.w
spread 
miter
write wire $\12120_ep3_pcb4.m
#
write session $\12120_ep3_pcb4.ses
report status $\12120_ep3_pcb4.sts
