#!/bin/bash
# This script was automatically generated.

function usage() {
    echo "Usage: $0 [options]"
    echo "Prepares processor design for RTL simulation."
    echo "Options:"
    echo "  -c     Enables code coverage."
    echo "  -h     This helpful help text."
}

# Function to do clean up when this script exits.
function cleanup() {
    true # Dummy command. Can not have empty function.
}
trap cleanup EXIT

OPTIND=1
while getopts "ch" OPTION
do
    case $OPTION in
        c)
            enable_coverage=yes
            ;;
        h)
            usage
            exit 0
            ;;
        ?)  
            echo "Unknown option -$OPTARG"
            usage
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

rm -rf work
vlib work
vmap
if [ "$enable_coverage" = "yes" ]; then
    coverage_opt="+cover=sbcet"
fi

vcom vhdl/tce_util_pkg.vhdl || exit 1
vcom vhdl/tta0_imem_mau_pkg.vhdl || exit 1
vcom vhdl/tta0_globals_pkg.vhdl || exit 1
vcom vhdl/tta0_params_pkg.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/lsu_le.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/stdout.vhdl || exit 1
vcom vhdl/util_pkg.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/monolithic_alu_shladd_medium.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/fixed_float_types_c.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/fixed_pkg_c.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/float_pkg_c.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/fpu_sp_conv.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/sabrewing_tce.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/alu_pkg_lvl1.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/alu_pkg_lvl2.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/alu.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/frontend.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/exponent_alignment_compare.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/shiftright_conditionalcomplement.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/stickybit_generation.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/comparator.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/dw.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/dw_clone.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/conditional_recomplement.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/integer_status_control.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/lza.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/lzd.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/normalize.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/round.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/backend.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/fpu_sp_div.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/fu_bnn_ops.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/rf_1wr_1rd_always_1_guarded_0.vhd || exit 1
vcom vhdl/tta0_imem_mau_pkg.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/tta0.vhdl || exit 1

vcom -check_synthesis gcu_ic/gcu_opcodes_pkg.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/datapath_gate.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/decoder.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/output_socket_3_1.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/idecompressor.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/ifetch.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/input_mux_3.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/output_socket_1_1.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/ic.vhdl || exit 1

vcom tb/proc_params_pkg.vhdl || exit 1
vcom tb/clkgen.vhdl || exit 1
vcom tb/proc.vhdl || exit 1
vcom tb/synch_sram.vhdl || exit 1
vcom tb/testbench.vhdl || exit 1
exit 0
