
call mark_below
msg db "Hello sploit!", 0x0a, 0x0d

mark_below:
  ; ssize_t write(int fd, const void *buf, size_t count);
  pop ecx       ; pop the 'call ret addr', actually our string addr into ecx
  push 14       ; push string length onto the stack
  push ecx      ; push string addr back onto the stack
  push 1        ; push file descriptor (1 for stdout)
  mov eax, 4    ; write syscall num in eax
  sub esp, 4    ; OS X (and BSD) system calls need extra space on stack
  int 0x80

  ; exit(0)
  push 0        ; exit return value 0 == success
  mov eax, 1    ; exit syscall  in eax
  sub esp, 4    ; OS X (and BSD) system calls need extra space on stack
  int 0x80
