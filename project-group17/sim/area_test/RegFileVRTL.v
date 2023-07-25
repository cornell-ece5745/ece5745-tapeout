//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`ifndef AREA_TEST_RegFileVRTL
`define AREA_TEST_RegFileVRTL

`include "vc/trace.v"

// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Define datapath and control unit here.
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

module area_test_RegFileVRTL
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
parameter ENTRIES = 4096;
logic [$clog2(ENTRIES)-1:0] cnt;


logic val_pipe;


always_ff @( posedge clk ) begin
  val_pipe <= recv_val;
  if(reset) cnt <= 0;
  else if( cnt < ENTRIES-1 ) cnt <= cnt + 1;
  else cnt <= 0;
end

logic [31:0] send_msg_in;
assign send_val = reset? 'd0 :((val_pipe == 1'b1) ? 1'd1 : 1'd0);

assign send_msg[31:0] = 'd0;


assign recv_rdy = 1'd1;
vc_ResetRegfile_1r1w 
#(
  .p_data_nbits(32),
  .p_num_entries(ENTRIES),
  .p_reset_value('d0)
)test_RegFile(
  .clk(clk),
  .reset(reset),

  .write_en(1'd1),
  .write_addr(cnt),
  .write_data(recv_msg[31:0]),

  .read_addr(11'd0),
  .read_data(send_msg_in[31:0])
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
//------------------------------------------------------------------------
// 1r1w register file with reset
//------------------------------------------------------------------------

module vc_ResetRegfile_1r1w
#(
  parameter p_data_nbits  = 1,
  parameter p_num_entries = 2,
  parameter p_reset_value = 0,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits  = $clog2(p_num_entries)
)(
  input  logic                    clk,
  input  logic                    reset,

  // Read port (combinational read)

  input  logic [c_addr_nbits-1:0] read_addr,
  output logic [p_data_nbits-1:0] read_data,

  // Write port (sampled on the rising clock edge)

  input  logic                    write_en,
  input  logic [c_addr_nbits-1:0] write_addr,
  input  logic [p_data_nbits-1:0] write_data
);

  logic [p_data_nbits-1:0] rfile[p_num_entries-1:0];

  // Combinational read

  assign read_data = rfile[read_addr];

  // Write on positive clock edge. We have to use a generate statement to
  // allow us to include the reset logic for each individual register.

  genvar i;
  generate
    for ( i = 0; i < p_num_entries; i = i+1 )
    begin : wport
      always_ff @( posedge clk )
        if ( reset )
          rfile[i] <= p_reset_value;
        else if ( write_en && (i[c_addr_nbits-1:0] == write_addr) )
          rfile[i] <= write_data;
    end
  endgenerate

  // Assertions

  /*
  always_ff @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( write_en );

      // If write_en is one, then write address better be less than the
      // number of entries and definitely cannot be X's.

      if ( write_en ) begin
        `VC_ASSERT_NOT_X( write_addr );
        `VC_ASSERT( write_addr < p_num_entries );
      end

    end
  end
  */

endmodule


`endif /* AREA_TEST_RegFileVRTL */

