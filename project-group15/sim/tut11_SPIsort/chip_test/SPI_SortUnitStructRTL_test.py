#=========================================================================
# SortUnitStructRTL_SPI_test
#=========================================================================

import pytest

from copy   import deepcopy
from random import randint

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim

from ..block_test.SortUnitFL_test import header_str, mk_test_vector_table, x, \
                             tvec_stream, tvec_dups, tvec_sorted, tvec_random

from ..SPI_SortUnitStructRTL import SPI_SortUnitStructRTL
from .SPITestHarness import SPITestHarness

def mk_test_vector_table(nbits, inputs):

  # Add initial invalid outputs to the list of output values

  outputs_val = []

  # Sort inputs and prepend valid bit to each list of inputs/outputs

  inputs_val  = []
  for input_ in inputs:
    inputs_val.append( input_ )
    outputs_val.append( deepcopy( sorted(input_) ) )

  req_list = []
  resp_list= []

  for input_,output in zip( inputs_val, outputs_val ):
    req= mk_input_msg(nbits, input_[0], input_[1], input_[2],  input_[3])
    req = concat(req.in0, req.in1, req.in2, req.in3 )
    resp= mk_output_msg(nbits, output[0], output[1], output[2], output[3])
    resp= concat(resp.out0, resp.out1, resp.out2, resp.out3)
    req_list.append(req)
    resp_list.append(resp)

  return (req_list, resp_list)

def mk_input_msg(nbits,a,b,c,d):
  @bitstruct
  class InputMsg:
    in0: mk_bits(nbits)
    in1: mk_bits(nbits) 
    in2: mk_bits(nbits)
    in3: mk_bits(nbits)
  return InputMsg(a,b,c,d)

def mk_output_msg(nbits,a,b,c,d):
  @bitstruct
  class OutputMsg:
    out0: mk_bits(nbits)
    out1: mk_bits(nbits) 
    out2: mk_bits(nbits)
    out3: mk_bits(nbits)
  return OutputMsg(a,b,c,d)

#-------------------------------------------------------------------------
# test_basic
#-------------------------------------------------------------------------

@pytest.mark.parametrize( "nbits", [ 4, 8, 16, 32 ] )
def test_basic( nbits, cmdline_opts ):
  harness= SPITestHarness(SPI_SortUnitStructRTL(nbits), 0, nbits*4 + 2, cmdline_opts)

  inputs=[]
  input_ = mk_input_msg(nbits,4,3,2,1)
  input_ = concat(input_.in0, input_.in1, input_.in2, input_.in3 )
  inputs.append(input_)

  outputs=[]
  output = mk_output_msg(nbits,1,2,3,4)
  output = concat(output.out0, output.out1, output.out2, output.out3)
  outputs.append(output)

  harness.t_mult_msg(nbits*4, nbits*4, inputs, outputs)
  # run_test_vector_sim( SortUnitStructRTL(), [ header_str,
  #   # in  in  in  in  in  out out out out out
  #   # val [0] [1] [2] [3] val [0] [1] [2] [3]
  #   [ 0,  0,  0,  0,  0,  0,  x,  x,  x,  x ],
  #   [ 1,  4,  2,  3,  1,  0,  x,  x,  x,  x ],
  #   [ 0,  0,  0,  0,  0,  0,  x,  x,  x,  x ],
  #   [ 0,  0,  0,  0,  0,  0,  x,  x,  x,  x ],
  #   [ 0,  0,  0,  0,  0,  1,  1,  2,  3,  4 ],
  #   [ 0,  0,  0,  0,  0,  0,  x,  x,  x,  x ],
  # ], cmdline_opts )

#-------------------------------------------------------------------------
# test_stream
#-------------------------------------------------------------------------
@pytest.mark.parametrize( "nbits", [ 4, 8, 16, 32 ] )
def test_stream( nbits, cmdline_opts ):
  harness= SPITestHarness(SPI_SortUnitStructRTL(nbits), 0, nbits*4 + 2, cmdline_opts) 
  table= mk_test_vector_table( nbits, tvec_stream )
  harness.t_mult_msg(nbits*4,nbits*4,table[0], table[1])
  

#-------------------------------------------------------------------------
# test_dups
#-------------------------------------------------------------------------
@pytest.mark.parametrize( "nbits", [ 4, 8, 16, 32 ] )
def test_dups( nbits, cmdline_opts ):
  harness= SPITestHarness(SPI_SortUnitStructRTL(nbits), 0, nbits*4 + 2, cmdline_opts) 
  table= mk_test_vector_table( nbits, tvec_dups )
  harness.t_mult_msg(nbits*4,nbits*4,table[0], table[1])

#-------------------------------------------------------------------------
# test_sorted
#-------------------------------------------------------------------------
@pytest.mark.parametrize( "nbits", [ 4, 8, 16, 32 ] )
def test_sorted( nbits, cmdline_opts ):
  harness= SPITestHarness(SPI_SortUnitStructRTL(nbits), 0, nbits*4 + 2, cmdline_opts) 
  table= mk_test_vector_table( nbits, tvec_sorted )
  harness.t_mult_msg(nbits*4,nbits*4,table[0], table[1])


#-------------------------------------------------------------------------
# test_random
#-------------------------------------------------------------------------

@pytest.mark.parametrize( "nbits", [ 4, 8, 16, 32 ] )
def test_random( nbits, cmdline_opts ):
  harness= SPITestHarness(SPI_SortUnitStructRTL(nbits), 0, nbits*4 + 2, cmdline_opts) 
  tvec_random = [ [ randint(0,2**nbits-1) for _ in range(4) ] for _ in range(20) ]
  table= mk_test_vector_table( nbits, tvec_random )
  harness.t_mult_msg(nbits*4,nbits*4,table[0], table[1])

