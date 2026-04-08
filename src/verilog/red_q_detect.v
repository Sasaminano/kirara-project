`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2026 11:42:51 AM
// Design Name: 
// Module Name: red_q_detect
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


module red_q_detect #(
    parameter integer W = 640,
    parameter integer H = 480,
    parameter integer R_TH = 12,
    parameter integer MARGIN = 3,
    parameter integer RED_TH = 150
) (
    input wire pclk,
    input wire vsync,
    input wire pixel_valid,
    input wire [11:0] pix_rgb444,

    output reg [3:0] winner_onehot = 4'b0000  // [0]=TL [1]=TR [2]=BL [3]=BR
);

    localparam integer HALF_W = W / 2;
    localparam integer HALF_H = H / 2;
    localparam integer XW = $clog2(W);
    localparam integer YW = $clog2(H);

    reg [XW-1:0] x = 0;
    reg [YW-1:0] y = 0;

    reg vsync_d = 1'b0;
    wire vsync_rise = vsync & ~vsync_d;

    wire [3:0] r = pix_rgb444[11:8];
    wire [3:0] g = pix_rgb444[7:4];
    wire [3:0] b = pix_rgb444[3:0];
    wire is_red = (r >= R_TH) && (r >= (g + MARGIN)) && (r >= (b + MARGIN));

    reg [31:0] cnt_tl = 0, cnt_tr = 0, cnt_bl = 0, cnt_br = 0;

    wire top = (y < HALF_H);
    wire left = (x < HALF_W);

    // combinational: pick winner (tie-break priority TL > TR > BL > BR)
    reg [31:0] max_cnt;
    reg [1:0] max_idx;  // 0 TL, 1 TR, 2 BL, 3 BR
    always @* begin
        max_cnt = cnt_tl;
        max_idx = 2'd0;
        if (cnt_tr > max_cnt) begin
            max_cnt = cnt_tr;
            max_idx = 2'd1;
        end
        if (cnt_bl > max_cnt) begin
            max_cnt = cnt_bl;
            max_idx = 2'd2;
        end
        if (cnt_br > max_cnt) begin
            max_cnt = cnt_br;
            max_idx = 2'd3;
        end
    end

    always @(posedge pclk) begin
        vsync_d <= vsync;

        if (vsync_rise) begin
            // decide output based on previous frame counts
            if (max_cnt > RED_TH) begin
                case (max_idx)
                    2'd0: winner_onehot <= 4'b0001;  // TL
                    2'd1: winner_onehot <= 4'b0010;  // TR
                    2'd2: winner_onehot <= 4'b0100;  // BL
                    2'd3: winner_onehot <= 4'b1000;  // BR
                endcase
            end else begin
                winner_onehot <= 4'b0000;
            end

            // clear for next frame
            cnt_tl <= 0;
            cnt_tr <= 0;
            cnt_bl <= 0;
            cnt_br <= 0;
            x <= 0;
            y <= 0;

        end else if (pixel_valid) begin
            if (is_red) begin
                if (top && left) cnt_tl <= cnt_tl + 1;
                else if (top && !left) cnt_tr <= cnt_tr + 1;
                else if (!top && left) cnt_bl <= cnt_bl + 1;
                else cnt_br <= cnt_br + 1;
            end

            // advance x/y
            if (x == W - 1) begin
                x <= 0;
                if (y != H - 1) y <= y + 1;
            end else begin
                x <= x + 1;
            end
        end
    end
endmodule
