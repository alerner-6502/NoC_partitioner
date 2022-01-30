`include "defines.vh"
module fifo_buffer #(parameter WIDTH=`TAM_FLIT, DEPTH=`TAM_BUFFER)(
input i_clk, i_rst,i_push,i_pull,
input [WIDTH-1:0]i_tail,
output [WIDTH-1:0] o_head,
output reg [$clog2(DEPTH):0]o_counter
);
reg [WIDTH-1:0] buff [DEPTH-1:0];
reg [$clog2(DEPTH)-1:0] first;
reg [$clog2(DEPTH)-1:0] last ;
reg [($clog2(DEPTH))-1:0] aux_first;
reg [($clog2(DEPTH))-1:0] aux_last ;
reg is_full,aux_is_full,is_empty;

integer i;
initial begin
	for(i=0; i<DEPTH; i=i+1) begin
		buff[i] = 0;
	end
end

always@(posedge i_clk)
begin
if(!i_rst)
    begin
    last<=0;
    first<=0;
    is_full<=0;
    is_empty<=1;
    end
else
    begin
    /* verilator lint_off BLKSEQ */
    aux_is_full=is_full;
    aux_last=last;
    aux_first=first;
    if((!is_empty)&i_pull)
        begin
        aux_first=(aux_first== DEPTH-1)?0:(aux_first+1);
        aux_is_full=0;
        is_empty<=(aux_first==aux_last)?1:0;
        end
    if((!aux_is_full)&i_push)
        begin
        buff[aux_last]<=i_tail;
        aux_last=(aux_last== DEPTH-1)?0:(aux_last+1);
        is_empty<=0;
        aux_is_full=(aux_first==aux_last)?1:0;
        end
    is_full<=aux_is_full;
    last<=aux_last;
    first<=aux_first;
    /* verilator lint_on BLKSEQ */
    end      
end

always@(*)
    o_counter=is_full?DEPTH:(last>=first?(last-first):(DEPTH-(first-last)));

assign o_head=buff[first];

endmodule