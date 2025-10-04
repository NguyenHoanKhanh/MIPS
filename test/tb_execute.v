`include "./source/execute_stage.v"

module tb;
    parameter DWIDTH = 32;
    parameter IMM_WIDTH = 16;
    reg es_clk, es_rst;
    reg es_i_ce;
    reg es_i_alu_src;
    reg [IMM_WIDTH - 1 : 0] es_i_imm;
    reg [`OPCODE_WIDTH - 1 : 0] es_i_alu_op;
    reg [`FUNCT_WIDTH - 1 : 0] es_i_alu_funct;
    reg [DWIDTH - 1 : 0] es_i_data_rs, es_i_data_rt;
    wire [DWIDTH - 1 : 0] es_o_alu_value;
    wire [`OPCODE_WIDTH - 1 : 0] es_o_opcode;
    wire [`FUNCT_WIDTH - 1 : 0] es_o_funct;
    wire es_o_zero;
    wire es_o_ce;

    execute #(
        .DWIDTH(DWIDTH)
    ) es (
        .es_clk(es_clk),
        .es_rst(es_rst),
        .es_i_ce(es_i_ce),
        .es_i_alu_src(es_i_alu_src),    // <-- đã nối
        .es_i_imm(es_i_imm),            // <-- đã nối
        .es_i_alu_op(es_i_alu_op),
        .es_i_alu_funct(es_i_alu_funct),
        .es_i_data_rs(es_i_data_rs),
        .es_i_data_rt(es_i_data_rt),
        .es_o_alu_value(es_o_alu_value),
        .es_o_zero(es_o_zero),
        .es_o_opcode(es_o_opcode),
        .es_o_funct(es_o_funct),
        .es_o_ce(es_o_ce)
    );

    initial begin
        es_clk = 1'b0;
        es_rst = 1'b1;               // khởi tạo an toàn
        es_i_ce = 1'b0;
        es_i_alu_src = 1'b0;        // R-type test -> use register as operand2
        es_i_imm = {IMM_WIDTH{1'b0}};
        es_i_data_rs = {DWIDTH{1'b0}};
        es_i_data_rt = {DWIDTH{1'b0}};
        es_i_alu_funct = {`FUNCT_WIDTH{1'b0}};
        es_i_alu_op = {`OPCODE_WIDTH{1'b0}};
    end

    always #5 es_clk = ~es_clk;

    initial begin
        $dumpfile("./waveform/execute.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin
            es_rst = 1'b0;
            repeat(counter) @(posedge es_clk);
            es_rst = 1'b1;
        end
    endtask

    initial begin
        reset(2);
        @(posedge es_clk);
        es_i_ce = 1'b1;

        // ADD
        es_i_data_rs = 5;
        es_i_data_rt = 4;
        es_i_alu_funct = `ADD;
        es_i_alu_op = `RTYPE;
        @(posedge es_clk);

        // SUB
        es_i_data_rs = 5;
        es_i_data_rt = 4;
        es_i_alu_funct = `SUB;
        es_i_alu_op = `RTYPE;
        @(posedge es_clk);

        // AND
        es_i_data_rs = 5;
        es_i_data_rt = 4;
        es_i_alu_funct = `AND;
        es_i_alu_op = `RTYPE;
        @(posedge es_clk);

        // OR
        es_i_data_rs = 5;
        es_i_data_rt = 4;
        es_i_alu_funct = `OR;
        es_i_alu_op = `RTYPE;
        @(posedge es_clk);

        // XOR
        es_i_data_rs = 5;
        es_i_data_rt = 4;
        es_i_alu_funct = `XOR;
        es_i_alu_op = `RTYPE;
        @(posedge es_clk);

        #20; $finish;
    end

    initial begin
        $monitor($time, " es_o_opcode=%b es_o_funct=%b es_i_alu_src=%b es_i_imm=%d rs=%d rt=%d -> alu=%d ce=%b",
            es_o_opcode, es_o_funct, es_i_alu_src, es_i_imm, es_i_data_rs, es_i_data_rt, es_o_alu_value, es_o_ce);
    end
endmodule
