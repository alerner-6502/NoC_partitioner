`include "defines.vh"
module crossbar (
input [`NPORT-1:0]i_data_av, i_free, i_credit,
input [`NP_REGF-1:0] i_data_t,
input [`NP_REG3-1:0] i_tab_in_t , 
input [`NP_REG3-1:0] i_tab_out_t,
output [`NPORT-1:0] o_data_ack, o_tx, 
output reg[`NP_REGF-1:0] o_data_t );
    
    genvar i;
    integer aux_var;
    reg [`TAM_FLIT-1:0]data_in[`NPORT-1:0];
    reg [`reg3-1:0]tab_in[`NPORT-1:0];
    reg [`reg3-1:0]tab_out[`NPORT-1:0];
    wire [`TAM_FLIT-1:0]data_out[`NPORT-1:0];
    
    always@(*)
        begin
        for(aux_var=0;aux_var<`NPORT;aux_var=aux_var+1)
            begin
            data_in[aux_var]=i_data_t[aux_var*`TAM_FLIT+:`TAM_FLIT]; 
            tab_out[aux_var]=i_tab_out_t[aux_var*`reg3+:`reg3];
            tab_in[aux_var]=i_tab_in_t[aux_var*`reg3+:`reg3];
            o_data_t[aux_var*`TAM_FLIT+:`TAM_FLIT]=data_out[aux_var]; 
            end
        end
        
    generate
        for(i=`EAST; i<=`LOCAL;i=i+1) begin : data_gen

            assign o_tx[i]= (i_free[i]==0)?i_data_av[tab_out[i]]:0;
            assign data_out[i]=(i_free[i]==0)?data_in[tab_out[i]]:0;
            assign o_data_ack[i]= (i_data_av[i]==1)?i_credit[tab_in[i]]:0;
            end
    endgenerate
endmodule
