
user/_shrinktest:     file format elf64-littleriscv


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

  printf("shrinktest: grow by 8192\n");
   8:	00001517          	auipc	a0,0x1
   c:	96850513          	addi	a0,a0,-1688 # 970 <malloc+0xfc>
  10:	7ac000ef          	jal	7bc <printf>
  p = sbrk(8192);
  14:	6509                	lui	a0,0x2
  16:	2fc000ef          	jal	312 <sbrk>
  if(p == (char*)-1){
  1a:	57fd                	li	a5,-1
  1c:	04f50763          	beq	a0,a5,6a <main+0x6a>
  20:	e426                	sd	s1,8(sp)
  22:	84aa                	mv	s1,a0
    printf("shrinktest: sbrk grow failed\n");
    exit(1);
  }

  printf("shrinktest: touch memory\n");
  24:	00001517          	auipc	a0,0x1
  28:	98c50513          	addi	a0,a0,-1652 # 9b0 <malloc+0x13c>
  2c:	790000ef          	jal	7bc <printf>
  p[0] = 1;
  30:	4785                	li	a5,1
  32:	00f48023          	sb	a5,0(s1)
  p[4096] = 2;
  36:	6785                	lui	a5,0x1
  38:	94be                	add	s1,s1,a5
  3a:	4789                	li	a5,2
  3c:	00f48023          	sb	a5,0(s1)

  printf("shrinktest: shrink by 4096\n");
  40:	00001517          	auipc	a0,0x1
  44:	99050513          	addi	a0,a0,-1648 # 9d0 <malloc+0x15c>
  48:	774000ef          	jal	7bc <printf>
  p = sbrk(-4096);
  4c:	757d                	lui	a0,0xfffff
  4e:	2c4000ef          	jal	312 <sbrk>
  if(p == (char*)-1){
  52:	57fd                	li	a5,-1
  54:	02f50563          	beq	a0,a5,7e <main+0x7e>
    printf("shrinktest: sbrk shrink failed\n");
    exit(1);
  }

  printf("shrinktest: done\n");
  58:	00001517          	auipc	a0,0x1
  5c:	9b850513          	addi	a0,a0,-1608 # a10 <malloc+0x19c>
  60:	75c000ef          	jal	7bc <printf>
  exit(0);
  64:	4501                	li	a0,0
  66:	2e0000ef          	jal	346 <exit>
  6a:	e426                	sd	s1,8(sp)
    printf("shrinktest: sbrk grow failed\n");
  6c:	00001517          	auipc	a0,0x1
  70:	92450513          	addi	a0,a0,-1756 # 990 <malloc+0x11c>
  74:	748000ef          	jal	7bc <printf>
    exit(1);
  78:	4505                	li	a0,1
  7a:	2cc000ef          	jal	346 <exit>
    printf("shrinktest: sbrk shrink failed\n");
  7e:	00001517          	auipc	a0,0x1
  82:	97250513          	addi	a0,a0,-1678 # 9f0 <malloc+0x17c>
  86:	736000ef          	jal	7bc <printf>
    exit(1);
  8a:	4505                	li	a0,1
  8c:	2ba000ef          	jal	346 <exit>

0000000000000090 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  90:	1141                	addi	sp,sp,-16
  92:	e406                	sd	ra,8(sp)
  94:	e022                	sd	s0,0(sp)
  96:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  98:	f69ff0ef          	jal	0 <main>
  exit(r);
  9c:	2aa000ef          	jal	346 <exit>

00000000000000a0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e406                	sd	ra,8(sp)
  a4:	e022                	sd	s0,0(sp)
  a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a8:	87aa                	mv	a5,a0
  aa:	0585                	addi	a1,a1,1
  ac:	0785                	addi	a5,a5,1 # 1001 <freep+0x1>
  ae:	fff5c703          	lbu	a4,-1(a1)
  b2:	fee78fa3          	sb	a4,-1(a5)
  b6:	fb75                	bnez	a4,aa <strcpy+0xa>
    ;
  return os;
}
  b8:	60a2                	ld	ra,8(sp)
  ba:	6402                	ld	s0,0(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e406                	sd	ra,8(sp)
  c4:	e022                	sd	s0,0(sp)
  c6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb91                	beqz	a5,e0 <strcmp+0x20>
  ce:	0005c703          	lbu	a4,0(a1)
  d2:	00f71763          	bne	a4,a5,e0 <strcmp+0x20>
    p++, q++;
  d6:	0505                	addi	a0,a0,1
  d8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  da:	00054783          	lbu	a5,0(a0)
  de:	fbe5                	bnez	a5,ce <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  e0:	0005c503          	lbu	a0,0(a1)
}
  e4:	40a7853b          	subw	a0,a5,a0
  e8:	60a2                	ld	ra,8(sp)
  ea:	6402                	ld	s0,0(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e406                	sd	ra,8(sp)
  f4:	e022                	sd	s0,0(sp)
  f6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cf91                	beqz	a5,118 <strlen+0x28>
  fe:	00150793          	addi	a5,a0,1
 102:	86be                	mv	a3,a5
 104:	0785                	addi	a5,a5,1
 106:	fff7c703          	lbu	a4,-1(a5)
 10a:	ff65                	bnez	a4,102 <strlen+0x12>
 10c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 110:	60a2                	ld	ra,8(sp)
 112:	6402                	ld	s0,0(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret
  for(n = 0; s[n]; n++)
 118:	4501                	li	a0,0
 11a:	bfdd                	j	110 <strlen+0x20>

000000000000011c <memset>:

void*
memset(void *dst, int c, uint n)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 124:	ca19                	beqz	a2,13a <memset+0x1e>
 126:	87aa                	mv	a5,a0
 128:	1602                	slli	a2,a2,0x20
 12a:	9201                	srli	a2,a2,0x20
 12c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 130:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 134:	0785                	addi	a5,a5,1
 136:	fee79de3          	bne	a5,a4,130 <memset+0x14>
  }
  return dst;
}
 13a:	60a2                	ld	ra,8(sp)
 13c:	6402                	ld	s0,0(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret

0000000000000142 <strchr>:

char*
strchr(const char *s, char c)
{
 142:	1141                	addi	sp,sp,-16
 144:	e406                	sd	ra,8(sp)
 146:	e022                	sd	s0,0(sp)
 148:	0800                	addi	s0,sp,16
  for(; *s; s++)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	cf81                	beqz	a5,166 <strchr+0x24>
    if(*s == c)
 150:	00f58763          	beq	a1,a5,15e <strchr+0x1c>
  for(; *s; s++)
 154:	0505                	addi	a0,a0,1
 156:	00054783          	lbu	a5,0(a0)
 15a:	fbfd                	bnez	a5,150 <strchr+0xe>
      return (char*)s;
  return 0;
 15c:	4501                	li	a0,0
}
 15e:	60a2                	ld	ra,8(sp)
 160:	6402                	ld	s0,0(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret
  return 0;
 166:	4501                	li	a0,0
 168:	bfdd                	j	15e <strchr+0x1c>

000000000000016a <gets>:

char*
gets(char *buf, int max)
{
 16a:	711d                	addi	sp,sp,-96
 16c:	ec86                	sd	ra,88(sp)
 16e:	e8a2                	sd	s0,80(sp)
 170:	e4a6                	sd	s1,72(sp)
 172:	e0ca                	sd	s2,64(sp)
 174:	fc4e                	sd	s3,56(sp)
 176:	f852                	sd	s4,48(sp)
 178:	f456                	sd	s5,40(sp)
 17a:	f05a                	sd	s6,32(sp)
 17c:	ec5e                	sd	s7,24(sp)
 17e:	e862                	sd	s8,16(sp)
 180:	1080                	addi	s0,sp,96
 182:	8baa                	mv	s7,a0
 184:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 186:	892a                	mv	s2,a0
 188:	4481                	li	s1,0
    cc = read(0, &c, 1);
 18a:	faf40b13          	addi	s6,s0,-81
 18e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 190:	8c26                	mv	s8,s1
 192:	0014899b          	addiw	s3,s1,1
 196:	84ce                	mv	s1,s3
 198:	0349d463          	bge	s3,s4,1c0 <gets+0x56>
    cc = read(0, &c, 1);
 19c:	8656                	mv	a2,s5
 19e:	85da                	mv	a1,s6
 1a0:	4501                	li	a0,0
 1a2:	1bc000ef          	jal	35e <read>
    if(cc < 1)
 1a6:	00a05d63          	blez	a0,1c0 <gets+0x56>
      break;
    buf[i++] = c;
 1aa:	faf44783          	lbu	a5,-81(s0)
 1ae:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b2:	0905                	addi	s2,s2,1
 1b4:	ff678713          	addi	a4,a5,-10
 1b8:	c319                	beqz	a4,1be <gets+0x54>
 1ba:	17cd                	addi	a5,a5,-13
 1bc:	fbf1                	bnez	a5,190 <gets+0x26>
    buf[i++] = c;
 1be:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1c0:	9c5e                	add	s8,s8,s7
 1c2:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1c6:	855e                	mv	a0,s7
 1c8:	60e6                	ld	ra,88(sp)
 1ca:	6446                	ld	s0,80(sp)
 1cc:	64a6                	ld	s1,72(sp)
 1ce:	6906                	ld	s2,64(sp)
 1d0:	79e2                	ld	s3,56(sp)
 1d2:	7a42                	ld	s4,48(sp)
 1d4:	7aa2                	ld	s5,40(sp)
 1d6:	7b02                	ld	s6,32(sp)
 1d8:	6be2                	ld	s7,24(sp)
 1da:	6c42                	ld	s8,16(sp)
 1dc:	6125                	addi	sp,sp,96
 1de:	8082                	ret

00000000000001e0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e0:	1101                	addi	sp,sp,-32
 1e2:	ec06                	sd	ra,24(sp)
 1e4:	e822                	sd	s0,16(sp)
 1e6:	e04a                	sd	s2,0(sp)
 1e8:	1000                	addi	s0,sp,32
 1ea:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ec:	4581                	li	a1,0
 1ee:	198000ef          	jal	386 <open>
  if(fd < 0)
 1f2:	02054263          	bltz	a0,216 <stat+0x36>
 1f6:	e426                	sd	s1,8(sp)
 1f8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fa:	85ca                	mv	a1,s2
 1fc:	1a2000ef          	jal	39e <fstat>
 200:	892a                	mv	s2,a0
  close(fd);
 202:	8526                	mv	a0,s1
 204:	16a000ef          	jal	36e <close>
  return r;
 208:	64a2                	ld	s1,8(sp)
}
 20a:	854a                	mv	a0,s2
 20c:	60e2                	ld	ra,24(sp)
 20e:	6442                	ld	s0,16(sp)
 210:	6902                	ld	s2,0(sp)
 212:	6105                	addi	sp,sp,32
 214:	8082                	ret
    return -1;
 216:	57fd                	li	a5,-1
 218:	893e                	mv	s2,a5
 21a:	bfc5                	j	20a <stat+0x2a>

000000000000021c <atoi>:

int
atoi(const char *s)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e406                	sd	ra,8(sp)
 220:	e022                	sd	s0,0(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 224:	00054683          	lbu	a3,0(a0)
 228:	fd06879b          	addiw	a5,a3,-48
 22c:	0ff7f793          	zext.b	a5,a5
 230:	4625                	li	a2,9
 232:	02f66963          	bltu	a2,a5,264 <atoi+0x48>
 236:	872a                	mv	a4,a0
  n = 0;
 238:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 23a:	0705                	addi	a4,a4,1
 23c:	0025179b          	slliw	a5,a0,0x2
 240:	9fa9                	addw	a5,a5,a0
 242:	0017979b          	slliw	a5,a5,0x1
 246:	9fb5                	addw	a5,a5,a3
 248:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 24c:	00074683          	lbu	a3,0(a4)
 250:	fd06879b          	addiw	a5,a3,-48
 254:	0ff7f793          	zext.b	a5,a5
 258:	fef671e3          	bgeu	a2,a5,23a <atoi+0x1e>
  return n;
}
 25c:	60a2                	ld	ra,8(sp)
 25e:	6402                	ld	s0,0(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
  n = 0;
 264:	4501                	li	a0,0
 266:	bfdd                	j	25c <atoi+0x40>

0000000000000268 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 270:	02b57563          	bgeu	a0,a1,29a <memmove+0x32>
    while(n-- > 0)
 274:	00c05f63          	blez	a2,292 <memmove+0x2a>
 278:	1602                	slli	a2,a2,0x20
 27a:	9201                	srli	a2,a2,0x20
 27c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 280:	872a                	mv	a4,a0
      *dst++ = *src++;
 282:	0585                	addi	a1,a1,1
 284:	0705                	addi	a4,a4,1
 286:	fff5c683          	lbu	a3,-1(a1)
 28a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28e:	fee79ae3          	bne	a5,a4,282 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 292:	60a2                	ld	ra,8(sp)
 294:	6402                	ld	s0,0(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
    while(n-- > 0)
 29a:	fec05ce3          	blez	a2,292 <memmove+0x2a>
    dst += n;
 29e:	00c50733          	add	a4,a0,a2
    src += n;
 2a2:	95b2                	add	a1,a1,a2
 2a4:	fff6079b          	addiw	a5,a2,-1
 2a8:	1782                	slli	a5,a5,0x20
 2aa:	9381                	srli	a5,a5,0x20
 2ac:	fff7c793          	not	a5,a5
 2b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b2:	15fd                	addi	a1,a1,-1
 2b4:	177d                	addi	a4,a4,-1
 2b6:	0005c683          	lbu	a3,0(a1)
 2ba:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2be:	fef71ae3          	bne	a4,a5,2b2 <memmove+0x4a>
 2c2:	bfc1                	j	292 <memmove+0x2a>

00000000000002c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2cc:	c61d                	beqz	a2,2fa <memcmp+0x36>
 2ce:	1602                	slli	a2,a2,0x20
 2d0:	9201                	srli	a2,a2,0x20
 2d2:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2d6:	00054783          	lbu	a5,0(a0)
 2da:	0005c703          	lbu	a4,0(a1)
 2de:	00e79863          	bne	a5,a4,2ee <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2e2:	0505                	addi	a0,a0,1
    p2++;
 2e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e6:	fed518e3          	bne	a0,a3,2d6 <memcmp+0x12>
  }
  return 0;
 2ea:	4501                	li	a0,0
 2ec:	a019                	j	2f2 <memcmp+0x2e>
      return *p1 - *p2;
 2ee:	40e7853b          	subw	a0,a5,a4
}
 2f2:	60a2                	ld	ra,8(sp)
 2f4:	6402                	ld	s0,0(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret
  return 0;
 2fa:	4501                	li	a0,0
 2fc:	bfdd                	j	2f2 <memcmp+0x2e>

00000000000002fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 306:	f63ff0ef          	jal	268 <memmove>
}
 30a:	60a2                	ld	ra,8(sp)
 30c:	6402                	ld	s0,0(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret

0000000000000312 <sbrk>:

char *
sbrk(int n) {
 312:	1141                	addi	sp,sp,-16
 314:	e406                	sd	ra,8(sp)
 316:	e022                	sd	s0,0(sp)
 318:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 31a:	4585                	li	a1,1
 31c:	0b2000ef          	jal	3ce <sys_sbrk>
}
 320:	60a2                	ld	ra,8(sp)
 322:	6402                	ld	s0,0(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret

0000000000000328 <sbrklazy>:

char *
sbrklazy(int n) {
 328:	1141                	addi	sp,sp,-16
 32a:	e406                	sd	ra,8(sp)
 32c:	e022                	sd	s0,0(sp)
 32e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 330:	4589                	li	a1,2
 332:	09c000ef          	jal	3ce <sys_sbrk>
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 33e:	4885                	li	a7,1
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <exit>:
.global exit
exit:
 li a7, SYS_exit
 346:	4889                	li	a7,2
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <wait>:
.global wait
wait:
 li a7, SYS_wait
 34e:	488d                	li	a7,3
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 356:	4891                	li	a7,4
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <read>:
.global read
read:
 li a7, SYS_read
 35e:	4895                	li	a7,5
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <write>:
.global write
write:
 li a7, SYS_write
 366:	48c1                	li	a7,16
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <close>:
.global close
close:
 li a7, SYS_close
 36e:	48d5                	li	a7,21
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <kill>:
.global kill
kill:
 li a7, SYS_kill
 376:	4899                	li	a7,6
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <exec>:
.global exec
exec:
 li a7, SYS_exec
 37e:	489d                	li	a7,7
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <open>:
.global open
open:
 li a7, SYS_open
 386:	48bd                	li	a7,15
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 38e:	48c5                	li	a7,17
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 396:	48c9                	li	a7,18
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 39e:	48a1                	li	a7,8
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <link>:
.global link
link:
 li a7, SYS_link
 3a6:	48cd                	li	a7,19
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ae:	48d1                	li	a7,20
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b6:	48a5                	li	a7,9
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <dup>:
.global dup
dup:
 li a7, SYS_dup
 3be:	48a9                	li	a7,10
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c6:	48ad                	li	a7,11
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3ce:	48b1                	li	a7,12
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3d6:	48b5                	li	a7,13
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3de:	48b9                	li	a7,14
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <csread>:
.global csread
csread:
 li a7, SYS_csread
 3e6:	48d9                	li	a7,22
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 3ee:	48dd                	li	a7,23
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 3f6:	48e1                	li	a7,24
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <memread>:
.global memread
memread:
 li a7, SYS_memread
 3fe:	48e5                	li	a7,25
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 406:	48e9                	li	a7,26
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 40e:	48ed                	li	a7,27
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 416:	1101                	addi	sp,sp,-32
 418:	ec06                	sd	ra,24(sp)
 41a:	e822                	sd	s0,16(sp)
 41c:	1000                	addi	s0,sp,32
 41e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 422:	4605                	li	a2,1
 424:	fef40593          	addi	a1,s0,-17
 428:	f3fff0ef          	jal	366 <write>
}
 42c:	60e2                	ld	ra,24(sp)
 42e:	6442                	ld	s0,16(sp)
 430:	6105                	addi	sp,sp,32
 432:	8082                	ret

0000000000000434 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 434:	715d                	addi	sp,sp,-80
 436:	e486                	sd	ra,72(sp)
 438:	e0a2                	sd	s0,64(sp)
 43a:	f84a                	sd	s2,48(sp)
 43c:	f44e                	sd	s3,40(sp)
 43e:	0880                	addi	s0,sp,80
 440:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 442:	c6d1                	beqz	a3,4ce <printint+0x9a>
 444:	0805d563          	bgez	a1,4ce <printint+0x9a>
    neg = 1;
    x = -xx;
 448:	40b005b3          	neg	a1,a1
    neg = 1;
 44c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 44e:	fb840993          	addi	s3,s0,-72
  neg = 0;
 452:	86ce                	mv	a3,s3
  i = 0;
 454:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 456:	00000817          	auipc	a6,0x0
 45a:	5da80813          	addi	a6,a6,1498 # a30 <digits>
 45e:	88ba                	mv	a7,a4
 460:	0017051b          	addiw	a0,a4,1
 464:	872a                	mv	a4,a0
 466:	02c5f7b3          	remu	a5,a1,a2
 46a:	97c2                	add	a5,a5,a6
 46c:	0007c783          	lbu	a5,0(a5)
 470:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 474:	87ae                	mv	a5,a1
 476:	02c5d5b3          	divu	a1,a1,a2
 47a:	0685                	addi	a3,a3,1
 47c:	fec7f1e3          	bgeu	a5,a2,45e <printint+0x2a>
  if(neg)
 480:	00030c63          	beqz	t1,498 <printint+0x64>
    buf[i++] = '-';
 484:	fd050793          	addi	a5,a0,-48
 488:	00878533          	add	a0,a5,s0
 48c:	02d00793          	li	a5,45
 490:	fef50423          	sb	a5,-24(a0)
 494:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 498:	02e05563          	blez	a4,4c2 <printint+0x8e>
 49c:	fc26                	sd	s1,56(sp)
 49e:	377d                	addiw	a4,a4,-1
 4a0:	00e984b3          	add	s1,s3,a4
 4a4:	19fd                	addi	s3,s3,-1
 4a6:	99ba                	add	s3,s3,a4
 4a8:	1702                	slli	a4,a4,0x20
 4aa:	9301                	srli	a4,a4,0x20
 4ac:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b0:	0004c583          	lbu	a1,0(s1)
 4b4:	854a                	mv	a0,s2
 4b6:	f61ff0ef          	jal	416 <putc>
  while(--i >= 0)
 4ba:	14fd                	addi	s1,s1,-1
 4bc:	ff349ae3          	bne	s1,s3,4b0 <printint+0x7c>
 4c0:	74e2                	ld	s1,56(sp)
}
 4c2:	60a6                	ld	ra,72(sp)
 4c4:	6406                	ld	s0,64(sp)
 4c6:	7942                	ld	s2,48(sp)
 4c8:	79a2                	ld	s3,40(sp)
 4ca:	6161                	addi	sp,sp,80
 4cc:	8082                	ret
  neg = 0;
 4ce:	4301                	li	t1,0
 4d0:	bfbd                	j	44e <printint+0x1a>

00000000000004d2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d2:	711d                	addi	sp,sp,-96
 4d4:	ec86                	sd	ra,88(sp)
 4d6:	e8a2                	sd	s0,80(sp)
 4d8:	e4a6                	sd	s1,72(sp)
 4da:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4dc:	0005c483          	lbu	s1,0(a1)
 4e0:	22048363          	beqz	s1,706 <vprintf+0x234>
 4e4:	e0ca                	sd	s2,64(sp)
 4e6:	fc4e                	sd	s3,56(sp)
 4e8:	f852                	sd	s4,48(sp)
 4ea:	f456                	sd	s5,40(sp)
 4ec:	f05a                	sd	s6,32(sp)
 4ee:	ec5e                	sd	s7,24(sp)
 4f0:	e862                	sd	s8,16(sp)
 4f2:	8b2a                	mv	s6,a0
 4f4:	8a2e                	mv	s4,a1
 4f6:	8bb2                	mv	s7,a2
  state = 0;
 4f8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4fa:	4901                	li	s2,0
 4fc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4fe:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 502:	06400c13          	li	s8,100
 506:	a00d                	j	528 <vprintf+0x56>
        putc(fd, c0);
 508:	85a6                	mv	a1,s1
 50a:	855a                	mv	a0,s6
 50c:	f0bff0ef          	jal	416 <putc>
 510:	a019                	j	516 <vprintf+0x44>
    } else if(state == '%'){
 512:	03598363          	beq	s3,s5,538 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 516:	0019079b          	addiw	a5,s2,1
 51a:	893e                	mv	s2,a5
 51c:	873e                	mv	a4,a5
 51e:	97d2                	add	a5,a5,s4
 520:	0007c483          	lbu	s1,0(a5)
 524:	1c048a63          	beqz	s1,6f8 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 528:	0004879b          	sext.w	a5,s1
    if(state == 0){
 52c:	fe0993e3          	bnez	s3,512 <vprintf+0x40>
      if(c0 == '%'){
 530:	fd579ce3          	bne	a5,s5,508 <vprintf+0x36>
        state = '%';
 534:	89be                	mv	s3,a5
 536:	b7c5                	j	516 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 538:	00ea06b3          	add	a3,s4,a4
 53c:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 540:	1c060863          	beqz	a2,710 <vprintf+0x23e>
      if(c0 == 'd'){
 544:	03878763          	beq	a5,s8,572 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 548:	f9478693          	addi	a3,a5,-108
 54c:	0016b693          	seqz	a3,a3
 550:	f9c60593          	addi	a1,a2,-100
 554:	e99d                	bnez	a1,58a <vprintf+0xb8>
 556:	ca95                	beqz	a3,58a <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 558:	008b8493          	addi	s1,s7,8
 55c:	4685                	li	a3,1
 55e:	4629                	li	a2,10
 560:	000bb583          	ld	a1,0(s7)
 564:	855a                	mv	a0,s6
 566:	ecfff0ef          	jal	434 <printint>
        i += 1;
 56a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 56c:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 56e:	4981                	li	s3,0
 570:	b75d                	j	516 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 572:	008b8493          	addi	s1,s7,8
 576:	4685                	li	a3,1
 578:	4629                	li	a2,10
 57a:	000ba583          	lw	a1,0(s7)
 57e:	855a                	mv	a0,s6
 580:	eb5ff0ef          	jal	434 <printint>
 584:	8ba6                	mv	s7,s1
      state = 0;
 586:	4981                	li	s3,0
 588:	b779                	j	516 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 58a:	9752                	add	a4,a4,s4
 58c:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 590:	f9460713          	addi	a4,a2,-108
 594:	00173713          	seqz	a4,a4
 598:	8f75                	and	a4,a4,a3
 59a:	f9c58513          	addi	a0,a1,-100
 59e:	18051363          	bnez	a0,724 <vprintf+0x252>
 5a2:	18070163          	beqz	a4,724 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a6:	008b8493          	addi	s1,s7,8
 5aa:	4685                	li	a3,1
 5ac:	4629                	li	a2,10
 5ae:	000bb583          	ld	a1,0(s7)
 5b2:	855a                	mv	a0,s6
 5b4:	e81ff0ef          	jal	434 <printint>
        i += 2;
 5b8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ba:	8ba6                	mv	s7,s1
      state = 0;
 5bc:	4981                	li	s3,0
        i += 2;
 5be:	bfa1                	j	516 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5c0:	008b8493          	addi	s1,s7,8
 5c4:	4681                	li	a3,0
 5c6:	4629                	li	a2,10
 5c8:	000be583          	lwu	a1,0(s7)
 5cc:	855a                	mv	a0,s6
 5ce:	e67ff0ef          	jal	434 <printint>
 5d2:	8ba6                	mv	s7,s1
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	b781                	j	516 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d8:	008b8493          	addi	s1,s7,8
 5dc:	4681                	li	a3,0
 5de:	4629                	li	a2,10
 5e0:	000bb583          	ld	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	e4fff0ef          	jal	434 <printint>
        i += 1;
 5ea:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ec:	8ba6                	mv	s7,s1
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b71d                	j	516 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f2:	008b8493          	addi	s1,s7,8
 5f6:	4681                	li	a3,0
 5f8:	4629                	li	a2,10
 5fa:	000bb583          	ld	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	e35ff0ef          	jal	434 <printint>
        i += 2;
 604:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 606:	8ba6                	mv	s7,s1
      state = 0;
 608:	4981                	li	s3,0
        i += 2;
 60a:	b731                	j	516 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 60c:	008b8493          	addi	s1,s7,8
 610:	4681                	li	a3,0
 612:	4641                	li	a2,16
 614:	000be583          	lwu	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	e1bff0ef          	jal	434 <printint>
 61e:	8ba6                	mv	s7,s1
      state = 0;
 620:	4981                	li	s3,0
 622:	bdd5                	j	516 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 624:	008b8493          	addi	s1,s7,8
 628:	4681                	li	a3,0
 62a:	4641                	li	a2,16
 62c:	000bb583          	ld	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	e03ff0ef          	jal	434 <printint>
        i += 1;
 636:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 638:	8ba6                	mv	s7,s1
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bde9                	j	516 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 63e:	008b8493          	addi	s1,s7,8
 642:	4681                	li	a3,0
 644:	4641                	li	a2,16
 646:	000bb583          	ld	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	de9ff0ef          	jal	434 <printint>
        i += 2;
 650:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 652:	8ba6                	mv	s7,s1
      state = 0;
 654:	4981                	li	s3,0
        i += 2;
 656:	b5c1                	j	516 <vprintf+0x44>
 658:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 65a:	008b8793          	addi	a5,s7,8
 65e:	8cbe                	mv	s9,a5
 660:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 664:	03000593          	li	a1,48
 668:	855a                	mv	a0,s6
 66a:	dadff0ef          	jal	416 <putc>
  putc(fd, 'x');
 66e:	07800593          	li	a1,120
 672:	855a                	mv	a0,s6
 674:	da3ff0ef          	jal	416 <putc>
 678:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67a:	00000b97          	auipc	s7,0x0
 67e:	3b6b8b93          	addi	s7,s7,950 # a30 <digits>
 682:	03c9d793          	srli	a5,s3,0x3c
 686:	97de                	add	a5,a5,s7
 688:	0007c583          	lbu	a1,0(a5)
 68c:	855a                	mv	a0,s6
 68e:	d89ff0ef          	jal	416 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 692:	0992                	slli	s3,s3,0x4
 694:	34fd                	addiw	s1,s1,-1
 696:	f4f5                	bnez	s1,682 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 698:	8be6                	mv	s7,s9
      state = 0;
 69a:	4981                	li	s3,0
 69c:	6ca2                	ld	s9,8(sp)
 69e:	bda5                	j	516 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6a0:	008b8493          	addi	s1,s7,8
 6a4:	000bc583          	lbu	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	d6dff0ef          	jal	416 <putc>
 6ae:	8ba6                	mv	s7,s1
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b595                	j	516 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6b4:	008b8993          	addi	s3,s7,8
 6b8:	000bb483          	ld	s1,0(s7)
 6bc:	cc91                	beqz	s1,6d8 <vprintf+0x206>
        for(; *s; s++)
 6be:	0004c583          	lbu	a1,0(s1)
 6c2:	c985                	beqz	a1,6f2 <vprintf+0x220>
          putc(fd, *s);
 6c4:	855a                	mv	a0,s6
 6c6:	d51ff0ef          	jal	416 <putc>
        for(; *s; s++)
 6ca:	0485                	addi	s1,s1,1
 6cc:	0004c583          	lbu	a1,0(s1)
 6d0:	f9f5                	bnez	a1,6c4 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6d2:	8bce                	mv	s7,s3
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b581                	j	516 <vprintf+0x44>
          s = "(null)";
 6d8:	00000497          	auipc	s1,0x0
 6dc:	35048493          	addi	s1,s1,848 # a28 <malloc+0x1b4>
        for(; *s; s++)
 6e0:	02800593          	li	a1,40
 6e4:	b7c5                	j	6c4 <vprintf+0x1f2>
        putc(fd, '%');
 6e6:	85be                	mv	a1,a5
 6e8:	855a                	mv	a0,s6
 6ea:	d2dff0ef          	jal	416 <putc>
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b51d                	j	516 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6f2:	8bce                	mv	s7,s3
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	b505                	j	516 <vprintf+0x44>
 6f8:	6906                	ld	s2,64(sp)
 6fa:	79e2                	ld	s3,56(sp)
 6fc:	7a42                	ld	s4,48(sp)
 6fe:	7aa2                	ld	s5,40(sp)
 700:	7b02                	ld	s6,32(sp)
 702:	6be2                	ld	s7,24(sp)
 704:	6c42                	ld	s8,16(sp)
    }
  }
}
 706:	60e6                	ld	ra,88(sp)
 708:	6446                	ld	s0,80(sp)
 70a:	64a6                	ld	s1,72(sp)
 70c:	6125                	addi	sp,sp,96
 70e:	8082                	ret
      if(c0 == 'd'){
 710:	06400713          	li	a4,100
 714:	e4e78fe3          	beq	a5,a4,572 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 718:	f9478693          	addi	a3,a5,-108
 71c:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 720:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 722:	4701                	li	a4,0
      } else if(c0 == 'u'){
 724:	07500513          	li	a0,117
 728:	e8a78ce3          	beq	a5,a0,5c0 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 72c:	f8b60513          	addi	a0,a2,-117
 730:	e119                	bnez	a0,736 <vprintf+0x264>
 732:	ea0693e3          	bnez	a3,5d8 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 736:	f8b58513          	addi	a0,a1,-117
 73a:	e119                	bnez	a0,740 <vprintf+0x26e>
 73c:	ea071be3          	bnez	a4,5f2 <vprintf+0x120>
      } else if(c0 == 'x'){
 740:	07800513          	li	a0,120
 744:	eca784e3          	beq	a5,a0,60c <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 748:	f8860613          	addi	a2,a2,-120
 74c:	e219                	bnez	a2,752 <vprintf+0x280>
 74e:	ec069be3          	bnez	a3,624 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 752:	f8858593          	addi	a1,a1,-120
 756:	e199                	bnez	a1,75c <vprintf+0x28a>
 758:	ee0713e3          	bnez	a4,63e <vprintf+0x16c>
      } else if(c0 == 'p'){
 75c:	07000713          	li	a4,112
 760:	eee78ce3          	beq	a5,a4,658 <vprintf+0x186>
      } else if(c0 == 'c'){
 764:	06300713          	li	a4,99
 768:	f2e78ce3          	beq	a5,a4,6a0 <vprintf+0x1ce>
      } else if(c0 == 's'){
 76c:	07300713          	li	a4,115
 770:	f4e782e3          	beq	a5,a4,6b4 <vprintf+0x1e2>
      } else if(c0 == '%'){
 774:	02500713          	li	a4,37
 778:	f6e787e3          	beq	a5,a4,6e6 <vprintf+0x214>
        putc(fd, '%');
 77c:	02500593          	li	a1,37
 780:	855a                	mv	a0,s6
 782:	c95ff0ef          	jal	416 <putc>
        putc(fd, c0);
 786:	85a6                	mv	a1,s1
 788:	855a                	mv	a0,s6
 78a:	c8dff0ef          	jal	416 <putc>
      state = 0;
 78e:	4981                	li	s3,0
 790:	b359                	j	516 <vprintf+0x44>

0000000000000792 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 792:	715d                	addi	sp,sp,-80
 794:	ec06                	sd	ra,24(sp)
 796:	e822                	sd	s0,16(sp)
 798:	1000                	addi	s0,sp,32
 79a:	e010                	sd	a2,0(s0)
 79c:	e414                	sd	a3,8(s0)
 79e:	e818                	sd	a4,16(s0)
 7a0:	ec1c                	sd	a5,24(s0)
 7a2:	03043023          	sd	a6,32(s0)
 7a6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7aa:	8622                	mv	a2,s0
 7ac:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b0:	d23ff0ef          	jal	4d2 <vprintf>
}
 7b4:	60e2                	ld	ra,24(sp)
 7b6:	6442                	ld	s0,16(sp)
 7b8:	6161                	addi	sp,sp,80
 7ba:	8082                	ret

00000000000007bc <printf>:

void
printf(const char *fmt, ...)
{
 7bc:	711d                	addi	sp,sp,-96
 7be:	ec06                	sd	ra,24(sp)
 7c0:	e822                	sd	s0,16(sp)
 7c2:	1000                	addi	s0,sp,32
 7c4:	e40c                	sd	a1,8(s0)
 7c6:	e810                	sd	a2,16(s0)
 7c8:	ec14                	sd	a3,24(s0)
 7ca:	f018                	sd	a4,32(s0)
 7cc:	f41c                	sd	a5,40(s0)
 7ce:	03043823          	sd	a6,48(s0)
 7d2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d6:	00840613          	addi	a2,s0,8
 7da:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7de:	85aa                	mv	a1,a0
 7e0:	4505                	li	a0,1
 7e2:	cf1ff0ef          	jal	4d2 <vprintf>
}
 7e6:	60e2                	ld	ra,24(sp)
 7e8:	6442                	ld	s0,16(sp)
 7ea:	6125                	addi	sp,sp,96
 7ec:	8082                	ret

00000000000007ee <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ee:	1141                	addi	sp,sp,-16
 7f0:	e406                	sd	ra,8(sp)
 7f2:	e022                	sd	s0,0(sp)
 7f4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fa:	00001797          	auipc	a5,0x1
 7fe:	8067b783          	ld	a5,-2042(a5) # 1000 <freep>
 802:	a039                	j	810 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 804:	6398                	ld	a4,0(a5)
 806:	00e7e463          	bltu	a5,a4,80e <free+0x20>
 80a:	00e6ea63          	bltu	a3,a4,81e <free+0x30>
{
 80e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 810:	fed7fae3          	bgeu	a5,a3,804 <free+0x16>
 814:	6398                	ld	a4,0(a5)
 816:	00e6e463          	bltu	a3,a4,81e <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81a:	fee7eae3          	bltu	a5,a4,80e <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 81e:	ff852583          	lw	a1,-8(a0)
 822:	6390                	ld	a2,0(a5)
 824:	02059813          	slli	a6,a1,0x20
 828:	01c85713          	srli	a4,a6,0x1c
 82c:	9736                	add	a4,a4,a3
 82e:	02e60563          	beq	a2,a4,858 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 832:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 836:	4790                	lw	a2,8(a5)
 838:	02061593          	slli	a1,a2,0x20
 83c:	01c5d713          	srli	a4,a1,0x1c
 840:	973e                	add	a4,a4,a5
 842:	02e68263          	beq	a3,a4,866 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 846:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 848:	00000717          	auipc	a4,0x0
 84c:	7af73c23          	sd	a5,1976(a4) # 1000 <freep>
}
 850:	60a2                	ld	ra,8(sp)
 852:	6402                	ld	s0,0(sp)
 854:	0141                	addi	sp,sp,16
 856:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 858:	4618                	lw	a4,8(a2)
 85a:	9f2d                	addw	a4,a4,a1
 85c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 860:	6398                	ld	a4,0(a5)
 862:	6310                	ld	a2,0(a4)
 864:	b7f9                	j	832 <free+0x44>
    p->s.size += bp->s.size;
 866:	ff852703          	lw	a4,-8(a0)
 86a:	9f31                	addw	a4,a4,a2
 86c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 86e:	ff053683          	ld	a3,-16(a0)
 872:	bfd1                	j	846 <free+0x58>

0000000000000874 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 874:	7139                	addi	sp,sp,-64
 876:	fc06                	sd	ra,56(sp)
 878:	f822                	sd	s0,48(sp)
 87a:	f04a                	sd	s2,32(sp)
 87c:	ec4e                	sd	s3,24(sp)
 87e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 880:	02051993          	slli	s3,a0,0x20
 884:	0209d993          	srli	s3,s3,0x20
 888:	09bd                	addi	s3,s3,15
 88a:	0049d993          	srli	s3,s3,0x4
 88e:	2985                	addiw	s3,s3,1
 890:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 892:	00000517          	auipc	a0,0x0
 896:	76e53503          	ld	a0,1902(a0) # 1000 <freep>
 89a:	c905                	beqz	a0,8ca <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89e:	4798                	lw	a4,8(a5)
 8a0:	09377663          	bgeu	a4,s3,92c <malloc+0xb8>
 8a4:	f426                	sd	s1,40(sp)
 8a6:	e852                	sd	s4,16(sp)
 8a8:	e456                	sd	s5,8(sp)
 8aa:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8ac:	8a4e                	mv	s4,s3
 8ae:	6705                	lui	a4,0x1
 8b0:	00e9f363          	bgeu	s3,a4,8b6 <malloc+0x42>
 8b4:	6a05                	lui	s4,0x1
 8b6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ba:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8be:	00000497          	auipc	s1,0x0
 8c2:	74248493          	addi	s1,s1,1858 # 1000 <freep>
  if(p == SBRK_ERROR)
 8c6:	5afd                	li	s5,-1
 8c8:	a83d                	j	906 <malloc+0x92>
 8ca:	f426                	sd	s1,40(sp)
 8cc:	e852                	sd	s4,16(sp)
 8ce:	e456                	sd	s5,8(sp)
 8d0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8d2:	00000797          	auipc	a5,0x0
 8d6:	73e78793          	addi	a5,a5,1854 # 1010 <base>
 8da:	00000717          	auipc	a4,0x0
 8de:	72f73323          	sd	a5,1830(a4) # 1000 <freep>
 8e2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e8:	b7d1                	j	8ac <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8ea:	6398                	ld	a4,0(a5)
 8ec:	e118                	sd	a4,0(a0)
 8ee:	a899                	j	944 <malloc+0xd0>
  hp->s.size = nu;
 8f0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f4:	0541                	addi	a0,a0,16
 8f6:	ef9ff0ef          	jal	7ee <free>
  return freep;
 8fa:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8fc:	c125                	beqz	a0,95c <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 900:	4798                	lw	a4,8(a5)
 902:	03277163          	bgeu	a4,s2,924 <malloc+0xb0>
    if(p == freep)
 906:	6098                	ld	a4,0(s1)
 908:	853e                	mv	a0,a5
 90a:	fef71ae3          	bne	a4,a5,8fe <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 90e:	8552                	mv	a0,s4
 910:	a03ff0ef          	jal	312 <sbrk>
  if(p == SBRK_ERROR)
 914:	fd551ee3          	bne	a0,s5,8f0 <malloc+0x7c>
        return 0;
 918:	4501                	li	a0,0
 91a:	74a2                	ld	s1,40(sp)
 91c:	6a42                	ld	s4,16(sp)
 91e:	6aa2                	ld	s5,8(sp)
 920:	6b02                	ld	s6,0(sp)
 922:	a03d                	j	950 <malloc+0xdc>
 924:	74a2                	ld	s1,40(sp)
 926:	6a42                	ld	s4,16(sp)
 928:	6aa2                	ld	s5,8(sp)
 92a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 92c:	fae90fe3          	beq	s2,a4,8ea <malloc+0x76>
        p->s.size -= nunits;
 930:	4137073b          	subw	a4,a4,s3
 934:	c798                	sw	a4,8(a5)
        p += p->s.size;
 936:	02071693          	slli	a3,a4,0x20
 93a:	01c6d713          	srli	a4,a3,0x1c
 93e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 940:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 944:	00000717          	auipc	a4,0x0
 948:	6aa73e23          	sd	a0,1724(a4) # 1000 <freep>
      return (void*)(p + 1);
 94c:	01078513          	addi	a0,a5,16
  }
}
 950:	70e2                	ld	ra,56(sp)
 952:	7442                	ld	s0,48(sp)
 954:	7902                	ld	s2,32(sp)
 956:	69e2                	ld	s3,24(sp)
 958:	6121                	addi	sp,sp,64
 95a:	8082                	ret
 95c:	74a2                	ld	s1,40(sp)
 95e:	6a42                	ld	s4,16(sp)
 960:	6aa2                	ld	s5,8(sp)
 962:	6b02                	ld	s6,0(sp)
 964:	b7f5                	j	950 <malloc+0xdc>
