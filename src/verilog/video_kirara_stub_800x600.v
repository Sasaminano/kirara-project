`timescale 1ns / 1ps

// 800x600 but we're actually 1280x720
// changing name breaks this
module video_kirara_stub_800x600 (
    input wire pix_clk,  // MUST be 74.25 MHz
    input wire rstn,

    // sys refers to being synchronized to system clock domain
    input wire [2:0] sprite_sel_sys,
    input wire [9:0] sprite_x_sys,
    input wire [9:0] sprite_y_sys,

    output reg [11:0] rgb,
    output reg hsync,
    output reg vsync,
    output reg de
);


    localparam NUM_SPRITES = 5;
    localparam IMG_W = 240;
    localparam IMG_H = 240;
    localparam IMG_PIXELS = IMG_W * IMG_H;  // 57600

    localparam SPR_PAL_DEPTH = 32;
    localparam SPR_IDX_WIDTH = 5;

    localparam BG_PAL_DEPTH = 64;
    localparam BG_IDX_WIDTH = 6;

    // 1280x720 @ 60 Hz timing
    localparam H_ACTIVE = 1280, H_FP = 110, H_SYNC = 40, H_BP = 220;
    localparam V_ACTIVE = 720, V_FP = 5, V_SYNC = 5, V_BP = 20;
    localparam H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;  // 1650
    localparam V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;  // 750

    reg [2:0] sprite_sel_meta, sprite_sel_pix;
    reg [9:0] sprite_x_meta, sprite_x_pix;
    reg [9:0] sprite_y_meta, sprite_y_pix;

    always @(posedge pix_clk) begin
        if (!rstn) begin
            sprite_sel_meta <= 3'd0;
            sprite_sel_pix <= 3'd0;
            sprite_x_meta <= 10'd520;
            sprite_x_pix <= 10'd520;
            sprite_y_meta <= 10'd240;
            sprite_y_pix <= 10'd240;
        end else begin
            sprite_sel_meta <= sprite_sel_sys;
            sprite_sel_pix <= sprite_sel_meta;
            sprite_x_meta <= sprite_x_sys;
            sprite_x_pix <= sprite_x_meta;
            sprite_y_meta <= sprite_y_sys;
            sprite_y_pix <= sprite_y_meta;
        end
    end


    reg [10:0] hcnt = 0;
    reg [9:0] vcnt = 0;

    wire h_active = (hcnt < H_ACTIVE);
    wire v_active = (vcnt < V_ACTIVE);

    wire hsync_i = (hcnt >= H_ACTIVE + H_FP) && (hcnt < H_ACTIVE + H_FP + H_SYNC);
    wire vsync_i = (vcnt >= V_ACTIVE + V_FP) && (vcnt < V_ACTIVE + V_FP + V_SYNC);

    // check if in sprite
    wire in_img = h_active && v_active &&
                  (hcnt >= sprite_x_pix) && (hcnt < sprite_x_pix + IMG_W) &&
                  (vcnt >= sprite_y_pix) && (vcnt < sprite_y_pix + IMG_H);

    wire [7:0] img_x = hcnt - sprite_x_pix;
    wire [7:0] img_y = vcnt - sprite_y_pix;

    // sprite rom address is y*240 = y*256 - y*16 = (y<<8) - (y<<4)
    wire [15:0] sprite_addr = in_img ? ((img_y << 8) - (img_y << 4) + img_x) : 16'd0;

    // background upscale from 360p to 720p
    wire [9:0] bg_x = hcnt[10:1];  // 0 to 639
    wire [8:0] bg_y = vcnt[9:1];  // 0 to 359

    // address is bg_y * 640 + bg_x
    // 640 = 512 + 128 so (bg_y << 9) + (bg_y << 7)
    wire [17:0] bkgrd_addr = (h_active && v_active) ? ((bg_y << 9) + (bg_y << 7) + bg_x) : 18'd0;

    // --------------- palette roms -------------------

    // sprite 5bit idx to rgb444
    reg [11:0] sprite_palette[0:SPR_PAL_DEPTH-1];
    initial begin
        $readmemh("kirara_palette_5bit.mem", sprite_palette);
    end

    // bg 6bit idx to rgb444 
    reg [11:0] bg_palette[0:BG_PAL_DEPTH-1];
    initial begin
        $readmemh("kirara_bg_palette_6bit.mem", bg_palette);
    end


    wire [BG_IDX_WIDTH-1:0] bkgrd_idx;
    background_rom #(
        .MEM_FILE("kirara_background_640x360_idx6_bayer4x4.mem"),
        .DEPTH(230400),
        .WIDTH(BG_IDX_WIDTH)
    ) u_bg_rom (
        .clk(pix_clk),
        .addr(bkgrd_addr),
        .dout(bkgrd_idx)
    );

    wire [SPR_IDX_WIDTH-1:0] rom_dout[0:NUM_SPRITES-1];

    sprite_rom #(
        .MEM_FILE("kirara_sleep_240x240_idx5.mem"),
        .DEPTH(IMG_PIXELS),
        .WIDTH(SPR_IDX_WIDTH)
    ) u_rom_0 (
        .clk(pix_clk),
        .addr(sprite_addr),
        .dout(rom_dout[0])
    );

    sprite_rom #(
        .MEM_FILE("kirara_standing_240x240_idx5.mem"),
        .DEPTH(IMG_PIXELS),
        .WIDTH(SPR_IDX_WIDTH)
    ) u_rom_1 (
        .clk(pix_clk),
        .addr(sprite_addr),
        .dout(rom_dout[1])
    );

    sprite_rom #(
        .MEM_FILE("kirara_run_240x240_idx5.mem"),
        .DEPTH(IMG_PIXELS),
        .WIDTH(SPR_IDX_WIDTH)
    ) u_rom_2 (
        .clk(pix_clk),
        .addr(sprite_addr),
        .dout(rom_dout[2])
    );

    sprite_rom #(
        .MEM_FILE("kirara_shake_left_240x240_idx5.mem"),
        .DEPTH(IMG_PIXELS),
        .WIDTH(SPR_IDX_WIDTH)
    ) u_rom_3 (
        .clk(pix_clk),
        .addr(sprite_addr),
        .dout(rom_dout[3])
    );

    sprite_rom #(
        .MEM_FILE("kirara_shake_right_240x240_idx5.mem"),
        .DEPTH(IMG_PIXELS),
        .WIDTH(SPR_IDX_WIDTH)
    ) u_rom_4 (
        .clk(pix_clk),
        .addr(sprite_addr),
        .dout(rom_dout[4])
    );


    // delay by 1 cycle to account for rom delay
    reg in_img_d;
    reg [2:0] sprite_sel_d;


    reg h_active_d, v_active_d;
    reg hsync_i_d, vsync_i_d;

    always @(posedge pix_clk) begin
        if (!rstn) begin
            in_img_d <= 1'b0;
            sprite_sel_d <= 3'd0;
            h_active_d <= 1'b0;
            v_active_d <= 1'b0;
            hsync_i_d <= 1'b0;
            vsync_i_d <= 1'b0;
        end else begin
            in_img_d <= in_img;
            sprite_sel_d <= sprite_sel_pix;
            h_active_d <= h_active;
            v_active_d <= v_active;
            hsync_i_d <= hsync_i;
            vsync_i_d <= vsync_i;
        end
    end

    // decode rgb from idx
    reg [SPR_IDX_WIDTH-1:0] spr_idx;
    reg [11:0] spr_rgb;
    reg [11:0] bg_rgb;

    always @(*) begin
        if (sprite_sel_d < NUM_SPRITES) spr_idx = rom_dout[sprite_sel_d];
        else spr_idx = {SPR_IDX_WIDTH{1'b0}};

        spr_rgb = sprite_palette[spr_idx];
        bg_rgb = bg_palette[bkgrd_idx];
    end

    // display image
    always @(posedge pix_clk) begin
        if (!rstn) begin
            hcnt <= 11'd0;
            vcnt <= 10'd0;
            rgb <= 12'h000;
            hsync <= 1'b0;
            vsync <= 1'b0;
            de <= 1'b0;
        end else begin
            // h/v counters
            if (hcnt == H_TOTAL - 1) begin
                hcnt <= 11'd0;
                vcnt <= (vcnt == V_TOTAL - 1) ? 10'd0 : vcnt + 10'd1;
            end else begin
                hcnt <= hcnt + 11'd1;
            end

            de <= h_active_d && v_active_d;
            hsync <= hsync_i_d;
            vsync <= vsync_i_d;

            // flip rgb to rbg since rgb2vga is backwards
            if (h_active_d && v_active_d) begin
                if (in_img_d && spr_idx != {SPR_IDX_WIDTH{1'b0}}) begin
                    rgb <= {spr_rgb[11:8], spr_rgb[3:0], spr_rgb[7:4]};
                end else begin
                    rgb <= {bg_rgb[11:8], bg_rgb[3:0], bg_rgb[7:4]};
                end
            end else begin
                rgb <= 12'h000;
            end
        end
    end

endmodule


module sprite_rom #(
    parameter MEM_FILE = "kirara_sleep_240x240_idx5.mem",
    parameter DEPTH = 57600,
    parameter WIDTH = 5
) (
    input wire clk,
    input wire [15:0] addr,
    output reg [WIDTH-1:0] dout
);
    (* ram_style="block" *) reg [WIDTH-1:0] mem[0:DEPTH-1];

    initial begin
        $readmemh(MEM_FILE, mem);
    end

    always @(posedge clk) begin
        dout <= mem[addr];
    end
endmodule

module background_rom #(
    parameter MEM_FILE = "background_640x360_rgb444.mem",
    parameter DEPTH = 230400,  // 640x360
    parameter WIDTH = 6
) (
    input wire clk,
    input wire [17:0] addr,
    output reg [WIDTH-1:0] dout
);
    (* ram_style="block" *) reg [WIDTH-1:0] mem[0:DEPTH-1];

    initial begin
        $readmemh(MEM_FILE, mem);
    end

    always @(posedge clk) begin
        dout <= mem[addr];
    end
endmodule
