`ifndef MEMORY_V
`define MEMORY_V
`include "./source/header.vh"
module memory (
    m_clk, m_rst, m_wr_en, m_rd_en, m_i_ce, m_i_store_data, 
    alu_value_addr, m_o_load_data
);
    input m_clk, m_rst;
    input m_wr_en, m_rd_en;    
    input m_i_ce;
    input [`AWIDTH_MEM - 1 : 0] alu_value_addr;
    input [`DWIDTH - 1 : 0] m_i_store_data;
    output [`DWIDTH - 1 : 0] m_o_load_data;
    integer i;
    reg [`DWIDTH - 1 : 0] data_mem [0 : `AWIDTH_MEM - 1];

    always @(negedge m_clk, negedge m_rst) begin
        if (!m_rst) begin
            for (i = 0; i < `AWIDTH_MEM; i = i + 1) begin
                data_mem[i] <= i;   
            end
        end
        else begin
            if (m_i_ce) begin
                if (m_wr_en) begin
                    data_mem[alu_value_addr] <= m_i_store_data;
                end
            end
        end
    end
    assign m_o_load_data = data_mem[alu_value_addr];
endmodule
`endif 