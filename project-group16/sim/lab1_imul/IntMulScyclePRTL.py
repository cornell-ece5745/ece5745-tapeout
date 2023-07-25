#=========================================================================
# Integer Multiplier Single-Cycle RTL Model
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.basic_rtl  import RegEn, RegEnRst
from .IntMulMsgs import IntMulMsgs

class IntMulScyclePRTL( Component ):

  # Constructor

  def construct( s ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'IntMulScycleRTL' )

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( IntMulMsgs.req )
    s.send = stream.ifcs.SendIfcRTL( IntMulMsgs.resp )

    # Input registers

    s.val_reg = RegEnRst(Bits1 )
    s.a_reg   = RegEn(Bits32)
    s.b_reg   = RegEn(Bits32)

    # Structional composition

    s.recv.val   //= s.val_reg.in_
    s.recv.msg.a //= s.a_reg.in_
    s.recv.msg.b //= s.b_reg.in_

    s.send.val //= s.val_reg.out
    s.send.rdy //= s.recv.rdy
    s.send.rdy //= s.val_reg.en
    s.send.rdy //= s.a_reg.en
    s.send.rdy //= s.b_reg.en

    # Combinational single-cycle multiplier

    s.result = Wire(64)

    @update
    def block():
      s.result @= sext( s.a_reg.out, 64 ) * sext( s.b_reg.out, 64 )
      s.send.msg @= s.result[0:32] & (sext(s.send.val, 32)) # 4-state sim fix

  # Line tracing

  def line_trace( s ):
    return f"{s.recv} > {s.send}"
