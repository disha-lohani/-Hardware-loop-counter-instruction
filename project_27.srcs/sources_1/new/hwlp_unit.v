`timescale 1ns / 1ps

module hwlp_unit(
    input clk, input reset,
    input ID_EX_is_hwlp,
    input stall,
    input [31:0] ID_EX_r1, ID_EX_r2, ID_EX_PC,
    input [6:0] ID_EX_hwlp_imm,
    input [31:0] IF_ID_PC,

    output reg [31:0] HWLP_COUNT, HWLP_START, HWLP_END_PC,
    output reg HWLP_ACTIVE,
    output loop_redirect
);

// ===== NEXT COUNT (CRITICAL FIX) =====
wire [31:0] next_count;
assign next_count = HWLP_COUNT - 1;

// ===== REDIRECT CONDITION =====
// Use next_count instead of current count
assign loop_redirect =
    HWLP_ACTIVE &&
    (IF_ID_PC == HWLP_END_PC) &&
    (next_count > 0);

// ===== MAIN LOGIC =====
always @(posedge clk or posedge reset) begin
    if(reset) begin
        HWLP_ACTIVE <= 0;
        HWLP_COUNT <= 0;
        HWLP_START <= 0;
        HWLP_END_PC <= 0;
    end
    else begin
        // Initialize HWLP
        if(ID_EX_is_hwlp && !HWLP_ACTIVE && !stall) begin
            HWLP_COUNT <= ID_EX_r1;
            HWLP_START <= ID_EX_r2;
            HWLP_END_PC <= ID_EX_PC + (ID_EX_hwlp_imm << 2);
            HWLP_ACTIVE <= 1;
        end

        // Loop end reached
        else if(HWLP_ACTIVE && (IF_ID_PC == HWLP_END_PC)) begin
            if(next_count > 0) begin
                // Continue loop
                HWLP_COUNT <= next_count;
            end
            else begin
                // Exit loop cleanly
                HWLP_ACTIVE <= 0;
                HWLP_COUNT <= 0;
            end
        end
    end
end

endmodule