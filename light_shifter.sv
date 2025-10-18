module light_shifter (
    input  logic clk,
    input  logic reset,
    input  logic left_btn,
    input  logic right_btn,
    output logic [9:1] leds,
	 output logic [1:0] winner
);

    // LED register - now 9 bits
    logic [9:1] led_reg;

    // Edge detection
    logic left_prev, right_prev;
    logic left_rising, right_rising;

    // --- Edge Detection ---
    always_ff @(posedge clk) begin
        if (reset) begin
            left_prev  <= 1'b1;
            right_prev <= 1'b1;
        end else begin
            left_prev  <= left_btn;
            right_prev <= right_btn;
        end
    end

    assign left_rising  = ~left_btn  & left_prev;
    assign right_rising = ~right_btn & right_prev;

    // --- Shift Logic ---
    always_ff @(posedge clk) begin
        if (reset) begin
            led_reg <= 9'b000010000;  // Start with bit 0 ON
				winner <= 2'b00;
        end else begin
		  		  
            if (left_rising && ~right_rising) begin
				
						if (led_reg[9]) begin
							winner <= 2'b10;
						end
						
				
                led_reg <= led_reg << 1;   // Shift left
					 
            end else if (right_rising & ~left_rising) begin
                
						if (led_reg[1]) begin
							winner <= 2'b01;
						end
						
					 
					 led_reg <= led_reg >> 1;   // Shift right
					 
				end
        end
    end

    assign leds = led_reg;

endmodule