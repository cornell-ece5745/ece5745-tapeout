'''
==========================================================================
SPIstack_test.py
==========================================================================
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from binascii import crc32
import random
from project.crc32.block_test.CRC32UnitRTL_test import crc32_ref

from tapeout.SPI_TapeOutBlockRTL import SPI_TapeOutBlockRTL
from SPI_v3.components.SPITestHarness import SPITestHarness

def test_loopback( cmdline_opts ):

  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 1 # loopback mode

  requests  = [] # Create empty list for requests
  responses = [] # Create empty list for responses
  for i in range(10):
    requests.append(i*10)
    responses.append(i*10)

  harness.t_mult_msg(32, requests, 32, responses)

def mk_msgs(values):
  req_msgs  = [len(values)]
  resp_msgs = [crc32_ref(values)]
  for value in values:
    req_msgs.append(value)
  return req_msgs, resp_msgs

req_msgs_small, resp_msgs_small = mk_msgs(range(0x1,  0x10))
req_msgs_large, resp_msgs_large = mk_msgs(range(0x0f, 0x7f))
req_msgs_long,  resp_msgs_long  = mk_msgs(range(0x1,  0x7f))
req_msgs_rand,  resp_msgs_rand  = mk_msgs(random.sample(range(0x1, 0x7f), 0x2f))

def test_small( cmdline_opts ):
  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 0
  harness.t_mult_msg(32, req_msgs_small, 32, resp_msgs_small)

def test_large( cmdline_opts ):
  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 0
  harness.t_mult_msg(32, req_msgs_large, 32, resp_msgs_large)

def test_long( cmdline_opts ):
  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 0
  harness.t_mult_msg(32, req_msgs_long, 32, resp_msgs_long)

def test_random( cmdline_opts ):
  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 0
  harness.t_mult_msg(32, req_msgs_rand, 32, resp_msgs_rand)

