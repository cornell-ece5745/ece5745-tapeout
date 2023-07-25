#=========================================================================
# CRC32 Unit FL Model
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib import stream

from .CRC32UnitMsg import CRC32UnitMsgs

#-------------------------------------------------------------------------
# Crc32UnitFL
#-------------------------------------------------------------------------

class CRC32UnitFl( Component ):

  # Constructor

  def construct( s ):

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL(CRC32UnitMsgs.req)
    s.send = stream.ifcs.SendIfcRTL(CRC32UnitMsgs.resp)

    # Queue Adapters

    s.req_q  = stream.RecvQueueAdapter(CRC32UnitMsgs.req) # gives a deq method to call
    s.resp_q = stream.SendQueueAdapter(CRC32UnitMsgs.resp) # gives a send method to call

    s.recv //= s.req_q.recv
    s.send //= s.resp_q.send

    # FL block

    @update_once
    def block():
      if s.resp_q.enq.rdy() and s.req_q.deq.rdy():
        msg = s.req_q.deq()
        s.resp_q.enq( gcd(msg.a, msg.b) )

  # Line tracing

  def line_trace( s ):
    return f"{s.recv}(){s.send}"
