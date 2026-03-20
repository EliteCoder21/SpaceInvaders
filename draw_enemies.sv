////////////////////////////////////////////////////////////////////////////////
// draw_enemies.sv - Game Graphics Compositor
// Game: Space Invaders
// Course: EE 271
//
// Description:
//     Composites all game elements into pixel buffers for the LED matrix.
//     Combines aliens, alien bullets, player bullets, and player position
//     into separate red and green color channels.
//
// Color Mapping:
//     Red channel (red_out):
//       - Aliens (red color)
//       - Alien bullets (red/orange color - shared red channel)
//
//     Green channel (grn_out):
//       - Alien bullets (orange = red+green)
//       - Player bullets (green color)
//       - Player (green color)
//
// LED Color Combinations:
//     Red pixel only     = Red   (alien)
//     Green pixel only   = Green (player, player bullet)
//     Both red+green     = Orange (alien bullet)
//
// Note: This module uses pure combinational logic (no clock needed) since
//       it simply OR's together the various pixel sources.
////////////////////////////////////////////////////////////////////////////////
module draw_enemies (
    input  logic         clk,                    // Clock (not used in this implementation)
    input  logic         rst,                    // Reset (not used in this implementation)
    input  logic [15:0][15:0]  alienBullets,     // Alien bullet positions
    input  logic [5:0][15:0]  aliens,             // Alien positions (6 rows)
    input  logic [15:0][15:0]  playerBullets,    // Player bullet positions
    input  logic [15:0]  player,                  // Player position
    output logic [15:0][15:0]  red_out,          // Red pixel buffer for LED matrix
    output logic [15:0][15:0]  grn_out           // Green pixel buffer for LED matrix
);

    // Pixel composition logic (purely combinational)
    // OR operation combines multiple sources into single pixel buffer
    
    // Red channel: Aliens + Alien bullets
    // aliens has 6 rows, padded to 16 by treating missing rows as 0
    assign red_out = aliens | alienBullets;
    
    // Green channel: Alien bullets (orange) + Player bullets + Player
    // Alien bullets and player bullets in rows 0-14
    assign grn_out[14:0] = alienBullets[14:0] | playerBullets[14:0];
    
    // Player occupies row 15 (bottom of screen)
    // Player bullets also rendered in row 15 via playerBullets[15]
    assign grn_out[15] = alienBullets[15] | player;

endmodule