module fir_filter #(
    parameter DATA_WIDTH = 16,
    parameter NUM_TAPS   = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [DATA_WIDTH-1:0] data_in,
    input  logic valid_in,
    output logic signed [DATA_WIDTH-1:0] data_out,
    output logic valid_out
);

    logic signed [DATA_WIDTH-1:0] delay_line [0:NUM_TAPS-1];
    logic signed [DATA_WIDTH-1:0] coeff [0:NUM_TAPS-1];
    
    assign coeff[0] = -16'sd492;
    assign coeff[1] =  16'sd1966;
    assign coeff[2] =  16'sd5734;
    assign coeff[3] =  16'sd9175;
    assign coeff[4] =  16'sd9175;
    assign coeff[5] =  16'sd5734;
    assign coeff[6] =  16'sd1966;
    assign coeff[7] = -16'sd492;

    // Pipeline Stage 1: Registered products
    logic signed [31:0] mult_reg [0:NUM_TAPS-1];
    logic valid_s1;

    // Pipeline Stage 2: Accumulator
    logic signed [34:0] acc;
    logic signed [DATA_WIDTH-1:0] out_reg;
    logic out_valid_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUM_TAPS; i++) delay_line[i] <= 0;
            for (int i = 0; i < NUM_TAPS; i++) mult_reg[i] <= 0;
            acc <= 0;
            out_reg <= 0;
            valid_s1 <= 0;
            out_valid_reg <= 0;
        end else begin
            // Shift register
            delay_line[0] <= data_in;
            for (int i = 1; i < NUM_TAPS; i++) delay_line[i] <= delay_line[i-1];

            // Stage 1: Register the products
            for (int i = 0; i < NUM_TAPS; i++) begin
                mult_reg[i] <= delay_line[i] * coeff[i];
            end
            valid_s1 <= valid_in;

            // Stage 2: Accumulate and shift
            acc = 0;
            for (int i = 0; i < NUM_TAPS; i++) begin
                acc += mult_reg[i];
            end
            out_reg <= (acc + 16384) >>> 15;
            out_valid_reg <= valid_s1;
        end
    end

    assign data_out = out_reg;
    assign valid_out = out_valid_reg;

endmodule
