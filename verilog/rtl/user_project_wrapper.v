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

module user_project_wrapper #(
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
    output [`MPRJ_IO_PADS-1:0] io_oeb,

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

// user_proj_example mprj (
// `ifdef USE_POWER_PINS
// 	.vccd1(vccd1),	// User area 1 1.8V power
// 	.vssd1(vssd1),	// User area 1 digital ground
// `endif

//     .wb_clk_i(wb_clk_i),
//     .wb_rst_i(wb_rst_i),

//     // MGMT SoC Wishbone Slave

//     .wbs_cyc_i(wbs_cyc_i),
//     .wbs_stb_i(wbs_stb_i),
//     .wbs_we_i(wbs_we_i),
//     .wbs_sel_i(wbs_sel_i),
//     .wbs_adr_i(wbs_adr_i),
//     .wbs_dat_i(wbs_dat_i),
//     .wbs_ack_o(wbs_ack_o),
//     .wbs_dat_o(wbs_dat_o),

//     // Logic Analyzer

//     .la_data_in(la_data_in),
//     .la_data_out(la_data_out),
//     .la_oenb (la_oenb),

//     // IO Pads

//     .io_in (io_in),
//     .io_out(io_out),
//     .io_oeb(io_oeb),

//     // IRQ
//     .irq(user_irq)
// );

grp_99_SPI_TapeOutBlockRTL_32bits_5entries grp_99 (
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif
    .adapter_parity  (io_out[14]),
    .clk             (io_in[11]),
    .loopthrough_sel (io_in[12]),
    .minion_parity   (io_out[13]),
    .reset           (io_in[10]),
    .spi_min_cs     (io_in[15]),
    .spi_min_miso   (io_out[17]),
    .spi_min_mosi   (io_in[18]),
    .spi_min_sclk   (io_in[16]),
    .clk_en          (io_oeb[11]),
    .reset_en        (io_oeb[10]),
    .lt_sel_en       (io_oeb[12]),
    .mp_en           (io_oeb[13]),
    .ap_en           (io_oeb[14]),
    .cs_en           (io_oeb[15]),
    .sclk_en         (io_oeb[16]),
    .miso_en         (io_oeb[17]),
    .mosi_en         (io_oeb[18])
);

  grp_15_SPI_TapeOutBlockRTL_32bits_5entries grp_15
  (
  `ifdef USE_POWER_PINS
    .vccd1(vccd1),  // User area 1 1.8V power
    .vssd1(vssd1),  // User area 1 digital ground
  `endif
    .adapter_parity  (io_out[37]),
    .clk             (io_in[11]),
    .loopthrough_sel (io_in[35]),
    .minion_parity   (io_out[36]),
    .reset           (io_in[10]),
    .spi_min_cs      (io_in[8]),
    .spi_min_miso    (io_out[33]),
    .spi_min_mosi    (io_in[34]),
    .spi_min_sclk    (io_in[9]),
    .clk_en          (),
    .reset_en        (),
    .lt_sel_en       (io_oeb[35]),
    .mp_en           (io_oeb[36]),
    .ap_en           (io_oeb[37]),
    .cs_en           (io_oeb[8]),
    .sclk_en         (io_oeb[9]),
    .miso_en         (io_oeb[33]),
    .mosi_en         (io_oeb[34])
  );

  grp_17_SPI_TapeOutBlockRTL_32bits_5entries grp_17
  (
  `ifdef USE_POWER_PINS
    .vccd1(vccd1),  // User area 1 1.8V power
    .vssd1(vssd1),  // User area 1 digital ground
  `endif
    .adapter_parity  (io_out[32]),
    .clk             (io_in[11]),
    .loopthrough_sel (io_in[27]),
    .minion_parity   (io_out[26]),
    .reset           (io_in[10]),
    .spi_min_cs      (io_in[31]),
    .spi_min_miso    (io_out[29]),
    .spi_min_mosi    (io_in[28]),
    .spi_min_sclk    (io_in[30]),
    .clk_en          (),
    .reset_en        (),
    .lt_sel_en       (io_oeb[27]),
    .mp_en           (io_oeb[26]),
    .ap_en           (io_oeb[32]),
    .cs_en           (io_oeb[31]),
    .sclk_en         (io_oeb[30]),
    .miso_en         (io_oeb[29]),
    .mosi_en         (io_oeb[28])
  );

endmodule	// user_project_wrapper

`default_nettype wire
