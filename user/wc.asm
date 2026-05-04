
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
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	20000d93          	li	s11,512
  32:	00001d17          	auipc	s10,0x1
  36:	fded0d13          	addi	s10,s10,-34 # 1010 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  3a:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  3c:	00001a17          	auipc	s4,0x1
  40:	9f4a0a13          	addi	s4,s4,-1548 # a30 <malloc+0x100>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  44:	a035                	j	70 <wc+0x70>
      if(strchr(" \r\t\n\v", buf[i]))
  46:	8552                	mv	a0,s4
  48:	1c6000ef          	jal	20e <strchr>
  4c:	c919                	beqz	a0,62 <wc+0x62>
        inword = 0;
  4e:	4901                	li	s2,0
    for(i=0; i<n; i++){
  50:	0485                	addi	s1,s1,1
  52:	01348d63          	beq	s1,s3,6c <wc+0x6c>
      if(buf[i] == '\n')
  56:	0004c583          	lbu	a1,0(s1)
  5a:	ff5596e3          	bne	a1,s5,46 <wc+0x46>
        l++;
  5e:	2b85                	addiw	s7,s7,1
  60:	b7dd                	j	46 <wc+0x46>
      else if(!inword){
  62:	fe0917e3          	bnez	s2,50 <wc+0x50>
        w++;
  66:	2c05                	addiw	s8,s8,1
        inword = 1;
  68:	4905                	li	s2,1
  6a:	b7dd                	j	50 <wc+0x50>
  6c:	019b0cbb          	addw	s9,s6,s9
  while((n = read(fd, buf, sizeof(buf))) > 0){
  70:	866e                	mv	a2,s11
  72:	85ea                	mv	a1,s10
  74:	f8843503          	ld	a0,-120(s0)
  78:	3b2000ef          	jal	42a <read>
  7c:	8b2a                	mv	s6,a0
  7e:	00a05963          	blez	a0,90 <wc+0x90>
  82:	00001497          	auipc	s1,0x1
  86:	f8e48493          	addi	s1,s1,-114 # 1010 <buf>
  8a:	009b09b3          	add	s3,s6,s1
  8e:	b7e1                	j	56 <wc+0x56>
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
  98:	86e6                	mv	a3,s9
  9a:	8662                	mv	a2,s8
  9c:	85de                	mv	a1,s7
  9e:	00001517          	auipc	a0,0x1
  a2:	9b250513          	addi	a0,a0,-1614 # a50 <malloc+0x120>
  a6:	7d2000ef          	jal	878 <printf>
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
  cc:	97850513          	addi	a0,a0,-1672 # a40 <malloc+0x110>
  d0:	7a8000ef          	jal	878 <printf>
    exit(1);
  d4:	4505                	li	a0,1
  d6:	33c000ef          	jal	412 <exit>

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
 108:	34a000ef          	jal	452 <open>
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
 11c:	31e000ef          	jal	43a <close>
  for(i = 1; i < argc; i++){
 120:	0921                	addi	s2,s2,8
 122:	ff3910e3          	bne	s2,s3,102 <main+0x28>
  }
  exit(0);
 126:	4501                	li	a0,0
 128:	2ea000ef          	jal	412 <exit>
 12c:	ec26                	sd	s1,24(sp)
 12e:	e84a                	sd	s2,16(sp)
 130:	e44e                	sd	s3,8(sp)
    wc(0, "");
 132:	00001597          	auipc	a1,0x1
 136:	90658593          	addi	a1,a1,-1786 # a38 <malloc+0x108>
 13a:	4501                	li	a0,0
 13c:	ec5ff0ef          	jal	0 <wc>
    exit(0);
 140:	4501                	li	a0,0
 142:	2d0000ef          	jal	412 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 146:	00093583          	ld	a1,0(s2)
 14a:	00001517          	auipc	a0,0x1
 14e:	91650513          	addi	a0,a0,-1770 # a60 <malloc+0x130>
 152:	726000ef          	jal	878 <printf>
      exit(1);
 156:	4505                	li	a0,1
 158:	2ba000ef          	jal	412 <exit>

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
 168:	2aa000ef          	jal	412 <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e406                	sd	ra,8(sp)
 170:	e022                	sd	s0,0(sp)
 172:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 174:	87aa                	mv	a5,a0
 176:	0585                	addi	a1,a1,1
 178:	0785                	addi	a5,a5,1
 17a:	fff5c703          	lbu	a4,-1(a1)
 17e:	fee78fa3          	sb	a4,-1(a5)
 182:	fb75                	bnez	a4,176 <strcpy+0xa>
    ;
  return os;
}
 184:	60a2                	ld	ra,8(sp)
 186:	6402                	ld	s0,0(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret

000000000000018c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e406                	sd	ra,8(sp)
 190:	e022                	sd	s0,0(sp)
 192:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	cb91                	beqz	a5,1ac <strcmp+0x20>
 19a:	0005c703          	lbu	a4,0(a1)
 19e:	00f71763          	bne	a4,a5,1ac <strcmp+0x20>
    p++, q++;
 1a2:	0505                	addi	a0,a0,1
 1a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	fbe5                	bnez	a5,19a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1ac:	0005c503          	lbu	a0,0(a1)
}
 1b0:	40a7853b          	subw	a0,a5,a0
 1b4:	60a2                	ld	ra,8(sp)
 1b6:	6402                	ld	s0,0(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret

00000000000001bc <strlen>:

uint
strlen(const char *s)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e406                	sd	ra,8(sp)
 1c0:	e022                	sd	s0,0(sp)
 1c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	cf91                	beqz	a5,1e4 <strlen+0x28>
 1ca:	00150793          	addi	a5,a0,1
 1ce:	86be                	mv	a3,a5
 1d0:	0785                	addi	a5,a5,1
 1d2:	fff7c703          	lbu	a4,-1(a5)
 1d6:	ff65                	bnez	a4,1ce <strlen+0x12>
 1d8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1dc:	60a2                	ld	ra,8(sp)
 1de:	6402                	ld	s0,0(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret
  for(n = 0; s[n]; n++)
 1e4:	4501                	li	a0,0
 1e6:	bfdd                	j	1dc <strlen+0x20>

00000000000001e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e406                	sd	ra,8(sp)
 1ec:	e022                	sd	s0,0(sp)
 1ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f0:	ca19                	beqz	a2,206 <memset+0x1e>
 1f2:	87aa                	mv	a5,a0
 1f4:	1602                	slli	a2,a2,0x20
 1f6:	9201                	srli	a2,a2,0x20
 1f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 200:	0785                	addi	a5,a5,1
 202:	fee79de3          	bne	a5,a4,1fc <memset+0x14>
  }
  return dst;
}
 206:	60a2                	ld	ra,8(sp)
 208:	6402                	ld	s0,0(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret

000000000000020e <strchr>:

char*
strchr(const char *s, char c)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e406                	sd	ra,8(sp)
 212:	e022                	sd	s0,0(sp)
 214:	0800                	addi	s0,sp,16
  for(; *s; s++)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cf81                	beqz	a5,232 <strchr+0x24>
    if(*s == c)
 21c:	00f58763          	beq	a1,a5,22a <strchr+0x1c>
  for(; *s; s++)
 220:	0505                	addi	a0,a0,1
 222:	00054783          	lbu	a5,0(a0)
 226:	fbfd                	bnez	a5,21c <strchr+0xe>
      return (char*)s;
  return 0;
 228:	4501                	li	a0,0
}
 22a:	60a2                	ld	ra,8(sp)
 22c:	6402                	ld	s0,0(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
  return 0;
 232:	4501                	li	a0,0
 234:	bfdd                	j	22a <strchr+0x1c>

0000000000000236 <gets>:

char*
gets(char *buf, int max)
{
 236:	711d                	addi	sp,sp,-96
 238:	ec86                	sd	ra,88(sp)
 23a:	e8a2                	sd	s0,80(sp)
 23c:	e4a6                	sd	s1,72(sp)
 23e:	e0ca                	sd	s2,64(sp)
 240:	fc4e                	sd	s3,56(sp)
 242:	f852                	sd	s4,48(sp)
 244:	f456                	sd	s5,40(sp)
 246:	f05a                	sd	s6,32(sp)
 248:	ec5e                	sd	s7,24(sp)
 24a:	e862                	sd	s8,16(sp)
 24c:	1080                	addi	s0,sp,96
 24e:	8baa                	mv	s7,a0
 250:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 252:	892a                	mv	s2,a0
 254:	4481                	li	s1,0
    cc = read(0, &c, 1);
 256:	faf40b13          	addi	s6,s0,-81
 25a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 25c:	8c26                	mv	s8,s1
 25e:	0014899b          	addiw	s3,s1,1
 262:	84ce                	mv	s1,s3
 264:	0349d463          	bge	s3,s4,28c <gets+0x56>
    cc = read(0, &c, 1);
 268:	8656                	mv	a2,s5
 26a:	85da                	mv	a1,s6
 26c:	4501                	li	a0,0
 26e:	1bc000ef          	jal	42a <read>
    if(cc < 1)
 272:	00a05d63          	blez	a0,28c <gets+0x56>
      break;
    buf[i++] = c;
 276:	faf44783          	lbu	a5,-81(s0)
 27a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27e:	0905                	addi	s2,s2,1
 280:	ff678713          	addi	a4,a5,-10
 284:	c319                	beqz	a4,28a <gets+0x54>
 286:	17cd                	addi	a5,a5,-13
 288:	fbf1                	bnez	a5,25c <gets+0x26>
    buf[i++] = c;
 28a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 28c:	9c5e                	add	s8,s8,s7
 28e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 292:	855e                	mv	a0,s7
 294:	60e6                	ld	ra,88(sp)
 296:	6446                	ld	s0,80(sp)
 298:	64a6                	ld	s1,72(sp)
 29a:	6906                	ld	s2,64(sp)
 29c:	79e2                	ld	s3,56(sp)
 29e:	7a42                	ld	s4,48(sp)
 2a0:	7aa2                	ld	s5,40(sp)
 2a2:	7b02                	ld	s6,32(sp)
 2a4:	6be2                	ld	s7,24(sp)
 2a6:	6c42                	ld	s8,16(sp)
 2a8:	6125                	addi	sp,sp,96
 2aa:	8082                	ret

00000000000002ac <stat>:

int
stat(const char *n, struct stat *st)
{
 2ac:	1101                	addi	sp,sp,-32
 2ae:	ec06                	sd	ra,24(sp)
 2b0:	e822                	sd	s0,16(sp)
 2b2:	e04a                	sd	s2,0(sp)
 2b4:	1000                	addi	s0,sp,32
 2b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b8:	4581                	li	a1,0
 2ba:	198000ef          	jal	452 <open>
  if(fd < 0)
 2be:	02054263          	bltz	a0,2e2 <stat+0x36>
 2c2:	e426                	sd	s1,8(sp)
 2c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c6:	85ca                	mv	a1,s2
 2c8:	1a2000ef          	jal	46a <fstat>
 2cc:	892a                	mv	s2,a0
  close(fd);
 2ce:	8526                	mv	a0,s1
 2d0:	16a000ef          	jal	43a <close>
  return r;
 2d4:	64a2                	ld	s1,8(sp)
}
 2d6:	854a                	mv	a0,s2
 2d8:	60e2                	ld	ra,24(sp)
 2da:	6442                	ld	s0,16(sp)
 2dc:	6902                	ld	s2,0(sp)
 2de:	6105                	addi	sp,sp,32
 2e0:	8082                	ret
    return -1;
 2e2:	57fd                	li	a5,-1
 2e4:	893e                	mv	s2,a5
 2e6:	bfc5                	j	2d6 <stat+0x2a>

00000000000002e8 <atoi>:

int
atoi(const char *s)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f0:	00054683          	lbu	a3,0(a0)
 2f4:	fd06879b          	addiw	a5,a3,-48
 2f8:	0ff7f793          	zext.b	a5,a5
 2fc:	4625                	li	a2,9
 2fe:	02f66963          	bltu	a2,a5,330 <atoi+0x48>
 302:	872a                	mv	a4,a0
  n = 0;
 304:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 306:	0705                	addi	a4,a4,1
 308:	0025179b          	slliw	a5,a0,0x2
 30c:	9fa9                	addw	a5,a5,a0
 30e:	0017979b          	slliw	a5,a5,0x1
 312:	9fb5                	addw	a5,a5,a3
 314:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 318:	00074683          	lbu	a3,0(a4)
 31c:	fd06879b          	addiw	a5,a3,-48
 320:	0ff7f793          	zext.b	a5,a5
 324:	fef671e3          	bgeu	a2,a5,306 <atoi+0x1e>
  return n;
}
 328:	60a2                	ld	ra,8(sp)
 32a:	6402                	ld	s0,0(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  n = 0;
 330:	4501                	li	a0,0
 332:	bfdd                	j	328 <atoi+0x40>

0000000000000334 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33c:	02b57563          	bgeu	a0,a1,366 <memmove+0x32>
    while(n-- > 0)
 340:	00c05f63          	blez	a2,35e <memmove+0x2a>
 344:	1602                	slli	a2,a2,0x20
 346:	9201                	srli	a2,a2,0x20
 348:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34c:	872a                	mv	a4,a0
      *dst++ = *src++;
 34e:	0585                	addi	a1,a1,1
 350:	0705                	addi	a4,a4,1
 352:	fff5c683          	lbu	a3,-1(a1)
 356:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35a:	fee79ae3          	bne	a5,a4,34e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35e:	60a2                	ld	ra,8(sp)
 360:	6402                	ld	s0,0(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
    while(n-- > 0)
 366:	fec05ce3          	blez	a2,35e <memmove+0x2a>
    dst += n;
 36a:	00c50733          	add	a4,a0,a2
    src += n;
 36e:	95b2                	add	a1,a1,a2
 370:	fff6079b          	addiw	a5,a2,-1
 374:	1782                	slli	a5,a5,0x20
 376:	9381                	srli	a5,a5,0x20
 378:	fff7c793          	not	a5,a5
 37c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37e:	15fd                	addi	a1,a1,-1
 380:	177d                	addi	a4,a4,-1
 382:	0005c683          	lbu	a3,0(a1)
 386:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38a:	fef71ae3          	bne	a4,a5,37e <memmove+0x4a>
 38e:	bfc1                	j	35e <memmove+0x2a>

0000000000000390 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 390:	1141                	addi	sp,sp,-16
 392:	e406                	sd	ra,8(sp)
 394:	e022                	sd	s0,0(sp)
 396:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 398:	c61d                	beqz	a2,3c6 <memcmp+0x36>
 39a:	1602                	slli	a2,a2,0x20
 39c:	9201                	srli	a2,a2,0x20
 39e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3a2:	00054783          	lbu	a5,0(a0)
 3a6:	0005c703          	lbu	a4,0(a1)
 3aa:	00e79863          	bne	a5,a4,3ba <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3ae:	0505                	addi	a0,a0,1
    p2++;
 3b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b2:	fed518e3          	bne	a0,a3,3a2 <memcmp+0x12>
  }
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	a019                	j	3be <memcmp+0x2e>
      return *p1 - *p2;
 3ba:	40e7853b          	subw	a0,a5,a4
}
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
  return 0;
 3c6:	4501                	li	a0,0
 3c8:	bfdd                	j	3be <memcmp+0x2e>

00000000000003ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e406                	sd	ra,8(sp)
 3ce:	e022                	sd	s0,0(sp)
 3d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d2:	f63ff0ef          	jal	334 <memmove>
}
 3d6:	60a2                	ld	ra,8(sp)
 3d8:	6402                	ld	s0,0(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret

00000000000003de <sbrk>:

char *
sbrk(int n) {
 3de:	1141                	addi	sp,sp,-16
 3e0:	e406                	sd	ra,8(sp)
 3e2:	e022                	sd	s0,0(sp)
 3e4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3e6:	4585                	li	a1,1
 3e8:	0b2000ef          	jal	49a <sys_sbrk>
}
 3ec:	60a2                	ld	ra,8(sp)
 3ee:	6402                	ld	s0,0(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret

00000000000003f4 <sbrklazy>:

char *
sbrklazy(int n) {
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e406                	sd	ra,8(sp)
 3f8:	e022                	sd	s0,0(sp)
 3fa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3fc:	4589                	li	a1,2
 3fe:	09c000ef          	jal	49a <sys_sbrk>
}
 402:	60a2                	ld	ra,8(sp)
 404:	6402                	ld	s0,0(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret

000000000000040a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 40a:	4885                	li	a7,1
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exit>:
.global exit
exit:
 li a7, SYS_exit
 412:	4889                	li	a7,2
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <wait>:
.global wait
wait:
 li a7, SYS_wait
 41a:	488d                	li	a7,3
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 422:	4891                	li	a7,4
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <read>:
.global read
read:
 li a7, SYS_read
 42a:	4895                	li	a7,5
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <write>:
.global write
write:
 li a7, SYS_write
 432:	48c1                	li	a7,16
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <close>:
.global close
close:
 li a7, SYS_close
 43a:	48d5                	li	a7,21
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <kill>:
.global kill
kill:
 li a7, SYS_kill
 442:	4899                	li	a7,6
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <exec>:
.global exec
exec:
 li a7, SYS_exec
 44a:	489d                	li	a7,7
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <open>:
.global open
open:
 li a7, SYS_open
 452:	48bd                	li	a7,15
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 45a:	48c5                	li	a7,17
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 462:	48c9                	li	a7,18
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 46a:	48a1                	li	a7,8
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <link>:
.global link
link:
 li a7, SYS_link
 472:	48cd                	li	a7,19
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 47a:	48d1                	li	a7,20
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 482:	48a5                	li	a7,9
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <dup>:
.global dup
dup:
 li a7, SYS_dup
 48a:	48a9                	li	a7,10
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 492:	48ad                	li	a7,11
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 49a:	48b1                	li	a7,12
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4a2:	48b5                	li	a7,13
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4aa:	48b9                	li	a7,14
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <csread>:
.global csread
csread:
 li a7, SYS_csread
 4b2:	48d9                	li	a7,22
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 4ba:	48dd                	li	a7,23
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 4c2:	48e1                	li	a7,24
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <memread>:
.global memread
memread:
 li a7, SYS_memread
 4ca:	48e5                	li	a7,25
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d2:	1101                	addi	sp,sp,-32
 4d4:	ec06                	sd	ra,24(sp)
 4d6:	e822                	sd	s0,16(sp)
 4d8:	1000                	addi	s0,sp,32
 4da:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4de:	4605                	li	a2,1
 4e0:	fef40593          	addi	a1,s0,-17
 4e4:	f4fff0ef          	jal	432 <write>
}
 4e8:	60e2                	ld	ra,24(sp)
 4ea:	6442                	ld	s0,16(sp)
 4ec:	6105                	addi	sp,sp,32
 4ee:	8082                	ret

00000000000004f0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4f0:	715d                	addi	sp,sp,-80
 4f2:	e486                	sd	ra,72(sp)
 4f4:	e0a2                	sd	s0,64(sp)
 4f6:	f84a                	sd	s2,48(sp)
 4f8:	f44e                	sd	s3,40(sp)
 4fa:	0880                	addi	s0,sp,80
 4fc:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4fe:	c6d1                	beqz	a3,58a <printint+0x9a>
 500:	0805d563          	bgez	a1,58a <printint+0x9a>
    neg = 1;
    x = -xx;
 504:	40b005b3          	neg	a1,a1
    neg = 1;
 508:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 50a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 50e:	86ce                	mv	a3,s3
  i = 0;
 510:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 512:	00000817          	auipc	a6,0x0
 516:	56e80813          	addi	a6,a6,1390 # a80 <digits>
 51a:	88ba                	mv	a7,a4
 51c:	0017051b          	addiw	a0,a4,1
 520:	872a                	mv	a4,a0
 522:	02c5f7b3          	remu	a5,a1,a2
 526:	97c2                	add	a5,a5,a6
 528:	0007c783          	lbu	a5,0(a5)
 52c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 530:	87ae                	mv	a5,a1
 532:	02c5d5b3          	divu	a1,a1,a2
 536:	0685                	addi	a3,a3,1
 538:	fec7f1e3          	bgeu	a5,a2,51a <printint+0x2a>
  if(neg)
 53c:	00030c63          	beqz	t1,554 <printint+0x64>
    buf[i++] = '-';
 540:	fd050793          	addi	a5,a0,-48
 544:	00878533          	add	a0,a5,s0
 548:	02d00793          	li	a5,45
 54c:	fef50423          	sb	a5,-24(a0)
 550:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 554:	02e05563          	blez	a4,57e <printint+0x8e>
 558:	fc26                	sd	s1,56(sp)
 55a:	377d                	addiw	a4,a4,-1
 55c:	00e984b3          	add	s1,s3,a4
 560:	19fd                	addi	s3,s3,-1
 562:	99ba                	add	s3,s3,a4
 564:	1702                	slli	a4,a4,0x20
 566:	9301                	srli	a4,a4,0x20
 568:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 56c:	0004c583          	lbu	a1,0(s1)
 570:	854a                	mv	a0,s2
 572:	f61ff0ef          	jal	4d2 <putc>
  while(--i >= 0)
 576:	14fd                	addi	s1,s1,-1
 578:	ff349ae3          	bne	s1,s3,56c <printint+0x7c>
 57c:	74e2                	ld	s1,56(sp)
}
 57e:	60a6                	ld	ra,72(sp)
 580:	6406                	ld	s0,64(sp)
 582:	7942                	ld	s2,48(sp)
 584:	79a2                	ld	s3,40(sp)
 586:	6161                	addi	sp,sp,80
 588:	8082                	ret
  neg = 0;
 58a:	4301                	li	t1,0
 58c:	bfbd                	j	50a <printint+0x1a>

000000000000058e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 58e:	711d                	addi	sp,sp,-96
 590:	ec86                	sd	ra,88(sp)
 592:	e8a2                	sd	s0,80(sp)
 594:	e4a6                	sd	s1,72(sp)
 596:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 598:	0005c483          	lbu	s1,0(a1)
 59c:	22048363          	beqz	s1,7c2 <vprintf+0x234>
 5a0:	e0ca                	sd	s2,64(sp)
 5a2:	fc4e                	sd	s3,56(sp)
 5a4:	f852                	sd	s4,48(sp)
 5a6:	f456                	sd	s5,40(sp)
 5a8:	f05a                	sd	s6,32(sp)
 5aa:	ec5e                	sd	s7,24(sp)
 5ac:	e862                	sd	s8,16(sp)
 5ae:	8b2a                	mv	s6,a0
 5b0:	8a2e                	mv	s4,a1
 5b2:	8bb2                	mv	s7,a2
  state = 0;
 5b4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5b6:	4901                	li	s2,0
 5b8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5ba:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5be:	06400c13          	li	s8,100
 5c2:	a00d                	j	5e4 <vprintf+0x56>
        putc(fd, c0);
 5c4:	85a6                	mv	a1,s1
 5c6:	855a                	mv	a0,s6
 5c8:	f0bff0ef          	jal	4d2 <putc>
 5cc:	a019                	j	5d2 <vprintf+0x44>
    } else if(state == '%'){
 5ce:	03598363          	beq	s3,s5,5f4 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5d2:	0019079b          	addiw	a5,s2,1
 5d6:	893e                	mv	s2,a5
 5d8:	873e                	mv	a4,a5
 5da:	97d2                	add	a5,a5,s4
 5dc:	0007c483          	lbu	s1,0(a5)
 5e0:	1c048a63          	beqz	s1,7b4 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5e4:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5e8:	fe0993e3          	bnez	s3,5ce <vprintf+0x40>
      if(c0 == '%'){
 5ec:	fd579ce3          	bne	a5,s5,5c4 <vprintf+0x36>
        state = '%';
 5f0:	89be                	mv	s3,a5
 5f2:	b7c5                	j	5d2 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5f4:	00ea06b3          	add	a3,s4,a4
 5f8:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5fc:	1c060863          	beqz	a2,7cc <vprintf+0x23e>
      if(c0 == 'd'){
 600:	03878763          	beq	a5,s8,62e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 604:	f9478693          	addi	a3,a5,-108
 608:	0016b693          	seqz	a3,a3
 60c:	f9c60593          	addi	a1,a2,-100
 610:	e99d                	bnez	a1,646 <vprintf+0xb8>
 612:	ca95                	beqz	a3,646 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 614:	008b8493          	addi	s1,s7,8
 618:	4685                	li	a3,1
 61a:	4629                	li	a2,10
 61c:	000bb583          	ld	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	ecfff0ef          	jal	4f0 <printint>
        i += 1;
 626:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 628:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 62a:	4981                	li	s3,0
 62c:	b75d                	j	5d2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 62e:	008b8493          	addi	s1,s7,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000ba583          	lw	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	eb5ff0ef          	jal	4f0 <printint>
 640:	8ba6                	mv	s7,s1
      state = 0;
 642:	4981                	li	s3,0
 644:	b779                	j	5d2 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 646:	9752                	add	a4,a4,s4
 648:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 64c:	f9460713          	addi	a4,a2,-108
 650:	00173713          	seqz	a4,a4
 654:	8f75                	and	a4,a4,a3
 656:	f9c58513          	addi	a0,a1,-100
 65a:	18051363          	bnez	a0,7e0 <vprintf+0x252>
 65e:	18070163          	beqz	a4,7e0 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 662:	008b8493          	addi	s1,s7,8
 666:	4685                	li	a3,1
 668:	4629                	li	a2,10
 66a:	000bb583          	ld	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	e81ff0ef          	jal	4f0 <printint>
        i += 2;
 674:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 676:	8ba6                	mv	s7,s1
      state = 0;
 678:	4981                	li	s3,0
        i += 2;
 67a:	bfa1                	j	5d2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 67c:	008b8493          	addi	s1,s7,8
 680:	4681                	li	a3,0
 682:	4629                	li	a2,10
 684:	000be583          	lwu	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	e67ff0ef          	jal	4f0 <printint>
 68e:	8ba6                	mv	s7,s1
      state = 0;
 690:	4981                	li	s3,0
 692:	b781                	j	5d2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 694:	008b8493          	addi	s1,s7,8
 698:	4681                	li	a3,0
 69a:	4629                	li	a2,10
 69c:	000bb583          	ld	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	e4fff0ef          	jal	4f0 <printint>
        i += 1;
 6a6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	8ba6                	mv	s7,s1
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b71d                	j	5d2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ae:	008b8493          	addi	s1,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4629                	li	a2,10
 6b6:	000bb583          	ld	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	e35ff0ef          	jal	4f0 <printint>
        i += 2;
 6c0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c2:	8ba6                	mv	s7,s1
      state = 0;
 6c4:	4981                	li	s3,0
        i += 2;
 6c6:	b731                	j	5d2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6c8:	008b8493          	addi	s1,s7,8
 6cc:	4681                	li	a3,0
 6ce:	4641                	li	a2,16
 6d0:	000be583          	lwu	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	e1bff0ef          	jal	4f0 <printint>
 6da:	8ba6                	mv	s7,s1
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	bdd5                	j	5d2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e0:	008b8493          	addi	s1,s7,8
 6e4:	4681                	li	a3,0
 6e6:	4641                	li	a2,16
 6e8:	000bb583          	ld	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	e03ff0ef          	jal	4f0 <printint>
        i += 1;
 6f2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f4:	8ba6                	mv	s7,s1
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bde9                	j	5d2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fa:	008b8493          	addi	s1,s7,8
 6fe:	4681                	li	a3,0
 700:	4641                	li	a2,16
 702:	000bb583          	ld	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	de9ff0ef          	jal	4f0 <printint>
        i += 2;
 70c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 70e:	8ba6                	mv	s7,s1
      state = 0;
 710:	4981                	li	s3,0
        i += 2;
 712:	b5c1                	j	5d2 <vprintf+0x44>
 714:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 716:	008b8793          	addi	a5,s7,8
 71a:	8cbe                	mv	s9,a5
 71c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 720:	03000593          	li	a1,48
 724:	855a                	mv	a0,s6
 726:	dadff0ef          	jal	4d2 <putc>
  putc(fd, 'x');
 72a:	07800593          	li	a1,120
 72e:	855a                	mv	a0,s6
 730:	da3ff0ef          	jal	4d2 <putc>
 734:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 736:	00000b97          	auipc	s7,0x0
 73a:	34ab8b93          	addi	s7,s7,842 # a80 <digits>
 73e:	03c9d793          	srli	a5,s3,0x3c
 742:	97de                	add	a5,a5,s7
 744:	0007c583          	lbu	a1,0(a5)
 748:	855a                	mv	a0,s6
 74a:	d89ff0ef          	jal	4d2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 74e:	0992                	slli	s3,s3,0x4
 750:	34fd                	addiw	s1,s1,-1
 752:	f4f5                	bnez	s1,73e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 754:	8be6                	mv	s7,s9
      state = 0;
 756:	4981                	li	s3,0
 758:	6ca2                	ld	s9,8(sp)
 75a:	bda5                	j	5d2 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 75c:	008b8493          	addi	s1,s7,8
 760:	000bc583          	lbu	a1,0(s7)
 764:	855a                	mv	a0,s6
 766:	d6dff0ef          	jal	4d2 <putc>
 76a:	8ba6                	mv	s7,s1
      state = 0;
 76c:	4981                	li	s3,0
 76e:	b595                	j	5d2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 770:	008b8993          	addi	s3,s7,8
 774:	000bb483          	ld	s1,0(s7)
 778:	cc91                	beqz	s1,794 <vprintf+0x206>
        for(; *s; s++)
 77a:	0004c583          	lbu	a1,0(s1)
 77e:	c985                	beqz	a1,7ae <vprintf+0x220>
          putc(fd, *s);
 780:	855a                	mv	a0,s6
 782:	d51ff0ef          	jal	4d2 <putc>
        for(; *s; s++)
 786:	0485                	addi	s1,s1,1
 788:	0004c583          	lbu	a1,0(s1)
 78c:	f9f5                	bnez	a1,780 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 78e:	8bce                	mv	s7,s3
      state = 0;
 790:	4981                	li	s3,0
 792:	b581                	j	5d2 <vprintf+0x44>
          s = "(null)";
 794:	00000497          	auipc	s1,0x0
 798:	2e448493          	addi	s1,s1,740 # a78 <malloc+0x148>
        for(; *s; s++)
 79c:	02800593          	li	a1,40
 7a0:	b7c5                	j	780 <vprintf+0x1f2>
        putc(fd, '%');
 7a2:	85be                	mv	a1,a5
 7a4:	855a                	mv	a0,s6
 7a6:	d2dff0ef          	jal	4d2 <putc>
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b51d                	j	5d2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7ae:	8bce                	mv	s7,s3
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	b505                	j	5d2 <vprintf+0x44>
 7b4:	6906                	ld	s2,64(sp)
 7b6:	79e2                	ld	s3,56(sp)
 7b8:	7a42                	ld	s4,48(sp)
 7ba:	7aa2                	ld	s5,40(sp)
 7bc:	7b02                	ld	s6,32(sp)
 7be:	6be2                	ld	s7,24(sp)
 7c0:	6c42                	ld	s8,16(sp)
    }
  }
}
 7c2:	60e6                	ld	ra,88(sp)
 7c4:	6446                	ld	s0,80(sp)
 7c6:	64a6                	ld	s1,72(sp)
 7c8:	6125                	addi	sp,sp,96
 7ca:	8082                	ret
      if(c0 == 'd'){
 7cc:	06400713          	li	a4,100
 7d0:	e4e78fe3          	beq	a5,a4,62e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7d4:	f9478693          	addi	a3,a5,-108
 7d8:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7dc:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7de:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7e0:	07500513          	li	a0,117
 7e4:	e8a78ce3          	beq	a5,a0,67c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7e8:	f8b60513          	addi	a0,a2,-117
 7ec:	e119                	bnez	a0,7f2 <vprintf+0x264>
 7ee:	ea0693e3          	bnez	a3,694 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7f2:	f8b58513          	addi	a0,a1,-117
 7f6:	e119                	bnez	a0,7fc <vprintf+0x26e>
 7f8:	ea071be3          	bnez	a4,6ae <vprintf+0x120>
      } else if(c0 == 'x'){
 7fc:	07800513          	li	a0,120
 800:	eca784e3          	beq	a5,a0,6c8 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 804:	f8860613          	addi	a2,a2,-120
 808:	e219                	bnez	a2,80e <vprintf+0x280>
 80a:	ec069be3          	bnez	a3,6e0 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 80e:	f8858593          	addi	a1,a1,-120
 812:	e199                	bnez	a1,818 <vprintf+0x28a>
 814:	ee0713e3          	bnez	a4,6fa <vprintf+0x16c>
      } else if(c0 == 'p'){
 818:	07000713          	li	a4,112
 81c:	eee78ce3          	beq	a5,a4,714 <vprintf+0x186>
      } else if(c0 == 'c'){
 820:	06300713          	li	a4,99
 824:	f2e78ce3          	beq	a5,a4,75c <vprintf+0x1ce>
      } else if(c0 == 's'){
 828:	07300713          	li	a4,115
 82c:	f4e782e3          	beq	a5,a4,770 <vprintf+0x1e2>
      } else if(c0 == '%'){
 830:	02500713          	li	a4,37
 834:	f6e787e3          	beq	a5,a4,7a2 <vprintf+0x214>
        putc(fd, '%');
 838:	02500593          	li	a1,37
 83c:	855a                	mv	a0,s6
 83e:	c95ff0ef          	jal	4d2 <putc>
        putc(fd, c0);
 842:	85a6                	mv	a1,s1
 844:	855a                	mv	a0,s6
 846:	c8dff0ef          	jal	4d2 <putc>
      state = 0;
 84a:	4981                	li	s3,0
 84c:	b359                	j	5d2 <vprintf+0x44>

000000000000084e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 84e:	715d                	addi	sp,sp,-80
 850:	ec06                	sd	ra,24(sp)
 852:	e822                	sd	s0,16(sp)
 854:	1000                	addi	s0,sp,32
 856:	e010                	sd	a2,0(s0)
 858:	e414                	sd	a3,8(s0)
 85a:	e818                	sd	a4,16(s0)
 85c:	ec1c                	sd	a5,24(s0)
 85e:	03043023          	sd	a6,32(s0)
 862:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 866:	8622                	mv	a2,s0
 868:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 86c:	d23ff0ef          	jal	58e <vprintf>
}
 870:	60e2                	ld	ra,24(sp)
 872:	6442                	ld	s0,16(sp)
 874:	6161                	addi	sp,sp,80
 876:	8082                	ret

0000000000000878 <printf>:

void
printf(const char *fmt, ...)
{
 878:	711d                	addi	sp,sp,-96
 87a:	ec06                	sd	ra,24(sp)
 87c:	e822                	sd	s0,16(sp)
 87e:	1000                	addi	s0,sp,32
 880:	e40c                	sd	a1,8(s0)
 882:	e810                	sd	a2,16(s0)
 884:	ec14                	sd	a3,24(s0)
 886:	f018                	sd	a4,32(s0)
 888:	f41c                	sd	a5,40(s0)
 88a:	03043823          	sd	a6,48(s0)
 88e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 892:	00840613          	addi	a2,s0,8
 896:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 89a:	85aa                	mv	a1,a0
 89c:	4505                	li	a0,1
 89e:	cf1ff0ef          	jal	58e <vprintf>
}
 8a2:	60e2                	ld	ra,24(sp)
 8a4:	6442                	ld	s0,16(sp)
 8a6:	6125                	addi	sp,sp,96
 8a8:	8082                	ret

00000000000008aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8aa:	1141                	addi	sp,sp,-16
 8ac:	e406                	sd	ra,8(sp)
 8ae:	e022                	sd	s0,0(sp)
 8b0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8b2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b6:	00000797          	auipc	a5,0x0
 8ba:	74a7b783          	ld	a5,1866(a5) # 1000 <freep>
 8be:	a039                	j	8cc <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c0:	6398                	ld	a4,0(a5)
 8c2:	00e7e463          	bltu	a5,a4,8ca <free+0x20>
 8c6:	00e6ea63          	bltu	a3,a4,8da <free+0x30>
{
 8ca:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8cc:	fed7fae3          	bgeu	a5,a3,8c0 <free+0x16>
 8d0:	6398                	ld	a4,0(a5)
 8d2:	00e6e463          	bltu	a3,a4,8da <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d6:	fee7eae3          	bltu	a5,a4,8ca <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8da:	ff852583          	lw	a1,-8(a0)
 8de:	6390                	ld	a2,0(a5)
 8e0:	02059813          	slli	a6,a1,0x20
 8e4:	01c85713          	srli	a4,a6,0x1c
 8e8:	9736                	add	a4,a4,a3
 8ea:	02e60563          	beq	a2,a4,914 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8ee:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8f2:	4790                	lw	a2,8(a5)
 8f4:	02061593          	slli	a1,a2,0x20
 8f8:	01c5d713          	srli	a4,a1,0x1c
 8fc:	973e                	add	a4,a4,a5
 8fe:	02e68263          	beq	a3,a4,922 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 902:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 904:	00000717          	auipc	a4,0x0
 908:	6ef73e23          	sd	a5,1788(a4) # 1000 <freep>
}
 90c:	60a2                	ld	ra,8(sp)
 90e:	6402                	ld	s0,0(sp)
 910:	0141                	addi	sp,sp,16
 912:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 914:	4618                	lw	a4,8(a2)
 916:	9f2d                	addw	a4,a4,a1
 918:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91c:	6398                	ld	a4,0(a5)
 91e:	6310                	ld	a2,0(a4)
 920:	b7f9                	j	8ee <free+0x44>
    p->s.size += bp->s.size;
 922:	ff852703          	lw	a4,-8(a0)
 926:	9f31                	addw	a4,a4,a2
 928:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 92a:	ff053683          	ld	a3,-16(a0)
 92e:	bfd1                	j	902 <free+0x58>

0000000000000930 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 930:	7139                	addi	sp,sp,-64
 932:	fc06                	sd	ra,56(sp)
 934:	f822                	sd	s0,48(sp)
 936:	f04a                	sd	s2,32(sp)
 938:	ec4e                	sd	s3,24(sp)
 93a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 93c:	02051993          	slli	s3,a0,0x20
 940:	0209d993          	srli	s3,s3,0x20
 944:	09bd                	addi	s3,s3,15
 946:	0049d993          	srli	s3,s3,0x4
 94a:	2985                	addiw	s3,s3,1
 94c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 94e:	00000517          	auipc	a0,0x0
 952:	6b253503          	ld	a0,1714(a0) # 1000 <freep>
 956:	c905                	beqz	a0,986 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 958:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95a:	4798                	lw	a4,8(a5)
 95c:	09377663          	bgeu	a4,s3,9e8 <malloc+0xb8>
 960:	f426                	sd	s1,40(sp)
 962:	e852                	sd	s4,16(sp)
 964:	e456                	sd	s5,8(sp)
 966:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 968:	8a4e                	mv	s4,s3
 96a:	6705                	lui	a4,0x1
 96c:	00e9f363          	bgeu	s3,a4,972 <malloc+0x42>
 970:	6a05                	lui	s4,0x1
 972:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 976:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 97a:	00000497          	auipc	s1,0x0
 97e:	68648493          	addi	s1,s1,1670 # 1000 <freep>
  if(p == SBRK_ERROR)
 982:	5afd                	li	s5,-1
 984:	a83d                	j	9c2 <malloc+0x92>
 986:	f426                	sd	s1,40(sp)
 988:	e852                	sd	s4,16(sp)
 98a:	e456                	sd	s5,8(sp)
 98c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 98e:	00001797          	auipc	a5,0x1
 992:	88278793          	addi	a5,a5,-1918 # 1210 <base>
 996:	00000717          	auipc	a4,0x0
 99a:	66f73523          	sd	a5,1642(a4) # 1000 <freep>
 99e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9a0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9a4:	b7d1                	j	968 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9a6:	6398                	ld	a4,0(a5)
 9a8:	e118                	sd	a4,0(a0)
 9aa:	a899                	j	a00 <malloc+0xd0>
  hp->s.size = nu;
 9ac:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9b0:	0541                	addi	a0,a0,16
 9b2:	ef9ff0ef          	jal	8aa <free>
  return freep;
 9b6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9b8:	c125                	beqz	a0,a18 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ba:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9bc:	4798                	lw	a4,8(a5)
 9be:	03277163          	bgeu	a4,s2,9e0 <malloc+0xb0>
    if(p == freep)
 9c2:	6098                	ld	a4,0(s1)
 9c4:	853e                	mv	a0,a5
 9c6:	fef71ae3          	bne	a4,a5,9ba <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9ca:	8552                	mv	a0,s4
 9cc:	a13ff0ef          	jal	3de <sbrk>
  if(p == SBRK_ERROR)
 9d0:	fd551ee3          	bne	a0,s5,9ac <malloc+0x7c>
        return 0;
 9d4:	4501                	li	a0,0
 9d6:	74a2                	ld	s1,40(sp)
 9d8:	6a42                	ld	s4,16(sp)
 9da:	6aa2                	ld	s5,8(sp)
 9dc:	6b02                	ld	s6,0(sp)
 9de:	a03d                	j	a0c <malloc+0xdc>
 9e0:	74a2                	ld	s1,40(sp)
 9e2:	6a42                	ld	s4,16(sp)
 9e4:	6aa2                	ld	s5,8(sp)
 9e6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9e8:	fae90fe3          	beq	s2,a4,9a6 <malloc+0x76>
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
 a10:	7902                	ld	s2,32(sp)
 a12:	69e2                	ld	s3,24(sp)
 a14:	6121                	addi	sp,sp,64
 a16:	8082                	ret
 a18:	74a2                	ld	s1,40(sp)
 a1a:	6a42                	ld	s4,16(sp)
 a1c:	6aa2                	ld	s5,8(sp)
 a1e:	6b02                	ld	s6,0(sp)
 a20:	b7f5                	j	a0c <malloc+0xdc>
