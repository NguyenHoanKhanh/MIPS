`include "./source/decoder_stage.v"

module tb;
    parameter AWIDTH = 5;
    parameter DWIDTH = 32;
    parameter IWIDTH = 32;
    parameter IMM_WIDTH = 16;

    reg ds_clk, ds_rst;
    reg ds_i_ce;
    reg ds_i_reg_dst;
    reg ds_i_reg_wr;
    reg [DWIDTH - 1 : 0] ds_i_data_rd;
    reg [IWIDTH - 1 : 0] ds_i_instr;
    wire [`OPCODE_WIDTH - 1 : 0] ds_o_opcode;
    wire [`FUNCT_WIDTH - 1 : 0] ds_o_funct;
    wire [DWIDTH - 1 : 0] ds_o_data_rs;
    wire [DWIDTH - 1 : 0] ds_o_data_rt;
    wire [IMM_WIDTH - 1 : 0] ds_o_imm;


    decoder_stage #(
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH),
        .IWIDTH(IWIDTH),
        .IMM_WIDTH(IMM_WIDTH)
    ) ds (
        .ds_clk(ds_clk), 
        .ds_rst(ds_rst), 
        .ds_i_ce(ds_i_ce), 
        .ds_i_reg_dst(ds_i_reg_dst), 
        .ds_i_reg_wr(ds_i_reg_wr),
        .ds_i_data_rd(ds_i_data_rd), 
        .ds_i_instr(ds_i_instr),
        .ds_o_opcode(ds_o_opcode), 
        .ds_o_funct(ds_o_funct), 
        .ds_o_data_rs(ds_o_data_rs),
        .ds_o_data_rt(ds_o_data_rt), 
        .ds_o_imm(ds_o_imm)
    );

    initial begin
        ds_i_ce = 1'b0;
        ds_clk = 1'b0;
    end
    always #5 ds_clk = ~ds_clk;

    initial begin
        $dumpfile("./waveform/decoder_stage.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin
            ds_rst = 1'b0;
            repeat(counter) @(posedge ds_clk);
            ds_rst = 1'b1;
        end
    endtask

    initial begin
        reset(2);
        ds_i_ce = 1'b1;
        @(posedge ds_clk) ds_i_instr = 32'h00430820; // ADD $1,$2,$3
        // @(posedge ds_clk) ds_i_instr = 32'h00A62021; // SUB $4,$5,$6
        // @(posedge ds_clk) ds_i_instr = 32'h01093822; // AND $7,$8,$9
        // @(posedge ds_clk) ds_i_instr = 32'h016C5023; // OR  $10,$11,$12
        // @(posedge ds_clk) ds_i_instr = 32'h01CF6824; // XOR $13,$14,$15
        // @(posedge ds_clk) ds_i_instr = 32'h0424000A; // SLTI $4, $1, 10
        #20; $finish;
    end

    initial begin
        $monitor($time, " ", "ds_o_opcode = %b, ds_o_funct = %b, ds_o_data_rs = %d, ds_o_data_rt = %d, ds_o_imm = %d",
        ds_o_opcode, ds_o_funct, ds_o_data_rs, ds_o_data_rt, ds_o_imm);
    end
endmodule