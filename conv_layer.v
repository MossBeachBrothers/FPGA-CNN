module conv_layer #(
    parameter IN_WIDTH = 28,
    parameter IN_CHANNELS = 1,
    parameter OUT_CHANNELS = 16,
    parameter KERNEL_SIZE = 5,
    parameter PADDING = 2,
    parameter WEIGHTS_FILE = "weights_conv1.hex",
    parameter BIAS_FILE = "bias_conv1.hex"
)(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [IN_WIDTH*IN_WIDTH*IN_CHANNELS-1:0] in_feature_map,
    output reg [IN_WIDTH*IN_WIDTH*OUT_CHANNELS-1:0] out_feature_map
);
    // Memory for weights and biases
    reg [15:0] weights [0:KERNEL_SIZE*KERNEL_SIZE*IN_CHANNELS*OUT_CHANNELS-1];
    reg [15:0] bias [0:OUT_CHANNELS-1];

    initial begin
        $readmemh(WEIGHTS_FILE, weights);
        $readmemh(BIAS_FILE, bias);
    end

    // Convolution logic
    integer i, j, m, n, c, k;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_feature_map <= 0;
        end else if (enable) begin
            for (i = 0; i < IN_WIDTH; i = i + 1) begin
                for (j = 0; j < IN_WIDTH; j = j + 1) begin
                    for (c = 0; c < OUT_CHANNELS; c = c + 1) begin
                        out_feature_map[(i * IN_WIDTH + j) * OUT_CHANNELS + c] = bias[c];
                        for (m = 0; m < KERNEL_SIZE; m = m + 1) begin
                            for (n = 0; n < KERNEL_SIZE; n = n + 1) begin
                                for (k = 0; k < IN_CHANNELS; k = k + 1) begin
                                    if ((i + m - PADDING) >= 0 && (i + m - PADDING) < IN_WIDTH && (j + n - PADDING) >= 0 && (j + n - PADDING) < IN_WIDTH) begin
                                        out_feature_map[(i * IN_WIDTH + j) * OUT_CHANNELS + c] = out_feature_map[(i * IN_WIDTH + j) * OUT_CHANNELS + c] +
                                        in_feature_map[((i + m - PADDING) * IN_WIDTH + (j + n - PADDING)) * IN_CHANNELS + k] *
                                        weights[(m * KERNEL_SIZE + n) * IN_CHANNELS * OUT_CHANNELS + k * OUT_CHANNELS + c];
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    // Debug statement for convolution layer
    always @(posedge clk) begin
        if (enable) begin
            $display("Convolution output: %h", out_feature_map);
        end
    end

endmodule
