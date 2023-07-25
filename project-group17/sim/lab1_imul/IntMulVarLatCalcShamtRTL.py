#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in CalcShamtPRTL) or set this variable to
# 'verilog' if you are using Verilog for your RTL design (i.e., your
# design is in CalcShamtVRTL).

rtl_language = 'pymtl'

#-------------------------------------------------------------------------
# Do not edit below this line
#-------------------------------------------------------------------------

# This is the PyMTL wrapper for the corresponding Verilog RTL model.

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class IntMulVarLatCalcShamtVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'IntMulVarLatCalcShamtRTL' )

    # Interface

    s.in_ = InPort (8)
    s.out = OutPort(4)

    # Configurations

    s.set_metadata( VerilogPlaceholderPass.has_clk,   False )
    s.set_metadata( VerilogPlaceholderPass.has_reset, False )

# See if the course staff want to force testing a specific RTL language
# for their own testing.

import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .IntMulVarLatCalcShamtPRTL import IntMulVarLatCalcShamtPRTL as IntMulVarLatCalcShamtRTL
elif rtl_language == 'verilog':
  IntMulVarLatCalcShamtRTL = IntMulVarLatCalcShamtVRTL
else:
  raise Exception("Invalid RTL language!")
