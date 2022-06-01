
module async_fifo #(parameter WORD_WIDTH, parameter WORDS, parameter THREADS)(
	input   i_rst,
	
	input   i_w_clk,
	input   i_w_push,
	input   [WORD_WIDTH-1:0] i_w_data [THREADS-1:0],
	input   [THREADS-1:0] i_w_enables [WORDS-1:0],
	
	input   i_r_clk,
	input   i_r_pull,
	output  [WORD_WIDTH-1:0] o_r_data [WORDS-1:0],
	output  o_r_available
);
	
	wire [1:0] write_cnt;
	wire [1:0] read_cnt;
	
	gray_counter #(.WIDTH(2), .RESET_VALUE(2'b00)) w_cnt(
		.i_rst ( i_rst     ),
		.i_clk ( i_w_clk   ),
		.i_en  ( i_w_push  ),
		.o_cnt ( write_cnt )
	);
	
	gray_counter #(.WIDTH(2), .RESET_VALUE(2'b00)) r_cnt(
		.i_rst ( i_rst    ),
		.i_clk ( i_r_clk  ),
		.i_en  ( i_r_pull ),
		.o_cnt ( read_cnt )
	);
	
	reg [1:0] crossing_reg_0;
	reg [1:0] crossing_reg_1;
	
	always @ (posedge i_r_clk or posedge i_rst) begin
		if(i_rst) begin
			crossing_reg_0 <= 0;
			crossing_reg_1 <= 0;
		end
		else begin
			crossing_reg_0 <= write_cnt;
			crossing_reg_1 <= crossing_reg_0;
		end
	end
	
	assign o_r_available = (read_cnt != crossing_reg_1);
	
	genvar i;
		
	generate
		for(i=0; i<WORDS; i=i+1) begin : memory_gen
			
			memory_cell #(.WORD_WIDTH(WORD_WIDTH), .THREADS(THREADS)) mem(
				.i_rst          ( i_rst   ),                  
				.i_clk          ( i_w_clk ),
				
				.i_cell_enable  ( i_w_enables[i] ),    // [THREADS-1:0] i_cell_enable  <---  [THREADS-1:0] i_w_enables [WORDS-1:0] 
				.i_write_select ( ^write_cnt     ),    // XOR all bits of your gray counter!!!
				.i_data         ( i_w_data       ),    // [WORD_WIDTH-1:0] i_data [THREADS-1:0]
				
				.i_read_select  ( ^read_cnt   ),                    // XOR all bits of your gray counter!!!
				.o_data         ( o_r_data[i] )                     //   [WORD_WIDTH-1:0] o_data <--- [WORD_WIDTH-1:0] o_r_data [WORDS-1:0]
			);
			
		end
	endgenerate
	
endmodule

//====================================================

module memory_cell #(parameter WORD_WIDTH, parameter THREADS)(
	input  i_rst,                                  // <--- CAN BE REMOVED!!!
	input  i_clk,
	
	input  [THREADS-1:0] i_cell_enable,
	input  i_write_select,
	
	input  i_read_select,
	input  [WORD_WIDTH-1:0] i_data [THREADS-1:0],
	output [WORD_WIDTH-1:0] o_data
);

	reg [WORD_WIDTH-1:0] data_0;
	reg [WORD_WIDTH-1:0] data_1;
	
	integer i, source;
	
	always @ (*) begin
		source = 0;
		for (i=0; i<THREADS; i=i+1) begin
			if(i_cell_enable[i]) source = i;
		end
	end

	always @ (posedge i_clk or posedge i_rst) begin
		if(i_rst) begin
			data_0 <= 0;
			data_1 <= 0;
		end
		else if(|i_cell_enable) begin
			if(i_write_select) data_1 <= i_data[source];
			else data_0 <= i_data[source];
		end
	end
	
	assign o_data = (i_read_select ? data_1 : data_0);
	
endmodule



