	.file	1 "test.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=xx
	.module	nooddspreg
	.module	arch=mips32r2
	.abicalls
	.text
	.globl	globalVar
	.section	.bss,"aw",@nobits
	.align	2
	.type	globalVar, @object
	.size	globalVar, 4
globalVar:
	.space	4
	.text
	.align	2
	.globl	add
	.set	nomips16
	.set	nomicromips
	.ent	add
	.type	add, @function
add:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	lw	$3,8($fp)
	lw	$2,12($fp)
	addu	$2,$3,$2
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	jr	$31
	nop

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
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	lw	$3,8($fp)
	lw	$2,12($fp)
	subu	$2,$3,$2
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	jr	$31
	nop

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
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	lw	$3,8($fp)
	lw	$2,12($fp)
	mul	$2,$3,$2
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	jr	$31
	nop

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
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	lw	$3,8($fp)
	lw	$2,12($fp)
	teq	$2,$0,7
	div	$0,$3,$2
	mfhi	$2
	mflo	$2
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	divi
	.size	divi, .-divi
	.align	2
	.globl	mod
	.set	nomips16
	.set	nomicromips
	.ent	mod
	.type	mod, @function
mod:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	lw	$3,8($fp)
	lw	$2,12($fp)
	teq	$2,$0,7
	div	$0,$3,$2
	mfhi	$2
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	mod
	.size	mod, .-mod
	.align	2
	.globl	factorial
	.set	nomips16
	.set	nomicromips
	.ent	factorial
	.type	factorial, @function
factorial:
	.frame	$fp,32,$31		# vars= 0, regs= 2/0, args= 16, gp= 8
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	sw	$4,32($fp)
	lw	$2,32($fp)
	slt	$2,$2,2
	beq	$2,$0,$L12
	nop

	li	$2,1			# 0x1
	.option	pic0
	b	$L13
	nop

	.option	pic2
$L12:
	lw	$2,32($fp)
	addiu	$2,$2,-1
	move	$4,$2
	.option	pic0
	jal	factorial
	nop

	.option	pic2
	move	$3,$2
	lw	$2,32($fp)
	mul	$2,$3,$2
$L13:
	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	factorial
	.size	factorial, .-factorial
	.align	2
	.globl	fib
	.set	nomips16
	.set	nomicromips
	.ent	fib
	.type	fib, @function
fib:
	.frame	$fp,40,$31		# vars= 0, regs= 3/0, args= 16, gp= 8
	.mask	0xc0010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	sw	$31,36($sp)
	sw	$fp,32($sp)
	sw	$16,28($sp)
	move	$fp,$sp
	sw	$4,40($fp)
	lw	$2,40($fp)
	slt	$2,$2,2
	beq	$2,$0,$L15
	nop

	lw	$2,40($fp)
	.option	pic0
	b	$L16
	nop

	.option	pic2
$L15:
	lw	$2,40($fp)
	addiu	$2,$2,-1
	move	$4,$2
	.option	pic0
	jal	fib
	nop

	.option	pic2
	move	$16,$2
	lw	$2,40($fp)
	addiu	$2,$2,-2
	move	$4,$2
	.option	pic0
	jal	fib
	nop

	.option	pic2
	addu	$2,$16,$2
$L16:
	move	$sp,$fp
	lw	$31,36($sp)
	lw	$fp,32($sp)
	lw	$16,28($sp)
	addiu	$sp,$sp,40
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	fib
	.size	fib, .-fib
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$fp,64,$31		# vars= 32, regs= 2/0, args= 16, gp= 8
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-64
	sw	$31,60($sp)
	sw	$fp,56($sp)
	move	$fp,$sp
	li	$2,5			# 0x5
	sw	$2,28($fp)
	li	$2,3			# 0x3
	sw	$2,32($fp)
	lw	$5,32($fp)
	lw	$4,28($fp)
	.option	pic0
	jal	add
	nop

	.option	pic2
	sw	$2,36($fp)
	lw	$5,32($fp)
	lw	$4,28($fp)
	.option	pic0
	jal	sub
	nop

	.option	pic2
	sw	$2,40($fp)
	lw	$5,32($fp)
	lw	$4,28($fp)
	.option	pic0
	jal	mul
	nop

	.option	pic2
	sw	$2,44($fp)
	lw	$5,32($fp)
	lw	$4,28($fp)
	.option	pic0
	jal	divi
	nop

	.option	pic2
	sw	$2,48($fp)
	lw	$5,32($fp)
	lw	$4,28($fp)
	.option	pic0
	jal	mod
	nop

	.option	pic2
	sw	$2,52($fp)
	lui	$2,%hi(globalVar)
	li	$3,100			# 0x64
	sw	$3,%lo(globalVar)($2)
	sw	$0,24($fp)
	.option	pic0
	b	$L18
	nop

	.option	pic2
$L19:
	lui	$2,%hi(globalVar)
	lw	$3,%lo(globalVar)($2)
	lw	$2,24($fp)
	addu	$3,$3,$2
	lui	$2,%hi(globalVar)
	sw	$3,%lo(globalVar)($2)
	lw	$2,24($fp)
	addiu	$2,$2,1
	sw	$2,24($fp)
$L18:
	lw	$2,24($fp)
	slt	$2,$2,10
	bne	$2,$0,$L19
	nop

	move	$2,$0
	move	$sp,$fp
	lw	$31,60($sp)
	lw	$fp,56($sp)
	addiu	$sp,$sp,64
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Ubuntu 12.3.0-17ubuntu1) 12.3.0"
	.section	.note.GNU-stack,"",@progbits
