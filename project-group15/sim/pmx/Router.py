#=========================================================================
# Router.py
#=========================================================================
# The Router model is a val-rdy based arbiter model that routes an incoming
# val-rdy message to an output val-rdy port bundle, given a number of
# outputs. NOTE: The message is assumed to have an opaque field and the
# router simply inspects the opaque field to route a message.

from pymtl3      import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.queues  import BypassQueueRTL

#-------------------------------------------------------------------------
# Router
#-------------------------------------------------------------------------

class Router( Component ):

  def construct( s, MsgType, nports ):

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    s.in_ = stream.ifcs.RecvIfcRTL( MsgType )
    s.out = [ stream.ifcs.SendIfcRTL( MsgType ) for _ in range(nports) ]

    s.out_id = Wire( clog2(nports) )
    s.out_id //= s.in_.msg.opaque[0:clog2(nports)]

    #---------------------------------------------------------------------
    # Assign outputs
    #---------------------------------------------------------------------
    # Notice that we inspect the opaque field in the incoming message to
    # assign the correct OutValRdyBundle.

    @update
    def up_router_logic():
      s.in_.rdy @= s.out[ s.out_id ].rdy

      for i in range( nports ):
        s.out[i].val @= 0
        s.out[i].msg @= MsgType()

      s.out[ s.out_id ].val @= s.in_.val
      s.out[ s.out_id ].msg @= s.in_.msg

  #-----------------------------------------------------------------------
  # line_trace
  #-----------------------------------------------------------------------

  def line_trace( s ):
    out_str = '{' + '|'.join(map(str,s.out)) + '}'
    return f"{s.in_} () {out_str}"
