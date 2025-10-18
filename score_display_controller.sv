module score_display_controller (
    input  logic [11:0] score,     // 12-bit input score (0x000 to 0xFFF)
    output logic [3:0] hex2,       // Most significant hex digit (hundreds place)
    output logic [3:0] hex1,       // Middle hex digit (tens place)
    output logic [3:0] hex0        // Least significant hex digit (ones place)
);

    // Break score into three 4-bit hex digits
    always_comb begin
        hex2 = (score >> 8) & 4'hF;  // Top 4 bits
        hex1 = (score >> 4) & 4'hF;  // Middle 4 bits
        hex0 = score & 4'hF;         // Bottom 4 bits
    end

endmodule