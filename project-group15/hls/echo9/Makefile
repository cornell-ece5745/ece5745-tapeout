IDIR = /opt/MentorGraphics/catapult/shared/include
TDIR ?= $(shell pwd)
CC = /opt/MentorGraphics/catapult/bin/g++
CFLAGS = -g
MGC_HOME = /opt/MentorGraphics/catapult/

# Add source files
src_tb_int := src/echo9-int.cc src/echo9-int-ref.cc src/tb9-int.cc

# Make for synthesis
src_synth := run.tcl

tb_int: $(src_tb_int)
	mkdir -p build
	$(CC) -o $(TDIR)/build/tb_int $(src_tb_int) -I$(IDIR) $(CFLAGS)
	$(TDIR)/build/tb_int

debug: $(src_tb_int)
	$(CC) -o $(TDIR)/build/tb_int $(src_tb_int) -I$(IDIR) $(CFLAGS)
	$(MGC_HOME)/bin/gdb $(TDIR)/build/tb_int

synth: ccs/$(src_synth)
	rm -rf synthesis
	mkdir -p synthesis
	cd synthesis; catapult -shell -file ../ccs/$(src_synth)

.PHONY: clean
clean:
	rm -rf $(TDIR)/build
	rm -rf $(TDIR)/synthesis