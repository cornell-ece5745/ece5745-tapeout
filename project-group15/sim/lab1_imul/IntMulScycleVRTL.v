//=========================================================================
// Integer Multiplier Single-Cycle Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_SCYCLE_V
`define LAB1_IMUL_INT_MUL_SCYCLE_V

`include "vc/trace.v"
`include "vc/regs.v"

//=========================================================================
// Integer Multiplier Single-Cycle Implementation
//=========================================================================

module lab1_imul_IntMulScycleVRTL
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

  // Input registers

  logic val_reg_out;

  vc_EnResetReg#(1) val_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (recv_val),
    .en    (send_rdy),
    .q     (val_reg_out)
  );

  logic [31:0] a_reg_out;

  vc_EnReg#(32) a_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (recv_msg[63:32]),
    .en    (send_rdy),
    .q     (a_reg_out)
  );

  logic [31:0] b_reg_out;

  vc_EnReg#(32) b_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (recv_msg[31:0]),
    .en    (send_rdy),
    .q     (b_reg_out)
  );

  logic [31:0] product;

  assign recv_rdy = send_rdy;
  assign send_val = val_reg_out;
  assign product  = a_reg_out * b_reg_out;
  assign send_msg = product & {32{send_val}}; // 4-state sim fix

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

    if ( val_reg_out ) begin
      vc_trace.append_str( trace_str, "*" );
    end else begin
      vc_trace.append_str( trace_str, " " );
    end

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", send_msg );
    vc_trace.append_val_rdy_str( trace_str, send_val, send_rdy, str );
  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_SCYCLE_V */
