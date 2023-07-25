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

class ImmGenVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'ImmGenRTL' )

    s.imm_type = InPort( 3 )
    s.inst     = InPort( 32 )

    s.imm      = OutPort( 32 )

    # Verilog module setup

    s.set_metadata( VerilogPlaceholderPass.src_file, path.dirname(__file__) + '/ProcDpathComponentsVRTL.v' )

    # Auto infer!
    # s.set_metadata( VerilogPlaceholderPass.has_clk,   False )
    # s.set_metadata( VerilogPlaceholderPass.has_reset, False )

class AluVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'AluRTL' )

    s.in0      = InPort ( 32 )
    s.in1      = InPort ( 32 )
    s.fn       = InPort ( 4 )

    s.out      = OutPort( 32 )
    s.ops_eq   = OutPort()
    s.ops_lt   = OutPort()
    s.ops_ltu  = OutPort()

    # Verilog module setup

    s.set_metadata( VerilogPlaceholderPass.src_file, path.dirname(__file__) + '/ProcDpathComponentsVRTL.v' )

    # Auto infer!
    # s.set_metadata( VerilogPlaceholderPass.has_clk,   False )
    # s.set_metadata( VerilogPlaceholderPass.has_reset, False )

# See if the course staff want to force testing a specific RTL language
# for their own testing.

import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .ProcDpathComponentsPRTL import ImmGenPRTL as ImmGenRTL
  from .ProcDpathComponentsPRTL import AluPRTL    as AluRTL
elif rtl_language == 'verilog':
  ImmGenRTL = ImmGenVRTL
  AluRTL    = AluVRTL
else:
  raise Exception("Invalid RTL language!")
