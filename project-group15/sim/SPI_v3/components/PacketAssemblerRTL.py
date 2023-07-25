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
from pymtl3.stdlib.stream.ifcs import MinionIfcRTL

class PacketAssemblerVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, nbits_in, nbits_out ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'PacketAssemblerRTL_{nbits_in}nbits_in_{nbits_out}nbits_out' )
    s.nbits_in = nbits_in
    s.nbits_out = nbits_out

    s.assem_ifc = MinionIfcRTL(mk_bits(s.nbits_in), mk_bits(s.nbits_out))

    s.set_metadata( VerilogPlaceholderPass.port_map, {
      s.assem_ifc.req.rdy  : 'req_rdy',
      s.assem_ifc.req.val  : 'req_val',
      s.assem_ifc.req.msg  : 'req_msg',
      s.assem_ifc.resp.rdy : 'resp_rdy',
      s.assem_ifc.resp.val : 'resp_val',
      s.assem_ifc.resp.msg : 'resp_msg',

    })

# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .PacketAssemblerPRTL import PacketAssemblerPRTL as PacketAssemblerRTL
elif rtl_language == 'verilog':
  PacketAssemblerRTL = PacketAssemblerVRTL
else:
  raise Exception("Invalid RTL language!")