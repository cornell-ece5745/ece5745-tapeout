#=========================================================================
# 
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.test_utils import run_test_vector_sim, mk_test_case_table, run_sim
from systolic_accelerator.memory_engine.MemoryEngineRTL import MemoryEngineRTL
from systolic_accelerator.memory_engine.MemoryEngineMsgs    import MEMsgs
#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s ):

    # instantiate models

    s.src  = stream.SourceRTL( MEMsgs.recv )
    s.sink = stream.SinkRTL( MEMsgs.send ) 
    s.dut = MemoryEngineRTL()

    # connect
    s.src.send //= s.dut.recv
    s.dut.send //= s.sink.recv

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.dut.line_trace()

#-------------------------------------------------------------------------
# make messages
#-------------------------------------------------------------------------

def recv( data0, mode, run ):
  return MEMsgs.recv( data0, mode, run )

def send( r0 ):
  return MEMsgs.send( r0 )

#----------------------------------------------------------------------
# Test Case: initial_test 
#----------------------------------------------------------------------
FRAC_WIDTH = 8
multiple = 2**FRAC_WIDTH
data = [1, 2]
fix_data = []
fix_data.append(int(hex(int(data[0] * (multiple))), 16))
fix_data.append(int(hex(int(data[1] * (multiple))), 16))
initial_test_recv_msgs = [
  recv( fix_data[0], 0x0, 0x0), 
  recv( fix_data[1], 0x0, 0x0), 
  recv( fix_data[0], 0x1, 0x1), 
]

initial_test_send_msgs = [
  send(fix_data[0]),
  send(fix_data[1]),
]

def test_01( cmdline_opts ):

  th = TestHarness()

  th.set_param( "top.src.construct",  msgs=initial_test_recv_msgs )
  th.set_param( "top.sink.construct", msgs=initial_test_send_msgs )

  run_sim( th, cmdline_opts, duts=['dut'] )