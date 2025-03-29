	.file	1 "test.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=xx
	.module	nooddspreg
	.module	arch=mips32r2
	.abicalls
	.text
	.globl	global_var
	.section	.bss,"aw",@nobits
	.align	2
	.type	global_var, @object
	.size	global_var, 4
global_var:
	.space	4
	.text
	.align	2
	.globl	abs
	.set	nomips16
	.set	nomicromips
	.ent	abs
	.type	abs, @function
abs:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	lw	$2,8($fp)
	bgez	$2,$L2
	nop

	subu	$2,$0,$2
$L2:
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	abs
	.size	abs, .-abs
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$fp,40,$31		# vars= 32, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	sw	$fp,36($sp)
	move	$fp,$sp
	li	$2,5			# 0x5
	sw	$2,4($fp)
	li	$2,3			# 0x3
	sw	$2,8($fp)
	lw	$3,4($fp)
	lw	$2,8($fp)
	addu	$2,$3,$2
	sw	$2,12($fp)
	lw	$2,12($fp)
	sll	$2,$2,2
	sw	$2,16($fp)
	lw	$3,4($fp)
	lw	$2,8($fp)
	and	$2,$3,$2
	sw	$2,20($fp)
	lui	$2,%hi(global_var)
	lw	$3,20($fp)
	sw	$3,%lo(global_var)($2)
	lui	$2,%hi(global_var)
	lw	$2,%lo(global_var)($2)
	sw	$2,24($fp)
	lw	$2,24($fp)
	blez	$2,$L5
	nop

	lw	$2,24($fp)
	addiu	$2,$2,-1
	sw	$2,4($fp)
	.option	pic0
	b	$L6
	nop

	.option	pic2
$L5:
	lw	$2,24($fp)
	addiu	$2,$2,1
	sw	$2,4($fp)
$L6:
	lw	$2,4($fp)
	bgez	$2,$L7
	nop

	subu	$2,$0,$2
$L7:
	sw	$2,28($fp)
	lw	$2,28($fp)
	move	$sp,$fp
	lw	$fp,36($sp)
	addiu	$sp,$sp,40
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Ubuntu 12.3.0-17ubuntu1) 12.3.0"
	.section	.note.GNU-stack,"",@progbits
