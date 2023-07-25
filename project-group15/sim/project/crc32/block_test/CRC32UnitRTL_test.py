#=========================================================================
# CRC32UnitRTL_test
#=========================================================================

import pytest
import random
import binascii

from pymtl3  import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib import stream

from project.crc32.CRC32UnitRTL import CRC32UnitRTL
from project.crc32.CRC32UnitMsg import CRC32UnitMsgs

# To ensure reproducible testing

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, crc ):

    # Instantiate models

    s.src  = stream.SourceRTL( CRC32UnitMsgs.req )
    s.sink = stream.SinkRTL( CRC32UnitMsgs.resp )
    s.crc = crc

    # Connect

    s.src.send //= s.crc.recv
    s.crc.send //= s.sink.recv

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " +  s.crc.line_trace() + " > " + s.sink.line_trace()

# Helpers to convert the inputs to the request messages
def req(msg):
  return CRC32UnitMsgs.req(msg)

def resp(msg):
  return CRC32UnitMsgs.resp(msg)

  
# Function to generate the CRC32 reference using python library
def crc32_ref(hex_nums):
  res = bytearray()
  for hex_num in hex_nums:
    res.append(hex_num)
  return binascii.crc32(res)

# Function to generate CRC32 reference
# def crc32_ref(arr):
#   crc = 0xFFFFFFFF
#   for i in range(len(arr)):
#     byte = arr[i]
#     for j in range(8):
#       b = (byte ^ crc) & 1
#       crc >>= 1
#       if b:
#         crc = crc ^ 0xEDB88320
#       byte >>= 1
  
#   return (~crc) & 0xFFFFFFFF

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

req_msgs_01 = [req(1), req(0x61)]
resp_msgs_01 = [resp(crc32_ref([0x61]))]

def mk_msgs(values):
  req_msgs = [req(len(values))]
  resp_msgs = [resp(crc32_ref(values))]
  for value in values:
    req_msgs.append(req(value))
  return req_msgs, resp_msgs

req_msgs_small, resp_msgs_small = mk_msgs(range(0x1, 0x10))
req_msgs_large, resp_msgs_large = mk_msgs(range(0x0f, 0x7f))
req_msgs_long, resp_msgs_long = mk_msgs(range(0x1, 0x7f))
req_msgs_rand, resp_msgs_rand = mk_msgs(random.sample(range(0x1,0x7f), 0x2f))
test_case_table = mk_test_case_table([
  (                   "req_msgs             resp_msgs            src_delay sink_delay"),
  [ "test_01_0x0",     req_msgs_01,         resp_msgs_01,        0,        0,         ], 
  [ "test_01_0x5",     req_msgs_01,         resp_msgs_01,        0,        5,         ], 
  [ "test_01_5x5",     req_msgs_01,         resp_msgs_01,        5,        5,         ],
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

  th = TestHarness(CRC32UnitRTL())

  th.set_param( "top.src.construct",
    msgs=test_params.req_msgs,
    initial_delay=test_params.src_delay,
    interval_delay=test_params.src_delay )

  th.set_param( "top.sink.construct",
    msgs=test_params.resp_msgs,
    initial_delay=test_params.src_delay,
    interval_delay=test_params.src_delay )

  run_sim( th, cmdline_opts, duts=['crc'] )