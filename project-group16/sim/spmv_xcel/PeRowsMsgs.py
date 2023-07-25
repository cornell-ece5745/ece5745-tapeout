#=========================================================================
# PeRowsMsgs
#=========================================================================

from pymtl3 import *

# Hardcode to Bits32 for lab1
@bitstruct
class PeRowsReqMsg:
  row_start: Bits32
  row_end  : Bits32
  row_idx  : Bits32

class PeRowsMsgs:
  req = PeRowsReqMsg
  resp = Bits1