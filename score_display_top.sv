module score_display_top (
    input  logic [11:0] score,     // 12-bit score input (0x000 to 0xFFF)

    output logic [6:0] seg2,       // 7-segment output for MSB digit (hex2)
    output logic [6:0] seg1,       // 7-segment output for middle digit (hex1)
    output logic [6:0] seg0        // 7-segment output for LSB digit (hex0)
);

    // Internal wires for hex digits
    logic [3:0] hex2, hex1, hex0;

    // Instantiate digit splitter
    score_display_controller digit_splitter (
        .score(score),
        .hex2(hex2),
        .hex1(hex1),
        .hex0(hex0)
    );

    // Instantiate 7-segment decoders for each digit
    hex_to_7seg seg_decoder2 (
        .hex(hex2),
        .seg(seg2)
    );

    hex_to_7seg seg_decoder1 (
        .hex(hex1),
        .seg(seg1)
    );

    hex_to_7seg seg_decoder0 (
        .hex(hex0),
        .seg(seg0)
    );

endmodule
