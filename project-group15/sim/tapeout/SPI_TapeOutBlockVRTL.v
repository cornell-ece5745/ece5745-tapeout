//========================================================================
// SPI_TapeOutBlockVRTL
//========================================================================

`include "SPI_v3/components/SPIstackVRTL.v"
`include "tapeout/concat_rtl.v"

module tapeout_SPI_TapeOutBlockVRTL
#(
  parameter nbits = 32, // the size of the val/rdy msg for the SPI Minion (includes the two flow control bits)
  parameter num_entries = 5
)(
  input  logic clk,
  input  logic reset,

  input  logic loopthrough_sel,
  output logic minion_parity,
  output logic adapter_parity,

  // SPI Minion Ifc
  input  logic spi_min_sclk,
  input  logic spi_min_cs,
  input  logic spi_min_mosi,
  output logic spi_min_miso
);

  //----------------------------------------------------------------------
  // Reset Synchronizer
  //----------------------------------------------------------------------

  logic reset_presync;
  logic reset_sync;

  always_ff @(posedge clk) begin
    reset_presync <= reset;
    reset_sync    <= reset_presync;
  end

  //------------------------------------------------------------------------
  // SPI Interface
  //------------------------------------------------------------------------
  // There was a comment "we add two to nbits for the two SPI minion flow
  // control bits" but I didn't see that ... I think we add those two
  // bits in the PyMTL wrapper ... very confusing. -cbatten

  logic         in_rsc_vld;
  logic [31:0]  in_rsc_dat;
  logic         in_rsc_rdy;

  logic         out_rsc_vld;
  logic [31:0]  out_rsc_dat;
  logic         out_rsc_rdy;

  SPI_v3_components_SPIstackVRTL
  #(
    .nbits           (nbits),
    .num_entries     (num_entries)
  )
  SPIstack
  (
    .clk             (clk),
    .reset           (reset_sync),
    .loopthrough_sel (loopthrough_sel),
    .minion_parity   (minion_parity),
    .adapter_parity  (adapter_parity),

    // SPI Minion Ifc

    .sclk            (spi_min_sclk),
    .cs              (spi_min_cs),
    .mosi            (spi_min_mosi),
    .miso            (spi_min_miso),

    // Send/Recv Ifc

    .recv_val        (out_rsc_vld),
    .recv_msg        (out_rsc_dat),
    .recv_rdy        (out_rsc_rdy),

    .send_val        (in_rsc_vld),
    .send_msg        (in_rsc_dat),
    .send_rdy        (in_rsc_rdy)
  );

  //----------------------------------------------------------------------
  // CRC32 Block
  //----------------------------------------------------------------------

  logic [7:0] truncated_in_rsc_dat;
  assign truncated_in_rsc_dat = in_rsc_dat[7:0];

  crc32 crc32_inst
  (
    .clk         (clk),
    .rst         (reset_sync),

    .in_rsc_dat  (truncated_in_rsc_dat),
    .in_rsc_vld  (in_rsc_vld),
    .in_rsc_rdy  (in_rsc_rdy),

    .out_rsc_dat (out_rsc_dat),
    .out_rsc_vld (out_rsc_vld),
    .out_rsc_rdy (out_rsc_rdy)
  );

endmodule
