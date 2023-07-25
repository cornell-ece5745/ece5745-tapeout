'''
==========================================================================
SPIIfc.py
==========================================================================
Master and minion SPI interfaces.

Author : Kyle Infantino
  Date : Mar 22, 2022
'''

from pymtl3 import *

#-------------------------------------------------------------------------
# SPIMasterIfc
#-------------------------------------------------------------------------

class SPIMasterIfc( Interface ):

  def construct( s, ncs ):
    s.cs   = [ OutPort() for _ in range(ncs) ] 
    s.sclk = OutPort()
    s.mosi = OutPort()
    s.miso = InPort()

  def __str__( s ):
    return f"{s.sclk}|{s.cs}|{s.mosi}|{s.miso}"

#-------------------------------------------------------------------------
# SPIMinionIfc
#-------------------------------------------------------------------------

class SPIMinionIfc( Interface ):

  def construct( s ):
    s.sclk  = InPort()
    s.cs    = InPort()
    s.mosi  = InPort()
    s.miso  = OutPort()

  def __str__( s ):
    return f"{s.sclk}|{s.cs}|{s.mosi}|{s.miso}"
