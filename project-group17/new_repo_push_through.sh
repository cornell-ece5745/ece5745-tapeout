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
make 3 4 5 6
