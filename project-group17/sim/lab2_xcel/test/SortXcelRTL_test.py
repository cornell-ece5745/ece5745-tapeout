#=========================================================================
# SortXcelRTL_test
#=========================================================================

import pytest

from pymtl3                import *
from lab2_xcel.SortXcelRTL import SortXcelRTL

#-------------------------------------------------------------------------
# Reuse tests from FL model
#-------------------------------------------------------------------------

from .SortXcelFL_test import test_case_table, run_test, run_test_multiple

@pytest.mark.parametrize( **test_case_table )
def test( test_params, cmdline_opts ):
  run_test( SortXcelRTL(), test_params, cmdline_opts )

def test_multiple( cmdline_opts ):
  run_test_multiple( SortXcelRTL(), cmdline_opts )

