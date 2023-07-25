#=========================================================================
# sw
#=========================================================================

import random

# Fix the random seed so results are reproducible
random.seed(0xdeadbeef)

from pymtl3 import *
from .inst_utils import *

#-------------------------------------------------------------------------
# gen_basic_test
#-------------------------------------------------------------------------

def gen_basic_test():
  return """
    csrr x1, mngr2proc < 0x00002000
    csrr x2, mngr2proc < 0xdeadbeef
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    sw   x2, 0(x1)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lw   x3, 0(x1)
    csrw proc2mngr, x3 > 0xdeadbeef

    .data
    .word 0x01020304
  """

# ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Define additional directed and random test cases.
# '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

#-------------------------------------------------------------------------
# gen_dest_dep_test
#-------------------------------------------------------------------------

def gen_dest_dep_test():
  return [

    gen_st_dest_dep_test( 5, "sw", 0x30313233, 0x2000, 0x30313233 ),
    gen_st_dest_dep_test( 4, "sw", 0x34353637, 0x2004, 0x34353637 ),
    gen_st_dest_dep_test( 3, "sw", 0x38393a3b, 0x2008, 0x38393a3b ),
    gen_st_dest_dep_test( 2, "sw", 0x3c3d3e3f, 0x200c, 0x3c3d3e3f ),
    gen_st_dest_dep_test( 1, "sw", 0x40414243, 0x2010, 0x40414243 ),
    gen_st_dest_dep_test( 0, "sw", 0x44454647, 0x2014, 0x44454647 ),

    gen_word_data([
      0x00010203,
      0x04050607,
      0x08090a0b,
      0x0c0d0e0f,
      0x10111213,
      0x14151617,
    ])

  ]

#-------------------------------------------------------------------------
# gen_base_dep_test
#-------------------------------------------------------------------------

def gen_base_dep_test():
  return [

    gen_st_base_dep_test( 5, "sw", 0x30313233, 0x2000, 0x30313233 ),
    gen_st_base_dep_test( 4, "sw", 0x34353637, 0x2004, 0x34353637 ),
    gen_st_base_dep_test( 3, "sw", 0x38393a3b, 0x2008, 0x38393a3b ),
    gen_st_base_dep_test( 2, "sw", 0x3c3d3e3f, 0x200c, 0x3c3d3e3f ),
    gen_st_base_dep_test( 1, "sw", 0x40414243, 0x2010, 0x40414243 ),
    gen_st_base_dep_test( 0, "sw", 0x44454647, 0x2014, 0x44454647 ),

    gen_word_data([
      0x00010203,
      0x04050607,
      0x08090a0b,
      0x0c0d0e0f,
      0x10111213,
      0x14151617,
    ])

  ]


#-------------------------------------------------------------------------
# gen_src_dep_test
#-------------------------------------------------------------------------

def gen_src_dep_test():
  return [

    gen_st_src_dep_test( 5, "sw", 0x30313233, 0x2000, 0x30313233 ),
    gen_st_src_dep_test( 4, "sw", 0x34353637, 0x2004, 0x34353637 ),
    gen_st_src_dep_test( 3, "sw", 0x38393a3b, 0x2008, 0x38393a3b ),
    gen_st_src_dep_test( 2, "sw", 0x3c3d3e3f, 0x200c, 0x3c3d3e3f ),
    gen_st_src_dep_test( 1, "sw", 0x40414243, 0x2010, 0x40414243 ),
    gen_st_src_dep_test( 0, "sw", 0x44454647, 0x2014, 0x44454647 ),

    gen_word_data([
      0x00010203,
      0x04050607,
      0x08090a0b,
      0x0c0d0e0f,
      0x10111213,
      0x14151617,
    ])

  ]

#-------------------------------------------------------------------------
# gen_srcs_dep_test
#-------------------------------------------------------------------------

def gen_srcs_dep_test():
  return [

    gen_st_srcs_dep_test( 5, "sw", 0x30313233, 0x2000, 0x30313233 ),
    gen_st_srcs_dep_test( 4, "sw", 0x34353637, 0x2004, 0x34353637 ),
    gen_st_srcs_dep_test( 3, "sw", 0x38393a3b, 0x2008, 0x38393a3b ),
    gen_st_srcs_dep_test( 2, "sw", 0x3c3d3e3f, 0x200c, 0x3c3d3e3f ),
    gen_st_srcs_dep_test( 1, "sw", 0x40414243, 0x2010, 0x40414243 ),
    gen_st_srcs_dep_test( 0, "sw", 0x44454647, 0x2014, 0x44454647 ),

    gen_word_data([
      0x00010203,
      0x04050607,
      0x08090a0b,
      0x0c0d0e0f,
      0x10111213,
      0x14151617,
    ])

  ]

#-------------------------------------------------------------------------
# gen_srcs_dest_test
#-------------------------------------------------------------------------

def gen_srcs_dest_test():
  return [
    gen_st_src_eq_base_test( "sw", 0x00002000, 0x00002000 ),
    gen_word_data([ 0x01020304 ])
  ]

#-------------------------------------------------------------------------
# gen_addr_test
#-------------------------------------------------------------------------

def gen_addr_test():
  return [

    # Test positive offsets

    gen_st_value_test( "sw", 0x30313233,   0, 0x00002000, 0x30313233 ),
    gen_st_value_test( "sw", 0x34353637,   4, 0x00002000, 0x34353637 ),
    gen_st_value_test( "sw", 0x38393a3b,   8, 0x00002000, 0x38393a3b ),
    gen_st_value_test( "sw", 0x3c3d3e3f,  12, 0x00002000, 0x3c3d3e3f ),
    gen_st_value_test( "sw", 0x40414243,  16, 0x00002000, 0x40414243 ),
    gen_st_value_test( "sw", 0x44454647,  20, 0x00002000, 0x44454647 ),

    # Test negative offsets

    gen_st_value_test( "sw", 0x48494a4b, -20, 0x00002014, 0x48494a4b ),
    gen_st_value_test( "sw", 0x4c4d4e4f, -16, 0x00002014, 0x4c4d4e4f ),
    gen_st_value_test( "sw", 0x50515253, -12, 0x00002014, 0x50515253 ),
    gen_st_value_test( "sw", 0x54555657,  -8, 0x00002014, 0x54555657 ),
    gen_st_value_test( "sw", 0x58595a5b,  -4, 0x00002014, 0x58595a5b ),
    gen_st_value_test( "sw", 0x5c5d5e5f,   0, 0x00002014, 0x5c5d5e5f ),

    # Test positive offset with unaligned base

    gen_st_value_test( "sw", 0x60616263,   1, 0x00001fff, 0x60616263 ),
    gen_st_value_test( "sw", 0x64656667,   5, 0x00001fff, 0x64656667 ),
    gen_st_value_test( "sw", 0x68696a6b,   9, 0x00001fff, 0x68696a6b ),
    gen_st_value_test( "sw", 0x6c6d6e6f,  13, 0x00001fff, 0x6c6d6e6f ),
    gen_st_value_test( "sw", 0x70717273,  17, 0x00001fff, 0x70717273 ),
    gen_st_value_test( "sw", 0x74757677,  21, 0x00001fff, 0x74757677 ),

    # Test negative offset with unaligned base

    gen_st_value_test( "sw", 0x78797a7b, -21, 0x00002015, 0x78797a7b ),
    gen_st_value_test( "sw", 0x7c7d7e7f, -17, 0x00002015, 0x7c7d7e7f ),
    gen_st_value_test( "sw", 0x80818283, -13, 0x00002015, 0x80818283 ),
    gen_st_value_test( "sw", 0x84858687,  -9, 0x00002015, 0x84858687 ),
    gen_st_value_test( "sw", 0x88898a8b,  -5, 0x00002015, 0x88898a8b ),
    gen_st_value_test( "sw", 0x8c8d8e8f,  -1, 0x00002015, 0x8c8d8e8f ),

    gen_word_data([
      0xdeadbeef,
      0x00010203,
      0x04050607,
      0x08090a0b,
      0x0c0d0e0f,
      0xcafecafe,
    ])

  ]

#-------------------------------------------------------------------------
# gen_random_test
#-------------------------------------------------------------------------

def gen_random_test():

  # Generate some random data

  data = []
  for i in range(128):
    data.append( random.randint(0,0xffffffff) )

  # Generate random accesses to this data

  asm_code = []
  for i in range(100):

    a = random.randint(0,127)
    b = random.randint(0,127)

    base   = 0x2000 + (4*b)
    offset = 4*(a - b)
    result = data[a]

    asm_code.append( gen_st_value_test( "sw", result, offset, base, result ) )

  # Generate some random data to initialize memory

  initial_data = []
  for i in range(128):
    initial_data.append( random.randint(0,0xffffffff) )

  # Add the data to the end of the assembly code

  asm_code.append( gen_word_data( initial_data ) )
  return asm_code

# '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\
