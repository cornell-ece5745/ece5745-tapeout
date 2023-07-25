#=========================================================================
# ReaderUnitMsgs
#=========================================================================

from pymtl3 import *

@bitstruct
class ReaderUnitReqMsg:
  base_addr: Bits32
  size: Bits32

@bitstruct
class ReaderUnitRespMsg:
  data: Bits32
  done: Bits1

class ReaderUnitMsgs:
  req  = ReaderUnitReqMsg
  resp = ReaderUnitRespMsg
