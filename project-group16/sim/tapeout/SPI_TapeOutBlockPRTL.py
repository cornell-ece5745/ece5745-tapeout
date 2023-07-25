'''
==========================================================================
SPI_TapeOutBlockPRTL.py
==========================================================================
A composition module combining the SPI stack (SPI Minion, SPI Minion Adapter, and Loopthrough)
that connects to the individual project group's block module. This was used for the 
efabless tapeout in Spring 2022.

Author : Jack Brzozowski
  Date : May 9th, 2022

'''

from pymtl3 import *
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL
from pymtl3.passes.backends.verilog import *
from pymtl3.passes.backends.yosys import *

from SPI_v3.components.SPIstackRTL import SPIstackRTL
from SPI_v3.components.PacketAssemblerRTL import PacketAssemblerRTL
from SPI_v3.components.PacketDisassemblerRTL import PacketDisassemblerRTL
from SPI_v3.interfaces.SPIIfc import SPIMinionIfc
from tapeout.BlockPlaceholderPRTL import BlockPlaceholderPRTL
from synthmemsimple.SynthMemSimple import SynthMemSimple

class SPI_TapeOutBlockPRTL( Component ):

  #=======================================================================
  # Constructor
  #=======================================================================

  def construct( s, nbits=32, num_entries=5):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'grp_16_SPI_TapeOutBlockRTL_{nbits}bits_{num_entries}entries' )
    s.set_metadata( YosysTranslationPass.explicit_module_name,   f'grp_16_SPI_TapeOutBlockRTL_{nbits}bits_{num_entries}entries' )

    s.mem_nbits_in = 78
    s.mem_nbits_out = 48

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    s.spi_min         = SPIMinionIfc()
    s.loopthrough_sel = InPort()
    s.minion_parity   = OutPort()
    s.adapter_parity  = OutPort()
 
    #--------------------------------------------------------------------- 
    # Module Instantiation
    #---------------------------------------------------------------------
    
    s.spi_min_stack = ms = SPIstackRTL(nbits + 2, num_entries)
    ms.spi_min.cs      //= s.spi_min.cs
    ms.spi_min.sclk    //= s.spi_min.sclk
    ms.spi_min.mosi    //= s.spi_min.mosi
    ms.spi_min.miso    //= s.spi_min.miso
    ms.loopthrough_sel //= s.loopthrough_sel
    ms.minion_parity   //= s.minion_parity
    ms.adapter_parity  //= s.adapter_parity

    #=====================================================================================================
    # TAPEOUT TASK Instantiate your PyMTL Module Here and connect it to the SPIstack Send/Recv interfaces
    #=====================================================================================================

    # ms.recv //=  #Connect to this interface
    # ms.send //=  #Connect to this interface

    # Instantiate Packet Assembler and Dissasembler for the synthmem
    s.synthmem_assem = PacketAssemblerRTL(nbits, s.mem_nbits_in) 
    s.synthmem_disassem = PacketDisassemblerRTL(s.mem_nbits_out,nbits)

    # Instantiate SynthMemSimple
    s.synthmem = SynthMemSimple()

    # Connect PackAssembler to SPI Stack & SynthMem
    @update
    def up_assembler():
      s.synthmem.minion.req.msg @= s.synthmem_assem.assem_ifc.resp.msg
      s.synthmem.minion.req.val @= s.synthmem_assem.assem_ifc.resp.val
      s.synthmem_assem.assem_ifc.resp.rdy @= s.synthmem.minion.req.rdy

    s.synthmem_assem.assem_ifc.req //= s.spi_min_stack.send

    # Connect PackDisassembler to SPI Stack & SynthMem
    @update
    def up_dissassembler(): 

      s.synthmem_disassem.disassem_ifc.req.msg @= s.synthmem.minion.resp.msg
      s.synthmem_disassem.disassem_ifc.req.val @= s.synthmem.minion.resp.val  
      s.synthmem.minion.resp.rdy @= s.synthmem_disassem.disassem_ifc.req.rdy
      
    s.spi_min_stack.recv //= s.synthmem_disassem.disassem_ifc.resp

    # Connect 

    # REPLACE THIS MODULE
    #s.placeholder = ph = BlockPlaceholderPRTL(nbits)

    #ms.send //= ph.recv
    #ms.recv //= ph.send

    
  #=======================================================================
  # Line tracing
  #=======================================================================

  def line_trace( s ):

    return ""
