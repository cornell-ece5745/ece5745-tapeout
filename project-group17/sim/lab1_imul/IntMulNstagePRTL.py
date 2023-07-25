#=========================================================================
# Integer Multiplier N-Stage Pipelined RTL Model
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.basic_rtl import RegEnRst, RegEn

from .IntMulMsgs import IntMulMsgs

# ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Import your partial product step model here. Make sure you unit test it!
# ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

from .IntMulNstageStepRTL import IntMulNstageStepRTL

# ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

class IntMulNstagePRTL( Component ):

  # Constructor

  def construct( s, nstages=2 ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'IntMulNstageRTL__nstages_{nstages}' )

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( IntMulMsgs.req )
    s.send = stream.ifcs.SendIfcRTL( IntMulMsgs.resp )

    # ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''
    # Instantiate the partial product steps here. Your design should be
    # parameterized by the number of pipeline stages given by the nstages
    # parameter.
    # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

    # We currently only support power of two number of stages

    assert nstages in [1,2,4,8,16,32]
    nsteps = 32 / nstages

    # Input registers

    s.val_reg = RegEnRst(Bits1)
    s.a_reg   = RegEn(Bits32)
    s.b_reg   = RegEn(Bits32)

    s.val_reg.in_ //= s.recv.val
    s.val_reg.en  //= s.send.rdy

    s.a_reg.in_ //= s.recv.msg.a
    s.a_reg.en  //= s.send.rdy

    s.b_reg.in_ //= s.recv.msg.b
    s.b_reg.en  //= s.send.rdy

    # Instantiate steps

    s.steps = [ IntMulNstageStepRTL() for _ in range(32) ]

    # Structural composition for first step

    s.steps[0].in_result //= 0
    s.steps[0].in_val    //= s.val_reg.out
    s.steps[0].in_a      //= s.a_reg.out
    s.steps[0].in_b      //= s.b_reg.out

    # Pipeline registers

    s.val_preg    = [ RegEnRst(Bits1)  for _ in range(nstages-1) ]
    s.a_preg      = [ RegEn(Bits32) for _ in range(nstages-1) ]
    s.b_preg      = [ RegEn(Bits32) for _ in range(nstages-1) ]
    s.result_preg = [ RegEn(Bits32) for _ in range(nstages-1) ]

    # Structural composition for intermediate steps

    nstage = 0
    for i in range(1,32):

      # Insert a pipeline register

      if i % nsteps == 0:

        #  print "-- pipe reg --"
        #  print "step = {}".format(i)

        s.val_preg[nstage].in_    //= s.steps[i-1].out_val
        s.a_preg[nstage].in_      //= s.steps[i-1].out_a
        s.b_preg[nstage].in_      //= s.steps[i-1].out_b
        s.result_preg[nstage].in_ //= s.steps[i-1].out_result

        s.steps[i].in_val         //= s.val_preg[nstage].out
        s.steps[i].in_a           //= s.a_preg[nstage].out
        s.steps[i].in_b           //= s.b_preg[nstage].out
        s.steps[i].in_result      //= s.result_preg[nstage].out

        s.val_preg[nstage].en     //= s.send.rdy
        s.a_preg[nstage].en       //= s.send.rdy
        s.b_preg[nstage].en       //= s.send.rdy
        s.result_preg[nstage].en  //= s.send.rdy

        nstage += 1

      # No pipeline register

      else:

        #  print "step = {}".format(i)

        s.steps[i].in_val    //= s.steps[i-1].out_val
        s.steps[i].in_a      //= s.steps[i-1].out_a
        s.steps[i].in_b      //= s.steps[i-1].out_b
        s.steps[i].in_result //= s.steps[i-1].out_result

    # Structural composition for last step

    s.send.val //= s.steps[31].out_val
    s.send.msg //= lambda: s.steps[31].out_result & (sext(s.send.val, 32)) # 4-state sim fix

    # Wire resp rdy to req rdy

    s.recv.rdy //= s.send.rdy

    # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

  # Line tracing

  def line_trace( s ):

    s.trace = ""

    # ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''
    # Add line tracing code here.
    # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

    s.trace = "{}({}{}){}".format(
      s.recv,
      ('*' if s.val_reg.out else ' '),
      ''.join([ ('*' if x.out else ' ') for x in s.val_preg ]),
      s.send
    )

    # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

    return s.trace

