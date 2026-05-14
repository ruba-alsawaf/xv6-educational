
user/_forphan:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char buf[BUFSZ];

int
main(int argc, char **argv)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
  int fd = 0;
  char *s = argv[0];
   a:	6184                	ld	s1,0(a1)
  struct stat st;
  char *ff = "file0";
  
  if ((fd = open(ff, O_CREATE|O_WRONLY)) < 0) {
   c:	20100593          	li	a1,513
  10:	00001517          	auipc	a0,0x1
  14:	95050513          	addi	a0,a0,-1712 # 960 <malloc+0xfc>
  18:	380000ef          	jal	398 <open>
  1c:	04054463          	bltz	a0,64 <main+0x64>
    printf("%s: open failed\n", s);
    exit(1);
  }
  if(fstat(fd, &st) < 0){
  20:	fc840593          	addi	a1,s0,-56
  24:	38c000ef          	jal	3b0 <fstat>
  28:	04054863          	bltz	a0,78 <main+0x78>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
    exit(1);
  }
  if (unlink(ff) < 0) {
  2c:	00001517          	auipc	a0,0x1
  30:	93450513          	addi	a0,a0,-1740 # 960 <malloc+0xfc>
  34:	374000ef          	jal	3a8 <unlink>
  38:	04054f63          	bltz	a0,96 <main+0x96>
    printf("%s: unlink failed\n", s);
    exit(1);
  }
  if (open(ff, O_RDONLY) != -1) {
  3c:	4581                	li	a1,0
  3e:	00001517          	auipc	a0,0x1
  42:	92250513          	addi	a0,a0,-1758 # 960 <malloc+0xfc>
  46:	352000ef          	jal	398 <open>
  4a:	57fd                	li	a5,-1
  4c:	04f50f63          	beq	a0,a5,aa <main+0xaa>
    printf("%s: open successed\n", s);
  50:	85a6                	mv	a1,s1
  52:	00001517          	auipc	a0,0x1
  56:	96e50513          	addi	a0,a0,-1682 # 9c0 <malloc+0x15c>
  5a:	756000ef          	jal	7b0 <printf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	2f8000ef          	jal	358 <exit>
    printf("%s: open failed\n", s);
  64:	85a6                	mv	a1,s1
  66:	00001517          	auipc	a0,0x1
  6a:	90a50513          	addi	a0,a0,-1782 # 970 <malloc+0x10c>
  6e:	742000ef          	jal	7b0 <printf>
    exit(1);
  72:	4505                	li	a0,1
  74:	2e4000ef          	jal	358 <exit>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
  78:	00001697          	auipc	a3,0x1
  7c:	91068693          	addi	a3,a3,-1776 # 988 <malloc+0x124>
  80:	8626                	mv	a2,s1
  82:	00001597          	auipc	a1,0x1
  86:	90e58593          	addi	a1,a1,-1778 # 990 <malloc+0x12c>
  8a:	4509                	li	a0,2
  8c:	6fa000ef          	jal	786 <fprintf>
    exit(1);
  90:	4505                	li	a0,1
  92:	2c6000ef          	jal	358 <exit>
    printf("%s: unlink failed\n", s);
  96:	85a6                	mv	a1,s1
  98:	00001517          	auipc	a0,0x1
  9c:	91050513          	addi	a0,a0,-1776 # 9a8 <malloc+0x144>
  a0:	710000ef          	jal	7b0 <printf>
    exit(1);
  a4:	4505                	li	a0,1
  a6:	2b2000ef          	jal	358 <exit>
  }
  printf("wait for kill and reclaim %d\n", st.ino);
  aa:	fcc42583          	lw	a1,-52(s0)
  ae:	00001517          	auipc	a0,0x1
  b2:	92a50513          	addi	a0,a0,-1750 # 9d8 <malloc+0x174>
  b6:	6fa000ef          	jal	7b0 <printf>
  // sit around until killed
  for(;;) pause(1000);
  ba:	3e800513          	li	a0,1000
  be:	33a000ef          	jal	3f8 <pause>
  c2:	bfe5                	j	ba <main+0xba>

00000000000000c4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e406                	sd	ra,8(sp)
  c8:	e022                	sd	s0,0(sp)
  ca:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  cc:	f35ff0ef          	jal	0 <main>
  exit(r);
  d0:	288000ef          	jal	358 <exit>

00000000000000d4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  da:	87aa                	mv	a5,a0
  dc:	0585                	addi	a1,a1,1
  de:	0785                	addi	a5,a5,1
  e0:	fff5c703          	lbu	a4,-1(a1)
  e4:	fee78fa3          	sb	a4,-1(a5)
  e8:	fb75                	bnez	a4,dc <strcpy+0x8>
    ;
  return os;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb91                	beqz	a5,10e <strcmp+0x1e>
  fc:	0005c703          	lbu	a4,0(a1)
 100:	00f71763          	bne	a4,a5,10e <strcmp+0x1e>
    p++, q++;
 104:	0505                	addi	a0,a0,1
 106:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbe5                	bnez	a5,fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10e:	0005c503          	lbu	a0,0(a1)
}
 112:	40a7853b          	subw	a0,a5,a0
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cf91                	beqz	a5,142 <strlen+0x26>
 128:	0505                	addi	a0,a0,1
 12a:	87aa                	mv	a5,a0
 12c:	86be                	mv	a3,a5
 12e:	0785                	addi	a5,a5,1
 130:	fff7c703          	lbu	a4,-1(a5)
 134:	ff65                	bnez	a4,12c <strlen+0x10>
 136:	40a6853b          	subw	a0,a3,a0
 13a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret
  for(n = 0; s[n]; n++)
 142:	4501                	li	a0,0
 144:	bfe5                	j	13c <strlen+0x20>

0000000000000146 <memset>:

void*
memset(void *dst, int c, uint n)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14c:	ca19                	beqz	a2,162 <memset+0x1c>
 14e:	87aa                	mv	a5,a0
 150:	1602                	slli	a2,a2,0x20
 152:	9201                	srli	a2,a2,0x20
 154:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 158:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15c:	0785                	addi	a5,a5,1
 15e:	fee79de3          	bne	a5,a4,158 <memset+0x12>
  }
  return dst;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strchr>:

char*
strchr(const char *s, char c)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb99                	beqz	a5,188 <strchr+0x20>
    if(*s == c)
 174:	00f58763          	beq	a1,a5,182 <strchr+0x1a>
  for(; *s; s++)
 178:	0505                	addi	a0,a0,1
 17a:	00054783          	lbu	a5,0(a0)
 17e:	fbfd                	bnez	a5,174 <strchr+0xc>
      return (char*)s;
  return 0;
 180:	4501                	li	a0,0
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
  return 0;
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strchr+0x1a>

000000000000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	711d                	addi	sp,sp,-96
 18e:	ec86                	sd	ra,88(sp)
 190:	e8a2                	sd	s0,80(sp)
 192:	e4a6                	sd	s1,72(sp)
 194:	e0ca                	sd	s2,64(sp)
 196:	fc4e                	sd	s3,56(sp)
 198:	f852                	sd	s4,48(sp)
 19a:	f456                	sd	s5,40(sp)
 19c:	f05a                	sd	s6,32(sp)
 19e:	ec5e                	sd	s7,24(sp)
 1a0:	1080                	addi	s0,sp,96
 1a2:	8baa                	mv	s7,a0
 1a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a6:	892a                	mv	s2,a0
 1a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1aa:	4aa9                	li	s5,10
 1ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ae:	89a6                	mv	s3,s1
 1b0:	2485                	addiw	s1,s1,1
 1b2:	0344d663          	bge	s1,s4,1de <gets+0x52>
    cc = read(0, &c, 1);
 1b6:	4605                	li	a2,1
 1b8:	faf40593          	addi	a1,s0,-81
 1bc:	4501                	li	a0,0
 1be:	1b2000ef          	jal	370 <read>
    if(cc < 1)
 1c2:	00a05e63          	blez	a0,1de <gets+0x52>
    buf[i++] = c;
 1c6:	faf44783          	lbu	a5,-81(s0)
 1ca:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ce:	01578763          	beq	a5,s5,1dc <gets+0x50>
 1d2:	0905                	addi	s2,s2,1
 1d4:	fd679de3          	bne	a5,s6,1ae <gets+0x22>
    buf[i++] = c;
 1d8:	89a6                	mv	s3,s1
 1da:	a011                	j	1de <gets+0x52>
 1dc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1de:	99de                	add	s3,s3,s7
 1e0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e4:	855e                	mv	a0,s7
 1e6:	60e6                	ld	ra,88(sp)
 1e8:	6446                	ld	s0,80(sp)
 1ea:	64a6                	ld	s1,72(sp)
 1ec:	6906                	ld	s2,64(sp)
 1ee:	79e2                	ld	s3,56(sp)
 1f0:	7a42                	ld	s4,48(sp)
 1f2:	7aa2                	ld	s5,40(sp)
 1f4:	7b02                	ld	s6,32(sp)
 1f6:	6be2                	ld	s7,24(sp)
 1f8:	6125                	addi	sp,sp,96
 1fa:	8082                	ret

00000000000001fc <stat>:

int
stat(const char *n, struct stat *st)
{
 1fc:	1101                	addi	sp,sp,-32
 1fe:	ec06                	sd	ra,24(sp)
 200:	e822                	sd	s0,16(sp)
 202:	e04a                	sd	s2,0(sp)
 204:	1000                	addi	s0,sp,32
 206:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 208:	4581                	li	a1,0
 20a:	18e000ef          	jal	398 <open>
  if(fd < 0)
 20e:	02054263          	bltz	a0,232 <stat+0x36>
 212:	e426                	sd	s1,8(sp)
 214:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 216:	85ca                	mv	a1,s2
 218:	198000ef          	jal	3b0 <fstat>
 21c:	892a                	mv	s2,a0
  close(fd);
 21e:	8526                	mv	a0,s1
 220:	160000ef          	jal	380 <close>
  return r;
 224:	64a2                	ld	s1,8(sp)
}
 226:	854a                	mv	a0,s2
 228:	60e2                	ld	ra,24(sp)
 22a:	6442                	ld	s0,16(sp)
 22c:	6902                	ld	s2,0(sp)
 22e:	6105                	addi	sp,sp,32
 230:	8082                	ret
    return -1;
 232:	597d                	li	s2,-1
 234:	bfcd                	j	226 <stat+0x2a>

0000000000000236 <atoi>:

int
atoi(const char *s)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23c:	00054683          	lbu	a3,0(a0)
 240:	fd06879b          	addiw	a5,a3,-48
 244:	0ff7f793          	zext.b	a5,a5
 248:	4625                	li	a2,9
 24a:	02f66863          	bltu	a2,a5,27a <atoi+0x44>
 24e:	872a                	mv	a4,a0
  n = 0;
 250:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 252:	0705                	addi	a4,a4,1
 254:	0025179b          	slliw	a5,a0,0x2
 258:	9fa9                	addw	a5,a5,a0
 25a:	0017979b          	slliw	a5,a5,0x1
 25e:	9fb5                	addw	a5,a5,a3
 260:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 264:	00074683          	lbu	a3,0(a4)
 268:	fd06879b          	addiw	a5,a3,-48
 26c:	0ff7f793          	zext.b	a5,a5
 270:	fef671e3          	bgeu	a2,a5,252 <atoi+0x1c>
  return n;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
  n = 0;
 27a:	4501                	li	a0,0
 27c:	bfe5                	j	274 <atoi+0x3e>

000000000000027e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e422                	sd	s0,8(sp)
 282:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 284:	02b57463          	bgeu	a0,a1,2ac <memmove+0x2e>
    while(n-- > 0)
 288:	00c05f63          	blez	a2,2a6 <memmove+0x28>
 28c:	1602                	slli	a2,a2,0x20
 28e:	9201                	srli	a2,a2,0x20
 290:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 294:	872a                	mv	a4,a0
      *dst++ = *src++;
 296:	0585                	addi	a1,a1,1
 298:	0705                	addi	a4,a4,1
 29a:	fff5c683          	lbu	a3,-1(a1)
 29e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a2:	fef71ae3          	bne	a4,a5,296 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
    dst += n;
 2ac:	00c50733          	add	a4,a0,a2
    src += n;
 2b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b2:	fec05ae3          	blez	a2,2a6 <memmove+0x28>
 2b6:	fff6079b          	addiw	a5,a2,-1
 2ba:	1782                	slli	a5,a5,0x20
 2bc:	9381                	srli	a5,a5,0x20
 2be:	fff7c793          	not	a5,a5
 2c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c4:	15fd                	addi	a1,a1,-1
 2c6:	177d                	addi	a4,a4,-1
 2c8:	0005c683          	lbu	a3,0(a1)
 2cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d0:	fee79ae3          	bne	a5,a4,2c4 <memmove+0x46>
 2d4:	bfc9                	j	2a6 <memmove+0x28>

00000000000002d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2dc:	ca05                	beqz	a2,30c <memcmp+0x36>
 2de:	fff6069b          	addiw	a3,a2,-1
 2e2:	1682                	slli	a3,a3,0x20
 2e4:	9281                	srli	a3,a3,0x20
 2e6:	0685                	addi	a3,a3,1
 2e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	0005c703          	lbu	a4,0(a1)
 2f2:	00e79863          	bne	a5,a4,302 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f6:	0505                	addi	a0,a0,1
    p2++;
 2f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fa:	fed518e3          	bne	a0,a3,2ea <memcmp+0x14>
  }
  return 0;
 2fe:	4501                	li	a0,0
 300:	a019                	j	306 <memcmp+0x30>
      return *p1 - *p2;
 302:	40e7853b          	subw	a0,a5,a4
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  return 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <memcmp+0x30>

0000000000000310 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 318:	f67ff0ef          	jal	27e <memmove>
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <sbrk>:

char *
sbrk(int n) {
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 32c:	4585                	li	a1,1
 32e:	0c2000ef          	jal	3f0 <sys_sbrk>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <sbrklazy>:

char *
sbrklazy(int n) {
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 342:	4589                	li	a1,2
 344:	0ac000ef          	jal	3f0 <sys_sbrk>
}
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret

0000000000000350 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 350:	4885                	li	a7,1
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exit>:
.global exit
exit:
 li a7, SYS_exit
 358:	4889                	li	a7,2
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <wait>:
.global wait
wait:
 li a7, SYS_wait
 360:	488d                	li	a7,3
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 368:	4891                	li	a7,4
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <read>:
.global read
read:
 li a7, SYS_read
 370:	4895                	li	a7,5
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <write>:
.global write
write:
 li a7, SYS_write
 378:	48c1                	li	a7,16
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <close>:
.global close
close:
 li a7, SYS_close
 380:	48d5                	li	a7,21
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <kill>:
.global kill
kill:
 li a7, SYS_kill
 388:	4899                	li	a7,6
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exec>:
.global exec
exec:
 li a7, SYS_exec
 390:	489d                	li	a7,7
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <open>:
.global open
open:
 li a7, SYS_open
 398:	48bd                	li	a7,15
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a0:	48c5                	li	a7,17
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a8:	48c9                	li	a7,18
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b0:	48a1                	li	a7,8
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <link>:
.global link
link:
 li a7, SYS_link
 3b8:	48cd                	li	a7,19
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c0:	48d1                	li	a7,20
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c8:	48a5                	li	a7,9
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d0:	48a9                	li	a7,10
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d8:	48ad                	li	a7,11
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 3e0:	48e9                	li	a7,26
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 3e8:	48ed                	li	a7,27
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3f0:	48b1                	li	a7,12
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3f8:	48b5                	li	a7,13
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 400:	48b9                	li	a7,14
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <csread>:
.global csread
csread:
 li a7, SYS_csread
 408:	48d9                	li	a7,22
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 410:	48dd                	li	a7,23
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 418:	48e1                	li	a7,24
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <memread>:
.global memread
memread:
 li a7, SYS_memread
 420:	48e5                	li	a7,25
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 428:	1101                	addi	sp,sp,-32
 42a:	ec06                	sd	ra,24(sp)
 42c:	e822                	sd	s0,16(sp)
 42e:	1000                	addi	s0,sp,32
 430:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 434:	4605                	li	a2,1
 436:	fef40593          	addi	a1,s0,-17
 43a:	f3fff0ef          	jal	378 <write>
}
 43e:	60e2                	ld	ra,24(sp)
 440:	6442                	ld	s0,16(sp)
 442:	6105                	addi	sp,sp,32
 444:	8082                	ret

0000000000000446 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 446:	715d                	addi	sp,sp,-80
 448:	e486                	sd	ra,72(sp)
 44a:	e0a2                	sd	s0,64(sp)
 44c:	f84a                	sd	s2,48(sp)
 44e:	0880                	addi	s0,sp,80
 450:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 452:	c299                	beqz	a3,458 <printint+0x12>
 454:	0805c363          	bltz	a1,4da <printint+0x94>
  neg = 0;
 458:	4881                	li	a7,0
 45a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 45e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 460:	00000517          	auipc	a0,0x0
 464:	5a050513          	addi	a0,a0,1440 # a00 <digits>
 468:	883e                	mv	a6,a5
 46a:	2785                	addiw	a5,a5,1
 46c:	02c5f733          	remu	a4,a1,a2
 470:	972a                	add	a4,a4,a0
 472:	00074703          	lbu	a4,0(a4)
 476:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 47a:	872e                	mv	a4,a1
 47c:	02c5d5b3          	divu	a1,a1,a2
 480:	0685                	addi	a3,a3,1
 482:	fec773e3          	bgeu	a4,a2,468 <printint+0x22>
  if(neg)
 486:	00088b63          	beqz	a7,49c <printint+0x56>
    buf[i++] = '-';
 48a:	fd078793          	addi	a5,a5,-48
 48e:	97a2                	add	a5,a5,s0
 490:	02d00713          	li	a4,45
 494:	fee78423          	sb	a4,-24(a5)
 498:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 49c:	02f05a63          	blez	a5,4d0 <printint+0x8a>
 4a0:	fc26                	sd	s1,56(sp)
 4a2:	f44e                	sd	s3,40(sp)
 4a4:	fb840713          	addi	a4,s0,-72
 4a8:	00f704b3          	add	s1,a4,a5
 4ac:	fff70993          	addi	s3,a4,-1
 4b0:	99be                	add	s3,s3,a5
 4b2:	37fd                	addiw	a5,a5,-1
 4b4:	1782                	slli	a5,a5,0x20
 4b6:	9381                	srli	a5,a5,0x20
 4b8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4bc:	fff4c583          	lbu	a1,-1(s1)
 4c0:	854a                	mv	a0,s2
 4c2:	f67ff0ef          	jal	428 <putc>
  while(--i >= 0)
 4c6:	14fd                	addi	s1,s1,-1
 4c8:	ff349ae3          	bne	s1,s3,4bc <printint+0x76>
 4cc:	74e2                	ld	s1,56(sp)
 4ce:	79a2                	ld	s3,40(sp)
}
 4d0:	60a6                	ld	ra,72(sp)
 4d2:	6406                	ld	s0,64(sp)
 4d4:	7942                	ld	s2,48(sp)
 4d6:	6161                	addi	sp,sp,80
 4d8:	8082                	ret
    x = -xx;
 4da:	40b005b3          	neg	a1,a1
    neg = 1;
 4de:	4885                	li	a7,1
    x = -xx;
 4e0:	bfad                	j	45a <printint+0x14>

00000000000004e2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e2:	711d                	addi	sp,sp,-96
 4e4:	ec86                	sd	ra,88(sp)
 4e6:	e8a2                	sd	s0,80(sp)
 4e8:	e0ca                	sd	s2,64(sp)
 4ea:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ec:	0005c903          	lbu	s2,0(a1)
 4f0:	28090663          	beqz	s2,77c <vprintf+0x29a>
 4f4:	e4a6                	sd	s1,72(sp)
 4f6:	fc4e                	sd	s3,56(sp)
 4f8:	f852                	sd	s4,48(sp)
 4fa:	f456                	sd	s5,40(sp)
 4fc:	f05a                	sd	s6,32(sp)
 4fe:	ec5e                	sd	s7,24(sp)
 500:	e862                	sd	s8,16(sp)
 502:	e466                	sd	s9,8(sp)
 504:	8b2a                	mv	s6,a0
 506:	8a2e                	mv	s4,a1
 508:	8bb2                	mv	s7,a2
  state = 0;
 50a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 50c:	4481                	li	s1,0
 50e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 510:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 514:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 518:	06c00c93          	li	s9,108
 51c:	a005                	j	53c <vprintf+0x5a>
        putc(fd, c0);
 51e:	85ca                	mv	a1,s2
 520:	855a                	mv	a0,s6
 522:	f07ff0ef          	jal	428 <putc>
 526:	a019                	j	52c <vprintf+0x4a>
    } else if(state == '%'){
 528:	03598263          	beq	s3,s5,54c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 52c:	2485                	addiw	s1,s1,1
 52e:	8726                	mv	a4,s1
 530:	009a07b3          	add	a5,s4,s1
 534:	0007c903          	lbu	s2,0(a5)
 538:	22090a63          	beqz	s2,76c <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 53c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 540:	fe0994e3          	bnez	s3,528 <vprintf+0x46>
      if(c0 == '%'){
 544:	fd579de3          	bne	a5,s5,51e <vprintf+0x3c>
        state = '%';
 548:	89be                	mv	s3,a5
 54a:	b7cd                	j	52c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 54c:	00ea06b3          	add	a3,s4,a4
 550:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 554:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 556:	c681                	beqz	a3,55e <vprintf+0x7c>
 558:	9752                	add	a4,a4,s4
 55a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 55e:	05878363          	beq	a5,s8,5a4 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 562:	05978d63          	beq	a5,s9,5bc <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 566:	07500713          	li	a4,117
 56a:	0ee78763          	beq	a5,a4,658 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 56e:	07800713          	li	a4,120
 572:	12e78963          	beq	a5,a4,6a4 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 576:	07000713          	li	a4,112
 57a:	14e78e63          	beq	a5,a4,6d6 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 57e:	06300713          	li	a4,99
 582:	18e78e63          	beq	a5,a4,71e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 586:	07300713          	li	a4,115
 58a:	1ae78463          	beq	a5,a4,732 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 58e:	02500713          	li	a4,37
 592:	04e79563          	bne	a5,a4,5dc <vprintf+0xfa>
        putc(fd, '%');
 596:	02500593          	li	a1,37
 59a:	855a                	mv	a0,s6
 59c:	e8dff0ef          	jal	428 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	b769                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5a4:	008b8913          	addi	s2,s7,8
 5a8:	4685                	li	a3,1
 5aa:	4629                	li	a2,10
 5ac:	000ba583          	lw	a1,0(s7)
 5b0:	855a                	mv	a0,s6
 5b2:	e95ff0ef          	jal	446 <printint>
 5b6:	8bca                	mv	s7,s2
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bf8d                	j	52c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5bc:	06400793          	li	a5,100
 5c0:	02f68963          	beq	a3,a5,5f2 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5c4:	06c00793          	li	a5,108
 5c8:	04f68263          	beq	a3,a5,60c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5cc:	07500793          	li	a5,117
 5d0:	0af68063          	beq	a3,a5,670 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5d4:	07800793          	li	a5,120
 5d8:	0ef68263          	beq	a3,a5,6bc <vprintf+0x1da>
        putc(fd, '%');
 5dc:	02500593          	li	a1,37
 5e0:	855a                	mv	a0,s6
 5e2:	e47ff0ef          	jal	428 <putc>
        putc(fd, c0);
 5e6:	85ca                	mv	a1,s2
 5e8:	855a                	mv	a0,s6
 5ea:	e3fff0ef          	jal	428 <putc>
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bf35                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f2:	008b8913          	addi	s2,s7,8
 5f6:	4685                	li	a3,1
 5f8:	4629                	li	a2,10
 5fa:	000bb583          	ld	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	e47ff0ef          	jal	446 <printint>
        i += 1;
 604:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
        i += 1;
 60a:	b70d                	j	52c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 60c:	06400793          	li	a5,100
 610:	02f60763          	beq	a2,a5,63e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 614:	07500793          	li	a5,117
 618:	06f60963          	beq	a2,a5,68a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 61c:	07800793          	li	a5,120
 620:	faf61ee3          	bne	a2,a5,5dc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 624:	008b8913          	addi	s2,s7,8
 628:	4681                	li	a3,0
 62a:	4641                	li	a2,16
 62c:	000bb583          	ld	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	e15ff0ef          	jal	446 <printint>
        i += 2;
 636:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
        i += 2;
 63c:	bdc5                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63e:	008b8913          	addi	s2,s7,8
 642:	4685                	li	a3,1
 644:	4629                	li	a2,10
 646:	000bb583          	ld	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	dfbff0ef          	jal	446 <printint>
        i += 2;
 650:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
        i += 2;
 656:	bdd9                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4629                	li	a2,10
 660:	000be583          	lwu	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	de1ff0ef          	jal	446 <printint>
 66a:	8bca                	mv	s7,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	bd7d                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 670:	008b8913          	addi	s2,s7,8
 674:	4681                	li	a3,0
 676:	4629                	li	a2,10
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	dc9ff0ef          	jal	446 <printint>
        i += 1;
 682:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
        i += 1;
 688:	b555                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68a:	008b8913          	addi	s2,s7,8
 68e:	4681                	li	a3,0
 690:	4629                	li	a2,10
 692:	000bb583          	ld	a1,0(s7)
 696:	855a                	mv	a0,s6
 698:	dafff0ef          	jal	446 <printint>
        i += 2;
 69c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
        i += 2;
 6a2:	b569                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4641                	li	a2,16
 6ac:	000be583          	lwu	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	d95ff0ef          	jal	446 <printint>
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	bd8d                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4681                	li	a3,0
 6c2:	4641                	li	a2,16
 6c4:	000bb583          	ld	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	d7dff0ef          	jal	446 <printint>
        i += 1;
 6ce:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
        i += 1;
 6d4:	bda1                	j	52c <vprintf+0x4a>
 6d6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6d8:	008b8d13          	addi	s10,s7,8
 6dc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e0:	03000593          	li	a1,48
 6e4:	855a                	mv	a0,s6
 6e6:	d43ff0ef          	jal	428 <putc>
  putc(fd, 'x');
 6ea:	07800593          	li	a1,120
 6ee:	855a                	mv	a0,s6
 6f0:	d39ff0ef          	jal	428 <putc>
 6f4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f6:	00000b97          	auipc	s7,0x0
 6fa:	30ab8b93          	addi	s7,s7,778 # a00 <digits>
 6fe:	03c9d793          	srli	a5,s3,0x3c
 702:	97de                	add	a5,a5,s7
 704:	0007c583          	lbu	a1,0(a5)
 708:	855a                	mv	a0,s6
 70a:	d1fff0ef          	jal	428 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70e:	0992                	slli	s3,s3,0x4
 710:	397d                	addiw	s2,s2,-1
 712:	fe0916e3          	bnez	s2,6fe <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 716:	8bea                	mv	s7,s10
      state = 0;
 718:	4981                	li	s3,0
 71a:	6d02                	ld	s10,0(sp)
 71c:	bd01                	j	52c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 71e:	008b8913          	addi	s2,s7,8
 722:	000bc583          	lbu	a1,0(s7)
 726:	855a                	mv	a0,s6
 728:	d01ff0ef          	jal	428 <putc>
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
 730:	bbf5                	j	52c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 732:	008b8993          	addi	s3,s7,8
 736:	000bb903          	ld	s2,0(s7)
 73a:	00090f63          	beqz	s2,758 <vprintf+0x276>
        for(; *s; s++)
 73e:	00094583          	lbu	a1,0(s2)
 742:	c195                	beqz	a1,766 <vprintf+0x284>
          putc(fd, *s);
 744:	855a                	mv	a0,s6
 746:	ce3ff0ef          	jal	428 <putc>
        for(; *s; s++)
 74a:	0905                	addi	s2,s2,1
 74c:	00094583          	lbu	a1,0(s2)
 750:	f9f5                	bnez	a1,744 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 752:	8bce                	mv	s7,s3
      state = 0;
 754:	4981                	li	s3,0
 756:	bbd9                	j	52c <vprintf+0x4a>
          s = "(null)";
 758:	00000917          	auipc	s2,0x0
 75c:	2a090913          	addi	s2,s2,672 # 9f8 <malloc+0x194>
        for(; *s; s++)
 760:	02800593          	li	a1,40
 764:	b7c5                	j	744 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 766:	8bce                	mv	s7,s3
      state = 0;
 768:	4981                	li	s3,0
 76a:	b3c9                	j	52c <vprintf+0x4a>
 76c:	64a6                	ld	s1,72(sp)
 76e:	79e2                	ld	s3,56(sp)
 770:	7a42                	ld	s4,48(sp)
 772:	7aa2                	ld	s5,40(sp)
 774:	7b02                	ld	s6,32(sp)
 776:	6be2                	ld	s7,24(sp)
 778:	6c42                	ld	s8,16(sp)
 77a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 77c:	60e6                	ld	ra,88(sp)
 77e:	6446                	ld	s0,80(sp)
 780:	6906                	ld	s2,64(sp)
 782:	6125                	addi	sp,sp,96
 784:	8082                	ret

0000000000000786 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 786:	715d                	addi	sp,sp,-80
 788:	ec06                	sd	ra,24(sp)
 78a:	e822                	sd	s0,16(sp)
 78c:	1000                	addi	s0,sp,32
 78e:	e010                	sd	a2,0(s0)
 790:	e414                	sd	a3,8(s0)
 792:	e818                	sd	a4,16(s0)
 794:	ec1c                	sd	a5,24(s0)
 796:	03043023          	sd	a6,32(s0)
 79a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a2:	8622                	mv	a2,s0
 7a4:	d3fff0ef          	jal	4e2 <vprintf>
}
 7a8:	60e2                	ld	ra,24(sp)
 7aa:	6442                	ld	s0,16(sp)
 7ac:	6161                	addi	sp,sp,80
 7ae:	8082                	ret

00000000000007b0 <printf>:

void
printf(const char *fmt, ...)
{
 7b0:	711d                	addi	sp,sp,-96
 7b2:	ec06                	sd	ra,24(sp)
 7b4:	e822                	sd	s0,16(sp)
 7b6:	1000                	addi	s0,sp,32
 7b8:	e40c                	sd	a1,8(s0)
 7ba:	e810                	sd	a2,16(s0)
 7bc:	ec14                	sd	a3,24(s0)
 7be:	f018                	sd	a4,32(s0)
 7c0:	f41c                	sd	a5,40(s0)
 7c2:	03043823          	sd	a6,48(s0)
 7c6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	00840613          	addi	a2,s0,8
 7ce:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d2:	85aa                	mv	a1,a0
 7d4:	4505                	li	a0,1
 7d6:	d0dff0ef          	jal	4e2 <vprintf>
}
 7da:	60e2                	ld	ra,24(sp)
 7dc:	6442                	ld	s0,16(sp)
 7de:	6125                	addi	sp,sp,96
 7e0:	8082                	ret

00000000000007e2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e2:	1141                	addi	sp,sp,-16
 7e4:	e422                	sd	s0,8(sp)
 7e6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ec:	00001797          	auipc	a5,0x1
 7f0:	8147b783          	ld	a5,-2028(a5) # 1000 <freep>
 7f4:	a02d                	j	81e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f6:	4618                	lw	a4,8(a2)
 7f8:	9f2d                	addw	a4,a4,a1
 7fa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fe:	6398                	ld	a4,0(a5)
 800:	6310                	ld	a2,0(a4)
 802:	a83d                	j	840 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 804:	ff852703          	lw	a4,-8(a0)
 808:	9f31                	addw	a4,a4,a2
 80a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 80c:	ff053683          	ld	a3,-16(a0)
 810:	a091                	j	854 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 812:	6398                	ld	a4,0(a5)
 814:	00e7e463          	bltu	a5,a4,81c <free+0x3a>
 818:	00e6ea63          	bltu	a3,a4,82c <free+0x4a>
{
 81c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81e:	fed7fae3          	bgeu	a5,a3,812 <free+0x30>
 822:	6398                	ld	a4,0(a5)
 824:	00e6e463          	bltu	a3,a4,82c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 828:	fee7eae3          	bltu	a5,a4,81c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 82c:	ff852583          	lw	a1,-8(a0)
 830:	6390                	ld	a2,0(a5)
 832:	02059813          	slli	a6,a1,0x20
 836:	01c85713          	srli	a4,a6,0x1c
 83a:	9736                	add	a4,a4,a3
 83c:	fae60de3          	beq	a2,a4,7f6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 840:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 844:	4790                	lw	a2,8(a5)
 846:	02061593          	slli	a1,a2,0x20
 84a:	01c5d713          	srli	a4,a1,0x1c
 84e:	973e                	add	a4,a4,a5
 850:	fae68ae3          	beq	a3,a4,804 <free+0x22>
    p->s.ptr = bp->s.ptr;
 854:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 856:	00000717          	auipc	a4,0x0
 85a:	7af73523          	sd	a5,1962(a4) # 1000 <freep>
}
 85e:	6422                	ld	s0,8(sp)
 860:	0141                	addi	sp,sp,16
 862:	8082                	ret

0000000000000864 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 864:	7139                	addi	sp,sp,-64
 866:	fc06                	sd	ra,56(sp)
 868:	f822                	sd	s0,48(sp)
 86a:	f426                	sd	s1,40(sp)
 86c:	ec4e                	sd	s3,24(sp)
 86e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 870:	02051493          	slli	s1,a0,0x20
 874:	9081                	srli	s1,s1,0x20
 876:	04bd                	addi	s1,s1,15
 878:	8091                	srli	s1,s1,0x4
 87a:	0014899b          	addiw	s3,s1,1
 87e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 880:	00000517          	auipc	a0,0x0
 884:	78053503          	ld	a0,1920(a0) # 1000 <freep>
 888:	c915                	beqz	a0,8bc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88c:	4798                	lw	a4,8(a5)
 88e:	08977a63          	bgeu	a4,s1,922 <malloc+0xbe>
 892:	f04a                	sd	s2,32(sp)
 894:	e852                	sd	s4,16(sp)
 896:	e456                	sd	s5,8(sp)
 898:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 89a:	8a4e                	mv	s4,s3
 89c:	0009871b          	sext.w	a4,s3
 8a0:	6685                	lui	a3,0x1
 8a2:	00d77363          	bgeu	a4,a3,8a8 <malloc+0x44>
 8a6:	6a05                	lui	s4,0x1
 8a8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ac:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b0:	00000917          	auipc	s2,0x0
 8b4:	75090913          	addi	s2,s2,1872 # 1000 <freep>
  if(p == SBRK_ERROR)
 8b8:	5afd                	li	s5,-1
 8ba:	a081                	j	8fa <malloc+0x96>
 8bc:	f04a                	sd	s2,32(sp)
 8be:	e852                	sd	s4,16(sp)
 8c0:	e456                	sd	s5,8(sp)
 8c2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8c4:	00001797          	auipc	a5,0x1
 8c8:	94478793          	addi	a5,a5,-1724 # 1208 <base>
 8cc:	00000717          	auipc	a4,0x0
 8d0:	72f73a23          	sd	a5,1844(a4) # 1000 <freep>
 8d4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8da:	b7c1                	j	89a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8dc:	6398                	ld	a4,0(a5)
 8de:	e118                	sd	a4,0(a0)
 8e0:	a8a9                	j	93a <malloc+0xd6>
  hp->s.size = nu;
 8e2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8e6:	0541                	addi	a0,a0,16
 8e8:	efbff0ef          	jal	7e2 <free>
  return freep;
 8ec:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8f0:	c12d                	beqz	a0,952 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f4:	4798                	lw	a4,8(a5)
 8f6:	02977263          	bgeu	a4,s1,91a <malloc+0xb6>
    if(p == freep)
 8fa:	00093703          	ld	a4,0(s2)
 8fe:	853e                	mv	a0,a5
 900:	fef719e3          	bne	a4,a5,8f2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 904:	8552                	mv	a0,s4
 906:	a1fff0ef          	jal	324 <sbrk>
  if(p == SBRK_ERROR)
 90a:	fd551ce3          	bne	a0,s5,8e2 <malloc+0x7e>
        return 0;
 90e:	4501                	li	a0,0
 910:	7902                	ld	s2,32(sp)
 912:	6a42                	ld	s4,16(sp)
 914:	6aa2                	ld	s5,8(sp)
 916:	6b02                	ld	s6,0(sp)
 918:	a03d                	j	946 <malloc+0xe2>
 91a:	7902                	ld	s2,32(sp)
 91c:	6a42                	ld	s4,16(sp)
 91e:	6aa2                	ld	s5,8(sp)
 920:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 922:	fae48de3          	beq	s1,a4,8dc <malloc+0x78>
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
 94a:	74a2                	ld	s1,40(sp)
 94c:	69e2                	ld	s3,24(sp)
 94e:	6121                	addi	sp,sp,64
 950:	8082                	ret
 952:	7902                	ld	s2,32(sp)
 954:	6a42                	ld	s4,16(sp)
 956:	6aa2                	ld	s5,8(sp)
 958:	6b02                	ld	s6,0(sp)
 95a:	b7f5                	j	946 <malloc+0xe2>
