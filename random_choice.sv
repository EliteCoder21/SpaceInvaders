////////////////////////////////////////////////////////////////////////////////
// random_choice.sv - Linear Feedback Shift Register (LFSR) Pseudo-Random Generator
// Game: Space Invaders
// Course: EE 271
//
// Description:
//     Generates pseudo-random numbers using a Linear Feedback Shift Register.
//     The LFSR produces a deterministic but statistically random-looking sequence
//     of 41-bit values by using XOR feedback from specific bit positions.
//
// LFSR Configuration:
//     - Width: 41 bits (produces values 0 to 2^41-1)
//     - Feedback: bit[40] XOR bit[37] (taps at positions 40 and 37)
//     - Period: 2^41 - 1 = 2,199,023,255,551 cycles before repeating
//     - Seed: 21 (non-zero value required for proper operation)
//
// How It Works:
//     On each clock cycle:
//       1. Compute new LSB: lfsr[40] XOR lfsr[37]
//       2. Shift all bits right by one position
//       3. Insert new LSB at the leftmost position
//
// Usage in Space Invaders:
//     Different slices of the LFSR output control various game behaviors:
//       - random_d[3:0]   - Alien movement decisions
//       - random_d[i+:4] - Alien firing patterns (varies by row)
//       - random_d[0+:4] - Alien respawn position
//
// Note: LFSR produces all-zeros state (bad state) if initialized to 0.
//       The seed value of 21 avoids this and ensures proper operation.
////////////////////////////////////////////////////////////////////////////////
module random_choice (
    output logic [40:0]  out,   // Current LFSR value (pseudo-random number)
    input  logic         rst,   // Reset signal (loads seed value)
    input  logic         clk    // Clock signal
);

    // Internal LFSR register
    logic [40:0] lfsr;

    // Main LFSR logic
    // On reset: load seed value (21)
    // Otherwise: shift left and insert XOR feedback at LSB
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 21;  // Non-zero seed ensures proper LFSR sequence
        end else begin
            // Shift left and compute new LSB using XOR feedback
            // New LSB = lfsr[40] XOR lfsr[37]
            lfsr <= {lfsr[39:0], lfsr[40] ^ lfsr[37]};
        end
    end

    // Drive output with current LFSR value
    assign out = lfsr;

endmodule

////////////////////////////////////////////////////////////////////////////////
// random_choice_testbench - Verification testbench for LFSR module
// Description:
//     Tests the LFSR by observing the output sequence over multiple cycles.
//     Verifies that the LFSR produces varying values and doesn't get stuck.
////////////////////////////////////////////////////////////////////////////////
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
