//=========================================================================
// 5-Stage Simple Pipelined Processor
//=========================================================================

`ifndef PROC_PROC_V
`define PROC_PROC_V

`include "vc/mem-msgs.v"
`include "vc/queues.v"
`include "vc/trace.v"

`include "proc/TinyRV2InstVRTL.v"
`include "proc/ProcCtrlVRTL.v"
`include "proc/ProcDpathVRTL.v"
`include "proc/DropUnitVRTL.v"
`include "proc/XcelMsg.v"

module proc_ProcVRTL
#(
  parameter p_num_cores = 1
)
(
  input  logic         clk,
  input  logic         reset,

  // core_id is an input port rather than a parameter so that
  // the module only needs to be compiled once. If it were a parameter,
  // each core would be compiled separately.
  input  logic [31:0]  core_id,

  // From mngr streaming port

  input  logic [31:0]  mngr2proc_msg,
  input  logic         mngr2proc_val,
  output logic         mngr2proc_rdy,

  // To mngr streaming port

  output logic [31:0]  proc2mngr_msg,
  output logic         proc2mngr_val,
  input  logic         proc2mngr_rdy,

  // Xcelresp port

  input  XcelRespMsg     xcelresp_msg,
  input  logic           xcelresp_val,
  output logic           xcelresp_rdy,

  // Xcelreq port

  output XcelReqMsg      xcelreq_msg,
  output logic           xcelreq_val,
  input  logic           xcelreq_rdy,

  // Instruction Memory Request Port

  output mem_req_4B_t  imemreq_msg,
  output logic         imemreq_val,
  input  logic         imemreq_rdy,

  // Instruction Memory Response Port

  input  mem_resp_4B_t imemresp_msg,
  input  logic         imemresp_val,
  output logic         imemresp_rdy,

  // Data Memory Request Port

  output mem_req_4B_t  dmemreq_msg,
  output logic         dmemreq_val,
  input  logic         dmemreq_rdy,

  // Data Memory Response Port

  input  mem_resp_4B_t dmemresp_msg,
  input  logic         dmemresp_val,
  output logic         dmemresp_rdy,

  // stats output

  output logic         commit_inst,

  output logic         stats_en

);

  //----------------------------------------------------------------------
  // data mem req/resp
  //----------------------------------------------------------------------

  // imemreq before pack

  logic [31:0] imemreq_msg_addr;

  // imemreq_enq signals after pack before bypass queue

  mem_req_4B_t imemreq_enq_msg;
  logic        imemreq_enq_val;
  logic        imemreq_enq_rdy;

  // dmemreq signals before bypass queue

  mem_req_4B_t  dmemreq_enq_msg;
  assign dmemreq_enq_msg.opaque= 8'b0; // Tie these explicitly to zero to pass 4-state sim
  assign dmemreq_enq_msg.len   = 2'b0; 
  logic         dmemreq_enq_val;
  logic         dmemreq_enq_rdy;

  // proc2mngr signals before bypass queue

  logic [31:0] proc2mngr_enq_msg;
  logic        proc2mngr_enq_val;
  logic        proc2mngr_enq_rdy;

  // imemresp signals after the drop unit

  mem_resp_4B_t imemresp_msg_drop;
  logic         imemresp_val_drop;
  logic         imemresp_rdy_drop;

  // imemresp drop signal

  logic        imemresp_drop;

  // accelerator specific

  // xcelreq signals before bypass queue

  XcelReqMsg  xcelreq_enq_msg;
  logic       xcelreq_enq_val;
  logic       xcelreq_enq_rdy;

//''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''
// Connect components
//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

  // control signals (ctrl->dpath)

  logic        reg_en_F;
  logic [1:0]  pc_sel_F;

  logic        reg_en_D;
  logic [1:0]  op1_byp_sel_D;
  logic [1:0]  op2_byp_sel_D;
  logic        op1_sel_D;
  logic [1:0]  op2_sel_D;
  logic [1:0]  csrr_sel_D;
  logic [2:0]  imm_type_D;
  logic        imul_req_val_D;

  logic        reg_en_X;
  logic [3:0]  alu_fn_X;
  logic [1:0]  ex_result_sel_X;
  logic        imul_resp_rdy_X;

  logic        reg_en_M;
  logic [1:0]  wb_result_sel_M;

  logic        reg_en_W;
  logic [4:0]  rf_waddr_W;
  logic        rf_wen_W;
  logic        stats_en_wen_W;

  // status signals (dpath->ctrl)

  logic [31:0] inst_D;
  logic        imul_req_rdy_D;
  logic        imul_resp_val_X;

  logic        br_cond_eq_X;
  logic        br_cond_lt_X;
  logic        br_cond_ltu_X;

//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

  //----------------------------------------------------------------------
  // Pack Memory Request Messages
  //----------------------------------------------------------------------

  assign imemreq_enq_msg.type_  = `VC_MEM_REQ_MSG_TYPE_READ;
  assign imemreq_enq_msg.opaque = 8'b0;
  assign imemreq_enq_msg.addr   = imemreq_msg_addr;
  assign imemreq_enq_msg.len    = 2'd0;
  assign imemreq_enq_msg.data   = 32'b0; // jtb237, tied this explicitly to zero for 4-state simulation

  //----------------------------------------------------------------------
  // Imem Drop Unit
  //----------------------------------------------------------------------

  vc_DropUnit #($bits(mem_resp_4B_t)) imem_drop_unit
  (
    .clk      (clk),
    .reset    (reset),

    .drop     (imemresp_drop),

    .in_msg   (imemresp_msg),
    .in_val   (imemresp_val),
    .in_rdy   (imemresp_rdy),

    .out_msg  (imemresp_msg_drop),
    .out_val  (imemresp_val_drop),
    .out_rdy  (imemresp_rdy_drop)
  );


//''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''
// Add components
//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

  //----------------------------------------------------------------------
  // Control Unit
  //----------------------------------------------------------------------

  proc_ProcCtrlVRTL ctrl
  (
    .clk                    (clk),
    .reset                  (reset),

    // Instruction Memory Port

    .imemreq_val            (imemreq_enq_val),
    .imemreq_rdy            (imemreq_enq_rdy),
    .imemresp_val           (imemresp_val_drop),
    .imemresp_rdy           (imemresp_rdy_drop),

    // Drop signal

    .imemresp_drop          (imemresp_drop),

    // Data Memory Port

    .dmemreq_val            (dmemreq_enq_val),
    .dmemreq_rdy            (dmemreq_enq_rdy),
    .dmemreq_msg_type       (dmemreq_enq_msg.type_),
    .dmemresp_val           (dmemresp_val),
    .dmemresp_rdy           (dmemresp_rdy),

    // mngr communication ports

    .mngr2proc_val          (mngr2proc_val),
    .mngr2proc_rdy          (mngr2proc_rdy),
    .proc2mngr_val          (proc2mngr_enq_val),
    .proc2mngr_rdy          (proc2mngr_enq_rdy),

    // xcel ports

    .xcelreq_val            (xcelreq_enq_val),
    .xcelreq_rdy            (xcelreq_enq_rdy),
    .xcelreq_msg_type       (xcelreq_enq_msg.type_),

    .xcelresp_val           (xcelresp_val),
    .xcelresp_rdy           (xcelresp_rdy),

    // control signals (ctrl->dpath)

    .reg_en_F               (reg_en_F),
    .pc_sel_F               (pc_sel_F),

    .reg_en_D               (reg_en_D),
    .op1_byp_sel_D          (op1_byp_sel_D),
    .op2_byp_sel_D          (op2_byp_sel_D),
    .op1_sel_D              (op1_sel_D),
    .op2_sel_D              (op2_sel_D),
    .csrr_sel_D             (csrr_sel_D),
    .imm_type_D             (imm_type_D),
    .imul_req_val_D         (imul_req_val_D),

    .reg_en_X               (reg_en_X),
    .alu_fn_X               (alu_fn_X),
    .ex_result_sel_X        (ex_result_sel_X),
    .imul_resp_rdy_X        (imul_resp_rdy_X),

    .reg_en_M               (reg_en_M),
    .wb_result_sel_M        (wb_result_sel_M),

    .reg_en_W               (reg_en_W),
    .rf_waddr_W             (rf_waddr_W),
    .rf_wen_W               (rf_wen_W),
    .stats_en_wen_W         (stats_en_wen_W),

    // status signals (dpath->ctrl)

    .inst_D                 (inst_D),
    .imul_req_rdy_D         (imul_req_rdy_D),

    .imul_resp_val_X        (imul_resp_val_X),
    .br_cond_eq_X           (br_cond_eq_X),
    .br_cond_lt_X           (br_cond_lt_X),
    .br_cond_ltu_X          (br_cond_ltu_X),

    .commit_inst            (commit_inst)
  );

//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

  //----------------------------------------------------------------------
  // Bypass Queue
  //----------------------------------------------------------------------

  logic [1:0] imemreq_q_num_free_entries;
  mem_req_4B_t imemreq_msg_raw; // 4-state sim fix

  vc_Queue#(`VC_QUEUE_BYPASS,$bits(mem_req_4B_t),2) imemreq_q
  (
    .clk     (clk),
    .reset   (reset),
    .num_free_entries(imemreq_q_num_free_entries),
    .recv_val (imemreq_enq_val),
    .recv_rdy (imemreq_enq_rdy),
    .recv_msg (imemreq_enq_msg),
    .send_val (imemreq_val),
    .send_rdy (imemreq_rdy),
    .send_msg (imemreq_msg_raw)
  );

  assign imemreq_msg = imemreq_msg_raw & {78{imemreq_val}}; // 4-state sim fix

  // logic [1:0] dmemreq_q_num_free_entries;
  logic dmemreq_q_num_free_entries;
  mem_req_4B_t dmemreq_msg_raw; // 4-state sim fix

  vc_Queue#(`VC_QUEUE_BYPASS,$bits(mem_req_4B_t),1) dmemreq_q
  (
    .clk     (clk),
    .reset   (reset),
    .num_free_entries(dmemreq_q_num_free_entries),
    .recv_val (dmemreq_enq_val),
    .recv_rdy (dmemreq_enq_rdy),
    .recv_msg (dmemreq_enq_msg),
    .send_val (dmemreq_val),
    .send_rdy (dmemreq_rdy),
    .send_msg (dmemreq_msg_raw)
  );

  // Force data to zero in read req messages, if type is 1 (READ), force data to zero
  mem_req_4B_t dmemreq_msg_and_val;
  assign dmemreq_msg_and_val = dmemreq_msg_raw & {78{dmemreq_val}}; // and with the valid bit

  always_comb begin
    if (dmemreq_val && (dmemreq_msg_and_val.type_ == `VC_MEM_REQ_MSG_TYPE_READ)) begin
      dmemreq_msg = {dmemreq_msg_and_val[77:32], {32{1'b0}}};
    end
    else begin
      dmemreq_msg = dmemreq_msg_and_val;
    end
  end // 4 state sim fix

  logic proc2mngr_q_num_free_entries;
  logic [31:0] proc2mngr_msg_raw;  // 4-state sim fix

  vc_Queue#(`VC_QUEUE_BYPASS,32,1) proc2mngr_q
  (
    .clk     (clk),
    .reset   (reset),
    .num_free_entries(proc2mngr_q_num_free_entries),
    .recv_val (proc2mngr_enq_val),
    .recv_rdy (proc2mngr_enq_rdy),
    .recv_msg (proc2mngr_enq_msg),
    .send_val (proc2mngr_val),
    .send_rdy (proc2mngr_rdy),
    .send_msg (proc2mngr_msg_raw)
  );

  assign proc2mngr_msg = proc2mngr_msg_raw & {32{proc2mngr_val}}; //4-state sim fix


  // xcel

  logic xcelreq_q_num_free_entries;
  logic [37:0] xcelreq_msg_raw; //4-state sim fix

  vc_Queue#(`VC_QUEUE_BYPASS,$bits(xcelreq_msg),1) xcelreq_q
  (
    .clk     (clk),
    .reset   (reset),
    .num_free_entries(xcelreq_q_num_free_entries),
    .recv_val (xcelreq_enq_val),
    .recv_rdy (xcelreq_enq_rdy),
    .recv_msg (xcelreq_enq_msg),
    .send_val (xcelreq_val),
    .send_rdy (xcelreq_rdy),
    .send_msg (xcelreq_msg_raw)
  );

  mem_req_4B_t xcelreq_msg_and_val;
  assign xcelreq_msg_and_val = xcelreq_msg_raw & {38{xcelreq_val}}; // and with the valid bit

  always_comb begin // If read type xcel msg, force data to zero
    if (xcelreq_val && (xcelreq_msg_and_val[37] == 1'd0)) begin
      xcelreq_msg = {xcelreq_msg_and_val[37:32], {32{1'b0}}};
    end
    else begin
      xcelreq_msg = xcelreq_msg_and_val;
    end
  end // 4 state sim fix

  // assign xcelreq_msg = xcelreq_msg_and_val;
  // assign xcelreq_msg = xcelreq_msg_raw & {38{xcelreq_val}}; //4-state sim fix

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  proc_ProcDpathVRTL
  #(
    .p_num_cores             (p_num_cores)
  )
  dpath
  (
    .clk                     (clk),
    .reset                   (reset),

    // core id
    .core_id                 (core_id),

    // Instruction Memory Port

    .imemreq_msg_addr        (imemreq_msg_addr),
    .imemresp_msg            (imemresp_msg_drop),

    // Data Memory Port

    .dmemreq_msg_addr        (dmemreq_enq_msg.addr),
    .dmemreq_msg_data        (dmemreq_enq_msg.data),
    .dmemresp_msg_data       (dmemresp_msg.data),

    // mngr communication ports

    .mngr2proc_data          (mngr2proc_msg),
    .proc2mngr_data          (proc2mngr_enq_msg),

    // xcel ports

    .xcelreq_msg_data        (xcelreq_enq_msg.data),
    .xcelreq_msg_addr        (xcelreq_enq_msg.addr),
    .xcelresp_msg_data       (xcelresp_msg.data),

    // control signals (ctrl->dpath)

    .reg_en_F                (reg_en_F),
    .pc_sel_F                (pc_sel_F),

    .reg_en_D                (reg_en_D),
    .op1_byp_sel_D           (op1_byp_sel_D),
    .op2_byp_sel_D           (op2_byp_sel_D),
    .op1_sel_D               (op1_sel_D),
    .op2_sel_D               (op2_sel_D),
    .csrr_sel_D              (csrr_sel_D),
    .imm_type_D              (imm_type_D),
    .imul_req_val_D          (imul_req_val_D),

    .reg_en_X                (reg_en_X),
    .alu_fn_X                (alu_fn_X),
    .ex_result_sel_X         (ex_result_sel_X),
    .imul_resp_rdy_X         (imul_resp_rdy_X),

    .reg_en_M                (reg_en_M),
    .wb_result_sel_M         (wb_result_sel_M),

    .reg_en_W                (reg_en_W),
    .rf_waddr_W              (rf_waddr_W),
    .rf_wen_W                (rf_wen_W),
    .stats_en_wen_W          (stats_en_wen_W),

    // status signals (dpath->ctrl)

    .inst_D                  (inst_D),
    .imul_req_rdy_D          (imul_req_rdy_D),

    .imul_resp_val_X         (imul_resp_val_X),
    .br_cond_eq_X            (br_cond_eq_X),
    .br_cond_lt_X            (br_cond_lt_X),
    .br_cond_ltu_X           (br_cond_ltu_X),

    // stats_en

    .stats_en                (stats_en)
  );

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  rv2isa_InstTasks rv2isa();

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin
    if ( !ctrl.val_F )
      vc_trace.append_chars( trace_str, " ", 8 );
    else if ( ctrl.squash_F ) begin
      vc_trace.append_str( trace_str, "~" );
      vc_trace.append_chars( trace_str, " ", 8-1 );
    end else if ( ctrl.stall_F ) begin
      vc_trace.append_str( trace_str, "#" );
      vc_trace.append_chars( trace_str, " ", 8-1 );
    end else begin
      $sformat( str, "%x", dpath.pc_F );
      vc_trace.append_str( trace_str, str );
    end

    vc_trace.append_str( trace_str, "|" );

    if ( !ctrl.val_D )
      vc_trace.append_chars( trace_str, " ", 23 );
    else if ( ctrl.squash_D ) begin
      vc_trace.append_str( trace_str, "~" );
      vc_trace.append_chars( trace_str, " ", 23-1 );
    end else if ( ctrl.stall_D ) begin
      vc_trace.append_str( trace_str, "#" );
      vc_trace.append_chars( trace_str, " ", 23-1 );
    end else
      vc_trace.append_str( trace_str, { 3896'b0, rv2isa.disasm( ctrl.inst_D ) } );

    vc_trace.append_str( trace_str, "|" );

    if ( !ctrl.val_X )
      vc_trace.append_chars( trace_str, " ", 4 );
    else if ( ctrl.stall_X ) begin
      vc_trace.append_str( trace_str, "#" );
      vc_trace.append_chars( trace_str, " ", 4-1 );
    end else
      vc_trace.append_str( trace_str, { 4064'b0, rv2isa.disasm_tiny( ctrl.inst_X ) } );

    vc_trace.append_str( trace_str, "|" );

    if ( !ctrl.val_M )
      vc_trace.append_chars( trace_str, " ", 4 );
    else if ( ctrl.stall_M ) begin
      vc_trace.append_str( trace_str, "#" );
      vc_trace.append_chars( trace_str, " ", 4-1 );
    end else
      vc_trace.append_str( trace_str, { 4064'b0, rv2isa.disasm_tiny( ctrl.inst_M ) } );

    vc_trace.append_str( trace_str, "|" );

    if ( !ctrl.val_W )
      vc_trace.append_chars( trace_str, " ", 4 );
    else if ( ctrl.stall_W ) begin
      vc_trace.append_str( trace_str, "#" );
      vc_trace.append_chars( trace_str, " ", 4-1 );
    end else
      vc_trace.append_str( trace_str, { 4064'b0, rv2isa.disasm_tiny( ctrl.inst_W ) } );

  end
  `VC_TRACE_END

  vc_MemReqMsg4BTrace imemreq_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (imemreq_val),
    .rdy   (imemreq_rdy),
    .msg   (imemreq_msg)
  );

  vc_MemReqMsg4BTrace dmemreq_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (dmemreq_val),
    .rdy   (dmemreq_rdy),
    .msg   (dmemreq_msg)
  );

  vc_MemRespMsg4BTrace imemresp_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (imemresp_val),
    .rdy   (imemresp_rdy),
    .msg   (imemresp_msg)
  );

  vc_MemRespMsg4BTrace dmemresp_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (dmemresp_val),
    .rdy   (dmemresp_rdy),
    .msg   (dmemresp_msg)
  );

  `endif

endmodule

`endif /* PROC_PROC_V */

