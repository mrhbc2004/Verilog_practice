// Overlapping 1011 mealy sequence detector
module mealy1011(input in,clk,rst_n,output out);
    
    parameter A=2'b00, B=2'b01,C=2'b10,D=2'b11;
    reg out;
    reg [1:0] cnt_state,nxt_state;
    ///wire clk,rst;
    
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) cnt_state<=A;
      else cnt_state<=nxt_state;
    end
 
    always @(*) begin
    nxt_state=A;
    out=1'b0;
        case(cnt_state)
            A: begin 
                if(in) nxt_state=B;
                else nxt_state=A;
            end
            B: begin
                if(in) nxt_state=B;
                else nxt_state=C;
            end
            C: begin
                if(in) nxt_state=D;
                else nxt_state=A;
            end
            D: begin
                if(in) begin
                out=1'b1;
                nxt_state=B;
                end
                else nxt_state=C;
            end
        endcase
    end
endmodule
