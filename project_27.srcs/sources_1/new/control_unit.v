`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2026 10:24:58
// Design Name: 
// Module Name: control_unit
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
module control_unit(
    input [6:0] opcode,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg [1:0] ALUOp
);

always @(*) begin
    case(opcode)
        7'b0110011: begin // R-type
            RegWrite = 1; MemRead = 0; MemWrite = 0;
            ALUSrc = 0; ALUOp = 2'b10;
        end
        7'b0010011: begin // I-type (addi)
            RegWrite = 1; MemRead = 0; MemWrite = 0;
            ALUSrc = 1; ALUOp = 2'b00;
        end
        7'b0000011: begin // load
            RegWrite = 1; MemRead = 1; MemWrite = 0;
            ALUSrc = 1; ALUOp = 2'b00;
        end
        7'b0100011: begin // store
            RegWrite = 0; MemRead = 0; MemWrite = 1;
            ALUSrc = 1; ALUOp = 2'b00;
        end
        default: begin
            RegWrite = 0; MemRead = 0; MemWrite = 0;
            ALUSrc = 0; ALUOp = 2'b00;
        end
    endcase
end

endmodule