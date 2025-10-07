`include "./source/datapath.v"

module tb;
    parameter DWIDTH = 32;
    parameter IWIDTH = 32;
    parameter AWIDTH = 5;      
    parameter PC_WIDTH = 32;
    parameter DEPTH = 5;
    parameter AWIDTH_MEM = 32;

    reg d_clk, d_rst;
    reg d_i_ce;
    reg d_i_RegDst;
    reg d_i_RegWrite;
    reg d_i_Branch;
    reg d_i_ALUSrc; 
    reg d_i_MemRead, d_i_MemWrite;
    reg d_i_MemtoReg;
    wire [`OPCODE_WIDTH - 1 : 0] ds_es_o_opcode;
    wire [PC_WIDTH - 1 : 0] fs_es_o_pc;
    wire [DWIDTH - 1 : 0] write_back_data;

    datapath #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .IWIDTH(IWIDTH),
        .PC_WIDTH(PC_WIDTH),
        .DEPTH(DEPTH),
        .AWIDTH_MEM(AWIDTH_MEM)
    ) d (
        .d_clk(d_clk), 
        .d_rst(d_rst), 
        .d_i_ce(d_i_ce), 
        .d_i_RegDst(d_i_RegDst), 
        .d_i_Branch(d_i_Branch),
        .d_i_RegWrite(d_i_RegWrite), 
        .d_i_ALUSrc(d_i_ALUSrc), 
        .d_i_MemRead(d_i_MemRead), 
        .d_i_MemWrite(d_i_MemWrite), 
        .d_i_MemtoReg(d_i_MemtoReg), 
        .fs_es_o_pc(fs_es_o_pc),
        .write_back_data(write_back_data),
        .ds_es_o_opcode(ds_es_o_opcode)
    );

    initial begin
        d_clk = 1'b0;
    end
    always #5 d_clk = ~d_clk;

    initial begin
        $dumpfile("./waveform/datapath.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin
            d_rst = 1'b0;
            repeat(counter) @(posedge d_clk);
            d_rst = 1'b1;
        end
    endtask

    initial begin
        reset(2);
        @(posedge d_clk);
        d_i_ce = 1'b1;
        @(posedge d_clk);
        // --- KHỞI TẠO CÁC TÍN HIỆU control --- (RẤT QUAN TRỌNG)
        d_i_RegDst   = 1'b1; // R-type: chọn rd
        d_i_RegWrite = 1'b1; // enable write-back vào regfile
        d_i_ALUSrc   = 1'b0; // ALU operand from register (rt), không immediate
        d_i_MemRead  = 1'b0;
        d_i_MemWrite = 1'b0;
        d_i_MemtoReg = 1'b0; // write back từ ALU, không từ mem
        repeat(7) @(posedge d_clk);
        $finish;
    end

    initial begin  
        $monitor("%0t: PC=%h, instr=%h, rs_data=%h, rt_data=%h, alu_out=%h, ds_es_o_opcode = %b", 
            $time, fs_es_o_pc, d.fs_ds_o_instr, d.ds_es_o_data_rs, 
            d.ds_es_o_data_rt, d.es_ms_alu_value, ds_es_o_opcode);
    end
endmodule
