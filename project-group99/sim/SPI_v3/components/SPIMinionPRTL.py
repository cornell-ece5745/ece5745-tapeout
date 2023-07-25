'''
==========================================================================
SPIMinionPRTL.py
==========================================================================
SPIMinion module. Supports SPI mode 0

Author : Yanghui Ou, Modified by Kyle Infantino
'''

from pymtl3 import *
from .Synchronizer import Synchronizer
from .ShiftReg import ShiftReg

from ..interfaces import PushOutIfc, PullInIfc
from ..interfaces.SPIIfc import SPIMinionIfc

class SPIMinionPRTL( Component ):

  def construct( s, nbits=8 ):

    # Local parameters
    s.nbits = nbits

    # Interface
    s.spi_min = SPIMinionIfc()

    s.push = PushOutIfc( s.nbits )
    s.pull = PullInIfc ( s.nbits )

    s.parity = OutPort()

    # Components & Logic
    s.cs_sync = Synchronizer(1)
    s.cs_sync.in_ //= s.spi_min.cs

    s.sclk_sync = Synchronizer(0)
    s.sclk_sync.in_ //= s.spi_min.sclk

    s.mosi_sync = Synchronizer(0)
    s.mosi_sync.in_ //= s.spi_min.mosi

    # Add Comments
    s.shreg_in = m = ShiftReg( s.nbits )
    m.in_       //= s.mosi_sync.out
    m.shift_en  //= lambda: ~s.cs_sync.out & s.sclk_sync.posedge_
    m.load_en   //= 0
    m.load_data //= 0

    s.shreg_out = m = ShiftReg( s.nbits )
    m.in_       //= 0
    m.shift_en  //= lambda: ~s.cs_sync.out & s.sclk_sync.negedge_
    m.load_en   //= s.pull.en
    m.load_data //= s.pull.msg

    s.spi_min.miso  //= s.shreg_out.out[s.nbits-1]
    s.pull.en       //= s.cs_sync.negedge_
    s.push.en       //= s.cs_sync.posedge_
    s.push.msg      //= s.shreg_in.out

    s.parity //= lambda: reduce_xor(s.push.msg[0:s.nbits-2]) & s.push.en


  def line_trace( s ):

    pull_msg = f'{s.pull}'
    push_msg = f'{s.push}'

    high = '@'
    low  = '.'
    cs   = high if s.spi_min.cs   else low
    sclk = high if s.spi_min.sclk else low

    in_bit  = f'{s.shreg_in.in_}' if s.shreg_in.shift_en else ' '

    return f'{cs} {sclk}   {s.spi_min.mosi} {pull_msg} ({in_bit}) {s.spi_min.miso} {push_msg}'
