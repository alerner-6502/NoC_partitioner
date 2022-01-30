module signed_echo #(parameter signature)(
	input              clk,
	input              rst,

	input       [15:0] i_rdata,
	input              i_rvalid,
	output             o_rcredit,
	
	output reg  [15:0] o_sdata,
	output reg         o_svalid,
	input              i_scredit
);

	wire [11:0] sum = i_rdata + signature;

	always @ (posedge clk) begin
		if(~rst) begin
			o_sdata  <= 0;
			o_svalid <= 0;
		end
		else begin
			o_sdata  <= (i_scredit ? {4'b0000, sum} : 16'd0);
			o_svalid <= (i_scredit ? i_rvalid : 1'b0);
		end
	end
	
	assign o_rcredit = 1'b1;
	
	

endmodule