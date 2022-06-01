module auto_bitslip #(
	parameter SERIALIZATION, 
	parameter CHANNELS,
	parameter SYNC_PATTERN, 
	parameter STABLE_CYCLES
)(
	input   i_rst,
	input   i_clk,
	
	input   [SERIALIZATION*CHANNELS-1:0] i_data,
	output  [CHANNELS-1:0] o_slip_pulse,
	output  o_ready
);

	wire [CHANNELS-1:0] match;
	
	reg [$clog2(STABLE_CYCLES):0] stable_cnt;
	
	assign o_ready = (stable_cnt == STABLE_CYCLES); 
	
	always @ (negedge i_clk or posedge i_rst) begin
		if(i_rst) stable_cnt <= 0;
		else if(o_ready) stable_cnt <= STABLE_CYCLES;
		else if(&match) stable_cnt <= stable_cnt + 1;
		else stable_cnt <= 0;
	end
	
	genvar i;
	generate
		for(i=0; i<CHANNELS; i=i+1) begin : pulser_gen
			
			feedback_pulser #(.SERIALIZATION(SERIALIZATION), .SYNC_PATTERN(SYNC_PATTERN)) pulse(
				.i_clk        ( i_clk    ),
				.i_enable     ( ~o_ready ),
				.i_data       ( i_data[i*SERIALIZATION +: SERIALIZATION] ),     // [SERIALIZATION-1:0]
				.o_slip_pulse ( o_slip_pulse[i] ),
				.o_match      ( match[i]      )
			);
		
		end
	endgenerate

endmodule

//==========================================

module feedback_pulser #(parameter SERIALIZATION, parameter SYNC_PATTERN)(
	input   i_clk,
	input   i_enable,
	input   [SERIALIZATION-1:0] i_data,
	output  o_slip_pulse,
	output  o_match
);

	reg [2:0] pulse_cnt;
	initial pulse_cnt = 0;
	
	assign o_match = (i_data == SYNC_PATTERN);
	
	always @ (negedge i_clk) begin
		if(~o_match & i_enable) pulse_cnt <= pulse_cnt + 1;
	end
	
	assign o_slip_pulse = pulse_cnt[2];

endmodule














