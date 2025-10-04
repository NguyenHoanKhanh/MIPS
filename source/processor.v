`ifndef PROCESSOR_V
`define PROCESSOR_V
`include "./source/datapath.v"
`include "./source/controller.v"

module processor #(
    parameter DWIDTH = 32,
    parameter IWIDTH = 32,
    parameter AWIDTH = 5,
    parameter PC_WIDTH = 32,
    parameter AWIDTH_MEM = 32,
    parameter IMM_WIDTH = 16,
    parameter DEPTH = 5
) (
    p_clk, p_rst, p_i_ce, p_o_pc, p_wb_data
);
    input p_clk, p_rst;
    input p_i_ce;
    output [PC_WIDTH - 1 : 0] p_o_pc;
    output [DWIDTH - 1 : 0] p_wb_data;

    wire [`OPCODE_WIDTH - 1 : 0] d_c_o_opcode;
    datapath #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .IWIDTH(IWIDTH),
        .PC_WIDTH(PC_WIDTH),
        .DEPTH(DEPTH),
        .AWIDTH_MEM(AWIDTH_MEM),
        .IMM_WIDTH(IMM_WIDTH)
    ) d (
        .d_clk(p_clk), 
        .d_rst(p_rst), 
        .d_i_ce(p_i_ce), 
        .d_i_RegDst(c_d_o_RegDst), 
        .d_i_RegWrite(c_d_o_RegWrite), 
        .d_i_ALUSrc(c_d_o_ALUSrc), 
        .d_i_MemRead(c_d_o_MemRead), 
        .d_i_MemWrite(c_d_o_MemWrite), 
        .d_i_MemtoReg(c_d_o_MemtoReg), 
        .d_o_pc(p_o_pc),
        .write_back_data(p_wb_data), 
        .ds_es_o_opcode(d_c_o_opcode)
    );

    wire c_d_o_RegDst, c_d_o_RegWrite;
    wire c_d_o_Branch;
    wire c_d_o_MemRead, c_d_o_MemWrite;
    wire c_d_o_MemtoReg;
    wire c_d_o_ALUSrc;

    controller c (
        .d_c_opcode(d_c_o_opcode), 
        .RegDst(c_d_o_RegDst), 
        .Branch(c_d_o_Branch), 
        .MemRead(c_d_o_MemRead), 
        .MemWrite(c_d_o_MemWrite), 
        .MemtoReg(c_d_o_MemtoReg), 
        .ALUSrc(c_d_o_ALUSrc), 
        .RegWrite(c_d_o_RegWrite)
    );
endmodule

`endif 