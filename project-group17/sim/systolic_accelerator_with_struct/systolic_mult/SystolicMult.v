//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`include "vc/trace.v"
`include "systolic_accelerator/systolic_mult/Pe.v"
`include "systolic_accelerator/systolic_mult/SystolicMultControl.v"
`include "systolic_accelerator/msg_structs/systolic_msgs.v"
// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Define datapath and control unit here.
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
module SystolicMult #(
	parameter INT_WIDTH,
	parameter FRAC_WIDTH,
  parameter SYSTOLIC_SIZE,
  parameter SYSTOLIC_STEP_SIZE
)
(
  input logic reset,
  input logic clk,

  input systolic_mult_recv_msg recv_msg,
  input logic recv_val,
  output logic recv_rdy,

  output systolic_mult_send_msg send_msg,
  output logic send_val,
  input logic send_rdy,
  output logic produce_run
);

logic finished, shift_result;
SystolicMultControl #(
// parameter for fixed point number, default is 11.5 (include sign bit)
 .SYSTOLIC_SIZE(SYSTOLIC_SIZE),
 .SYSTOLIC_STEP_SIZE(SYSTOLIC_STEP_SIZE)
) systolicMultControl
( .clk(clk),
  .reset(reset),
  .run(recv_msg.run),
  .final_run(recv_msg.final_run),
  .shift_result(shift_result),
  .finished(finished),
  .val(send_val),
  .ready(recv_rdy),
  .produce_run(produce_run)
 );

parameter NUM_INTERCONNECT_1D = (SYSTOLIC_SIZE-1) * SYSTOLIC_SIZE;
logic [NUM_INTERCONNECT_1D-1:0] [INT_WIDTH + FRAC_WIDTH - 1:0] pass_a, pass_b;

logic [SYSTOLIC_SIZE-1:0] pass_shift_result, reg_finished;
Pe #(
  INT_WIDTH,
  FRAC_WIDTH
  ) 
  pe0 (	
    .clk(clk),
    .reset(reset),
    .a(recv_msg.data_0), 
    .b(recv_msg.weight_0),
    .shift_result(shift_result),
    .finished(finished),
    .pass_shift_result(pass_shift_result[0]),
    .reg_finished(reg_finished[0]),
    .reg_pass_down(pass_a[0]),
    .reg_pass_right(pass_b[0])
);
Pe #(
  INT_WIDTH,
  FRAC_WIDTH
  ) 
  pe1 (	
    .clk(clk),
    .reset(reset),
    .a(recv_msg.data_1), 
    .b(pass_b[0]),
    .shift_result(pass_shift_result[0]),
    .finished(reg_finished[0]),
    .pass_shift_result(pass_shift_result[1]),
    .reg_finished(reg_finished[1]),
    .reg_pass_down(pass_a[1]),
    .reg_pass_right()
);
Pe #(
  INT_WIDTH,
  FRAC_WIDTH
  ) 
  pe2 (	
    .clk(clk),
    .reset(reset),
    .a(pass_a[0]), 
    .b(recv_msg.weight_1),
    .shift_result(pass_shift_result[0]),
    .finished(reg_finished[0]),
    .pass_shift_result(),
    .reg_finished(),
    .reg_pass_down(send_msg.result_0),
    .reg_pass_right(pass_b[1])
);
Pe #(
  INT_WIDTH,
  FRAC_WIDTH
  ) 
  pe3 (	
    .clk(clk),
    .reset(reset),
    .a(pass_a[1]), 
    .b(pass_b[1]),
    .shift_result(pass_shift_result[1]),
    .finished(reg_finished[1]),
    .pass_shift_result(),
    .reg_finished(),
    .reg_pass_down(send_msg.result_1),
    .reg_pass_right()
);


endmodule