module playerButtons (playerInput, out);

	input [1:0] playerInput;
	output [1:0] out;

	logic [1:0] ns, ps;
	
	// Output logic - could also be another always_comb block.
	assign out = ps;
	
	// DFFs
	always_ff @(negedge playerInput[0]) begin
		ps[0] <= 1'b1;
	end

	always_ff @(posedge playerInput[0]) begin
		ps[0] <= 1'b0;
	end
	
	always_ff @(negedge playerInput[1]) begin
		ps[1] <= 1'b1;
	end

	always_ff @(posedge playerInput[1]) begin
		ps[1] <= 1'b0;
	end
endmodule