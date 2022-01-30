`include"defines.vh"
module RoundRobinArbiter #(parameter size=`NPORT)
(
input [size-1:0] i_requests,
input i_enable,
output o_isOutputSelected,
output reg [$clog2(size)-1:0] o_selectedOutput 
 );

reg [$clog2(size)-1:0] lastport=0;
reg [$clog2(size)-1:0] selectedPort=0 ;
reg [$clog2(size)-1:0] requestCheck;
reg exit_aux;
integer i;
always@(posedge i_enable)
    begin 
    /* verilator lint_off BLKSEQ */
    requestCheck=lastport;
    selectedPort=lastport;
    exit_aux=1;
    for (i = 0; i < size; i = i +1) 
        begin
        if(exit_aux==1)
        begin
        if(requestCheck==size-1 )
            begin
            requestCheck=0;
            end
        else
            requestCheck=requestCheck+1;
            
        if(i_requests[requestCheck]==1 )
            begin
            selectedPort=requestCheck;
            exit_aux=0;//simula o quit do vhdl
            end
        end
        end     
    /* verilator lint_on BLKSEQ */
    lastport<=selectedPort;
    o_selectedOutput<=selectedPort;
    end
    
    assign o_isOutputSelected=i_enable;
endmodule
