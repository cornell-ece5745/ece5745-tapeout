//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`include "vc/trace.v"
`include "systolic_accelerator/systolic_mult/Pe.v"
`include "systolic_accelerator/systolic_mult/SystolicMultControl.v"
`include "systolic_accelerator/msg_structs/data_type.v"

module SystolicMult
#(
  parameter INT_WIDTH,
  parameter FRAC_WIDTH,
  parameter SYSTOLIC_SIZE,
  parameter SYSTOLIC_STEP_SIZE
)(
  input  logic                                    reset,
  input  logic                                    clk,

  input  logic [(INT_WIDTH + FRAC_WIDTH)*4+3-1:0] recv_msg,
  input  logic                                    recv_val,
  output logic                                    recv_rdy,

  output logic [(INT_WIDTH + FRAC_WIDTH)*2-1:0]   send_msg,
  output logic                                    send_val,
  input  logic                                    send_rdy,

  output logic                                    produce_run
);

  logic finished, shift_result;
  SystolicMultControl #(
    // parameter for fixed point number, default is 11.5 (include sign bit)
   .SYSTOLIC_SIZE      (SYSTOLIC_SIZE),
   .SYSTOLIC_STEP_SIZE (SYSTOLIC_STEP_SIZE)
  )
  systolicMultControl
  (
    .clk(clk),
    .reset(reset),
    .run(recv_msg[1]),
    .final_run(recv_msg[0]),
    .shift_result(shift_result),
    .finished(finished),
    .val(send_val),
    .ready(recv_rdy),
    .produce_run(produce_run)
   );

  parameter NUM_INTERCONNECT_1D = (SYSTOLIC_SIZE-1) * SYSTOLIC_SIZE;
  // logic [NUM_INTERCONNECT_1D-1:0] [INT_WIDTH + FRAC_WIDTH - 1:0] pass_a, pass_b;
  logic [INT_WIDTH + FRAC_WIDTH - 1:0] pass_a_0, pass_b_0;
  logic [INT_WIDTH + FRAC_WIDTH - 1:0] pass_a_1, pass_b_1;

  logic [SYSTOLIC_SIZE-1:0] pass_shift_result, reg_finished;

  Pe #( INT_WIDTH, FRAC_WIDTH ) pe0
  (
    .clk(clk),
    .reset(reset),
    .a(recv_msg[(INT_WIDTH+FRAC_WIDTH)*2+3-1:(INT_WIDTH+FRAC_WIDTH)*1+3]),
    .b(recv_msg[(INT_WIDTH+FRAC_WIDTH)*4+3-1:(INT_WIDTH+FRAC_WIDTH)*3+3]),
    .shift_result(shift_result),
    .finished(finished),
    .pass_shift_result(pass_shift_result[0]),
    .reg_finished(reg_finished[0]),
    // .reg_pass_down(pass_a[0]),
    // .reg_pass_right(pass_b[0])
    .reg_pass_down(pass_a_0),
    .reg_pass_right(pass_b_0)
  );

  // dummy wires to avoid PINMISSING warnings after running sv2v -cbatten
  logic [INT_WIDTH+FRAC_WIDTH-1:0] pe1_reg_pass_right;

  Pe #( INT_WIDTH, FRAC_WIDTH ) pe1
  (
    .clk(clk),
    .reset(reset),
    .a(recv_msg[(INT_WIDTH+FRAC_WIDTH)*1+3-1:3]),
    // .b(pass_b[0]),
    .b(pass_b_0),
    .shift_result(pass_shift_result[0]),
    .finished(reg_finished[0]),
    .pass_shift_result(pass_shift_result[1]),
    .reg_finished(reg_finished[1]),
    // .reg_pass_down(pass_a[1]),
    .reg_pass_down(pass_a_1),
    .reg_pass_right(pe1_reg_pass_right)
  );

  // dummy wires to avoid PINMISSING warnings after running sv2v -cbatten
  logic pe2_pass_shift_result;
  logic pe2_reg_finished;

  Pe #( INT_WIDTH, FRAC_WIDTH ) pe2
  (
    .clk(clk),
    .reset(reset),
    // .a(pass_a[0]),
    .a(pass_a_0),
    .b(recv_msg[(INT_WIDTH+FRAC_WIDTH)*3+3-1:(INT_WIDTH+FRAC_WIDTH)*2+3]),
    .shift_result(pass_shift_result[0]),
    .finished(reg_finished[0]),
    .pass_shift_result(pe2_pass_shift_result),
    .reg_finished(pe2_reg_finished),
    .reg_pass_down(send_msg[(INT_WIDTH+FRAC_WIDTH)*2-1:(INT_WIDTH+FRAC_WIDTH)]),
    // .reg_pass_right(pass_b[1])
    .reg_pass_right(pass_b_1)
  );

  // dummy wires to avoid PINMISSING warnings after running sv2v -cbatten
  logic                            pe3_pass_shift_result;
  logic                            pe3_reg_finished;
  logic [INT_WIDTH+FRAC_WIDTH-1:0] pe3_reg_pass_right;

  Pe #( INT_WIDTH,  FRAC_WIDTH ) pe3
  (
    .clk(clk),
    .reset(reset),
    // .a(pass_a[1]),
    // .b(pass_b[1]),
    .a(pass_a_1),
    .b(pass_b_1),
    .shift_result(pass_shift_result[1]),
    .finished(reg_finished[1]),
    .pass_shift_result(pe3_pass_shift_result),
    .reg_finished(pe3_reg_finished),
    .reg_pass_down(send_msg[INT_WIDTH + FRAC_WIDTH - 1:0]),
    .reg_pass_right(pe3_reg_pass_right)
  );

endmodule
