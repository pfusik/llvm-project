# The file testing Nop insertion with R_RISCV_ALIGN for relaxation.

# Relaxation enabled:
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+relax < %s \
# RUN:     | llvm-objdump -d -M no-aliases - \
# RUN:     | FileCheck -check-prefix=RELAX-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+relax < %s \
# RUN:     | llvm-readobj -r - | FileCheck -check-prefix=RELAX-RELOC %s

# Relaxation disabled:
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=-relax < %s \
# RUN:     | llvm-objdump -d -M no-aliases - \
# RUN:     | FileCheck -check-prefix=NORELAX-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=-relax < %s \
# RUN:     | llvm-readobj -r - | FileCheck -check-prefix=NORELAX-RELOC %s

# Relaxation enabled with C extension:
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+c,+relax < %s \
# RUN:     | llvm-objdump -d -M no-aliases - \
# RUN:     | FileCheck -check-prefix=C-OR-ZCA-EXT-RELAX-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+c,+relax < %s \
# RUN:     | llvm-readobj -r - | FileCheck -check-prefix=C-OR-ZCA-EXT-RELAX-RELOC %s

# Relaxation enabled with Zca extension:
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+zca,+relax < %s \
# RUN:     | llvm-objdump --mattr=+zca -d -M no-aliases - \
# RUN:     | FileCheck -check-prefix=C-OR-ZCA-EXT-RELAX-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+zca,+relax < %s \
# RUN:     | llvm-readobj -r - | FileCheck -check-prefix=C-OR-ZCA-EXT-RELAX-RELOC %s

# Relaxation disabled with C extension:
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+c,-relax < %s \
# RUN:     | llvm-objdump -d -M no-aliases - \
# RUN:     | FileCheck -check-prefix=C-OR-ZCA-EXT-NORELAX-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+c,-relax < %s \
# RUN:     | llvm-readobj -r - | FileCheck -check-prefix=C-OR-ZCA-EXT-NORELAX-RELOC %s

# Relaxation disabled with ZCA extension:
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+zca,-relax < %s \
# RUN:     | llvm-objdump --mattr=+zca -d -M no-aliases - \
# RUN:     | FileCheck -check-prefix=C-OR-ZCA-EXT-NORELAX-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+zca,-relax < %s \
# RUN:     | llvm-readobj -r - | FileCheck -check-prefix=C-OR-ZCA-EXT-NORELAX-RELOC %s

# We need to insert N-MinNopSize bytes NOPs and R_RISCV_ALIGN relocation
# type for .align N directive when linker relaxation enabled.
# Linker could satisfy alignment by removing NOPs after linker relaxation.

# The first R_RISCV_ALIGN come from
# MCELFStreamer::InitSections() emitCodeAlignment(getTextSectionAligntment()).
# C-OR-ZCA-EXT-RELAX-RELOC: R_RISCV_ALIGN - 0x2
# C-OR-ZCA-EXT-RELAX-INST:  c.nop
test:
	.p2align 2
# If the +c extension is enabled, the text section will be 2-byte aligned, so
# one c.nop instruction is sufficient.
# C-OR-ZCA-EXT-RELAX-RELOC-NOT: R_RISCV_ALIGN - 0x2
# C-OR-ZCA-EXT-RELAX-INST-NOT:  c.nop
	bne     zero, a0, .LBB0_2
	mv	a0, zero
	.p2align 3
# RELAX-RELOC: R_RISCV_ALIGN - 0x4
# RELAX-INST:  addi    zero, zero, 0
# C-OR-ZCA-EXT-RELAX-RELOC: R_RISCV_ALIGN - 0x6
# C-OR-ZCA-EXT-RELAX-INST:  c.nop
# C-OR-ZCA-EXT-RELAX-INST:  addi    zero, zero, 0
# C-OR-ZCA-EXT-NORELAX-INST: addi    zero, zero, 0
	add	a0, a0, a1
	.align 4
.LBB0_2:
# RELAX-RELOC: R_RISCV_ALIGN - 0xC
# RELAX-INST:  addi    zero, zero, 0
# RELAX-INST:  addi    zero, zero, 0
# RELAX-INST:  addi    zero, zero, 0
# NORELAX-INST: addi    zero, zero, 0
# C-OR-ZCA-EXT-RELAX-RELOC: R_RISCV_ALIGN - 0xE
# C-OR-ZCA-EXT-RELAX-INST:  addi    zero, zero, 0
# C-OR-ZCA-EXT-RELAX-INST:  addi    zero, zero, 0
# C-OR-ZCA-EXT-RELAX-INST:  addi    zero, zero, 0
# C-OR-ZCA-EXT-RELAX-INST:  c.nop
# C-EXT-INST: addi    zero, zero, 0
# C-EXT-INST: c.nop
	add	a0, a0, a1
	.p2align 3
.constant_pool:
.long	3126770193
# RELAX-RELOC: R_RISCV_ALIGN - 0x4
# RELAX-INST:  addi    zero, zero, 0
# NORELAX-INST: addi    zero, zero, 0
# C-OR-ZCA-EXT-RELAX-RELOC: R_RISCV_ALIGN - 0x6
# C-OR-ZCA-EXT-RELAX-INST:  addi    zero, zero, 0
# C-OR-ZCA-EXT-RELAX-INST-NOT:  c.nop
# C-EXT-INST: addi    zero, zero, 0
# C-EXT-INST: c.nop
	add	a0, a0, a1
# Alignment directive with specific padding value 0x01.
# We will not emit R_RISCV_ALIGN in this case.
# The behavior is the same as GNU assembler.
	.p2align 4, 1
# RELAX-RELOC-NOT: R_RISCV_ALIGN - 0xC
# RELAX-INST:  0101
# RELAX-INST:  0101
# C-OR-ZCA-EXT-RELAX-RELOC-NOT: R_RISCV_ALIGN - 0xE
# C-OR-ZCA-EXT-RELAX-INST:  0101
# C-EXT-INST:  0101
	ret
# NORELAX-RELOC-NOT: R_RISCV
# C-OR-ZCA-EXT-NORELAX-RELOC-NOT: R_RISCV
# Code alignment of a byte size less than the size of a nop must be treated
# as no alignment. This used to trigger a fatal error with relaxation enabled
# as the calculation to emit the worst-case sequence of nops would overflow.
	.p2align        1
	add	a0, a0, a1
	.p2align        0
	add	a0, a0, a1
# We only need to insert R_RISCV_ALIGN for code section
# when the linker relaxation enabled.
        .data
	.p2align        3
# RELAX-RELOC-NOT: R_RISCV_ALIGN
# C-OR-ZCA-EXT-RELAX-RELOC-NOT: R_RISCV_ALIGN
data1:
	.word 7
	.p2align        4
# RELAX-RELOC-NOT: R_RISCV_ALIGN
# C-OR-ZCA-EXT-RELAX-RELOC-NOT: R_RISCV_ALIGN
data2:
	.word 9
# Check that the initial alignment is properly handled when using .option to
# disable the C extension. This used to crash.
# C-OR-ZCA-EXT-RELAX-INST:      <.text2>:
# C-OR-ZCA-EXT-RELAX-INST-NEXT: add a0, a0, a1
	.section .text2, "x"
	.option norvc
	.balign 4
	add	a0, a0, a1

## Branches crossing the linker-relaxable R_RISCV_ALIGN need relocations.
# RELAX-RELOC:      .rela.text3 {
# RELAX-RELOC-NEXT:    0x4 R_RISCV_BRANCH .Ltmp[[#]] 0x0
# RELAX-RELOC-NEXT:    0x8 R_RISCV_ALIGN - 0x4
# RELAX-RELOC-NEXT:    0xC R_RISCV_BRANCH .Ltmp[[#]] 0x0
# RELAX-RELOC-NEXT: }
# C-OR-ZCA-EXT-RELAX-RELOC:      .rela.text3 {
# C-OR-ZCA-EXT-RELAX-RELOC-NEXT:    0x4 R_RISCV_BRANCH .Ltmp[[#]] 0x0
# C-OR-ZCA-EXT-RELAX-RELOC-NEXT:    0x8 R_RISCV_ALIGN - 0x4
# C-OR-ZCA-EXT-RELAX-RELOC-NEXT:    0xC R_RISCV_BRANCH .Ltmp[[#]] 0x0
# C-OR-ZCA-EXT-RELAX-RELOC-NEXT: }
	.section .text3, "ax"
	bnez t1, 1f
	bnez t2, 2f
1:
	.p2align 3
2:
	bnez t1, 1b
	bnez t1, 2b

## .text3 with a call at the start
# NORELAX-RELOC:    .rela.text3a
# C-OR-ZCA-EXT-NORELAX-RELOC: .rela.text3a
# RELAX-RELOC:      .rela.text3a {
# RELAX-RELOC-NEXT:    0x0  R_RISCV_CALL_PLT foo 0x0
# RELAX-RELOC-NEXT:    0x0  R_RISCV_RELAX - 0x0
# RELAX-RELOC-NEXT:    0xC  R_RISCV_BRANCH .Ltmp[[#]] 0x0
# RELAX-RELOC-NEXT:    0x10 R_RISCV_ALIGN - 0x4
# RELAX-RELOC-NEXT:    0x14 R_RISCV_BRANCH .Ltmp[[#]] 0x0
# RELAX-RELOC-NEXT: }
.section .text3a, "ax"
call foo
bnez t1, 1f
bnez t2, 2f
1:
.p2align 3
2:
bnez t1, 1b
bnez t1, 2b

## .text3 with a call at the end
# RELAX-RELOC:      .rela.text3b {
# RELAX-RELOC-NEXT:    0x4  R_RISCV_BRANCH .Ltmp[[#]] 0x0
# RELAX-RELOC-NEXT:    0x8  R_RISCV_ALIGN - 0x4
# RELAX-RELOC-NEXT:    0xC  R_RISCV_BRANCH .Ltmp[[#]] 0x0
# RELAX-RELOC-NEXT:    0x14 R_RISCV_CALL_PLT foo 0x0
# RELAX-RELOC-NEXT:    0x14 R_RISCV_RELAX - 0x0
# RELAX-RELOC-NEXT: }
.section .text3b, "ax"
bnez t1, 1f
bnez t2, 2f
1:
.p2align 3
2:
bnez t1, 1b
bnez t1, 2b
call foo
