// FPGA 1

module main (
	input  i_rst,
	input  i_start,
	input  CLOCK_50,   
	
	input  i_rx_clk_0,
	output o_tx_clk_0,
	input  [6:0] i_rx_0,
	output [6:0] o_tx_0,
	
	output o_ready
);

	wire gen_sync;
	wire tx_start;
	wire rx_pull;
	wire CORE_CLK;
	wire EMU_CLK;
	
	wire [0:0] tx_ready;
	wire [0:0] rx_ready;
	
	wire [0:0] sync_complete;
	assign o_ready = &sync_complete;
	
	state_machine #(.GATE_NUMBER(1)) machine (
		.i_clk ( CORE_CLK ),
		.i_rst ( i_rst ),
		
		.i_start    ( i_start ),
		.i_tx_ready ( tx_ready ),
		.i_rx_ready ( rx_ready ),
		
		.o_gen_sync ( gen_sync ),
		.o_tx_start ( tx_start ),
		.o_rx_pull  ( rx_pull  ),
		.o_clock    ( EMU_CLK  )
	);
	
	//-----------------------
	
	wire [7:0] flits_to_node_0 [7:0];
	wire [7:0] flits_from_node_0 [7:0]; 
	
	wire [7:0] valids_to_node_0;
	wire [7:0] valids_from_node_0;
	
	wire [7:0] credits_to_node_0;
	wire [7:0] credits_from_node_0;
	
	rxtx_bridge_lvds #(
		.FLIT_WIDTH    ( 8 ),
		.GATE_WIDTH    ( 8 ),
		.GATE_FOLDS    ( 3 ),
		.SYNC_PATTERN  ( 1 ),
		.STABLE_CYCLES ( 1000000 ),
		                       
		.LVDS_SERIALIZATION  ( 4 ),	   
		.LVDS_CHANNELS		 ( 7 ),
		.LVDS_DATA_RATE	     ( 100 ),
		.LVDS_DATA_RATE_STR  ( "100.0 Mbps" ),
		.LVDS_CLOCK_MHZ	     ( 50 ),	   
		.LVDS_CLOCK_MHZ_STR  ( "50.000000 MHz" ),	   
		.LVDS_REFCLK_MHZ_STR ( "25.000000 MHz" ),		   
		.LVDS_DEVICE		 ( "Cyclone V" )	   		   
							   
	) rxtx_0 (
		.i_rst      ( i_rst    ),
		.i_ref_clk  ( CLOCK_50 ),      
		.o_core_clk ( CORE_CLK ),      
		
		.i_tx_start     ( tx_start ),
		.o_tx_done      ( tx_ready[0] ),
		.i_rx_pull      ( rx_pull ),
		.o_rx_available ( rx_ready[0] ),
		
		.i_sync_generate ( gen_sync ),
		.o_sync_complete ( sync_complete[0] ),
		
		.i_rx_clk ( i_rx_clk_0 ),
		.o_tx_clk ( o_tx_clk_0 ),
		
		.i_rx ( i_rx_0 ),
		.o_tx ( o_tx_0 ),
		
		.i_dt ( flits_to_node_0   ),
		.o_dt ( flits_from_node_0 ),
		
		.i_vl ( valids_to_node_0  ),
		.o_vl ( valids_from_node_0 ), 
		
		.i_cr ( credits_to_node_0   ),
		.o_cr ( credits_from_node_0 )
	);
	
	//-----------------------

	noc_1 noc (
		.i_rst ( i_rst   ),
		.i_clk ( EMU_CLK ),

		.i_valids_0 ( valids_from_node_0 ),
		.i_credits_0 ( credits_from_node_0 ),
		.i_flits_0 ( flits_from_node_0 ),
		.o_valids_0 ( valids_to_node_0 ),
		.o_credits_0 ( credits_to_node_0 ),
		.o_flits_0 ( flits_to_node_0 )
	);

endmodule

	