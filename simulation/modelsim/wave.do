onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /FeedForwardNN/x0
add wave -noupdate /FeedForwardNN/x1
add wave -noupdate /FeedForwardNN/x2
add wave -noupdate /FeedForwardNN/x3
add wave -noupdate /FeedForwardNN/y0
add wave -noupdate /FeedForwardNN/y1
add wave -noupdate /FeedForwardNN/RST
add wave -noupdate /FeedForwardNN/CLK
add wave -noupdate /FeedForwardNN/addr
add wave -noupdate /FeedForwardNN/write_data
add wave -noupdate /FeedForwardNN/selected_data
add wave -noupdate /FeedForwardNN/we
add wave -noupdate /FeedForwardNN/read_data
add wave -noupdate /FeedForwardNN/state
add wave -noupdate /FeedForwardNN/reset
add wave -noupdate /FeedForwardNN/counter
add wave -noupdate /FeedForwardNN/mem_clk
add wave -noupdate /FeedForwardNN/x0
add wave -noupdate /FeedForwardNN/x1
add wave -noupdate /FeedForwardNN/x2
add wave -noupdate /FeedForwardNN/x3
add wave -noupdate /FeedForwardNN/y0
add wave -noupdate /FeedForwardNN/y1
add wave -noupdate /FeedForwardNN/RST
add wave -noupdate /FeedForwardNN/CLK
add wave -noupdate /FeedForwardNN/addr
add wave -noupdate /FeedForwardNN/write_data
add wave -noupdate /FeedForwardNN/selected_data
add wave -noupdate /FeedForwardNN/we
add wave -noupdate /FeedForwardNN/read_data
add wave -noupdate /FeedForwardNN/state
add wave -noupdate /FeedForwardNN/reset
add wave -noupdate /FeedForwardNN/counter
add wave -noupdate /FeedForwardNN/mem_clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 209
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
WaveRestoreZoom {0 ps} {912 ps}
