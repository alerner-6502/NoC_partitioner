// megafunction wizard: %ALTLVDS_TX%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: ALTLVDS_TX 

module lvds_transmitter #(
	parameter CHANNELS,     
	parameter SERIALIZATION,
	parameter DATA_RATE,    
	parameter DATA_RATE_STR,
	parameter CLOCK_MHZ,    
	parameter CLOCK_MHZ_STR,
	parameter DEVICE        
)
(
	tx_in,
	tx_inclock,
	tx_coreclock,
	tx_out,
	tx_outclock);

	input	[CHANNELS*SERIALIZATION-1:0] tx_in;
	input	  tx_inclock;
	output	  tx_coreclock;
	output	[CHANNELS-1:0]  tx_out;
	output	  tx_outclock;

	wire  sub_wire0;
	wire [CHANNELS-1:0] sub_wire1;
	wire  sub_wire2;
	wire  tx_coreclock = sub_wire0;
	wire [CHANNELS-1:0] tx_out = sub_wire1[CHANNELS-1:0];
	wire  tx_outclock = sub_wire2;

	altlvds_tx	ALTLVDS_TX_component (
				.tx_in (tx_in),
				.tx_inclock (tx_inclock),
				.tx_coreclock (sub_wire0),
				.tx_out (sub_wire1),
				.tx_outclock (sub_wire2),
				.pll_areset (1'b0),
				.sync_inclock (1'b0),
				.tx_data_reset (1'b0),
				.tx_enable (1'b1),
				.tx_locked (),
				.tx_pll_enable (1'b1),
				.tx_syncclock (1'b0));
	defparam
		ALTLVDS_TX_component.center_align_msb = "UNUSED",
		ALTLVDS_TX_component.common_rx_tx_pll = "ON",
		ALTLVDS_TX_component.coreclock_divide_by = 1,
		ALTLVDS_TX_component.data_rate = DATA_RATE_STR,
		ALTLVDS_TX_component.deserialization_factor = SERIALIZATION,
		ALTLVDS_TX_component.differential_drive = 0,
		ALTLVDS_TX_component.enable_clock_pin_mode = "UNUSED",
		ALTLVDS_TX_component.implement_in_les = "OFF",
		ALTLVDS_TX_component.inclock_boost = 0,
		ALTLVDS_TX_component.inclock_data_alignment = "EDGE_ALIGNED",
		ALTLVDS_TX_component.inclock_period = 1000000/CLOCK_MHZ,
		ALTLVDS_TX_component.inclock_phase_shift = 0,
		ALTLVDS_TX_component.intended_device_family = DEVICE,
		ALTLVDS_TX_component.lpm_hint = "CBX_MODULE_PREFIX=lvds_transmitter",
		ALTLVDS_TX_component.lpm_type = "altlvds_tx",
		ALTLVDS_TX_component.multi_clock = "OFF",
		ALTLVDS_TX_component.number_of_channels = CHANNELS,
		ALTLVDS_TX_component.outclock_alignment = "EDGE_ALIGNED",
		ALTLVDS_TX_component.outclock_divide_by = 4,
		ALTLVDS_TX_component.outclock_duty_cycle = 50,
		ALTLVDS_TX_component.outclock_multiply_by = 1,
		ALTLVDS_TX_component.outclock_phase_shift = (1000000/DATA_RATE)/2,
		ALTLVDS_TX_component.outclock_resource = "AUTO",
		ALTLVDS_TX_component.output_data_rate = DATA_RATE,
		ALTLVDS_TX_component.pll_compensation_mode = "AUTO",
		ALTLVDS_TX_component.pll_self_reset_on_loss_lock = "OFF",
		ALTLVDS_TX_component.preemphasis_setting = 0,
		ALTLVDS_TX_component.refclk_frequency = CLOCK_MHZ_STR,
		ALTLVDS_TX_component.registered_input = "TX_CORECLK",
		ALTLVDS_TX_component.use_external_pll = "OFF",
		ALTLVDS_TX_component.use_no_phase_shift = "ON",
		ALTLVDS_TX_component.vod_setting = 0,
		ALTLVDS_TX_component.clk_src_is_pll = "off";
		
endmodule
