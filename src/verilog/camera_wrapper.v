//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2026 12:01:53 PM
// Design Name: 
// Module Name: camera_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module camera_wrapper (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk_25mhz CLK" *)
    input  wire        clk_25mhz, 
    
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rstn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input wire rstn,

    // camera
    output wire cam_sioc,
    inout wire cam_siod,
    output wire cam_reset,
    output wire cam_pwdn,
    output wire cam_xclk,
    input wire cam_pclk,
    input wire cam_vsync,
    input wire cam_href,
    input wire [7:0] cam_d,

    // red quadrant detection
    input wire red_detect_enable,
    output reg [3:0] red_quadrant,
    output wire red_detected
);

    wire [11:0] capture_dout;
    wire capture_we;
    wire config_finished;
    wire [3:0] red_quadrant_raw;  // signal unaffected by enable

    ov7670_controller u_controller (
        .clk(clk_25mhz),
        .resend(~rstn),  // reconfigs if board is reset
        .config_finished(config_finished),
        .sioc(cam_sioc),
        .siod(cam_siod),
        .reset(cam_reset),
        .pwdn(cam_pwdn),
        .xclk(cam_xclk)
    );

    ov7670_capture u_capture (
        .pclk(cam_pclk),
        .vsync(cam_vsync),
        .href(cam_href),
        .d(cam_d),
        .addr(),  // streaming so no bram needed
        .dout(capture_dout),
        .we(capture_we)
    );

    red_q_detect u_red_detect (
        .pclk(cam_pclk),
        .vsync(cam_vsync),
        .pixel_valid(capture_we),
        .pix_rgb444(capture_dout),
        .winner_onehot(red_quadrant_raw)
    );

    wire [3:0] red_quadrant_gated = red_detect_enable ? red_quadrant_raw : 4'b0;

    // latches values, we hold the previous value forever until we receive
    // a new quadrant so that software can read at any time
    reg [3:0] gated_prev;

    always @(posedge cam_pclk) begin
        if (!rstn) begin
            red_quadrant <= 4'b0;
            gated_prev <= 4'b0;
        end else begin
            gated_prev <= red_quadrant_gated;

            // latch on changes
            if (red_quadrant_gated != 4'b0) red_quadrant <= red_quadrant_gated;
        end
    end

    // this uses the unlatched value intentionally to avoid saying perma detection;
    // the latch will clear itself once we get a new quadrant, we save the previous
    // quadrant indefinitely until then so software can read it
    assign red_detected = (red_quadrant_gated != 4'b0) ? 1 : 0;

endmodule
