#=========================================================================
# WrapperMsgs
#=========================================================================

from pymtl3 import *

BITWIDTH = Bits16
NUMCHIP = Bits4
DATA_ENTRIES = 2

# Hardcode to Bits25 currently
@bitstruct
class WrapperReqMsgs:
  recv_msg_data: BITWIDTH
  recv_msg_chip_select: NUMCHIP
  recv_msg_mode: Bits1
  recv_msg_run: Bits1
  recv_msg_final_run: Bits1

@bitstruct
class WrapperRespMsgs:
  send_msg_result_0: BITWIDTH
  send_msg_result_1: BITWIDTH

class WrapperMsgs:
  recv = WrapperReqMsgs
  send = WrapperRespMsgs