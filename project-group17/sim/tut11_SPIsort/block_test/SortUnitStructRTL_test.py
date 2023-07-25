#=========================================================================
# SortUnitStructRTL_test
#=========================================================================

import pytest

from copy   import deepcopy
from random import randint

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from .SortUnitFL_test import x, \
                             tvec_stream, tvec_dups, tvec_sorted, tvec_random

from ..SortUnitStructRTL import SortUnitStructRTL


header_str =  ( "in_val", "in_[0]",  "in_[1]",  "in_[2]",  "in_[3]",
    "out_val*", "out[0]*", "out[1]*", "out[2]*", "out[3]*", "in_rdy*", "out_rdy" )

def mk_test_vector_table( nstages, inputs ):

  # Add initial invalid outputs to the list of output values

  outputs_val = [[0,x,x,x,x]]*nstages

  # Sort inputs and prepend valid bit to each list of inputs/outputs

  inputs_val  = []
  for input_ in inputs:
    inputs_val.append( [1] + input_ )
    outputs_val.append( [1] + deepcopy( sorted(input_) ) )

  # Add final invalid inputs to the list of input values

  inputs_val.extend( [[0,0,0,0,0]]*nstages )

  # Put inputs_val and outputs_val together to make test_vector_table

  test_vector_table = [ header_str ]
  for input_,output in zip( inputs_val, outputs_val ):
    test_vector_table.append( input_ + output + [x] + [1])

  return test_vector_table

#-------------------------------------------------------------------------
# test_basic
#-------------------------------------------------------------------------

def test_basic( cmdline_opts ):
  run_test_vector_sim( SortUnitStructRTL(), [ header_str,
    # in  in  in  in  in  out out out out out in  out
    # val [0] [1] [2] [3] val [0] [1] [2] [3] rdy rdy
    [ 0,  0,  0,  0,  0,  0,  x,  x,  x,  x,  x,  1,  ],
    [ 1,  4,  2,  3,  1,  0,  x,  x,  x,  x,  x,  1,  ],
    [ 0,  0,  0,  0,  0,  0,  x,  x,  x,  x,  x,  1,  ],
    [ 0,  0,  0,  0,  0,  0,  x,  x,  x,  x,  x,  1,  ],
    [ 0,  0,  0,  0,  0,  1,  1,  2,  3,  4,  x,  1,  ],
    [ 0,  0,  0,  0,  0,  0,  x,  x,  x,  x,  x,  1,  ],
  ], cmdline_opts )

#-------------------------------------------------------------------------
# test_stream
#-------------------------------------------------------------------------

def test_stream( cmdline_opts ):
  run_test_vector_sim( SortUnitStructRTL(), mk_test_vector_table( 3, tvec_stream ),
                       cmdline_opts )

#-------------------------------------------------------------------------
# test_dups
#-------------------------------------------------------------------------

def test_dups( cmdline_opts ):
  run_test_vector_sim( SortUnitStructRTL(), mk_test_vector_table( 3, tvec_dups ),
                       cmdline_opts )

#-------------------------------------------------------------------------
# test_sorted
#-------------------------------------------------------------------------

def test_sorted( cmdline_opts ):
  run_test_vector_sim( SortUnitStructRTL(), mk_test_vector_table( 3, tvec_sorted ),
                       cmdline_opts )

#-------------------------------------------------------------------------
# test_random
#-------------------------------------------------------------------------

@pytest.mark.parametrize( "nbits", [ 4, 8, 16, 32 ] )
def test_random( nbits, cmdline_opts ):
  tvec_random = [ [ randint(0,2**nbits-1) for _ in range(4) ] for _ in range(20) ]
  run_test_vector_sim( SortUnitStructRTL(nbits),
    mk_test_vector_table( 3, tvec_random ), cmdline_opts )
