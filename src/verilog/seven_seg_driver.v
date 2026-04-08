`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2026 01:11:31 AM
// Design Name: 
// Module Name: seven_seg_driver
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


module seven_seg_driver (
    input clk,
    input [9:0] mic_buffer,
    input mic_active,
    input red_detected,
    input [3:0] quadrant_detected,
    input shake_active,
    input tilt_active,

    output reg [6:0] seg,
    output reg [7:0] an,
    output wire dp
);
    // clock devider and segment selecter
    reg [19:0] clkdiv;
    wire [2:0] s;
    // digit mapper
    reg [3:0] digit;

    // draw enable
    wire [7:0] aen;

    assign dp = 1;
    assign s = clkdiv[19:17];
    assign aen = 8'b11111111;

    always @(posedge clk)
        case (s)
            0: digit = mic_buffer[3:0];
            1: digit = mic_buffer[7:4];
            2: digit = mic_buffer[9:8];
            3: digit = mic_active;
            4: digit = red_detected;
            5: digit = quadrant_detected;
            6: digit = shake_active;
            7: digit = tilt_active;
            default: digit = 0;
        endcase

    always @(*)
        case (digit)
            0: seg = 7'b1000000;
            1: seg = 7'b1111001;
            2: seg = 7'b0100100;
            3: seg = 7'b0110000;
            4: seg = 7'b0011001;
            5: seg = 7'b0010010;
            6: seg = 7'b0000010;
            7: seg = 7'b1111000;
            8: seg = 7'b0000000;
            9: seg = 7'b0010000;
            'hA: seg = 7'b0001000;
            'hB: seg = 7'b0000011;
            'hC: seg = 7'b1000110;
            'hD: seg = 7'b0100001;
            'hE: seg = 7'b0000110;
            'hF: seg = 7'b0001110;
            default: seg = 7'b0000000;
        endcase

    always @(*) begin
        an = 8'b11111111;
        if (aen[s] == 1) begin
            an[s] = 0;
        end
    end

    always @(posedge clk) begin
        clkdiv <= clkdiv + 1;
    end

endmodule
