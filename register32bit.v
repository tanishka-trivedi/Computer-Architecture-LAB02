module register32bit (
    input wire        clk,
    input wire        reset,
    input wire        enable,
    input wire [31:0] data_in,
    output reg [31:0] data_out
);

    always @(posedge clk or posedge reset) begin

        if (reset)
            data_out <= 32'b0;

        else if (enable)
            data_out <= data_in;

    end

endmodule
