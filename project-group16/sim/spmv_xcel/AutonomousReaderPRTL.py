#=========================================================================
# Reader Unit RTL Model
#=========================================================================
# Read size elements from memory starting at base address.
#

from pymtl3      import *

from pymtl3.stdlib import stream
from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType
from pymtl3.stdlib.basic_rtl  import Reg, RegRst
from pymtl3.passes.backends.verilog import *

from .ReaderUnitMsgs import ReaderUnitMsgs

class ReaderUnitPRTL( Component ):

  # Constructor

  def construct( s ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'ReaderUnitRTL' )

    MemReqMsg, MemRespMsg = mk_mem_msg( 8,32,32 )
    MEM_TYPE_READ  = b4(MemMsgType.READ)
    MEM_TYPE_WRITE = b4(MemMsgType.WRITE)

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( ReaderUnitMsgs.req )
    s.send = stream.ifcs.SendIfcRTL( ReaderUnitMsgs.resp )

    s.mem  = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )

    # Queues Buffer input

    s.memresp_q = stream.NormalQueueRTL( MemRespMsg, 8 )
    s.memresp_q.recv //= s.mem.resp

    # Internal state

    s.idx_rd        = RegRst( Bits32 )
    s.memrsp_recv   = RegRst( Bits32 )
    s.base_addr     = RegRst( Bits32 )
    s.size          = RegRst( Bits32 )
    s.counter       = RegRst( Bits5  )
    s.queue         = [Bits32(0) for _ in range(32)]

    #=====================================================================
    # State Update
    #=====================================================================

    s.STATE_INIT    = b1( 0 )
    s.STATE_M_RD    = b1( 1 )
    s.state         = Wire( 1 )

    @update_ff
    def state_transitions():

      if s.reset:
        s.state <<= s.STATE_INIT

      # Transistions out of IDLE state

      elif s.state == s.STATE_INIT:
        if s.recv.val:
          s.state <<= s.STATE_M_RD

      # Transistions out of M_RD state

      if s.state == s.STATE_M_RD:
        if ( s.idx_rd.out >= s.size.out ) & ( s.memrsp_recv.out >= s.size.out ):
          s.state <<= s.STATE_INIT

      #=====================================================================
      # State Outputs
      #=====================================================================

    @update
    def block1():

      s.mem.req.val        @= 0
      s.memresp_q.send.rdy @= 0
      s.mem.req.msg        @= b78(0)
      s.recv.rdy           @= 0
      s.send.val           @= 0

      s.idx_rd.in_      @= s.idx_rd.out
      s.base_addr.in_   @= s.base_addr.out
      s.size.in_        @= s.size.out
      s.memrsp_recv.in_ @= s.memrsp_recv.out
      s.counter.in_     @= s.counter.out

      #-------------------------------------------------------------------
      # STATE: INIT
      #-------------------------------------------------------------------

      if s.state == s.STATE_INIT:

        s.idx_rd.in_         @= 0
        s.memrsp_recv.in_    @= 0
        s.recv.rdy           @= 1
        s.send.val           @= 0
        s.counter.in_        @= 0
        s.base_addr.in_      @= s.recv.msg.base_addr
        s.size.in_           @= s.recv.msg.size
        s.send.msg.done      @= 0

      #-------------------------------------------------------------------
      # STATE: M_RD
      #-------------------------------------------------------------------
      # Memory read stage.
      # Decouple memory requests and responses and wait until sent all memreq
      # and received all memory responses

      elif s.state == s.STATE_M_RD:

        s.recv.rdy @= s.send.rdy
        s.send.val @= 0

        # Memory requests. Continue sending until have sent all memreq
        if (s.idx_rd.out < s.size.out):
          s.mem.req.val @= 1

          s.mem.req.msg @= MemReqMsg( MEM_TYPE_READ, 0, s.base_addr.out + 4*zext(s.idx_rd.out, 32), 0, 0 )

          if s.mem.req.rdy:
            s.idx_rd.in_  @= s.idx_rd.out + 1

        else:
          s.mem.req.msg @= b78(0)
          s.mem.req.val @= 0

        s.memresp_q.send.rdy @= s.send.rdy

        # Memory responses. Continue receiving until received all memresp
        if s.memresp_q.send.val & s.memresp_q.send.rdy:
          s.send.val             @= 1
          s.memrsp_recv.in_      @= s.memrsp_recv.out + 1
          s.send.msg.data        @= s.memresp_q.send.msg.data if s.send.val else 0
          s.send.msg.done        @= 1 if ( (s.memrsp_recv.out == s.size.out - 1 ) & s.send.val) else 0
        
  #   Line tracing

  def line_trace( s ):

    s.trace = ""

    state2char = {
      s.STATE_INIT    : "I ",
      s.STATE_M_RD    : "RD",
    }

    s.state_str = state2char[s.state]

    s.trace = "({} {}:{}:{}){}".format(
      s.state_str,
      s.memrsp_recv.out,
      s.send.val,
      s.mem.req,
      s.mem.resp,
    )

    return s.trace
