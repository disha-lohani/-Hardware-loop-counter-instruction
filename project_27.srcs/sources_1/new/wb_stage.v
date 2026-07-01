`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2026 22:29:20
// Design Name: 
// Module Name: wb_stage
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

module wb_stage(
    input clk,
    input MEM_WB_RegWrite,
    input [4:0] MEM_WB_rd,
    input [31:0] WB_data,
    output regfile_write_en,
    output [4:0] regfile_rd,
    output [31:0] regfile_data
);

assign regfile_write_en = (MEM_WB_RegWrite && MEM_WB_rd != 0);
assign regfile_rd = MEM_WB_rd;
assign regfile_data = WB_data;

endmodule
