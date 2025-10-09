`ifndef INSTRUCTION_FETCH_V
`define INSTRUCTION_FETCH_V
`include "./source/transmit.v"

module instruction_fetch (
    f_clk, f_rst, f_i_ce, f_i_change_pc, f_i_pc, f_o_instr, f_o_pc, f_o_ce
);
    input f_clk, f_rst;
    input f_i_ce;
    input f_i_change_pc;
    input [`PC_WIDTH - 1 : 0] f_i_pc;
    output reg [`IWIDTH - 1 : 0] f_o_instr;
    output reg [`PC_WIDTH - 1 : 0] f_o_pc;
    output reg f_o_ce;
    wire [`IWIDTH - 1 : 0] f_i_instr;
    wire f_i_ack;
    wire f_i_last;
    reg f_o_syn;
    reg [`PC_WIDTH - 1 : 0] cur_pc;
    wire [`PC_WIDTH - 1 : 0] temp_pc;
    transmit t (
        .t_clk(f_clk), 
        .t_rst(f_rst), 
        .t_i_syn(f_o_syn), 
        .t_o_instr(f_i_instr), 
        .t_o_last(f_i_last), 
        .t_o_ack(f_i_ack)
    );
    always@(posedge f_clk, negedge f_rst) begin
        if (!f_rst) begin
            f_o_instr <= {`IWIDTH{1'b0}};
            f_o_pc <= {`PC_WIDTH{1'b0}};
            f_o_syn <= 1'b0;
            f_o_ce <= 1'b0;
            cur_pc <= {`PC_WIDTH{1'b0}};
        end
        else begin
            if (f_i_ce) begin
                // cur_pc <= ;
                f_o_pc <= (f_i_change_pc) ? f_i_pc : f_o_pc + 4;
                f_o_syn <= (f_i_last && f_i_ack) ? 1'b0 : 1'b1;
                if (f_i_ack) begin
                    f_o_instr <= f_i_instr;
                    f_o_ce <= 1'b1;
                end
                else begin
                    f_o_ce <= 1'b0;
                end
            end
            else begin
                f_o_ce <= 1'b0;
                f_o_syn <= 1'b0;
                f_o_instr <= {`IWIDTH{1'b0}};
                f_o_pc <= {`PC_WIDTH{1'b0}};
            end
        end
    end
endmodule
`endif 