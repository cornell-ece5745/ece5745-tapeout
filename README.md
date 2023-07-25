# ECE5745 Class Tapeout

This is the repository for the Spring 2022 tapeout for ECE5745: Complex Digital Asic Design, a class taught at Cornell University by Prof. Christopher Batten. Projects include:

 - Wavelet Compression Accelerator (Arun Raman, Anya Prabowo, Tim Tran, Cecilio Camarero)
   - Macro name: grp_15
 - SpMV Accelerator (Amulya Khurana, Kofi Efah, Mustapha Toureg, Dani Song, Aditi Agarwal)
   - Macro name: grp_16
 - BNN Accelerator (Kejia Hu, Yunhe Shao, Yujie Lu, Ziming Xiong, Jasmin An)
   - Macro name: grp_17
 - GCD unit (Aidan McNay)
   - Macro name: grp_99

Clone Repo
--------------------------------------------------------------------------

    % mkdir -p $HOME/vc/git-hub/cornell-ece5745
    % cd $HOME/vc/git-hub/cornell-ece5745
    % git clone git@github.com:cornell-ece5745/ece5745-tapeout
    % cd $HOME/vc/git-hub/cornell-ece5745/ece5745-tapeout
    % TODIR=$PWD
    % cd $TODIR
    % make install check-env install_mcw

Group 15
--------------------------------------------------------------------------

### group 15 tapein setup

    % cd $TODIR/project-group15
    % TOPDIR=$PWD

### group 15 PyMTL sim

    % mkdir -p $TOPDIR/sim/build
    % cd $TOPDIR/sim/build
    % pytest ../tapeout/chip_test --test-verilog --dump-vtb

### group 15 tapein flow

    % mkdir -p $TOPDIR/asic/build-tapeout
    % cd $TOPDIR/asic/build-tapeout
    % mflowgen run --design ../tapeout-block
    % make

     area & timing
      design_area   = 3490.452 um^2
      stdcells_area = 3490.452 um^2
      macros_area   = 0.0 um^2
      chip_area     = 1113719.603 um^2
      core_area     = 959916.674 um^2
      constraint    = 2.0 ns
      slack         = 0.387 ns
      actual_clk    = 1.613 ns

     4-State Sim Results
      - [PASSED]: test_loopback
      - [PASSED]: test_small
      - [PASSED]: test_large
      - [PASSED]: test_long
      - [PASSED]: test_random

     Fast-Functional Sim Results
      - [PASSED]: test_loopback
      - [PASSED]: test_small
      - [PASSED]: test_large
      - [PASSED]: test_long
      - [PASSED]: test_random

### group 15 tapeout setup

    % cd $TODIR
    % make install check-env install_mcw

 - make sure sv2v verilog matches what is in tapein flow
    + vc_Trace should be missing
    + modules should be prefixed
    + and top-level interface should be different, with enables

```
 % diff \
   $TOPDIR/sim/build/grp_15_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v \
   $TODIR/verilog/rtl/grp_15_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v
```

### group 15 tapeout RTL simulation

 - edit `$TODIR/verilog/includes/includes.rtl.caravel_user_project`

```
 # Caravel user project includes
 -v $(USER_PROJECT_VERILOG)/rtl/grp_15_project_wrapper.v
 -v $(USER_PROJECT_VERILOG)/rtl/grp_15_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v

 % cd $TODIR
 % make verify-grp_15_test_loopback-rtl
 % make verify-grp_15_test_small-rtl
 % make verify-grp_15_test_large-rtl
 % make verify-grp_15_test_long-rtl
 % make verify-grp_15_test_random-rtl
```

### group 15 tapeout flow

    % cd $TODIR
    % make project-group15
    % make grp_15_project_wrapper

 - from `openlane/project-group15/runs/project-group15/reports/final_summary_report.csv`
    + DIEAREA_mm^2       0.81
    + cell_count         2319
    + CLOCK_PERIOD        100
    + wns                   0
    + antenna_violations   28
    + lvs_total_errors      0
    + cvc_total_errors      0

 - from `openlane/project-group15/runs/project-group15/reports/routing/19-groute_sta.max.rpt`
    + slack: 74.79ns

 - from `openlane/project-group15/runs/project-group15/reports/routing/19-groute_sta.min.rpt`
    + slack:  0.62ns

### group 15 tapeout GL simulation

 - edit `$TODIR/verilog/includes/includes.gl.caravel_user_project`

```
    # Caravel user project includes
    -v $(USER_PROJECT_VERILOG)/rtl/grp_15_project_wrapper.v
    -v $(USER_PROJECT_VERILOG)/gl/grp_15_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v

    % cd $TODIR
    % make verify-grp_15_test_loopback-gl
    % make verify-grp_15_test_small-gl
    % make verify-grp_15_test_large-gl
    % make verify-grp_15_test_long-gl
    % make verify-grp_15_test_random-gl
```

Group 17
--------------------------------------------------------------------------

### group 17 tapein setup

    % cd $TODIR/project-group17
    % TOPDIR=$PWD

### group 17 PyMTL sim

    % mkdir -p $TOPDIR/sim/build
    % cd $TOPDIR/sim/build
    % pytest ../tapeout/chip_test --test-verilog --dump-vtb

### group 17 tapein flow

    % mkdir -p $TOPDIR/asic/build-tapeout
    % cd $TOPDIR/asic/build-tapeout
    % mflowgen run --design ../tapeout-block
    % make

     area & timing
      design_area   = 9257.332 um^2
      stdcells_area = 9257.332 um^2
      macros_area   = 0.0 um^2
      chip_area     = 1113719.603 um^2
      core_area     = 959916.674 um^2
      constraint    = 2.0 ns
      slack         = 0.009 ns
      actual_clk    = 1.991 ns

     4-State Sim Results
      - [PASSED]: test_2x2
      - [PASSED]: test_2x4
      - [PASSED]: test_loopback

     Fast-Functional Sim Results
      - [PASSED]: test_2x2
      - [PASSED]: test_2x4
      - [PASSED]: test_loopback

### group 17 tapeout setup

    % cd $TODIR
    % make install check-env install_mcw

 - make sure sv2v verilog matches what is in tapein flow
    + vc_Trace should be missing
    + modules should be prefixed
    + and top-level interface should be different, with enables

```
 % diff \
   $TOPDIR/sim/build/grp_17_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v \
   $TODIR/verilog/rtl/grp_17_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v
```

### group 17 tapeout RTL simulation

 - edit `$TODIR/verilog/includes/includes.rtl.caravel_user_project`

```
 # Caravel user project includes
 -v $(USER_PROJECT_VERILOG)/rtl/grp_17_project_wrapper.v
 -v $(USER_PROJECT_VERILOG)/rtl/grp_17_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v

 % cd $TODIR
 % make verify-grp_17_test_loopback-rtl
 % make verify-grp_17_test_2x2-rtl
 % make verify-grp_17_test_2x4-rtl
```

### group 17 tapeout flow

    % cd $TODIR
    % make project-group17
    % make grp_17_project_wrapper

 - from `openlane/project-group17/runs/project-group17/reports/final_summary_report.csv`
    + DIEAREA_mm^2       0.49
    + cell_count         9374
    + CLOCK_PERIOD        100
    + wns                   0
    + antenna_violations    6
    + lvs_total_errors      0
    + cvc_total_errors      0

 - from `openlane/project-group17/runs/project-group17/reports/routing/19-groute_sta.max.rpt`
    + slack: 73.25ns

 - from `openlane/project-group17/runs/project-group17/reports/routing/19-groute_sta.min.rpt`
    + slack:  0.82ns

### group 17 tapeout GL simulation

 - edit `$TODIR/verilog/includes/includes.gl.caravel_user_project`

```
    # Caravel user project includes
    -v $(USER_PROJECT_VERILOG)/rtl/grp_17_project_wrapper.v
    -v $(USER_PROJECT_VERILOG)/gl/grp_17_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v

    % cd $TODIR
    % make verify-grp_17_test_loopback-gl
    % make verify-grp_17_test_2x2-gl
    % make verify-grp_17_test_2x4-gl
```

Group 16
--------------------------------------------------------------------------

### group 16 tapein setup

    % cd $TODIR/project-group16
    % TOPDIR=$PWD

### group 16 PyMTL sim

    % mkdir -p $TOPDIR/sim/build
    % cd $TOPDIR/sim/build
    % pytest ../tapeout/chip_test --test-verilog --dump-vtb

### group 16 tapein flow

    % mkdir -p $TOPDIR/asic/build-tapeout
    % cd $TOPDIR/asic/build-tapeout
    % mflowgen run --design ../tapeout-block
    % make

     area & timing
      design_area   = 10053.47 um^2
      stdcells_area = 10053.47 um^2
      macros_area   = 0.0 um^2
      chip_area     = 1113719.603 um^2
      core_area     = 959916.674 um^2
      constraint    = 2.0 ns
      slack         = 0.862 ns
      actual_clk    = 1.138 ns

     4-State Sim Results
      - [PASSED]: test_2x2
      - [PASSED]: test_2x4
      - [PASSED]: test_loopback

     Fast-Functional Sim Results
      - [PASSED]: test_2x2
      - [PASSED]: test_2x4
      - [PASSED]: test_loopback

### group 16 tapeout setup

    % cd $TODIR
    % make install check-env install_mcw

 - make sure sv2v verilog matches what is in tapein flow
    + modules should be prefixed
    + top-level interface should be different, with enables

```
 % diff \
   $TOPDIR/sim/build/grp_16_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v \
   $TODIR/verilog/rtl/grp_16_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v
```

### group 16 tapeout RTL simulation

 - edit `$TODIR/verilog/includes/includes.rtl.caravel_user_project`

```
 # Caravel user project includes
 -v $(USER_PROJECT_VERILOG)/rtl/grp_16_project_wrapper.v
 -v $(USER_PROJECT_VERILOG)/rtl/grp_16_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v

 % cd $TODIR
 % make verify-grp_16_test_loopback-rtl
 % make verify-grp_16_test_loopback_stream-rtl
 % make verify-grp_16_test_basic_msgs-rtl
 % make verify-grp_16_test_basic_multiple_msgs-rtl
 % make verify-grp_16_test_random_msgs-rtl
```

### group 16 tapeout flow

    % cd $TODIR
    % make project-group16
    % make grp_16_project_wrapper

 - from `openlane/project-group16/runs/project-group16/reports/final_summary_report.csv`
    + DIEAREA_mm^2       0.49
    + cell_count         7588
    + CLOCK_PERIOD        100
    + wns                   0
    + antenna_violations   29
    + lvs_total_errors      0
    + cvc_total_errors      0

 - from `openlane/project-group16/runs/project-group16/reports/routing/19-groute_sta.max.rpt`
    + slack: 73.33ns

 - from `openlane/project-group16/runs/project-group16/reports/routing/19-groute_sta.min.rpt`
    + slack:  0.77ns

### group 16 tapeout GL simulation

 - edit `$TODIR/verilog/includes/includes.gl.caravel_user_project`

```
 # Caravel user project includes
 -v $(USER_PROJECT_VERILOG)/rtl/grp_16_project_wrapper.v
 -v $(USER_PROJECT_VERILOG)/gl/grp_16_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v

 % cd $TODIR
 % make verify-grp_16_test_loopback-gl
 % make verify-grp_16_test_loopback_stream-gl
 % make verify-grp_16_test_basic_msgs-gl
 % make verify-grp_16_test_basic_multiple_msgs-gl
 % make verify-grp_16_test_random_msgs-gl
```

Group 99
--------------------------------------------------------------------------

### group 99 tapein setup

    % cd $TODIR/project-group99
    % TOPDIR=$PWD

### group 99 PyMTL sim

    % mkdir -p $TOPDIR/sim/build
    % cd $TOPDIR/sim/build
    % pytest ../tapeout/chip_test --test-verilog --dump-vtb

### group 99 tapein flow

    % mkdir -p $TOPDIR/asic/build-tapeout
    % cd $TOPDIR/asic/build-tapeout
    % mflowgen run --design ../tapeout-block
    % make

### group 99 tapeout setup

    % cd $TODIR
    % make install check-env install_mcw

 - make sure sv2v verilog matches what is in tapein flow
    + vc Trace should be missing
    + modules should be prefixed
    + top-level interface should be different, with enables

```
 % diff \
   $TOPDIR/sim/build/grp_99_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v \
   $TODIR/verilog/rtl/grp_99_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v
```

### group 99 tapeout RTL simulation

 - edit `$TODIR/verilog/includes/includes.rtl.caravel_user_project`

```
 # Caravel user project includes
 -v $(USER_PROJECT_VERILOG)/rtl/grp_99_project_wrapper.v
 -v $(USER_PROJECT_VERILOG)/rtl/grp_99_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v

 % cd $TODIR
 % make verify-grp_99_test_loopback-rtl
 % make verify-grp_99_test_gcd_rtl_basic_0x0-rtl
 % make verify-grp_99_test_gcd_rtl_basic_0x5-rtl
 % make verify-grp_99_test_gcd_rtl_basic_3x9-rtl
 % make verify-grp_99_test_gcd_rtl_basic_5x0-rtl
```

### group 99 tapeout flow

    % cd $TODIR
    % make project-group99
    % make grp_99_project_wrapper

### group 99 tapeout GL simulation

 - edit `$TODIR/verilog/includes/includes.gl.caravel_user_project`

```
 # Caravel user project includes
 -v $(USER_PROJECT_VERILOG)/rtl/grp_99_project_wrapper.v
 -v $(USER_PROJECT_VERILOG)/gl/grp_99_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v

 % cd $TODIR
 % make verify-grp_99_test_loopback-gl
 % make verify-grp_99_test_gcd_rtl_basic_0x0-gl
 % make verify-grp_99_test_gcd_rtl_basic_0x5-gl
 % make verify-grp_99_test_gcd_rtl_basic_3x9-gl
 % make verify-grp_99_test_gcd_rtl_basic_5x0-gl
```

Assemble the Quad Block
--------------------------------------------------------------------------

 - All modules should already be instantiated in `user_project_wrapper.v`

### Re-run all RTL tests with wrapper

 - edit `$TODIR/verilog/includes/includes.rtl.caravel_user_project`

```
 # Caravel user project includes
   -v $(USER_PROJECT_VERILOG)/rtl/grp_99_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v
   -v $(USER_PROJECT_VERILOG)/rtl/grp_15_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v
   -v $(USER_PROJECT_VERILOG)/rtl/grp_17_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v
   -v $(USER_PROJECT_VERILOG)/rtl/grp_16_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v
   -v $(USER_PROJECT_VERILOG)/rtl/user_project_wrapper.v

 % cd $TODIR

 % make verify-grp_15_test_loopback-rtl
 % make verify-grp_15_test_small-rtl
 % make verify-grp_15_test_large-rtl
 % make verify-grp_15_test_long-rtl
 % make verify-grp_15_test_random-rtl

 % make verify-grp_16_test_loopback-rtl
 % make verify-grp_16_test_loopback_stream-rtl
 % make verify-grp_16_test_basic_msgs-rtl
 % make verify-grp_16_test_basic_multiple_msgs-rtl
 % make verify-grp_16_test_random_msgs-rtl

 % make verify-grp_17_test_loopback-rtl
 % make verify-grp_17_test_2x2-rtl
 % make verify-grp_17_test_2x4-rtl

 % make verify-grp_99_test_loopback-rtl
 % make verify-grp_99_test_gcd_rtl_basic_0x0-rtl
 % make verify-grp_99_test_gcd_rtl_basic_0x5-rtl
 % make verify-grp_99_test_gcd_rtl_basic_3x9-rtl
 % make verify-grp_99_test_gcd_rtl_basic_5x0-rtl
```

### Harden the chip

If you didn't already, make sure to make each macro (unnecessary to
do it again if you did before)

    % make project-group15
    % make project-group16
    % make project-group17
    % make project-group99

Harden the wrapper

    % make user_project_wrapper

### Re-run all GL tests with wrapper

 - edit `$TODIR/verilog/includes/includes.gl.caravel_user_project`

```
 # Caravel user project includes
 -v $(USER_PROJECT_VERILOG)/gl/user_project_wrapper.v
 -v $(USER_PROJECT_VERILOG)/gl/grp_99_SPI_TapeOutBlockRTL_32bits_5entries.v
 -v $(USER_PROJECT_VERILOG)/gl/grp_15_SPI_TapeOutBlockRTL_32bits_5entries.v
 -v $(USER_PROJECT_VERILOG)/gl/grp_17_SPI_TapeOutBlockRTL_32bits_5entries.v
 -v $(USER_PROJECT_VERILOG)/gl/grp_16_SPI_TapeOutBlockRTL_32bits_5entries.v

 % cd $TODIR

 % make verify-grp_15_test_loopback-gl
 % make verify-grp_15_test_small-gl
 % make verify-grp_15_test_large-gl
 % make verify-grp_15_test_long-gl
 % make verify-grp_15_test_random-gl

 % make verify-grp_16_test_loopback-gl
 % make verify-grp_16_test_loopback_stream-gl
 % make verify-grp_16_test_basic_msgs-gl
 % make verify-grp_16_test_basic_multiple_msgs-gl
 % make verify-grp_16_test_random_msgs-gl

 % make verify-grp_17_test_loopback-gl
 % make verify-grp_17_test_2x2-gl
 % make verify-grp_17_test_2x4-gl

 % make verify-grp_99_test_loopback-gl
 % make verify-grp_99_test_gcd_rtl_basic_0x0-gl
 % make verify-grp_99_test_gcd_rtl_basic_0x5-gl
 % make verify-grp_99_test_gcd_rtl_basic_3x9-gl
 % make verify-grp_99_test_gcd_rtl_basic_5x0-gl
```

### Check that we pass the precheck/tapeout checks

    % make precheck
    % make run-precheck

Note: user_project_wrapper.gds (in ece5745-tapeout/gds) may be larger
than GitHub can handle. Right now, it only has a warning, but for future
reference, if it becomes an issue, one can compress the files from the
top-level directory with

    % make compress

to compress them for a GitHub repo-friendly size. If you are pulling from
a compressed repository, the files can be uncompressed with

    % make uncompress
