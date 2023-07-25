/*
==========================================================================
ShiftReg.v
==========================================================================
N-bit shift register.
*/

`ifndef SPI_V3_COMPONENTS_SHIFTREG_V
`define SPI_V3_COMPONENTS_SHIFTREG_V

module SPI_v3_components_ShiftReg
#(
    parameter nbits = 8,
    parameter reset_value = 1'b0
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
  
  always_ff @(posedge clk) begin 
    if ( reset ) begin
      out <= { nbits{reset_value}};
    end else if ( load_en ) begin
      out <= load_data;
    end else if ( ( ~load_en ) & shift_en ) begin
      out <= { out[nbits-2:0], in_ };
    end
  end

endmodule

`endif /* SPI_V3_COMPONENTS_SHIFTREG_V */