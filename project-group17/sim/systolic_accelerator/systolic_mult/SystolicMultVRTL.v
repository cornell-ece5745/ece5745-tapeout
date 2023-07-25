//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`ifndef SystolicMultVRTL
`define SystolicMultVRTL

`include "systolic_accelerator/systolic_mult/SystolicMult.v"
`include "systolic_accelerator/msg_structs/systolic_msgs.v"
// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Define datapath and control unit here.
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


parameter SYSTOLIC_SIZE = 2;
parameter SYSTOLIC_STEP_SIZE = 6;

module systolic_accelerator_systolic_mult_SystolicMultVRTL
(
  input logic reset,
  input logic clk,

  input systolic_mult_recv_msg recv_msg,
  input logic recv_val,
  output logic recv_rdy,

  output systolic_mult_send_msg send_msg,
  output logic send_val,
  input logic send_rdy
);

assign recv_rdy = 1'b1;

SystolicMult #(
	INT_WIDTH,
	FRAC_WIDTH,
  SYSTOLIC_SIZE,
  SYSTOLIC_STEP_SIZE
) systolicMult
(
  .reset(reset),
  .clk(clk),
  .recv_msg(recv_msg),
  .recv_val(recv_val),
  .recv_rdy(),
  .send_msg(send_msg),
  .send_val(send_val),
  .send_rdy(send_rdy),
  .produce_run()
);

`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
`VC_TRACE_BEGIN
begin

   // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Define line trace here
  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/
  $sformat( str, "wr:%x:%x:%x:%x:%x:%x:%x", recv_msg.weight_0, recv_msg.weight_1, recv_msg.data_0, recv_msg.data_1, recv_msg.mode, recv_msg.run, recv_msg.final_run);
  vc_trace.append_val_rdy_str( trace_str, recv_val, recv_rdy, str );
  $sformat( str, " > " );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "(" );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "PE00:%x:%x:%x", systolicMult.pe0.a, systolicMult.pe0.b, systolicMult.pe0.sum_result  );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "|PE01:%x:%x:%x", systolicMult.pe1.a, systolicMult.pe1.b, systolicMult.pe1.sum_result  );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "|PE10:%x:%x:%x", systolicMult.pe2.a, systolicMult.pe2.b, systolicMult.pe2.sum_result  );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "|PE11:%x:%x:%x", systolicMult.pe3.a, systolicMult.pe3.b, systolicMult.pe3.sum_result  );
  vc_trace.append_str( trace_str, str );
  $sformat( str, ") > " );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "rd:%x:%x", send_msg.result_0, send_msg.result_1);
  vc_trace.append_val_rdy_str( trace_str, send_val, send_rdy, str );

end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule


`endif /* SystolicMultVRTL */