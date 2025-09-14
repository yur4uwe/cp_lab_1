IDEAL
    DOSSEG
    MODEL   small
    STACK   256
    
    DATASEG
exc         DB 0
arr         DD 100.5, 200.3, 150.7, 175.2
len         DW 4
buffer      DD 5 dup(0)
ten         DD 10.0
temp_int      DW ?
control_word  DW ?
    CODESEG
Start:
    mov	  ax, @data
    mov	  ds,ax
    mov   cx, [len]
    
    FINIT

    FSTSW [control_word]        ; Store current control word
    mov ax, [control_word]      ; Load it into AX
    or  ax, 0C00h               ; Set bits 10-11 to 11 (truncate mode)
    mov [control_word], ax      ; Store modified control word
    FLDCW [control_word]        ; Load new control word into FPU

    FLD [ten]  ; Load 10.0 onto the FPU stack for later use
    FLDZ
    xor   si, si

sum_loop:
    FLD   [arr + si]
    FADD  ST(1), ST(0)
    FSTP  ST(0)
    add   si, 4
    loop  sum_loop

    FILD  [len]
    FDIVP ; Get the mean at ST(0)

    FTST
    FSTSW [control_word] ; Store status word with comparison to 0 result
    mov ax, [control_word]
    test ah, 01h      ; C0 is bit 8, which is bit 0 of AH
    jz has_leading_zero ; If not negative, jump 

    mov dl, '-'
    mov ah, 02h
    int 21h
    FABS

has_leading_zero:
    FLD1             ; Load 1.0 onto the FPU stack
    FCOM     ; Compare mean with 1.0 (if less than 1.0, then i need to print a leading zero)
    FSTSW [control_word] ; Store status word
    mov ax, [control_word]
    sahf     ; Transfer to CPU flags

    jl print_zero        ; If less print leading zero and decimal point

    FSTP ST(0)        ; Remove the 1.0 from the stack
    FLD ST(0)         ; Reload the mean
    FRNDINT           ; Truncate to integer

    FIST [WORD ptr temp_int] ; Store integer
    mov ax, [temp_int]       ; Get the integer value

    FSUBP  ; Subtract integer part from original value

    lea si, [buffer] ; load buffer address
    mov bx, 10       ; divisor
    mov cx, 0        ; digit count

write_to_buffer_loop:
    xor dx, dx       ; clear DX before DIV
    div bx           ; AX / 10, quotient in AL, remainder in AH
    add dl, '0'      ; convert remainder to ASCII
    mov [si], dl     ; store digit
    inc si
    inc cx
    cmp ax, 0
    jne write_to_buffer_loop

    mov ah, 02h
print_int:
    dec si
    mov dl, [si]
    int 21h
    loop print_int

    jmp print_decimal

print_zero:
    mov dl, '0'
    mov ah, 02h
    int 21h

print_decimal:
    mov dl, '.'
    mov ah, 02h
    int 21h

    mov cx, 6  ; Number of decimal places to print
print:
    FMUL ST(0), ST(1)

    FLD ST(0)        ; Duplicate the fractional part

    FRNDINT                  ; Truncate to integer
    FIST [WORD ptr temp_int] ; Store integer part
    mov ax, [temp_int]       ; Get the integer value
    mov ah, 02h
    mov dl, '0'
    add dl, al
    int 21h

    FSUBP  ; Subtract integer part from original value
    loop print

Exit:  
    mov	  ah, 04Ch	  ; DOS Exit program
    mov	  al, [exc]	  ; Return exit	code value
    int	  21h		  ; Call DOS.  Terminate program
    END	  Start