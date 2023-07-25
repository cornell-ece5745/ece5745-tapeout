'''
==========================================================================
SPILoopbackComposite_test.py
==========================================================================
Unit test for SPILoopbackComposite.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.SPILoopBackCompositeRTL import SPILoopBackCompositeRTL


def test_basic( cmdline_opts ):

  dut = SPILoopBackCompositeRTL( 4 )
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.spi_min.cs          @= 1
  dut.spi_min.sclk        @= 0
  dut.spi_min.mosi        @= 0
  dut.sim_reset()


  
  # Test vectors
  #       cs, sclk, mosi, miso
  t( dut,  1,    0,    0,    0 ) # cs high
  t( dut,  1,    0,    0,    0 )
  t( dut,  1,    0,    0,    0 )
  t( dut,  1,    0,    0,    0 )
  t( dut,  0,    0,    0,    0 ) # period before sclk toggle
  # 0                                     
  t( dut,  0,    0,    1,    0 ) #val_wrt = 1
  t( dut,  0,    0,    1,    0 )
  t( dut,  0,    0,    1,    0 )
  t( dut,  0,    1,    1,    0 )
  t( dut,  0,    1,    1,    0 )
  t( dut,  0,    1,    1,    0 )
  # 1                                  
  t( dut,  0,    0,    0,    0 ) #val_rd =0
  t( dut,  0,    0,    0,    0 )
  t( dut,  0,    0,    0,    0 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  # 2                                  
  t( dut,  0,    0,    1,    1 ) #mosi_data = 11
  t( dut,  0,    0,    1,    1 ) 
  t( dut,  0,    0,    1,    1 )
  t( dut,  0,    1,    1,    0 )
  t( dut,  0,    1,    1,    0 )
  t( dut,  0,    1,    1,    0 )
  # 3                                  
  t( dut,  0,    0,    1,    0 ) 
  t( dut,  0,    0,    1,    0 )
  t( dut,  0,    0,    1,    0 )
  t( dut,  0,    1,    1,    0 )
  t( dut,  0,    1,    1,    0 )
  t( dut,  0,    1,    1,    0 )

  # cs high                                  
  t( dut,  1,    0,    0,    0 )
  t( dut,  1,    0,    0,    0 )
  t( dut,  1,    0,    0,    0 )
  t( dut,  1,    1,    0,    0 )
  t( dut,  1,    1,    0,    0 )
  t( dut,  1,    1,    0,    0 )   
  # 0
  t( dut,  0,    0,    0,    0 ) #val_wrt
  t( dut,  0,    0,    0,    0 )
  t( dut,  0,    0,    0,    0 )
  t( dut,  0,    1,    0,    0 )
  t( dut,  0,    1,    0,    0 )
  t( dut,  0,    1,    0,    0 )
  # 1                                  
  t( dut,  0,    0,    1,    0 ) #val_rd
  t( dut,  0,    0,    1,    0 )
  t( dut,  0,    0,    1,    0 )
  t( dut,  0,    1,    1,    1 )
  t( dut,  0,    1,    1,    1 )
  t( dut,  0,    1,    1,    1 )
#  # 2                                  
  t( dut,  0,    0,    0,    1 ) #mosi_data = 00
  t( dut,  0,    0,    0,    1 )
  t( dut,  0,    0,    0,    1 )
  t( dut,  0,    1,    0,    0 )
  t( dut,  0,    1,    0,    0 )
  t( dut,  0,    1,    0,    0 )
#   # 3                                  
  t( dut,  0,    0,    0,    0 ) 
  t( dut,  0,    0,    0,    0 )
  t( dut,  0,    0,    0,    0 )
  t( dut,  0,    1,    0,    0 )
  t( dut,  0,    1,    0,    0 )
  t( dut,  0,    1,    0,    0 )
# cs high                                  
  t( dut,  1,    0,    0,    0 )
  t( dut,  1,    0,    0,    0 )
  t( dut,  1,    0,    0,    0 )
  t( dut,  1,    1,    0,    0 )
  t( dut,  1,    1,    0,    0 )
  t( dut,  1,    1,    0,    0 ) 
  # 0
  t( dut,  0,    0,    0,    0 ) #val
  t( dut,  0,    0,    0,    0 )
  t( dut,  0,    0,    0,    0 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  # 1                                  
  t( dut,  0,    0,    0,    1 ) #spc
  t( dut,  0,    0,    0,    1 )
  t( dut,  0,    0,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )
#  # 2                                  
  t( dut,  0,    0,    0,    1 ) #miso_data = 00
  t( dut,  0,    0,    0,    1 )
  t( dut,  0,    0,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )
#   # 3                                  
  t( dut,  0,    0,    0,    1 ) 
  t( dut,  0,    0,    0,    1 )
  t( dut,  0,    0,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )
  t( dut,  0,    1,    0,    1 )

# Helper function
def t( dut, cs, sclk, mosi, miso ):

  # Write input value to input port
  dut.spi_min.sclk        @= sclk
  dut.spi_min.cs          @= cs
  dut.spi_min.mosi        @= mosi

  dut.sim_eval_combinational()

  assert dut.spi_min.miso == miso

  # Tick simulator one cycle
  dut.sim_tick()