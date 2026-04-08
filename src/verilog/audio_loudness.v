`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2026 04:38:11 AM
// Design Name: 
// Module Name: audio_loudness
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


module audio_loudness (
    input wire sys_clk,
    input wire mic_read_mic_en,
    input wire mic_data_in,

    input wire rstn,

    output wire is_loud,
    output wire [9:0] high_cnt  // 10 bits to prevent overflow
);

    // records the past 512 inputs, FIFO
    reg [0:511] mic_out_fifo;

    // records the number of highs (10 bits prevents overflow)
    reg [9:0] high_cnt_reg;

    // set threshold
    wire [9:0] threshold = 10'd384;

    // when mic_read_mic_en is high => read in mic_data
    always @(posedge sys_clk) begin
        if (!rstn) begin
            mic_out_fifo <= 512'd0;
            high_cnt_reg <= 10'd0;
        end else if (mic_read_mic_en) begin
            // decrease high count if removing a high from the FIFO
            high_cnt_reg <= high_cnt_reg + (mic_data_in ? 10'd1 : 10'd0) - (mic_out_fifo[0] ? 10'd1 : 10'd0);

            // shift the register in the FIFO using concatenation
            mic_out_fifo <= {mic_out_fifo[1:511], mic_data_in};
        end
    end

    // it is loud when the number highs is greater than the threshold
    assign is_loud = (high_cnt_reg > threshold);
    assign high_cnt = high_cnt_reg;

endmodule
