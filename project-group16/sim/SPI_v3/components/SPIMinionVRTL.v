//==========================================================================
//SPIMinionVRTL.v
//==========================================================================

`include "SPI_v3/components/ShiftReg.v"
`include "SPI_v3/components/Synchronizer.v"

module SPI_v3_components_SPIMinionVRTL
#(
  parameter nbits = 8
)
(
  input  logic             clk,
  input  logic             cs,
  output logic             miso,
  input  logic             mosi,
  input  logic             reset,
  input  logic             sclk,
  output logic             pull_en,
  input  logic [nbits-1:0] pull_msg,
  output logic             push_en,
  output logic [nbits-1:0] push_msg,  
  output logic             parity
);
  //-------------------------------------------------------------
  // Component cs_sync
  //-------------------------------------------------------------

  logic cs_sync_clk;
  logic cs_sync_in_;
  logic cs_sync_negedge_;
  logic cs_sync_out;
  logic cs_sync_posedge_;
  logic cs_sync_reset;

  Synchronizer #(1'b1) cs_sync
  (
    .clk( cs_sync_clk ),
    .in_( cs_sync_in_ ),
    .negedge_( cs_sync_negedge_ ),
    .out( cs_sync_out ),
    .posedge_( cs_sync_posedge_ ),
    .reset( cs_sync_reset )
  );

  //-------------------------------------------------------------
  // Component mosi_sync
  //-------------------------------------------------------------

  logic mosi_sync_clk;
  logic mosi_sync_in_;
  logic mosi_sync_negedge_;
  logic mosi_sync_out;
  logic mosi_sync_posedge_;
  logic mosi_sync_reset;

  Synchronizer #(1'b0) mosi_sync
  (
    .clk( mosi_sync_clk ),
    .in_( mosi_sync_in_ ),
    .negedge_( mosi_sync_negedge_ ),
    .out( mosi_sync_out ),
    .posedge_( mosi_sync_posedge_ ),
    .reset( mosi_sync_reset )
  );

  //-------------------------------------------------------------
  // Component sclk_sync
  //-------------------------------------------------------------

  logic sclk_sync_clk;
  logic sclk_sync_in_;
  logic sclk_sync_negedge_;
  logic sclk_sync_out;
  logic sclk_sync_posedge_;
  logic sclk_sync_reset;

  Synchronizer #(1'b0) sclk_sync
  (
    .clk( sclk_sync_clk ),
    .in_( sclk_sync_in_ ),
    .negedge_( sclk_sync_negedge_ ),
    .out( sclk_sync_out ),
    .posedge_( sclk_sync_posedge_ ),
    .reset( sclk_sync_reset )
  );

  //-------------------------------------------------------------
  // Component shreg_in
  //-------------------------------------------------------------

  logic             shreg_in_clk;
  logic             shreg_in_in_;
  logic [nbits-1:0] shreg_in_load_data;
  logic             shreg_in_load_en;
  logic [nbits-1:0] shreg_in_out;
  logic             shreg_in_reset;
  logic             shreg_in_shift_en;

  ShiftReg #( nbits ) shreg_in
  (
    .clk( shreg_in_clk ),
    .in_( shreg_in_in_ ),
    .load_data( shreg_in_load_data ),
    .load_en( shreg_in_load_en ),
    .out( shreg_in_out ),
    .reset( shreg_in_reset ),
    .shift_en( shreg_in_shift_en )
  );

  //-------------------------------------------------------------
  // Component shreg_out
  //-------------------------------------------------------------

  logic             shreg_out_clk;
  logic             shreg_out_in_;
  logic [nbits-1:0] shreg_out_load_data;
  logic             shreg_out_load_en;
  logic [nbits-1:0] shreg_out_out;
  logic             shreg_out_reset;
  logic             shreg_out_shift_en;

  ShiftReg #( nbits ) shreg_out
  (
    .clk( shreg_out_clk ),
    .in_( shreg_out_in_ ),
    .load_data( shreg_out_load_data ),
    .load_en( shreg_out_load_en ),
    .out( shreg_out_out ),
    .reset( shreg_out_reset ),
    .shift_en( shreg_out_shift_en )
  );
  
  always_comb begin
    shreg_in_shift_en = ( ~cs_sync_out ) & sclk_sync_posedge_;
    shreg_out_shift_en = ( ~cs_sync_out ) & sclk_sync_negedge_;
  end

  assign cs_sync_clk         = clk;
  assign cs_sync_reset       = reset;
  assign cs_sync_in_         = cs;
  assign sclk_sync_clk       = clk;
  assign sclk_sync_reset     = reset;
  assign sclk_sync_in_       = sclk;
  assign mosi_sync_clk       = clk;
  assign mosi_sync_reset     = reset;
  assign mosi_sync_in_       = mosi;
  assign shreg_in_clk        = clk;
  assign shreg_in_reset      = reset;
  assign shreg_in_in_        = mosi_sync_out;
  assign shreg_in_load_en    = 1'b0;
  assign shreg_in_load_data  = {nbits{1'b0}};
  assign shreg_out_clk       = clk;
  assign shreg_out_reset     = reset;
  assign shreg_out_in_       = 1'b0;
  assign shreg_out_load_en   = pull_en;
  assign shreg_out_load_data = pull_msg;
  assign miso                = shreg_out_out[nbits-1];
  assign pull_en             = cs_sync_negedge_;
  assign push_en             = cs_sync_posedge_;
  assign push_msg            = shreg_in_out;
  assign parity              = (^push_msg[nbits-3:0]) & push_en;

endmodule
