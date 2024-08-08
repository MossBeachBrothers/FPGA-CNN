module dense_layer #(
    parameter IN_FEATURES = 0,
    parameter OUT_FEATURES = 0,
    parameter WEIGHTS_FILE = "weights_dense.hex",
    parameter BIAS_FILE = "bias_dense.hex"
)(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [IN_FEATURES-1:0] in_vector,
    output reg [OUT_FEATURES-1:0] out_vector
);
    // Memory for weights and biases
    reg [15:0] weights [0:IN_FEATURES*OUT_FEATURES-1];
    reg [15:0] bias [0:OUT_FEATURES-1];

    initial begin
        $readmemh(WEIGHTS_FILE, weights);
        $readmemh(BIAS_FILE, bias);
    end

    integer i, j;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_vector <= 0;
        end else if (enable) begin
            for (i = 0; i < OUT_FEATURES; i = i + 1) begin
                out_vector[i] <= bias[i];
                for (j = 0; j < IN_FEATURES; j = j + 1) begin
                    out_vector[i] <= out_vector[i] + in_vector[j] * weights[j * OUT_FEATURES + i];
                end
            end
        end
    end

    // Debug statement for dense layer
    always @(posedge clk) begin
        if (enable) begin
            $display("Dense output: %h", out_vector);
        end
    end

endmodule
