//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
//Date        : Mon Mar 30 06:51:34 2026
//Host        : user running 64-bit Ubuntu 24.04.3 LTS
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (an,
    aud_pwm,
    aud_sd,
    cam_d,
    cam_href,
    cam_pclk,
    cam_pwdn,
    cam_reset,
    cam_sioc,
    cam_siod,
    cam_vsync,
    cam_xclk,
    dp,
    imu_shake_active,
    imu_tilt_active,
    led_high,
    mic_active,
    mic_clk,
    mic_data,
    mic_lrsel,
    red_detect_enable,
    red_detected,
    resetn,
    seg,
    spi_cs_ag_0,
    spi_cs_alt_0,
    spi_cs_mag_0,
    spi_miso_0,
    spi_mosi_0,
    spi_sclk_0,
    sys_clk,
    usb_uart_rxd,
    usb_uart_txd,
    vga_blue_0,
    vga_green_0,
    vga_hsync_0,
    vga_red_0,
    vga_vsync_0);
  output [7:0]an;
  output aud_pwm;
  output aud_sd;
  input [7:0]cam_d;
  input cam_href;
  input cam_pclk;
  output cam_pwdn;
  output cam_reset;
  output cam_sioc;
  inout cam_siod;
  input cam_vsync;
  output cam_xclk;
  output dp;
  output imu_shake_active;
  output imu_tilt_active;
  output [9:0]led_high;
  output mic_active;
  output mic_clk;
  input mic_data;
  output mic_lrsel;
  input red_detect_enable;
  output red_detected;
  input resetn;
  output [6:0]seg;
  output spi_cs_ag_0;
  output spi_cs_alt_0;
  output spi_cs_mag_0;
  input spi_miso_0;
  output spi_mosi_0;
  output spi_sclk_0;
  input sys_clk;
  input usb_uart_rxd;
  output usb_uart_txd;
  output [3:0]vga_blue_0;
  output [3:0]vga_green_0;
  output vga_hsync_0;
  output [3:0]vga_red_0;
  output vga_vsync_0;

  wire [7:0]an;
  wire aud_pwm;
  wire aud_sd;
  wire [7:0]cam_d;
  wire cam_href;
  wire cam_pclk;
  wire cam_pwdn;
  wire cam_reset;
  wire cam_sioc;
  wire cam_siod;
  wire cam_vsync;
  wire cam_xclk;
  wire dp;
  wire imu_shake_active;
  wire imu_tilt_active;
  wire [9:0]led_high;
  wire mic_active;
  wire mic_clk;
  wire mic_data;
  wire mic_lrsel;
  wire red_detect_enable;
  wire red_detected;
  wire resetn;
  wire [6:0]seg;
  wire spi_cs_ag_0;
  wire spi_cs_alt_0;
  wire spi_cs_mag_0;
  wire spi_miso_0;
  wire spi_mosi_0;
  wire spi_sclk_0;
  wire sys_clk;
  wire usb_uart_rxd;
  wire usb_uart_txd;
  wire [3:0]vga_blue_0;
  wire [3:0]vga_green_0;
  wire vga_hsync_0;
  wire [3:0]vga_red_0;
  wire vga_vsync_0;

  system system_i
       (.an(an),
        .aud_pwm(aud_pwm),
        .aud_sd(aud_sd),
        .cam_d(cam_d),
        .cam_href(cam_href),
        .cam_pclk(cam_pclk),
        .cam_pwdn(cam_pwdn),
        .cam_reset(cam_reset),
        .cam_sioc(cam_sioc),
        .cam_siod(cam_siod),
        .cam_vsync(cam_vsync),
        .cam_xclk(cam_xclk),
        .dp(dp),
        .imu_shake_active(imu_shake_active),
        .imu_tilt_active(imu_tilt_active),
        .led_high(led_high),
        .mic_active(mic_active),
        .mic_clk(mic_clk),
        .mic_data(mic_data),
        .mic_lrsel(mic_lrsel),
        .red_detect_enable(red_detect_enable),
        .red_detected(red_detected),
        .resetn(resetn),
        .seg(seg),
        .spi_cs_ag_0(spi_cs_ag_0),
        .spi_cs_alt_0(spi_cs_alt_0),
        .spi_cs_mag_0(spi_cs_mag_0),
        .spi_miso_0(spi_miso_0),
        .spi_mosi_0(spi_mosi_0),
        .spi_sclk_0(spi_sclk_0),
        .sys_clk(sys_clk),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd),
        .vga_blue_0(vga_blue_0),
        .vga_green_0(vga_green_0),
        .vga_hsync_0(vga_hsync_0),
        .vga_red_0(vga_red_0),
        .vga_vsync_0(vga_vsync_0));
endmodule
