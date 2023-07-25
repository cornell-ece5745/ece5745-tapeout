//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`ifndef MEM_TEST_INIT_RegFileVRTL
`define MEM_TEST_INIT_RegFileVRTL

`include "vc/trace.v"
`include "mem_test_init/initial.dat"
// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Define datapath and control unit here.
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

module mem_test_init_RegFileVRTL
(
  input  logic        clk,
  input  logic        reset,

  input  logic        recv_val,
  output logic        recv_rdy,
  input  logic [63:0] recv_msg,

  output logic        send_val,
  input  logic        send_rdy,
  output logic [31:0] send_msg
);

  // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Instantiate datapath and control models here and then connect them
  // together.
  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
logic [31:0] useless_data;

always_ff @( posedge clk ) begin
  send_val <= recv_val;
end   
assign recv_rdy = 1;

regfile 
#(
  .p_data_nbits(32),
  .p_num_entries(3)
)test_RegFile(
  .clk(clk),
  .reset(reset),

  .write_en0(1'd0),
  .write_addr0('d0),
  .write_data0(recv_msg[31:0]),

  .write_en1(1'd0),
  .write_addr1('d1),
  .write_data1(recv_msg[31:0]),

  .read_addr0('d3),
  .read_data0(send_msg[31:0]),

  .read_addr1('d1),
  .read_data1(useless_data)
);

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x", recv_msg );
    vc_trace.append_val_rdy_str( trace_str, recv_val, recv_rdy, str );

    vc_trace.append_str( trace_str, "(" );

    // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Add additional line tracing using the helper tasks for
    // internal state including the current FSM state.
    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", send_msg );
    vc_trace.append_val_rdy_str( trace_str, send_val, send_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule
module regfile
#(
  parameter p_data_nbits  = 1,
  parameter p_num_entries = 2,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits  = $clog2(p_num_entries)
)(
  input  logic                    clk,
  input  logic                    reset,

  // Read port 0 (combinational read)

  input  logic [c_addr_nbits-1:0] read_addr0,
  output logic [p_data_nbits-1:0] read_data0,

  // Read port 1 (combinational read)

  input  logic [c_addr_nbits-1:0] read_addr1,
  output logic [p_data_nbits-1:0] read_data1,

  // Write port (sampled on the rising clock edge)

  input  logic                    write_en0,
  input  logic [c_addr_nbits-1:0] write_addr0,
  input  logic [p_data_nbits-1:0] write_data0,

  // Write port (sampled on the rising clock edge)

  input  logic                    write_en1,
  input  logic [c_addr_nbits-1:0] write_addr1,
  input  logic [p_data_nbits-1:0] write_data1
);

  logic [p_data_nbits-1:0] rfile[p_num_entries-1:0];
  initial  $readmemh("initial.mem", rfile);
  // Combinational read

  assign read_data0 = rfile[read_addr0];
  assign read_data1 = rfile[read_addr1];

  // Write on positive clock edge

  always_ff @( posedge clk ) begin

    if ( write_en0 )
      rfile[write_addr0] <= write_data0;

    if ( write_en1 )
      rfile[write_addr1] <= write_data1;

  end

  // Assertions

  /*
  always_ff @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( write_en0 );
      `VC_ASSERT_NOT_X( write_en1 );

      // If write_en is one, then write address better be less than the
      // number of entries and definitely cannot be X's.

      if ( write_en0 ) begin
        `VC_ASSERT_NOT_X( write_addr0 );
        `VC_ASSERT( write_addr0 < p_num_entries );
      end

      if ( write_en1 ) begin
        `VC_ASSERT_NOT_X( write_addr1 );
        `VC_ASSERT( write_addr1 < p_num_entries );
      end

      // It is invalid to use the same write address for both write ports

      if ( write_en0 && write_en1 ) begin
        `VC_ASSERT( write_addr0 != write_addr1 );
      end

    end
  end
  */

endmodule


`endif /* AREA_TEST_RegFileVRTL */

