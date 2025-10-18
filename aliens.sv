module aliens (
    input  logic         clk1,
	 input  logic         clk2,
    input  logic         rst,
    input  logic [40:0]  random_d,
    output logic [5:0][15:0]  aliens,
	 output logic [15:0][15:0]  alienBullets,
	 input logic [15:0][15:0]  playerBullets,
	 input logic [15:0] player,
	 output logic [11:0] points
);

    // Shift aliens right or left
    logic [10:0][15:0] data_reg;
	 logic [15:0][15:0] alienBulletReg;
	 logic [3:0] i;

    // Output assignment
    assign aliens = data_reg;
	 assign alienBullets = alienBulletReg;
	 
	 // Animate the bullets
	 always_ff @(posedge clk2) begin
	 
			for (i = 0; i < 15; i = i + 1) begin
			
				if (random_d[i+:4] < i + 3 && random_d[i+:4] > i && i < 11) begin
					alienBulletReg[i+1] <= alienBulletReg[i] | data_reg[i];
					
				end else begin
					alienBulletReg[i+1] <= alienBulletReg[i] & ~playerBullets[i];
				end
				
				alienBulletReg[0] <= 0;
			end
	 end

    // Edge detection and shift logic
    always_ff @(posedge clk1 or posedge rst) begin
        if (rst) begin
            data_reg <= 1;
				points <= 0;
        end else begin
            
            // Shift only on rising edge of button press
				for (i = 0; i < 5; i = i + 1) begin
							
					if (random_d[i+:4] > 8) begin
						 data_reg[i] <= {data_reg[i][14:0], data_reg[i][15]};
					end else if (random_d[i+:4] < 4) begin
						 data_reg[i] <= {data_reg[i][0], data_reg[i][15:1]};
					end
					
					// Respawn aliens
					if (data_reg[i] == 0 && random_d[0+:4] == 0) begin
						data_reg[i][random_d[0+:4]] <= 1;
					end
					
					// Death + Point increment
					if ((data_reg[i] & playerBullets[i]) != 0) begin
						 data_reg[i] <= 0;
						 points <= points + 1;
						 
					end else if ((player & alienBulletReg[15]) > 0 && points > 0) begin
							points <= points - 1;
					end
				end
				
        end
    end

endmodule