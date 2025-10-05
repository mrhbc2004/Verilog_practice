// TOP-LEVEL: Multiplier Datapath + Controller
module MUL_top(
    input clk, start,
    input [15:0] data_in,
    output done,
    output [15:0] product
);
    wire eqz, ldA, ldB, ldP, clrP, decB;

    // Datapath
    MUL_datapath DP(eqz, ldA, ldB, ldP, clrP, decB, data_in, clk, product);

    // Controller
    controller CON(ldA, ldB, ldP, clrP, decB, done, clk, eqz, start);
endmodule


// DATAPATH MODULE
module MUL_datapath(
    output eqz,
    input ldA, ldB, ldP, clrP, decB,
    input [15:0] data_in,
    input clk,
    output [15:0] product
);
    wire [15:0] X, Y, Z, Bout, Bus;

    assign Bus = data_in;
    assign product = Y;

    PIPO1 A(X, Bus, ldA, clk);
    PIPO2 P(Y, Z, ldP, clrP, clk);
    CNTR B(Bout, Bus, ldB, decB, clk);
    ADD AD(Z, X, Y);
    EQZ COMP(eqz, Bout);
endmodule


// PIPO1 Register (Register A)
module PIPO1(output reg [15:0] dout, input [15:0] din, input ld, clk);
    always @(posedge clk)
        if(ld) dout <= din;
endmodule


// ADDER
module ADD(output reg [15:0] out, input [15:0] in1, in2);
    always @(*) out = in1 + in2;
endmodule

// PIPO2 Register (Product Register)
module PIPO2(output reg [15:0] dout, input [15:0] din, input ld, clr, clk);
    always @(posedge clk) begin
        if(clr) dout <= 16'b0;
        else if(ld) dout <= din;
    end
endmodule


// ZERO DETECTOR
module EQZ(output eqz, input [15:0] data);
    assign eqz = (data == 16'd1);
endmodule


// COUNTER (Register B)
module CNTR(output reg [15:0] dout, input [15:0] din, input ld, dec, clk);
    always @(posedge clk) begin
        if(ld) dout <= din;
        else if(dec) dout <= dout - 1;
    end
endmodule


// CONTROLLER FSM
module controller(
    output reg ldA, ldB, ldP, clrP, decB, done,
    input clk, eqz, start
);
    reg [2:0] state;
    parameter S0=3'b000, S1=3'b001, S2=3'b010, S3=3'b011, S4=3'b100;

    initial begin
        state = S0;
        ldA=0; ldB=0; ldP=0; clrP=0; decB=0; done=0;
    end

    // State transitions
    always @(posedge clk) begin
        case(state)
            S0: if(start) state <= S1;
            S1: state <= S2;
            S2: state <= S3;
            S3:  begin if(eqz) state <= S4; else state<=S3; end
            S4: state <= S4;
            default: state <= S0;
        endcase
    end

    // Control signal generation
    always @(*) begin
        ldA=0; ldB=0; ldP=0; clrP=0; decB=0; done=0; // default
        case(state)
            S0: ;                                // idle
            S1: ldA=1;                           // load A
            S2: begin ldB=1; clrP=1; end         // load B, clear product
            S3: begin ldP=1; if(!eqz) decB=1; end         // accumulate, decrement B
            S4: done=1;                          // finish
        endcase
    end
endmodule
