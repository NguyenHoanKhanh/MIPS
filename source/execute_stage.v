`ifndef EXECUTE_STAGE_V
`define EXECUTE_STAGE_V
`include "./source/alu.v"
`include "./source/header.vh"
`include "./source/alu_control.v"

module execute (
    es_i_ce, es_i_branch, es_i_pc, es_i_alu_src, es_i_imm, es_i_alu_op, es_i_alu_funct,
    es_i_data_rs, es_i_data_rt, es_o_alu_value, es_o_opcode, es_o_funct, es_o_zero, es_o_ce,
    es_o_change_pc, es_o_alu_pc
);  
    input es_i_ce;
    input es_i_alu_src;
    input es_i_branch;
    input [`PC_WIDTH - 1 : 0] es_i_pc;
    input  [`IMM_WIDTH - 1 : 0] es_i_imm;
    input  [`OPCODE_WIDTH - 1 : 0] es_i_alu_op;
    input  [`FUNCT_WIDTH - 1 : 0]  es_i_alu_funct;
    input  [`DWIDTH - 1 : 0] es_i_data_rs, es_i_data_rt;
    output reg [`DWIDTH - 1 : 0] es_o_alu_value;
    output reg [`OPCODE_WIDTH - 1 : 0] es_o_opcode;
    output reg [`FUNCT_WIDTH - 1 : 0]  es_o_funct;
    output reg es_o_zero;
    output reg es_o_ce;
    output es_o_change_pc;
    output [`PC_WIDTH - 1 : 0] es_o_alu_pc;

    // alu_control computed combinationally from opcode/funct
    wire [4 : 0] alu_control;
    alucontrol ac (
        .ac_i_opcode(es_i_alu_op), 
        .ac_i_funct(es_i_alu_funct), 
        .ac_o_control(alu_control)
    );

    // instantiate combinational ALU
    wire [`DWIDTH - 1 : 0] alu_value;
    wire [`PC_WIDTH - 1 : 0] alu_pc;
    wire change_pc;
    alu a (
        .a_i_data_rs(es_i_data_rs), 
        .a_i_data_rt(es_i_data_rt), 
        .a_i_imm(es_i_imm), 
        .a_i_funct(alu_control), 
        .a_i_alu_src(es_i_alu_src), 
        .a_i_pc(es_i_pc), 
        .alu_value(alu_value), 
        .alu_pc(alu_pc), 
        .a_o_change_pc(change_pc)
    );

    wire take_beq = (es_i_alu_op == `BEQ) && es_i_branch && temp_zero;
    wire take_bne = (es_i_alu_op == `BNE) && es_i_branch && !temp_zero;
    wire take_branch = es_i_ce && (take_beq || take_bne);
    assign es_o_change_pc = change_pc & take_branch;
    assign es_o_alu_pc = (take_branch && change_pc) ? alu_pc : {`PC_WIDTH{1'b0}};
    
    wire temp_zero;
    assign temp_zero = (alu_value == {`DWIDTH{1'b0}}) ? 1'b1 : 1'b0;
    // register outputs on clock
    always @(*) begin
        es_o_alu_value = {`DWIDTH{1'b0}};
        es_o_zero = 1'b0;
        es_o_funct = {`FUNCT_WIDTH{1'b0}};
        es_o_opcode = {`OPCODE_WIDTH{1'b0}};
        es_o_ce = 1'b0;
        if (es_i_ce) begin
            es_o_alu_value = alu_value;
            es_o_opcode = es_i_alu_op;
            es_o_funct  = es_i_alu_funct;
            es_o_zero = temp_zero;
            es_o_ce = 1'b1;
        end
        else begin
            es_o_ce = 1'b0;
            es_o_alu_value = {`DWIDTH{1'b0}};
            es_o_zero = 1'b0;
            es_o_funct = {`FUNCT_WIDTH{1'b0}};
            es_o_opcode = {`OPCODE_WIDTH{1'b0}};
        end
    end
endmodule
`endif
