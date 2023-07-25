#=========================================================================
# Xcel Control Unit
#=========================================================================
# Sends base addresses and sizes to each PE
#

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType
from pymtl3.stdlib.basic_rtl  import Reg, RegRst
from pymtl3.passes.backends.verilog import *

from .XcelMsg import *
from .PeConfigMsg import PeConfigMsgs
from .PeRowsMsgs import PeRowsMsgs
from .ReaderUnitMsgs import ReaderUnitMsgs
from .SpmvPeRTL import SpmvPeRTL 
from .AutonomousReaderRTL import ReaderUnitRTL

class SpmvXcelCtrlPRTL( Component ):
    def construct( s, num_pe = 4 ):
        s.set_metadata( VerilogTranslationPass.explicit_module_name, 'SpmvXcelCtrlRTL' )

        dtype = mk_bits(32)
        
        #---------------------------------------------------------------------
        # Interface
        #---------------------------------------------------------------------
        
        s.xcel = stream.ifcs.MinionIfcRTL( XcelReqMsg, XcelRespMsg )

        MemReqMsg, MemRespMsg  = mk_mem_msg( 8,32,32 )
        MEM_TYPE_READ          = b4(MemMsgType.READ)
        MEM_TYPE_WRITE         = b4(MemMsgType.WRITE)

        s.mem = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )

        s.pe = [ SpmvPeRTL() for _ in range(num_pe) ]
        s.write_ctrl_mem = [ stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg ) for _ in range(num_pe) ]
        s.vals_ctrl_mem  = [ stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg ) for _ in range(num_pe) ]
        s.vec_ctrl_mem   = [ stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg ) for _ in range(num_pe) ]
        s.cols_ctrl_mem  = [ stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg ) for _ in range(num_pe) ]

        for i in range(num_pe):
            s.pe[i].write_mem //= s.write_ctrl_mem[i]
            s.pe[i].vals_mem //= s.vals_ctrl_mem[i]
            s.pe[i].vec_mem //= s.vec_ctrl_mem[i]
            s.pe[i].cols_mem //= s.cols_ctrl_mem[i]

        s.row_reader = ReaderUnitRTL()
        s.row_reader.mem //= s.mem
        
        s.xcelreq_q = stream.PipeQueueRTL( XcelReqMsg, 1 )
        s.xcelreq_q.recv //= s.xcel.req

        # Rows Reader Queue input
        s.rowresp_q = stream.NormalQueueRTL( ReaderUnitMsgs.resp, 8 )
        s.rowresp_q.recv //= s.row_reader.send

        # Internal State
        s.base_addr         = RegRst( Bits32 )
        s.temp              = RegRst( Bits32 )
        s.num_rows          = RegRst( Bits32 )
        s.num_nnz           = RegRst( Bits32 )
        s.num_rows_pe       = RegRst( Bits32 )
        s.row_sent_ctr      = RegRst( Bits32 )
        s.pe_ctr            = RegRst( clog2(num_pe) if num_pe > 1 else 1 )
        s.num_pe_configured = RegRst( Bits8 )
        s.pe_done_ctr       = RegRst( Bits8 )
        s.pes_cfgd          = [RegRst( Bits1 ) for _ in range(num_pe)]
        s.pes_done          = [RegRst( Bits1 ) for _ in range(num_pe)]
        
        # Line tracing

        s.prev_state = 0
        s.xcfg_trace = "  "

        #=====================================================================
        # 4 state sim fixes
        #=====================================================================
        s.xcel_resp_msg_raw = Wire ( XcelRespMsg )

        s.xcel.resp.msg.type_  //= lambda: s.xcel_resp_msg_raw.type_  & s.xcel.resp.val
        s.xcel.resp.msg.data   //= lambda: s.xcel_resp_msg_raw.data   & (sext(s.xcel.resp.val, 32))
       
        s.pe_rows_req_msg_raw = [ Wire ( PeRowsMsgs.req ) for _ in range(num_pe) ]

        s.row_reader_recv_addr_raw         = Wire( 32 )
        s.row_reader.recv.msg.base_addr    //= lambda: s.row_reader_recv_addr_raw & (sext(s.row_reader.recv.val, 32))

        s.row_reader_recv_size_raw         = Wire( 32 )
        s.row_reader.recv.msg.size         //= lambda: s.row_reader_recv_size_raw & (sext(s.row_reader.recv.val, 32))

        #=====================================================================
        # State Update
        #=====================================================================

        s.STATE_XCFG    = b2(0)
        s.STATE_PE_CFG  = b2(1)
        s.STATE_SPMV    = b2(2)
        s.STATE_LAST    = b2(3)

        s.state = Wire(2)
        s.go    = Wire()

        @update_ff
        def block0():
        
            if s.reset:
                s.state <<= s.STATE_XCFG

            elif s.state == s.STATE_XCFG:
                if s.go:
                    s.state <<= s.STATE_PE_CFG
            
            elif s.state == s.STATE_PE_CFG:
                if s.num_pe_configured.out == num_pe:
                    s.state <<= s.STATE_SPMV

            elif s.state == s.STATE_SPMV:
                if s.row_sent_ctr.out == s.num_rows.out:
                    s.state <<= s.STATE_LAST
            
            elif s.state == s.STATE_LAST:
                if s.pe_done_ctr.out == num_pe:
                    s.state <<= s.STATE_XCFG
            
        #=====================================================================
        # State Outputs
        #=====================================================================

        @update
        def block1():

            s.xcelreq_q.send.rdy @= 0
            s.xcel.resp.val      @= 0
            s.go                 @= 0

            s.base_addr.in_         @= s.base_addr.out
            s.num_rows.in_          @= s.num_rows.out
            s.num_nnz.in_           @= s.num_nnz.out
            s.num_rows_pe.in_       @= s.num_rows_pe.out
            s.num_pe_configured.in_ @= s.num_pe_configured.out
            s.pe_ctr.in_            @= s.pe_ctr.out
            s.row_sent_ctr.in_      @= s.row_sent_ctr.out
            s.temp.in_              @= s.temp.out
            for i in range(num_pe):
                s.pes_cfgd[i].in_   @= s.pes_cfgd[i].out
                s.pes_done[i].in_   @= s.pes_done[i].out
            #-------------------------------------------------------------------
            # STATE: XCFG
            #-------------------------------------------------------------------

            if s.state == s.STATE_XCFG:
                s.row_sent_ctr.in_ @= 0
                s.pe_done_ctr.in_  @= 0
                s.row_reader.recv.val @= 0

                for i in range(num_pe):
                    s.pe[i].rows_recv.val @= 0
                    s.pe[i].config_recv.val @= 0

                    s.pe[i].config_send.rdy  @= 0

                    s.pe[i].rows_send.rdy   @= 0
                    s.pes_cfgd[i].in_   @= 0
                    s.pes_done[i].in_   @= 0

                s.xcelreq_q.send.rdy @= s.xcel.resp.rdy
                s.xcel.resp.val      @= s.xcelreq_q.send.val

                if s.xcelreq_q.send.val:

                    if s.xcelreq_q.send.msg.type_ == XCEL_TYPE_WRITE:

                        if   s.xcelreq_q.send.msg.addr == 0:
                            s.go              @= 1

                        elif s.xcelreq_q.send.msg.addr == 1:
                            s.base_addr.in_ @= s.xcelreq_q.send.msg.data

                        elif s.xcelreq_q.send.msg.addr == 2:
                            s.num_rows.in_ @= s.xcelreq_q.send.msg.data

                        elif s.xcelreq_q.send.msg.addr == 3:
                            s.num_nnz.in_ @= s.xcelreq_q.send.msg.data

                        elif s.xcelreq_q.send.msg.addr == 4:
                            s.num_rows_pe.in_ @= s.xcelreq_q.send.msg.data

                        # Send xcel response message

                        s.xcel_resp_msg_raw @= XcelRespMsg( XCEL_TYPE_WRITE, 0 )

                    else:

                        # Send xcel response message, obviously you only want to
                        # send the response message when accelerator is done

                        s.xcel_resp_msg_raw @= XcelRespMsg( XCEL_TYPE_READ, 1 )

            #-------------------------------------------------------------------
            # STATE: PE_CFG
            #-------------------------------------------------------------------

            elif s.state == s.STATE_PE_CFG:
                # send config messages to each PE and increment config counter when response is 1

                for i in range(num_pe):
                    s.pe[i].config_recv.val               @= 1
                    s.pe[i].config_send.rdy               @= 1
                    s.pe[i].config_recv.msg.base_addr     @= s.base_addr.out
                    s.pe[i].config_recv.msg.num_rows      @= s.num_rows.out
                    s.pe[i].config_recv.msg.num_nnz       @= s.num_nnz.out
                    s.pe[i].config_recv.msg.num_rows_pe   @= s.num_rows_pe.out

                    if s.pes_cfgd[i].out == 0:
                        if s.pe[i].config_send.msg & (s.num_pe_configured.out == i):
                            s.pes_cfgd[i].in_ @= 1
                            s.num_pe_configured.in_ @= s.num_pe_configured.out+1
                            
                # row reader

                s.row_reader_recv_addr_raw      @= s.base_addr.out
                s.row_reader_recv_size_raw      @= s.num_rows.out
                s.row_reader.recv.val           @= 1

            #-------------------------------------------------------------------
            # STATE: SPMV
            #-------------------------------------------------------------------

            elif s.state == s.STATE_SPMV:
                
                s.row_reader.recv.val @= 0
                s.rowresp_q.send.rdy  @= 1

                # take from rows queue 
                for i in range(num_pe):
                    s.pe[i].rows_recv.val @= 0
                    
                if s.rowresp_q.send.val & s.rowresp_q.send.rdy:
                    # temp = num_pe if num_pe < 8 else 8
                    s.pe[s.pe_ctr.out].rows_recv.val              @= 1
                    s.pe[s.pe_ctr.out].rows_recv.msg.row_end      @= s.rowresp_q.send.msg.data
                    s.temp.in_                                              @= s.rowresp_q.send.msg.data
                    s.pe[s.pe_ctr.out].rows_recv.msg.row_start    @= s.temp.out if s.row_sent_ctr.out > 0 else 0
                    s.pe[s.pe_ctr.out].rows_recv.msg.row_idx      @= s.row_sent_ctr.out
                
                #if s.rowresp_q.send.val & s.rowresp_q.send.rdy:
                    s.row_sent_ctr.in_                            @= s.row_sent_ctr.out + 1
                    s.pe_ctr.in_                                  @= s.pe_ctr.out + 1 if s.pe_ctr.out < num_pe - 1 else 0

            #-------------------------------------------------------------------
            # STATE: LAST
            #-------------------------------------------------------------------

            elif s.state == s.STATE_LAST:
                
                for i in range(num_pe):
                    s.pe[i].rows_send.rdy @= 1

                    if s.pes_done[i].out == 0:
                        if s.pe[i].rows_send.msg & (s.pe_done_ctr.out == i):
                            s.pes_done[i].in_ @= 1
                            s.pe_done_ctr.in_ @= s.pe_done_ctr.out + 1
        
    #   Line tracing

    def line_trace( s ):

        s.trace = ""

        state2char = {
        s.STATE_XCFG      : "X ",
        s.STATE_PE_CFG    : "PE",
        s.STATE_SPMV      : "S ",
        s.STATE_LAST      : "L "
        }

        s.state_str = state2char[s.state]

        s.trace = "({} {} base addr {}, num rows {}, num nnz {}, num rows pe {}, row start {}, row end {}, row idx {})".format(
        s.state_str,
        s.mem.req.msg,
        int(s.pe[0].config_recv.msg.base_addr),
        int(s.pe[0].config_recv.msg.num_rows),
        int(s.pe[0].config_recv.msg.num_nnz),
        int(s.pe[0].config_recv.msg.num_rows_pe),
        int(s.pe[0].rows_recv.msg.row_start),
        int(s.pe[0].rows_recv.msg.row_end),
        int(s.pe[0].rows_recv.msg.row_idx),
        )

        return s.trace
