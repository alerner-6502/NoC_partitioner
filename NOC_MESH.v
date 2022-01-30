`include"defines.vh"

module NOC_MESH(
   input [`NROT-1:0]i_rxLocal,i_credit_iLocal,
   input i_rst,i_clk,
   input [`NR_REGF-1:0]i_data_inLocal_flit,
   output [`NR_REGF-1:0]o_data_outLocal_flit,
   output [`NROT-1:0] o_credit_oLocal,o_txLocal
   );

/* verilator lint_off UNOPTFLAT */
    wire [`NP_REGF-1:0]data_in[`NROT-1:0];
    wire [`NPORT-1:0]rx[`NROT-1:0];
    //wire [`NPORT-1:0] clk_rx[`NROT-1:0];
    wire [`NPORT-1:0] credit_i[`NROT-1:0];
    wire [`NPORT-1:0] credit_o[`NROT-1:0];
    wire [`NPORT-1:0] clk_tx[`NROT-1:0];
    wire [`NPORT-1:0] tx[`NROT-1:0];
    wire [`NP_REGF-1:0] data_out[`NROT-1:0]; 
    

    /* verilator lint_off WIDTH */
    function [`TAM_FLIT-1:0]addr;
      input [$clog2(`NROT)-1:0]index;
      reg [`METADEFLIT-1:0]addrX, addrY;
      begin
      addrX=index/`NUM_Y;
      addrY=index%`NUM_Y;
      addr={addrX,addrY};
      end
    endfunction
    /* verilator lint_on WIDTH */

    genvar i;
    
generate
    for(i=0; i<`NROT;i=i+1) begin : router_gen
        
        routercc #(.address(addr(i)))router(
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_credit(credit_i[i]),
            .i_clk_rx({`NPORT{i_clk}}),
            .i_rx(rx[i]),
            .i_data(data_in[i]),
            .o_credit(credit_o[i]), 
            .o_clk_tx(clk_tx[i]), 
            .o_tx(tx[i]),
            .o_data(data_out[i])
            );
        end
endgenerate

generate
    for(i=0;i<`NROT;i=i+1) begin : mesh_gen
    
    //EAST
    if(i<`NUM_Y*`MAX_X) begin
        //assign clk_rx[i][0]=clk_tx[i+`NUM_Y][1];
        assign rx[i][0]=tx[i+`NUM_Y][1];
        assign data_in[i][`TAM_FLIT-1:0]=data_out[i+`NUM_Y][(`TAM_FLIT*2)-1:`TAM_FLIT];
        assign credit_i[i][0]= credit_o[i+`NUM_Y][1];
    end
	else begin
		//assign clk_rx[i][0] = clk_rx[i][1];
        assign rx[i][0] = 1'b0;
        assign data_in[i][`TAM_FLIT-1:0] = 0;
        assign credit_i[i][0] = 1'b1;
	end
	
    //WEST
    if(i>=`NUM_Y) begin
        //assign clk_rx[i][1]=clk_tx[i-`NUM_Y][0];
        assign rx[i][1]=tx[i-`NUM_Y][0];
        assign data_in[i][(`TAM_FLIT*2)-1:`TAM_FLIT]=data_out[i-`NUM_Y][`TAM_FLIT-1:0];
        assign credit_i[i][1]= credit_o[i-`NUM_Y][0];
    end
	else begin
        //assign clk_rx[i][1] = clk_rx[i][0];
        assign rx[i][1] = 1'b0;
        assign data_in[i][(`TAM_FLIT*2)-1:`TAM_FLIT] = 0;
        assign credit_i[i][1] = 1'b1;
	end
	
    //NORTH
    if(i-(i/`NUM_Y)*`NUM_Y<`MAX_Y) begin
        //assign clk_rx[i][2]=clk_tx[i+1][3];
        assign rx[i][2]=tx[i+1][3];
        assign data_in[i][(`TAM_FLIT*3)-1:`TAM_FLIT*2]=data_out[i+1][(`TAM_FLIT*4)-1:`TAM_FLIT*3];
        assign credit_i[i][2]=credit_o[i+1][3];
    end
	else begin
	    //assign clk_rx[i][2] = clk_rx[i][1];
        assign rx[i][2] = 1'b0;
        assign data_in[i][(`TAM_FLIT*3)-1:`TAM_FLIT*2] = 0;
        assign credit_i[i][2] = 1'b1;
	end
	
    //SOUTH
    if(i-(i/`NUM_Y)*`NUM_Y>`MIN_Y)begin
        //assign clk_rx[i][3]=clk_tx[i-1][2];
        assign rx[i][3]=tx[i-1][2];
        assign data_in[i][(`TAM_FLIT*4)-1:`TAM_FLIT*3]=data_out[i-1][(`TAM_FLIT*3)-1:`TAM_FLIT*2];
        assign credit_i[i][3]= credit_o[i-1][2];
    end
	else begin
	    //assign clk_rx[i][3] = clk_tx[i-1][2];
        assign rx[i][3] = 1'b0;
        assign data_in[i][(`TAM_FLIT*4)-1:`TAM_FLIT*3] = 0;
        assign credit_i[i][3] = 1'b1;
	end
	
    //LOCAL
    //assign clk_rx[i][`LOCAL]=i_clk;
    assign data_in[i][(`TAM_FLIT*5)-1:`TAM_FLIT*4]=i_data_inLocal_flit[i*`TAM_FLIT+:`TAM_FLIT];   
    assign credit_i[i][`LOCAL]= i_credit_iLocal[i];
    assign rx[i][`LOCAL]=i_rxLocal[i];    
	
    assign o_data_outLocal_flit[i*`TAM_FLIT+:`TAM_FLIT]=data_out[i][(`TAM_FLIT*5)-1:`TAM_FLIT*4];

    assign o_credit_oLocal[i]=credit_o[i][`LOCAL];
    assign o_txLocal[i]=tx[i][`LOCAL];
    end
endgenerate
/* verilator lint_on UNOPTFLAT */

endmodule
