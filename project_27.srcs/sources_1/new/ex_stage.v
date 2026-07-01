`timescale 1ns / 1ps

module ex_stage(
    input clk, input reset,

    input [31:0] ID_EX_r1, ID_EX_r2,
    input [31:0] ID_EX_imm,
    input [4:0] ID_EX_rd,

    input ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite,
    input ID_EX_ALUSrc,
    input [1:0] ID_EX_ALUOp,
    input [2:0] ID_EX_funct3,
    input [6:0] ID_EX_funct7,

    output reg [31:0] EX_MEM_alu,
    output reg [4:0] EX_MEM_rd,
    output reg EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite
);

// ===== ALU INPUT SELECTION =====
wire [31:0] alu_in2;
assign alu_in2 = (ID_EX_ALUSrc) ? ID_EX_imm : ID_EX_r2;

// ===== ALU CONTROL =====
wire [3:0] alu_ctrl;

alu_control AC(
    .ALUOp(ID_EX_ALUOp),
    .funct3(ID_EX_funct3),
    .funct7(ID_EX_funct7),
    .alu_ctrl(alu_ctrl)
);

// ===== ALU =====
wire [31:0] alu_result;

alu ALU(
    .a(ID_EX_r1),
    .b(alu_in2),
    .alu_ctrl(alu_ctrl),
    .result(alu_result)
);

// ===== PIPELINE REGISTER =====
always @(posedge clk or posedge reset) begin
    if(reset) begin
        EX_MEM_alu <= 0;
        EX_MEM_rd <= 0;
        EX_MEM_RegWrite <= 0;
        EX_MEM_MemRead <= 0;
        EX_MEM_MemWrite <= 0;
    end
    else begin
        EX_MEM_alu <= alu_result;
        EX_MEM_rd <= ID_EX_rd;
        EX_MEM_RegWrite <= ID_EX_RegWrite;
        EX_MEM_MemRead <= ID_EX_MemRead;
        EX_MEM_MemWrite <= ID_EX_MemWrite;
    end
end

endmodule