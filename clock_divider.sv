////////////////////////////////////////////////////////////////////////////////
// clock_divider.sv - Multi-Frequency Clock Generator
// Target Board: DE1-SoC (any FPGA with 50MHz clock)
// Course: EE 271
//
// Description:
//     Generates multiple divided clock signals from a source clock.
//     Each bit of the output represents a successively divided version
//     of the input clock, creating a binary-weighted frequency hierarchy.
//
// Output Clock Frequencies (assuming 50MHz input):
//     divided_clocks[0]  = 50 MHz / 2     = 25.0 MHz
//     divided_clocks[1]  = 50 MHz / 4     = 12.5 MHz
//     divided_clocks[2]  = 50 MHz / 8     = 6.25 MHz
//     ...
//     divided_clocks[14] = 50 MHz / 32768 ≈ 1526 Hz
//     ...
//     divided_clocks[31] = 50 MHz / 4294967296 ≈ 0.0116 Hz
//
// Usage Example:
//     // Use clk[14] for LED matrix scanning (~1526 Hz)
//     LEDDriver Driver(..., .CLK(clk[14]), ...);
//
//     // Use clk[20] for slower animations (~48 Hz)
//     animation_clk = clk[20];
////////////////////////////////////////////////////////////////////////////////
module clock_divider (clock, reset, divided_clocks);
    input logic reset, clock;
    output logic [31:0] divided_clocks = 0;
    
    // Simple binary counter that increments on each clock rising edge.
    // Each bit of the counter toggles at half the frequency of the bit to its right,
    // effectively creating multiple clock divisions from a single counter.
    always_ff @(posedge clock) begin
        divided_clocks <= divided_clocks + 1;
    end
    
endmodule