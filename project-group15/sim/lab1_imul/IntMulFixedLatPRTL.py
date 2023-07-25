#=========================================================================
# Integer Multiplier Fixed Latency RTL Model
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.basic_rtl import Mux, Reg, RegEn, RegRst, LeftLogicalShifter, RightLogicalShifter, Adder, ZeroComparator

from .IntMulMsgs import IntMulMsgs

#=========================================================================
# Constants
#=========================================================================

A_MUX_SEL_NBITS      = 1
A_MUX_SEL_LSH        = 0
A_MUX_SEL_LD         = 1
A_MUX_SEL_X          = 0

B_MUX_SEL_NBITS      = 1
B_MUX_SEL_RSH        = 0
B_MUX_SEL_LD         = 1
B_MUX_SEL_X          = 0

RESULT_MUX_SEL_NBITS = 1
RESULT_MUX_SEL_ADD   = 0
RESULT_MUX_SEL_0     = 1
RESULT_MUX_SEL_X     = 0

ADD_MUX_SEL_NBITS    = 1
ADD_MUX_SEL_ADD      = 0
ADD_MUX_SEL_RESULT   = 1
ADD_MUX_SEL_X        = 0

#=========================================================================
# Integer Multiplier Fixed Latency Datapath
#=========================================================================

class IntMulFixedLatDpathRTL( Component ):

  def construct( s ):

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    s.req_msg_a      = InPort ( 32 )
    s.req_msg_b      = InPort ( 32 )
    s.resp_msg       = OutPort( 32 )

    # Control signals (ctrl -> dpath)

    s.a_mux_sel      = InPort( A_MUX_SEL_NBITS )
    s.b_mux_sel      = InPort( B_MUX_SEL_NBITS )
    s.result_mux_sel = InPort( RESULT_MUX_SEL_NBITS )
    s.result_reg_en  = InPort()
    s.add_mux_sel    = InPort( ADD_MUX_SEL_NBITS )

    # Status signals (dpath -> ctrl)

    s.b_lsb          = OutPort()

    #---------------------------------------------------------------------
    # Struction composition
    #---------------------------------------------------------------------

    # B mux

    s.rshifter_out = Wire( Bits32 )

    s.b_mux = m = Mux( Bits32, 2 )
    m.sel //= s.b_mux_sel
    m.in_[B_MUX_SEL_RSH] //= s.rshifter_out
    m.in_[B_MUX_SEL_LD ] //= s.req_msg_b

    # B register

    s.b_reg = Reg( Bits32 )
    s.b_reg.in_ //= s.b_mux.out

    # Right shifter

    s.rshifter = m = RightLogicalShifter( Bits32, 32 )
    m.in_   //= s.b_reg.out
    m.shamt //= 1
    m.out   //= s.rshifter_out

    # A mux

    s.lshifter_out = Wire( Bits32 )

    s.a_mux = m = Mux( Bits32, 2 )
    m.sel //= s.a_mux_sel
    m.in_[A_MUX_SEL_LSH] //= s.lshifter_out
    m.in_[A_MUX_SEL_LD ] //= s.req_msg_a

    # A register

    s.a_reg = Reg( Bits32 )
    s.a_reg.in_ //= s.a_mux.out

    # Left shifter

    s.lshifter = m = LeftLogicalShifter( Bits32, 32 )
    m.in_   //= s.a_reg.out
    m.shamt //= 1
    m.out   //= s.lshifter_out

    # Result mux

    s.add_mux_out = Wire( Bits32 )

    s.result_mux = m = Mux( Bits32, 2 )
    m.sel //= s.result_mux_sel
    m.in_[RESULT_MUX_SEL_ADD] //= s.add_mux_out
    m.in_[RESULT_MUX_SEL_0  ] //= 0

    # Result register

    s.result_reg = m = RegEn( Bits32 )
    m.en  //= s.result_reg_en
    m.in_ //= s.result_mux.out

    # Adder

    s.add = m = Adder( Bits32 )
    m.in0 //= s.a_reg.out
    m.in1 //= s.result_reg.out

    # Add mux

    s.add_mux = m = Mux( Bits32, 2 )
    m.sel //= s.add_mux_sel
    m.in_[ADD_MUX_SEL_ADD   ] //= s.add.out
    m.in_[ADD_MUX_SEL_RESULT] //= s.result_reg.out
    m.out //= s.add_mux_out

    # Status signals

    s.b_lsb //= s.b_reg.out[0]

    # Connect to output port

    s.resp_msg //= s.result_reg.out

#=========================================================================
# Integer Multiplier Fixed Latency Control
#=========================================================================

class IntMulFixedLatCtrlRTL( Component ):

  def construct( s ):

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    s.req_val        = InPort  ()
    s.req_rdy        = OutPort ()

    s.resp_val       = OutPort ()
    s.resp_rdy       = InPort  ()

    # Control signals (ctrl -> dpath)

    s.a_mux_sel      = OutPort ( A_MUX_SEL_NBITS )
    s.b_mux_sel      = OutPort ( B_MUX_SEL_NBITS )
    s.result_mux_sel = OutPort ( RESULT_MUX_SEL_NBITS )
    s.result_reg_en  = OutPort ()
    s.add_mux_sel    = OutPort ( ADD_MUX_SEL_NBITS )

    # Status signals (dpath -> ctrl)

    s.b_lsb          = InPort ()

    # State element

    s.STATE_IDLE  = b2(0)
    s.STATE_CALC  = b2(1)
    s.STATE_DONE  = b2(2)

    s.state    = Wire( Bits2 )
    s.counter  = RegRst( Bits6, reset_value = 31 )

    #---------------------------------------------------------------------
    # State transitions
    #---------------------------------------------------------------------

    @update_ff
    def state_transitions():

      if s.reset:
        s.state <<= s.STATE_IDLE

      # Transistions out of IDLE state

      elif s.state == s.STATE_IDLE:
        if s.req_val:
          s.state <<= s.STATE_CALC

      # Transistions out of CALC state

      if s.state == s.STATE_CALC:
        if s.counter.out == 0:
          s.state <<= s.STATE_DONE

      # Transistions out of DONE state

      if s.state == s.STATE_DONE:
        if s.resp_rdy:
          s.state <<= s.STATE_IDLE

    #---------------------------------------------------------------------
    # State outputs
    #---------------------------------------------------------------------

    s.do_sh_add = Wire()
    s.do_sh     = Wire()

    @update
    def state_outputs():

      # Initialize all control signals

      s.do_sh_add      @= 0
      s.do_sh          @= 0

      s.req_rdy        @= 0
      s.resp_val       @= 0

      s.a_mux_sel      @= 0
      s.b_mux_sel      @= 0
      s.result_mux_sel @= 0
      s.result_reg_en  @= 0
      s.add_mux_sel    @= 0

      s.counter.in_    @= 0

      # In IDLE state we simply wait for inputs to arrive and latch them

      if s.state == s.STATE_IDLE:

        s.req_rdy        @= 1
        s.resp_val       @= 0

        s.a_mux_sel      @= A_MUX_SEL_LD
        s.b_mux_sel      @= B_MUX_SEL_LD
        s.result_mux_sel @= RESULT_MUX_SEL_0
        s.result_reg_en  @= 1
        s.add_mux_sel    @= ADD_MUX_SEL_X

        s.counter.in_    @= 31

      # In CALC state we iteratively add/shift to caculate mult

      elif s.state == s.STATE_CALC:

        s.do_sh_add      @= s.b_lsb == 1 # do shift and add
        s.do_sh          @= s.b_lsb == 0 # do shift but no add

        s.req_rdy        @= 0
        s.resp_val       @= 0

        s.a_mux_sel      @= A_MUX_SEL_LSH
        s.b_mux_sel      @= B_MUX_SEL_RSH
        s.result_mux_sel @= RESULT_MUX_SEL_ADD
        s.result_reg_en  @= 1
        if s.do_sh_add:
          s.add_mux_sel  @= ADD_MUX_SEL_ADD
        else:
          s.add_mux_sel  @= ADD_MUX_SEL_RESULT

        s.counter.in_    @= s.counter.out - 1

      # In DONE state we simply wait for output transition to occur

      elif s.state == s.STATE_DONE:

        s.req_rdy        @= 0
        s.resp_val       @= 1

        s.a_mux_sel      @= A_MUX_SEL_X
        s.b_mux_sel      @= B_MUX_SEL_X
        s.result_mux_sel @= RESULT_MUX_SEL_X
        s.result_reg_en  @= 0
        s.add_mux_sel    @= ADD_MUX_SEL_X

        s.counter.in_    @= 31

#=========================================================================
# Integer Multiplier Fixed Latency
#=========================================================================

class IntMulFixedLatPRTL( Component ):

  # Constructor

  def construct( s ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'IntMulFixedLatRTL' )

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( IntMulMsgs.req )
    s.send = stream.ifcs.SendIfcRTL( IntMulMsgs.resp )

    # Instantiate datapath and control

    s.dpath = IntMulFixedLatDpathRTL()
    s.ctrl  = IntMulFixedLatCtrlRTL()


    # Connections

    s.recv.msg.a //= s.dpath.req_msg_a 
    s.recv.msg.b //= s.dpath.req_msg_b 
    s.send.msg   //= lambda: s.dpath.resp_msg & (sext(s.ctrl.resp_val, 32))

    s.recv.val //= s.ctrl.req_val 
    s.recv.rdy //= s.ctrl.req_rdy 
    s.send.val //= s.ctrl.resp_val 
    s.send.rdy //= s.ctrl.resp_rdy 

    s.ctrl.a_mux_sel      //= s.dpath.a_mux_sel
    s.ctrl.b_mux_sel      //= s.dpath.b_mux_sel
    s.ctrl.result_mux_sel //= s.dpath.result_mux_sel
    s.ctrl.result_reg_en  //= s.dpath.result_reg_en
    s.ctrl.add_mux_sel    //= s.dpath.add_mux_sel
    s.ctrl.b_lsb          //= s.dpath.b_lsb

  # Line tracing

  def line_trace( s ):

    if s.ctrl.state == s.ctrl.STATE_IDLE:
      line_trace_str = "I "

    elif s.ctrl.state == s.ctrl.STATE_CALC:
      if s.ctrl.do_sh_add:
        line_trace_str = "C+"
      elif s.ctrl.do_sh:
        line_trace_str = "C "
      else:
        line_trace_str = "C?"

    elif s.ctrl.state == s.ctrl.STATE_DONE:
      line_trace_str = "D "

    return "({} {} {} {})".format(
      s.dpath.a_reg.out,
      s.dpath.b_reg.out,
      s.dpath.result_reg.out,
      line_trace_str,
    )


