// TESTBENCH
module MUL_test;
    reg [15:0] data_in;
    reg clk, start;
    wire done;
    wire [15:0] product;

    // Instantiate top-level multiplier
    MUL_top DUT(clk, start, data_in, done, product);

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 10 time units = 1 clock period
    end

    // Stimulus
    initial begin
        data_in = 0;
        start = 0;
        #5 start = 1;             // start multiplication

        // Provide operands in sync with controller signals
        wait(DUT.CON.ldA); data_in = 16'd25;    // load A = 20
        @(posedge clk);
        wait(DUT.CON.ldB); data_in = 16'd4;     // load B = 5

        // Wait for done
        wait(done);
        $display("Final Product = %0d", product);
        #20 $finish;
    end

    // Waveform and monitor
    initial begin
        $dumpfile("mul.vcd");
        $dumpvars(0, MUL_test);
        $monitor($time, " Product=%d, done=%b", product, done);
    end
endmodule
