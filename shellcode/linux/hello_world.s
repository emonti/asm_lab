
call mark_below               ; hop over string with 'call' so esp points to it
msg db "Hello, world!", 0x0a  ; the string argument to our write syscall

mark_below:
; ssize_t write(int fd, const void *buf, size_t count);
mov edx, 14   ; length of string
pop ecx       ; pop the return addr which is actually our string addr into ecx
mov ebx, 1    ; STDOUT file descriptor
mov eax, 4    ; write syscall num in eax
int 0x80

; exit(0)
mov eax, 1    ; exit syscall  in eax
mov ebx, 0    ; exit return value 0 == success
int 0x80
