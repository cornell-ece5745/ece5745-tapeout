/*
==========================================================================
Synchronizer.v
==========================================================================
 - RTL code for the Synchronizer module.
 - It samples the input signal using the device clock and also detects
     positive and negative edges.
 - Reference: https://www.fpga4fun.com/SPI2.html
*/

`ifndef SPI_V3_COMPONENTS_SYNCHRONIZER_V
`define SPI_V3_COMPONENTS_SYNCHRONIZER_V

module SPI_v3_components_Synchronizer 
#(
  parameter reset_value = 1'b0
)(
  input  logic clk ,
  input  logic in_,
  output logic negedge_,
  output logic out,
  output logic posedge_,
  input  logic reset 
);

  logic [2:0] shreg;
  
  always_comb begin
    negedge_ = shreg[2] & ( ~shreg[1] );
    posedge_ = ( ~shreg[2] ) & shreg[1];
  end
  
  always_ff @(posedge clk) begin
    if ( reset ) begin
      shreg <= { 3{reset_value} };
    end
    else
      shreg <= { shreg[1:0], in_ };
  end

  assign out = shreg[1];

endmodule

`endif /* SPI_V3_COMPONENTS_SYNCHRONIZER_V */