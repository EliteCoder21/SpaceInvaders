////////////////////////////////////////////////////////////////////////////////
// DE1_SoC.sv - Top-Level Module for Space Invaders FPGA Implementation
// Target Board: DE1-SoC (Cyclone V)
// Course: EE 271
//
// Description:
//     This is the top-level module that integrates all game subsystems. It
//     defines the hardware I/O interface and instantiates the following modules:
//       - clock_divider: Generates divided clocks from the 50MHz system clock
//       - LEDDriver: Drives the 16x16 bi-color LED matrix display
//       - player_control: Handles player movement (left/right)
//       - player_bullets: Manages player bullet firing and movement
//       - aliens: Controls alien enemy movement and firing
//       - random_choice: LFSR-based pseudo-random number generator
//       - draw_enemies: Composites all game elements into pixel buffers
//       - binary_score_to_decimal_7seg: Converts score to 7-segment display
//
// Hardware I/O Mapping (see DE1_SoC.qsf for pin assignments):
//       CLOCK_50  - 50 MHz system clock
//       KEY[0]    - Player move right
//       KEY[1]    - Fire bullet
//       KEY[2]    - Player move left
//       KEY[3]    - Reset (active low)
//       HEX0-2    - Score display (7-segment, active low)
//       GPIO_1    - 16x16 bi-color LED matrix expansion header
////////////////////////////////////////////////////////////////////////////////
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1;
    input logic CLOCK_50;

    // Turn off unused HEX displays (active low, so '1' turns them off)
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
    
    
    // Clock generation: Produces multiple divided clock frequencies from 50MHz
    // clk[14] is used for LED matrix scanning (50MHz / 2^15 ≈ 1526 Hz)
    // =======================================================================
    logic [31:0] clk;
    
    clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));
         
    // Note: If LED board flickers, try using a faster clock (lower bit of clk).
    // However, faster scanning may reduce LED brightness.
    
    
    // Game state signals and pixel buffers
    // ======================================================================
    // Internal wires for connecting subsystems
    logic [11:0] score;                              // Player's current score
    logic [15:0][15:0] RedPixels;                    // Red pixel buffer for LED matrix
    logic [15:0][15:0] GrnPixels;                    // Green pixel buffer for LED matrix
    logic [15:0][15:0] alienBullets;                // Alien bullet positions
    logic [15:0][15:0] playerBullets;               // Player bullet positions
    logic [5:0][15:0] aliens;                        // Alien positions (6 rows)
    logic [15:0] player;                            // Player position (16-bit shift register)
    logic [40:0] random_d;                          // Random values from LFSR
    logic RST, temp;                                // Reset signal (active high)
    
    // Convert KEY[3] from active-low to active-high reset signal
    assign RST = ~KEY[3];
         
    // LED matrix driver - handles row scanning and GPIO output to 16x16 display
    // Uses clk[14] (~1526 Hz) for row scanning to avoid flicker
    LEDDriver Driver (.GPIO_1, .RedPixels, .GrnPixels, .EnableCount(1'b1), .CLK(clk[14]), .RST);
	 
    
    // Game subsystem instantiations
    // Each module handles a specific aspect of game logic
    // ===================================================================
    
    // Player bullets module: Handles bullet firing and upward movement
    // Uses two clocks - clk1 for edge detection, clk2 for bullet animation
    player_bullets pb (.clk1(CLOCK_50), .clk2(CLOCK_50), .rst(RST), .fire(~KEY[1]), .player_loc(player), .data_out(playerBullets));
    
    // Player control module: Handles horizontal player movement via shift register
    // Left/Right buttons shift the player's position bit pattern
    player_control p (.clk(CLOCK_50), .rst(RST), .left(~KEY[2]), .right(~KEY[0]), .data_out(player));
    
    // Random number generator: 41-bit LFSR for pseudo-random alien behavior
    // Provides unpredictable movement and firing patterns
    random_choice rando (.out(random_d), .rst(RST), .clk(CLOCK_50));
    
    // Aliens module: Controls alien movement, respawning, and firing
    // Also handles collision detection (bullets hitting aliens) and scoring
    aliens a (.clk1(CLOCK_50), .clk2(CLOCK_50), .rst(RST), .random_d, .aliens, .alienBullets, .playerBullets, .player, .points(score));
    
    // Draw module: Composites all game elements into pixel buffers
    // Combines aliens, alien bullets, player bullets, and player into LED arrays
    draw_enemies drawer (.clk(CLOCK_50), .rst(RST), .alienBullets, .aliens, .playerBullets, .player, .red_out(RedPixels), .grn_out(GrnPixels));
    
    // Score display: Converts binary score to 7-segment format
    // Displays on HEX0-2 (ones, tens, hundreds digits)
    binary_score_to_decimal_7seg display_score (.RST, .score, .seg2(HEX2), .seg1(HEX1), .seg0(HEX0));
    
endmodule

////////////////////////////////////////////////////////////////////////////////
// DE1_SoC_testbench - Verification testbench for the top-level module
// Description:
//     Functional simulation that tests basic game interactions including
//     player movement, firing, and score tracking.
// Usage: Compile with ModelSim-Altera and run simulation
////////////////////////////////////////////////////////////////////////////////
module DE1_SoC_testbench();
    // Testbench signals - mirror the top-level I/O
    logic CLOCK_50;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;

    DE1_SoC dut (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);

    // Clock generation: 100ns period (10 MHz) for simulation
    parameter CLOCK_PERIOD = 100;

    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    // Test sequence:
    // 1. Initial reset
    // 2. Wait period with no input
    // 3. Reset again
    // 4. Rapid button presses (left, fire, right, fire) to simulate gameplay
    // 5. Observe score changes
    initial begin
        // Initial system reset
        repeat(1) @(posedge CLOCK_50);
        KEY[3] <= 0; repeat(10) @(posedge CLOCK_50);  // Assert reset (active low on KEY[3])
        KEY[3] <= 1; repeat(10) @(posedge CLOCK_50);  // Release reset
        repeat(1) @(posedge CLOCK_50);
        
        // Wait period for initial state observation
        repeat(500) @(posedge CLOCK_50);
        
        // Reset before gameplay test
        repeat(1) @(posedge CLOCK_50);
        KEY[3] <= 0; repeat(10) @(posedge CLOCK_50);
        KEY[3] <= 1; repeat(10) @(posedge CLOCK_50);
        repeat(1) @(posedge CLOCK_50);
        
        // Simulate gameplay: rapid left/right movement with firing
        for (int i = 0; i < 500; i++) begin
            // Move left (KEY[2] active low)
            KEY[2] <= 0; repeat(10) @(posedge CLOCK_50);
            KEY[2] <= 1; repeat(10) @(posedge CLOCK_50);
            
            // Fire bullet (KEY[1] active low)
            KEY[1] <= 0; repeat(10) @(posedge CLOCK_50);
            KEY[1] <= 1; repeat(10) @(posedge CLOCK_50);
            
            // Move right (KEY[0] active low)
            KEY[0] <= 0; repeat(10) @(posedge CLOCK_50);
            KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
            
            // Fire bullet
            KEY[1] <= 0; repeat(10) @(posedge CLOCK_50);
            KEY[1] <= 1; repeat(10) @(posedge CLOCK_50);
        end
        
        // Observe score changes after gameplay
        repeat(500) @(posedge CLOCK_50);
        
        $stop;
    end
endmodule


