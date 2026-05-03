
user/_memcat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  }
}

int
main(void)
{
   0:	8e010113          	addi	sp,sp,-1824
   4:	70113c23          	sd	ra,1816(sp)
   8:	70813823          	sd	s0,1808(sp)
   c:	70913423          	sd	s1,1800(sp)
  10:	71213023          	sd	s2,1792(sp)
  14:	6f313c23          	sd	s3,1784(sp)
  18:	6f413823          	sd	s4,1776(sp)
  1c:	6f513423          	sd	s5,1768(sp)
  20:	6f613023          	sd	s6,1760(sp)
  24:	6d713c23          	sd	s7,1752(sp)
  28:	6d813823          	sd	s8,1744(sp)
  2c:	6d913423          	sd	s9,1736(sp)
  30:	6da13023          	sd	s10,1728(sp)
  34:	6bb13c23          	sd	s11,1720(sp)
  38:	72010413          	addi	s0,sp,1824
  struct mem_event ev[16];
  int n, i;

  for(;;){
    n = memread(ev, 16);
  3c:	91040d93          	addi	s11,s0,-1776
    default:         return "UNKNOWN";
  40:	00001b17          	auipc	s6,0x1
  44:	a48b0b13          	addi	s6,s6,-1464 # a88 <malloc+0x12e>
  switch(t){
  48:	00001a17          	auipc	s4,0x1
  4c:	b30a0a13          	addi	s4,s4,-1232 # b78 <malloc+0x21e>
  50:	00001d17          	auipc	s10,0x1
  54:	a08d0d13          	addi	s10,s10,-1528 # a58 <malloc+0xfe>
    n = memread(ev, 16);
  58:	45c1                	li	a1,16
  5a:	856e                	mv	a0,s11
  5c:	498000ef          	jal	4f4 <memread>
  60:	8aaa                	mv	s5,a0
    if(n <= 0)
  62:	10a05f63          	blez	a0,180 <main+0x180>
  66:	92c40493          	addi	s1,s0,-1748
      break;

    for(i = 0; i < n; i++){
  6a:	4901                	li	s2,0
  switch(t){
  6c:	499d                	li	s3,7
    case MEM_FREE:   return "FREE";
  6e:	00001c97          	auipc	s9,0x1
  72:	a12c8c93          	addi	s9,s9,-1518 # a80 <malloc+0x126>
    case MEM_ALLOC:  return "ALLOC";
  76:	00001c17          	auipc	s8,0x1
  7a:	a02c0c13          	addi	s8,s8,-1534 # a78 <malloc+0x11e>
    case MEM_UNMAP:  return "UNMAP";
  7e:	00001b97          	auipc	s7,0x1
  82:	9f2b8b93          	addi	s7,s7,-1550 # a70 <malloc+0x116>
  86:	a061                	j	10e <main+0x10e>
    case MEM_GROW:   return "GROW";
  88:	00001817          	auipc	a6,0x1
  8c:	9c880813          	addi	a6,a6,-1592 # a50 <malloc+0xf6>
  switch(s){
  90:	41a8                	lw	a0,64(a1)
  92:	0ea9e063          	bltu	s3,a0,172 <main+0x172>
  96:	0405e503          	lwu	a0,64(a1)
  9a:	050a                	slli	a0,a0,0x2
  9c:	00001897          	auipc	a7,0x1
  a0:	abc88893          	addi	a7,a7,-1348 # b58 <malloc+0x1fe>
  a4:	9546                	add	a0,a0,a7
  a6:	4108                	lw	a0,0(a0)
  a8:	9546                	add	a0,a0,a7
  aa:	8502                	jr	a0
    case MEM_FAULT:  return "FAULT";
  ac:	00001817          	auipc	a6,0x1
  b0:	9b480813          	addi	a6,a6,-1612 # a60 <malloc+0x106>
  b4:	bff1                	j	90 <main+0x90>
    case MEM_MAP:    return "MAP";
  b6:	00001817          	auipc	a6,0x1
  ba:	9b280813          	addi	a6,a6,-1614 # a68 <malloc+0x10e>
  be:	bfc9                	j	90 <main+0x90>
    case MEM_UNMAP:  return "UNMAP";
  c0:	885e                	mv	a6,s7
  c2:	b7f9                	j	90 <main+0x90>
    case MEM_ALLOC:  return "ALLOC";
  c4:	8862                	mv	a6,s8
  c6:	b7e9                	j	90 <main+0x90>
    case MEM_FREE:   return "FREE";
  c8:	8866                	mv	a6,s9
  ca:	b7d9                	j	90 <main+0x90>
    default:         return "UNKNOWN";
  cc:	885a                	mv	a6,s6
  ce:	b7c9                	j	90 <main+0x90>
  switch(t){
  d0:	886a                	mv	a6,s10
  d2:	bf7d                	j	90 <main+0x90>
    case SRC_NONE:       return "NONE";
  d4:	00001897          	auipc	a7,0x1
  d8:	9bc88893          	addi	a7,a7,-1604 # a90 <malloc+0x136>
     
    
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s name=%s old=%p new=%p pa=0x%lx va=0x%lx\n",
  dc:	0145b503          	ld	a0,20(a1)
  e0:	f02a                	sd	a0,32(sp)
  e2:	01c5b503          	ld	a0,28(a1)
  e6:	ec2a                	sd	a0,24(sp)
  e8:	02c5b503          	ld	a0,44(a1)
  ec:	e82a                	sd	a0,16(sp)
  ee:	0245b503          	ld	a0,36(a1)
  f2:	e42a                	sd	a0,8(sp)
  f4:	e02e                	sd	a1,0(sp)
  f6:	85ca                	mv	a1,s2
  f8:	00001517          	auipc	a0,0x1
  fc:	9f850513          	addi	a0,a0,-1544 # af0 <malloc+0x196>
 100:	7a2000ef          	jal	8a2 <printf>
    for(i = 0; i < n; i++){
 104:	2905                	addiw	s2,s2,1
 106:	06848493          	addi	s1,s1,104
 10a:	f52a87e3          	beq	s5,s2,58 <main+0x58>
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s name=%s old=%p new=%p pa=0x%lx va=0x%lx\n",
 10e:	85a6                	mv	a1,s1
 110:	fe44a603          	lw	a2,-28(s1)
 114:	fec4a683          	lw	a3,-20(s1)
 118:	ff04a703          	lw	a4,-16(s1)
 11c:	ff84a783          	lw	a5,-8(s1)
  switch(t){
 120:	ff44a503          	lw	a0,-12(s1)
 124:	faa9e4e3          	bltu	s3,a0,cc <main+0xcc>
 128:	ff44e503          	lwu	a0,-12(s1)
 12c:	050a                	slli	a0,a0,0x2
 12e:	9552                	add	a0,a0,s4
 130:	4108                	lw	a0,0(a0)
 132:	9552                	add	a0,a0,s4
 134:	8502                	jr	a0
    case SRC_KFREE:      return "KFREE";
 136:	00001897          	auipc	a7,0x1
 13a:	96a88893          	addi	a7,a7,-1686 # aa0 <malloc+0x146>
 13e:	bf79                	j	dc <main+0xdc>
    case SRC_MAPPAGES:   return "MAPPAGES";
 140:	00001897          	auipc	a7,0x1
 144:	96888893          	addi	a7,a7,-1688 # aa8 <malloc+0x14e>
 148:	bf51                	j	dc <main+0xdc>
    case SRC_UVMUNMAP:   return "UVMUNMAP";
 14a:	00001897          	auipc	a7,0x1
 14e:	96e88893          	addi	a7,a7,-1682 # ab8 <malloc+0x15e>
 152:	b769                	j	dc <main+0xdc>
    case SRC_UVMALLOC:   return "UVMALLOC";
 154:	00001897          	auipc	a7,0x1
 158:	97488893          	addi	a7,a7,-1676 # ac8 <malloc+0x16e>
 15c:	b741                	j	dc <main+0xdc>
    case SRC_UVMDEALLOC: return "UVMDEALLOC";
 15e:	00001897          	auipc	a7,0x1
 162:	97a88893          	addi	a7,a7,-1670 # ad8 <malloc+0x17e>
 166:	bf9d                	j	dc <main+0xdc>
    case SRC_VMFAULT:    return "VMFAULT";
 168:	00001897          	auipc	a7,0x1
 16c:	98088893          	addi	a7,a7,-1664 # ae8 <malloc+0x18e>
 170:	b7b5                	j	dc <main+0xdc>
    default:             return "UNKNOWN";
 172:	88da                	mv	a7,s6
 174:	b7a5                	j	dc <main+0xdc>
  switch(s){
 176:	00001897          	auipc	a7,0x1
 17a:	92288893          	addi	a7,a7,-1758 # a98 <malloc+0x13e>
 17e:	bfb9                	j	dc <main+0xdc>
    }
  }

 

  exit(0);
 180:	4501                	li	a0,0
 182:	2ba000ef          	jal	43c <exit>

0000000000000186 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 186:	1141                	addi	sp,sp,-16
 188:	e406                	sd	ra,8(sp)
 18a:	e022                	sd	s0,0(sp)
 18c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 18e:	e73ff0ef          	jal	0 <main>
  exit(r);
 192:	2aa000ef          	jal	43c <exit>

0000000000000196 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 196:	1141                	addi	sp,sp,-16
 198:	e406                	sd	ra,8(sp)
 19a:	e022                	sd	s0,0(sp)
 19c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 19e:	87aa                	mv	a5,a0
 1a0:	0585                	addi	a1,a1,1
 1a2:	0785                	addi	a5,a5,1
 1a4:	fff5c703          	lbu	a4,-1(a1)
 1a8:	fee78fa3          	sb	a4,-1(a5)
 1ac:	fb75                	bnez	a4,1a0 <strcpy+0xa>
    ;
  return os;
}
 1ae:	60a2                	ld	ra,8(sp)
 1b0:	6402                	ld	s0,0(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e406                	sd	ra,8(sp)
 1ba:	e022                	sd	s0,0(sp)
 1bc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	cb91                	beqz	a5,1d6 <strcmp+0x20>
 1c4:	0005c703          	lbu	a4,0(a1)
 1c8:	00f71763          	bne	a4,a5,1d6 <strcmp+0x20>
    p++, q++;
 1cc:	0505                	addi	a0,a0,1
 1ce:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	fbe5                	bnez	a5,1c4 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1d6:	0005c503          	lbu	a0,0(a1)
}
 1da:	40a7853b          	subw	a0,a5,a0
 1de:	60a2                	ld	ra,8(sp)
 1e0:	6402                	ld	s0,0(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret

00000000000001e6 <strlen>:

uint
strlen(const char *s)
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e406                	sd	ra,8(sp)
 1ea:	e022                	sd	s0,0(sp)
 1ec:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	cf91                	beqz	a5,20e <strlen+0x28>
 1f4:	00150793          	addi	a5,a0,1
 1f8:	86be                	mv	a3,a5
 1fa:	0785                	addi	a5,a5,1
 1fc:	fff7c703          	lbu	a4,-1(a5)
 200:	ff65                	bnez	a4,1f8 <strlen+0x12>
 202:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 206:	60a2                	ld	ra,8(sp)
 208:	6402                	ld	s0,0(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  for(n = 0; s[n]; n++)
 20e:	4501                	li	a0,0
 210:	bfdd                	j	206 <strlen+0x20>

0000000000000212 <memset>:

void*
memset(void *dst, int c, uint n)
{
 212:	1141                	addi	sp,sp,-16
 214:	e406                	sd	ra,8(sp)
 216:	e022                	sd	s0,0(sp)
 218:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 21a:	ca19                	beqz	a2,230 <memset+0x1e>
 21c:	87aa                	mv	a5,a0
 21e:	1602                	slli	a2,a2,0x20
 220:	9201                	srli	a2,a2,0x20
 222:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 226:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 22a:	0785                	addi	a5,a5,1
 22c:	fee79de3          	bne	a5,a4,226 <memset+0x14>
  }
  return dst;
}
 230:	60a2                	ld	ra,8(sp)
 232:	6402                	ld	s0,0(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret

0000000000000238 <strchr>:

char*
strchr(const char *s, char c)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e406                	sd	ra,8(sp)
 23c:	e022                	sd	s0,0(sp)
 23e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 240:	00054783          	lbu	a5,0(a0)
 244:	cf81                	beqz	a5,25c <strchr+0x24>
    if(*s == c)
 246:	00f58763          	beq	a1,a5,254 <strchr+0x1c>
  for(; *s; s++)
 24a:	0505                	addi	a0,a0,1
 24c:	00054783          	lbu	a5,0(a0)
 250:	fbfd                	bnez	a5,246 <strchr+0xe>
      return (char*)s;
  return 0;
 252:	4501                	li	a0,0
}
 254:	60a2                	ld	ra,8(sp)
 256:	6402                	ld	s0,0(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret
  return 0;
 25c:	4501                	li	a0,0
 25e:	bfdd                	j	254 <strchr+0x1c>

0000000000000260 <gets>:

char*
gets(char *buf, int max)
{
 260:	711d                	addi	sp,sp,-96
 262:	ec86                	sd	ra,88(sp)
 264:	e8a2                	sd	s0,80(sp)
 266:	e4a6                	sd	s1,72(sp)
 268:	e0ca                	sd	s2,64(sp)
 26a:	fc4e                	sd	s3,56(sp)
 26c:	f852                	sd	s4,48(sp)
 26e:	f456                	sd	s5,40(sp)
 270:	f05a                	sd	s6,32(sp)
 272:	ec5e                	sd	s7,24(sp)
 274:	e862                	sd	s8,16(sp)
 276:	1080                	addi	s0,sp,96
 278:	8baa                	mv	s7,a0
 27a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27c:	892a                	mv	s2,a0
 27e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 280:	faf40b13          	addi	s6,s0,-81
 284:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 286:	8c26                	mv	s8,s1
 288:	0014899b          	addiw	s3,s1,1
 28c:	84ce                	mv	s1,s3
 28e:	0349d463          	bge	s3,s4,2b6 <gets+0x56>
    cc = read(0, &c, 1);
 292:	8656                	mv	a2,s5
 294:	85da                	mv	a1,s6
 296:	4501                	li	a0,0
 298:	1bc000ef          	jal	454 <read>
    if(cc < 1)
 29c:	00a05d63          	blez	a0,2b6 <gets+0x56>
      break;
    buf[i++] = c;
 2a0:	faf44783          	lbu	a5,-81(s0)
 2a4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a8:	0905                	addi	s2,s2,1
 2aa:	ff678713          	addi	a4,a5,-10
 2ae:	c319                	beqz	a4,2b4 <gets+0x54>
 2b0:	17cd                	addi	a5,a5,-13
 2b2:	fbf1                	bnez	a5,286 <gets+0x26>
    buf[i++] = c;
 2b4:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2b6:	9c5e                	add	s8,s8,s7
 2b8:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2bc:	855e                	mv	a0,s7
 2be:	60e6                	ld	ra,88(sp)
 2c0:	6446                	ld	s0,80(sp)
 2c2:	64a6                	ld	s1,72(sp)
 2c4:	6906                	ld	s2,64(sp)
 2c6:	79e2                	ld	s3,56(sp)
 2c8:	7a42                	ld	s4,48(sp)
 2ca:	7aa2                	ld	s5,40(sp)
 2cc:	7b02                	ld	s6,32(sp)
 2ce:	6be2                	ld	s7,24(sp)
 2d0:	6c42                	ld	s8,16(sp)
 2d2:	6125                	addi	sp,sp,96
 2d4:	8082                	ret

00000000000002d6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d6:	1101                	addi	sp,sp,-32
 2d8:	ec06                	sd	ra,24(sp)
 2da:	e822                	sd	s0,16(sp)
 2dc:	e04a                	sd	s2,0(sp)
 2de:	1000                	addi	s0,sp,32
 2e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e2:	4581                	li	a1,0
 2e4:	198000ef          	jal	47c <open>
  if(fd < 0)
 2e8:	02054263          	bltz	a0,30c <stat+0x36>
 2ec:	e426                	sd	s1,8(sp)
 2ee:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2f0:	85ca                	mv	a1,s2
 2f2:	1a2000ef          	jal	494 <fstat>
 2f6:	892a                	mv	s2,a0
  close(fd);
 2f8:	8526                	mv	a0,s1
 2fa:	16a000ef          	jal	464 <close>
  return r;
 2fe:	64a2                	ld	s1,8(sp)
}
 300:	854a                	mv	a0,s2
 302:	60e2                	ld	ra,24(sp)
 304:	6442                	ld	s0,16(sp)
 306:	6902                	ld	s2,0(sp)
 308:	6105                	addi	sp,sp,32
 30a:	8082                	ret
    return -1;
 30c:	57fd                	li	a5,-1
 30e:	893e                	mv	s2,a5
 310:	bfc5                	j	300 <stat+0x2a>

0000000000000312 <atoi>:

int
atoi(const char *s)
{
 312:	1141                	addi	sp,sp,-16
 314:	e406                	sd	ra,8(sp)
 316:	e022                	sd	s0,0(sp)
 318:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31a:	00054683          	lbu	a3,0(a0)
 31e:	fd06879b          	addiw	a5,a3,-48
 322:	0ff7f793          	zext.b	a5,a5
 326:	4625                	li	a2,9
 328:	02f66963          	bltu	a2,a5,35a <atoi+0x48>
 32c:	872a                	mv	a4,a0
  n = 0;
 32e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 330:	0705                	addi	a4,a4,1
 332:	0025179b          	slliw	a5,a0,0x2
 336:	9fa9                	addw	a5,a5,a0
 338:	0017979b          	slliw	a5,a5,0x1
 33c:	9fb5                	addw	a5,a5,a3
 33e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 342:	00074683          	lbu	a3,0(a4)
 346:	fd06879b          	addiw	a5,a3,-48
 34a:	0ff7f793          	zext.b	a5,a5
 34e:	fef671e3          	bgeu	a2,a5,330 <atoi+0x1e>
  return n;
}
 352:	60a2                	ld	ra,8(sp)
 354:	6402                	ld	s0,0(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
  n = 0;
 35a:	4501                	li	a0,0
 35c:	bfdd                	j	352 <atoi+0x40>

000000000000035e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 366:	02b57563          	bgeu	a0,a1,390 <memmove+0x32>
    while(n-- > 0)
 36a:	00c05f63          	blez	a2,388 <memmove+0x2a>
 36e:	1602                	slli	a2,a2,0x20
 370:	9201                	srli	a2,a2,0x20
 372:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 376:	872a                	mv	a4,a0
      *dst++ = *src++;
 378:	0585                	addi	a1,a1,1
 37a:	0705                	addi	a4,a4,1
 37c:	fff5c683          	lbu	a3,-1(a1)
 380:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 384:	fee79ae3          	bne	a5,a4,378 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 388:	60a2                	ld	ra,8(sp)
 38a:	6402                	ld	s0,0(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret
    while(n-- > 0)
 390:	fec05ce3          	blez	a2,388 <memmove+0x2a>
    dst += n;
 394:	00c50733          	add	a4,a0,a2
    src += n;
 398:	95b2                	add	a1,a1,a2
 39a:	fff6079b          	addiw	a5,a2,-1
 39e:	1782                	slli	a5,a5,0x20
 3a0:	9381                	srli	a5,a5,0x20
 3a2:	fff7c793          	not	a5,a5
 3a6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3a8:	15fd                	addi	a1,a1,-1
 3aa:	177d                	addi	a4,a4,-1
 3ac:	0005c683          	lbu	a3,0(a1)
 3b0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3b4:	fef71ae3          	bne	a4,a5,3a8 <memmove+0x4a>
 3b8:	bfc1                	j	388 <memmove+0x2a>

00000000000003ba <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e406                	sd	ra,8(sp)
 3be:	e022                	sd	s0,0(sp)
 3c0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3c2:	c61d                	beqz	a2,3f0 <memcmp+0x36>
 3c4:	1602                	slli	a2,a2,0x20
 3c6:	9201                	srli	a2,a2,0x20
 3c8:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3cc:	00054783          	lbu	a5,0(a0)
 3d0:	0005c703          	lbu	a4,0(a1)
 3d4:	00e79863          	bne	a5,a4,3e4 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3d8:	0505                	addi	a0,a0,1
    p2++;
 3da:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3dc:	fed518e3          	bne	a0,a3,3cc <memcmp+0x12>
  }
  return 0;
 3e0:	4501                	li	a0,0
 3e2:	a019                	j	3e8 <memcmp+0x2e>
      return *p1 - *p2;
 3e4:	40e7853b          	subw	a0,a5,a4
}
 3e8:	60a2                	ld	ra,8(sp)
 3ea:	6402                	ld	s0,0(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret
  return 0;
 3f0:	4501                	li	a0,0
 3f2:	bfdd                	j	3e8 <memcmp+0x2e>

00000000000003f4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e406                	sd	ra,8(sp)
 3f8:	e022                	sd	s0,0(sp)
 3fa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3fc:	f63ff0ef          	jal	35e <memmove>
}
 400:	60a2                	ld	ra,8(sp)
 402:	6402                	ld	s0,0(sp)
 404:	0141                	addi	sp,sp,16
 406:	8082                	ret

0000000000000408 <sbrk>:

char *
sbrk(int n) {
 408:	1141                	addi	sp,sp,-16
 40a:	e406                	sd	ra,8(sp)
 40c:	e022                	sd	s0,0(sp)
 40e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 410:	4585                	li	a1,1
 412:	0b2000ef          	jal	4c4 <sys_sbrk>
}
 416:	60a2                	ld	ra,8(sp)
 418:	6402                	ld	s0,0(sp)
 41a:	0141                	addi	sp,sp,16
 41c:	8082                	ret

000000000000041e <sbrklazy>:

char *
sbrklazy(int n) {
 41e:	1141                	addi	sp,sp,-16
 420:	e406                	sd	ra,8(sp)
 422:	e022                	sd	s0,0(sp)
 424:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 426:	4589                	li	a1,2
 428:	09c000ef          	jal	4c4 <sys_sbrk>
}
 42c:	60a2                	ld	ra,8(sp)
 42e:	6402                	ld	s0,0(sp)
 430:	0141                	addi	sp,sp,16
 432:	8082                	ret

0000000000000434 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 434:	4885                	li	a7,1
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <exit>:
.global exit
exit:
 li a7, SYS_exit
 43c:	4889                	li	a7,2
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <wait>:
.global wait
wait:
 li a7, SYS_wait
 444:	488d                	li	a7,3
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 44c:	4891                	li	a7,4
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <read>:
.global read
read:
 li a7, SYS_read
 454:	4895                	li	a7,5
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <write>:
.global write
write:
 li a7, SYS_write
 45c:	48c1                	li	a7,16
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <close>:
.global close
close:
 li a7, SYS_close
 464:	48d5                	li	a7,21
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <kill>:
.global kill
kill:
 li a7, SYS_kill
 46c:	4899                	li	a7,6
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <exec>:
.global exec
exec:
 li a7, SYS_exec
 474:	489d                	li	a7,7
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <open>:
.global open
open:
 li a7, SYS_open
 47c:	48bd                	li	a7,15
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 484:	48c5                	li	a7,17
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 48c:	48c9                	li	a7,18
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 494:	48a1                	li	a7,8
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <link>:
.global link
link:
 li a7, SYS_link
 49c:	48cd                	li	a7,19
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4a4:	48d1                	li	a7,20
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ac:	48a5                	li	a7,9
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4b4:	48a9                	li	a7,10
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4bc:	48ad                	li	a7,11
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4c4:	48b1                	li	a7,12
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <pause>:
.global pause
pause:
 li a7, SYS_pause
 4cc:	48b5                	li	a7,13
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4d4:	48b9                	li	a7,14
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <csread>:
.global csread
csread:
 li a7, SYS_csread
 4dc:	48d9                	li	a7,22
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 4e4:	48dd                	li	a7,23
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 4ec:	48e1                	li	a7,24
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <memread>:
.global memread
memread:
 li a7, SYS_memread
 4f4:	48e5                	li	a7,25
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4fc:	1101                	addi	sp,sp,-32
 4fe:	ec06                	sd	ra,24(sp)
 500:	e822                	sd	s0,16(sp)
 502:	1000                	addi	s0,sp,32
 504:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 508:	4605                	li	a2,1
 50a:	fef40593          	addi	a1,s0,-17
 50e:	f4fff0ef          	jal	45c <write>
}
 512:	60e2                	ld	ra,24(sp)
 514:	6442                	ld	s0,16(sp)
 516:	6105                	addi	sp,sp,32
 518:	8082                	ret

000000000000051a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 51a:	715d                	addi	sp,sp,-80
 51c:	e486                	sd	ra,72(sp)
 51e:	e0a2                	sd	s0,64(sp)
 520:	f84a                	sd	s2,48(sp)
 522:	f44e                	sd	s3,40(sp)
 524:	0880                	addi	s0,sp,80
 526:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 528:	c6d1                	beqz	a3,5b4 <printint+0x9a>
 52a:	0805d563          	bgez	a1,5b4 <printint+0x9a>
    neg = 1;
    x = -xx;
 52e:	40b005b3          	neg	a1,a1
    neg = 1;
 532:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 534:	fb840993          	addi	s3,s0,-72
  neg = 0;
 538:	86ce                	mv	a3,s3
  i = 0;
 53a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 53c:	00000817          	auipc	a6,0x0
 540:	65c80813          	addi	a6,a6,1628 # b98 <digits>
 544:	88ba                	mv	a7,a4
 546:	0017051b          	addiw	a0,a4,1
 54a:	872a                	mv	a4,a0
 54c:	02c5f7b3          	remu	a5,a1,a2
 550:	97c2                	add	a5,a5,a6
 552:	0007c783          	lbu	a5,0(a5)
 556:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 55a:	87ae                	mv	a5,a1
 55c:	02c5d5b3          	divu	a1,a1,a2
 560:	0685                	addi	a3,a3,1
 562:	fec7f1e3          	bgeu	a5,a2,544 <printint+0x2a>
  if(neg)
 566:	00030c63          	beqz	t1,57e <printint+0x64>
    buf[i++] = '-';
 56a:	fd050793          	addi	a5,a0,-48
 56e:	00878533          	add	a0,a5,s0
 572:	02d00793          	li	a5,45
 576:	fef50423          	sb	a5,-24(a0)
 57a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 57e:	02e05563          	blez	a4,5a8 <printint+0x8e>
 582:	fc26                	sd	s1,56(sp)
 584:	377d                	addiw	a4,a4,-1
 586:	00e984b3          	add	s1,s3,a4
 58a:	19fd                	addi	s3,s3,-1
 58c:	99ba                	add	s3,s3,a4
 58e:	1702                	slli	a4,a4,0x20
 590:	9301                	srli	a4,a4,0x20
 592:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 596:	0004c583          	lbu	a1,0(s1)
 59a:	854a                	mv	a0,s2
 59c:	f61ff0ef          	jal	4fc <putc>
  while(--i >= 0)
 5a0:	14fd                	addi	s1,s1,-1
 5a2:	ff349ae3          	bne	s1,s3,596 <printint+0x7c>
 5a6:	74e2                	ld	s1,56(sp)
}
 5a8:	60a6                	ld	ra,72(sp)
 5aa:	6406                	ld	s0,64(sp)
 5ac:	7942                	ld	s2,48(sp)
 5ae:	79a2                	ld	s3,40(sp)
 5b0:	6161                	addi	sp,sp,80
 5b2:	8082                	ret
  neg = 0;
 5b4:	4301                	li	t1,0
 5b6:	bfbd                	j	534 <printint+0x1a>

00000000000005b8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5b8:	711d                	addi	sp,sp,-96
 5ba:	ec86                	sd	ra,88(sp)
 5bc:	e8a2                	sd	s0,80(sp)
 5be:	e4a6                	sd	s1,72(sp)
 5c0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5c2:	0005c483          	lbu	s1,0(a1)
 5c6:	22048363          	beqz	s1,7ec <vprintf+0x234>
 5ca:	e0ca                	sd	s2,64(sp)
 5cc:	fc4e                	sd	s3,56(sp)
 5ce:	f852                	sd	s4,48(sp)
 5d0:	f456                	sd	s5,40(sp)
 5d2:	f05a                	sd	s6,32(sp)
 5d4:	ec5e                	sd	s7,24(sp)
 5d6:	e862                	sd	s8,16(sp)
 5d8:	8b2a                	mv	s6,a0
 5da:	8a2e                	mv	s4,a1
 5dc:	8bb2                	mv	s7,a2
  state = 0;
 5de:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5e0:	4901                	li	s2,0
 5e2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5e4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5e8:	06400c13          	li	s8,100
 5ec:	a00d                	j	60e <vprintf+0x56>
        putc(fd, c0);
 5ee:	85a6                	mv	a1,s1
 5f0:	855a                	mv	a0,s6
 5f2:	f0bff0ef          	jal	4fc <putc>
 5f6:	a019                	j	5fc <vprintf+0x44>
    } else if(state == '%'){
 5f8:	03598363          	beq	s3,s5,61e <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5fc:	0019079b          	addiw	a5,s2,1
 600:	893e                	mv	s2,a5
 602:	873e                	mv	a4,a5
 604:	97d2                	add	a5,a5,s4
 606:	0007c483          	lbu	s1,0(a5)
 60a:	1c048a63          	beqz	s1,7de <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 60e:	0004879b          	sext.w	a5,s1
    if(state == 0){
 612:	fe0993e3          	bnez	s3,5f8 <vprintf+0x40>
      if(c0 == '%'){
 616:	fd579ce3          	bne	a5,s5,5ee <vprintf+0x36>
        state = '%';
 61a:	89be                	mv	s3,a5
 61c:	b7c5                	j	5fc <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 61e:	00ea06b3          	add	a3,s4,a4
 622:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 626:	1c060863          	beqz	a2,7f6 <vprintf+0x23e>
      if(c0 == 'd'){
 62a:	03878763          	beq	a5,s8,658 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 62e:	f9478693          	addi	a3,a5,-108
 632:	0016b693          	seqz	a3,a3
 636:	f9c60593          	addi	a1,a2,-100
 63a:	e99d                	bnez	a1,670 <vprintf+0xb8>
 63c:	ca95                	beqz	a3,670 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63e:	008b8493          	addi	s1,s7,8
 642:	4685                	li	a3,1
 644:	4629                	li	a2,10
 646:	000bb583          	ld	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	ecfff0ef          	jal	51a <printint>
        i += 1;
 650:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 652:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 654:	4981                	li	s3,0
 656:	b75d                	j	5fc <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 658:	008b8493          	addi	s1,s7,8
 65c:	4685                	li	a3,1
 65e:	4629                	li	a2,10
 660:	000ba583          	lw	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	eb5ff0ef          	jal	51a <printint>
 66a:	8ba6                	mv	s7,s1
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b779                	j	5fc <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 670:	9752                	add	a4,a4,s4
 672:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 676:	f9460713          	addi	a4,a2,-108
 67a:	00173713          	seqz	a4,a4
 67e:	8f75                	and	a4,a4,a3
 680:	f9c58513          	addi	a0,a1,-100
 684:	18051363          	bnez	a0,80a <vprintf+0x252>
 688:	18070163          	beqz	a4,80a <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68c:	008b8493          	addi	s1,s7,8
 690:	4685                	li	a3,1
 692:	4629                	li	a2,10
 694:	000bb583          	ld	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	e81ff0ef          	jal	51a <printint>
        i += 2;
 69e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a0:	8ba6                	mv	s7,s1
      state = 0;
 6a2:	4981                	li	s3,0
        i += 2;
 6a4:	bfa1                	j	5fc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6a6:	008b8493          	addi	s1,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000be583          	lwu	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	e67ff0ef          	jal	51a <printint>
 6b8:	8ba6                	mv	s7,s1
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b781                	j	5fc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6be:	008b8493          	addi	s1,s7,8
 6c2:	4681                	li	a3,0
 6c4:	4629                	li	a2,10
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	e4fff0ef          	jal	51a <printint>
        i += 1;
 6d0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d2:	8ba6                	mv	s7,s1
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b71d                	j	5fc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d8:	008b8493          	addi	s1,s7,8
 6dc:	4681                	li	a3,0
 6de:	4629                	li	a2,10
 6e0:	000bb583          	ld	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	e35ff0ef          	jal	51a <printint>
        i += 2;
 6ea:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ec:	8ba6                	mv	s7,s1
      state = 0;
 6ee:	4981                	li	s3,0
        i += 2;
 6f0:	b731                	j	5fc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6f2:	008b8493          	addi	s1,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4641                	li	a2,16
 6fa:	000be583          	lwu	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	e1bff0ef          	jal	51a <printint>
 704:	8ba6                	mv	s7,s1
      state = 0;
 706:	4981                	li	s3,0
 708:	bdd5                	j	5fc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 70a:	008b8493          	addi	s1,s7,8
 70e:	4681                	li	a3,0
 710:	4641                	li	a2,16
 712:	000bb583          	ld	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	e03ff0ef          	jal	51a <printint>
        i += 1;
 71c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 71e:	8ba6                	mv	s7,s1
      state = 0;
 720:	4981                	li	s3,0
 722:	bde9                	j	5fc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 724:	008b8493          	addi	s1,s7,8
 728:	4681                	li	a3,0
 72a:	4641                	li	a2,16
 72c:	000bb583          	ld	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	de9ff0ef          	jal	51a <printint>
        i += 2;
 736:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 738:	8ba6                	mv	s7,s1
      state = 0;
 73a:	4981                	li	s3,0
        i += 2;
 73c:	b5c1                	j	5fc <vprintf+0x44>
 73e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 740:	008b8793          	addi	a5,s7,8
 744:	8cbe                	mv	s9,a5
 746:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 74a:	03000593          	li	a1,48
 74e:	855a                	mv	a0,s6
 750:	dadff0ef          	jal	4fc <putc>
  putc(fd, 'x');
 754:	07800593          	li	a1,120
 758:	855a                	mv	a0,s6
 75a:	da3ff0ef          	jal	4fc <putc>
 75e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 760:	00000b97          	auipc	s7,0x0
 764:	438b8b93          	addi	s7,s7,1080 # b98 <digits>
 768:	03c9d793          	srli	a5,s3,0x3c
 76c:	97de                	add	a5,a5,s7
 76e:	0007c583          	lbu	a1,0(a5)
 772:	855a                	mv	a0,s6
 774:	d89ff0ef          	jal	4fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 778:	0992                	slli	s3,s3,0x4
 77a:	34fd                	addiw	s1,s1,-1
 77c:	f4f5                	bnez	s1,768 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 77e:	8be6                	mv	s7,s9
      state = 0;
 780:	4981                	li	s3,0
 782:	6ca2                	ld	s9,8(sp)
 784:	bda5                	j	5fc <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 786:	008b8493          	addi	s1,s7,8
 78a:	000bc583          	lbu	a1,0(s7)
 78e:	855a                	mv	a0,s6
 790:	d6dff0ef          	jal	4fc <putc>
 794:	8ba6                	mv	s7,s1
      state = 0;
 796:	4981                	li	s3,0
 798:	b595                	j	5fc <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 79a:	008b8993          	addi	s3,s7,8
 79e:	000bb483          	ld	s1,0(s7)
 7a2:	cc91                	beqz	s1,7be <vprintf+0x206>
        for(; *s; s++)
 7a4:	0004c583          	lbu	a1,0(s1)
 7a8:	c985                	beqz	a1,7d8 <vprintf+0x220>
          putc(fd, *s);
 7aa:	855a                	mv	a0,s6
 7ac:	d51ff0ef          	jal	4fc <putc>
        for(; *s; s++)
 7b0:	0485                	addi	s1,s1,1
 7b2:	0004c583          	lbu	a1,0(s1)
 7b6:	f9f5                	bnez	a1,7aa <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7b8:	8bce                	mv	s7,s3
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b581                	j	5fc <vprintf+0x44>
          s = "(null)";
 7be:	00000497          	auipc	s1,0x0
 7c2:	39248493          	addi	s1,s1,914 # b50 <malloc+0x1f6>
        for(; *s; s++)
 7c6:	02800593          	li	a1,40
 7ca:	b7c5                	j	7aa <vprintf+0x1f2>
        putc(fd, '%');
 7cc:	85be                	mv	a1,a5
 7ce:	855a                	mv	a0,s6
 7d0:	d2dff0ef          	jal	4fc <putc>
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	b51d                	j	5fc <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7d8:	8bce                	mv	s7,s3
      state = 0;
 7da:	4981                	li	s3,0
 7dc:	b505                	j	5fc <vprintf+0x44>
 7de:	6906                	ld	s2,64(sp)
 7e0:	79e2                	ld	s3,56(sp)
 7e2:	7a42                	ld	s4,48(sp)
 7e4:	7aa2                	ld	s5,40(sp)
 7e6:	7b02                	ld	s6,32(sp)
 7e8:	6be2                	ld	s7,24(sp)
 7ea:	6c42                	ld	s8,16(sp)
    }
  }
}
 7ec:	60e6                	ld	ra,88(sp)
 7ee:	6446                	ld	s0,80(sp)
 7f0:	64a6                	ld	s1,72(sp)
 7f2:	6125                	addi	sp,sp,96
 7f4:	8082                	ret
      if(c0 == 'd'){
 7f6:	06400713          	li	a4,100
 7fa:	e4e78fe3          	beq	a5,a4,658 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7fe:	f9478693          	addi	a3,a5,-108
 802:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 806:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 808:	4701                	li	a4,0
      } else if(c0 == 'u'){
 80a:	07500513          	li	a0,117
 80e:	e8a78ce3          	beq	a5,a0,6a6 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 812:	f8b60513          	addi	a0,a2,-117
 816:	e119                	bnez	a0,81c <vprintf+0x264>
 818:	ea0693e3          	bnez	a3,6be <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 81c:	f8b58513          	addi	a0,a1,-117
 820:	e119                	bnez	a0,826 <vprintf+0x26e>
 822:	ea071be3          	bnez	a4,6d8 <vprintf+0x120>
      } else if(c0 == 'x'){
 826:	07800513          	li	a0,120
 82a:	eca784e3          	beq	a5,a0,6f2 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 82e:	f8860613          	addi	a2,a2,-120
 832:	e219                	bnez	a2,838 <vprintf+0x280>
 834:	ec069be3          	bnez	a3,70a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 838:	f8858593          	addi	a1,a1,-120
 83c:	e199                	bnez	a1,842 <vprintf+0x28a>
 83e:	ee0713e3          	bnez	a4,724 <vprintf+0x16c>
      } else if(c0 == 'p'){
 842:	07000713          	li	a4,112
 846:	eee78ce3          	beq	a5,a4,73e <vprintf+0x186>
      } else if(c0 == 'c'){
 84a:	06300713          	li	a4,99
 84e:	f2e78ce3          	beq	a5,a4,786 <vprintf+0x1ce>
      } else if(c0 == 's'){
 852:	07300713          	li	a4,115
 856:	f4e782e3          	beq	a5,a4,79a <vprintf+0x1e2>
      } else if(c0 == '%'){
 85a:	02500713          	li	a4,37
 85e:	f6e787e3          	beq	a5,a4,7cc <vprintf+0x214>
        putc(fd, '%');
 862:	02500593          	li	a1,37
 866:	855a                	mv	a0,s6
 868:	c95ff0ef          	jal	4fc <putc>
        putc(fd, c0);
 86c:	85a6                	mv	a1,s1
 86e:	855a                	mv	a0,s6
 870:	c8dff0ef          	jal	4fc <putc>
      state = 0;
 874:	4981                	li	s3,0
 876:	b359                	j	5fc <vprintf+0x44>

0000000000000878 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 878:	715d                	addi	sp,sp,-80
 87a:	ec06                	sd	ra,24(sp)
 87c:	e822                	sd	s0,16(sp)
 87e:	1000                	addi	s0,sp,32
 880:	e010                	sd	a2,0(s0)
 882:	e414                	sd	a3,8(s0)
 884:	e818                	sd	a4,16(s0)
 886:	ec1c                	sd	a5,24(s0)
 888:	03043023          	sd	a6,32(s0)
 88c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 890:	8622                	mv	a2,s0
 892:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 896:	d23ff0ef          	jal	5b8 <vprintf>
}
 89a:	60e2                	ld	ra,24(sp)
 89c:	6442                	ld	s0,16(sp)
 89e:	6161                	addi	sp,sp,80
 8a0:	8082                	ret

00000000000008a2 <printf>:

void
printf(const char *fmt, ...)
{
 8a2:	711d                	addi	sp,sp,-96
 8a4:	ec06                	sd	ra,24(sp)
 8a6:	e822                	sd	s0,16(sp)
 8a8:	1000                	addi	s0,sp,32
 8aa:	e40c                	sd	a1,8(s0)
 8ac:	e810                	sd	a2,16(s0)
 8ae:	ec14                	sd	a3,24(s0)
 8b0:	f018                	sd	a4,32(s0)
 8b2:	f41c                	sd	a5,40(s0)
 8b4:	03043823          	sd	a6,48(s0)
 8b8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8bc:	00840613          	addi	a2,s0,8
 8c0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8c4:	85aa                	mv	a1,a0
 8c6:	4505                	li	a0,1
 8c8:	cf1ff0ef          	jal	5b8 <vprintf>
}
 8cc:	60e2                	ld	ra,24(sp)
 8ce:	6442                	ld	s0,16(sp)
 8d0:	6125                	addi	sp,sp,96
 8d2:	8082                	ret

00000000000008d4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8d4:	1141                	addi	sp,sp,-16
 8d6:	e406                	sd	ra,8(sp)
 8d8:	e022                	sd	s0,0(sp)
 8da:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8dc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e0:	00000797          	auipc	a5,0x0
 8e4:	7207b783          	ld	a5,1824(a5) # 1000 <freep>
 8e8:	a039                	j	8f6 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ea:	6398                	ld	a4,0(a5)
 8ec:	00e7e463          	bltu	a5,a4,8f4 <free+0x20>
 8f0:	00e6ea63          	bltu	a3,a4,904 <free+0x30>
{
 8f4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f6:	fed7fae3          	bgeu	a5,a3,8ea <free+0x16>
 8fa:	6398                	ld	a4,0(a5)
 8fc:	00e6e463          	bltu	a3,a4,904 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 900:	fee7eae3          	bltu	a5,a4,8f4 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 904:	ff852583          	lw	a1,-8(a0)
 908:	6390                	ld	a2,0(a5)
 90a:	02059813          	slli	a6,a1,0x20
 90e:	01c85713          	srli	a4,a6,0x1c
 912:	9736                	add	a4,a4,a3
 914:	02e60563          	beq	a2,a4,93e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 918:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 91c:	4790                	lw	a2,8(a5)
 91e:	02061593          	slli	a1,a2,0x20
 922:	01c5d713          	srli	a4,a1,0x1c
 926:	973e                	add	a4,a4,a5
 928:	02e68263          	beq	a3,a4,94c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 92c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 92e:	00000717          	auipc	a4,0x0
 932:	6cf73923          	sd	a5,1746(a4) # 1000 <freep>
}
 936:	60a2                	ld	ra,8(sp)
 938:	6402                	ld	s0,0(sp)
 93a:	0141                	addi	sp,sp,16
 93c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 93e:	4618                	lw	a4,8(a2)
 940:	9f2d                	addw	a4,a4,a1
 942:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 946:	6398                	ld	a4,0(a5)
 948:	6310                	ld	a2,0(a4)
 94a:	b7f9                	j	918 <free+0x44>
    p->s.size += bp->s.size;
 94c:	ff852703          	lw	a4,-8(a0)
 950:	9f31                	addw	a4,a4,a2
 952:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 954:	ff053683          	ld	a3,-16(a0)
 958:	bfd1                	j	92c <free+0x58>

000000000000095a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 95a:	7139                	addi	sp,sp,-64
 95c:	fc06                	sd	ra,56(sp)
 95e:	f822                	sd	s0,48(sp)
 960:	f04a                	sd	s2,32(sp)
 962:	ec4e                	sd	s3,24(sp)
 964:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 966:	02051993          	slli	s3,a0,0x20
 96a:	0209d993          	srli	s3,s3,0x20
 96e:	09bd                	addi	s3,s3,15
 970:	0049d993          	srli	s3,s3,0x4
 974:	2985                	addiw	s3,s3,1
 976:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 978:	00000517          	auipc	a0,0x0
 97c:	68853503          	ld	a0,1672(a0) # 1000 <freep>
 980:	c905                	beqz	a0,9b0 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 982:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 984:	4798                	lw	a4,8(a5)
 986:	09377663          	bgeu	a4,s3,a12 <malloc+0xb8>
 98a:	f426                	sd	s1,40(sp)
 98c:	e852                	sd	s4,16(sp)
 98e:	e456                	sd	s5,8(sp)
 990:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 992:	8a4e                	mv	s4,s3
 994:	6705                	lui	a4,0x1
 996:	00e9f363          	bgeu	s3,a4,99c <malloc+0x42>
 99a:	6a05                	lui	s4,0x1
 99c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9a0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9a4:	00000497          	auipc	s1,0x0
 9a8:	65c48493          	addi	s1,s1,1628 # 1000 <freep>
  if(p == SBRK_ERROR)
 9ac:	5afd                	li	s5,-1
 9ae:	a83d                	j	9ec <malloc+0x92>
 9b0:	f426                	sd	s1,40(sp)
 9b2:	e852                	sd	s4,16(sp)
 9b4:	e456                	sd	s5,8(sp)
 9b6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9b8:	00000797          	auipc	a5,0x0
 9bc:	65878793          	addi	a5,a5,1624 # 1010 <base>
 9c0:	00000717          	auipc	a4,0x0
 9c4:	64f73023          	sd	a5,1600(a4) # 1000 <freep>
 9c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9ce:	b7d1                	j	992 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9d0:	6398                	ld	a4,0(a5)
 9d2:	e118                	sd	a4,0(a0)
 9d4:	a899                	j	a2a <malloc+0xd0>
  hp->s.size = nu;
 9d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9da:	0541                	addi	a0,a0,16
 9dc:	ef9ff0ef          	jal	8d4 <free>
  return freep;
 9e0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9e2:	c125                	beqz	a0,a42 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e6:	4798                	lw	a4,8(a5)
 9e8:	03277163          	bgeu	a4,s2,a0a <malloc+0xb0>
    if(p == freep)
 9ec:	6098                	ld	a4,0(s1)
 9ee:	853e                	mv	a0,a5
 9f0:	fef71ae3          	bne	a4,a5,9e4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9f4:	8552                	mv	a0,s4
 9f6:	a13ff0ef          	jal	408 <sbrk>
  if(p == SBRK_ERROR)
 9fa:	fd551ee3          	bne	a0,s5,9d6 <malloc+0x7c>
        return 0;
 9fe:	4501                	li	a0,0
 a00:	74a2                	ld	s1,40(sp)
 a02:	6a42                	ld	s4,16(sp)
 a04:	6aa2                	ld	s5,8(sp)
 a06:	6b02                	ld	s6,0(sp)
 a08:	a03d                	j	a36 <malloc+0xdc>
 a0a:	74a2                	ld	s1,40(sp)
 a0c:	6a42                	ld	s4,16(sp)
 a0e:	6aa2                	ld	s5,8(sp)
 a10:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a12:	fae90fe3          	beq	s2,a4,9d0 <malloc+0x76>
        p->s.size -= nunits;
 a16:	4137073b          	subw	a4,a4,s3
 a1a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a1c:	02071693          	slli	a3,a4,0x20
 a20:	01c6d713          	srli	a4,a3,0x1c
 a24:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a26:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a2a:	00000717          	auipc	a4,0x0
 a2e:	5ca73b23          	sd	a0,1494(a4) # 1000 <freep>
      return (void*)(p + 1);
 a32:	01078513          	addi	a0,a5,16
  }
}
 a36:	70e2                	ld	ra,56(sp)
 a38:	7442                	ld	s0,48(sp)
 a3a:	7902                	ld	s2,32(sp)
 a3c:	69e2                	ld	s3,24(sp)
 a3e:	6121                	addi	sp,sp,64
 a40:	8082                	ret
 a42:	74a2                	ld	s1,40(sp)
 a44:	6a42                	ld	s4,16(sp)
 a46:	6aa2                	ld	s5,8(sp)
 a48:	6b02                	ld	s6,0(sp)
 a4a:	b7f5                	j	a36 <malloc+0xdc>
