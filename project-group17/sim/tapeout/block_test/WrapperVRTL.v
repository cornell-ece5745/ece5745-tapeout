`ifndef TOP_WRAPPERVRTL_V
`define TOP_WRAPPERVRTL_V

`include "tapeout/block_test/Wrapper.v"
`include "systolic_accelerator/msg_structs/wrapper_msg.v"

module tapeout_block_test_WrapperVRTL
(
  input clk,
  input reset,

  input logic send_rdy, // TODO, need halt
  output logic send_val,
  output [(INT_WIDTH+FRAC_WIDTH)*2-1:0] send_msg,

  input logic recv_val,
  output logic recv_rdy,
  input [9+INT_WIDTH+FRAC_WIDTH+4+3-1:0] recv_msg // share by 4
);

Wrapper #
(
  DATA_ENTRIES,
  DATA_LAT,

  INT_WIDTH,
	FRAC_WIDTH,
  SYSTOLIC_SIZE,
  SYSTOLIC_STEP_SIZE
) wrapper
(
  .clk(clk),
  .reset(reset),
  .send_rdy(send_rdy),
  .send_val(send_val),
  .send_msg(send_msg),
  .recv_val(recv_val),
  .recv_rdy(recv_rdy),
  .recv_msg(recv_msg[22:0])
);

endmodule

`endif /* TOP_WRAPPERVRTL_V */
