module game_driver(all_clk, RST, left_btn, right_btn, fire, RedPixels, GrnPixels);
    input logic               RST, left_btn, right_btn, fire;
	 input logic [31:0] all_clk;
    output logic [15:0][15:0] RedPixels; // 16x16 array of red LEDs
    output logic [15:0][15:0] GrnPixels; // 16x16 array of green LEDs

endmodule


module LED_test_testbench();

	logic RST;
	logic [15:0][15:0] RedPixels, GrnPixels;
	
endmodule