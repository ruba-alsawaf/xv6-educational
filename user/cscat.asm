
user/_cscat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(void){
   0:	9c010113          	addi	sp,sp,-1600
   4:	62113c23          	sd	ra,1592(sp)
   8:	62813823          	sd	s0,1584(sp)
   c:	62913423          	sd	s1,1576(sp)
  10:	63213023          	sd	s2,1568(sp)
  14:	61313c23          	sd	s3,1560(sp)
  18:	61413823          	sd	s4,1552(sp)
  1c:	61513423          	sd	s5,1544(sp)
  20:	61613023          	sd	s6,1536(sp)
  24:	64010413          	addi	s0,sp,1600
  struct cs_event ev[32];
  while(1){
    int n = csread(ev, 32);
  28:	9c040a93          	addi	s5,s0,-1600
  2c:	02000a13          	li	s4,32
    for(int i=0;i<n;i++){
      if(ev[i].type != CS_RUN_START) continue;
  30:	4985                	li	s3,1
      printf("seq=%ld tick=%d cpu=%d pid=%d name=%s state=%d\n",
  32:	00001b17          	auipc	s6,0x1
  36:	90eb0b13          	addi	s6,s6,-1778 # 940 <malloc+0xf6>
  3a:	a809                	j	4c <main+0x4c>
      if(ev[i].type != CS_RUN_START) continue;
  3c:	ff44a783          	lw	a5,-12(s1)
  40:	03378463          	beq	a5,s3,68 <main+0x68>
    for(int i=0;i<n;i++){
  44:	03048493          	addi	s1,s1,48
  48:	ff249ae3          	bne	s1,s2,3c <main+0x3c>
    int n = csread(ev, 32);
  4c:	85d2                	mv	a1,s4
  4e:	8556                	mv	a0,s5
  50:	38c000ef          	jal	3dc <csread>
    for(int i=0;i<n;i++){
  54:	fea05ce3          	blez	a0,4c <main+0x4c>
  58:	9dc40493          	addi	s1,s0,-1572
  5c:	00151913          	slli	s2,a0,0x1
  60:	992a                	add	s2,s2,a0
  62:	0912                	slli	s2,s2,0x4
  64:	9926                	add	s2,s2,s1
  66:	bfd9                	j	3c <main+0x3c>
      printf("seq=%ld tick=%d cpu=%d pid=%d name=%s state=%d\n",
  68:	ffc4a803          	lw	a6,-4(s1)
  6c:	87a6                	mv	a5,s1
  6e:	ff84a703          	lw	a4,-8(s1)
  72:	ff04a683          	lw	a3,-16(s1)
  76:	fec4a603          	lw	a2,-20(s1)
  7a:	fe44b583          	ld	a1,-28(s1)
  7e:	855a                	mv	a0,s6
  80:	712000ef          	jal	792 <printf>
  84:	b7c1                	j	44 <main+0x44>

0000000000000086 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  86:	1141                	addi	sp,sp,-16
  88:	e406                	sd	ra,8(sp)
  8a:	e022                	sd	s0,0(sp)
  8c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  8e:	f73ff0ef          	jal	0 <main>
  exit(r);
  92:	2aa000ef          	jal	33c <exit>

0000000000000096 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  96:	1141                	addi	sp,sp,-16
  98:	e406                	sd	ra,8(sp)
  9a:	e022                	sd	s0,0(sp)
  9c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9e:	87aa                	mv	a5,a0
  a0:	0585                	addi	a1,a1,1
  a2:	0785                	addi	a5,a5,1
  a4:	fff5c703          	lbu	a4,-1(a1)
  a8:	fee78fa3          	sb	a4,-1(a5)
  ac:	fb75                	bnez	a4,a0 <strcpy+0xa>
    ;
  return os;
}
  ae:	60a2                	ld	ra,8(sp)
  b0:	6402                	ld	s0,0(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e406                	sd	ra,8(sp)
  ba:	e022                	sd	s0,0(sp)
  bc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  be:	00054783          	lbu	a5,0(a0)
  c2:	cb91                	beqz	a5,d6 <strcmp+0x20>
  c4:	0005c703          	lbu	a4,0(a1)
  c8:	00f71763          	bne	a4,a5,d6 <strcmp+0x20>
    p++, q++;
  cc:	0505                	addi	a0,a0,1
  ce:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d0:	00054783          	lbu	a5,0(a0)
  d4:	fbe5                	bnez	a5,c4 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  d6:	0005c503          	lbu	a0,0(a1)
}
  da:	40a7853b          	subw	a0,a5,a0
  de:	60a2                	ld	ra,8(sp)
  e0:	6402                	ld	s0,0(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strlen>:

uint
strlen(const char *s)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e406                	sd	ra,8(sp)
  ea:	e022                	sd	s0,0(sp)
  ec:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cf91                	beqz	a5,10e <strlen+0x28>
  f4:	00150793          	addi	a5,a0,1
  f8:	86be                	mv	a3,a5
  fa:	0785                	addi	a5,a5,1
  fc:	fff7c703          	lbu	a4,-1(a5)
 100:	ff65                	bnez	a4,f8 <strlen+0x12>
 102:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 106:	60a2                	ld	ra,8(sp)
 108:	6402                	ld	s0,0(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret
  for(n = 0; s[n]; n++)
 10e:	4501                	li	a0,0
 110:	bfdd                	j	106 <strlen+0x20>

0000000000000112 <memset>:

void*
memset(void *dst, int c, uint n)
{
 112:	1141                	addi	sp,sp,-16
 114:	e406                	sd	ra,8(sp)
 116:	e022                	sd	s0,0(sp)
 118:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 11a:	ca19                	beqz	a2,130 <memset+0x1e>
 11c:	87aa                	mv	a5,a0
 11e:	1602                	slli	a2,a2,0x20
 120:	9201                	srli	a2,a2,0x20
 122:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 126:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 12a:	0785                	addi	a5,a5,1
 12c:	fee79de3          	bne	a5,a4,126 <memset+0x14>
  }
  return dst;
}
 130:	60a2                	ld	ra,8(sp)
 132:	6402                	ld	s0,0(sp)
 134:	0141                	addi	sp,sp,16
 136:	8082                	ret

0000000000000138 <strchr>:

char*
strchr(const char *s, char c)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e406                	sd	ra,8(sp)
 13c:	e022                	sd	s0,0(sp)
 13e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 140:	00054783          	lbu	a5,0(a0)
 144:	cf81                	beqz	a5,15c <strchr+0x24>
    if(*s == c)
 146:	00f58763          	beq	a1,a5,154 <strchr+0x1c>
  for(; *s; s++)
 14a:	0505                	addi	a0,a0,1
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbfd                	bnez	a5,146 <strchr+0xe>
      return (char*)s;
  return 0;
 152:	4501                	li	a0,0
}
 154:	60a2                	ld	ra,8(sp)
 156:	6402                	ld	s0,0(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfdd                	j	154 <strchr+0x1c>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	711d                	addi	sp,sp,-96
 162:	ec86                	sd	ra,88(sp)
 164:	e8a2                	sd	s0,80(sp)
 166:	e4a6                	sd	s1,72(sp)
 168:	e0ca                	sd	s2,64(sp)
 16a:	fc4e                	sd	s3,56(sp)
 16c:	f852                	sd	s4,48(sp)
 16e:	f456                	sd	s5,40(sp)
 170:	f05a                	sd	s6,32(sp)
 172:	ec5e                	sd	s7,24(sp)
 174:	e862                	sd	s8,16(sp)
 176:	1080                	addi	s0,sp,96
 178:	8baa                	mv	s7,a0
 17a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17c:	892a                	mv	s2,a0
 17e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 180:	faf40b13          	addi	s6,s0,-81
 184:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 186:	8c26                	mv	s8,s1
 188:	0014899b          	addiw	s3,s1,1
 18c:	84ce                	mv	s1,s3
 18e:	0349d463          	bge	s3,s4,1b6 <gets+0x56>
    cc = read(0, &c, 1);
 192:	8656                	mv	a2,s5
 194:	85da                	mv	a1,s6
 196:	4501                	li	a0,0
 198:	1bc000ef          	jal	354 <read>
    if(cc < 1)
 19c:	00a05d63          	blez	a0,1b6 <gets+0x56>
      break;
    buf[i++] = c;
 1a0:	faf44783          	lbu	a5,-81(s0)
 1a4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a8:	0905                	addi	s2,s2,1
 1aa:	ff678713          	addi	a4,a5,-10
 1ae:	c319                	beqz	a4,1b4 <gets+0x54>
 1b0:	17cd                	addi	a5,a5,-13
 1b2:	fbf1                	bnez	a5,186 <gets+0x26>
    buf[i++] = c;
 1b4:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1b6:	9c5e                	add	s8,s8,s7
 1b8:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1bc:	855e                	mv	a0,s7
 1be:	60e6                	ld	ra,88(sp)
 1c0:	6446                	ld	s0,80(sp)
 1c2:	64a6                	ld	s1,72(sp)
 1c4:	6906                	ld	s2,64(sp)
 1c6:	79e2                	ld	s3,56(sp)
 1c8:	7a42                	ld	s4,48(sp)
 1ca:	7aa2                	ld	s5,40(sp)
 1cc:	7b02                	ld	s6,32(sp)
 1ce:	6be2                	ld	s7,24(sp)
 1d0:	6c42                	ld	s8,16(sp)
 1d2:	6125                	addi	sp,sp,96
 1d4:	8082                	ret

00000000000001d6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d6:	1101                	addi	sp,sp,-32
 1d8:	ec06                	sd	ra,24(sp)
 1da:	e822                	sd	s0,16(sp)
 1dc:	e04a                	sd	s2,0(sp)
 1de:	1000                	addi	s0,sp,32
 1e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e2:	4581                	li	a1,0
 1e4:	198000ef          	jal	37c <open>
  if(fd < 0)
 1e8:	02054263          	bltz	a0,20c <stat+0x36>
 1ec:	e426                	sd	s1,8(sp)
 1ee:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f0:	85ca                	mv	a1,s2
 1f2:	1a2000ef          	jal	394 <fstat>
 1f6:	892a                	mv	s2,a0
  close(fd);
 1f8:	8526                	mv	a0,s1
 1fa:	16a000ef          	jal	364 <close>
  return r;
 1fe:	64a2                	ld	s1,8(sp)
}
 200:	854a                	mv	a0,s2
 202:	60e2                	ld	ra,24(sp)
 204:	6442                	ld	s0,16(sp)
 206:	6902                	ld	s2,0(sp)
 208:	6105                	addi	sp,sp,32
 20a:	8082                	ret
    return -1;
 20c:	57fd                	li	a5,-1
 20e:	893e                	mv	s2,a5
 210:	bfc5                	j	200 <stat+0x2a>

0000000000000212 <atoi>:

int
atoi(const char *s)
{
 212:	1141                	addi	sp,sp,-16
 214:	e406                	sd	ra,8(sp)
 216:	e022                	sd	s0,0(sp)
 218:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21a:	00054683          	lbu	a3,0(a0)
 21e:	fd06879b          	addiw	a5,a3,-48
 222:	0ff7f793          	zext.b	a5,a5
 226:	4625                	li	a2,9
 228:	02f66963          	bltu	a2,a5,25a <atoi+0x48>
 22c:	872a                	mv	a4,a0
  n = 0;
 22e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 230:	0705                	addi	a4,a4,1
 232:	0025179b          	slliw	a5,a0,0x2
 236:	9fa9                	addw	a5,a5,a0
 238:	0017979b          	slliw	a5,a5,0x1
 23c:	9fb5                	addw	a5,a5,a3
 23e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 242:	00074683          	lbu	a3,0(a4)
 246:	fd06879b          	addiw	a5,a3,-48
 24a:	0ff7f793          	zext.b	a5,a5
 24e:	fef671e3          	bgeu	a2,a5,230 <atoi+0x1e>
  return n;
}
 252:	60a2                	ld	ra,8(sp)
 254:	6402                	ld	s0,0(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret
  n = 0;
 25a:	4501                	li	a0,0
 25c:	bfdd                	j	252 <atoi+0x40>

000000000000025e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e406                	sd	ra,8(sp)
 262:	e022                	sd	s0,0(sp)
 264:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 266:	02b57563          	bgeu	a0,a1,290 <memmove+0x32>
    while(n-- > 0)
 26a:	00c05f63          	blez	a2,288 <memmove+0x2a>
 26e:	1602                	slli	a2,a2,0x20
 270:	9201                	srli	a2,a2,0x20
 272:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 276:	872a                	mv	a4,a0
      *dst++ = *src++;
 278:	0585                	addi	a1,a1,1
 27a:	0705                	addi	a4,a4,1
 27c:	fff5c683          	lbu	a3,-1(a1)
 280:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 284:	fee79ae3          	bne	a5,a4,278 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 288:	60a2                	ld	ra,8(sp)
 28a:	6402                	ld	s0,0(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
    while(n-- > 0)
 290:	fec05ce3          	blez	a2,288 <memmove+0x2a>
    dst += n;
 294:	00c50733          	add	a4,a0,a2
    src += n;
 298:	95b2                	add	a1,a1,a2
 29a:	fff6079b          	addiw	a5,a2,-1
 29e:	1782                	slli	a5,a5,0x20
 2a0:	9381                	srli	a5,a5,0x20
 2a2:	fff7c793          	not	a5,a5
 2a6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a8:	15fd                	addi	a1,a1,-1
 2aa:	177d                	addi	a4,a4,-1
 2ac:	0005c683          	lbu	a3,0(a1)
 2b0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b4:	fef71ae3          	bne	a4,a5,2a8 <memmove+0x4a>
 2b8:	bfc1                	j	288 <memmove+0x2a>

00000000000002ba <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e406                	sd	ra,8(sp)
 2be:	e022                	sd	s0,0(sp)
 2c0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c2:	c61d                	beqz	a2,2f0 <memcmp+0x36>
 2c4:	1602                	slli	a2,a2,0x20
 2c6:	9201                	srli	a2,a2,0x20
 2c8:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2cc:	00054783          	lbu	a5,0(a0)
 2d0:	0005c703          	lbu	a4,0(a1)
 2d4:	00e79863          	bne	a5,a4,2e4 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2d8:	0505                	addi	a0,a0,1
    p2++;
 2da:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2dc:	fed518e3          	bne	a0,a3,2cc <memcmp+0x12>
  }
  return 0;
 2e0:	4501                	li	a0,0
 2e2:	a019                	j	2e8 <memcmp+0x2e>
      return *p1 - *p2;
 2e4:	40e7853b          	subw	a0,a5,a4
}
 2e8:	60a2                	ld	ra,8(sp)
 2ea:	6402                	ld	s0,0(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  return 0;
 2f0:	4501                	li	a0,0
 2f2:	bfdd                	j	2e8 <memcmp+0x2e>

00000000000002f4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e406                	sd	ra,8(sp)
 2f8:	e022                	sd	s0,0(sp)
 2fa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fc:	f63ff0ef          	jal	25e <memmove>
}
 300:	60a2                	ld	ra,8(sp)
 302:	6402                	ld	s0,0(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret

0000000000000308 <sbrk>:

char *
sbrk(int n) {
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 310:	4585                	li	a1,1
 312:	0b2000ef          	jal	3c4 <sys_sbrk>
}
 316:	60a2                	ld	ra,8(sp)
 318:	6402                	ld	s0,0(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret

000000000000031e <sbrklazy>:

char *
sbrklazy(int n) {
 31e:	1141                	addi	sp,sp,-16
 320:	e406                	sd	ra,8(sp)
 322:	e022                	sd	s0,0(sp)
 324:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 326:	4589                	li	a1,2
 328:	09c000ef          	jal	3c4 <sys_sbrk>
}
 32c:	60a2                	ld	ra,8(sp)
 32e:	6402                	ld	s0,0(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret

0000000000000334 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 334:	4885                	li	a7,1
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <exit>:
.global exit
exit:
 li a7, SYS_exit
 33c:	4889                	li	a7,2
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <wait>:
.global wait
wait:
 li a7, SYS_wait
 344:	488d                	li	a7,3
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34c:	4891                	li	a7,4
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <read>:
.global read
read:
 li a7, SYS_read
 354:	4895                	li	a7,5
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <write>:
.global write
write:
 li a7, SYS_write
 35c:	48c1                	li	a7,16
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <close>:
.global close
close:
 li a7, SYS_close
 364:	48d5                	li	a7,21
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <kill>:
.global kill
kill:
 li a7, SYS_kill
 36c:	4899                	li	a7,6
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <exec>:
.global exec
exec:
 li a7, SYS_exec
 374:	489d                	li	a7,7
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <open>:
.global open
open:
 li a7, SYS_open
 37c:	48bd                	li	a7,15
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 384:	48c5                	li	a7,17
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38c:	48c9                	li	a7,18
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 394:	48a1                	li	a7,8
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <link>:
.global link
link:
 li a7, SYS_link
 39c:	48cd                	li	a7,19
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a4:	48d1                	li	a7,20
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ac:	48a5                	li	a7,9
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b4:	48a9                	li	a7,10
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3bc:	48ad                	li	a7,11
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3c4:	48b1                	li	a7,12
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <pause>:
.global pause
pause:
 li a7, SYS_pause
 3cc:	48b5                	li	a7,13
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d4:	48b9                	li	a7,14
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <csread>:
.global csread
csread:
 li a7, SYS_csread
 3dc:	48d9                	li	a7,22
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 3e4:	48dd                	li	a7,23
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ec:	1101                	addi	sp,sp,-32
 3ee:	ec06                	sd	ra,24(sp)
 3f0:	e822                	sd	s0,16(sp)
 3f2:	1000                	addi	s0,sp,32
 3f4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f8:	4605                	li	a2,1
 3fa:	fef40593          	addi	a1,s0,-17
 3fe:	f5fff0ef          	jal	35c <write>
}
 402:	60e2                	ld	ra,24(sp)
 404:	6442                	ld	s0,16(sp)
 406:	6105                	addi	sp,sp,32
 408:	8082                	ret

000000000000040a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 40a:	715d                	addi	sp,sp,-80
 40c:	e486                	sd	ra,72(sp)
 40e:	e0a2                	sd	s0,64(sp)
 410:	f84a                	sd	s2,48(sp)
 412:	f44e                	sd	s3,40(sp)
 414:	0880                	addi	s0,sp,80
 416:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 418:	c6d1                	beqz	a3,4a4 <printint+0x9a>
 41a:	0805d563          	bgez	a1,4a4 <printint+0x9a>
    neg = 1;
    x = -xx;
 41e:	40b005b3          	neg	a1,a1
    neg = 1;
 422:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 424:	fb840993          	addi	s3,s0,-72
  neg = 0;
 428:	86ce                	mv	a3,s3
  i = 0;
 42a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 42c:	00000817          	auipc	a6,0x0
 430:	54c80813          	addi	a6,a6,1356 # 978 <digits>
 434:	88ba                	mv	a7,a4
 436:	0017051b          	addiw	a0,a4,1
 43a:	872a                	mv	a4,a0
 43c:	02c5f7b3          	remu	a5,a1,a2
 440:	97c2                	add	a5,a5,a6
 442:	0007c783          	lbu	a5,0(a5)
 446:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 44a:	87ae                	mv	a5,a1
 44c:	02c5d5b3          	divu	a1,a1,a2
 450:	0685                	addi	a3,a3,1
 452:	fec7f1e3          	bgeu	a5,a2,434 <printint+0x2a>
  if(neg)
 456:	00030c63          	beqz	t1,46e <printint+0x64>
    buf[i++] = '-';
 45a:	fd050793          	addi	a5,a0,-48
 45e:	00878533          	add	a0,a5,s0
 462:	02d00793          	li	a5,45
 466:	fef50423          	sb	a5,-24(a0)
 46a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 46e:	02e05563          	blez	a4,498 <printint+0x8e>
 472:	fc26                	sd	s1,56(sp)
 474:	377d                	addiw	a4,a4,-1
 476:	00e984b3          	add	s1,s3,a4
 47a:	19fd                	addi	s3,s3,-1
 47c:	99ba                	add	s3,s3,a4
 47e:	1702                	slli	a4,a4,0x20
 480:	9301                	srli	a4,a4,0x20
 482:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 486:	0004c583          	lbu	a1,0(s1)
 48a:	854a                	mv	a0,s2
 48c:	f61ff0ef          	jal	3ec <putc>
  while(--i >= 0)
 490:	14fd                	addi	s1,s1,-1
 492:	ff349ae3          	bne	s1,s3,486 <printint+0x7c>
 496:	74e2                	ld	s1,56(sp)
}
 498:	60a6                	ld	ra,72(sp)
 49a:	6406                	ld	s0,64(sp)
 49c:	7942                	ld	s2,48(sp)
 49e:	79a2                	ld	s3,40(sp)
 4a0:	6161                	addi	sp,sp,80
 4a2:	8082                	ret
  neg = 0;
 4a4:	4301                	li	t1,0
 4a6:	bfbd                	j	424 <printint+0x1a>

00000000000004a8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a8:	711d                	addi	sp,sp,-96
 4aa:	ec86                	sd	ra,88(sp)
 4ac:	e8a2                	sd	s0,80(sp)
 4ae:	e4a6                	sd	s1,72(sp)
 4b0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b2:	0005c483          	lbu	s1,0(a1)
 4b6:	22048363          	beqz	s1,6dc <vprintf+0x234>
 4ba:	e0ca                	sd	s2,64(sp)
 4bc:	fc4e                	sd	s3,56(sp)
 4be:	f852                	sd	s4,48(sp)
 4c0:	f456                	sd	s5,40(sp)
 4c2:	f05a                	sd	s6,32(sp)
 4c4:	ec5e                	sd	s7,24(sp)
 4c6:	e862                	sd	s8,16(sp)
 4c8:	8b2a                	mv	s6,a0
 4ca:	8a2e                	mv	s4,a1
 4cc:	8bb2                	mv	s7,a2
  state = 0;
 4ce:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4d0:	4901                	li	s2,0
 4d2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4d4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4d8:	06400c13          	li	s8,100
 4dc:	a00d                	j	4fe <vprintf+0x56>
        putc(fd, c0);
 4de:	85a6                	mv	a1,s1
 4e0:	855a                	mv	a0,s6
 4e2:	f0bff0ef          	jal	3ec <putc>
 4e6:	a019                	j	4ec <vprintf+0x44>
    } else if(state == '%'){
 4e8:	03598363          	beq	s3,s5,50e <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4ec:	0019079b          	addiw	a5,s2,1
 4f0:	893e                	mv	s2,a5
 4f2:	873e                	mv	a4,a5
 4f4:	97d2                	add	a5,a5,s4
 4f6:	0007c483          	lbu	s1,0(a5)
 4fa:	1c048a63          	beqz	s1,6ce <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4fe:	0004879b          	sext.w	a5,s1
    if(state == 0){
 502:	fe0993e3          	bnez	s3,4e8 <vprintf+0x40>
      if(c0 == '%'){
 506:	fd579ce3          	bne	a5,s5,4de <vprintf+0x36>
        state = '%';
 50a:	89be                	mv	s3,a5
 50c:	b7c5                	j	4ec <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 50e:	00ea06b3          	add	a3,s4,a4
 512:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 516:	1c060863          	beqz	a2,6e6 <vprintf+0x23e>
      if(c0 == 'd'){
 51a:	03878763          	beq	a5,s8,548 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 51e:	f9478693          	addi	a3,a5,-108
 522:	0016b693          	seqz	a3,a3
 526:	f9c60593          	addi	a1,a2,-100
 52a:	e99d                	bnez	a1,560 <vprintf+0xb8>
 52c:	ca95                	beqz	a3,560 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 52e:	008b8493          	addi	s1,s7,8
 532:	4685                	li	a3,1
 534:	4629                	li	a2,10
 536:	000bb583          	ld	a1,0(s7)
 53a:	855a                	mv	a0,s6
 53c:	ecfff0ef          	jal	40a <printint>
        i += 1;
 540:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 542:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 544:	4981                	li	s3,0
 546:	b75d                	j	4ec <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 548:	008b8493          	addi	s1,s7,8
 54c:	4685                	li	a3,1
 54e:	4629                	li	a2,10
 550:	000ba583          	lw	a1,0(s7)
 554:	855a                	mv	a0,s6
 556:	eb5ff0ef          	jal	40a <printint>
 55a:	8ba6                	mv	s7,s1
      state = 0;
 55c:	4981                	li	s3,0
 55e:	b779                	j	4ec <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 560:	9752                	add	a4,a4,s4
 562:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 566:	f9460713          	addi	a4,a2,-108
 56a:	00173713          	seqz	a4,a4
 56e:	8f75                	and	a4,a4,a3
 570:	f9c58513          	addi	a0,a1,-100
 574:	18051363          	bnez	a0,6fa <vprintf+0x252>
 578:	18070163          	beqz	a4,6fa <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 57c:	008b8493          	addi	s1,s7,8
 580:	4685                	li	a3,1
 582:	4629                	li	a2,10
 584:	000bb583          	ld	a1,0(s7)
 588:	855a                	mv	a0,s6
 58a:	e81ff0ef          	jal	40a <printint>
        i += 2;
 58e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 590:	8ba6                	mv	s7,s1
      state = 0;
 592:	4981                	li	s3,0
        i += 2;
 594:	bfa1                	j	4ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 596:	008b8493          	addi	s1,s7,8
 59a:	4681                	li	a3,0
 59c:	4629                	li	a2,10
 59e:	000be583          	lwu	a1,0(s7)
 5a2:	855a                	mv	a0,s6
 5a4:	e67ff0ef          	jal	40a <printint>
 5a8:	8ba6                	mv	s7,s1
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	b781                	j	4ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ae:	008b8493          	addi	s1,s7,8
 5b2:	4681                	li	a3,0
 5b4:	4629                	li	a2,10
 5b6:	000bb583          	ld	a1,0(s7)
 5ba:	855a                	mv	a0,s6
 5bc:	e4fff0ef          	jal	40a <printint>
        i += 1;
 5c0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c2:	8ba6                	mv	s7,s1
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b71d                	j	4ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c8:	008b8493          	addi	s1,s7,8
 5cc:	4681                	li	a3,0
 5ce:	4629                	li	a2,10
 5d0:	000bb583          	ld	a1,0(s7)
 5d4:	855a                	mv	a0,s6
 5d6:	e35ff0ef          	jal	40a <printint>
        i += 2;
 5da:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5dc:	8ba6                	mv	s7,s1
      state = 0;
 5de:	4981                	li	s3,0
        i += 2;
 5e0:	b731                	j	4ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5e2:	008b8493          	addi	s1,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4641                	li	a2,16
 5ea:	000be583          	lwu	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	e1bff0ef          	jal	40a <printint>
 5f4:	8ba6                	mv	s7,s1
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	bdd5                	j	4ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fa:	008b8493          	addi	s1,s7,8
 5fe:	4681                	li	a3,0
 600:	4641                	li	a2,16
 602:	000bb583          	ld	a1,0(s7)
 606:	855a                	mv	a0,s6
 608:	e03ff0ef          	jal	40a <printint>
        i += 1;
 60c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 60e:	8ba6                	mv	s7,s1
      state = 0;
 610:	4981                	li	s3,0
 612:	bde9                	j	4ec <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 614:	008b8493          	addi	s1,s7,8
 618:	4681                	li	a3,0
 61a:	4641                	li	a2,16
 61c:	000bb583          	ld	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	de9ff0ef          	jal	40a <printint>
        i += 2;
 626:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 628:	8ba6                	mv	s7,s1
      state = 0;
 62a:	4981                	li	s3,0
        i += 2;
 62c:	b5c1                	j	4ec <vprintf+0x44>
 62e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 630:	008b8793          	addi	a5,s7,8
 634:	8cbe                	mv	s9,a5
 636:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 63a:	03000593          	li	a1,48
 63e:	855a                	mv	a0,s6
 640:	dadff0ef          	jal	3ec <putc>
  putc(fd, 'x');
 644:	07800593          	li	a1,120
 648:	855a                	mv	a0,s6
 64a:	da3ff0ef          	jal	3ec <putc>
 64e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 650:	00000b97          	auipc	s7,0x0
 654:	328b8b93          	addi	s7,s7,808 # 978 <digits>
 658:	03c9d793          	srli	a5,s3,0x3c
 65c:	97de                	add	a5,a5,s7
 65e:	0007c583          	lbu	a1,0(a5)
 662:	855a                	mv	a0,s6
 664:	d89ff0ef          	jal	3ec <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 668:	0992                	slli	s3,s3,0x4
 66a:	34fd                	addiw	s1,s1,-1
 66c:	f4f5                	bnez	s1,658 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 66e:	8be6                	mv	s7,s9
      state = 0;
 670:	4981                	li	s3,0
 672:	6ca2                	ld	s9,8(sp)
 674:	bda5                	j	4ec <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 676:	008b8493          	addi	s1,s7,8
 67a:	000bc583          	lbu	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	d6dff0ef          	jal	3ec <putc>
 684:	8ba6                	mv	s7,s1
      state = 0;
 686:	4981                	li	s3,0
 688:	b595                	j	4ec <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 68a:	008b8993          	addi	s3,s7,8
 68e:	000bb483          	ld	s1,0(s7)
 692:	cc91                	beqz	s1,6ae <vprintf+0x206>
        for(; *s; s++)
 694:	0004c583          	lbu	a1,0(s1)
 698:	c985                	beqz	a1,6c8 <vprintf+0x220>
          putc(fd, *s);
 69a:	855a                	mv	a0,s6
 69c:	d51ff0ef          	jal	3ec <putc>
        for(; *s; s++)
 6a0:	0485                	addi	s1,s1,1
 6a2:	0004c583          	lbu	a1,0(s1)
 6a6:	f9f5                	bnez	a1,69a <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6a8:	8bce                	mv	s7,s3
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b581                	j	4ec <vprintf+0x44>
          s = "(null)";
 6ae:	00000497          	auipc	s1,0x0
 6b2:	2c248493          	addi	s1,s1,706 # 970 <malloc+0x126>
        for(; *s; s++)
 6b6:	02800593          	li	a1,40
 6ba:	b7c5                	j	69a <vprintf+0x1f2>
        putc(fd, '%');
 6bc:	85be                	mv	a1,a5
 6be:	855a                	mv	a0,s6
 6c0:	d2dff0ef          	jal	3ec <putc>
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b51d                	j	4ec <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6c8:	8bce                	mv	s7,s3
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b505                	j	4ec <vprintf+0x44>
 6ce:	6906                	ld	s2,64(sp)
 6d0:	79e2                	ld	s3,56(sp)
 6d2:	7a42                	ld	s4,48(sp)
 6d4:	7aa2                	ld	s5,40(sp)
 6d6:	7b02                	ld	s6,32(sp)
 6d8:	6be2                	ld	s7,24(sp)
 6da:	6c42                	ld	s8,16(sp)
    }
  }
}
 6dc:	60e6                	ld	ra,88(sp)
 6de:	6446                	ld	s0,80(sp)
 6e0:	64a6                	ld	s1,72(sp)
 6e2:	6125                	addi	sp,sp,96
 6e4:	8082                	ret
      if(c0 == 'd'){
 6e6:	06400713          	li	a4,100
 6ea:	e4e78fe3          	beq	a5,a4,548 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6ee:	f9478693          	addi	a3,a5,-108
 6f2:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6f6:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6f8:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6fa:	07500513          	li	a0,117
 6fe:	e8a78ce3          	beq	a5,a0,596 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 702:	f8b60513          	addi	a0,a2,-117
 706:	e119                	bnez	a0,70c <vprintf+0x264>
 708:	ea0693e3          	bnez	a3,5ae <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 70c:	f8b58513          	addi	a0,a1,-117
 710:	e119                	bnez	a0,716 <vprintf+0x26e>
 712:	ea071be3          	bnez	a4,5c8 <vprintf+0x120>
      } else if(c0 == 'x'){
 716:	07800513          	li	a0,120
 71a:	eca784e3          	beq	a5,a0,5e2 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 71e:	f8860613          	addi	a2,a2,-120
 722:	e219                	bnez	a2,728 <vprintf+0x280>
 724:	ec069be3          	bnez	a3,5fa <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 728:	f8858593          	addi	a1,a1,-120
 72c:	e199                	bnez	a1,732 <vprintf+0x28a>
 72e:	ee0713e3          	bnez	a4,614 <vprintf+0x16c>
      } else if(c0 == 'p'){
 732:	07000713          	li	a4,112
 736:	eee78ce3          	beq	a5,a4,62e <vprintf+0x186>
      } else if(c0 == 'c'){
 73a:	06300713          	li	a4,99
 73e:	f2e78ce3          	beq	a5,a4,676 <vprintf+0x1ce>
      } else if(c0 == 's'){
 742:	07300713          	li	a4,115
 746:	f4e782e3          	beq	a5,a4,68a <vprintf+0x1e2>
      } else if(c0 == '%'){
 74a:	02500713          	li	a4,37
 74e:	f6e787e3          	beq	a5,a4,6bc <vprintf+0x214>
        putc(fd, '%');
 752:	02500593          	li	a1,37
 756:	855a                	mv	a0,s6
 758:	c95ff0ef          	jal	3ec <putc>
        putc(fd, c0);
 75c:	85a6                	mv	a1,s1
 75e:	855a                	mv	a0,s6
 760:	c8dff0ef          	jal	3ec <putc>
      state = 0;
 764:	4981                	li	s3,0
 766:	b359                	j	4ec <vprintf+0x44>

0000000000000768 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 768:	715d                	addi	sp,sp,-80
 76a:	ec06                	sd	ra,24(sp)
 76c:	e822                	sd	s0,16(sp)
 76e:	1000                	addi	s0,sp,32
 770:	e010                	sd	a2,0(s0)
 772:	e414                	sd	a3,8(s0)
 774:	e818                	sd	a4,16(s0)
 776:	ec1c                	sd	a5,24(s0)
 778:	03043023          	sd	a6,32(s0)
 77c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 780:	8622                	mv	a2,s0
 782:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 786:	d23ff0ef          	jal	4a8 <vprintf>
}
 78a:	60e2                	ld	ra,24(sp)
 78c:	6442                	ld	s0,16(sp)
 78e:	6161                	addi	sp,sp,80
 790:	8082                	ret

0000000000000792 <printf>:

void
printf(const char *fmt, ...)
{
 792:	711d                	addi	sp,sp,-96
 794:	ec06                	sd	ra,24(sp)
 796:	e822                	sd	s0,16(sp)
 798:	1000                	addi	s0,sp,32
 79a:	e40c                	sd	a1,8(s0)
 79c:	e810                	sd	a2,16(s0)
 79e:	ec14                	sd	a3,24(s0)
 7a0:	f018                	sd	a4,32(s0)
 7a2:	f41c                	sd	a5,40(s0)
 7a4:	03043823          	sd	a6,48(s0)
 7a8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ac:	00840613          	addi	a2,s0,8
 7b0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b4:	85aa                	mv	a1,a0
 7b6:	4505                	li	a0,1
 7b8:	cf1ff0ef          	jal	4a8 <vprintf>
}
 7bc:	60e2                	ld	ra,24(sp)
 7be:	6442                	ld	s0,16(sp)
 7c0:	6125                	addi	sp,sp,96
 7c2:	8082                	ret

00000000000007c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c4:	1141                	addi	sp,sp,-16
 7c6:	e406                	sd	ra,8(sp)
 7c8:	e022                	sd	s0,0(sp)
 7ca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7cc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d0:	00001797          	auipc	a5,0x1
 7d4:	8307b783          	ld	a5,-2000(a5) # 1000 <freep>
 7d8:	a039                	j	7e6 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e7e463          	bltu	a5,a4,7e4 <free+0x20>
 7e0:	00e6ea63          	bltu	a3,a4,7f4 <free+0x30>
{
 7e4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e6:	fed7fae3          	bgeu	a5,a3,7da <free+0x16>
 7ea:	6398                	ld	a4,0(a5)
 7ec:	00e6e463          	bltu	a3,a4,7f4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f0:	fee7eae3          	bltu	a5,a4,7e4 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7f4:	ff852583          	lw	a1,-8(a0)
 7f8:	6390                	ld	a2,0(a5)
 7fa:	02059813          	slli	a6,a1,0x20
 7fe:	01c85713          	srli	a4,a6,0x1c
 802:	9736                	add	a4,a4,a3
 804:	02e60563          	beq	a2,a4,82e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 80c:	4790                	lw	a2,8(a5)
 80e:	02061593          	slli	a1,a2,0x20
 812:	01c5d713          	srli	a4,a1,0x1c
 816:	973e                	add	a4,a4,a5
 818:	02e68263          	beq	a3,a4,83c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 81c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 81e:	00000717          	auipc	a4,0x0
 822:	7ef73123          	sd	a5,2018(a4) # 1000 <freep>
}
 826:	60a2                	ld	ra,8(sp)
 828:	6402                	ld	s0,0(sp)
 82a:	0141                	addi	sp,sp,16
 82c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 82e:	4618                	lw	a4,8(a2)
 830:	9f2d                	addw	a4,a4,a1
 832:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 836:	6398                	ld	a4,0(a5)
 838:	6310                	ld	a2,0(a4)
 83a:	b7f9                	j	808 <free+0x44>
    p->s.size += bp->s.size;
 83c:	ff852703          	lw	a4,-8(a0)
 840:	9f31                	addw	a4,a4,a2
 842:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 844:	ff053683          	ld	a3,-16(a0)
 848:	bfd1                	j	81c <free+0x58>

000000000000084a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 84a:	7139                	addi	sp,sp,-64
 84c:	fc06                	sd	ra,56(sp)
 84e:	f822                	sd	s0,48(sp)
 850:	f04a                	sd	s2,32(sp)
 852:	ec4e                	sd	s3,24(sp)
 854:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 856:	02051993          	slli	s3,a0,0x20
 85a:	0209d993          	srli	s3,s3,0x20
 85e:	09bd                	addi	s3,s3,15
 860:	0049d993          	srli	s3,s3,0x4
 864:	2985                	addiw	s3,s3,1
 866:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 868:	00000517          	auipc	a0,0x0
 86c:	79853503          	ld	a0,1944(a0) # 1000 <freep>
 870:	c905                	beqz	a0,8a0 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 872:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 874:	4798                	lw	a4,8(a5)
 876:	09377663          	bgeu	a4,s3,902 <malloc+0xb8>
 87a:	f426                	sd	s1,40(sp)
 87c:	e852                	sd	s4,16(sp)
 87e:	e456                	sd	s5,8(sp)
 880:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 882:	8a4e                	mv	s4,s3
 884:	6705                	lui	a4,0x1
 886:	00e9f363          	bgeu	s3,a4,88c <malloc+0x42>
 88a:	6a05                	lui	s4,0x1
 88c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 890:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 894:	00000497          	auipc	s1,0x0
 898:	76c48493          	addi	s1,s1,1900 # 1000 <freep>
  if(p == SBRK_ERROR)
 89c:	5afd                	li	s5,-1
 89e:	a83d                	j	8dc <malloc+0x92>
 8a0:	f426                	sd	s1,40(sp)
 8a2:	e852                	sd	s4,16(sp)
 8a4:	e456                	sd	s5,8(sp)
 8a6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8a8:	00000797          	auipc	a5,0x0
 8ac:	76878793          	addi	a5,a5,1896 # 1010 <base>
 8b0:	00000717          	auipc	a4,0x0
 8b4:	74f73823          	sd	a5,1872(a4) # 1000 <freep>
 8b8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ba:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8be:	b7d1                	j	882 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8c0:	6398                	ld	a4,0(a5)
 8c2:	e118                	sd	a4,0(a0)
 8c4:	a899                	j	91a <malloc+0xd0>
  hp->s.size = nu;
 8c6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ca:	0541                	addi	a0,a0,16
 8cc:	ef9ff0ef          	jal	7c4 <free>
  return freep;
 8d0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8d2:	c125                	beqz	a0,932 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d6:	4798                	lw	a4,8(a5)
 8d8:	03277163          	bgeu	a4,s2,8fa <malloc+0xb0>
    if(p == freep)
 8dc:	6098                	ld	a4,0(s1)
 8de:	853e                	mv	a0,a5
 8e0:	fef71ae3          	bne	a4,a5,8d4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8e4:	8552                	mv	a0,s4
 8e6:	a23ff0ef          	jal	308 <sbrk>
  if(p == SBRK_ERROR)
 8ea:	fd551ee3          	bne	a0,s5,8c6 <malloc+0x7c>
        return 0;
 8ee:	4501                	li	a0,0
 8f0:	74a2                	ld	s1,40(sp)
 8f2:	6a42                	ld	s4,16(sp)
 8f4:	6aa2                	ld	s5,8(sp)
 8f6:	6b02                	ld	s6,0(sp)
 8f8:	a03d                	j	926 <malloc+0xdc>
 8fa:	74a2                	ld	s1,40(sp)
 8fc:	6a42                	ld	s4,16(sp)
 8fe:	6aa2                	ld	s5,8(sp)
 900:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 902:	fae90fe3          	beq	s2,a4,8c0 <malloc+0x76>
        p->s.size -= nunits;
 906:	4137073b          	subw	a4,a4,s3
 90a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 90c:	02071693          	slli	a3,a4,0x20
 910:	01c6d713          	srli	a4,a3,0x1c
 914:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 916:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 91a:	00000717          	auipc	a4,0x0
 91e:	6ea73323          	sd	a0,1766(a4) # 1000 <freep>
      return (void*)(p + 1);
 922:	01078513          	addi	a0,a5,16
  }
}
 926:	70e2                	ld	ra,56(sp)
 928:	7442                	ld	s0,48(sp)
 92a:	7902                	ld	s2,32(sp)
 92c:	69e2                	ld	s3,24(sp)
 92e:	6121                	addi	sp,sp,64
 930:	8082                	ret
 932:	74a2                	ld	s1,40(sp)
 934:	6a42                	ld	s4,16(sp)
 936:	6aa2                	ld	s5,8(sp)
 938:	6b02                	ld	s6,0(sp)
 93a:	b7f5                	j	926 <malloc+0xdc>
