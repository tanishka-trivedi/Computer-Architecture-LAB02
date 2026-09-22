module main (
    input wire        clk,
    input wire        reset,

    // =====================================================
    // COMMON BUS SOURCE SELECT
    //
    // 0  -> PC
    // 1  -> MAR
    // 2  -> MDR
    // 3  -> IR
    // 4  -> R0
    // 5  -> R1
    // 6  -> R2
    // 7  -> R3
    // 8  -> Y
    // 9  -> Z
    // 10 -> External data
    // =====================================================

    input wire [3:0] bus_select,

    // External data source for testing / initialization
    input wire [31:0] external_data,

    // =====================================================
    // REGISTER ENABLE SIGNALS
    // =====================================================

    input wire pc_enable,
    input wire mar_enable,
    input wire mdr_enable,
    input wire ir_enable,

    input wire r0_enable,
    input wire r1_enable,
    input wire r2_enable,
    input wire r3_enable,

    input wire y_enable,
    input wire z_enable,

    // =====================================================
    // ALU CONTROL
    //
    // 00 -> ADD
    // 01 -> SUB
    // 10 -> AND
    // 11 -> XOR
    // =====================================================

    input wire       mux_select,
    input wire [1:0] alu_control,
    input wire       carry_in,

    output wire       carry_out,

    // Common bus output
    output wire [31:0] bus_out
);


    // =====================================================
    // REGISTER OUTPUTS
    // =====================================================

    wire [31:0] pc_data;
    wire [31:0] mar_data;
    wire [31:0] mdr_data;
    wire [31:0] ir_data;

    wire [31:0] r0_data;
    wire [31:0] r1_data;
    wire [31:0] r2_data;
    wire [31:0] r3_data;

    wire [31:0] y_data;
    wire [31:0] z_data;


    // =====================================================
    // PC
    // =====================================================

    register32bit PC (
        .clk      (clk),
        .reset    (reset),
        .enable   (pc_enable),
        .data_in  (bus_out),
        .data_out (pc_data)
    );


    // =====================================================
    // MAR
    // =====================================================

    register32bit MAR (
        .clk      (clk),
        .reset    (reset),
        .enable   (mar_enable),
        .data_in  (bus_out),
        .data_out (mar_data)
    );


    // =====================================================
    // MDR
    // =====================================================

    register32bit MDR (
        .clk      (clk),
        .reset    (reset),
        .enable   (mdr_enable),
        .data_in  (bus_out),
        .data_out (mdr_data)
    );


    // =====================================================
    // IR
    // =====================================================

    register32bit IR (
        .clk      (clk),
        .reset    (reset),
        .enable   (ir_enable),
        .data_in  (bus_out),
        .data_out (ir_data)
    );


    // =====================================================
    // R0
    // =====================================================

    register32bit R0 (
        .clk      (clk),
        .reset    (reset),
        .enable   (r0_enable),
        .data_in  (bus_out),
        .data_out (r0_data)
    );


    // =====================================================
    // R1
    // =====================================================

    register32bit R1 (
        .clk      (clk),
        .reset    (reset),
        .enable   (r1_enable),
        .data_in  (bus_out),
        .data_out (r1_data)
    );


    // =====================================================
    // R2
    // =====================================================

    register32bit R2 (
        .clk      (clk),
        .reset    (reset),
        .enable   (r2_enable),
        .data_in  (bus_out),
        .data_out (r2_data)
    );


    // =====================================================
    // R3
    // =====================================================

    register32bit R3 (
        .clk      (clk),
        .reset    (reset),
        .enable   (r3_enable),
        .data_in  (bus_out),
        .data_out (r3_data)
    );


    // =====================================================
    // Y REGISTER
    // =====================================================

    register32bit Y (
        .clk      (clk),
        .reset    (reset),
        .enable   (y_enable),
        .data_in  (bus_out),
        .data_out (y_data)
    );


    // =====================================================
    // MUX
    //
    // mux_select = 0 -> Y
    // mux_select = 1 -> Constant 4
    // =====================================================

    wire [31:0] mux_out;

    assign mux_out = mux_select ? 32'd4 : y_data;


    // =====================================================
    // ALU
    //
    // A = MUX output
    // B = Common bus
    //
    // 00 -> ADD
    // 01 -> SUB
    // 10 -> AND
    // 11 -> XOR
    // =====================================================

    reg [31:0] alu_result;
    reg        carry_out_reg;

    assign carry_out = carry_out_reg;


    always @(*) begin

        alu_result    = 32'b0;
        carry_out_reg = 1'b0;

        case (alu_control)

            // ADD
            2'b00: begin

                {carry_out_reg, alu_result} =
                    {1'b0, mux_out} +
                    {1'b0, bus_out} +
                    carry_in;

            end


            // SUB
            2'b01: begin

                alu_result = mux_out - bus_out - carry_in;

            end


            // AND
            2'b10: begin

                alu_result = mux_out & bus_out;

            end


            // XOR
            2'b11: begin

                alu_result = mux_out ^ bus_out;

            end


            default: begin

                alu_result    = 32'b0;
                carry_out_reg = 1'b0;

            end

        endcase

    end


    // =====================================================
    // Z REGISTER
    //
    // ALU -> Z
    // =====================================================

    register32bit Z (
        .clk      (clk),
        .reset    (reset),
        .enable   (z_enable),
        .data_in  (alu_result),
        .data_out (z_data)
    );


    // =====================================================
    // COMMON BUS
    // =====================================================

    reg [31:0] bus;

    always @(*) begin

        case (bus_select)

            4'd0:
                bus = pc_data;

            4'd1:
                bus = mar_data;

            4'd2:
                bus = mdr_data;

            4'd3:
                bus = ir_data;

            4'd4:
                bus = r0_data;

            4'd5:
                bus = r1_data;

            4'd6:
                bus = r2_data;

            4'd7:
                bus = r3_data;

            4'd8:
                bus = y_data;

            4'd9:
                bus = z_data;

            4'd10:
                bus = external_data;

            default:
                bus = 32'b0;

        endcase

    end


    assign bus_out = bus;


endmodule
