////////////////////////////////////////////////////////////////////////////////
// player_control.sv - Player Movement Controller
// Game: Space Invaders
// Course: EE 271
//
// Description:
//     Controls horizontal player movement using a 16-bit shift register.
//     The player position is represented as a single '1' bit in a 16-bit
//     word, with all other bits set to '0'. This creates a simple but
//     effective position encoding where the bit position indicates column.
//
// Position Encoding:
//     16'h0001 = Column 0 (leftmost)
//     16'h0002 = Column 1
//     16'h0004 = Column 2
//     ...
//     16'h8000 = Column 15 (rightmost)
//
// Movement Logic:
//     Left button:  Rotate bits right (player position moves right on screen)
//     Right button: Rotate bits left  (player position moves left on screen)
//
// Reset Behavior:
//     On reset, player initializes to column 0 (16'h0001)
//
// Note: The shift register implements rotation (not simple shift) so the
//       player wraps around when reaching screen edges.
////////////////////////////////////////////////////////////////////////////////
module player_control (
    input  logic         clk,
    input  logic         rst,
    input  logic         left,     // Active high: move player right (rotate left)
    input  logic         right,    // Active high: move player left (rotate right)
    output logic [15:0]  data_out  // Player position bit pattern
);

    // Internal 16-bit shift register holding player position
    logic [15:0] shift_reg;

    // State registers for edge detection (debounce-free button handling)
    logic left_prev, right_prev, left_edge, right_edge;

    // Drive output with current shift register value
    assign data_out = shift_reg;

    // Main control logic: edge detection and position updates
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset: Initialize player at leftmost column
            left_prev  <= 0;
            right_prev <= 0;
            shift_reg  <= 1;  // 16'h0001 = column 0
        end else begin
            // Detect rising edges (button press, not hold)
            // left_edge is high only during the first clock cycle of a left-button press
            left_edge  <= (left  && !left_prev);
            right_edge <= (right && !right_prev);

            // Store current button states for next cycle's edge detection
            left_prev  <= left;
            right_prev <= right;

            // Execute movement on rising edge of button press
            // Left button: rotate right (bits move right, player appears to move left)
            if (left_edge) begin
                shift_reg <= {shift_reg[14:0], shift_reg[15]};
            end 
            // Right button: rotate left (bits move left, player appears to move right)
            else if (right_edge) begin
                shift_reg <= {shift_reg[0], shift_reg[15:1]};
            end
        end
    end

endmodule


////////////////////////////////////////////////////////////////////////////////
// player_control_testbench - Verification testbench for player_control module
// Description:
//     Tests player movement by simulating left/right button presses and
//     verifying the shift register updates correctly.
// Note: This testbench has signal name mismatches with the actual module
//       interface (btn_left/btn_right vs left/right, shift_reg vs data_out).
//       A corrected version should be used for proper verification.
////////////////////////////////////////////////////////////////////////////////
module player_control_testbench();

    // Testbench signals
    logic clk;
    logic reset;
    logic btn_left;
    logic btn_right;
    logic [7:0] shift_reg;

    // Instantiate the DUT (Device Under Test)
    player_control dut (
        .clk(clk),
        .reset(reset),
        .left(btn_left),
        .right(btn_right),
        .data_out(shift_reg)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Test sequence: Press left twice, then right twice
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        btn_left = 0;
        btn_right = 0;

        // Wait and release reset
        #15;
        reset = 0;

        // Press left button twice (should rotate right twice)
        btn_left = 1; 
        #5;
        btn_left = 0;
        
        btn_left = 1; 
        #5;
        btn_left = 0;

        // Press right button twice (should rotate left twice)
        btn_right = 1; 
        #5;
        btn_right = 0;
        
        btn_right = 1; 
        #5;
        btn_right = 0;

        // Finish simulation
        #20;
        $finish;
    end
	
	
endmodule