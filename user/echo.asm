
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	e05a                	sd	s6,0(sp)
  12:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  14:	4785                	li	a5,1
  16:	06a7d063          	bge	a5,a0,76 <main+0x76>
  1a:	00858493          	addi	s1,a1,8
  1e:	3579                	addiw	a0,a0,-2
  20:	02051793          	slli	a5,a0,0x20
  24:	01d7d513          	srli	a0,a5,0x1d
  28:	00a48ab3          	add	s5,s1,a0
  2c:	05c1                	addi	a1,a1,16
  2e:	00a58a33          	add	s4,a1,a0
    write(1, argv[i], strlen(argv[i]));
  32:	4985                	li	s3,1
    if(i + 1 < argc){
      write(1, " ", 1);
  34:	00001b17          	auipc	s6,0x1
  38:	91cb0b13          	addi	s6,s6,-1764 # 950 <malloc+0x100>
  3c:	a809                	j	4e <main+0x4e>
  3e:	864e                	mv	a2,s3
  40:	85da                	mv	a1,s6
  42:	854e                	mv	a0,s3
  44:	30e000ef          	jal	352 <write>
  for(i = 1; i < argc; i++){
  48:	04a1                	addi	s1,s1,8
  4a:	03448663          	beq	s1,s4,76 <main+0x76>
    write(1, argv[i], strlen(argv[i]));
  4e:	0004b903          	ld	s2,0(s1)
  52:	854a                	mv	a0,s2
  54:	088000ef          	jal	dc <strlen>
  58:	862a                	mv	a2,a0
  5a:	85ca                	mv	a1,s2
  5c:	854e                	mv	a0,s3
  5e:	2f4000ef          	jal	352 <write>
    if(i + 1 < argc){
  62:	fd549ee3          	bne	s1,s5,3e <main+0x3e>
    } else {
      write(1, "\n", 1);
  66:	4605                	li	a2,1
  68:	00001597          	auipc	a1,0x1
  6c:	8f058593          	addi	a1,a1,-1808 # 958 <malloc+0x108>
  70:	8532                	mv	a0,a2
  72:	2e0000ef          	jal	352 <write>
    }
  }
  exit(0);
  76:	4501                	li	a0,0
  78:	2ba000ef          	jal	332 <exit>

000000000000007c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e406                	sd	ra,8(sp)
  80:	e022                	sd	s0,0(sp)
  82:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  84:	f7dff0ef          	jal	0 <main>
  exit(r);
  88:	2aa000ef          	jal	332 <exit>

000000000000008c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e406                	sd	ra,8(sp)
  90:	e022                	sd	s0,0(sp)
  92:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  94:	87aa                	mv	a5,a0
  96:	0585                	addi	a1,a1,1
  98:	0785                	addi	a5,a5,1
  9a:	fff5c703          	lbu	a4,-1(a1)
  9e:	fee78fa3          	sb	a4,-1(a5)
  a2:	fb75                	bnez	a4,96 <strcpy+0xa>
    ;
  return os;
}
  a4:	60a2                	ld	ra,8(sp)
  a6:	6402                	ld	s0,0(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret

00000000000000ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e406                	sd	ra,8(sp)
  b0:	e022                	sd	s0,0(sp)
  b2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b4:	00054783          	lbu	a5,0(a0)
  b8:	cb91                	beqz	a5,cc <strcmp+0x20>
  ba:	0005c703          	lbu	a4,0(a1)
  be:	00f71763          	bne	a4,a5,cc <strcmp+0x20>
    p++, q++;
  c2:	0505                	addi	a0,a0,1
  c4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	fbe5                	bnez	a5,ba <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  cc:	0005c503          	lbu	a0,0(a1)
}
  d0:	40a7853b          	subw	a0,a5,a0
  d4:	60a2                	ld	ra,8(sp)
  d6:	6402                	ld	s0,0(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <strlen>:

uint
strlen(const char *s)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e406                	sd	ra,8(sp)
  e0:	e022                	sd	s0,0(sp)
  e2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	cf91                	beqz	a5,104 <strlen+0x28>
  ea:	00150793          	addi	a5,a0,1
  ee:	86be                	mv	a3,a5
  f0:	0785                	addi	a5,a5,1
  f2:	fff7c703          	lbu	a4,-1(a5)
  f6:	ff65                	bnez	a4,ee <strlen+0x12>
  f8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  fc:	60a2                	ld	ra,8(sp)
  fe:	6402                	ld	s0,0(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret
  for(n = 0; s[n]; n++)
 104:	4501                	li	a0,0
 106:	bfdd                	j	fc <strlen+0x20>

0000000000000108 <memset>:

void*
memset(void *dst, int c, uint n)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e406                	sd	ra,8(sp)
 10c:	e022                	sd	s0,0(sp)
 10e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 110:	ca19                	beqz	a2,126 <memset+0x1e>
 112:	87aa                	mv	a5,a0
 114:	1602                	slli	a2,a2,0x20
 116:	9201                	srli	a2,a2,0x20
 118:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 11c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 120:	0785                	addi	a5,a5,1
 122:	fee79de3          	bne	a5,a4,11c <memset+0x14>
  }
  return dst;
}
 126:	60a2                	ld	ra,8(sp)
 128:	6402                	ld	s0,0(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strchr>:

char*
strchr(const char *s, char c)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e406                	sd	ra,8(sp)
 132:	e022                	sd	s0,0(sp)
 134:	0800                	addi	s0,sp,16
  for(; *s; s++)
 136:	00054783          	lbu	a5,0(a0)
 13a:	cf81                	beqz	a5,152 <strchr+0x24>
    if(*s == c)
 13c:	00f58763          	beq	a1,a5,14a <strchr+0x1c>
  for(; *s; s++)
 140:	0505                	addi	a0,a0,1
 142:	00054783          	lbu	a5,0(a0)
 146:	fbfd                	bnez	a5,13c <strchr+0xe>
      return (char*)s;
  return 0;
 148:	4501                	li	a0,0
}
 14a:	60a2                	ld	ra,8(sp)
 14c:	6402                	ld	s0,0(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret
  return 0;
 152:	4501                	li	a0,0
 154:	bfdd                	j	14a <strchr+0x1c>

0000000000000156 <gets>:

char*
gets(char *buf, int max)
{
 156:	711d                	addi	sp,sp,-96
 158:	ec86                	sd	ra,88(sp)
 15a:	e8a2                	sd	s0,80(sp)
 15c:	e4a6                	sd	s1,72(sp)
 15e:	e0ca                	sd	s2,64(sp)
 160:	fc4e                	sd	s3,56(sp)
 162:	f852                	sd	s4,48(sp)
 164:	f456                	sd	s5,40(sp)
 166:	f05a                	sd	s6,32(sp)
 168:	ec5e                	sd	s7,24(sp)
 16a:	e862                	sd	s8,16(sp)
 16c:	1080                	addi	s0,sp,96
 16e:	8baa                	mv	s7,a0
 170:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 172:	892a                	mv	s2,a0
 174:	4481                	li	s1,0
    cc = read(0, &c, 1);
 176:	faf40b13          	addi	s6,s0,-81
 17a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 17c:	8c26                	mv	s8,s1
 17e:	0014899b          	addiw	s3,s1,1
 182:	84ce                	mv	s1,s3
 184:	0349d463          	bge	s3,s4,1ac <gets+0x56>
    cc = read(0, &c, 1);
 188:	8656                	mv	a2,s5
 18a:	85da                	mv	a1,s6
 18c:	4501                	li	a0,0
 18e:	1bc000ef          	jal	34a <read>
    if(cc < 1)
 192:	00a05d63          	blez	a0,1ac <gets+0x56>
      break;
    buf[i++] = c;
 196:	faf44783          	lbu	a5,-81(s0)
 19a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 19e:	0905                	addi	s2,s2,1
 1a0:	ff678713          	addi	a4,a5,-10
 1a4:	c319                	beqz	a4,1aa <gets+0x54>
 1a6:	17cd                	addi	a5,a5,-13
 1a8:	fbf1                	bnez	a5,17c <gets+0x26>
    buf[i++] = c;
 1aa:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1ac:	9c5e                	add	s8,s8,s7
 1ae:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1b2:	855e                	mv	a0,s7
 1b4:	60e6                	ld	ra,88(sp)
 1b6:	6446                	ld	s0,80(sp)
 1b8:	64a6                	ld	s1,72(sp)
 1ba:	6906                	ld	s2,64(sp)
 1bc:	79e2                	ld	s3,56(sp)
 1be:	7a42                	ld	s4,48(sp)
 1c0:	7aa2                	ld	s5,40(sp)
 1c2:	7b02                	ld	s6,32(sp)
 1c4:	6be2                	ld	s7,24(sp)
 1c6:	6c42                	ld	s8,16(sp)
 1c8:	6125                	addi	sp,sp,96
 1ca:	8082                	ret

00000000000001cc <stat>:

int
stat(const char *n, struct stat *st)
{
 1cc:	1101                	addi	sp,sp,-32
 1ce:	ec06                	sd	ra,24(sp)
 1d0:	e822                	sd	s0,16(sp)
 1d2:	e04a                	sd	s2,0(sp)
 1d4:	1000                	addi	s0,sp,32
 1d6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d8:	4581                	li	a1,0
 1da:	198000ef          	jal	372 <open>
  if(fd < 0)
 1de:	02054263          	bltz	a0,202 <stat+0x36>
 1e2:	e426                	sd	s1,8(sp)
 1e4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1e6:	85ca                	mv	a1,s2
 1e8:	1a2000ef          	jal	38a <fstat>
 1ec:	892a                	mv	s2,a0
  close(fd);
 1ee:	8526                	mv	a0,s1
 1f0:	16a000ef          	jal	35a <close>
  return r;
 1f4:	64a2                	ld	s1,8(sp)
}
 1f6:	854a                	mv	a0,s2
 1f8:	60e2                	ld	ra,24(sp)
 1fa:	6442                	ld	s0,16(sp)
 1fc:	6902                	ld	s2,0(sp)
 1fe:	6105                	addi	sp,sp,32
 200:	8082                	ret
    return -1;
 202:	57fd                	li	a5,-1
 204:	893e                	mv	s2,a5
 206:	bfc5                	j	1f6 <stat+0x2a>

0000000000000208 <atoi>:

int
atoi(const char *s)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e406                	sd	ra,8(sp)
 20c:	e022                	sd	s0,0(sp)
 20e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 210:	00054683          	lbu	a3,0(a0)
 214:	fd06879b          	addiw	a5,a3,-48
 218:	0ff7f793          	zext.b	a5,a5
 21c:	4625                	li	a2,9
 21e:	02f66963          	bltu	a2,a5,250 <atoi+0x48>
 222:	872a                	mv	a4,a0
  n = 0;
 224:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 226:	0705                	addi	a4,a4,1
 228:	0025179b          	slliw	a5,a0,0x2
 22c:	9fa9                	addw	a5,a5,a0
 22e:	0017979b          	slliw	a5,a5,0x1
 232:	9fb5                	addw	a5,a5,a3
 234:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 238:	00074683          	lbu	a3,0(a4)
 23c:	fd06879b          	addiw	a5,a3,-48
 240:	0ff7f793          	zext.b	a5,a5
 244:	fef671e3          	bgeu	a2,a5,226 <atoi+0x1e>
  return n;
}
 248:	60a2                	ld	ra,8(sp)
 24a:	6402                	ld	s0,0(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
  n = 0;
 250:	4501                	li	a0,0
 252:	bfdd                	j	248 <atoi+0x40>

0000000000000254 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 254:	1141                	addi	sp,sp,-16
 256:	e406                	sd	ra,8(sp)
 258:	e022                	sd	s0,0(sp)
 25a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 25c:	02b57563          	bgeu	a0,a1,286 <memmove+0x32>
    while(n-- > 0)
 260:	00c05f63          	blez	a2,27e <memmove+0x2a>
 264:	1602                	slli	a2,a2,0x20
 266:	9201                	srli	a2,a2,0x20
 268:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 26c:	872a                	mv	a4,a0
      *dst++ = *src++;
 26e:	0585                	addi	a1,a1,1
 270:	0705                	addi	a4,a4,1
 272:	fff5c683          	lbu	a3,-1(a1)
 276:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 27a:	fee79ae3          	bne	a5,a4,26e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 27e:	60a2                	ld	ra,8(sp)
 280:	6402                	ld	s0,0(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret
    while(n-- > 0)
 286:	fec05ce3          	blez	a2,27e <memmove+0x2a>
    dst += n;
 28a:	00c50733          	add	a4,a0,a2
    src += n;
 28e:	95b2                	add	a1,a1,a2
 290:	fff6079b          	addiw	a5,a2,-1
 294:	1782                	slli	a5,a5,0x20
 296:	9381                	srli	a5,a5,0x20
 298:	fff7c793          	not	a5,a5
 29c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 29e:	15fd                	addi	a1,a1,-1
 2a0:	177d                	addi	a4,a4,-1
 2a2:	0005c683          	lbu	a3,0(a1)
 2a6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2aa:	fef71ae3          	bne	a4,a5,29e <memmove+0x4a>
 2ae:	bfc1                	j	27e <memmove+0x2a>

00000000000002b0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e406                	sd	ra,8(sp)
 2b4:	e022                	sd	s0,0(sp)
 2b6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2b8:	c61d                	beqz	a2,2e6 <memcmp+0x36>
 2ba:	1602                	slli	a2,a2,0x20
 2bc:	9201                	srli	a2,a2,0x20
 2be:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2c2:	00054783          	lbu	a5,0(a0)
 2c6:	0005c703          	lbu	a4,0(a1)
 2ca:	00e79863          	bne	a5,a4,2da <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2ce:	0505                	addi	a0,a0,1
    p2++;
 2d0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2d2:	fed518e3          	bne	a0,a3,2c2 <memcmp+0x12>
  }
  return 0;
 2d6:	4501                	li	a0,0
 2d8:	a019                	j	2de <memcmp+0x2e>
      return *p1 - *p2;
 2da:	40e7853b          	subw	a0,a5,a4
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  return 0;
 2e6:	4501                	li	a0,0
 2e8:	bfdd                	j	2de <memcmp+0x2e>

00000000000002ea <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e406                	sd	ra,8(sp)
 2ee:	e022                	sd	s0,0(sp)
 2f0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f2:	f63ff0ef          	jal	254 <memmove>
}
 2f6:	60a2                	ld	ra,8(sp)
 2f8:	6402                	ld	s0,0(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret

00000000000002fe <sbrk>:

char *
sbrk(int n) {
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 306:	4585                	li	a1,1
 308:	0b2000ef          	jal	3ba <sys_sbrk>
}
 30c:	60a2                	ld	ra,8(sp)
 30e:	6402                	ld	s0,0(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret

0000000000000314 <sbrklazy>:

char *
sbrklazy(int n) {
 314:	1141                	addi	sp,sp,-16
 316:	e406                	sd	ra,8(sp)
 318:	e022                	sd	s0,0(sp)
 31a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 31c:	4589                	li	a1,2
 31e:	09c000ef          	jal	3ba <sys_sbrk>
}
 322:	60a2                	ld	ra,8(sp)
 324:	6402                	ld	s0,0(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret

000000000000032a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 32a:	4885                	li	a7,1
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <exit>:
.global exit
exit:
 li a7, SYS_exit
 332:	4889                	li	a7,2
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <wait>:
.global wait
wait:
 li a7, SYS_wait
 33a:	488d                	li	a7,3
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 342:	4891                	li	a7,4
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <read>:
.global read
read:
 li a7, SYS_read
 34a:	4895                	li	a7,5
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <write>:
.global write
write:
 li a7, SYS_write
 352:	48c1                	li	a7,16
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <close>:
.global close
close:
 li a7, SYS_close
 35a:	48d5                	li	a7,21
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <kill>:
.global kill
kill:
 li a7, SYS_kill
 362:	4899                	li	a7,6
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <exec>:
.global exec
exec:
 li a7, SYS_exec
 36a:	489d                	li	a7,7
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <open>:
.global open
open:
 li a7, SYS_open
 372:	48bd                	li	a7,15
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 37a:	48c5                	li	a7,17
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 382:	48c9                	li	a7,18
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 38a:	48a1                	li	a7,8
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <link>:
.global link
link:
 li a7, SYS_link
 392:	48cd                	li	a7,19
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 39a:	48d1                	li	a7,20
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a2:	48a5                	li	a7,9
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <dup>:
.global dup
dup:
 li a7, SYS_dup
 3aa:	48a9                	li	a7,10
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b2:	48ad                	li	a7,11
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3ba:	48b1                	li	a7,12
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3c2:	48b5                	li	a7,13
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ca:	48b9                	li	a7,14
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <csread>:
.global csread
csread:
 li a7, SYS_csread
 3d2:	48d9                	li	a7,22
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 3da:	48dd                	li	a7,23
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 3e2:	48e1                	li	a7,24
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <memread>:
.global memread
memread:
 li a7, SYS_memread
 3ea:	48e5                	li	a7,25
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f2:	1101                	addi	sp,sp,-32
 3f4:	ec06                	sd	ra,24(sp)
 3f6:	e822                	sd	s0,16(sp)
 3f8:	1000                	addi	s0,sp,32
 3fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fe:	4605                	li	a2,1
 400:	fef40593          	addi	a1,s0,-17
 404:	f4fff0ef          	jal	352 <write>
}
 408:	60e2                	ld	ra,24(sp)
 40a:	6442                	ld	s0,16(sp)
 40c:	6105                	addi	sp,sp,32
 40e:	8082                	ret

0000000000000410 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 410:	715d                	addi	sp,sp,-80
 412:	e486                	sd	ra,72(sp)
 414:	e0a2                	sd	s0,64(sp)
 416:	f84a                	sd	s2,48(sp)
 418:	f44e                	sd	s3,40(sp)
 41a:	0880                	addi	s0,sp,80
 41c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 41e:	c6d1                	beqz	a3,4aa <printint+0x9a>
 420:	0805d563          	bgez	a1,4aa <printint+0x9a>
    neg = 1;
    x = -xx;
 424:	40b005b3          	neg	a1,a1
    neg = 1;
 428:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 42a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 42e:	86ce                	mv	a3,s3
  i = 0;
 430:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 432:	00000817          	auipc	a6,0x0
 436:	53680813          	addi	a6,a6,1334 # 968 <digits>
 43a:	88ba                	mv	a7,a4
 43c:	0017051b          	addiw	a0,a4,1
 440:	872a                	mv	a4,a0
 442:	02c5f7b3          	remu	a5,a1,a2
 446:	97c2                	add	a5,a5,a6
 448:	0007c783          	lbu	a5,0(a5)
 44c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 450:	87ae                	mv	a5,a1
 452:	02c5d5b3          	divu	a1,a1,a2
 456:	0685                	addi	a3,a3,1
 458:	fec7f1e3          	bgeu	a5,a2,43a <printint+0x2a>
  if(neg)
 45c:	00030c63          	beqz	t1,474 <printint+0x64>
    buf[i++] = '-';
 460:	fd050793          	addi	a5,a0,-48
 464:	00878533          	add	a0,a5,s0
 468:	02d00793          	li	a5,45
 46c:	fef50423          	sb	a5,-24(a0)
 470:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 474:	02e05563          	blez	a4,49e <printint+0x8e>
 478:	fc26                	sd	s1,56(sp)
 47a:	377d                	addiw	a4,a4,-1
 47c:	00e984b3          	add	s1,s3,a4
 480:	19fd                	addi	s3,s3,-1
 482:	99ba                	add	s3,s3,a4
 484:	1702                	slli	a4,a4,0x20
 486:	9301                	srli	a4,a4,0x20
 488:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 48c:	0004c583          	lbu	a1,0(s1)
 490:	854a                	mv	a0,s2
 492:	f61ff0ef          	jal	3f2 <putc>
  while(--i >= 0)
 496:	14fd                	addi	s1,s1,-1
 498:	ff349ae3          	bne	s1,s3,48c <printint+0x7c>
 49c:	74e2                	ld	s1,56(sp)
}
 49e:	60a6                	ld	ra,72(sp)
 4a0:	6406                	ld	s0,64(sp)
 4a2:	7942                	ld	s2,48(sp)
 4a4:	79a2                	ld	s3,40(sp)
 4a6:	6161                	addi	sp,sp,80
 4a8:	8082                	ret
  neg = 0;
 4aa:	4301                	li	t1,0
 4ac:	bfbd                	j	42a <printint+0x1a>

00000000000004ae <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ae:	711d                	addi	sp,sp,-96
 4b0:	ec86                	sd	ra,88(sp)
 4b2:	e8a2                	sd	s0,80(sp)
 4b4:	e4a6                	sd	s1,72(sp)
 4b6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b8:	0005c483          	lbu	s1,0(a1)
 4bc:	22048363          	beqz	s1,6e2 <vprintf+0x234>
 4c0:	e0ca                	sd	s2,64(sp)
 4c2:	fc4e                	sd	s3,56(sp)
 4c4:	f852                	sd	s4,48(sp)
 4c6:	f456                	sd	s5,40(sp)
 4c8:	f05a                	sd	s6,32(sp)
 4ca:	ec5e                	sd	s7,24(sp)
 4cc:	e862                	sd	s8,16(sp)
 4ce:	8b2a                	mv	s6,a0
 4d0:	8a2e                	mv	s4,a1
 4d2:	8bb2                	mv	s7,a2
  state = 0;
 4d4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4d6:	4901                	li	s2,0
 4d8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4da:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4de:	06400c13          	li	s8,100
 4e2:	a00d                	j	504 <vprintf+0x56>
        putc(fd, c0);
 4e4:	85a6                	mv	a1,s1
 4e6:	855a                	mv	a0,s6
 4e8:	f0bff0ef          	jal	3f2 <putc>
 4ec:	a019                	j	4f2 <vprintf+0x44>
    } else if(state == '%'){
 4ee:	03598363          	beq	s3,s5,514 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4f2:	0019079b          	addiw	a5,s2,1
 4f6:	893e                	mv	s2,a5
 4f8:	873e                	mv	a4,a5
 4fa:	97d2                	add	a5,a5,s4
 4fc:	0007c483          	lbu	s1,0(a5)
 500:	1c048a63          	beqz	s1,6d4 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 504:	0004879b          	sext.w	a5,s1
    if(state == 0){
 508:	fe0993e3          	bnez	s3,4ee <vprintf+0x40>
      if(c0 == '%'){
 50c:	fd579ce3          	bne	a5,s5,4e4 <vprintf+0x36>
        state = '%';
 510:	89be                	mv	s3,a5
 512:	b7c5                	j	4f2 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 514:	00ea06b3          	add	a3,s4,a4
 518:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 51c:	1c060863          	beqz	a2,6ec <vprintf+0x23e>
      if(c0 == 'd'){
 520:	03878763          	beq	a5,s8,54e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 524:	f9478693          	addi	a3,a5,-108
 528:	0016b693          	seqz	a3,a3
 52c:	f9c60593          	addi	a1,a2,-100
 530:	e99d                	bnez	a1,566 <vprintf+0xb8>
 532:	ca95                	beqz	a3,566 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 534:	008b8493          	addi	s1,s7,8
 538:	4685                	li	a3,1
 53a:	4629                	li	a2,10
 53c:	000bb583          	ld	a1,0(s7)
 540:	855a                	mv	a0,s6
 542:	ecfff0ef          	jal	410 <printint>
        i += 1;
 546:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 548:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 54a:	4981                	li	s3,0
 54c:	b75d                	j	4f2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 54e:	008b8493          	addi	s1,s7,8
 552:	4685                	li	a3,1
 554:	4629                	li	a2,10
 556:	000ba583          	lw	a1,0(s7)
 55a:	855a                	mv	a0,s6
 55c:	eb5ff0ef          	jal	410 <printint>
 560:	8ba6                	mv	s7,s1
      state = 0;
 562:	4981                	li	s3,0
 564:	b779                	j	4f2 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 566:	9752                	add	a4,a4,s4
 568:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 56c:	f9460713          	addi	a4,a2,-108
 570:	00173713          	seqz	a4,a4
 574:	8f75                	and	a4,a4,a3
 576:	f9c58513          	addi	a0,a1,-100
 57a:	18051363          	bnez	a0,700 <vprintf+0x252>
 57e:	18070163          	beqz	a4,700 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 582:	008b8493          	addi	s1,s7,8
 586:	4685                	li	a3,1
 588:	4629                	li	a2,10
 58a:	000bb583          	ld	a1,0(s7)
 58e:	855a                	mv	a0,s6
 590:	e81ff0ef          	jal	410 <printint>
        i += 2;
 594:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 596:	8ba6                	mv	s7,s1
      state = 0;
 598:	4981                	li	s3,0
        i += 2;
 59a:	bfa1                	j	4f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 59c:	008b8493          	addi	s1,s7,8
 5a0:	4681                	li	a3,0
 5a2:	4629                	li	a2,10
 5a4:	000be583          	lwu	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	e67ff0ef          	jal	410 <printint>
 5ae:	8ba6                	mv	s7,s1
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	b781                	j	4f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b4:	008b8493          	addi	s1,s7,8
 5b8:	4681                	li	a3,0
 5ba:	4629                	li	a2,10
 5bc:	000bb583          	ld	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	e4fff0ef          	jal	410 <printint>
        i += 1;
 5c6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c8:	8ba6                	mv	s7,s1
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b71d                	j	4f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ce:	008b8493          	addi	s1,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4629                	li	a2,10
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	e35ff0ef          	jal	410 <printint>
        i += 2;
 5e0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e2:	8ba6                	mv	s7,s1
      state = 0;
 5e4:	4981                	li	s3,0
        i += 2;
 5e6:	b731                	j	4f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5e8:	008b8493          	addi	s1,s7,8
 5ec:	4681                	li	a3,0
 5ee:	4641                	li	a2,16
 5f0:	000be583          	lwu	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	e1bff0ef          	jal	410 <printint>
 5fa:	8ba6                	mv	s7,s1
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	bdd5                	j	4f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 600:	008b8493          	addi	s1,s7,8
 604:	4681                	li	a3,0
 606:	4641                	li	a2,16
 608:	000bb583          	ld	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	e03ff0ef          	jal	410 <printint>
        i += 1;
 612:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 614:	8ba6                	mv	s7,s1
      state = 0;
 616:	4981                	li	s3,0
 618:	bde9                	j	4f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 61a:	008b8493          	addi	s1,s7,8
 61e:	4681                	li	a3,0
 620:	4641                	li	a2,16
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	de9ff0ef          	jal	410 <printint>
        i += 2;
 62c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	8ba6                	mv	s7,s1
      state = 0;
 630:	4981                	li	s3,0
        i += 2;
 632:	b5c1                	j	4f2 <vprintf+0x44>
 634:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 636:	008b8793          	addi	a5,s7,8
 63a:	8cbe                	mv	s9,a5
 63c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 640:	03000593          	li	a1,48
 644:	855a                	mv	a0,s6
 646:	dadff0ef          	jal	3f2 <putc>
  putc(fd, 'x');
 64a:	07800593          	li	a1,120
 64e:	855a                	mv	a0,s6
 650:	da3ff0ef          	jal	3f2 <putc>
 654:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 656:	00000b97          	auipc	s7,0x0
 65a:	312b8b93          	addi	s7,s7,786 # 968 <digits>
 65e:	03c9d793          	srli	a5,s3,0x3c
 662:	97de                	add	a5,a5,s7
 664:	0007c583          	lbu	a1,0(a5)
 668:	855a                	mv	a0,s6
 66a:	d89ff0ef          	jal	3f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66e:	0992                	slli	s3,s3,0x4
 670:	34fd                	addiw	s1,s1,-1
 672:	f4f5                	bnez	s1,65e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 674:	8be6                	mv	s7,s9
      state = 0;
 676:	4981                	li	s3,0
 678:	6ca2                	ld	s9,8(sp)
 67a:	bda5                	j	4f2 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 67c:	008b8493          	addi	s1,s7,8
 680:	000bc583          	lbu	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	d6dff0ef          	jal	3f2 <putc>
 68a:	8ba6                	mv	s7,s1
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b595                	j	4f2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 690:	008b8993          	addi	s3,s7,8
 694:	000bb483          	ld	s1,0(s7)
 698:	cc91                	beqz	s1,6b4 <vprintf+0x206>
        for(; *s; s++)
 69a:	0004c583          	lbu	a1,0(s1)
 69e:	c985                	beqz	a1,6ce <vprintf+0x220>
          putc(fd, *s);
 6a0:	855a                	mv	a0,s6
 6a2:	d51ff0ef          	jal	3f2 <putc>
        for(; *s; s++)
 6a6:	0485                	addi	s1,s1,1
 6a8:	0004c583          	lbu	a1,0(s1)
 6ac:	f9f5                	bnez	a1,6a0 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6ae:	8bce                	mv	s7,s3
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b581                	j	4f2 <vprintf+0x44>
          s = "(null)";
 6b4:	00000497          	auipc	s1,0x0
 6b8:	2ac48493          	addi	s1,s1,684 # 960 <malloc+0x110>
        for(; *s; s++)
 6bc:	02800593          	li	a1,40
 6c0:	b7c5                	j	6a0 <vprintf+0x1f2>
        putc(fd, '%');
 6c2:	85be                	mv	a1,a5
 6c4:	855a                	mv	a0,s6
 6c6:	d2dff0ef          	jal	3f2 <putc>
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b51d                	j	4f2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6ce:	8bce                	mv	s7,s3
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b505                	j	4f2 <vprintf+0x44>
 6d4:	6906                	ld	s2,64(sp)
 6d6:	79e2                	ld	s3,56(sp)
 6d8:	7a42                	ld	s4,48(sp)
 6da:	7aa2                	ld	s5,40(sp)
 6dc:	7b02                	ld	s6,32(sp)
 6de:	6be2                	ld	s7,24(sp)
 6e0:	6c42                	ld	s8,16(sp)
    }
  }
}
 6e2:	60e6                	ld	ra,88(sp)
 6e4:	6446                	ld	s0,80(sp)
 6e6:	64a6                	ld	s1,72(sp)
 6e8:	6125                	addi	sp,sp,96
 6ea:	8082                	ret
      if(c0 == 'd'){
 6ec:	06400713          	li	a4,100
 6f0:	e4e78fe3          	beq	a5,a4,54e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6f4:	f9478693          	addi	a3,a5,-108
 6f8:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6fc:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6fe:	4701                	li	a4,0
      } else if(c0 == 'u'){
 700:	07500513          	li	a0,117
 704:	e8a78ce3          	beq	a5,a0,59c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 708:	f8b60513          	addi	a0,a2,-117
 70c:	e119                	bnez	a0,712 <vprintf+0x264>
 70e:	ea0693e3          	bnez	a3,5b4 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 712:	f8b58513          	addi	a0,a1,-117
 716:	e119                	bnez	a0,71c <vprintf+0x26e>
 718:	ea071be3          	bnez	a4,5ce <vprintf+0x120>
      } else if(c0 == 'x'){
 71c:	07800513          	li	a0,120
 720:	eca784e3          	beq	a5,a0,5e8 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 724:	f8860613          	addi	a2,a2,-120
 728:	e219                	bnez	a2,72e <vprintf+0x280>
 72a:	ec069be3          	bnez	a3,600 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 72e:	f8858593          	addi	a1,a1,-120
 732:	e199                	bnez	a1,738 <vprintf+0x28a>
 734:	ee0713e3          	bnez	a4,61a <vprintf+0x16c>
      } else if(c0 == 'p'){
 738:	07000713          	li	a4,112
 73c:	eee78ce3          	beq	a5,a4,634 <vprintf+0x186>
      } else if(c0 == 'c'){
 740:	06300713          	li	a4,99
 744:	f2e78ce3          	beq	a5,a4,67c <vprintf+0x1ce>
      } else if(c0 == 's'){
 748:	07300713          	li	a4,115
 74c:	f4e782e3          	beq	a5,a4,690 <vprintf+0x1e2>
      } else if(c0 == '%'){
 750:	02500713          	li	a4,37
 754:	f6e787e3          	beq	a5,a4,6c2 <vprintf+0x214>
        putc(fd, '%');
 758:	02500593          	li	a1,37
 75c:	855a                	mv	a0,s6
 75e:	c95ff0ef          	jal	3f2 <putc>
        putc(fd, c0);
 762:	85a6                	mv	a1,s1
 764:	855a                	mv	a0,s6
 766:	c8dff0ef          	jal	3f2 <putc>
      state = 0;
 76a:	4981                	li	s3,0
 76c:	b359                	j	4f2 <vprintf+0x44>

000000000000076e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76e:	715d                	addi	sp,sp,-80
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	e010                	sd	a2,0(s0)
 778:	e414                	sd	a3,8(s0)
 77a:	e818                	sd	a4,16(s0)
 77c:	ec1c                	sd	a5,24(s0)
 77e:	03043023          	sd	a6,32(s0)
 782:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	8622                	mv	a2,s0
 788:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 78c:	d23ff0ef          	jal	4ae <vprintf>
}
 790:	60e2                	ld	ra,24(sp)
 792:	6442                	ld	s0,16(sp)
 794:	6161                	addi	sp,sp,80
 796:	8082                	ret

0000000000000798 <printf>:

void
printf(const char *fmt, ...)
{
 798:	711d                	addi	sp,sp,-96
 79a:	ec06                	sd	ra,24(sp)
 79c:	e822                	sd	s0,16(sp)
 79e:	1000                	addi	s0,sp,32
 7a0:	e40c                	sd	a1,8(s0)
 7a2:	e810                	sd	a2,16(s0)
 7a4:	ec14                	sd	a3,24(s0)
 7a6:	f018                	sd	a4,32(s0)
 7a8:	f41c                	sd	a5,40(s0)
 7aa:	03043823          	sd	a6,48(s0)
 7ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b2:	00840613          	addi	a2,s0,8
 7b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ba:	85aa                	mv	a1,a0
 7bc:	4505                	li	a0,1
 7be:	cf1ff0ef          	jal	4ae <vprintf>
}
 7c2:	60e2                	ld	ra,24(sp)
 7c4:	6442                	ld	s0,16(sp)
 7c6:	6125                	addi	sp,sp,96
 7c8:	8082                	ret

00000000000007ca <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ca:	1141                	addi	sp,sp,-16
 7cc:	e406                	sd	ra,8(sp)
 7ce:	e022                	sd	s0,0(sp)
 7d0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	00001797          	auipc	a5,0x1
 7da:	82a7b783          	ld	a5,-2006(a5) # 1000 <freep>
 7de:	a039                	j	7ec <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	6398                	ld	a4,0(a5)
 7e2:	00e7e463          	bltu	a5,a4,7ea <free+0x20>
 7e6:	00e6ea63          	bltu	a3,a4,7fa <free+0x30>
{
 7ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ec:	fed7fae3          	bgeu	a5,a3,7e0 <free+0x16>
 7f0:	6398                	ld	a4,0(a5)
 7f2:	00e6e463          	bltu	a3,a4,7fa <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	fee7eae3          	bltu	a5,a4,7ea <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7fa:	ff852583          	lw	a1,-8(a0)
 7fe:	6390                	ld	a2,0(a5)
 800:	02059813          	slli	a6,a1,0x20
 804:	01c85713          	srli	a4,a6,0x1c
 808:	9736                	add	a4,a4,a3
 80a:	02e60563          	beq	a2,a4,834 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 80e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 812:	4790                	lw	a2,8(a5)
 814:	02061593          	slli	a1,a2,0x20
 818:	01c5d713          	srli	a4,a1,0x1c
 81c:	973e                	add	a4,a4,a5
 81e:	02e68263          	beq	a3,a4,842 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 822:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 824:	00000717          	auipc	a4,0x0
 828:	7cf73e23          	sd	a5,2012(a4) # 1000 <freep>
}
 82c:	60a2                	ld	ra,8(sp)
 82e:	6402                	ld	s0,0(sp)
 830:	0141                	addi	sp,sp,16
 832:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 834:	4618                	lw	a4,8(a2)
 836:	9f2d                	addw	a4,a4,a1
 838:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 83c:	6398                	ld	a4,0(a5)
 83e:	6310                	ld	a2,0(a4)
 840:	b7f9                	j	80e <free+0x44>
    p->s.size += bp->s.size;
 842:	ff852703          	lw	a4,-8(a0)
 846:	9f31                	addw	a4,a4,a2
 848:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 84a:	ff053683          	ld	a3,-16(a0)
 84e:	bfd1                	j	822 <free+0x58>

0000000000000850 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 850:	7139                	addi	sp,sp,-64
 852:	fc06                	sd	ra,56(sp)
 854:	f822                	sd	s0,48(sp)
 856:	f04a                	sd	s2,32(sp)
 858:	ec4e                	sd	s3,24(sp)
 85a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 85c:	02051993          	slli	s3,a0,0x20
 860:	0209d993          	srli	s3,s3,0x20
 864:	09bd                	addi	s3,s3,15
 866:	0049d993          	srli	s3,s3,0x4
 86a:	2985                	addiw	s3,s3,1
 86c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 86e:	00000517          	auipc	a0,0x0
 872:	79253503          	ld	a0,1938(a0) # 1000 <freep>
 876:	c905                	beqz	a0,8a6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 878:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87a:	4798                	lw	a4,8(a5)
 87c:	09377663          	bgeu	a4,s3,908 <malloc+0xb8>
 880:	f426                	sd	s1,40(sp)
 882:	e852                	sd	s4,16(sp)
 884:	e456                	sd	s5,8(sp)
 886:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 888:	8a4e                	mv	s4,s3
 88a:	6705                	lui	a4,0x1
 88c:	00e9f363          	bgeu	s3,a4,892 <malloc+0x42>
 890:	6a05                	lui	s4,0x1
 892:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 896:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 89a:	00000497          	auipc	s1,0x0
 89e:	76648493          	addi	s1,s1,1894 # 1000 <freep>
  if(p == SBRK_ERROR)
 8a2:	5afd                	li	s5,-1
 8a4:	a83d                	j	8e2 <malloc+0x92>
 8a6:	f426                	sd	s1,40(sp)
 8a8:	e852                	sd	s4,16(sp)
 8aa:	e456                	sd	s5,8(sp)
 8ac:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ae:	00000797          	auipc	a5,0x0
 8b2:	76278793          	addi	a5,a5,1890 # 1010 <base>
 8b6:	00000717          	auipc	a4,0x0
 8ba:	74f73523          	sd	a5,1866(a4) # 1000 <freep>
 8be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c4:	b7d1                	j	888 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8c6:	6398                	ld	a4,0(a5)
 8c8:	e118                	sd	a4,0(a0)
 8ca:	a899                	j	920 <malloc+0xd0>
  hp->s.size = nu;
 8cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d0:	0541                	addi	a0,a0,16
 8d2:	ef9ff0ef          	jal	7ca <free>
  return freep;
 8d6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8d8:	c125                	beqz	a0,938 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8dc:	4798                	lw	a4,8(a5)
 8de:	03277163          	bgeu	a4,s2,900 <malloc+0xb0>
    if(p == freep)
 8e2:	6098                	ld	a4,0(s1)
 8e4:	853e                	mv	a0,a5
 8e6:	fef71ae3          	bne	a4,a5,8da <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8ea:	8552                	mv	a0,s4
 8ec:	a13ff0ef          	jal	2fe <sbrk>
  if(p == SBRK_ERROR)
 8f0:	fd551ee3          	bne	a0,s5,8cc <malloc+0x7c>
        return 0;
 8f4:	4501                	li	a0,0
 8f6:	74a2                	ld	s1,40(sp)
 8f8:	6a42                	ld	s4,16(sp)
 8fa:	6aa2                	ld	s5,8(sp)
 8fc:	6b02                	ld	s6,0(sp)
 8fe:	a03d                	j	92c <malloc+0xdc>
 900:	74a2                	ld	s1,40(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 908:	fae90fe3          	beq	s2,a4,8c6 <malloc+0x76>
        p->s.size -= nunits;
 90c:	4137073b          	subw	a4,a4,s3
 910:	c798                	sw	a4,8(a5)
        p += p->s.size;
 912:	02071693          	slli	a3,a4,0x20
 916:	01c6d713          	srli	a4,a3,0x1c
 91a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 920:	00000717          	auipc	a4,0x0
 924:	6ea73023          	sd	a0,1760(a4) # 1000 <freep>
      return (void*)(p + 1);
 928:	01078513          	addi	a0,a5,16
  }
}
 92c:	70e2                	ld	ra,56(sp)
 92e:	7442                	ld	s0,48(sp)
 930:	7902                	ld	s2,32(sp)
 932:	69e2                	ld	s3,24(sp)
 934:	6121                	addi	sp,sp,64
 936:	8082                	ret
 938:	74a2                	ld	s1,40(sp)
 93a:	6a42                	ld	s4,16(sp)
 93c:	6aa2                	ld	s5,8(sp)
 93e:	6b02                	ld	s6,0(sp)
 940:	b7f5                	j	92c <malloc+0xdc>
