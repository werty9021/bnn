# This script runs Vivado synthesis and place+route for the TTA core
# loading constraints from constraints.xdc and produces a hierarchical
# utilization summary
set script_path [ file dirname [ file normalize [ info script ] ] ]
set sources [join [list $script_path "/{platform,gcu_ic,vhdl}/*"] ""]
read_vhdl [glob $sources]
read_xdc [join [list $script_path "constraints.xdc"] "/"]
synth_design -top tta_core_toplevel \
             -part xc7z020clg400-1 \
             -flatten none -mode out_of_context
opt_design
place_design
route_design
report_utilization -force -hierarchical -hierarchical_depth 20 \
                   -file utilization.txt

