#=========================================================================
# Memory controller
#=========================================================================

from pymtl3 import *

BITWIDTH = Bits16

# Hardcode to Bits25 currently
@bitstruct
class MemReqMsgs:
  recv_msg_data: BITWIDTH
  recv_msg_mode: Bits1
  recv_msg_run: Bits1

@bitstruct
class MemRespMsgs:
  send_msg_data: BITWIDTH
  send_msg_mode: Bits1
  send_msg_run : Bits1

class MemMsgs:
  recv = SystolicReqMsgs
  send = SystolicRespMsgs