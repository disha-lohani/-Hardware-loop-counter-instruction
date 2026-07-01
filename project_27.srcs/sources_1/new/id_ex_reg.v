`timescale 1ns / 1ps

module id_ex_reg(
    input clk, input reset,
    input stall, input flush,

    input [31:0] rs1_val, rs2_val, IF_ID_PC,
    input [4:0] rd,
    input [6:0] hwlp_imm,
    input is_hwlp,

    input RegWrite, MemRead, MemWrite, ALUSrc,
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    input [31:0] imm,

    output reg [31:0] ID_EX_r1, ID_EX_r2, ID_EX_PC,
    output reg [4:0] ID_EX_rd,
    output reg ID_EX_MemRead, ID_EX_RegWrite, ID_EX_MemWrite,
    output reg ID_EX_ALUSrc,
    output reg [1:0] ID_EX_ALUOp,
    output reg [2:0] ID_EX_funct3,
    output reg [6:0] ID_EX_funct7,
    output reg [31:0] ID_EX_imm,
    output reg [6:0] ID_EX_hwlp_imm,
    output reg ID_EX_is_hwlp
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        // FULL RESET
        ID_EX_r1 <= 0; ID_EX_r2 <= 0; ID_EX_PC <= 0;
        ID_EX_rd <= 0;

        ID_EX_MemRead <= 0;
        ID_EX_RegWrite <= 0;
        ID_EX_MemWrite <= 0;

        ID_EX_ALUSrc <= 0;
        ID_EX_ALUOp <= 0;
        ID_EX_funct3 <= 0;
        ID_EX_funct7 <= 0;
        ID_EX_imm <= 0;

        ID_EX_hwlp_imm <= 0;
        ID_EX_is_hwlp <= 0;
    end

    // ===== FLUSH (control hazard / loop redirect) =====
    else if(flush) begin
        // kill instruction
        ID_EX_r1 <= 0; ID_EX_r2 <= 0; ID_EX_PC <= 0;
        ID_EX_rd <= 0;

        ID_EX_MemRead <= 0;
        ID_EX_RegWrite <= 0;
        ID_EX_MemWrite <= 0;

        ID_EX_ALUSrc <= 0;
        ID_EX_ALUOp <= 0;
        ID_EX_funct3 <= 0;
        ID_EX_funct7 <= 0;
        ID_EX_imm <= 0;

        ID_EX_hwlp_imm <= 0;
        ID_EX_is_hwlp <= 0;
    end

    // ===== 🔥 KEY FIX: STALL = INSERT BUBBLE =====
    else if(stall) begin
        // insert NOP (bubble)
        ID_EX_r1 <= 0; 
        ID_EX_r2 <= 0; 
        ID_EX_PC <= 0;
        ID_EX_rd <= 0;

        ID_EX_MemRead <= 0;
        ID_EX_RegWrite <= 0;
        ID_EX_MemWrite <= 0;

        ID_EX_ALUSrc <= 0;
        ID_EX_ALUOp <= 0;
        ID_EX_funct3 <= 0;
        ID_EX_funct7 <= 0;
        ID_EX_imm <= 0;

        ID_EX_hwlp_imm <= 0;
        ID_EX_is_hwlp <= 0;
    end

    // ===== NORMAL PIPELINE =====
    else begin
        ID_EX_r1 <= rs1_val;
        ID_EX_r2 <= rs2_val;
        ID_EX_PC <= IF_ID_PC;
        ID_EX_rd <= rd;

        ID_EX_MemRead <= MemRead;
        ID_EX_RegWrite <= RegWrite;
        ID_EX_MemWrite <= MemWrite;

        ID_EX_ALUSrc <= ALUSrc;
        ID_EX_ALUOp <= ALUOp;

        ID_EX_funct3 <= funct3;
        ID_EX_funct7 <= funct7;

        ID_EX_imm <= imm;

        ID_EX_hwlp_imm <= hwlp_imm;
        ID_EX_is_hwlp <= is_hwlp;
    end
end

endmodule