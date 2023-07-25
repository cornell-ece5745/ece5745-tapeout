#=========================================================================
# ReaderUnitRTL_test
#=========================================================================

import pytest
import random
import struct

from pymtl3  import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim

from pymtl3.stdlib import stream
from ..AutonomousReaderRTL  import ReaderUnitRTL
from ..ReaderUnitMsgs       import ReaderUnitMsgs

# To ensure reproducible testing

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, reader ):

    # Instantiate models

    s.src    = stream.SourceRTL( ReaderUnitMsgs.req )
    s.sink   = stream.SinkRTL  ( ReaderUnitMsgs.resp )
    s.mem    = stream.MagicMemoryRTL( 1 )
    s.reader = reader

    # Connect

    s.src.send    //= s.reader.recv
    s.reader.send //= s.sink.recv
    s.mem.ifc[0]  //= s.reader.mem

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " + s.reader.line_trace() + " > " + s.sink.line_trace()

one_element   = [0x21]
small_data    = [ random.randint(0,0xffff)     for i in range(32) ]
large_data    = [ random.randint(0,0x7fffffff) for i in range(32) ]
sort_fwd_data = sorted(small_data)
sort_rev_data = list(reversed(sorted(small_data)))
nonpow2_size  = [ random.randint(0,0xffff)     for i in range(35) ]
mini          = [ 0x21, 0x14, 0x42, 0x03 ]


#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
                         #                delays   test mem
                         #                -------- ---------
  (                      "data            src sink stall lat"),
  [ "one_element",        one_element,    0,  0,   0,    0   ],
  [ "one_element_delay",  one_element,    3, 14,   0.5,  2   ],
  [ "mini",               mini,           0,  0,   0,    0   ],
  [ "mini_delay_3x14x4",  mini,           3, 14,   0.5,  2   ],
  [ "mini_delay_5x7",     mini,           5,  7,   0.5,  4   ],
  [ "small_data",         small_data,     0,  0,   0,    0   ],
  [ "large_data",         large_data,     0,  0,   0,    0   ],
  [ "sort_fwd_data",      sort_fwd_data,  0,  0,   0,    0   ],
  [ "sort_rev_data",      sort_rev_data,  0,  0,   0,    0   ],
  [ "nonpow2_size",       nonpow2_size,   0,  0,   0,    0   ],
  [ "small_data_3x14x0",  small_data,     3, 14,   0,    0   ],
  [ "small_data_5x7x0",   small_data,     5,  7,   0,    0   ],
  [ "small_data_0x0x4",   small_data,     0,  0,   0.5,  4   ],
  [ "small_data_3x14x4",  small_data,     3,  14,  0.5,  4   ],
  [ "small_data_5x7x4",   small_data,     5,  7,   0.5,  4   ],
])

#-------------------------------------------------------------------------
# Test Case
#-------------------------------------------------------------------------

def run_test(reader, test_params, cmdline_opts=None):

  # Create test harness with messages for the src/sink

  th = TestHarness( reader )

  data = test_params.data
  data_bytes = struct.pack("<{}I".format(len(data)),*data)

  req  = ReaderUnitMsgs.req(0x1000,len(data))
  resp = []
  for i in data:
    if data.index(i) == len(data) - 1:
      resp.append(ReaderUnitMsgs.resp(i, 1))
    else:
      resp.append(ReaderUnitMsgs.resp(i, 0))

  # resp.append(ReaderUnitMsgs.resp(0,1))

  th.set_param( "top.src.construct", msgs=[req],
    initial_delay=2, interval_delay=2 )

  th.set_param( "top.sink.construct", msgs=resp,
    initial_delay=2, interval_delay=2 )

  # th.set_param( "top.mem.construct", stall_prob=0.5, extra_latency=3 )

  # Elaborate the model

  th.elaborate()

  # Load the data into the test memory

  th.mem.write_mem( 0x1000, data_bytes )

  # Run the test

  run_sim( th, cmdline_opts, duts=['reader'] )

@pytest.mark.parametrize( **test_case_table )

def test( test_params, cmdline_opts ):
  run_test( ReaderUnitRTL(), test_params, cmdline_opts )
