	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 14, 5
	.globl	_main
	.align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## BB#0:                                ## %entry
	pushq	%rbp
Ltmp0:
	.cfi_def_cfa_offset 16
Ltmp1:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp2:
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	pushq	%rax
Ltmp3:
	.cfi_offset %rbx, -24
	movl	$0, -12(%rbp)
	leaq	L_fmts(%rip), %rbx
	jmp	LBB0_1
	.align	4, 0x90
LBB0_2:                                 ## %while_body
                                        ##   in Loop: Header=BB0_1 Depth=1
	movq	%rsp, %rax
	leaq	-16(%rax), %rsp
	imull	$3, -12(%rbp), %esi
	movl	%esi, -16(%rax)
	xorl	%eax, %eax
	movq	%rbx, %rdi
	callq	_printf
	incl	-12(%rbp)
LBB0_1:                                 ## %while
                                        ## =>This Inner Loop Header: Depth=1
	cmpl	$4, -12(%rbp)
	jle	LBB0_2
## BB#3:                                ## %merge
	movl	$10, -12(%rbp)
	movl	$10, %eax
	leaq	-8(%rbp), %rsp
	popq	%rbx
	popq	%rbp
	retq
	.cfi_endproc

	.section	__TEXT,__cstring,cstring_literals
L_fmt:                                  ## @fmt
	.asciz	"%d\n"

L_fmt2:                                 ## @fmt2
	.asciz	"%s"

L_fmts:                                 ## @fmts
	.asciz	"%d\n"


.subsections_via_symbols
