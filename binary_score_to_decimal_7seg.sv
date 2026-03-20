////////////////////////////////////////////////////////////////////////////////
// binary_score_to_decimal_7seg.sv - Score Display Controller
// Game: Space Invaders
// Course: EE 271
//
// Description:
//     Converts the binary game score to decimal digits for display on
//     the DE1-SoC's 7-segment displays (HEX0, HEX1, HEX2).
//
// Display Format:
//     HEX2 (MSD) = Hundreds digit (0-9, max displayable score: 999)
//     HEX1       = Tens digit
//     HEX0 (LSD) = Ones digit
//
// Signal Convention:
//     DE1-SoC 7-segment displays use ACTIVE-LOW signals
//     (0 turns segment ON, 1 turns segment OFF)
//
// 7-Segment Segment Mapping (for each digit):
//         --- 0 ---
//        |       |
//        5       1
//        |       |
//         --- 6 ---
//        |       |
//        4       2
//        |       |
//         --- 3 ---
//
// Binary-to-BCD Conversion:
//     Uses division/modulo operations which are efficient for small
//     numbers (0-4095 range) in FPGA synthesis.
////////////////////////////////////////////////////////////////////////////////
module binary_score_to_decimal_7seg (
    input  logic RST,                // Reset signal (not used in this implementation)
    input  logic [11:0] score,       // Binary score (0-4095)
    output logic [6:0] seg2,         // Hundreds place (MSD) - active low
    output logic [6:0] seg1,         // Tens place - active low
    output logic [6:0] seg0          // Ones place (LSD) - active low
);

    // Decimal digit storage
    logic [3:0] hundreds, tens, ones;
    logic [11:0] temp;

    // Binary to BCD conversion using repeated division
    // This works by extracting each decimal digit place
    always_comb begin
        // Initialize all digits to 0
        hundreds = 0;
        tens     = 0;
        ones     = 0;

        // Work with a copy of the score
        temp = score;

        // Extract hundreds digit: divide by 100
        hundreds = temp / 100;
        temp     = temp % 100;  // Remove hundreds portion

        // Extract tens digit: divide remaining by 10
        tens     = temp / 10;
        ones     = temp % 10;   // Remaining is ones digit
    end

    // Convert each decimal digit to 7-segment encoding
    always_comb begin
        seg2 = hex_to_7seg(hundreds);  // Hundreds digit to HEX2
        seg1 = hex_to_7seg(tens);       // Tens digit to HEX1
        seg0 = hex_to_7seg(ones);       // Ones digit to HEX0
    end

    // Function: Convert hex value (0-9) to 7-segment pattern (active low)
    // Segment pattern: {6,5,4,3,2,1,0} (MSB to LSB)
    function logic [6:0] hex_to_7seg(input logic [3:0] hex);
        case (hex)
            4'd0: hex_to_7seg = 7'b1000000;  // 0: All segments except DP
            4'd1: hex_to_7seg = 7'b1111001;  // 1: Only segments 0,1,5,6
            4'd2: hex_to_7seg = 7'b0100100;  // 2
            4'd3: hex_to_7seg = 7'b0110000;  // 3
            4'd4: hex_to_7seg = 7'b0011001;  // 4
            4'd5: hex_to_7seg = 7'b0010010;  // 5
            4'd6: hex_to_7seg = 7'b0000010;  // 6
            4'd7: hex_to_7seg = 7'b1111000;  // 7
            4'd8: hex_to_7seg = 7'b0000000;  // 8: All segments ON
            4'd9: hex_to_7seg = 7'b0010000;  // 9
            default: hex_to_7seg = 7'b1111111; // Blank (all segments OFF)
        endcase
    endfunction

endmodule
