SHELL := /bin/bash
all: tests sims flow_init flow_run
tests:
	mkdir -p ../../sim/build
	cd ../../sim/build; \
	pytest ../project/crc32/block_test --test-verilog --dump-vtb --tb=short -x
sims: 
	cd ../../sim/build; \
	../project/crc32/crc32-sim --stats --translate --dump-vtb --input large; \
	../project/crc32/crc32-sim --stats --translate --dump-vtb --input small; \
	../project/crc32/crc32-sim --stats --translate --dump-vtb --input random
flow_init: 
	mkdir -p ../build/crc32
	cd ../build/crc32; \
	mflowgen run --design ../../../sim/project/crc32
flow_run:
	cd ../build/crc32; \
	make clean-all; \
	make 13
clean:
	rm -rf ../../sim/build
	rm -rf ../build/crc32