module broadcast(
	input         clk,
	input         rst,
	
	input         i_start,
	input [8:0]   i_number,   // 9 bit number for calculations
	
	output reg [15:0] o_sdata,
	output reg        o_svalid
);

	reg [3:0] state;
	
	always @ (posedge clk) begin
		if(~rst) state <= 0;
		else begin
			if(state == 0) state <= (i_start ? 1 : 0);
			else state <= ((state == 9) ? 9 : state+1);
		end
	end
	
	always @ (*) begin
		case(state)
			0 : begin o_sdata = 16'd0; o_svalid = 1'b0; end
			
			1 : begin o_sdata = {4'b00_01, 3'b000, i_number}; o_svalid = 1'b1; end
			2 : begin o_sdata = {4'b00_10, 3'b000, i_number}; o_svalid = 1'b1; end
			3 : begin o_sdata = {4'b01_00, 3'b000, i_number}; o_svalid = 1'b1; end
			4 : begin o_sdata = {4'b01_01, 3'b000, i_number}; o_svalid = 1'b1; end
			5 : begin o_sdata = {4'b01_10, 3'b000, i_number}; o_svalid = 1'b1; end
			6 : begin o_sdata = {4'b10_00, 3'b000, i_number}; o_svalid = 1'b1; end
			7 : begin o_sdata = {4'b10_01, 3'b000, i_number}; o_svalid = 1'b1; end
			8 : begin o_sdata = {4'b10_10, 3'b000, i_number}; o_svalid = 1'b1; end
			
			9 : begin o_sdata = 16'd0; o_svalid = 1'b0; end
			
			default : begin o_sdata = 16'd0; o_svalid = 1'b0; end
			
		endcase
	end

endmodule
