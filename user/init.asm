
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
  12:	98250513          	addi	a0,a0,-1662 # 990 <malloc+0x100>
  16:	39c000ef          	jal	3b2 <open>
  1a:	04054563          	bltz	a0,64 <main+0x64>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  1e:	4501                	li	a0,0
  20:	3ca000ef          	jal	3ea <dup>
  dup(0);  // stderr
  24:	4501                	li	a0,0
  26:	3c4000ef          	jal	3ea <dup>



  for(;;){
    printf("init: starting sh\n");
  2a:	00001917          	auipc	s2,0x1
  2e:	96e90913          	addi	s2,s2,-1682 # 998 <malloc+0x108>
  32:	854a                	mv	a0,s2
  34:	7a4000ef          	jal	7d8 <printf>
    pid = fork();
  38:	332000ef          	jal	36a <fork>
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
  46:	334000ef          	jal	37a <wait>
      if(wpid == pid){
  4a:	fea484e3          	beq	s1,a0,32 <main+0x32>
        break;
      } else if(wpid < 0){
  4e:	fe055be3          	bgez	a0,44 <main+0x44>
        printf("init: wait returned an error\n");
  52:	00001517          	auipc	a0,0x1
  56:	99650513          	addi	a0,a0,-1642 # 9e8 <malloc+0x158>
  5a:	77e000ef          	jal	7d8 <printf>
        exit(1);
  5e:	4505                	li	a0,1
  60:	312000ef          	jal	372 <exit>
    mknod("console", CONSOLE, 0);
  64:	4601                	li	a2,0
  66:	4585                	li	a1,1
  68:	00001517          	auipc	a0,0x1
  6c:	92850513          	addi	a0,a0,-1752 # 990 <malloc+0x100>
  70:	34a000ef          	jal	3ba <mknod>
    open("console", O_RDWR);
  74:	4589                	li	a1,2
  76:	00001517          	auipc	a0,0x1
  7a:	91a50513          	addi	a0,a0,-1766 # 990 <malloc+0x100>
  7e:	334000ef          	jal	3b2 <open>
  82:	bf71                	j	1e <main+0x1e>
      printf("init: fork failed\n");
  84:	00001517          	auipc	a0,0x1
  88:	92c50513          	addi	a0,a0,-1748 # 9b0 <malloc+0x120>
  8c:	74c000ef          	jal	7d8 <printf>
      exit(1);
  90:	4505                	li	a0,1
  92:	2e0000ef          	jal	372 <exit>
      exec("sh", argv);
  96:	00001597          	auipc	a1,0x1
  9a:	f6a58593          	addi	a1,a1,-150 # 1000 <argv>
  9e:	00001517          	auipc	a0,0x1
  a2:	92a50513          	addi	a0,a0,-1750 # 9c8 <malloc+0x138>
  a6:	304000ef          	jal	3aa <exec>
      printf("init: exec sh failed\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	92650513          	addi	a0,a0,-1754 # 9d0 <malloc+0x140>
  b2:	726000ef          	jal	7d8 <printf>
      exit(1);
  b6:	4505                	li	a0,1
  b8:	2ba000ef          	jal	372 <exit>

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
  c8:	2aa000ef          	jal	372 <exit>

00000000000000cc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d4:	87aa                	mv	a5,a0
  d6:	0585                	addi	a1,a1,1
  d8:	0785                	addi	a5,a5,1
  da:	fff5c703          	lbu	a4,-1(a1)
  de:	fee78fa3          	sb	a4,-1(a5)
  e2:	fb75                	bnez	a4,d6 <strcpy+0xa>
    ;
  return os;
}
  e4:	60a2                	ld	ra,8(sp)
  e6:	6402                	ld	s0,0(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret

00000000000000ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e406                	sd	ra,8(sp)
  f0:	e022                	sd	s0,0(sp)
  f2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	cb91                	beqz	a5,10c <strcmp+0x20>
  fa:	0005c703          	lbu	a4,0(a1)
  fe:	00f71763          	bne	a4,a5,10c <strcmp+0x20>
    p++, q++;
 102:	0505                	addi	a0,a0,1
 104:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbe5                	bnez	a5,fa <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 10c:	0005c503          	lbu	a0,0(a1)
}
 110:	40a7853b          	subw	a0,a5,a0
 114:	60a2                	ld	ra,8(sp)
 116:	6402                	ld	s0,0(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 124:	00054783          	lbu	a5,0(a0)
 128:	cf91                	beqz	a5,144 <strlen+0x28>
 12a:	00150793          	addi	a5,a0,1
 12e:	86be                	mv	a3,a5
 130:	0785                	addi	a5,a5,1
 132:	fff7c703          	lbu	a4,-1(a5)
 136:	ff65                	bnez	a4,12e <strlen+0x12>
 138:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 13c:	60a2                	ld	ra,8(sp)
 13e:	6402                	ld	s0,0(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret
  for(n = 0; s[n]; n++)
 144:	4501                	li	a0,0
 146:	bfdd                	j	13c <strlen+0x20>

0000000000000148 <memset>:

void*
memset(void *dst, int c, uint n)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e406                	sd	ra,8(sp)
 14c:	e022                	sd	s0,0(sp)
 14e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 150:	ca19                	beqz	a2,166 <memset+0x1e>
 152:	87aa                	mv	a5,a0
 154:	1602                	slli	a2,a2,0x20
 156:	9201                	srli	a2,a2,0x20
 158:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 160:	0785                	addi	a5,a5,1
 162:	fee79de3          	bne	a5,a4,15c <memset+0x14>
  }
  return dst;
}
 166:	60a2                	ld	ra,8(sp)
 168:	6402                	ld	s0,0(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <strchr>:

char*
strchr(const char *s, char c)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e406                	sd	ra,8(sp)
 172:	e022                	sd	s0,0(sp)
 174:	0800                	addi	s0,sp,16
  for(; *s; s++)
 176:	00054783          	lbu	a5,0(a0)
 17a:	cf81                	beqz	a5,192 <strchr+0x24>
    if(*s == c)
 17c:	00f58763          	beq	a1,a5,18a <strchr+0x1c>
  for(; *s; s++)
 180:	0505                	addi	a0,a0,1
 182:	00054783          	lbu	a5,0(a0)
 186:	fbfd                	bnez	a5,17c <strchr+0xe>
      return (char*)s;
  return 0;
 188:	4501                	li	a0,0
}
 18a:	60a2                	ld	ra,8(sp)
 18c:	6402                	ld	s0,0(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret
  return 0;
 192:	4501                	li	a0,0
 194:	bfdd                	j	18a <strchr+0x1c>

0000000000000196 <gets>:

char*
gets(char *buf, int max)
{
 196:	711d                	addi	sp,sp,-96
 198:	ec86                	sd	ra,88(sp)
 19a:	e8a2                	sd	s0,80(sp)
 19c:	e4a6                	sd	s1,72(sp)
 19e:	e0ca                	sd	s2,64(sp)
 1a0:	fc4e                	sd	s3,56(sp)
 1a2:	f852                	sd	s4,48(sp)
 1a4:	f456                	sd	s5,40(sp)
 1a6:	f05a                	sd	s6,32(sp)
 1a8:	ec5e                	sd	s7,24(sp)
 1aa:	e862                	sd	s8,16(sp)
 1ac:	1080                	addi	s0,sp,96
 1ae:	8baa                	mv	s7,a0
 1b0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b2:	892a                	mv	s2,a0
 1b4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1b6:	faf40b13          	addi	s6,s0,-81
 1ba:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1bc:	8c26                	mv	s8,s1
 1be:	0014899b          	addiw	s3,s1,1
 1c2:	84ce                	mv	s1,s3
 1c4:	0349d463          	bge	s3,s4,1ec <gets+0x56>
    cc = read(0, &c, 1);
 1c8:	8656                	mv	a2,s5
 1ca:	85da                	mv	a1,s6
 1cc:	4501                	li	a0,0
 1ce:	1bc000ef          	jal	38a <read>
    if(cc < 1)
 1d2:	00a05d63          	blez	a0,1ec <gets+0x56>
      break;
    buf[i++] = c;
 1d6:	faf44783          	lbu	a5,-81(s0)
 1da:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1de:	0905                	addi	s2,s2,1
 1e0:	ff678713          	addi	a4,a5,-10
 1e4:	c319                	beqz	a4,1ea <gets+0x54>
 1e6:	17cd                	addi	a5,a5,-13
 1e8:	fbf1                	bnez	a5,1bc <gets+0x26>
    buf[i++] = c;
 1ea:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1ec:	9c5e                	add	s8,s8,s7
 1ee:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1f2:	855e                	mv	a0,s7
 1f4:	60e6                	ld	ra,88(sp)
 1f6:	6446                	ld	s0,80(sp)
 1f8:	64a6                	ld	s1,72(sp)
 1fa:	6906                	ld	s2,64(sp)
 1fc:	79e2                	ld	s3,56(sp)
 1fe:	7a42                	ld	s4,48(sp)
 200:	7aa2                	ld	s5,40(sp)
 202:	7b02                	ld	s6,32(sp)
 204:	6be2                	ld	s7,24(sp)
 206:	6c42                	ld	s8,16(sp)
 208:	6125                	addi	sp,sp,96
 20a:	8082                	ret

000000000000020c <stat>:

int
stat(const char *n, struct stat *st)
{
 20c:	1101                	addi	sp,sp,-32
 20e:	ec06                	sd	ra,24(sp)
 210:	e822                	sd	s0,16(sp)
 212:	e04a                	sd	s2,0(sp)
 214:	1000                	addi	s0,sp,32
 216:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 218:	4581                	li	a1,0
 21a:	198000ef          	jal	3b2 <open>
  if(fd < 0)
 21e:	02054263          	bltz	a0,242 <stat+0x36>
 222:	e426                	sd	s1,8(sp)
 224:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 226:	85ca                	mv	a1,s2
 228:	1a2000ef          	jal	3ca <fstat>
 22c:	892a                	mv	s2,a0
  close(fd);
 22e:	8526                	mv	a0,s1
 230:	16a000ef          	jal	39a <close>
  return r;
 234:	64a2                	ld	s1,8(sp)
}
 236:	854a                	mv	a0,s2
 238:	60e2                	ld	ra,24(sp)
 23a:	6442                	ld	s0,16(sp)
 23c:	6902                	ld	s2,0(sp)
 23e:	6105                	addi	sp,sp,32
 240:	8082                	ret
    return -1;
 242:	57fd                	li	a5,-1
 244:	893e                	mv	s2,a5
 246:	bfc5                	j	236 <stat+0x2a>

0000000000000248 <atoi>:

int
atoi(const char *s)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e406                	sd	ra,8(sp)
 24c:	e022                	sd	s0,0(sp)
 24e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 250:	00054683          	lbu	a3,0(a0)
 254:	fd06879b          	addiw	a5,a3,-48
 258:	0ff7f793          	zext.b	a5,a5
 25c:	4625                	li	a2,9
 25e:	02f66963          	bltu	a2,a5,290 <atoi+0x48>
 262:	872a                	mv	a4,a0
  n = 0;
 264:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 266:	0705                	addi	a4,a4,1
 268:	0025179b          	slliw	a5,a0,0x2
 26c:	9fa9                	addw	a5,a5,a0
 26e:	0017979b          	slliw	a5,a5,0x1
 272:	9fb5                	addw	a5,a5,a3
 274:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 278:	00074683          	lbu	a3,0(a4)
 27c:	fd06879b          	addiw	a5,a3,-48
 280:	0ff7f793          	zext.b	a5,a5
 284:	fef671e3          	bgeu	a2,a5,266 <atoi+0x1e>
  return n;
}
 288:	60a2                	ld	ra,8(sp)
 28a:	6402                	ld	s0,0(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
  n = 0;
 290:	4501                	li	a0,0
 292:	bfdd                	j	288 <atoi+0x40>

0000000000000294 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e406                	sd	ra,8(sp)
 298:	e022                	sd	s0,0(sp)
 29a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29c:	02b57563          	bgeu	a0,a1,2c6 <memmove+0x32>
    while(n-- > 0)
 2a0:	00c05f63          	blez	a2,2be <memmove+0x2a>
 2a4:	1602                	slli	a2,a2,0x20
 2a6:	9201                	srli	a2,a2,0x20
 2a8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ac:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ae:	0585                	addi	a1,a1,1
 2b0:	0705                	addi	a4,a4,1
 2b2:	fff5c683          	lbu	a3,-1(a1)
 2b6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ba:	fee79ae3          	bne	a5,a4,2ae <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2be:	60a2                	ld	ra,8(sp)
 2c0:	6402                	ld	s0,0(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
    while(n-- > 0)
 2c6:	fec05ce3          	blez	a2,2be <memmove+0x2a>
    dst += n;
 2ca:	00c50733          	add	a4,a0,a2
    src += n;
 2ce:	95b2                	add	a1,a1,a2
 2d0:	fff6079b          	addiw	a5,a2,-1
 2d4:	1782                	slli	a5,a5,0x20
 2d6:	9381                	srli	a5,a5,0x20
 2d8:	fff7c793          	not	a5,a5
 2dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2de:	15fd                	addi	a1,a1,-1
 2e0:	177d                	addi	a4,a4,-1
 2e2:	0005c683          	lbu	a3,0(a1)
 2e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ea:	fef71ae3          	bne	a4,a5,2de <memmove+0x4a>
 2ee:	bfc1                	j	2be <memmove+0x2a>

00000000000002f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f8:	c61d                	beqz	a2,326 <memcmp+0x36>
 2fa:	1602                	slli	a2,a2,0x20
 2fc:	9201                	srli	a2,a2,0x20
 2fe:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 302:	00054783          	lbu	a5,0(a0)
 306:	0005c703          	lbu	a4,0(a1)
 30a:	00e79863          	bne	a5,a4,31a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 30e:	0505                	addi	a0,a0,1
    p2++;
 310:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 312:	fed518e3          	bne	a0,a3,302 <memcmp+0x12>
  }
  return 0;
 316:	4501                	li	a0,0
 318:	a019                	j	31e <memcmp+0x2e>
      return *p1 - *p2;
 31a:	40e7853b          	subw	a0,a5,a4
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  return 0;
 326:	4501                	li	a0,0
 328:	bfdd                	j	31e <memcmp+0x2e>

000000000000032a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 332:	f63ff0ef          	jal	294 <memmove>
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <sbrk>:

char *
sbrk(int n) {
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 346:	4585                	li	a1,1
 348:	0b2000ef          	jal	3fa <sys_sbrk>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <sbrklazy>:

char *
sbrklazy(int n) {
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 35c:	4589                	li	a1,2
 35e:	09c000ef          	jal	3fa <sys_sbrk>
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 36a:	4885                	li	a7,1
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <exit>:
.global exit
exit:
 li a7, SYS_exit
 372:	4889                	li	a7,2
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <wait>:
.global wait
wait:
 li a7, SYS_wait
 37a:	488d                	li	a7,3
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 382:	4891                	li	a7,4
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <read>:
.global read
read:
 li a7, SYS_read
 38a:	4895                	li	a7,5
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <write>:
.global write
write:
 li a7, SYS_write
 392:	48c1                	li	a7,16
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <close>:
.global close
close:
 li a7, SYS_close
 39a:	48d5                	li	a7,21
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a2:	4899                	li	a7,6
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <exec>:
.global exec
exec:
 li a7, SYS_exec
 3aa:	489d                	li	a7,7
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <open>:
.global open
open:
 li a7, SYS_open
 3b2:	48bd                	li	a7,15
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ba:	48c5                	li	a7,17
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c2:	48c9                	li	a7,18
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ca:	48a1                	li	a7,8
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <link>:
.global link
link:
 li a7, SYS_link
 3d2:	48cd                	li	a7,19
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3da:	48d1                	li	a7,20
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e2:	48a5                	li	a7,9
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ea:	48a9                	li	a7,10
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f2:	48ad                	li	a7,11
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3fa:	48b1                	li	a7,12
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <pause>:
.global pause
pause:
 li a7, SYS_pause
 402:	48b5                	li	a7,13
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 40a:	48b9                	li	a7,14
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <csread>:
.global csread
csread:
 li a7, SYS_csread
 412:	48d9                	li	a7,22
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 41a:	48dd                	li	a7,23
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 422:	48e1                	li	a7,24
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <memread>:
.global memread
memread:
 li a7, SYS_memread
 42a:	48e5                	li	a7,25
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 432:	1101                	addi	sp,sp,-32
 434:	ec06                	sd	ra,24(sp)
 436:	e822                	sd	s0,16(sp)
 438:	1000                	addi	s0,sp,32
 43a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43e:	4605                	li	a2,1
 440:	fef40593          	addi	a1,s0,-17
 444:	f4fff0ef          	jal	392 <write>
}
 448:	60e2                	ld	ra,24(sp)
 44a:	6442                	ld	s0,16(sp)
 44c:	6105                	addi	sp,sp,32
 44e:	8082                	ret

0000000000000450 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 450:	715d                	addi	sp,sp,-80
 452:	e486                	sd	ra,72(sp)
 454:	e0a2                	sd	s0,64(sp)
 456:	f84a                	sd	s2,48(sp)
 458:	f44e                	sd	s3,40(sp)
 45a:	0880                	addi	s0,sp,80
 45c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 45e:	c6d1                	beqz	a3,4ea <printint+0x9a>
 460:	0805d563          	bgez	a1,4ea <printint+0x9a>
    neg = 1;
    x = -xx;
 464:	40b005b3          	neg	a1,a1
    neg = 1;
 468:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 46a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 46e:	86ce                	mv	a3,s3
  i = 0;
 470:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 472:	00000817          	auipc	a6,0x0
 476:	59e80813          	addi	a6,a6,1438 # a10 <digits>
 47a:	88ba                	mv	a7,a4
 47c:	0017051b          	addiw	a0,a4,1
 480:	872a                	mv	a4,a0
 482:	02c5f7b3          	remu	a5,a1,a2
 486:	97c2                	add	a5,a5,a6
 488:	0007c783          	lbu	a5,0(a5)
 48c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 490:	87ae                	mv	a5,a1
 492:	02c5d5b3          	divu	a1,a1,a2
 496:	0685                	addi	a3,a3,1
 498:	fec7f1e3          	bgeu	a5,a2,47a <printint+0x2a>
  if(neg)
 49c:	00030c63          	beqz	t1,4b4 <printint+0x64>
    buf[i++] = '-';
 4a0:	fd050793          	addi	a5,a0,-48
 4a4:	00878533          	add	a0,a5,s0
 4a8:	02d00793          	li	a5,45
 4ac:	fef50423          	sb	a5,-24(a0)
 4b0:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4b4:	02e05563          	blez	a4,4de <printint+0x8e>
 4b8:	fc26                	sd	s1,56(sp)
 4ba:	377d                	addiw	a4,a4,-1
 4bc:	00e984b3          	add	s1,s3,a4
 4c0:	19fd                	addi	s3,s3,-1
 4c2:	99ba                	add	s3,s3,a4
 4c4:	1702                	slli	a4,a4,0x20
 4c6:	9301                	srli	a4,a4,0x20
 4c8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4cc:	0004c583          	lbu	a1,0(s1)
 4d0:	854a                	mv	a0,s2
 4d2:	f61ff0ef          	jal	432 <putc>
  while(--i >= 0)
 4d6:	14fd                	addi	s1,s1,-1
 4d8:	ff349ae3          	bne	s1,s3,4cc <printint+0x7c>
 4dc:	74e2                	ld	s1,56(sp)
}
 4de:	60a6                	ld	ra,72(sp)
 4e0:	6406                	ld	s0,64(sp)
 4e2:	7942                	ld	s2,48(sp)
 4e4:	79a2                	ld	s3,40(sp)
 4e6:	6161                	addi	sp,sp,80
 4e8:	8082                	ret
  neg = 0;
 4ea:	4301                	li	t1,0
 4ec:	bfbd                	j	46a <printint+0x1a>

00000000000004ee <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ee:	711d                	addi	sp,sp,-96
 4f0:	ec86                	sd	ra,88(sp)
 4f2:	e8a2                	sd	s0,80(sp)
 4f4:	e4a6                	sd	s1,72(sp)
 4f6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f8:	0005c483          	lbu	s1,0(a1)
 4fc:	22048363          	beqz	s1,722 <vprintf+0x234>
 500:	e0ca                	sd	s2,64(sp)
 502:	fc4e                	sd	s3,56(sp)
 504:	f852                	sd	s4,48(sp)
 506:	f456                	sd	s5,40(sp)
 508:	f05a                	sd	s6,32(sp)
 50a:	ec5e                	sd	s7,24(sp)
 50c:	e862                	sd	s8,16(sp)
 50e:	8b2a                	mv	s6,a0
 510:	8a2e                	mv	s4,a1
 512:	8bb2                	mv	s7,a2
  state = 0;
 514:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 516:	4901                	li	s2,0
 518:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 51a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 51e:	06400c13          	li	s8,100
 522:	a00d                	j	544 <vprintf+0x56>
        putc(fd, c0);
 524:	85a6                	mv	a1,s1
 526:	855a                	mv	a0,s6
 528:	f0bff0ef          	jal	432 <putc>
 52c:	a019                	j	532 <vprintf+0x44>
    } else if(state == '%'){
 52e:	03598363          	beq	s3,s5,554 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 532:	0019079b          	addiw	a5,s2,1
 536:	893e                	mv	s2,a5
 538:	873e                	mv	a4,a5
 53a:	97d2                	add	a5,a5,s4
 53c:	0007c483          	lbu	s1,0(a5)
 540:	1c048a63          	beqz	s1,714 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 544:	0004879b          	sext.w	a5,s1
    if(state == 0){
 548:	fe0993e3          	bnez	s3,52e <vprintf+0x40>
      if(c0 == '%'){
 54c:	fd579ce3          	bne	a5,s5,524 <vprintf+0x36>
        state = '%';
 550:	89be                	mv	s3,a5
 552:	b7c5                	j	532 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 554:	00ea06b3          	add	a3,s4,a4
 558:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 55c:	1c060863          	beqz	a2,72c <vprintf+0x23e>
      if(c0 == 'd'){
 560:	03878763          	beq	a5,s8,58e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 564:	f9478693          	addi	a3,a5,-108
 568:	0016b693          	seqz	a3,a3
 56c:	f9c60593          	addi	a1,a2,-100
 570:	e99d                	bnez	a1,5a6 <vprintf+0xb8>
 572:	ca95                	beqz	a3,5a6 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 574:	008b8493          	addi	s1,s7,8
 578:	4685                	li	a3,1
 57a:	4629                	li	a2,10
 57c:	000bb583          	ld	a1,0(s7)
 580:	855a                	mv	a0,s6
 582:	ecfff0ef          	jal	450 <printint>
        i += 1;
 586:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 588:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 58a:	4981                	li	s3,0
 58c:	b75d                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 58e:	008b8493          	addi	s1,s7,8
 592:	4685                	li	a3,1
 594:	4629                	li	a2,10
 596:	000ba583          	lw	a1,0(s7)
 59a:	855a                	mv	a0,s6
 59c:	eb5ff0ef          	jal	450 <printint>
 5a0:	8ba6                	mv	s7,s1
      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	b779                	j	532 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 5a6:	9752                	add	a4,a4,s4
 5a8:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ac:	f9460713          	addi	a4,a2,-108
 5b0:	00173713          	seqz	a4,a4
 5b4:	8f75                	and	a4,a4,a3
 5b6:	f9c58513          	addi	a0,a1,-100
 5ba:	18051363          	bnez	a0,740 <vprintf+0x252>
 5be:	18070163          	beqz	a4,740 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c2:	008b8493          	addi	s1,s7,8
 5c6:	4685                	li	a3,1
 5c8:	4629                	li	a2,10
 5ca:	000bb583          	ld	a1,0(s7)
 5ce:	855a                	mv	a0,s6
 5d0:	e81ff0ef          	jal	450 <printint>
        i += 2;
 5d4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d6:	8ba6                	mv	s7,s1
      state = 0;
 5d8:	4981                	li	s3,0
        i += 2;
 5da:	bfa1                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5dc:	008b8493          	addi	s1,s7,8
 5e0:	4681                	li	a3,0
 5e2:	4629                	li	a2,10
 5e4:	000be583          	lwu	a1,0(s7)
 5e8:	855a                	mv	a0,s6
 5ea:	e67ff0ef          	jal	450 <printint>
 5ee:	8ba6                	mv	s7,s1
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b781                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f4:	008b8493          	addi	s1,s7,8
 5f8:	4681                	li	a3,0
 5fa:	4629                	li	a2,10
 5fc:	000bb583          	ld	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	e4fff0ef          	jal	450 <printint>
        i += 1;
 606:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 608:	8ba6                	mv	s7,s1
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b71d                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60e:	008b8493          	addi	s1,s7,8
 612:	4681                	li	a3,0
 614:	4629                	li	a2,10
 616:	000bb583          	ld	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	e35ff0ef          	jal	450 <printint>
        i += 2;
 620:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 622:	8ba6                	mv	s7,s1
      state = 0;
 624:	4981                	li	s3,0
        i += 2;
 626:	b731                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 628:	008b8493          	addi	s1,s7,8
 62c:	4681                	li	a3,0
 62e:	4641                	li	a2,16
 630:	000be583          	lwu	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	e1bff0ef          	jal	450 <printint>
 63a:	8ba6                	mv	s7,s1
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bdd5                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 640:	008b8493          	addi	s1,s7,8
 644:	4681                	li	a3,0
 646:	4641                	li	a2,16
 648:	000bb583          	ld	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e03ff0ef          	jal	450 <printint>
        i += 1;
 652:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 654:	8ba6                	mv	s7,s1
      state = 0;
 656:	4981                	li	s3,0
 658:	bde9                	j	532 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 65a:	008b8493          	addi	s1,s7,8
 65e:	4681                	li	a3,0
 660:	4641                	li	a2,16
 662:	000bb583          	ld	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	de9ff0ef          	jal	450 <printint>
        i += 2;
 66c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 66e:	8ba6                	mv	s7,s1
      state = 0;
 670:	4981                	li	s3,0
        i += 2;
 672:	b5c1                	j	532 <vprintf+0x44>
 674:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 676:	008b8793          	addi	a5,s7,8
 67a:	8cbe                	mv	s9,a5
 67c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 680:	03000593          	li	a1,48
 684:	855a                	mv	a0,s6
 686:	dadff0ef          	jal	432 <putc>
  putc(fd, 'x');
 68a:	07800593          	li	a1,120
 68e:	855a                	mv	a0,s6
 690:	da3ff0ef          	jal	432 <putc>
 694:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 696:	00000b97          	auipc	s7,0x0
 69a:	37ab8b93          	addi	s7,s7,890 # a10 <digits>
 69e:	03c9d793          	srli	a5,s3,0x3c
 6a2:	97de                	add	a5,a5,s7
 6a4:	0007c583          	lbu	a1,0(a5)
 6a8:	855a                	mv	a0,s6
 6aa:	d89ff0ef          	jal	432 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ae:	0992                	slli	s3,s3,0x4
 6b0:	34fd                	addiw	s1,s1,-1
 6b2:	f4f5                	bnez	s1,69e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6b4:	8be6                	mv	s7,s9
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	6ca2                	ld	s9,8(sp)
 6ba:	bda5                	j	532 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6bc:	008b8493          	addi	s1,s7,8
 6c0:	000bc583          	lbu	a1,0(s7)
 6c4:	855a                	mv	a0,s6
 6c6:	d6dff0ef          	jal	432 <putc>
 6ca:	8ba6                	mv	s7,s1
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b595                	j	532 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6d0:	008b8993          	addi	s3,s7,8
 6d4:	000bb483          	ld	s1,0(s7)
 6d8:	cc91                	beqz	s1,6f4 <vprintf+0x206>
        for(; *s; s++)
 6da:	0004c583          	lbu	a1,0(s1)
 6de:	c985                	beqz	a1,70e <vprintf+0x220>
          putc(fd, *s);
 6e0:	855a                	mv	a0,s6
 6e2:	d51ff0ef          	jal	432 <putc>
        for(; *s; s++)
 6e6:	0485                	addi	s1,s1,1
 6e8:	0004c583          	lbu	a1,0(s1)
 6ec:	f9f5                	bnez	a1,6e0 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6ee:	8bce                	mv	s7,s3
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b581                	j	532 <vprintf+0x44>
          s = "(null)";
 6f4:	00000497          	auipc	s1,0x0
 6f8:	31448493          	addi	s1,s1,788 # a08 <malloc+0x178>
        for(; *s; s++)
 6fc:	02800593          	li	a1,40
 700:	b7c5                	j	6e0 <vprintf+0x1f2>
        putc(fd, '%');
 702:	85be                	mv	a1,a5
 704:	855a                	mv	a0,s6
 706:	d2dff0ef          	jal	432 <putc>
      state = 0;
 70a:	4981                	li	s3,0
 70c:	b51d                	j	532 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 70e:	8bce                	mv	s7,s3
      state = 0;
 710:	4981                	li	s3,0
 712:	b505                	j	532 <vprintf+0x44>
 714:	6906                	ld	s2,64(sp)
 716:	79e2                	ld	s3,56(sp)
 718:	7a42                	ld	s4,48(sp)
 71a:	7aa2                	ld	s5,40(sp)
 71c:	7b02                	ld	s6,32(sp)
 71e:	6be2                	ld	s7,24(sp)
 720:	6c42                	ld	s8,16(sp)
    }
  }
}
 722:	60e6                	ld	ra,88(sp)
 724:	6446                	ld	s0,80(sp)
 726:	64a6                	ld	s1,72(sp)
 728:	6125                	addi	sp,sp,96
 72a:	8082                	ret
      if(c0 == 'd'){
 72c:	06400713          	li	a4,100
 730:	e4e78fe3          	beq	a5,a4,58e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 734:	f9478693          	addi	a3,a5,-108
 738:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 73c:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 73e:	4701                	li	a4,0
      } else if(c0 == 'u'){
 740:	07500513          	li	a0,117
 744:	e8a78ce3          	beq	a5,a0,5dc <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 748:	f8b60513          	addi	a0,a2,-117
 74c:	e119                	bnez	a0,752 <vprintf+0x264>
 74e:	ea0693e3          	bnez	a3,5f4 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 752:	f8b58513          	addi	a0,a1,-117
 756:	e119                	bnez	a0,75c <vprintf+0x26e>
 758:	ea071be3          	bnez	a4,60e <vprintf+0x120>
      } else if(c0 == 'x'){
 75c:	07800513          	li	a0,120
 760:	eca784e3          	beq	a5,a0,628 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 764:	f8860613          	addi	a2,a2,-120
 768:	e219                	bnez	a2,76e <vprintf+0x280>
 76a:	ec069be3          	bnez	a3,640 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 76e:	f8858593          	addi	a1,a1,-120
 772:	e199                	bnez	a1,778 <vprintf+0x28a>
 774:	ee0713e3          	bnez	a4,65a <vprintf+0x16c>
      } else if(c0 == 'p'){
 778:	07000713          	li	a4,112
 77c:	eee78ce3          	beq	a5,a4,674 <vprintf+0x186>
      } else if(c0 == 'c'){
 780:	06300713          	li	a4,99
 784:	f2e78ce3          	beq	a5,a4,6bc <vprintf+0x1ce>
      } else if(c0 == 's'){
 788:	07300713          	li	a4,115
 78c:	f4e782e3          	beq	a5,a4,6d0 <vprintf+0x1e2>
      } else if(c0 == '%'){
 790:	02500713          	li	a4,37
 794:	f6e787e3          	beq	a5,a4,702 <vprintf+0x214>
        putc(fd, '%');
 798:	02500593          	li	a1,37
 79c:	855a                	mv	a0,s6
 79e:	c95ff0ef          	jal	432 <putc>
        putc(fd, c0);
 7a2:	85a6                	mv	a1,s1
 7a4:	855a                	mv	a0,s6
 7a6:	c8dff0ef          	jal	432 <putc>
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b359                	j	532 <vprintf+0x44>

00000000000007ae <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ae:	715d                	addi	sp,sp,-80
 7b0:	ec06                	sd	ra,24(sp)
 7b2:	e822                	sd	s0,16(sp)
 7b4:	1000                	addi	s0,sp,32
 7b6:	e010                	sd	a2,0(s0)
 7b8:	e414                	sd	a3,8(s0)
 7ba:	e818                	sd	a4,16(s0)
 7bc:	ec1c                	sd	a5,24(s0)
 7be:	03043023          	sd	a6,32(s0)
 7c2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c6:	8622                	mv	a2,s0
 7c8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7cc:	d23ff0ef          	jal	4ee <vprintf>
}
 7d0:	60e2                	ld	ra,24(sp)
 7d2:	6442                	ld	s0,16(sp)
 7d4:	6161                	addi	sp,sp,80
 7d6:	8082                	ret

00000000000007d8 <printf>:

void
printf(const char *fmt, ...)
{
 7d8:	711d                	addi	sp,sp,-96
 7da:	ec06                	sd	ra,24(sp)
 7dc:	e822                	sd	s0,16(sp)
 7de:	1000                	addi	s0,sp,32
 7e0:	e40c                	sd	a1,8(s0)
 7e2:	e810                	sd	a2,16(s0)
 7e4:	ec14                	sd	a3,24(s0)
 7e6:	f018                	sd	a4,32(s0)
 7e8:	f41c                	sd	a5,40(s0)
 7ea:	03043823          	sd	a6,48(s0)
 7ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f2:	00840613          	addi	a2,s0,8
 7f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7fa:	85aa                	mv	a1,a0
 7fc:	4505                	li	a0,1
 7fe:	cf1ff0ef          	jal	4ee <vprintf>
}
 802:	60e2                	ld	ra,24(sp)
 804:	6442                	ld	s0,16(sp)
 806:	6125                	addi	sp,sp,96
 808:	8082                	ret

000000000000080a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80a:	1141                	addi	sp,sp,-16
 80c:	e406                	sd	ra,8(sp)
 80e:	e022                	sd	s0,0(sp)
 810:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 812:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 816:	00000797          	auipc	a5,0x0
 81a:	7fa7b783          	ld	a5,2042(a5) # 1010 <freep>
 81e:	a039                	j	82c <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 820:	6398                	ld	a4,0(a5)
 822:	00e7e463          	bltu	a5,a4,82a <free+0x20>
 826:	00e6ea63          	bltu	a3,a4,83a <free+0x30>
{
 82a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82c:	fed7fae3          	bgeu	a5,a3,820 <free+0x16>
 830:	6398                	ld	a4,0(a5)
 832:	00e6e463          	bltu	a3,a4,83a <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 836:	fee7eae3          	bltu	a5,a4,82a <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 83a:	ff852583          	lw	a1,-8(a0)
 83e:	6390                	ld	a2,0(a5)
 840:	02059813          	slli	a6,a1,0x20
 844:	01c85713          	srli	a4,a6,0x1c
 848:	9736                	add	a4,a4,a3
 84a:	02e60563          	beq	a2,a4,874 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 84e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 852:	4790                	lw	a2,8(a5)
 854:	02061593          	slli	a1,a2,0x20
 858:	01c5d713          	srli	a4,a1,0x1c
 85c:	973e                	add	a4,a4,a5
 85e:	02e68263          	beq	a3,a4,882 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 862:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 864:	00000717          	auipc	a4,0x0
 868:	7af73623          	sd	a5,1964(a4) # 1010 <freep>
}
 86c:	60a2                	ld	ra,8(sp)
 86e:	6402                	ld	s0,0(sp)
 870:	0141                	addi	sp,sp,16
 872:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 874:	4618                	lw	a4,8(a2)
 876:	9f2d                	addw	a4,a4,a1
 878:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87c:	6398                	ld	a4,0(a5)
 87e:	6310                	ld	a2,0(a4)
 880:	b7f9                	j	84e <free+0x44>
    p->s.size += bp->s.size;
 882:	ff852703          	lw	a4,-8(a0)
 886:	9f31                	addw	a4,a4,a2
 888:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 88a:	ff053683          	ld	a3,-16(a0)
 88e:	bfd1                	j	862 <free+0x58>

0000000000000890 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 890:	7139                	addi	sp,sp,-64
 892:	fc06                	sd	ra,56(sp)
 894:	f822                	sd	s0,48(sp)
 896:	f04a                	sd	s2,32(sp)
 898:	ec4e                	sd	s3,24(sp)
 89a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89c:	02051993          	slli	s3,a0,0x20
 8a0:	0209d993          	srli	s3,s3,0x20
 8a4:	09bd                	addi	s3,s3,15
 8a6:	0049d993          	srli	s3,s3,0x4
 8aa:	2985                	addiw	s3,s3,1
 8ac:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8ae:	00000517          	auipc	a0,0x0
 8b2:	76253503          	ld	a0,1890(a0) # 1010 <freep>
 8b6:	c905                	beqz	a0,8e6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ba:	4798                	lw	a4,8(a5)
 8bc:	09377663          	bgeu	a4,s3,948 <malloc+0xb8>
 8c0:	f426                	sd	s1,40(sp)
 8c2:	e852                	sd	s4,16(sp)
 8c4:	e456                	sd	s5,8(sp)
 8c6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8c8:	8a4e                	mv	s4,s3
 8ca:	6705                	lui	a4,0x1
 8cc:	00e9f363          	bgeu	s3,a4,8d2 <malloc+0x42>
 8d0:	6a05                	lui	s4,0x1
 8d2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8da:	00000497          	auipc	s1,0x0
 8de:	73648493          	addi	s1,s1,1846 # 1010 <freep>
  if(p == SBRK_ERROR)
 8e2:	5afd                	li	s5,-1
 8e4:	a83d                	j	922 <malloc+0x92>
 8e6:	f426                	sd	s1,40(sp)
 8e8:	e852                	sd	s4,16(sp)
 8ea:	e456                	sd	s5,8(sp)
 8ec:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ee:	00000797          	auipc	a5,0x0
 8f2:	73278793          	addi	a5,a5,1842 # 1020 <base>
 8f6:	00000717          	auipc	a4,0x0
 8fa:	70f73d23          	sd	a5,1818(a4) # 1010 <freep>
 8fe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 900:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 904:	b7d1                	j	8c8 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 906:	6398                	ld	a4,0(a5)
 908:	e118                	sd	a4,0(a0)
 90a:	a899                	j	960 <malloc+0xd0>
  hp->s.size = nu;
 90c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 910:	0541                	addi	a0,a0,16
 912:	ef9ff0ef          	jal	80a <free>
  return freep;
 916:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 918:	c125                	beqz	a0,978 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 91c:	4798                	lw	a4,8(a5)
 91e:	03277163          	bgeu	a4,s2,940 <malloc+0xb0>
    if(p == freep)
 922:	6098                	ld	a4,0(s1)
 924:	853e                	mv	a0,a5
 926:	fef71ae3          	bne	a4,a5,91a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 92a:	8552                	mv	a0,s4
 92c:	a13ff0ef          	jal	33e <sbrk>
  if(p == SBRK_ERROR)
 930:	fd551ee3          	bne	a0,s5,90c <malloc+0x7c>
        return 0;
 934:	4501                	li	a0,0
 936:	74a2                	ld	s1,40(sp)
 938:	6a42                	ld	s4,16(sp)
 93a:	6aa2                	ld	s5,8(sp)
 93c:	6b02                	ld	s6,0(sp)
 93e:	a03d                	j	96c <malloc+0xdc>
 940:	74a2                	ld	s1,40(sp)
 942:	6a42                	ld	s4,16(sp)
 944:	6aa2                	ld	s5,8(sp)
 946:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 948:	fae90fe3          	beq	s2,a4,906 <malloc+0x76>
        p->s.size -= nunits;
 94c:	4137073b          	subw	a4,a4,s3
 950:	c798                	sw	a4,8(a5)
        p += p->s.size;
 952:	02071693          	slli	a3,a4,0x20
 956:	01c6d713          	srli	a4,a3,0x1c
 95a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 95c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 960:	00000717          	auipc	a4,0x0
 964:	6aa73823          	sd	a0,1712(a4) # 1010 <freep>
      return (void*)(p + 1);
 968:	01078513          	addi	a0,a5,16
  }
}
 96c:	70e2                	ld	ra,56(sp)
 96e:	7442                	ld	s0,48(sp)
 970:	7902                	ld	s2,32(sp)
 972:	69e2                	ld	s3,24(sp)
 974:	6121                	addi	sp,sp,64
 976:	8082                	ret
 978:	74a2                	ld	s1,40(sp)
 97a:	6a42                	ld	s4,16(sp)
 97c:	6aa2                	ld	s5,8(sp)
 97e:	6b02                	ld	s6,0(sp)
 980:	b7f5                	j	96c <malloc+0xdc>
