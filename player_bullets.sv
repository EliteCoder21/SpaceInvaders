////////////////////////////////////////////////////////////////////////////////
// player_bullets.sv - Player Bullet Management Module
// Game: Space Invaders
// Course: EE 271
//
// Description:
//     Manages player bullet firing and vertical bullet movement.
//     Implements a 15-row deep bullet buffer where each row represents
//     a vertical position on the screen. Bullets start at the player's
//     location and move upward (toward lower row indices).
//
// Data Structure:
//     data_reg[row][col] - A '1' indicates a bullet at (row, column)
//     data_reg[14]       - Bottom row (nearest player, row index 14)
//     data_reg[0]        - Top row (farthest from player, row index 0)
//
// Clock Usage:
//     clk1 - Used for edge detection on fire button
//     clk2 - Used for bullet movement animation
//
// Behavior:
//     - Fire button press: Spawns a new bullet at player's column in row 14
//     - Each clock cycle: All bullets shift up one row (toward row 0)
//     - When bullets reach row 0, they are removed from the display
////////////////////////////////////////////////////////////////////////////////
module player_bullets (
    input  logic         clk1,          // Clock for fire button edge detection
    input  logic         clk2,          // Clock for bullet animation
    input  logic         rst,           // Reset signal
    input  logic         fire,          // Fire button (active high)
    input  logic [15:0]  player_loc,   // Player position from player_control
    output logic [15:0][15:0] data_out  // Bullet positions (15 rows x 16 cols)
);

    // Bullet storage: 15 rows x 16 columns
    // Each row represents a vertical position on the screen
    logic [14:0][15:0] data_reg;

    // Fire button state for edge detection
    logic fire_prev, fire_edge;

    // Drive output with current bullet positions
    assign data_out = data_reg;

    // Edge detection for fire button (on clk1)
    // fire_edge goes high only during the first cycle of a fire button press
    always_ff @(posedge clk1 or posedge rst) begin
        if (rst) begin
            fire_prev  <= 0;
        end else begin
            fire_edge <= fire && !fire_prev;  // Rising edge detection
            fire_prev  <= fire;                // Store current state for next cycle
        end
    end
     
    // Bullet animation logic (on clk2)
    // Handles both bullet spawning and upward movement
    always_ff @(posedge clk2) begin
        // On fire button press: spawn new bullet at player's position
        // OR with existing data_reg[14] allows multiple bullets to exist
        if (fire_edge) begin
            data_reg[14] = player_loc | data_reg[14];
        end else begin
            // Normal operation: shift all bullets up one row
            // Bullet at row N moves to row N-1 (closer to top of screen)
            // This creates the illusion of bullets traveling upward
            data_reg[0]  <= data_reg[1];
            data_reg[1]  <= data_reg[2];
            data_reg[2]  <= data_reg[3];
            data_reg[3]  <= data_reg[4];
            data_reg[4]  <= data_reg[5];
            data_reg[5]  <= data_reg[6];
            data_reg[6]  <= data_reg[7];
            data_reg[7]  <= data_reg[8];
            data_reg[8]  <= data_reg[9];
            data_reg[9]  <= data_reg[10];
            data_reg[10] <= data_reg[11];
            data_reg[11] <= data_reg[12];
            data_reg[12] <= data_reg[13];
            data_reg[13] <= data_reg[14];
            data_reg[14] <= 0;  // Clear bottom row (bullets leave from here)
        end                   
    end

endmodule