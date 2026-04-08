//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2026 09:11:34 PM
// Design Name: 
// Module Name: input_integration_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:
//   - Synchronize into clk domain
//   - Stretch signal so that it can be detected via software polling
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module input_integration_unit #(
    parameter N_CHANNELS = 4,
    parameter STRETCH_CYCLES = 20_000_000  // 200ms; needs to be higher than software poll interval
) (
    input wire clk,
    input wire rstn,

    input wire mic_active_in,
    input wire red_detected_in,
    input wire imu_tilt_active_in,
    input wire imu_shake_active_in,

    output wire mic_active,
    output wire red_detected,
    output wire imu_tilt_active,
    output wire imu_shake_active
);

    localparam CW = $clog2(STRETCH_CYCLES);

    wire [3:0] event_in = {mic_active_in, red_detected_in, imu_tilt_active_in, imu_shake_active_in};

    // clock domain crossing
    reg [3:0] meta, sync;

    always @(posedge clk) begin
        if (!rstn) begin
            meta <= 4'b0;
            sync <= 4'b0;
        end else begin
            meta <= event_in;
            sync <= meta;
        end
    end


    // pulse stretching
    reg [CW-1:0] cnt0, cnt1, cnt2, cnt3;

    always @(posedge clk) begin
        if (!rstn) begin
            cnt0 <= {CW{1'b0}};
            cnt1 <= {CW{1'b0}};
            cnt2 <= {CW{1'b0}};
            cnt3 <= {CW{1'b0}};
        end else begin
            cnt0 <= sync[0] ? STRETCH_CYCLES[CW-1:0] - 1 : (cnt0 != 0 ? cnt0 - 1 : 0);
            cnt1 <= sync[1] ? STRETCH_CYCLES[CW-1:0] - 1 : (cnt1 != 0 ? cnt1 - 1 : 0);
            cnt2 <= sync[2] ? STRETCH_CYCLES[CW-1:0] - 1 : (cnt2 != 0 ? cnt2 - 1 : 0);
            cnt3 <= sync[3] ? STRETCH_CYCLES[CW-1:0] - 1 : (cnt3 != 0 ? cnt3 - 1 : 0);
        end
    end

    // reverse order due to bit order
    assign mic_active = (cnt3 != 0);
    assign red_detected = (cnt2 != 0);
    assign imu_tilt_active = (cnt1 != 0);
    assign imu_shake_active = (cnt0 != 0);
endmodule
