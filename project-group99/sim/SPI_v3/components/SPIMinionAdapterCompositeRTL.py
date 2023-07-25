#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in IntMultBasePRTL) or set this variable to
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

class SPIMinionAdapterCompositeVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, nbits=34, num_entries=1 ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'SPIMinionAdapterCompositeRTL_{nbits}nbits_{num_entries}entries' )

    s.spi_min = SPIMinionIfc()
    
    s.recv = RecvIfcRTL( mk_bits(nbits-2))
    s.send = SendIfcRTL( mk_bits(nbits-2))

    s.minion_parity = OutPort()
    s.adapter_parity = OutPort()

    s.set_metadata( VerilogPlaceholderPass.port_map, {
      s.spi_min.cs    : 'cs',
      s.spi_min.sclk  : 'sclk',
      s.spi_min.mosi  : 'mosi',
      s.spi_min.miso  : 'miso',

      s.recv.val  : 'recv_val',
      s.recv.rdy  : 'recv_rdy',
      s.recv.msg  : 'recv_msg',

      s.send.val  : 'send_val',
      s.send.rdy  : 'send_rdy',
      s.send.msg  : 'send_msg',

      s.minion_parity  : 'minion_parity',
      s.adapter_parity : 'adapter_parity'
    })

# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .SPIMinionAdapterCompositePRTL import SPIMinionAdapterCompositePRTL as SPIMinionAdapterCompositeRTL
elif rtl_language == 'verilog':
  SPIMinionAdapterCompositeRTL = SPIMinionAdapterCompositeVRTL
else:
  raise Exception("Invalid RTL language!")