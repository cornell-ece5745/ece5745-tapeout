
ECE 5745 Group 15
==========================================================================

[![Build Status](https://github.com/cornell-ece5745/project-group15/actions/workflows/run_tests.yml/badge.svg)](https://github.com/cornell-ece5745/project-group15/actions)

This is the code repository for your ECE 5745 assignment. You will use
this repository to collaborate with your group members, run continuous
integration tests, and submit each assignment.


### Tapeout Commands 
```
% git clone git@github.com:cornell-ece5745/project-group15.git
% cd project-group15
% TOPDIR=$PWD
% mkdir -p $TOPDIR/sim/build
% cd sim/build
# There are no block tests
# pytest ../tapeout/block_test -v --tb=short
# Run tests that will generate pickled file, as well as VTB's for simulation in our flow
% pytest ../tapeout/chip_test -v --tb=short --test-yosys-verilog --dump-vtb 
# Run mflowgen flow
% cd $TOPDIR/asic
% mkdir -p $TOPDIR/asic/build-tapeout
% cd build-tapeout
% mflowgen run --design ../tapeout-block
% make 

# Copy files over to efabless
% cd $TOPDIR/sim/build 
# copy to wherever you have cloned ece5745-tapeout
% cp grp_15_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v ece5745-tapeout/verilog/rtl
% cd ece5745-tapeout
% make project-group15
```

### How to use repo

1. From hls/whatever: make all
2. From asic/whatever:
  1. make tests
  2. make sims
  3. make flow_init
  4. make flow_run

### GitHub Actions Continuous Integration

We will be using GitHub Actions as our continuous integration service.
Continuous integration means all of the tests for your repository will be
run automatically every time you push to this repository. The current
status of these tests is shown as an image at the top of the README. If
the image says "failing" then your repository is currently failing one or
more tests; if the image says "passed" then your repository is passing
all tests. You can click on the image or on the following direct link to
go to the GitHub Actions build report to find out more about which tests
are passing or failing.

 * https://github.com/cornell-ece5745/project-group15/actions

### GitHub and Academic Integrity Violations

Students are explicitly prohibited from sharing their code with anyone
that is not within their group or on the course staff. This includes
making public forks or duplicating this repository on a different
repository hosting service. Students are also explicitly prohibited from
manipulating the Git history or changing any of the tags that are created
by the course staff. The course staff maintain a copy of all
repositories, so we will easily discover if a student manipulates a
repository in some inappropriate way. Normal users will never have an
issue, but advanced users have been warned.

Sharing code, manipulating the Git history, or changing staff tags will
be considered a violation of the Code of Academic Integrity. A primary
hearing will be held, and if found guilty, students will face a serious
penalty on their grade for this course. More information about the Code
of Academic Integrity can be found here:

 * https://theuniversityfaculty.cornell.edu/dean/academic-integrity

