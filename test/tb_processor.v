`include "./source/processor.v"

module tb;
    parameter DWIDTH = 32;
    parameter IWIDTH = 32;
    parameter AWIDTH = 5;
    parameter PC_WIDTH = 32;
    parameter DEPTH = 5;
    parameter AWIDTH_MEM = 32;
    parameter IMM_WIDTH = 16;

    reg p_clk;
    reg p_rst;
    reg p_i_ce;
    wire [PC_WIDTH - 1 : 0] p_o_pc;
    wire [DWIDTH - 1 : 0] p_wb_data;

    processor #(
        .DWIDTH(DWIDTH),
        .IWIDTH(IWIDTH),
        .AWIDTH(AWIDTH),
        .PC_WIDTH(PC_WIDTH),
        .DEPTH(DEPTH),
        .AWIDTH_MEM(AWIDTH_MEM),
        .IMM_WIDTH(IMM_WIDTH)
    ) p (
        .p_clk(p_clk), 
        .p_rst(p_rst), 
        .p_i_ce(p_i_ce), 
        .p_o_pc(p_o_pc), 
        .p_wb_data(p_wb_data)
    );

    initial begin
        p_clk = 1'b0;
    end
    always #5 p_clk = ~p_clk;

    initial begin
        $dumpfile("./waveform/processor.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin
            p_rst = 1'b0;
            repeat(counter) @(posedge p_clk);
            p_rst = 1'b1;
        end
    endtask

    initial begin
        reset(2);
        @(posedge p_clk);
        p_i_ce = 1'b1;
        repeat(13) @(posedge p_clk);
        $finish;
    end

    initial begin
        $monitor($time, " ", "p_o_pc = %d, p_wb_data = %d", p_o_pc, p_wb_data);
    end
endmodule