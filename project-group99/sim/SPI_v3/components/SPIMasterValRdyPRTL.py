'''
==========================================================================
SPIMasterValRdyPRTL.py
==========================================================================
SPIMaster module for sending messages over SPI.
Supports SPI mode 0.

Author : Kyle Infantino
  Date : April 26, 2022

'''

from pymtl3 import *
from .ShiftReg import ShiftReg, ShiftRegExtRst

from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL
from pymtl3.stdlib.basic_rtl.registers import RegEnRst
from ..interfaces.SPIIfc import SPIMasterIfc


class SPIMasterValRdyPRTL( Component ):

  def construct( s, nbits=8, ncs=1 ):

    # Local parameters
    s.nbits = nbits                      # size of message
    s.ncs = ncs                          # number of chip select lines
    s.logBitsN = mk_bits(clog2(nbits)+1) # number of bits required to count to packet size
    s.logCSN = mk_bits(clog2(s.ncs) if s.ncs > 1 else 1)

    # Interface
    s.spi_ifc = SPIMasterIfc( ncs )

    s.send = SendIfcRTL( mk_bits(s.nbits) )
    s.recv = RecvIfcRTL( mk_bits(s.nbits) )

    s.packet_size_ifc = RecvIfcRTL( s.logBitsN ) # size of spi packet (up to nbits)
    s.cs_addr_ifc = RecvIfcRTL( s.logCSN )

    s.packet_size_reg = m = RegEnRst( s.logBitsN )
    m.in_ //= s.packet_size_ifc.msg 

    s.cs_addr_reg = m = RegEnRst( s.logCSN )
    m.in_ //= s.cs_addr_ifc.msg

    s.packet_size_ifc.rdy //= s.recv.rdy
    s.cs_addr_ifc.rdy     //= s.recv.rdy

    s.sclk_negedge = Wire()
    s.sclk_posedge = Wire()
    s.shreg_in_rst = Wire()

    # Components & Logic
    s.STATE_INIT        = 0
    s.STATE_START0      = 1 # pull chip select low
    s.STATE_START1      = 2 # wait a cycle
    s.STATE_SCLK_HIGH   = 3 # start toggling sclk
    s.STATE_SCLK_LOW    = 4
    s.STATE_CS_LOW_WAIT = 5
    s.STATE_DONE        = 6

    s.state = Wire(3)
    s.nextState = Wire(3)
    @update_ff
    def up_state():
      if s.reset: s.state <<= 0
      else: s.state <<= s.nextState

    @update
    def up_stateChange():
      if s.state == s.STATE_INIT: 
        if s.recv.val: s.nextState @= s.STATE_START0
        else: s.nextState @= s.STATE_INIT
        
      elif s.state == s.STATE_START0: 
        s.nextState @= s.STATE_START1
        
      elif s.state == s.STATE_START1: 
        s.nextState @= s.STATE_SCLK_HIGH

      elif s.state == s.STATE_SCLK_HIGH: #sclk toggle low
        s.nextState @= s.STATE_SCLK_LOW

      elif s.state == s.STATE_SCLK_LOW: #sclk toggle high
        if s.sclk_counter == 0: s.nextState @= s.STATE_CS_LOW_WAIT
        else: s.nextState @= s.STATE_SCLK_HIGH

      elif s.state == s.STATE_CS_LOW_WAIT:
        s.nextState @= s.STATE_DONE
      
      elif s.state == s.STATE_DONE: 
        if s.recv.val: s.nextState @= s.STATE_START0 # if you get another req, immediately start another transaction
        elif s.send.rdy: s.nextState @= s.STATE_INIT # if the data is read from the master, go back to INIT
        else: s.nextState @= s.STATE_DONE

      else: #default
        s.nextState @= s.STATE_INIT

    #=====================================================================
    # State Outputs
    #=====================================================================

    @update
    def up_stateOutputs():
      s.recv.rdy            @= 0 
      s.send.val            @= 0 
      s.spi_ifc.sclk        @= 0
      s.packet_size_reg.en  @= 0
      s.cs_addr_reg.en      @= 0
      for i in range(ncs):
        s.spi_ifc.cs[i]     @= 1
      s.sclk_negedge        @= 0
      s.sclk_posedge        @= 0
      s.sclk_counter_en     @= 0
      s.shreg_in_rst       @= 0
      
      #-------------------------------------------------------------------
      # STATE: INIT
      #-------------------------------------------------------------------
      if s.state == s.STATE_INIT: #init
        s.recv.rdy            @= 1
        s.packet_size_reg.en  @= s.packet_size_ifc.val
        s.cs_addr_reg.en      @= s.cs_addr_ifc.val
      #-------------------------------------------------------------------
      # STATE: START0
      #-------------------------------------------------------------------    
      elif s.state == s.STATE_START0: #start
        s.spi_ifc.cs[s.cs_addr_reg.out] @= 0
        s.shreg_in_rst                 @= 1
      #-------------------------------------------------------------------
      # STATE: START1
      #------------------------------------------------------------------- 
      elif s.state == s.STATE_START1: #start
        s.sclk_posedge @= 1
        s.spi_ifc.cs[s.cs_addr_reg.out] @= 0
      #-------------------------------------------------------------------
      # STATE: SCLK_HIGH
      #------------------------------------------------------------------- 
      elif s.state == s.STATE_SCLK_HIGH:
        s.spi_ifc.cs[s.cs_addr_reg.out] @= 0
        s.spi_ifc.sclk @= 1
        s.sclk_negedge @= 1
        s.sclk_counter_en @= 1
      #-------------------------------------------------------------------
      # STATE: SCLK_LOW
      #------------------------------------------------------------------- 
      elif s.state == s.STATE_SCLK_LOW:
        s.sclk_posedge @= (s.sclk_counter != 0) # will not go high again if all bits were already read
        s.spi_ifc.cs[s.cs_addr_reg.out] @= 0
      #-------------------------------------------------------------------
      # STATE: CS_LOW_WAIT
      #------------------------------------------------------------------- 
      elif s.state == s.STATE_CS_LOW_WAIT:
        s.spi_ifc.cs[s.cs_addr_reg.out] @= 0
      #-------------------------------------------------------------------
      # STATE: DONE
      #------------------------------------------------------------------- 
      elif s.state == s.STATE_DONE: #done
        s.recv.rdy @= 1
        s.send.val @= 1
        s.packet_size_reg.en  @= s.packet_size_ifc.val
        s.cs_addr_reg.en      @= s.cs_addr_ifc.val

    # sclk counter logic
    s.sclk_counter = Wire(s.logBitsN)
    s.sclk_counter_en = Wire(1)
    @update_ff
    def up_sclk_counter():
      if s.reset: s.sclk_counter <<= 0
      elif (s.recv.val & s.recv.rdy): s.sclk_counter <<= s.packet_size_reg.out
      elif s.sclk_counter_en: s.sclk_counter <<= s.sclk_counter - 1

    # Datapath
    s.shreg_in = m = ShiftRegExtRst( s.nbits )
    m.in_       //= s.spi_ifc.miso
    m.shift_en  //= s.sclk_posedge 
    m.load_en   //= 0
    m.load_data //= 0
    m.ext_reset //= s.shreg_in_rst

    s.shreg_out = m = ShiftReg( s.nbits )
    m.in_       //= 0
    m.shift_en  //= s.sclk_negedge
    m.load_en   //= lambda: s.recv.rdy & s.recv.val
    m.load_data //= lambda: s.recv.msg << zext(((s.nbits-s.packet_size_reg.out)), s.nbits) # put message into most significant bits

    s.spi_ifc.mosi     //= s.shreg_out.out[nbits-1]
    s.send.msg //= s.shreg_in.out

  def line_trace( s ):
    return f'mosi{s.spi_ifc.mosi}|miso{s.spi_ifc.miso}|sclk{s.spi_ifc.sclk}[cs{s.spi_ifc.cs[0]}]st{s.state}|rcv{s.recv.val}|rcd{s.recv.rdy}'
