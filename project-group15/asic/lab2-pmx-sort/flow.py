#=========================================================================
# Processor, Cache, Sort Xcel
#=========================================================================
# Author : Jack Brzozowski
# Date   : February 28th, 2022
#
# ProcMemXcel with the Sort Accelerator, UNDER CONSTRUCTION
#

import os
import json

from mflowgen.components import Graph, Step

def construct():

  g = Graph()

  this_dir = os.path.dirname( os.path.abspath( __file__ ) )

  #-----------------------------------------------------------------------
  # Parameters
  #-----------------------------------------------------------------------

  adk_name = 'freepdk-45nm'
  adk_view = 'stdview'

  parameters = {
    'construct_path'  : __file__,
    'sim_path'        : f"{this_dir}/../../sim",
    'design_path'     : f"{this_dir}/../../sim/pmx",
    'design_name'     : 'ProcMemXcel_sort_rtl',
    'clock_period'    : 3.0,
    'clk_port'        : 'clk',
    'reset_port'      : 'reset',
    'adk'             : adk_name,
    'adk_view'        : adk_view,
    'pad_ring'        : False,

    # VCS-sim
    'test_design_name': 'ProcMemXcel_sort_rtl',
    'input_delay'     : 0.05,
    'output_delay'    : 0.05,

    # Synthesis
    'gate_clock'      : True,
    'topographical'   : False,

    # PT Power
    'saif_instance'   : 'ProcMemXcel_sort_rtl_tb/DUT',
  }

  #-----------------------------------------------------------------------
  # Truncate design name at first instance of '__' to run the right tests
  #-----------------------------------------------------------------------

  trunc_design_name = parameters['design_name']
  trunc_design_name = trunc_design_name.split("__", 1)[0]
  parameters['trunc_design_name'] = trunc_design_name


  #-----------------------------------------------------------------------
  # Create nodes
  #-----------------------------------------------------------------------

  # ADK step

  g.set_adk( adk_name )
  adk = g.get_adk_step()

  # Custom steps

  info           = Step( 'info',                                 default=True )
  gather         = Step( 'brgtc5-block-gather',                  default=True )
  vcsSim         = Step( 'brg-synopsys-vcs-sim',                 default=True )
  synth          = Step( 'brg-synopsys-dc-synthesis',            default=True )
  init           = Step( 'brg-cadence-innovus-init',             default=True )
  blocksetup     = Step( 'brg-cadence-innovus-blocksetup',       default=True )
  pnr            = Step( 'brg-cadence-innovus-pnr',              default=True )
  signoff        = Step( 'brg-cadence-innovus-signoff',          default=True )
  power          = Step( 'brg-synopsys-pt-power',                default=True )
  summary        = Step( 'brg-flow-summary',                     default=True )

  # Clone vcsSim

  rtlsim     = vcsSim.clone()
  glFFsim    = vcsSim.clone()
  # glBAsim    = vcsSim.clone()

  # Clone pt-power

  synthpower = power.clone()
  # pnrpower   = power.clone()

  # Give clones new names

  rtlsim.set_name('brg-rtl-4-state-vcssim')
  glFFsim.set_name('post-synth-gate-level-simulation')
  # glBAsim.set_name('post-pnr-gate-level-simulation')

  synthpower.set_name('post-synth-power-analysis')
  # pnrpower.set_name("post-pnr-power-analysis")

  info.set_name('build-info')

  #-----------------------------------------------------------------------
  # Graph -- Add nodes
  #-----------------------------------------------------------------------

  g.add_step( info           )
  g.add_step( gather         )
  g.add_step( rtlsim         )
  g.add_step( synth          )
  g.add_step( glFFsim        )
  g.add_step( init           )
  g.add_step( blocksetup     )
  g.add_step( pnr            )
  g.add_step( signoff        )
  # g.add_step( glBAsim        )
  g.add_step( synthpower     )
  # g.add_step( pnrpower       )
  g.add_step( summary        )

  #-----------------------------------------------------------------------
  # Graph -- Add edges
  #-----------------------------------------------------------------------

  # Connect by name
  g.connect_by_name( adk,            synth          )
  g.connect_by_name( adk,            glFFsim        )
  g.connect_by_name( adk,            init           )
  g.connect_by_name( adk,            blocksetup     )
  g.connect_by_name( adk,            pnr            )
  g.connect_by_name( adk,            signoff        )
  # g.connect_by_name( adk,            glBAsim        )
  g.connect_by_name( adk,            synthpower     )
  # g.connect_by_name( adk,            pnrpower       )

  g.connect_by_name( gather,         synth          )
  g.connect_by_name( gather,         rtlsim         )
  g.connect_by_name( gather,         glFFsim        )
  # g.connect_by_name( gather,         glBAsim        )

  g.connect_by_name( synth,          glFFsim        ) # design.vcs.v
  g.connect_by_name( synth,          init           )
  g.connect_by_name( synth,          blocksetup     )
  g.connect_by_name( synth,          pnr            )
  g.connect_by_name( synth,          signoff        )
  g.connect( synth.o( 'design.sdc'),   synthpower.i('design.sdc')) #design.sdc
  g.connect( synth.o( 'design.vcs.v'), synthpower.i('design.vcs.v')) #design.vcs.v
  g.connect( synth.o( 'design.spef.gz'), synthpower.i('design.spef.gz')) #design.spef.gz
  # g.connect( synth.o( 'design.sdc'),     pnrpower.i('design.sdc')) #design.sdc

  g.connect_by_name( init,           blocksetup     )

  g.connect_by_name( blocksetup,      pnr           )

  g.connect_by_name( pnr,            signoff        )

  # g.connect_by_name( signoff,        glBAsim        ) # design.vcs.v, design.sdf
  # g.connect_by_name( signoff,        pnrpower       ) # design.vcs.v, design.spef.gz
  g.connect_by_name( signoff,        summary        )


  g.connect_by_name( glFFsim,        synthpower     ) # saif, vcd
  # g.connect_by_name( glBAsim,        pnrpower       ) # saif, vcd

  g.connect( rtlsim.o('sim.summary.txt'), summary.i('4state.summary.txt'))
  g.connect( glFFsim.o('sim.summary.txt'), summary.i('ff.summary.txt'))
  # g.connect( glBAsim.o('sim.summary.txt'), summary.i('ba.summary.txt'))
  g.connect( synthpower.o('power.summary.txt'), summary.i('powerFF.summary.txt'))
  # g.connect( pnrpower.o('power.summary.txt'), summary.i('powerBA.summary.txt'))

#   #-----------------------------------------------------------------------
#   # Parameterize
#   #-----------------------------------------------------------------------

  g.update_params( parameters )
  rtlsim.update_params({'simtype':'rtl'}, False)
  glFFsim.update_params({'simtype':'gate-level'}, False)
  # glBAsim.update_params({'simtype': 'gate-level'}, False)
  synthpower.update_params({'zero_delay_simulation': True}, False)

  return g


if __name__ == '__main__':
  g = construct()
