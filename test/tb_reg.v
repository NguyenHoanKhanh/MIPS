`include "./source/register.v"

module tb;
    reg r_clk, r_rst;
    reg r_wr_en;
    reg [`DWIDTH - 1 : 0] r_data_in;
    reg [`AWIDTH - 1 : 0] r_addr_in;
    wire [`DWIDTH - 1 : 0] r_data_out1, r_data_out2;
    reg [`AWIDTH - 1 : 0] r_addr_out1, r_addr_out2;
    integer i;

    register r_eg (
        .r_clk(r_clk), 
        .r_rst(r_rst), 
        .r_wr_en(r_wr_en), 
        .r_data_in(r_data_in), 
        .r_addr_in(r_addr_in), 
        .r_data_out1(r_data_out1), 
        .r_data_out2(r_data_out2), 
        .r_addr_out1(r_addr_out1), 
        .r_addr_out2(r_addr_out2) 
    );

    initial begin
        i = 0;
        r_wr_en = 1'b0;
        r_addr_in = {`AWIDTH{1'b0}};
        r_addr_out1 = {`AWIDTH{1'b0}};
        r_addr_out2 = {`AWIDTH{1'b0}};
        r_clk = 1'b0;
    end
    always #5 r_clk = ~r_clk;

    task reset (input integer counter);
        begin
            r_rst = 1'b0;
            repeat(counter) @(posedge r_clk);
            r_rst = 1'b1;
        end
    endtask 

    task load (input integer counter);
        begin
            r_wr_en = 1'b1;
            for (i = 0; i < counter; i = i + 1) begin
                @(posedge r_clk);
                r_addr_in = i;
                r_data_in = i;
            end
            @(posedge r_clk);
            r_wr_en = 1'b0;
        end
    endtask
    
    task display (input integer counter);
        begin
            for (i = 0; i < counter; i = i + 1) begin
                r_addr_out1 = i;
                r_addr_out2 = i;
                @(posedge r_clk);
                $display($time, " ", "addr 1 = %d, data 1 = %d", r_addr_out1, r_data_out1);
                $display($time, " ", "addr 2 = %d, data 2 = %d\n", r_addr_out2, r_data_out2);
            end
        end
    endtask

    initial begin
        reset(2);
        load(10);
        @(posedge r_clk);
        display(10);
        #20; $finish;
    end
endmodule