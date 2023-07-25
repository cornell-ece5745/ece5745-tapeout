'''
==========================================================================
ShiftReg.py
==========================================================================
N-bit shift register.
'''

from pymtl3 import *

class ShiftReg( Component ):

  def construct( s, nbits ):

    # Local Parameters
    s.nbits = nbits

    # Interface

    s.in_       = InPort ()
    s.out       = OutPort( s.nbits )
    s.shift_en  = InPort ()
    s.load_en   = InPort ()
    s.load_data = InPort ( s.nbits )

    # Logic

    @update_ff
    def up_shreg():
      if s.reset: 
        s.out <<= zext(Bits1(0), s.nbits) # for 4 state sim
      elif ( s.load_en ):
        s.out <<= s.load_data
      elif ( ~s.load_en & s.shift_en ):
        s.out <<= concat( s.out[0:s.nbits-1], s.in_ )


  def line_trace( s ):
    return f'{s.in_.bin()}(){s.out.bin()}'
