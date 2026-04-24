module tt_um_DivyanshuJaiswal411 (   // 👈 CHANGE THIS to your GitHub username
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire clk,
    input  wire rst_n
); 

    wire enable = ui_in[0];
    wire pedestrian = ui_in[1];

    reg [1:0] state;
    reg [23:0] counter;

    // States
    localparam S0 = 2'd0;
    localparam S1 = 2'd1;
    localparam S2 = 2'd2;
    localparam S3 = 2'd3;

    // Timing
    localparam MAX_COUNT = 24'd2_000_000;

    // FSM logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S0;
            counter <= 0;
        end else if (enable) begin
            if (counter >= MAX_COUNT) begin
                counter <= 0;
                case (state)
                    S0: state <= S1;
                    S1: state <= S2;
                    S2: state <= S3;
                    S3: state <= S0;
                endcase
            end else begin
                counter <= counter + 1;
            end
        end
    end

    // Output logic
    reg [5:0] lights;

    always @(*) begin
        case (state)
            S0: lights = 6'b001100; // A=Green, B=Red
            S1: lights = 6'b010100; // A=Yellow, B=Red
            S2: lights = 6'b100001; // A=Red, B=Green
            S3: lights = 6'b100010; // A=Red, B=Yellow
            default: lights = 6'b100100;
        endcase
    end

    assign uo_out[5:0] = lights;
    assign uo_out[7:6] = 2'b00;

endmodule
