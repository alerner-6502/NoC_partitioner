module gray_counter #(parameter WIDTH, parameter RESET_VALUE)(
	input  i_rst,
	input  i_clk,
	input  i_en,
	output reg [WIDTH-1:0] o_cnt
); 

	wire [WIDTH-1:0] new_cnt;
	wire [WIDTH-1:0] dec_cnt;
	wire [WIDTH-1:0] const_one = 1;

	gray_to_dec #(.WIDTH(WIDTH)) dec_from_gray (
		.i_data ( o_cnt   ),
		.o_data ( dec_cnt )
	);
	
	dec_to_gray #(.WIDTH(WIDTH)) gray_from_dec (
		.i_data ( dec_cnt + const_one ),
		.o_data ( new_cnt     )
	);
	
	always @ (posedge i_clk or posedge i_rst) begin
		if(i_rst) o_cnt <= RESET_VALUE;
		else if(i_en) o_cnt <= new_cnt;
	end
	
endmodule

//====================================================

module gray_to_dec #(parameter WIDTH)(
	input  [WIDTH-1:0] i_data,
	output reg [WIDTH-1:0] o_data
);
	integer i;
	
	always @ (*) begin
		o_data[WIDTH-1] = i_data[WIDTH-1];
		for(i=WIDTH-2; i>=0; i=i-1) begin
			o_data[i] = i_data[i] ^ o_data[i+1];
		end
	end

endmodule

//====================================================

module dec_to_gray #(parameter WIDTH)(
	input  [WIDTH-1:0] i_data,
	output reg [WIDTH-1:0] o_data
);
	integer i;
	
	always @ (*) begin
		o_data[WIDTH-1] = i_data[WIDTH-1];
		for(i=WIDTH-2; i>=0; i=i-1) begin
			o_data[i] = i_data[i] ^ i_data[i+1];
		end
	end

endmodule

