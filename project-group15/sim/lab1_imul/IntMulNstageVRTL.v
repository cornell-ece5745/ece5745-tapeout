//=========================================================================
// Integer Multiplier Nstage Pipelined Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_NSTAGE_V
`define LAB1_IMUL_INT_MUL_NSTAGE_V

`include "vc/trace.v"

// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Import your partial product step model here. Make sure you unit test it!
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

`include "lab1_imul/IntMulNstageStepVRTL.v"
`include "vc/regs.v"

// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

//=========================================================================
// Integer Multiplier Nstage Pipelined Implementation
//=========================================================================

module lab1_imul_IntMulNstageVRTL
#(
  parameter nstages = 4
)(
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
  // Instantiate the partial product steps here. Your design should be
  // parameterized by the number of pipeline stages given by the nstages
  // parameter.
  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

  // This might not be the most compact way to parameterize the pipelined
  // multiplier, but it has an exact one-to-one mapping to the approach
  // used in our PyMTL implementation.

  // Input registers

  logic        val_reg_in;
  logic        val_reg_out;
  logic        val_reg_en;

  vc_EnResetReg#(1) en_reg( clk, reset, val_reg_out, val_reg_in, val_reg_en );

  logic [31:0] a_reg_in;
  logic [31:0] a_reg_out;
  logic        a_reg_en;

  vc_EnReg#(32) a_reg( clk, reset, a_reg_out, a_reg_in, a_reg_en );

  logic [31:0] b_reg_in;
  logic [31:0] b_reg_out;
  logic        b_reg_en;

  vc_EnReg#(32) b_reg( clk, reset, b_reg_out, b_reg_in, b_reg_en );

  assign val_reg_in = recv_val;
  assign val_reg_en = send_rdy;

  assign a_reg_in  = recv_msg[63:32];
  assign a_reg_en  = send_rdy;

  assign b_reg_in  = recv_msg[31:0];
  assign b_reg_en  = send_rdy;

  // Instantiate steps

  logic        steps_in_val      [31:0];
  logic [31:0] steps_in_a        [31:0];
  logic [31:0] steps_in_b        [31:0];
  logic [31:0] steps_in_result   [31:0];

  logic        steps_out_val     [31:0];
  logic [31:0] steps_out_a       [31:0];
  logic [31:0] steps_out_b       [31:0];
  logic [31:0] steps_out_result  [31:0];

  genvar i;
  generate
    for ( i = 0; i < 32; i = i + 1 ) begin: STEPS

      lab1_imul_IntMulNstageStepVRTL steps
      (
        .in_val     ( steps_in_val[i]      ),
        .in_a       ( steps_in_a[i]       ),
        .in_b       ( steps_in_b[i]       ),
        .in_result  ( steps_in_result[i]  ),

        .out_val    ( steps_out_val[i]    ),
        .out_a      ( steps_out_a[i]      ),
        .out_b      ( steps_out_b[i]      ),
        .out_result ( steps_out_result[i] )
      );

    end
  endgenerate

  // Structural composition for first step

  assign steps_in_val[0]    = val_reg_out;
  assign steps_in_a[0]      = a_reg_out;
  assign steps_in_b[0]      = b_reg_out;
  assign steps_in_result[0] = 32'b0;

  // Pipeline registers

  logic        val_preg_in     [nstages-2:0];
  logic        val_preg_out    [nstages-2:0];
  logic        val_preg_en     [nstages-2:0];

  logic [31:0] a_preg_in       [nstages-2:0];
  logic [31:0] a_preg_out      [nstages-2:0];
  logic        a_preg_en       [nstages-2:0];

  logic [31:0] b_preg_in       [nstages-2:0];
  logic [31:0] b_preg_out      [nstages-2:0];
  logic        b_preg_en       [nstages-2:0];

  logic [31:0] result_preg_in  [nstages-2:0];
  logic [31:0] result_preg_out [nstages-2:0];
  logic        result_preg_en  [nstages-2:0];

  genvar j;
  generate
    for ( j = 0; j < nstages-1; j = j + 1 ) begin: PREG

      vc_EnResetReg#(1) val_preg( .clk(clk), .reset(reset),
        .q  (val_preg_out[j]),
        .d  (val_preg_in[j]),
        .en (val_preg_en[j])
      );

      vc_EnReg#(32) a_preg( .clk(clk), .reset(reset),
        .q  (a_preg_out[j]),
        .d  (a_preg_in[j]),
        .en (a_preg_en[j])
      );

      vc_EnReg#(32) b_preg( .clk(clk), .reset(reset),
        .q  (b_preg_out[j]),
        .d  (b_preg_in[j]),
        .en (b_preg_en[j])
      );

      vc_EnReg#(32) result_preg( .clk(clk), .reset(reset),
        .q  (result_preg_out[j]),
        .d  (result_preg_in[j]),
        .en (result_preg_en[j])
      );

    end
  endgenerate

  // Structural composition for intermediate steps

  genvar k;
  generate
    for ( k = 1; k < 32; k = k + 1 ) begin: CONNECT

      // Insert a pipeline register

      if ( (k % (32/nstages)) == 0 ) begin
        localparam integer nstage = (k/(32/nstages)) - 1;

        assign val_preg_in[nstage]    = steps_out_val[k-1];
        assign a_preg_in[nstage]      = steps_out_a[k-1];
        assign b_preg_in[nstage]      = steps_out_b[k-1];
        assign result_preg_in[nstage] = steps_out_result[k-1];

        assign steps_in_val[k]        = val_preg_out[nstage];
        assign steps_in_a[k]          = a_preg_out[nstage];
        assign steps_in_b[k]          = b_preg_out[nstage];
        assign steps_in_result[k]     = result_preg_out[nstage];

        assign val_preg_en[nstage]    = send_rdy;
        assign a_preg_en[nstage]      = send_rdy;
        assign b_preg_en[nstage]      = send_rdy;
        assign result_preg_en[nstage] = send_rdy;

      end

      // No pipeline register

      else begin

        assign steps_in_val[k]        = steps_out_val[k-1];
        assign steps_in_a[k]          = steps_out_a[k-1];
        assign steps_in_b[k]          = steps_out_b[k-1];
        assign steps_in_result[k]     = steps_out_result[k-1];

      end

    end
  endgenerate

  // Structural composition for last step

  assign send_val = steps_out_val[31];
  assign send_msg = steps_out_result[31] & {32{send_val}}; //4-state-sim fix

  // Wire send rdy to recv rdy

  assign recv_rdy  = send_rdy;

  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  integer f;
  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x", recv_msg );
    vc_trace.append_val_rdy_str( trace_str, recv_val, recv_rdy, str );

    vc_trace.append_str( trace_str, "(" );

    // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Add line tracing code here.
    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

    if ( val_reg_out ) begin
      vc_trace.append_str( trace_str, "*" );
    end else begin
      vc_trace.append_str( trace_str, " " );
    end

    for ( f = 0; f < nstages-1; f = f + 1 ) begin: TRACE
      if ( val_preg_out[f] ) begin
        vc_trace.append_str( trace_str, "*" );
      end else begin
        vc_trace.append_str( trace_str, " " );
      end
    end

    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", send_msg );
    vc_trace.append_val_rdy_str( trace_str, send_val, send_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_NSTAGE_V */
