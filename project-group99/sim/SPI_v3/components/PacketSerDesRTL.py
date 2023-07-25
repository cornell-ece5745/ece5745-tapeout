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
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL
from pymtl3.stdlib.stream.ifcs import SendIfcRTL

class PacketSerDesVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, nbits_in, nbits_out ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'PacketSerDesRTL_{nbits_in}nbits_in_{nbits_out}nbits_out' )

    s.nbits_in = nbits_in
    s.nbits_out = nbits_out

    s.serdes_recv = RecvIfcRTL(mk_bits(s.nbits_in))
    s.serdes_send = SendIfcRTL(mk_bits(s.nbits_out))

    s.set_metadata( VerilogPlaceholderPass.port_map, {
      s.serdes_recv.rdy  : 'recv_rdy',
      s.serdes_recv.val  : 'recv_val',
      s.serdes_recv.msg  : 'recv_msg',
      s.serdes_send.rdy : 'send_rdy',
      s.serdes_send.val : 'send_val',
      s.serdes_send.msg : 'send_msg',
    })

# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .PacketSerDesPRTL import PacketSerDesPRTL as PacketSerDesRTL
elif rtl_language == 'verilog':
  PacketSerDesRTL = PacketSerDesVRTL
else:
  raise Exception("Invalid RTL language!")