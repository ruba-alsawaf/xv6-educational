
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
  14:	2c6000ef          	jal	2da <exit>

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
 102:	1f0000ef          	jal	2f2 <read>
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
 14e:	1cc000ef          	jal	31a <open>
  if(fd < 0)
 152:	02054263          	bltz	a0,176 <stat+0x36>
 156:	e426                	sd	s1,8(sp)
 158:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 15a:	85ca                	mv	a1,s2
 15c:	1d6000ef          	jal	332 <fstat>
 160:	892a                	mv	s2,a0
  close(fd);
 162:	8526                	mv	a0,s1
 164:	19e000ef          	jal	302 <close>
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
 272:	0f0000ef          	jal	362 <sys_sbrk>
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
 288:	0da000ef          	jal	362 <sys_sbrk>
}
 28c:	60a2                	ld	ra,8(sp)
 28e:	6402                	ld	s0,0(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
 294:	1141                	addi	sp,sp,-16
 296:	e406                	sd	ra,8(sp)
 298:	e022                	sd	s0,0(sp)
 29a:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
 29c:	0025961b          	slliw	a2,a1,0x2
 2a0:	9e2d                	addw	a2,a2,a1
 2a2:	0036161b          	slliw	a2,a2,0x3
 2a6:	4581                	li	a1,0
 2a8:	de3ff0ef          	jal	8a <memset>
  return 0;
}
 2ac:	4501                	li	a0,0
 2ae:	60a2                	ld	ra,8(sp)
 2b0:	6402                	ld	s0,0(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret

00000000000002b6 <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e406                	sd	ra,8(sp)
 2ba:	e022                	sd	s0,0(sp)
 2bc:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
 2be:	07000613          	li	a2,112
 2c2:	4581                	li	a1,0
 2c4:	dc7ff0ef          	jal	8a <memset>
  return 0;
}
 2c8:	4501                	li	a0,0
 2ca:	60a2                	ld	ra,8(sp)
 2cc:	6402                	ld	s0,0(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret

00000000000002d2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2d2:	4885                	li	a7,1
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <exit>:
.global exit
exit:
 li a7, SYS_exit
 2da:	4889                	li	a7,2
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2e2:	488d                	li	a7,3
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ea:	4891                	li	a7,4
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <read>:
.global read
read:
 li a7, SYS_read
 2f2:	4895                	li	a7,5
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <write>:
.global write
write:
 li a7, SYS_write
 2fa:	48c1                	li	a7,16
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <close>:
.global close
close:
 li a7, SYS_close
 302:	48d5                	li	a7,21
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <kill>:
.global kill
kill:
 li a7, SYS_kill
 30a:	4899                	li	a7,6
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <exec>:
.global exec
exec:
 li a7, SYS_exec
 312:	489d                	li	a7,7
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <open>:
.global open
open:
 li a7, SYS_open
 31a:	48bd                	li	a7,15
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 322:	48c5                	li	a7,17
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 32a:	48c9                	li	a7,18
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 332:	48a1                	li	a7,8
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <link>:
.global link
link:
 li a7, SYS_link
 33a:	48cd                	li	a7,19
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 342:	48d1                	li	a7,20
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 34a:	48a5                	li	a7,9
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <dup>:
.global dup
dup:
 li a7, SYS_dup
 352:	48a9                	li	a7,10
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 35a:	48ad                	li	a7,11
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 362:	48b1                	li	a7,12
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <pause>:
.global pause
pause:
 li a7, SYS_pause
 36a:	48b5                	li	a7,13
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 372:	48b9                	li	a7,14
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <csread>:
.global csread
csread:
 li a7, SYS_csread
 37a:	48d9                	li	a7,22
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 382:	48dd                	li	a7,23
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 38a:	48e1                	li	a7,24
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <memread>:
.global memread
memread:
 li a7, SYS_memread
 392:	48e5                	li	a7,25
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 39a:	1101                	addi	sp,sp,-32
 39c:	ec06                	sd	ra,24(sp)
 39e:	e822                	sd	s0,16(sp)
 3a0:	1000                	addi	s0,sp,32
 3a2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a6:	4605                	li	a2,1
 3a8:	fef40593          	addi	a1,s0,-17
 3ac:	f4fff0ef          	jal	2fa <write>
}
 3b0:	60e2                	ld	ra,24(sp)
 3b2:	6442                	ld	s0,16(sp)
 3b4:	6105                	addi	sp,sp,32
 3b6:	8082                	ret

00000000000003b8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3b8:	715d                	addi	sp,sp,-80
 3ba:	e486                	sd	ra,72(sp)
 3bc:	e0a2                	sd	s0,64(sp)
 3be:	f84a                	sd	s2,48(sp)
 3c0:	0880                	addi	s0,sp,80
 3c2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3c4:	c299                	beqz	a3,3ca <printint+0x12>
 3c6:	0805c363          	bltz	a1,44c <printint+0x94>
  neg = 0;
 3ca:	4881                	li	a7,0
 3cc:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3d0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3d2:	00000517          	auipc	a0,0x0
 3d6:	50650513          	addi	a0,a0,1286 # 8d8 <digits>
 3da:	883e                	mv	a6,a5
 3dc:	2785                	addiw	a5,a5,1
 3de:	02c5f733          	remu	a4,a1,a2
 3e2:	972a                	add	a4,a4,a0
 3e4:	00074703          	lbu	a4,0(a4)
 3e8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3ec:	872e                	mv	a4,a1
 3ee:	02c5d5b3          	divu	a1,a1,a2
 3f2:	0685                	addi	a3,a3,1
 3f4:	fec773e3          	bgeu	a4,a2,3da <printint+0x22>
  if(neg)
 3f8:	00088b63          	beqz	a7,40e <printint+0x56>
    buf[i++] = '-';
 3fc:	fd078793          	addi	a5,a5,-48
 400:	97a2                	add	a5,a5,s0
 402:	02d00713          	li	a4,45
 406:	fee78423          	sb	a4,-24(a5)
 40a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 40e:	02f05a63          	blez	a5,442 <printint+0x8a>
 412:	fc26                	sd	s1,56(sp)
 414:	f44e                	sd	s3,40(sp)
 416:	fb840713          	addi	a4,s0,-72
 41a:	00f704b3          	add	s1,a4,a5
 41e:	fff70993          	addi	s3,a4,-1
 422:	99be                	add	s3,s3,a5
 424:	37fd                	addiw	a5,a5,-1
 426:	1782                	slli	a5,a5,0x20
 428:	9381                	srli	a5,a5,0x20
 42a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 42e:	fff4c583          	lbu	a1,-1(s1)
 432:	854a                	mv	a0,s2
 434:	f67ff0ef          	jal	39a <putc>
  while(--i >= 0)
 438:	14fd                	addi	s1,s1,-1
 43a:	ff349ae3          	bne	s1,s3,42e <printint+0x76>
 43e:	74e2                	ld	s1,56(sp)
 440:	79a2                	ld	s3,40(sp)
}
 442:	60a6                	ld	ra,72(sp)
 444:	6406                	ld	s0,64(sp)
 446:	7942                	ld	s2,48(sp)
 448:	6161                	addi	sp,sp,80
 44a:	8082                	ret
    x = -xx;
 44c:	40b005b3          	neg	a1,a1
    neg = 1;
 450:	4885                	li	a7,1
    x = -xx;
 452:	bfad                	j	3cc <printint+0x14>

0000000000000454 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 454:	711d                	addi	sp,sp,-96
 456:	ec86                	sd	ra,88(sp)
 458:	e8a2                	sd	s0,80(sp)
 45a:	e0ca                	sd	s2,64(sp)
 45c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 45e:	0005c903          	lbu	s2,0(a1)
 462:	28090663          	beqz	s2,6ee <vprintf+0x29a>
 466:	e4a6                	sd	s1,72(sp)
 468:	fc4e                	sd	s3,56(sp)
 46a:	f852                	sd	s4,48(sp)
 46c:	f456                	sd	s5,40(sp)
 46e:	f05a                	sd	s6,32(sp)
 470:	ec5e                	sd	s7,24(sp)
 472:	e862                	sd	s8,16(sp)
 474:	e466                	sd	s9,8(sp)
 476:	8b2a                	mv	s6,a0
 478:	8a2e                	mv	s4,a1
 47a:	8bb2                	mv	s7,a2
  state = 0;
 47c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 47e:	4481                	li	s1,0
 480:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 482:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 486:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 48a:	06c00c93          	li	s9,108
 48e:	a005                	j	4ae <vprintf+0x5a>
        putc(fd, c0);
 490:	85ca                	mv	a1,s2
 492:	855a                	mv	a0,s6
 494:	f07ff0ef          	jal	39a <putc>
 498:	a019                	j	49e <vprintf+0x4a>
    } else if(state == '%'){
 49a:	03598263          	beq	s3,s5,4be <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 49e:	2485                	addiw	s1,s1,1
 4a0:	8726                	mv	a4,s1
 4a2:	009a07b3          	add	a5,s4,s1
 4a6:	0007c903          	lbu	s2,0(a5)
 4aa:	22090a63          	beqz	s2,6de <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4ae:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4b2:	fe0994e3          	bnez	s3,49a <vprintf+0x46>
      if(c0 == '%'){
 4b6:	fd579de3          	bne	a5,s5,490 <vprintf+0x3c>
        state = '%';
 4ba:	89be                	mv	s3,a5
 4bc:	b7cd                	j	49e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4be:	00ea06b3          	add	a3,s4,a4
 4c2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4c6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4c8:	c681                	beqz	a3,4d0 <vprintf+0x7c>
 4ca:	9752                	add	a4,a4,s4
 4cc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4d0:	05878363          	beq	a5,s8,516 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4d4:	05978d63          	beq	a5,s9,52e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4d8:	07500713          	li	a4,117
 4dc:	0ee78763          	beq	a5,a4,5ca <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4e0:	07800713          	li	a4,120
 4e4:	12e78963          	beq	a5,a4,616 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4e8:	07000713          	li	a4,112
 4ec:	14e78e63          	beq	a5,a4,648 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4f0:	06300713          	li	a4,99
 4f4:	18e78e63          	beq	a5,a4,690 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4f8:	07300713          	li	a4,115
 4fc:	1ae78463          	beq	a5,a4,6a4 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 500:	02500713          	li	a4,37
 504:	04e79563          	bne	a5,a4,54e <vprintf+0xfa>
        putc(fd, '%');
 508:	02500593          	li	a1,37
 50c:	855a                	mv	a0,s6
 50e:	e8dff0ef          	jal	39a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 512:	4981                	li	s3,0
 514:	b769                	j	49e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 516:	008b8913          	addi	s2,s7,8
 51a:	4685                	li	a3,1
 51c:	4629                	li	a2,10
 51e:	000ba583          	lw	a1,0(s7)
 522:	855a                	mv	a0,s6
 524:	e95ff0ef          	jal	3b8 <printint>
 528:	8bca                	mv	s7,s2
      state = 0;
 52a:	4981                	li	s3,0
 52c:	bf8d                	j	49e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 52e:	06400793          	li	a5,100
 532:	02f68963          	beq	a3,a5,564 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 536:	06c00793          	li	a5,108
 53a:	04f68263          	beq	a3,a5,57e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 53e:	07500793          	li	a5,117
 542:	0af68063          	beq	a3,a5,5e2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 546:	07800793          	li	a5,120
 54a:	0ef68263          	beq	a3,a5,62e <vprintf+0x1da>
        putc(fd, '%');
 54e:	02500593          	li	a1,37
 552:	855a                	mv	a0,s6
 554:	e47ff0ef          	jal	39a <putc>
        putc(fd, c0);
 558:	85ca                	mv	a1,s2
 55a:	855a                	mv	a0,s6
 55c:	e3fff0ef          	jal	39a <putc>
      state = 0;
 560:	4981                	li	s3,0
 562:	bf35                	j	49e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 564:	008b8913          	addi	s2,s7,8
 568:	4685                	li	a3,1
 56a:	4629                	li	a2,10
 56c:	000bb583          	ld	a1,0(s7)
 570:	855a                	mv	a0,s6
 572:	e47ff0ef          	jal	3b8 <printint>
        i += 1;
 576:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 578:	8bca                	mv	s7,s2
      state = 0;
 57a:	4981                	li	s3,0
        i += 1;
 57c:	b70d                	j	49e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 57e:	06400793          	li	a5,100
 582:	02f60763          	beq	a2,a5,5b0 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 586:	07500793          	li	a5,117
 58a:	06f60963          	beq	a2,a5,5fc <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 58e:	07800793          	li	a5,120
 592:	faf61ee3          	bne	a2,a5,54e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 596:	008b8913          	addi	s2,s7,8
 59a:	4681                	li	a3,0
 59c:	4641                	li	a2,16
 59e:	000bb583          	ld	a1,0(s7)
 5a2:	855a                	mv	a0,s6
 5a4:	e15ff0ef          	jal	3b8 <printint>
        i += 2;
 5a8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5aa:	8bca                	mv	s7,s2
      state = 0;
 5ac:	4981                	li	s3,0
        i += 2;
 5ae:	bdc5                	j	49e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b0:	008b8913          	addi	s2,s7,8
 5b4:	4685                	li	a3,1
 5b6:	4629                	li	a2,10
 5b8:	000bb583          	ld	a1,0(s7)
 5bc:	855a                	mv	a0,s6
 5be:	dfbff0ef          	jal	3b8 <printint>
        i += 2;
 5c2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
        i += 2;
 5c8:	bdd9                	j	49e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5ca:	008b8913          	addi	s2,s7,8
 5ce:	4681                	li	a3,0
 5d0:	4629                	li	a2,10
 5d2:	000be583          	lwu	a1,0(s7)
 5d6:	855a                	mv	a0,s6
 5d8:	de1ff0ef          	jal	3b8 <printint>
 5dc:	8bca                	mv	s7,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bd7d                	j	49e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4629                	li	a2,10
 5ea:	000bb583          	ld	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	dc9ff0ef          	jal	3b8 <printint>
        i += 1;
 5f4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f6:	8bca                	mv	s7,s2
      state = 0;
 5f8:	4981                	li	s3,0
        i += 1;
 5fa:	b555                	j	49e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fc:	008b8913          	addi	s2,s7,8
 600:	4681                	li	a3,0
 602:	4629                	li	a2,10
 604:	000bb583          	ld	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	dafff0ef          	jal	3b8 <printint>
        i += 2;
 60e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
        i += 2;
 614:	b569                	j	49e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 616:	008b8913          	addi	s2,s7,8
 61a:	4681                	li	a3,0
 61c:	4641                	li	a2,16
 61e:	000be583          	lwu	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	d95ff0ef          	jal	3b8 <printint>
 628:	8bca                	mv	s7,s2
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bd8d                	j	49e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	008b8913          	addi	s2,s7,8
 632:	4681                	li	a3,0
 634:	4641                	li	a2,16
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	d7dff0ef          	jal	3b8 <printint>
        i += 1;
 640:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 1;
 646:	bda1                	j	49e <vprintf+0x4a>
 648:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 64a:	008b8d13          	addi	s10,s7,8
 64e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 652:	03000593          	li	a1,48
 656:	855a                	mv	a0,s6
 658:	d43ff0ef          	jal	39a <putc>
  putc(fd, 'x');
 65c:	07800593          	li	a1,120
 660:	855a                	mv	a0,s6
 662:	d39ff0ef          	jal	39a <putc>
 666:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 668:	00000b97          	auipc	s7,0x0
 66c:	270b8b93          	addi	s7,s7,624 # 8d8 <digits>
 670:	03c9d793          	srli	a5,s3,0x3c
 674:	97de                	add	a5,a5,s7
 676:	0007c583          	lbu	a1,0(a5)
 67a:	855a                	mv	a0,s6
 67c:	d1fff0ef          	jal	39a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 680:	0992                	slli	s3,s3,0x4
 682:	397d                	addiw	s2,s2,-1
 684:	fe0916e3          	bnez	s2,670 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 688:	8bea                	mv	s7,s10
      state = 0;
 68a:	4981                	li	s3,0
 68c:	6d02                	ld	s10,0(sp)
 68e:	bd01                	j	49e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 690:	008b8913          	addi	s2,s7,8
 694:	000bc583          	lbu	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	d01ff0ef          	jal	39a <putc>
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bbf5                	j	49e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6a4:	008b8993          	addi	s3,s7,8
 6a8:	000bb903          	ld	s2,0(s7)
 6ac:	00090f63          	beqz	s2,6ca <vprintf+0x276>
        for(; *s; s++)
 6b0:	00094583          	lbu	a1,0(s2)
 6b4:	c195                	beqz	a1,6d8 <vprintf+0x284>
          putc(fd, *s);
 6b6:	855a                	mv	a0,s6
 6b8:	ce3ff0ef          	jal	39a <putc>
        for(; *s; s++)
 6bc:	0905                	addi	s2,s2,1
 6be:	00094583          	lbu	a1,0(s2)
 6c2:	f9f5                	bnez	a1,6b6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6c4:	8bce                	mv	s7,s3
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	bbd9                	j	49e <vprintf+0x4a>
          s = "(null)";
 6ca:	00000917          	auipc	s2,0x0
 6ce:	20690913          	addi	s2,s2,518 # 8d0 <malloc+0xfa>
        for(; *s; s++)
 6d2:	02800593          	li	a1,40
 6d6:	b7c5                	j	6b6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6d8:	8bce                	mv	s7,s3
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	b3c9                	j	49e <vprintf+0x4a>
 6de:	64a6                	ld	s1,72(sp)
 6e0:	79e2                	ld	s3,56(sp)
 6e2:	7a42                	ld	s4,48(sp)
 6e4:	7aa2                	ld	s5,40(sp)
 6e6:	7b02                	ld	s6,32(sp)
 6e8:	6be2                	ld	s7,24(sp)
 6ea:	6c42                	ld	s8,16(sp)
 6ec:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6ee:	60e6                	ld	ra,88(sp)
 6f0:	6446                	ld	s0,80(sp)
 6f2:	6906                	ld	s2,64(sp)
 6f4:	6125                	addi	sp,sp,96
 6f6:	8082                	ret

00000000000006f8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6f8:	715d                	addi	sp,sp,-80
 6fa:	ec06                	sd	ra,24(sp)
 6fc:	e822                	sd	s0,16(sp)
 6fe:	1000                	addi	s0,sp,32
 700:	e010                	sd	a2,0(s0)
 702:	e414                	sd	a3,8(s0)
 704:	e818                	sd	a4,16(s0)
 706:	ec1c                	sd	a5,24(s0)
 708:	03043023          	sd	a6,32(s0)
 70c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 710:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 714:	8622                	mv	a2,s0
 716:	d3fff0ef          	jal	454 <vprintf>
}
 71a:	60e2                	ld	ra,24(sp)
 71c:	6442                	ld	s0,16(sp)
 71e:	6161                	addi	sp,sp,80
 720:	8082                	ret

0000000000000722 <printf>:

void
printf(const char *fmt, ...)
{
 722:	711d                	addi	sp,sp,-96
 724:	ec06                	sd	ra,24(sp)
 726:	e822                	sd	s0,16(sp)
 728:	1000                	addi	s0,sp,32
 72a:	e40c                	sd	a1,8(s0)
 72c:	e810                	sd	a2,16(s0)
 72e:	ec14                	sd	a3,24(s0)
 730:	f018                	sd	a4,32(s0)
 732:	f41c                	sd	a5,40(s0)
 734:	03043823          	sd	a6,48(s0)
 738:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 73c:	00840613          	addi	a2,s0,8
 740:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 744:	85aa                	mv	a1,a0
 746:	4505                	li	a0,1
 748:	d0dff0ef          	jal	454 <vprintf>
}
 74c:	60e2                	ld	ra,24(sp)
 74e:	6442                	ld	s0,16(sp)
 750:	6125                	addi	sp,sp,96
 752:	8082                	ret

0000000000000754 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 754:	1141                	addi	sp,sp,-16
 756:	e422                	sd	s0,8(sp)
 758:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 75a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75e:	00001797          	auipc	a5,0x1
 762:	8a27b783          	ld	a5,-1886(a5) # 1000 <freep>
 766:	a02d                	j	790 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 768:	4618                	lw	a4,8(a2)
 76a:	9f2d                	addw	a4,a4,a1
 76c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 770:	6398                	ld	a4,0(a5)
 772:	6310                	ld	a2,0(a4)
 774:	a83d                	j	7b2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 776:	ff852703          	lw	a4,-8(a0)
 77a:	9f31                	addw	a4,a4,a2
 77c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 77e:	ff053683          	ld	a3,-16(a0)
 782:	a091                	j	7c6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 784:	6398                	ld	a4,0(a5)
 786:	00e7e463          	bltu	a5,a4,78e <free+0x3a>
 78a:	00e6ea63          	bltu	a3,a4,79e <free+0x4a>
{
 78e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 790:	fed7fae3          	bgeu	a5,a3,784 <free+0x30>
 794:	6398                	ld	a4,0(a5)
 796:	00e6e463          	bltu	a3,a4,79e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79a:	fee7eae3          	bltu	a5,a4,78e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 79e:	ff852583          	lw	a1,-8(a0)
 7a2:	6390                	ld	a2,0(a5)
 7a4:	02059813          	slli	a6,a1,0x20
 7a8:	01c85713          	srli	a4,a6,0x1c
 7ac:	9736                	add	a4,a4,a3
 7ae:	fae60de3          	beq	a2,a4,768 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7b2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7b6:	4790                	lw	a2,8(a5)
 7b8:	02061593          	slli	a1,a2,0x20
 7bc:	01c5d713          	srli	a4,a1,0x1c
 7c0:	973e                	add	a4,a4,a5
 7c2:	fae68ae3          	beq	a3,a4,776 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7c6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7c8:	00001717          	auipc	a4,0x1
 7cc:	82f73c23          	sd	a5,-1992(a4) # 1000 <freep>
}
 7d0:	6422                	ld	s0,8(sp)
 7d2:	0141                	addi	sp,sp,16
 7d4:	8082                	ret

00000000000007d6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7d6:	7139                	addi	sp,sp,-64
 7d8:	fc06                	sd	ra,56(sp)
 7da:	f822                	sd	s0,48(sp)
 7dc:	f426                	sd	s1,40(sp)
 7de:	ec4e                	sd	s3,24(sp)
 7e0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e2:	02051493          	slli	s1,a0,0x20
 7e6:	9081                	srli	s1,s1,0x20
 7e8:	04bd                	addi	s1,s1,15
 7ea:	8091                	srli	s1,s1,0x4
 7ec:	0014899b          	addiw	s3,s1,1
 7f0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7f2:	00001517          	auipc	a0,0x1
 7f6:	80e53503          	ld	a0,-2034(a0) # 1000 <freep>
 7fa:	c915                	beqz	a0,82e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fe:	4798                	lw	a4,8(a5)
 800:	08977a63          	bgeu	a4,s1,894 <malloc+0xbe>
 804:	f04a                	sd	s2,32(sp)
 806:	e852                	sd	s4,16(sp)
 808:	e456                	sd	s5,8(sp)
 80a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 80c:	8a4e                	mv	s4,s3
 80e:	0009871b          	sext.w	a4,s3
 812:	6685                	lui	a3,0x1
 814:	00d77363          	bgeu	a4,a3,81a <malloc+0x44>
 818:	6a05                	lui	s4,0x1
 81a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 81e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 822:	00000917          	auipc	s2,0x0
 826:	7de90913          	addi	s2,s2,2014 # 1000 <freep>
  if(p == SBRK_ERROR)
 82a:	5afd                	li	s5,-1
 82c:	a081                	j	86c <malloc+0x96>
 82e:	f04a                	sd	s2,32(sp)
 830:	e852                	sd	s4,16(sp)
 832:	e456                	sd	s5,8(sp)
 834:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 836:	00000797          	auipc	a5,0x0
 83a:	7da78793          	addi	a5,a5,2010 # 1010 <base>
 83e:	00000717          	auipc	a4,0x0
 842:	7cf73123          	sd	a5,1986(a4) # 1000 <freep>
 846:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 848:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 84c:	b7c1                	j	80c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 84e:	6398                	ld	a4,0(a5)
 850:	e118                	sd	a4,0(a0)
 852:	a8a9                	j	8ac <malloc+0xd6>
  hp->s.size = nu;
 854:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 858:	0541                	addi	a0,a0,16
 85a:	efbff0ef          	jal	754 <free>
  return freep;
 85e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 862:	c12d                	beqz	a0,8c4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 864:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 866:	4798                	lw	a4,8(a5)
 868:	02977263          	bgeu	a4,s1,88c <malloc+0xb6>
    if(p == freep)
 86c:	00093703          	ld	a4,0(s2)
 870:	853e                	mv	a0,a5
 872:	fef719e3          	bne	a4,a5,864 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 876:	8552                	mv	a0,s4
 878:	9f1ff0ef          	jal	268 <sbrk>
  if(p == SBRK_ERROR)
 87c:	fd551ce3          	bne	a0,s5,854 <malloc+0x7e>
        return 0;
 880:	4501                	li	a0,0
 882:	7902                	ld	s2,32(sp)
 884:	6a42                	ld	s4,16(sp)
 886:	6aa2                	ld	s5,8(sp)
 888:	6b02                	ld	s6,0(sp)
 88a:	a03d                	j	8b8 <malloc+0xe2>
 88c:	7902                	ld	s2,32(sp)
 88e:	6a42                	ld	s4,16(sp)
 890:	6aa2                	ld	s5,8(sp)
 892:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 894:	fae48de3          	beq	s1,a4,84e <malloc+0x78>
        p->s.size -= nunits;
 898:	4137073b          	subw	a4,a4,s3
 89c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 89e:	02071693          	slli	a3,a4,0x20
 8a2:	01c6d713          	srli	a4,a3,0x1c
 8a6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ac:	00000717          	auipc	a4,0x0
 8b0:	74a73a23          	sd	a0,1876(a4) # 1000 <freep>
      return (void*)(p + 1);
 8b4:	01078513          	addi	a0,a5,16
  }
}
 8b8:	70e2                	ld	ra,56(sp)
 8ba:	7442                	ld	s0,48(sp)
 8bc:	74a2                	ld	s1,40(sp)
 8be:	69e2                	ld	s3,24(sp)
 8c0:	6121                	addi	sp,sp,64
 8c2:	8082                	ret
 8c4:	7902                	ld	s2,32(sp)
 8c6:	6a42                	ld	s4,16(sp)
 8c8:	6aa2                	ld	s5,8(sp)
 8ca:	6b02                	ld	s6,0(sp)
 8cc:	b7f5                	j	8b8 <malloc+0xe2>
