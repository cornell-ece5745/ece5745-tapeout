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

def test_loopback( cmdline_opts ):
  # InstantiateTest Harness         DUT               # components  spi_bits
  harness = SPITestHarness(SPI_TapeOutBlockRTL(),    1,           34,   cmdline_opts)
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