#=========================================================================
# EchoUnitMsg_test
#=========================================================================
# Test suite for the Echo unit message

from pymtl3 import *

from  echo.EchoUnitMsg import EchoUnitMsgs

#-------------------------------------------------------------------------
# test_fields
#-------------------------------------------------------------------------

def test_fields():

  # Create msg

  msg = EchoUnitMsgs
  msg.req = b11(1)
  msg.resp = b11(2)

  assert msg.req == 1
  assert msg.resp == 2
