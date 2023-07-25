from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.basic_rtl import RegRst

class CRC32UnitPRTL ( Component ):

  # Constructor

  def construct( s ):
    
    # Data
    s.recv          = stream.ifcs.RecvIfcRTL( Bits8 )
    # CRC
    s.send          = stream.ifcs.SendIfcRTL( Bits32 )

    s.res           = RegRst( Bits32, reset_value=0xFFFFFFFF )
    s.size          = RegRst( Bits8 )

    s.state         = Wire( Bits2 )

    s.INIT          = b2(0)
    s.SIZED         = b2(1)
    s.CALC          = b2(2)
    s.FINISH        = b2(3)

    @update_ff
    def state_update():
      if s.reset:
        s.state <<= s.INIT

      elif s.state == s.INIT:
        if s.recv.val:
          s.state <<= s.SIZED
        
      elif s.state == s.SIZED:
        if s.recv.rdy & s.recv.val:
          s.state <<= s.CALC

      elif s.state == s.CALC:
        if s.size.out == 0:
          s.state <<= s.FINISH

      elif s.state == s.FINISH:
        if s.send.rdy:
          s.state <<= s.INIT

      else:
        s.state <<= s.state

    @update
    def state_outputs():
      s.recv.rdy @= 0
      s.send.val @= 0
      s.send.msg @= 0

      s.res.in_ @= s.res.out
      s.size.in_ @= s.size.out

      #if s.state == s.INIT:
        #pass
        #do nothing

      if s.state == s.SIZED:
        s.recv.rdy @= 1
        s.size.in_ @= s.recv.msg 

      elif s.state == s.CALC:
        s.recv.rdy @= 1

        if s.recv.val:
          s.size.in_ @= s.size.out - 1

          s.res.in_ [31] @= s.res.out [7] ^ s.res.out [1] ^ s.recv.msg [7] ^ s.recv.msg [1]
          s.res.in_ [30] @= s.res.out [7] ^ s.res.out [6] ^ s.res.out [1] ^ s.res.out [0] ^ s.recv.msg [7] ^ s.recv.msg [6] ^ s.recv.msg [1] ^ s.recv.msg [0]
          s.res.in_ [29] @= s.res.out [7] ^ s.res.out [6] ^ s.res.out [5] ^ s.res.out [1] ^ s.res.out [0] ^ s.recv.msg [7] ^ s.recv.msg [6] ^ s.recv.msg [5] ^ s.recv.msg [1] ^ s.recv.msg [0]
          s.res.in_ [28] @= s.res.out [6] ^ s.res.out [5] ^ s.res.out [4] ^ s.res.out [0] ^ s.recv.msg [6] ^ s.recv.msg [5] ^ s.recv.msg [4] ^ s.recv.msg [0]
          s.res.in_ [27] @= s.res.out [7] ^ s.res.out [5] ^ s.res.out [4] ^ s.res.out [3] ^ s.res.out [1] ^ s.recv.msg [7] ^ s.recv.msg [5] ^ s.recv.msg [4] ^ s.recv.msg [3] ^ s.recv.msg [1]
          s.res.in_ [26] @= s.res.out [7] ^ s.res.out [6] ^ s.res.out [4] ^ s.res.out [3] ^ s.res.out [2] ^ s.res.out [1] ^ s.res.out [0] ^ s.recv.msg [7] ^ s.recv.msg [6] ^ s.recv.msg [4] ^ s.recv.msg [3] ^ s.recv.msg [2] ^ s.recv.msg [1] ^ s.recv.msg [0]
          s.res.in_ [25] @= s.res.out [6] ^ s.res.out [5] ^ s.res.out [3] ^ s.res.out [2] ^ s.res.out [1] ^ s.res.out [0] ^ s.recv.msg [6] ^ s.recv.msg [5] ^ s.recv.msg [3] ^ s.recv.msg [2] ^ s.recv.msg [1] ^ s.recv.msg [0]
          s.res.in_ [24] @= s.res.out [7] ^ s.res.out [5] ^ s.res.out [4] ^ s.res.out [2] ^ s.res.out [0] ^ s.recv.msg [7] ^ s.recv.msg [5] ^ s.recv.msg [4] ^ s.recv.msg [2] ^ s.recv.msg [0]
          s.res.in_ [23] @= s.res.out [31] ^ s.res.out [7] ^ s.res.out [6] ^ s.res.out [4] ^ s.res.out [3] ^ s.recv.msg [7] ^ s.recv.msg [6] ^ s.recv.msg [4] ^ s.recv.msg [3]
          s.res.in_ [22] @= s.res.out [30] ^ s.res.out [6] ^ s.res.out [5] ^ s.res.out [3] ^ s.res.out [2] ^ s.recv.msg [6] ^ s.recv.msg [5] ^ s.recv.msg [3] ^ s.recv.msg [2]
          s.res.in_ [21] @= s.res.out [29] ^ s.res.out [7] ^ s.res.out [5] ^ s.res.out [4] ^ s.res.out [2] ^ s.recv.msg [7] ^ s.recv.msg [5] ^ s.recv.msg [4] ^ s.recv.msg [2]
          s.res.in_ [20] @= s.res.out [28] ^ s.res.out [7] ^ s.res.out [6] ^ s.res.out [4] ^ s.res.out [3] ^ s.recv.msg [7] ^ s.recv.msg [6] ^ s.recv.msg [4] ^ s.recv.msg [3]
          s.res.in_ [19] @= s.res.out [27] ^ s.res.out [7] ^ s.res.out [6] ^ s.res.out [5] ^ s.res.out [3] ^ s.res.out [2] ^ s.res.out [1] ^ s.recv.msg [7] ^ s.recv.msg [6] ^ s.recv.msg [5] ^ s.recv.msg [3] ^ s.recv.msg [2] ^ s.recv.msg [1]
          s.res.in_ [18] @= s.res.out [26] ^ s.res.out [6] ^ s.res.out [5] ^ s.res.out [4] ^ s.res.out [2] ^ s.res.out [1] ^ s.res.out [0] ^ s.recv.msg [6] ^ s.recv.msg [5] ^ s.recv.msg [4] ^ s.recv.msg [2] ^ s.recv.msg [1] ^ s.recv.msg [0]
          s.res.in_ [17] @= s.res.out [25] ^ s.res.out [5] ^ s.res.out [4] ^ s.res.out [3] ^ s.res.out [1] ^ s.res.out [0] ^ s.recv.msg [5] ^ s.recv.msg [4] ^ s.recv.msg [3] ^ s.recv.msg [1] ^ s.recv.msg [0]
          s.res.in_ [16] @= s.res.out [24] ^ s.res.out [4] ^ s.res.out [3] ^ s.res.out [2] ^ s.res.out [0] ^ s.recv.msg [4] ^ s.recv.msg [3] ^ s.recv.msg [2] ^ s.recv.msg [0]
          s.res.in_ [15] @= s.res.out [23] ^ s.res.out [7] ^ s.res.out [3] ^ s.res.out [2] ^ s.recv.msg [7] ^ s.recv.msg [3] ^ s.recv.msg [2]
          s.res.in_ [14] @= s.res.out [22] ^ s.res.out [6] ^ s.res.out [2] ^ s.res.out [1] ^ s.recv.msg [6] ^ s.recv.msg [2] ^ s.recv.msg [1]
          s.res.in_ [13] @= s.res.out [21] ^ s.res.out [5] ^ s.res.out [1] ^ s.res.out [0] ^ s.recv.msg [5] ^ s.recv.msg [1] ^ s.recv.msg [0]
          s.res.in_ [12] @= s.res.out [20] ^ s.res.out [4] ^ s.res.out [0] ^ s.recv.msg [4] ^ s.recv.msg [0]
          s.res.in_ [11] @= s.res.out [19] ^ s.res.out [3] ^ s.recv.msg [3]
          s.res.in_ [10] @= s.res.out [18] ^ s.res.out [2] ^ s.recv.msg [2]
          s.res.in_ [9]  @= s.res.out [17] ^ s.res.out [7] ^ s.recv.msg [7]
          s.res.in_ [8]  @= s.res.out [16] ^ s.res.out [7] ^ s.res.out [6] ^ s.res.out [1] ^ s.recv.msg [7] ^ s.recv.msg [6] ^ s.recv.msg [1]
          s.res.in_ [7]  @= s.res.out [15] ^ s.res.out [6] ^ s.res.out [5] ^ s.res.out [0] ^ s.recv.msg [6] ^ s.recv.msg [5] ^ s.recv.msg [0]
          s.res.in_ [6]  @= s.res.out [14] ^ s.res.out [5] ^ s.res.out [4] ^ s.recv.msg [5] ^ s.recv.msg [4]
          s.res.in_ [5]  @= s.res.out [13] ^ s.res.out [7] ^ s.res.out [4] ^ s.res.out [3] ^ s.res.out [1] ^ s.recv.msg [7] ^ s.recv.msg [4] ^ s.recv.msg [3] ^ s.recv.msg [1]
          s.res.in_ [4]  @= s.res.out [12] ^ s.res.out [6] ^ s.res.out [3] ^ s.res.out [2] ^ s.res.out [0] ^ s.recv.msg [6] ^ s.recv.msg [3] ^ s.recv.msg [2] ^ s.recv.msg [0]
          s.res.in_ [3]  @= s.res.out [11] ^ s.res.out [5] ^ s.res.out [2] ^ s.res.out [1] ^ s.recv.msg [5] ^ s.recv.msg [2] ^ s.recv.msg [1]
          s.res.in_ [2]  @= s.res.out [10] ^ s.res.out [4] ^ s.res.out [1] ^ s.res.out [0] ^ s.recv.msg [4] ^ s.recv.msg [1] ^ s.recv.msg [0]
          s.res.in_ [1]  @= s.res.out [9] ^ s.res.out [3] ^ s.res.out [0] ^ s.recv.msg [3] ^ s.recv.msg [0]
          s.res.in_ [0]  @= s.res.out [8] ^ s.res.out [2] ^ s.recv.msg [2]
      
      elif s.state == s.FINISH:
        s.send.msg @= ~s.res.out
        s.send.val @= 1;


  def line_trace( s ):
    return f"{s.state}|>{s.size.out}|{s.recv}({s.res.in_}|{s.res.out}){s.send}"
