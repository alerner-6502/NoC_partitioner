module state_machine #(parameter GATE_NUMBER)(
	input i_clk,
	input i_rst,
	
	input i_start,
	input [GATE_NUMBER-1:0] i_tx_ready,
	input [GATE_NUMBER-1:0] i_rx_ready,
	
	output o_gen_sync,
	output o_tx_start,
	output o_rx_pull,
	output o_clock 
);

	localparam S0 = 3'b000;
	localparam S1 = 3'b001;
	localparam S2 = 3'b011;
	localparam S3 = 3'b111;

	reg [2:0] state;
	reg [2:0] next_state;
	
	assign o_gen_sync  = (state == S0);
	assign o_tx_start = (state == S1) | (state == S3);
	assign o_rx_pull  = (state == S3);
	
	assign o_clock = state[2];

	wire all_ready = (&i_tx_ready) & (&i_rx_ready);

	always @ (*) begin
		case(state)
			S0      : next_state = (i_start ? S1 : S0);
			S1      : next_state = S2;
			S2      : next_state = (all_ready ? S3 : S2);
			S3      : next_state = S2;
			default : next_state = S0;
		endcase
	end

	always @ (posedge i_clk or posedge i_rst) begin
		if(i_rst) state <= S0;
		else state <= next_state;
	end

endmodule














