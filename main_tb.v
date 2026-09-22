`timescale 1ns/1ps

module main_tb;

    // =====================================================
    // INPUTS
    // =====================================================

    reg        clk;
    reg        reset;

    reg [3:0]  bus_select;
    reg [31:0] external_data;

    reg pc_enable;
    reg mar_enable;
    reg mdr_enable;
    reg ir_enable;

    reg r0_enable;
    reg r1_enable;
    reg r2_enable;
    reg r3_enable;

    reg y_enable;
    reg z_enable;

    reg       mux_select;
    reg [1:0] alu_control;
    reg       carry_in;


    // =====================================================
    // OUTPUTS
    // =====================================================

    wire [31:0] bus_out;
    wire        carry_out;


    // =====================================================
    // DUT
    // =====================================================

    main dut (

        .clk          (clk),
        .reset        (reset),

        .bus_select   (bus_select),
        .external_data(external_data),

        .pc_enable    (pc_enable),
        .mar_enable   (mar_enable),
        .mdr_enable   (mdr_enable),
        .ir_enable    (ir_enable),

        .r0_enable    (r0_enable),
        .r1_enable    (r1_enable),
        .r2_enable    (r2_enable),
        .r3_enable    (r3_enable),

        .y_enable     (y_enable),
        .z_enable     (z_enable),

        .mux_select   (mux_select),
        .alu_control  (alu_control),
        .carry_in     (carry_in),

        .bus_out      (bus_out),
        .carry_out    (carry_out)
    );


    // =====================================================
    // CLOCK
    // =====================================================

    always #5 clk = ~clk;


    // =====================================================
    // TASK: Disable all register enables
    // =====================================================

    task disable_all;
        begin

            pc_enable  = 0;
            mar_enable = 0;
            mdr_enable = 0;
            ir_enable  = 0;

            r0_enable = 0;
            r1_enable = 0;
            r2_enable = 0;
            r3_enable = 0;

            y_enable = 0;
            z_enable = 0;

        end
    endtask


    // =====================================================
    // TASK: Display register values
    // =====================================================

    task display_values;
        begin

            $display("------------------------------------------------------------");

            $display("PC  = %0d", dut.pc_data);

            $display("MAR = %0d", dut.mar_data);

            $display("MDR = %0d", dut.mdr_data);

            $display("IR  = %0d", dut.ir_data);

            $display("R0  = %0d", dut.r0_data);

            $display("R1  = %0d", dut.r1_data);

            $display("R2  = %0d", dut.r2_data);

            $display("R3  = %0d", dut.r3_data);

            $display("Y   = %0d", dut.y_data);

            $display("Z   = %0d", dut.z_data);

            $display("BUS = %0d", bus_out);

            $display("------------------------------------------------------------");

        end
    endtask


    // =====================================================
    // INITIALIZATION
    // =====================================================

    initial begin

        clk = 0;

        reset = 1;

        bus_select = 4'd10;

        external_data = 32'd0;

        disable_all;

        mux_select = 0;

        alu_control = 2'b00;

        carry_in = 0;


        // =================================================
        // RESET
        // =================================================

        #10;

        reset = 0;


        // =================================================
        // INITIALIZE R1 = 10
        //
        // External data -> BUS -> R1
        // =================================================

        $display("");
        $display("============================================================");
        $display("INITIALIZING R1 = 10");
        $display("============================================================");

        external_data = 32'd10;

        bus_select = 4'd10;

        r1_enable = 1;

        #10;

        r1_enable = 0;


        // =================================================
        // INITIALIZE R2 = 20
        //
        // External data -> BUS -> R2
        // =================================================

        $display("");
        $display("============================================================");
        $display("INITIALIZING R2 = 20");
        $display("============================================================");

        external_data = 32'd20;

        bus_select = 4'd10;

        r2_enable = 1;

        #10;

        r2_enable = 0;


        // =================================================
        // INITIALIZE PC = 100
        //
        // External data -> BUS -> PC
        // =================================================

        $display("");
        $display("============================================================");
        $display("INITIALIZING PC = 100");
        $display("============================================================");

        external_data = 32'd100;

        bus_select = 4'd10;

        pc_enable = 1;

        #10;

        pc_enable = 0;


        // =================================================
        // TEST 1
        //
        // R2 <- R1
        // =================================================

        $display("");
        $display("============================================================");
        $display("TEST 1 : R2 <- R1");
        $display("============================================================");

        // R1 -> BUS
        bus_select = 4'd5;

        // BUS -> R2
        r2_enable = 1;

        #10;

        r2_enable = 0;

        display_values;


        // =================================================
        // Re-initialize R2 = 20
        // so following tests use R1=10, R2=20
        // =================================================

        external_data = 32'd20;

        bus_select = 4'd10;

        r2_enable = 1;

        #10;

        r2_enable = 0;


        // =================================================
        // TEST 2
        //
        // R3 <- R1 + R2
        // =================================================

        $display("");
        $display("============================================================");
        $display("TEST 2 : R3 <- R1 + R2");
        $display("============================================================");


        // -------------------------------------------------
        // Cycle 1
        // R1 -> BUS -> Y
        // -------------------------------------------------

        bus_select = 4'd5;

        y_enable = 1;

        #10;

        y_enable = 0;


        // -------------------------------------------------
        // Cycle 2
        // R2 -> BUS
        // Y + BUS -> ALU -> Z
        // -------------------------------------------------

        bus_select = 4'd6;

        mux_select  = 0;

        alu_control = 2'b00;

        carry_in = 0;

        z_enable = 1;

        #10;

        z_enable = 0;


        // -------------------------------------------------
        // Cycle 3
        // Z -> BUS -> R3
        // -------------------------------------------------

        bus_select = 4'd9;

        r3_enable = 1;

        #10;

        r3_enable = 0;

        display_values;


        // =================================================
        // TEST 3
        //
        // R3 <- R1 - R2
        // =================================================

        $display("");
        $display("============================================================");
        $display("TEST 3 : R3 <- R1 - R2");
        $display("============================================================");


        // Cycle 1
        // R1 -> BUS -> Y

        bus_select = 4'd5;

        y_enable = 1;

        #10;

        y_enable = 0;


        // Cycle 2
        // R2 -> BUS
        // Y - BUS -> ALU -> Z

        bus_select = 4'd6;

        mux_select  = 0;

        alu_control = 2'b01;

        carry_in = 0;

        z_enable = 1;

        #10;

        z_enable = 0;


        // Cycle 3
        // Z -> BUS -> R3

        bus_select = 4'd9;

        r3_enable = 1;

        #10;

        r3_enable = 0;

        display_values;


        // =================================================
        // TEST 4
        //
        // PC <- PC + 4
        // =================================================

        $display("");
        $display("============================================================");
        $display("TEST 4 : PC <- PC + 4");
        $display("============================================================");


        // -------------------------------------------------
        // Cycle 1
        // PC -> BUS -> Y
        // -------------------------------------------------

        bus_select = 4'd0;

        y_enable = 1;

        #10;

        y_enable = 0;


        // -------------------------------------------------
        // Cycle 2
        //
        // PC -> BUS
        // Constant 4 -> MUX
        // 4 + PC -> ALU -> Z
        // -------------------------------------------------

        bus_select = 4'd0;

        mux_select = 1;

        alu_control = 2'b00;

        carry_in = 0;

        z_enable = 1;

        #10;

        z_enable = 0;


        // -------------------------------------------------
        // Cycle 3
        //
        // Z -> BUS -> PC
        // -------------------------------------------------

        bus_select = 4'd9;

        pc_enable = 1;

        #10;

        pc_enable = 0;

        display_values;


        // =================================================
        // EXTRA TEST: AND
        //
        // R1 AND R2
        // =================================================

        $display("");
        $display("============================================================");
        $display("EXTRA TEST : R1 AND R2");
        $display("============================================================");


        // R1 -> Y

        bus_select = 4'd5;

        y_enable = 1;

        #10;

        y_enable = 0;


        // R2 -> BUS
        // Y AND BUS -> Z

        bus_select = 4'd6;

        mux_select = 0;

        alu_control = 2'b10;

        z_enable = 1;

        #10;

        z_enable = 0;

        display_values;


        // =================================================
        // EXTRA TEST: XOR
        //
        // R1 XOR R2
        // =================================================

        $display("");
        $display("============================================================");
        $display("EXTRA TEST : R1 XOR R2");
        $display("============================================================");


        // R1 -> Y

        bus_select = 4'd5;

        y_enable = 1;

        #10;

        y_enable = 0;


        // R2 -> BUS
        // Y XOR BUS -> Z

        bus_select = 4'd6;

        mux_select = 0;

        alu_control = 2'b11;

        z_enable = 1;

        #10;

        z_enable = 0;

        display_values;


        // =================================================
        // END
        // =================================================

        $display("");
        $display("============================================================");
        $display("              SIMULATION COMPLETE");
        $display("============================================================");

        #10;

        $finish;

    end

endmodule
