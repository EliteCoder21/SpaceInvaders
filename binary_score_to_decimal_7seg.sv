module binary_score_to_decimal_7seg (
	 input  logic RST,
    input  logic [11:0] score,     // Binary score (0–4095)
    output logic [6:0] seg2,       // Hundreds place (MSD)
    output logic [6:0] seg1,       // Tens place
    output logic [6:0] seg0        // Ones place (LSD)
);

    // Decimal digits (0–9)
    logic [3:0] hundreds, tens, ones;
	 logic [11:0] temp;

    // --- Binary to BCD Conversion (double dabble method optional) ---
    always_comb begin
        // Start with 0s
        hundreds = 0;
        tens     = 0;
        ones     = 0;

        // Temporary copy of score
        temp = score;

        // Extract BCD digits via division (works fine in synthesis up to 4095)
        hundreds = temp / 100;
        temp     = temp % 100;

        tens     = temp / 10;
        ones     = temp % 10;
    end

    // --- Convert to 7-segment (active-low) ---
    always_comb begin
        seg2 = hex_to_7seg(hundreds);
        seg1 = hex_to_7seg(tens);
        seg0 = hex_to_7seg(ones);
    end

    // --- Function to convert hex digit (0–9) to 7-seg (active-low) ---
    function logic [6:0] hex_to_7seg(input logic [3:0] hex);
        case (hex)
            4'd0: hex_to_7seg = 7'b1000000;
            4'd1: hex_to_7seg = 7'b1111001;
            4'd2: hex_to_7seg = 7'b0100100;
            4'd3: hex_to_7seg = 7'b0110000;
            4'd4: hex_to_7seg = 7'b0011001;
            4'd5: hex_to_7seg = 7'b0010010;
            4'd6: hex_to_7seg = 7'b0000010;
            4'd7: hex_to_7seg = 7'b1111000;
            4'd8: hex_to_7seg = 7'b0000000;
            4'd9: hex_to_7seg = 7'b0010000;
            default: hex_to_7seg = 7'b1111111; // all segments off
        endcase
    endfunction

endmodule
