//========================================================================
// grp_15_project_wrapper
//========================================================================

`default_nettype none

module user_project_wrapper
#(
  parameter BITS = 32
)(
`ifdef USE_POWER_PINS
  inout vdda1,  // User area 1 3.3V supply
  inout vdda2,  // User area 2 3.3V supply
  inout vssa1,  // User area 1 analog ground
  inout vssa2,  // User area 2 analog ground
  inout vccd1,  // User area 1 1.8V supply
  inout vccd2,  // User area 2 1.8v supply
  inout vssd1,  // User area 1 digital ground
  inout vssd2,  // User area 2 digital ground
`endif

  // Wishbone Interface (NOT USED)

  input                      wb_clk_i,
  input                      wb_rst_i,
  input                      wbs_stb_i,
  input                      wbs_cyc_i,
  input                      wbs_we_i,
  input  [3:0]               wbs_sel_i,
  input  [31:0]              wbs_dat_i,
  input  [31:0]              wbs_adr_i,
  output                     wbs_ack_o,
  output [31:0]              wbs_dat_o,

  // Logic Analyzer (NOT USED)

  input  [127:0]             la_data_in,
  output [127:0]             la_data_out,
  input  [127:0]             la_oenb,

  // General-Purpose IOs

  input  [`MPRJ_IO_PADS-1:0] io_in,
  output [`MPRJ_IO_PADS-1:0] io_out,
  output [`MPRJ_IO_PADS-1:0] io_oeb,

  // Analog IOs (NOT USED)

  inout  [`MPRJ_IO_PADS-10:0] analog_io,

  // Independent clock (NOT USED)

  input                       user_clock2,

  // User maskable interrupt signals (NOT USED)

  output [2:0]                user_irq
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

endmodule

`default_nettype wire

