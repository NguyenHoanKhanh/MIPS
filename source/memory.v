`ifndef MEMORY_V
`define MEMORY_V

module memory #(
    parameter DWIDTH = 32,
    parameter AWIDTH_MEM = 32
) (
    m_clk, m_rst, m_wr_en, m_rd_en, m_i_ce, m_i_store_data, 
    alu_value_addr, m_o_load_data
);
    input m_clk, m_rst;
    input m_wr_en, m_rd_en;    
    input m_i_ce;
    input [AWIDTH_MEM - 1 : 0] alu_value_addr;
    input [DWIDTH - 1 : 0] m_i_store_data;
    output reg [DWIDTH - 1 : 0] m_o_load_data;
    integer i;
    reg [DWIDTH - 1 : 0] data_mem [0 : AWIDTH_MEM - 1];

    always @(posedge m_clk, negedge m_rst) begin
        if (!m_rst) begin
            for (i = 0; i < AWIDTH_MEM; i = i + 1) begin
                data_mem[i] <= {DWIDTH{1'b0}};   
            end
            m_o_load_data <= {DWIDTH{1'b0}};
        end
        else begin
            if (m_i_ce) begin
                if (m_wr_en) begin
                    data_mem[alu_value_addr] <= m_i_store_data;
                end
                if (m_rd_en) begin
                    m_o_load_data <= data_mem[alu_value_addr];
                end
            end
        end
    end
endmodule
`endif 