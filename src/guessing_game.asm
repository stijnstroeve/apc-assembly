
section .data
  SYSCALL_READ equ 0 ; https://en.wikipedia.org/wiki/Read_(system_call)
  SYSCALL_WRITE equ 1 ; https://en.wikipedia.org/wiki/Write_(system_call)
  SYSCALL_EXIT equ 60 ; https://en.wikipedia.org/wiki/Exit_(system_call)
  SYSCALL_TIME equ 201

  EXIT_SUCCESS equ 0

  FD_STDIN equ 0 ; File descriptor for standard input
  FD_STDOUT equ 1 ; File descriptor for standard output

  ; All static strings that will be used throughout the application.
  intro_text_1 db "Welcome to the guessing game!",0x0a,0x00
  intro_text_2 db "I'm thinking of a number between 1 and 128. Can you guess what it is?",0x0a,0x00
  enter_guess_text db 0x0a,"Enter your guess:",0x0a,0x00
  wrong_text db "Wrong! The number I'm thinking of is ",0x00
  lower_text db "lower than that.",0x00
  higher_text db "higher than that.",0x00
  correct_text db 0x0a,"Correct! That was the number I was thinking of.",0x0a,0x00
  outro_text db "Thanks for playing the guessing game!",0x0a,0x00

  seed dq 0

section .bss
  INPUT_BUFFER_SIZE equ 4
  input_buffer resb INPUT_BUFFER_SIZE

section .text
    global _start

_start:
  push rbp
  mov rbp, rsp

  sub rsp, 8 ; Make space for two local variable of 4 bytes each
  mov dword [rbp - 4], 0 ; Set local variable A to 0
  mov dword [rbp - 8], 0 ; Set local variable B to 0

  ; Get the current UNIX timestamp
  mov eax, SYSCALL_TIME
  syscall
  mov [seed], eax ; Store the timestamp in the seed quad word
  call _rand
  mov dword [rbp - 4], eax ; Move result of rand to local variable A

  ; Print first introduction line
  mov rdi, intro_text_1
  call _print_str

  ; Print second introduction line
  mov rdi, intro_text_2
  call _print_str

  ; Do a guess
game_guess:
  call _guess
  mov [rbp - 8], eax ; Move the result of the guess to local variable B
  cmp dword [rbp - 4], eax ; Compare the random number to the input number
  jne nmb_ne ; Jump to "nmb_ne" if the value given number is not equal to the random one
  
  ; Otherwise, print the corrext text
  mov rdi, correct_text
  call _print_str

  jmp game_end ; The number was correct, so we jump to the game end label
nmb_ne:
  mov rdi, wrong_text
  call _print_str ; Print the "Wrong!" text

  ; We know the given number was wrong, now we need to figure out if it has higher or lower
  mov eax, [rbp - 8]
  cmp [rbp - 4], eax ; Compare the random number to the input number
  jge nmb_higher ; Jump to "nmb_higher" if the value given number is higher than the random one

  ; Otherwise, print the "lower" text
  mov rdi, lower_text
  call _print_str

  jmp game_guess ; Do a new guess
nmb_higher:
  ; Print the "higher" text
  mov rdi, higher_text
  call _print_str

  jmp game_guess ; Do a new guess
game_end:

  ; Print the outro text
  mov rdi, outro_text
  call _print_str

  ; Exit program
  mov rax, SYSCALL_EXIT
  mov rdi, EXIT_SUCCESS
  syscall

; Description: Asks a user to input a number
; Return value EAX: The number that was guessed by the user
_guess:
  ; Print enter guess text
  mov rdi, enter_guess_text
  call _print_str

  ; Get number input from user
  mov rax, SYSCALL_READ
  mov rdi, FD_STDIN
  mov rsi, input_buffer
  mov rdx, INPUT_BUFFER_SIZE
  syscall

  mov rdi, input_buffer ; Move input buffer to 1st argument of atoi
  call _atoi ; Call the atoi function
  ; The result will be in the eax register, which is also the return register
  ret

; Description: Converts the given string to an integer
; 1st argument RDI: The address of the string to convert to an integer
; Return value RAX: The integer that was converted
_atoi:
  push rcx
  mov rax, 0
_atoi_loop_cycle:
  movzx rcx, byte [rdi] ; Move the current char into rcx
  
  cmp rcx, '0' ; Compare current char to '0'
  jb _atoi_loop_end ; If current char is below '0', end the loop

  cmp rcx, '9' ; Compare current char to '9'
  ja _atoi_loop_end ; If current char is above '9', end the loop

  sub rcx, '0' ; Subtract ASCII '0' to get int value

  lea rax, [rax * 4 + rax] ; rax = result * 5
  lea rax, [rax * 2 + rcx] ; rax = result * 5 * 2 + digit = result*10 + digit
  inc rdi ; Increase rdi to go to the next character
  jmp _atoi_loop_cycle
_atoi_loop_end:
  pop rcx
  ret

; Description: Prints the given string to cout
; 1st argument RDI: The address of the string to print
_print_str:
    ; Now that we know the length of the string, we can actually print it
    push r10
    push r11

    call _get_string_length
    mov r10, rax ; Move the string length, currently in rax to temporary register 10
    mov r11, rdi ; Move the address of the string, currently in rdi to temporary register 11

    ; Call the print system call
    mov rax, SYSCALL_WRITE
    mov rdi, FD_STDOUT
    mov rsi, r11
    mov rdx, r10
    syscall

    pop r10
    pop r11
    ret

; Description: Gets the length of the given string. The string needs to be null terminated.
; 1st argument RDI: The address of the string
; Return value RAX: Length of the string
_get_string_length:
    mov rax, 0 ; Initial length of the string
_get_string_length_loop_cycle:
    cmp byte [rdi+rax], 0 ; Compare current char to 0
    je _get_string_length_loop_end ; If current char is 0, end the loop

    inc rax ; Else increase the count
    jmp _get_string_length_loop_cycle
_get_string_length_loop_end:
    ret

; Description: Generates a random number between 1 and 128
; Return value RAX: Random number between 1 and 128
_rand:
  mov rax, [seed]
  imul rax, rax, 1103515245
  add rax, 12345
  mov [seed], rax
  mov rax, [seed]
  shr rax, 16
  and eax, 32767
  shr rax, 8
  ret

; Description: Exits the application
_exit:
  mov rax, SYSCALL_EXIT
  mov rdi, EXIT_SUCCESS
  syscall
  ret