
from pymtl3.passes.backends.verilog import *

# Only using PyMTL version
from .BlockingCachePRTL import BlockingCachePRTL

class BlockingCacheRTL( BlockingCachePRTL ):
  def construct( s, num_banks=0 ):
    super().construct( num_banks )

    # The translated Verilog must be xRTL.v instead of xPRTL.v
    s.set_metadata( VerilogTranslationPass.explicit_module_name,
                    f'cache_BlockingCacheRTL_{num_banks}bank' )
