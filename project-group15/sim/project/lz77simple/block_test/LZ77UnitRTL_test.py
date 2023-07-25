#=========================================================================
# LZ77UnitRTL_test
#=========================================================================

import pytest
import random
import binascii

from pymtl3  import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib import stream

from project.lz77simple.LZ77UnitRTL import LZ77UnitRTL
from project.lz77simple.LZ77UnitMsg import LZ77UnitMsgs

# To ensure reproducible testing

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, lz77 ):

    # Instantiate models

    s.src  = stream.SourceRTL( LZ77UnitMsgs.req )
    s.sink = stream.SinkRTL( LZ77UnitMsgs.resp )
    s.lz77 = lz77

    # Connect

    s.src.send //= s.lz77.recv
    s.lz77.send //= s.sink.recv

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " +  s.lz77.line_trace() + " > " + s.sink.line_trace()

# Helpers to convert the inputs to the request messages
def req(msg):
  return LZ77UnitMsgs.req(msg)

def resp(msg):
  return LZ77UnitMsgs.resp(msg)

    
#-------------------------------------------------------------------------
# Test Case: long
#-------------------------------------------------------------------------
# def test_long( cmdline_opts ):
#   inputs = [3, 2, 3, 3, 2, 3, 3, 2, 1, 3, 2, 0, 2, 2, 3, 1, 1, 2, 3, 2, 1, 
#             0, 3, 1, 1, 1, 3, 0, 3, 3, 1, 0, 2, 2, 1, 0, 0, 3, 0, 2, 1, 3, 
#             1, 3, 1, 2, 3, 0, 0, 3, 2, 1, 3, 3, 3, 1, 2, 3, 2, 2, 0, 1, 3, 
#             3, 2, 1, 2, 1, 0, 2, 0, 0, 1, 1, 2, 0, 1, 0, 0, 3, 1, 3, 1, 3, 
#             0, 1, 3, 3, 0, 2, 2, 2, 1, 2, 3, 0, 3, 0, 3, 1, 0, 0, 2, 2, 0, 
#             1, 2, 1, 2, 1, 0, 1, 3, 3, 1, 1, 0, 1, 0, 0, 2, 3, 2, 2, 2, 0, 
#             0, 2, 2, 3, 1, 2, 2, 2, 3, 2, 2, 2, 2, 0, 0, 0, 0, 3, 2, 2, 3, 
#             2, 3, 0, 2, 0, 1, 1, 0, 0, 1, 0, 2, 2, 2, 2, 0, 0, 3, 2, 1, 2, 
#             0, 2, 1, 1, 1, 0, 0, 2, 1, 1, 1, 0, 3, 3, 0, 2, 1, 0, 1, 3, 0, 
#             0, 2, 0, 1, 3, 3, 1, 3, 2, 0, 2]
#   ref = [0, 0, 3, 0, 0, 2, 0, 0, 3, 3, 3, 3, 0, 0, 3, 0, 0, 2, 
#             0, 0, 1, 0, 0, 3, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 2, 
#             0, 0, 3, 0, 0, 1, 0, 0, 1, 0, 0, 2, 0, 0, 3, 0, 0, 2, 
#             0, 0, 1, 0, 0, 0, 8, 3, 1, 0, 0, 1, 0, 0, 3, 0, 0, 0, 
#             0, 0, 3, 0, 0, 3, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 2, 
#             0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 2, 
#             0, 0, 1, 0, 0, 3, 0, 0, 1, 0, 0, 3, 0, 0, 1, 0, 0, 2, 
#             0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 2, 0, 0, 1, 
#             0, 0, 3, 0, 0, 3, 0, 0, 3, 0, 0, 1, 0, 0, 2, 0, 0, 3, 
#             0, 0, 2, 0, 0, 2, 0, 0, 0, 10, 3, 2, 0, 0, 2, 0, 0, 1, 
#             0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 
#             0, 0, 1, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 
#             0, 0, 0, 0, 0, 3, 0, 0, 1, 0, 0, 3, 0, 0, 1, 0, 0, 3, 
#             0, 0, 0, 0, 0, 1, 0, 0, 3, 0, 0, 3, 0, 0, 0, 0, 0, 2, 
#             0, 0, 2, 0, 0, 2, 0, 0, 1, 0, 0, 2, 0, 0, 3, 0, 0, 0, 
#             0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0, 1, 0, 0, 0, 0, 0, 0, 
#             0, 0, 2, 0, 0, 2, 0, 0, 0, 0, 0, 1, 0, 0, 2, 0, 0, 1, 
#             0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 3, 0, 0, 3, 
#             0, 0, 1, 6, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 
#             0, 0, 2, 0, 0, 2, 0, 0, 2, 7, 3, 2, 0, 0, 2, 0, 0, 3, 
#             0, 0, 1, 9, 3, 3, 0, 0, 3, 4, 3, 2, 0, 0, 2, 0, 0, 0, 
#             0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 3, 3, 0, 0, 3, 0, 0, 2, 
#             0, 0, 3, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 1, 0, 0, 1, 
#             0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 2, 
#             0, 0, 2, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 2, 
#             0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 1, 
#             0, 0, 1, 0, 0, 0, 6, 6, 3, 0, 0, 3, 0, 0, 3, 8, 3, 0, 
#             0, 0, 0, 0, 0, 1, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 2, 
#             6, 3, 3, 0, 0, 3, 0, 0, 1, 0, 0, 3, 0, 0, 2, 0, 0, 0, 
#             0, 0, 2]
#   req_msgs = [req(len(inputs))]
#   for input in inputs:
#     req_msgs.append(req(input))
#   resp_msgs = []
#   for r in ref:
#     resp_msgs.append(resp(r))

#   th = TestHarness( LZ77UnitRTL() )
#   th.set_param( "top.src.construct",  msgs=req_msgs )
#   th.set_param( "top.sink.construct", msgs=resp_msgs )
#   run_sim( th, cmdline_opts, duts=['lz77'] )

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

#req_msgs_01 = [req(1), req(0x61)]
#resp_msgs_01 = [resp(lz77_ref([0x61]))]

#def mk_msgs(values):
#  req_msgs = [req(len(values))]
#  resp_msgs = [resp(lz77_ref(values))]
#  for value in values:
#    req_msgs.append(req(value))
#  return req_msgs, resp_msgs

#req_msgs_small, resp_msgs_small = mk_msgs(range(0x1, 0x10))
#req_msgs_large, resp_msgs_large = mk_msgs(range(0x0f, 0x7f))
#req_msgs_long, resp_msgs_long = mk_msgs(range(0x1, 0x7f))
#req_msgs_rand, resp_msgs_rand = mk_msgs(random.sample(range(0x1,0x7f), 0x2f))
#test_case_table = mk_test_case_table([
#  (                   "req_msgs             resp_msgs            src_delay sink_delay"),
#  [ "long_0x0",        req_msgs_long,       resp_msgs_long,      0,        0,         ],
#  [ "long_0x5",        req_msgs_long,       resp_msgs_long,      0,        5,         ],
#  [ "long_5x5",        req_msgs_long,       resp_msgs_long,      5,        5,         ],
#  [ "rand_0x0",        req_msgs_rand,       resp_msgs_rand,      0,        0,         ],
#  [ "rand_0x5",        req_msgs_rand,       resp_msgs_rand,      0,        5,         ],
#  [ "rand_5x5",        req_msgs_rand,       resp_msgs_rand,      5,        5,         ],
#])

#-------------------------------------------------------------------------
# Test cases
#-------------------------------------------------------------------------

#@pytest.mark.parametrize( **test_case_table )
#def test_case( test_params, cmdline_opts ):

#  th = TestHarness(LZ77UnitRTL())

#  th.set_param( "top.src.construct",
#    msgs=test_params.req_msgs,
#    initial_delay=test_params.src_delay,
#    interval_delay=test_params.src_delay )

#  th.set_param( "top.sink.construct",
#    msgs=test_params.resp_msgs,
#    initial_delay=test_params.src_delay,
#    interval_delay=test_params.src_delay )

#  run_sim( th, cmdline_opts, duts=['lz77simple'] )
