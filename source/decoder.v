`ifndef DECODER_V
`define DECODER_V
`include "./source/header.vh"
module decode #(
    parameter AWIDTH = 5,
    parameter IWIDTH = 32, 
    parameter DWIDTH = 32,
    parameter IMM_WIDTH = 16
)(
    d_clk, d_rst, d_i_ce, d_i_instr, d_o_opcode, d_o_funct, d_o_addr_rs, d_o_addr_rt,
    d_o_addr_rd, d_o_imm, d_o_ce
);
    input d_clk, d_rst;
    input [IWIDTH - 1 : 0] d_i_instr;
    input d_i_ce;
    output reg [AWIDTH - 1 : 0] d_o_addr_rs, d_o_addr_rt, d_o_addr_rd;
    output reg [`OPCODE_WIDTH - 1 : 0] d_o_opcode;
    output reg [`FUNCT_WIDTH - 1 : 0] d_o_funct;
    output reg [IMM_WIDTH - 1 : 0] d_o_imm;
    output reg d_o_ce;

    wire [DWIDTH - 1 : 0] d_i_data_rs, d_i_data_rt;
    reg [IWIDTH - 1 : 0] temp_instr;

    wire [`OPCODE_WIDTH - 1 : 0] d_i_opcode = temp_instr[31 : 26];
    wire [`FUNCT_WIDTH - 1 : 0] d_i_funct = temp_instr[5 : 0];

    wire op_rtype = d_i_opcode == `RTYPE;
    wire op_load = d_i_opcode == `LOAD;
    wire op_store = d_i_opcode == `STORE;
    wire op_branch = d_i_opcode == `BRANCH;
    wire op_addi = d_i_opcode == `ADDI;
    wire op_addiu = d_i_opcode == `ADDIU;
    wire op_slti = d_i_opcode == `SLTI;
    wire op_sltiu = d_i_opcode == `SLTIU;
    wire op_andi = d_i_opcode == `ANDI;
    wire op_ori = d_i_opcode == `ORI;
    wire op_xori = d_i_opcode == `XORI;
    
    wire funct_add = d_i_funct == `ADD;
    wire funct_sub = d_i_funct == `SUB;
    wire funct_and = d_i_funct == `AND;
    wire funct_or = d_i_funct == `OR;
    wire funct_xor = d_i_funct == `XOR;

    always @(posedge d_clk, negedge d_rst) begin
        if (!d_rst) begin
            d_o_addr_rs <= {AWIDTH{1'b0}};
            d_o_addr_rt <= {AWIDTH{1'b0}};
            d_o_addr_rd <= {AWIDTH{1'b0}};
            d_o_opcode <= {`OPCODE_WIDTH{1'b0}};
            d_o_funct <= {`FUNCT_WIDTH{1'b0}};
            d_o_imm <= {DWIDTH{1'b0}};
            d_o_ce <= 1'b0;
        end 
        else begin
            if (d_i_ce) begin
                temp_instr <= d_i_instr;
                if (op_rtype) begin
                    d_o_addr_rs <= temp_instr[25 : 21];
                    d_o_addr_rt <= temp_instr[20 : 16];
                    d_o_addr_rd <= temp_instr[15 : 11];
                    d_o_opcode <= temp_instr[31 : 26];
                    d_o_funct <= temp_instr[5 : 0];
                    d_o_imm <= {DWIDTH{1'b0}};
                    d_o_ce <= 1'b1;
                end
                else if (op_load || op_store) begin
                    d_o_addr_rs <= temp_instr[25 : 21];
                    d_o_addr_rt <= temp_instr[20 : 16];
                    d_o_addr_rd <= {AWIDTH{1'b0}};
                    d_o_opcode <= temp_instr[31 : 26];
                    d_o_funct <= {`FUNCT_WIDTH{1'b0}};
                    d_o_imm <= temp_instr[15 : 0];
                    d_o_ce <= 1'b1;
                end
                else if (op_addi || op_addiu || op_slti || op_sltiu || op_andi || op_ori || op_xori) begin
                    d_o_addr_rs <= temp_instr[25 : 21];
                    d_o_addr_rt <= temp_instr[20 : 16];
                    d_o_addr_rd <= {AWIDTH{1'b0}};
                    d_o_opcode <= temp_instr[31 : 26];
                    d_o_funct <= {`FUNCT_WIDTH{1'b0}};
                    d_o_imm <= temp_instr[15 : 0];
                    d_o_ce <= 1'b1;
                end
                else begin
                    d_o_addr_rs <= {AWIDTH{1'b0}};
                    d_o_addr_rt <= {AWIDTH{1'b0}};
                    d_o_addr_rd <= {AWIDTH{1'b0}};
                    d_o_opcode <= {`OPCODE_WIDTH{1'b0}};
                    d_o_funct <= {`FUNCT_WIDTH{1'b0}};
                    d_o_imm <= {IMM_WIDTH{1'b0}};
                    d_o_ce <= 1'b0;
                end
            end
            else begin
                d_o_addr_rs <= {AWIDTH{1'b0}};
                d_o_addr_rt <= {AWIDTH{1'b0}};
                d_o_addr_rd <= {AWIDTH{1'b0}};
                d_o_opcode <= {`OPCODE_WIDTH{1'b0}};
                d_o_funct <= {`FUNCT_WIDTH{1'b0}};
                d_o_imm <= {DWIDTH{1'b0}};
                d_o_ce <= 1'b0;
            end
        end
    end
endmodule
`endif 