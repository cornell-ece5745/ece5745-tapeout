#=========================================================================
# Processing Element
#=========================================================================
# Performs SpMV multiplication on sparse matrix in CSR format and dense vector
# Receives two messages from CTRL unit:
# Config:
# Base address of all data in memory
# Number of rows in the whole matrix
# Number of nonzero values in the whole matrix
# Number of rows per PE

from pymtl3      import *

from pymtl3.stdlib import stream
from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType
from pymtl3.stdlib.queues import PipeQueueRTL, NormalQueueRTL
from pymtl3.stdlib.basic_rtl  import Reg, RegRst
from pymtl3.passes.backends.verilog import *

from .PeConfigMsg import * 
from .ReaderUnitMsgs import *
from .PeRowsMsgs import *
from .AutonomousReaderRTL import ReaderUnitRTL


class SpmvPePRTL( Component ):
  # Constructor
  def construct( s ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'SpmvPeRTL' )
    
    MemReqMsg, MemRespMsg  = mk_mem_msg( 8,32,32 )
    MEM_TYPE_READ          = b4(MemMsgType.READ)
    MEM_TYPE_WRITE         = b4(MemMsgType.WRITE)

    # Exposing memory ports
    s.write_mem            = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )
    s.vals_mem             = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )
    s.vec_mem              = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )
    s.cols_mem             = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )

    # Queues Buffer input
    s.memresp_q            = stream.NormalQueueRTL( MemRespMsg, 16 ) # To accommodate for 32x32 matrix
    s.memresp_q.recv       //= s.write_mem.resp

    # Instantiate reader units and connect memory ports
    s.cols                 = ReaderUnitRTL()
    s.cols.mem             //= s.cols_mem
    s.vals                 = ReaderUnitRTL()
    s.vals.mem             //= s.vals_mem
    s.vec                  = ReaderUnitRTL() # without reg file
    s.vec.mem              //= s.vec_mem

    # PE config msgs (sent once to configure this PE)
    s.config_recv          = stream.ifcs.RecvIfcRTL( PeConfigMsgs.req ) # PE receives
    s.config_send          = stream.ifcs.SendIfcRTL( PeConfigMsgs.resp ) # PE sends

    # PE rows msgs (sent for each row this PE is responsible for)
    s.rows_recv            = stream.ifcs.RecvIfcRTL( PeRowsMsgs.req ) # PE receives
    s.rows_send            = stream.ifcs.SendIfcRTL( PeRowsMsgs.resp ) # PE sends

    # Queue for config msgs
    s.config_recv_q        = stream.NormalQueueRTL( PeConfigMsgs.req, 2)
    s.config_recv_q.recv   //= s.config_recv

    # Queue for rows msgs
    s.rows_recv_q          = stream.NormalQueueRTL( PeRowsMsgs.req, 128 ) 
    s.rows_recv_q.recv     //= s.rows_recv

    # Queue for cols
    # Reader sends
    s.cols_send_q          = stream.NormalQueueRTL( ReaderUnitMsgs.resp, 8 ) # queue with 8 entries
    s.cols_send_q.recv     //= s.cols.send

    # Queue for vals
    # Reader sends
    s.vals_send_q          = stream.NormalQueueRTL( ReaderUnitMsgs.resp, 8 ) # queue with 8 entries
    s.vals_send_q.recv     //= s.vals.send

    # Queue for vec
    # Reader sends
    s.vec_send_q           = stream.NormalQueueRTL( ReaderUnitMsgs.resp, 8 ) # queue with 8 entries
    s.vec_send_q.recv      //= s.vec.send

    # Internal state
    s.base_src             = RegRst( Bits32 )
    s.num_rows             = RegRst( Bits32 )
    s.num_nnz              = RegRst( Bits32 )

    # base addresses
    s.cols_addr            = RegRst( Bits32 )
    s.vals_addr            = RegRst( Bits32 )
    s.vec_addr             = RegRst( Bits32 )
    s.dest_addr            = RegRst( Bits32 )

    s.col_idx              = RegRst( Bits32 ) # number of nonzero values this PE has processed
    s.row_idx              = RegRst( Bits32 ) # number of rows this PE has processed

    s.row_end              = RegRst( Bits32 ) # number of nonzero values up to current row
    s.val_val              = RegRst( Bits32 ) # nonzero value of the current matrix element
    s.sum                  = RegRst( Bits32 ) # sum of products of current row

    s.write_ctr            = RegRst( Bits32 ) # number of rows this PE has left
    s.mem_sent             = RegRst( Bits1 )  # set when write memory request is sent
    s.flag                 = RegRst( Bits1 )  # set when write is done and cleared when next row is dequeued
    s.done                 = RegRst( Bits1 )  # set when this PE is done with all rows

    #=====================================================================
    # 4 state sim fixes
    #=====================================================================
    s.config_send_msg_raw        = Wire ( 1 )
    s.config_send.msg            //= lambda: s.config_send_msg_raw & s.config_send.val

    s.rows_send_msg_raw          = Wire ( 1 )
    s.rows_send.msg              //= lambda: s.rows_send_msg_raw & s.rows_send.val

    s.cols_recv_addr_raw         = Wire( 32 )
    s.cols.recv.msg.base_addr    //= lambda: s.cols_recv_addr_raw & (sext(s.cols.recv.val, 32))

    s.cols_recv_size_raw         = Wire( 32 )
    s.cols.recv.msg.size         //= lambda: s.cols_recv_size_raw & (sext(s.cols.recv.val, 32))

    s.vals_recv_addr_raw         = Wire( 32 )
    s.vals.recv.msg.base_addr    //= lambda: s.vals_recv_addr_raw & (sext(s.vals.recv.val, 32))

    s.vals_recv_size_raw         = Wire( 32 )
    s.vals.recv.msg.size         //= lambda: s.vals_recv_size_raw & (sext(s.vals.recv.val, 32))

    s.vec_recv_addr_raw          = Wire( 32 )
    s.vec.recv.msg.base_addr     //= lambda: s.vec_recv_addr_raw & (sext(s.vec.recv.val, 32))

    s.vec_recv_size_raw          = Wire( 32 )
    s.vec.recv.msg.size          //= lambda: s.vec_recv_size_raw & (sext(s.vec.recv.val, 32))

    s.write_mem_msg_raw          = Wire( 78 )
    s.write_mem.req.msg          //= lambda: s.write_mem_msg_raw & (sext(s.write_mem.req.val, 78))

    #=====================================================================
    # State Update
    #=====================================================================
    s.STATE_XCFG    = b1(0)
    s.STATE_SPMV    = b1(1)

    s.state         = Wire()

    @update_ff
    def block0():
        if s.reset:
          s.state <<= s.STATE_XCFG
        else:
          s.state <<= s.state
          if s.state == s.STATE_XCFG:
            if s.config_recv_q.send.val:
              s.state <<= s.STATE_SPMV
          elif s.state == s.STATE_SPMV:
            if s.done.out:
                s.state <<= s.STATE_XCFG

    #=====================================================================
    # State Outputs
    #=====================================================================
    @update
    def block1():        
        s.config_recv_q.send.rdy   @= 0
        s.config_send.val          @= 0
        s.config_send_msg_raw      @= b1(0)

        s.rows_recv_q.send.rdy     @= 0
        s.rows_send.val            @= 0
        s.rows_send_msg_raw        @= b1(0)

        s.cols.recv.val            @= 0
        s.cols_recv_addr_raw       @= b32(0)
        s.cols_recv_size_raw       @= b32(0)

        s.vals.recv.val            @= 0
        s.vals_recv_addr_raw       @= b32(0)
        s.vals_recv_size_raw       @= b32(0)

        s.vec.recv.val             @= 0
        s.vec_recv_addr_raw        @= b32(0)
        s.vec_recv_size_raw        @= b32(0)

        s.write_mem.req.val        @= 0
        s.write_mem_msg_raw        @= 0

        s.base_src.in_             @= s.base_src.out
        s.num_rows.in_             @= s.num_rows.out
        s.num_nnz.in_              @= s.num_nnz.out

        s.cols_addr.in_            @= s.cols_addr.out
        s.vals_addr.in_            @= s.vals_addr.out
        s.vec_addr.in_             @= s.vec_addr.out
        s.dest_addr.in_            @= s.dest_addr.out

        s.col_idx.in_              @= s.col_idx.out
        s.row_idx.in_              @= s.row_idx.out

        s.row_end.in_              @= s.row_end.out
        s.val_val.in_              @= s.val_val.out
        s.sum.in_                  @= s.sum.out

        s.write_ctr.in_            @= s.write_ctr.out
        s.mem_sent.in_             @= s.mem_sent.out
        s.flag.in_                 @= s.flag.out
        s.done.in_                 @= 0
        
        #-------------------------------------------------------------------
        # STATE: XCFG
        #-------------------------------------------------------------------
        # In this state we handle the accelerator configuration protocol,
        # where we write the base addresses, sizes, and then tell the
        # accelerator to start. We also handle responding when the
        # accelerator is done.
        if s.state == s.STATE_XCFG:
          s.config_send.val           @= s.config_recv_q.send.val
          if s.config_recv_q.send.val:
            s.config_recv_q.send.rdy  @= b1(0)
            # save config values
            s.base_src.in_            @= s.config_recv_q.send.msg.base_addr
            s.num_rows.in_            @= s.config_recv_q.send.msg.num_rows
            s.num_nnz.in_             @= s.config_recv_q.send.msg.num_nnz
            s.write_ctr.in_           @= s.config_recv_q.send.msg.num_rows_pe
            # compute base addresses
            s.cols_addr.in_           @= s.config_recv_q.send.msg.base_addr + (s.config_recv_q.send.msg.num_rows) * 4
            s.vals_addr.in_           @= s.config_recv_q.send.msg.base_addr + (s.config_recv_q.send.msg.num_rows + s.config_recv_q.send.msg.num_nnz) * 4
            s.vec_addr.in_            @= s.config_recv_q.send.msg.base_addr + (s.config_recv_q.send.msg.num_rows + s.config_recv_q.send.msg.num_nnz * 2) * 4
            s.dest_addr.in_           @= s.config_recv_q.send.msg.base_addr + (s.config_recv_q.send.msg.num_rows + s.config_recv_q.send.msg.num_nnz) * 8
           
            s.config_send_msg_raw     @= b1(1)
            s.config_send.val         @= 1

            s.col_idx.in_             @= 0
            s.row_end.in_             @= 0
            s.mem_sent.in_            @= 0
            s.flag.in_                @= 1
          else:
            s.config_recv_q.send.rdy  @= b1(1)
            s.config_send_msg_raw     @= b1(0)

        #-------------------------------------------------------------------
        # STATE: SPMV
        #-------------------------------------------------------------------
        # This is the latency insensitive version of SpMV accelerator.
        # Matrix and Vector values are read from memory, multiplied, and the
        # result value is written back to memory.
        # Read requests are sent each cycle as long as there are values to be
        # read and read response queues aren't full.
        # Read response values are read from response queues when next values
        # are needed by other modules

        elif s.state == s.STATE_SPMV:
          if (s.flag.out & s.cols.recv.rdy & s.vals.recv.rdy):
            if ((s.rows_recv_q.send.msg.row_end - s.rows_recv_q.send.msg.row_start) == 0):
              s.write_ctr.in_           @= s.write_ctr.out - 1 if (s.rows_recv_q.send.msg.row_idx != s.write_ctr.out - s.num_rows.out) else s.write_ctr.out
              s.rows_recv_q.send.rdy    @= 1
            else:
              s.flag.in_                @= 0
              s.row_end.in_             @= s.rows_recv_q.send.msg.row_end
              s.row_idx.in_             @= s.rows_recv_q.send.msg.row_idx
              s.col_idx.in_             @= s.rows_recv_q.send.msg.row_start

              s.cols_recv_addr_raw      @= s.cols_addr.out + 4 * s.rows_recv_q.send.msg.row_start
              s.cols_recv_size_raw      @= s.rows_recv_q.send.msg.row_end - s.rows_recv_q.send.msg.row_start
              s.cols.recv.val           @= 1
              s.cols_send_q.send.rdy    @= 1

              s.vals_recv_addr_raw      @= s.vals_addr.out + 4 * s.rows_recv_q.send.msg.row_start
              s.vals_recv_size_raw      @= s.rows_recv_q.send.msg.row_end - s.rows_recv_q.send.msg.row_start
              s.vals.recv.val           @= 1
              s.vals_send_q.send.rdy    @= 1

              s.vec_send_q.send.rdy     @= 0

          if (s.cols_send_q.send.val & s.vals_send_q.send.val):
            s.val_val.in_               @= s.vals_send_q.send.msg.data
            s.vec_recv_addr_raw         @= s.vec_addr.out + 4 * s.cols_send_q.send.msg.data
            s.vec_recv_size_raw         @= b32(1)
            s.vec.recv.val              @= 1

            s.vec_send_q.send.rdy       @= 1

            s.cols_send_q.send.rdy      @= 0
            s.vals_send_q.send.rdy      @= 0
            s.cols.recv.val             @= 0
            s.vals.recv.val             @= 0
          
          if (s.vec.send.val & s.vec.send.rdy):          
            s.col_idx.in_               @= s.col_idx.out + 1
            s.vec_send_q.send.rdy       @= 0
            s.vec.recv.val              @= 0
            s.sum.in_                   @= s.sum.out + s.val_val.out * s.vec.send.msg.data

            s.cols_send_q.send.rdy      @= 1
            s.vals_send_q.send.rdy      @= 1
            s.cols.recv.val             @= 1
            s.vals.recv.val             @= 1

            s.vec_send_q.send.rdy       @= 0
            
          if ((s.col_idx.out == s.row_end.out) & (s.row_end.out != 0)) & (s.mem_sent.out == 0) & (s.flag.out == 0):
            s.write_mem.req.val         @= 1
            s.mem_sent.in_              @= 1
            s.write_mem_msg_raw         @= MemReqMsg( MEM_TYPE_WRITE, 0, s.dest_addr.out + s.row_idx.out * 4, 0, s.sum.out )
            s.memresp_q.send.rdy        @= 1
            s.rows_recv_q.send.rdy      @= 1

          if (s.memresp_q.send.val & s.memresp_q.send.rdy):
            s.memresp_q.send.rdy        @= 0
            s.vec_send_q.send.rdy       @= 0
            s.flag.in_                  @= 1
            s.sum.in_                   @= 0
            s.mem_sent.in_              @= 0
            s.write_ctr.in_             @= s.write_ctr.out - 1 

          if (s.write_ctr.out == 0):
            s.done.in_                @= 1
            
          if (s.done.out):
            s.rows_send_msg_raw       @= 1
            s.rows_send.val           @= 1

  #   Line tracing
  def line_trace( s ):
    s.trace = ""

    state2char = {
      s.STATE_XCFG    : "I ",
      s.STATE_SPMV    : "X ",
    }

    s.state_str = state2char[s.state]

    s.trace = "({}: val {}, vec {}, col {}, data {}, wr: req {} ctr {})".format(
      s.state_str,
      s.val_val.out,
      s.vec.send.msg.data,
      s.col_idx.out,
      s.sum.out,
      s.write_mem.req.val,
      s.write_ctr.out,
    )

    return s.trace