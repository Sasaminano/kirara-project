
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# audio_loudness_wrapper, audio_output, camera_wrapper, imu_wrapper, input_integration_unit, seven_seg_driver, video_kirara_stub_800x600

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
   set_property BOARD_PART digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set usb_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 usb_uart ]

  # Create ports
  set an [ create_bd_port -dir O -from 7 -to 0 an ]
  set aud_pwm [ create_bd_port -dir O aud_pwm ]
  set aud_sd [ create_bd_port -dir O aud_sd ]
  set cam_d [ create_bd_port -dir I -from 7 -to 0 cam_d ]
  set cam_href [ create_bd_port -dir I cam_href ]
  set cam_pclk [ create_bd_port -dir I cam_pclk ]
  set cam_pwdn [ create_bd_port -dir O cam_pwdn ]
  set cam_reset [ create_bd_port -dir O -type rst cam_reset ]
  set cam_sioc [ create_bd_port -dir O cam_sioc ]
  set cam_siod [ create_bd_port -dir IO cam_siod ]
  set cam_vsync [ create_bd_port -dir I cam_vsync ]
  set cam_xclk [ create_bd_port -dir O cam_xclk ]
  set dp [ create_bd_port -dir O dp ]
  set imu_shake_active [ create_bd_port -dir O imu_shake_active ]
  set imu_tilt_active [ create_bd_port -dir O imu_tilt_active ]
  set led_high [ create_bd_port -dir O -from 9 -to 0 led_high ]
  set mic_active [ create_bd_port -dir O mic_active ]
  set mic_clk [ create_bd_port -dir O -type clk mic_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {3125000} \
 ] $mic_clk
  set mic_data [ create_bd_port -dir I mic_data ]
  set mic_lrsel [ create_bd_port -dir O mic_lrsel ]
  set red_detect_enable [ create_bd_port -dir I red_detect_enable ]
  set red_detected [ create_bd_port -dir O red_detected ]
  set resetn [ create_bd_port -dir I -type rst resetn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $resetn
  set seg [ create_bd_port -dir O -from 6 -to 0 seg ]
  set spi_cs_ag_0 [ create_bd_port -dir O spi_cs_ag_0 ]
  set spi_cs_alt_0 [ create_bd_port -dir O spi_cs_alt_0 ]
  set spi_cs_mag_0 [ create_bd_port -dir O spi_cs_mag_0 ]
  set spi_miso_0 [ create_bd_port -dir I spi_miso_0 ]
  set spi_mosi_0 [ create_bd_port -dir O spi_mosi_0 ]
  set spi_sclk_0 [ create_bd_port -dir O spi_sclk_0 ]
  set sys_clk [ create_bd_port -dir I -type clk sys_clk ]
  set vga_blue_0 [ create_bd_port -dir O -from 3 -to 0 vga_blue_0 ]
  set vga_green_0 [ create_bd_port -dir O -from 3 -to 0 vga_green_0 ]
  set vga_hsync_0 [ create_bd_port -dir O vga_hsync_0 ]
  set vga_red_0 [ create_bd_port -dir O -from 3 -to 0 vga_red_0 ]
  set vga_vsync_0 [ create_bd_port -dir O vga_vsync_0 ]

  # Create instance: audio_loudness_wrapp_0, and set properties
  set block_name audio_loudness_wrapper
  set block_cell_name audio_loudness_wrapp_0
  if { [catch {set audio_loudness_wrapp_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $audio_loudness_wrapp_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: audio_output_0, and set properties
  set block_name audio_output
  set block_cell_name audio_output_0
  if { [catch {set audio_output_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $audio_output_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS_2 {1} \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_GPIO2_WIDTH {8} \
   CONFIG.C_GPIO_WIDTH {27} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.GPIO_BOARD_INTERFACE {Custom} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_gpio_0

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
   CONFIG.UARTLITE_BOARD_INTERFACE {usb_uart} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_uartlite_0

  # Create instance: camera_wrapper_0, and set properties
  set block_name camera_wrapper
  set block_cell_name camera_wrapper_0
  if { [catch {set camera_wrapper_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $camera_wrapper_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {116.394} \
   CONFIG.CLKOUT1_PHASE_ERROR {87.466} \
   CONFIG.CLKOUT2_JITTER {123.264} \
   CONFIG.CLKOUT2_PHASE_ERROR {87.466} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {74.25} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {156.161} \
   CONFIG.CLKOUT3_PHASE_ERROR {87.466} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {25} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLK_OUT1_PORT {sys_clk} \
   CONFIG.CLK_OUT2_PORT {pix_clk} \
   CONFIG.CLK_OUT3_PORT {cam_clk} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {11.875} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {11.875} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {16} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {48} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {3} \
   CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.RESET_PORT {resetn} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz_1

  # Create instance: imu_wrapper_0, and set properties
  set block_name imu_wrapper
  set block_cell_name imu_wrapper_0
  if { [catch {set imu_wrapper_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $imu_wrapper_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: input_integration_un_0, and set properties
  set block_name input_integration_unit
  set block_cell_name input_integration_un_0
  if { [catch {set input_integration_un_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $input_integration_un_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0 ]
  set_property -dict [ list \
   CONFIG.C_DEBUG_ENABLED {1} \
   CONFIG.C_D_AXI {1} \
   CONFIG.C_D_LMB {1} \
   CONFIG.C_I_LMB {1} \
 ] $microblaze_0

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
 ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: pmod_nav_hw_controll_0, and set properties
  set pmod_nav_hw_controll_0 [ create_bd_cell -type ip -vlnv user.org:user:pmod_nav_hw_controller:2.0 pmod_nav_hw_controll_0 ]

  # Create instance: rgb2vga_0, and set properties
  set rgb2vga_0 [ create_bd_cell -type ip -vlnv digilentinc.com:ip:rgb2vga:1.0 rgb2vga_0 ]
  set_property -dict [ list \
   CONFIG.VID_IN_DATA_WIDTH {12} \
   CONFIG.kBlueDepth {4} \
   CONFIG.kGreenDepth {4} \
   CONFIG.kRedDepth {4} \
 ] $rgb2vga_0

  # Create instance: rst_clk_wiz_1_100M, and set properties
  set rst_clk_wiz_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_1_100M ]
  set_property -dict [ list \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $rst_clk_wiz_1_100M

  # Create instance: rst_clk_wiz_1_24M, and set properties
  set rst_clk_wiz_1_24M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_1_24M ]

  # Create instance: rst_clk_wiz_1_74M, and set properties
  set rst_clk_wiz_1_74M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_1_74M ]
  set_property -dict [ list \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $rst_clk_wiz_1_74M

  # Create instance: seven_seg_driver_0, and set properties
  set block_name seven_seg_driver
  set block_cell_name seven_seg_driver_0
  if { [catch {set seven_seg_driver_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $seven_seg_driver_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sound_en_slice_0, and set properties
  set sound_en_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sound_en_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {26} \
   CONFIG.DIN_TO {26} \
   CONFIG.DIN_WIDTH {27} \
   CONFIG.DOUT_WIDTH {1} \
 ] $sound_en_slice_0

  # Create instance: sound_sel_slice_0, and set properties
  set sound_sel_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sound_sel_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {25} \
   CONFIG.DIN_TO {23} \
   CONFIG.DIN_WIDTH {27} \
   CONFIG.DOUT_WIDTH {3} \
 ] $sound_sel_slice_0

  # Create instance: sprite_sel_slice_0, and set properties
  set sprite_sel_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sprite_sel_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {27} \
   CONFIG.DOUT_WIDTH {3} \
 ] $sprite_sel_slice_0

  # Create instance: sprite_x_slice_0, and set properties
  set sprite_x_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sprite_x_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {12} \
   CONFIG.DIN_TO {3} \
   CONFIG.DIN_WIDTH {27} \
   CONFIG.DOUT_WIDTH {10} \
 ] $sprite_x_slice_0

  # Create instance: sprite_y_slice_0, and set properties
  set sprite_y_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sprite_y_slice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {22} \
   CONFIG.DIN_TO {13} \
   CONFIG.DIN_WIDTH {27} \
   CONFIG.DOUT_WIDTH {10} \
 ] $sprite_y_slice_0

  # Create instance: video_kirara_stub_80_0, and set properties
  set block_name video_kirara_stub_800x600
  set block_cell_name video_kirara_stub_80_0
  if { [catch {set video_kirara_stub_80_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $video_kirara_stub_80_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.IN0_WIDTH {1} \
   CONFIG.IN1_WIDTH {1} \
   CONFIG.IN2_WIDTH {4} \
   CONFIG.IN3_WIDTH {1} \
   CONFIG.IN4_WIDTH {1} \
   CONFIG.NUM_PORTS {5} \
 ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports usb_uart] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M00_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI] [get_bd_intf_pins pmod_nav_hw_controll_0/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]

  # Create port connections
  connect_bd_net -net Net [get_bd_ports cam_siod] [get_bd_pins camera_wrapper_0/cam_siod]
  connect_bd_net -net audio_loudness_wrapp_0_led_high [get_bd_ports led_high] [get_bd_pins audio_loudness_wrapp_0/led_high] [get_bd_pins seven_seg_driver_0/mic_buffer]
  connect_bd_net -net audio_loudness_wrapp_0_mic_active [get_bd_pins audio_loudness_wrapp_0/mic_active] [get_bd_pins input_integration_un_0/mic_active_in] [get_bd_pins seven_seg_driver_0/mic_active]
  connect_bd_net -net audio_loudness_wrapp_0_mic_clk [get_bd_ports mic_clk] [get_bd_pins audio_loudness_wrapp_0/mic_clk]
  connect_bd_net -net audio_loudness_wrapp_0_mic_lrsel [get_bd_ports mic_lrsel] [get_bd_pins audio_loudness_wrapp_0/mic_lrsel]
  connect_bd_net -net audio_output_0_AUD_PWM [get_bd_ports aud_pwm] [get_bd_pins audio_output_0/AUD_PWM]
  connect_bd_net -net audio_output_0_AUD_SD [get_bd_ports aud_sd] [get_bd_pins audio_output_0/AUD_SD]
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins sound_en_slice_0/Din] [get_bd_pins sound_sel_slice_0/Din] [get_bd_pins sprite_sel_slice_0/Din] [get_bd_pins sprite_x_slice_0/Din] [get_bd_pins sprite_y_slice_0/Din]
  connect_bd_net -net cam_d_0_1 [get_bd_ports cam_d] [get_bd_pins camera_wrapper_0/cam_d]
  connect_bd_net -net cam_href_0_1 [get_bd_ports cam_href] [get_bd_pins camera_wrapper_0/cam_href]
  connect_bd_net -net cam_pclk_0_1 [get_bd_ports cam_pclk] [get_bd_pins camera_wrapper_0/cam_pclk]
  connect_bd_net -net cam_vsync_0_1 [get_bd_ports cam_vsync] [get_bd_pins camera_wrapper_0/cam_vsync]
  connect_bd_net -net camera_wrapper_0_cam_pwdn [get_bd_ports cam_pwdn] [get_bd_pins camera_wrapper_0/cam_pwdn]
  connect_bd_net -net camera_wrapper_0_cam_reset [get_bd_ports cam_reset] [get_bd_pins camera_wrapper_0/cam_reset]
  connect_bd_net -net camera_wrapper_0_cam_sioc [get_bd_ports cam_sioc] [get_bd_pins camera_wrapper_0/cam_sioc]
  connect_bd_net -net camera_wrapper_0_cam_xclk [get_bd_ports cam_xclk] [get_bd_pins camera_wrapper_0/cam_xclk]
  connect_bd_net -net camera_wrapper_0_red_detected1 [get_bd_pins camera_wrapper_0/red_detected] [get_bd_pins input_integration_un_0/red_detected_in] [get_bd_pins seven_seg_driver_0/red_detected]
  connect_bd_net -net camera_wrapper_0_red_quadrant [get_bd_pins camera_wrapper_0/red_quadrant] [get_bd_pins seven_seg_driver_0/quadrant_detected] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net clk_in1_0_1 [get_bd_ports sys_clk] [get_bd_pins clk_wiz_1/clk_in1]
  connect_bd_net -net clk_wiz_1_cam_clk [get_bd_pins camera_wrapper_0/clk_25mhz] [get_bd_pins clk_wiz_1/cam_clk] [get_bd_pins rst_clk_wiz_1_24M/slowest_sync_clk]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_clk_wiz_1_100M/dcm_locked] [get_bd_pins rst_clk_wiz_1_24M/dcm_locked] [get_bd_pins rst_clk_wiz_1_74M/dcm_locked]
  connect_bd_net -net clk_wiz_1_pix_clk [get_bd_pins clk_wiz_1/pix_clk] [get_bd_pins rgb2vga_0/PixelClk] [get_bd_pins rst_clk_wiz_1_74M/slowest_sync_clk] [get_bd_pins video_kirara_stub_80_0/pix_clk]
  connect_bd_net -net imu_wrapper_0_shake_active [get_bd_pins imu_wrapper_0/shake_active] [get_bd_pins input_integration_un_0/imu_shake_active_in] [get_bd_pins seven_seg_driver_0/shake_active]
  connect_bd_net -net imu_wrapper_0_tilt_active [get_bd_pins imu_wrapper_0/tilt_active] [get_bd_pins input_integration_un_0/imu_tilt_active_in] [get_bd_pins seven_seg_driver_0/tilt_active]
  connect_bd_net -net input_integration_un_0_imu_shake_active [get_bd_ports imu_shake_active] [get_bd_pins input_integration_un_0/imu_shake_active] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net input_integration_un_0_imu_tilt_active [get_bd_ports imu_tilt_active] [get_bd_pins input_integration_un_0/imu_tilt_active] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net input_integration_un_0_mic_active [get_bd_ports mic_active] [get_bd_pins input_integration_un_0/mic_active] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net input_integration_un_0_red_detected [get_bd_ports red_detected] [get_bd_pins input_integration_un_0/red_detected] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/mb_debug_sys_rst]
  connect_bd_net -net mic_data_0_1 [get_bd_ports mic_data] [get_bd_pins audio_loudness_wrapp_0/mic_data]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins audio_loudness_wrapp_0/sys_clk] [get_bd_pins audio_output_0/CLK100MHZ] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins clk_wiz_1/sys_clk] [get_bd_pins imu_wrapper_0/clk] [get_bd_pins input_integration_un_0/clk] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins pmod_nav_hw_controll_0/s00_axi_aclk] [get_bd_pins rst_clk_wiz_1_100M/slowest_sync_clk] [get_bd_pins seven_seg_driver_0/clk]
  connect_bd_net -net pmod_nav_hw_controll_0_accel_x [get_bd_pins imu_wrapper_0/imu_accel_x] [get_bd_pins pmod_nav_hw_controll_0/accel_x]
  connect_bd_net -net pmod_nav_hw_controll_0_accel_y [get_bd_pins imu_wrapper_0/imu_accel_y] [get_bd_pins pmod_nav_hw_controll_0/accel_y]
  connect_bd_net -net pmod_nav_hw_controll_0_accel_z [get_bd_pins imu_wrapper_0/imu_accel_z] [get_bd_pins pmod_nav_hw_controll_0/accel_z]
  connect_bd_net -net pmod_nav_hw_controll_0_imu_data_valid [get_bd_pins imu_wrapper_0/imu_data_valid] [get_bd_pins pmod_nav_hw_controll_0/imu_data_valid]
  connect_bd_net -net pmod_nav_hw_controll_0_spi_cs_ag [get_bd_ports spi_cs_ag_0] [get_bd_pins pmod_nav_hw_controll_0/spi_cs_ag]
  connect_bd_net -net pmod_nav_hw_controll_0_spi_cs_alt [get_bd_ports spi_cs_alt_0] [get_bd_pins pmod_nav_hw_controll_0/spi_cs_alt]
  connect_bd_net -net pmod_nav_hw_controll_0_spi_cs_mag [get_bd_ports spi_cs_mag_0] [get_bd_pins pmod_nav_hw_controll_0/spi_cs_mag]
  connect_bd_net -net pmod_nav_hw_controll_0_spi_mosi [get_bd_ports spi_mosi_0] [get_bd_pins pmod_nav_hw_controll_0/spi_mosi]
  connect_bd_net -net pmod_nav_hw_controll_0_spi_sclk [get_bd_ports spi_sclk_0] [get_bd_pins pmod_nav_hw_controll_0/spi_sclk]
  connect_bd_net -net red_detect_enable_0_1 [get_bd_ports red_detect_enable] [get_bd_pins camera_wrapper_0/red_detect_enable]
  connect_bd_net -net reset_1 [get_bd_ports resetn] [get_bd_pins clk_wiz_1/resetn] [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in] [get_bd_pins rst_clk_wiz_1_24M/ext_reset_in] [get_bd_pins rst_clk_wiz_1_74M/ext_reset_in]
  connect_bd_net -net rgb2vga_0_vga_pBlue [get_bd_ports vga_blue_0] [get_bd_pins rgb2vga_0/vga_pBlue]
  connect_bd_net -net rgb2vga_0_vga_pGreen [get_bd_ports vga_green_0] [get_bd_pins rgb2vga_0/vga_pGreen]
  connect_bd_net -net rgb2vga_0_vga_pHSync [get_bd_ports vga_hsync_0] [get_bd_pins rgb2vga_0/vga_pHSync]
  connect_bd_net -net rgb2vga_0_vga_pRed [get_bd_ports vga_red_0] [get_bd_pins rgb2vga_0/vga_pRed]
  connect_bd_net -net rgb2vga_0_vga_pVSync [get_bd_ports vga_vsync_0] [get_bd_pins rgb2vga_0/vga_pVSync]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins rst_clk_wiz_1_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins audio_loudness_wrapp_0/rstn] [get_bd_pins audio_output_0/rstn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins imu_wrapper_0/rstn] [get_bd_pins input_integration_un_0/rstn] [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins pmod_nav_hw_controll_0/s00_axi_aresetn] [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn]
  connect_bd_net -net rst_clk_wiz_1_24M_peripheral_aresetn [get_bd_pins camera_wrapper_0/rstn] [get_bd_pins rst_clk_wiz_1_24M/peripheral_aresetn]
  connect_bd_net -net rst_clk_wiz_1_74M_peripheral_aresetn [get_bd_pins rst_clk_wiz_1_74M/peripheral_aresetn] [get_bd_pins video_kirara_stub_80_0/rstn]
  connect_bd_net -net seven_seg_driver_0_an [get_bd_ports an] [get_bd_pins seven_seg_driver_0/an]
  connect_bd_net -net seven_seg_driver_0_dp [get_bd_ports dp] [get_bd_pins seven_seg_driver_0/dp]
  connect_bd_net -net seven_seg_driver_0_seg [get_bd_ports seg] [get_bd_pins seven_seg_driver_0/seg]
  connect_bd_net -net sound_en_slice_0_Dout [get_bd_pins audio_output_0/sound_enable] [get_bd_pins sound_en_slice_0/Dout]
  connect_bd_net -net sound_sel_slice_0_Dout [get_bd_pins audio_output_0/sound_select] [get_bd_pins sound_sel_slice_0/Dout]
  connect_bd_net -net spi_miso_0_1 [get_bd_ports spi_miso_0] [get_bd_pins pmod_nav_hw_controll_0/spi_miso]
  connect_bd_net -net sprite_sel_slice_0_Dout [get_bd_pins sprite_sel_slice_0/Dout] [get_bd_pins video_kirara_stub_80_0/sprite_sel_sys]
  connect_bd_net -net sprite_x_slice_0_Dout [get_bd_pins sprite_x_slice_0/Dout] [get_bd_pins video_kirara_stub_80_0/sprite_x_sys]
  connect_bd_net -net sprite_y_slice_0_Dout [get_bd_pins sprite_y_slice_0/Dout] [get_bd_pins video_kirara_stub_80_0/sprite_y_sys]
  connect_bd_net -net video_kirara_stub_80_0_de [get_bd_pins rgb2vga_0/rgb_pVDE] [get_bd_pins video_kirara_stub_80_0/de]
  connect_bd_net -net video_kirara_stub_80_0_hsync [get_bd_pins rgb2vga_0/rgb_pHSync] [get_bd_pins video_kirara_stub_80_0/hsync]
  connect_bd_net -net video_kirara_stub_80_0_rgb [get_bd_pins rgb2vga_0/rgb_pData] [get_bd_pins video_kirara_stub_80_0/rgb]
  connect_bd_net -net video_kirara_stub_80_0_vsync [get_bd_pins rgb2vga_0/rgb_pVSync] [get_bd_pins video_kirara_stub_80_0/vsync]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins axi_gpio_0/gpio2_io_i] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00002000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00002000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs pmod_nav_hw_controll_0/S00_AXI/S00_AXI_reg] SEG_pmod_nav_hw_controll_0_S00_AXI_reg


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


