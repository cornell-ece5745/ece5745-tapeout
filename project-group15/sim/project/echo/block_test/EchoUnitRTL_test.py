#=========================================================================
# EchoUnitRTL_test
#=========================================================================

import pytest
import random

from pymtl3  import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib import stream

from project.echo.EchoUnitRTL import EchoUnitRTL
from project.echo.EchoUnitMsg import EchoUnitMsgs

# To ensure reproducible testing

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, echo ):

    # Instantiate models

    s.src  = stream.SourceRTL( EchoUnitMsgs.req )
    s.sink = stream.SinkRTL( EchoUnitMsgs.resp )
    s.echo = echo

    # Connect

    s.src.send //= s.echo.recv
    s.echo.send //= s.sink.recv

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " + s.echo.line_trace() + " > " + s.sink.line_trace()


#-------------------------------------------------------------------------
# Test Case: basic
#-------------------------------------------------------------------------

basic_cases = [
  ( 5     ,     5   ),
  ( -1    ,     -1  ),
  ( 0     ,     0  )
]

basic_msgs = []
for a, result in basic_cases:
  basic_msgs.extend( [EchoUnitMsgs.req(a), EchoUnitMsgs.resp( result )] )

#-------------------------------------------------------------------------
# Test Case: random
#-------------------------------------------------------------------------

random_cases = []
for i in range(30):
  a = random.randint(0,0x7ff)
  c = a
  random_cases.append( ( a, c ) )

random_msgs = []
for a, result in random_cases:
  random_msgs.extend( [EchoUnitMsgs.req(a), EchoUnitMsgs.resp( result )] )

#-------------------------------------------------------------------------
# Test Case: Edge cases
#-------------------------------------------------------------------------
edge_cases = [
  (0x7ff, 0x7ff),
  (-0x400, -0x400)
]

edge_msgs = []
for a, result in edge_cases:
  edge_msgs.extend([EchoUnitMsgs.req(a), EchoUnitMsgs.resp(result)])


#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
  (               "msgs        src_delay  sink_delay"),
  [ "basic_0x0",  basic_msgs,  0,         0,         ],
  [ "basic_5x0",  basic_msgs,  5,         0,         ],
  [ "basic_0x5",  basic_msgs,  0,         5,         ],
  [ "basic_3x9",  basic_msgs,  3,         9,         ],
  [ "random_3x9", random_msgs, 3,         9,         ],
  [ "edge_3x9",   edge_msgs,   3,         9,         ],
])

#-------------------------------------------------------------------------
# Test cases
#-------------------------------------------------------------------------

@pytest.mark.parametrize( **test_case_table )
def test_echo_rtl( test_params, cmdline_opts ):
  th = TestHarness( EchoUnitRTL() )

  th.set_param("top.src.construct",
    msgs=test_params.msgs[::2],
    initial_delay=test_params.src_delay,
    interval_delay=test_params.src_delay )

  th.set_param("top.sink.construct",
    msgs=test_params.msgs[1::2],
    initial_delay=test_params.sink_delay,
    interval_delay=test_params.sink_delay )

  run_sim( th, cmdline_opts, duts=['echo'] )
