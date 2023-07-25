#=========================================================================
# SystolicMsgs
#=========================================================================

from pymtl3 import *

DATAWIDTH = Bits25

# Hardcode to Bits25 currently
@bitstruct
class MERecvMsgs:
  recv_msg_data: DATAWIDTH
  recv_msg_mode: Bits1
  recv_msg_run: Bits1

@bitstruct
class MESendMsgs:
  send_msg_data: DATAWIDTH

class MEMsgs:
  recv = MERecvMsgs
  send = MESendMsgs