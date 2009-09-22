#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
  size_t bloblen;
  char *blob;
  void (*funcptr)();

  if (argc > 1)  {
    bloblen = strlen(argv[1]); // hope you're nullsafe!
    blob = (char *) malloc(bloblen);
    if(blob != NULL) {
      memcpy(blob, argv[1], bloblen);
      funcptr = (void *) blob;
      funcptr();
      exit(0);
    }
  }
  exit(1);
}
