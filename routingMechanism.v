`include "defines.vh"
module routingMechanism#(parameter adress=16)(
input [`TAM_FLIT-1:0]i_dest,
output reg [`NPORT-1:0]o_outputPort,
output [`ROUTERCONTROL-1:0]o_find
    );

    wire [`METADEFLIT-1:0] local_x;
    wire [`METADEFLIT-1:0] dest_x;
    wire [`METADEFLIT-1:0] local_y;
    wire [`METADEFLIT-1:0] dest_y;

    always@(*)
        begin
        o_outputPort=0;
        if (dest_x>local_x)
            o_outputPort[`EAST]=1;
        else
            if (dest_x<local_x)
                o_outputPort[`WEST]=1;
            else 
               if (dest_y<local_y)
                   o_outputPort[`SOUTH]=1;
               else
                   begin  
                   if (dest_y>local_y)
                       o_outputPort[`NORTH]=1;
                   else
                       o_outputPort[`LOCAL]=1; 
                   end           
        end
    assign local_x = adress[`TAM_FLIT-1:`METADEFLIT];
    assign local_y = adress[`METADEFLIT-1:0];
    assign dest_x  = {6'd0, i_dest[15:14]};    // <-----------------------  Used to be: i_dest[`TAM_FLIT-1:`METADEFLIT];
    assign dest_y  = {6'd0, i_dest[13:12]};    // <-----------------------  Used to be: i_dest[`METADEFLIT-1:0];
    assign o_find  =`validRegion;   
endmodule
