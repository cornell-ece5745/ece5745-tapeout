'''
==========================================================================
LoopThrough_test.py
==========================================================================
Unit test for Loopback.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.LoopThroughRTL import LoopThroughRTL

# Helper function
def t( dut, recv_val, recv_rdy, send_val, send_rdy, recv_msg, send_msg):

  # Write input value to input port
  dut.upstream.req.msg        @= recv_msg
  dut.upstream.req.val        @= recv_val
  dut.upstream.resp.rdy       @= send_rdy

  dut.sim_eval_combinational()

  if recv_rdy != '?':
    assert dut.upstream.req.rdy == recv_rdy
  
  if send_msg != '?':
    assert dut.upstream.resp.msg == send_msg

  if send_val != '?':
    assert dut.upstream.resp.val == send_val

  # Tick simulator one cycle
  dut.sim_tick()

# Helper function
def t2( dut, up_req_val, up_req_rdy, up_req_msg, down_req_val, down_req_rdy, down_req_msg,
        down_resp_val, down_resp_rdy, down_resp_msg, up_resp_val, up_resp_rdy, up_resp_msg):

  # Write input value to input port
  dut.upstream.req.msg        @= up_req_msg
  dut.upstream.req.val        @= up_req_val
  dut.upstream.resp.rdy       @= up_resp_rdy
  dut.downstream.resp.msg     @= down_resp_msg 
  dut.downstream.resp.val     @= down_resp_val
  dut.downstream.req.rdy      @= down_req_rdy

  dut.sim_eval_combinational()

  if up_req_rdy != '?':
    assert dut.upstream.req.rdy == up_req_rdy
  
  if up_resp_msg != '?':
    assert dut.upstream.resp.msg == up_resp_msg

  if up_resp_val != '?':
    assert dut.upstream.resp.val == up_resp_val

  if down_resp_rdy != '?':
    assert dut.downstream.resp.rdy == down_resp_rdy
  
  if down_req_msg != '?':
    assert dut.downstream.req.msg == down_req_msg

  if down_req_val != '?':
    assert dut.downstream.req.val == down_req_val

  # Tick simulator one cycle
  dut.sim_tick()

# Test vectors

# This test is for Loopback(32)
def test_basic(cmdline_opts):

  dut = LoopThroughRTL(32)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.sel       @= 1 # Select loopback mode
  dut.upstream.req.msg  @= 0 
  dut.upstream.req.val  @= 0
  dut.upstream.resp.rdy  @= 0
  dut.sim_reset()
  # All upstream
  #       recv_val recv_rdy send_val send_rdy recv_msg   send_msg
  t( dut,    1,      1,        1,       1,     0xABCD,    0xABCD ) # start transaction
  t( dut,    1,      1,        1,       1,     0xDCBA,    0xDCBA ) 
  t( dut,    0,      1,        0,       1,     0x0001,    '?' )
  t( dut,    0,      0,        0,       0,     0x0400,    '?' ) 
  t( dut,    1,      0,        1,       0,     0x0000,    0x0000 ) 
  t( dut,    1,      1,        1,       1,     0x0000,    0x0000 )


def test_passthrough(cmdline_opts):
  
  dut = LoopThroughRTL(32)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.sel       @= 0 # Select passthrough mode
  dut.upstream.req.msg    @= 0 
  dut.upstream.req.val    @= 0
  dut.upstream.resp.rdy   @= 0
  dut.downstream.resp.msg @= 0 
  dut.downstream.resp.val @= 0
  dut.downstream.req.rdy  @= 0
  dut.sim_reset()
  # All upstream
  #           up_req          down_req         down_resp         up_resp
  t2( dut, 1, 1, 0xABCD,    1, 1, 0xABCD,    1, 0, 0xBEEF,     1, 0, 0xBEEF ) # start transaction
  t2( dut, 1, 1, 0xDCBA,    1, 1, 0xDCBA,    1, 0, 0xBEEF,     1, 0, 0xBEEF ) 
  t2( dut, 0, 1, 0x0001,    0, 1, 0x0001,    1, 1, 0xBEEF,     1, 1, 0xBEEF )
  t2( dut, 0, 0, 0x0400,    0, 0, 0x0400,    1, 0, 0xBEEF,     1, 0, 0xBEEF ) 
  t2( dut, 1, 0, 0x0000,    1, 0, 0x0000,    0, 0, 0xBEEF,     0, 0, 0xBEEF ) 
  t2( dut, 1, 1, 0x0000,    1, 1, 0x0000,    0, 1, 0xBEEF,     0, 1, 0xBEEF )

def test_loopback(cmdline_opts):
  
  dut = LoopThroughRTL(32)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.sel       @= 1 # Select loopback mode
  dut.upstream.req.msg    @= 0 
  dut.upstream.req.val    @= 0
  dut.upstream.resp.rdy   @= 0
  dut.downstream.resp.msg @= 0 
  dut.downstream.resp.val @= 0
  dut.downstream.req.rdy  @= 0
  dut.sim_reset()
  # All upstream
  #           up_req          down_req         down_resp         up_resp
  t2( dut, 1, 1, 0xABCD,    0, 1, 0xABCD,    1, 0, 0xBEEF,     1, 1, 0xABCD ) # start transaction
  t2( dut, 1, 1, 0xDCBA,    0, 1, 0xDCBA,    1, 0, 0xBEEF,     1, 1, 0xDCBA ) 
  t2( dut, 0, 1, 0x0001,    0, 1, 0x0001,    0, 0, 0xBEEF,     0, 1, 0x0001 )
  t2( dut, 0, 0, 0x0400,    0, 0, 0x0400,    1, 0, 0xBEEF,     0, 0, 0x0400 ) 
  t2( dut, 1, 0, 0x0000,    0, 0, 0x0000,    1, 0, 0xBEEF,     1, 0, 0x0000 ) 
  t2( dut, 1, 1, 0x0000,    0, 1, 0x0000,    0, 0, 0xBEEF,     1, 1, 0x0000 )

