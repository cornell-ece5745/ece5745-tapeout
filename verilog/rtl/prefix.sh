unset TARGET_FILE
unset PREFIX
unset MODULENAMES
unset MODULENAMESARRAY
unset MODULE_WITH_PREFIX
unset MODULE_WITHOUT_PREFIX

#=============CHANGE TARGETS==================
TARGET_FILE=grp_16_SPI_TapeOutBlockRTL_32bits_5entries__pickled.v 
PREFIX="grp_16_"
#=============================================

# Get module names

NAMES=($(grep "module" $TARGET_FILE | \
  grep -v "endmodule" | \
  cut -d ' ' -f2))

# For each module name, replace with prefix

for i in "${NAMES[@]}"
do
    MODULE_WITH_PREFIX="$PREFIX$i "
    MODULE_WITHOUT_PREFIX="$i "
    sed -i "s/$MODULE_WITHOUT_PREFIX/$MODULE_WITH_PREFIX/g" $TARGET_FILE
    echo $i
done