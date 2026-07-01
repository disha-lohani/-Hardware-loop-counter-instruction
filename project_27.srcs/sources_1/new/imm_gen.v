`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2026 10:27:08
// Design Name: 
// Module Name: imm_gen
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
module imm_gen(
    input [31:0] instr,
    output reg [31:0] imm
);

always @(*) begin
    case(instr[6:0])
        7'b0010011, 7'b0000011: // I-type
            imm = {{20{instr[31]}}, instr[31:20]};
        7'b0100011: // S-type
            imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        default:
            imm = 0;
    endcase
end

endmodule