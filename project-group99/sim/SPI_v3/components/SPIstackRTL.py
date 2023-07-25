#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in IntMulBasePRTL) or set this variable to
# 'verilog' if you are using Verilog for your RTL design (i.e., your
# design is in IntMulBaseVRTL).

rtl_language = 'pymtl'

#-------------------------------------------------------------------------
# Do not edit below this line
#-------------------------------------------------------------------------

# PyMTL wrappers for the corresponding Verilog RTL models.

from os import path
from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL
from ..interfaces.SPIIfc import SPIMinionIfc


class SPIStackVRTL( VerilogPlaceholder, Component ):

  def construct( s, nbits=34, num_entries=1 ):
    s.nbits = nbits

    # Interface

    s.spi_min = SPIMinionIfc()

    s.recv = RecvIfcRTL( mk_bits(nbits-2))
    s.send = SendIfcRTL( mk_bits(nbits-2))

    s.minion_parity = OutPort()
    s.adapter_parity = OutPort()

    s.loopthrough_sel = InPort()

    s.set_metadata( VerilogPlaceholderPass.params, { 
      'nbits'       : nbits, 
      'num_entries' : num_entries
    })
    s.set_metadata( VerilogPlaceholderPass.port_map, {

      s.loopthrough_sel     : 'loopthrough_sel',
      s.minion_parity       : 'minion_parity',
      s.adapter_parity      : 'adapter_parity',

      s.spi_min.cs          : 'cs',
      s.spi_min.mosi        : 'mosi',
      s.spi_min.miso        : 'miso',
      s.spi_min.sclk        : 'sclk',

      s.recv.val            : 'recv_val',
      s.recv.msg            : 'recv_msg',
      s.recv.rdy            : 'recv_rdy',

      s.send.val            : 'send_val',
      s.send.msg            : 'send_msg',      
      s.send.rdy            : 'send_rdy',
    })
  
  def line_trace( s ):
    return f"send {s.send.val}|{s.send.rdy}|{s.send.msg}\
              recv {s.recv.val}|{s.recv.rdy}|{s.recv.msg}\
              lt_sel|{s.loopthrough_sel}\
              mp|{s.minion_parity}\
              ap|{s.adapter_parity}"

# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .SPIStackPRTL import SPIStackPRTL as SPIStackRTL
elif rtl_language == 'verilog':
  SPIStackRTL = SPIStackVRTL
else:
  raise Exception("Invalid RTL language!")
