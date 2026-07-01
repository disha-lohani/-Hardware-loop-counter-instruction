module top(
    input clk,
    input reset,
    output [3:0] debug_pc,
    output debug_active
);

// =====================================================
// CLOCK WIZARD
// =====================================================
wire clk_wiz_out;
wire clk_locked;

clk_wiz_0 clkgen (
    .clk_in1(clk),          // Board clock input
    .clk_out1(clk_wiz_out), // Stable internal clock
    .locked(clk_locked)
);

// =====================================================
// RESET LOGIC
// Hold CPU in reset until clock is stable
// Active-high reset to CPU
// =====================================================
wire rst;
assign rst = reset | ~clk_locked;

// =====================================================
// DEBUG WIRES FROM CPU
// =====================================================
wire [31:0] dbg_pc_wire;
wire [31:0] dbg_count_wire;
wire dbg_active_wire;
wire dbg_redirect_wire;
wire dbg_stall_wire;

// =====================================================
// CPU
// =====================================================
pipelined_cpu_hwlp cpu (
    .clk(clk_wiz_out),
    .reset(rst),

    .debug_pc(),
    .debug_active(),

    .dbg_PC(dbg_pc_wire),
    .dbg_HWLP_COUNT(dbg_count_wire),
    .dbg_HWLP_ACTIVE(dbg_active_wire),
    .dbg_loop_redirect(dbg_redirect_wire),
    .dbg_stall(dbg_stall_wire)
);

// =====================================================
// LEDs
// =====================================================
assign debug_pc     = dbg_pc_wire[5:2];
assign debug_active = dbg_active_wire;

// =====================================================
// DEBUG REGISTERS
// =====================================================
reg [31:0] dbg_pc_reg;
reg [31:0] dbg_count_reg;
reg dbg_active_reg;
reg dbg_redirect_reg;
reg dbg_stall_reg;

always @(posedge clk_wiz_out) begin
    dbg_pc_reg       <= dbg_pc_wire;
    dbg_count_reg    <= dbg_count_wire;
    dbg_active_reg   <= dbg_active_wire;
    dbg_redirect_reg <= dbg_redirect_wire;
    dbg_stall_reg    <= dbg_stall_wire;
end

// =====================================================
// MARK DEBUG
// =====================================================
(* mark_debug = "true", DONT_TOUCH = "true" *) wire [31:0] dbg_pc       = dbg_pc_reg;
(* mark_debug = "true", DONT_TOUCH = "true" *) wire [31:0] dbg_count    = dbg_count_reg;
(* mark_debug = "true", DONT_TOUCH = "true" *) wire        dbg_active   = dbg_active_reg;
(* mark_debug = "true", DONT_TOUCH = "true" *) wire        dbg_redirect = dbg_redirect_reg;
(* mark_debug = "true", DONT_TOUCH = "true" *) wire        dbg_stall    = dbg_stall_reg;

// =====================================================
// ILA
// =====================================================
(* DONT_TOUCH = "true" *)
ila_0 ila_inst (
    .clk(clk_wiz_out),
    .probe0(dbg_pc),
    .probe1(dbg_count),
    .probe2(dbg_active),
    .probe3(dbg_redirect),
    .probe4(dbg_stall)
);

endmodule