#=========================================================================
# Funnel.py
#=========================================================================
# The Funnel model is a val-rdy based arbiter model that selects a single
# val-rdy message source given a number of sources. NOTE: The message is
# assumed to have an opaque field.
from copy import deepcopy

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.queues  import BypassQueueRTL
from pymtl3.stdlib.basic_rtl  import RoundRobinArbiterEn

#-------------------------------------------------------------------------
# Funnel
#-------------------------------------------------------------------------

class Funnel( Component ):

  def construct( s, MsgType, nports ):
    DataType = mk_bits(nports)

    OpaqueType = MsgType.get_field_type( 'opaque' )

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    s.in_ = [ stream.ifcs.RecvIfcRTL( MsgType ) for _ in range(nports) ]
    s.out = stream.ifcs.SendIfcRTL( MsgType )

    #---------------------------------------------------------------------
    # Setup round robin arbiter
    #---------------------------------------------------------------------
    # Notice that we AND the output ready with each request signal, so
    # if the output port is not ready we do not make any requests to the
    # arbiter. This will prevent the arbiter priority from changing.

    s.vals    = Wire( nports )
    s.arbiter = RoundRobinArbiterEn( nports )
    s.arbiter.en //= 1

    @update
    def arbiter_logic():
      s.vals         @= 0
      s.arbiter.reqs @= 0
      for i in range( nports ):
        s.in_[i].rdy @= 0

      for i in range( nports ):
        s.vals[i]         @= s.in_[i].val
        s.arbiter.reqs[i] @= s.in_[i].val & s.out.rdy
        s.in_[i].rdy      @= s.arbiter.grants[i]

    #---------------------------------------------------------------------
    # Assign outputs
    #---------------------------------------------------------------------

    @update
    def output_logic():
      s.out.val @= reduce_or( s.vals )
      s.out.msg @= MsgType()

      for i in range( nports ):
        if s.arbiter.grants[i]:
          s.out.msg        @= s.in_[i].msg
          s.out.msg.opaque @= i

  #-----------------------------------------------------------------------
  # line_trace
  #-----------------------------------------------------------------------

  def line_trace( s ):
    in_str = '{' + '|'.join(map(str,s.in_)) + '}'
    return "{} ({}) {}".format( in_str, s.arbiter.line_trace(), s.out )
