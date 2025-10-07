`timescale 1ns/1ps
`include "./source/decoder.v"

module tb_decoder;
    parameter AWIDTH = 5;
    parameter IWIDTH = 32; 
    parameter DWIDTH = 32;
    parameter IMM_WIDTH = 16;

    reg d_clk, d_rst;
    reg d_i_ce;
    reg [IWIDTH - 1 : 0] d_i_instr;
    reg [DWIDTH - 1 : 0] d_i_data_rd;
    wire [`OPCODE_WIDTH - 1 : 0] d_o_opcode;
    wire [`FUNCT_WIDTH  - 1 : 0] d_o_funct;
    wire [AWIDTH - 1 : 0] d_o_addr_rs, d_o_addr_rt;
    wire [AWIDTH - 1 : 0] d_o_addr_rd;
    wire [DWIDTH - 1 : 0] d_o_data_rs, d_o_data_rt;
    wire [IMM_WIDTH - 1 : 0] d_o_imm;
    wire d_i_wr_reg;

    // Instantiate decoder
    decode #(
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH),
        .IWIDTH(IWIDTH)
    ) dut (
        .d_clk(d_clk), 
        .d_rst(d_rst), 
        .d_i_ce(d_i_ce), 
        .d_i_instr(d_i_instr), 
        .d_o_opcode(d_o_opcode), 
        .d_o_funct(d_o_funct), 
        .d_o_addr_rs(d_o_addr_rs), 
        .d_o_addr_rt(d_o_addr_rt),
        .d_o_addr_rd(d_o_addr_rd), 
        .d_o_imm(d_o_imm), 
        .d_o_ce(d_o_ce)
    );

    // Clock
    initial d_clk = 0;
    always #5 d_clk = ~d_clk;

    initial begin
        $dumpfile("./waveform/decoder.vcd");
        $dumpvars(0, tb_decoder);
    end

    // Reset task
    task reset(input integer cycles);
        begin
            d_rst = 1'b0;
            repeat(cycles) @(posedge d_clk);
            d_rst = 1'b1;
            @(posedge d_clk);
        end
    endtask

    // Main test sequence
    initial begin
        d_i_ce     = 0;
        d_i_instr  = 32'h00000000;
        d_i_data_rd = 32'h00000000;

        reset(2);
        d_i_ce = 1;

        // Load 5 instructions
        @(posedge d_clk) d_i_instr = 32'h00430820; // ADD $1,$2,$3
        @(posedge d_clk) d_i_instr = 32'h00A62021; // SUB $4,$5,$6
        @(posedge d_clk) d_i_instr = 32'h01093822; // AND $7,$8,$9
        @(posedge d_clk) d_i_instr = 32'h016C5023; // OR  $10,$11,$12
        @(posedge d_clk) d_i_instr = 32'h01CF6824; // XOR $13,$14,$15
        @(posedge d_clk) d_i_instr = 32'h10410064; //ADDI $1, $2, 100

        // Thêm vài chu kỳ để quan sát output
        repeat(5) @(posedge d_clk);

        $finish;
    end

    // Monitor outputs
    initial begin
        $display("Time\t Instr\t\tOpcode\tFunct\tRS\tRT\tRD\tIMM");
        $monitor("%0t\t%h\t%0d\t%0b\t%0d\t%0d\t%0d\t%0d",
                  $time, d_i_instr, d_o_opcode, d_o_funct, 
                  dut.d_o_addr_rs, dut.d_o_addr_rt, d_o_addr_rd, d_o_imm);
    end
endmodule
