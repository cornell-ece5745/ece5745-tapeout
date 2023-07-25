# # mkdir
# cd app
# mkdir build-native
# mkdir build
# cd ..
# cd sim
# mkdir build
# cd ..

# make x86
cd app/build-native
../configure
make ubmark-base
# run x86
./ubmark-base
cd ../..

# # make riscv
# cd app/build
# ../configure --host=riscv32-unknown-elf
# make ubmark-base
# riscv32-objdump ubmark-base > rv_assemb.out
# code rv_assemb.out
# cd ../..

# # run riscv
# cd sim/build
# ../pmx/pmx-sim ../../app/build/ubmark-base --limit 40000000 --trace