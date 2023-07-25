#=========================================================================
# PyMTL wrappers
#=========================================================================

from pymtl3 import *

from pymtl3.passes.backends.verilog import *
from pymtl3.passes.backends.yosys   import *

from SPI_v3.interfaces.SPIIfc import SPIMinionIfc

#-------------------------------------------------------------------------
# PyMTL wrapper for sv2v verilog
#-------------------------------------------------------------------------

class SPI_TapeOutBlockVRTL_sv2v( VerilogPlaceholder, Component ):

  def construct( s ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'grp_16_SPI_TapeOutBlockRTL_32bits_5entries' )
    s.set_metadata( YosysTranslationPass.explicit_module_name,   f'grp_16_SPI_TapeOutBlockRTL_32bits_5entries' )

    s.spi_min         = SPIMinionIfc()
    s.loopthrough_sel = InPort()
    s.minion_parity   = OutPort()
    s.adapter_parity  = OutPort()

    s.set_metadata( VerilogPlaceholderPass.port_map, {
      s.spi_min.cs    : 'spi_min__cs',
      s.spi_min.mosi  : 'spi_min__mosi',
      s.spi_min.miso  : 'spi_min__miso',
      s.spi_min.sclk  : 'spi_min__sclk',
    })

#-------------------------------------------------------------------------
# Choose which implementation to use
#-------------------------------------------------------------------------
# To test the original verilog use this:
#
#   from .SPI_TapeOutBlockPRTL import SPI_TapeOutBlockPRTL as SPI_TapeOutBlockRTL
#
# To test the sv2v verilog use this:
#
#   SPI_TapeOutBlockRTL = SPI_TapeOutBlockVRTL_sv2v

SPI_TapeOutBlockRTL = SPI_TapeOutBlockVRTL_sv2v

