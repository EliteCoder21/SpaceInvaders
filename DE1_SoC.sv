// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1;
    input logic CLOCK_50;

	 // Turn off HEX displays
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
	 
	 
	 /* Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
	    ===========================================================*/
	 logic [31:0] clk;
	 
	 clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));
	 	 
	 /* If you notice flickering, set SYSTEM_CLOCK faster.
	    However, this may reduce the brightness of the LED board. */
	
	 
	 /* Set up LED board driver
	    ================================================================== */
	 logic [11:0] score;
	 logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
    logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	 logic [15:0][15:0] alienBullets;
	 logic [15:0][15:0] playerBullets;
	 logic [5:0][15:0] aliens;
	 logic [15:0] player;
	 logic [40:0] random_d;
	 logic RST, temp;                   // reset - toggle this on startup
	 
	 assign RST = ~KEY[3];
	 	 
	 /* Standard LED Driver instantiation - set once and 'forget it'. 
	    See LEDDriver.sv for more info. Do not modify unless you know what you are doing! */
	 LEDDriver Driver (.GPIO_1, .RedPixels, .GrnPixels, .EnableCount(1'b1), .CLK(clk[14]), .RST);
	 
	 //GPIO_1, RedPixels, GrnPixels, EnableCount, CLK, RST
	 
	 
	 /* LED board test submodule - paints the board with a static pattern.
	    Replace with your own code driving RedPixels and GrnPixels.
		 
	 	 KEY0      : Reset
		 =================================================================== */
		 
	 player_bullets pb (.clk1(CLOCK_50), .clk2(CLOCK_50), .rst(RST), .fire(~KEY[1]), .player_loc(player), .data_out(playerBullets));
	 player_control p (.clk(CLOCK_50), .rst(RST), .left(~KEY[2]), .right(~KEY[0]), .data_out(player));
	 
	 random_choice rando (.out(random_d), .rst(RST), .clk(CLOCK_50));
	 
	 aliens a (.clk1(CLOCK_50), .clk2(CLOCK_50), .rst(RST), .random_d, .aliens, .alienBullets, .playerBullets, .player, .points(score));
	 
	 draw_enemies drawer (.clk(CLOCK_50), .rst(RST), .alienBullets, .aliens, .playerBullets, .player, .red_out(RedPixels), .grn_out(GrnPixels));
	 
	 binary_score_to_decimal_7seg display_score (.RST, .score, .seg2(HEX2), .seg1(HEX1), .seg0(HEX0));
	 
endmodule

module DE1_SoC_testbench();
    logic CLOCK_50;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;

    DE1_SoC dut (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);

    // Set up a simulated clock.
    parameter CLOCK_PERIOD = 100;

    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    // Test the design.
    initial begin
			 
			 // No Result
			 
			 // Reset
			 repeat(1) @(posedge CLOCK_50);
			 KEY[3] <= 0; repeat(10) @(posedge CLOCK_50);
			 KEY[3] <= 1; repeat(10) @(posedge CLOCK_50);
			 repeat(1) @(posedge CLOCK_50);
			 
			 repeat(500) @(posedge CLOCK_50);
			 
			 // Get points after constant shots and movement
			 
			 // Reset
			 repeat(1) @(posedge CLOCK_50);
			 KEY[3] <= 0; repeat(10) @(posedge CLOCK_50);
			 KEY[3] <= 1; repeat(10) @(posedge CLOCK_50);
			 repeat(1) @(posedge CLOCK_50);
			 
			 // Constant shoot and move back and forth
			 for (int i = 0; i < 500; i++) begin
			 
				// Left
			 
				KEY[2] <= 0; repeat(10) @(posedge CLOCK_50);
				KEY[2] <= 1; repeat(10) @(posedge CLOCK_50);
				
				// Shoot
				KEY[1] <= 0; repeat(10) @(posedge CLOCK_50);
				KEY[1] <= 1; repeat(10) @(posedge CLOCK_50);
				
				// Right
				KEY[0] <= 0; repeat(10) @(posedge CLOCK_50);
				KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
				
				// Shoot
				KEY[1] <= 0; repeat(10) @(posedge CLOCK_50);
				KEY[1] <= 1; repeat(10) @(posedge CLOCK_50);
				
          end
			 
			 // Watch points go down
			 repeat(500) @(posedge CLOCK_50);
			 
        $stop;
    end
endmodule


