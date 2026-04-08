`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2026 04:56:09 AM
// Design Name: 
// Module Name: audio_loudness_wrapper
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


module audio_loudness_wrapper (
    input wire sys_clk,
    input wire rstn,
    input wire mic_data,

    // disable missing freq_hz warning
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 3125000" *)
    output wire mic_clk,
    output wire mic_active,
    output wire mic_lrsel,

    output wire [9:0] led_high
);

    assign mic_lrsel = 1'b0;

    // 5 bit counter for the clock divider
    reg [4:0] clk_div;

    //  -------------- two-stage buffer for mic data --------------
    reg [1:0] mic_sync;
    always @(posedge sys_clk) begin
        if (!rstn) mic_sync <= 2'b00;
        else mic_sync <= {mic_sync[0], mic_data};
    end

    // ------------------- enable signal for when to read mic -------------
    wire mic_read_mic_en = (clk_div == 5'b01111);

    audio_loudness u_audio_loudness (
        .sys_clk(sys_clk),
        .mic_read_mic_en(mic_read_mic_en),
        .mic_data_in(mic_sync[1]),
        .rstn(rstn),
        .is_loud(mic_active),
        .high_cnt(led_high)
    );


    // ----------------- clock divider for mic_clk -------------------
    // cannot use clocking wizard due to clk_wizard limits; so clock divider
    // clock reads every 2^5 = 32 cycles, polling rate = 100/32 = 3.125 MHz
    assign mic_clk = clk_div[4];

    always @(posedge sys_clk) begin
        if (!rstn) begin
            clk_div <= 5'b00000;
        end else begin
            // increment the counter by 1
            clk_div <= clk_div + 5'd1;
        end
    end

endmodule
