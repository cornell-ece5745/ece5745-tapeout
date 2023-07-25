#=========================================================================
# Echo Unit RTL Model
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

from project.echo.EchoUnitMsg import EchoUnitMsgs

#=========================================================================
# Echo Unit RTL Model
#=========================================================================

class EchoUnitRTL ( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( EchoUnitMsgs.req )
    s.send = stream.ifcs.SendIfcRTL( EchoUnitMsgs.resp )
