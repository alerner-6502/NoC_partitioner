`include "defines.vh"
module routercc #(parameter address=`TAM_FLIT)(
    input i_clk,i_rst,
    input [`NPORT-1:0] i_credit, i_clk_rx, i_rx,
    input [`NP_REGF-1:0] i_data, 
    output [`NPORT-1:0] o_clk_tx, o_tx, 
    output [`NPORT-1:0] o_credit,
    output [`NP_REGF-1:0] o_data
    );
    genvar i;
    integer aux_var;
    wire [`NPORT-1:0]h, ack_h, data_av, sender, data_ack; 
    reg [`TAM_FLIT-1:0]data_inb[`NPORT-1:0];
    wire [`TAM_FLIT-1:0]data_outb[`NPORT-1:0];
    wire [`NPORT-1:0]free;   
    reg [`NP_REGF-1:0]data_in_t;
    wire [`NP_REG3-1:0]mux_in_t;
    wire [`NP_REG3-1:0]mux_out_t;

    generate
        for(i=`EAST; i<=`LOCAL;i=i+1) begin : phbuffer_gen

            phoenix_buffer buffer(
            .i_clk(i_clk), 
            .i_rst(i_rst),
            .i_rx(i_rx[i]), 
            .i_clk_rx(i_clk_rx[i]),//nao usa i_clk_rx ainda
            .i_ack_h(ack_h[i]),
            .i_data_ack(data_ack[i]),
            .i_data(data_inb[i]),
            .o_credit(o_credit[i]),
            .o_h(h[i]),
            .o_data_av(data_av[i]),
            .o_sender(sender[i]),
            .o_data(data_outb[i]));
            end
    endgenerate
    
    switchcontrol #(.address(address)) swctrl
        (  .i_clk(i_clk),
           .i_rst(i_rst),
           .i_h(h),
           .o_ack_h(ack_h),
           .i_data(data_in_t),
           .i_sender(sender), 
           .o_free(free),
           .o_mux_in(mux_in_t),
           .o_mux_out(mux_out_t)
        );
        
    crossbar crossbar
        (  .i_data_av(data_av),
           .i_free(free),
           .i_credit(i_credit),
           .i_data_t(data_in_t),
           .i_tab_in_t(mux_in_t), 
           .i_tab_out_t(mux_out_t),
           .o_data_ack(data_ack),
           .o_tx(o_tx), 
           .o_data_t(o_data)
        );   
    
   /* NL_route_preselect #(.NV(2), .NP(5)) rt_presel 
        (  .credit_valid(i_cntrl_in),
           .flit_valid(output_used),
           .select(rt_presel_sel),
           .clk(i_clk),
           .rst_n(i_rst) 
        );
*/
    always@(*)
        for (aux_var=0;aux_var<`NPORT;aux_var=aux_var+1)
            begin
            data_inb[aux_var]=i_data[aux_var*`TAM_FLIT+:`TAM_FLIT];
            data_in_t[aux_var*`TAM_FLIT+:`TAM_FLIT]=data_outb[aux_var];
            end

    generate
        for( i=0;i<=(`NPORT-1);i=i+1) begin : clk_gen
            assign o_clk_tx[i]=i_clk;
        end
    endgenerate 

endmodule
