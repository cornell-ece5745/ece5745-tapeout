cd sim/build
pytest ../area_test/ --test-verilog --dump-vtb
cd ../../asic/build
mflowgen run --design ../RegFileTestArea
make 4 > log.out
code log.out