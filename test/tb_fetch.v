`include "./source/instruction_fetch.v"
module tb;
    parameter IWIDTH = 32;
    parameter PC_WIDTH = 32;
    parameter DEPTH = 6;
    
    reg f_clk, f_rst;
    reg f_i_ce;
    reg f_i_change_pc;
    reg [PC_WIDTH - 1 : 0] f_i_pc;
    wire [IWIDTH - 1 : 0] f_o_instr;
    wire [PC_WIDTH - 1 : 0] f_o_pc; 
    wire f_o_ce;
    integer i;

    instruction_fetch #(
        .IWIDTH(IWIDTH),
        .DEPTH(DEPTH),
        .PC_WIDTH(PC_WIDTH)
    ) f (
        .f_clk(f_clk), 
        .f_rst(f_rst), 
        .f_i_ce(f_i_ce), 
        .f_i_change_pc(f_i_change_pc),
        .f_i_pc(f_i_pc),
        .f_o_instr(f_o_instr), 
        .f_o_pc(f_o_pc),
        .f_o_ce(f_o_ce)
    );

    initial begin
        f_clk = 1'b0;
    end
    always #5 f_clk = ~f_clk;

    initial begin
        $dumpfile("./waveform/fetch.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin
            f_rst = 1'b0;
            repeat(counter) @(posedge f_clk);
            f_rst = 1'b1;
        end
    endtask 

    task display (input integer counter);
        begin
            f_i_ce = 1'b1;
            for (i = 0; i < counter; i = i + 1) begin
                @(posedge f_clk);
                $display($time, " ", "instr = %h, pc = %d, last = %b, syn = %b, ack = %b, ce = %b", f_o_instr, f_o_pc, f.f_i_last, f.f_o_syn, f.f_i_ack, f_o_ce); 
            end
            f_i_ce = 1'b0;
        end
    endtask

    initial begin
        reset(2);
        display(9);
        repeat(10) @(posedge f_clk);
        $finish;
    end
endmodule