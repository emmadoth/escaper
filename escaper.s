global _start

%macro write 3
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	mov rax, 1
	syscall
%endmacro

%macro read 3
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	xor rax, rax
	syscall
%endmacro

%macro mmap 6
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	mov r10, %4
	mov r8, %5
	mov r9, %6
	mov rax, 9
	syscall
%endmacro

%macro munmap 2
	mov rdi, %1
	mov rsi, %2
	mov rax, 11
	syscall
%endmacro

%macro exit 1
	mov rdi, %1
	mov rax, 60
	syscall
%endmacro

section .text
_start:
	pop qword [argc]
	pop rcx
	cmp dword [argc], 1
	jg skip_stdin
stdin_loop:
	read 0, buf, 4000
	cmp rax, 1
	jle end
	mov rdx, buf
	mov rcx, [argc]
	jmp count_start
clear_pos:
	cmp rbx, rax
	je arg_loop
	mov byte [pos + rax], 0
	inc rax
	jmp clear_pos
skip_stdin:
	mov rcx, [argc]
arg_loop:
	cmp rcx, 1
	jle end
	pop rdx
count_start:
	xor rax, rax
	xor rbx, rbx
count_loop:
	cmp byte [rdx + rax], '~'
	je found
	cmp byte [rdx + rax], '`'
	je found
	cmp byte [rdx + rax], '_'
	je found
	cmp byte [rdx + rax], '*'
	je found
	cmp byte [rdx + rax], '|'
	je found
	cmp byte [rdx + rax], '\'
	je found
	cmp byte [rdx + rax], 0
	je escape
	inc rax
	jmp count_loop
found:
	inc rbx
	mov byte [pos + rax], 1
	inc rax
	jmp count_loop
escape:
	push rcx ; argc counter
	push rax ; string length
	push rbx ; number of extra characters needed
	push rdx ; string memory address
	add rbx, rax
	inc rbx
	mmap 0, rbx, 3, 34, -1, 0	; 3 = PROT_READ | PROT_WRITE, 34 = MAP_PRIVATE | MAP_ANONYMOUS
	pop rdx
	pop rbx
	pop rsi
	add rsi, rbx
	xor r8, r8
	xor r9, r9
escape_loop:
	cmp r9, rsi
	je escape_loop_end
	cmp byte [pos + r8], 1
	jne skip_backslash
	mov byte [rax + r9], '\'
	inc r9
skip_backslash:
	mov r10b, byte [rdx + r8]
	mov byte [rax + r9], r10b
	inc r8
	inc r9
	jmp escape_loop
escape_loop_end:
	mov byte [rax + r9], 10
	inc r9
	push rax
	write 1, rax, r9
	pop rax
	munmap rax, r9
	pop rcx
next_arg:
	dec rcx
	xor rax, rax
	jmp clear_pos
end:
	exit 0

section .bss
	argc: resq 1
	buf: resb 4001
	pos: resb 4000

