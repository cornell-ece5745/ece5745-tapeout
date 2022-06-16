###############################################################################
# Created by write_sdc
# Thu Jun 16 17:44:50 2022
###############################################################################
current_design grp_99_SPI_TapeOutBlockRTL_32bits_5entries
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 100.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {loopthrough_sel}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {reset}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {spi_min_cs}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {spi_min_mosi}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {spi_min_sclk}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {adapter_parity}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ap_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {clk_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {cs_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {lt_sel_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {minion_parity}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {miso_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {mosi_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {mp_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {reset_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {sclk_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {spi_min_miso}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {adapter_parity}]
set_load -pin_load 0.0334 [get_ports {ap_en}]
set_load -pin_load 0.0334 [get_ports {clk_en}]
set_load -pin_load 0.0334 [get_ports {cs_en}]
set_load -pin_load 0.0334 [get_ports {lt_sel_en}]
set_load -pin_load 0.0334 [get_ports {minion_parity}]
set_load -pin_load 0.0334 [get_ports {miso_en}]
set_load -pin_load 0.0334 [get_ports {mosi_en}]
set_load -pin_load 0.0334 [get_ports {mp_en}]
set_load -pin_load 0.0334 [get_ports {reset_en}]
set_load -pin_load 0.0334 [get_ports {sclk_en}]
set_load -pin_load 0.0334 [get_ports {spi_min_miso}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {loopthrough_sel}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reset}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {spi_min_cs}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {spi_min_mosi}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {spi_min_sclk}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 5.0000 [current_design]
