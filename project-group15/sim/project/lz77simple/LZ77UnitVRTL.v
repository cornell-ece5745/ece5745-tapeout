//========================================================================
// LZ77 Unit RTL Wrapper
//========================================================================

`ifndef LZ77_UNIT_V
`define LZ77_UNIT_V

`include "vc/trace.v"
`include "project/lz77simple/concat_rtl.v"

module project_lz77simple_LZ77UnitVRTL
(
  input  logic clk,
  input  logic reset,

  input  logic             recv_val,
  output logic             recv_rdy,
  input  logic [31:0]       recv_msg,

  output logic             send_val,
  input  logic             send_rdy,
  output logic [31:0]      send_msg
);


lz77simple lz77(
  .clk            (clk), 
  .rst            (reset), 
  .dest_rsc_dat   (send_msg), 
  .dest_rsc_vld   (send_val), 
  .dest_rsc_rdy   (send_rdy),
  .src_rsc_dat    (recv_msg), 
  .src_rsc_vld    (recv_val), 
  .src_rsc_rdy    (recv_rdy)
);
  

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    vc_trace.append_str( trace_str, "(" );

    // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Define line trace here
    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    
    $sformat(str, "%x", recv_msg);
    vc_trace.append_val_rdy_str(trace_str, recv_val, recv_rdy, str);

    vc_trace.append_str( trace_str, "(" );
    vc_trace.append_str( trace_str, ")" );
    
    $sformat( str, "%x", send_msg );
    vc_trace.append_val_rdy_str( trace_str, send_val, send_rdy, str );

    vc_trace.append_str( trace_str, ")" );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LZ77_UNIT_V */

