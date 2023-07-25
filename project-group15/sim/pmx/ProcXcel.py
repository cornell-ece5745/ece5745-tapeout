#=========================================================================
# ProcXcel
#=========================================================================
# No caches, just processor + accelerator

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.mem import mk_mem_msg, MemMasterIfcRTL

class ProcXcel( Component ):

  #-----------------------------------------------------------------------
  # constructor
  #-----------------------------------------------------------------------

  def construct( s, proc, xcel ):

    CacheReqType, CacheRespType = mk_mem_msg( 8, 32, 32 )
    MemReqType,   MemRespType   = mk_mem_msg( 8, 32, 128 )

    # interface to outside ProcMemXcel

    s.go        = InPort ()
    s.stats_en  = OutPort()
    s.commit_inst = OutPort()

    s.proc = proc
    s.xcel = xcel

    # More interfaces that replicates the proc interface
    s.mngr2proc = stream.ifcs.RecvIfcRTL( Type=Bits32 )
    s.mngr2proc //= s.proc.mngr2proc

    s.proc2mngr = stream.ifcs.SendIfcRTL( Type=Bits32 )
    s.proc2mngr //= s.proc.proc2mngr

    s.imem = stream.ifcs.MasterIfcRTL( CacheReqType, CacheRespType )
    s.imem //= s.proc.imem

    s.dmem = stream.ifcs.MasterIfcRTL( CacheReqType, CacheRespType )
    s.dmem //= s.proc.dmem

    s.xmem = stream.ifcs.MasterIfcRTL( CacheReqType, CacheRespType )
    s.xmem //= s.xcel.mem

    # connect signals

    s.proc.core_id //= 0

    s.stats_en  //= s.proc.stats_en
    s.commit_inst //= s.proc.commit_inst

    # xcel

    s.xcel.xcel //= s.proc.xcel


  def line_trace( s ):
    return s.proc.line_trace() + "|||" + s.xcel.line_trace()


