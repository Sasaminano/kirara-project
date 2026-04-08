# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "SHAKE_THRESH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TILT_THRESH" -parent ${Page_0}


}

proc update_PARAM_VALUE.SHAKE_THRESH { PARAM_VALUE.SHAKE_THRESH } {
	# Procedure called to update SHAKE_THRESH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHAKE_THRESH { PARAM_VALUE.SHAKE_THRESH } {
	# Procedure called to validate SHAKE_THRESH
	return true
}

proc update_PARAM_VALUE.TILT_THRESH { PARAM_VALUE.TILT_THRESH } {
	# Procedure called to update TILT_THRESH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TILT_THRESH { PARAM_VALUE.TILT_THRESH } {
	# Procedure called to validate TILT_THRESH
	return true
}


proc update_MODELPARAM_VALUE.TILT_THRESH { MODELPARAM_VALUE.TILT_THRESH PARAM_VALUE.TILT_THRESH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TILT_THRESH}] ${MODELPARAM_VALUE.TILT_THRESH}
}

proc update_MODELPARAM_VALUE.SHAKE_THRESH { MODELPARAM_VALUE.SHAKE_THRESH PARAM_VALUE.SHAKE_THRESH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHAKE_THRESH}] ${MODELPARAM_VALUE.SHAKE_THRESH}
}

