`include "./source/transmit.v"
module tb;
    parameter IWIDTH = 32;
    parameter DEPTH = 1;
    reg t_clk, t_rst;
    reg t_i_syn;
    wire [IWIDTH - 1 : 0] t_o_instr;
    wire t_o_last, t_o_ack;
    integer i;

    transmit #(
        .IWIDTH(IWIDTH),
        .DEPTH(DEPTH)
    ) t (
        .t_clk(t_clk), 
        .t_rst(t_rst), 
        .t_i_syn(t_i_syn),
        .t_o_instr(t_o_instr), 
        .t_o_last(t_o_last), 
        .t_o_ack(t_o_ack)
    );
    
    initial begin
        i = 0;
        t_i_syn = 1'b0;
        t_clk = 1'b0;
    end
    always #5 t_clk = ~t_clk;

    initial begin
        $dumpfile("./waveform/transmit.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin
            t_rst = 1'b0;
            repeat(counter) @(posedge t_clk);
            t_rst = 1'b1;
        end
    endtask

    task display (input integer counter);
        begin
            t_i_syn = 1'b1;
            for (i = 0; i < counter; i = i + 1) begin
                @(posedge t_clk);
                $display($time, " ", "instr = %h, last = %b, ack = %b", t_o_instr, t_o_last, t_o_ack);
            end
            @(posedge t_clk);
            t_i_syn = 1'b0;
        end
    endtask

    initial begin
        reset(2);
        @(posedge t_clk);
        display(1);
        #20; $finish;
    end
endmodule