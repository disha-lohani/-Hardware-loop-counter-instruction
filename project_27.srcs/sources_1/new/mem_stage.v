`timescale 1ns / 1ps

module mem_stage(
    input clk, input reset,
    input [31:0] EX_MEM_alu,
    input [4:0] EX_MEM_rd,
    input EX_MEM_RegWrite,
    input EX_MEM_MemWrite,   // (optional future use)

    output reg [31:0] MEM_WB_data,
    output reg [4:0] MEM_WB_rd,
    output reg MEM_WB_RegWrite
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        MEM_WB_data <= 0;
        MEM_WB_rd <= 0;
        MEM_WB_RegWrite <= 0;
    end
    else begin
        // For now: just pass ALU result
        MEM_WB_data <= EX_MEM_alu;
        MEM_WB_rd <= EX_MEM_rd;
        MEM_WB_RegWrite <= EX_MEM_RegWrite;
    end
end

endmodule