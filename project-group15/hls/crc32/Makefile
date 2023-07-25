SHELL := /bin/bash
IDIR = /opt/MentorGraphics/catapult/shared/include
TDIR ?= $(shell pwd)
CC = /opt/MentorGraphics/catapult/bin/g++
CFLAGS = -g
MGC_HOME = /opt/MentorGraphics/catapult/

# Add source files
src_crc_tb := src/crc32.cc src/crc32-ref.cc src/crc32-tb.cc

# Make for synthesis
src_synth := run.tcl

# Solution name
v = crc32.v1

all: crc_tb synth cosim

unroll: src_crc_tb := src/crc32_unroll_inner.cc src/crc32-ref.cc src/crc32-tb.cc
unroll:	src_synth := run_unroll_inner.tcl
unroll: all

unroll_outer: src_crc_tb := src/crc32_unroll_outer.cc src/crc32-ref.cc src/crc32-tb.cc
unroll_outer:	src_synth := run_unroll_outer.tcl
unroll_outer: all

pipeline: src_crc_tb := src/crc32_pipelined.cc src/crc32-ref.cc src/crc32-tb.cc
pipeline: src_synth := run_pipelined.tcl
pipeline: all

crc_tb: $(src_crc_tb)
	mkdir -p build
	$(CC) -o $(TDIR)/build/crc_tb $(src_crc_tb) -I$(IDIR) $(CFLAGS)
	$(TDIR)/build/crc_tb

debug: $(src_crc_tb)
	$(CC) -o $(TDIR)/build/crc_tb $(src_crc_tb) -I$(IDIR) $(CFLAGS)
	$(MGC_HOME)/bin/gdb $(TDIR)/build/crc_tb

synth: ccs/$(src_synth)
	rm -rf synthesis; mkdir -p synthesis;
	source $$MODULESHOME/init/bash; module load catapult; cd synthesis; catapult -shell -file ../ccs/$(src_synth)
	cp synthesis/Catapult/crc32.v1/concat_rtl.v ../../sim/project/crc32/concat_rtl.v

cosim: ccs/$(src_synth)
	cp ccs/ccs_vcs.mk synthesis/Catapult/$(v)/ccs_vcs.mk
	cd synthesis/Catapult/$(v); sed -i 's/include $$(MGC_HOME)\/shared\/include\/mkfiles\/ccs_$$(SIMTOOL).mk/include .\/ccs_vcs.mk/g' scverify/Verify_concat_sim_rtl_v_vcs.mk; sed -i 's/include $$(MGC_HOME)\/shared\/include\/mkfiles\/ccs_$$(RTLTOOL).mk/include .\/ccs_vcs.mk/g' scverify/Verify_concat_sim_rtl_v_vcs.mk
	module load synopsys-vcs-R-2020.12; cd synthesis/Catapult/$(v); make -f scverify/Verify_concat_sim_rtl_v_vcs.mk build; make -f scverify/Verify_concat_sim_rtl_v_vcs.mk sim

.PHONY: clean
clean:
	rm -rf $(TDIR)/build
	rm -rf $(TDIR)/synthesis
