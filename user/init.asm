
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	95250513          	addi	a0,a0,-1710 # 960 <malloc+0x104>
  16:	37a000ef          	jal	390 <open>
  1a:	04054563          	bltz	a0,64 <main+0x64>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  1e:	4501                	li	a0,0
  20:	3a8000ef          	jal	3c8 <dup>
  dup(0);  // stderr
  24:	4501                	li	a0,0
  26:	3a2000ef          	jal	3c8 <dup>



  for(;;){
    printf("init: starting sh\n");
  2a:	00001917          	auipc	s2,0x1
  2e:	93e90913          	addi	s2,s2,-1730 # 968 <malloc+0x10c>
  32:	854a                	mv	a0,s2
  34:	774000ef          	jal	7a8 <printf>
    pid = fork();
  38:	310000ef          	jal	348 <fork>
  3c:	84aa                	mv	s1,a0
    if(pid < 0){
  3e:	04054363          	bltz	a0,84 <main+0x84>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  42:	c931                	beqz	a0,96 <main+0x96>
      printf("init: exec sh failed\n");
      exit(1);
    }

    for(;;){
      wpid = wait((int *) 0);
  44:	4501                	li	a0,0
  46:	312000ef          	jal	358 <wait>
      if(wpid == pid){
  4a:	fea484e3          	beq	s1,a0,32 <main+0x32>
        break;
      } else if(wpid < 0){
  4e:	fe055be3          	bgez	a0,44 <main+0x44>
        printf("init: wait returned an error\n");
  52:	00001517          	auipc	a0,0x1
  56:	96650513          	addi	a0,a0,-1690 # 9b8 <malloc+0x15c>
  5a:	74e000ef          	jal	7a8 <printf>
        exit(1);
  5e:	4505                	li	a0,1
  60:	2f0000ef          	jal	350 <exit>
    mknod("console", CONSOLE, 0);
  64:	4601                	li	a2,0
  66:	4585                	li	a1,1
  68:	00001517          	auipc	a0,0x1
  6c:	8f850513          	addi	a0,a0,-1800 # 960 <malloc+0x104>
  70:	328000ef          	jal	398 <mknod>
    open("console", O_RDWR);
  74:	4589                	li	a1,2
  76:	00001517          	auipc	a0,0x1
  7a:	8ea50513          	addi	a0,a0,-1814 # 960 <malloc+0x104>
  7e:	312000ef          	jal	390 <open>
  82:	bf71                	j	1e <main+0x1e>
      printf("init: fork failed\n");
  84:	00001517          	auipc	a0,0x1
  88:	8fc50513          	addi	a0,a0,-1796 # 980 <malloc+0x124>
  8c:	71c000ef          	jal	7a8 <printf>
      exit(1);
  90:	4505                	li	a0,1
  92:	2be000ef          	jal	350 <exit>
      exec("sh", argv);
  96:	00001597          	auipc	a1,0x1
  9a:	f6a58593          	addi	a1,a1,-150 # 1000 <argv>
  9e:	00001517          	auipc	a0,0x1
  a2:	8fa50513          	addi	a0,a0,-1798 # 998 <malloc+0x13c>
  a6:	2e2000ef          	jal	388 <exec>
      printf("init: exec sh failed\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	8f650513          	addi	a0,a0,-1802 # 9a0 <malloc+0x144>
  b2:	6f6000ef          	jal	7a8 <printf>
      exit(1);
  b6:	4505                	li	a0,1
  b8:	298000ef          	jal	350 <exit>

00000000000000bc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e406                	sd	ra,8(sp)
  c0:	e022                	sd	s0,0(sp)
  c2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  c4:	f3dff0ef          	jal	0 <main>
  exit(r);
  c8:	288000ef          	jal	350 <exit>

00000000000000cc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d2:	87aa                	mv	a5,a0
  d4:	0585                	addi	a1,a1,1
  d6:	0785                	addi	a5,a5,1
  d8:	fff5c703          	lbu	a4,-1(a1)
  dc:	fee78fa3          	sb	a4,-1(a5)
  e0:	fb75                	bnez	a4,d4 <strcpy+0x8>
    ;
  return os;
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cb91                	beqz	a5,106 <strcmp+0x1e>
  f4:	0005c703          	lbu	a4,0(a1)
  f8:	00f71763          	bne	a4,a5,106 <strcmp+0x1e>
    p++, q++;
  fc:	0505                	addi	a0,a0,1
  fe:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	fbe5                	bnez	a5,f4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 106:	0005c503          	lbu	a0,0(a1)
}
 10a:	40a7853b          	subw	a0,a5,a0
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strlen>:

uint
strlen(const char *s)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cf91                	beqz	a5,13a <strlen+0x26>
 120:	0505                	addi	a0,a0,1
 122:	87aa                	mv	a5,a0
 124:	86be                	mv	a3,a5
 126:	0785                	addi	a5,a5,1
 128:	fff7c703          	lbu	a4,-1(a5)
 12c:	ff65                	bnez	a4,124 <strlen+0x10>
 12e:	40a6853b          	subw	a0,a3,a0
 132:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret
  for(n = 0; s[n]; n++)
 13a:	4501                	li	a0,0
 13c:	bfe5                	j	134 <strlen+0x20>

000000000000013e <memset>:

void*
memset(void *dst, int c, uint n)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 144:	ca19                	beqz	a2,15a <memset+0x1c>
 146:	87aa                	mv	a5,a0
 148:	1602                	slli	a2,a2,0x20
 14a:	9201                	srli	a2,a2,0x20
 14c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 150:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 154:	0785                	addi	a5,a5,1
 156:	fee79de3          	bne	a5,a4,150 <memset+0x12>
  }
  return dst;
}
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strchr>:

char*
strchr(const char *s, char c)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  for(; *s; s++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cb99                	beqz	a5,180 <strchr+0x20>
    if(*s == c)
 16c:	00f58763          	beq	a1,a5,17a <strchr+0x1a>
  for(; *s; s++)
 170:	0505                	addi	a0,a0,1
 172:	00054783          	lbu	a5,0(a0)
 176:	fbfd                	bnez	a5,16c <strchr+0xc>
      return (char*)s;
  return 0;
 178:	4501                	li	a0,0
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  return 0;
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strchr+0x1a>

0000000000000184 <gets>:

char*
gets(char *buf, int max)
{
 184:	711d                	addi	sp,sp,-96
 186:	ec86                	sd	ra,88(sp)
 188:	e8a2                	sd	s0,80(sp)
 18a:	e4a6                	sd	s1,72(sp)
 18c:	e0ca                	sd	s2,64(sp)
 18e:	fc4e                	sd	s3,56(sp)
 190:	f852                	sd	s4,48(sp)
 192:	f456                	sd	s5,40(sp)
 194:	f05a                	sd	s6,32(sp)
 196:	ec5e                	sd	s7,24(sp)
 198:	1080                	addi	s0,sp,96
 19a:	8baa                	mv	s7,a0
 19c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19e:	892a                	mv	s2,a0
 1a0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a2:	4aa9                	li	s5,10
 1a4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a6:	89a6                	mv	s3,s1
 1a8:	2485                	addiw	s1,s1,1
 1aa:	0344d663          	bge	s1,s4,1d6 <gets+0x52>
    cc = read(0, &c, 1);
 1ae:	4605                	li	a2,1
 1b0:	faf40593          	addi	a1,s0,-81
 1b4:	4501                	li	a0,0
 1b6:	1b2000ef          	jal	368 <read>
    if(cc < 1)
 1ba:	00a05e63          	blez	a0,1d6 <gets+0x52>
    buf[i++] = c;
 1be:	faf44783          	lbu	a5,-81(s0)
 1c2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c6:	01578763          	beq	a5,s5,1d4 <gets+0x50>
 1ca:	0905                	addi	s2,s2,1
 1cc:	fd679de3          	bne	a5,s6,1a6 <gets+0x22>
    buf[i++] = c;
 1d0:	89a6                	mv	s3,s1
 1d2:	a011                	j	1d6 <gets+0x52>
 1d4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d6:	99de                	add	s3,s3,s7
 1d8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1dc:	855e                	mv	a0,s7
 1de:	60e6                	ld	ra,88(sp)
 1e0:	6446                	ld	s0,80(sp)
 1e2:	64a6                	ld	s1,72(sp)
 1e4:	6906                	ld	s2,64(sp)
 1e6:	79e2                	ld	s3,56(sp)
 1e8:	7a42                	ld	s4,48(sp)
 1ea:	7aa2                	ld	s5,40(sp)
 1ec:	7b02                	ld	s6,32(sp)
 1ee:	6be2                	ld	s7,24(sp)
 1f0:	6125                	addi	sp,sp,96
 1f2:	8082                	ret

00000000000001f4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f4:	1101                	addi	sp,sp,-32
 1f6:	ec06                	sd	ra,24(sp)
 1f8:	e822                	sd	s0,16(sp)
 1fa:	e04a                	sd	s2,0(sp)
 1fc:	1000                	addi	s0,sp,32
 1fe:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 200:	4581                	li	a1,0
 202:	18e000ef          	jal	390 <open>
  if(fd < 0)
 206:	02054263          	bltz	a0,22a <stat+0x36>
 20a:	e426                	sd	s1,8(sp)
 20c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20e:	85ca                	mv	a1,s2
 210:	198000ef          	jal	3a8 <fstat>
 214:	892a                	mv	s2,a0
  close(fd);
 216:	8526                	mv	a0,s1
 218:	160000ef          	jal	378 <close>
  return r;
 21c:	64a2                	ld	s1,8(sp)
}
 21e:	854a                	mv	a0,s2
 220:	60e2                	ld	ra,24(sp)
 222:	6442                	ld	s0,16(sp)
 224:	6902                	ld	s2,0(sp)
 226:	6105                	addi	sp,sp,32
 228:	8082                	ret
    return -1;
 22a:	597d                	li	s2,-1
 22c:	bfcd                	j	21e <stat+0x2a>

000000000000022e <atoi>:

int
atoi(const char *s)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 234:	00054683          	lbu	a3,0(a0)
 238:	fd06879b          	addiw	a5,a3,-48
 23c:	0ff7f793          	zext.b	a5,a5
 240:	4625                	li	a2,9
 242:	02f66863          	bltu	a2,a5,272 <atoi+0x44>
 246:	872a                	mv	a4,a0
  n = 0;
 248:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 24a:	0705                	addi	a4,a4,1
 24c:	0025179b          	slliw	a5,a0,0x2
 250:	9fa9                	addw	a5,a5,a0
 252:	0017979b          	slliw	a5,a5,0x1
 256:	9fb5                	addw	a5,a5,a3
 258:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25c:	00074683          	lbu	a3,0(a4)
 260:	fd06879b          	addiw	a5,a3,-48
 264:	0ff7f793          	zext.b	a5,a5
 268:	fef671e3          	bgeu	a2,a5,24a <atoi+0x1c>
  return n;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  n = 0;
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <atoi+0x3e>

0000000000000276 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27c:	02b57463          	bgeu	a0,a1,2a4 <memmove+0x2e>
    while(n-- > 0)
 280:	00c05f63          	blez	a2,29e <memmove+0x28>
 284:	1602                	slli	a2,a2,0x20
 286:	9201                	srli	a2,a2,0x20
 288:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28c:	872a                	mv	a4,a0
      *dst++ = *src++;
 28e:	0585                	addi	a1,a1,1
 290:	0705                	addi	a4,a4,1
 292:	fff5c683          	lbu	a3,-1(a1)
 296:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29a:	fef71ae3          	bne	a4,a5,28e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
    dst += n;
 2a4:	00c50733          	add	a4,a0,a2
    src += n;
 2a8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2aa:	fec05ae3          	blez	a2,29e <memmove+0x28>
 2ae:	fff6079b          	addiw	a5,a2,-1
 2b2:	1782                	slli	a5,a5,0x20
 2b4:	9381                	srli	a5,a5,0x20
 2b6:	fff7c793          	not	a5,a5
 2ba:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2bc:	15fd                	addi	a1,a1,-1
 2be:	177d                	addi	a4,a4,-1
 2c0:	0005c683          	lbu	a3,0(a1)
 2c4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c8:	fee79ae3          	bne	a5,a4,2bc <memmove+0x46>
 2cc:	bfc9                	j	29e <memmove+0x28>

00000000000002ce <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d4:	ca05                	beqz	a2,304 <memcmp+0x36>
 2d6:	fff6069b          	addiw	a3,a2,-1
 2da:	1682                	slli	a3,a3,0x20
 2dc:	9281                	srli	a3,a3,0x20
 2de:	0685                	addi	a3,a3,1
 2e0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e2:	00054783          	lbu	a5,0(a0)
 2e6:	0005c703          	lbu	a4,0(a1)
 2ea:	00e79863          	bne	a5,a4,2fa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ee:	0505                	addi	a0,a0,1
    p2++;
 2f0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f2:	fed518e3          	bne	a0,a3,2e2 <memcmp+0x14>
  }
  return 0;
 2f6:	4501                	li	a0,0
 2f8:	a019                	j	2fe <memcmp+0x30>
      return *p1 - *p2;
 2fa:	40e7853b          	subw	a0,a5,a4
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
  return 0;
 304:	4501                	li	a0,0
 306:	bfe5                	j	2fe <memcmp+0x30>

0000000000000308 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 310:	f67ff0ef          	jal	276 <memmove>
}
 314:	60a2                	ld	ra,8(sp)
 316:	6402                	ld	s0,0(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <sbrk>:

char *
sbrk(int n) {
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 324:	4585                	li	a1,1
 326:	0c2000ef          	jal	3e8 <sys_sbrk>
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <sbrklazy>:

char *
sbrklazy(int n) {
 332:	1141                	addi	sp,sp,-16
 334:	e406                	sd	ra,8(sp)
 336:	e022                	sd	s0,0(sp)
 338:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 33a:	4589                	li	a1,2
 33c:	0ac000ef          	jal	3e8 <sys_sbrk>
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret

0000000000000348 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 348:	4885                	li	a7,1
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <exit>:
.global exit
exit:
 li a7, SYS_exit
 350:	4889                	li	a7,2
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <wait>:
.global wait
wait:
 li a7, SYS_wait
 358:	488d                	li	a7,3
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 360:	4891                	li	a7,4
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <read>:
.global read
read:
 li a7, SYS_read
 368:	4895                	li	a7,5
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <write>:
.global write
write:
 li a7, SYS_write
 370:	48c1                	li	a7,16
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <close>:
.global close
close:
 li a7, SYS_close
 378:	48d5                	li	a7,21
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <kill>:
.global kill
kill:
 li a7, SYS_kill
 380:	4899                	li	a7,6
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <exec>:
.global exec
exec:
 li a7, SYS_exec
 388:	489d                	li	a7,7
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <open>:
.global open
open:
 li a7, SYS_open
 390:	48bd                	li	a7,15
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 398:	48c5                	li	a7,17
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a0:	48c9                	li	a7,18
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a8:	48a1                	li	a7,8
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <link>:
.global link
link:
 li a7, SYS_link
 3b0:	48cd                	li	a7,19
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b8:	48d1                	li	a7,20
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c0:	48a5                	li	a7,9
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c8:	48a9                	li	a7,10
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d0:	48ad                	li	a7,11
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 3d8:	48e9                	li	a7,26
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 3e0:	48ed                	li	a7,27
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e8:	48b1                	li	a7,12
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3f0:	48b5                	li	a7,13
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f8:	48b9                	li	a7,14
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <csread>:
.global csread
csread:
 li a7, SYS_csread
 400:	48d9                	li	a7,22
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 408:	48dd                	li	a7,23
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 410:	48e1                	li	a7,24
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <memread>:
.global memread
memread:
 li a7, SYS_memread
 418:	48e5                	li	a7,25
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 420:	1101                	addi	sp,sp,-32
 422:	ec06                	sd	ra,24(sp)
 424:	e822                	sd	s0,16(sp)
 426:	1000                	addi	s0,sp,32
 428:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 42c:	4605                	li	a2,1
 42e:	fef40593          	addi	a1,s0,-17
 432:	f3fff0ef          	jal	370 <write>
}
 436:	60e2                	ld	ra,24(sp)
 438:	6442                	ld	s0,16(sp)
 43a:	6105                	addi	sp,sp,32
 43c:	8082                	ret

000000000000043e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 43e:	715d                	addi	sp,sp,-80
 440:	e486                	sd	ra,72(sp)
 442:	e0a2                	sd	s0,64(sp)
 444:	f84a                	sd	s2,48(sp)
 446:	0880                	addi	s0,sp,80
 448:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 44a:	c299                	beqz	a3,450 <printint+0x12>
 44c:	0805c363          	bltz	a1,4d2 <printint+0x94>
  neg = 0;
 450:	4881                	li	a7,0
 452:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 456:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 458:	00000517          	auipc	a0,0x0
 45c:	58850513          	addi	a0,a0,1416 # 9e0 <digits>
 460:	883e                	mv	a6,a5
 462:	2785                	addiw	a5,a5,1
 464:	02c5f733          	remu	a4,a1,a2
 468:	972a                	add	a4,a4,a0
 46a:	00074703          	lbu	a4,0(a4)
 46e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 472:	872e                	mv	a4,a1
 474:	02c5d5b3          	divu	a1,a1,a2
 478:	0685                	addi	a3,a3,1
 47a:	fec773e3          	bgeu	a4,a2,460 <printint+0x22>
  if(neg)
 47e:	00088b63          	beqz	a7,494 <printint+0x56>
    buf[i++] = '-';
 482:	fd078793          	addi	a5,a5,-48
 486:	97a2                	add	a5,a5,s0
 488:	02d00713          	li	a4,45
 48c:	fee78423          	sb	a4,-24(a5)
 490:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 494:	02f05a63          	blez	a5,4c8 <printint+0x8a>
 498:	fc26                	sd	s1,56(sp)
 49a:	f44e                	sd	s3,40(sp)
 49c:	fb840713          	addi	a4,s0,-72
 4a0:	00f704b3          	add	s1,a4,a5
 4a4:	fff70993          	addi	s3,a4,-1
 4a8:	99be                	add	s3,s3,a5
 4aa:	37fd                	addiw	a5,a5,-1
 4ac:	1782                	slli	a5,a5,0x20
 4ae:	9381                	srli	a5,a5,0x20
 4b0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4b4:	fff4c583          	lbu	a1,-1(s1)
 4b8:	854a                	mv	a0,s2
 4ba:	f67ff0ef          	jal	420 <putc>
  while(--i >= 0)
 4be:	14fd                	addi	s1,s1,-1
 4c0:	ff349ae3          	bne	s1,s3,4b4 <printint+0x76>
 4c4:	74e2                	ld	s1,56(sp)
 4c6:	79a2                	ld	s3,40(sp)
}
 4c8:	60a6                	ld	ra,72(sp)
 4ca:	6406                	ld	s0,64(sp)
 4cc:	7942                	ld	s2,48(sp)
 4ce:	6161                	addi	sp,sp,80
 4d0:	8082                	ret
    x = -xx;
 4d2:	40b005b3          	neg	a1,a1
    neg = 1;
 4d6:	4885                	li	a7,1
    x = -xx;
 4d8:	bfad                	j	452 <printint+0x14>

00000000000004da <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4da:	711d                	addi	sp,sp,-96
 4dc:	ec86                	sd	ra,88(sp)
 4de:	e8a2                	sd	s0,80(sp)
 4e0:	e0ca                	sd	s2,64(sp)
 4e2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e4:	0005c903          	lbu	s2,0(a1)
 4e8:	28090663          	beqz	s2,774 <vprintf+0x29a>
 4ec:	e4a6                	sd	s1,72(sp)
 4ee:	fc4e                	sd	s3,56(sp)
 4f0:	f852                	sd	s4,48(sp)
 4f2:	f456                	sd	s5,40(sp)
 4f4:	f05a                	sd	s6,32(sp)
 4f6:	ec5e                	sd	s7,24(sp)
 4f8:	e862                	sd	s8,16(sp)
 4fa:	e466                	sd	s9,8(sp)
 4fc:	8b2a                	mv	s6,a0
 4fe:	8a2e                	mv	s4,a1
 500:	8bb2                	mv	s7,a2
  state = 0;
 502:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 504:	4481                	li	s1,0
 506:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 508:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 50c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 510:	06c00c93          	li	s9,108
 514:	a005                	j	534 <vprintf+0x5a>
        putc(fd, c0);
 516:	85ca                	mv	a1,s2
 518:	855a                	mv	a0,s6
 51a:	f07ff0ef          	jal	420 <putc>
 51e:	a019                	j	524 <vprintf+0x4a>
    } else if(state == '%'){
 520:	03598263          	beq	s3,s5,544 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 524:	2485                	addiw	s1,s1,1
 526:	8726                	mv	a4,s1
 528:	009a07b3          	add	a5,s4,s1
 52c:	0007c903          	lbu	s2,0(a5)
 530:	22090a63          	beqz	s2,764 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 534:	0009079b          	sext.w	a5,s2
    if(state == 0){
 538:	fe0994e3          	bnez	s3,520 <vprintf+0x46>
      if(c0 == '%'){
 53c:	fd579de3          	bne	a5,s5,516 <vprintf+0x3c>
        state = '%';
 540:	89be                	mv	s3,a5
 542:	b7cd                	j	524 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 544:	00ea06b3          	add	a3,s4,a4
 548:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 54c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 54e:	c681                	beqz	a3,556 <vprintf+0x7c>
 550:	9752                	add	a4,a4,s4
 552:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 556:	05878363          	beq	a5,s8,59c <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 55a:	05978d63          	beq	a5,s9,5b4 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 55e:	07500713          	li	a4,117
 562:	0ee78763          	beq	a5,a4,650 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 566:	07800713          	li	a4,120
 56a:	12e78963          	beq	a5,a4,69c <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 56e:	07000713          	li	a4,112
 572:	14e78e63          	beq	a5,a4,6ce <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 576:	06300713          	li	a4,99
 57a:	18e78e63          	beq	a5,a4,716 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 57e:	07300713          	li	a4,115
 582:	1ae78463          	beq	a5,a4,72a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 586:	02500713          	li	a4,37
 58a:	04e79563          	bne	a5,a4,5d4 <vprintf+0xfa>
        putc(fd, '%');
 58e:	02500593          	li	a1,37
 592:	855a                	mv	a0,s6
 594:	e8dff0ef          	jal	420 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 598:	4981                	li	s3,0
 59a:	b769                	j	524 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 59c:	008b8913          	addi	s2,s7,8
 5a0:	4685                	li	a3,1
 5a2:	4629                	li	a2,10
 5a4:	000ba583          	lw	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	e95ff0ef          	jal	43e <printint>
 5ae:	8bca                	mv	s7,s2
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	bf8d                	j	524 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5b4:	06400793          	li	a5,100
 5b8:	02f68963          	beq	a3,a5,5ea <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5bc:	06c00793          	li	a5,108
 5c0:	04f68263          	beq	a3,a5,604 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5c4:	07500793          	li	a5,117
 5c8:	0af68063          	beq	a3,a5,668 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5cc:	07800793          	li	a5,120
 5d0:	0ef68263          	beq	a3,a5,6b4 <vprintf+0x1da>
        putc(fd, '%');
 5d4:	02500593          	li	a1,37
 5d8:	855a                	mv	a0,s6
 5da:	e47ff0ef          	jal	420 <putc>
        putc(fd, c0);
 5de:	85ca                	mv	a1,s2
 5e0:	855a                	mv	a0,s6
 5e2:	e3fff0ef          	jal	420 <putc>
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	bf35                	j	524 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ea:	008b8913          	addi	s2,s7,8
 5ee:	4685                	li	a3,1
 5f0:	4629                	li	a2,10
 5f2:	000bb583          	ld	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	e47ff0ef          	jal	43e <printint>
        i += 1;
 5fc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fe:	8bca                	mv	s7,s2
      state = 0;
 600:	4981                	li	s3,0
        i += 1;
 602:	b70d                	j	524 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 604:	06400793          	li	a5,100
 608:	02f60763          	beq	a2,a5,636 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 60c:	07500793          	li	a5,117
 610:	06f60963          	beq	a2,a5,682 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 614:	07800793          	li	a5,120
 618:	faf61ee3          	bne	a2,a5,5d4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 61c:	008b8913          	addi	s2,s7,8
 620:	4681                	li	a3,0
 622:	4641                	li	a2,16
 624:	000bb583          	ld	a1,0(s7)
 628:	855a                	mv	a0,s6
 62a:	e15ff0ef          	jal	43e <printint>
        i += 2;
 62e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 630:	8bca                	mv	s7,s2
      state = 0;
 632:	4981                	li	s3,0
        i += 2;
 634:	bdc5                	j	524 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 636:	008b8913          	addi	s2,s7,8
 63a:	4685                	li	a3,1
 63c:	4629                	li	a2,10
 63e:	000bb583          	ld	a1,0(s7)
 642:	855a                	mv	a0,s6
 644:	dfbff0ef          	jal	43e <printint>
        i += 2;
 648:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 64a:	8bca                	mv	s7,s2
      state = 0;
 64c:	4981                	li	s3,0
        i += 2;
 64e:	bdd9                	j	524 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 650:	008b8913          	addi	s2,s7,8
 654:	4681                	li	a3,0
 656:	4629                	li	a2,10
 658:	000be583          	lwu	a1,0(s7)
 65c:	855a                	mv	a0,s6
 65e:	de1ff0ef          	jal	43e <printint>
 662:	8bca                	mv	s7,s2
      state = 0;
 664:	4981                	li	s3,0
 666:	bd7d                	j	524 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 668:	008b8913          	addi	s2,s7,8
 66c:	4681                	li	a3,0
 66e:	4629                	li	a2,10
 670:	000bb583          	ld	a1,0(s7)
 674:	855a                	mv	a0,s6
 676:	dc9ff0ef          	jal	43e <printint>
        i += 1;
 67a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 67c:	8bca                	mv	s7,s2
      state = 0;
 67e:	4981                	li	s3,0
        i += 1;
 680:	b555                	j	524 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	008b8913          	addi	s2,s7,8
 686:	4681                	li	a3,0
 688:	4629                	li	a2,10
 68a:	000bb583          	ld	a1,0(s7)
 68e:	855a                	mv	a0,s6
 690:	dafff0ef          	jal	43e <printint>
        i += 2;
 694:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 696:	8bca                	mv	s7,s2
      state = 0;
 698:	4981                	li	s3,0
        i += 2;
 69a:	b569                	j	524 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 69c:	008b8913          	addi	s2,s7,8
 6a0:	4681                	li	a3,0
 6a2:	4641                	li	a2,16
 6a4:	000be583          	lwu	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	d95ff0ef          	jal	43e <printint>
 6ae:	8bca                	mv	s7,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bd8d                	j	524 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b4:	008b8913          	addi	s2,s7,8
 6b8:	4681                	li	a3,0
 6ba:	4641                	li	a2,16
 6bc:	000bb583          	ld	a1,0(s7)
 6c0:	855a                	mv	a0,s6
 6c2:	d7dff0ef          	jal	43e <printint>
        i += 1;
 6c6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c8:	8bca                	mv	s7,s2
      state = 0;
 6ca:	4981                	li	s3,0
        i += 1;
 6cc:	bda1                	j	524 <vprintf+0x4a>
 6ce:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6d0:	008b8d13          	addi	s10,s7,8
 6d4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d8:	03000593          	li	a1,48
 6dc:	855a                	mv	a0,s6
 6de:	d43ff0ef          	jal	420 <putc>
  putc(fd, 'x');
 6e2:	07800593          	li	a1,120
 6e6:	855a                	mv	a0,s6
 6e8:	d39ff0ef          	jal	420 <putc>
 6ec:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ee:	00000b97          	auipc	s7,0x0
 6f2:	2f2b8b93          	addi	s7,s7,754 # 9e0 <digits>
 6f6:	03c9d793          	srli	a5,s3,0x3c
 6fa:	97de                	add	a5,a5,s7
 6fc:	0007c583          	lbu	a1,0(a5)
 700:	855a                	mv	a0,s6
 702:	d1fff0ef          	jal	420 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 706:	0992                	slli	s3,s3,0x4
 708:	397d                	addiw	s2,s2,-1
 70a:	fe0916e3          	bnez	s2,6f6 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 70e:	8bea                	mv	s7,s10
      state = 0;
 710:	4981                	li	s3,0
 712:	6d02                	ld	s10,0(sp)
 714:	bd01                	j	524 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 716:	008b8913          	addi	s2,s7,8
 71a:	000bc583          	lbu	a1,0(s7)
 71e:	855a                	mv	a0,s6
 720:	d01ff0ef          	jal	420 <putc>
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
 728:	bbf5                	j	524 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 72a:	008b8993          	addi	s3,s7,8
 72e:	000bb903          	ld	s2,0(s7)
 732:	00090f63          	beqz	s2,750 <vprintf+0x276>
        for(; *s; s++)
 736:	00094583          	lbu	a1,0(s2)
 73a:	c195                	beqz	a1,75e <vprintf+0x284>
          putc(fd, *s);
 73c:	855a                	mv	a0,s6
 73e:	ce3ff0ef          	jal	420 <putc>
        for(; *s; s++)
 742:	0905                	addi	s2,s2,1
 744:	00094583          	lbu	a1,0(s2)
 748:	f9f5                	bnez	a1,73c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 74a:	8bce                	mv	s7,s3
      state = 0;
 74c:	4981                	li	s3,0
 74e:	bbd9                	j	524 <vprintf+0x4a>
          s = "(null)";
 750:	00000917          	auipc	s2,0x0
 754:	28890913          	addi	s2,s2,648 # 9d8 <malloc+0x17c>
        for(; *s; s++)
 758:	02800593          	li	a1,40
 75c:	b7c5                	j	73c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 75e:	8bce                	mv	s7,s3
      state = 0;
 760:	4981                	li	s3,0
 762:	b3c9                	j	524 <vprintf+0x4a>
 764:	64a6                	ld	s1,72(sp)
 766:	79e2                	ld	s3,56(sp)
 768:	7a42                	ld	s4,48(sp)
 76a:	7aa2                	ld	s5,40(sp)
 76c:	7b02                	ld	s6,32(sp)
 76e:	6be2                	ld	s7,24(sp)
 770:	6c42                	ld	s8,16(sp)
 772:	6ca2                	ld	s9,8(sp)
    }
  }
}
 774:	60e6                	ld	ra,88(sp)
 776:	6446                	ld	s0,80(sp)
 778:	6906                	ld	s2,64(sp)
 77a:	6125                	addi	sp,sp,96
 77c:	8082                	ret

000000000000077e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 77e:	715d                	addi	sp,sp,-80
 780:	ec06                	sd	ra,24(sp)
 782:	e822                	sd	s0,16(sp)
 784:	1000                	addi	s0,sp,32
 786:	e010                	sd	a2,0(s0)
 788:	e414                	sd	a3,8(s0)
 78a:	e818                	sd	a4,16(s0)
 78c:	ec1c                	sd	a5,24(s0)
 78e:	03043023          	sd	a6,32(s0)
 792:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 796:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 79a:	8622                	mv	a2,s0
 79c:	d3fff0ef          	jal	4da <vprintf>
}
 7a0:	60e2                	ld	ra,24(sp)
 7a2:	6442                	ld	s0,16(sp)
 7a4:	6161                	addi	sp,sp,80
 7a6:	8082                	ret

00000000000007a8 <printf>:

void
printf(const char *fmt, ...)
{
 7a8:	711d                	addi	sp,sp,-96
 7aa:	ec06                	sd	ra,24(sp)
 7ac:	e822                	sd	s0,16(sp)
 7ae:	1000                	addi	s0,sp,32
 7b0:	e40c                	sd	a1,8(s0)
 7b2:	e810                	sd	a2,16(s0)
 7b4:	ec14                	sd	a3,24(s0)
 7b6:	f018                	sd	a4,32(s0)
 7b8:	f41c                	sd	a5,40(s0)
 7ba:	03043823          	sd	a6,48(s0)
 7be:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c2:	00840613          	addi	a2,s0,8
 7c6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ca:	85aa                	mv	a1,a0
 7cc:	4505                	li	a0,1
 7ce:	d0dff0ef          	jal	4da <vprintf>
}
 7d2:	60e2                	ld	ra,24(sp)
 7d4:	6442                	ld	s0,16(sp)
 7d6:	6125                	addi	sp,sp,96
 7d8:	8082                	ret

00000000000007da <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7da:	1141                	addi	sp,sp,-16
 7dc:	e422                	sd	s0,8(sp)
 7de:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e4:	00001797          	auipc	a5,0x1
 7e8:	82c7b783          	ld	a5,-2004(a5) # 1010 <freep>
 7ec:	a02d                	j	816 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ee:	4618                	lw	a4,8(a2)
 7f0:	9f2d                	addw	a4,a4,a1
 7f2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f6:	6398                	ld	a4,0(a5)
 7f8:	6310                	ld	a2,0(a4)
 7fa:	a83d                	j	838 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7fc:	ff852703          	lw	a4,-8(a0)
 800:	9f31                	addw	a4,a4,a2
 802:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 804:	ff053683          	ld	a3,-16(a0)
 808:	a091                	j	84c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80a:	6398                	ld	a4,0(a5)
 80c:	00e7e463          	bltu	a5,a4,814 <free+0x3a>
 810:	00e6ea63          	bltu	a3,a4,824 <free+0x4a>
{
 814:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 816:	fed7fae3          	bgeu	a5,a3,80a <free+0x30>
 81a:	6398                	ld	a4,0(a5)
 81c:	00e6e463          	bltu	a3,a4,824 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 820:	fee7eae3          	bltu	a5,a4,814 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 824:	ff852583          	lw	a1,-8(a0)
 828:	6390                	ld	a2,0(a5)
 82a:	02059813          	slli	a6,a1,0x20
 82e:	01c85713          	srli	a4,a6,0x1c
 832:	9736                	add	a4,a4,a3
 834:	fae60de3          	beq	a2,a4,7ee <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 838:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 83c:	4790                	lw	a2,8(a5)
 83e:	02061593          	slli	a1,a2,0x20
 842:	01c5d713          	srli	a4,a1,0x1c
 846:	973e                	add	a4,a4,a5
 848:	fae68ae3          	beq	a3,a4,7fc <free+0x22>
    p->s.ptr = bp->s.ptr;
 84c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 84e:	00000717          	auipc	a4,0x0
 852:	7cf73123          	sd	a5,1986(a4) # 1010 <freep>
}
 856:	6422                	ld	s0,8(sp)
 858:	0141                	addi	sp,sp,16
 85a:	8082                	ret

000000000000085c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 85c:	7139                	addi	sp,sp,-64
 85e:	fc06                	sd	ra,56(sp)
 860:	f822                	sd	s0,48(sp)
 862:	f426                	sd	s1,40(sp)
 864:	ec4e                	sd	s3,24(sp)
 866:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 868:	02051493          	slli	s1,a0,0x20
 86c:	9081                	srli	s1,s1,0x20
 86e:	04bd                	addi	s1,s1,15
 870:	8091                	srli	s1,s1,0x4
 872:	0014899b          	addiw	s3,s1,1
 876:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 878:	00000517          	auipc	a0,0x0
 87c:	79853503          	ld	a0,1944(a0) # 1010 <freep>
 880:	c915                	beqz	a0,8b4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 882:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 884:	4798                	lw	a4,8(a5)
 886:	08977a63          	bgeu	a4,s1,91a <malloc+0xbe>
 88a:	f04a                	sd	s2,32(sp)
 88c:	e852                	sd	s4,16(sp)
 88e:	e456                	sd	s5,8(sp)
 890:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 892:	8a4e                	mv	s4,s3
 894:	0009871b          	sext.w	a4,s3
 898:	6685                	lui	a3,0x1
 89a:	00d77363          	bgeu	a4,a3,8a0 <malloc+0x44>
 89e:	6a05                	lui	s4,0x1
 8a0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a8:	00000917          	auipc	s2,0x0
 8ac:	76890913          	addi	s2,s2,1896 # 1010 <freep>
  if(p == SBRK_ERROR)
 8b0:	5afd                	li	s5,-1
 8b2:	a081                	j	8f2 <malloc+0x96>
 8b4:	f04a                	sd	s2,32(sp)
 8b6:	e852                	sd	s4,16(sp)
 8b8:	e456                	sd	s5,8(sp)
 8ba:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8bc:	00000797          	auipc	a5,0x0
 8c0:	76478793          	addi	a5,a5,1892 # 1020 <base>
 8c4:	00000717          	auipc	a4,0x0
 8c8:	74f73623          	sd	a5,1868(a4) # 1010 <freep>
 8cc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ce:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d2:	b7c1                	j	892 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8d4:	6398                	ld	a4,0(a5)
 8d6:	e118                	sd	a4,0(a0)
 8d8:	a8a9                	j	932 <malloc+0xd6>
  hp->s.size = nu;
 8da:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8de:	0541                	addi	a0,a0,16
 8e0:	efbff0ef          	jal	7da <free>
  return freep;
 8e4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e8:	c12d                	beqz	a0,94a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ec:	4798                	lw	a4,8(a5)
 8ee:	02977263          	bgeu	a4,s1,912 <malloc+0xb6>
    if(p == freep)
 8f2:	00093703          	ld	a4,0(s2)
 8f6:	853e                	mv	a0,a5
 8f8:	fef719e3          	bne	a4,a5,8ea <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8fc:	8552                	mv	a0,s4
 8fe:	a1fff0ef          	jal	31c <sbrk>
  if(p == SBRK_ERROR)
 902:	fd551ce3          	bne	a0,s5,8da <malloc+0x7e>
        return 0;
 906:	4501                	li	a0,0
 908:	7902                	ld	s2,32(sp)
 90a:	6a42                	ld	s4,16(sp)
 90c:	6aa2                	ld	s5,8(sp)
 90e:	6b02                	ld	s6,0(sp)
 910:	a03d                	j	93e <malloc+0xe2>
 912:	7902                	ld	s2,32(sp)
 914:	6a42                	ld	s4,16(sp)
 916:	6aa2                	ld	s5,8(sp)
 918:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 91a:	fae48de3          	beq	s1,a4,8d4 <malloc+0x78>
        p->s.size -= nunits;
 91e:	4137073b          	subw	a4,a4,s3
 922:	c798                	sw	a4,8(a5)
        p += p->s.size;
 924:	02071693          	slli	a3,a4,0x20
 928:	01c6d713          	srli	a4,a3,0x1c
 92c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 92e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 932:	00000717          	auipc	a4,0x0
 936:	6ca73f23          	sd	a0,1758(a4) # 1010 <freep>
      return (void*)(p + 1);
 93a:	01078513          	addi	a0,a5,16
  }
}
 93e:	70e2                	ld	ra,56(sp)
 940:	7442                	ld	s0,48(sp)
 942:	74a2                	ld	s1,40(sp)
 944:	69e2                	ld	s3,24(sp)
 946:	6121                	addi	sp,sp,64
 948:	8082                	ret
 94a:	7902                	ld	s2,32(sp)
 94c:	6a42                	ld	s4,16(sp)
 94e:	6aa2                	ld	s5,8(sp)
 950:	6b02                	ld	s6,0(sp)
 952:	b7f5                	j	93e <malloc+0xe2>
