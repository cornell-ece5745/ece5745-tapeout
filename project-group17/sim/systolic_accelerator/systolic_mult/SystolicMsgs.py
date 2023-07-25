#=========================================================================
# SystolicMsgs
#=========================================================================

from pymtl3 import *

BITWIDTH = Bits16

# Hardcode to Bits25 currently
@bitstruct
class SystolicReqMsgs:
  recv_msg_weight_0: BITWIDTH
  recv_msg_weight_1: BITWIDTH
  recv_msg_data_0: BITWIDTH
  recv_msg_data_1: BITWIDTH
  recv_msg_mode: Bits1
  recv_msg_run: Bits1
  recv_msg_final_run: Bits1

@bitstruct
class SystolicRespMsgs:
  send_msg_result_0: BITWIDTH
  send_msg_result_1: BITWIDTH

class SystolicMsgs:
  recv = SystolicReqMsgs
  send = SystolicRespMsgs