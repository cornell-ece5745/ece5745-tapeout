#=========================================================================
# ProcDpathPRTL.py
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.basic_rtl import RegisterFile, Mux, RegEnRst, RegEn, Adder, Incrementer
from pymtl3.stdlib.mem import mk_mem_msg

from .ProcDpathComponentsPRTL import AluPRTL, ImmGenPRTL
from .TinyRV2InstPRTL         import OPCODE, RS1, RS2, XS1, XS2, RD, SHAMT

from .XcelMsg import XcelReqMsg, XcelRespMsg
from lab1_imul.IntMulScycleRTL import IntMulScycleRTL
from lab1_imul.IntMulMsgs import IntMulMsgs

#-------------------------------------------------------------------------
# Constants
#-------------------------------------------------------------------------

c_reset_vector = 0x200
c_reset_inst   = 0

#-------------------------------------------------------------------------
# ProcDpathPRTL
#-------------------------------------------------------------------------

class ProcDpathPRTL( Component ):

  def construct( s, num_cores = 1 ):

    dtype = mk_bits(32)
    MemReqType, MemRespType = mk_mem_msg(8,32,32)

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    # Parameters

    s.core_id = InPort( dtype )

    # imem ports

    s.imemreq_msg  = OutPort( MemReqType )
    s.imemresp_msg = InPort ( MemRespType )

    # dmem ports

    s.dmemreq_data = OutPort( dtype )
    s.dmemreq_addr = OutPort( dtype )
    s.dmemresp_msg = InPort ( MemRespType )

    # mngr ports

    s.mngr2proc_data    = InPort ( dtype )
    s.proc2mngr_data    = OutPort( dtype )

    # xcel ports

    s.xcelreq_addr = OutPort(5)
    s.xcelreq_data = OutPort( dtype )
    s.xcelresp_msg = InPort ( XcelRespMsg )

    # Control signals (ctrl->dpath)

    s.reg_en_F          = InPort()
    s.pc_sel_F          = InPort(2)

    s.reg_en_D          = InPort()
    s.op1_byp_sel_D     = InPort(2)
    s.op2_byp_sel_D     = InPort(2)
    s.op1_sel_D         = InPort()
    s.op2_sel_D         = InPort(2)
    s.csrr_sel_D        = InPort(2)
    s.imm_type_D        = InPort(3)
    s.imul_req_val_D    = InPort()
    s.imul_req_rdy_D    = OutPort()

    s.reg_en_X          = InPort()
    s.alu_fn_X          = InPort(4)
    s.ex_result_sel_X   = InPort(2)
    s.imul_resp_val_X   = OutPort()
    s.imul_resp_rdy_X   = InPort()

    s.reg_en_M          = InPort()
    s.wb_result_sel_M   = InPort(2)

    s.reg_en_W          = InPort()
    s.rf_waddr_W        = InPort(5)
    s.rf_wen_W          = InPort()
    s.stats_en_wen_W    = InPort()

    # Status signals (dpath->Ctrl)

    s.inst_D            = OutPort( dtype )
    s.br_cond_eq_X      = OutPort()
    s.br_cond_lt_X      = OutPort()
    s.br_cond_ltu_X     = OutPort()

    # stats_en output

    s.stats_en          = OutPort()

    #---------------------------------------------------------------------
    # F stage
    #---------------------------------------------------------------------

    s.pc_F        = Wire( dtype )
    s.pc_plus4_F  = Wire( dtype )

    # PC+4 incrementer

    s.pc_incr_F = m = Incrementer( dtype, amount=4 )
    m.in_ //= s.pc_F
    m.out //= s.pc_plus4_F

    # forward delaration for branch target and jal target

    s.br_target_X  = Wire( dtype )
    s.jal_target_D = Wire( dtype )
    s.jalr_target_X = Wire( dtype )

    # PC sel mux

    s.pc_sel_mux_F = m = Mux( dtype, ninputs=4 )
    m.in_[0] //= s.pc_plus4_F
    m.in_[1] //= s.br_target_X
    m.in_[2] //= s.jal_target_D
    m.in_[3] //= s.jalr_target_X
    m.sel //= s.pc_sel_F

    s.imemreq_msg //= lambda: MemReqType( 0, 0, s.pc_sel_mux_F.out, 0, 0 )

    # PC register

    s.pc_reg_F = m = RegEnRst( dtype, reset_value=c_reset_vector-4 )
    m.en  //= s.reg_en_F
    m.in_ //= s.pc_sel_mux_F.out
    m.out //= s.pc_F

    #---------------------------------------------------------------------
    # D stage
    #---------------------------------------------------------------------

    # PC reg in D stage
    # This value is basically passed from F stage for the corresponding
    # instruction to use, e.g. branch to (PC+imm)

    s.pc_reg_D = m = RegEnRst( dtype )
    m.en  //= s.reg_en_D
    m.in_ //= s.pc_F

    # Instruction reg

    s.inst_D_reg = m = RegEnRst( dtype, reset_value=c_reset_inst )
    m.en  //= s.reg_en_D
    m.in_ //= s.imemresp_msg.data
    m.out //= s.inst_D                  # to ctrl

    # Register File
    # The rf_rdata_D wires, albeit redundant in some sense, are used to
    # remind people these data are from D stage.

    s.rf_rdata0_D = Wire( dtype )
    s.rf_rdata1_D = Wire( dtype )

    s.rf_wdata_W  = Wire( dtype )

    s.rf = m = RegisterFile( dtype, nregs=32, rd_ports=2, wr_ports=1, const_zero=True )
    m.raddr[0] //= s.inst_D[ RS1 ]
    m.raddr[1] //= s.inst_D[ RS2 ]
    # m.rdata[0] //= s.rf_rdata0_D
    # m.rdata[1] //= s.rf_rdata1_D
    s.rf_rdata0_D //= lambda: 0 if (s.rf.raddr[0]==0) else s.rf.rdata[0] # djl357- we always want x0 to equal 0, so we hardwire it
    s.rf_rdata1_D //= lambda: 0 if (s.rf.raddr[1]==0) else s.rf.rdata[1]
    m.wen[0]   //= s.rf_wen_W
    m.waddr[0] //= s.rf_waddr_W
    m.wdata[0] //= s.rf_wdata_W

    # Immediate generator

    s.imm_gen_D = m = ImmGenPRTL()
    m.imm_type //= s.imm_type_D
    m.inst     //= s.inst_D

    s.byp_data_X = Wire( dtype )
    s.byp_data_M = Wire( dtype )
    s.byp_data_W = Wire( dtype )

    # op1 bypass mux

    s.op1_byp_mux_D = m = Mux( dtype, ninputs=4 )
    m.in_[0] //= s.rf_rdata0_D
    m.in_[1] //= s.byp_data_X
    m.in_[2] //= s.byp_data_M
    m.in_[3] //= s.byp_data_W
    m.sel //= s.op1_byp_sel_D

    # op2 bypass mux

    s.op2_byp_mux_D = m = Mux( dtype, ninputs=4 )
    m.in_[0] //= s.rf_rdata1_D
    m.in_[1] //= s.byp_data_X
    m.in_[2] //= s.byp_data_M
    m.in_[3] //= s.byp_data_W
    m.sel //= s.op2_byp_sel_D

    # op1 sel mux

    s.op1_sel_mux_D = m = Mux( dtype, ninputs=2 )
    m.in_[0] //= s.op1_byp_mux_D.out
    m.in_[1] //= s.pc_reg_D.out
    m.sel //= s.op1_sel_D

    # csrr sel mux

    s.csrr_sel_mux_D = m = Mux( dtype, ninputs=3 )
    m.in_[0] //= s.mngr2proc_data
    m.in_[1] //= num_cores
    m.in_[2] //= s.core_id
    m.sel //= s.csrr_sel_D

    # op2 sel mux
    # This mux chooses among RS2, imm, and the output of the above csrr
    # sel mux. Basically we are using two muxes here for pedagogy.

    s.op2_sel_mux_D = m = Mux( dtype, ninputs=3 )
    m.in_[0] //= s.op2_byp_mux_D.out
    m.in_[1] //= s.imm_gen_D.imm
    m.in_[2] //= s.csrr_sel_mux_D.out
    m.sel //= s.op2_sel_D

    # Risc-V always calcs branch/jal target by adding imm(generated above) to PC

    s.pc_plus_imm_D = m = Adder( dtype )
    m.in0 //= s.pc_reg_D.out
    m.in1 //= s.imm_gen_D.imm
    m.out //= s.jal_target_D

    #---------------------------------------------------------------------
    # X stage
    #---------------------------------------------------------------------

    # imul
    # Since on the datapath diagram it's slightly left to those registers,
    # I put it at the beginning of the X stage :)

    s.imul = IntMulScycleRTL()

    s.imul.recv.val   //= s.imul_req_val_D
    s.imul.recv.rdy   //= s.imul_req_rdy_D
    s.imul.recv.msg.a //= s.op1_sel_mux_D.out
    s.imul.recv.msg.b //= s.op2_sel_mux_D.out

    s.imulresp_q = stream.BypassQueueRTL( IntMulMsgs.resp, 1 )
    s.imulresp_q.recv //= s.imul.send

    s.imulresp_q.send.val //= s.imul_resp_val_X
    s.imulresp_q.send.rdy //= s.imul_resp_rdy_X

    # br_target_reg_X
    # Since branches are resolved in X stage, we register the target,
    # which is already calculated in D stage, to X stage.

    s.br_target_reg_X = m = RegEnRst( dtype, reset_value=0 )
    m.en  //= s.reg_en_X
    m.in_ //= s.pc_plus_imm_D.out
    m.out //= s.br_target_X

    # PC reg in X stage

    s.pc_reg_X = m = RegEnRst( dtype, reset_value=0 )
    m.en  //= s.reg_en_X
    m.in_ //= s.pc_reg_D.out

    # op1 reg

    s.op1_reg_X = m = RegEnRst( dtype, reset_value=0 )
    m.en  //= s.reg_en_X
    m.in_ //= s.op1_sel_mux_D.out

    # op2 reg

    s.op2_reg_X = m = RegEnRst( dtype, reset_value=0 )
    m.en  //= s.reg_en_X
    m.in_ //= s.op2_sel_mux_D.out

    s.xcelreq_addr //= s.op2_reg_X.out[0:5]
    s.xcelreq_data //= s.op1_reg_X.out

    # dmemreq write data reg
    # Since the op1 is the base address and op2 is the immediate so that
    # we could utilize ALU to do address calculation, we need one more
    # register to hold the R[rs2] we want to store to memory.

    s.dmem_write_data_reg_X = m = RegEnRst( dtype, reset_value=0 )
    m.en  //= s.reg_en_X
    m.in_ //= s.op2_byp_mux_D.out # R[rs2]
    m.out //= s.dmemreq_data

    # ALU

    s.alu_X = m = AluPRTL()
    m.in0     //= s.op1_reg_X.out
    m.in1     //= s.op2_reg_X.out
    m.fn      //= s.alu_fn_X
    m.ops_eq  //= s.br_cond_eq_X
    m.ops_lt  //= s.br_cond_lt_X
    m.ops_ltu //= s.br_cond_ltu_X
    m.out     //= s.jalr_target_X

    # PC+4 generator

    s.pc_incr_X = m = Incrementer( dtype, amount=4 )
    m.in_ //= s.pc_reg_X.out

    # X result sel mux

    s.ex_result_sel_mux_X = m = Mux( dtype, ninputs=3 )
    m.in_[0] //= s.alu_X.out
    m.in_[1] //= s.imulresp_q.send.msg
    m.in_[2] //= s.pc_incr_X.out
    m.sel //= s.ex_result_sel_X
    m.out //= s.byp_data_X
    m.out //= s.dmemreq_addr

    #---------------------------------------------------------------------
    # M stage
    #---------------------------------------------------------------------

    # Alu execution result reg

    s.ex_result_reg_M = m = RegEnRst( dtype, reset_value=0 )
    m.en  //= s.reg_en_M
    m.in_ //= s.ex_result_sel_mux_X.out

    # Writeback result selection mux

    s.wb_result_sel_mux_M = m = Mux( dtype, ninputs=3 )
    m.in_[0] //= s.ex_result_reg_M.out
    m.in_[1] //= s.dmemresp_msg.data
    m.in_[2] //= s.xcelresp_msg.data
    m.sel //= s.wb_result_sel_M
    m.out //= s.byp_data_M

    #---------------------------------------------------------------------
    # W stage
    #---------------------------------------------------------------------

    # Writeback result reg

    s.wb_result_reg_W = m = RegEnRst( dtype, reset_value=0 )
    m.en  //= s.reg_en_W
    m.in_ //= s.wb_result_sel_mux_M.out
    m.out //= s.byp_data_W
    m.out //= s.rf_wdata_W
    m.out //= s.proc2mngr_data

    # stats_en

    s.stats_en_reg_W = m = RegEnRst( dtype, reset_value=0 )
    m.en  //= s.stats_en_wen_W
    m.in_ //= s.wb_result_reg_W.out
    s.stats_en //= s.stats_en_reg_W.out[0]
