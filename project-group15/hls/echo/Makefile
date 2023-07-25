SHELL := /bin/bash
IDIR = /opt/MentorGraphics/catapult/shared/include
TDIR ?= $(shell pwd)
CC = /opt/MentorGraphics/catapult/bin/g++
CFLAGS = -g

# Add source files
src_tb_int := src/echo-int.cc src/echo-int-ref.cc src/tb-int.cc

# Make for synthesis
src_synth := run.tcl

all: tb_int synth

tb_int: $(src_tb_int)
	mkdir -p build
	$(CC) -o $(TDIR)/build/tb_int $(src_tb_int) -I$(IDIR) $(CFLAGS)
	$(TDIR)/build/tb_int

synth: ccs/$(src_synth)
	rm -rf synthesis; mkdir -p synthesis;
	source $$MODULESHOME/init/bash; module load catapult; cd synthesis; catapult -shell -file ../ccs/$(src_synth)

sim: ccs/$(src_synth)
	cp ccs/ccs_vcs.mk synthesis/Catapult/echo_int.v1/ccs_vcs.mk
	cd synthesis/Catapult/echo_int.v1; sed -i 's/include $$(MGC_HOME)\/shared\/include\/mkfiles\/ccs_$$(SIMTOOL).mk/include .\/ccs_vcs.mk/g' scverify/Verify_concat_sim_rtl_v_vcs.mk; sed -i 's/include $$(MGC_HOME)\/shared\/include\/mkfiles\/ccs_$$(RTLTOOL).mk/include .\/ccs_vcs.mk/g' scverify/Verify_concat_sim_rtl_v_vcs.mk
	module load synopsys-vcs-R-2020.12; cd synthesis/Catapult/echo_int.v1; make -f scverify/Verify_concat_sim_rtl_v_vcs.mk build; make -f scverify/Verify_concat_sim_rtl_v_vcs.mk sim

.PHONY: clean
clean:
	rm -rf $(TDIR)/build
	rm -rf $(TDIR)/synthesis
