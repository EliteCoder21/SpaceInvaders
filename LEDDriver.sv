////////////////////////////////////////////////////////////////////////////////
// LEDDriver.sv - 16x16 Bi-Color LED Matrix Driver
// Target Board: DE1-SoC with 16x16 bi-color LED expansion board
// Course: EE 271
//
// Description:
//     This module drives a 16x16 bi-color (red/green) LED matrix via the
//     GPIO_1 expansion header. It implements a row-scanning technique where
//     each row is enabled sequentially at a configurable frequency. When a
//     row is selected, the corresponding red and green pixel data for that
//     row is driven onto the GPIO pins.
//
//     The matrix uses row multiplexing: at any given time, only one row
//     is actively being driven. This creates the illusion of a full display
//     through persistence of vision when scanned at sufficient speed (>24 Hz).
//
// GPIO_1 Pin Mapping (see DE1_SoC.qsf for actual pin assignments):
//     GPIO_1[35:32] - 4-bit row select (one-hot encoding, 16 rows)
//     GPIO_1[31:16] - Green LED row data (16 bits, one per column)
//     GPIO_1[15:0]  - Red LED row data (16 bits, one per column)
//
// Parameters:
//     FREQDIV - Clock divider factor for row scanning frequency
//               Effective scan rate = CLK / 2^(FREQDIV+4)
//               Higher values = slower scanning = potential flicker
//               Lower values = faster scanning = dimmer LEDs
//
// Note: For most applications, the default FREQDIV=0 works well with
//       an appropriately divided clock from clock_divider module.
////////////////////////////////////////////////////////////////////////////////
module LEDDriver #(parameter FREQDIV = 0) (GPIO_1, RedPixels, GrnPixels, EnableCount, CLK, RST);
    // Outputs: 36-bit GPIO interface to LED matrix
    output logic [35:0] GPIO_1;
    
    // Inputs: Pixel data buffers (16x16 arrays)
    input logic [15:0][15:0] RedPixels ;   // Red channel pixel data
    input logic [15:0][15:0] GrnPixels ;   // Green channel pixel data
    input logic EnableCount, CLK, RST;     // Control signals

    // Row scanning counter
    // Bits [FREQDIV+3:FREQDIV] extract 4 bits that cycle through rows 0-15
    reg [(FREQDIV + 3):0] Counter;
    logic [3:0] RowSelect;
    
    // RowSelect uses a 4-bit value to select one of 16 rows
    // As Counter increments, RowSelect cycles through 0, 1, 2, ... F, 0, ...
    assign RowSelect = Counter[(FREQDIV + 3):FREQDIV];

    // Counter increments on each clock when enabled
    // When Counter overflows, RowSelect wraps automatically (4-bit behavior)
    always_ff @(posedge CLK or posedge RST)
    begin
        if(RST) Counter <= 0;
        else if(EnableCount) Counter <= Counter + 1'b1;
    end
    
    // Drive GPIO pins with selected row's pixel data
    // RowSelect[35:32] - One-hot encoded row enable (only one bit high at a time)
    assign GPIO_1[35:32] = RowSelect;
    
    // Green pixel data for selected row (16 columns)
    // GrnPixels[RowSelect][col] gets mapped to GPIO_1[31-col]
    assign GPIO_1[31:16] = { GrnPixels[RowSelect][0], GrnPixels[RowSelect][1], GrnPixels[RowSelect][2], GrnPixels[RowSelect][3], GrnPixels[RowSelect][4], GrnPixels[RowSelect][5], GrnPixels[RowSelect][6], GrnPixels[RowSelect][7], GrnPixels[RowSelect][8], GrnPixels[RowSelect][9], GrnPixels[RowSelect][10], GrnPixels[RowSelect][11], GrnPixels[RowSelect][12], GrnPixels[RowSelect][13], GrnPixels[RowSelect][14], GrnPixels[RowSelect][15] };
    
    // Red pixel data for selected row (16 columns)
    // RedPixels[RowSelect][col] gets mapped to GPIO_1[15-col]
    assign GPIO_1[15:0] = { RedPixels[RowSelect][0], RedPixels[RowSelect][1], RedPixels[RowSelect][2], RedPixels[RowSelect][3], RedPixels[RowSelect][4], RedPixels[RowSelect][5], RedPixels[RowSelect][6], RedPixels[RowSelect][7], RedPixels[RowSelect][8], RedPixels[RowSelect][9], RedPixels[RowSelect][10], RedPixels[RowSelect][11], RedPixels[RowSelect][12], RedPixels[RowSelect][13], RedPixels[RowSelect][14], RedPixels[RowSelect][15] };
endmodule

////////////////////////////////////////////////////////////////////////////////
// LEDDriver_Test - Functional testbench for LEDDriver module
// Description:
//     Verifies basic functionality of the LED matrix driver including
//     row scanning, pixel data output, and reset behavior.
////////////////////////////////////////////////////////////////////////////////
module LEDDriver_Test();
    logic CLK, RST, EnableCount;
    logic [15:0][15:0]RedPixels;
    logic [15:0][15:0]GrnPixels;
    logic [35:0] GPIO_1;

    LEDDriver #(.FREQDIV(2)) Driver(.GPIO_1, .RedPixels, .GrnPixels, .EnableCount, .CLK, .RST);
    
    initial
    begin
        CLK <= 1'b0;
        forever #50 CLK <= ~CLK;
    end

    initial
    begin
        EnableCount <= 1'b0;
        RedPixels <= '{default:0};
        GrnPixels <= '{default:0};
        @(posedge CLK);

        RST <= 1; @(posedge CLK);
        RST <= 0; @(posedge CLK);
        @(posedge CLK); @(posedge CLK); @(posedge CLK);

        GrnPixels[1][1] <= 1'b1; @(posedge CLK);
        EnableCount <= 1'b1; @(posedge CLK); #1000;
        RedPixels[2][2] <= 1'b1;
        RedPixels[2][3] <= 1'b1;
        GrnPixels[2][3] <= 1'b1; @(posedge CLK); #1000;
        EnableCount <= 1'b0; @(posedge CLK); #1000;
        GrnPixels[1][1] <= 1'b0; @(posedge CLK);
        $stop;

    end
endmodule

////////////////////////////////////////////////////////////////////////////////
// LEDDriver_TestPhysical - Physical test module with pattern display
// Description:
//     Displays a predefined pattern (smiley face) on the LED matrix.
//     The Speed parameter controls scanning frequency.
//     This is useful for verifying LED matrix wiring and functionality
//     before integrating with game logic.
////////////////////////////////////////////////////////////////////////////////
module LEDDriver_TestPhysical(CLOCK_50, RST, Speed, GPIO_1);
    input logic CLOCK_50, RST;
    input logic [9:0] Speed;
    output logic [35:0] GPIO_1;
    logic [15:0][15:0]RedPixels;
    logic [15:0][15:0]GrnPixels;
    logic [31:0] Counter;
    logic EnableCount;

    LEDDriver #(.FREQDIV(15)) Driver (.CLK(CLOCK_50), .RST, .EnableCount, .RedPixels, .GrnPixels, .GPIO_1);

    //                       F E D C B A 9 8 7 6 5 4 3 2 1 0
    assign RedPixels[00] = '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    assign RedPixels[01] = '{1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1};
    assign RedPixels[02] = '{1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1};
    assign RedPixels[03] = '{1,0,1,1,0,0,0,0,0,0,0,0,1,1,0,1};
    assign RedPixels[04] = '{1,0,1,0,1,1,1,1,1,1,1,1,0,1,0,1};
    assign RedPixels[05] = '{1,0,1,0,1,1,0,0,0,0,1,1,0,1,0,1};
    assign RedPixels[06] = '{1,0,1,0,1,0,1,1,1,1,0,1,0,1,0,1};
    assign RedPixels[07] = '{1,0,1,0,1,0,1,0,1,1,0,1,0,1,0,1};
    assign RedPixels[08] = '{1,0,1,0,1,0,1,1,0,1,0,1,0,1,0,1};
    assign RedPixels[09] = '{1,0,1,0,1,0,1,1,1,1,0,1,0,1,0,1};
    assign RedPixels[10] = '{1,0,1,0,1,1,0,0,0,0,1,1,0,1,0,1};
    assign RedPixels[11] = '{1,0,1,0,1,1,1,1,1,1,1,1,0,1,0,1};
    assign RedPixels[12] = '{1,0,1,1,0,0,0,0,0,0,0,0,1,1,0,1};
    assign RedPixels[13] = '{1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1};
    assign RedPixels[14] = '{1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1};
    assign RedPixels[15] = '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};

    assign GrnPixels[00] = '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
    assign GrnPixels[01] = '{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0};
    assign GrnPixels[02] = '{0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0};
    assign GrnPixels[03] = '{0,1,0,1,1,1,1,1,1,1,1,1,1,0,1,0};
    assign GrnPixels[04] = '{0,1,0,1,1,0,0,0,0,0,0,1,1,0,1,0};
    assign GrnPixels[05] = '{0,1,0,1,0,1,1,1,1,1,1,0,1,0,1,0};
    assign GrnPixels[06] = '{0,1,0,1,0,1,1,0,0,1,1,0,1,0,1,0};
    assign GrnPixels[07] = '{0,1,0,1,0,1,0,1,0,0,1,0,1,0,1,0};
    assign GrnPixels[08] = '{0,1,0,1,0,1,0,0,1,0,1,0,1,0,1,0};
    assign GrnPixels[09] = '{0,1,0,1,0,1,1,0,0,1,1,0,1,0,1,0};
    assign GrnPixels[10] = '{0,1,0,1,0,1,1,1,1,1,1,0,1,0,1,0};
    assign GrnPixels[11] = '{0,1,0,1,1,0,0,0,0,0,0,1,1,0,1,0};
    assign GrnPixels[12] = '{0,1,0,1,1,1,1,1,1,1,1,1,1,0,1,0};
    assign GrnPixels[13] = '{0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0};
    assign GrnPixels[14] = '{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0};
    assign GrnPixels[15] = '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};

    always_ff @(posedge CLOCK_50)
    begin
        if(RST) Counter <= 'b0;
        else
        begin
            Counter <= Counter + 1'b1;
            if(Counter >= Speed)
            begin
                EnableCount <= 1'b1;
                Counter <= 'b0;
            end
            else EnableCount <= 1'b0;
        end
    end
endmodule