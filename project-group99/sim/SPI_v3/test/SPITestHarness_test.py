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
from ..components.SPILoopBackCompositePRTL import SPILoopBackCompositePRTL
from ..components.SPITestHarness import SPITestHarness

def test_one( cmdline_opts ):

  nbits = 4
  model = SPILoopBackCompositePRTL((nbits+2))
  model.elaborate()

  spi_harness = SPITestHarness( model, 0, 6, cmdline_opts)


  msgs = [0xf]
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs)


def test_basic( cmdline_opts ):

  nbits = 32 #data size
  model = SPILoopBackCompositePRTL((nbits+2))
  model.elaborate()

  spi_harness = SPITestHarness( model, 0, 34, cmdline_opts)

  msgs = [0x00000000, 0x00000001, 0x10000000, 0x12345678, 0xffffffff]
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs)


def test_one_comp( cmdline_opts ):

  nbits = 32 #data size
  model = SPILoopBackCompositePRTL((nbits+2))
  model.elaborate()

  spi_harness = SPITestHarness( model, 1, 34, cmdline_opts)

  msgs = [0x00000000, 0x00000001, 0x10000000, 0x12345678, 0xffffffff]
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs)


def test_sim_multiple_components( cmdline_opts ):

  nbits = 4 #data size
  model = SPILoopBackCompositePRTL(10) #spi packet size (2 flow, 4 comp, 4 data)
  model.elaborate()

  spi_harness = SPITestHarness( model, 16, 10, cmdline_opts) #16 comp addresses, 10 bit spi packet
  msgs = [0x0, 0x1, 0x0, 0x8, 0xf]
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs, 5) #send to comp address 5


def test_random( cmdline_opts ):
  nbits = 32
  model = SPILoopBackCompositePRTL((nbits+2))
  model.elaborate()

  spi_harness = SPITestHarness( model, 0, 34, cmdline_opts)

  msgs = []
  for i in range(100):
    msg = b32( random.randint(0,0xffffffff) )
    msgs.append(msg)
  spi_harness.t_mult_msg(nbits, msgs, nbits, msgs)

def test_16_bits( cmdline_opts ):

  model = SPILoopBackCompositePRTL(16)
  model.elaborate()
  spi_harness = SPITestHarness( model, 0, 16, cmdline_opts)

  msgs = [0x0000, 0x0101, 0x0202, 0x0303, 0x0404, 0x0505, 0x0606, 0x0707, 0x0808, 0x0909, 0x0A0A, 0x0B0B, 0x0C0C, 0x0D0D, 0x0E0E, 0x0F0F]

  for i in range(16):
    spi_harness.t_mult_msg(14, [msgs[i]], 14, [msgs[i]])
    send = 0x3fff
    print(send)
    spi_harness.t_mult_msg(14, [send], 14, [send])
    # for j in range(50000000):
    # # for j in range(5):
    #   spi_harness.dut.sim_tick()

def test_37_bits( cmdline_opts ):

  model = SPILoopBackCompositePRTL(37)
  model.elaborate()
  spi_harness = SPITestHarness( model, 0, 37, cmdline_opts)

  msgs = [0x0000, 0x0101, 0x0202, 0x0303, 0x0404, 0x0505, 0x0606, 0x0707, 0x0808, 0x0909, 0x0A0A, 0x0B0B, 0x0C0C, 0x0D0D, 0x0E0E, 0x0F0F]

  for i in range(16):
    spi_harness.t_mult_msg(14, [msgs[i]], 14, [msgs[i]])
    send = 0x3fff
    print(send)
    spi_harness.t_mult_msg(14, [send], 14, [send])
