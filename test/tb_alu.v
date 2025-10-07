`include "./source/alu.v"

module tb;
    parameter DWIDTH = 32;
    parameter IMM_WIDTH = 16;
    parameter PC_WIDTH = 32;
    reg [DWIDTH - 1 : 0] a_i_data_rs, a_i_data_rt;
    reg [IMM_WIDTH - 1 : 0] a_i_imm;
    reg [4 : 0] a_i_funct;
    reg a_i_alu_src;
    reg [PC_WIDTH - 1 : 0] a_i_pc; 
    wire [DWIDTH - 1 : 0] alu_value;
    wire [PC_WIDTH - 1 : 0] alu_pc;
    wire done;

    alu #(
        .DWIDTH(DWIDTH),
        .IMM_WIDTH(IMM_WIDTH),
        .PC_WIDTH(PC_WIDTH)
    ) a (
        .a_i_data_rs(a_i_data_rs), 
        .a_i_data_rt(a_i_data_rt), 
        .a_i_imm(a_i_imm), 
        .a_i_funct(a_i_funct), 
        .a_i_alu_src(a_i_alu_src), 
        .a_i_pc(a_i_pc), 
        .alu_value(alu_value), 
        .alu_pc(alu_pc), 
        .done(done)
    );

    initial begin
        a_i_data_rt = 4;
        a_i_data_rs = 5;
        a_i_imm = 4;
        a_i_alu_src = 0;
        a_i_pc = 10;
        a_i_funct = 0;
        #10;
        a_i_data_rt = 4;
        a_i_data_rs = 5;
        a_i_imm = 10;
        a_i_alu_src = 1;
        a_i_pc = 10;
        a_i_funct = 0;
        #10;
        a_i_data_rt = 5;
        a_i_data_rs = 5;
        a_i_imm = 4;
        a_i_alu_src = 0;
        a_i_pc = 10;
        a_i_funct = 15;
        #10;
        #20; $finish;
    end

    initial begin
        $monitor($time, " ", "a_i_funct = %b, a_i_data_rs = %0d, a_i_data_rt = %0d, alu_value = %0d, alu_pc = %0d, done = %b", 
        a_i_funct, a_i_data_rs, a_i_data_rt, alu_value, alu_pc, done);
    end
endmodule