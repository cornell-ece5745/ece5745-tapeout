#=========================================================================
# Fletcher32 Unit FL Model
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib import stream

from .Fletcher32UnitMsg import Fletcher32UnitMsgs

#-------------------------------------------------------------------------
# Fletcher32UnitFL
#-------------------------------------------------------------------------

class Fletcher32UnitFl( Component ):

  # Constructor

  def construct( s ):

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL(Fletcher32UnitMsgs.req)
    s.send = stream.ifcs.SendIfcRTL(Fletcher32UnitMsgs.resp)

    # Queue Adapters

    s.req_q  = stream.RecvQueueAdapter(Fletcher32UnitMsgs.req) # gives a deq method to call
    s.resp_q = stream.SendQueueAdapter(Fletcher32UnitMsgs.resp) # gives a send method to call

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
