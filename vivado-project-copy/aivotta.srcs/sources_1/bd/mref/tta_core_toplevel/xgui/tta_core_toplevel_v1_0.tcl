# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "axi_addr_width_g" -parent ${Page_0}
  ipgui::add_param $IPINST -name "axi_id_width_g" -parent ${Page_0}
  ipgui::add_param $IPINST -name "local_mem_addrw_g" -parent ${Page_0}


}

proc update_PARAM_VALUE.axi_addr_width_g { PARAM_VALUE.axi_addr_width_g } {
	# Procedure called to update axi_addr_width_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.axi_addr_width_g { PARAM_VALUE.axi_addr_width_g } {
	# Procedure called to validate axi_addr_width_g
	return true
}

proc update_PARAM_VALUE.axi_id_width_g { PARAM_VALUE.axi_id_width_g } {
	# Procedure called to update axi_id_width_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.axi_id_width_g { PARAM_VALUE.axi_id_width_g } {
	# Procedure called to validate axi_id_width_g
	return true
}

proc update_PARAM_VALUE.local_mem_addrw_g { PARAM_VALUE.local_mem_addrw_g } {
	# Procedure called to update local_mem_addrw_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.local_mem_addrw_g { PARAM_VALUE.local_mem_addrw_g } {
	# Procedure called to validate local_mem_addrw_g
	return true
}


proc update_MODELPARAM_VALUE.axi_addr_width_g { MODELPARAM_VALUE.axi_addr_width_g PARAM_VALUE.axi_addr_width_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.axi_addr_width_g}] ${MODELPARAM_VALUE.axi_addr_width_g}
}

proc update_MODELPARAM_VALUE.axi_id_width_g { MODELPARAM_VALUE.axi_id_width_g PARAM_VALUE.axi_id_width_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.axi_id_width_g}] ${MODELPARAM_VALUE.axi_id_width_g}
}

proc update_MODELPARAM_VALUE.local_mem_addrw_g { MODELPARAM_VALUE.local_mem_addrw_g PARAM_VALUE.local_mem_addrw_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.local_mem_addrw_g}] ${MODELPARAM_VALUE.local_mem_addrw_g}
}

