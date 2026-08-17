module fir_testbench;

    logic signed [7:0] x0, x1, x2;
    logic signed [7:0] h0, h1, h2;

    logic signed [19:0] y;

    fir_accelerator dut (
        .x0(x0),
        .x1(x1),
        .x2(x2),
        .h0(h0),
        .h1(h1),
        .h2(h2),
        .y(y)
    );

    initial begin

        $dumpfile("fir_waveform.vcd");
        $dumpvars(0, fir_testbench);

        // Filter coefficients
        h0 = 1;
        h1 = 2;
        h2 = 1;

        // Test 1
        x0 = 2;
        x1 = 3;
        x2 = 4;

        #10;

        $display("Test 1: y = %d", y);

        if (y == 12)
            $display("TEST 1 PASSED");
        else
            $display("TEST 1 FAILED");


        // Test 2
        x0 = 1;
        x1 = 2;
        x2 = 3;

        #10;

        $display("Test 2: y = %d", y);

        if (y == 8)
            $display("TEST 2 PASSED");
        else
            $display("TEST 2 FAILED");


        // Test 3
        x0 = 5;
        x1 = 1;
        x2 = 2;

        #10;

        $display("Test 3: y = %d", y);

        if (y == 9)
            $display("TEST 3 PASSED");
        else
            $display("TEST 3 FAILED");


        // Test 4
        x0 = -2;
        x1 = 4;
        x2 = 1;

        #10;

        $display("Test 4: y = %d", y);

        if (y == 7)
            $display("TEST 4 PASSED");
        else
            $display("TEST 4 FAILED");


        $finish;

    end

endmodule