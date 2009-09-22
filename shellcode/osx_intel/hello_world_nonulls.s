jmp bounceback  ; jump to end

land:
  ; ssize_t write(int fd, const void *buf, size_t count);
  pop ecx       ; pop the ret addr which is actually our string addr into ecx
  push 14       ; push string length onto the stack
  push ecx      ; push string addr back onto the stack
  push 1        ; push file descriptor (1 for stdout)
  xor eax,eax   ; zero out eax
  mov al, 4     ; put write syscall # in al
  sub esp, 4    ; OS X (and BSD) system calls need extra space on stack
  int 0x80

  ; exit(0)
  xor eax,eax   ; zero out ebx
  push eax      ; push exit code of zero onto stack
  mov al, 1     ; put exit syscall # in al
  sub esp, 4    ; OS X (and BSD) system calls need extra space on stack
  int 0x80

bounceback:
  call land     ; call backwards, to a call address with no nulls
  msg db "Hello sploit!", 0x0a, 0x0d

