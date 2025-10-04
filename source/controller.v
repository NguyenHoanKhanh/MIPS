`ifndef CONTROLLER_V
`define CONTROLLER_V

`include "./source/header.vh"  
module controller (
    d_c_opcode, RegDst, Branch, MemRead, MemWrite, MemtoReg, ALUSrc, RegWrite
);
    input  [`OPCODE_WIDTH - 1: 0] d_c_opcode;
    output reg   RegDst;       // 1: rd, 0: rt
    output reg   Branch;
	output reg   MemRead; 	 
    output reg   MemtoReg;     // 1: write-back từ RAM, 0: từ ALU
    output reg   MemWrite;
    output reg   ALUSrc;     // 1: immediate, 0: register
    output reg   RegWrite;

    always @* begin
        RegDst   = 1'b0;
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;

        case (d_c_opcode)
            // ===== R-type 
            `RTYPE: begin
                RegDst   = 1'b1;  
                ALUSrc   = 1'b0;  
                RegWrite = 1'b1;
            end

            // ===== Immediate ALU ops
            `ADDI,  `ADDIU,
            `SLTI,  `SLTIU,
            `ANDI,  `ORI, `XORI : begin
                RegDst   = 1'b0;  
                ALUSrc   = 1'b1;  
                RegWrite = 1'b1;
            end

            // ===== Loads
            `LOAD: begin
                RegDst   = 1'b0; 
                ALUSrc   = 1'b1; 
                MemRead  = 1'b1;
                MemtoReg = 1'b1;  
                RegWrite = 1'b1;
            end

            // ===== Stores
            `STORE: begin
                ALUSrc   = 1'b1; 
                MemWrite = 1'b1;
            end
            default: begin
                RegDst   = 1'b0;
                Branch   = 1'b0;
                MemRead  = 1'b0;
                MemtoReg = 1'b0;
                MemWrite = 1'b0;
                ALUSrc   = 1'b0;
                RegWrite = 1'b0;
            end
        endcase
    end
endmodule

`endif
