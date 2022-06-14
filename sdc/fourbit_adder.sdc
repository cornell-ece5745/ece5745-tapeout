###############################################################################
# Created by write_sdc
# Mon Jun 13 22:40:31 2022
###############################################################################
current_design fourbit_adder
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 100.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {a[0]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {a[1]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {a[2]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {a[3]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {b[0]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {b[1]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {b[2]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {b[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_en[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_en[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_en[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_en[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_en[4]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_en[5]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_en[6]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_en[7]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {output_en[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {output_en[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {output_en[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {output_en[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {y[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {y[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {y[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {y[3]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {input_en[7]}]
set_load -pin_load 0.0334 [get_ports {input_en[6]}]
set_load -pin_load 0.0334 [get_ports {input_en[5]}]
set_load -pin_load 0.0334 [get_ports {input_en[4]}]
set_load -pin_load 0.0334 [get_ports {input_en[3]}]
set_load -pin_load 0.0334 [get_ports {input_en[2]}]
set_load -pin_load 0.0334 [get_ports {input_en[1]}]
set_load -pin_load 0.0334 [get_ports {input_en[0]}]
set_load -pin_load 0.0334 [get_ports {output_en[3]}]
set_load -pin_load 0.0334 [get_ports {output_en[2]}]
set_load -pin_load 0.0334 [get_ports {output_en[1]}]
set_load -pin_load 0.0334 [get_ports {output_en[0]}]
set_load -pin_load 0.0334 [get_ports {y[3]}]
set_load -pin_load 0.0334 [get_ports {y[2]}]
set_load -pin_load 0.0334 [get_ports {y[1]}]
set_load -pin_load 0.0334 [get_ports {y[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {a[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {a[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {a[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {a[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {b[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {b[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {b[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {b[0]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 5.0000 [current_design]
