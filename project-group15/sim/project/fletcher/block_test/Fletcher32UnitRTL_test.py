#=========================================================================
# Fletcher32UnitRTL_test
#=========================================================================

import pytest
import random
import binascii

from pymtl3  import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib import stream

from project.fletcher.Fletcher32UnitRTL import Fletcher32UnitRTL
from project.fletcher.Fletcher32UnitMsg import Fletcher32UnitMsgs

# To ensure reproducible testing

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, fletcher ):

    # Instantiate models

    s.src  = stream.SourceRTL( Fletcher32UnitMsgs.req )
    s.sink = stream.SinkRTL( Fletcher32UnitMsgs.resp )
    s.fletcher = fletcher

    # Connect

    s.src.send //= s.fletcher.recv
    s.fletcher.send //= s.sink.recv

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " +  s.fletcher.line_trace() + " > " + s.sink.line_trace()

# Function to generate Fletcher32 reference
def fletcher32_ref(arr):
  sum1 = 0
  sum2 = 0
  for i in range(8):
    sum1 = ( sum1 + arr[i] ) % 65536
    sum2 = ( sum1 + sum2 ) % 65536
  return ( ( sum2 << 16 ) | sum1 )


#-------------------------------------------------------------------------
# test_01
#-------------------------------------------------------------------------
# If we send in 'a' (0x61), then dut should output 3904355907
def test_01( cmdline_opts ):
  inputs = [0, 0, 0, 0, 0, 0, 0, 0]
  req_msgs = []
  for input in inputs:
    req_msgs.append(b16(input))
  resp_msgs = [b32(fletcher32_ref(inputs))]

  th = TestHarness( Fletcher32UnitRTL() )
  th.set_param( "top.src.construct",  msgs=req_msgs )
  th.set_param( "top.sink.construct", msgs=resp_msgs )
  run_sim( th, cmdline_opts, duts=['fletcher'] )

#-------------------------------------------------------------------------
# test_02
#-------------------------------------------------------------------------
# If we send in ab, two then dut should produce three

def test_02( cmdline_opts ):

  inputs = [1, 1, 1, 1, 1, 1, 1, 1]
  req_msgs = []
  for input in inputs:
    req_msgs.append(b16(input))
  resp_msgs = [b32(fletcher32_ref(inputs))]

  th = TestHarness( Fletcher32UnitRTL() )
  th.set_param( "top.src.construct",  msgs=req_msgs )
  th.set_param( "top.sink.construct", msgs=resp_msgs )
  run_sim( th, cmdline_opts, duts=['fletcher'] )
    
#-------------------------------------------------------------------------
# Test Case: long
#-------------------------------------------------------------------------
def test_long( cmdline_opts ):
  inputs = [121, 113, 44, 14, 13, 96, 107, 89]
  req_msgs = []
  for input in inputs:
    req_msgs.append(b16(input))
  resp_msgs = [b32(fletcher32_ref(inputs))]

  th = TestHarness( Fletcher32UnitRTL() )
  th.set_param( "top.src.construct",  msgs=req_msgs )
  th.set_param( "top.sink.construct", msgs=resp_msgs )
  run_sim( th, cmdline_opts, duts=['fletcher'] )

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

small_pos_req = [
  [0x0003,0x0002,0x0001,0x0000,0x0003,0x0002,0x0001,0x0000],
  [0x0000,0x0001,0x0002,0x0003,0x0000,0x0001,0x0002,0x0003],
  [0x000a,0x000b,0x000c,0x000d,0x000a,0x000b,0x000c,0x000d],
  [0x000d,0x000c,0x000b,0x000a,0x000d,0x000c,0x000b,0x000a], ]

small_pos_resp = [
  [ b32(fletcher32_ref(small_pos_req[0])) ],
  [ b32(fletcher32_ref(small_pos_req[1])) ],
  [ b32(fletcher32_ref(small_pos_req[2])) ],
  [ b32(fletcher32_ref(small_pos_req[3])) ], ]
  
large_pos_req = [
  [0x7ffc,0x7ffd,0x7ffe,0x7fff,0x7ffc,0x7ffd,0x7ffe,0x7fff],
  [0x7fff,0x7ffe,0x7ffd,0x7ffc,0x7fff,0x7ffe,0x7ffd,0x7ffc],
  [0x7ff6,0x7ff7,0x7ff8,0x7ff9,0x7ff6,0x7ff7,0x7ff8,0x7ff9],
  [0x7ff9,0x7ff8,0x7ff7,0x7ff6,0x7ff9,0x7ff8,0x7ff7,0x7ff6], ]

large_pos_resp = [
  [ b32(fletcher32_ref(large_pos_req[0])) ],
  [ b32(fletcher32_ref(large_pos_req[1])) ],
  [ b32(fletcher32_ref(large_pos_req[2])) ],
  [ b32(fletcher32_ref(large_pos_req[3])) ], ]
def mk_msgs(range1, range2):
  req_msgs = []
  resp_msgs = []
  for i in range(8):
    req_msgs.append( random.randint(range1,range2) )
  resp_msgs.append( b32(fletcher32_ref(req_msgs)) )
  return req_msgs, resp_msgs

req_msgs_small, resp_msgs_small = mk_msgs(0x1, 0x8)
req_msgs_large, resp_msgs_large = mk_msgs(0x0f, 0x7f)
req_msgs_long, resp_msgs_long = mk_msgs(0x1, 0x7f)
req_msgs_rand, resp_msgs_rand = mk_msgs(0x1,0x7f)

test_case_table = mk_test_case_table([
  (                   "req_msgs             resp_msgs            src_delay sink_delay"),
  [ "small_pos_0",     small_pos_req[0],    small_pos_resp[0],   0,        0,         ], 
  [ "small_pos_1",     small_pos_req[1],    small_pos_resp[1],   0,        0,         ], 
  [ "small_pos_2",     small_pos_req[2],    small_pos_resp[2],   0,        0,         ],
  [ "small_pos_3",     small_pos_req[3],    small_pos_resp[3],   0,        0,         ],
  [ "large_pos_0",     large_pos_req[0],    large_pos_resp[0],   0,        0,         ], 
  [ "large_pos_0",     large_pos_req[1],    large_pos_resp[1],   0,        0,         ], 
  [ "large_pos_0",     large_pos_req[2],    large_pos_resp[2],   0,        0,         ],
  [ "large_pos_0",     large_pos_req[3],    large_pos_resp[3],   0,        0,         ],
  [ "small_0x0",       req_msgs_small,      resp_msgs_small,     0,        0,         ],
  [ "small_0x5",       req_msgs_small,      resp_msgs_small,     0,        5,         ],
  [ "small_5x5",       req_msgs_small,      resp_msgs_small,     5,        5,         ],
  [ "large_0x0",       req_msgs_large,      resp_msgs_large,     0,        0,         ],
  [ "large_0x5",       req_msgs_large,      resp_msgs_large,     0,        5,         ],
  [ "large_5x5",       req_msgs_large,      resp_msgs_large,     5,        5,         ],
  [ "long_0x0",        req_msgs_long,       resp_msgs_long,      0,        0,         ],
  [ "long_0x5",        req_msgs_long,       resp_msgs_long,      0,        5,         ],
  [ "long_5x5",        req_msgs_long,       resp_msgs_long,      5,        5,         ],
  [ "rand_0x0",        req_msgs_rand,       resp_msgs_rand,      0,        0,         ],
  [ "rand_0x5",        req_msgs_rand,       resp_msgs_rand,      0,        5,         ],
  [ "rand_5x5",        req_msgs_rand,       resp_msgs_rand,      5,        5,         ],
])

#-------------------------------------------------------------------------
# Test cases
#-------------------------------------------------------------------------

@pytest.mark.parametrize( **test_case_table )
def test_case( test_params, cmdline_opts ):

  th = TestHarness(Fletcher32UnitRTL())

  th.set_param( "top.src.construct",
    msgs=test_params.req_msgs,
    initial_delay=test_params.src_delay,
    interval_delay=test_params.src_delay )

  th.set_param( "top.sink.construct",
    msgs=test_params.resp_msgs,
    initial_delay=test_params.src_delay,
    interval_delay=test_params.src_delay )

  run_sim( th, cmdline_opts, duts=['fletcher'] )
