// ==========================================================================
// LoopBackVRTL.v
// ==========================================================================
// This takes receives a packet from the SPIMinionAdapter module and sends it back the next cycle to the 
// SPIMinionAdapter module. Uses val/rdy microprotocol.
//
// Authors: Dilan Lakhani and Kyle Infantino
// May 31, 2022

`ifndef SPI_V3_COMPONENTS_LOOPBACK_V
`define SPI_V3_COMPONENTS_LOOPBACK_V

`include "vc/regs.v"

module SPI_v3_components_LoopBackVRTL 
#(
  parameter nbits = 32 // the size of the val/rdy msg
)(
  input logic clk,
  input logic reset,

  // Recv Interface
  input  logic             recv_val,
  output logic             recv_rdy,
  input  logic [nbits-1:0] recv_msg,

  // Send Interface
  output logic             send_val,
  input  logic             send_rdy,
  output logic [nbits-1:0] send_msg
);

  logic [nbits-1:0] reg_out;
  logic             transaction_val_out;
  
  vc_EnResetReg #(nbits, 0) reg_
  (
    .clk(clk),
    .reset(reset),
    .d(recv_msg),
    .q(reg_out),
    .en(recv_val & recv_rdy)
  );

  vc_EnResetReg #(1, 0) transaction_val
  (
    .clk(clk),
    .reset(reset),
    .d(recv_val & recv_rdy),
    .q(transaction_val_out),
    .en((recv_val & recv_rdy) | (send_val & send_rdy))
  );
  
  // Assigns
  assign recv_rdy = (~transaction_val_out) | (send_val & send_rdy);
  assign send_val = transaction_val_out;
  assign send_msg = reg_out;

endmodule

`endif /* SPI_V3_COMPONENTS_LOOPBACK_V */