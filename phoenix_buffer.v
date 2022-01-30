`include "defines.vh"
module phoenix_buffer #(parameter DEPTH=`TAM_BUFFER)(
input i_clk, i_rst,i_rx, i_clk_rx,i_ack_h,i_data_ack,
input [`TAM_FLIT-1:0] i_data,
output o_credit,o_h,o_data_av,o_sender,
output [`TAM_FLIT-1:0] o_data);


localparam REQ_ROUTING=0;
localparam SEND_DATA=1;

wire pull, has_data,has_data_and_sending;
wire [`TAM_FLIT-1:0] bufferhead;
wire [$clog2(DEPTH):0]counter;
reg [`TAM_FLIT-1:0] counter_flit;
reg sending,sent;
reg next_state, current_state;
integer flit_index;

fifo_buffer CBUF(
.i_rst(i_rst),
.i_clk(i_clk_rx),
.i_tail(i_data),
.i_push(i_rx),
.i_pull(pull),
.o_counter(counter),
.o_head(bufferhead)
);

always@(*)
begin
    next_state=current_state;
    case(current_state)
    REQ_ROUTING:
        if (i_ack_h)
            next_state=SEND_DATA;
    SEND_DATA:
        if (pull)
            next_state=REQ_ROUTING;       
    endcase
end

always@(posedge i_clk)
    begin
    if (!i_rst)
        begin
        current_state<= REQ_ROUTING;
        sent<=0;
        end
    else
        begin
        current_state<= next_state;
        if(sending)
            begin
            if (i_data_ack & has_data)
                begin
                sent<=0;
                if (flit_index==1)
                    counter_flit<=bufferhead;
                else 
                    begin
                    if(counter_flit!=1)
                        counter_flit<=counter_flit-1;
                    else//se counter_flit=1
                        sent<=1;
                    end                           
                flit_index<=flit_index+1;
                end
            end
        else
            begin
            flit_index<=0;
            counter_flit<=0;
            sent<=0;
            end
        end
    end
    
always@(*)
begin
    case (current_state)
        SEND_DATA:
            sending= 1; //!sent;
        default:
            sending=0;
    endcase
end

assign o_data= bufferhead;
assign o_data_av= has_data_and_sending;
assign o_credit=(counter!=DEPTH)?1:0;         // <------------------- OR removed
assign o_sender=sending;
assign o_h=has_data &(!sending);
assign pull= i_data_ack &has_data_and_sending;
assign has_data= (counter!=0)?1:0;
assign has_data_and_sending= has_data & sending;

endmodule