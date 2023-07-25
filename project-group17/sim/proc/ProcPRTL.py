#=========================================================================
# ProcPRTL.py
#=========================================================================
# ProcAlt + xcelreq/resp + custom0

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.mem import mk_mem_msg
from pymtl3.stdlib.queues import BypassQueueRTL
from pymtl3.passes.backends.verilog import *
from .tinyrv2_encoding    import disassemble_inst
from .TinyRV2InstPRTL     import inst_dict

from .ProcDpathPRTL    import ProcDpathPRTL
from .ProcCtrlPRTL     import ProcCtrlPRTL
from .DropUnitPRTL     import DropUnitPRTL

from .XcelMsg import XcelReqMsg, XcelRespMsg

class ProcPRTL( Component ):

  def construct( s, num_cores=1 ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'ProcRTL_{num_cores}cores' )

    MemReqMsg, MemRespMsg = mk_mem_msg( 8, 32, 32 )

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    # Starting F16 we turn core_id into input ports to
    # enable module reusability. In the past it was passed as arguments.

    s.core_id   = InPort(32)

    # Proc/Mngr Interface

    s.mngr2proc = stream.ifcs.RecvIfcRTL( Bits32 )
    s.proc2mngr = stream.ifcs.SendIfcRTL( Bits32 )

    # Instruction Memory Request/Response Interface

    s.imem = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )

    # Data Memory Request/Response Interface

    s.dmem = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )

    # Accelerator Request/Response Interface

    s.xcel = stream.ifcs.MasterIfcRTL( XcelReqMsg, XcelRespMsg )

    # val_W port used for counting commited insts.

    s.commit_inst = OutPort()

    # stats_en

    s.stats_en    = OutPort()

    #=====================================================================
    # 4 state sim fixes
    #=====================================================================

    s.imem.req.msg.type_  //= lambda: s.imemreq_q.send.msg.type_  & (sext(s.imem.req.val, 4))
    s.imem.req.msg.opaque //= lambda: s.imemreq_q.send.msg.opaque & (sext(s.imem.req.val, 8))
    s.imem.req.msg.addr   //= lambda: s.imemreq_q.send.msg.addr   & (sext(s.imem.req.val, 32))
    s.imem.req.msg.len    //= lambda: s.imemreq_q.send.msg.len    & (sext(s.imem.req.val, 2))
    s.imem.req.msg.data   //= lambda: s.imemreq_q.send.msg.data   & (sext(s.imem.req.val, 32))

    s.dmem.req.msg.type_  //= lambda: s.dmemreq_q.send.msg.type_  & (sext(s.dmem.req.val, 4))
    s.dmem.req.msg.opaque //= lambda: s.dmemreq_q.send.msg.opaque & (sext(s.dmem.req.val, 8))
    s.dmem.req.msg.addr   //= lambda: s.dmemreq_q.send.msg.addr   & (sext(s.dmem.req.val, 32))
    s.dmem.req.msg.len    //= lambda: s.dmemreq_q.send.msg.len    & (sext(s.dmem.req.val, 2))
    s.dmem.req.msg.data   //= lambda: s.dmemreq_q.send.msg.data   & (sext(s.dmem.req.val, 32))

    s.xcel.req.msg.type_  //= lambda: s.xcelreq_q.send.msg.type_  & s.xcel.req.val
    s.xcel.req.msg.addr   //= lambda: s.xcelreq_q.send.msg.addr   & (sext(s.xcel.req.val, 5 ))
    s.xcel.req.msg.data   //= lambda: s.xcelreq_q.send.msg.data   & (sext(s.xcel.req.val, 32))

    s.proc2mngr.msg       //= lambda: s.proc2mngr_q.send.msg      & (sext(s.proc2mngr.val, 32))

    #---------------------------------------------------------------------
    # Structural composition
    #---------------------------------------------------------------------

    # Bypass queues

    s.imemreq_q   = stream.BypassQueueRTL( MemReqMsg, 2 )
    s.dmemreq_q   = stream.BypassQueueRTL( MemReqMsg, 1 )
    s.proc2mngr_q = stream.BypassQueueRTL( Bits32, 1 )
    s.xcelreq_q   = stream.BypassQueueRTL( XcelReqMsg, 1 )

    s.imemreq_q.send.val   //= s.imem.req.val    
    s.imemreq_q.send.rdy   //= s.imem.req.rdy
    s.dmemreq_q.send.val   //= s.dmem.req.val    
    s.dmemreq_q.send.rdy   //= s.dmem.req.rdy
    s.proc2mngr_q.send.val //= s.proc2mngr.val     
    s.proc2mngr_q.send.rdy //= s.proc2mngr.rdy
    s.xcelreq_q.send.val   //= s.xcel.req.val     
    s.xcelreq_q.send.rdy   //= s.xcel.req.rdy

    # imem drop unit

    s.imemresp_drop_unit = DropUnitPRTL( MemRespMsg )
    s.imemresp_drop_unit.in_ //= s.imem.resp

    # control logic

    s.ctrl  = ProcCtrlPRTL()

    # imem port
    s.ctrl.imemresp_drop //= s.imemresp_drop_unit.drop
    s.ctrl.imemreq_val   //= s.imemreq_q.recv.val
    s.ctrl.imemreq_rdy   //= s.imemreq_q.recv.rdy
    s.ctrl.imemresp_val  //= s.imemresp_drop_unit.out.val
    s.ctrl.imemresp_rdy  //= s.imemresp_drop_unit.out.rdy

    # dmem port
    s.ctrl.dmemreq_val   //= s.dmemreq_q.recv.val
    s.ctrl.dmemreq_rdy   //= s.dmemreq_q.recv.rdy
    s.ctrl.dmemresp_val  //= s.dmem.resp.val
    s.ctrl.dmemresp_rdy  //= s.dmem.resp.rdy

    # xcel port
    s.ctrl.xcelreq_val   //= s.xcelreq_q.recv.val
    s.ctrl.xcelreq_rdy   //= s.xcelreq_q.recv.rdy
    s.ctrl.xcelresp_val  //= s.xcel.resp.val
    s.ctrl.xcelresp_rdy  //= s.xcel.resp.rdy

    # proc2mngr and mngr2proc
    s.ctrl.proc2mngr_val //= s.proc2mngr_q.recv.val
    s.ctrl.proc2mngr_rdy //= s.proc2mngr_q.recv.rdy
    s.ctrl.mngr2proc_val //= s.mngr2proc.val
    s.ctrl.mngr2proc_rdy //= s.mngr2proc.rdy

    # commit inst for counting
    s.ctrl.commit_inst //= s.commit_inst

    # data path

    s.dpath = ProcDpathPRTL( num_cores )
    s.dpath.core_id  //= s.core_id
    s.dpath.stats_en //= s.stats_en

    # imem ports
    s.dpath.imemreq_msg  //= s.imemreq_q.recv.msg
    s.dpath.imemresp_msg //= s.imemresp_drop_unit.out.msg

    # dmem ports
    s.dpath.dmemresp_msg //= s.dmem.resp.msg

    # xcel ports
    s.dpath.xcelresp_msg //= s.xcel.resp.msg

    # mngr
    s.dpath.mngr2proc_data //= s.mngr2proc.msg
    s.dpath.proc2mngr_data //= s.proc2mngr_q.recv.msg

    # Connect parameters

    s.xcelreq_data = Wire(32)
    s.xcelreq_data //= lambda: 0 if s.ctrl.xcelreq_type == 0 else s.dpath.xcelreq_data # jtb237, 4-state fix

    # s.xcelreq_q.recv.msg //= lambda: XcelReqMsg( s.ctrl.xcelreq_type, s.dpath.xcelreq_addr, s.dpath.xcelreq_data )
    s.xcelreq_q.recv.msg //= lambda: XcelReqMsg( s.ctrl.xcelreq_type, s.dpath.xcelreq_addr, s.xcelreq_data )

    s.dmemreq_q.recv.msg //= lambda: MemReqMsg( s.ctrl.dmemreq_type, 0, s.dpath.dmemreq_addr, 0, s.dpath.dmemreq_data )

    # Ctrl <-> Dpath

    s.ctrl.reg_en_F        //= s.dpath.reg_en_F
    s.ctrl.pc_sel_F        //= s.dpath.pc_sel_F

    s.ctrl.reg_en_D        //= s.dpath.reg_en_D
    s.ctrl.csrr_sel_D      //= s.dpath.csrr_sel_D
    s.ctrl.op1_byp_sel_D   //= s.dpath.op1_byp_sel_D
    s.ctrl.op2_byp_sel_D   //= s.dpath.op2_byp_sel_D
    s.ctrl.op1_sel_D       //= s.dpath.op1_sel_D
    s.ctrl.op2_sel_D       //= s.dpath.op2_sel_D
    s.ctrl.imm_type_D      //= s.dpath.imm_type_D
    s.ctrl.imul_req_val_D  //= s.dpath.imul_req_val_D
    s.ctrl.imul_req_rdy_D  //= s.dpath.imul_req_rdy_D

    s.ctrl.reg_en_X        //= s.dpath.reg_en_X
    s.ctrl.alu_fn_X        //= s.dpath.alu_fn_X
    s.ctrl.ex_result_sel_X //= s.dpath.ex_result_sel_X
    s.ctrl.imul_resp_val_X //= s.dpath.imul_resp_val_X
    s.ctrl.imul_resp_rdy_X //= s.dpath.imul_resp_rdy_X

    s.ctrl.reg_en_M        //= s.dpath.reg_en_M
    s.ctrl.wb_result_sel_M //= s.dpath.wb_result_sel_M

    s.ctrl.reg_en_W        //= s.dpath.reg_en_W
    s.ctrl.rf_waddr_W      //= s.dpath.rf_waddr_W
    s.ctrl.rf_wen_W        //= s.dpath.rf_wen_W
    s.ctrl.stats_en_wen_W  //= s.dpath.stats_en_wen_W

    s.dpath.inst_D         //= s.ctrl.inst_D
    s.dpath.br_cond_eq_X   //= s.ctrl.br_cond_eq_X
    s.dpath.br_cond_lt_X   //= s.ctrl.br_cond_lt_X
    s.dpath.br_cond_ltu_X  //= s.ctrl.br_cond_ltu_X

  #-----------------------------------------------------------------------
  # Line tracing
  #-----------------------------------------------------------------------

  def line_trace( s ):
    # F stage
    if not s.ctrl.val_F:  F_str = "{:<8s}".format( ' ' )
    elif s.ctrl.squash_F: F_str = "{:<8s}".format( '~' )
    elif s.ctrl.stall_F:  F_str = "{:<8s}".format( '#' )
    else:                 F_str = "{:08x}".format( s.dpath.pc_reg_F.out.uint() )

    # D stage
    if not s.ctrl.val_D:  D_str = "{:<23s}".format( ' ' )
    elif s.ctrl.squash_D: D_str = "{:<23s}".format( '~' )
    elif s.ctrl.stall_D:  D_str = "{:<23s}".format( '#' )
    else:                 D_str = "{:<23s}".format( disassemble_inst(s.ctrl.inst_D) )

    # X stage
    if not s.ctrl.val_X:  X_str = "{:<5s}".format( ' ' )
    elif s.ctrl.stall_X:  X_str = "{:<5s}".format( '#' )
    else:                 X_str = "{:<5s}".format( inst_dict[s.ctrl.inst_type_X] )

    # M stage
    if not s.ctrl.val_M:  M_str = "{:<5s}".format( ' ' )
    elif s.ctrl.stall_M:  M_str = "{:<5s}".format( '#' )
    else:                 M_str = "{:<5s}".format( inst_dict[s.ctrl.inst_type_M] )

    # W stage
    if not s.ctrl.val_W:  W_str = "{:<5s}".format( ' ' )
    elif s.ctrl.stall_W:  W_str = "{:<5s}".format( '#' )
    else:                 W_str = "{:<5s}".format( inst_dict[s.ctrl.inst_type_W] )

    return "{}|{}|{}|{}|{}".format( F_str, D_str, X_str, M_str, W_str)
