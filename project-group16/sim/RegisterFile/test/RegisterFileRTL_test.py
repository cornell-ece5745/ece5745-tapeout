
#=========================================================================
# RegisterFile_test
#=========================================================================
import pytest
from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..RegisterFileRTL import RegisterFile

# In pytest, unit tests are simply functions that begin with a "test_"
# prefix. PyMTL3 is setup to collect command line options. Simply specify
# "cmdline_opts" as an argument to your unit test source code,
# and then you can dump VCD by adding --dump-vcd option to pytest
# invocation from the command line.


@pytest.mark.parametrize("nregs", [2, 4, 8, 16, 32, 64, 128, 256])
def test_basic( cmdline_opts, nregs ):

  # Create the model

  model = RegisterFile(Bits32, nregs)

  # Configure the model

  model = config_model_with_cmdline_opts( model, cmdline_opts, duts=[] )

  # Create and reset simulator

  model.apply( DefaultPassGroup(linetrace=True) )
  model.sim_reset()

  # Helper function

  def t( raddr, waddr, wen, wdata, rdata, val):

    # Write input value to input port

    model.raddr[0] @= raddr
    model.waddr[0] @= waddr
    model.wen[0] @= wen
    model.wdata[0] @= wdata
    model.val @= val
    # Ensure that all combinational concurrent blocks are called

    model.sim_eval_combinational()

    # If reference output is not '?', verify value read from output port

    if rdata != '?':
      assert model.rdata[0] == rdata

    # Tick simulator one cycle

    model.sim_tick()

  #raddr waddr wen wdata rdata val
  t(0x00,0x00, 1,  0x02, '?', 1)
  t(0x00,0x00, 0,  0x02, '?', 1)
  t(0x00,0x01, 1,  0x08, 0x02,1)
  t(0x01,0x01, 0,  0x08, '?', 1)
  t(0x01,0x01, 0,  0x08, 0x08,1)
  t(0x01,0x01, 0,  0x08, 0x00,0)
    
