#=========================================================================
# PeConfigMsgs
#=========================================================================

from pymtl3 import *

# Hardcode to Bits32 for lab1
@bitstruct
class PeConfigReqMsgs:
  base_addr:   Bits32
  num_rows:    Bits32
  num_nnz:     Bits32
  num_rows_pe: Bits32

class PeConfigMsgs:
  req = PeConfigReqMsgs
  resp = Bits1 #responds 1 when successfully configured