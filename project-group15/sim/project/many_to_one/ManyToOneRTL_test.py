#=========================================================================
# OneToManyRTL_test
#=========================================================================

import pytest
import random

from pymtl3 import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib import stream

from ManyToOneRTL import ManyToOneRTL

# To ensure reproducible testing

random.seed(0xdeadbeef)


#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s ):

    # Instantiate models

    s.src  = stream.SourceRTL ( Bits8 )
    s.sink = stream.SinkRTL   ( Bits32 )
    s.dut  = ManyToOneRTL()

    # Connect

    s.src.send //= s.dut.recv
    s.dut.send //= s.sink.recv

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " + s.dut.line_trace() + " > " + s.sink.line_trace()

#-------------------------------------------------------------------------
# test_00
#-------------------------------------------------------------------------
# If we send in a -one then dut should produce nothing

def test_00( cmdline_opts ):

  th = TestHarness()

  th.set_param( "top.src.construct",  msgs=[Bits8(-1)] )
  th.set_param( "top.sink.construct", msgs=[b32(0)] )

  run_sim( th, cmdline_opts, duts=['dut'] )

#-------------------------------------------------------------------------
# test_01
#-------------------------------------------------------------------------
# If we send in a one then dut should produce one

def test_01( cmdline_opts ):

  th = TestHarness()

  th.set_param( "top.src.construct",  msgs=[Bits8(1), Bits8(-1)] )
  th.set_param( "top.sink.construct", msgs=[Bits32(1)] )

  run_sim( th, cmdline_opts, duts=['dut'] )

#-------------------------------------------------------------------------
# test_02
#-------------------------------------------------------------------------
# If we send in a one, two then dut should produce three

def test_02( cmdline_opts ):

  th = TestHarness()

  th.set_param( "top.src.construct",  msgs=[Bits8(1), b8(2), b8(-1)] )
  th.set_param( "top.sink.construct", msgs=[b32(3)] )

  run_sim( th, cmdline_opts, duts=['dut'] )

#-------------------------------------------------------------------------
# test_multiple
#-------------------------------------------------------------------------
# Send in multiple transactions

def test_multiple( cmdline_opts ):

  th = TestHarness()

  req_msgs  = [ Bits8(3), b8(-1), Bits8(2), Bits8(1), Bits8(-1) ]
  resp_msgs = [ b32(3), b32(3)]

  th.set_param( "top.src.construct",  msgs=req_msgs  )
  th.set_param( "top.sink.construct", msgs=resp_msgs )

  run_sim( th, cmdline_opts, duts=['dut'] )

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

req_msgs_3_2_1      = [ Bits8(1), Bits8(2), Bits8(3), b8(-1) ]
resp_msgs_3_2_1     = [ Bits32(6) ]

def mk_msgs( values ):
  # Randomly insert -1s inbetween values in the input array. Then calculate the resp messages based on that
  req_msgs  = []
  resp_msgs = []
  
  num_1s = random.randint(1,3)
  loc_1s = []

  for _ in range(num_1s):
    loc_1 = random.randint(0, len(values)-1)
    loc_1s.append(loc_1)

  resp = 0
  for i, y in enumerate(values):
    if i in loc_1s:
      resp_msgs.append(b32(resp))
      req_msgs.append(b8(-1))
      resp = 0
    else:
      resp += y
      req_msgs.append(b8(y))
  req_msgs.append(b8(-1))
  resp_msgs.append(b32(resp))

  return req_msgs,resp_msgs

req_msgs_seq, resp_msgs_seq = mk_msgs( range(1,10))
req_msgs_large,resp_msgs_large = mk_msgs( range(1,100) )
req_msgs_rand,resp_msgs_rand   = mk_msgs( random.sample(range(0,0x7f),20) )

test_case_table = mk_test_case_table([
  (                   "req_msgs             resp_msgs            src_delay sink_delay"),
  [ "basic_3_0x0",     req_msgs_3_2_1,      resp_msgs_3_2_1,     0,        0,         ], 
  [ "seq_0x0",         req_msgs_seq,        resp_msgs_seq,       0,        0,         ],
  [ "large_0x0",       req_msgs_large,      resp_msgs_large,     0,        0,         ],
  [ "large_5x0",       req_msgs_large,      resp_msgs_large,     5,        0,         ],
  [ "large_0x5",       req_msgs_large,      resp_msgs_large,     0,        5,         ],
  [ "large_3x9",       req_msgs_large,      resp_msgs_large,     3,        9,         ],
  [ "rand_0x0",        req_msgs_rand,       resp_msgs_rand,      0,        0,         ],
  [ "rand_5x0",        req_msgs_rand,       resp_msgs_rand,      5,        0,         ],
  [ "rand_0x5",        req_msgs_rand,       resp_msgs_rand,      0,        5,         ],
  [ "rand_3x9",        req_msgs_rand,       resp_msgs_rand,      3,        9,         ],
])

#-------------------------------------------------------------------------
# Test cases
#-------------------------------------------------------------------------

@pytest.mark.parametrize( **test_case_table )
def test_case( test_params, cmdline_opts ):

  th = TestHarness()

  th.set_param( "top.src.construct",
    msgs=test_params.req_msgs,
    initial_delay=test_params.src_delay,
    interval_delay=test_params.src_delay )

  th.set_param( "top.sink.construct",
    msgs=test_params.resp_msgs,
    initial_delay=test_params.src_delay,
    interval_delay=test_params.src_delay )

  run_sim( th, cmdline_opts, duts=['dut'] )