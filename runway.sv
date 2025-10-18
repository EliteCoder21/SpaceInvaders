module runway (clk, reset, w, lights, out);

	input logic clk, reset;
	input [1:0] w;
	input [2:0] lights;
	output [2:0] out;

	logic [2:0] ns, ps;

	// State variables
	assign hasWind = |w;
	
	// Next State logic
	always_comb begin
		ns[0] = (~lights[0]) & (lights[1] ^ w[1]);
		ns[1] = (~lights[1]) & (lights[2] | ~w[0]) & (lights[0] | w[1]);
		ns[2] = (~lights[2]) & (lights[1] ^ w[0]);
	end
	
	// Output logic - could also be another always_comb block.
	assign out = ps;
	
	// DFFs
	always_ff @(posedge clk) begin
		if (reset)
			ps <= 3'b010;
		else
			ps <= ns;
	end
	
endmodule