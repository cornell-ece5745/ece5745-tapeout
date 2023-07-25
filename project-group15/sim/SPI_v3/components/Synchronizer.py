'''
==========================================================================
Synchronizer.py
==========================================================================
 - RTL code for the Synchronizer module.
 - It samples the input signal using the device clock and also detects
     positive and negative edges.
 - Reference: https://www.fpga4fun.com/SPI2.html
'''

from pymtl3 import *


class Synchronizer( Component ):

  def construct( s, reset_value=0 ):

    s.reset_value = Bits1(reset_value)
    # Interface

    s.in_      = InPort()
    s.out      = OutPort()
    s.posedge_ = OutPort()
    s.negedge_ = OutPort()

    # Components

    s.shreg = Wire( Bits3 )

    @update_ff
    def up_shreg():
      if s.reset: s.shreg <<= concat(s.reset_value,s.reset_value,s.reset_value) #for 4 state sim
      else: s.shreg <<= concat( s.shreg[0:2], s.in_ )

    s.out      //= s.shreg[1]
    s.posedge_ //= lambda: ~s.shreg[2] & s.shreg[1]
    s.negedge_ //= lambda: s.shreg[2]  & ~s.shreg[1]

  def line_trace( s ):
    return ''
