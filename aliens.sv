////////////////////////////////////////////////////////////////////////////////
// aliens.sv - Alien Enemy Controller
// Game: Space Invaders
// Course: EE 271
//
// Description:
//     Controls all alien-related game mechanics:
//       - Alien movement (horizontal, pseudo-random based on LFSR)
//       - Alien bullet firing and movement (downward)
//       - Collision detection with player bullets (aliens die)
//       - Alien respawning logic
//       - Score tracking (+1 for kill, -1 for player hit)
//
// Data Structures:
//     aliens[row][col]       - 6 rows x 16 columns (one-hot per column)
//     alienBullets[row][col] - 16 rows x 16 columns
//
// Random Behavior (LFSR-driven):
//     Uses bits from random_d[40:0] to determine:
//       - When aliens move left or right
//       - When aliens fire bullets
//       - Alien respawn positions
//
// Clock Usage:
//     clk1 - Alien movement, respawning, collision detection
//     clk2 - Alien bullet animation (downward movement)
////////////////////////////////////////////////////////////////////////////////
module aliens (
    input  logic         clk1,                  // Clock for alien movement logic
    input  logic         clk2,                  // Clock for bullet animation
    input  logic         rst,                   // Reset signal
    input  logic [40:0]  random_d,             // Random values from LFSR
    output logic [5:0][15:0]  aliens,           // Alien positions (6 rows)
    output logic [15:0][15:0]  alienBullets,   // Alien bullet positions
    input  logic [15:0][15:0]  playerBullets, // Player bullet positions (for collision)
    input  logic [15:0]  player,                // Player position (for collision)
    output logic [11:0]  points                 // Player score
);

    // Alien position storage (11 rows of 16 bits each - extra rows for flexibility)
    logic [10:0][15:0] data_reg;
    
    // Alien bullet position storage (16 rows x 16 columns)
    logic [15:0][15:0] alienBulletReg;
    logic [3:0] i;

    // Drive outputs with current state
    assign aliens = data_reg;
    assign alienBullets = alienBulletReg;
    
    // Alien bullet animation (moves bullets downward on clk2)
    // Bullets shift toward higher row indices (toward player at bottom)
    always_ff @(posedge clk2) begin
        for (i = 0; i < 15; i = i + 1) begin
            // Random condition determines if new bullet spawns at this row
            // If condition met: spawn bullet at alien's column position
            if (random_d[i+:4] < i + 3 && random_d[i+:4] > i && i < 11) begin
                // Spawn new alien bullet at this row
                alienBulletReg[i+1] <= alienBulletReg[i] | data_reg[i];
            end else begin
                // Normal movement: shift bullets down, clear bullets hit by player
                alienBulletReg[i+1] <= alienBulletReg[i] & ~playerBullets[i];
            end
            
            // Always clear bottom row (bullets that reached player)
            alienBulletReg[0] <= 0;
        end
    end

    // Alien movement and collision logic (on clk1)
    always_ff @(posedge clk1 or posedge rst) begin
        if (rst) begin
            // Reset: Initialize aliens in leftmost column
            data_reg <= 1;
            points <= 0;
        end else begin
            // Process each of the 5 alien rows
            for (i = 0; i < 5; i = i + 1) begin
                // Random horizontal movement using LFSR bits
                // Use different bit slices for each alien row
                if (random_d[i+:4] > 8) begin
                    // Rotate right (alien appears to move right on screen)
                    data_reg[i] <= {data_reg[i][14:0], data_reg[i][15]};
                end else if (random_d[i+:4] < 4) begin
                    // Rotate left (alien appears to move left on screen)
                    data_reg[i] <= {data_reg[i][0], data_reg[i][15:1]};
                end
                
                // Respawn logic: When an alien is killed (data_reg[i] == 0)
                // and a specific random condition is met, respawn at random column
                if (data_reg[i] == 0 && random_d[0+:4] == 0) begin
                    data_reg[i][random_d[0+:4]] <= 1;
                end
                
                // Collision detection: Player bullet hits alien
                // Check if any player bullet overlaps with alien position at this row
                if ((data_reg[i] & playerBullets[i]) != 0) begin
                    data_reg[i] <= 0;       // Kill alien
                    points <= points + 1;   // Increment score
                end
                // Collision detection: Alien bullet hits player
                else if ((player & alienBulletReg[15]) > 0 && points > 0) begin
                    points <= points - 1;    // Decrement score (player hit)
                end
            end
        end
    end

endmodule