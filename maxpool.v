module maxpool #(
    parameter IN_WIDTH = 0,
    parameter IN_CHANNELS = 0,
    parameter POOL_SIZE = 2
)(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [IN_WIDTH*IN_WIDTH*IN_CHANNELS-1:0] in_feature_map,
    output reg [(IN_WIDTH/POOL_SIZE)*(IN_WIDTH/POOL_SIZE)*IN_CHANNELS-1:0] out_feature_map
);
    integer i, j, c, m, n;
    reg [15:0] max_val;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_feature_map <= 0;
        end else if (enable) begin
            for (i = 0; i < IN_WIDTH / POOL_SIZE; i = i + 1) begin
                for (j = 0; j < IN_WIDTH / POOL_SIZE; j = j + 1) begin
                    for (c = 0; c < IN_CHANNELS; c = c + 1) begin
                        max_val = in_feature_map[(i * POOL_SIZE * IN_WIDTH + j * POOL_SIZE) * IN_CHANNELS + c];
                        for (m = 0; m < POOL_SIZE; m = m + 1) begin
                            for (n = 0; n < POOL_SIZE; n = n + 1) begin
                                if (in_feature_map[((i * POOL_SIZE + m) * IN_WIDTH + (j * POOL_SIZE + n)) * IN_CHANNELS + c] > max_val) begin
                                    max_val = in_feature_map[((i * POOL_SIZE + m) * IN_WIDTH + (j * POOL_SIZE + n)) * IN_CHANNELS + c];
                                end
                            end
                        end
                        out_feature_map[(i * (IN_WIDTH / POOL_SIZE) + j) * IN_CHANNELS + c] = max_val;
                    end
                end
            end
        end
    end

    // Debug statement for max pooling
    always @(posedge clk) begin
        if (enable) begin
            $display("MaxPool output: %h", out_feature_map);
        end
    end

endmodule
