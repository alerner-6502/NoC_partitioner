module transmitter #(parameter FLIT_WIDTH, parameter GATE_WIDTH, parameter GATE_FOLDS)(
	input  i_clk,  
	input  i_rst,
	
	input  i_start,
	output o_done,
	output o_adone,  // almost done
	
	input      [FLIT_WIDTH-1:0] i_dt [GATE_WIDTH-1:0],
	input      [GATE_WIDTH-1:0] i_vl, 
	input      [GATE_WIDTH-1:0] i_cr,
	output reg [FLIT_WIDTH*GATE_FOLDS-1:0] o_tx   // will be registered by LVDS serializer         
);
	// Full width is calculated with VALIDs and CREDITs in mind
	
	localparam HEADER_SIZE   = 1 + GATE_WIDTH + GATE_WIDTH;                     // 1 + valids + credits
	localparam HEADER_FLITS  = (HEADER_SIZE + FLIT_WIDTH - 1) / FLIT_WIDTH;     // Number of flits needed for the entire header
	localparam HEADER_WIDTH  = HEADER_FLITS * FLIT_WIDTH;                       // Effective number of bits used to store one header
	localparam HEADER_ZEROS  = HEADER_WIDTH - HEADER_SIZE;                      // Number of zeros needed to pad the header
	localparam REQUEST_WIDTH = HEADER_FLITS + GATE_WIDTH;                       // full request length for the "scheduler" module
	
	
	wire [REQUEST_WIDTH-1:0] request = {{HEADER_FLITS{1'b1}}, i_vl};
	
	wire [$clog2(REQUEST_WIDTH)-1:0] mux_sel [GATE_FOLDS-1:0];
	wire [GATE_FOLDS-1:0] mux_none;
	
	wire [HEADER_WIDTH-1:0] header = {1'b1, i_vl, i_cr, {HEADER_ZEROS{1'b0}}};  // will be sliced for multiplexors
	
	scheduler #(.WIDTH(REQUEST_WIDTH), .FOLDS(GATE_FOLDS)) sch (
		.i_clk    ( i_clk ),  
        .i_rst    ( i_rst ),

        .i_astart ( i_start ),
        .o_done   ( o_done  ),
        .o_adone  ( o_adone ),     // almost done
        
        .i_request  ( request ),
		.o_mux_sel  ( mux_sel ),
		.o_mux_none ( mux_none )
	);

	integer i;
	
	always @ (*) begin
		for(i=0; i<GATE_FOLDS; i=i+1) begin
		
			if(mux_none[i]) o_tx[(GATE_FOLDS-i-1)*FLIT_WIDTH +: FLIT_WIDTH] = 0;
			
			else if(mux_sel[i] > GATE_WIDTH-1) 
			o_tx[(GATE_FOLDS-i-1)*FLIT_WIDTH +: FLIT_WIDTH] = header[FLIT_WIDTH*(mux_sel[i]-GATE_WIDTH) +: FLIT_WIDTH];

			else o_tx[(GATE_FOLDS-i-1)*FLIT_WIDTH +: FLIT_WIDTH] = i_dt[mux_sel[i]];
			
		end
	end
		
endmodule




