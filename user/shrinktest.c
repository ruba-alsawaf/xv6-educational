#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  char *p;

  printf("shrinktest: grow by 8192\n");
  p = sbrk(8192);
  if(p == (char*)-1){
    printf("shrinktest: sbrk grow failed\n");
    exit(1);
  }

  printf("shrinktest: touch memory\n");
  p[0] = 1;
  p[4096] = 2;

  printf("shrinktest: shrink by 4096\n");
  p = sbrk(-4096);
  if(p == (char*)-1){
    printf("shrinktest: sbrk shrink failed\n");
    exit(1);
  }

  printf("shrinktest: done\n");
  exit(0);
}