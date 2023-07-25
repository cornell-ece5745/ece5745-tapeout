#=========================================================================
# Many to One RTL Model
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib import stream

class ManyToOneRTL ( Component ):

  # Constructor

  def construct( s ):

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( Bits8 )
    s.send = stream.ifcs.SendIfcRTL( Bits32 )

    # # Queues to buffer input

    # s.inq = stream.NormalQueueRTL( Bits8, 2 )
    # s.inq.recv //= s.recv

    # Counter

    s.res           = Wire( Bits32 )
    s.res_next      = Wire( Bits32 )
    s.finished      = Wire( Bits1 )
    s.finished_next = Wire( Bits1 )
    
    @update_ff
    def res_update():
      if s.reset | s.finished:
        s.res <<= 0
        s.finished <<= 0
      else:
        s.finished <<= s.finished_next
        if s.finished_next:
          s.res <<= s.res
        else:
          s.res <<= s.res_next
        
    
    # Logic
    @update
    def block():
      # We are ready to process another number if the previous input is not 0
      s.recv.rdy    @= ~s.finished

      # The output is always the result
      s.send.msg     @= s.res

      # If we have a new transaction, update the result
      if s.recv.val & s.recv.rdy:
        s.res_next  @= s.res + sext(s.recv.msg, 32)
      else:
        s.res_next  @= s.res
      
      # We have a valid message when we're finished 
      s.send.val @= s.finished

      # If we are able to send the transaction, then reset the finished bit
      if s.send.val & s.send.rdy:
        s.finished_next @= 0
      else:
        s.finished_next @= (s.recv.msg == b8(-1))


  # Line tracing

  def line_trace( s ):
    return f"{s.recv}({s.res}|{s.finished}){s.send}"

