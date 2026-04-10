
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
   c:	95850513          	addi	a0,a0,-1704 # 960 <malloc+0xfc>
  10:	79c000ef          	jal	7ac <printf>
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
  28:	97c50513          	addi	a0,a0,-1668 # 9a0 <malloc+0x13c>
  2c:	780000ef          	jal	7ac <printf>
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
  44:	98050513          	addi	a0,a0,-1664 # 9c0 <malloc+0x15c>
  48:	764000ef          	jal	7ac <printf>
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
  5c:	9a850513          	addi	a0,a0,-1624 # a00 <malloc+0x19c>
  60:	74c000ef          	jal	7ac <printf>
  exit(0);
  64:	4501                	li	a0,0
  66:	2e0000ef          	jal	346 <exit>
  6a:	e426                	sd	s1,8(sp)
    printf("shrinktest: sbrk grow failed\n");
  6c:	00001517          	auipc	a0,0x1
  70:	91450513          	addi	a0,a0,-1772 # 980 <malloc+0x11c>
  74:	738000ef          	jal	7ac <printf>
    exit(1);
  78:	4505                	li	a0,1
  7a:	2cc000ef          	jal	346 <exit>
    printf("shrinktest: sbrk shrink failed\n");
  7e:	00001517          	auipc	a0,0x1
  82:	96250513          	addi	a0,a0,-1694 # 9e0 <malloc+0x17c>
  86:	726000ef          	jal	7ac <printf>
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

0000000000000406 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 406:	1101                	addi	sp,sp,-32
 408:	ec06                	sd	ra,24(sp)
 40a:	e822                	sd	s0,16(sp)
 40c:	1000                	addi	s0,sp,32
 40e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 412:	4605                	li	a2,1
 414:	fef40593          	addi	a1,s0,-17
 418:	f4fff0ef          	jal	366 <write>
}
 41c:	60e2                	ld	ra,24(sp)
 41e:	6442                	ld	s0,16(sp)
 420:	6105                	addi	sp,sp,32
 422:	8082                	ret

0000000000000424 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 424:	715d                	addi	sp,sp,-80
 426:	e486                	sd	ra,72(sp)
 428:	e0a2                	sd	s0,64(sp)
 42a:	f84a                	sd	s2,48(sp)
 42c:	f44e                	sd	s3,40(sp)
 42e:	0880                	addi	s0,sp,80
 430:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 432:	c6d1                	beqz	a3,4be <printint+0x9a>
 434:	0805d563          	bgez	a1,4be <printint+0x9a>
    neg = 1;
    x = -xx;
 438:	40b005b3          	neg	a1,a1
    neg = 1;
 43c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 43e:	fb840993          	addi	s3,s0,-72
  neg = 0;
 442:	86ce                	mv	a3,s3
  i = 0;
 444:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 446:	00000817          	auipc	a6,0x0
 44a:	5da80813          	addi	a6,a6,1498 # a20 <digits>
 44e:	88ba                	mv	a7,a4
 450:	0017051b          	addiw	a0,a4,1
 454:	872a                	mv	a4,a0
 456:	02c5f7b3          	remu	a5,a1,a2
 45a:	97c2                	add	a5,a5,a6
 45c:	0007c783          	lbu	a5,0(a5)
 460:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 464:	87ae                	mv	a5,a1
 466:	02c5d5b3          	divu	a1,a1,a2
 46a:	0685                	addi	a3,a3,1
 46c:	fec7f1e3          	bgeu	a5,a2,44e <printint+0x2a>
  if(neg)
 470:	00030c63          	beqz	t1,488 <printint+0x64>
    buf[i++] = '-';
 474:	fd050793          	addi	a5,a0,-48
 478:	00878533          	add	a0,a5,s0
 47c:	02d00793          	li	a5,45
 480:	fef50423          	sb	a5,-24(a0)
 484:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 488:	02e05563          	blez	a4,4b2 <printint+0x8e>
 48c:	fc26                	sd	s1,56(sp)
 48e:	377d                	addiw	a4,a4,-1
 490:	00e984b3          	add	s1,s3,a4
 494:	19fd                	addi	s3,s3,-1
 496:	99ba                	add	s3,s3,a4
 498:	1702                	slli	a4,a4,0x20
 49a:	9301                	srli	a4,a4,0x20
 49c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a0:	0004c583          	lbu	a1,0(s1)
 4a4:	854a                	mv	a0,s2
 4a6:	f61ff0ef          	jal	406 <putc>
  while(--i >= 0)
 4aa:	14fd                	addi	s1,s1,-1
 4ac:	ff349ae3          	bne	s1,s3,4a0 <printint+0x7c>
 4b0:	74e2                	ld	s1,56(sp)
}
 4b2:	60a6                	ld	ra,72(sp)
 4b4:	6406                	ld	s0,64(sp)
 4b6:	7942                	ld	s2,48(sp)
 4b8:	79a2                	ld	s3,40(sp)
 4ba:	6161                	addi	sp,sp,80
 4bc:	8082                	ret
  neg = 0;
 4be:	4301                	li	t1,0
 4c0:	bfbd                	j	43e <printint+0x1a>

00000000000004c2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c2:	711d                	addi	sp,sp,-96
 4c4:	ec86                	sd	ra,88(sp)
 4c6:	e8a2                	sd	s0,80(sp)
 4c8:	e4a6                	sd	s1,72(sp)
 4ca:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4cc:	0005c483          	lbu	s1,0(a1)
 4d0:	22048363          	beqz	s1,6f6 <vprintf+0x234>
 4d4:	e0ca                	sd	s2,64(sp)
 4d6:	fc4e                	sd	s3,56(sp)
 4d8:	f852                	sd	s4,48(sp)
 4da:	f456                	sd	s5,40(sp)
 4dc:	f05a                	sd	s6,32(sp)
 4de:	ec5e                	sd	s7,24(sp)
 4e0:	e862                	sd	s8,16(sp)
 4e2:	8b2a                	mv	s6,a0
 4e4:	8a2e                	mv	s4,a1
 4e6:	8bb2                	mv	s7,a2
  state = 0;
 4e8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4ea:	4901                	li	s2,0
 4ec:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4ee:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4f2:	06400c13          	li	s8,100
 4f6:	a00d                	j	518 <vprintf+0x56>
        putc(fd, c0);
 4f8:	85a6                	mv	a1,s1
 4fa:	855a                	mv	a0,s6
 4fc:	f0bff0ef          	jal	406 <putc>
 500:	a019                	j	506 <vprintf+0x44>
    } else if(state == '%'){
 502:	03598363          	beq	s3,s5,528 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 506:	0019079b          	addiw	a5,s2,1
 50a:	893e                	mv	s2,a5
 50c:	873e                	mv	a4,a5
 50e:	97d2                	add	a5,a5,s4
 510:	0007c483          	lbu	s1,0(a5)
 514:	1c048a63          	beqz	s1,6e8 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 518:	0004879b          	sext.w	a5,s1
    if(state == 0){
 51c:	fe0993e3          	bnez	s3,502 <vprintf+0x40>
      if(c0 == '%'){
 520:	fd579ce3          	bne	a5,s5,4f8 <vprintf+0x36>
        state = '%';
 524:	89be                	mv	s3,a5
 526:	b7c5                	j	506 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 528:	00ea06b3          	add	a3,s4,a4
 52c:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 530:	1c060863          	beqz	a2,700 <vprintf+0x23e>
      if(c0 == 'd'){
 534:	03878763          	beq	a5,s8,562 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 538:	f9478693          	addi	a3,a5,-108
 53c:	0016b693          	seqz	a3,a3
 540:	f9c60593          	addi	a1,a2,-100
 544:	e99d                	bnez	a1,57a <vprintf+0xb8>
 546:	ca95                	beqz	a3,57a <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 548:	008b8493          	addi	s1,s7,8
 54c:	4685                	li	a3,1
 54e:	4629                	li	a2,10
 550:	000bb583          	ld	a1,0(s7)
 554:	855a                	mv	a0,s6
 556:	ecfff0ef          	jal	424 <printint>
        i += 1;
 55a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 55c:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 55e:	4981                	li	s3,0
 560:	b75d                	j	506 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 562:	008b8493          	addi	s1,s7,8
 566:	4685                	li	a3,1
 568:	4629                	li	a2,10
 56a:	000ba583          	lw	a1,0(s7)
 56e:	855a                	mv	a0,s6
 570:	eb5ff0ef          	jal	424 <printint>
 574:	8ba6                	mv	s7,s1
      state = 0;
 576:	4981                	li	s3,0
 578:	b779                	j	506 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 57a:	9752                	add	a4,a4,s4
 57c:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 580:	f9460713          	addi	a4,a2,-108
 584:	00173713          	seqz	a4,a4
 588:	8f75                	and	a4,a4,a3
 58a:	f9c58513          	addi	a0,a1,-100
 58e:	18051363          	bnez	a0,714 <vprintf+0x252>
 592:	18070163          	beqz	a4,714 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 596:	008b8493          	addi	s1,s7,8
 59a:	4685                	li	a3,1
 59c:	4629                	li	a2,10
 59e:	000bb583          	ld	a1,0(s7)
 5a2:	855a                	mv	a0,s6
 5a4:	e81ff0ef          	jal	424 <printint>
        i += 2;
 5a8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5aa:	8ba6                	mv	s7,s1
      state = 0;
 5ac:	4981                	li	s3,0
        i += 2;
 5ae:	bfa1                	j	506 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5b0:	008b8493          	addi	s1,s7,8
 5b4:	4681                	li	a3,0
 5b6:	4629                	li	a2,10
 5b8:	000be583          	lwu	a1,0(s7)
 5bc:	855a                	mv	a0,s6
 5be:	e67ff0ef          	jal	424 <printint>
 5c2:	8ba6                	mv	s7,s1
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b781                	j	506 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c8:	008b8493          	addi	s1,s7,8
 5cc:	4681                	li	a3,0
 5ce:	4629                	li	a2,10
 5d0:	000bb583          	ld	a1,0(s7)
 5d4:	855a                	mv	a0,s6
 5d6:	e4fff0ef          	jal	424 <printint>
        i += 1;
 5da:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5dc:	8ba6                	mv	s7,s1
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b71d                	j	506 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e2:	008b8493          	addi	s1,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4629                	li	a2,10
 5ea:	000bb583          	ld	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	e35ff0ef          	jal	424 <printint>
        i += 2;
 5f4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f6:	8ba6                	mv	s7,s1
      state = 0;
 5f8:	4981                	li	s3,0
        i += 2;
 5fa:	b731                	j	506 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5fc:	008b8493          	addi	s1,s7,8
 600:	4681                	li	a3,0
 602:	4641                	li	a2,16
 604:	000be583          	lwu	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	e1bff0ef          	jal	424 <printint>
 60e:	8ba6                	mv	s7,s1
      state = 0;
 610:	4981                	li	s3,0
 612:	bdd5                	j	506 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 614:	008b8493          	addi	s1,s7,8
 618:	4681                	li	a3,0
 61a:	4641                	li	a2,16
 61c:	000bb583          	ld	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	e03ff0ef          	jal	424 <printint>
        i += 1;
 626:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 628:	8ba6                	mv	s7,s1
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bde9                	j	506 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	008b8493          	addi	s1,s7,8
 632:	4681                	li	a3,0
 634:	4641                	li	a2,16
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	de9ff0ef          	jal	424 <printint>
        i += 2;
 640:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 642:	8ba6                	mv	s7,s1
      state = 0;
 644:	4981                	li	s3,0
        i += 2;
 646:	b5c1                	j	506 <vprintf+0x44>
 648:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 64a:	008b8793          	addi	a5,s7,8
 64e:	8cbe                	mv	s9,a5
 650:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 654:	03000593          	li	a1,48
 658:	855a                	mv	a0,s6
 65a:	dadff0ef          	jal	406 <putc>
  putc(fd, 'x');
 65e:	07800593          	li	a1,120
 662:	855a                	mv	a0,s6
 664:	da3ff0ef          	jal	406 <putc>
 668:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66a:	00000b97          	auipc	s7,0x0
 66e:	3b6b8b93          	addi	s7,s7,950 # a20 <digits>
 672:	03c9d793          	srli	a5,s3,0x3c
 676:	97de                	add	a5,a5,s7
 678:	0007c583          	lbu	a1,0(a5)
 67c:	855a                	mv	a0,s6
 67e:	d89ff0ef          	jal	406 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 682:	0992                	slli	s3,s3,0x4
 684:	34fd                	addiw	s1,s1,-1
 686:	f4f5                	bnez	s1,672 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 688:	8be6                	mv	s7,s9
      state = 0;
 68a:	4981                	li	s3,0
 68c:	6ca2                	ld	s9,8(sp)
 68e:	bda5                	j	506 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 690:	008b8493          	addi	s1,s7,8
 694:	000bc583          	lbu	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	d6dff0ef          	jal	406 <putc>
 69e:	8ba6                	mv	s7,s1
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	b595                	j	506 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6a4:	008b8993          	addi	s3,s7,8
 6a8:	000bb483          	ld	s1,0(s7)
 6ac:	cc91                	beqz	s1,6c8 <vprintf+0x206>
        for(; *s; s++)
 6ae:	0004c583          	lbu	a1,0(s1)
 6b2:	c985                	beqz	a1,6e2 <vprintf+0x220>
          putc(fd, *s);
 6b4:	855a                	mv	a0,s6
 6b6:	d51ff0ef          	jal	406 <putc>
        for(; *s; s++)
 6ba:	0485                	addi	s1,s1,1
 6bc:	0004c583          	lbu	a1,0(s1)
 6c0:	f9f5                	bnez	a1,6b4 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6c2:	8bce                	mv	s7,s3
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b581                	j	506 <vprintf+0x44>
          s = "(null)";
 6c8:	00000497          	auipc	s1,0x0
 6cc:	35048493          	addi	s1,s1,848 # a18 <malloc+0x1b4>
        for(; *s; s++)
 6d0:	02800593          	li	a1,40
 6d4:	b7c5                	j	6b4 <vprintf+0x1f2>
        putc(fd, '%');
 6d6:	85be                	mv	a1,a5
 6d8:	855a                	mv	a0,s6
 6da:	d2dff0ef          	jal	406 <putc>
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	b51d                	j	506 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6e2:	8bce                	mv	s7,s3
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b505                	j	506 <vprintf+0x44>
 6e8:	6906                	ld	s2,64(sp)
 6ea:	79e2                	ld	s3,56(sp)
 6ec:	7a42                	ld	s4,48(sp)
 6ee:	7aa2                	ld	s5,40(sp)
 6f0:	7b02                	ld	s6,32(sp)
 6f2:	6be2                	ld	s7,24(sp)
 6f4:	6c42                	ld	s8,16(sp)
    }
  }
}
 6f6:	60e6                	ld	ra,88(sp)
 6f8:	6446                	ld	s0,80(sp)
 6fa:	64a6                	ld	s1,72(sp)
 6fc:	6125                	addi	sp,sp,96
 6fe:	8082                	ret
      if(c0 == 'd'){
 700:	06400713          	li	a4,100
 704:	e4e78fe3          	beq	a5,a4,562 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 708:	f9478693          	addi	a3,a5,-108
 70c:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 710:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 712:	4701                	li	a4,0
      } else if(c0 == 'u'){
 714:	07500513          	li	a0,117
 718:	e8a78ce3          	beq	a5,a0,5b0 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 71c:	f8b60513          	addi	a0,a2,-117
 720:	e119                	bnez	a0,726 <vprintf+0x264>
 722:	ea0693e3          	bnez	a3,5c8 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 726:	f8b58513          	addi	a0,a1,-117
 72a:	e119                	bnez	a0,730 <vprintf+0x26e>
 72c:	ea071be3          	bnez	a4,5e2 <vprintf+0x120>
      } else if(c0 == 'x'){
 730:	07800513          	li	a0,120
 734:	eca784e3          	beq	a5,a0,5fc <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 738:	f8860613          	addi	a2,a2,-120
 73c:	e219                	bnez	a2,742 <vprintf+0x280>
 73e:	ec069be3          	bnez	a3,614 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 742:	f8858593          	addi	a1,a1,-120
 746:	e199                	bnez	a1,74c <vprintf+0x28a>
 748:	ee0713e3          	bnez	a4,62e <vprintf+0x16c>
      } else if(c0 == 'p'){
 74c:	07000713          	li	a4,112
 750:	eee78ce3          	beq	a5,a4,648 <vprintf+0x186>
      } else if(c0 == 'c'){
 754:	06300713          	li	a4,99
 758:	f2e78ce3          	beq	a5,a4,690 <vprintf+0x1ce>
      } else if(c0 == 's'){
 75c:	07300713          	li	a4,115
 760:	f4e782e3          	beq	a5,a4,6a4 <vprintf+0x1e2>
      } else if(c0 == '%'){
 764:	02500713          	li	a4,37
 768:	f6e787e3          	beq	a5,a4,6d6 <vprintf+0x214>
        putc(fd, '%');
 76c:	02500593          	li	a1,37
 770:	855a                	mv	a0,s6
 772:	c95ff0ef          	jal	406 <putc>
        putc(fd, c0);
 776:	85a6                	mv	a1,s1
 778:	855a                	mv	a0,s6
 77a:	c8dff0ef          	jal	406 <putc>
      state = 0;
 77e:	4981                	li	s3,0
 780:	b359                	j	506 <vprintf+0x44>

0000000000000782 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 782:	715d                	addi	sp,sp,-80
 784:	ec06                	sd	ra,24(sp)
 786:	e822                	sd	s0,16(sp)
 788:	1000                	addi	s0,sp,32
 78a:	e010                	sd	a2,0(s0)
 78c:	e414                	sd	a3,8(s0)
 78e:	e818                	sd	a4,16(s0)
 790:	ec1c                	sd	a5,24(s0)
 792:	03043023          	sd	a6,32(s0)
 796:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79a:	8622                	mv	a2,s0
 79c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a0:	d23ff0ef          	jal	4c2 <vprintf>
}
 7a4:	60e2                	ld	ra,24(sp)
 7a6:	6442                	ld	s0,16(sp)
 7a8:	6161                	addi	sp,sp,80
 7aa:	8082                	ret

00000000000007ac <printf>:

void
printf(const char *fmt, ...)
{
 7ac:	711d                	addi	sp,sp,-96
 7ae:	ec06                	sd	ra,24(sp)
 7b0:	e822                	sd	s0,16(sp)
 7b2:	1000                	addi	s0,sp,32
 7b4:	e40c                	sd	a1,8(s0)
 7b6:	e810                	sd	a2,16(s0)
 7b8:	ec14                	sd	a3,24(s0)
 7ba:	f018                	sd	a4,32(s0)
 7bc:	f41c                	sd	a5,40(s0)
 7be:	03043823          	sd	a6,48(s0)
 7c2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c6:	00840613          	addi	a2,s0,8
 7ca:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ce:	85aa                	mv	a1,a0
 7d0:	4505                	li	a0,1
 7d2:	cf1ff0ef          	jal	4c2 <vprintf>
}
 7d6:	60e2                	ld	ra,24(sp)
 7d8:	6442                	ld	s0,16(sp)
 7da:	6125                	addi	sp,sp,96
 7dc:	8082                	ret

00000000000007de <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7de:	1141                	addi	sp,sp,-16
 7e0:	e406                	sd	ra,8(sp)
 7e2:	e022                	sd	s0,0(sp)
 7e4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ea:	00001797          	auipc	a5,0x1
 7ee:	8167b783          	ld	a5,-2026(a5) # 1000 <freep>
 7f2:	a039                	j	800 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f4:	6398                	ld	a4,0(a5)
 7f6:	00e7e463          	bltu	a5,a4,7fe <free+0x20>
 7fa:	00e6ea63          	bltu	a3,a4,80e <free+0x30>
{
 7fe:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 800:	fed7fae3          	bgeu	a5,a3,7f4 <free+0x16>
 804:	6398                	ld	a4,0(a5)
 806:	00e6e463          	bltu	a3,a4,80e <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80a:	fee7eae3          	bltu	a5,a4,7fe <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 80e:	ff852583          	lw	a1,-8(a0)
 812:	6390                	ld	a2,0(a5)
 814:	02059813          	slli	a6,a1,0x20
 818:	01c85713          	srli	a4,a6,0x1c
 81c:	9736                	add	a4,a4,a3
 81e:	02e60563          	beq	a2,a4,848 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 822:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 826:	4790                	lw	a2,8(a5)
 828:	02061593          	slli	a1,a2,0x20
 82c:	01c5d713          	srli	a4,a1,0x1c
 830:	973e                	add	a4,a4,a5
 832:	02e68263          	beq	a3,a4,856 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 836:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 838:	00000717          	auipc	a4,0x0
 83c:	7cf73423          	sd	a5,1992(a4) # 1000 <freep>
}
 840:	60a2                	ld	ra,8(sp)
 842:	6402                	ld	s0,0(sp)
 844:	0141                	addi	sp,sp,16
 846:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 848:	4618                	lw	a4,8(a2)
 84a:	9f2d                	addw	a4,a4,a1
 84c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 850:	6398                	ld	a4,0(a5)
 852:	6310                	ld	a2,0(a4)
 854:	b7f9                	j	822 <free+0x44>
    p->s.size += bp->s.size;
 856:	ff852703          	lw	a4,-8(a0)
 85a:	9f31                	addw	a4,a4,a2
 85c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 85e:	ff053683          	ld	a3,-16(a0)
 862:	bfd1                	j	836 <free+0x58>

0000000000000864 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 864:	7139                	addi	sp,sp,-64
 866:	fc06                	sd	ra,56(sp)
 868:	f822                	sd	s0,48(sp)
 86a:	f04a                	sd	s2,32(sp)
 86c:	ec4e                	sd	s3,24(sp)
 86e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 870:	02051993          	slli	s3,a0,0x20
 874:	0209d993          	srli	s3,s3,0x20
 878:	09bd                	addi	s3,s3,15
 87a:	0049d993          	srli	s3,s3,0x4
 87e:	2985                	addiw	s3,s3,1
 880:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 882:	00000517          	auipc	a0,0x0
 886:	77e53503          	ld	a0,1918(a0) # 1000 <freep>
 88a:	c905                	beqz	a0,8ba <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88e:	4798                	lw	a4,8(a5)
 890:	09377663          	bgeu	a4,s3,91c <malloc+0xb8>
 894:	f426                	sd	s1,40(sp)
 896:	e852                	sd	s4,16(sp)
 898:	e456                	sd	s5,8(sp)
 89a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 89c:	8a4e                	mv	s4,s3
 89e:	6705                	lui	a4,0x1
 8a0:	00e9f363          	bgeu	s3,a4,8a6 <malloc+0x42>
 8a4:	6a05                	lui	s4,0x1
 8a6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8aa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ae:	00000497          	auipc	s1,0x0
 8b2:	75248493          	addi	s1,s1,1874 # 1000 <freep>
  if(p == SBRK_ERROR)
 8b6:	5afd                	li	s5,-1
 8b8:	a83d                	j	8f6 <malloc+0x92>
 8ba:	f426                	sd	s1,40(sp)
 8bc:	e852                	sd	s4,16(sp)
 8be:	e456                	sd	s5,8(sp)
 8c0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8c2:	00000797          	auipc	a5,0x0
 8c6:	74e78793          	addi	a5,a5,1870 # 1010 <base>
 8ca:	00000717          	auipc	a4,0x0
 8ce:	72f73b23          	sd	a5,1846(a4) # 1000 <freep>
 8d2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d8:	b7d1                	j	89c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8da:	6398                	ld	a4,0(a5)
 8dc:	e118                	sd	a4,0(a0)
 8de:	a899                	j	934 <malloc+0xd0>
  hp->s.size = nu;
 8e0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8e4:	0541                	addi	a0,a0,16
 8e6:	ef9ff0ef          	jal	7de <free>
  return freep;
 8ea:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8ec:	c125                	beqz	a0,94c <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f0:	4798                	lw	a4,8(a5)
 8f2:	03277163          	bgeu	a4,s2,914 <malloc+0xb0>
    if(p == freep)
 8f6:	6098                	ld	a4,0(s1)
 8f8:	853e                	mv	a0,a5
 8fa:	fef71ae3          	bne	a4,a5,8ee <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8fe:	8552                	mv	a0,s4
 900:	a13ff0ef          	jal	312 <sbrk>
  if(p == SBRK_ERROR)
 904:	fd551ee3          	bne	a0,s5,8e0 <malloc+0x7c>
        return 0;
 908:	4501                	li	a0,0
 90a:	74a2                	ld	s1,40(sp)
 90c:	6a42                	ld	s4,16(sp)
 90e:	6aa2                	ld	s5,8(sp)
 910:	6b02                	ld	s6,0(sp)
 912:	a03d                	j	940 <malloc+0xdc>
 914:	74a2                	ld	s1,40(sp)
 916:	6a42                	ld	s4,16(sp)
 918:	6aa2                	ld	s5,8(sp)
 91a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 91c:	fae90fe3          	beq	s2,a4,8da <malloc+0x76>
        p->s.size -= nunits;
 920:	4137073b          	subw	a4,a4,s3
 924:	c798                	sw	a4,8(a5)
        p += p->s.size;
 926:	02071693          	slli	a3,a4,0x20
 92a:	01c6d713          	srli	a4,a3,0x1c
 92e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 930:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 934:	00000717          	auipc	a4,0x0
 938:	6ca73623          	sd	a0,1740(a4) # 1000 <freep>
      return (void*)(p + 1);
 93c:	01078513          	addi	a0,a5,16
  }
}
 940:	70e2                	ld	ra,56(sp)
 942:	7442                	ld	s0,48(sp)
 944:	7902                	ld	s2,32(sp)
 946:	69e2                	ld	s3,24(sp)
 948:	6121                	addi	sp,sp,64
 94a:	8082                	ret
 94c:	74a2                	ld	s1,40(sp)
 94e:	6a42                	ld	s4,16(sp)
 950:	6aa2                	ld	s5,8(sp)
 952:	6b02                	ld	s6,0(sp)
 954:	b7f5                	j	940 <malloc+0xdc>
