`include "./source/memory.v"

module tb;
    parameter DWIDTH = 32;
    parameter AWIDTH_MEM = 32;
    reg m_clk, m_rst;
    reg m_wr_en, m_rd_en;
    reg m_i_ce;
    reg [AWIDTH_MEM - 1 : 0] alu_value_addr;
    reg [DWIDTH - 1 : 0] m_i_store_data;
    wire [DWIDTH - 1 : 0] m_o_load_data;
    integer i;

    memory #(
        .AWIDTH_MEM(AWIDTH_MEM),
        .DWIDTH(DWIDTH)
    ) m (
        .m_clk(m_clk), 
        .m_rst(m_rst), 
        .m_wr_en(m_wr_en), 
        .m_rd_en(m_rd_en), 
        .m_i_ce(m_i_ce), 
        .alu_value_addr(alu_value_addr),
        .m_i_store_data(m_i_store_data),  
        .m_o_load_data(m_o_load_data)
    );

    initial begin
        m_i_ce = 1'b0;
        m_wr_en = 1'b0;
        m_rd_en = 1'b0;
        m_clk = 1'b0;
        i = 0;
    end
    always #5 m_clk = ~m_clk;

    initial begin
        $dumpfile("./waveform/memory.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin
            m_rst = 1'b0;
            repeat(counter) @(posedge m_clk);
            m_rst = 1'b1;
        end
    endtask

    task load_data (input integer counter);
        begin
            m_wr_en = 1'b1;
            for (i = 0; i < counter; i = i + 1) begin
                @(posedge m_clk)
                alu_value_addr = i;
                m_i_store_data = i;
            end
            @(posedge m_clk);
            m_wr_en = 1'b0;
        end
    endtask

    task display (input integer counter);
        begin
            m_rd_en = 1'b1;
            for (i = 0; i < counter; i = i + 1) begin
                @(posedge m_clk);
                alu_value_addr = i;
                @(posedge m_clk);
                $display($time, " ", "load addr = %d, load data = %d", alu_value_addr, m_o_load_data);
            end
            @(posedge m_clk);
            m_rd_en = 1'b0;
        end
    endtask

    initial begin
        reset(2);
        m_i_ce = 1'b1;
        @(posedge m_clk);
        load_data(10);
        @(posedge m_clk);
        display(10);
        @(posedge m_clk);
        m_i_ce = 1'b0;
        #20; $finish;
    end
endmodule