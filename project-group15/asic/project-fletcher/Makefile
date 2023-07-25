SHELL := /bin/bash
all: tests sims flow_init flow_run
tests:
	mkdir -p ../../sim/build
	cd ../../sim/build; \
	pytest ../project/fletcher --test-verilog --dump-vtb
sims:
	cd ../../sim/build; \
	../project/fletcher/fletcher-sim --stats --translate --dump-vtb
flow_init:
	mkdir -p ../build/fletcher
	cd ../build/fletcher; \
	mflowgen run --design ../../../sim/project/fletcher
flow_run:
	cd ../build/fletcher; \
	make 13
clean:
	rm -rf ../../sim/build
	rm -rf ../build/fletcher