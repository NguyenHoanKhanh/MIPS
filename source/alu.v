`ifndef ALU_V
`define ALU_V
`include "./source/header.vh"
module alu #(
    parameter DWIDTH = 32
) (
    a_i_data_rs, a_i_data_rt, a_i_funct, alu_value, done
);
    input  [DWIDTH - 1 : 0] a_i_data_rs;
    input  [DWIDTH - 1 : 0] a_i_data_rt;
    input  [3 : 0]         a_i_funct;
    output reg [DWIDTH - 1 : 0] alu_value;
    output reg done;

    // funct signals (optional, for readability)
    wire funct_add  = a_i_funct == 0;
    wire funct_sub  = a_i_funct == 1;
    wire funct_and  = a_i_funct == 2;
    wire funct_or   = a_i_funct == 3;
    wire funct_xor  = a_i_funct == 4;
    wire funct_slt  = a_i_funct == 5;
    wire funct_sltu = a_i_funct == 6;
    wire funct_sll  = a_i_funct == 7;
    wire funct_srl  = a_i_funct == 8;
    wire funct_sra  = a_i_funct == 9;
    wire funct_eq   = a_i_funct == 10;
    wire funct_neq  = a_i_funct == 11;
    wire funct_ge   = a_i_funct == 12;
    wire funct_geu  = a_i_funct == 13;
    wire funct_addu = a_i_funct == 14;
    // combinational ALU: always @*
    always @(*) begin
        alu_value = {DWIDTH{1'b0}};
        done = 1'b0;
        if (funct_add) begin
            alu_value = a_i_data_rs + a_i_data_rt;
            done = 1'b1;
        end
        else if (funct_addu) begin
            alu_value = $unsigned(a_i_data_rs) + $unsigned(a_i_data_rt);
            done = 1'b1;
        end
        else if (funct_sub) begin
            alu_value = a_i_data_rs - a_i_data_rt;
            done = 1'b1;
        end
        else if (funct_and) begin
            alu_value = a_i_data_rs & a_i_data_rt;
            done = 1'b1;
        end
        else if (funct_or) begin
            alu_value = a_i_data_rs | a_i_data_rt;
            done = 1'b1;
        end
        else if (funct_xor) begin
            alu_value = a_i_data_rs ^ a_i_data_rt;
            done = 1'b1;
        end
        else if (funct_slt) begin
            if (($signed(a_i_data_rs) < $signed(a_i_data_rt))) begin
                alu_value = {{(DWIDTH - 1){1'b0}},1'b1};
            end
            else begin
                alu_value = {DWIDTH{1'b0}};
            end
            done = 1'b1;
        end
        else if (funct_sltu) begin
            if (($unsigned(a_i_data_rs) < $unsigned(a_i_data_rt))) begin
                alu_value ={{(DWIDTH - 1){1'b0}},1'b1};
            end
            else begin
                alu_value = {DWIDTH{1'b0}};
            end
            done = 1'b1;
        end
        else if (funct_sll) begin
            alu_value = a_i_data_rs << a_i_data_rt[4 : 0];
            done = 1'b1;
        end
        else if (funct_srl) begin
            alu_value = a_i_data_rs >> a_i_data_rt[4 : 0];
            done = 1'b1;
        end
        else if (funct_sra) begin
            alu_value = $signed(a_i_data_rs) >>> a_i_data_rt[4 : 0];
            done = 1'b1;
        end
        else if (funct_eq) begin
            alu_value = (a_i_data_rs == a_i_data_rt) ? 32'd1 : 32'd0;
            done = 1'b1;
        end
        else if (funct_neq) begin
            alu_value = (a_i_data_rs == a_i_data_rt) ? 32'd0 : 32'd1;
            done = 1'b1;
        end
        else if (funct_ge) begin
            if (($signed(a_i_data_rs) >= $signed(a_i_data_rt))) begin
                alu_value = {{(DWIDTH - 1){1'b0}},1'b1};
            end
            else begin
                alu_value = {DWIDTH{1'b0}};
            end
            done = 1'b1;
        end
        else if (funct_geu) begin
            if (($unsigned(a_i_data_rs) >= $unsigned(a_i_data_rt))) begin
                alu_value = {{(DWIDTH - 1){1'b0}},1'b1};
            end
            else begin
                alu_value = {DWIDTH{1'b0}};
            end
            done = 1'b1;
        end
        else begin
            alu_value = {DWIDTH{1'b0}};
            done = 1'b0;
        end
    end

endmodule
`endif
