
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	fe2d8d93          	addi	s11,s11,-30 # 1010 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	9f8a0a13          	addi	s4,s4,-1544 # a30 <malloc+0x106>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a035                	j	6e <wc+0x6e>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	1ba000ef          	jal	200 <strchr>
  4a:	c919                	beqz	a0,60 <wc+0x60>
        inword = 0;
  4c:	895e                	mv	s2,s7
    for(i=0; i<n; i++){
  4e:	0485                	addi	s1,s1,1
  50:	01348d63          	beq	s1,s3,6a <wc+0x6a>
      if(buf[i] == '\n')
  54:	0004c583          	lbu	a1,0(s1)
  58:	ff5596e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  5c:	2c05                	addiw	s8,s8,1
  5e:	b7dd                	j	44 <wc+0x44>
      else if(!inword){
  60:	fe0917e3          	bnez	s2,4e <wc+0x4e>
        w++;
  64:	2c85                	addiw	s9,s9,1
        inword = 1;
  66:	4905                	li	s2,1
  68:	b7dd                	j	4e <wc+0x4e>
  6a:	01ab0d3b          	addw	s10,s6,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  6e:	20000613          	li	a2,512
  72:	85ee                	mv	a1,s11
  74:	f8843503          	ld	a0,-120(s0)
  78:	3ce000ef          	jal	446 <read>
  7c:	8b2a                	mv	s6,a0
  7e:	00a05963          	blez	a0,90 <wc+0x90>
    for(i=0; i<n; i++){
  82:	00001497          	auipc	s1,0x1
  86:	f8e48493          	addi	s1,s1,-114 # 1010 <buf>
  8a:	009509b3          	add	s3,a0,s1
  8e:	b7d9                	j	54 <wc+0x54>
      }
    }
  }
  if(n < 0){
  90:	02054c63          	bltz	a0,c8 <wc+0xc8>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  94:	f8043703          	ld	a4,-128(s0)
  98:	86ea                	mv	a3,s10
  9a:	8666                	mv	a2,s9
  9c:	85e2                	mv	a1,s8
  9e:	00001517          	auipc	a0,0x1
  a2:	9b250513          	addi	a0,a0,-1614 # a50 <malloc+0x126>
  a6:	7d0000ef          	jal	876 <printf>
}
  aa:	70e6                	ld	ra,120(sp)
  ac:	7446                	ld	s0,112(sp)
  ae:	74a6                	ld	s1,104(sp)
  b0:	7906                	ld	s2,96(sp)
  b2:	69e6                	ld	s3,88(sp)
  b4:	6a46                	ld	s4,80(sp)
  b6:	6aa6                	ld	s5,72(sp)
  b8:	6b06                	ld	s6,64(sp)
  ba:	7be2                	ld	s7,56(sp)
  bc:	7c42                	ld	s8,48(sp)
  be:	7ca2                	ld	s9,40(sp)
  c0:	7d02                	ld	s10,32(sp)
  c2:	6de2                	ld	s11,24(sp)
  c4:	6109                	addi	sp,sp,128
  c6:	8082                	ret
    printf("wc: read error\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	97850513          	addi	a0,a0,-1672 # a40 <malloc+0x116>
  d0:	7a6000ef          	jal	876 <printf>
    exit(1);
  d4:	4505                	li	a0,1
  d6:	358000ef          	jal	42e <exit>

00000000000000da <main>:

int
main(int argc, char *argv[])
{
  da:	7179                	addi	sp,sp,-48
  dc:	f406                	sd	ra,40(sp)
  de:	f022                	sd	s0,32(sp)
  e0:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  e2:	4785                	li	a5,1
  e4:	04a7d463          	bge	a5,a0,12c <main+0x52>
  e8:	ec26                	sd	s1,24(sp)
  ea:	e84a                	sd	s2,16(sp)
  ec:	e44e                	sd	s3,8(sp)
  ee:	00858913          	addi	s2,a1,8
  f2:	ffe5099b          	addiw	s3,a0,-2
  f6:	02099793          	slli	a5,s3,0x20
  fa:	01d7d993          	srli	s3,a5,0x1d
  fe:	05c1                	addi	a1,a1,16
 100:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
 102:	4581                	li	a1,0
 104:	00093503          	ld	a0,0(s2)
 108:	366000ef          	jal	46e <open>
 10c:	84aa                	mv	s1,a0
 10e:	02054c63          	bltz	a0,146 <main+0x6c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 112:	00093583          	ld	a1,0(s2)
 116:	eebff0ef          	jal	0 <wc>
    close(fd);
 11a:	8526                	mv	a0,s1
 11c:	33a000ef          	jal	456 <close>
  for(i = 1; i < argc; i++){
 120:	0921                	addi	s2,s2,8
 122:	ff3910e3          	bne	s2,s3,102 <main+0x28>
  }
  exit(0);
 126:	4501                	li	a0,0
 128:	306000ef          	jal	42e <exit>
 12c:	ec26                	sd	s1,24(sp)
 12e:	e84a                	sd	s2,16(sp)
 130:	e44e                	sd	s3,8(sp)
    wc(0, "");
 132:	00001597          	auipc	a1,0x1
 136:	90658593          	addi	a1,a1,-1786 # a38 <malloc+0x10e>
 13a:	4501                	li	a0,0
 13c:	ec5ff0ef          	jal	0 <wc>
    exit(0);
 140:	4501                	li	a0,0
 142:	2ec000ef          	jal	42e <exit>
      printf("wc: cannot open %s\n", argv[i]);
 146:	00093583          	ld	a1,0(s2)
 14a:	00001517          	auipc	a0,0x1
 14e:	91650513          	addi	a0,a0,-1770 # a60 <malloc+0x136>
 152:	724000ef          	jal	876 <printf>
      exit(1);
 156:	4505                	li	a0,1
 158:	2d6000ef          	jal	42e <exit>

000000000000015c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 164:	f77ff0ef          	jal	da <main>
  exit(r);
 168:	2c6000ef          	jal	42e <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 172:	87aa                	mv	a5,a0
 174:	0585                	addi	a1,a1,1
 176:	0785                	addi	a5,a5,1
 178:	fff5c703          	lbu	a4,-1(a1)
 17c:	fee78fa3          	sb	a4,-1(a5)
 180:	fb75                	bnez	a4,174 <strcpy+0x8>
    ;
  return os;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb91                	beqz	a5,1a6 <strcmp+0x1e>
 194:	0005c703          	lbu	a4,0(a1)
 198:	00f71763          	bne	a4,a5,1a6 <strcmp+0x1e>
    p++, q++;
 19c:	0505                	addi	a0,a0,1
 19e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbe5                	bnez	a5,194 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	addi	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	86be                	mv	a3,a5
 1c6:	0785                	addi	a5,a5,1
 1c8:	fff7c703          	lbu	a4,-1(a5)
 1cc:	ff65                	bnez	a4,1c4 <strlen+0x10>
 1ce:	40a6853b          	subw	a0,a3,a0
 1d2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ca19                	beqz	a2,1fa <memset+0x1c>
 1e6:	87aa                	mv	a5,a0
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f4:	0785                	addi	a5,a5,1
 1f6:	fee79de3          	bne	a5,a4,1f0 <memset+0x12>
  }
  return dst;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  for(; *s; s++)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb99                	beqz	a5,220 <strchr+0x20>
    if(*s == c)
 20c:	00f58763          	beq	a1,a5,21a <strchr+0x1a>
  for(; *s; s++)
 210:	0505                	addi	a0,a0,1
 212:	00054783          	lbu	a5,0(a0)
 216:	fbfd                	bnez	a5,20c <strchr+0xc>
      return (char*)s;
  return 0;
 218:	4501                	li	a0,0
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
  return 0;
 220:	4501                	li	a0,0
 222:	bfe5                	j	21a <strchr+0x1a>

0000000000000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	711d                	addi	sp,sp,-96
 226:	ec86                	sd	ra,88(sp)
 228:	e8a2                	sd	s0,80(sp)
 22a:	e4a6                	sd	s1,72(sp)
 22c:	e0ca                	sd	s2,64(sp)
 22e:	fc4e                	sd	s3,56(sp)
 230:	f852                	sd	s4,48(sp)
 232:	f456                	sd	s5,40(sp)
 234:	f05a                	sd	s6,32(sp)
 236:	ec5e                	sd	s7,24(sp)
 238:	1080                	addi	s0,sp,96
 23a:	8baa                	mv	s7,a0
 23c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	892a                	mv	s2,a0
 240:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 242:	4aa9                	li	s5,10
 244:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 246:	89a6                	mv	s3,s1
 248:	2485                	addiw	s1,s1,1
 24a:	0344d663          	bge	s1,s4,276 <gets+0x52>
    cc = read(0, &c, 1);
 24e:	4605                	li	a2,1
 250:	faf40593          	addi	a1,s0,-81
 254:	4501                	li	a0,0
 256:	1f0000ef          	jal	446 <read>
    if(cc < 1)
 25a:	00a05e63          	blez	a0,276 <gets+0x52>
    buf[i++] = c;
 25e:	faf44783          	lbu	a5,-81(s0)
 262:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 266:	01578763          	beq	a5,s5,274 <gets+0x50>
 26a:	0905                	addi	s2,s2,1
 26c:	fd679de3          	bne	a5,s6,246 <gets+0x22>
    buf[i++] = c;
 270:	89a6                	mv	s3,s1
 272:	a011                	j	276 <gets+0x52>
 274:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 276:	99de                	add	s3,s3,s7
 278:	00098023          	sb	zero,0(s3)
  return buf;
}
 27c:	855e                	mv	a0,s7
 27e:	60e6                	ld	ra,88(sp)
 280:	6446                	ld	s0,80(sp)
 282:	64a6                	ld	s1,72(sp)
 284:	6906                	ld	s2,64(sp)
 286:	79e2                	ld	s3,56(sp)
 288:	7a42                	ld	s4,48(sp)
 28a:	7aa2                	ld	s5,40(sp)
 28c:	7b02                	ld	s6,32(sp)
 28e:	6be2                	ld	s7,24(sp)
 290:	6125                	addi	sp,sp,96
 292:	8082                	ret

0000000000000294 <stat>:

int
stat(const char *n, struct stat *st)
{
 294:	1101                	addi	sp,sp,-32
 296:	ec06                	sd	ra,24(sp)
 298:	e822                	sd	s0,16(sp)
 29a:	e04a                	sd	s2,0(sp)
 29c:	1000                	addi	s0,sp,32
 29e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a0:	4581                	li	a1,0
 2a2:	1cc000ef          	jal	46e <open>
  if(fd < 0)
 2a6:	02054263          	bltz	a0,2ca <stat+0x36>
 2aa:	e426                	sd	s1,8(sp)
 2ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ae:	85ca                	mv	a1,s2
 2b0:	1d6000ef          	jal	486 <fstat>
 2b4:	892a                	mv	s2,a0
  close(fd);
 2b6:	8526                	mv	a0,s1
 2b8:	19e000ef          	jal	456 <close>
  return r;
 2bc:	64a2                	ld	s1,8(sp)
}
 2be:	854a                	mv	a0,s2
 2c0:	60e2                	ld	ra,24(sp)
 2c2:	6442                	ld	s0,16(sp)
 2c4:	6902                	ld	s2,0(sp)
 2c6:	6105                	addi	sp,sp,32
 2c8:	8082                	ret
    return -1;
 2ca:	597d                	li	s2,-1
 2cc:	bfcd                	j	2be <stat+0x2a>

00000000000002ce <atoi>:

int
atoi(const char *s)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d4:	00054683          	lbu	a3,0(a0)
 2d8:	fd06879b          	addiw	a5,a3,-48
 2dc:	0ff7f793          	zext.b	a5,a5
 2e0:	4625                	li	a2,9
 2e2:	02f66863          	bltu	a2,a5,312 <atoi+0x44>
 2e6:	872a                	mv	a4,a0
  n = 0;
 2e8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ea:	0705                	addi	a4,a4,1
 2ec:	0025179b          	slliw	a5,a0,0x2
 2f0:	9fa9                	addw	a5,a5,a0
 2f2:	0017979b          	slliw	a5,a5,0x1
 2f6:	9fb5                	addw	a5,a5,a3
 2f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fc:	00074683          	lbu	a3,0(a4)
 300:	fd06879b          	addiw	a5,a3,-48
 304:	0ff7f793          	zext.b	a5,a5
 308:	fef671e3          	bgeu	a2,a5,2ea <atoi+0x1c>
  return n;
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  n = 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <atoi+0x3e>

0000000000000316 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31c:	02b57463          	bgeu	a0,a1,344 <memmove+0x2e>
    while(n-- > 0)
 320:	00c05f63          	blez	a2,33e <memmove+0x28>
 324:	1602                	slli	a2,a2,0x20
 326:	9201                	srli	a2,a2,0x20
 328:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32c:	872a                	mv	a4,a0
      *dst++ = *src++;
 32e:	0585                	addi	a1,a1,1
 330:	0705                	addi	a4,a4,1
 332:	fff5c683          	lbu	a3,-1(a1)
 336:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33a:	fef71ae3          	bne	a4,a5,32e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
    dst += n;
 344:	00c50733          	add	a4,a0,a2
    src += n;
 348:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34a:	fec05ae3          	blez	a2,33e <memmove+0x28>
 34e:	fff6079b          	addiw	a5,a2,-1
 352:	1782                	slli	a5,a5,0x20
 354:	9381                	srli	a5,a5,0x20
 356:	fff7c793          	not	a5,a5
 35a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35c:	15fd                	addi	a1,a1,-1
 35e:	177d                	addi	a4,a4,-1
 360:	0005c683          	lbu	a3,0(a1)
 364:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 368:	fee79ae3          	bne	a5,a4,35c <memmove+0x46>
 36c:	bfc9                	j	33e <memmove+0x28>

000000000000036e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 374:	ca05                	beqz	a2,3a4 <memcmp+0x36>
 376:	fff6069b          	addiw	a3,a2,-1
 37a:	1682                	slli	a3,a3,0x20
 37c:	9281                	srli	a3,a3,0x20
 37e:	0685                	addi	a3,a3,1
 380:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 382:	00054783          	lbu	a5,0(a0)
 386:	0005c703          	lbu	a4,0(a1)
 38a:	00e79863          	bne	a5,a4,39a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38e:	0505                	addi	a0,a0,1
    p2++;
 390:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 392:	fed518e3          	bne	a0,a3,382 <memcmp+0x14>
  }
  return 0;
 396:	4501                	li	a0,0
 398:	a019                	j	39e <memcmp+0x30>
      return *p1 - *p2;
 39a:	40e7853b          	subw	a0,a5,a4
}
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret
  return 0;
 3a4:	4501                	li	a0,0
 3a6:	bfe5                	j	39e <memcmp+0x30>

00000000000003a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e406                	sd	ra,8(sp)
 3ac:	e022                	sd	s0,0(sp)
 3ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b0:	f67ff0ef          	jal	316 <memmove>
}
 3b4:	60a2                	ld	ra,8(sp)
 3b6:	6402                	ld	s0,0(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret

00000000000003bc <sbrk>:

char *
sbrk(int n) {
 3bc:	1141                	addi	sp,sp,-16
 3be:	e406                	sd	ra,8(sp)
 3c0:	e022                	sd	s0,0(sp)
 3c2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3c4:	4585                	li	a1,1
 3c6:	0f0000ef          	jal	4b6 <sys_sbrk>
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret

00000000000003d2 <sbrklazy>:

char *
sbrklazy(int n) {
 3d2:	1141                	addi	sp,sp,-16
 3d4:	e406                	sd	ra,8(sp)
 3d6:	e022                	sd	s0,0(sp)
 3d8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3da:	4589                	li	a1,2
 3dc:	0da000ef          	jal	4b6 <sys_sbrk>
}
 3e0:	60a2                	ld	ra,8(sp)
 3e2:	6402                	ld	s0,0(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret

00000000000003e8 <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e406                	sd	ra,8(sp)
 3ec:	e022                	sd	s0,0(sp)
 3ee:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
 3f0:	0025961b          	slliw	a2,a1,0x2
 3f4:	9e2d                	addw	a2,a2,a1
 3f6:	0036161b          	slliw	a2,a2,0x3
 3fa:	4581                	li	a1,0
 3fc:	de3ff0ef          	jal	1de <memset>
  return 0;
}
 400:	4501                	li	a0,0
 402:	60a2                	ld	ra,8(sp)
 404:	6402                	ld	s0,0(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret

000000000000040a <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e406                	sd	ra,8(sp)
 40e:	e022                	sd	s0,0(sp)
 410:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
 412:	07000613          	li	a2,112
 416:	4581                	li	a1,0
 418:	dc7ff0ef          	jal	1de <memset>
  return 0;
}
 41c:	4501                	li	a0,0
 41e:	60a2                	ld	ra,8(sp)
 420:	6402                	ld	s0,0(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret

0000000000000426 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 426:	4885                	li	a7,1
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <exit>:
.global exit
exit:
 li a7, SYS_exit
 42e:	4889                	li	a7,2
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <wait>:
.global wait
wait:
 li a7, SYS_wait
 436:	488d                	li	a7,3
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 43e:	4891                	li	a7,4
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <read>:
.global read
read:
 li a7, SYS_read
 446:	4895                	li	a7,5
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <write>:
.global write
write:
 li a7, SYS_write
 44e:	48c1                	li	a7,16
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <close>:
.global close
close:
 li a7, SYS_close
 456:	48d5                	li	a7,21
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <kill>:
.global kill
kill:
 li a7, SYS_kill
 45e:	4899                	li	a7,6
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <exec>:
.global exec
exec:
 li a7, SYS_exec
 466:	489d                	li	a7,7
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <open>:
.global open
open:
 li a7, SYS_open
 46e:	48bd                	li	a7,15
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 476:	48c5                	li	a7,17
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 47e:	48c9                	li	a7,18
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 486:	48a1                	li	a7,8
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <link>:
.global link
link:
 li a7, SYS_link
 48e:	48cd                	li	a7,19
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 496:	48d1                	li	a7,20
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 49e:	48a5                	li	a7,9
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4a6:	48a9                	li	a7,10
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ae:	48ad                	li	a7,11
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4b6:	48b1                	li	a7,12
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <pause>:
.global pause
pause:
 li a7, SYS_pause
 4be:	48b5                	li	a7,13
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4c6:	48b9                	li	a7,14
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <csread>:
.global csread
csread:
 li a7, SYS_csread
 4ce:	48d9                	li	a7,22
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 4d6:	48dd                	li	a7,23
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 4de:	48e1                	li	a7,24
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <memread>:
.global memread
memread:
 li a7, SYS_memread
 4e6:	48e5                	li	a7,25
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ee:	1101                	addi	sp,sp,-32
 4f0:	ec06                	sd	ra,24(sp)
 4f2:	e822                	sd	s0,16(sp)
 4f4:	1000                	addi	s0,sp,32
 4f6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4fa:	4605                	li	a2,1
 4fc:	fef40593          	addi	a1,s0,-17
 500:	f4fff0ef          	jal	44e <write>
}
 504:	60e2                	ld	ra,24(sp)
 506:	6442                	ld	s0,16(sp)
 508:	6105                	addi	sp,sp,32
 50a:	8082                	ret

000000000000050c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 50c:	715d                	addi	sp,sp,-80
 50e:	e486                	sd	ra,72(sp)
 510:	e0a2                	sd	s0,64(sp)
 512:	f84a                	sd	s2,48(sp)
 514:	0880                	addi	s0,sp,80
 516:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 518:	c299                	beqz	a3,51e <printint+0x12>
 51a:	0805c363          	bltz	a1,5a0 <printint+0x94>
  neg = 0;
 51e:	4881                	li	a7,0
 520:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 524:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 526:	00000517          	auipc	a0,0x0
 52a:	55a50513          	addi	a0,a0,1370 # a80 <digits>
 52e:	883e                	mv	a6,a5
 530:	2785                	addiw	a5,a5,1
 532:	02c5f733          	remu	a4,a1,a2
 536:	972a                	add	a4,a4,a0
 538:	00074703          	lbu	a4,0(a4)
 53c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 540:	872e                	mv	a4,a1
 542:	02c5d5b3          	divu	a1,a1,a2
 546:	0685                	addi	a3,a3,1
 548:	fec773e3          	bgeu	a4,a2,52e <printint+0x22>
  if(neg)
 54c:	00088b63          	beqz	a7,562 <printint+0x56>
    buf[i++] = '-';
 550:	fd078793          	addi	a5,a5,-48
 554:	97a2                	add	a5,a5,s0
 556:	02d00713          	li	a4,45
 55a:	fee78423          	sb	a4,-24(a5)
 55e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 562:	02f05a63          	blez	a5,596 <printint+0x8a>
 566:	fc26                	sd	s1,56(sp)
 568:	f44e                	sd	s3,40(sp)
 56a:	fb840713          	addi	a4,s0,-72
 56e:	00f704b3          	add	s1,a4,a5
 572:	fff70993          	addi	s3,a4,-1
 576:	99be                	add	s3,s3,a5
 578:	37fd                	addiw	a5,a5,-1
 57a:	1782                	slli	a5,a5,0x20
 57c:	9381                	srli	a5,a5,0x20
 57e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 582:	fff4c583          	lbu	a1,-1(s1)
 586:	854a                	mv	a0,s2
 588:	f67ff0ef          	jal	4ee <putc>
  while(--i >= 0)
 58c:	14fd                	addi	s1,s1,-1
 58e:	ff349ae3          	bne	s1,s3,582 <printint+0x76>
 592:	74e2                	ld	s1,56(sp)
 594:	79a2                	ld	s3,40(sp)
}
 596:	60a6                	ld	ra,72(sp)
 598:	6406                	ld	s0,64(sp)
 59a:	7942                	ld	s2,48(sp)
 59c:	6161                	addi	sp,sp,80
 59e:	8082                	ret
    x = -xx;
 5a0:	40b005b3          	neg	a1,a1
    neg = 1;
 5a4:	4885                	li	a7,1
    x = -xx;
 5a6:	bfad                	j	520 <printint+0x14>

00000000000005a8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5a8:	711d                	addi	sp,sp,-96
 5aa:	ec86                	sd	ra,88(sp)
 5ac:	e8a2                	sd	s0,80(sp)
 5ae:	e0ca                	sd	s2,64(sp)
 5b0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b2:	0005c903          	lbu	s2,0(a1)
 5b6:	28090663          	beqz	s2,842 <vprintf+0x29a>
 5ba:	e4a6                	sd	s1,72(sp)
 5bc:	fc4e                	sd	s3,56(sp)
 5be:	f852                	sd	s4,48(sp)
 5c0:	f456                	sd	s5,40(sp)
 5c2:	f05a                	sd	s6,32(sp)
 5c4:	ec5e                	sd	s7,24(sp)
 5c6:	e862                	sd	s8,16(sp)
 5c8:	e466                	sd	s9,8(sp)
 5ca:	8b2a                	mv	s6,a0
 5cc:	8a2e                	mv	s4,a1
 5ce:	8bb2                	mv	s7,a2
  state = 0;
 5d0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5d2:	4481                	li	s1,0
 5d4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5d6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5da:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5de:	06c00c93          	li	s9,108
 5e2:	a005                	j	602 <vprintf+0x5a>
        putc(fd, c0);
 5e4:	85ca                	mv	a1,s2
 5e6:	855a                	mv	a0,s6
 5e8:	f07ff0ef          	jal	4ee <putc>
 5ec:	a019                	j	5f2 <vprintf+0x4a>
    } else if(state == '%'){
 5ee:	03598263          	beq	s3,s5,612 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5f2:	2485                	addiw	s1,s1,1
 5f4:	8726                	mv	a4,s1
 5f6:	009a07b3          	add	a5,s4,s1
 5fa:	0007c903          	lbu	s2,0(a5)
 5fe:	22090a63          	beqz	s2,832 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 602:	0009079b          	sext.w	a5,s2
    if(state == 0){
 606:	fe0994e3          	bnez	s3,5ee <vprintf+0x46>
      if(c0 == '%'){
 60a:	fd579de3          	bne	a5,s5,5e4 <vprintf+0x3c>
        state = '%';
 60e:	89be                	mv	s3,a5
 610:	b7cd                	j	5f2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 612:	00ea06b3          	add	a3,s4,a4
 616:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 61a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 61c:	c681                	beqz	a3,624 <vprintf+0x7c>
 61e:	9752                	add	a4,a4,s4
 620:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 624:	05878363          	beq	a5,s8,66a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 628:	05978d63          	beq	a5,s9,682 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 62c:	07500713          	li	a4,117
 630:	0ee78763          	beq	a5,a4,71e <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 634:	07800713          	li	a4,120
 638:	12e78963          	beq	a5,a4,76a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 63c:	07000713          	li	a4,112
 640:	14e78e63          	beq	a5,a4,79c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 644:	06300713          	li	a4,99
 648:	18e78e63          	beq	a5,a4,7e4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 64c:	07300713          	li	a4,115
 650:	1ae78463          	beq	a5,a4,7f8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 654:	02500713          	li	a4,37
 658:	04e79563          	bne	a5,a4,6a2 <vprintf+0xfa>
        putc(fd, '%');
 65c:	02500593          	li	a1,37
 660:	855a                	mv	a0,s6
 662:	e8dff0ef          	jal	4ee <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 666:	4981                	li	s3,0
 668:	b769                	j	5f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4685                	li	a3,1
 670:	4629                	li	a2,10
 672:	000ba583          	lw	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	e95ff0ef          	jal	50c <printint>
 67c:	8bca                	mv	s7,s2
      state = 0;
 67e:	4981                	li	s3,0
 680:	bf8d                	j	5f2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 682:	06400793          	li	a5,100
 686:	02f68963          	beq	a3,a5,6b8 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 68a:	06c00793          	li	a5,108
 68e:	04f68263          	beq	a3,a5,6d2 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 692:	07500793          	li	a5,117
 696:	0af68063          	beq	a3,a5,736 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 69a:	07800793          	li	a5,120
 69e:	0ef68263          	beq	a3,a5,782 <vprintf+0x1da>
        putc(fd, '%');
 6a2:	02500593          	li	a1,37
 6a6:	855a                	mv	a0,s6
 6a8:	e47ff0ef          	jal	4ee <putc>
        putc(fd, c0);
 6ac:	85ca                	mv	a1,s2
 6ae:	855a                	mv	a0,s6
 6b0:	e3fff0ef          	jal	4ee <putc>
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	bf35                	j	5f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b8:	008b8913          	addi	s2,s7,8
 6bc:	4685                	li	a3,1
 6be:	4629                	li	a2,10
 6c0:	000bb583          	ld	a1,0(s7)
 6c4:	855a                	mv	a0,s6
 6c6:	e47ff0ef          	jal	50c <printint>
        i += 1;
 6ca:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6cc:	8bca                	mv	s7,s2
      state = 0;
 6ce:	4981                	li	s3,0
        i += 1;
 6d0:	b70d                	j	5f2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6d2:	06400793          	li	a5,100
 6d6:	02f60763          	beq	a2,a5,704 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6da:	07500793          	li	a5,117
 6de:	06f60963          	beq	a2,a5,750 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6e2:	07800793          	li	a5,120
 6e6:	faf61ee3          	bne	a2,a5,6a2 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ea:	008b8913          	addi	s2,s7,8
 6ee:	4681                	li	a3,0
 6f0:	4641                	li	a2,16
 6f2:	000bb583          	ld	a1,0(s7)
 6f6:	855a                	mv	a0,s6
 6f8:	e15ff0ef          	jal	50c <printint>
        i += 2;
 6fc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fe:	8bca                	mv	s7,s2
      state = 0;
 700:	4981                	li	s3,0
        i += 2;
 702:	bdc5                	j	5f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 704:	008b8913          	addi	s2,s7,8
 708:	4685                	li	a3,1
 70a:	4629                	li	a2,10
 70c:	000bb583          	ld	a1,0(s7)
 710:	855a                	mv	a0,s6
 712:	dfbff0ef          	jal	50c <printint>
        i += 2;
 716:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 718:	8bca                	mv	s7,s2
      state = 0;
 71a:	4981                	li	s3,0
        i += 2;
 71c:	bdd9                	j	5f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 71e:	008b8913          	addi	s2,s7,8
 722:	4681                	li	a3,0
 724:	4629                	li	a2,10
 726:	000be583          	lwu	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	de1ff0ef          	jal	50c <printint>
 730:	8bca                	mv	s7,s2
      state = 0;
 732:	4981                	li	s3,0
 734:	bd7d                	j	5f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 736:	008b8913          	addi	s2,s7,8
 73a:	4681                	li	a3,0
 73c:	4629                	li	a2,10
 73e:	000bb583          	ld	a1,0(s7)
 742:	855a                	mv	a0,s6
 744:	dc9ff0ef          	jal	50c <printint>
        i += 1;
 748:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 74a:	8bca                	mv	s7,s2
      state = 0;
 74c:	4981                	li	s3,0
        i += 1;
 74e:	b555                	j	5f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 750:	008b8913          	addi	s2,s7,8
 754:	4681                	li	a3,0
 756:	4629                	li	a2,10
 758:	000bb583          	ld	a1,0(s7)
 75c:	855a                	mv	a0,s6
 75e:	dafff0ef          	jal	50c <printint>
        i += 2;
 762:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 764:	8bca                	mv	s7,s2
      state = 0;
 766:	4981                	li	s3,0
        i += 2;
 768:	b569                	j	5f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 76a:	008b8913          	addi	s2,s7,8
 76e:	4681                	li	a3,0
 770:	4641                	li	a2,16
 772:	000be583          	lwu	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	d95ff0ef          	jal	50c <printint>
 77c:	8bca                	mv	s7,s2
      state = 0;
 77e:	4981                	li	s3,0
 780:	bd8d                	j	5f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 782:	008b8913          	addi	s2,s7,8
 786:	4681                	li	a3,0
 788:	4641                	li	a2,16
 78a:	000bb583          	ld	a1,0(s7)
 78e:	855a                	mv	a0,s6
 790:	d7dff0ef          	jal	50c <printint>
        i += 1;
 794:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 796:	8bca                	mv	s7,s2
      state = 0;
 798:	4981                	li	s3,0
        i += 1;
 79a:	bda1                	j	5f2 <vprintf+0x4a>
 79c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 79e:	008b8d13          	addi	s10,s7,8
 7a2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7a6:	03000593          	li	a1,48
 7aa:	855a                	mv	a0,s6
 7ac:	d43ff0ef          	jal	4ee <putc>
  putc(fd, 'x');
 7b0:	07800593          	li	a1,120
 7b4:	855a                	mv	a0,s6
 7b6:	d39ff0ef          	jal	4ee <putc>
 7ba:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7bc:	00000b97          	auipc	s7,0x0
 7c0:	2c4b8b93          	addi	s7,s7,708 # a80 <digits>
 7c4:	03c9d793          	srli	a5,s3,0x3c
 7c8:	97de                	add	a5,a5,s7
 7ca:	0007c583          	lbu	a1,0(a5)
 7ce:	855a                	mv	a0,s6
 7d0:	d1fff0ef          	jal	4ee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7d4:	0992                	slli	s3,s3,0x4
 7d6:	397d                	addiw	s2,s2,-1
 7d8:	fe0916e3          	bnez	s2,7c4 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7dc:	8bea                	mv	s7,s10
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	6d02                	ld	s10,0(sp)
 7e2:	bd01                	j	5f2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7e4:	008b8913          	addi	s2,s7,8
 7e8:	000bc583          	lbu	a1,0(s7)
 7ec:	855a                	mv	a0,s6
 7ee:	d01ff0ef          	jal	4ee <putc>
 7f2:	8bca                	mv	s7,s2
      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	bbf5                	j	5f2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7f8:	008b8993          	addi	s3,s7,8
 7fc:	000bb903          	ld	s2,0(s7)
 800:	00090f63          	beqz	s2,81e <vprintf+0x276>
        for(; *s; s++)
 804:	00094583          	lbu	a1,0(s2)
 808:	c195                	beqz	a1,82c <vprintf+0x284>
          putc(fd, *s);
 80a:	855a                	mv	a0,s6
 80c:	ce3ff0ef          	jal	4ee <putc>
        for(; *s; s++)
 810:	0905                	addi	s2,s2,1
 812:	00094583          	lbu	a1,0(s2)
 816:	f9f5                	bnez	a1,80a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 818:	8bce                	mv	s7,s3
      state = 0;
 81a:	4981                	li	s3,0
 81c:	bbd9                	j	5f2 <vprintf+0x4a>
          s = "(null)";
 81e:	00000917          	auipc	s2,0x0
 822:	25a90913          	addi	s2,s2,602 # a78 <malloc+0x14e>
        for(; *s; s++)
 826:	02800593          	li	a1,40
 82a:	b7c5                	j	80a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 82c:	8bce                	mv	s7,s3
      state = 0;
 82e:	4981                	li	s3,0
 830:	b3c9                	j	5f2 <vprintf+0x4a>
 832:	64a6                	ld	s1,72(sp)
 834:	79e2                	ld	s3,56(sp)
 836:	7a42                	ld	s4,48(sp)
 838:	7aa2                	ld	s5,40(sp)
 83a:	7b02                	ld	s6,32(sp)
 83c:	6be2                	ld	s7,24(sp)
 83e:	6c42                	ld	s8,16(sp)
 840:	6ca2                	ld	s9,8(sp)
    }
  }
}
 842:	60e6                	ld	ra,88(sp)
 844:	6446                	ld	s0,80(sp)
 846:	6906                	ld	s2,64(sp)
 848:	6125                	addi	sp,sp,96
 84a:	8082                	ret

000000000000084c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 84c:	715d                	addi	sp,sp,-80
 84e:	ec06                	sd	ra,24(sp)
 850:	e822                	sd	s0,16(sp)
 852:	1000                	addi	s0,sp,32
 854:	e010                	sd	a2,0(s0)
 856:	e414                	sd	a3,8(s0)
 858:	e818                	sd	a4,16(s0)
 85a:	ec1c                	sd	a5,24(s0)
 85c:	03043023          	sd	a6,32(s0)
 860:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 864:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 868:	8622                	mv	a2,s0
 86a:	d3fff0ef          	jal	5a8 <vprintf>
}
 86e:	60e2                	ld	ra,24(sp)
 870:	6442                	ld	s0,16(sp)
 872:	6161                	addi	sp,sp,80
 874:	8082                	ret

0000000000000876 <printf>:

void
printf(const char *fmt, ...)
{
 876:	711d                	addi	sp,sp,-96
 878:	ec06                	sd	ra,24(sp)
 87a:	e822                	sd	s0,16(sp)
 87c:	1000                	addi	s0,sp,32
 87e:	e40c                	sd	a1,8(s0)
 880:	e810                	sd	a2,16(s0)
 882:	ec14                	sd	a3,24(s0)
 884:	f018                	sd	a4,32(s0)
 886:	f41c                	sd	a5,40(s0)
 888:	03043823          	sd	a6,48(s0)
 88c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 890:	00840613          	addi	a2,s0,8
 894:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 898:	85aa                	mv	a1,a0
 89a:	4505                	li	a0,1
 89c:	d0dff0ef          	jal	5a8 <vprintf>
}
 8a0:	60e2                	ld	ra,24(sp)
 8a2:	6442                	ld	s0,16(sp)
 8a4:	6125                	addi	sp,sp,96
 8a6:	8082                	ret

00000000000008a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a8:	1141                	addi	sp,sp,-16
 8aa:	e422                	sd	s0,8(sp)
 8ac:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ae:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b2:	00000797          	auipc	a5,0x0
 8b6:	74e7b783          	ld	a5,1870(a5) # 1000 <freep>
 8ba:	a02d                	j	8e4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8bc:	4618                	lw	a4,8(a2)
 8be:	9f2d                	addw	a4,a4,a1
 8c0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c4:	6398                	ld	a4,0(a5)
 8c6:	6310                	ld	a2,0(a4)
 8c8:	a83d                	j	906 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ca:	ff852703          	lw	a4,-8(a0)
 8ce:	9f31                	addw	a4,a4,a2
 8d0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8d2:	ff053683          	ld	a3,-16(a0)
 8d6:	a091                	j	91a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d8:	6398                	ld	a4,0(a5)
 8da:	00e7e463          	bltu	a5,a4,8e2 <free+0x3a>
 8de:	00e6ea63          	bltu	a3,a4,8f2 <free+0x4a>
{
 8e2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e4:	fed7fae3          	bgeu	a5,a3,8d8 <free+0x30>
 8e8:	6398                	ld	a4,0(a5)
 8ea:	00e6e463          	bltu	a3,a4,8f2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ee:	fee7eae3          	bltu	a5,a4,8e2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8f2:	ff852583          	lw	a1,-8(a0)
 8f6:	6390                	ld	a2,0(a5)
 8f8:	02059813          	slli	a6,a1,0x20
 8fc:	01c85713          	srli	a4,a6,0x1c
 900:	9736                	add	a4,a4,a3
 902:	fae60de3          	beq	a2,a4,8bc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 906:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 90a:	4790                	lw	a2,8(a5)
 90c:	02061593          	slli	a1,a2,0x20
 910:	01c5d713          	srli	a4,a1,0x1c
 914:	973e                	add	a4,a4,a5
 916:	fae68ae3          	beq	a3,a4,8ca <free+0x22>
    p->s.ptr = bp->s.ptr;
 91a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 91c:	00000717          	auipc	a4,0x0
 920:	6ef73223          	sd	a5,1764(a4) # 1000 <freep>
}
 924:	6422                	ld	s0,8(sp)
 926:	0141                	addi	sp,sp,16
 928:	8082                	ret

000000000000092a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 92a:	7139                	addi	sp,sp,-64
 92c:	fc06                	sd	ra,56(sp)
 92e:	f822                	sd	s0,48(sp)
 930:	f426                	sd	s1,40(sp)
 932:	ec4e                	sd	s3,24(sp)
 934:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 936:	02051493          	slli	s1,a0,0x20
 93a:	9081                	srli	s1,s1,0x20
 93c:	04bd                	addi	s1,s1,15
 93e:	8091                	srli	s1,s1,0x4
 940:	0014899b          	addiw	s3,s1,1
 944:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 946:	00000517          	auipc	a0,0x0
 94a:	6ba53503          	ld	a0,1722(a0) # 1000 <freep>
 94e:	c915                	beqz	a0,982 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 950:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 952:	4798                	lw	a4,8(a5)
 954:	08977a63          	bgeu	a4,s1,9e8 <malloc+0xbe>
 958:	f04a                	sd	s2,32(sp)
 95a:	e852                	sd	s4,16(sp)
 95c:	e456                	sd	s5,8(sp)
 95e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 960:	8a4e                	mv	s4,s3
 962:	0009871b          	sext.w	a4,s3
 966:	6685                	lui	a3,0x1
 968:	00d77363          	bgeu	a4,a3,96e <malloc+0x44>
 96c:	6a05                	lui	s4,0x1
 96e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 972:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 976:	00000917          	auipc	s2,0x0
 97a:	68a90913          	addi	s2,s2,1674 # 1000 <freep>
  if(p == SBRK_ERROR)
 97e:	5afd                	li	s5,-1
 980:	a081                	j	9c0 <malloc+0x96>
 982:	f04a                	sd	s2,32(sp)
 984:	e852                	sd	s4,16(sp)
 986:	e456                	sd	s5,8(sp)
 988:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 98a:	00001797          	auipc	a5,0x1
 98e:	88678793          	addi	a5,a5,-1914 # 1210 <base>
 992:	00000717          	auipc	a4,0x0
 996:	66f73723          	sd	a5,1646(a4) # 1000 <freep>
 99a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 99c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9a0:	b7c1                	j	960 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9a2:	6398                	ld	a4,0(a5)
 9a4:	e118                	sd	a4,0(a0)
 9a6:	a8a9                	j	a00 <malloc+0xd6>
  hp->s.size = nu;
 9a8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9ac:	0541                	addi	a0,a0,16
 9ae:	efbff0ef          	jal	8a8 <free>
  return freep;
 9b2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9b6:	c12d                	beqz	a0,a18 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ba:	4798                	lw	a4,8(a5)
 9bc:	02977263          	bgeu	a4,s1,9e0 <malloc+0xb6>
    if(p == freep)
 9c0:	00093703          	ld	a4,0(s2)
 9c4:	853e                	mv	a0,a5
 9c6:	fef719e3          	bne	a4,a5,9b8 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9ca:	8552                	mv	a0,s4
 9cc:	9f1ff0ef          	jal	3bc <sbrk>
  if(p == SBRK_ERROR)
 9d0:	fd551ce3          	bne	a0,s5,9a8 <malloc+0x7e>
        return 0;
 9d4:	4501                	li	a0,0
 9d6:	7902                	ld	s2,32(sp)
 9d8:	6a42                	ld	s4,16(sp)
 9da:	6aa2                	ld	s5,8(sp)
 9dc:	6b02                	ld	s6,0(sp)
 9de:	a03d                	j	a0c <malloc+0xe2>
 9e0:	7902                	ld	s2,32(sp)
 9e2:	6a42                	ld	s4,16(sp)
 9e4:	6aa2                	ld	s5,8(sp)
 9e6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9e8:	fae48de3          	beq	s1,a4,9a2 <malloc+0x78>
        p->s.size -= nunits;
 9ec:	4137073b          	subw	a4,a4,s3
 9f0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9f2:	02071693          	slli	a3,a4,0x20
 9f6:	01c6d713          	srli	a4,a3,0x1c
 9fa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9fc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a00:	00000717          	auipc	a4,0x0
 a04:	60a73023          	sd	a0,1536(a4) # 1000 <freep>
      return (void*)(p + 1);
 a08:	01078513          	addi	a0,a5,16
  }
}
 a0c:	70e2                	ld	ra,56(sp)
 a0e:	7442                	ld	s0,48(sp)
 a10:	74a2                	ld	s1,40(sp)
 a12:	69e2                	ld	s3,24(sp)
 a14:	6121                	addi	sp,sp,64
 a16:	8082                	ret
 a18:	7902                	ld	s2,32(sp)
 a1a:	6a42                	ld	s4,16(sp)
 a1c:	6aa2                	ld	s5,8(sp)
 a1e:	6b02                	ld	s6,0(sp)
 a20:	b7f5                	j	a0c <malloc+0xe2>
