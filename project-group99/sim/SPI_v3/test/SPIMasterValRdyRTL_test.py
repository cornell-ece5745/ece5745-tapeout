'''
==========================================================================
SPIMasterRTL_test.py
==========================================================================
Unit test for SPIMasterRTL.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.SPIMasterValRdyRTL import SPIMasterValRdyRTL


"""
Notes: figure out cs_addr and packet_szie registers
"""
# array format [ val, rdy, msg ]

def t( dut, cs_addr, packet_size, recv, send, cs, sclk, mosi, miso ):

  # Write input value to input port
  dut.cs_addr_ifc.val      @= cs_addr[0]
  dut.cs_addr_ifc.msg      @= cs_addr[2]
  dut.packet_size_ifc.val  @= packet_size[0]
  dut.packet_size_ifc.msg  @= packet_size[2]
  dut.recv.val             @= recv[0]
  dut.recv.msg             @= recv[2]
  dut.send.rdy             @= send[1]
  dut.spi_ifc.miso         @= miso


  dut.sim_eval_combinational()

  assert dut.cs_addr_ifc.rdy == cs_addr[1]
  assert dut.packet_size_ifc.rdy == packet_size[1]
  assert dut.recv.rdy == recv[1]
  assert dut.send.val == send[0]

  if send[2] != '?':
    assert dut.send.msg == send[2]

  if sclk != '?':
    assert dut.spi_ifc.sclk == sclk

  if mosi != '?':
    assert dut.spi_ifc.mosi == mosi

  for i in range(len(cs)):
    assert dut.spi_ifc.cs[i]  == cs[i]

  # Tick simulator one cycle
  dut.sim_tick()

def reset( dut ):
  dut.cs_addr_ifc.val      @= 0
  dut.cs_addr_ifc.msg      @= 0
  dut.packet_size_ifc.val  @= 0
  dut.packet_size_ifc.msg  @= 0
  dut.recv.val             @= 0
  dut.recv.msg             @= 0
  dut.send.rdy             @= 0
  dut.spi_ifc.miso         @= 0
  dut.sim_reset()

def test_basic (cmdline_opts ): # basic test
  dut = SPIMasterValRdyRTL(4, 1)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  reset( dut )
  # Test vectors
      #    cs_addr,   pkt_sz,      recv,       send ,     cs,  sclk, mosi, miso 
      # INIT
  t(  dut, [1,1,0],  [0,1,0x0],  [0,1,0x0],  [0,1,'?'],   [1],    0,  '?',    0 ) # use cs0
  t(  dut, [0,1,0],  [1,1,0x4],  [0,1,0x0],  [0,1,'?'],   [1],    0,  '?',    0 ) # pkt size = 4
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xA],  [0,1,'?'],   [1],    0,  '?',    0 ) # Send out 0xA MOSI
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,1,'?'],   [0],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x0],  [1,0,0x5],   [1],    0,   '?',   0 )


def test_basic_32bit_max_size (cmdline_opts ): # 32 nbits with 4 bit packet  
  dut = SPIMasterValRdyRTL(32, 1)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  reset( dut )
  # Test vectors
      #    cs_addr,   pkt_sz,      recv,       send ,     cs,  sclk, mosi, miso 
      # INIT
  t(  dut, [1,1,0],  [0,1,0x0],  [0,1,0x0],  [0,1,'?'],   [1],    0,  '?',    0 ) # use cs0
  t(  dut, [0,1,0],  [1,1,0x4],  [0,1,0x0],  [0,1,'?'],   [1],    0,  '?',    0 ) # pkt size = 4
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xA],  [0,1,'?'],   [1],    0,  '?',    0 ) # Send out 0xA MOSI
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,1,'?'],   [0],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x0],  [1,0,0x5],   [1],    0,   '?',   0 )


def test_basic_twoCS (cmdline_opts ): # two chip selects
  dut = SPIMasterValRdyRTL(4, 2)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  reset( dut )
  # Test vectors
      #    cs_addr,   pkt_sz,      recv,       send ,     cs,  sclk, mosi, miso 
      # INIT
  t(  dut, [1,1,0],  [0,1,0x0],  [0,1,0x0],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # use cs0
  t(  dut, [0,1,0],  [1,1,0x4],  [0,1,0x0],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # pkt size = 4
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xA],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # Send out 0xA MOSI
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,1,'?'],   [0,1],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [0,1],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x0],  [1,0,0x5],   [1,1],    0,   '?',   0 )


def test_cs1_twoCS (cmdline_opts ): #two chip selects - using other chip select
  dut = SPIMasterValRdyRTL(4, 2)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  reset( dut )
  # Test vectors
      #    cs_addr,   pkt_sz,      recv,       send ,     cs,  sclk, mosi, miso 
      # INIT
  t(  dut, [1,1,1],  [0,1,0x0],  [0,1,0x0],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # use cs0
  t(  dut, [0,1,0],  [1,1,0x4],  [0,1,0x0],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # pkt size = 4
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xA],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # Send out 0xA MOSI
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,1,'?'],   [1,0],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x0],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x0],  [1,0,0x5],   [1,1],    0,   '?',   0 )


def test_8bit (cmdline_opts ): # 32 nbits, 8 bit packet, CS 1
  dut = SPIMasterValRdyRTL(32, 2)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  reset( dut )
  # Test vectors
      #    cs_addr,   pkt_sz,      recv,       send ,       cs,  sclk, mosi, miso 
      # INIT
  t(  dut, [1,1,1],  [0,1,0x0],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # use cs0
  t(  dut, [0,1,0],  [1,1,0x8],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # pkt size = 4
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xAA],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # Send out 0xA MOSI
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,1,'?'],   [1,0],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x55],  [1,1],    0,   '?',   0 )

def test_8bit_two_msgs (cmdline_opts ): # two messages in a row - same CS
  dut = SPIMasterValRdyRTL(32, 2)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  reset( dut )
  # Test vectors
      #    cs_addr,   pkt_sz,      recv,       send ,       cs,  sclk, mosi, miso 
      # INIT
  t(  dut, [1,1,1],  [0,1,0x0],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # use cs0
  t(  dut, [0,1,0],  [1,1,0x8],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # pkt size = 4
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xAA],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # Send out 0xA MOSI
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,1,'?'],   [1,0],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x55],  [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x55],  [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,1,0x55],  [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [0,0,'?'],   [1,1],    0,   '?',   0 )
      # INIT
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xAA],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # Send out 0xAA MOSI
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,1,'?'],   [1,0],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x55],  [1,1],    0,   '?',   0 )


def test_8bit_val_often (cmdline_opts ): # two messages in a row - same CS - changing valrdy
  dut = SPIMasterValRdyRTL(32, 2)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  reset( dut )
  # Test vectors
      #    cs_addr,   pkt_sz,      recv,       send ,       cs,  sclk, mosi, miso 
      # INIT
  t(  dut, [1,1,1],  [0,1,0x0],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # use cs0
  t(  dut, [0,1,0],  [1,1,0x8],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # pkt size = 4
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xAA],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # Send out 0xA MOSI
      # START0
  t(  dut, [1,0,0],  [0,0,0x0],  [0,0,0x00],  [0,1,'?'],   [1,0],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [1,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [1,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [1,0,0],  [1,0,0x0],  [1,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [1,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [1,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [1,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [1,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [1,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [1,0,0],  [0,0,0x0],  [1,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x55],  [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x55],  [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,1,0x55],  [1,1],    0,   '?',   0 )
      # INIT
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [0,0,'?'],   [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xAA],  [0,1,'?'],   [1,1],    0,   '?',    0 ) # Send out 0xAA MOSI
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,1,'?'],   [1,0],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x55],  [1,1],    0,   '?',   0 )


def test_8bit_2_msgs_no_read (cmdline_opts ): # 2 messages in a row, send both without reading the send data
  dut = SPIMasterValRdyRTL(32, 2)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  reset( dut )
  # Test vectors
      #    cs_addr,   pkt_sz,      recv,       send ,       cs,    sclk, mosi, miso 
      # INIT
  t(  dut, [1,1,1],  [0,1,0x0],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # use cs0
  t(  dut, [0,1,0],  [1,1,0x8],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # pkt size = 4
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xAA],  [0,1,'?'],   [1,1],    0,  '?',    0 ) # Send out 0xA MOSI
      # START0
  t(  dut, [1,0,0],  [0,0,0x0],  [0,0,0x00],  [0,1,'?'],   [1,0],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [1,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [1,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [1,0,0],  [1,0,0x0],  [1,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [1,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [1,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [1,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [1,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [1,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [1,0,0],  [0,0,0x0],  [1,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x55],  [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x55],  [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0xDD],  [1,0,0x55],  [1,1],    0,   '?',   0 )
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,1,'?'],   [1,0],    0,    1,    1 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    1 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    1 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   1 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    1 ) # MOSI sampled on Minion, we sample MISO
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 ) # Change MOSI, Minion changes MISO
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   1 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   1 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0xAA],  [1,1],    0,   '?',   1 )

def test_changeCS_changePktSz ( cmdline_opts ): # two messages in a row - switch CS
  dut = SPIMasterValRdyRTL(8, 3)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )
  reset( dut )
  # Test vectors
      #    cs_addr,   pkt_sz,      recv,       send ,       cs,  sclk, mosi, miso 
      # INIT
  t(  dut, [1,1,1],  [0,1,0x0],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 )
  t(  dut, [0,1,0],  [1,1,0x5],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) 
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0x0A],  [0,1,'?'],   [1,1],    0,  '?',    0 ) 
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,1,'?'],   [1,0],    0,    0,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    0 )
      # SCLK_HIGH,       # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    0 ) 
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    1 ) 
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    1,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    1,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,    0,    0 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    1,    0,    0 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [1,0],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x0A],  [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x0A],  [1,1],    0,   '?',   0 )
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,1,0x0A],  [1,1],    0,   '?',   0 )
      # INIT
  t(  dut, [1,1,0],  [0,1,0x0],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 )
  t(  dut, [0,1,0],  [1,1,0x1],  [0,1,0x00],  [0,1,'?'],   [1,1],    0,  '?',    0 ) 
  t(  dut, [0,1,0],  [0,1,0x0],  [1,1,0x01],  [0,1,'?'],   [1,1],    0,  '?',    0 )
      # START0
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,1,'?'],   [0,1],    0,    1,    0 ) 
      # START1
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [0,1],    0,    1,    1 )
      # SCLK_HIGH,        # SCLK_LOW
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [0,1],    1,    1,    1 )
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [0,1],    0,   '?',   0 )
      # CS_LOW_WAIT
  t(  dut, [0,0,0],  [0,0,0x0],  [0,0,0x00],  [0,0,'?'],   [0,1],    0,   '?',   0 )
      # DONE
  t(  dut, [0,1,0],  [0,1,0x0],  [0,1,0x00],  [1,0,0x1],  [1,1],    0,   '?',   0 )



