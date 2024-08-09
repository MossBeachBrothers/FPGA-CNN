`timescale 1ns/1ps

module cnn_tb;
    reg clk;
    reg rst;
    reg [7:0] image_memory [0:28*28-1];
    reg [28*28-1:0] input_image;
    wire [3:0] predicted_digit;
    integer output_file;
    integer i, j;
    reg [255:0] file_names [0:3];  // Array of file names
    reg [255:0] output_file_name;

    // Instantiate the top-level module
    cnn_top cnn (
        .clk(clk),
        .rst(rst),
        .input_image(input_image),
        .predicted_digit(predicted_digit)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period
    end

    // Initialize file names
    initial begin
        file_names[0] = "test_images/input_image_0.txt";
        file_names[1] = "test_images/input_image_1.txt";
        file_names[2] = "test_images/input_image_2.txt";
        file_names[3] = "test_images/input_image_3.txt";
    end

    // Test sequence
    initial begin
        for (j = 0; j < 4; j = j + 1) begin
            // Read pixel data from file into memory array
            $readmemh(file_names[j], image_memory);

            // Initialize input_image from image_memory
            for (i = 0; i < 28*28; i = i + 1) begin
                input_image[i*8 +: 8] = image_memory[i];
            end

            // Initialize inputs
            rst = 1;
            #20;
            rst = 0;

            // Wait for processing to complete
            wait (cnn.control.done);

            // Display and save the prediction
            $display("Predicted Digit for %0s: %d", file_names[j], predicted_digit);
            output_file_name = {file_names[j], ".predicted_output.txt"};
            output_file = $fopen(output_file_name, "w");
            $fwrite(output_file, "%d\n", predicted_digit);
            $fclose(output_file);

            // Reset for next image
            #10;
            rst = 1;
        end

        // End the simulation
        #10;
        $finish;
    end

endmodule
