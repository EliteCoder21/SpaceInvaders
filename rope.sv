module rope (clk, reset, playerInput, lights, out);

	// Input logic
	input logic clk, reset;
	input [1:0] playerInput;
	input [8:0] lights;
	
	// Output logic
	output [8:0] out;

	reg [8:0] ns, ps;
	
	// Next State logic
	always_comb begin
	/*
		if (leftEdge ^ rightEdge) begin
			if (leftEdge) begin
				ns = lights << 1;
			end else begin
				ns = lights >> 1;
			end
		end else begin
			ns = lights;
		end*/
	end	
	
	// Output logic - could also be another always_comb block.
	assign out = ps;
	
	// DFFs
	always_ff @(posedge clk) begin
		if (reset)
			ps <= 9'b000010000;
		else
			ps <= ns;
	end	
endmodule