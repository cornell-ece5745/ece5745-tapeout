SHELL := /bin/bash
all: tests sims flow_init flow_run
tests:
	mkdir -p ../../sim/build
	cd ../../sim/build; \
	pytest ../project/lz77simple/block_test --test-verilog --dump-vtb --tb=short -x
sims: 
	cd ../../sim/build; \
	../project/lz77/crc32-sim --stats --translate --dump-vtb --input large
flow_init: 
	mkdir -p ../build/lz77simple
	cd ../build/lz77simple; \
	mflowgen run --design ../../../sim/project/lz77simple
flow_run: 
	cd ../build/lz77simple;
	make 13
clean:
	rm -rf ../../sim/build
	rm -rf ../build/lz77simple
