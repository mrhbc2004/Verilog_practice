// Overlappnig 1011 sequence detection
module moore1011(input in,clk,rst_n,output out);
    //Parameters for states
    parameter A=3'b000, B=3'b001,C=3'b010,D=3'b011,E=3'b100;
    reg out;
    reg [2:0]cnt_state,nxt_state;

    //resetting logic
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) cnt_state<=A;
      else cnt_state<=nxt_state;
    end

    //next state logic
    always @(*) begin
        nxt_state=A;
        out=1'b0;
        case(cnt_state)
            A: begin // For code readability i have used if and else statements
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
              if(in) nxt_state=E;
              else nxt_state=C;
            end
            E: begin
                // out=1'b1;  This line will be useful if designing a mealy machine
                if(in) nxt_state=B;
                else nxt_state=C;
            end
        endcase
    end
    always @(*) out= (cnt_state==E);
endmodule
