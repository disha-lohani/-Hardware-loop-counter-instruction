`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2026 22:20:23
// Design Name: 
// Module Name: if_stage
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


module if_stage(
    input clk, input reset,
    input stall,
    input loop_redirect,
    input [31:0] HWLP_START,
    output reg [31:0] PC
);

always @(posedge clk or posedge reset) begin
    if(reset) PC <= 0;
    else if(!stall) begin
        if(loop_redirect) PC <= HWLP_START;
        else PC <= PC + 4;
    end
end

endmodule