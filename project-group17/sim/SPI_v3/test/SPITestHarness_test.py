'''
==========================================================================
SPITestHarness_test.py
==========================================================================
Unit test for SPITestHarness.
'''
import random

# Fix the random seed so results are reproducible
random.seed(0xdeadbeef)

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts
from ..components.SPILoopbackComposite import SPILoopbackComposite
from ..components.SPITestHarness import SPITestHarness

def test_one( cmdline_opts ):

  nbits = 30
  model = SPILoopbackComposite((nbits+2))
  model.elaborate()

  spi_harness = SPITestHarness( model, 0, 32, cmdline_opts)


  msgs = [0x4]
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs)


def test_basic( cmdline_opts ):

  nbits = 30 #data size
  model = SPILoopbackComposite((nbits+2))
  model.elaborate()

  spi_harness = SPITestHarness( model, 0, 32, cmdline_opts)

  msgs = [0x00000000, 0x00000001, 0x10000000, 0x12345678, 0xffffffff]
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs)


def test_one_comp( cmdline_opts ):

  nbits = 30 #data size
  model = SPILoopbackComposite((nbits+2))
  model.elaborate()

  spi_harness = SPITestHarness( model, 1, 32, cmdline_opts)

  msgs = [0x00000000, 0x00000001, 0x10000000, 0x12345678, 0x00ffffff]
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs)


def test_sim_multiple_components( cmdline_opts ):

  nbits = 4 #data size
  model = SPILoopbackComposite(10) #spi packet size (2 flow, 4 comp, 4 data)
  model.elaborate()

  spi_harness = SPITestHarness( model, 16, 10, cmdline_opts) #16 comp addresses, 10 bit spi packet
  msgs = [0x0, 0x1, 0x0, 0x8, 0xf]
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs, 5) #send to comp address 5


def test_random( cmdline_opts ):
  nbits = 32
  model = SPILoopbackComposite((nbits+2))
  model.elaborate()

  spi_harness = SPITestHarness( model, 0, 34, cmdline_opts)

  msgs = []
  for i in range(100):
    msg = b32( random.randint(0,0xffffffff) )
    msgs.append(msg)
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs)

def test_16_bits( cmdline_opts ):

  model = SPILoopbackComposite(16)
  model.elaborate()

  spi_harness = SPITestHarness( model, 0, 16, cmdline_opts)

  msgs = [0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008, 0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x000E, 0x000F]

  for i in range(16):
    spi_harness.t_mult_msg(14, [msgs[i]], 14, [msgs[i]])
    # for j in range(50000000):
    for j in range(5):
      spi_harness.dut.sim_tick()