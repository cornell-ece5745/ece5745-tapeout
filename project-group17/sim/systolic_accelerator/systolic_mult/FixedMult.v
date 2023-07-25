module FixedMult #(
// parameter for fixed point number, default is 11.5 (include sign bit)
 parameter INT_WIDTH,
 parameter FRAC_WIDTH
)
(input logic  signed [INT_WIDTH + FRAC_WIDTH - 1:0] a,
 input logic signed [INT_WIDTH + FRAC_WIDTH - 1:0] b,
 output logic signed [INT_WIDTH + FRAC_WIDTH - 1:0] result
 );

logic signed [2* (INT_WIDTH + FRAC_WIDTH) - 1 : 0] partial;
assign partial =  a * b;
assign result = partial [  INT_WIDTH + 2 * FRAC_WIDTH - 1: FRAC_WIDTH] ;

endmodule