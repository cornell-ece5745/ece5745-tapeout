#=========================================================================
# SortXcelRTL_test
#=========================================================================

import pytest

from pymtl3                import *
from ..SortXcelRTL import SortXcelRTL

#-------------------------------------------------------------------------
# Reuse tests from FL model
#-------------------------------------------------------------------------

from .SpmvXcelFL_test import test_case_table, run_test

@pytest.mark.parametrize( **test_case_table )
def test( test_params, cmdline_opts ):
  run_test( SpmvXcelCtrlRTL(), 1, test_params, cmdline_opts )

def test_multiple( cmdline_opts ):
  run_test_multiple( SpmvXcelCtrlRTL(), 1, cmdline_opts )

