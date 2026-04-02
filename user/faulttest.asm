
user/_faulttest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  char *p;

  printf("faulttest: lazy grow by 8192\n");
   8:	00001517          	auipc	a0,0x1
   c:	93850513          	addi	a0,a0,-1736 # 940 <malloc+0xfa>
  10:	77e000ef          	jal	78e <printf>
  p = sbrklazy(8192);
  14:	6509                	lui	a0,0x2
  16:	2f4000ef          	jal	30a <sbrklazy>
  if(p == (char*)-1){
  1a:	57fd                	li	a5,-1
  1c:	04f50163          	beq	a0,a5,5e <main+0x5e>
  20:	e426                	sd	s1,8(sp)
  22:	84aa                	mv	s1,a0
    printf("faulttest: sbrklazy failed\n");
    exit(1);
  }

  printf("faulttest: touching first page\n");
  24:	00001517          	auipc	a0,0x1
  28:	96450513          	addi	a0,a0,-1692 # 988 <malloc+0x142>
  2c:	762000ef          	jal	78e <printf>
  p[0] = 1;
  30:	4785                	li	a5,1
  32:	00f48023          	sb	a5,0(s1)

  printf("faulttest: touching second page\n");
  36:	00001517          	auipc	a0,0x1
  3a:	97250513          	addi	a0,a0,-1678 # 9a8 <malloc+0x162>
  3e:	750000ef          	jal	78e <printf>
  p[4096] = 2;
  42:	6785                	lui	a5,0x1
  44:	94be                	add	s1,s1,a5
  46:	4789                	li	a5,2
  48:	00f48023          	sb	a5,0(s1)

  printf("faulttest: done\n");
  4c:	00001517          	auipc	a0,0x1
  50:	98450513          	addi	a0,a0,-1660 # 9d0 <malloc+0x18a>
  54:	73a000ef          	jal	78e <printf>
  exit(0);
  58:	4501                	li	a0,0
  5a:	2ce000ef          	jal	328 <exit>
  5e:	e426                	sd	s1,8(sp)
    printf("faulttest: sbrklazy failed\n");
  60:	00001517          	auipc	a0,0x1
  64:	90850513          	addi	a0,a0,-1784 # 968 <malloc+0x122>
  68:	726000ef          	jal	78e <printf>
    exit(1);
  6c:	4505                	li	a0,1
  6e:	2ba000ef          	jal	328 <exit>

0000000000000072 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  72:	1141                	addi	sp,sp,-16
  74:	e406                	sd	ra,8(sp)
  76:	e022                	sd	s0,0(sp)
  78:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  7a:	f87ff0ef          	jal	0 <main>
  exit(r);
  7e:	2aa000ef          	jal	328 <exit>

0000000000000082 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  82:	1141                	addi	sp,sp,-16
  84:	e406                	sd	ra,8(sp)
  86:	e022                	sd	s0,0(sp)
  88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8a:	87aa                	mv	a5,a0
  8c:	0585                	addi	a1,a1,1
  8e:	0785                	addi	a5,a5,1 # 1001 <freep+0x1>
  90:	fff5c703          	lbu	a4,-1(a1)
  94:	fee78fa3          	sb	a4,-1(a5)
  98:	fb75                	bnez	a4,8c <strcpy+0xa>
    ;
  return os;
}
  9a:	60a2                	ld	ra,8(sp)
  9c:	6402                	ld	s0,0(sp)
  9e:	0141                	addi	sp,sp,16
  a0:	8082                	ret

00000000000000a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e406                	sd	ra,8(sp)
  a6:	e022                	sd	s0,0(sp)
  a8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	cb91                	beqz	a5,c2 <strcmp+0x20>
  b0:	0005c703          	lbu	a4,0(a1)
  b4:	00f71763          	bne	a4,a5,c2 <strcmp+0x20>
    p++, q++;
  b8:	0505                	addi	a0,a0,1
  ba:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	fbe5                	bnez	a5,b0 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  c2:	0005c503          	lbu	a0,0(a1)
}
  c6:	40a7853b          	subw	a0,a5,a0
  ca:	60a2                	ld	ra,8(sp)
  cc:	6402                	ld	s0,0(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret

00000000000000d2 <strlen>:

uint
strlen(const char *s)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e406                	sd	ra,8(sp)
  d6:	e022                	sd	s0,0(sp)
  d8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  da:	00054783          	lbu	a5,0(a0)
  de:	cf91                	beqz	a5,fa <strlen+0x28>
  e0:	00150793          	addi	a5,a0,1
  e4:	86be                	mv	a3,a5
  e6:	0785                	addi	a5,a5,1
  e8:	fff7c703          	lbu	a4,-1(a5)
  ec:	ff65                	bnez	a4,e4 <strlen+0x12>
  ee:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  f2:	60a2                	ld	ra,8(sp)
  f4:	6402                	ld	s0,0(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret
  for(n = 0; s[n]; n++)
  fa:	4501                	li	a0,0
  fc:	bfdd                	j	f2 <strlen+0x20>

00000000000000fe <memset>:

void*
memset(void *dst, int c, uint n)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e406                	sd	ra,8(sp)
 102:	e022                	sd	s0,0(sp)
 104:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 106:	ca19                	beqz	a2,11c <memset+0x1e>
 108:	87aa                	mv	a5,a0
 10a:	1602                	slli	a2,a2,0x20
 10c:	9201                	srli	a2,a2,0x20
 10e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 112:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 116:	0785                	addi	a5,a5,1
 118:	fee79de3          	bne	a5,a4,112 <memset+0x14>
  }
  return dst;
}
 11c:	60a2                	ld	ra,8(sp)
 11e:	6402                	ld	s0,0(sp)
 120:	0141                	addi	sp,sp,16
 122:	8082                	ret

0000000000000124 <strchr>:

char*
strchr(const char *s, char c)
{
 124:	1141                	addi	sp,sp,-16
 126:	e406                	sd	ra,8(sp)
 128:	e022                	sd	s0,0(sp)
 12a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 12c:	00054783          	lbu	a5,0(a0)
 130:	cf81                	beqz	a5,148 <strchr+0x24>
    if(*s == c)
 132:	00f58763          	beq	a1,a5,140 <strchr+0x1c>
  for(; *s; s++)
 136:	0505                	addi	a0,a0,1
 138:	00054783          	lbu	a5,0(a0)
 13c:	fbfd                	bnez	a5,132 <strchr+0xe>
      return (char*)s;
  return 0;
 13e:	4501                	li	a0,0
}
 140:	60a2                	ld	ra,8(sp)
 142:	6402                	ld	s0,0(sp)
 144:	0141                	addi	sp,sp,16
 146:	8082                	ret
  return 0;
 148:	4501                	li	a0,0
 14a:	bfdd                	j	140 <strchr+0x1c>

000000000000014c <gets>:

char*
gets(char *buf, int max)
{
 14c:	711d                	addi	sp,sp,-96
 14e:	ec86                	sd	ra,88(sp)
 150:	e8a2                	sd	s0,80(sp)
 152:	e4a6                	sd	s1,72(sp)
 154:	e0ca                	sd	s2,64(sp)
 156:	fc4e                	sd	s3,56(sp)
 158:	f852                	sd	s4,48(sp)
 15a:	f456                	sd	s5,40(sp)
 15c:	f05a                	sd	s6,32(sp)
 15e:	ec5e                	sd	s7,24(sp)
 160:	e862                	sd	s8,16(sp)
 162:	1080                	addi	s0,sp,96
 164:	8baa                	mv	s7,a0
 166:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 168:	892a                	mv	s2,a0
 16a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 16c:	faf40b13          	addi	s6,s0,-81
 170:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 172:	8c26                	mv	s8,s1
 174:	0014899b          	addiw	s3,s1,1
 178:	84ce                	mv	s1,s3
 17a:	0349d463          	bge	s3,s4,1a2 <gets+0x56>
    cc = read(0, &c, 1);
 17e:	8656                	mv	a2,s5
 180:	85da                	mv	a1,s6
 182:	4501                	li	a0,0
 184:	1bc000ef          	jal	340 <read>
    if(cc < 1)
 188:	00a05d63          	blez	a0,1a2 <gets+0x56>
      break;
    buf[i++] = c;
 18c:	faf44783          	lbu	a5,-81(s0)
 190:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 194:	0905                	addi	s2,s2,1
 196:	ff678713          	addi	a4,a5,-10
 19a:	c319                	beqz	a4,1a0 <gets+0x54>
 19c:	17cd                	addi	a5,a5,-13
 19e:	fbf1                	bnez	a5,172 <gets+0x26>
    buf[i++] = c;
 1a0:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1a2:	9c5e                	add	s8,s8,s7
 1a4:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1a8:	855e                	mv	a0,s7
 1aa:	60e6                	ld	ra,88(sp)
 1ac:	6446                	ld	s0,80(sp)
 1ae:	64a6                	ld	s1,72(sp)
 1b0:	6906                	ld	s2,64(sp)
 1b2:	79e2                	ld	s3,56(sp)
 1b4:	7a42                	ld	s4,48(sp)
 1b6:	7aa2                	ld	s5,40(sp)
 1b8:	7b02                	ld	s6,32(sp)
 1ba:	6be2                	ld	s7,24(sp)
 1bc:	6c42                	ld	s8,16(sp)
 1be:	6125                	addi	sp,sp,96
 1c0:	8082                	ret

00000000000001c2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c2:	1101                	addi	sp,sp,-32
 1c4:	ec06                	sd	ra,24(sp)
 1c6:	e822                	sd	s0,16(sp)
 1c8:	e04a                	sd	s2,0(sp)
 1ca:	1000                	addi	s0,sp,32
 1cc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ce:	4581                	li	a1,0
 1d0:	198000ef          	jal	368 <open>
  if(fd < 0)
 1d4:	02054263          	bltz	a0,1f8 <stat+0x36>
 1d8:	e426                	sd	s1,8(sp)
 1da:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1dc:	85ca                	mv	a1,s2
 1de:	1a2000ef          	jal	380 <fstat>
 1e2:	892a                	mv	s2,a0
  close(fd);
 1e4:	8526                	mv	a0,s1
 1e6:	16a000ef          	jal	350 <close>
  return r;
 1ea:	64a2                	ld	s1,8(sp)
}
 1ec:	854a                	mv	a0,s2
 1ee:	60e2                	ld	ra,24(sp)
 1f0:	6442                	ld	s0,16(sp)
 1f2:	6902                	ld	s2,0(sp)
 1f4:	6105                	addi	sp,sp,32
 1f6:	8082                	ret
    return -1;
 1f8:	57fd                	li	a5,-1
 1fa:	893e                	mv	s2,a5
 1fc:	bfc5                	j	1ec <stat+0x2a>

00000000000001fe <atoi>:

int
atoi(const char *s)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e406                	sd	ra,8(sp)
 202:	e022                	sd	s0,0(sp)
 204:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 206:	00054683          	lbu	a3,0(a0)
 20a:	fd06879b          	addiw	a5,a3,-48
 20e:	0ff7f793          	zext.b	a5,a5
 212:	4625                	li	a2,9
 214:	02f66963          	bltu	a2,a5,246 <atoi+0x48>
 218:	872a                	mv	a4,a0
  n = 0;
 21a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 21c:	0705                	addi	a4,a4,1
 21e:	0025179b          	slliw	a5,a0,0x2
 222:	9fa9                	addw	a5,a5,a0
 224:	0017979b          	slliw	a5,a5,0x1
 228:	9fb5                	addw	a5,a5,a3
 22a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 22e:	00074683          	lbu	a3,0(a4)
 232:	fd06879b          	addiw	a5,a3,-48
 236:	0ff7f793          	zext.b	a5,a5
 23a:	fef671e3          	bgeu	a2,a5,21c <atoi+0x1e>
  return n;
}
 23e:	60a2                	ld	ra,8(sp)
 240:	6402                	ld	s0,0(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret
  n = 0;
 246:	4501                	li	a0,0
 248:	bfdd                	j	23e <atoi+0x40>

000000000000024a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e406                	sd	ra,8(sp)
 24e:	e022                	sd	s0,0(sp)
 250:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 252:	02b57563          	bgeu	a0,a1,27c <memmove+0x32>
    while(n-- > 0)
 256:	00c05f63          	blez	a2,274 <memmove+0x2a>
 25a:	1602                	slli	a2,a2,0x20
 25c:	9201                	srli	a2,a2,0x20
 25e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 262:	872a                	mv	a4,a0
      *dst++ = *src++;
 264:	0585                	addi	a1,a1,1
 266:	0705                	addi	a4,a4,1
 268:	fff5c683          	lbu	a3,-1(a1)
 26c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 270:	fee79ae3          	bne	a5,a4,264 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 274:	60a2                	ld	ra,8(sp)
 276:	6402                	ld	s0,0(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret
    while(n-- > 0)
 27c:	fec05ce3          	blez	a2,274 <memmove+0x2a>
    dst += n;
 280:	00c50733          	add	a4,a0,a2
    src += n;
 284:	95b2                	add	a1,a1,a2
 286:	fff6079b          	addiw	a5,a2,-1
 28a:	1782                	slli	a5,a5,0x20
 28c:	9381                	srli	a5,a5,0x20
 28e:	fff7c793          	not	a5,a5
 292:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 294:	15fd                	addi	a1,a1,-1
 296:	177d                	addi	a4,a4,-1
 298:	0005c683          	lbu	a3,0(a1)
 29c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2a0:	fef71ae3          	bne	a4,a5,294 <memmove+0x4a>
 2a4:	bfc1                	j	274 <memmove+0x2a>

00000000000002a6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e406                	sd	ra,8(sp)
 2aa:	e022                	sd	s0,0(sp)
 2ac:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ae:	c61d                	beqz	a2,2dc <memcmp+0x36>
 2b0:	1602                	slli	a2,a2,0x20
 2b2:	9201                	srli	a2,a2,0x20
 2b4:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2b8:	00054783          	lbu	a5,0(a0)
 2bc:	0005c703          	lbu	a4,0(a1)
 2c0:	00e79863          	bne	a5,a4,2d0 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2c4:	0505                	addi	a0,a0,1
    p2++;
 2c6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c8:	fed518e3          	bne	a0,a3,2b8 <memcmp+0x12>
  }
  return 0;
 2cc:	4501                	li	a0,0
 2ce:	a019                	j	2d4 <memcmp+0x2e>
      return *p1 - *p2;
 2d0:	40e7853b          	subw	a0,a5,a4
}
 2d4:	60a2                	ld	ra,8(sp)
 2d6:	6402                	ld	s0,0(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
  return 0;
 2dc:	4501                	li	a0,0
 2de:	bfdd                	j	2d4 <memcmp+0x2e>

00000000000002e0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e406                	sd	ra,8(sp)
 2e4:	e022                	sd	s0,0(sp)
 2e6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2e8:	f63ff0ef          	jal	24a <memmove>
}
 2ec:	60a2                	ld	ra,8(sp)
 2ee:	6402                	ld	s0,0(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret

00000000000002f4 <sbrk>:

char *
sbrk(int n) {
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e406                	sd	ra,8(sp)
 2f8:	e022                	sd	s0,0(sp)
 2fa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2fc:	4585                	li	a1,1
 2fe:	0b2000ef          	jal	3b0 <sys_sbrk>
}
 302:	60a2                	ld	ra,8(sp)
 304:	6402                	ld	s0,0(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret

000000000000030a <sbrklazy>:

char *
sbrklazy(int n) {
 30a:	1141                	addi	sp,sp,-16
 30c:	e406                	sd	ra,8(sp)
 30e:	e022                	sd	s0,0(sp)
 310:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 312:	4589                	li	a1,2
 314:	09c000ef          	jal	3b0 <sys_sbrk>
}
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret

0000000000000320 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 320:	4885                	li	a7,1
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <exit>:
.global exit
exit:
 li a7, SYS_exit
 328:	4889                	li	a7,2
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <wait>:
.global wait
wait:
 li a7, SYS_wait
 330:	488d                	li	a7,3
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 338:	4891                	li	a7,4
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <read>:
.global read
read:
 li a7, SYS_read
 340:	4895                	li	a7,5
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <write>:
.global write
write:
 li a7, SYS_write
 348:	48c1                	li	a7,16
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <close>:
.global close
close:
 li a7, SYS_close
 350:	48d5                	li	a7,21
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <kill>:
.global kill
kill:
 li a7, SYS_kill
 358:	4899                	li	a7,6
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <exec>:
.global exec
exec:
 li a7, SYS_exec
 360:	489d                	li	a7,7
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <open>:
.global open
open:
 li a7, SYS_open
 368:	48bd                	li	a7,15
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 370:	48c5                	li	a7,17
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 378:	48c9                	li	a7,18
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 380:	48a1                	li	a7,8
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <link>:
.global link
link:
 li a7, SYS_link
 388:	48cd                	li	a7,19
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 390:	48d1                	li	a7,20
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 398:	48a5                	li	a7,9
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a0:	48a9                	li	a7,10
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a8:	48ad                	li	a7,11
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3b0:	48b1                	li	a7,12
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3b8:	48b5                	li	a7,13
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c0:	48b9                	li	a7,14
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <csread>:
.global csread
csread:
 li a7, SYS_csread
 3c8:	48d9                	li	a7,22
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 3d0:	48dd                	li	a7,23
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 3d8:	48e1                	li	a7,24
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <memread>:
.global memread
memread:
 li a7, SYS_memread
 3e0:	48e5                	li	a7,25
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e8:	1101                	addi	sp,sp,-32
 3ea:	ec06                	sd	ra,24(sp)
 3ec:	e822                	sd	s0,16(sp)
 3ee:	1000                	addi	s0,sp,32
 3f0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f4:	4605                	li	a2,1
 3f6:	fef40593          	addi	a1,s0,-17
 3fa:	f4fff0ef          	jal	348 <write>
}
 3fe:	60e2                	ld	ra,24(sp)
 400:	6442                	ld	s0,16(sp)
 402:	6105                	addi	sp,sp,32
 404:	8082                	ret

0000000000000406 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 406:	715d                	addi	sp,sp,-80
 408:	e486                	sd	ra,72(sp)
 40a:	e0a2                	sd	s0,64(sp)
 40c:	f84a                	sd	s2,48(sp)
 40e:	f44e                	sd	s3,40(sp)
 410:	0880                	addi	s0,sp,80
 412:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 414:	c6d1                	beqz	a3,4a0 <printint+0x9a>
 416:	0805d563          	bgez	a1,4a0 <printint+0x9a>
    neg = 1;
    x = -xx;
 41a:	40b005b3          	neg	a1,a1
    neg = 1;
 41e:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 420:	fb840993          	addi	s3,s0,-72
  neg = 0;
 424:	86ce                	mv	a3,s3
  i = 0;
 426:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 428:	00000817          	auipc	a6,0x0
 42c:	5c880813          	addi	a6,a6,1480 # 9f0 <digits>
 430:	88ba                	mv	a7,a4
 432:	0017051b          	addiw	a0,a4,1
 436:	872a                	mv	a4,a0
 438:	02c5f7b3          	remu	a5,a1,a2
 43c:	97c2                	add	a5,a5,a6
 43e:	0007c783          	lbu	a5,0(a5)
 442:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 446:	87ae                	mv	a5,a1
 448:	02c5d5b3          	divu	a1,a1,a2
 44c:	0685                	addi	a3,a3,1
 44e:	fec7f1e3          	bgeu	a5,a2,430 <printint+0x2a>
  if(neg)
 452:	00030c63          	beqz	t1,46a <printint+0x64>
    buf[i++] = '-';
 456:	fd050793          	addi	a5,a0,-48
 45a:	00878533          	add	a0,a5,s0
 45e:	02d00793          	li	a5,45
 462:	fef50423          	sb	a5,-24(a0)
 466:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 46a:	02e05563          	blez	a4,494 <printint+0x8e>
 46e:	fc26                	sd	s1,56(sp)
 470:	377d                	addiw	a4,a4,-1
 472:	00e984b3          	add	s1,s3,a4
 476:	19fd                	addi	s3,s3,-1
 478:	99ba                	add	s3,s3,a4
 47a:	1702                	slli	a4,a4,0x20
 47c:	9301                	srli	a4,a4,0x20
 47e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 482:	0004c583          	lbu	a1,0(s1)
 486:	854a                	mv	a0,s2
 488:	f61ff0ef          	jal	3e8 <putc>
  while(--i >= 0)
 48c:	14fd                	addi	s1,s1,-1
 48e:	ff349ae3          	bne	s1,s3,482 <printint+0x7c>
 492:	74e2                	ld	s1,56(sp)
}
 494:	60a6                	ld	ra,72(sp)
 496:	6406                	ld	s0,64(sp)
 498:	7942                	ld	s2,48(sp)
 49a:	79a2                	ld	s3,40(sp)
 49c:	6161                	addi	sp,sp,80
 49e:	8082                	ret
  neg = 0;
 4a0:	4301                	li	t1,0
 4a2:	bfbd                	j	420 <printint+0x1a>

00000000000004a4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a4:	711d                	addi	sp,sp,-96
 4a6:	ec86                	sd	ra,88(sp)
 4a8:	e8a2                	sd	s0,80(sp)
 4aa:	e4a6                	sd	s1,72(sp)
 4ac:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ae:	0005c483          	lbu	s1,0(a1)
 4b2:	22048363          	beqz	s1,6d8 <vprintf+0x234>
 4b6:	e0ca                	sd	s2,64(sp)
 4b8:	fc4e                	sd	s3,56(sp)
 4ba:	f852                	sd	s4,48(sp)
 4bc:	f456                	sd	s5,40(sp)
 4be:	f05a                	sd	s6,32(sp)
 4c0:	ec5e                	sd	s7,24(sp)
 4c2:	e862                	sd	s8,16(sp)
 4c4:	8b2a                	mv	s6,a0
 4c6:	8a2e                	mv	s4,a1
 4c8:	8bb2                	mv	s7,a2
  state = 0;
 4ca:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4cc:	4901                	li	s2,0
 4ce:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4d0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4d4:	06400c13          	li	s8,100
 4d8:	a00d                	j	4fa <vprintf+0x56>
        putc(fd, c0);
 4da:	85a6                	mv	a1,s1
 4dc:	855a                	mv	a0,s6
 4de:	f0bff0ef          	jal	3e8 <putc>
 4e2:	a019                	j	4e8 <vprintf+0x44>
    } else if(state == '%'){
 4e4:	03598363          	beq	s3,s5,50a <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4e8:	0019079b          	addiw	a5,s2,1
 4ec:	893e                	mv	s2,a5
 4ee:	873e                	mv	a4,a5
 4f0:	97d2                	add	a5,a5,s4
 4f2:	0007c483          	lbu	s1,0(a5)
 4f6:	1c048a63          	beqz	s1,6ca <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4fa:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4fe:	fe0993e3          	bnez	s3,4e4 <vprintf+0x40>
      if(c0 == '%'){
 502:	fd579ce3          	bne	a5,s5,4da <vprintf+0x36>
        state = '%';
 506:	89be                	mv	s3,a5
 508:	b7c5                	j	4e8 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 50a:	00ea06b3          	add	a3,s4,a4
 50e:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 512:	1c060863          	beqz	a2,6e2 <vprintf+0x23e>
      if(c0 == 'd'){
 516:	03878763          	beq	a5,s8,544 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 51a:	f9478693          	addi	a3,a5,-108
 51e:	0016b693          	seqz	a3,a3
 522:	f9c60593          	addi	a1,a2,-100
 526:	e99d                	bnez	a1,55c <vprintf+0xb8>
 528:	ca95                	beqz	a3,55c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 52a:	008b8493          	addi	s1,s7,8
 52e:	4685                	li	a3,1
 530:	4629                	li	a2,10
 532:	000bb583          	ld	a1,0(s7)
 536:	855a                	mv	a0,s6
 538:	ecfff0ef          	jal	406 <printint>
        i += 1;
 53c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 53e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 540:	4981                	li	s3,0
 542:	b75d                	j	4e8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 544:	008b8493          	addi	s1,s7,8
 548:	4685                	li	a3,1
 54a:	4629                	li	a2,10
 54c:	000ba583          	lw	a1,0(s7)
 550:	855a                	mv	a0,s6
 552:	eb5ff0ef          	jal	406 <printint>
 556:	8ba6                	mv	s7,s1
      state = 0;
 558:	4981                	li	s3,0
 55a:	b779                	j	4e8 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 55c:	9752                	add	a4,a4,s4
 55e:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 562:	f9460713          	addi	a4,a2,-108
 566:	00173713          	seqz	a4,a4
 56a:	8f75                	and	a4,a4,a3
 56c:	f9c58513          	addi	a0,a1,-100
 570:	18051363          	bnez	a0,6f6 <vprintf+0x252>
 574:	18070163          	beqz	a4,6f6 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 578:	008b8493          	addi	s1,s7,8
 57c:	4685                	li	a3,1
 57e:	4629                	li	a2,10
 580:	000bb583          	ld	a1,0(s7)
 584:	855a                	mv	a0,s6
 586:	e81ff0ef          	jal	406 <printint>
        i += 2;
 58a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 58c:	8ba6                	mv	s7,s1
      state = 0;
 58e:	4981                	li	s3,0
        i += 2;
 590:	bfa1                	j	4e8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 592:	008b8493          	addi	s1,s7,8
 596:	4681                	li	a3,0
 598:	4629                	li	a2,10
 59a:	000be583          	lwu	a1,0(s7)
 59e:	855a                	mv	a0,s6
 5a0:	e67ff0ef          	jal	406 <printint>
 5a4:	8ba6                	mv	s7,s1
      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	b781                	j	4e8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5aa:	008b8493          	addi	s1,s7,8
 5ae:	4681                	li	a3,0
 5b0:	4629                	li	a2,10
 5b2:	000bb583          	ld	a1,0(s7)
 5b6:	855a                	mv	a0,s6
 5b8:	e4fff0ef          	jal	406 <printint>
        i += 1;
 5bc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5be:	8ba6                	mv	s7,s1
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	b71d                	j	4e8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c4:	008b8493          	addi	s1,s7,8
 5c8:	4681                	li	a3,0
 5ca:	4629                	li	a2,10
 5cc:	000bb583          	ld	a1,0(s7)
 5d0:	855a                	mv	a0,s6
 5d2:	e35ff0ef          	jal	406 <printint>
        i += 2;
 5d6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d8:	8ba6                	mv	s7,s1
      state = 0;
 5da:	4981                	li	s3,0
        i += 2;
 5dc:	b731                	j	4e8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5de:	008b8493          	addi	s1,s7,8
 5e2:	4681                	li	a3,0
 5e4:	4641                	li	a2,16
 5e6:	000be583          	lwu	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	e1bff0ef          	jal	406 <printint>
 5f0:	8ba6                	mv	s7,s1
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	bdd5                	j	4e8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f6:	008b8493          	addi	s1,s7,8
 5fa:	4681                	li	a3,0
 5fc:	4641                	li	a2,16
 5fe:	000bb583          	ld	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	e03ff0ef          	jal	406 <printint>
        i += 1;
 608:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 60a:	8ba6                	mv	s7,s1
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bde9                	j	4e8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 610:	008b8493          	addi	s1,s7,8
 614:	4681                	li	a3,0
 616:	4641                	li	a2,16
 618:	000bb583          	ld	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	de9ff0ef          	jal	406 <printint>
        i += 2;
 622:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 624:	8ba6                	mv	s7,s1
      state = 0;
 626:	4981                	li	s3,0
        i += 2;
 628:	b5c1                	j	4e8 <vprintf+0x44>
 62a:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 62c:	008b8793          	addi	a5,s7,8
 630:	8cbe                	mv	s9,a5
 632:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 636:	03000593          	li	a1,48
 63a:	855a                	mv	a0,s6
 63c:	dadff0ef          	jal	3e8 <putc>
  putc(fd, 'x');
 640:	07800593          	li	a1,120
 644:	855a                	mv	a0,s6
 646:	da3ff0ef          	jal	3e8 <putc>
 64a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64c:	00000b97          	auipc	s7,0x0
 650:	3a4b8b93          	addi	s7,s7,932 # 9f0 <digits>
 654:	03c9d793          	srli	a5,s3,0x3c
 658:	97de                	add	a5,a5,s7
 65a:	0007c583          	lbu	a1,0(a5)
 65e:	855a                	mv	a0,s6
 660:	d89ff0ef          	jal	3e8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 664:	0992                	slli	s3,s3,0x4
 666:	34fd                	addiw	s1,s1,-1
 668:	f4f5                	bnez	s1,654 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 66a:	8be6                	mv	s7,s9
      state = 0;
 66c:	4981                	li	s3,0
 66e:	6ca2                	ld	s9,8(sp)
 670:	bda5                	j	4e8 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 672:	008b8493          	addi	s1,s7,8
 676:	000bc583          	lbu	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	d6dff0ef          	jal	3e8 <putc>
 680:	8ba6                	mv	s7,s1
      state = 0;
 682:	4981                	li	s3,0
 684:	b595                	j	4e8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 686:	008b8993          	addi	s3,s7,8
 68a:	000bb483          	ld	s1,0(s7)
 68e:	cc91                	beqz	s1,6aa <vprintf+0x206>
        for(; *s; s++)
 690:	0004c583          	lbu	a1,0(s1)
 694:	c985                	beqz	a1,6c4 <vprintf+0x220>
          putc(fd, *s);
 696:	855a                	mv	a0,s6
 698:	d51ff0ef          	jal	3e8 <putc>
        for(; *s; s++)
 69c:	0485                	addi	s1,s1,1
 69e:	0004c583          	lbu	a1,0(s1)
 6a2:	f9f5                	bnez	a1,696 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6a4:	8bce                	mv	s7,s3
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b581                	j	4e8 <vprintf+0x44>
          s = "(null)";
 6aa:	00000497          	auipc	s1,0x0
 6ae:	33e48493          	addi	s1,s1,830 # 9e8 <malloc+0x1a2>
        for(; *s; s++)
 6b2:	02800593          	li	a1,40
 6b6:	b7c5                	j	696 <vprintf+0x1f2>
        putc(fd, '%');
 6b8:	85be                	mv	a1,a5
 6ba:	855a                	mv	a0,s6
 6bc:	d2dff0ef          	jal	3e8 <putc>
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b51d                	j	4e8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6c4:	8bce                	mv	s7,s3
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b505                	j	4e8 <vprintf+0x44>
 6ca:	6906                	ld	s2,64(sp)
 6cc:	79e2                	ld	s3,56(sp)
 6ce:	7a42                	ld	s4,48(sp)
 6d0:	7aa2                	ld	s5,40(sp)
 6d2:	7b02                	ld	s6,32(sp)
 6d4:	6be2                	ld	s7,24(sp)
 6d6:	6c42                	ld	s8,16(sp)
    }
  }
}
 6d8:	60e6                	ld	ra,88(sp)
 6da:	6446                	ld	s0,80(sp)
 6dc:	64a6                	ld	s1,72(sp)
 6de:	6125                	addi	sp,sp,96
 6e0:	8082                	ret
      if(c0 == 'd'){
 6e2:	06400713          	li	a4,100
 6e6:	e4e78fe3          	beq	a5,a4,544 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6ea:	f9478693          	addi	a3,a5,-108
 6ee:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6f2:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6f4:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6f6:	07500513          	li	a0,117
 6fa:	e8a78ce3          	beq	a5,a0,592 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6fe:	f8b60513          	addi	a0,a2,-117
 702:	e119                	bnez	a0,708 <vprintf+0x264>
 704:	ea0693e3          	bnez	a3,5aa <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 708:	f8b58513          	addi	a0,a1,-117
 70c:	e119                	bnez	a0,712 <vprintf+0x26e>
 70e:	ea071be3          	bnez	a4,5c4 <vprintf+0x120>
      } else if(c0 == 'x'){
 712:	07800513          	li	a0,120
 716:	eca784e3          	beq	a5,a0,5de <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 71a:	f8860613          	addi	a2,a2,-120
 71e:	e219                	bnez	a2,724 <vprintf+0x280>
 720:	ec069be3          	bnez	a3,5f6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 724:	f8858593          	addi	a1,a1,-120
 728:	e199                	bnez	a1,72e <vprintf+0x28a>
 72a:	ee0713e3          	bnez	a4,610 <vprintf+0x16c>
      } else if(c0 == 'p'){
 72e:	07000713          	li	a4,112
 732:	eee78ce3          	beq	a5,a4,62a <vprintf+0x186>
      } else if(c0 == 'c'){
 736:	06300713          	li	a4,99
 73a:	f2e78ce3          	beq	a5,a4,672 <vprintf+0x1ce>
      } else if(c0 == 's'){
 73e:	07300713          	li	a4,115
 742:	f4e782e3          	beq	a5,a4,686 <vprintf+0x1e2>
      } else if(c0 == '%'){
 746:	02500713          	li	a4,37
 74a:	f6e787e3          	beq	a5,a4,6b8 <vprintf+0x214>
        putc(fd, '%');
 74e:	02500593          	li	a1,37
 752:	855a                	mv	a0,s6
 754:	c95ff0ef          	jal	3e8 <putc>
        putc(fd, c0);
 758:	85a6                	mv	a1,s1
 75a:	855a                	mv	a0,s6
 75c:	c8dff0ef          	jal	3e8 <putc>
      state = 0;
 760:	4981                	li	s3,0
 762:	b359                	j	4e8 <vprintf+0x44>

0000000000000764 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 764:	715d                	addi	sp,sp,-80
 766:	ec06                	sd	ra,24(sp)
 768:	e822                	sd	s0,16(sp)
 76a:	1000                	addi	s0,sp,32
 76c:	e010                	sd	a2,0(s0)
 76e:	e414                	sd	a3,8(s0)
 770:	e818                	sd	a4,16(s0)
 772:	ec1c                	sd	a5,24(s0)
 774:	03043023          	sd	a6,32(s0)
 778:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 77c:	8622                	mv	a2,s0
 77e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 782:	d23ff0ef          	jal	4a4 <vprintf>
}
 786:	60e2                	ld	ra,24(sp)
 788:	6442                	ld	s0,16(sp)
 78a:	6161                	addi	sp,sp,80
 78c:	8082                	ret

000000000000078e <printf>:

void
printf(const char *fmt, ...)
{
 78e:	711d                	addi	sp,sp,-96
 790:	ec06                	sd	ra,24(sp)
 792:	e822                	sd	s0,16(sp)
 794:	1000                	addi	s0,sp,32
 796:	e40c                	sd	a1,8(s0)
 798:	e810                	sd	a2,16(s0)
 79a:	ec14                	sd	a3,24(s0)
 79c:	f018                	sd	a4,32(s0)
 79e:	f41c                	sd	a5,40(s0)
 7a0:	03043823          	sd	a6,48(s0)
 7a4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a8:	00840613          	addi	a2,s0,8
 7ac:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b0:	85aa                	mv	a1,a0
 7b2:	4505                	li	a0,1
 7b4:	cf1ff0ef          	jal	4a4 <vprintf>
}
 7b8:	60e2                	ld	ra,24(sp)
 7ba:	6442                	ld	s0,16(sp)
 7bc:	6125                	addi	sp,sp,96
 7be:	8082                	ret

00000000000007c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c0:	1141                	addi	sp,sp,-16
 7c2:	e406                	sd	ra,8(sp)
 7c4:	e022                	sd	s0,0(sp)
 7c6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7cc:	00001797          	auipc	a5,0x1
 7d0:	8347b783          	ld	a5,-1996(a5) # 1000 <freep>
 7d4:	a039                	j	7e2 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d6:	6398                	ld	a4,0(a5)
 7d8:	00e7e463          	bltu	a5,a4,7e0 <free+0x20>
 7dc:	00e6ea63          	bltu	a3,a4,7f0 <free+0x30>
{
 7e0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e2:	fed7fae3          	bgeu	a5,a3,7d6 <free+0x16>
 7e6:	6398                	ld	a4,0(a5)
 7e8:	00e6e463          	bltu	a3,a4,7f0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ec:	fee7eae3          	bltu	a5,a4,7e0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7f0:	ff852583          	lw	a1,-8(a0)
 7f4:	6390                	ld	a2,0(a5)
 7f6:	02059813          	slli	a6,a1,0x20
 7fa:	01c85713          	srli	a4,a6,0x1c
 7fe:	9736                	add	a4,a4,a3
 800:	02e60563          	beq	a2,a4,82a <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 804:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 808:	4790                	lw	a2,8(a5)
 80a:	02061593          	slli	a1,a2,0x20
 80e:	01c5d713          	srli	a4,a1,0x1c
 812:	973e                	add	a4,a4,a5
 814:	02e68263          	beq	a3,a4,838 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 818:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 81a:	00000717          	auipc	a4,0x0
 81e:	7ef73323          	sd	a5,2022(a4) # 1000 <freep>
}
 822:	60a2                	ld	ra,8(sp)
 824:	6402                	ld	s0,0(sp)
 826:	0141                	addi	sp,sp,16
 828:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 82a:	4618                	lw	a4,8(a2)
 82c:	9f2d                	addw	a4,a4,a1
 82e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 832:	6398                	ld	a4,0(a5)
 834:	6310                	ld	a2,0(a4)
 836:	b7f9                	j	804 <free+0x44>
    p->s.size += bp->s.size;
 838:	ff852703          	lw	a4,-8(a0)
 83c:	9f31                	addw	a4,a4,a2
 83e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 840:	ff053683          	ld	a3,-16(a0)
 844:	bfd1                	j	818 <free+0x58>

0000000000000846 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 846:	7139                	addi	sp,sp,-64
 848:	fc06                	sd	ra,56(sp)
 84a:	f822                	sd	s0,48(sp)
 84c:	f04a                	sd	s2,32(sp)
 84e:	ec4e                	sd	s3,24(sp)
 850:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 852:	02051993          	slli	s3,a0,0x20
 856:	0209d993          	srli	s3,s3,0x20
 85a:	09bd                	addi	s3,s3,15
 85c:	0049d993          	srli	s3,s3,0x4
 860:	2985                	addiw	s3,s3,1
 862:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 864:	00000517          	auipc	a0,0x0
 868:	79c53503          	ld	a0,1948(a0) # 1000 <freep>
 86c:	c905                	beqz	a0,89c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 870:	4798                	lw	a4,8(a5)
 872:	09377663          	bgeu	a4,s3,8fe <malloc+0xb8>
 876:	f426                	sd	s1,40(sp)
 878:	e852                	sd	s4,16(sp)
 87a:	e456                	sd	s5,8(sp)
 87c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 87e:	8a4e                	mv	s4,s3
 880:	6705                	lui	a4,0x1
 882:	00e9f363          	bgeu	s3,a4,888 <malloc+0x42>
 886:	6a05                	lui	s4,0x1
 888:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 88c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 890:	00000497          	auipc	s1,0x0
 894:	77048493          	addi	s1,s1,1904 # 1000 <freep>
  if(p == SBRK_ERROR)
 898:	5afd                	li	s5,-1
 89a:	a83d                	j	8d8 <malloc+0x92>
 89c:	f426                	sd	s1,40(sp)
 89e:	e852                	sd	s4,16(sp)
 8a0:	e456                	sd	s5,8(sp)
 8a2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8a4:	00000797          	auipc	a5,0x0
 8a8:	76c78793          	addi	a5,a5,1900 # 1010 <base>
 8ac:	00000717          	auipc	a4,0x0
 8b0:	74f73a23          	sd	a5,1876(a4) # 1000 <freep>
 8b4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8b6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ba:	b7d1                	j	87e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8bc:	6398                	ld	a4,0(a5)
 8be:	e118                	sd	a4,0(a0)
 8c0:	a899                	j	916 <malloc+0xd0>
  hp->s.size = nu;
 8c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c6:	0541                	addi	a0,a0,16
 8c8:	ef9ff0ef          	jal	7c0 <free>
  return freep;
 8cc:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8ce:	c125                	beqz	a0,92e <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	03277163          	bgeu	a4,s2,8f6 <malloc+0xb0>
    if(p == freep)
 8d8:	6098                	ld	a4,0(s1)
 8da:	853e                	mv	a0,a5
 8dc:	fef71ae3          	bne	a4,a5,8d0 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8e0:	8552                	mv	a0,s4
 8e2:	a13ff0ef          	jal	2f4 <sbrk>
  if(p == SBRK_ERROR)
 8e6:	fd551ee3          	bne	a0,s5,8c2 <malloc+0x7c>
        return 0;
 8ea:	4501                	li	a0,0
 8ec:	74a2                	ld	s1,40(sp)
 8ee:	6a42                	ld	s4,16(sp)
 8f0:	6aa2                	ld	s5,8(sp)
 8f2:	6b02                	ld	s6,0(sp)
 8f4:	a03d                	j	922 <malloc+0xdc>
 8f6:	74a2                	ld	s1,40(sp)
 8f8:	6a42                	ld	s4,16(sp)
 8fa:	6aa2                	ld	s5,8(sp)
 8fc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8fe:	fae90fe3          	beq	s2,a4,8bc <malloc+0x76>
        p->s.size -= nunits;
 902:	4137073b          	subw	a4,a4,s3
 906:	c798                	sw	a4,8(a5)
        p += p->s.size;
 908:	02071693          	slli	a3,a4,0x20
 90c:	01c6d713          	srli	a4,a3,0x1c
 910:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 912:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 916:	00000717          	auipc	a4,0x0
 91a:	6ea73523          	sd	a0,1770(a4) # 1000 <freep>
      return (void*)(p + 1);
 91e:	01078513          	addi	a0,a5,16
  }
}
 922:	70e2                	ld	ra,56(sp)
 924:	7442                	ld	s0,48(sp)
 926:	7902                	ld	s2,32(sp)
 928:	69e2                	ld	s3,24(sp)
 92a:	6121                	addi	sp,sp,64
 92c:	8082                	ret
 92e:	74a2                	ld	s1,40(sp)
 930:	6a42                	ld	s4,16(sp)
 932:	6aa2                	ld	s5,8(sp)
 934:	6b02                	ld	s6,0(sp)
 936:	b7f5                	j	922 <malloc+0xdc>
