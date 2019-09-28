if {[file exist [project env]] > 0} {project close}
if {[file exist "D:/ADC/asvm12120_fft_fast/Quartus/fast_fft/nco.mpf"] == 0} {
  project new D:/ADC/asvm12120_fft_fast/Quartus/fast_fft/ nco
} else	{
project open nco
}
if {[file exist work] ==0} 	{
  exec vlib work
  exec vmap work work}      
vlog $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.v
vlog $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.v
vlog $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.v
vlog nco.vo
vlog nco_tb.v
vsim -novopt nco_tb
do nco_wave.do
run 22000 ns;
