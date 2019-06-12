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
mkdir -p work
rm -rf bus.dump
rm -rf testbench
if [ "$enable_coverage" = "yes" ]; then
    echo "-c option is not available for ghdl."; exit 2;
fi

ghdl -i --workdir=work vhdl/tce_util_pkg.vhdl  || exit 1
ghdl -i --workdir=work vhdl/tta0_imem_mau_pkg.vhdl  || exit 1
ghdl -i --workdir=work vhdl/tta0_globals_pkg.vhdl  || exit 1
ghdl -i --workdir=work vhdl/tta0_params_pkg.vhdl  || exit 1
ghdl -i --workdir=work vhdl/lsu_le.vhdl  || exit 1
ghdl -i --workdir=work vhdl/stdout.vhdl  || exit 1
ghdl -i --workdir=work vhdl/util_pkg.vhdl  || exit 1
ghdl -i --workdir=work vhdl/monolithic_alu_shladd_medium.vhdl  || exit 1
ghdl -i --workdir=work vhdl/fixed_float_types_c.vhdl  || exit 1
ghdl -i --workdir=work vhdl/fixed_pkg_c.vhdl  || exit 1
ghdl -i --workdir=work vhdl/float_pkg_c.vhdl  || exit 1
ghdl -i --workdir=work vhdl/fpu_sp_conv.vhdl  || exit 1
ghdl -i --workdir=work vhdl/sabrewing_tce.vhd  || exit 1
ghdl -i --workdir=work vhdl/alu_pkg_lvl1.vhd  || exit 1
ghdl -i --workdir=work vhdl/alu_pkg_lvl2.vhd  || exit 1
ghdl -i --workdir=work vhdl/alu.vhd  || exit 1
ghdl -i --workdir=work vhdl/frontend.vhd  || exit 1
ghdl -i --workdir=work vhdl/exponent_alignment_compare.vhd  || exit 1
ghdl -i --workdir=work vhdl/shiftright_conditionalcomplement.vhd  || exit 1
ghdl -i --workdir=work vhdl/stickybit_generation.vhd  || exit 1
ghdl -i --workdir=work vhdl/comparator.vhd  || exit 1
ghdl -i --workdir=work vhdl/dw.vhd  || exit 1
ghdl -i --workdir=work vhdl/dw_clone.vhd  || exit 1
ghdl -i --workdir=work vhdl/conditional_recomplement.vhd  || exit 1
ghdl -i --workdir=work vhdl/integer_status_control.vhd  || exit 1
ghdl -i --workdir=work vhdl/lza.vhd  || exit 1
ghdl -i --workdir=work vhdl/lzd.vhd  || exit 1
ghdl -i --workdir=work vhdl/normalize.vhd  || exit 1
ghdl -i --workdir=work vhdl/round.vhd  || exit 1
ghdl -i --workdir=work vhdl/backend.vhd  || exit 1
ghdl -i --workdir=work vhdl/fpu_sp_div.vhdl  || exit 1
ghdl -i --workdir=work vhdl/fu_bnn_ops.vhd  || exit 1
ghdl -i --workdir=work vhdl/rf_1wr_1rd_always_1_guarded_0.vhd  || exit 1
ghdl -i --workdir=work vhdl/tta0_imem_mau_pkg.vhdl  || exit 1
ghdl -i --workdir=work vhdl/tta0.vhdl  || exit 1

ghdl -i --workdir=work gcu_ic/gcu_opcodes_pkg.vhdl  || exit 1
ghdl -i --workdir=work gcu_ic/datapath_gate.vhdl  || exit 1
ghdl -i --workdir=work gcu_ic/decoder.vhdl  || exit 1
ghdl -i --workdir=work gcu_ic/output_socket_3_1.vhdl  || exit 1
ghdl -i --workdir=work gcu_ic/idecompressor.vhdl  || exit 1
ghdl -i --workdir=work gcu_ic/ifetch.vhdl  || exit 1
ghdl -i --workdir=work gcu_ic/input_mux_3.vhdl  || exit 1
ghdl -i --workdir=work gcu_ic/output_socket_1_1.vhdl  || exit 1
ghdl -i --workdir=work gcu_ic/ic.vhdl  || exit 1

ghdl -i --workdir=work tb/proc_params_pkg.vhdl  || exit 1
ghdl -i --workdir=work tb/clkgen.vhdl  || exit 1
ghdl -i --workdir=work tb/proc.vhdl  || exit 1
ghdl -i --workdir=work tb/synch_sram.vhdl  || exit 1
ghdl -i --workdir=work tb/testbench.vhdl  || exit 1

ghdl -m --workdir=work --ieee=synopsys -fexplicit testbench
exit 0
