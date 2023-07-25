#=========================================================================
# SpmvXcelRTL_test
#=========================================================================

import pytest

from pymtl3                import *
from ..SpmvXcelCtrlRTL import SpmvXcelCtrlRTL

#-------------------------------------------------------------------------
# Reuse tests from FL model
#-------------------------------------------------------------------------

from .SpmvXcelFL_test import test_case_table, run_test

@pytest.mark.parametrize( **test_case_table )
def test( test_params, cmdline_opts ):
  run_test( SpmvXcelCtrlRTL(test_params.num_pe), test_params.num_pe, 'rtl', test_params, cmdline_opts )

