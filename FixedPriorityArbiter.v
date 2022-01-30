`include"defines.vh"
module FixedPriorityArbiter #(parameter size=`NPORT)
(
input [size-1:0] i_requests,
input i_enable,
output reg o_isOutputSelected,
output reg [$clog2(size)-1:0] o_selectedOutput 
 );
    
reg auxDone,exit_aux;
reg [$clog2(size)-1:0]auxSelect =0;
integer i;
    always@(*) begin // <----------------------------------- (i_requests,i_enable)
        
        auxDone=0;
        auxSelect =0;
		exit_aux = 0;
		i = 0;
        if(i_enable==1) begin  
            exit_aux=0;              
            for (i = 0; i < size; i = i +1)  begin
                if(i_requests[i]==1 & exit_aux==0) begin
                    /* verilator lint_off WIDTH */
                    auxSelect=i;
                    /* verilator lint_on WIDTH */
                    auxDone=1;
                    exit_aux=1;
                end
            end            
        end
                          
        o_isOutputSelected= auxDone;
        o_selectedOutput= auxSelect;  

    end
     
endmodule
