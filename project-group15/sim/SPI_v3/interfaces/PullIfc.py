'''
==========================================================================
PullIfc.py
==========================================================================
Master and minion of the pull interface.

Author : Yanghui Ou
  Date : Oct 6, 2021
'''

from pymtl3 import *

#-------------------------------------------------------------------------
# PullMasterIfc
#-------------------------------------------------------------------------

class PullInIfc( Interface ):

  def construct( s, Type ):
    s.en  = OutPort()
    s.msg = InPort ( Type )

    s.trace_len = len( f'{Type}' )

  def __str__( s ):
    if s.en:
      return f'{s.msg}'
    return ' '.ljust( s.trace_len )

#-------------------------------------------------------------------------
# PullMinionIfc
#-------------------------------------------------------------------------

class PullOutIfc( Interface ):

  def construct( s, Type ):
    s.en  = InPort ()
    s.msg = OutPort( Type )

    s.trace_len = len( f'{Type}' )

  def __str__( s ):
    if s.en:
      return f'{s.msg}'
    return ' '.ljust( s.trace_len )
