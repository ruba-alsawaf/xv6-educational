#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  char *p;

  printf("faulttest: lazy grow by 8192\n");
  p = sbrklazy(8192);
  if(p == (char*)-1){
    printf("faulttest: sbrklazy failed\n");
    exit(1);
  }

  printf("faulttest: touching first page\n");
  p[0] = 1;

  printf("faulttest: touching second page\n");
  p[4096] = 2;

  printf("faulttest: done\n");
  exit(0);
}