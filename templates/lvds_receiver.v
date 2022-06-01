// megafunction wizard: %ALTLVDS_RX%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: ALTLVDS_RX 

module lvds_receiver #(
	parameter CHANNELS,       
	parameter SERIALIZATION,  
	parameter DATA_RATE,      
	parameter DATA_RATE_STR,  
	parameter REFCLK_MHZ_STR, 
	parameter DEVICE          
)
(
	rx_channel_data_align,
	rx_in,
	rx_inclock,
	rx_out,
	rx_outclock);

	input	[CHANNELS-1:0]  rx_channel_data_align;
	input	[CHANNELS-1:0]  rx_in;
	input	  rx_inclock;
	output	[CHANNELS*SERIALIZATION-1:0]  rx_out;
	output	  rx_outclock;

	wire [CHANNELS*SERIALIZATION-1:0] sub_wire0;
	wire  sub_wire1;
	wire [CHANNELS*SERIALIZATION-1:0] rx_out = sub_wire0[CHANNELS*SERIALIZATION-1:0];
	wire  rx_outclock = sub_wire1;

	altlvds_rx	ALTLVDS_RX_component (
				.rx_channel_data_align (rx_channel_data_align),
				.rx_in (rx_in),
				.rx_inclock (rx_inclock),
				.rx_out (sub_wire0),
				.rx_outclock (sub_wire1),
				.dpa_pll_cal_busy (),
				.dpa_pll_recal (1'b0),
				.pll_areset (1'b0),
				.pll_phasecounterselect (),
				.pll_phasedone (1'b1),
				.pll_phasestep (),
				.pll_phaseupdown (),
				.pll_scanclk (),
				.rx_cda_max (),
				.rx_cda_reset ({CHANNELS{1'b0}}),
				.rx_coreclk ({CHANNELS{1'b1}}),
				.rx_data_align (1'b0),
				.rx_data_align_reset (1'b0),
				.rx_data_reset (1'b0),
				.rx_deskew (1'b0),
				.rx_divfwdclk (),
				.rx_dpa_lock_reset ({CHANNELS{1'b0}}),
				.rx_dpa_locked (),
				.rx_dpaclock (1'b0),
				.rx_dpll_enable ({CHANNELS{1'b1}}),
				.rx_dpll_hold ({CHANNELS{1'b0}}),
				.rx_dpll_reset ({CHANNELS{1'b0}}),
				.rx_enable (1'b1),
				.rx_fifo_reset ({CHANNELS{1'b0}}),
				.rx_locked (),
				.rx_pll_enable (1'b1),
				.rx_readclock (1'b0),
				.rx_reset ({CHANNELS{1'b0}}),
				.rx_syncclock (1'b0));
	defparam
		ALTLVDS_RX_component.buffer_implementation = "RAM",
		ALTLVDS_RX_component.cds_mode = "UNUSED",
		ALTLVDS_RX_component.common_rx_tx_pll = "OFF",
		ALTLVDS_RX_component.data_align_rollover = SERIALIZATION,
		ALTLVDS_RX_component.data_rate = DATA_RATE_STR,
		ALTLVDS_RX_component.deserialization_factor = SERIALIZATION,
		ALTLVDS_RX_component.dpa_initial_phase_value = 0,
		ALTLVDS_RX_component.dpll_lock_count = 0,
		ALTLVDS_RX_component.dpll_lock_window = 0,
		ALTLVDS_RX_component.enable_clock_pin_mode = "UNUSED",
		ALTLVDS_RX_component.enable_dpa_align_to_rising_edge_only = "OFF",
		ALTLVDS_RX_component.enable_dpa_calibration = "ON",
		ALTLVDS_RX_component.enable_dpa_fifo = "UNUSED",
		ALTLVDS_RX_component.enable_dpa_initial_phase_selection = "OFF",
		ALTLVDS_RX_component.enable_dpa_mode = "OFF",
		ALTLVDS_RX_component.enable_dpa_pll_calibration = "OFF",
		ALTLVDS_RX_component.enable_soft_cdr_mode = "OFF",
		ALTLVDS_RX_component.implement_in_les = "OFF",
		ALTLVDS_RX_component.inclock_boost = 0,
		ALTLVDS_RX_component.inclock_data_alignment = "EDGE_ALIGNED",
		ALTLVDS_RX_component.inclock_period = 1000000/(DATA_RATE/4),
		ALTLVDS_RX_component.inclock_phase_shift = (1000000/DATA_RATE)/2,
		ALTLVDS_RX_component.input_data_rate = DATA_RATE,
		ALTLVDS_RX_component.intended_device_family = DEVICE,
		ALTLVDS_RX_component.lose_lock_on_one_change = "UNUSED",
		ALTLVDS_RX_component.lpm_hint = "CBX_MODULE_PREFIX=lvds_receiver",
		ALTLVDS_RX_component.lpm_type = "altlvds_rx",
		ALTLVDS_RX_component.number_of_channels = CHANNELS,
		ALTLVDS_RX_component.outclock_resource = "AUTO",
		ALTLVDS_RX_component.pll_operation_mode = "NORMAL",
		ALTLVDS_RX_component.pll_self_reset_on_loss_lock = "UNUSED",
		ALTLVDS_RX_component.port_rx_channel_data_align = "PORT_USED",
		ALTLVDS_RX_component.port_rx_data_align = "PORT_UNUSED",
		ALTLVDS_RX_component.refclk_frequency = REFCLK_MHZ_STR,
		ALTLVDS_RX_component.registered_data_align_input = "UNUSED",
		ALTLVDS_RX_component.registered_output = "ON",
		ALTLVDS_RX_component.reset_fifo_at_first_lock = "UNUSED",
		ALTLVDS_RX_component.rx_align_data_reg = "RISING_EDGE",
		ALTLVDS_RX_component.sim_dpa_is_negative_ppm_drift = "OFF",
		ALTLVDS_RX_component.sim_dpa_net_ppm_variation = 0,
		ALTLVDS_RX_component.sim_dpa_output_clock_phase_shift = 0,
		ALTLVDS_RX_component.use_coreclock_input = "OFF",
		ALTLVDS_RX_component.use_dpll_rawperror = "OFF",
		ALTLVDS_RX_component.use_external_pll = "OFF",
		ALTLVDS_RX_component.use_no_phase_shift = "ON",
		ALTLVDS_RX_component.x_on_bitslip = "ON",
		ALTLVDS_RX_component.clk_src_is_pll = "off";

endmodule

