`timescale 1ns / 1ps

module id_stage(
    input [31:0] IF_ID_instr,
    input [31:0] reg_rs1, reg_rs2,

    input EX_MEM_RegWrite,
    input [4:0] EX_MEM_rd,
    input [31:0] EX_MEM_alu,

    input MEM_WB_RegWrite,
    input [4:0] MEM_WB_rd,
    input [31:0] WB_data,

    input ID_EX_MemRead,
    input [4:0] ID_EX_rd,

    // ===== OUTPUTS =====
    output [31:0] rs1_val,
    output [31:0] rs2_val,
    output reg stall,
    output [6:0] hwlp_imm,
    output is_hwlp,
    output [4:0] rs1,
    output [4:0] rs2,
    output [6:0] opcode,

    // ===== CONTROL SIGNALS =====
    output RegWrite,
    output MemRead,
    output MemWrite,
    output ALUSrc,
    output [1:0] ALUOp,
    output [2:0] funct3,
    output [6:0] funct7,
    output [31:0] imm
);

// ================= FIELD EXTRACTION =================
assign opcode = IF_ID_instr[6:0];
assign rs1    = IF_ID_instr[19:15];
assign rs2    = IF_ID_instr[24:20];
assign funct3 = IF_ID_instr[14:12];
assign funct7 = IF_ID_instr[31:25];

assign hwlp_imm = IF_ID_instr[31:25];
assign is_hwlp  = (opcode == 7'b0001011);  // HWLP custom opcode

// ================= CONTROL UNIT =================
control_unit CU (
    .opcode(opcode),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .ALUOp(ALUOp)
);

// ================= IMMEDIATE GENERATOR =================
imm_gen IG (
    .instr(IF_ID_instr),
    .imm(imm)
);

// ================= FORWARDING =================
assign rs1_val =
    (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == rs1)) ? EX_MEM_alu :
    (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == rs1)) ? WB_data :
    reg_rs1;

assign rs2_val =
    (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == rs2)) ? EX_MEM_alu :
    (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == rs2)) ? WB_data :
    reg_rs2;

// ================= LOAD-USE STALL (FIXED) =================
always @(*) begin
    stall = 0;

    if (ID_EX_MemRead &&
        (ID_EX_rd != 0) &&   // 🔥 IMPORTANT FIX
        ((ID_EX_rd == rs1) || (ID_EX_rd == rs2)))
        stall = 1;
end

endmodule