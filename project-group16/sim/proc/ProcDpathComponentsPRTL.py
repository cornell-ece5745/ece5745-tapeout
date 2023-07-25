#=========================================================================
# ProcDpathComponentsPRTL.py
#=========================================================================

from pymtl3            import *
from .TinyRV2InstPRTL  import *

#-------------------------------------------------------------------------
# Generate intermediate (imm) based on type
#-------------------------------------------------------------------------

class ImmGenPRTL( Component ):

  # Interface

  def construct( s ):

    s.imm_type = InPort( 3 )
    s.inst     = InPort( 32 )
    s.imm      = OutPort( 32 )

    @update
    def comb_logic():
      s.imm @= 0

      # Always sext!

      if   s.imm_type == 0: # I-type
        s.imm @= sext( s.inst[ I_IMM ], 32 )

      elif s.imm_type == 1: # S-type
        s.imm @= concat( sext( s.inst[ S_IMM1 ], 27 ),
                               s.inst[ S_IMM0 ] )
      elif s.imm_type == 2: # B-type
        s.imm @= concat( sext( s.inst[ B_IMM3 ], 20 ),
                               s.inst[ B_IMM2 ],
                               s.inst[ B_IMM1 ],
                               s.inst[ B_IMM0 ],
                               b1(0) )


      elif s.imm_type == b3(3): # U-type
        s.imm @= concat(       s.inst[ U_IMM ],
                               b12(0) )

      elif s.imm_type == b3(4): # J-type
        s.imm @= concat( sext( s.inst[ J_IMM3 ], 12 ),
                               s.inst[ J_IMM2 ],
                               s.inst[ J_IMM1 ],
                               s.inst[ J_IMM0 ],
                               b1(0) )

  def line_trace( s ):
    return f"immT{s.imm_type}={s.imm}"


#-------------------------------------------------------------------------
# ALU
#-------------------------------------------------------------------------

class AluPRTL( Component ):

  # Interface

  def construct( s ):

    s.in0     = InPort ( 32 )
    s.in1     = InPort ( 32 )
    s.fn      = InPort ( 4 )

    s.out     = OutPort( 32 )
    s.ops_eq  = OutPort()
    s.ops_lt  = OutPort()
    s.ops_ltu = OutPort()

    # Combinational Logic

    s.tmp_a = Wire( 33 )
    s.tmp_b = Wire( 64 )

    @update
    def comb_logic():
      s.out   @= 0
      s.tmp_a @= 0
      s.tmp_b @= 0

      if   s.fn == 0: s.out @= s.in0 + s.in1         # ADD
      elif s.fn == 1: s.out @= s.in0 - s.in1         # SUB
      elif s.fn == 2: s.out @= s.in0 << zext( s.in1[0:5], 32 )   # SLL
      elif s.fn == 3: s.out @= s.in0 | s.in1         # OR

      elif s.fn == 4:                               # SLT
        s.tmp_a @= sext( s.in0, 33 ) - sext( s.in1, 33 )
        s.out   @= zext( s.tmp_a[32], 32 )

      elif s.fn == 5: s.out @= zext(s.in0 < s.in1, 32)    # SLTU
      elif s.fn == 6: s.out @= s.in0 & s.in1    # AND
      elif s.fn == 7: s.out @= s.in0 ^ s.in1    # XOR
      elif s.fn == 8: s.out @= ~( s.in0 | s.in1 )    # NOR
      elif s.fn == 9: s.out @= s.in0 >> zext( s.in1[0:5], 32 ) # SRL

      elif s.fn == 10:                             # SRA
        s.tmp_b @= sext( s.in0, 64 ) >> zext( s.in1[0:5], 64 )
        s.out   @= s.tmp_b[0:32]

      elif s.fn == 11: s.out @= s.in0               # CP OP0
      elif s.fn == 12: s.out @= s.in1               # CP OP1

      elif s.fn == 13:                             # ADDZ for clearing LSB
        s.out @= (s.in0 + s.in1) & 0xfffffffe

      s.ops_eq  @= ( s.in0 == s.in1 )
      s.ops_lt  @= s.tmp_a[32]
      s.ops_ltu @= ( s.in0 < s.in1 )

  def line_trace( s ):
    return f"aluT{int(s.fn)}({s.in0},{s.in1})={s.out}," \
           f"{'eq' if s.ops_eq else 'ne'}," \
           f"{'lt' if s.ops_lt else 'ge'}," \
           f"{'ltu' if s.ops_ltu else 'geu'}"
