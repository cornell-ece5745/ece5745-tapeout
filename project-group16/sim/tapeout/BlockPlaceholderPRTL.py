'''
==========================================================================
BlockPlaceholderPRTL.py
==========================================================================
This module is connected to the SPI_stack upon release of the Tapeout folder.
It will be replaced by the module the group is hoping to put onto the chip.
The reason for this is that smoke tests will not pass in pymtl3 unless all the
ports are connected.

This module is simply another loopback

Author : Jack Brzozowski
  Date : May 18th, 2022

'''

from pymtl3 import *
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL
from pymtl3.passes.backends.verilog import *
from pymtl3.passes.backends.yosys import *


class BlockPlaceholderPRTL( Component ):

  #=======================================================================
  # Constructor
  #=======================================================================

  def construct( s, nbits=32 ):

    s.nbits = mk_bits(nbits)

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    s.send         = SendIfcRTL(s.nbits)
    s.recv         = RecvIfcRTL(s.nbits)
 
    #--------------------------------------------------------------------- 
    # Module Instantiation
    #---------------------------------------------------------------------
    
    s.send //= s.recv
    
  #=======================================================================
  # Line tracing
  #=======================================================================

  def line_trace( s ):

    return ""