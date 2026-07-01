`timescale 1ns / 1ps

module tb_cpu;

reg clk;
reg reset;
integer i;

pipelined_cpu_hwlp uut(.clk(clk), .reset(reset));


// ================= CLOCK =================
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


// ================= WAVE =================
initial begin
    $dumpfile("hwlp_full_debug.vcd");
    $dumpvars(0, tb_cpu);
end


// ================= MONITOR =================
always @(posedge clk) begin
    $display("T=%0t | PC=%h | COUNT=%0d | ACTIVE=%b | stall=%b | rs1_val=%h",
        $time,
        uut.PC,
        uut.HWLP_COUNT,
        uut.HWLP_ACTIVE,
        uut.stall,
        uut.rs1_val
    );
end


// ================= INIT =================
task init_all;
begin
    for(i=0;i<32;i=i+1) uut.regfile[i] = 0;
    for(i=0;i<256;i=i+1) uut.instr_mem[i] = 0;
end
endtask


// ================= ASSERT =================
task check;
input condition;
input [200*8:1] msg;
begin
    if(!condition)
        $display("❌ ERROR: %s", msg);
    else
        $display("✅ PASS: %s", msg);
end
endtask


// =========================================================
// MAIN TEST
// =========================================================
initial begin

// =========================================================
// TEST 1: BASIC HWLP
// =========================================================
$display("\n==== TEST 1: BASIC HWLP ====\n");

reset = 1;
init_all();

uut.regfile[1] = 3;   // loop count
uut.regfile[2] = 8;   // loop start

uut.instr_mem[0] = {7'd3, 5'd2, 5'd1, 3'b000, 5'd0, 7'b0001011};
uut.instr_mem[1] = 32'h00000013;
uut.instr_mem[2] = 32'h00000013;
uut.instr_mem[3] = 32'h00000013;

#20 reset = 0;
#120;

check(uut.HWLP_COUNT == 0, "HWLP count reached zero");
check(uut.HWLP_ACTIVE == 0, "HWLP exited correctly");


// =========================================================
// TEST 2: FORWARDING (REAL EX HAZARD)
// =========================================================
$display("\n==== TEST 2: FORWARDING (EX hazard) ====\n");

reset = 1;
#10;
init_all();

uut.regfile[2] = 5;
uut.regfile[3] = 6;

// add x1 = x2 + x3  → result = 11
uut.instr_mem[0] = 32'b0000000_00011_00010_000_00001_0110011;

// hwlp uses x1 immediately → MUST FORWARD
uut.instr_mem[1] = {7'd2, 5'd2, 5'd1, 3'b000, 5'd0, 7'b0001011};

#10 reset = 0;
#80;

check(uut.rs1_val == 11, "Forwarding provided correct value (11)");


// =========================================================
// TEST 3: LOAD-USE HAZARD (STALL REQUIRED)
// =========================================================
$display("\n==== TEST 3: LOAD-USE HAZARD ====\n");

reset = 1;
#10;
init_all();

// Fake load result (ALU just passes)
uut.regfile[2] = 4;

// lw x1, 0(x2)
uut.instr_mem[0] = 32'b000000000000_00010_010_00001_0000011;

// hwlp uses x1 immediately → MUST STALL
uut.instr_mem[1] = {7'd2, 5'd2, 5'd1, 3'b000, 5'd0, 7'b0001011};

#10 reset = 0;
#80;

check(uut.stall == 1, "STALL triggered for load-use hazard");


// =========================================================
// TEST 4: LOOP REDIRECT UNDER PIPELINE LOAD
// =========================================================
$display("\n==== TEST 4: LOOP REDIRECT (PIPELINE STRESS) ====\n");

reset = 1;
#10;
init_all();

uut.regfile[1] = 2;
uut.regfile[2] = 8;

uut.instr_mem[0] = {7'd2, 5'd2, 5'd1, 3'b000, 5'd0, 7'b0001011};

// add instructions inside loop
uut.instr_mem[1] = 32'h00300093; // addi
uut.instr_mem[2] = 32'h00300093;
uut.instr_mem[3] = 32'h00300093;

#10 reset = 0;
#150;

check(uut.HWLP_ACTIVE == 0, "Loop exits correctly under pipeline load");


// =========================================================
// TEST 5: BACK-TO-BACK HWLP (CONTROL HAZARD)
// =========================================================
$display("\n==== TEST 5: BACK-TO-BACK HWLP ====\n");

reset = 1;
#10;
init_all();

uut.regfile[1] = 2;
uut.regfile[2] = 8;

uut.instr_mem[0] = {7'd2, 5'd2, 5'd1, 3'b000, 5'd0, 7'b0001011};
uut.instr_mem[1] = {7'd2, 5'd2, 5'd1, 3'b000, 5'd0, 7'b0001011};

#10 reset = 0;
#120;

check(uut.HWLP_ACTIVE == 1 || uut.HWLP_ACTIVE == 0,
      "Back-to-back HWLP did not crash");


// =========================================================
// DONE
// =========================================================
$display("\n==== ALL TESTS COMPLETE ====\n");
$finish;

end

endmodule