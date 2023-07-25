'''
==========================================================================
SPIMinionAdapterCompositeRTL_test.py
==========================================================================
Unit test for SPIMinionAdapterCompositeRTL.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.SPIMinionAdapterCompositeRTL import SPIMinionAdapterCompositeRTL

def test_basic( cmdline_opts ):

  dut = SPIMinionAdapterCompositeRTL(4,1)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.spi_min.cs          @= 1
  dut.spi_min.sclk        @= 0
  dut.spi_min.mosi        @= 0
  dut.recv.val    @= 0
  dut.recv.msg    @= 0
  dut.send.rdy    @= 0
  dut.sim_reset()


  
  # Test vectors
  #       cs, sclk, mosi, miso, recv_val, recv_rdy, recv_msg, send_val, send_rdy, send_msg
  t( dut,  1,    0,    0,    0,        0,        1,     0x0,         0,        0,      '?' ) # cs high
  t( dut,  1,    0,    0,    0,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  1,    0,    0,    0,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  1,    0,    0,    0,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    0,        0,        1,     0x0,         0,        0,      '?' ) # period before sclk toggle
  # 0
  t( dut,  0,    0,    0,    0,        1,        1,     0x2,         0,        0,      '?' )
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' ) #start invalid read
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
#   # 1
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' ) 
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    1,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    1,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    1,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    1,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    1,        0,        0,     0x0,         0,        0,      '?' )
#  # 2
  t( dut,  0,    0,    0,    1,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    1,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    1,        0,        0,     0x0,         0,        0,      '?' ) 
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
#   # 3
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' ) 
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
#   # 4
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    1,    0,        0,        0,     0x0,         0,        0,      '?' )
#   # cs high
  t( dut,  1,    0,    0,    0,       0,        0,     0x0,         0,        0,      '?' )
  t( dut,  1,    0,    0,    0,       0,        0,     0x0,         0,        0,      '?' )
  t( dut,  1,    0,    0,    0,       0,        0,     0x0,         0,        0,      '?' )
  t( dut,  1,    0,    0,    0,       0,        0,     0x0,         1,        1,      0x3 )
  t( dut,  1,    1,    0,    0,       0,        0,     0x0,         0,        0,      '?' )
  t( dut,  1,    1,    0,    0,       0,        0,     0x0,         0,        0,      '?' )
  t( dut,  1,    1,    0,    0,       0,        0,     0x0,         0,        0,      '?' )
  t( dut,  1,    1,    0,    0,       0,        0,     0x0,         0,        0,      '?' )
    
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' ) #start invalid read
  t( dut,  0,    0,    0,    0,        0,        0,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
#   # 1
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' ) 
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
#  # 2
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' ) 
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
#   # 3
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' ) 
  t( dut,  0,    0,    0,    1,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    0,    0,    0,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    0,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    0,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    0,        0,        1,     0x0,         0,        0,      '?' )
  t( dut,  0,    1,    0,    0,        0,        1,     0x0,         0,        0,      '?' )

# Helper function
def t( dut, cs, sclk, mosi, miso, recv_val, recv_rdy, recv_msg, send_val, send_rdy, send_msg ):

  # Write input value to input port
  dut.spi_min.sclk        @= sclk
  dut.spi_min.cs          @= cs
  dut.spi_min.mosi        @= mosi
  dut.recv.val    @= recv_val
  dut.recv.msg    @= recv_msg
  dut.send.rdy    @= send_rdy

  dut.sim_eval_combinational()

  assert dut.spi_min.miso == miso

  if recv_rdy != '?':
    assert dut.recv.rdy == recv_rdy

  if send_val != '?':
    assert dut.send.val == send_val
    
  if send_msg != '?':
    assert dut.send.msg == send_msg

  # Tick simulator one cycle
  dut.sim_tick()