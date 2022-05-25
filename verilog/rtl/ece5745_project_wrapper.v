// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module ece5745_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb, //Output enable, low to enable

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

// // ECE5745: Hardcode output enables for GPIO here
// assign io_oeb[26] = 1; //Input clk
// assign io_oeb[27] = 1; //Input reset

// assign io_oeb[35] = 1; //Input  15 lt_sel
// assign io_oeb[36] = 0; //Output 15 mp
// assign io_oeb[37] = 0; //Output 15 ap
// assign io_oeb[8]  = 1; //Input  15 cs
// assign io_oeb[9]  = 1; //Input  15 sclk
// assign io_oeb[10] = 0; //Output 15 miso
// assign io_oeb[11] = 1; //Input  15 mosi

// assign io_oeb[25] = 1; //Input  16 lt_sel
// assign io_oeb[24] = 0; //Output 16 mp
// assign io_oeb[23] = 0; //Output 16 ap
// assign io_oeb[22] = 1; //Input  16 cs
// assign io_oeb[21] = 1; //Input  16 sclk
// assign io_oeb[20] = 0; //Output 16 miso
// assign io_oeb[19] = 1; //Input  16 mosi

// assign io_oeb[34] = 1; //Input  17 lt_sel
// assign io_oeb[33] = 0; //Output 17 mp
// assign io_oeb[32] = 0; //Output 17 ap
// assign io_oeb[31] = 1; //Input  17 cs
// assign io_oeb[30] = 1; //Input  17 sclk
// assign io_oeb[29] = 0; //Output 17 miso
// assign io_oeb[28] = 1; //Input  17 mosi

// assign io_oeb[12] = 1; //Input  99 lt_sel
// assign io_oeb[13] = 0; //Output 99 mp
// assign io_oeb[14] = 0; //Output 99 ap
// assign io_oeb[15] = 1; //Input  99 cs
// assign io_oeb[16] = 1; //Input  99 sclk
// assign io_oeb[17] = 0; //Output 99 miso
// assign io_oeb[18] = 1; //Input  99 mosi

grp_15_SPI_TapeOutBlock_32bits_5entries grp_15
(
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif 
    .clk(io_in[26]),   // Connect to same GPIO as other groups
    .reset(io_in[27]), // Connect to same GPIO as other groups
    .loopthrough_sel(io_in[35]),
    .minion_parity(io_out[36]),
    .adapter_parity(io_out[37]),
    .cs(io_in[8]), // These pins are usually used by the SPI unit on chip, and will need to be reconfigured for GPIO
    .sclk(io_in[9]), // These pins are usually used by the SPI unit on chip, and will need to be reconfigured for GPIO
    .miso(io_out[10]), // These pins are usually used by the SPI unit on chip, and will need to be reconfigured for GPIO
    .mosi(io_in[11]), // These pins are usually used by the SPI unit on chip, and will need to be reconfigured for GPIO
    .lt_sel_en(io_oeb[35]),
    .mp_en(io_oeb[36]),
    .ap_en(io_oeb[37]),
    .cs_en(io_oeb[8]),
    .sclk_en(io_oeb[9]),
    .miso_en(io_oeb[10]),
    .mosi_en(io_oeb[11])
);

grp_16_SPI_TapeOutBlock_32bits_5entries grp_16
(
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif 
    .clk(io_in[26]),   // Connect to same GPIO as other groups
    .reset(io_in[27]), // Connect to same GPIO as other groups
    .loopthrough_sel(io_in[25]),
    .minion_parity(io_out[24]),
    .adapter_parity(io_out[23]),
    .cs(io_in[22]),
    .sclk(io_in[21]),
    .miso(io_out[20]),
    .mosi(io_in[19]),
    .lt_sel_en(io_oeb[25]),
    .mp_en(io_oeb[24]),
    .ap_en(io_oeb[23]),
    .cs_en(io_oeb[22]),
    .sclk_en(io_oeb[21]),
    .miso_en(io_oeb[20]),
    .mosi_en(io_oeb[19])
);

grp_17_SPI_TapeOutBlock_32bits_5entries grp_17
(
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif 
    .clk(io_in[26]),   // Connect to same GPIO as other groups
    .reset(io_in[27]), // Connect to same GPIO as other groups
    .loopthrough_sel(io_in[34]),
    .minion_parity(io_out[33]),
    .adapter_parity(io_out[32]),
    .cs(io_in[31]),
    .sclk(io_in[30]),
    .miso(io_out[29]),
    .mosi(io_in[28]),
    .lt_sel_en(io_oeb[34]),
    .mp_en(io_oeb[33]),
    .ap_en(io_oeb[32]),
    .cs_en(io_oeb[31]),
    .sclk_en(io_oeb[30]),
    .miso_en(io_oeb[29]),
    .mosi_en(io_oeb[28])
);

grp_99_SPI_TapeOutBlock_32bits_5entries grp_99
(
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif 
    .clk(io_in[26]),   // Connect to same GPIO as other groups
    .reset(io_in[27]), // Connect to same GPIO as other groups
    .loopthrough_sel(io_in[12]),
    .minion_parity(io_out[13]),
    .adapter_parity(io_out[14]),
    .cs(io_in[15]),
    .sclk(io_in[16]),
    .miso(io_out[17]),
    .mosi(io_in[18]),
    .clk_en(io_oeb[26]),
    .reset_en(io_oeb[27]),
    .lt_sel_en(io_oeb[12]),
    .mp_en(io_oeb[13]),
    .ap_en(io_oeb[14]),
    .cs_en(io_oeb[15]),
    .sclk_en(io_oeb[16]),
    .miso_en(io_oeb[17]),
    .mosi_en(io_oeb[18])
);

endmodule	// ece5745_project_wrapper

`default_nettype wire
