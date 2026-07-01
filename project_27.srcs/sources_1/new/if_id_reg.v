`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2026 22:21:15
// Design Name: 
// Module Name: if_id_reg
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


module if_id_reg(
    input clk, input reset,
    input stall, input flush,
    input [31:0] instruction, input [31:0] PC,
    output reg [31:0] IF_ID_instr, output reg [31:0] IF_ID_PC
);

always @(posedge clk or posedge reset) begin
    if(reset || flush) begin
        IF_ID_instr <= 0;
        IF_ID_PC <= 0;
    end
    else if(!stall) begin
        IF_ID_instr <= instruction;
        IF_ID_PC <= PC;
    end
end

endmodule