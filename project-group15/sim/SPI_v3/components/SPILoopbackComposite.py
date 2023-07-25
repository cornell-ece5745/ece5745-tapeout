'''
==========================================================================
SPILoopbackComposite.py
==========================================================================
A composition module consisting of SPIMinionAdapterComposite and Loopback modules.
For use with testing SPI communication

Author : Kyle Infantino
  Date : Jan 30, 2022

'''

from pymtl3 import *
from .SPIMinionAdapterCompositePRTL import SPIMinionAdapterCompositePRTL
from .Loopback import Loopback
from ..interfaces.SPIIfc import SPIMinionIfc

class SPILoopbackComposite( Component ):

  def construct( s, nbits=32 ):

    #Local parameters

    s.nbits = nbits  # size of SPI packet including 2 bit flow control

    #Interface

    s.spi_min = SPIMinionIfc()
    s.minion_parity = OutPort()
    s.adapter_parity = OutPort()

    s.composite = m = SPIMinionAdapterCompositePRTL(s.nbits, 1)
    m.spi_min   //= s.spi_min
    m.minion_parity //= s.minion_parity
    m.adapter_parity //= s.adapter_parity

    s.loopback = m = Loopback(s.nbits-2)
    m.recv //= s.composite.send
    m.send //= s.composite.recv

  def line_trace( s ):
    return f'loopback recv_msg {s.loopback.recv.msg} loopback send_msg {s.loopback.send.msg}'