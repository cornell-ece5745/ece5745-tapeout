#=========================================================================
# NullXcelRTL_test
#=========================================================================

import pytest
import random
import struct

random.seed(0xdeadbeef)

from pymtl3 import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib import stream

from proc.XcelMsg     import *
from proc.NullXcelRTL import NullXcelRTL

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness(Component):

  def construct( s ):

    # Instantiate models

    s.src  = stream.SourceRTL( XcelMsgs.req )
    s.xcel = NullXcelRTL()
    s.sink = stream.SinkRTL( XcelMsgs.resp )

    s.xcel.mem.req.rdy  //= 0
    s.xcel.mem.resp.val //= 0

    s.src.send  //= s.xcel.xcel.req
    s.sink.recv //= s.xcel.xcel.resp

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace()  + " > " + \
           s.xcel.line_trace() + " > " + \
           s.sink.line_trace()

#-------------------------------------------------------------------------
# make messages
#-------------------------------------------------------------------------

def req( type_, raddr, data ):
  return XcelReqMsg(XCEL_TYPE_READ if type_ == 'rd' else XCEL_TYPE_WRITE, raddr, data)

def resp( type_, data ):
  return XcelRespMsg(XCEL_TYPE_READ if type_ == 'rd' else XCEL_TYPE_WRITE, data)

#-------------------------------------------------------------------------
# Test Case: basic
#-------------------------------------------------------------------------

basic_msgs = [
  req( 'wr', 0, 0xa  ), resp( 'wr', 0x0 ),
  req( 'rd', 0, 0x0  ), resp( 'rd', 0xa ),
]

#-------------------------------------------------------------------------
# Test Case: stream
#-------------------------------------------------------------------------

stream_msgs = [
  req( 'wr', 0, 0xa  ), resp( 'wr', 0x0 ),
  req( 'wr', 0, 0xb  ), resp( 'wr', 0x0 ),
  req( 'rd', 0, 0x0  ), resp( 'rd', 0xb ),
  req( 'wr', 0, 0xc  ), resp( 'wr', 0x0 ),
  req( 'wr', 0, 0xd  ), resp( 'wr', 0x0 ),
  req( 'rd', 0, 0x0  ), resp( 'rd', 0xd ),
]

#-------------------------------------------------------------------------
# Test Case: random
#-------------------------------------------------------------------------

random.seed(0xdeadbeef)
random_msgs = []
for i in range(20):
  data = random.randint(0,0xffffffff)
  random_msgs.extend([ req( 'wr', 0, data ), resp( 'wr', 0,   ) ])
  random_msgs.extend([ req( 'rd', 0, 0    ), resp( 'rd', data ) ])

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
  (              "msgs         src_delay sink_delay"),
  [ "basic_0x0",  basic_msgs,  0,        0,   ],
  [ "stream_0x0", stream_msgs, 0,        0,   ],
  [ "random_0x0", random_msgs, 0,        0,   ],
  [ "random_5x0", random_msgs, 5,        0,   ],
  [ "random_0x5", random_msgs, 0,        5,   ],
  [ "random_3x9", random_msgs, 3,        9,   ],
])

#-------------------------------------------------------------------------
# Test cases
#-------------------------------------------------------------------------

@pytest.mark.parametrize( **test_case_table )
def test( cmdline_opts, test_params ):
  th = TestHarness()

  th.set_param("top.src.construct",
    msgs=test_params.msgs[::2],
    initial_delay=test_params.src_delay+3,
    interval_delay=test_params.src_delay )

  th.set_param("top.sink.construct",
    msgs=test_params.msgs[1::2],
    initial_delay=test_params.sink_delay+3,
    interval_delay=test_params.sink_delay )

  run_sim( th, cmdline_opts, duts=['xcel'] )
