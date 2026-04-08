`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 09:25:56 AM
// Design Name: 
// Module Name: imu_wrapper
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


module imu_wrapper #(
    parameter signed [15:0] TILT_THRESH = 16'sd8000,
    parameter signed [15:0] SHAKE_THRESH = 16'sd16000
) (
    input wire clk,
    input wire rstn,

    input wire signed [15:0] imu_accel_x,
    input wire signed [15:0] imu_accel_y,
    input wire signed [15:0] imu_accel_z,
    input wire imu_data_valid,

    output reg tilt_active,
    output reg shake_active
);

    function [15:0] abs16;
        input signed [15:0] val;
        abs16 = (val < 0) ? -val : val;
    endfunction

    reg signed [15:0] prev_x, prev_y, prev_z;

    // edge detect data_valid
    reg dv_prev;
    wire new_sample = imu_data_valid && !dv_prev;

    always @(posedge clk) begin
        if (!rstn) dv_prev <= 1'b0;
        else dv_prev <= imu_data_valid;
    end

    // classify new samples
    always @(posedge clk) begin
        if (!rstn) begin
            prev_x <= 16'sd0;
            prev_y <= 16'sd0;
            prev_z <= 16'sd0;
            tilt_active <= 1'b0;
            shake_active <= 1'b0;
        end else if (new_sample) begin
            tilt_active <= (abs16(imu_accel_x) > TILT_THRESH) || (abs16(imu_accel_y) > TILT_THRESH);

            shake_active <= (abs16(
                imu_accel_x - prev_x
            ) > SHAKE_THRESH) || (abs16(
                imu_accel_y - prev_y
            ) > SHAKE_THRESH) || (abs16(
                imu_accel_z - prev_z
            ) > SHAKE_THRESH);

            prev_x <= imu_accel_x;
            prev_y <= imu_accel_y;
            prev_z <= imu_accel_z;
        end
    end

endmodule
