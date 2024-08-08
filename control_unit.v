module control_unit (
    input wire clk,
    input wire rst,
    output reg conv1_enable,
    output reg relu1_enable,
    output reg maxpool1_enable,
    output reg conv2_enable,
    output reg relu2_enable,
    output reg maxpool2_enable,
    output reg flatten_enable,
    output reg dense_enable,
    output reg done
);

    // State encoding
    localparam IDLE = 4'd0;
    localparam CONV1 = 4'd1;
    localparam RELU1 = 4'd2;
    localparam MAXPOOL1 = 4'd3;
    localparam CONV2 = 4'd4;
    localparam RELU2 = 4'd5;
    localparam MAXPOOL2 = 4'd6;
    localparam FLATTEN = 4'd7;
    localparam DENSE = 4'd8;
    localparam DONE = 4'd9;

    reg [3:0] state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        // Default values
        conv1_enable = 0;
        relu1_enable = 0;
        maxpool1_enable = 0;
        conv2_enable = 0;
        relu2_enable = 0;
        maxpool2_enable = 0;
        flatten_enable = 0;
        dense_enable = 0;
        done = 0;

        case (state)
            IDLE: next_state = CONV1;
            CONV1: begin
                conv1_enable = 1;
                next_state = RELU1;
            end
            RELU1: begin
                relu1_enable = 1;
                next_state = MAXPOOL1;
            end
            MAXPOOL1: begin
                maxpool1_enable = 1;
                next_state = CONV2;
            end
            CONV2: begin
                conv2_enable = 1;
                next_state = RELU2;
            end
            RELU2: begin
                relu2_enable = 1;
                next_state = MAXPOOL2;
            end
            MAXPOOL2: begin
                maxpool2_enable = 1;
                next_state = FLATTEN;
            end
            FLATTEN: begin
                flatten_enable = 1;
                next_state = DENSE;
            end
            DENSE: begin
                dense_enable = 1;
                next_state = DONE;
            end
            DONE: begin
                done = 1;
                next_state = DONE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Debug statement for state transitions
    always @(posedge clk) begin
        case (state)
            IDLE: $display("State: IDLE");
            CONV1: $display("State: CONV1");
            RELU1: $display("State: RELU1");
            MAXPOOL1: $display("State: MAXPOOL1");
            CONV2: $display("State: CONV2");
            RELU2: $display("State: RELU2");
            MAXPOOL2: $display("State: MAXPOOL2");
            FLATTEN: $display("State: FLATTEN");
            DENSE: $display("State: DENSE");
            DONE: $display("State: DONE");
            default: $display("State: UNKNOWN");
        endcase
    end

endmodule
