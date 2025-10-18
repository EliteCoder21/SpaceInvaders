module draw_enemies (
    input  logic         clk,
    input  logic         rst,
    input logic [15:0][15:0]  alienBullets,
    input logic [5:0][15:0]  aliens,
	 input logic [15:0][15:0]  playerBullets,
    input logic [15:0]  player,
	 output logic [15:0][15:0]  red_out,
	 output logic [15:0][15:0]  grn_out
);

	 // Counter
	 logic [3:0] i;	 
	 
    // Output assignment
    assign red_out = aliens | alienBullets;
	 assign grn_out[14:0] = alienBullets[14:0] | playerBullets[14:0];
	 assign grn_out[15] = alienBullets[15] | player;

endmodule