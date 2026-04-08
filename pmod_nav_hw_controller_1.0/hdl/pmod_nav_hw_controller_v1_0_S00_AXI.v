`timescale 1 ns / 1 ps

    module pmod_nav_hw_controller_v1_0_S00_AXI #
    (
        parameter integer C_S_AXI_DATA_WIDTH    = 32,
        parameter integer C_S_AXI_ADDR_WIDTH    = 5
    )
    (
        // Users to add ports here
        output wire spi_cs_ag,
        output wire spi_cs_mag,
        output wire spi_cs_alt,
        output wire spi_sclk,
        output wire spi_mosi,
        input  wire spi_miso,
        output wire [15:0] accel_x,
        output wire [15:0] accel_y,
        output wire [15:0] accel_z,
        output wire imu_data_valid,
        
        // User ports ends

        input wire  S_AXI_ACLK,
        input wire  S_AXI_ARESETN,
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
        input wire [2 : 0] S_AXI_AWPROT,
        input wire  S_AXI_AWVALID,
        output wire  S_AXI_AWREADY,
        input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
        input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
        input wire  S_AXI_WVALID,
        output wire  S_AXI_WREADY,
        output wire [1 : 0] S_AXI_BRESP,
        output wire  S_AXI_BVALID,
        input wire  S_AXI_BREADY,
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
        input wire [2 : 0] S_AXI_ARPROT,
        input wire  S_AXI_ARVALID,
        output wire  S_AXI_ARREADY,
        output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
        output wire [1 : 0] S_AXI_RRESP,
        output wire  S_AXI_RVALID,
        input wire  S_AXI_RREADY
    );

    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr;
    reg      axi_awready;
    reg      axi_wready;
    reg [1 : 0]     axi_bresp;
    reg      axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_araddr;
    reg      axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0]  axi_rdata;
    reg [1 : 0]     axi_rresp;
    reg      axi_rvalid;

    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 2;

    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg0;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg1;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg2;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg3;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg4;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg5;
    wire     slv_reg_rden;
    wire     slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0]     reg_data_out;
    integer     byte_index;
    reg     aw_en;

    assign S_AXI_AWREADY    = axi_awready;
    assign S_AXI_WREADY    = axi_wready;
    assign S_AXI_BRESP    = axi_bresp;
    assign S_AXI_BVALID    = axi_bvalid;
    assign S_AXI_ARREADY    = axi_arready;
    assign S_AXI_RDATA    = axi_rdata;
    assign S_AXI_RRESP    = axi_rresp;
    assign S_AXI_RVALID    = axi_rvalid;

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awready <= 1'b0;
          aw_en <= 1'b1;
        end 
      else
        begin    
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
              axi_awready <= 1'b1;
              aw_en <= 1'b0;
            end
            else if (S_AXI_BREADY && axi_bvalid)
                begin
                  aw_en <= 1'b1;
                  axi_awready <= 1'b0;
                end
          else           
            begin
              axi_awready <= 1'b0;
            end
        end 
    end       

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awaddr <= 0;
        end 
      else
        begin    
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
              axi_awaddr <= S_AXI_AWADDR;
            end
        end 
    end       

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_wready <= 1'b0;
        end 
      else
        begin    
          if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
            begin
              axi_wready <= 1'b1;
            end
          else
            begin
              axi_wready <= 1'b0;
            end
        end 
    end       

    // register write
    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          slv_reg0 <= 0;
          slv_reg1 <= 0;
          slv_reg2 <= 0;
          slv_reg3 <= 0;
          slv_reg4 <= 0;
          slv_reg5 <= 0;
        end 
      else begin
        if (slv_reg_wren)
          begin
            case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
              3'h0:
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end  
              3'h1:
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end  
              3'h2:
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end  
              3'h3:
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end  
              3'h4:
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end  
              3'h5:
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end  
              default : begin
                          slv_reg0 <= slv_reg0;
                          slv_reg1 <= slv_reg1;
                          slv_reg2 <= slv_reg2;
                          slv_reg3 <= slv_reg3;
                          slv_reg4 <= slv_reg4;
                          slv_reg5 <= slv_reg5;
                        end
            endcase
          end
      end
    end    

    // write response
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_bvalid  <= 0;
          axi_bresp   <= 2'b0;
        end 
      else
        begin    
          if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
            begin
              axi_bvalid <= 1'b1;
              axi_bresp  <= 2'b0; 
            end                   
          else
            begin
              if (S_AXI_BREADY && axi_bvalid) 
                begin
                  axi_bvalid <= 1'b0; 
                end  
            end
        end
    end   

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_arready <= 1'b0;
          axi_araddr  <= 32'b0;
        end 
      else
        begin    
          if (~axi_arready && S_AXI_ARVALID)
            begin
              axi_arready <= 1'b1;
              axi_araddr  <= S_AXI_ARADDR;
            end
          else
            begin
              axi_arready <= 1'b0;
            end
        end 
    end       

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rvalid <= 0;
          axi_rresp  <= 0;
        end 
      else
        begin    
          if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
            begin
              axi_rvalid <= 1'b1;
              axi_rresp  <= 2'b0;
            end   
          else if (axi_rvalid && S_AXI_RREADY)
            begin
              axi_rvalid <= 1'b0;
            end                
        end
    end    

    // read registers
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    
    always @(*)
    begin
          case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            3'h0   : reg_data_out <= {{16{accel_x[15]}}, accel_x};
            3'h1   : reg_data_out <= {{16{accel_y[15]}}, accel_y};
            3'h2   : reg_data_out <= {{16{accel_z[15]}}, accel_z};
            3'h3   : reg_data_out <= slv_reg3;
            3'h4   : reg_data_out <= slv_reg4;
            3'h5   : reg_data_out <= slv_reg5;
            default : reg_data_out <= 0;
          endcase
    end

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rdata  <= 0;
        end 
      else
        begin    
          if (slv_reg_rden)
            begin
              axi_rdata <= reg_data_out;
            end   
        end
    end    

    
    // spi clock divider
    reg [6:0] clk_div_reg = 0;
    wire spi_clk_en = (clk_div_reg == 7'd49); 

    always @(posedge S_AXI_ACLK) begin
        if (~S_AXI_ARESETN) clk_div_reg <= 0;
        else if (spi_clk_en) clk_div_reg <= 0;
        else clk_div_reg <= clk_div_reg + 1;
    end

    // spi state machine
    localparam IDLE = 0, INIT_START = 1, INIT_SHIFT = 2, READ_START = 3, READ_SHIFT = 4, STOP = 5, WAIT_STATE = 6;
    reg [2:0] state = IDLE;
    reg [5:0] bit_cnt = 0;
    reg [55:0] shift_out = 0;
    reg [47:0] shift_in = 0;
    
    reg [15:0] delay_cnt = 0;
    reg init_done = 0;

    // clean output registers
    reg [15:0] accel_x_reg = 0;
    reg [15:0] accel_y_reg = 0;
    reg [15:0] accel_z_reg = 0;
    reg        data_valid_reg = 0;
    
    assign accel_x = accel_x_reg;
    assign accel_y = accel_y_reg;
    assign accel_z = accel_z_reg;
    assign imu_data_valid = data_valid_reg;

    reg cs_reg = 1;
    reg sclk_reg = 0;
    reg mosi_reg = 0;

    assign spi_cs_ag  = cs_reg;
    assign spi_cs_mag = 1'b1;
    assign spi_cs_alt = 1'b1;
    assign spi_sclk   = sclk_reg;
    assign spi_mosi   = mosi_reg;

    always @(posedge S_AXI_ACLK) begin
        if (~S_AXI_ARESETN) begin
            state <= IDLE;
            cs_reg <= 1;
            sclk_reg <= 0;
            init_done <= 0;
            accel_x_reg <= 0;
            accel_y_reg <= 0;
            accel_z_reg <= 0;
        end else if (spi_clk_en) begin
            case (state)
                IDLE: begin
                    cs_reg <= 1;
                    sclk_reg <= 0;
                    if (init_done == 0) begin
                        // spi write CTRL_REG6_XL 0x20 = 0x60 119Hz
                        shift_out <= {8'h20, 8'h60, 40'h0}; 
                        state <= INIT_START;
                    end else begin
                        // burst read 0x80 | 0x28 OUT_X_L_XL = 0xA8
                        shift_out <= {8'hA8, 48'h0};
                        state <= READ_START;
                    end
                end
                
                INIT_START: begin
                    cs_reg <= 0; 
                    mosi_reg <= shift_out[55]; 
                    shift_out <= {shift_out[54:0], 1'b0};
                    bit_cnt <= 17; 
                    state <= INIT_SHIFT;
                end
                
                INIT_SHIFT: begin
                    if (sclk_reg == 0) begin
                        sclk_reg <= 1; 
                    end else begin
                        sclk_reg <= 0; 
                        bit_cnt <= bit_cnt - 1;
                        
                        if (bit_cnt == 1) begin
                            // 16 rising edges have occurred
                            delay_cnt <= 16'd20000; 
                            state <= WAIT_STATE;
                            init_done <= 1; 
                        end else begin
                            mosi_reg <= shift_out[55];
                            shift_out <= {shift_out[54:0], 1'b0};
                        end
                    end
                end
                
                // read 56 bits 8 cmd + 48 data
                READ_START: begin
                    cs_reg <= 0; 
                    mosi_reg <= shift_out[55];
                    shift_out <= {shift_out[54:0], 1'b0};
                    bit_cnt <= 57;
                    state <= READ_SHIFT;
                end
                
                READ_SHIFT: begin
                    if (sclk_reg == 0) begin
                        sclk_reg <= 1; 
                        if (bit_cnt <= 49) shift_in <= {shift_in[46:0], spi_miso};  
                    end else begin
                        sclk_reg <= 0; 
                        bit_cnt <= bit_cnt - 1;
                        
                        if (bit_cnt == 1) begin
                            state <= STOP;
                        end else begin
                            mosi_reg <= shift_out[55];
                            shift_out <= {shift_out[54:0], 1'b0};
                        end
                    end
                end
                
                STOP: begin
                    cs_reg <= 1; 
                    data_valid_reg <= 1;
                    // low byte then high byte
                    accel_x_reg <= {shift_in[39:32], shift_in[47:40]}; 
                    accel_y_reg <= {shift_in[23:16], shift_in[31:24]};
                    accel_z_reg <= {shift_in[7:0],   shift_in[15:8]};
                    
                    delay_cnt <= 16'd10000; 
                    state <= WAIT_STATE; 
                end
                
                WAIT_STATE: begin
                    cs_reg <= 1;
                    data_valid_reg <= 0;
                    if (delay_cnt == 0) state <= IDLE;
                    else delay_cnt <= delay_cnt - 1;
                end
            endcase
        end
    end

    endmodule