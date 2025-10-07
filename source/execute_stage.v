`ifndef EXECUTE_STAGE_V
`define EXECUTE_STAGE_V
`include "./source/alu.v"
`include "./source/header.vh"

module execute #(
    parameter DWIDTH = 32,
    parameter IMM_WIDTH = 16,
    parameter PC_WIDTH = 32
) (
    es_clk, es_rst, es_i_ce, es_i_branch, es_i_pc, es_i_alu_src, es_i_imm, es_i_alu_op, es_i_alu_funct,
    es_i_data_rs, es_i_data_rt, es_o_alu_value, es_o_opcode, es_o_funct, es_o_zero, es_o_ce, 
    es_o_alu_pc, es_o_change_pc
);
    input  es_clk, es_rst;
    input  es_i_ce;
    input  es_i_alu_src;
    input es_i_branch;
    input [PC_WIDTH - 1 : 0] es_i_pc;
    input  [IMM_WIDTH - 1 : 0] es_i_imm;
    input  [`OPCODE_WIDTH - 1 : 0] es_i_alu_op;
    input  [`FUNCT_WIDTH - 1 : 0]  es_i_alu_funct;
    input  [DWIDTH - 1 : 0] es_i_data_rs, es_i_data_rt;
    output reg [DWIDTH - 1 : 0] es_o_alu_value;
    output reg [PC_WIDTH - 1 : 0] es_o_alu_pc;
    output reg [`OPCODE_WIDTH - 1 : 0] es_o_opcode;
    output reg [`FUNCT_WIDTH - 1 : 0]  es_o_funct;
    output reg es_o_zero;
    output reg es_o_ce;
    output reg es_o_change_pc;

    // alu_control computed combinationally from opcode/funct
    reg [4 : 0] alu_control;
    always @(*) begin
        alu_control = 5'd0;
        if (es_i_alu_op == `RTYPE) begin
            case (es_i_alu_funct)
                `ADD:  alu_control = 5'd0;
                `SUB:  alu_control = 5'd1;
                `AND:  alu_control = 5'd2;
                `OR:   alu_control = 5'd3;
                `XOR:  alu_control = 5'd4;
                `SLT:  alu_control = 5'd5;
                `SLTU: alu_control = 5'd6;
                `SLL:  alu_control = 5'd7;
                `SRL:  alu_control = 5'd8;
                `SRA:  alu_control = 5'd9;
                `EQ:   alu_control = 5'd10;
                `NEQ:  alu_control = 5'd11;
                `GE:   alu_control = 5'd12;
                `GEU:  alu_control = 5'd13;
                `ADDIU : alu_control = 5'd14;
                default: alu_control = 5'd0;
            endcase
        end
        else if (es_i_alu_op == `LOAD || es_i_alu_op == `STORE) begin
            alu_control = 5'd0;
        end
        else if (es_i_alu_op == `ADDI) begin
            alu_control = 5'd0;
        end
        else if (es_i_alu_op == `ADDIU) begin
            alu_control = 5'd14;
        end
        else if (es_i_alu_op == `SLTI) begin
            alu_control = 5'd5;
        end
        else if (es_i_alu_op == `SLTIU) begin
            alu_control = 5'd6;
        end
        else if (es_i_alu_op == `ANDI) begin
            alu_control = 5'd2;
        end
        else if (es_i_alu_op == `ORI) begin
            alu_control = 5'd3;
        end
        else if (es_i_alu_op == `XORI) begin
            alu_control = 5'd4;
        end
        else if (es_i_alu_op == `BEQ) begin
            alu_control = 5'd15;
        end
        else if (es_i_alu_op == `BNE) begin
            alu_control = 5'd16;
        end
    end

    // instantiate combinational ALU
    wire [DWIDTH - 1 : 0] alu_value;
    wire [PC_WIDTH - 1 : 0] alu_pc;
    wire done;
    wire change_pc;
    alu #(
        .DWIDTH(DWIDTH),
        .PC_WIDTH(PC_WIDTH),
        .IMM_WIDTH(IMM_WIDTH)
    ) a (
        .a_i_data_rs(es_i_data_rs), 
        .a_i_data_rt(es_i_data_rt), 
        .a_i_imm(es_i_imm), 
        .a_i_funct(alu_control), 
        .a_i_alu_src(es_i_alu_src), 
        .a_i_pc(es_i_pc), 
        .alu_value(alu_value), 
        .alu_pc(alu_pc), 
        .done(done),
        .a_o_change_pc(change_pc)
    );

    wire temp_zero;
    assign temp_zero = (alu_value == {DWIDTH{1'b0}}) ? 1'b1 : 1'b0;
    // register outputs on clock
    always @(posedge es_clk or negedge es_rst) begin
        if (!es_rst) begin
            es_o_alu_value <= {DWIDTH{1'b0}};
            es_o_alu_pc <= {PC_WIDTH{1'b0}};
            es_o_zero <= 1'b0;
            es_o_funct <= {`FUNCT_WIDTH{1'b0}};
            es_o_opcode <= {`OPCODE_WIDTH{1'b0}};
            es_o_ce <= 1'b0;
            es_o_change_pc <= 1'b0;
        end
        else begin
            if (es_i_ce) begin
                es_o_change_pc <= 1'b0;
                es_o_alu_value <= alu_value;
                es_o_opcode <= es_i_alu_op;
                es_o_funct  <= es_i_alu_funct;
                es_o_zero <= temp_zero;
                if (es_i_alu_op == `BEQ) begin
                    if (es_i_branch && temp_zero) begin
                        es_o_alu_pc <= alu_pc;
                        es_o_change_pc <= change_pc;
                    end
                    else begin 
                        es_o_change_pc <= 1'b0;
                        es_o_alu_pc <= es_i_pc;
                    end
                end
                if (es_i_alu_op == `BNE) begin
                    if (es_i_branch && ~temp_zero) begin
                        es_o_alu_pc <= alu_pc;
                        es_o_change_pc <= change_pc;
                    end
                    else begin 
                        es_o_change_pc <= 1'b0;
                        es_o_alu_pc <= es_i_pc;
                    end
                end
                if (done) begin
                    es_o_ce <= 1'b1;
                end
            end
            else begin
                es_o_change_pc <= 1'b0;
                es_o_alu_value <= {DWIDTH{1'b0}};
                es_o_alu_pc <= {PC_WIDTH{1'b0}};
                es_o_zero <= 1'b0;
                es_o_funct <= {`FUNCT_WIDTH{1'b0}};
                es_o_opcode <= {`OPCODE_WIDTH{1'b0}};
                es_o_ce <= 1'b0;
                es_o_change_pc <= 1'b0;
            end
        end
    end
endmodule
`endif
