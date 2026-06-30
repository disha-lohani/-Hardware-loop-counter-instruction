# -Hardware-loop-counter-instruction
A RISC-V custom instruction hwlp rd, rs1, imm that sets a hardware loop count register and an end-of-loop PC register. On reaching the end-PC, the pipeline decrements the count and redirects without a branch instruction.
