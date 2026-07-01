`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2026 10:25:35
// Design Name: 
// Module Name: alu_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module alu_control(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_ctrl
);

always @(*) begin
    case(ALUOp)
        2'b00: alu_ctrl = 4'b0000; // ADD (for load/store/addi)
        2'b10: begin
            case({funct7, funct3})
                {7'b0000000, 3'b000}: alu_ctrl = 4'b0000; // ADD
                {7'b0100000, 3'b000}: alu_ctrl = 4'b0001; // SUB
                {7'b0000000, 3'b111}: alu_ctrl = 4'b0010; // AND
                {7'b0000000, 3'b110}: alu_ctrl = 4'b0011; // OR
                default: alu_ctrl = 4'b0000;
            endcase
        end
        default: alu_ctrl = 4'b0000;
    endcase
end

endmodule