
//`define ENABLE_ADC
//`define ENABLE_AUD
//`define ENABLE_CLOCK2
//`define ENABLE_CLOCK3
//`define ENABLE_CLOCK4
`define ENABLE_CLOCK
//`define ENABLE_DRAM
//`define ENABLE_FAN
`define ENABLE_FPGA
`define ENABLE_GPIO
`define ENABLE_HEX
//`define ENABLE_HPS
//`define ENABLE_IRDA
`define ENABLE_KEY
`define ENABLE_LEDR
//`define ENABLE_PS2
//`define ENABLE_TD
//`define ENABLE_VGA
`define ENABLE_SW

`include"defines.vh"

module de1_soc(

      `ifdef ENABLE_ADC
      output             ADC_CONVST,
      output             ADC_DIN,
      input              ADC_DOUT,
      output             ADC_SCLK,
      `endif

      `ifdef ENABLE_AUD
      input              AUD_ADCDAT,
      inout              AUD_ADCLRCK,
      inout              AUD_BCLK,
      output             AUD_DACDAT,
      inout              AUD_DACLRCK,
      output             AUD_XCK,
      `endif

      `ifdef ENABLE_CLOCK2
      input              CLOCK2_50,
      `endif

      `ifdef ENABLE_CLOCK3
      input              CLOCK3_50,
      `endif

      `ifdef ENABLE_CLOCK4
      input              CLOCK4_50,
      `endif

      `ifdef ENABLE_CLOCK
      input              CLOCK_50,
      `endif

      `ifdef ENABLE_DRAM
      output      [12:0] DRAM_ADDR,
      output      [1:0]  DRAM_BA,
      output             DRAM_CAS_N,
      output             DRAM_CKE,
      output             DRAM_CLK,
      output             DRAM_CS_N,
      inout       [15:0] DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_RAS_N,
      output             DRAM_UDQM,
      output             DRAM_WE_N,
      `endif

      `ifdef ENABLE_FAN
      output             FAN_CTRL,
      `endif

      `ifdef ENABLE_FPGA
      output             FPGA_I2C_SCLK,
      inout              FPGA_I2C_SDAT,
      `endif

      `ifdef ENABLE_GPIO
      inout     [35:0]         GPIO_0,
      inout     [35:0]         GPIO_1,
      `endif

      `ifdef ENABLE_HEX
      output      [6:0]  HEX0,
      output      [6:0]  HEX1,
      output      [6:0]  HEX2,
      output      [6:0]  HEX3,
      output      [6:0]  HEX4,
      output      [6:0]  HEX5,
      `endif

      `ifdef ENABLE_HPS
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N,
      output             HPS_DDR3_CK_P,
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout       [3:0]  HPS_FLASH_DATA,
      output             HPS_FLASH_DCLK,
      output             HPS_FLASH_NCSO,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_I2C2_SCLK,
      inout              HPS_I2C2_SDAT,
      inout              HPS_I2C_CONTROL,
      inout              HPS_KEY,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
      `endif

      `ifdef ENABLE_IRDA
      input              IRDA_RXD,
      output             IRDA_TXD,
      `endif

      `ifdef ENABLE_KEY
      input       [3:0]  KEY,
      `endif

      `ifdef ENABLE_LEDR
      output      [9:0]  LEDR,
      `endif

      `ifdef ENABLE_PS2
      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,
      `endif

      `ifdef ENABLE_TD
      input             TD_CLK27,
      input      [7:0]  TD_DATA,
      input             TD_HS,
      output            TD_RESET_N,
      input             TD_VS,
      `endif

      `ifdef ENABLE_VGA
      output      [7:0]  VGA_B,
      output             VGA_BLANK_N,
      output             VGA_CLK,
      output      [7:0]  VGA_G,
      output             VGA_HS,
      output      [7:0]  VGA_R,
      output             VGA_SYNC_N,
      output             VGA_VS,
      `endif

      `ifdef ENABLE_SW
      input       [9:0]  SW
      `endif
);

	reg [15:0] divider;
	always @(posedge CLOCK_50) begin
		divider <= divider + 1;
	end

	wire clk = CLOCK_50; //divider[15];
	wire rst = KEY[0];

    wire [15:0] s0, s1, s2, s3, s4, s5, s6, s7, s8;  // OUT. processor sends data packets
	wire        t0, t1, t2, t3, t4, t5, t6, t7, t8;  // OUT. processor sets packets as valid
	wire        c0, c1, c2, c3, c4, c5, c6, c7, c8;  // IN.  can processor accept packets?
	 
	wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7, r8;  // IN.  processor recieves data packets
	wire        v0, v1, v2, v3, v4, v5, v6, v7, v8;  // IN.  processor checks if packets are valid
	wire        f0, f1, f2, f3, f4, f5, f6, f7, f8;  // OUT. can router accept processors packets?
	
	
	NOC_MESH mynoc
    (
		// GENERAL
		.i_rst                ( rst ),
		.i_clk                ( clk ),
		
		// RECIEVE PACKET
		.o_data_outLocal_flit ( {r8,r7,r6,r5,r4,r3,r2,r1,r0}  ),  // 9*16 = 144 bits
		.o_txLocal            ( {v8,v7,v6,v5,v4,v3,v2,v1,v0} ),  // 9 bits
		.i_credit_iLocal      ( {f8,f7,f6,f5,f4,f3,f2,f1,f0}  ),  // all ports are always ready to recieve
		
		// SEND PACKET
		.i_data_inLocal_flit  ( {s8,s7,s6,s5,s4,s3,s2,s1,s0} ),  // 9*16 = 144 bits
		.i_rxLocal            ( {t8,t7,t6,t5,t4,t3,t2,t1,t0} ),  // 9 bits
		.o_credit_oLocal      ( {c8,c7,c6,c5,c4,c3,c2,c1,c0} )   // 9 bits
    );
	
	assign f0 = 1'b1;   // key user can always recieve packets
	
/* 	assign s0 = {SW[9:6], 8'b00000000, SW[3:0]};
	assign t0 = ~KEY[1] & c0; */
	
	broadcast gen (
		.clk      ( clk     ),
		.rst      ( rst     ),
		.i_start  ( ~KEY[1] ),
		.i_number ( SW[8:0] ),   // 9 bit number for calculations
		.o_sdata  ( s0      ),
		.o_svalid ( t0      )
	);
	
	reg [9:0] ledreg;
	always @ (posedge clk) begin
		if(~rst) ledreg <= 0;
		else if(v0) ledreg <= r0[9:0];
	end
	assign LEDR = ledreg;
	
	seg7_encoder seg0 (ledreg[3:0], HEX0);
	seg7_encoder seg1 (ledreg[7:4], HEX1);
	seg7_encoder seg2 ({2'b00, ledreg[9:8]}, HEX2);
	
	assign HEX5 = 7'h7f;
    assign HEX4 = 7'h7f;
    assign HEX3 = 7'h7f;
	
    //assign HEX2 = 7'h7f;
    //assign HEX1 = 7'h7f;
    //assign HEX0 = 7'h7f;

	
/* 	signed_echo #(.signature(8'ha1)) e1 (
		.clk(clk), .rst(rst), 
		.i_rdata(r1), .i_rvalid(v1), .o_rcredit(f1),
		.o_sdata(s1), .o_svalid(t1), .i_scredit(c1)
	);
	
	signed_echo #(.signature(8'h45)) e2 (
		.clk(clk), .rst(rst), 
		.i_rdata(r2), .i_rvalid(v2), .o_rcredit(f2),
		.o_sdata(s2), .o_svalid(t2), .i_scredit(c2)
	);
	
	signed_echo #(.signature(8'h23)) e3 (
		.clk(clk), .rst(rst), 
		.i_rdata(r3), .i_rvalid(v3), .o_rcredit(f3),
		.o_sdata(s3), .o_svalid(t3), .i_scredit(c3)
	);
	
	signed_echo #(.signature(8'h67)) e4 (
		.clk(clk), .rst(rst), 
		.i_rdata(r4), .i_rvalid(v4), .o_rcredit(f4),
		.o_sdata(s4), .o_svalid(t4), .i_scredit(c4)
	);

	signed_echo #(.signature(8'h98)) e5 (
		.clk(clk), .rst(rst), 
		.i_rdata(r5), .i_rvalid(v5), .o_rcredit(f5),
		.o_sdata(s5), .o_svalid(t5), .i_scredit(c5)
	);
	
	signed_echo #(.signature(8'hf0)) e6 (
		.clk(clk), .rst(rst), 
		.i_rdata(r6), .i_rvalid(v6), .o_rcredit(f6),
		.o_sdata(s6), .o_svalid(t6), .i_scredit(c6)
	);
	
	signed_echo #(.signature(8'hd3)) e7 (
		.clk(clk), .rst(rst), 
		.i_rdata(r7), .i_rvalid(v7), .o_rcredit(f7),
		.o_sdata(s7), .o_svalid(t7), .i_scredit(c7)
	);
	
	signed_echo #(.signature(8'hb1)) e8 (
		.clk(clk), .rst(rst), 
		.i_rdata(r8), .i_rvalid(v8), .o_rcredit(f8),
		.o_sdata(s8), .o_svalid(t8), .i_scredit(c8)
	); */
	
	nios_core_1 n1 (
        .clk_clk                  ( clk ),
        .reset_reset_n            ( rst ),
        .input_port_export_export ( {c1, v1, r1} ),
        .ouput_port_export_export ( {f1, t1, s1} ) 
    );

	nios_core_2 n2 (
        .clk_clk                  ( clk ),
        .reset_reset_n            ( rst ),
        .input_port_export_export ( {c2, v2, r2} ),
        .ouput_port_export_export ( {f2, t2, s2} ) 
    );
	
	nios_core_3 n3 (
        .clk_clk                  ( clk ),
        .reset_reset_n            ( rst ),
        .input_port_export_export ( {c3, v3, r3} ),
        .ouput_port_export_export ( {f3, t3, s3} ) 
    );
	
	nios_core_4 n4 (
        .clk_clk                  ( clk ),
        .reset_reset_n            ( rst ),
        .input_port_export_export ( {c4, v4, r4} ),
        .ouput_port_export_export ( {f4, t4, s4} ) 
    );
	
	nios_core_5 n5 (
        .clk_clk                  ( clk ),
        .reset_reset_n            ( rst ),
        .input_port_export_export ( {c5, v5, r5} ),
        .ouput_port_export_export ( {f5, t5, s5} ) 
    );
	
	nios_core_6 n6 (
        .clk_clk                  ( clk ),
        .reset_reset_n            ( rst ),
        .input_port_export_export ( {c6, v6, r6} ),
        .ouput_port_export_export ( {f6, t6, s6} ) 
    );
	
	nios_core_7 n7 (
        .clk_clk                  ( clk ),
        .reset_reset_n            ( rst ),
        .input_port_export_export ( {c7, v7, r7} ),
        .ouput_port_export_export ( {f7, t7, s7} ) 
    );
	
	nios_core_8 n8 (
        .clk_clk                  ( clk ),
        .reset_reset_n            ( rst ),
        .input_port_export_export ( {c8, v8, r8} ),
        .ouput_port_export_export ( {f8, t8, s8} ) 
    );

endmodule
