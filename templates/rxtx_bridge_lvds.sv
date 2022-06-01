module rxtx_bridge_lvds #(
	parameter FLIT_WIDTH,
	parameter GATE_WIDTH,   // (excluding the valid word) (actual width is calculated and automatically implemented with VALIDS in mind)
	parameter GATE_FOLDS,
	
	parameter SYNC_PATTERN,
	parameter STABLE_CYCLES,
	
	parameter LVDS_SERIALIZATION,
	parameter LVDS_CHANNELS,
	parameter LVDS_DATA_RATE,
	parameter LVDS_DATA_RATE_STR,
	parameter LVDS_CLOCK_MHZ,
	parameter LVDS_CLOCK_MHZ_STR,
	parameter LVDS_REFCLK_MHZ_STR,
	parameter LVDS_DEVICE	
) 
(
	input  i_rst,           // async reset
	input  i_ref_clk, 
	output o_core_clk,
	
	input  i_tx_start,
	output o_tx_done,
	input  i_rx_pull,
	output o_rx_available,
	
	input  i_sync_generate,
	output o_sync_complete,
	
	input  [FLIT_WIDTH-1:0] i_dt [GATE_WIDTH-1:0],
	output [FLIT_WIDTH-1:0] o_dt [GATE_WIDTH-1:0],
	
	input  [GATE_WIDTH-1:0] i_vl,
	output [GATE_WIDTH-1:0] o_vl,
	
	input  [GATE_WIDTH-1:0] i_cr,
	output [GATE_WIDTH-1:0] o_cr,
	
	input  i_rx_clk,
	output o_tx_clk,
	
	input  [LVDS_CHANNELS-1:0] i_rx,
	output [LVDS_CHANNELS-1:0] o_tx 
);

	parameter LVDS_WIDTH = LVDS_CHANNELS * LVDS_SERIALIZATION;
	parameter TX_WIDTH   = FLIT_WIDTH * GATE_FOLDS;
	parameter TX_PADDING = LVDS_WIDTH - TX_WIDTH;
	
	//==========================================================
	
	wire [TX_WIDTH-1:0] tx_data;
	
	transmitter #(.FLIT_WIDTH(FLIT_WIDTH), .GATE_WIDTH(GATE_WIDTH), .GATE_FOLDS(GATE_FOLDS)) trans (
		.i_clk ( o_core_clk ),  
		.i_rst ( i_rst      ),
		
		.i_start ( i_tx_start ),
		.o_done  ( o_tx_done  ),
		.o_adone (            ),  // almost done
		
		.i_dt ( i_dt    ),   // [FLIT_WIDTH-1:0] i_dt [GATE_WIDTH-1:0],
		.i_vl ( i_vl    ),   // [GATE_WIDTH-1:0] i_vl, 
		.i_cr ( i_cr    ),   // [GATE_WIDTH-1:0] i_cr,
		.o_tx ( tx_data )    // [FLIT_WIDTH*GATE_FOLDS-1:0] o_tx // will be registered by LVDS serializer         
	);
	
	wire [LVDS_SERIALIZATION-1:0] sync_word = SYNC_PATTERN;

	wire [LVDS_WIDTH-1:0] lvds_tx_data = (i_sync_generate ? {LVDS_CHANNELS{sync_word}} : {{TX_PADDING{1'b0}}, tx_data});
	
	//==========================================================
	
	wire lvds_rx_clock;
	
	wire [LVDS_WIDTH-1:0] lvds_rx_data;
	
	wire [TX_WIDTH-1:0] rx_data = lvds_rx_data[TX_WIDTH-1:0]; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< POTENTIAL PROBLEM IN THE FUTURE (receiver reacts to sync)
	
	receiver #(.FLIT_WIDTH(FLIT_WIDTH), .GATE_WIDTH(GATE_WIDTH), .GATE_FOLDS(GATE_FOLDS)) rec (
		.i_rst ( i_rst ),
		
		.i_w_clk    ( lvds_rx_clock      ),
		.i_w_enable ( o_sync_complete    ),
		.i_w_rx     ( rx_data            ),  //[FLIT_WIDTH*GATE_FOLDS-1:0] i_w_rx,
		
		.i_r_clk       ( o_core_clk     ),
		.i_r_pull      ( i_rx_pull      ),
		.o_r_available ( o_rx_available ),
		.o_r_vl        ( o_vl           ),  // [GATE_WIDTH-1:0] o_r_vl,
		.o_r_cr        ( o_cr           ),  // [GATE_WIDTH-1:0] o_r_cr,
		.o_r_dt        ( o_dt           )   // [FLIT_WIDTH-1:0] o_r_dt [GATE_WIDTH-1:0]
	);
	
	//===========================================================
	
	wire [LVDS_CHANNELS-1:0] slip_pulses;
	
	auto_bitslip #(
		.SERIALIZATION ( LVDS_SERIALIZATION ),
		.CHANNELS      ( LVDS_CHANNELS      ),
		.SYNC_PATTERN  ( SYNC_PATTERN       ), 
		.STABLE_CYCLES ( STABLE_CYCLES      )
	) auto(
		.i_rst ( i_rst         ),
		.i_clk ( lvds_rx_clock ),

		.i_data       ( lvds_rx_data    ), //[SERIALIZATION*CHANNELS-1:0] i_data,
		.o_slip_pulse ( slip_pulses     ), //[CHANNELS-1:0] o_slip_pulse,
		.o_ready      ( o_sync_complete )
	);
	
	//===========================================================
	
	lvds_transmitter #(
		.CHANNELS      ( LVDS_CHANNELS      ),
		.SERIALIZATION ( LVDS_SERIALIZATION ),
		.DATA_RATE     ( LVDS_DATA_RATE     ),
		.DATA_RATE_STR ( LVDS_DATA_RATE_STR ),
		.CLOCK_MHZ     ( LVDS_CLOCK_MHZ     ),
		.CLOCK_MHZ_STR ( LVDS_CLOCK_MHZ_STR ),
		.DEVICE        ( LVDS_DEVICE        )
	) my_tx(
		.tx_in        ( lvds_tx_data ),
		.tx_inclock   ( i_ref_clk    ),
		
		.tx_out       ( o_tx       ),
		.tx_outclock  ( o_tx_clk   ),
		.tx_coreclock ( o_core_clk )
	);
	
	lvds_receiver #(
		.CHANNELS       ( LVDS_CHANNELS       ),
		.SERIALIZATION  ( LVDS_SERIALIZATION  ),
		.DATA_RATE      ( LVDS_DATA_RATE      ),
		.DATA_RATE_STR  ( LVDS_DATA_RATE_STR  ),
		.REFCLK_MHZ_STR ( LVDS_REFCLK_MHZ_STR ),
		.DEVICE         ( LVDS_DEVICE         )
	) my_rx (
		.rx_in                 ( i_rx        ),
		.rx_inclock            ( i_rx_clk    ),
		.rx_channel_data_align ( slip_pulses ),
		
		.rx_out      ( lvds_rx_data  ),
		.rx_outclock ( lvds_rx_clock )
	);
	
	//===========================================================

endmodule
