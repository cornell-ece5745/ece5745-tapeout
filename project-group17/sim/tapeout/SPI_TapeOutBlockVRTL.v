//========================================================================
// SPI_TapeOutBlockVRTL
//========================================================================

`include "SPI_v3/components/SPIstackVRTL.v"
`include "tapeout/block_test/WrapperVRTL.v"

module tapeout_SPI_TapeOutBlockVRTL
#(
  parameter nbits = 34, // the size of the val/rdy msg for the SPI Minion (includes the two flow control bits)
  parameter num_entries = 5
)(
  input  logic clk,
  input  logic reset,

  input  logic loopthrough_sel,
  output logic minion_parity,
  output logic adapter_parity,

  // SPI Minion Ifc
  input  logic sclk,
  input  logic cs,
  input  logic mosi,
  output logic miso
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

  //----------------------------------------------------------------------
  // SPI Interface
  //----------------------------------------------------------------------
  // There was a comment "we add two to nbits for the two SPI minion flow
  // control bits" but I didn't see that ... I think we add those two
  // bits in the PyMTL wrapper ... very confusing. -cbatten

  parameter packet_nbits = nbits - 2; // remove control flow bits

  logic                    send_val;
  logic [packet_nbits-1:0] send_msg;
  logic                    send_rdy;

  logic                    recv_val;
  logic [packet_nbits-1:0] recv_msg;
  logic                    recv_rdy;

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

    .sclk            (sclk),
    .cs              (cs),
    .mosi            (mosi),
    .miso            (miso),

    // Send/Recv Ifc

    .send_val        (send_val),
    .send_msg        (send_msg),
    .send_rdy        (send_rdy),

    .recv_val        (recv_val),
    .recv_msg        (recv_msg),
    .recv_rdy        (recv_rdy)
 );

  //----------------------------------------------------------------------
  // SystolicMult Block
  //----------------------------------------------------------------------
  // Not quite sure what is going on with the recv_msg? But leave it for
  // now ... -cbatten

  tapeout_block_test_WrapperVRTL  SystolicMult_SPI_Test
  (
    .clk      (clk),
    .reset    (reset_sync),

    .send_val (recv_val),
    .send_msg (recv_msg),
    .send_rdy (recv_rdy),

    .recv_val (send_val),
    .recv_msg (send_val ? send_msg: 23'b0 ),
    .recv_rdy (send_rdy)
  );

endmodule
