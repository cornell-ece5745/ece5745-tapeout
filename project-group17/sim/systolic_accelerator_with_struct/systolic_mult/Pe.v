//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================
`include "vc/trace.v"
`include "systolic_accelerator/systolic_mult/FixedMult.v"

// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Define datapath and control unit here.
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
module Pe 
#(
	parameter INT_WIDTH,
	parameter FRAC_WIDTH
)
(
  input logic reset,
  input logic clk,
  input logic [INT_WIDTH+FRAC_WIDTH-1 : 0] a,
  input logic [INT_WIDTH+FRAC_WIDTH-1 : 0] b,
  input logic shift_result,
  input logic finished,
  output logic pass_shift_result,
  output logic reg_finished,
  output logic [INT_WIDTH+FRAC_WIDTH-1 : 0] reg_pass_down, 
  output logic [INT_WIDTH+FRAC_WIDTH-1 : 0] reg_pass_right
);

assign pass_shift_result = shift_result;

logic [INT_WIDTH+FRAC_WIDTH-1:0] reg_output;
logic [INT_WIDTH+FRAC_WIDTH-1 :0] fixed_mult_result;

FixedMult #(
  INT_WIDTH,
  FRAC_WIDTH
)
fixed_mult (
  .a(a),
  .b(b),
  .result(fixed_mult_result)
);

logic [INT_WIDTH+FRAC_WIDTH-1 : 0] sum_result;
assign sum_result = reg_output + fixed_mult_result;

logic [INT_WIDTH+FRAC_WIDTH-1 : 0] reg_pass_down_in, reg_pass_right_in, reg_output_in;
assign reg_pass_down_in = shift_result ? reg_output : a;
assign reg_pass_right_in = shift_result ? reg_pass_right : b;
assign reg_output_in = shift_result ? 0 : reg_finished ? reg_output : sum_result;

always @(posedge clk )begin
  if(reset) begin
    reg_pass_down <= 0;
    reg_pass_right <= 0;
    reg_output  <= 0;
    reg_finished <= 0;
  end
  //TODO: clk gating?
  else begin  
    reg_finished <= finished;
    reg_output <= reg_output_in;
    reg_pass_down <= reg_pass_down_in; //for reuse
    reg_pass_right <= reg_pass_right_in; //for reuse
  end
end



endmodule