module reciever #(parameter FLIT_WIDTH, parameter GATE_WIDTH, parameter GATE_FOLDS)(
	input  i_rst,
	
	input  i_w_clk,
	input  i_w_enable,
	input  [FLIT_WIDTH*GATE_FOLDS-1:0] i_w_rx,
	
	input  i_r_clk,
	input  i_r_pull,
	output o_r_available,
	output [GATE_WIDTH-1:0] o_r_vl,
	output [GATE_WIDTH-1:0] o_r_cr,
	output reg [FLIT_WIDTH-1:0] o_r_dt [GATE_WIDTH-1:0]
);
	// Full width is calculated with VALIDs and CREDITs in mind
	
	localparam HEADER_SIZE   = 1 + GATE_WIDTH + GATE_WIDTH;                     // 1 + valids + credits
	localparam HEADER_FLITS  = (HEADER_SIZE + FLIT_WIDTH - 1) / FLIT_WIDTH;     // Number of flits needed for the entire header
	localparam HEADER_WIDTH  = HEADER_FLITS * FLIT_WIDTH;
	localparam REQUEST_WIDTH = HEADER_FLITS + GATE_WIDTH;                       // full request length for the "scheduler" module
	localparam FLAT_RX_WIDTH = FLIT_WIDTH * GATE_FOLDS;
	
	integer i, j;
	
	reg [FLIT_WIDTH-1:0] packed_w_rx [GATE_FOLDS-1:0];
	
	always @ (*) begin
		for(i=0; i<GATE_FOLDS; i=i+1) begin
			packed_w_rx[GATE_FOLDS-i-1] = i_w_rx[i*FLIT_WIDTH +: FLIT_WIDTH];
		end
	end

	wire [GATE_WIDTH-1:0] only_valids = i_w_rx[FLAT_RX_WIDTH-2 -: GATE_WIDTH];
	wire one_flag = i_w_rx[FLAT_RX_WIDTH-1];
	
	
	wire [REQUEST_WIDTH-1:0] request = {{HEADER_FLITS{one_flag}}, only_valids};
	
	wire [$clog2(REQUEST_WIDTH)-1:0] mux_sel [GATE_FOLDS-1:0];
	wire [GATE_FOLDS-1:0] mux_none;
	
	wire done, adone;
	wire packet_cnt_e = ~done & adone;
	
	scheduler #(.WIDTH(REQUEST_WIDTH), .FOLDS(GATE_FOLDS)) sch (
		.i_clk    ( i_w_clk ),  
        .i_rst    ( i_rst   ),

        .i_astart ( i_w_enable ),
        .o_done   ( done       ),
        .o_adone  ( adone      ),   // almost done
        
        .i_request  ( request  ),   // [WIDTH-1:0] request
		.o_mux_sel  ( mux_sel  ),   // [$clog2(WIDTH)-1:0] mux_sel [FOLDS-1:0]
		.o_mux_none ( mux_none )    // [FOLDS-1:0] mux_none
	);
	
	wire [FLIT_WIDTH-1:0] splitter [REQUEST_WIDTH-1:0];
	
	reg [GATE_FOLDS-1:0] enables [REQUEST_WIDTH-1:0];
	reg [REQUEST_WIDTH-1:0] tmp;
	
	always @ (*) begin
		for(i=0; i<GATE_FOLDS; i=i+1) begin
			tmp = (mux_none[i] ? 0 : (1 << mux_sel[i]));
			for(j=0; j<REQUEST_WIDTH; j=j+1) enables[j][i] = tmp[j];
		end
	end

	async_fifo #(.WORD_WIDTH(FLIT_WIDTH), .WORDS(REQUEST_WIDTH), .THREADS(GATE_FOLDS)) fifo(
		.i_rst         ( i_rst         ),
		
		.i_w_clk       ( i_w_clk       ),
		.i_w_push      ( packet_cnt_e  ),
		.i_w_data      ( packed_w_rx   ),    // [WORD_WIDTH-1:0] i_w_rx [THREADS-1:0]
		.i_w_enables   ( enables       ),    // [THREADS-1:0] enables [WORDS-1:0]  
		
		.i_r_clk       ( i_r_clk       ),
		.i_r_pull      ( i_r_pull      ),
		.o_r_data      ( splitter      ),    // [WORD_WIDTH-1:0] o_r_dt [WORDS-1:0]
		.o_r_available ( o_r_available )
	);
	
	always @ (*) begin
		for(i=0; i<GATE_WIDTH; i=i+1) begin
			o_r_dt[i] = splitter[i];         // You can't just assign these like so: assign o_r_dt = splitter[GATE_WIDTH-1:0];
		end
	end
	
	reg [HEADER_WIDTH-1:0] flat_header;
	
	always @ (*) begin
		for(i=GATE_WIDTH; i<REQUEST_WIDTH; i=i+1) begin
			flat_header[(i-GATE_WIDTH)*FLIT_WIDTH +: FLIT_WIDTH] = splitter[i];
		end
	end
	
	assign o_r_vl = flat_header[HEADER_WIDTH-2 -: GATE_WIDTH];
	
	assign o_r_cr = flat_header[HEADER_WIDTH-GATE_WIDTH-2 -: GATE_WIDTH];

endmodule

