module player_control (
    input  logic         clk,
    input  logic         rst,
    input  logic         left,
    input  logic         right,
    output logic [15:0]  data_out
);

    // Internal 16-bit shift register
    logic [15:0] shift_reg;

    // Registers to hold previous state for edge detection
    logic left_prev, right_prev, left_edge, right_edge;

    // Output assignment
    assign data_out = shift_reg;

    // Edge detection and shift logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            left_prev  <= 0;
            right_prev <= 0;
            shift_reg  <= 1;
        end else begin
            // Detect rising edges
            left_edge  <= (left  && !left_prev);
            right_edge <= (right && !right_prev);

            // Store current button state for next cycle
            left_prev  <= left;
            right_prev <= right;

            // Shift only on rising edge of button press
            if (left_edge) begin
                shift_reg <= {shift_reg[14:0], shift_reg[15]};
            end else if (right_edge) begin
                shift_reg <= {shift_reg[0], shift_reg[15:1]};
            end
        end
    end

endmodule


module player_control_testbench();

	// Testbench signals
    logic clk;
    logic reset;
    logic btn_left;
    logic btn_right;
    logic [7:0] shift_reg;

    // Instantiate the DUT (Device Under Test)
    player_control dut (
        .clk(clk),
        .reset(reset),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .shift_reg(shift_reg)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Task to simulate button press

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        btn_left = 0;
        btn_right = 0;

        // Wait a few cycles and release reset
        #15;
        reset = 0;

        //$display("Initial shift_reg: %b", shift_reg);

        // Press left button (should shift left)
        btn_left = 1; 
		  #5;
		  btn_left = 0;
        //$display("After left press 1: %b", shift_reg);

        // Press left button again
        btn_left = 1; 
		  #5;
		  btn_left = 0;
        //$display("After left press 2: %b", shift_reg);

        // Press right button (should shift right)
        btn_right = 1; 
		  #5;
		  btn_right = 0;
        //$display("After right press 1: %b", shift_reg);

        // Press right button again
        btn_right = 1; 
		  #5;
		  btn_right = 0;
		  //$display("After right press 2: %b", shift_reg);

        // Finish simulation
        #20;
        $finish;
    end
	
	
endmodule