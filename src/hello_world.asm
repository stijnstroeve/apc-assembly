section .data
  SYSCALL_WRITE equ 1 ; https://en.wikipedia.org/wiki/Write_(system_call)
  SYSCALL_EXIT equ 60 ; https://en.wikipedia.org/wiki/Exit_(system_call)
  EXIT_SUCCESS equ 0
  FD_STDOUT equ 1 ; File descriptor for standard output

  msg db "Hello World!",0x0a,0x00
  msg_len dw 14

section .text
  global _start

_start:
  ; Print message
  mov rax, SYSCALL_WRITE
  mov rdi, FD_STDOUT
  mov rsi, msg
  mov rdx, [msg_len]
  syscall

  ; Exit program
  mov rax, SYSCALL_EXIT
  mov rdi, EXIT_SUCCESS
  syscall