
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7d963          	bge	a5,a0,3c <main+0x3c>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	19e000ef          	jal	1c6 <atoi>
  2c:	2ec000ef          	jal	318 <kill>
  for(i=1; i<argc; i++)
  30:	04a1                	addi	s1,s1,8
  32:	ff249ae3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  36:	4501                	li	a0,0
  38:	2b0000ef          	jal	2e8 <exit>
  3c:	e426                	sd	s1,8(sp)
  3e:	e04a                	sd	s2,0(sp)
    fprintf(2, "usage: kill pid...\n");
  40:	00001597          	auipc	a1,0x1
  44:	8b058593          	addi	a1,a1,-1872 # 8f0 <malloc+0xfc>
  48:	4509                	li	a0,2
  4a:	6cc000ef          	jal	716 <fprintf>
    exit(1);
  4e:	4505                	li	a0,1
  50:	298000ef          	jal	2e8 <exit>

0000000000000054 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  5c:	fa5ff0ef          	jal	0 <main>
  exit(r);
  60:	288000ef          	jal	2e8 <exit>

0000000000000064 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  64:	1141                	addi	sp,sp,-16
  66:	e422                	sd	s0,8(sp)
  68:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  6a:	87aa                	mv	a5,a0
  6c:	0585                	addi	a1,a1,1
  6e:	0785                	addi	a5,a5,1
  70:	fff5c703          	lbu	a4,-1(a1)
  74:	fee78fa3          	sb	a4,-1(a5)
  78:	fb75                	bnez	a4,6c <strcpy+0x8>
    ;
  return os;
}
  7a:	6422                	ld	s0,8(sp)
  7c:	0141                	addi	sp,sp,16
  7e:	8082                	ret

0000000000000080 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80:	1141                	addi	sp,sp,-16
  82:	e422                	sd	s0,8(sp)
  84:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  86:	00054783          	lbu	a5,0(a0)
  8a:	cb91                	beqz	a5,9e <strcmp+0x1e>
  8c:	0005c703          	lbu	a4,0(a1)
  90:	00f71763          	bne	a4,a5,9e <strcmp+0x1e>
    p++, q++;
  94:	0505                	addi	a0,a0,1
  96:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  98:	00054783          	lbu	a5,0(a0)
  9c:	fbe5                	bnez	a5,8c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9e:	0005c503          	lbu	a0,0(a1)
}
  a2:	40a7853b          	subw	a0,a5,a0
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret

00000000000000ac <strlen>:

uint
strlen(const char *s)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e422                	sd	s0,8(sp)
  b0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	cf91                	beqz	a5,d2 <strlen+0x26>
  b8:	0505                	addi	a0,a0,1
  ba:	87aa                	mv	a5,a0
  bc:	86be                	mv	a3,a5
  be:	0785                	addi	a5,a5,1
  c0:	fff7c703          	lbu	a4,-1(a5)
  c4:	ff65                	bnez	a4,bc <strlen+0x10>
  c6:	40a6853b          	subw	a0,a3,a0
  ca:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret
  for(n = 0; s[n]; n++)
  d2:	4501                	li	a0,0
  d4:	bfe5                	j	cc <strlen+0x20>

00000000000000d6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  dc:	ca19                	beqz	a2,f2 <memset+0x1c>
  de:	87aa                	mv	a5,a0
  e0:	1602                	slli	a2,a2,0x20
  e2:	9201                	srli	a2,a2,0x20
  e4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ec:	0785                	addi	a5,a5,1
  ee:	fee79de3          	bne	a5,a4,e8 <memset+0x12>
  }
  return dst;
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <strchr>:

char*
strchr(const char *s, char c)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cb99                	beqz	a5,118 <strchr+0x20>
    if(*s == c)
 104:	00f58763          	beq	a1,a5,112 <strchr+0x1a>
  for(; *s; s++)
 108:	0505                	addi	a0,a0,1
 10a:	00054783          	lbu	a5,0(a0)
 10e:	fbfd                	bnez	a5,104 <strchr+0xc>
      return (char*)s;
  return 0;
 110:	4501                	li	a0,0
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret
  return 0;
 118:	4501                	li	a0,0
 11a:	bfe5                	j	112 <strchr+0x1a>

000000000000011c <gets>:

char*
gets(char *buf, int max)
{
 11c:	711d                	addi	sp,sp,-96
 11e:	ec86                	sd	ra,88(sp)
 120:	e8a2                	sd	s0,80(sp)
 122:	e4a6                	sd	s1,72(sp)
 124:	e0ca                	sd	s2,64(sp)
 126:	fc4e                	sd	s3,56(sp)
 128:	f852                	sd	s4,48(sp)
 12a:	f456                	sd	s5,40(sp)
 12c:	f05a                	sd	s6,32(sp)
 12e:	ec5e                	sd	s7,24(sp)
 130:	1080                	addi	s0,sp,96
 132:	8baa                	mv	s7,a0
 134:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 136:	892a                	mv	s2,a0
 138:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 13a:	4aa9                	li	s5,10
 13c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13e:	89a6                	mv	s3,s1
 140:	2485                	addiw	s1,s1,1
 142:	0344d663          	bge	s1,s4,16e <gets+0x52>
    cc = read(0, &c, 1);
 146:	4605                	li	a2,1
 148:	faf40593          	addi	a1,s0,-81
 14c:	4501                	li	a0,0
 14e:	1b2000ef          	jal	300 <read>
    if(cc < 1)
 152:	00a05e63          	blez	a0,16e <gets+0x52>
    buf[i++] = c;
 156:	faf44783          	lbu	a5,-81(s0)
 15a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15e:	01578763          	beq	a5,s5,16c <gets+0x50>
 162:	0905                	addi	s2,s2,1
 164:	fd679de3          	bne	a5,s6,13e <gets+0x22>
    buf[i++] = c;
 168:	89a6                	mv	s3,s1
 16a:	a011                	j	16e <gets+0x52>
 16c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16e:	99de                	add	s3,s3,s7
 170:	00098023          	sb	zero,0(s3)
  return buf;
}
 174:	855e                	mv	a0,s7
 176:	60e6                	ld	ra,88(sp)
 178:	6446                	ld	s0,80(sp)
 17a:	64a6                	ld	s1,72(sp)
 17c:	6906                	ld	s2,64(sp)
 17e:	79e2                	ld	s3,56(sp)
 180:	7a42                	ld	s4,48(sp)
 182:	7aa2                	ld	s5,40(sp)
 184:	7b02                	ld	s6,32(sp)
 186:	6be2                	ld	s7,24(sp)
 188:	6125                	addi	sp,sp,96
 18a:	8082                	ret

000000000000018c <stat>:

int
stat(const char *n, struct stat *st)
{
 18c:	1101                	addi	sp,sp,-32
 18e:	ec06                	sd	ra,24(sp)
 190:	e822                	sd	s0,16(sp)
 192:	e04a                	sd	s2,0(sp)
 194:	1000                	addi	s0,sp,32
 196:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 198:	4581                	li	a1,0
 19a:	18e000ef          	jal	328 <open>
  if(fd < 0)
 19e:	02054263          	bltz	a0,1c2 <stat+0x36>
 1a2:	e426                	sd	s1,8(sp)
 1a4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a6:	85ca                	mv	a1,s2
 1a8:	198000ef          	jal	340 <fstat>
 1ac:	892a                	mv	s2,a0
  close(fd);
 1ae:	8526                	mv	a0,s1
 1b0:	160000ef          	jal	310 <close>
  return r;
 1b4:	64a2                	ld	s1,8(sp)
}
 1b6:	854a                	mv	a0,s2
 1b8:	60e2                	ld	ra,24(sp)
 1ba:	6442                	ld	s0,16(sp)
 1bc:	6902                	ld	s2,0(sp)
 1be:	6105                	addi	sp,sp,32
 1c0:	8082                	ret
    return -1;
 1c2:	597d                	li	s2,-1
 1c4:	bfcd                	j	1b6 <stat+0x2a>

00000000000001c6 <atoi>:

int
atoi(const char *s)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1cc:	00054683          	lbu	a3,0(a0)
 1d0:	fd06879b          	addiw	a5,a3,-48
 1d4:	0ff7f793          	zext.b	a5,a5
 1d8:	4625                	li	a2,9
 1da:	02f66863          	bltu	a2,a5,20a <atoi+0x44>
 1de:	872a                	mv	a4,a0
  n = 0;
 1e0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1e2:	0705                	addi	a4,a4,1
 1e4:	0025179b          	slliw	a5,a0,0x2
 1e8:	9fa9                	addw	a5,a5,a0
 1ea:	0017979b          	slliw	a5,a5,0x1
 1ee:	9fb5                	addw	a5,a5,a3
 1f0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f4:	00074683          	lbu	a3,0(a4)
 1f8:	fd06879b          	addiw	a5,a3,-48
 1fc:	0ff7f793          	zext.b	a5,a5
 200:	fef671e3          	bgeu	a2,a5,1e2 <atoi+0x1c>
  return n;
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret
  n = 0;
 20a:	4501                	li	a0,0
 20c:	bfe5                	j	204 <atoi+0x3e>

000000000000020e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e422                	sd	s0,8(sp)
 212:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 214:	02b57463          	bgeu	a0,a1,23c <memmove+0x2e>
    while(n-- > 0)
 218:	00c05f63          	blez	a2,236 <memmove+0x28>
 21c:	1602                	slli	a2,a2,0x20
 21e:	9201                	srli	a2,a2,0x20
 220:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 224:	872a                	mv	a4,a0
      *dst++ = *src++;
 226:	0585                	addi	a1,a1,1
 228:	0705                	addi	a4,a4,1
 22a:	fff5c683          	lbu	a3,-1(a1)
 22e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 232:	fef71ae3          	bne	a4,a5,226 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
    dst += n;
 23c:	00c50733          	add	a4,a0,a2
    src += n;
 240:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 242:	fec05ae3          	blez	a2,236 <memmove+0x28>
 246:	fff6079b          	addiw	a5,a2,-1
 24a:	1782                	slli	a5,a5,0x20
 24c:	9381                	srli	a5,a5,0x20
 24e:	fff7c793          	not	a5,a5
 252:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 254:	15fd                	addi	a1,a1,-1
 256:	177d                	addi	a4,a4,-1
 258:	0005c683          	lbu	a3,0(a1)
 25c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 260:	fee79ae3          	bne	a5,a4,254 <memmove+0x46>
 264:	bfc9                	j	236 <memmove+0x28>

0000000000000266 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 26c:	ca05                	beqz	a2,29c <memcmp+0x36>
 26e:	fff6069b          	addiw	a3,a2,-1
 272:	1682                	slli	a3,a3,0x20
 274:	9281                	srli	a3,a3,0x20
 276:	0685                	addi	a3,a3,1
 278:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 27a:	00054783          	lbu	a5,0(a0)
 27e:	0005c703          	lbu	a4,0(a1)
 282:	00e79863          	bne	a5,a4,292 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 286:	0505                	addi	a0,a0,1
    p2++;
 288:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 28a:	fed518e3          	bne	a0,a3,27a <memcmp+0x14>
  }
  return 0;
 28e:	4501                	li	a0,0
 290:	a019                	j	296 <memcmp+0x30>
      return *p1 - *p2;
 292:	40e7853b          	subw	a0,a5,a4
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  return 0;
 29c:	4501                	li	a0,0
 29e:	bfe5                	j	296 <memcmp+0x30>

00000000000002a0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e406                	sd	ra,8(sp)
 2a4:	e022                	sd	s0,0(sp)
 2a6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a8:	f67ff0ef          	jal	20e <memmove>
}
 2ac:	60a2                	ld	ra,8(sp)
 2ae:	6402                	ld	s0,0(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret

00000000000002b4 <sbrk>:

char *
sbrk(int n) {
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2bc:	4585                	li	a1,1
 2be:	0c2000ef          	jal	380 <sys_sbrk>
}
 2c2:	60a2                	ld	ra,8(sp)
 2c4:	6402                	ld	s0,0(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <sbrklazy>:

char *
sbrklazy(int n) {
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2d2:	4589                	li	a1,2
 2d4:	0ac000ef          	jal	380 <sys_sbrk>
}
 2d8:	60a2                	ld	ra,8(sp)
 2da:	6402                	ld	s0,0(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e0:	4885                	li	a7,1
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e8:	4889                	li	a7,2
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f0:	488d                	li	a7,3
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f8:	4891                	li	a7,4
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <read>:
.global read
read:
 li a7, SYS_read
 300:	4895                	li	a7,5
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <write>:
.global write
write:
 li a7, SYS_write
 308:	48c1                	li	a7,16
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <close>:
.global close
close:
 li a7, SYS_close
 310:	48d5                	li	a7,21
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <kill>:
.global kill
kill:
 li a7, SYS_kill
 318:	4899                	li	a7,6
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <exec>:
.global exec
exec:
 li a7, SYS_exec
 320:	489d                	li	a7,7
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <open>:
.global open
open:
 li a7, SYS_open
 328:	48bd                	li	a7,15
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 330:	48c5                	li	a7,17
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 338:	48c9                	li	a7,18
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 340:	48a1                	li	a7,8
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <link>:
.global link
link:
 li a7, SYS_link
 348:	48cd                	li	a7,19
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 350:	48d1                	li	a7,20
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 358:	48a5                	li	a7,9
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <dup>:
.global dup
dup:
 li a7, SYS_dup
 360:	48a9                	li	a7,10
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 368:	48ad                	li	a7,11
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 370:	48e9                	li	a7,26
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 378:	48ed                	li	a7,27
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 380:	48b1                	li	a7,12
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <pause>:
.global pause
pause:
 li a7, SYS_pause
 388:	48b5                	li	a7,13
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 390:	48b9                	li	a7,14
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <csread>:
.global csread
csread:
 li a7, SYS_csread
 398:	48d9                	li	a7,22
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 3a0:	48dd                	li	a7,23
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 3a8:	48e1                	li	a7,24
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <memread>:
.global memread
memread:
 li a7, SYS_memread
 3b0:	48e5                	li	a7,25
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b8:	1101                	addi	sp,sp,-32
 3ba:	ec06                	sd	ra,24(sp)
 3bc:	e822                	sd	s0,16(sp)
 3be:	1000                	addi	s0,sp,32
 3c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c4:	4605                	li	a2,1
 3c6:	fef40593          	addi	a1,s0,-17
 3ca:	f3fff0ef          	jal	308 <write>
}
 3ce:	60e2                	ld	ra,24(sp)
 3d0:	6442                	ld	s0,16(sp)
 3d2:	6105                	addi	sp,sp,32
 3d4:	8082                	ret

00000000000003d6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3d6:	715d                	addi	sp,sp,-80
 3d8:	e486                	sd	ra,72(sp)
 3da:	e0a2                	sd	s0,64(sp)
 3dc:	f84a                	sd	s2,48(sp)
 3de:	0880                	addi	s0,sp,80
 3e0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3e2:	c299                	beqz	a3,3e8 <printint+0x12>
 3e4:	0805c363          	bltz	a1,46a <printint+0x94>
  neg = 0;
 3e8:	4881                	li	a7,0
 3ea:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3ee:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3f0:	00000517          	auipc	a0,0x0
 3f4:	52050513          	addi	a0,a0,1312 # 910 <digits>
 3f8:	883e                	mv	a6,a5
 3fa:	2785                	addiw	a5,a5,1
 3fc:	02c5f733          	remu	a4,a1,a2
 400:	972a                	add	a4,a4,a0
 402:	00074703          	lbu	a4,0(a4)
 406:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 40a:	872e                	mv	a4,a1
 40c:	02c5d5b3          	divu	a1,a1,a2
 410:	0685                	addi	a3,a3,1
 412:	fec773e3          	bgeu	a4,a2,3f8 <printint+0x22>
  if(neg)
 416:	00088b63          	beqz	a7,42c <printint+0x56>
    buf[i++] = '-';
 41a:	fd078793          	addi	a5,a5,-48
 41e:	97a2                	add	a5,a5,s0
 420:	02d00713          	li	a4,45
 424:	fee78423          	sb	a4,-24(a5)
 428:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 42c:	02f05a63          	blez	a5,460 <printint+0x8a>
 430:	fc26                	sd	s1,56(sp)
 432:	f44e                	sd	s3,40(sp)
 434:	fb840713          	addi	a4,s0,-72
 438:	00f704b3          	add	s1,a4,a5
 43c:	fff70993          	addi	s3,a4,-1
 440:	99be                	add	s3,s3,a5
 442:	37fd                	addiw	a5,a5,-1
 444:	1782                	slli	a5,a5,0x20
 446:	9381                	srli	a5,a5,0x20
 448:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 44c:	fff4c583          	lbu	a1,-1(s1)
 450:	854a                	mv	a0,s2
 452:	f67ff0ef          	jal	3b8 <putc>
  while(--i >= 0)
 456:	14fd                	addi	s1,s1,-1
 458:	ff349ae3          	bne	s1,s3,44c <printint+0x76>
 45c:	74e2                	ld	s1,56(sp)
 45e:	79a2                	ld	s3,40(sp)
}
 460:	60a6                	ld	ra,72(sp)
 462:	6406                	ld	s0,64(sp)
 464:	7942                	ld	s2,48(sp)
 466:	6161                	addi	sp,sp,80
 468:	8082                	ret
    x = -xx;
 46a:	40b005b3          	neg	a1,a1
    neg = 1;
 46e:	4885                	li	a7,1
    x = -xx;
 470:	bfad                	j	3ea <printint+0x14>

0000000000000472 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 472:	711d                	addi	sp,sp,-96
 474:	ec86                	sd	ra,88(sp)
 476:	e8a2                	sd	s0,80(sp)
 478:	e0ca                	sd	s2,64(sp)
 47a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 47c:	0005c903          	lbu	s2,0(a1)
 480:	28090663          	beqz	s2,70c <vprintf+0x29a>
 484:	e4a6                	sd	s1,72(sp)
 486:	fc4e                	sd	s3,56(sp)
 488:	f852                	sd	s4,48(sp)
 48a:	f456                	sd	s5,40(sp)
 48c:	f05a                	sd	s6,32(sp)
 48e:	ec5e                	sd	s7,24(sp)
 490:	e862                	sd	s8,16(sp)
 492:	e466                	sd	s9,8(sp)
 494:	8b2a                	mv	s6,a0
 496:	8a2e                	mv	s4,a1
 498:	8bb2                	mv	s7,a2
  state = 0;
 49a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 49c:	4481                	li	s1,0
 49e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4a0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4a4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4a8:	06c00c93          	li	s9,108
 4ac:	a005                	j	4cc <vprintf+0x5a>
        putc(fd, c0);
 4ae:	85ca                	mv	a1,s2
 4b0:	855a                	mv	a0,s6
 4b2:	f07ff0ef          	jal	3b8 <putc>
 4b6:	a019                	j	4bc <vprintf+0x4a>
    } else if(state == '%'){
 4b8:	03598263          	beq	s3,s5,4dc <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4bc:	2485                	addiw	s1,s1,1
 4be:	8726                	mv	a4,s1
 4c0:	009a07b3          	add	a5,s4,s1
 4c4:	0007c903          	lbu	s2,0(a5)
 4c8:	22090a63          	beqz	s2,6fc <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4cc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4d0:	fe0994e3          	bnez	s3,4b8 <vprintf+0x46>
      if(c0 == '%'){
 4d4:	fd579de3          	bne	a5,s5,4ae <vprintf+0x3c>
        state = '%';
 4d8:	89be                	mv	s3,a5
 4da:	b7cd                	j	4bc <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4dc:	00ea06b3          	add	a3,s4,a4
 4e0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4e4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4e6:	c681                	beqz	a3,4ee <vprintf+0x7c>
 4e8:	9752                	add	a4,a4,s4
 4ea:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4ee:	05878363          	beq	a5,s8,534 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4f2:	05978d63          	beq	a5,s9,54c <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4f6:	07500713          	li	a4,117
 4fa:	0ee78763          	beq	a5,a4,5e8 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4fe:	07800713          	li	a4,120
 502:	12e78963          	beq	a5,a4,634 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 506:	07000713          	li	a4,112
 50a:	14e78e63          	beq	a5,a4,666 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 50e:	06300713          	li	a4,99
 512:	18e78e63          	beq	a5,a4,6ae <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 516:	07300713          	li	a4,115
 51a:	1ae78463          	beq	a5,a4,6c2 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 51e:	02500713          	li	a4,37
 522:	04e79563          	bne	a5,a4,56c <vprintf+0xfa>
        putc(fd, '%');
 526:	02500593          	li	a1,37
 52a:	855a                	mv	a0,s6
 52c:	e8dff0ef          	jal	3b8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 530:	4981                	li	s3,0
 532:	b769                	j	4bc <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 534:	008b8913          	addi	s2,s7,8
 538:	4685                	li	a3,1
 53a:	4629                	li	a2,10
 53c:	000ba583          	lw	a1,0(s7)
 540:	855a                	mv	a0,s6
 542:	e95ff0ef          	jal	3d6 <printint>
 546:	8bca                	mv	s7,s2
      state = 0;
 548:	4981                	li	s3,0
 54a:	bf8d                	j	4bc <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 54c:	06400793          	li	a5,100
 550:	02f68963          	beq	a3,a5,582 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 554:	06c00793          	li	a5,108
 558:	04f68263          	beq	a3,a5,59c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 55c:	07500793          	li	a5,117
 560:	0af68063          	beq	a3,a5,600 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 564:	07800793          	li	a5,120
 568:	0ef68263          	beq	a3,a5,64c <vprintf+0x1da>
        putc(fd, '%');
 56c:	02500593          	li	a1,37
 570:	855a                	mv	a0,s6
 572:	e47ff0ef          	jal	3b8 <putc>
        putc(fd, c0);
 576:	85ca                	mv	a1,s2
 578:	855a                	mv	a0,s6
 57a:	e3fff0ef          	jal	3b8 <putc>
      state = 0;
 57e:	4981                	li	s3,0
 580:	bf35                	j	4bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 582:	008b8913          	addi	s2,s7,8
 586:	4685                	li	a3,1
 588:	4629                	li	a2,10
 58a:	000bb583          	ld	a1,0(s7)
 58e:	855a                	mv	a0,s6
 590:	e47ff0ef          	jal	3d6 <printint>
        i += 1;
 594:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 596:	8bca                	mv	s7,s2
      state = 0;
 598:	4981                	li	s3,0
        i += 1;
 59a:	b70d                	j	4bc <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 59c:	06400793          	li	a5,100
 5a0:	02f60763          	beq	a2,a5,5ce <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5a4:	07500793          	li	a5,117
 5a8:	06f60963          	beq	a2,a5,61a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5ac:	07800793          	li	a5,120
 5b0:	faf61ee3          	bne	a2,a5,56c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4681                	li	a3,0
 5ba:	4641                	li	a2,16
 5bc:	000bb583          	ld	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	e15ff0ef          	jal	3d6 <printint>
        i += 2;
 5c6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
        i += 2;
 5cc:	bdc5                	j	4bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4685                	li	a3,1
 5d4:	4629                	li	a2,10
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	dfbff0ef          	jal	3d6 <printint>
        i += 2;
 5e0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
        i += 2;
 5e6:	bdd9                	j	4bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5e8:	008b8913          	addi	s2,s7,8
 5ec:	4681                	li	a3,0
 5ee:	4629                	li	a2,10
 5f0:	000be583          	lwu	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	de1ff0ef          	jal	3d6 <printint>
 5fa:	8bca                	mv	s7,s2
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	bd7d                	j	4bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 600:	008b8913          	addi	s2,s7,8
 604:	4681                	li	a3,0
 606:	4629                	li	a2,10
 608:	000bb583          	ld	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	dc9ff0ef          	jal	3d6 <printint>
        i += 1;
 612:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
        i += 1;
 618:	b555                	j	4bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4681                	li	a3,0
 620:	4629                	li	a2,10
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	dafff0ef          	jal	3d6 <printint>
        i += 2;
 62c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
        i += 2;
 632:	b569                	j	4bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 634:	008b8913          	addi	s2,s7,8
 638:	4681                	li	a3,0
 63a:	4641                	li	a2,16
 63c:	000be583          	lwu	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	d95ff0ef          	jal	3d6 <printint>
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
 64a:	bd8d                	j	4bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 64c:	008b8913          	addi	s2,s7,8
 650:	4681                	li	a3,0
 652:	4641                	li	a2,16
 654:	000bb583          	ld	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	d7dff0ef          	jal	3d6 <printint>
        i += 1;
 65e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 660:	8bca                	mv	s7,s2
      state = 0;
 662:	4981                	li	s3,0
        i += 1;
 664:	bda1                	j	4bc <vprintf+0x4a>
 666:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 668:	008b8d13          	addi	s10,s7,8
 66c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 670:	03000593          	li	a1,48
 674:	855a                	mv	a0,s6
 676:	d43ff0ef          	jal	3b8 <putc>
  putc(fd, 'x');
 67a:	07800593          	li	a1,120
 67e:	855a                	mv	a0,s6
 680:	d39ff0ef          	jal	3b8 <putc>
 684:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 686:	00000b97          	auipc	s7,0x0
 68a:	28ab8b93          	addi	s7,s7,650 # 910 <digits>
 68e:	03c9d793          	srli	a5,s3,0x3c
 692:	97de                	add	a5,a5,s7
 694:	0007c583          	lbu	a1,0(a5)
 698:	855a                	mv	a0,s6
 69a:	d1fff0ef          	jal	3b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69e:	0992                	slli	s3,s3,0x4
 6a0:	397d                	addiw	s2,s2,-1
 6a2:	fe0916e3          	bnez	s2,68e <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6a6:	8bea                	mv	s7,s10
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	6d02                	ld	s10,0(sp)
 6ac:	bd01                	j	4bc <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	000bc583          	lbu	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	d01ff0ef          	jal	3b8 <putc>
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bbf5                	j	4bc <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6c2:	008b8993          	addi	s3,s7,8
 6c6:	000bb903          	ld	s2,0(s7)
 6ca:	00090f63          	beqz	s2,6e8 <vprintf+0x276>
        for(; *s; s++)
 6ce:	00094583          	lbu	a1,0(s2)
 6d2:	c195                	beqz	a1,6f6 <vprintf+0x284>
          putc(fd, *s);
 6d4:	855a                	mv	a0,s6
 6d6:	ce3ff0ef          	jal	3b8 <putc>
        for(; *s; s++)
 6da:	0905                	addi	s2,s2,1
 6dc:	00094583          	lbu	a1,0(s2)
 6e0:	f9f5                	bnez	a1,6d4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6e2:	8bce                	mv	s7,s3
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	bbd9                	j	4bc <vprintf+0x4a>
          s = "(null)";
 6e8:	00000917          	auipc	s2,0x0
 6ec:	22090913          	addi	s2,s2,544 # 908 <malloc+0x114>
        for(; *s; s++)
 6f0:	02800593          	li	a1,40
 6f4:	b7c5                	j	6d4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6f6:	8bce                	mv	s7,s3
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b3c9                	j	4bc <vprintf+0x4a>
 6fc:	64a6                	ld	s1,72(sp)
 6fe:	79e2                	ld	s3,56(sp)
 700:	7a42                	ld	s4,48(sp)
 702:	7aa2                	ld	s5,40(sp)
 704:	7b02                	ld	s6,32(sp)
 706:	6be2                	ld	s7,24(sp)
 708:	6c42                	ld	s8,16(sp)
 70a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 70c:	60e6                	ld	ra,88(sp)
 70e:	6446                	ld	s0,80(sp)
 710:	6906                	ld	s2,64(sp)
 712:	6125                	addi	sp,sp,96
 714:	8082                	ret

0000000000000716 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 716:	715d                	addi	sp,sp,-80
 718:	ec06                	sd	ra,24(sp)
 71a:	e822                	sd	s0,16(sp)
 71c:	1000                	addi	s0,sp,32
 71e:	e010                	sd	a2,0(s0)
 720:	e414                	sd	a3,8(s0)
 722:	e818                	sd	a4,16(s0)
 724:	ec1c                	sd	a5,24(s0)
 726:	03043023          	sd	a6,32(s0)
 72a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 72e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 732:	8622                	mv	a2,s0
 734:	d3fff0ef          	jal	472 <vprintf>
}
 738:	60e2                	ld	ra,24(sp)
 73a:	6442                	ld	s0,16(sp)
 73c:	6161                	addi	sp,sp,80
 73e:	8082                	ret

0000000000000740 <printf>:

void
printf(const char *fmt, ...)
{
 740:	711d                	addi	sp,sp,-96
 742:	ec06                	sd	ra,24(sp)
 744:	e822                	sd	s0,16(sp)
 746:	1000                	addi	s0,sp,32
 748:	e40c                	sd	a1,8(s0)
 74a:	e810                	sd	a2,16(s0)
 74c:	ec14                	sd	a3,24(s0)
 74e:	f018                	sd	a4,32(s0)
 750:	f41c                	sd	a5,40(s0)
 752:	03043823          	sd	a6,48(s0)
 756:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 75a:	00840613          	addi	a2,s0,8
 75e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 762:	85aa                	mv	a1,a0
 764:	4505                	li	a0,1
 766:	d0dff0ef          	jal	472 <vprintf>
}
 76a:	60e2                	ld	ra,24(sp)
 76c:	6442                	ld	s0,16(sp)
 76e:	6125                	addi	sp,sp,96
 770:	8082                	ret

0000000000000772 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 772:	1141                	addi	sp,sp,-16
 774:	e422                	sd	s0,8(sp)
 776:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 778:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77c:	00001797          	auipc	a5,0x1
 780:	8847b783          	ld	a5,-1916(a5) # 1000 <freep>
 784:	a02d                	j	7ae <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 786:	4618                	lw	a4,8(a2)
 788:	9f2d                	addw	a4,a4,a1
 78a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 78e:	6398                	ld	a4,0(a5)
 790:	6310                	ld	a2,0(a4)
 792:	a83d                	j	7d0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 794:	ff852703          	lw	a4,-8(a0)
 798:	9f31                	addw	a4,a4,a2
 79a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 79c:	ff053683          	ld	a3,-16(a0)
 7a0:	a091                	j	7e4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a2:	6398                	ld	a4,0(a5)
 7a4:	00e7e463          	bltu	a5,a4,7ac <free+0x3a>
 7a8:	00e6ea63          	bltu	a3,a4,7bc <free+0x4a>
{
 7ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ae:	fed7fae3          	bgeu	a5,a3,7a2 <free+0x30>
 7b2:	6398                	ld	a4,0(a5)
 7b4:	00e6e463          	bltu	a3,a4,7bc <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b8:	fee7eae3          	bltu	a5,a4,7ac <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7bc:	ff852583          	lw	a1,-8(a0)
 7c0:	6390                	ld	a2,0(a5)
 7c2:	02059813          	slli	a6,a1,0x20
 7c6:	01c85713          	srli	a4,a6,0x1c
 7ca:	9736                	add	a4,a4,a3
 7cc:	fae60de3          	beq	a2,a4,786 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d4:	4790                	lw	a2,8(a5)
 7d6:	02061593          	slli	a1,a2,0x20
 7da:	01c5d713          	srli	a4,a1,0x1c
 7de:	973e                	add	a4,a4,a5
 7e0:	fae68ae3          	beq	a3,a4,794 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7e4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e6:	00001717          	auipc	a4,0x1
 7ea:	80f73d23          	sd	a5,-2022(a4) # 1000 <freep>
}
 7ee:	6422                	ld	s0,8(sp)
 7f0:	0141                	addi	sp,sp,16
 7f2:	8082                	ret

00000000000007f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f4:	7139                	addi	sp,sp,-64
 7f6:	fc06                	sd	ra,56(sp)
 7f8:	f822                	sd	s0,48(sp)
 7fa:	f426                	sd	s1,40(sp)
 7fc:	ec4e                	sd	s3,24(sp)
 7fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 800:	02051493          	slli	s1,a0,0x20
 804:	9081                	srli	s1,s1,0x20
 806:	04bd                	addi	s1,s1,15
 808:	8091                	srli	s1,s1,0x4
 80a:	0014899b          	addiw	s3,s1,1
 80e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 810:	00000517          	auipc	a0,0x0
 814:	7f053503          	ld	a0,2032(a0) # 1000 <freep>
 818:	c915                	beqz	a0,84c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81c:	4798                	lw	a4,8(a5)
 81e:	08977a63          	bgeu	a4,s1,8b2 <malloc+0xbe>
 822:	f04a                	sd	s2,32(sp)
 824:	e852                	sd	s4,16(sp)
 826:	e456                	sd	s5,8(sp)
 828:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 82a:	8a4e                	mv	s4,s3
 82c:	0009871b          	sext.w	a4,s3
 830:	6685                	lui	a3,0x1
 832:	00d77363          	bgeu	a4,a3,838 <malloc+0x44>
 836:	6a05                	lui	s4,0x1
 838:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 840:	00000917          	auipc	s2,0x0
 844:	7c090913          	addi	s2,s2,1984 # 1000 <freep>
  if(p == SBRK_ERROR)
 848:	5afd                	li	s5,-1
 84a:	a081                	j	88a <malloc+0x96>
 84c:	f04a                	sd	s2,32(sp)
 84e:	e852                	sd	s4,16(sp)
 850:	e456                	sd	s5,8(sp)
 852:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 854:	00000797          	auipc	a5,0x0
 858:	7bc78793          	addi	a5,a5,1980 # 1010 <base>
 85c:	00000717          	auipc	a4,0x0
 860:	7af73223          	sd	a5,1956(a4) # 1000 <freep>
 864:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 866:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86a:	b7c1                	j	82a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 86c:	6398                	ld	a4,0(a5)
 86e:	e118                	sd	a4,0(a0)
 870:	a8a9                	j	8ca <malloc+0xd6>
  hp->s.size = nu;
 872:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 876:	0541                	addi	a0,a0,16
 878:	efbff0ef          	jal	772 <free>
  return freep;
 87c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 880:	c12d                	beqz	a0,8e2 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 882:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 884:	4798                	lw	a4,8(a5)
 886:	02977263          	bgeu	a4,s1,8aa <malloc+0xb6>
    if(p == freep)
 88a:	00093703          	ld	a4,0(s2)
 88e:	853e                	mv	a0,a5
 890:	fef719e3          	bne	a4,a5,882 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 894:	8552                	mv	a0,s4
 896:	a1fff0ef          	jal	2b4 <sbrk>
  if(p == SBRK_ERROR)
 89a:	fd551ce3          	bne	a0,s5,872 <malloc+0x7e>
        return 0;
 89e:	4501                	li	a0,0
 8a0:	7902                	ld	s2,32(sp)
 8a2:	6a42                	ld	s4,16(sp)
 8a4:	6aa2                	ld	s5,8(sp)
 8a6:	6b02                	ld	s6,0(sp)
 8a8:	a03d                	j	8d6 <malloc+0xe2>
 8aa:	7902                	ld	s2,32(sp)
 8ac:	6a42                	ld	s4,16(sp)
 8ae:	6aa2                	ld	s5,8(sp)
 8b0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8b2:	fae48de3          	beq	s1,a4,86c <malloc+0x78>
        p->s.size -= nunits;
 8b6:	4137073b          	subw	a4,a4,s3
 8ba:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8bc:	02071693          	slli	a3,a4,0x20
 8c0:	01c6d713          	srli	a4,a3,0x1c
 8c4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ca:	00000717          	auipc	a4,0x0
 8ce:	72a73b23          	sd	a0,1846(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d2:	01078513          	addi	a0,a5,16
  }
}
 8d6:	70e2                	ld	ra,56(sp)
 8d8:	7442                	ld	s0,48(sp)
 8da:	74a2                	ld	s1,40(sp)
 8dc:	69e2                	ld	s3,24(sp)
 8de:	6121                	addi	sp,sp,64
 8e0:	8082                	ret
 8e2:	7902                	ld	s2,32(sp)
 8e4:	6a42                	ld	s4,16(sp)
 8e6:	6aa2                	ld	s5,8(sp)
 8e8:	6b02                	ld	s6,0(sp)
 8ea:	b7f5                	j	8d6 <malloc+0xe2>
