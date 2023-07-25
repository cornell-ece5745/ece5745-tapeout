'''
==========================================================================
SPIstack_test.py
==========================================================================
Simple loopback test for SPIstack in the context of the SPI_TapeOutBlock,
this time using the SPITestHarness. Note that this test will fail until
you connect your block to this one.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from tapeout.SPI_TapeOutBlockRTL import SPI_TapeOutBlockRTL
from SPI_v3.components.SPITestHarness import SPITestHarness
from pymtl3.stdlib.mem        import mk_mem_msg, MemMsgType

import random

MemReqType, MemRespType = mk_mem_msg( 8, 32, 32 )

def test_loopback( cmdline_opts ):

  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts, True)
  harness.dut.loopthrough_sel @= 1 # loopback mode

  requests  = [] # Create empty list for requests
  responses = [] # Create empty list for responses

  requests.append(0xDEADBEEF)
  responses.append(0xDEADBEEF)

  harness.t_mult_msg(32, requests, 32, responses)

def test_loopback_stream( cmdline_opts ):

  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 1 # loopback mode

  requests  = [] # Create empty list for requests
  responses = [] # Create empty list for responses
  for i in range(10):
    requests.append(i*10)
    responses.append(i*10)

  harness.t_mult_msg(32, requests, 32, responses)


def test_basic_msgs( cmdline_opts ):

  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 0 # loopback mode

  requests = [
    #    type  opq  addr   len data                type  opq len data
    req( 'wr', 0x0, 0x0000, 0, 0xdeadbeef ).to_bits(), req( 'rd', 0x1, 0x0000, 0, 0).to_bits()  ]
  responses = [resp('wr',0x0,0,0).to_bits(),resp('rd',0x1,0,0xdeadbeef).to_bits()]
  harness.t_mult_msg(78, requests, 48, responses)

def test_basic_multiple_msgs(cmdline_opts):

  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 0 # loopback mode
  requests =[]
  responses = []

  req_resp = [
    #    type  opq  addr   len data                        type  opq len data
    req( 'wr', 0x0, 0x0000, 0, 0xcafe0123 ).to_bits(), resp( 'wr', 0x0, 0, 0          ).to_bits(),
    req( 'rd', 0x1, 0x0000, 0, 0          ).to_bits(), resp( 'rd', 0x1, 0, 0xcafe0123 ).to_bits(),
    req( 'wr', 0x2, 0x0008, 0, 0x0a0b0c0d ).to_bits(), resp( 'wr', 0x2, 0, 0          ).to_bits(),
    req( 'rd', 0x3, 0x0008, 0, 0          ).to_bits(), resp( 'rd', 0x3, 0, 0x0a0b0c0d ).to_bits(),
    req( 'wr', 0x4, 0x01f8, 0, 0x42134213 ).to_bits(), resp( 'wr', 0x4, 0, 0          ).to_bits(),
    req( 'rd', 0x5, 0x01f8, 0, 0          ).to_bits(), resp( 'rd', 0x5, 0, 0x42134213 ).to_bits(),
  ]

  for i in range(len(req_resp)):
    if i % 2 == 0:
      requests.append(req_resp[i])
    else:
      responses.append(req_resp[i])

  harness.t_mult_msg(78, requests, 48, responses)

#----------------------------------------------------------------------
# Test Case: random
#----------------------------------------------------------------------

def test_random_msgs(cmdline_opts):

  harness = SPITestHarness(SPI_TapeOutBlockRTL(),    1,           34,   cmdline_opts,True)
  harness.dut.loopthrough_sel @= 0 # loopback mode

  base_addr = 0

  rgen = random.Random()
  rgen.seed(0xa4e28cc2)

  vmem = [ rgen.randint(0,0xffffffff) for _ in range(32) ]
  msgs = []
  requests = []
  responses = []

  # Force this to be 32 because there are 32 entries in the regfile
  for i in range(32):
    msgs.extend([
      req( 'wr', i, base_addr+4*i, 0, vmem[i]).to_bits(), resp( 'wr', i, 0, 0 ).to_bits(),
    ])

  for i in range(32):
    idx = rgen.randint(0,31)

    if rgen.randint(0,1):

      correct_data = vmem[idx]
      msgs.extend([
        req( 'rd', i, base_addr+4*idx, 0, 0 ).to_bits(), resp( 'rd', i, 0, correct_data ).to_bits(),
      ])

    else:

      new_data = rgen.randint(0,0xffffffff)
      vmem[idx] = new_data
      msgs.extend([
        req( 'wr', i, base_addr+4*idx, 0, new_data ).to_bits(), resp( 'wr', i, 0, 0 ).to_bits(),
      ])

  for i in range(len(msgs)):
    if i % 2 == 0:
      requests.append(msgs[i])
    else:
      responses.append(msgs[i])

  harness.t_mult_msg(78, requests, 48, responses)

#-------------------------------------------------------------------------
# make messages
#-------------------------------------------------------------------------

def req( type_, opaque, addr, len, data ):
  if   type_ == 'rd': type_ = MemMsgType.READ
  elif type_ == 'wr': type_ = MemMsgType.WRITE

  return MemReqType( type_, opaque, addr, len, data)

def resp( type_, opaque, len, data ):
  if   type_ == 'rd': type_ = MemMsgType.READ
  elif type_ == 'wr': type_ = MemMsgType.WRITE

  return MemRespType( type_, opaque, b2(0), len, data )
