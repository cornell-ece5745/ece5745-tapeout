/*
==========================================================================
ShiftReg.v
==========================================================================
N-bit shift register.
*/

module ShiftReg
#(
    parameter nbits = 8
)
(
  input  logic             clk,
  input  logic             in_,
  input  logic [nbits-1:0] load_data,
  input  logic             load_en,
  output logic [nbits-1:0] out,
  input  logic             reset,
  input  logic             shift_en 
);
  
  always_ff @(posedge clk) 
  begin 
    if ( reset ) begin
      out <= { nbits{1'b0}};
    end
    else if ( load_en ) begin
      out <= load_data;
    end
    else if ( ( ~load_en ) & shift_en ) begin
      out <= { out[nbits-2:0], in_ };
    end
  end

endmodule