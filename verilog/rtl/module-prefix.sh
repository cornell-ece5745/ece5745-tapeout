#=============CHANGE TARGETS==================
TARGET_FILE=grp_17_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v
PREFIX="grp_17_"
#=============================================

# Get module names

MODULENAMES=grep "module" $TARGET_FILE | \
  grep -v "endmodule" | \
  cut -d ' ' -f2

MODULENAMESARRAY=(`echo $MODULENAMES | tr ' ' ' '`)

# For each module name, replace with prefix

for i in "${MODULENAMESARRAY[@]}"
do
    MODULE_WITH_PREFIX="$PREFIX$i "
    MODULE_WITHOUT_PREFIX="$i "
    sed -i "s/$MODULE_WITHOUT_PREFIX/$MODULE_WITH_PREFIX/g" $TARGET_FILE
    echo $i
done