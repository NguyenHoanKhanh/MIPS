`ifndef PROGRAM_COUNTER_V
`define PROGRAM_COUNTER_V
`include "./source/header.vh"
module prog_counter (
    pc_clk, pc_rst, pc_i_ce, pc_i_change_pc, pc_i_pc, pc_o_pc, pc_o_ce
);
    input pc_clk, pc_rst;
    input pc_i_ce;
    input pc_i_change_pc;
    input [`PC_WIDTH - 1 : 0] pc_i_pc;
    output reg [`PC_WIDTH - 1 : 0] pc_o_pc;
    output reg pc_o_ce;
    reg [`PC_WIDTH - 1 : 0] temp_pc;

    always @(posedge pc_clk or negedge pc_rst) begin
        if (!pc_rst) begin
            pc_o_pc <= {`PC_WIDTH{1'b0}};
            pc_o_ce <= 1'b0;
            temp_pc <= {`PC_WIDTH{1'b0}};
        end
        else begin
            if (pc_i_ce) begin
                pc_o_pc <= temp_pc;
                pc_o_ce <= 1'b1;
                if (pc_i_change_pc) begin
                    temp_pc <= pc_i_pc;
                end
                else begin
                    temp_pc <= temp_pc + 4;
                end
            end
        end
    end
endmodule
`endif 