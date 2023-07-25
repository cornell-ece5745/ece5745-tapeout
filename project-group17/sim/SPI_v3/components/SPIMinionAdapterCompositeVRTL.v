//-------------------------------------------------------------------------
// SPIMinionAdapterCompositeVRTL.v
//-------------------------------------------------------------------------
`include "SPI_v3/components/SPIMinionVRTL.v"
`include "SPI_v3/components/SPIMinionAdapterVRTL.v"

module SPI_v3_components_SPIMinionAdapterCompositeVRTL
#(
  parameter nbits = 8,
  parameter num_entries = 1
)
(
  input  logic             clk,
  input  logic             cs,
  output logic             miso,
  input  logic             mosi,
  input  logic             reset,
  input  logic             sclk,
  input  logic [nbits-3:0] recv_msg,
  output logic             recv_rdy,
  input  logic             recv_val,
  output logic [nbits-3:0] send_msg,
  input  logic             send_rdy,
  output logic             send_val,
  output logic             minion_parity,
  output logic             adapter_parity
);

  logic             pull_en;
  logic             pull_msg_val;
  logic             pull_msg_spc;
  logic [nbits-3:0] pull_msg_data;
  logic             push_en;
  logic             push_msg_val_wrt;
  logic             push_msg_val_rd;
  logic [nbits-3:0] push_msg_data;

  logic [nbits-1:0] pull_msg;
  logic [nbits-1:0] push_msg;

  SPI_v3_components_SPIMinionAdapterVRTL #(nbits,num_entries) adapter
  (
    .clk( clk ),
    .reset( reset ),
    .pull_en( pull_en ),
    .pull_msg_val( pull_msg_val ),
    .pull_msg_spc(pull_msg_spc),
    .pull_msg_data(pull_msg_data),
    .push_en( push_en ),
    .push_msg_val_wrt( push_msg_val_wrt ),
    .push_msg_val_rd( push_msg_val_rd ),
    .push_msg_data( push_msg_data ),
    .recv_msg( recv_msg ),
    .recv_rdy( recv_rdy ),
    .recv_val( recv_val ),
    .send_msg( send_msg ),
    .send_rdy( send_rdy ),
    .send_val( send_val ),
    .parity( adapter_parity )
  );

  SPI_v3_components_SPIMinionVRTL #(nbits) minion
  (
    .clk( clk ),
    .cs( cs ),
    .miso( miso ),
    .mosi( mosi ),
    .reset( reset ),
    .sclk( sclk ),
    .pull_en( pull_en ),
    .pull_msg( pull_msg ),
    .push_en( push_en ),
    .push_msg( push_msg ),
    .parity( minion_parity )
  );

  assign pull_msg[nbits-1]   =  pull_msg_val;
  assign pull_msg[nbits-2]   =  pull_msg_spc;
  assign pull_msg[nbits-3:0] =  pull_msg_data;
  assign push_msg_val_wrt = push_msg[nbits-1];
  assign push_msg_val_rd  = push_msg[nbits-2];
  assign push_msg_data    = push_msg[nbits-3:0];

endmodule
