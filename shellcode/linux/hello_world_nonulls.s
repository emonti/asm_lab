jmp bounceback  ; jump to end

landing:
  ; ssize_t write(int fd, const void *buf, size_t count);
  xor edx, edx
  mov dl, 14    ; length of string
  pop ecx       ; pop the ret addr which is actually our string addr into ecx
  xor ebx, ebx  ; zero out ebx
  inc ebx       ; STDOUT file descriptor = 1
  xor eax,eax   ; zero out eax
  mov al, 4     ; put write syscall # in al
  sub esp, 4    ; OS X (and BSD) system calls need extra space on stack
  int 0x80

  ; exit(0)
  xor eax,eax   ; zero out ebx
  push eax      ; push exit code of zero onto stack
  mov al, 1     ; put exit syscall # in al
  int 0x80

bounceback:
  call landing     ; call backwards, to a call address with no nulls
  msg db "Hello sploit!", 0x0a, 0x0d

