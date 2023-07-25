### Clone and test SPI tapeout block, dump vtb

```
git clone git@github.com:cornell-ece5745/project-group16.git
cd project-group16
TOPDIR=$PWD
mkdir -p $TOPDIR/sim/build
cd sim/build
pytest ../tapeout/chip_test -v --tb=short --test-verilog --dump-vtb 
```

### Run mflowgen flow

```
cd $TOPDIR/asic
mkdir -p $TOPDIR/asic/build-tapeout-block
cd build-tapeout-block
mflowgen run --design ../tapeout-block
make 
```

### Copy files over to efabless

```
cd $TOPDIR/sim/build 
```

### copy to wherever you have cloned ece5745-tapeout

```
cp grp_16_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v ece5745-tapeout/verilog/rtl
```

### Add the following lines in your top module's interface:

```
`ifdef USE_POWER_PINS
 inout vccd1, // User area 1 1.8V supply
 inout vssd1, // User area 1 digital ground
`endif
cd ece5745-tapeout
make project-group16
```
