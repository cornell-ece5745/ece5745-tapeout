from pymtl3 import *

from SPI_v3.components.SPIMinionAdapterCompositeRTL import SPIMinionAdapterCompositeRTL
from .SortUnitStructRTL import SortUnitStructRTL

class SPI_SortUnitStructRTL( Component ):

  #=======================================================================
  # Constructor
  #=======================================================================

  def construct( s, nbits=8, num_entries=5):

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------
    
    s.cs   = InPort()
    s.sclk = InPort()
    s.mosi = InPort()
    s.miso = OutPort()
 
    #--------------------------------------------------------------------- 
    # Module Instantiation
    #---------------------------------------------------------------------
    
    s.minionAdapter = ma = SPIMinionAdapterCompositeRTL((nbits*4) + 2, num_entries)
    ma.spi_min.cs //= s.cs
    ma.spi_min.sclk //= s.sclk
    ma.spi_min.mosi //= s.mosi
    ma.spi_min.miso //= s.miso

    s.SortUnit = su = SortUnitStructRTL(nbits)

    su.in_[0] //= ma.send.msg[3*nbits:4*nbits]
    su.in_[1] //= ma.send.msg[2*nbits:3*nbits]
    su.in_[2] //= ma.send.msg[nbits:2*nbits]
    su.in_[3] //= ma.send.msg[0:nbits]

    su.in_val //= ma.send.val
    ma.send.rdy //= su.in_rdy

    su.out[0] //= ma.recv.msg[3*nbits:4*nbits]
    su.out[1] //= ma.recv.msg[2*nbits:3*nbits]
    su.out[2] //= ma.recv.msg[nbits:2*nbits]
    su.out[3] //= ma.recv.msg[0:nbits]

    su.out_val //= ma.recv.val
    su.out_rdy //= ma.recv.rdy
    
    
  #=======================================================================
  # Line tracing
  #=======================================================================

  def line_trace( s ):
    
    def trace_val_elm( val, elm ):
      str_ = '{{{},{},{},{}}}'.format( elm[0], elm[1], elm[2], elm[3] )
      if not val:
        str_ = ' '*len(str_)
      return str_

    return "{}|{}|{}|{}|{}".format(
      trace_val_elm( s.SortUnit.in_val,        s.SortUnit.in_                         ),
      trace_val_elm( s.SortUnit.val_S0S1.out,  [ m.out for m in s.SortUnit.elm_S0S1 ] ),
      trace_val_elm( s.SortUnit.val_S1S2.out,  [ m.out for m in s.SortUnit.elm_S1S2 ] ),
      trace_val_elm( s.SortUnit.val_S2S3.out,  [ m.out for m in s.SortUnit.elm_S2S3 ] ),
      trace_val_elm( s.SortUnit.out_val,       s.SortUnit.out                         ),
    )