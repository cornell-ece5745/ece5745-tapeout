#=======================================================================
# DropUnit.py
#=======================================================================

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.basic_rtl  import RegRst

# State Constants


#-------------------------------------------------------------------------
# DropUnit
#-------------------------------------------------------------------------
# Drop Unit drops a transaction between any two models connected by
# using the en-rdy handshake protocol. It receives a drop signal as an
# input and if the drop signal is high, it will drop the next message
# it sees.

class DropUnitPRTL( Component ):

  def construct( s, dtype ):

    s.drop = InPort()
    s.in_  = stream.ifcs.RecvIfcRTL( dtype )
    s.out  = stream.ifcs.SendIfcRTL( dtype )

    s.out.msg //= s.in_.msg

    s.snoop_state = Wire()

    SNOOP = 0
    WAIT  = 1

    #------------------------------------------------------------------
    # state_transitions
    #------------------------------------------------------------------

    @update_ff
    def state_transitions():
      in_go   = s.in_.rdy & s.in_.val
      do_wait = s.drop & ~in_go

      if s.reset:
        s.snoop_state <<= SNOOP

      elif s.snoop_state == SNOOP:
        if do_wait:
          s.snoop_state <<= WAIT

      elif s.snoop_state == WAIT:
        if in_go:
          s.snoop_state <<= SNOOP

    #------------------------------------------------------------------
    # set_outputs
    #------------------------------------------------------------------

    @update
    def set_outputs():
      s.in_.rdy @= 0
      s.out.val @= 0

      if   s.snoop_state == SNOOP:
        s.out.val @= s.in_.val & ~s.drop
        s.in_.rdy @= s.out.rdy

      elif s.snoop_state == WAIT:
        s.out.val @= 0
        s.in_.rdy @= 1
