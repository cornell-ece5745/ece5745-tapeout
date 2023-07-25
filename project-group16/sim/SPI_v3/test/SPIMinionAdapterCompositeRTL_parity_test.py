'''
==========================================================================
SPIMinionAdapterCompositeRTL_parity_test.py
==========================================================================
Testing spi minion and adapter parity bits through minion adapter composite.
'''
import random

# Fix the random seed so results are reproducible
random.seed(0xdeadbeef)

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.SPIMinionAdapterCompositeRTL import SPIMinionAdapterCompositeRTL

def test_zero ( cmdline_opts ):
  send_and_check_parity(cmdline_opts, 0x0)

def test_one ( cmdline_opts ):
  send_and_check_parity(cmdline_opts, 0x1)

def test_even ( cmdline_opts ):
  send_and_check_parity(cmdline_opts, 0x0AAAAAAAA)

def test_odd ( cmdline_opts ):
  send_and_check_parity(cmdline_opts, 0x1AAAAAAAA)

def test_rand ( cmdline_opts ):
  for i in range(20): 
    msg = random.randint(0,0x7ffffffff)
    send_and_check_parity(cmdline_opts, msg)
  

def send_and_check_parity( cmdline_opts, data):
  #data is 35 bit message to check parity of

  #instantiate design
  nbits = 37
  q_num_entries = 5
  dut = SPIMinionAdapterCompositeRTL(nbits, q_num_entries)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  #reset
  dut.spi_min.cs          @= 1
  dut.spi_min.sclk        @= 0
  dut.spi_min.mosi        @= 0
  dut.sim_reset()

  #send message and check parities
  assert dut.minion_parity == 0
  assert dut.adapter_parity == 0
  start_transaction(dut)
  assert dut.minion_parity == 0
  assert dut.adapter_parity == 0
  send_bit(dut, 1)
  assert dut.minion_parity == 0
  assert dut.adapter_parity == 0
  send_bit(dut, 0)
  assert dut.minion_parity == 0
  assert dut.adapter_parity == 0
  bits35 = mk_bits(35)
  msg = bits35(data)
  for i in range(35):
    send_bit(dut, msg[34-i])
    assert dut.minion_parity == 0
    assert dut.adapter_parity == 0
  end_transaction(dut) # chip select high
  dut.sim_tick() # push_en 1
  assert dut.minion_parity == reduce_xor(msg)
  assert dut.adapter_parity == 0
  dut.sim_tick() #send_val 1
  assert dut.adapter_parity == reduce_xor(msg)



# Helper functions
def start_transaction( dut ): #send bits
  # Starts a transaction by keeping cs HIGH for 3 cycles then pulling cs LOW 
  for i in range(3): # cs = 1
    # Write input values to input ports
    dut.spi_min.sclk        @= 0
    dut.spi_min.cs          @= 1
    dut.spi_min.mosi        @= 1 # mosi is a dont care here bc CS is high
    dut.sim_eval_combinational()
    # Tick simulator one cycle
    dut.sim_tick()
  for i in range(3): # cs = 0, three cycles because the synchronizer takes 2 cycles for negedge to appear
    dut.spi_min.sclk        @= 0
    dut.spi_min.cs          @= 0
    dut.spi_min.mosi        @= 1 # mosi is a dont care here bc CS is high
    dut.sim_eval_combinational()
    dut.sim_tick()

def end_transaction( dut ):
  dut.spi_min.sclk        @= 0
  dut.spi_min.cs          @= 1
  dut.spi_min.mosi        @= 1 # mosi is a dont care here bc CS is high
  dut.sim_eval_combinational()
  dut.sim_tick()

def send_bit( dut, mosi): #send bits
  # This function sends bits over SPI once the transaction has been started (CS is already low)
  for i in range(3): # sclk = 0
    # Write input values to input ports
    dut.spi_min.sclk        @= 0
    dut.spi_min.cs          @= 0
    dut.spi_min.mosi        @= mosi
    dut.sim_eval_combinational()
    # Tick simulator one cycle
    dut.sim_tick()

  for i in range(3): # sclk = 1
    dut.spi_min.sclk        @= 1
    dut.spi_min.cs          @= 0
    dut.spi_min.mosi        @= mosi
    dut.sim_eval_combinational()
    dut.sim_tick()
