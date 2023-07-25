#=========================================================================
# Spmv Xcel RTL Model
#=========================================================================
# instantiates and connects a parameterized number of PEs and the control unit

from pymtl3      import *

from pymtl3.stdlib import stream

from .SpmvXcelCtrlPRTL import *
from .SpmvPePrtl import *

from .XcelMsg import *

class SpmvXcelPRTL (Component):

    def construct(s, num_pe = 1):
        s.set_metadata( VerilogTranslationPass.explicit_module_name, f'SpmvXcelRTL_{num_pes}pes' )

        s.ctrl = SpmvXcelCtrlPRTL(num_pe=num_pe)

        s.ctrl.xcel = idk
        s.pes = [SpmvPePrtl() for _ in range(num_pe)]
        

