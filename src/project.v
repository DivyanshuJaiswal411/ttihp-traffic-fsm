`default_nettype none

module tt_um_traffic_light (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Disable bidirectional IOs as we don't need them for this project
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // FSM State Encoding
    localparam S_NS_G_EW_R = 2'b00;
    localparam S_NS_Y_EW_R = 2'b01;
    localparam S_NS_R_EW_G = 2'b10;
    localparam S_NS_R_EW_Y = 2'b11;

    reg [1:0] state;
    reg [25:0] counter; // 26-bit counter to create a visible delay

    // Output logic (Combinational)
    // Bit mapping: {Empty, Empty, EW_Green, EW_Yellow, EW_Red, NS_Green, NS_Yellow, NS_Red}
    reg [5:0] lights;
    
    // Assign the lower 6 bits of uo_out to our lights, tie top 2 bits to 0
    assign uo_out = {2'b00, lights};

    always @(*) begin
        case(state)
            // lights = {EW_G, EW_Y, EW_R, NS_G, NS_Y, NS_R}
            S_NS_G_EW_R: lights = 6'b001_100; // EW Red (bit 3), NS Green (bit 2)
            S_NS_Y_EW_R: lights = 6'b001_010; // EW Red (bit 3), NS Yellow (bit 1)
            S_NS_R_EW_G: lights = 6'b100_001; // EW Green (bit 5), NS Red (bit 0)
            S_NS_R_EW_Y: lights = 6'b010_001; // EW Yellow (bit 4), NS Red (bit 0)
            default:     lights = 6'b001_001; // Default to Red/Red for safety
        endcase
    end

    // State Transitions and Counter (Sequential)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= S_NS_G_EW_R;
            counter <= 0;
        end else begin
            counter <= counter + 1;

            // Timer thresholds. Assuming a fast clock (e.g., 10-50MHz), 
            // these large numbers divide the clock to create a multi-second delay.
            if (state == S_NS_G_EW_R && counter == 26'd20_000_000) begin
                state <= S_NS_Y_EW_R;
                counter <= 0;
            end else if (state == S_NS_Y_EW_R && counter == 26'd5_000_000) begin
                state <= S_NS_R_EW_G;
                counter <= 0;
            end else if (state == S_NS_R_EW_G && counter == 26'd20_000_000) begin
                state <= S_NS_R_EW_Y;
                counter <= 0;
            end else if (state == S_NS_R_EW_Y && counter == 26'd5_000_000) begin
                state <= S_NS_G_EW_R;
                counter <= 0;
            end
        end
    end

endmodule
