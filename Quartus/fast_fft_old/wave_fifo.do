onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /fifo_120_48_tb/clk
add wave -noupdate -format Logic /fifo_120_48_tb/ifclk
add wave -noupdate -format Logic /fifo_120_48_tb/reset_n
add wave -noupdate -format Literal -radix decimal /fifo_120_48_tb/data
add wave -noupdate -format Logic /fifo_120_48_tb/rdreq
add wave -noupdate -format Logic /fifo_120_48_tb/wrreq
add wave -noupdate -format Literal -radix decimal /fifo_120_48_tb/q
add wave -noupdate -format Logic -radix binary /fifo_120_48_tb/rdempty
add wave -noupdate -format Logic -radix decimal /fifo_120_48_tb/wrfull_sig
add wave -noupdate -format Literal -radix decimal /fifo_120_48_tb/m_clk
add wave -noupdate -format Literal -radix decimal /fifo_120_48_tb/m_ifclk
add wave -noupdate -format Logic /fifo_120_48_tb/wrfull_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {135669 ps} 0}
configure wave -namecolwidth 197
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
WaveRestoreZoom {0 ps} {223752 ps}
