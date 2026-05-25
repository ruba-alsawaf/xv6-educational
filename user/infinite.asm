
user/_infinite:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main() {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    while(1) {
   6:	a001                	j	6 <main+0x6>

0000000000000008 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
   8:	1141                	addi	sp,sp,-16
   a:	e406                	sd	ra,8(sp)
   c:	e022                	sd	s0,0(sp)
   e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  10:	ff1ff0ef          	jal	0 <main>
  exit(r);
  14:	288000ef          	jal	29c <exit>

0000000000000018 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  18:	1141                	addi	sp,sp,-16
  1a:	e422                	sd	s0,8(sp)
  1c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  1e:	87aa                	mv	a5,a0
  20:	0585                	addi	a1,a1,1
  22:	0785                	addi	a5,a5,1
  24:	fff5c703          	lbu	a4,-1(a1)
  28:	fee78fa3          	sb	a4,-1(a5)
  2c:	fb75                	bnez	a4,20 <strcpy+0x8>
    ;
  return os;
}
  2e:	6422                	ld	s0,8(sp)
  30:	0141                	addi	sp,sp,16
  32:	8082                	ret

0000000000000034 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  34:	1141                	addi	sp,sp,-16
  36:	e422                	sd	s0,8(sp)
  38:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  3a:	00054783          	lbu	a5,0(a0)
  3e:	cb91                	beqz	a5,52 <strcmp+0x1e>
  40:	0005c703          	lbu	a4,0(a1)
  44:	00f71763          	bne	a4,a5,52 <strcmp+0x1e>
    p++, q++;
  48:	0505                	addi	a0,a0,1
  4a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  4c:	00054783          	lbu	a5,0(a0)
  50:	fbe5                	bnez	a5,40 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  52:	0005c503          	lbu	a0,0(a1)
}
  56:	40a7853b          	subw	a0,a5,a0
  5a:	6422                	ld	s0,8(sp)
  5c:	0141                	addi	sp,sp,16
  5e:	8082                	ret

0000000000000060 <strlen>:

uint
strlen(const char *s)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  66:	00054783          	lbu	a5,0(a0)
  6a:	cf91                	beqz	a5,86 <strlen+0x26>
  6c:	0505                	addi	a0,a0,1
  6e:	87aa                	mv	a5,a0
  70:	86be                	mv	a3,a5
  72:	0785                	addi	a5,a5,1
  74:	fff7c703          	lbu	a4,-1(a5)
  78:	ff65                	bnez	a4,70 <strlen+0x10>
  7a:	40a6853b          	subw	a0,a3,a0
  7e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  80:	6422                	ld	s0,8(sp)
  82:	0141                	addi	sp,sp,16
  84:	8082                	ret
  for(n = 0; s[n]; n++)
  86:	4501                	li	a0,0
  88:	bfe5                	j	80 <strlen+0x20>

000000000000008a <memset>:

void*
memset(void *dst, int c, uint n)
{
  8a:	1141                	addi	sp,sp,-16
  8c:	e422                	sd	s0,8(sp)
  8e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  90:	ca19                	beqz	a2,a6 <memset+0x1c>
  92:	87aa                	mv	a5,a0
  94:	1602                	slli	a2,a2,0x20
  96:	9201                	srli	a2,a2,0x20
  98:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  9c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  a0:	0785                	addi	a5,a5,1
  a2:	fee79de3          	bne	a5,a4,9c <memset+0x12>
  }
  return dst;
}
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret

00000000000000ac <strchr>:

char*
strchr(const char *s, char c)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e422                	sd	s0,8(sp)
  b0:	0800                	addi	s0,sp,16
  for(; *s; s++)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	cb99                	beqz	a5,cc <strchr+0x20>
    if(*s == c)
  b8:	00f58763          	beq	a1,a5,c6 <strchr+0x1a>
  for(; *s; s++)
  bc:	0505                	addi	a0,a0,1
  be:	00054783          	lbu	a5,0(a0)
  c2:	fbfd                	bnez	a5,b8 <strchr+0xc>
      return (char*)s;
  return 0;
  c4:	4501                	li	a0,0
}
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret
  return 0;
  cc:	4501                	li	a0,0
  ce:	bfe5                	j	c6 <strchr+0x1a>

00000000000000d0 <gets>:

char*
gets(char *buf, int max)
{
  d0:	711d                	addi	sp,sp,-96
  d2:	ec86                	sd	ra,88(sp)
  d4:	e8a2                	sd	s0,80(sp)
  d6:	e4a6                	sd	s1,72(sp)
  d8:	e0ca                	sd	s2,64(sp)
  da:	fc4e                	sd	s3,56(sp)
  dc:	f852                	sd	s4,48(sp)
  de:	f456                	sd	s5,40(sp)
  e0:	f05a                	sd	s6,32(sp)
  e2:	ec5e                	sd	s7,24(sp)
  e4:	1080                	addi	s0,sp,96
  e6:	8baa                	mv	s7,a0
  e8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  ea:	892a                	mv	s2,a0
  ec:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
  ee:	4aa9                	li	s5,10
  f0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
  f2:	89a6                	mv	s3,s1
  f4:	2485                	addiw	s1,s1,1
  f6:	0344d663          	bge	s1,s4,122 <gets+0x52>
    cc = read(0, &c, 1);
  fa:	4605                	li	a2,1
  fc:	faf40593          	addi	a1,s0,-81
 100:	4501                	li	a0,0
 102:	1b2000ef          	jal	2b4 <read>
    if(cc < 1)
 106:	00a05e63          	blez	a0,122 <gets+0x52>
    buf[i++] = c;
 10a:	faf44783          	lbu	a5,-81(s0)
 10e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 112:	01578763          	beq	a5,s5,120 <gets+0x50>
 116:	0905                	addi	s2,s2,1
 118:	fd679de3          	bne	a5,s6,f2 <gets+0x22>
    buf[i++] = c;
 11c:	89a6                	mv	s3,s1
 11e:	a011                	j	122 <gets+0x52>
 120:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 122:	99de                	add	s3,s3,s7
 124:	00098023          	sb	zero,0(s3)
  return buf;
}
 128:	855e                	mv	a0,s7
 12a:	60e6                	ld	ra,88(sp)
 12c:	6446                	ld	s0,80(sp)
 12e:	64a6                	ld	s1,72(sp)
 130:	6906                	ld	s2,64(sp)
 132:	79e2                	ld	s3,56(sp)
 134:	7a42                	ld	s4,48(sp)
 136:	7aa2                	ld	s5,40(sp)
 138:	7b02                	ld	s6,32(sp)
 13a:	6be2                	ld	s7,24(sp)
 13c:	6125                	addi	sp,sp,96
 13e:	8082                	ret

0000000000000140 <stat>:

int
stat(const char *n, struct stat *st)
{
 140:	1101                	addi	sp,sp,-32
 142:	ec06                	sd	ra,24(sp)
 144:	e822                	sd	s0,16(sp)
 146:	e04a                	sd	s2,0(sp)
 148:	1000                	addi	s0,sp,32
 14a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 14c:	4581                	li	a1,0
 14e:	18e000ef          	jal	2dc <open>
  if(fd < 0)
 152:	02054263          	bltz	a0,176 <stat+0x36>
 156:	e426                	sd	s1,8(sp)
 158:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 15a:	85ca                	mv	a1,s2
 15c:	198000ef          	jal	2f4 <fstat>
 160:	892a                	mv	s2,a0
  close(fd);
 162:	8526                	mv	a0,s1
 164:	160000ef          	jal	2c4 <close>
  return r;
 168:	64a2                	ld	s1,8(sp)
}
 16a:	854a                	mv	a0,s2
 16c:	60e2                	ld	ra,24(sp)
 16e:	6442                	ld	s0,16(sp)
 170:	6902                	ld	s2,0(sp)
 172:	6105                	addi	sp,sp,32
 174:	8082                	ret
    return -1;
 176:	597d                	li	s2,-1
 178:	bfcd                	j	16a <stat+0x2a>

000000000000017a <atoi>:

int
atoi(const char *s)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e422                	sd	s0,8(sp)
 17e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 180:	00054683          	lbu	a3,0(a0)
 184:	fd06879b          	addiw	a5,a3,-48
 188:	0ff7f793          	zext.b	a5,a5
 18c:	4625                	li	a2,9
 18e:	02f66863          	bltu	a2,a5,1be <atoi+0x44>
 192:	872a                	mv	a4,a0
  n = 0;
 194:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 196:	0705                	addi	a4,a4,1
 198:	0025179b          	slliw	a5,a0,0x2
 19c:	9fa9                	addw	a5,a5,a0
 19e:	0017979b          	slliw	a5,a5,0x1
 1a2:	9fb5                	addw	a5,a5,a3
 1a4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1a8:	00074683          	lbu	a3,0(a4)
 1ac:	fd06879b          	addiw	a5,a3,-48
 1b0:	0ff7f793          	zext.b	a5,a5
 1b4:	fef671e3          	bgeu	a2,a5,196 <atoi+0x1c>
  return n;
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  n = 0;
 1be:	4501                	li	a0,0
 1c0:	bfe5                	j	1b8 <atoi+0x3e>

00000000000001c2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1c8:	02b57463          	bgeu	a0,a1,1f0 <memmove+0x2e>
    while(n-- > 0)
 1cc:	00c05f63          	blez	a2,1ea <memmove+0x28>
 1d0:	1602                	slli	a2,a2,0x20
 1d2:	9201                	srli	a2,a2,0x20
 1d4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1d8:	872a                	mv	a4,a0
      *dst++ = *src++;
 1da:	0585                	addi	a1,a1,1
 1dc:	0705                	addi	a4,a4,1
 1de:	fff5c683          	lbu	a3,-1(a1)
 1e2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1e6:	fef71ae3          	bne	a4,a5,1da <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret
    dst += n;
 1f0:	00c50733          	add	a4,a0,a2
    src += n;
 1f4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 1f6:	fec05ae3          	blez	a2,1ea <memmove+0x28>
 1fa:	fff6079b          	addiw	a5,a2,-1
 1fe:	1782                	slli	a5,a5,0x20
 200:	9381                	srli	a5,a5,0x20
 202:	fff7c793          	not	a5,a5
 206:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 208:	15fd                	addi	a1,a1,-1
 20a:	177d                	addi	a4,a4,-1
 20c:	0005c683          	lbu	a3,0(a1)
 210:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 214:	fee79ae3          	bne	a5,a4,208 <memmove+0x46>
 218:	bfc9                	j	1ea <memmove+0x28>

000000000000021a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 220:	ca05                	beqz	a2,250 <memcmp+0x36>
 222:	fff6069b          	addiw	a3,a2,-1
 226:	1682                	slli	a3,a3,0x20
 228:	9281                	srli	a3,a3,0x20
 22a:	0685                	addi	a3,a3,1
 22c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 22e:	00054783          	lbu	a5,0(a0)
 232:	0005c703          	lbu	a4,0(a1)
 236:	00e79863          	bne	a5,a4,246 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 23a:	0505                	addi	a0,a0,1
    p2++;
 23c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 23e:	fed518e3          	bne	a0,a3,22e <memcmp+0x14>
  }
  return 0;
 242:	4501                	li	a0,0
 244:	a019                	j	24a <memcmp+0x30>
      return *p1 - *p2;
 246:	40e7853b          	subw	a0,a5,a4
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
  return 0;
 250:	4501                	li	a0,0
 252:	bfe5                	j	24a <memcmp+0x30>

0000000000000254 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 254:	1141                	addi	sp,sp,-16
 256:	e406                	sd	ra,8(sp)
 258:	e022                	sd	s0,0(sp)
 25a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 25c:	f67ff0ef          	jal	1c2 <memmove>
}
 260:	60a2                	ld	ra,8(sp)
 262:	6402                	ld	s0,0(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret

0000000000000268 <sbrk>:

char *
sbrk(int n) {
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 270:	4585                	li	a1,1
 272:	0c2000ef          	jal	334 <sys_sbrk>
}
 276:	60a2                	ld	ra,8(sp)
 278:	6402                	ld	s0,0(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret

000000000000027e <sbrklazy>:

char *
sbrklazy(int n) {
 27e:	1141                	addi	sp,sp,-16
 280:	e406                	sd	ra,8(sp)
 282:	e022                	sd	s0,0(sp)
 284:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 286:	4589                	li	a1,2
 288:	0ac000ef          	jal	334 <sys_sbrk>
}
 28c:	60a2                	ld	ra,8(sp)
 28e:	6402                	ld	s0,0(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 294:	4885                	li	a7,1
 ecall
 296:	00000073          	ecall
 ret
 29a:	8082                	ret

000000000000029c <exit>:
.global exit
exit:
 li a7, SYS_exit
 29c:	4889                	li	a7,2
 ecall
 29e:	00000073          	ecall
 ret
 2a2:	8082                	ret

00000000000002a4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2a4:	488d                	li	a7,3
 ecall
 2a6:	00000073          	ecall
 ret
 2aa:	8082                	ret

00000000000002ac <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ac:	4891                	li	a7,4
 ecall
 2ae:	00000073          	ecall
 ret
 2b2:	8082                	ret

00000000000002b4 <read>:
.global read
read:
 li a7, SYS_read
 2b4:	4895                	li	a7,5
 ecall
 2b6:	00000073          	ecall
 ret
 2ba:	8082                	ret

00000000000002bc <write>:
.global write
write:
 li a7, SYS_write
 2bc:	48c1                	li	a7,16
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <close>:
.global close
close:
 li a7, SYS_close
 2c4:	48d5                	li	a7,21
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <kill>:
.global kill
kill:
 li a7, SYS_kill
 2cc:	4899                	li	a7,6
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2d4:	489d                	li	a7,7
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <open>:
.global open
open:
 li a7, SYS_open
 2dc:	48bd                	li	a7,15
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2e4:	48c5                	li	a7,17
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2ec:	48c9                	li	a7,18
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2f4:	48a1                	li	a7,8
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <link>:
.global link
link:
 li a7, SYS_link
 2fc:	48cd                	li	a7,19
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 304:	48d1                	li	a7,20
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 30c:	48a5                	li	a7,9
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <dup>:
.global dup
dup:
 li a7, SYS_dup
 314:	48a9                	li	a7,10
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 31c:	48ad                	li	a7,11
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 324:	48e9                	li	a7,26
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 32c:	48ed                	li	a7,27
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 334:	48b1                	li	a7,12
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <pause>:
.global pause
pause:
 li a7, SYS_pause
 33c:	48b5                	li	a7,13
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 344:	48b9                	li	a7,14
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <csread>:
.global csread
csread:
 li a7, SYS_csread
 34c:	48d9                	li	a7,22
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 354:	48dd                	li	a7,23
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 35c:	48e1                	li	a7,24
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <memread>:
.global memread
memread:
 li a7, SYS_memread
 364:	48e5                	li	a7,25
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 36c:	1101                	addi	sp,sp,-32
 36e:	ec06                	sd	ra,24(sp)
 370:	e822                	sd	s0,16(sp)
 372:	1000                	addi	s0,sp,32
 374:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 378:	4605                	li	a2,1
 37a:	fef40593          	addi	a1,s0,-17
 37e:	f3fff0ef          	jal	2bc <write>
}
 382:	60e2                	ld	ra,24(sp)
 384:	6442                	ld	s0,16(sp)
 386:	6105                	addi	sp,sp,32
 388:	8082                	ret

000000000000038a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 38a:	715d                	addi	sp,sp,-80
 38c:	e486                	sd	ra,72(sp)
 38e:	e0a2                	sd	s0,64(sp)
 390:	f84a                	sd	s2,48(sp)
 392:	0880                	addi	s0,sp,80
 394:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 396:	c299                	beqz	a3,39c <printint+0x12>
 398:	0805c363          	bltz	a1,41e <printint+0x94>
  neg = 0;
 39c:	4881                	li	a7,0
 39e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3a2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3a4:	00000517          	auipc	a0,0x0
 3a8:	50450513          	addi	a0,a0,1284 # 8a8 <digits>
 3ac:	883e                	mv	a6,a5
 3ae:	2785                	addiw	a5,a5,1
 3b0:	02c5f733          	remu	a4,a1,a2
 3b4:	972a                	add	a4,a4,a0
 3b6:	00074703          	lbu	a4,0(a4)
 3ba:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3be:	872e                	mv	a4,a1
 3c0:	02c5d5b3          	divu	a1,a1,a2
 3c4:	0685                	addi	a3,a3,1
 3c6:	fec773e3          	bgeu	a4,a2,3ac <printint+0x22>
  if(neg)
 3ca:	00088b63          	beqz	a7,3e0 <printint+0x56>
    buf[i++] = '-';
 3ce:	fd078793          	addi	a5,a5,-48
 3d2:	97a2                	add	a5,a5,s0
 3d4:	02d00713          	li	a4,45
 3d8:	fee78423          	sb	a4,-24(a5)
 3dc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 3e0:	02f05a63          	blez	a5,414 <printint+0x8a>
 3e4:	fc26                	sd	s1,56(sp)
 3e6:	f44e                	sd	s3,40(sp)
 3e8:	fb840713          	addi	a4,s0,-72
 3ec:	00f704b3          	add	s1,a4,a5
 3f0:	fff70993          	addi	s3,a4,-1
 3f4:	99be                	add	s3,s3,a5
 3f6:	37fd                	addiw	a5,a5,-1
 3f8:	1782                	slli	a5,a5,0x20
 3fa:	9381                	srli	a5,a5,0x20
 3fc:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 400:	fff4c583          	lbu	a1,-1(s1)
 404:	854a                	mv	a0,s2
 406:	f67ff0ef          	jal	36c <putc>
  while(--i >= 0)
 40a:	14fd                	addi	s1,s1,-1
 40c:	ff349ae3          	bne	s1,s3,400 <printint+0x76>
 410:	74e2                	ld	s1,56(sp)
 412:	79a2                	ld	s3,40(sp)
}
 414:	60a6                	ld	ra,72(sp)
 416:	6406                	ld	s0,64(sp)
 418:	7942                	ld	s2,48(sp)
 41a:	6161                	addi	sp,sp,80
 41c:	8082                	ret
    x = -xx;
 41e:	40b005b3          	neg	a1,a1
    neg = 1;
 422:	4885                	li	a7,1
    x = -xx;
 424:	bfad                	j	39e <printint+0x14>

0000000000000426 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 426:	711d                	addi	sp,sp,-96
 428:	ec86                	sd	ra,88(sp)
 42a:	e8a2                	sd	s0,80(sp)
 42c:	e0ca                	sd	s2,64(sp)
 42e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 430:	0005c903          	lbu	s2,0(a1)
 434:	28090663          	beqz	s2,6c0 <vprintf+0x29a>
 438:	e4a6                	sd	s1,72(sp)
 43a:	fc4e                	sd	s3,56(sp)
 43c:	f852                	sd	s4,48(sp)
 43e:	f456                	sd	s5,40(sp)
 440:	f05a                	sd	s6,32(sp)
 442:	ec5e                	sd	s7,24(sp)
 444:	e862                	sd	s8,16(sp)
 446:	e466                	sd	s9,8(sp)
 448:	8b2a                	mv	s6,a0
 44a:	8a2e                	mv	s4,a1
 44c:	8bb2                	mv	s7,a2
  state = 0;
 44e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 450:	4481                	li	s1,0
 452:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 454:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 458:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 45c:	06c00c93          	li	s9,108
 460:	a005                	j	480 <vprintf+0x5a>
        putc(fd, c0);
 462:	85ca                	mv	a1,s2
 464:	855a                	mv	a0,s6
 466:	f07ff0ef          	jal	36c <putc>
 46a:	a019                	j	470 <vprintf+0x4a>
    } else if(state == '%'){
 46c:	03598263          	beq	s3,s5,490 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 470:	2485                	addiw	s1,s1,1
 472:	8726                	mv	a4,s1
 474:	009a07b3          	add	a5,s4,s1
 478:	0007c903          	lbu	s2,0(a5)
 47c:	22090a63          	beqz	s2,6b0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 480:	0009079b          	sext.w	a5,s2
    if(state == 0){
 484:	fe0994e3          	bnez	s3,46c <vprintf+0x46>
      if(c0 == '%'){
 488:	fd579de3          	bne	a5,s5,462 <vprintf+0x3c>
        state = '%';
 48c:	89be                	mv	s3,a5
 48e:	b7cd                	j	470 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 490:	00ea06b3          	add	a3,s4,a4
 494:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 498:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 49a:	c681                	beqz	a3,4a2 <vprintf+0x7c>
 49c:	9752                	add	a4,a4,s4
 49e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4a2:	05878363          	beq	a5,s8,4e8 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4a6:	05978d63          	beq	a5,s9,500 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4aa:	07500713          	li	a4,117
 4ae:	0ee78763          	beq	a5,a4,59c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4b2:	07800713          	li	a4,120
 4b6:	12e78963          	beq	a5,a4,5e8 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4ba:	07000713          	li	a4,112
 4be:	14e78e63          	beq	a5,a4,61a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4c2:	06300713          	li	a4,99
 4c6:	18e78e63          	beq	a5,a4,662 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4ca:	07300713          	li	a4,115
 4ce:	1ae78463          	beq	a5,a4,676 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4d2:	02500713          	li	a4,37
 4d6:	04e79563          	bne	a5,a4,520 <vprintf+0xfa>
        putc(fd, '%');
 4da:	02500593          	li	a1,37
 4de:	855a                	mv	a0,s6
 4e0:	e8dff0ef          	jal	36c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4e4:	4981                	li	s3,0
 4e6:	b769                	j	470 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4e8:	008b8913          	addi	s2,s7,8
 4ec:	4685                	li	a3,1
 4ee:	4629                	li	a2,10
 4f0:	000ba583          	lw	a1,0(s7)
 4f4:	855a                	mv	a0,s6
 4f6:	e95ff0ef          	jal	38a <printint>
 4fa:	8bca                	mv	s7,s2
      state = 0;
 4fc:	4981                	li	s3,0
 4fe:	bf8d                	j	470 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 500:	06400793          	li	a5,100
 504:	02f68963          	beq	a3,a5,536 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 508:	06c00793          	li	a5,108
 50c:	04f68263          	beq	a3,a5,550 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 510:	07500793          	li	a5,117
 514:	0af68063          	beq	a3,a5,5b4 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 518:	07800793          	li	a5,120
 51c:	0ef68263          	beq	a3,a5,600 <vprintf+0x1da>
        putc(fd, '%');
 520:	02500593          	li	a1,37
 524:	855a                	mv	a0,s6
 526:	e47ff0ef          	jal	36c <putc>
        putc(fd, c0);
 52a:	85ca                	mv	a1,s2
 52c:	855a                	mv	a0,s6
 52e:	e3fff0ef          	jal	36c <putc>
      state = 0;
 532:	4981                	li	s3,0
 534:	bf35                	j	470 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 536:	008b8913          	addi	s2,s7,8
 53a:	4685                	li	a3,1
 53c:	4629                	li	a2,10
 53e:	000bb583          	ld	a1,0(s7)
 542:	855a                	mv	a0,s6
 544:	e47ff0ef          	jal	38a <printint>
        i += 1;
 548:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 54a:	8bca                	mv	s7,s2
      state = 0;
 54c:	4981                	li	s3,0
        i += 1;
 54e:	b70d                	j	470 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 550:	06400793          	li	a5,100
 554:	02f60763          	beq	a2,a5,582 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 558:	07500793          	li	a5,117
 55c:	06f60963          	beq	a2,a5,5ce <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 560:	07800793          	li	a5,120
 564:	faf61ee3          	bne	a2,a5,520 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 568:	008b8913          	addi	s2,s7,8
 56c:	4681                	li	a3,0
 56e:	4641                	li	a2,16
 570:	000bb583          	ld	a1,0(s7)
 574:	855a                	mv	a0,s6
 576:	e15ff0ef          	jal	38a <printint>
        i += 2;
 57a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
        i += 2;
 580:	bdc5                	j	470 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 582:	008b8913          	addi	s2,s7,8
 586:	4685                	li	a3,1
 588:	4629                	li	a2,10
 58a:	000bb583          	ld	a1,0(s7)
 58e:	855a                	mv	a0,s6
 590:	dfbff0ef          	jal	38a <printint>
        i += 2;
 594:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 596:	8bca                	mv	s7,s2
      state = 0;
 598:	4981                	li	s3,0
        i += 2;
 59a:	bdd9                	j	470 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 59c:	008b8913          	addi	s2,s7,8
 5a0:	4681                	li	a3,0
 5a2:	4629                	li	a2,10
 5a4:	000be583          	lwu	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	de1ff0ef          	jal	38a <printint>
 5ae:	8bca                	mv	s7,s2
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	bd7d                	j	470 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4681                	li	a3,0
 5ba:	4629                	li	a2,10
 5bc:	000bb583          	ld	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	dc9ff0ef          	jal	38a <printint>
        i += 1;
 5c6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
        i += 1;
 5cc:	b555                	j	470 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4629                	li	a2,10
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	dafff0ef          	jal	38a <printint>
        i += 2;
 5e0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
        i += 2;
 5e6:	b569                	j	470 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5e8:	008b8913          	addi	s2,s7,8
 5ec:	4681                	li	a3,0
 5ee:	4641                	li	a2,16
 5f0:	000be583          	lwu	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	d95ff0ef          	jal	38a <printint>
 5fa:	8bca                	mv	s7,s2
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	bd8d                	j	470 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 600:	008b8913          	addi	s2,s7,8
 604:	4681                	li	a3,0
 606:	4641                	li	a2,16
 608:	000bb583          	ld	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	d7dff0ef          	jal	38a <printint>
        i += 1;
 612:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
        i += 1;
 618:	bda1                	j	470 <vprintf+0x4a>
 61a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 61c:	008b8d13          	addi	s10,s7,8
 620:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 624:	03000593          	li	a1,48
 628:	855a                	mv	a0,s6
 62a:	d43ff0ef          	jal	36c <putc>
  putc(fd, 'x');
 62e:	07800593          	li	a1,120
 632:	855a                	mv	a0,s6
 634:	d39ff0ef          	jal	36c <putc>
 638:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 63a:	00000b97          	auipc	s7,0x0
 63e:	26eb8b93          	addi	s7,s7,622 # 8a8 <digits>
 642:	03c9d793          	srli	a5,s3,0x3c
 646:	97de                	add	a5,a5,s7
 648:	0007c583          	lbu	a1,0(a5)
 64c:	855a                	mv	a0,s6
 64e:	d1fff0ef          	jal	36c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 652:	0992                	slli	s3,s3,0x4
 654:	397d                	addiw	s2,s2,-1
 656:	fe0916e3          	bnez	s2,642 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 65a:	8bea                	mv	s7,s10
      state = 0;
 65c:	4981                	li	s3,0
 65e:	6d02                	ld	s10,0(sp)
 660:	bd01                	j	470 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 662:	008b8913          	addi	s2,s7,8
 666:	000bc583          	lbu	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	d01ff0ef          	jal	36c <putc>
 670:	8bca                	mv	s7,s2
      state = 0;
 672:	4981                	li	s3,0
 674:	bbf5                	j	470 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 676:	008b8993          	addi	s3,s7,8
 67a:	000bb903          	ld	s2,0(s7)
 67e:	00090f63          	beqz	s2,69c <vprintf+0x276>
        for(; *s; s++)
 682:	00094583          	lbu	a1,0(s2)
 686:	c195                	beqz	a1,6aa <vprintf+0x284>
          putc(fd, *s);
 688:	855a                	mv	a0,s6
 68a:	ce3ff0ef          	jal	36c <putc>
        for(; *s; s++)
 68e:	0905                	addi	s2,s2,1
 690:	00094583          	lbu	a1,0(s2)
 694:	f9f5                	bnez	a1,688 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 696:	8bce                	mv	s7,s3
      state = 0;
 698:	4981                	li	s3,0
 69a:	bbd9                	j	470 <vprintf+0x4a>
          s = "(null)";
 69c:	00000917          	auipc	s2,0x0
 6a0:	20490913          	addi	s2,s2,516 # 8a0 <malloc+0xf8>
        for(; *s; s++)
 6a4:	02800593          	li	a1,40
 6a8:	b7c5                	j	688 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6aa:	8bce                	mv	s7,s3
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b3c9                	j	470 <vprintf+0x4a>
 6b0:	64a6                	ld	s1,72(sp)
 6b2:	79e2                	ld	s3,56(sp)
 6b4:	7a42                	ld	s4,48(sp)
 6b6:	7aa2                	ld	s5,40(sp)
 6b8:	7b02                	ld	s6,32(sp)
 6ba:	6be2                	ld	s7,24(sp)
 6bc:	6c42                	ld	s8,16(sp)
 6be:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6c0:	60e6                	ld	ra,88(sp)
 6c2:	6446                	ld	s0,80(sp)
 6c4:	6906                	ld	s2,64(sp)
 6c6:	6125                	addi	sp,sp,96
 6c8:	8082                	ret

00000000000006ca <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ca:	715d                	addi	sp,sp,-80
 6cc:	ec06                	sd	ra,24(sp)
 6ce:	e822                	sd	s0,16(sp)
 6d0:	1000                	addi	s0,sp,32
 6d2:	e010                	sd	a2,0(s0)
 6d4:	e414                	sd	a3,8(s0)
 6d6:	e818                	sd	a4,16(s0)
 6d8:	ec1c                	sd	a5,24(s0)
 6da:	03043023          	sd	a6,32(s0)
 6de:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6e2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6e6:	8622                	mv	a2,s0
 6e8:	d3fff0ef          	jal	426 <vprintf>
}
 6ec:	60e2                	ld	ra,24(sp)
 6ee:	6442                	ld	s0,16(sp)
 6f0:	6161                	addi	sp,sp,80
 6f2:	8082                	ret

00000000000006f4 <printf>:

void
printf(const char *fmt, ...)
{
 6f4:	711d                	addi	sp,sp,-96
 6f6:	ec06                	sd	ra,24(sp)
 6f8:	e822                	sd	s0,16(sp)
 6fa:	1000                	addi	s0,sp,32
 6fc:	e40c                	sd	a1,8(s0)
 6fe:	e810                	sd	a2,16(s0)
 700:	ec14                	sd	a3,24(s0)
 702:	f018                	sd	a4,32(s0)
 704:	f41c                	sd	a5,40(s0)
 706:	03043823          	sd	a6,48(s0)
 70a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 70e:	00840613          	addi	a2,s0,8
 712:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 716:	85aa                	mv	a1,a0
 718:	4505                	li	a0,1
 71a:	d0dff0ef          	jal	426 <vprintf>
}
 71e:	60e2                	ld	ra,24(sp)
 720:	6442                	ld	s0,16(sp)
 722:	6125                	addi	sp,sp,96
 724:	8082                	ret

0000000000000726 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 726:	1141                	addi	sp,sp,-16
 728:	e422                	sd	s0,8(sp)
 72a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 72c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 730:	00001797          	auipc	a5,0x1
 734:	8d07b783          	ld	a5,-1840(a5) # 1000 <freep>
 738:	a02d                	j	762 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 73a:	4618                	lw	a4,8(a2)
 73c:	9f2d                	addw	a4,a4,a1
 73e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 742:	6398                	ld	a4,0(a5)
 744:	6310                	ld	a2,0(a4)
 746:	a83d                	j	784 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 748:	ff852703          	lw	a4,-8(a0)
 74c:	9f31                	addw	a4,a4,a2
 74e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 750:	ff053683          	ld	a3,-16(a0)
 754:	a091                	j	798 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 756:	6398                	ld	a4,0(a5)
 758:	00e7e463          	bltu	a5,a4,760 <free+0x3a>
 75c:	00e6ea63          	bltu	a3,a4,770 <free+0x4a>
{
 760:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 762:	fed7fae3          	bgeu	a5,a3,756 <free+0x30>
 766:	6398                	ld	a4,0(a5)
 768:	00e6e463          	bltu	a3,a4,770 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 76c:	fee7eae3          	bltu	a5,a4,760 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 770:	ff852583          	lw	a1,-8(a0)
 774:	6390                	ld	a2,0(a5)
 776:	02059813          	slli	a6,a1,0x20
 77a:	01c85713          	srli	a4,a6,0x1c
 77e:	9736                	add	a4,a4,a3
 780:	fae60de3          	beq	a2,a4,73a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 784:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 788:	4790                	lw	a2,8(a5)
 78a:	02061593          	slli	a1,a2,0x20
 78e:	01c5d713          	srli	a4,a1,0x1c
 792:	973e                	add	a4,a4,a5
 794:	fae68ae3          	beq	a3,a4,748 <free+0x22>
    p->s.ptr = bp->s.ptr;
 798:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 79a:	00001717          	auipc	a4,0x1
 79e:	86f73323          	sd	a5,-1946(a4) # 1000 <freep>
}
 7a2:	6422                	ld	s0,8(sp)
 7a4:	0141                	addi	sp,sp,16
 7a6:	8082                	ret

00000000000007a8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7a8:	7139                	addi	sp,sp,-64
 7aa:	fc06                	sd	ra,56(sp)
 7ac:	f822                	sd	s0,48(sp)
 7ae:	f426                	sd	s1,40(sp)
 7b0:	ec4e                	sd	s3,24(sp)
 7b2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b4:	02051493          	slli	s1,a0,0x20
 7b8:	9081                	srli	s1,s1,0x20
 7ba:	04bd                	addi	s1,s1,15
 7bc:	8091                	srli	s1,s1,0x4
 7be:	0014899b          	addiw	s3,s1,1
 7c2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7c4:	00001517          	auipc	a0,0x1
 7c8:	83c53503          	ld	a0,-1988(a0) # 1000 <freep>
 7cc:	c915                	beqz	a0,800 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d0:	4798                	lw	a4,8(a5)
 7d2:	08977a63          	bgeu	a4,s1,866 <malloc+0xbe>
 7d6:	f04a                	sd	s2,32(sp)
 7d8:	e852                	sd	s4,16(sp)
 7da:	e456                	sd	s5,8(sp)
 7dc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7de:	8a4e                	mv	s4,s3
 7e0:	0009871b          	sext.w	a4,s3
 7e4:	6685                	lui	a3,0x1
 7e6:	00d77363          	bgeu	a4,a3,7ec <malloc+0x44>
 7ea:	6a05                	lui	s4,0x1
 7ec:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7f0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f4:	00001917          	auipc	s2,0x1
 7f8:	80c90913          	addi	s2,s2,-2036 # 1000 <freep>
  if(p == SBRK_ERROR)
 7fc:	5afd                	li	s5,-1
 7fe:	a081                	j	83e <malloc+0x96>
 800:	f04a                	sd	s2,32(sp)
 802:	e852                	sd	s4,16(sp)
 804:	e456                	sd	s5,8(sp)
 806:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 808:	00001797          	auipc	a5,0x1
 80c:	80878793          	addi	a5,a5,-2040 # 1010 <base>
 810:	00000717          	auipc	a4,0x0
 814:	7ef73823          	sd	a5,2032(a4) # 1000 <freep>
 818:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 81a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 81e:	b7c1                	j	7de <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 820:	6398                	ld	a4,0(a5)
 822:	e118                	sd	a4,0(a0)
 824:	a8a9                	j	87e <malloc+0xd6>
  hp->s.size = nu;
 826:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 82a:	0541                	addi	a0,a0,16
 82c:	efbff0ef          	jal	726 <free>
  return freep;
 830:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 834:	c12d                	beqz	a0,896 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 836:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 838:	4798                	lw	a4,8(a5)
 83a:	02977263          	bgeu	a4,s1,85e <malloc+0xb6>
    if(p == freep)
 83e:	00093703          	ld	a4,0(s2)
 842:	853e                	mv	a0,a5
 844:	fef719e3          	bne	a4,a5,836 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 848:	8552                	mv	a0,s4
 84a:	a1fff0ef          	jal	268 <sbrk>
  if(p == SBRK_ERROR)
 84e:	fd551ce3          	bne	a0,s5,826 <malloc+0x7e>
        return 0;
 852:	4501                	li	a0,0
 854:	7902                	ld	s2,32(sp)
 856:	6a42                	ld	s4,16(sp)
 858:	6aa2                	ld	s5,8(sp)
 85a:	6b02                	ld	s6,0(sp)
 85c:	a03d                	j	88a <malloc+0xe2>
 85e:	7902                	ld	s2,32(sp)
 860:	6a42                	ld	s4,16(sp)
 862:	6aa2                	ld	s5,8(sp)
 864:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 866:	fae48de3          	beq	s1,a4,820 <malloc+0x78>
        p->s.size -= nunits;
 86a:	4137073b          	subw	a4,a4,s3
 86e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 870:	02071693          	slli	a3,a4,0x20
 874:	01c6d713          	srli	a4,a3,0x1c
 878:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 87a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 87e:	00000717          	auipc	a4,0x0
 882:	78a73123          	sd	a0,1922(a4) # 1000 <freep>
      return (void*)(p + 1);
 886:	01078513          	addi	a0,a5,16
  }
}
 88a:	70e2                	ld	ra,56(sp)
 88c:	7442                	ld	s0,48(sp)
 88e:	74a2                	ld	s1,40(sp)
 890:	69e2                	ld	s3,24(sp)
 892:	6121                	addi	sp,sp,64
 894:	8082                	ret
 896:	7902                	ld	s2,32(sp)
 898:	6a42                	ld	s4,16(sp)
 89a:	6aa2                	ld	s5,8(sp)
 89c:	6b02                	ld	s6,0(sp)
 89e:	b7f5                	j	88a <malloc+0xe2>
