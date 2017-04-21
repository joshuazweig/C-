	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 14, 5
	.globl	_main
	.align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## BB#0:                                ## %entry
	subq	$24, %rsp
Ltmp0:
	.cfi_def_cfa_offset 32
	movl	$1, 20(%rsp)
	movl	$3, 16(%rsp)
	movl	$3, 12(%rsp)
	imull	$3, 16(%rsp), %esi
	addl	20(%rsp), %esi
	leaq	L_fmts(%rip), %rdi
	xorl	%eax, %eax
	callq	_printf
	movl	$4, 16(%rsp)
	leaq	L_fmts.1(%rip), %rdi
	movl	$4, %esi
	xorl	%eax, %eax
	callq	_printf
	movl	$5, 20(%rsp)
	leaq	L_fmts.2(%rip), %rdi
	movl	$5, %esi
	xorl	%eax, %eax
	callq	_printf
	xorl	%eax, %eax
	addq	$24, %rsp
	retq
	.cfi_endproc

	.section	__TEXT,__cstring,cstring_literals
L_fmt:                                  ## @fmt
	.asciz	"%d\n"

L_fmt2:                                 ## @fmt2
	.asciz	"%s"

L_fmts:                                 ## @fmts
	.asciz	"%d\n"

L_fmts.1:                               ## @fmts.1
	.asciz	"%d\n"

L_fmts.2:                               ## @fmts.2
	.asciz	"%d\n"


.subsections_via_symbols
