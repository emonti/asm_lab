
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void vuln(char *ptr) {
  char buffer[48];
  strcpy(buffer, ptr);
}

int main(int argc, char *argv[]) {
  size_t blob_sz;
  char *stack_blob;
  char *pad;
  char *heap_blob;

  if (argc > 1) {
    if (stack_blob=getenv("SHELLCODE")) {
      blob_sz = strlen(stack_blob);
      pad = malloc(0x02020202);
      heap_blob = malloc(blob_sz);
      memcpy(heap_blob, stack_blob, blob_sz);
      free(pad);

      printf("shellcode on stack: 0x%0.8x\n", stack_blob);
      printf("shellcode on heap:  0x%0.8x\n", heap_blob);
    }

    vuln(argv[1]);
    exit(0);
  }
  exit(1);
}
