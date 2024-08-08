module relu #(
    parameter WIDTH = 0
)(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [WIDTH-1:0] in_feature_map,
    output reg [WIDTH-1:0] out_feature_map
);
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_feature_map <= 0;
        end else if (enable) begin
            for (i = 0; i < WIDTH; i = i + 1) begin
                out_feature_map[i] <= (in_feature_map[i] > 0) ? in_feature_map[i] : 0;
            end
        end
    end

    // Debug statement for ReLU
    always @(posedge clk) begin
        if (enable) begin
            $display("ReLU output: %h", out_feature_map);
        end
    end

endmodule
