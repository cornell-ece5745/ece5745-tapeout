#=========================================================================
# Reader Unit RTL Model
#=========================================================================
# Get data from memory and store in xcel response message
# Accelerator register interface:
#
#  xr0 : go/done
#  xr1 : memory address 
#
# Accelerator protocol involves the following steps:
#  1. Write the memory address to xr1
#  2. Tell accelerator to go by writing xr0
#  3. Wait for accelerator to finish by reading xr0, result will be the data

from pymtl3      import *

from pymtl3.stdlib import stream
from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType
from pymtl3.stdlib.basic_rtl  import Reg, RegRst
from pymtl3.passes.backends.verilog import *

from proc.XcelMsg import *

class ReaderUnitXcelPRTL( Component ):

  # Constructor

  def construct( s ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'ReaderUnitXcelRTL' )

    MemReqMsg, MemRespMsg = mk_mem_msg( 8,32,32 )
    MEM_TYPE_READ  = b4(MemMsgType.READ)
    MEM_TYPE_WRITE = b4(MemMsgType.WRITE)

    # Interface

    s.xcel = stream.ifcs.MinionIfcRTL( XcelReqMsg, XcelRespMsg )

    s.mem  = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )

    # Queues Buffer input

    s.xcelreq_q = stream.PipeQueueRTL( XcelReqMsg, 1 )
    s.xcelreq_q.recv //= s.xcel.req
    s.memresp_q = stream.PipeQueueRTL( MemRespMsg, 1 )
    s.memresp_q.recv //= s.mem.resp

    # Input

    s.base_addr     = Reg( Bits32 )

    #=====================================================================
    # Variables
    #=====================================================================

    s.go            = Wire()
    s.queue         = [Bits32(0) for _ in range(8)]
    s.counter       = RegRst( Bits3 )
    s.memreq_sent   = RegRst( Bits32 )
    s.xcelreq       = RegRst( Bits32 )
    s.flag          = Wire()
    s.mem_req       = Wire()
    s.temp          = Wire(32)

    #=====================================================================
    # Combinational Logic
    #=====================================================================

    @update
    def block1():

      s.xcelreq_q.send.rdy @= s.xcel.resp.rdy and s.counter.out <= 7
      # s.xcel.resp.val      @= s.xcel.resp.rdy and s.xcelreq.out != 0 #s.xcelreq_q.send.msg.type_ == XCEL_TYPE_WRITE else 0
      s.counter.in_        @= s.counter.out
      s.memreq_sent.in_    @= s.memreq_sent.out
      s.xcelreq.in_        @= s.xcelreq.out
      s.mem.req.val        @= 0
      
      if s.xcelreq_q.send.val:

        if s.xcelreq_q.send.msg.type_ == XCEL_TYPE_WRITE:

          if s.xcelreq_q.send.msg.addr == 0 and s.flag == 0:
            s.go  @= 1
            s.xcelreq.in_   @= s.xcelreq.out + 1
            s.flag @= 1

          elif s.xcelreq_q.send.msg.addr == 1:
            s.base_addr.in_ @= s.xcelreq_q.send.msg.data
            s.flag @= 0

          s.xcel.resp.msg @= XcelRespMsg( XCEL_TYPE_WRITE, 0 )
          s.xcel.resp.val @= s.xcel.resp.rdy

        else:
          s.xcel.resp.val @= 0

      if (s.xcelreq.out > s.memreq_sent.out):
        if s.go and s.counter.out <= 7 and s.mem.req.rdy: # and s.xcel.resp.rdy:
          s.mem.req.val @= 1
          s.mem.req.msg @= MemReqMsg( MEM_TYPE_READ, 0, s.base_addr.out, 0, 0 )
          s.memreq_sent.in_ @= s.memreq_sent.out + 1
      
      s.memresp_q.send.rdy @= s.memreq_sent.in_ > 0

      if s.memresp_q.send.val and s.memresp_q.send.rdy and s.memreq_sent.out >= zext(s.counter.out, 32):
        s.queue[s.counter.out] @= s.memresp_q.send.msg.data
        s.counter.in_ @= s.counter.out + 1

      if s.counter.out > 0 and s.xcel.resp.rdy and s.xcelreq_q.send.msg.type_ == XCEL_TYPE_READ:
        s.temp @= s.queue.pop(0)
        s.xcel.resp.msg @= XcelRespMsg( XCEL_TYPE_READ, s.temp )
        s.xcel.resp.msg.data @= s.temp
        s.queue.extend([Bits32(0)])
        s.counter.in_ @= s.counter.out - 1
        s.xcel.resp.val @= 1
      
  # Line tracing

  def line_trace( s ):
    return f"{s.counter.out} > {s.temp} > {s.queue[0]}"
