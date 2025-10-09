`ifndef DECODER_STAGE_V
`define DECODER_STAGE_V
`include "./source/decoder.v"
`include "./source/register.v"
`include "./source/header.vh"
module decoder_stage (
    ds_clk, ds_rst, ds_i_ce, ds_i_reg_dst, ds_i_data_rd, ds_i_instr, ds_o_opcode, 
    ds_o_funct, ds_o_data_rs, ds_o_data_rt, ds_o_imm, ds_o_ce, ds_i_reg_wr
);
    input ds_clk, ds_rst;
    input ds_i_ce;
    input ds_i_reg_dst;
    input ds_i_reg_wr;
    input [`DWIDTH - 1 : 0] ds_i_data_rd;
    input [`IWIDTH - 1 : 0] ds_i_instr;
    output [`OPCODE_WIDTH - 1 : 0] ds_o_opcode;
    output [`FUNCT_WIDTH - 1 : 0] ds_o_funct;
    output [`DWIDTH - 1 : 0] ds_o_data_rs, ds_o_data_rt;
    output [`IMM_WIDTH - 1 : 0] ds_o_imm;
    output ds_o_ce;
    wire [`AWIDTH - 1 : 0] d_o_addr_rs, d_o_addr_rt;
    wire [`AWIDTH - 1 : 0] ds_i_addr_rd;
    
    decode d (
        .d_i_ce(ds_i_ce), 
        .d_i_instr(ds_i_instr), 
        .d_o_opcode(ds_o_opcode), 
        .d_o_funct(ds_o_funct), 
        .d_o_addr_rs(d_o_addr_rs), 
        .d_o_addr_rt(d_o_addr_rt), 
        .d_o_addr_rd(ds_i_addr_rd), 
        .d_o_imm(ds_o_imm),
        .d_o_ce(ds_o_ce)
    );

    wire [`AWIDTH - 1 : 0] write_register;
    assign write_register = (ds_i_reg_dst) ? ds_i_addr_rd : d_o_addr_rt;

    register r (
        .r_clk(ds_clk), 
        .r_rst(ds_rst), 
        .r_wr_en(ds_i_reg_wr), 
        .r_data_in(ds_i_data_rd), 
        .r_addr_in(write_register), 
        .r_addr_out1(d_o_addr_rs), 
        .r_addr_out2(d_o_addr_rt),
        .r_data_out1(ds_o_data_rs), 
        .r_data_out2(ds_o_data_rt) 
    );
endmodule
`endif 