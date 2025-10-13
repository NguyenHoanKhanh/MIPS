`ifndef DATAPATH_V
`define DATAPATH_V
`include "./source/program_counter.v"
`include "./source/imem.v"
`include "./source/decoder_stage.v"
`include "./source/execute_stage.v"
`include "./source/memory.v"

module datapath (
    d_clk, d_rst, d_i_ce, d_i_RegDst, d_i_RegWrite, d_i_ALUSrc,
    d_i_Branch, d_i_MemRead, d_i_MemWrite, d_i_MemtoReg, pc_im_o_pc,
    write_back_data, ds_es_o_opcode
);
    input d_clk, d_rst;
    input d_i_ce;
    input d_i_RegDst;
    input d_i_RegWrite;
    input d_i_Branch;
    input d_i_ALUSrc;
    input d_i_MemRead, d_i_MemWrite;
    input d_i_MemtoReg;
    output [`OPCODE_WIDTH - 1 : 0] ds_es_o_opcode;
    output [`PC_WIDTH - 1 : 0] pc_im_o_pc;
    output [`DWIDTH - 1 : 0] write_back_data;

    wire [`PC_WIDTH - 1 : 0] pc_im_o_pc;
    wire pc_im_o_ce;
    prog_counter pc (
        .pc_clk(d_clk), 
        .pc_rst(d_rst), 
        .pc_i_ce(d_i_ce), 
        .pc_i_change_pc(es_is_change_pc), 
        .pc_i_pc(es_is_o_pc), 
        .pc_o_pc(pc_im_o_pc), 
        .pc_o_ce(pc_im_o_ce)
    );

    wire [`IWIDTH - 1 : 0] fs_ds_o_instr;
    wire fs_ds_o_ce;
    imem i_m (
        .im_clk(d_clk), 
        .im_rst(d_rst), 
        .im_i_ce(pc_im_o_ce), 
        .im_i_address(pc_im_o_pc), 
        .im_o_instr(fs_ds_o_instr), 
        .im_o_ce(fs_ds_o_ce)
    );

    wire ds_es_o_ce;
    wire [`FUNCT_WIDTH - 1 : 0] ds_es_o_funct;
    wire [`DWIDTH - 1 : 0] ds_es_o_data_rs, ds_es_o_data_rt;
    wire [`IMM_WIDTH - 1 : 0] ds_es_o_imm;
    decoder_stage ds (
        .ds_clk(d_clk), 
        .ds_rst(d_rst), 
        .ds_i_ce(fs_ds_o_ce), 
        .ds_i_reg_dst(d_i_RegDst), 
        .ds_i_reg_wr(d_i_RegWrite),
        .ds_i_data_rd(write_back_data), 
        .ds_i_instr(fs_ds_o_instr), 
        .ds_o_opcode(ds_es_o_opcode), 
        .ds_o_funct(ds_es_o_funct), 
        .ds_o_data_rs(ds_es_o_data_rs), 
        .ds_o_data_rt(ds_es_o_data_rt), 
        .ds_o_imm(ds_es_o_imm),
        .ds_o_ce(ds_es_o_ce)
    );
    
    wire [`DWIDTH - 1 : 0] es_ms_alu_value;
    wire es_o_zero;
    wire [`OPCODE_WIDTH - 1 : 0] es_o_opcode;
    wire [`PC_WIDTH - 1 : 0] es_is_o_pc;
    wire [`FUNCT_WIDTH - 1 : 0] es_o_funct;
    wire es_ms_o_ce;
    wire es_is_change_pc;
    execute es (
        .es_i_ce(ds_es_o_ce), 
        .es_i_alu_src(d_i_ALUSrc), 
        .es_i_branch(d_i_Branch),
        .es_i_pc(pc_im_o_pc),
        .es_i_imm(ds_es_o_imm), 
        .es_i_alu_op(ds_es_o_opcode), 
        .es_i_alu_funct(ds_es_o_funct),
        .es_i_data_rs(ds_es_o_data_rs), 
        .es_i_data_rt(ds_es_o_data_rt), 
        .es_o_alu_value(es_ms_alu_value), 
        .es_o_alu_pc(es_is_o_pc),
        .es_o_opcode(es_o_opcode), 
        .es_o_funct(es_o_funct), 
        .es_o_zero(es_o_zero),
        .es_o_ce(es_ms_o_ce),
        .es_o_change_pc(es_is_change_pc)
    );

    wire [`DWIDTH - 1 : 0] es_load_data;
    memory m (
        .m_clk(d_clk), 
        .m_rst(d_rst), 
        .m_wr_en(d_i_MemWrite), 
        .m_rd_en(d_i_MemRead), 
        .m_i_ce(es_ms_o_ce), 
        .alu_value_addr(es_ms_alu_value),
        .m_i_store_data(ds_es_o_data_rt), 
        .m_o_load_data(es_load_data)
    );

    assign write_back_data = (d_i_MemtoReg) ? es_load_data : es_ms_alu_value;
endmodule
`endif 
