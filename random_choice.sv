module random_choice (
	output logic [40:0]  out,
	input  logic         rst,
	input  logic         clk 
);

    logic [40:0] lfsr;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 21; // Reset to non-zero seed
        end else begin
            lfsr <= {lfsr[39:0], lfsr[40] ^ lfsr[37]};
        end
    end

    assign out = lfsr;

endmodule

module random_choice_testbench;

    // DUT signals
    logic clk;
    logic rst;
    logic [40:0] out;

    // Instantiate the LFSR
    random_choice dut (
        .out(out),
        .rst(rst),
        .clk(clk)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $display("Starting LFSR Testbench...");

        // Reset LFSR
        rst = 1;
        #10; // wait one clock
        rst = 0;

        // Let it run for a while
        for (int i = 0; i < 100; i++) begin
            @(posedge clk);
            $display("Cycle %0d: LFSR = %041b", i, out);
        end

        $display("Finished.");
        $finish;
    end

endmodule
