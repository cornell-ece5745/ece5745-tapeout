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
solution file add [file join $sfd ../src/tb4-int.cc] -type C++
solution file add [file join $sfd ../src/echo4-int-ref.cc] -type C++
solution file add [file join $sfd ../src/echo4-int.cc] -type C++
go compile

# Load Libraries
solution library add nangate-45nm_beh -- -rtlsyntool OasysRTL
go libraries

directive set -CLOCKS {clk {-CLOCK_PERIOD 1.11 }}
go assembly

# Apply IO and Loop Constraints
directive set /echo4_int/in1:rsc  -MAP_TO_MODULE ccs_ioport.ccs_in1_wait
directive set /echo4_int/in2:rsc  -MAP_TO_MODULE ccs_ioport.ccs_in2_wait
directive set /echo4_int/out1:rsc -MAP_TO_MODULE ccs_ioport.ccs_out1_wait
directive set /echo4_int/out2:rsc -MAP_TO_MODULE ccs_ioport.ccs_out2_wait

go extract

