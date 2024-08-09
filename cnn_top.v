module cnn_top #(
    parameter INPUT_WIDTH = 28 * 28,  // 28x28 input image
    parameter CONV1_OUT_WIDTH = 16 * 28 * 28,  // 16 output channels, 28x28 due to padding
    parameter MAXPOOL1_OUT_WIDTH = 16 * 14 * 14,  // 16 output channels, 14x14 after pooling
    parameter CONV2_OUT_WIDTH = 32 * 14 * 14,  // 32 output channels, 14x14 due to padding
    parameter MAXPOOL2_OUT_WIDTH = 32 * 7 * 7,  // 32 output channels, 7x7 after pooling
    parameter FLATTEN_OUT_WIDTH = 32 * 7 * 7,
    parameter DENSE_OUT_WIDTH = 10
)(
    input wire clk,
    input wire rst,
    input wire [INPUT_WIDTH-1:0] input_image,
    output wire [3:0] predicted_digit
);

    // Intermediate wires to connect the modules
    wire [CONV1_OUT_WIDTH-1:0] conv1_output;
    wire [CONV1_OUT_WIDTH-1:0] relu1_output;
    wire [MAXPOOL1_OUT_WIDTH-1:0] maxpool1_output;
    wire [CONV2_OUT_WIDTH-1:0] conv2_output;
    wire [CONV2_OUT_WIDTH-1:0] relu2_output;
    wire [MAXPOOL2_OUT_WIDTH-1:0] maxpool2_output;
    wire [FLATTEN_OUT_WIDTH-1:0] flatten_output;
    wire [DENSE_OUT_WIDTH-1:0] dense_output;

    // Control signals
    wire conv1_enable;
    wire relu1_enable;
    wire maxpool1_enable;
    wire conv2_enable;
    wire relu2_enable;
    wire maxpool2_enable;
    wire flatten_enable;
    wire dense_enable;
    wire done;

    // Instantiate the control unit
    control_unit control (
        .clk(clk),
        .rst(rst),
        .conv1_enable(conv1_enable),
        .relu1_enable(relu1_enable),
        .maxpool1_enable(maxpool1_enable),
        .conv2_enable(conv2_enable),
        .relu2_enable(relu2_enable),
        .maxpool2_enable(maxpool2_enable),
        .flatten_enable(flatten_enable),
        .dense_enable(dense_enable),
        .done(done)
    );

    // Instantiate the first convolutional layer
    conv_layer #(
        .IN_WIDTH(28),
        .IN_CHANNELS(1),
        .OUT_CHANNELS(16),
        .KERNEL_SIZE(5),
        .PADDING(2),
        .WEIGHTS_FILE("weights_conv1.hex"),
        .BIAS_FILE("bias_conv1.hex")
    ) conv1 (
        .clk(clk),
        .rst(rst),
        .enable(conv1_enable),
        .in_feature_map(input_image),
        .out_feature_map(conv1_output)
    );

    // Debug statement for conv1 output
    always @(posedge clk) begin
        if (conv1_enable) begin
            $display("Conv1 output: %h", conv1_output);
        end
    end

    // Instantiate the first ReLU activation
    relu #(
        .WIDTH(CONV1_OUT_WIDTH)
    ) relu1 (
        .clk(clk),
        .rst(rst),
        .enable(relu1_enable),
        .in_feature_map(conv1_output),
        .out_feature_map(relu1_output)
    );

    // Debug statement for relu1 output
    always @(posedge clk) begin
        if (relu1_enable) begin
            $display("ReLU1 output: %h", relu1_output);
        end
    end

    // Instantiate the first max pooling layer
    maxpool #(
        .IN_WIDTH(28),
        .IN_CHANNELS(16),
        .POOL_SIZE(2)
    ) maxpool1 (
        .clk(clk),
        .rst(rst),
        .enable(maxpool1_enable),
        .in_feature_map(relu1_output),
        .out_feature_map(maxpool1_output)
    );

    // Debug statement for maxpool1 output
    always @(posedge clk) begin
        if (maxpool1_enable) begin
            $display("MaxPool1 output: %h", maxpool1_output);
        end
    end

    // Instantiate the second convolutional layer
    conv_layer #(
        .IN_WIDTH(14),
        .IN_CHANNELS(16),
        .OUT_CHANNELS(32),
        .KERNEL_SIZE(5),
        .PADDING(2),
        .WEIGHTS_FILE("weights_conv2.hex"),
        .BIAS_FILE("bias_conv2.hex")
    ) conv2 (
        .clk(clk),
        .rst(rst),
        .enable(conv2_enable),
        .in_feature_map(maxpool1_output),
        .out_feature_map(conv2_output)
    );

    // Debug statement for conv2 output
    always @(posedge clk) begin
        if (conv2_enable) begin
            $display("Conv2 output: %h", conv2_output);
        end
    end

    // Instantiate the second ReLU activation
    relu #(
        .WIDTH(CONV2_OUT_WIDTH)
    ) relu2 (
        .clk(clk),
        .rst(rst),
        .enable(relu2_enable),
        .in_feature_map(conv2_output),
        .out_feature_map(relu2_output)
    );

    // Debug statement for relu2 output
    always @(posedge clk) begin
        if (relu2_enable) begin
            $display("ReLU2 output: %h", relu2_output);
        end
    end

    // Instantiate the second max pooling layer
    maxpool #(
        .IN_WIDTH(14),
        .IN_CHANNELS(32),
        .POOL_SIZE(2)
    ) maxpool2 (
        .clk(clk),
        .rst(rst),
        .enable(maxpool2_enable),
        .in_feature_map(relu2_output),
        .out_feature_map(maxpool2_output)
    );

    // Debug statement for maxpool2 output
    always @(posedge clk) begin
        if (maxpool2_enable) begin
            $display("MaxPool2 output: %h", maxpool2_output);
        end
    end

    // Instantiate the flatten layer
    flatten #(
        .IN_WIDTH(7),
        .IN_CHANNELS(32),
        .OUT_WIDTH(FLATTEN_OUT_WIDTH)
    ) flatten_layer (
        .clk(clk),
        .rst(rst),
        .enable(flatten_enable),
        .in_feature_map(maxpool2_output),
        .out_vector(flatten_output)
    );

    // Debug statement for flatten output
    always @(posedge clk) begin
        if (flatten_enable) begin
            $display("Flatten output: %h", flatten_output);
        end
    end

    // Instantiate the dense layer
    dense_layer #(
        .IN_FEATURES(FLATTEN_OUT_WIDTH),
        .OUT_FEATURES(DENSE_OUT_WIDTH),
        .WEIGHTS_FILE("weights_dense.hex"),
        .BIAS_FILE("bias_dense.hex")
    ) dense (
        .clk(clk),
        .rst(rst),
        .enable(dense_enable),
        .in_vector(flatten_output),
        .out_vector(dense_output)
    );

    // Debug statement for dense output
    always @(posedge clk) begin
        if (dense_enable) begin
            $display("Dense output: %h", dense_output);
        end
    end

    // Instantiate the argmax module
    argmax #(
        .IN_WIDTH(DENSE_OUT_WIDTH)
    ) argmax_layer (
        .enable(done),  // Enable argmax when done
        .probabilities(dense_output),
        .predicted_digit(predicted_digit)
    );

    // Debug statement for predicted digit
    always @(posedge clk) begin
        if (done) begin
            $display("Predicted Digit: %d", predicted_digit);
        end
    end

endmodule
