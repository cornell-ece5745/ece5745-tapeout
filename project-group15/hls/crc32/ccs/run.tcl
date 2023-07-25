##
## Copyright 2003-2019 Siemens
##
#------------------------------------------------------------
# Basic Training: C++: Lab2 Initial Run
#------------------------------------------------------------

set sfd [file dirname [info script]]

options defaults
options set /Input/CppStandard c++11
options set /Input/Compiler Custom
options set Input/CompilerHome /opt/rh/devtoolset-9/root/usr/bin

project new

flow package require /SCVerify
flow package option set /SCVerify/USE_CCS_BLOCK true
flow package option set /SCVerify/USE_NCSIM true
flow package option set /SCVerify/USE_VCS true

# Read Design Files
solution file add [file join $sfd ../src/crc32-tb.cc] -type C++
solution file add [file join $sfd ../src/crc32-ref.cc] -type C++
solution file add [file join $sfd ../src/crc32.cc] -type C++
go compile

# Load Libraries
solution library add nangate-45nm_beh -- -rtlsyntool OasysRTL
go libraries

directive set -CLOCKS {clk {-CLOCK_PERIOD 1.11 }}
go assembly

# Apply IO and Loop Constraints
directive set /crc32/in:rsc  -MAP_TO_MODULE ccs_ioport.ccs_in_wait
directive set /crc32/out:rsc -MAP_TO_MODULE ccs_ioport.ccs_out_wait

go extract

