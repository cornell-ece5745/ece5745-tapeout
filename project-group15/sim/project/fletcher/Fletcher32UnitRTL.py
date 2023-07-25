#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in IntMultFixedLatPRTL) or set this variable to
# 'verilog' if you are using Verilog for your RTL design (i.e., your
# design is in IntMulFixedLatVRTL).

rtl_language = 'verilog'

#-------------------------------------------------------------------------
# Do not edit below this line
#-------------------------------------------------------------------------

# This is the PyMTL wrapper for the corresponding Verilog RTL model.

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

from .Fletcher32UnitMsg import Fletcher32UnitMsgs

class Fletcher32UnitVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'Fletcher32UnitRTL' )

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( Fletcher32UnitMsgs.req )
    s.send = stream.ifcs.SendIfcRTL( Fletcher32UnitMsgs.resp )

# Import the appropriate version based on the rtl_language variable

# if rtl_language == 'pymtl':
#   from .IntMulFixedLatPRTL import IntMulFixedLatPRTL as IntMulFixedLatRTL
# elif rtl_language == 'verilog':
#   IntMulFixedLatRTL = IntMulFixedLatVRTL
# else:
#   raise Exception("Invalid RTL language!")

Fletcher32UnitRTL = Fletcher32UnitVRTL