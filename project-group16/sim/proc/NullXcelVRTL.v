//========================================================================
// Null Accelerator Model
//========================================================================
// This is an empty accelerator model. It includes a single 32-bit
// register named xr0 for testing purposes. It includes a memory
// interface, but this memory interface is not used. The model is
// synthesizable and can be combined with an processor RTL model.
//
// We use a two-input normal queue to buffer up the xcelreq. This
// eliminates any combinational loops when composing the accelerator with
// the processor. We combinationally connect the en/rdy from the dequeue
// interface of the xcelreq queue to the xcelresp interface. Essentially,
// an xcelreq is buffered up and waits in the queue until the xcelresp
// interface is ready to accept it.
//
// We directly connect the data from an xcelreq to the input of the xr0
// register, and ideally we would directly connect the output of the xr0
// register to the data of an xcelresp; this would work fine because there
// is only a single accelerator register. So if we are reading or writing
// an accelerator register it must be that one. There is one catch though.
// We don't really have wildcards in our test sources, so it is easier if
// we force the xcelresp data to zero on a write. So we have a little bit
// of muxing to do this.
//
// The final part is that we need to figure out when to set the enable on
// the xr0 register. This register is enabled when the transaction at the
// head of the xcelreq queue is a write and when the xcelresp interface is
// ready.
//

`ifndef PROC_NULL_XCEL_V
`define PROC_NULL_XCEL_V

`include "vc/trace.v"

`include "vc/mem-msgs.v"
`include "vc/queues.v"
`include "proc/XcelMsg.v"

//========================================================================
// Null Xcel Implementation
//========================================================================

module proc_NullXcelVRTL
(
  input  logic        clk,
  input  logic        reset,

  // Interface

  output logic         xcelreq_rdy,
  input  logic         xcelreq_val,
  input  XcelReqMsg    xcelreq_msg,

  input  logic         xcelresp_rdy,
  output logic         xcelresp_val,
  output XcelRespMsg   xcelresp_msg,

  input  logic         memreq_rdy,
  output logic         memreq_val,
  output mem_req_4B_t  memreq_msg,

  output logic         memresp_rdy,
  input  logic         memresp_val,
  input  mem_resp_4B_t memresp_msg

);

  // Accelerator ports and queues

  logic        xcelreq_deq_val;
  logic        xcelreq_deq_rdy;
  XcelReqMsg   xcelreq_deq_msg;

  vc_Queue#(`VC_QUEUE_PIPE,$bits(xcelreq_msg),1) xcelreq_q
  (
    .clk     (clk),
    .reset   (reset),
    .num_free_entries(),
    .recv_val (xcelreq_val),
    .recv_rdy (xcelreq_rdy),
    .recv_msg (xcelreq_msg),
    .send_val (xcelreq_deq_val),
    .send_rdy (xcelreq_deq_rdy),
    .send_msg (xcelreq_deq_msg)
  );

  // Single accelerator register

  logic        xr0_en;
  logic [31:0] xr0, xr0_in;

  always_ff @(posedge clk) begin
    if ( xr0_en )
      xr0 <= xr0_in;
  end

  // Direct connections for xcelreq/xcelresp

  assign xr0_in             = xcelreq_deq_msg.data;
  assign xcelresp_msg.type_ = xcelreq_deq_msg.type_;

  // Even though memreq/memresp interface is not hooked up, we still
  // need to set the output ports correctly.

  assign memreq_val  = 0;
  assign memreq_msg  = '0;
  assign memresp_rdy = 0;

  assign xcelresp_val    = xcelreq_deq_val;
  assign xcelreq_deq_rdy = xcelresp_rdy;

  // Combinational block

  always_comb begin

    // Mux to force xcelresp data to zero on a write
    // Enable xr0 only upon write requests and both val/rdy on resp side

    if ( xcelreq_deq_msg.type_ == `XcelReqMsg_TYPE_WRITE ) begin
      xr0_en            = xcelresp_val && xcelresp_rdy;
      xcelresp_msg.data = '0;
    end
    else begin
      xr0_en            = 0;
      xcelresp_msg.data = xr0;
    end

  end

  //======================================================================
  // Line Tracing
  //======================================================================

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin
    $sformat( str, "xr%2x = %x", xcelreq_msg.addr, xcelreq_msg.data );
    vc_trace.append_val_rdy_str( trace_str, xcelreq_val, xcelreq_rdy, str );

    vc_trace.append_str( trace_str, "(" );
    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", xcelresp_msg.data );
    vc_trace.append_val_rdy_str( trace_str, xcelresp_val, xcelresp_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* PROC_NULL_XCEL_V */

