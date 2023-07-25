'''
==========================================================================
SPIStackPRTL.py
==========================================================================
A composition module combining the SPI Minion, SPI Minion Adapter, and Loopthrough
This is the standard SPI stack used in the efabless tapeout in 2022.

Author : Jack Brzozowski
  Date : May 7th, 2022

'''
from pymtl3 import *

from .SPIMinionAdapterCompositePRTL import SPIMinionAdapterCompositePRTL
from .LoopThroughPRTL import LoopThroughPRTL
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL
from ..interfaces.SPIIfc import SPIMinionIfc
from .Synchronizer import Synchronizer

class SPIStackPRTL( Component ):

  def construct( s, nbits=34, num_entries=1 ):
    s.nbits = nbits

    # Interface

    s.spi_min = SPIMinionIfc()

    s.recv = RecvIfcRTL( mk_bits(nbits-2))
    s.send = SendIfcRTL( mk_bits(nbits-2))

    s.minion_parity = OutPort()
    s.adapter_parity = OutPort()

    s.loopthrough_sel = InPort()

    s.minion = m = SPIMinionAdapterCompositePRTL(nbits, num_entries)
    m.spi_min //= s.spi_min # Connect SPI Ifc
    m.minion_parity //= s.minion_parity
    m.adapter_parity //= s.adapter_parity

    s.loopthrough = lt = LoopThroughPRTL(nbits-2)

    s.lt_sel_sync = Synchronizer(0)
    s.lt_sel_sync.in_ //= s.loopthrough_sel
    lt.sel //= s.lt_sel_sync.out

    lt.upstream.req //= m.send # Connect send ifc of minion adapter to upstream recv ifc of loopthrough
    lt.upstream.resp//= m.recv # Connect recv ifc of minion adapter to upstream send ifc of loopthrough

    lt.downstream.req //=s.send # Output to the design block connecting to the SPI stack
    lt.downstream.resp//=s.recv # Input from the design block connecting to the SPI stack

  def line_trace( s ):
    return f"send {s.send.val}|{s.send.rdy}|{s.send.msg} recv {s.recv.val}|{s.recv.rdy}|{s.recv.msg}\
            lt_sel|{s.loopthrough_sel} mp|{s.minion_parity} ap|{s.adapter_parity}"
