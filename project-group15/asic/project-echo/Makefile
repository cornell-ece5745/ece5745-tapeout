SHELL := /bin/bash
all: tests sims flow_init flow_run
tests:
	mkdir -p ../../sim/build
	cd ../../sim/build; \
	pytest ../project/echo --test-verilog --dump-vtb
sims:
	cd ../../sim/build; \
	../project/echo/echo-sim --stats --translate --dump-vtb
flow_init:
	mkdir -p ../build/echo
	cd ../build/echo; \
	mflowgen run --design ../../../sim/project/echo
flow_run:
	cd ../build/echo; \
	make clean-all; \
	make 13
clean:
	rm -rf ../../sim/build
	rm -rf ../build/echo