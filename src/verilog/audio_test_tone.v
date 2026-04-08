`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02/01/2026 05:54:45 PM
// Design Name:
// Module Name: audio_output
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


module audio_output (
    input wire CLK100MHZ,
    input wire rstn,
    input wire [2:0] sound_select,
    input wire sound_enable,
    output AUD_PWM,
    output AUD_SD
);

    assign AUD_SD = 1'b1;

    //edge detect sound enable
    reg sound_enable_d;
    always @(posedge CLK100MHZ) begin
        if (!rstn) begin
            sound_enable_d <= 1'b0;
        end else begin
            sound_enable_d <= sound_enable;
        end
    end
    wire play_pulse = sound_enable && !sound_enable_d;

    // rom
    reg [15:0] sample_addr;
    wire [7:0] dout_0, dout_1, dout_2, dout_3;

    kirara_sound_rom #(
        .MEM_FILE("kirara_wake_2816.mem"),
        .MEM_SAMPLES(2816)
    ) rom_0 (
        .clk(CLK100MHZ),
        .addr(sample_addr),
        .dout(dout_0)
    );

    kirara_sound_rom #(
        .MEM_FILE("kirara_sprint_2357.mem"),
        .MEM_SAMPLES(2357)
    ) rom_1 (
        .clk(CLK100MHZ),
        .addr(sample_addr),
        .dout(dout_1)
    );

    kirara_sound_rom #(
        .MEM_FILE("kirara_slide_4757.mem"),
        .MEM_SAMPLES(4757)
    ) rom_2 (
        .clk(CLK100MHZ),
        .addr(sample_addr),
        .dout(dout_2)
    );

    kirara_sound_rom #(
        .MEM_FILE("kirara_shake_2912.mem"),
        .MEM_SAMPLES(2912)
    ) rom_3 (
        .clk(CLK100MHZ),
        .addr(sample_addr),
        .dout(dout_3)
    );

    // rom length
    reg [2:0] active_sound;

    reg [15:0] max_addr;
    always @(*) begin
        case (active_sound)
            3'd0: max_addr = 17'd2816;
            3'd1: max_addr = 17'd2357;
            3'd2: max_addr = 17'd4757;
            3'd3: max_addr = 17'd2912;
            default: max_addr = 17'd4892;
        endcase
    end

    reg [7:0] active_dout;
    always @(*) begin
        case (active_sound)
            3'd0: active_dout = dout_0;
            3'd1: active_dout = dout_1;
            3'd2: active_dout = dout_2;
            3'd3: active_dout = dout_3;
            default: active_dout = dout_0;
        endcase
    end

    // playback
    reg [17:0] tone_cnt;
    reg [7:0] audio_sample;
    reg play_audio;

    always @(posedge CLK100MHZ) begin
        if (!rstn) begin
            play_audio <= 1'b0;
            sample_addr <= 17'd0;
            tone_cnt <= 18'd0;
            active_sound <= 3'd0;
            audio_sample <= 8'd0;
        end else begin
            // start new playback
            if (play_pulse) begin
                play_audio <= 1'b1;
                sample_addr <= 17'd0;
                tone_cnt <= 18'd0;
                active_sound <= sound_select;
            end  // ongoing playback
      else if (play_audio) begin
                if (tone_cnt >= 18'd12499) begin  // 100MHz / 8000Hz - 1
                    tone_cnt <= 18'd0;

                    if (sample_addr >= max_addr - 1) begin
                        play_audio <= 1'b0;
                        sample_addr <= 17'd0;
                    end else begin
                        sample_addr <= sample_addr + 17'd1;
                    end

                    audio_sample <= active_dout;
                end else begin
                    tone_cnt <= tone_cnt + 18'd1;
                end
            end
        end
    end

    // pwm
    reg [7:0] pwm_cnt;
    always @(posedge CLK100MHZ) begin
        if (!rstn) begin
            pwm_cnt <= 8'd0;
        end else begin
            pwm_cnt <= pwm_cnt + 8'd1;
        end
    end

    assign AUD_PWM = play_audio ? (audio_sample > pwm_cnt) : 1'b0;

endmodule

module kirara_sound_rom #(
    parameter MEM_FILE = "kirara_yoink.mem",
    parameter MEM_SAMPLES = 4892
) (
    input wire clk,
    input wire [15:0] addr,  // 16 bits so max 64k samples
    output wire [7:0] dout
);
    // https://docs.amd.com/r/en-US/ug901-vivado-synthesis/ROM-Using-Block-RAM-Resources-Verilo
    (* rom_style="block" *) reg [7:0] bram[0:MEM_SAMPLES-1];
    reg [7:0] data = 0;

    initial begin
        $readmemh(MEM_FILE, bram);
    end

    always @(posedge clk) begin
        if (addr < MEM_SAMPLES) begin
            data <= bram[addr];
        end else begin
            // output 0 if address goes out of bounds
            data <= 8'd0;
        end
    end

    assign dout = data;
endmodule
