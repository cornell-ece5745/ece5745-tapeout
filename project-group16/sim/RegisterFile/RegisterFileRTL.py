from pymtl3 import *

class RegisterFile( Component ):

  def construct( s, Type, nregs=32, rd_ports=1, wr_ports=1,
                const_zero=False ):

    addr_type = mk_bits( max( 1, clog2( nregs ) ) )

    s.raddr = [ InPort( addr_type ) for i in range( rd_ports ) ]
    s.rdata = [ OutPort( Type ) for i in range( rd_ports ) ]
    
    s.waddr = [ InPort( addr_type ) for i in range( wr_ports ) ]
    s.wdata = [ InPort( Type ) for i in range( wr_ports ) ]
    s.wen   = [ InPort( Bits1 ) for i in range( wr_ports ) ]
    s.val   = InPort( )

    s.regs = [ Wire( Type ) for i in range(nregs) ]

    @update
    def up_rf_read():
      for i in range( rd_ports ):
          if (s.val == 1):
            s.rdata[i] @= s.regs[ s.raddr[i] ]
          else:
            s.rdata[i] @= 0

    if const_zero:
      @update_ff
      def up_rf_write_constzero():
        for i in range( wr_ports ):
          if s.wen[i] & (s.waddr[i] != 0) & s.val:
            s.regs[ s.waddr[i] ] <<= s.wdata[i]

    else:
      @update_ff
      def up_rf_write():
        for i in range( wr_ports ):
          if s.wen[i] & s.val:
            s.regs[ s.waddr[i] ] <<= s.wdata[i]
            
            
  def line_trace(s):
    return f"{s.val}|{s.wen}|{s.raddr[0]}|{s.rdata[0]}|{s.waddr[0]}|{s.wdata[0]}"
