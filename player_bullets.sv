module player_bullets (
    input  logic         clk1,
	 input  logic         clk2,
    input  logic         rst ,
    input  logic         fire,
	 input  logic [15:0] player_loc,
    output logic [15:0] [15:0]  data_out
);

    // Internal 16-bit shift register
    logic [14:0] [15:0] data_reg;

    // Registers to hold previous state for edge detection
    logic fire_prev, fire_edge;

    // Output assignment
    assign data_out = data_reg;

    // Edge detection and shift logic
    always_ff @(posedge clk1 or posedge rst) begin
        if (rst) begin
            fire_prev  <= 0;
        end else begin
		  
				fire_edge <= fire  && !fire_prev;
		  
            // Store current button state for next cycle
            fire_prev  <= fire;
        end
    end
	 
	 always_ff @(posedge clk2) begin

         // Shift only on rising edge of button press
         if (fire_edge) begin
				data_reg[14] = player_loc | data_reg[14];
			end else begin
				data_reg[0] <= data_reg[1];
				data_reg[1] <= data_reg[2];
				data_reg[2] <= data_reg[3];
				data_reg[3] <= data_reg[4];
				data_reg[4] <= data_reg[5];
				data_reg[5] <= data_reg[6];
				data_reg[6] <= data_reg[7];
				data_reg[7] <= data_reg[8];
				data_reg[8] <= data_reg[9];
				data_reg[9] <= data_reg[10];
				data_reg[10] <= data_reg[11];
				data_reg[11] <= data_reg[12];
				data_reg[12] <= data_reg[13];
				data_reg[13] <= data_reg[14];
				data_reg[14] <= 0;
			end					
	end

endmodule