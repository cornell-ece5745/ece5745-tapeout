#=========================================================================
# Sort Unit FL Model
#=========================================================================
# Sort array in memory containing positive integers.
# Accelerator register interface:
#
#  xr0 : go/done
#  xr1 : base address of array
#  xr2 : number of elements in array
#
# Accelerator protocol involves the following steps:
#  1. Write the base address of array via xr1
#  2. Write the number of elements in array via xr2
#  3. Tell accelerator to go by writing xr0
#  4. Wait for accelerator to finish by reading xr0, result will be 1
#

from pymtl3        import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType

from proc.XcelMsg import *

class SortXcelFL( Component ):


  def construct( s ):

    # Interface

    s.xcel = stream.ifcs.MinionIfcRTL( XcelReqMsg, XcelRespMsg )
    s.mem  = stream.ifcs.MasterIfcRTL( *mk_mem_msg( 8,32,32 ) )

    s.xcelreq_q  = stream.fl.RecvQueueAdapter(XcelReqMsg)
    s.xcelresp_q = stream.fl.SendQueueAdapter(XcelRespMsg)
    s.xcelreq_q.recv  //= s.xcel.req
    s.xcelresp_q.send //= s.xcel.resp

    s.mem_adapter = stream.fl.MemMasterAdapter( *mk_mem_msg( 8,32,32 ) )
    s.mem_adapter.master //= s.mem

    # Storage
    s.base_addr  = 0
    s.array_size = 0

    @update_once
    def up_sort_xcel():

      # We loop handling accelerator requests. We are only expecting
      # writes to xr0-4, so any other requests are an error. We exit the
      # loop when we see the write to xr0.

      go = False
      while not go:

        xcelreq_msg = s.xcelreq_q.deq()

        if xcelreq_msg.type_ == XCEL_TYPE_WRITE:
          assert xcelreq_msg.addr in [0,1,2], "Only reg writes to 0,1,2 allowed during setup!"

          # Use xcel register address to configure accelerator

          if   xcelreq_msg.addr == 0: go = True
          if   xcelreq_msg.addr == 1: s.base_addr  = xcelreq_msg.data
          elif xcelreq_msg.addr == 2: s.array_size = xcelreq_msg.data

          # Send xcel response message
          s.xcelresp_q.enq( XcelRespMsg( XCEL_TYPE_WRITE, 0 ) )

      array = []
      for i in range(s.array_size):
        array.append( s.mem_adapter.read( s.base_addr + i*4, 4 ) )

      array = sorted(array)

      for i in range(s.array_size):
        s.mem_adapter.write( s.base_addr + i*4, 4, array[i] )

      # Now wait for read of xr0

      xcelreq_msg = s.xcelreq_q.deq()

      # Only expecting read from xr0, so any other request is an xcel
      # protocol error.

      assert xcelreq_msg.type_ == XCEL_TYPE_READ, "Only reg reads allowed during done phase!"

      assert xcelreq_msg.addr == 0, "Only reg read to 0 allowed during done phase!"

      # Send xcel response message indicating xcel is done
      s.xcelresp_q.enq( XcelRespMsg( XCEL_TYPE_READ, 1 ) )

  # Line tracing

  def line_trace( s ):
    return f"{s.xcel}|{s.mem}"
