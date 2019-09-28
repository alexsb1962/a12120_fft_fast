onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /fast_fft_tb/asvm12120_fft_inst/cyp_inst/ifclk
add wave -noupdate -format Logic /fast_fft_tb/asvm12120_fft_inst/cyp_inst/flaga
add wave -noupdate -format Logic /fast_fft_tb/asvm12120_fft_inst/cyp_inst/reset
add wave -noupdate -format Logic /fast_fft_tb/asvm12120_fft_inst/cyp_inst/sink_valid
add wave -noupdate -format Literal /fast_fft_tb/asvm12120_fft_inst/cyp_inst/fd
add wave -noupdate -format Logic /fast_fft_tb/asvm12120_fft_inst/cyp_inst/slwr
add wave -noupdate -format Logic /fast_fft_tb/asvm12120_fft_inst/cyp_inst/sink_ready
add wave -noupdate -format Literal -radix hexadecimal /fast_fft_tb/asvm12120_fft_inst/cyp_inst/fdata
add wave -noupdate -format Literal -radix hexadecimal /fast_fft_tb/asvm12120_fft_inst/cyp_inst/rfdata
add wave -noupdate -format Literal /fast_fft_tb/asvm12120_fft_inst/cyp_inst/m1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {108152 ps} 0}
configure wave -namecolwidth 335
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {503862 ps}
