`timescale 1ns / 1ps

module pipelined_cpu_hwlp(
    input clk,
    input reset,
    output [3:0] debug_pc,
    output debug_active,

    // 🔥 DEBUG OUTPUTS (CRITICAL)
    output [31:0] dbg_PC,
    output [31:0] dbg_HWLP_COUNT,
    output dbg_HWLP_ACTIVE,
    output dbg_loop_redirect,
    output dbg_stall
);

// ================= MEMORY =================
reg [31:0] instr_mem [0:255];
reg [31:0] regfile   [0:31];

integer i;
initial begin
    for(i=0;i<32;i=i+1) regfile[i] = 0;
    for(i=0;i<256;i=i+1) instr_mem[i] = 0;
end

// ================= WIRES =================
wire [31:0] PC, instruction;
wire [31:0] IF_ID_instr, IF_ID_PC;

wire [4:0] rs1, rs2;
wire [6:0] opcode, hwlp_imm;
wire is_hwlp;

wire [31:0] rs1_val, rs2_val;

// CONTROL
wire RegWrite, MemRead, MemWrite, ALUSrc;
wire [1:0] ALUOp;
wire [2:0] funct3;
wire [6:0] funct7;
wire [31:0] imm;

wire stall, flush;

// ID/EX
wire [31:0] ID_EX_r1, ID_EX_r2, ID_EX_PC;
wire [31:0] ID_EX_imm;
wire [4:0]  ID_EX_rd;
wire ID_EX_MemRead, ID_EX_RegWrite, ID_EX_MemWrite;
wire ID_EX_ALUSrc;
wire [1:0] ID_EX_ALUOp;
wire [2:0] ID_EX_funct3;
wire [6:0] ID_EX_funct7;
wire [6:0] ID_EX_hwlp_imm;
wire ID_EX_is_hwlp;

// EX/MEM
wire [31:0] EX_MEM_alu;
wire [4:0]  EX_MEM_rd;
wire EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite;

// MEM/WB
wire [31:0] MEM_WB_data;
wire [4:0]  MEM_WB_rd;
wire MEM_WB_RegWrite;

wire [31:0] WB_data;

// HWLP
wire [31:0] HWLP_COUNT, HWLP_START, HWLP_END_PC;
wire HWLP_ACTIVE;
wire loop_redirect;


// ================= IF =================
assign instruction = instr_mem[PC >> 2];

if_stage IF (
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .loop_redirect(loop_redirect),
    .HWLP_START(HWLP_START),
    .PC(PC)
);

// ================= IF/ID =================
assign flush = loop_redirect;

if_id_reg IF_ID (
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush),
    .instruction(instruction),
    .PC(PC),
    .IF_ID_instr(IF_ID_instr),
    .IF_ID_PC(IF_ID_PC)
);

// ================= REGFILE =================
wire [31:0] reg_rs1 = regfile[IF_ID_instr[19:15]];
wire [31:0] reg_rs2 = regfile[IF_ID_instr[24:20]];

// ================= ID =================
id_stage ID (
    .IF_ID_instr(IF_ID_instr),
    .reg_rs1(reg_rs1),
    .reg_rs2(reg_rs2),

    .EX_MEM_RegWrite(EX_MEM_RegWrite),
    .EX_MEM_rd(EX_MEM_rd),
    .EX_MEM_alu(EX_MEM_alu),

    .MEM_WB_RegWrite(MEM_WB_RegWrite),
    .MEM_WB_rd(MEM_WB_rd),
    .WB_data(WB_data),

    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_rd(ID_EX_rd),

    .rs1_val(rs1_val),
    .rs2_val(rs2_val),
    .stall(stall),
    .hwlp_imm(hwlp_imm),
    .is_hwlp(is_hwlp),
    .rs1(rs1),
    .rs2(rs2),
    .opcode(opcode),

    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .imm(imm)
);

// ================= ID/EX =================
id_ex_reg ID_EX (
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush),

    .rs1_val(rs1_val),
    .rs2_val(rs2_val),
    .IF_ID_PC(IF_ID_PC),
    .rd(IF_ID_instr[11:7]),
    .hwlp_imm(hwlp_imm),
    .is_hwlp(is_hwlp),

    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .imm(imm),

    .ID_EX_r1(ID_EX_r1),
    .ID_EX_r2(ID_EX_r2),
    .ID_EX_PC(ID_EX_PC),
    .ID_EX_rd(ID_EX_rd),
    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_RegWrite(ID_EX_RegWrite),
    .ID_EX_MemWrite(ID_EX_MemWrite),
    .ID_EX_ALUSrc(ID_EX_ALUSrc),
    .ID_EX_ALUOp(ID_EX_ALUOp),
    .ID_EX_funct3(ID_EX_funct3),
    .ID_EX_funct7(ID_EX_funct7),
    .ID_EX_imm(ID_EX_imm),
    .ID_EX_hwlp_imm(ID_EX_hwlp_imm),
    .ID_EX_is_hwlp(ID_EX_is_hwlp)
);

// ================= EX =================
ex_stage EX (
    .clk(clk),
    .reset(reset),

    .ID_EX_r1(ID_EX_r1),
    .ID_EX_r2(ID_EX_r2),
    .ID_EX_imm(ID_EX_imm),
    .ID_EX_rd(ID_EX_rd),

    .ID_EX_RegWrite(ID_EX_RegWrite),
    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_MemWrite(ID_EX_MemWrite),

    .ID_EX_ALUSrc(ID_EX_ALUSrc),
    .ID_EX_ALUOp(ID_EX_ALUOp),
    .ID_EX_funct3(ID_EX_funct3),
    .ID_EX_funct7(ID_EX_funct7),

    .EX_MEM_alu(EX_MEM_alu),
    .EX_MEM_rd(EX_MEM_rd),
    .EX_MEM_RegWrite(EX_MEM_RegWrite),
    .EX_MEM_MemRead(EX_MEM_MemRead),
    .EX_MEM_MemWrite(EX_MEM_MemWrite)
);

// ================= MEM =================
mem_stage MEM (
    .clk(clk),
    .reset(reset),

    .EX_MEM_alu(EX_MEM_alu),
    .EX_MEM_rd(EX_MEM_rd),
    .EX_MEM_RegWrite(EX_MEM_RegWrite),
    .EX_MEM_MemWrite(EX_MEM_MemWrite),

    .MEM_WB_data(MEM_WB_data),
    .MEM_WB_rd(MEM_WB_rd),
    .MEM_WB_RegWrite(MEM_WB_RegWrite)
);

assign WB_data = MEM_WB_data;

// ================= WB =================
always @(posedge clk) begin
    if(MEM_WB_RegWrite && MEM_WB_rd != 0)
        regfile[MEM_WB_rd] <= WB_data;
end

// ================= HWLP =================
hwlp_unit HWLP (
    .clk(clk),
    .reset(reset),
    .ID_EX_is_hwlp(ID_EX_is_hwlp),
    .stall(stall),
    .ID_EX_r1(ID_EX_r1),
    .ID_EX_r2(ID_EX_r2),
    .ID_EX_PC(ID_EX_PC),
    .ID_EX_hwlp_imm(ID_EX_hwlp_imm),
    .IF_ID_PC(IF_ID_PC),

    .HWLP_COUNT(HWLP_COUNT),
    .HWLP_START(HWLP_START),
    .HWLP_END_PC(HWLP_END_PC),
    .HWLP_ACTIVE(HWLP_ACTIVE),
    .loop_redirect(loop_redirect)
);

// ================= DEBUG OUTPUTS =================
assign debug_pc = PC[3:0];
assign debug_active = HWLP_ACTIVE;

// 🔥 DEBUG EXPORTS
assign dbg_PC            = PC;
assign dbg_HWLP_COUNT    = HWLP_COUNT;
assign dbg_HWLP_ACTIVE   = HWLP_ACTIVE;
assign dbg_loop_redirect = loop_redirect;
assign dbg_stall         = stall;

endmodule