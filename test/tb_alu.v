`include "./source/alu.v"

module tb;
    parameter DWIDTH = 32;
    reg [DWIDTH - 1 : 0] a_i_data_rs, a_i_data_rt;
    reg [4 - 1 : 0] a_i_funct;
    wire [DWIDTH - 1 : 0] alu_value;

    alu #(
        .DWIDTH(DWIDTH)
    ) a (
        .a_i_data_rs(a_i_data_rs), 
        .a_i_data_rt(a_i_data_rt), 
        .a_i_funct(a_i_funct),
        .alu_value(alu_value)
    );

    initial begin
        a_i_data_rt = 4;
        a_i_data_rs = 5;
        a_i_funct = 0;
        #10;
        a_i_data_rt = 4;
        a_i_data_rs = 5;
        a_i_funct = 1;
        #10;
        a_i_data_rt = 4;
        a_i_data_rs = 5;
        a_i_funct = 2;
        #10;
        a_i_data_rt = 4;
        a_i_data_rs = 5;
        a_i_funct = 3;
        #10;
        a_i_data_rt = 4;
        a_i_data_rs = 5;
        a_i_funct = 4;
        #10;
        #20; $finish;
    end

    initial begin
        $monitor($time, " ", "a_i_funct = %b, a_i_data_rs = %d, a_i_data_rt = %d, alu_value = %d", 
        a_i_funct, a_i_data_rs, a_i_data_rt, alu_value);
    end
endmodule