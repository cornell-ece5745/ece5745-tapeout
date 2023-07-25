//========================================================================
// Generic Parameterized SRAM
//========================================================================
// This is meant to be instantiated within a carefully named outer module
// so the outer module corresponds to an SRAM generated with the
// OpenRAM memory compiler.

`ifndef SRAM_SRAM_GENERIC_V
`define SRAM_SRAM_GENERIC_V

module sram_SramGenericVRTL
#(
  parameter p_data_nbits  = 1,
  parameter p_num_entries = 2,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits  = $clog2(p_num_entries),
  parameter c_data_nbytes = (p_data_nbits+7)/8 // $ceil(p_data_nbits/8)
)(
  input  logic                      clk0,  // clk
  input  logic                      web0,  // bar( write en )
  input  logic                      csb0,  // bar( whole SRAM en )
  input  logic [c_addr_nbits-1:0]   addr0, // address
  input  logic [p_data_nbits-1:0]   din0,  // write data
  output logic [p_data_nbits-1:0]   dout0  // read data
);

  logic [p_data_nbits-1:0] mem[p_num_entries-1:0];

  logic [p_data_nbits-1:0] data_out1;
  logic [p_data_nbits-1:0] wdata1;

  always @( posedge clk0 ) begin

    // Read path

    if ( ~csb0 && web0 )
      data_out1 <= mem[addr0];
    else
      data_out1 <= {p_data_nbits{1'bx}};

  end

  // Write path

  genvar i;
  generate
    for ( i = 0; i < c_data_nbytes; i = i + 1 )
    begin : write
      always @( posedge clk0 ) begin
        if ( ~csb0 && ~web0 )
          mem[addr0][ (i+1)*8-1 : i*8 ] <= din0[ (i+1)*8-1 : i*8 ];
      end
    end
  endgenerate

  assign dout0 = data_out1;

endmodule

`endif /* SRAM_SRAM_GENERIC_V */
