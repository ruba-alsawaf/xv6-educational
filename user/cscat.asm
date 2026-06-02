
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
  36:	92eb0b13          	addi	s6,s6,-1746 # 960 <malloc+0xf6>
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
  80:	732000ef          	jal	7b2 <printf>
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

00000000000003ec <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 3ec:	48e1                	li	a7,24
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <memread>:
.global memread
memread:
 li a7, SYS_memread
 3f4:	48e5                	li	a7,25
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 3fc:	48e9                	li	a7,26
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 404:	48ed                	li	a7,27
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40c:	1101                	addi	sp,sp,-32
 40e:	ec06                	sd	ra,24(sp)
 410:	e822                	sd	s0,16(sp)
 412:	1000                	addi	s0,sp,32
 414:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 418:	4605                	li	a2,1
 41a:	fef40593          	addi	a1,s0,-17
 41e:	f3fff0ef          	jal	35c <write>
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	6105                	addi	sp,sp,32
 428:	8082                	ret

000000000000042a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 42a:	715d                	addi	sp,sp,-80
 42c:	e486                	sd	ra,72(sp)
 42e:	e0a2                	sd	s0,64(sp)
 430:	f84a                	sd	s2,48(sp)
 432:	f44e                	sd	s3,40(sp)
 434:	0880                	addi	s0,sp,80
 436:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 438:	c6d1                	beqz	a3,4c4 <printint+0x9a>
 43a:	0805d563          	bgez	a1,4c4 <printint+0x9a>
    neg = 1;
    x = -xx;
 43e:	40b005b3          	neg	a1,a1
    neg = 1;
 442:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 444:	fb840993          	addi	s3,s0,-72
  neg = 0;
 448:	86ce                	mv	a3,s3
  i = 0;
 44a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 44c:	00000817          	auipc	a6,0x0
 450:	54c80813          	addi	a6,a6,1356 # 998 <digits>
 454:	88ba                	mv	a7,a4
 456:	0017051b          	addiw	a0,a4,1
 45a:	872a                	mv	a4,a0
 45c:	02c5f7b3          	remu	a5,a1,a2
 460:	97c2                	add	a5,a5,a6
 462:	0007c783          	lbu	a5,0(a5)
 466:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 46a:	87ae                	mv	a5,a1
 46c:	02c5d5b3          	divu	a1,a1,a2
 470:	0685                	addi	a3,a3,1
 472:	fec7f1e3          	bgeu	a5,a2,454 <printint+0x2a>
  if(neg)
 476:	00030c63          	beqz	t1,48e <printint+0x64>
    buf[i++] = '-';
 47a:	fd050793          	addi	a5,a0,-48
 47e:	00878533          	add	a0,a5,s0
 482:	02d00793          	li	a5,45
 486:	fef50423          	sb	a5,-24(a0)
 48a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 48e:	02e05563          	blez	a4,4b8 <printint+0x8e>
 492:	fc26                	sd	s1,56(sp)
 494:	377d                	addiw	a4,a4,-1
 496:	00e984b3          	add	s1,s3,a4
 49a:	19fd                	addi	s3,s3,-1
 49c:	99ba                	add	s3,s3,a4
 49e:	1702                	slli	a4,a4,0x20
 4a0:	9301                	srli	a4,a4,0x20
 4a2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a6:	0004c583          	lbu	a1,0(s1)
 4aa:	854a                	mv	a0,s2
 4ac:	f61ff0ef          	jal	40c <putc>
  while(--i >= 0)
 4b0:	14fd                	addi	s1,s1,-1
 4b2:	ff349ae3          	bne	s1,s3,4a6 <printint+0x7c>
 4b6:	74e2                	ld	s1,56(sp)
}
 4b8:	60a6                	ld	ra,72(sp)
 4ba:	6406                	ld	s0,64(sp)
 4bc:	7942                	ld	s2,48(sp)
 4be:	79a2                	ld	s3,40(sp)
 4c0:	6161                	addi	sp,sp,80
 4c2:	8082                	ret
  neg = 0;
 4c4:	4301                	li	t1,0
 4c6:	bfbd                	j	444 <printint+0x1a>

00000000000004c8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c8:	711d                	addi	sp,sp,-96
 4ca:	ec86                	sd	ra,88(sp)
 4cc:	e8a2                	sd	s0,80(sp)
 4ce:	e4a6                	sd	s1,72(sp)
 4d0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d2:	0005c483          	lbu	s1,0(a1)
 4d6:	22048363          	beqz	s1,6fc <vprintf+0x234>
 4da:	e0ca                	sd	s2,64(sp)
 4dc:	fc4e                	sd	s3,56(sp)
 4de:	f852                	sd	s4,48(sp)
 4e0:	f456                	sd	s5,40(sp)
 4e2:	f05a                	sd	s6,32(sp)
 4e4:	ec5e                	sd	s7,24(sp)
 4e6:	e862                	sd	s8,16(sp)
 4e8:	8b2a                	mv	s6,a0
 4ea:	8a2e                	mv	s4,a1
 4ec:	8bb2                	mv	s7,a2
  state = 0;
 4ee:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4f0:	4901                	li	s2,0
 4f2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4f4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4f8:	06400c13          	li	s8,100
 4fc:	a00d                	j	51e <vprintf+0x56>
        putc(fd, c0);
 4fe:	85a6                	mv	a1,s1
 500:	855a                	mv	a0,s6
 502:	f0bff0ef          	jal	40c <putc>
 506:	a019                	j	50c <vprintf+0x44>
    } else if(state == '%'){
 508:	03598363          	beq	s3,s5,52e <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 50c:	0019079b          	addiw	a5,s2,1
 510:	893e                	mv	s2,a5
 512:	873e                	mv	a4,a5
 514:	97d2                	add	a5,a5,s4
 516:	0007c483          	lbu	s1,0(a5)
 51a:	1c048a63          	beqz	s1,6ee <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 51e:	0004879b          	sext.w	a5,s1
    if(state == 0){
 522:	fe0993e3          	bnez	s3,508 <vprintf+0x40>
      if(c0 == '%'){
 526:	fd579ce3          	bne	a5,s5,4fe <vprintf+0x36>
        state = '%';
 52a:	89be                	mv	s3,a5
 52c:	b7c5                	j	50c <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 52e:	00ea06b3          	add	a3,s4,a4
 532:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 536:	1c060863          	beqz	a2,706 <vprintf+0x23e>
      if(c0 == 'd'){
 53a:	03878763          	beq	a5,s8,568 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 53e:	f9478693          	addi	a3,a5,-108
 542:	0016b693          	seqz	a3,a3
 546:	f9c60593          	addi	a1,a2,-100
 54a:	e99d                	bnez	a1,580 <vprintf+0xb8>
 54c:	ca95                	beqz	a3,580 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 54e:	008b8493          	addi	s1,s7,8
 552:	4685                	li	a3,1
 554:	4629                	li	a2,10
 556:	000bb583          	ld	a1,0(s7)
 55a:	855a                	mv	a0,s6
 55c:	ecfff0ef          	jal	42a <printint>
        i += 1;
 560:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 562:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 564:	4981                	li	s3,0
 566:	b75d                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 568:	008b8493          	addi	s1,s7,8
 56c:	4685                	li	a3,1
 56e:	4629                	li	a2,10
 570:	000ba583          	lw	a1,0(s7)
 574:	855a                	mv	a0,s6
 576:	eb5ff0ef          	jal	42a <printint>
 57a:	8ba6                	mv	s7,s1
      state = 0;
 57c:	4981                	li	s3,0
 57e:	b779                	j	50c <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 580:	9752                	add	a4,a4,s4
 582:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 586:	f9460713          	addi	a4,a2,-108
 58a:	00173713          	seqz	a4,a4
 58e:	8f75                	and	a4,a4,a3
 590:	f9c58513          	addi	a0,a1,-100
 594:	18051363          	bnez	a0,71a <vprintf+0x252>
 598:	18070163          	beqz	a4,71a <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 59c:	008b8493          	addi	s1,s7,8
 5a0:	4685                	li	a3,1
 5a2:	4629                	li	a2,10
 5a4:	000bb583          	ld	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	e81ff0ef          	jal	42a <printint>
        i += 2;
 5ae:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b0:	8ba6                	mv	s7,s1
      state = 0;
 5b2:	4981                	li	s3,0
        i += 2;
 5b4:	bfa1                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5b6:	008b8493          	addi	s1,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4629                	li	a2,10
 5be:	000be583          	lwu	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	e67ff0ef          	jal	42a <printint>
 5c8:	8ba6                	mv	s7,s1
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b781                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ce:	008b8493          	addi	s1,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4629                	li	a2,10
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	e4fff0ef          	jal	42a <printint>
        i += 1;
 5e0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e2:	8ba6                	mv	s7,s1
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	b71d                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e8:	008b8493          	addi	s1,s7,8
 5ec:	4681                	li	a3,0
 5ee:	4629                	li	a2,10
 5f0:	000bb583          	ld	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	e35ff0ef          	jal	42a <printint>
        i += 2;
 5fa:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fc:	8ba6                	mv	s7,s1
      state = 0;
 5fe:	4981                	li	s3,0
        i += 2;
 600:	b731                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 602:	008b8493          	addi	s1,s7,8
 606:	4681                	li	a3,0
 608:	4641                	li	a2,16
 60a:	000be583          	lwu	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	e1bff0ef          	jal	42a <printint>
 614:	8ba6                	mv	s7,s1
      state = 0;
 616:	4981                	li	s3,0
 618:	bdd5                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 61a:	008b8493          	addi	s1,s7,8
 61e:	4681                	li	a3,0
 620:	4641                	li	a2,16
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	e03ff0ef          	jal	42a <printint>
        i += 1;
 62c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	8ba6                	mv	s7,s1
      state = 0;
 630:	4981                	li	s3,0
 632:	bde9                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 634:	008b8493          	addi	s1,s7,8
 638:	4681                	li	a3,0
 63a:	4641                	li	a2,16
 63c:	000bb583          	ld	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	de9ff0ef          	jal	42a <printint>
        i += 2;
 646:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 648:	8ba6                	mv	s7,s1
      state = 0;
 64a:	4981                	li	s3,0
        i += 2;
 64c:	b5c1                	j	50c <vprintf+0x44>
 64e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 650:	008b8793          	addi	a5,s7,8
 654:	8cbe                	mv	s9,a5
 656:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 65a:	03000593          	li	a1,48
 65e:	855a                	mv	a0,s6
 660:	dadff0ef          	jal	40c <putc>
  putc(fd, 'x');
 664:	07800593          	li	a1,120
 668:	855a                	mv	a0,s6
 66a:	da3ff0ef          	jal	40c <putc>
 66e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 670:	00000b97          	auipc	s7,0x0
 674:	328b8b93          	addi	s7,s7,808 # 998 <digits>
 678:	03c9d793          	srli	a5,s3,0x3c
 67c:	97de                	add	a5,a5,s7
 67e:	0007c583          	lbu	a1,0(a5)
 682:	855a                	mv	a0,s6
 684:	d89ff0ef          	jal	40c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 688:	0992                	slli	s3,s3,0x4
 68a:	34fd                	addiw	s1,s1,-1
 68c:	f4f5                	bnez	s1,678 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 68e:	8be6                	mv	s7,s9
      state = 0;
 690:	4981                	li	s3,0
 692:	6ca2                	ld	s9,8(sp)
 694:	bda5                	j	50c <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 696:	008b8493          	addi	s1,s7,8
 69a:	000bc583          	lbu	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	d6dff0ef          	jal	40c <putc>
 6a4:	8ba6                	mv	s7,s1
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b595                	j	50c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6aa:	008b8993          	addi	s3,s7,8
 6ae:	000bb483          	ld	s1,0(s7)
 6b2:	cc91                	beqz	s1,6ce <vprintf+0x206>
        for(; *s; s++)
 6b4:	0004c583          	lbu	a1,0(s1)
 6b8:	c985                	beqz	a1,6e8 <vprintf+0x220>
          putc(fd, *s);
 6ba:	855a                	mv	a0,s6
 6bc:	d51ff0ef          	jal	40c <putc>
        for(; *s; s++)
 6c0:	0485                	addi	s1,s1,1
 6c2:	0004c583          	lbu	a1,0(s1)
 6c6:	f9f5                	bnez	a1,6ba <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6c8:	8bce                	mv	s7,s3
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b581                	j	50c <vprintf+0x44>
          s = "(null)";
 6ce:	00000497          	auipc	s1,0x0
 6d2:	2c248493          	addi	s1,s1,706 # 990 <malloc+0x126>
        for(; *s; s++)
 6d6:	02800593          	li	a1,40
 6da:	b7c5                	j	6ba <vprintf+0x1f2>
        putc(fd, '%');
 6dc:	85be                	mv	a1,a5
 6de:	855a                	mv	a0,s6
 6e0:	d2dff0ef          	jal	40c <putc>
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b51d                	j	50c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6e8:	8bce                	mv	s7,s3
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	b505                	j	50c <vprintf+0x44>
 6ee:	6906                	ld	s2,64(sp)
 6f0:	79e2                	ld	s3,56(sp)
 6f2:	7a42                	ld	s4,48(sp)
 6f4:	7aa2                	ld	s5,40(sp)
 6f6:	7b02                	ld	s6,32(sp)
 6f8:	6be2                	ld	s7,24(sp)
 6fa:	6c42                	ld	s8,16(sp)
    }
  }
}
 6fc:	60e6                	ld	ra,88(sp)
 6fe:	6446                	ld	s0,80(sp)
 700:	64a6                	ld	s1,72(sp)
 702:	6125                	addi	sp,sp,96
 704:	8082                	ret
      if(c0 == 'd'){
 706:	06400713          	li	a4,100
 70a:	e4e78fe3          	beq	a5,a4,568 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 70e:	f9478693          	addi	a3,a5,-108
 712:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 716:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 718:	4701                	li	a4,0
      } else if(c0 == 'u'){
 71a:	07500513          	li	a0,117
 71e:	e8a78ce3          	beq	a5,a0,5b6 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 722:	f8b60513          	addi	a0,a2,-117
 726:	e119                	bnez	a0,72c <vprintf+0x264>
 728:	ea0693e3          	bnez	a3,5ce <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 72c:	f8b58513          	addi	a0,a1,-117
 730:	e119                	bnez	a0,736 <vprintf+0x26e>
 732:	ea071be3          	bnez	a4,5e8 <vprintf+0x120>
      } else if(c0 == 'x'){
 736:	07800513          	li	a0,120
 73a:	eca784e3          	beq	a5,a0,602 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 73e:	f8860613          	addi	a2,a2,-120
 742:	e219                	bnez	a2,748 <vprintf+0x280>
 744:	ec069be3          	bnez	a3,61a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 748:	f8858593          	addi	a1,a1,-120
 74c:	e199                	bnez	a1,752 <vprintf+0x28a>
 74e:	ee0713e3          	bnez	a4,634 <vprintf+0x16c>
      } else if(c0 == 'p'){
 752:	07000713          	li	a4,112
 756:	eee78ce3          	beq	a5,a4,64e <vprintf+0x186>
      } else if(c0 == 'c'){
 75a:	06300713          	li	a4,99
 75e:	f2e78ce3          	beq	a5,a4,696 <vprintf+0x1ce>
      } else if(c0 == 's'){
 762:	07300713          	li	a4,115
 766:	f4e782e3          	beq	a5,a4,6aa <vprintf+0x1e2>
      } else if(c0 == '%'){
 76a:	02500713          	li	a4,37
 76e:	f6e787e3          	beq	a5,a4,6dc <vprintf+0x214>
        putc(fd, '%');
 772:	02500593          	li	a1,37
 776:	855a                	mv	a0,s6
 778:	c95ff0ef          	jal	40c <putc>
        putc(fd, c0);
 77c:	85a6                	mv	a1,s1
 77e:	855a                	mv	a0,s6
 780:	c8dff0ef          	jal	40c <putc>
      state = 0;
 784:	4981                	li	s3,0
 786:	b359                	j	50c <vprintf+0x44>

0000000000000788 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 788:	715d                	addi	sp,sp,-80
 78a:	ec06                	sd	ra,24(sp)
 78c:	e822                	sd	s0,16(sp)
 78e:	1000                	addi	s0,sp,32
 790:	e010                	sd	a2,0(s0)
 792:	e414                	sd	a3,8(s0)
 794:	e818                	sd	a4,16(s0)
 796:	ec1c                	sd	a5,24(s0)
 798:	03043023          	sd	a6,32(s0)
 79c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a0:	8622                	mv	a2,s0
 7a2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a6:	d23ff0ef          	jal	4c8 <vprintf>
}
 7aa:	60e2                	ld	ra,24(sp)
 7ac:	6442                	ld	s0,16(sp)
 7ae:	6161                	addi	sp,sp,80
 7b0:	8082                	ret

00000000000007b2 <printf>:

void
printf(const char *fmt, ...)
{
 7b2:	711d                	addi	sp,sp,-96
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	1000                	addi	s0,sp,32
 7ba:	e40c                	sd	a1,8(s0)
 7bc:	e810                	sd	a2,16(s0)
 7be:	ec14                	sd	a3,24(s0)
 7c0:	f018                	sd	a4,32(s0)
 7c2:	f41c                	sd	a5,40(s0)
 7c4:	03043823          	sd	a6,48(s0)
 7c8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7cc:	00840613          	addi	a2,s0,8
 7d0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d4:	85aa                	mv	a1,a0
 7d6:	4505                	li	a0,1
 7d8:	cf1ff0ef          	jal	4c8 <vprintf>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6125                	addi	sp,sp,96
 7e2:	8082                	ret

00000000000007e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e4:	1141                	addi	sp,sp,-16
 7e6:	e406                	sd	ra,8(sp)
 7e8:	e022                	sd	s0,0(sp)
 7ea:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ec:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f0:	00001797          	auipc	a5,0x1
 7f4:	8107b783          	ld	a5,-2032(a5) # 1000 <freep>
 7f8:	a039                	j	806 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fa:	6398                	ld	a4,0(a5)
 7fc:	00e7e463          	bltu	a5,a4,804 <free+0x20>
 800:	00e6ea63          	bltu	a3,a4,814 <free+0x30>
{
 804:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 806:	fed7fae3          	bgeu	a5,a3,7fa <free+0x16>
 80a:	6398                	ld	a4,0(a5)
 80c:	00e6e463          	bltu	a3,a4,814 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	fee7eae3          	bltu	a5,a4,804 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 814:	ff852583          	lw	a1,-8(a0)
 818:	6390                	ld	a2,0(a5)
 81a:	02059813          	slli	a6,a1,0x20
 81e:	01c85713          	srli	a4,a6,0x1c
 822:	9736                	add	a4,a4,a3
 824:	02e60563          	beq	a2,a4,84e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 828:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 82c:	4790                	lw	a2,8(a5)
 82e:	02061593          	slli	a1,a2,0x20
 832:	01c5d713          	srli	a4,a1,0x1c
 836:	973e                	add	a4,a4,a5
 838:	02e68263          	beq	a3,a4,85c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 83c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 83e:	00000717          	auipc	a4,0x0
 842:	7cf73123          	sd	a5,1986(a4) # 1000 <freep>
}
 846:	60a2                	ld	ra,8(sp)
 848:	6402                	ld	s0,0(sp)
 84a:	0141                	addi	sp,sp,16
 84c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 84e:	4618                	lw	a4,8(a2)
 850:	9f2d                	addw	a4,a4,a1
 852:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 856:	6398                	ld	a4,0(a5)
 858:	6310                	ld	a2,0(a4)
 85a:	b7f9                	j	828 <free+0x44>
    p->s.size += bp->s.size;
 85c:	ff852703          	lw	a4,-8(a0)
 860:	9f31                	addw	a4,a4,a2
 862:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 864:	ff053683          	ld	a3,-16(a0)
 868:	bfd1                	j	83c <free+0x58>

000000000000086a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86a:	7139                	addi	sp,sp,-64
 86c:	fc06                	sd	ra,56(sp)
 86e:	f822                	sd	s0,48(sp)
 870:	f04a                	sd	s2,32(sp)
 872:	ec4e                	sd	s3,24(sp)
 874:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 876:	02051993          	slli	s3,a0,0x20
 87a:	0209d993          	srli	s3,s3,0x20
 87e:	09bd                	addi	s3,s3,15
 880:	0049d993          	srli	s3,s3,0x4
 884:	2985                	addiw	s3,s3,1
 886:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 888:	00000517          	auipc	a0,0x0
 88c:	77853503          	ld	a0,1912(a0) # 1000 <freep>
 890:	c905                	beqz	a0,8c0 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 892:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 894:	4798                	lw	a4,8(a5)
 896:	09377663          	bgeu	a4,s3,922 <malloc+0xb8>
 89a:	f426                	sd	s1,40(sp)
 89c:	e852                	sd	s4,16(sp)
 89e:	e456                	sd	s5,8(sp)
 8a0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8a2:	8a4e                	mv	s4,s3
 8a4:	6705                	lui	a4,0x1
 8a6:	00e9f363          	bgeu	s3,a4,8ac <malloc+0x42>
 8aa:	6a05                	lui	s4,0x1
 8ac:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b4:	00000497          	auipc	s1,0x0
 8b8:	74c48493          	addi	s1,s1,1868 # 1000 <freep>
  if(p == SBRK_ERROR)
 8bc:	5afd                	li	s5,-1
 8be:	a83d                	j	8fc <malloc+0x92>
 8c0:	f426                	sd	s1,40(sp)
 8c2:	e852                	sd	s4,16(sp)
 8c4:	e456                	sd	s5,8(sp)
 8c6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8c8:	00000797          	auipc	a5,0x0
 8cc:	74878793          	addi	a5,a5,1864 # 1010 <base>
 8d0:	00000717          	auipc	a4,0x0
 8d4:	72f73823          	sd	a5,1840(a4) # 1000 <freep>
 8d8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8da:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8de:	b7d1                	j	8a2 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8e0:	6398                	ld	a4,0(a5)
 8e2:	e118                	sd	a4,0(a0)
 8e4:	a899                	j	93a <malloc+0xd0>
  hp->s.size = nu;
 8e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ea:	0541                	addi	a0,a0,16
 8ec:	ef9ff0ef          	jal	7e4 <free>
  return freep;
 8f0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8f2:	c125                	beqz	a0,952 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f6:	4798                	lw	a4,8(a5)
 8f8:	03277163          	bgeu	a4,s2,91a <malloc+0xb0>
    if(p == freep)
 8fc:	6098                	ld	a4,0(s1)
 8fe:	853e                	mv	a0,a5
 900:	fef71ae3          	bne	a4,a5,8f4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 904:	8552                	mv	a0,s4
 906:	a03ff0ef          	jal	308 <sbrk>
  if(p == SBRK_ERROR)
 90a:	fd551ee3          	bne	a0,s5,8e6 <malloc+0x7c>
        return 0;
 90e:	4501                	li	a0,0
 910:	74a2                	ld	s1,40(sp)
 912:	6a42                	ld	s4,16(sp)
 914:	6aa2                	ld	s5,8(sp)
 916:	6b02                	ld	s6,0(sp)
 918:	a03d                	j	946 <malloc+0xdc>
 91a:	74a2                	ld	s1,40(sp)
 91c:	6a42                	ld	s4,16(sp)
 91e:	6aa2                	ld	s5,8(sp)
 920:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 922:	fae90fe3          	beq	s2,a4,8e0 <malloc+0x76>
        p->s.size -= nunits;
 926:	4137073b          	subw	a4,a4,s3
 92a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 92c:	02071693          	slli	a3,a4,0x20
 930:	01c6d713          	srli	a4,a3,0x1c
 934:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 936:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 93a:	00000717          	auipc	a4,0x0
 93e:	6ca73323          	sd	a0,1734(a4) # 1000 <freep>
      return (void*)(p + 1);
 942:	01078513          	addi	a0,a5,16
  }
}
 946:	70e2                	ld	ra,56(sp)
 948:	7442                	ld	s0,48(sp)
 94a:	7902                	ld	s2,32(sp)
 94c:	69e2                	ld	s3,24(sp)
 94e:	6121                	addi	sp,sp,64
 950:	8082                	ret
 952:	74a2                	ld	s1,40(sp)
 954:	6a42                	ld	s4,16(sp)
 956:	6aa2                	ld	s5,8(sp)
 958:	6b02                	ld	s6,0(sp)
 95a:	b7f5                	j	946 <malloc+0xdc>
