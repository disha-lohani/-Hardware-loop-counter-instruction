`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2026 10:24:03
// Design Name: 
// Module Name: alu
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

module alu(
    input [31:0] a, b,
    input [3:0] alu_ctrl,
    output reg [31:0] result
);

always @(*) begin
    case(alu_ctrl)
        4'b0000: result = a + b;   // ADD
        4'b0001: result = a - b;   // SUB
        4'b0010: result = a & b;   // AND
        4'b0011: result = a | b;   // OR
        default: result = 0;
    endcase
end

endmodule