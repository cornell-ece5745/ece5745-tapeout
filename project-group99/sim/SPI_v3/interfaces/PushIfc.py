'''
==========================================================================
PushIfc.py
==========================================================================
Master and minion of the push interface.

Author : Yanghui Ou
  Date : Oct 6, 2021
'''

from pymtl3 import *

#-------------------------------------------------------------------------
# PushMasterIfc
#-------------------------------------------------------------------------

class PushOutIfc( Interface ):

  def construct( s, Type ):
    s.en  = OutPort()
    s.msg = OutPort( Type )

    s.trace_len = len( f'{Type}' )

  def __str__( s ):
    if s.en:
      return f'{s.msg}'
    return ' '.ljust( s.trace_len )

#-------------------------------------------------------------------------
# PushMinionIfc
#-------------------------------------------------------------------------

class PushInIfc( Interface ):

  def construct( s, Type ):
    s.en  = InPort()
    s.msg = InPort( Type )

    s.trace_len = len( f'{Type}' )

  def __str__( s ):
    if s.en:
      return f'{s.msg}'
    return ' '.ljust( s.trace_len )
