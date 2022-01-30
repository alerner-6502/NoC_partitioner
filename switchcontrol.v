`include"defines.vh"
module switchcontrol #(parameter address=`TAM_FLIT)
    ( input i_clk,
      input i_rst,
      input  [`NPORT-1:0] i_h,
      output reg [`NPORT-1:0] o_ack_h,
      input [`NP_REGF-1:0] i_data,
      input [`NPORT-1:0] i_sender, 
      output  [`NPORT-1:0] o_free,
      output reg [`NP_REG3-1:0] o_mux_in,
      output reg  [`NP_REG3-1:0] o_mux_out      
    );

    integer aux_var;
    reg [`reg3-1:0]mux_in_a[`NPORT-1:0];
    reg [`reg3-1:0]mux_out_a[`NPORT-1:0];
    reg [`TAM_FLIT-1:0]data[`NPORT-1:0];
    reg [$clog2(`STATE)-1:0] ES,PES;
    reg ask=0;
    reg enable;
    reg [$clog2(`NPORT)-1:0] sel=0;
    reg [`reg3-1:0] incoming=0;
    reg [`TAM_FLIT-1:0] header=0;    
    reg [$clog2(`NPORT)-1:0] indice_dir=0;
    reg [`NPORT-1:0] auxfree;
    reg [`reg3 -1:0] source [`NPORT-1:0];
    reg [`NPORT-1:0] sender_ant;
    wire [`NPORT-1:0] dir;
    wire [`NPORT-1:0] requests;
    wire [$clog2(`NPORT)-1:0] prox;
    wire [$clog2(`NPORT)-1:0]selectedOutput;
    wire [`ROUTERCONTROL-1:0] find;
    wire isOutputSelected, ready;
    integer i;

    RoundRobinArbiter rr1(.i_requests(i_h),.i_enable(enable),.o_selectedOutput(prox),.o_isOutputSelected(ready));
    routingMechanism #(address)rm1(.i_dest(header),.o_outputPort(dir),.o_find(find));
    FixedPriorityArbiter fp1(.i_requests(requests),.i_enable(1'b1),.o_isOutputSelected(isOutputSelected),.o_selectedOutput(selectedOutput)); 

    always@(*)begin
        for(i=0;i<`NPORT;i=i+1)
            mux_in_a[i]=source[i];

        for(aux_var=0;aux_var<`NPORT;aux_var=aux_var+1)begin
            data[aux_var]=i_data[aux_var*`TAM_FLIT+:`TAM_FLIT];
            o_mux_in[aux_var*`reg3+:`reg3]=mux_in_a[aux_var];
            o_mux_out[aux_var*`reg3+:`reg3]=mux_out_a[aux_var];
        end

        ask =(|i_h)? 1:0;
        incoming=sel;
        header=data[incoming];
              
    end
        
    always@(*)  // <------------------------------------(ES, ask, find, isOutputSelected) 
        begin
            case(ES)              
                `S0: PES=`S1;
                `S1: 
                    begin
                    if (ask==1)
                        begin
                        PES=`S2;
                        end                          
                    else
                        PES=`S1;                     
                     end
               `S2: PES=`S3;
               `S3: 
                    begin
                    if (find==`validRegion)
                        begin
                        if(isOutputSelected==1)
                            PES=`S4;
                        else
                            PES=`S1;                                    
                        end
                    else
                        if (find==`portError)
                            PES=`S1;   
                        else 
                            PES = `S3;                  
                    end
               `S4: PES=`S5;                       
               `S5: PES=`S1;  
               default:PES=`S0;

            endcase 
        end
    always@(posedge i_clk)
        begin
        if (!i_rst)
            ES<=`S0;
        else
            begin
            ES<=PES;   
            case(ES)
                //zera vari�veis
                `S0:begin
                    //ceTable<=0;
                    sel<=0;
                    o_ack_h<=0;
                    sender_ant<=0;
                    for(i=0;i<`NPORT;i=i+1)
                        begin
                        auxfree[i]<=1;
                        mux_out_a[i]<=0;
                        source[i]<=0;
                        end
                    end
                //chega um header   
                `S1:begin
                    enable<=ask;
                    //ceTable<=0;
                    o_ack_h<=0;
                    end
                // Seleciona quem tera direito a requisitar roteamento    
                `S2:begin
                    sel <= prox;
                    enable <= ~ready;                       
                    end
                //Aguarda resposta da Tabela
                `S3:begin
                    if(find == `validRegion & isOutputSelected ==1)
                        indice_dir <= selectedOutput;
                    //else
                        //ceTable=1;
                    end
                `S4:begin
                    source[incoming] <= indice_dir;
                    mux_out_a[indice_dir] <= incoming;
                    auxfree[indice_dir] <= 0;
                    o_ack_h[sel] <= 1;
                    end
                default:begin
                    o_ack_h[sel] <= 0;
                    //ceTable <= '0';
                    end        
            endcase
            
            for(i=`EAST;i<=`LOCAL;i=i+1)
                if (i_sender[i] == 0 & sender_ant[i] == 1)
                    begin
                    auxfree[source[i]] <= 1;
                    //auxfree[i] <= 1;
                    end

            sender_ant <= i_sender;
           end

        end
   
    assign o_free=auxfree;
    assign requests=auxfree & dir;
    


    endmodule
