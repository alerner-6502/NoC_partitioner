module scheduler #(parameter WIDTH, parameter FOLDS)(
	input  i_clk,  
	input  i_rst,
	
	input  i_astart,  // auto start
	output o_done,
	output o_adone,   // almost done
	
	input  [WIDTH-1:0] i_request,
	output [$clog2(WIDTH)-1:0] o_mux_sel [FOLDS-1:0],
	output [FOLDS-1:0] o_mux_none
);

	reg  [WIDTH-1:0] iter_reg;
	wire [WIDTH-1:0] next_iter;

	wire [WIDTH-1:0] requests [FOLDS:0];
	
	assign o_done  = o_mux_none[0];
	assign o_adone = (next_iter == 0);
	
	wire zero_reg = (iter_reg == 0);
	wire msb_bit = i_request[WIDTH-1];
	
	assign requests[0] = ((i_astart & zero_reg & msb_bit) ? i_request : iter_reg);
	assign next_iter = requests[FOLDS];
	
	genvar i;
	generate
		for(i=0; i<FOLDS; i=i+1) begin : fold_gen
		
			selector #(.WIDTH(WIDTH)) sel (
				.i_request     ( requests[i]   ),
				.o_new_request ( requests[i+1] ),
				.o_code        ( o_mux_sel[i]  ),
				.o_none        ( o_mux_none[i]  )
			);
		
		end
	endgenerate
	
	always @ (posedge i_clk or posedge i_rst) begin
		if(i_rst) iter_reg <= 0;
		else iter_reg <= next_iter;
	end

endmodule

//=============================================
 
module selector #(parameter WIDTH)(
    input  [WIDTH-1:0] i_request,
	output [WIDTH-1:0] o_new_request,
    output reg [$clog2(WIDTH)-1:0] o_code,
	output o_none
);
	integer i;
	
	always @ (*) begin
		o_code = 0;
		for(i=0; i<WIDTH; i=i+1) begin
			if(i_request[i]) o_code = i;
		end
	end
	
	assign o_new_request = ~({WIDTH{1'b1}} << o_code) & i_request;
	assign o_none = ~|i_request;

endmodule
