module argmax #(
    parameter IN_WIDTH = 0
)(
    input wire enable,
    input wire [IN_WIDTH-1:0] probabilities,
    output reg [3:0] predicted_digit
);
    integer i;
    reg [15:0] max_val;
    always @(*) begin
        if (enable) begin
            max_val = probabilities[0];
            predicted_digit = 0;
            for (i = 1; i < IN_WIDTH; i = i + 1) begin
                if (probabilities[i] > max_val) begin
                    max_val = probabilities[i];
                    predicted_digit = i;
                end
            end
        end
    end

    // Debug statement for argmax
    always @(*) begin
        if (enable) begin
            $display("Argmax output: %d", predicted_digit);
        end
    end

endmodule
