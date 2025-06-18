	.file	"test-reduce.c"
	.text
	.section	.rodata
.LC0:
	.string	"Total: %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movl	%edi, -36(%rbp)
	movq	%rsi, -48(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	leaq	-48(%rbp), %rdx
	leaq	-36(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	MPI_Init@PLT
	movl	$10, -16(%rbp)
	movl	$0, -12(%rbp)
	leaq	-24(%rbp), %rax
	movq	%rax, %rsi
	leaq	ompi_mpi_comm_world(%rip), %rax
	movq	%rax, %rdi
	call	MPI_Comm_rank@PLT
	leaq	-20(%rbp), %rax
	movq	%rax, %rsi
	leaq	ompi_mpi_comm_world(%rip), %rax
	movq	%rax, %rdi
	call	MPI_Comm_size@PLT
	leaq	-12(%rbp), %rsi
	leaq	-16(%rbp), %rax
	subq	$8, %rsp
	leaq	ompi_mpi_comm_world(%rip), %rdx
	pushq	%rdx
	movl	$0, %r9d
	leaq	ompi_mpi_op_sum(%rip), %r8
	leaq	ompi_mpi_int(%rip), %rdx
	movq	%rdx, %rcx
	movl	$1, %edx
	movq	%rax, %rdi
	call	MPI_Reduce@PLT
	addq	$16, %rsp
	movl	-24(%rbp), %eax
	testl	%eax, %eax
	jne	.L2
	movl	-12(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC0(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
.L2:
	call	MPI_Finalize@PLT
	movl	$0, %eax
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L4
	call	__stack_chk_fail@PLT
.L4:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 14.2.0-19ubuntu2) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
