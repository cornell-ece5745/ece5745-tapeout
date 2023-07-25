'''
==========================================================================
SPITestHarness.py
==========================================================================
Test harness for sending messages over SPI. For use with SPIMinionAdapterComposite module

Author : Kyle Infantino and Dilan Lakhani
  Date : Jan 30, 2022
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from math import ceil
import copy
from spidriver import SPIDriver
import sys

#=========================================================================
# TestHarness
#=========================================================================

class SPITestHarness( object ):

  #-----------------------------------------------------------------------
  # constructor
  #-----------------------------------------------------------------------
 
  #-----------------------------------------------------------------------
  # DESIGN: instantiation of RTL design
  # num_components: number of components that can be addressed
  # spi_bits: number of bits in an spi packet. Each packet consists of 2 
  #           flow control bits, (optional) component address bits, and the data
  #-----------------------------------------------------------------------
  def __init__( s, DESIGN, num_components, spi_bits, cmdline_opts, trace=True ):
 
    s.dut = DESIGN
    s.is_phy_test = sys._is_physical  # Use the --physical flag if you want to use the Physical Test Harness and the SPIDriver
    s.dut = config_model_with_cmdline_opts( s.dut, cmdline_opts, [] )
    s.dut.apply(DefaultPassGroup(linetrace=True)) #commented out for chip-sim
    # from pymtl3.passes.mamba import Mamba2020
    # s.dut.apply( Mamba2020( print_line_trace=trace ) )

    if s.is_phy_test:
      port = '/dev/ttyUSB0'
      # keep retrying since SPI Driver sometimes doesnt work
      while True:
        try:
          s.driver = SPIDriver(port) # change for your port
        except KeyboardInterrupt:
          print("Got control-C while trying to connect to SPIDriver, exiting")
          exit()
        except:
          continue
        break
      
      # s.driver.setmode(3) # set to SPI mode 3
      s.driver.unsel() # raise CS line
      s.driver.seta(1) # reset the chip
      s.driver.setb(looparound) # Set the chip to looparound/passthrough mode 
      s.driver.seta(0) # Take chip out of reset
    else:
      s.dut.spi_min.cs @= 1
      s.dut.spi_min.sclk @= 0
      s.dut.spi_min.mosi @= 0
      s.dut.spi_min.miso @= 0

    s.dut.sim_reset() # Reset the simulator

    s.spi_bits = spi_bits
    s.component_bits = 0 if num_components < 2 else clog2(num_components)
    s.spi_msg_bits = s.spi_bits - s.component_bits - 2 # 2 valid bits that we do not want to account for when splitting message

  #-----------------------------------------------------------------------
  # req/resp_len: number of bits of req/resp message
  # request_list: array of messages to send to DUT
  # expected_resp_list: array of expected message to receive from DUT. If print_msgs is True, list can be filled with don't cares
  # components_addr: index of component messages are being sent to
  # return_msgs: False indicates actual responses will be compared to the expected responses. 
  #             True indicates the actual responses will be returned instead. Returns format [actual response addresses], [actual response messages]
  #             The length of expected_resp_list must be equal to the number of messages to be printed
  #-----------------------------------------------------------------------
  def t_mult_msg(s, req_len, request_list, resp_len, expected_resp_list, component_addr=0, return_msgs=False ):#send messages

    if req_len > 0:
      req_BitsN = mk_bits(req_len)
    
    if resp_len > 0:
      resp_BitsN = mk_bits(resp_len)

    if s.component_bits > 0:
      comp_addr = mk_bits(s.component_bits)(component_addr)

    #create req messages
    all_reqs = []
    for req in request_list:
      req_msgs = [] 
      i = 0
      req = req_BitsN(req)
      while i < req_len//s.spi_msg_bits: 
        req_msgs.append(req[i*s.spi_msg_bits: (i+1)*s.spi_msg_bits])
        i += 1

      if req_len % (s.spi_msg_bits) != 0: # if there are leftover bits i.e. we will have to pad with zeros to get to width of SPI channel
        req_msgs.append( zext( req[i*s.spi_msg_bits:], s.spi_msg_bits ) )

      req_msgs.reverse() # reverse because we want the most significant packet to be first in the list
      all_reqs.append(req_msgs) # append this list to the all_requests list

    all_expected_resps = []
    for resp in expected_resp_list:
      # zext to get correct length for the expected message (actual result will be a multiple of spi_msg_bits)
      exp_resp = zext(resp_BitsN(resp), s.spi_msg_bits*(ceil(resp_len/s.spi_msg_bits))) 
      all_expected_resps.append(exp_resp)

    #send req / read resp
    actual_responses = []
    actual_resp_addr = []
    resp_msgs = []
    timeout_cntr = 0

    def _assemble_msg( addr ):
      # assemble full response from spi packets
      if len(resp_msgs) == 1:
        act_resp = resp_msgs[0]
      else:
        act_resp = concat(resp_msgs[0], resp_msgs[1] )
        i = 2
        while i < len(resp_msgs):
          act_resp = concat(act_resp, resp_msgs[i])
          i+=1
      resp_msgs.clear() #clear received SPI packets
      actual_resp_addr.append(addr) #append components address to array
      actual_responses.append(act_resp) # append assembled response to list of all responses

    def _process_resp(resp):
      if resp[s.spi_bits-1]==1: #check if valid response
        timeout_cntr = 0
        resp_msgs.append(resp[0:s.spi_msg_bits]) #save message if response val bit set
        if len(resp_msgs) == ceil(resp_len/s.spi_msg_bits): #check if number of packets received is enough to assemble a whole response message
          if s.component_bits > 0: #check if any component bits
            resp_addr = resp[ s.spi_msg_bits:s.spi_msg_bits + s.component_bits ]  #get component address
          else: #no component bits
            resp_addr = 0 #set response address equal to 0
          _assemble_msg( resp_addr ) #assemble message if enough spi response packets to make response message

    #send spi message to get status bits from MinionAdapter TODO: remove condition
    if s.component_bits > 0:
      resp_spi = s._t_spi(concat(Bits1(0), Bits1(0), comp_addr, zext(Bits1(0),s.spi_msg_bits)))
    else:
      resp_spi = s._t_spi(concat(Bits1(0), Bits1(0), zext(Bits1(0),s.spi_msg_bits)))
    _process_resp(resp_spi)

    while(resp_spi[s.spi_bits-2] == 0 ):#poll until space available. We wait for the space bit (the second most significant bit) to be 1
      if s.component_bits > 0:
        resp_spi = s._t_spi(concat(Bits1(0), Bits1(0), comp_addr, zext(Bits1(0),s.spi_msg_bits)))
      else:
        resp_spi = s._t_spi(concat(Bits1(0), Bits1(0), zext(Bits1(0),s.spi_msg_bits)))
      _process_resp(resp_spi)

    #space is now available in MinionAdapter queue for more messages
    for req in all_reqs:
      for msg in req: #sending reqs
        if s.component_bits > 0:
          resp_spi = s._t_spi(concat(Bits1(1),Bits1(1),comp_addr,msg))
        else:
          resp_spi = s._t_spi(concat(Bits1(1),Bits1(1),msg))
        _process_resp(resp_spi)

        while(resp_spi[s.spi_bits-2] == 0 ): #wait until space is available again
          if s.component_bits > 0:
            resp_spi = s._t_spi(concat(Bits1(0), Bits1(1), comp_addr, zext(Bits1(0), s.spi_msg_bits)))
          else:
            resp_spi = s._t_spi(concat(Bits1(0), Bits1(1), zext(Bits1(0), s.spi_msg_bits)))
          _process_resp(resp_spi)

    # get responses to each request
    while len(actual_responses) < len(all_expected_resps): #wait until all exepected responses received 
      if(timeout_cntr >= 1000 and s.is_phy_test):
          raise TimeoutError("t_mult_msg has timed out")
      if s.component_bits > 0:
        resp_spi = s._t_spi( concat(Bits1(0), Bits1(1), comp_addr, zext(Bits1(0),s.spi_msg_bits)))
      else:
        resp_spi = s._t_spi( concat(Bits1(0), Bits1(1), zext(Bits1(0),s.spi_msg_bits)))
      _process_resp(resp_spi)
      timeout_cntr +=1


    # all responses received - check results
    if return_msgs:
      return actual_resp_addr, actual_responses
    for i in range(len(all_expected_resps)):
      print("Component Addr: " + str(actual_resp_addr[i]) + " Actual: " + str(actual_responses[i]) + " | Expected: " + str(all_expected_resps[i]))
      assert all_expected_resps[i] == actual_responses[i]

  #helper functions
  def _t_spi(s, pkt):
    if s.is_phy_test:
      return s._t_phy_spi(pkt)
    else:
      return s._t_sim_spi(pkt)

  def _t_phy_spi( s, pkt ): #send spi packets
    num_bytes = ceil(s.spi_bits/8) # round up to nearest byte
    pkt = zext(pkt, num_bytes*8)
    send_arr = []
    i = 0
    for i in range(num_bytes):
      send_arr.append(pkt[i*8:(i+1)*8].uint())
    send_arr.reverse()
    s.driver.sel()
    rec_msg = list(s.driver.writeread(send_arr))
    s.driver.unsel()
    resp_bits = concat(b8(rec_msg[0]), b8(rec_msg[1]))
    i = 2
    while i < len(rec_msg):
      resp_bits = concat(resp_bits, b8(rec_msg[i]))
      i += 1
    resp_bits = resp_bits >> (num_bytes*8 - s.spi_bits) 
    return resp_bits

  #helper functions
  def _t_sim_spi( s, pkt ): #send spi packets
    s._start_transaction()
    resp_spi = Bits1(0)
    for i in range(s.spi_bits):
      resp_bit = s._send_bit( pkt[s.spi_bits - i - 1] ) #send most significant bits first
      if i == 0:
        resp_spi = resp_bit
      else:
        resp_spi = concat( resp_spi, resp_bit )
    s._end_transaction()
    return copy.deepcopy(resp_spi)

  def _start_transaction( s ): #send bits
    # Starts a transaction by keeping cs HIGH for 3 cycles then pulling cs LOW 
    for i in range(3): # cs = 1
      # Write input values to input ports
      s.dut.spi_min.sclk        @= 0
      s.dut.spi_min.cs          @= 1
      s.dut.spi_min.mosi        @= 1 # mosi is a dont care here bc CS is high
      s.dut.sim_eval_combinational()
      # Tick simulator one cycle
      s.dut.sim_tick()
    for i in range(3): # cs = 0, three cycles because the synchronizer takes 2 cycles for negedge to appear
      s.dut.spi_min.sclk        @= 0
      s.dut.spi_min.cs          @= 0
      s.dut.spi_min.mosi        @= 1 # mosi is a dont care here bc CS is high
      s.dut.sim_eval_combinational()
      s.dut.sim_tick()

  def _end_transaction( s ):
    s.dut.spi_min.sclk        @= 0
    s.dut.spi_min.cs          @= 1
    s.dut.spi_min.mosi        @= 1 # mosi is a dont care here bc CS is high
    s.dut.sim_eval_combinational()
    s.dut.sim_tick()

  def _send_bit( s, mosi): #send bits
    # This function sends bits over SPI once the transaction has been started (CS is already low)
    for i in range(3): # sclk = 0
      # Write input values to input ports
      s.dut.spi_min.sclk        @= 0
      s.dut.spi_min.cs          @= 0
      s.dut.spi_min.mosi        @= mosi
      s.dut.sim_eval_combinational()
      # Tick simulator one cycle
      s.dut.sim_tick()

    for i in range(3): # sclk = 1
      s.dut.spi_min.sclk        @= 1
      s.dut.spi_min.cs          @= 0
      s.dut.spi_min.mosi        @= mosi
      s.dut.sim_eval_combinational()
      s.dut.sim_tick()

    # only return MISO after 8th cycle so it has time to reflect correct value
    return copy.deepcopy(s.dut.spi_min.miso) 