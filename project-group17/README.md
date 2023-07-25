
ECE 5745 Group 17
==========================================================================

[![Build Status](https://github.com/cornell-ece5745/project-group17/actions/workflows/run_tests.yml/badge.svg)](https://github.com/cornell-ece5745/project-group17/actions)

This is the code repository for your ECE 5745 assignment. You will use
this repository to collaborate with your group members, run continuous
integration tests, and submit each assignment.

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

 * https://github.com/cornell-ece5745/project-group17/actions

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

### Push the tapeout design to the tapein flow
cd sim

mkdir build

cd build

pytest ../systolic_accelerator/ --test-verilog --dump-vtb

pytest ../tapeout/chip_test/SPIstack_test.py -v --tb=short --test-verilog --dump-vtb

cp grp_17_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v ../tapeout/grp_17_SPI_TapeOutBlockRTL_32bits_5entries.v

cd ../../asic

mkdir build

cd build

mkdir tapeout-block

cd tapeout-block

rm -r -f *

mflowgen run --design ../../tapeout-block

make

### Push the tapeout design to the tapeout flow

cp the pickled file to verilog/rtl

make install check-env install_mcw

make project-group17
