# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "N_CHANNELS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "STRETCH_CYCLES" -parent ${Page_0}


}

proc update_PARAM_VALUE.N_CHANNELS { PARAM_VALUE.N_CHANNELS } {
	# Procedure called to update N_CHANNELS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_CHANNELS { PARAM_VALUE.N_CHANNELS } {
	# Procedure called to validate N_CHANNELS
	return true
}

proc update_PARAM_VALUE.STRETCH_CYCLES { PARAM_VALUE.STRETCH_CYCLES } {
	# Procedure called to update STRETCH_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STRETCH_CYCLES { PARAM_VALUE.STRETCH_CYCLES } {
	# Procedure called to validate STRETCH_CYCLES
	return true
}


proc update_MODELPARAM_VALUE.N_CHANNELS { MODELPARAM_VALUE.N_CHANNELS PARAM_VALUE.N_CHANNELS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_CHANNELS}] ${MODELPARAM_VALUE.N_CHANNELS}
}

proc update_MODELPARAM_VALUE.STRETCH_CYCLES { MODELPARAM_VALUE.STRETCH_CYCLES PARAM_VALUE.STRETCH_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STRETCH_CYCLES}] ${MODELPARAM_VALUE.STRETCH_CYCLES}
}

