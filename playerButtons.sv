module playerButtons (clk, playerInput, out);

	// Inputs
	input logic clk;
	input logic [3:0] playerInput;
	
	// Outputs
	output logic [1:0] out;

	// Intermediate States
	logic [1:0] ns, ps1, ps2;	
	
	// Output logic - could also be another always_comb block.
	assign out = ps2;
	
	// Switch as needed
	assign ns[0] = ~playerInput[0];
	assign ns[1] = ~playerInput[3];
		
	// DFFs
	always_ff @(posedge clk) begin
		ps1 <= ns;
		ps2 <= ps1;
	end
	
endmodule