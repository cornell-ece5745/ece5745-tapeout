#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in IntMulAltPRTL) or set this variable to
# 'verilog' if you are using Verilog for your RTL design (i.e., your
# design is in IntMulAltVRTL).

rtl_language = 'pymtl'

#-------------------------------------------------------------------------
# Do not edit below this line
#-------------------------------------------------------------------------

# This is the PyMTL wrapper for the corresponding Verilog RTL model.

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

from pymtl3.stdlib import stream
from pymtl3.stdlib.mem import mk_mem_msg

from .XcelMsg import XcelReqMsg, XcelRespMsg

class ProcVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, num_cores=1 ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'ProcRTL_{num_cores}cores' )

    # Configurations

    MemReqMsg, MemRespMsg = mk_mem_msg( 8, 32, 32 )

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    # Starting F16 we turn core_id into input ports to
    # enable module reusability. In the past it was passed as arguments.

    s.core_id   = InPort( Bits32 )

    # Proc/Mngr Interface

    s.mngr2proc = stream.ifcs.RecvIfcRTL( Bits32 )
    s.proc2mngr = stream.ifcs.SendIfcRTL( Bits32 )

    # Instruction Memory Request/Response Interface

    s.imem = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )

    # Data Memory Request/Response Interface

    s.dmem = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )

    # Accelerator Request/Response Interface

    s.xcel = stream.ifcs.MasterIfcRTL( XcelReqMsg, XcelRespMsg )

    # val_W port used for counting commited insts.

    s.commit_inst = OutPort()

    # stats_en

    s.stats_en    = OutPort()

    from os import path

    s.set_metadata( VerilogPlaceholderPass.params, { 'p_num_cores' : num_cores } )
    s.set_metadata( VerilogPlaceholderPass.port_map, {
      s.core_id     : 'core_id',
      s.commit_inst : 'commit_inst',
      s.stats_en    : 'stats_en',

      s.imem.req.val  : 'imemreq_val',
      s.imem.req.rdy  : 'imemreq_rdy',
      s.imem.req.msg  : 'imemreq_msg',

      s.imem.resp.val : 'imemresp_val',
      s.imem.resp.rdy : 'imemresp_rdy',
      s.imem.resp.msg : 'imemresp_msg',

      s.dmem.req.val  : 'dmemreq_val',
      s.dmem.req.rdy  : 'dmemreq_rdy',
      s.dmem.req.msg  : 'dmemreq_msg',

      s.dmem.resp.val : 'dmemresp_val',
      s.dmem.resp.rdy : 'dmemresp_rdy',
      s.dmem.resp.msg : 'dmemresp_msg',


      s.xcel.req.val  : 'xcelreq_val',
      s.xcel.req.rdy  : 'xcelreq_rdy',
      s.xcel.req.msg  : 'xcelreq_msg',

      s.xcel.resp.val  : 'xcelresp_val',
      s.xcel.resp.rdy  : 'xcelresp_rdy',
      s.xcel.resp.msg  : 'xcelresp_msg',

      s.proc2mngr.val  : 'proc2mngr_val',
      s.proc2mngr.rdy  : 'proc2mngr_rdy',
      s.proc2mngr.msg  : 'proc2mngr_msg',

      s.mngr2proc.val  : 'mngr2proc_val',
      s.mngr2proc.rdy  : 'mngr2proc_rdy',
      s.mngr2proc.msg  : 'mngr2proc_msg',
    })

    # s.set_metadata( VerilogVerilatorImportPass.vl_line_trace, True )

# See if the course staff want to force testing a specific RTL language
# for their own testing.

import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .ProcPRTL import ProcPRTL as ProcRTL
elif rtl_language == 'verilog':
  ProcRTL = ProcVRTL
else:
  raise Exception("Invalid RTL language!")
