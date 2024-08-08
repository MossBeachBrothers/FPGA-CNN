module flatten #(
    parameter IN_WIDTH = 0,
    parameter IN_CHANNELS = 0,
    parameter OUT_WIDTH = 0
)(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [IN_WIDTH*IN_WIDTH*IN_CHANNELS-1:0] in_feature_map,
    output reg [OUT_WIDTH-1:0] out_vector
);
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_vector <= 0;
        end else if (enable) begin
            for (i = 0; i < IN_WIDTH * IN_WIDTH * IN_CHANNELS; i = i + 1) begin
                out_vector[i] <= in_feature_map[i];
            end
        end
    end

    // Debug statement for flatten
    always @(posedge clk) begin
        if (enable) begin
            $display("Flatten output: %h", out_vector);
        end
    end

endmodule
