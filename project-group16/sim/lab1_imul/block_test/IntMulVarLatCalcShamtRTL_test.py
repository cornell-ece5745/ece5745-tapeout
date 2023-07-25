#=========================================================================
# IntMulVarLatCalcShamtRTL_test
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim
from lab1_imul.IntMulVarLatCalcShamtRTL import IntMulVarLatCalcShamtRTL

#-------------------------------------------------------------------------
# test_basic
#-------------------------------------------------------------------------

def test_basic( cmdline_opts ):
  dut = IntMulVarLatCalcShamtRTL()

  run_test_vector_sim( dut, [
    ('in_   out*'),
    [ 0x10, 4    ],
  ], cmdline_opts )

#-------------------------------------------------------------------------
# test_single_one
#-------------------------------------------------------------------------

def test_single_one( cmdline_opts ):
  dut = IntMulVarLatCalcShamtRTL()

  run_test_vector_sim( dut, [
    ('in_         out*'),
    [ 0x00000000, 8    ],
    [ 0x00000001, 1    ],
    [ 0x00000002, 1    ],
    [ 0x00000004, 2    ],
    [ 0x00000008, 3    ],
    [ 0x00000010, 4    ],
    [ 0x00000020, 5    ],
    [ 0x00000040, 6    ],
    [ 0x00000080, 7    ],
  ], cmdline_opts )

#-------------------------------------------------------------------------
# test_multiple_ones
#-------------------------------------------------------------------------

def test_multiple_ones( cmdline_opts ):
  dut = IntMulVarLatCalcShamtRTL()

  run_test_vector_sim( dut, [
    ('in_         out*'),
    [ 0x00000011, 1    ],
    [ 0x00000012, 1    ],
    [ 0x00000014, 2    ],
    [ 0x00000018, 3    ],
    [ 0x00000010, 4    ],
    [ 0x00000010, 4    ],
  ], cmdline_opts )
