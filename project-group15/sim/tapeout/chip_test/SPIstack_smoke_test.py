'''
==========================================================================
SPIstack_smoke_test.py
==========================================================================
Simple loopback test for SPIstack in the context of the SPI_TapeOutBlock
Note that this test will fail until you connect your block to this one.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from tapeout.SPI_TapeOutBlockRTL import SPI_TapeOutBlockRTL

# def test_loopback( cmdline_opts ):

#   dut = SPI_TapeOutBlockRTL( 2, 1 )
#   dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
#   dut.apply( DefaultPassGroup( linetrace=True ) )

#   dut.loopthrough_sel @= 1 # Loopback mode
#   dut.spi_min.cs          @= 1
#   dut.spi_min.sclk        @= 0
#   dut.spi_min.mosi        @= 0
#   dut.sim_reset()
  
#   # Test vectors
#   #       cs, sclk, mosi, miso
#   t2( dut,  1,    0,    0,    0 ) # cs high
#   t2( dut,  1,    0,    0,    0 )
#   t2( dut,  1,    0,    0,    0 )
#   t2( dut,  1,    0,    0,    0 )
#   t2( dut,  0,    0,    0,    0 ) # period before sclk toggle
#   # 0                                     
#   t2( dut,  0,    0,    1,    0 ) #val_wrt = 1
#   t2( dut,  0,    0,    1,    0 )
#   t2( dut,  0,    0,    1,    0 )
#   t2( dut,  0,    1,    1,    0 )
#   t2( dut,  0,    1,    1,    0 )
#   t2( dut,  0,    1,    1,    0 )
#   # 1                                  
#   t2( dut,  0,    0,    1,    0 ) #val_rd =1
#   t2( dut,  0,    0,    1,    0 )
#   t2( dut,  0,    0,    1,    0 )
#   t2( dut,  0,    1,    1,    1 )
#   t2( dut,  0,    1,    1,    1 )
#   t2( dut,  0,    1,    1,    1 )
#   # 2                                  
#   t2( dut,  0,    0,    1,    1 ) #mosi_data = 11
#   t2( dut,  0,    0,    1,    1 ) 
#   t2( dut,  0,    0,    1,    1 )
#   t2( dut,  0,    1,    1,    0 )
#   t2( dut,  0,    1,    1,    0 )
#   t2( dut,  0,    1,    1,    0 )
#   # 3                                  
#   t2( dut,  0,    0,    1,    0 ) 
#   t2( dut,  0,    0,    1,    0 )
#   t2( dut,  0,    0,    1,    0 )
#   t2( dut,  0,    1,    1,    0 )
#   t2( dut,  0,    1,    1,    0 )
#   t2( dut,  0,    1,    1,    0 )

# # cs high                                  
#   t2( dut,  1,    0,    0,    0 )
#   t2( dut,  1,    0,    0,    0 )
#   t2( dut,  1,    0,    0,    0 )
#   t2( dut,  1,    1,    0,    0 )
#   t2( dut,  1,    1,    0,    0 )
#   t2( dut,  1,    1,    0,    0 ) 
#   # 0
#   t2( dut,  0,    0,    0,    0 ) #val
#   t2( dut,  0,    0,    0,    0 )
#   t2( dut,  0,    0,    0,    0 )
#   t2( dut,  0,    1,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
#   # 1                                  
#   t2( dut,  0,    0,    0,    1 ) #spc
#   t2( dut,  0,    0,    0,    1 )
#   t2( dut,  0,    0,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
# #  # 2                                  
#   t2( dut,  0,    0,    0,    1 ) #miso_data = 11
#   t2( dut,  0,    0,    0,    1 )
#   t2( dut,  0,    0,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
# #   # 3                                  
#   t2( dut,  0,    0,    0,    1 ) 
#   t2( dut,  0,    0,    0,    1 )
#   t2( dut,  0,    0,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )
#   t2( dut,  0,    1,    0,    1 )

# # Helper function
# def t2( dut, cs, sclk, mosi, miso ):

#   # Write input value to input port
#   dut.spi_min.sclk        @= sclk
#   dut.spi_min.cs          @= cs
#   dut.spi_min.mosi        @= mosi

#   dut.sim_eval_combinational()

#   assert dut.spi_min.miso == miso

#   # Tick simulator one cycle
#   dut.sim_tick()