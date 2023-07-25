//========================================================================
// Echo Unit RTL Wrapper
//========================================================================

`ifndef PROJECT_ECHO_UNIT_V
`define PROJECT_ECHO_UNIT_V

`include "vc/trace.v"
`include "../hls/echo/synthesis/Catapult/echo_int.v1/concat_rtl.v"

module project_echo_EchoUnitRTL
(
  input  logic clk,
  input  logic reset,

  input  logic             recv_val,
  output logic             recv_rdy,
  input  logic [10:0]      recv_msg,

  output logic             send_val,
  input  logic             send_rdy,
  output logic [10:0]      send_msg
);

echo_int echo(
  .clk            (clk),
  .rst            (reset),
  .in_rsc_dat     (recv_msg),
  .in_rsc_vld     (recv_val),
  .in_rsc_rdy     (recv_rdy),
  .out_rsc_dat    (send_msg),
  .out_rsc_vld    (send_val),
  .out_rsc_rdy    (send_rdy)
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

`endif /* PROJECT_ECHO_UNIT_V */

