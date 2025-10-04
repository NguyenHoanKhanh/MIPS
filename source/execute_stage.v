`ifndef EXECUTE_STAGE_V
`define EXECUTE_STAGE_V
`include "./source/alu.v"
`include "./source/header.vh"

module execute #(
    parameter DWIDTH = 32,
    parameter IMM_WIDTH = 16
) (
    es_clk, es_rst, es_i_ce, es_i_alu_src, es_i_imm, es_i_alu_op, es_i_alu_funct,
    es_i_data_rs, es_i_data_rt, es_o_alu_value, es_o_opcode, es_o_funct, es_o_zero,
    es_o_ce
);
    input  es_clk, es_rst;
    input  es_i_ce;
    input  es_i_alu_src;
    input  [IMM_WIDTH - 1 : 0] es_i_imm;
    input  [`OPCODE_WIDTH - 1 : 0] es_i_alu_op;
    input  [`FUNCT_WIDTH - 1 : 0]  es_i_alu_funct;
    input  [DWIDTH - 1 : 0] es_i_data_rs, es_i_data_rt;
    output reg [DWIDTH - 1 : 0] es_o_alu_value;
    output reg [`OPCODE_WIDTH - 1 : 0] es_o_opcode;
    output reg [`FUNCT_WIDTH - 1 : 0]  es_o_funct;
    output reg es_o_zero;
    output reg es_o_ce;

    // sign-extend immediate (parameterized)
    wire [DWIDTH - 1 : 0] es_imm = {{(DWIDTH-IMM_WIDTH){es_i_imm[IMM_WIDTH-1]}}, es_i_imm};
    wire [DWIDTH - 1 : 0] es_o_data_2 = (es_i_alu_src) ? es_imm : es_i_data_rt;

    // alu_control computed combinationally from opcode/funct
    reg [3:0] alu_control;
    always @* begin
        alu_control = 4'd0;
        if (es_i_alu_op == `RTYPE) begin
            case (es_i_alu_funct)
                `ADD:  alu_control = 4'd0;
                `SUB:  alu_control = 4'd1;
                `AND:  alu_control = 4'd2;
                `OR:   alu_control = 4'd3;
                `XOR:  alu_control = 4'd4;
                `SLT:  alu_control = 4'd5;
                `SLTU: alu_control = 4'd6;
                `SLL:  alu_control = 4'd7;
                `SRL:  alu_control = 4'd8;
                `SRA:  alu_control = 4'd9;
                `EQ:   alu_control = 4'd10;
                `NEQ:  alu_control = 4'd11;
                `GE:   alu_control = 4'd12;
                `GEU:  alu_control = 4'd13;
                `ADDIU : alu_control = 4'd14;
                default: alu_control = 4'd0;
            endcase
        end
        else if (es_i_alu_op == `LOAD || es_i_alu_op == `STORE) begin
            alu_control = 4'd0;
        end
        else if (es_i_alu_op == `ADDI) begin
            alu_control = 4'd0;
        end
        else if (es_i_alu_op == `ADDIU) begin
            alu_control = 4'd14;
        end
        else if (es_i_alu_op == `SLTI) begin
            alu_control = 4'd5;
        end
        else if (es_i_alu_op == `SLTIU) begin
            alu_control = 4'd6;
        end
        else if (es_i_alu_op == `ANDI) begin
            alu_control = 4'd2;
        end
        else if (es_i_alu_op == `ORI) begin
            alu_control = 4'd3;
        end
        else if (es_i_alu_op == `XORI) begin
            alu_control = 4'd4;
        end
    end

    // instantiate combinational ALU
    wire [DWIDTH - 1 : 0] alu_value;
    wire done;
    alu #(.DWIDTH(DWIDTH)) a (
        .a_i_data_rs(es_i_data_rs),
        .a_i_data_rt(es_o_data_2),
        .a_i_funct(alu_control),
        .alu_value(alu_value),
        .done(done)
    );
    // register outputs on clock
    always @(posedge es_clk or negedge es_rst) begin
        if (!es_rst) begin
            es_o_alu_value <= {DWIDTH{1'b0}};
            es_o_zero <= 1'b0;
            es_o_funct <= {`FUNCT_WIDTH{1'b0}};
            es_o_opcode <= {`OPCODE_WIDTH{1'b0}};
            es_o_ce <= 1'b0;
        end
        else begin
            if (es_i_ce) begin
                es_o_alu_value <= alu_value;
                es_o_opcode <= es_i_alu_op;
                es_o_funct  <= es_i_alu_funct;
                es_o_ce <= 1'b1;
                es_o_zero <= (alu_value == {DWIDTH{1'b0}}) ? 1'b1 : 1'b0;
                if (done) begin
                    es_o_ce <= 1'b0;
                end
            end
            else begin
                es_o_alu_value <= {DWIDTH{1'b0}};
                es_o_zero <= 1'b0;
                es_o_ce <= 1'b0;
            end
        end
    end
endmodule
`endif
