module TugOfWarHex (HEX0, HEX5, winner);

	output logic [6:0] HEX0, HEX5;
	input logic [1:0] winner;

	always_comb begin
		case (winner)
			2'b10: begin
				HEX0 = 7'b1111111;  // player 1 Wins
				HEX5 = 7'b1111001;

			end 

			2'b01: begin
				HEX0 = 7'b0100100;  // player 2 Wins
				HEX5 = 7'b1111111;
			end 

			default: begin
				HEX0 = 7'b1111111;
				HEX5 = 7'b1111111;
			end
		endcase
	end
endmodule