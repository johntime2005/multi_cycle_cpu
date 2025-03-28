	.file	1 "example.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=xx
	.module	nooddspreg
	.module	arch=mips32r2
	.abicalls
	.text
	.align	2
	.globl	add
	.set	nomips16
	.set	nomicromips
	.ent	add
	.type	add, @function
add:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	jr	$31
	addu	$2,$4,$5

	.set	macro
	.set	reorder
	.end	add
	.size	add, .-add
	.align	2
	.globl	sub
	.set	nomips16
	.set	nomicromips
	.ent	sub
	.type	sub, @function
sub:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	jr	$31
	subu	$2,$4,$5

	.set	macro
	.set	reorder
	.end	sub
	.size	sub, .-sub
	.align	2
	.globl	mul
	.set	nomips16
	.set	nomicromips
	.ent	mul
	.type	mul, @function
mul:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	jr	$31
	mul	$2,$4,$5

	.set	macro
	.set	reorder
	.end	mul
	.size	mul, .-mul
	.align	2
	.globl	divi
	.set	nomips16
	.set	nomicromips
	.ent	divi
	.type	divi, @function
divi:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	teq	$5,$0,7
	div	$0,$4,$5
	jr	$31
	mflo	$2

	.set	macro
	.set	reorder
	.end	divi
	.size	divi, .-divi
	.align	2
	.globl	fact
	.set	nomips16
	.set	nomicromips
	.ent	fact
	.type	fact, @function
fact:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	slt	$3,$4,2
	li	$2,1			# 0x1
	bne	$3,$0,$L11
	li	$5,1			# 0x1

$L7:
	move	$3,$4
	addiu	$4,$4,-1
	bne	$4,$5,$L7
	mul	$2,$2,$3

$L11:
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	fact
	.size	fact, .-fact
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
$LC0:
	.ascii	"Add: %d\012\000"
	.align	2
$LC1:
	.ascii	"Sub: %d\012\000"
	.align	2
$LC2:
	.ascii	"Mul: %d\012\000"
	.align	2
$LC3:
	.ascii	"Div: %d\012\000"
	.align	2
$LC4:
	.ascii	"Fact(6): %d\012\000"
	.align	2
$LC5:
	.ascii	"Array Sum: %d\012\000"
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,32,$31		# vars= 0, regs= 1/0, args= 16, gp= 8
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	lui	$28,%hi(__gnu_local_gp)
	addiu	$sp,$sp,-32
	addiu	$28,$28,%lo(__gnu_local_gp)
	lui	$5,%hi($LC0)
	li	$6,15			# 0xf
	sw	$31,28($sp)
	.cprestore	16
	addiu	$5,$5,%lo($LC0)
	lw	$25,%call16(__printf_chk)($28)
	.reloc	1f,R_MIPS_JALR,__printf_chk
1:	jalr	$25
	li	$4,2			# 0x2

	lui	$5,%hi($LC1)
	lw	$28,16($sp)
	li	$6,5			# 0x5
	addiu	$5,$5,%lo($LC1)
	lw	$25,%call16(__printf_chk)($28)
	.reloc	1f,R_MIPS_JALR,__printf_chk
1:	jalr	$25
	li	$4,2			# 0x2

	lui	$5,%hi($LC2)
	lw	$28,16($sp)
	li	$6,50			# 0x32
	addiu	$5,$5,%lo($LC2)
	lw	$25,%call16(__printf_chk)($28)
	.reloc	1f,R_MIPS_JALR,__printf_chk
1:	jalr	$25
	li	$4,2			# 0x2

	lui	$5,%hi($LC3)
	lw	$28,16($sp)
	li	$6,2			# 0x2
	addiu	$5,$5,%lo($LC3)
	lw	$25,%call16(__printf_chk)($28)
	.reloc	1f,R_MIPS_JALR,__printf_chk
1:	jalr	$25
	li	$4,2			# 0x2

	lui	$5,%hi($LC4)
	lw	$28,16($sp)
	li	$6,720			# 0x2d0
	addiu	$5,$5,%lo($LC4)
	lw	$25,%call16(__printf_chk)($28)
	.reloc	1f,R_MIPS_JALR,__printf_chk
1:	jalr	$25
	li	$4,2			# 0x2

	lui	$5,%hi($LC5)
	lw	$28,16($sp)
	li	$6,15			# 0xf
	addiu	$5,$5,%lo($LC5)
	lw	$25,%call16(__printf_chk)($28)
	.reloc	1f,R_MIPS_JALR,__printf_chk
1:	jalr	$25
	li	$4,2			# 0x2

	move	$2,$0
	lw	$31,28($sp)
	jr	$31
	addiu	$sp,$sp,32

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Ubuntu 12.3.0-17ubuntu1) 12.3.0"
	.section	.note.GNU-stack,"",@progbits
