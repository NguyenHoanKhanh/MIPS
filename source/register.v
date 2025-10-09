`ifndef REGISTER_V
`define REGISTER_V
`include "./source/header.vh"
module register (
    r_clk, r_rst, r_wr_en, r_data_in, r_addr_in, r_data_out1, r_data_out2, r_addr_out1, r_addr_out2 
);
    input r_clk, r_rst;
    input r_wr_en;
    input [`DWIDTH - 1 : 0] r_data_in;
    input [`AWIDTH - 1 : 0] r_addr_in;
    input [`AWIDTH - 1 : 0] r_addr_out1, r_addr_out2;
    output [`DWIDTH - 1 : 0] r_data_out1, r_data_out2;
    
    reg [`DWIDTH - 1 : 0] data_reg [((2 ** `AWIDTH) - 1): 0];
    
    integer i;  
    always @(negedge r_clk, negedge r_rst) begin
        if (!r_rst) begin
            for (i = 0; i < 1 << `AWIDTH; i = i + 1) begin
                data_reg[i] <= i;
            end
        end
        else begin
            if (r_wr_en) begin
                data_reg[r_addr_in] <= r_data_in;
            end 
        end
    end 

    assign r_data_out1 = data_reg[r_addr_out1];
    assign r_data_out2 = data_reg[r_addr_out2];
endmodule

`endif 