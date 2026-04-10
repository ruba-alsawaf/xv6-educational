
user/_memcat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  }
}

int
main(void)
{
   0:	8f010113          	addi	sp,sp,-1808
   4:	70113423          	sd	ra,1800(sp)
   8:	70813023          	sd	s0,1792(sp)
   c:	6e913c23          	sd	s1,1784(sp)
  10:	6f213823          	sd	s2,1776(sp)
  14:	6f313423          	sd	s3,1768(sp)
  18:	6f413023          	sd	s4,1760(sp)
  1c:	6d513c23          	sd	s5,1752(sp)
  20:	6d613823          	sd	s6,1744(sp)
  24:	6d713423          	sd	s7,1736(sp)
  28:	6d813023          	sd	s8,1728(sp)
  2c:	6b913c23          	sd	s9,1720(sp)
  30:	6ba13823          	sd	s10,1712(sp)
  34:	6bb13423          	sd	s11,1704(sp)
  38:	71010413          	addi	s0,sp,1808
  struct mem_event ev[16];
  int n, i;

  for(;;){
    n = memread(ev, 16);
  3c:	91040d93          	addi	s11,s0,-1776
    default:         return "UNKNOWN";
  40:	00001b17          	auipc	s6,0x1
  44:	a40b0b13          	addi	s6,s6,-1472 # a80 <malloc+0x132>
  switch(t){
  48:	00001a17          	auipc	s4,0x1
  4c:	b10a0a13          	addi	s4,s4,-1264 # b58 <malloc+0x20a>
  50:	00001d17          	auipc	s10,0x1
  54:	a00d0d13          	addi	s10,s10,-1536 # a50 <malloc+0x102>
    n = memread(ev, 16);
  58:	45c1                	li	a1,16
  5a:	856e                	mv	a0,s11
  5c:	48c000ef          	jal	4e8 <memread>
  60:	8aaa                	mv	s5,a0
    if(n <= 0)
  62:	10a05963          	blez	a0,174 <main+0x174>
  66:	92c40493          	addi	s1,s0,-1748
      break;

    for(i = 0; i < n; i++){
  6a:	4901                	li	s2,0
  switch(t){
  6c:	499d                	li	s3,7
    case MEM_FREE:   return "FREE";
  6e:	00001c97          	auipc	s9,0x1
  72:	a0ac8c93          	addi	s9,s9,-1526 # a78 <malloc+0x12a>
    case MEM_ALLOC:  return "ALLOC";
  76:	00001c17          	auipc	s8,0x1
  7a:	9fac0c13          	addi	s8,s8,-1542 # a70 <malloc+0x122>
    case MEM_UNMAP:  return "UNMAP";
  7e:	00001b97          	auipc	s7,0x1
  82:	9eab8b93          	addi	s7,s7,-1558 # a68 <malloc+0x11a>
  86:	a8b5                	j	102 <main+0x102>
    case MEM_GROW:   return "GROW";
  88:	00001817          	auipc	a6,0x1
  8c:	9b880813          	addi	a6,a6,-1608 # a40 <malloc+0xf2>
  switch(s){
  90:	41a8                	lw	a0,64(a1)
  92:	0ca9ea63          	bltu	s3,a0,166 <main+0x166>
  96:	0405e503          	lwu	a0,64(a1)
  9a:	050a                	slli	a0,a0,0x2
  9c:	00001897          	auipc	a7,0x1
  a0:	a9c88893          	addi	a7,a7,-1380 # b38 <malloc+0x1ea>
  a4:	9546                	add	a0,a0,a7
  a6:	4108                	lw	a0,0(a0)
  a8:	9546                	add	a0,a0,a7
  aa:	8502                	jr	a0
    case MEM_FAULT:  return "FAULT";
  ac:	00001817          	auipc	a6,0x1
  b0:	9ac80813          	addi	a6,a6,-1620 # a58 <malloc+0x10a>
  b4:	bff1                	j	90 <main+0x90>
    case MEM_MAP:    return "MAP";
  b6:	00001817          	auipc	a6,0x1
  ba:	9aa80813          	addi	a6,a6,-1622 # a60 <malloc+0x112>
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
  d8:	9b488893          	addi	a7,a7,-1612 # a88 <malloc+0x13a>
     
    
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s name=%s old=%p new=%p\n",
  dc:	02c5b503          	ld	a0,44(a1)
  e0:	e82a                	sd	a0,16(sp)
  e2:	0245b503          	ld	a0,36(a1)
  e6:	e42a                	sd	a0,8(sp)
  e8:	e02e                	sd	a1,0(sp)
  ea:	85ca                	mv	a1,s2
  ec:	00001517          	auipc	a0,0x1
  f0:	9fc50513          	addi	a0,a0,-1540 # ae8 <malloc+0x19a>
  f4:	7a2000ef          	jal	896 <printf>
    for(i = 0; i < n; i++){
  f8:	2905                	addiw	s2,s2,1
  fa:	06848493          	addi	s1,s1,104
  fe:	f52a8de3          	beq	s5,s2,58 <main+0x58>
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s name=%s old=%p new=%p\n",
 102:	85a6                	mv	a1,s1
 104:	fe44a603          	lw	a2,-28(s1)
 108:	fec4a683          	lw	a3,-20(s1)
 10c:	ff04a703          	lw	a4,-16(s1)
 110:	ff84a783          	lw	a5,-8(s1)
  switch(t){
 114:	ff44a503          	lw	a0,-12(s1)
 118:	faa9eae3          	bltu	s3,a0,cc <main+0xcc>
 11c:	ff44e503          	lwu	a0,-12(s1)
 120:	050a                	slli	a0,a0,0x2
 122:	9552                	add	a0,a0,s4
 124:	4108                	lw	a0,0(a0)
 126:	9552                	add	a0,a0,s4
 128:	8502                	jr	a0
    case SRC_KFREE:      return "KFREE";
 12a:	00001897          	auipc	a7,0x1
 12e:	96e88893          	addi	a7,a7,-1682 # a98 <malloc+0x14a>
 132:	b76d                	j	dc <main+0xdc>
    case SRC_MAPPAGES:   return "MAPPAGES";
 134:	00001897          	auipc	a7,0x1
 138:	96c88893          	addi	a7,a7,-1684 # aa0 <malloc+0x152>
 13c:	b745                	j	dc <main+0xdc>
    case SRC_UVMUNMAP:   return "UVMUNMAP";
 13e:	00001897          	auipc	a7,0x1
 142:	97288893          	addi	a7,a7,-1678 # ab0 <malloc+0x162>
 146:	bf59                	j	dc <main+0xdc>
    case SRC_UVMALLOC:   return "UVMALLOC";
 148:	00001897          	auipc	a7,0x1
 14c:	97888893          	addi	a7,a7,-1672 # ac0 <malloc+0x172>
 150:	b771                	j	dc <main+0xdc>
    case SRC_UVMDEALLOC: return "UVMDEALLOC";
 152:	00001897          	auipc	a7,0x1
 156:	97e88893          	addi	a7,a7,-1666 # ad0 <malloc+0x182>
 15a:	b749                	j	dc <main+0xdc>
    case SRC_VMFAULT:    return "VMFAULT";
 15c:	00001897          	auipc	a7,0x1
 160:	98488893          	addi	a7,a7,-1660 # ae0 <malloc+0x192>
 164:	bfa5                	j	dc <main+0xdc>
    default:             return "UNKNOWN";
 166:	88da                	mv	a7,s6
 168:	bf95                	j	dc <main+0xdc>
  switch(s){
 16a:	00001897          	auipc	a7,0x1
 16e:	92688893          	addi	a7,a7,-1754 # a90 <malloc+0x142>
 172:	b7ad                	j	dc <main+0xdc>
    }
  }

 

  exit(0);
 174:	4501                	li	a0,0
 176:	2ba000ef          	jal	430 <exit>

000000000000017a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e406                	sd	ra,8(sp)
 17e:	e022                	sd	s0,0(sp)
 180:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 182:	e7fff0ef          	jal	0 <main>
  exit(r);
 186:	2aa000ef          	jal	430 <exit>

000000000000018a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e406                	sd	ra,8(sp)
 18e:	e022                	sd	s0,0(sp)
 190:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 192:	87aa                	mv	a5,a0
 194:	0585                	addi	a1,a1,1
 196:	0785                	addi	a5,a5,1
 198:	fff5c703          	lbu	a4,-1(a1)
 19c:	fee78fa3          	sb	a4,-1(a5)
 1a0:	fb75                	bnez	a4,194 <strcpy+0xa>
    ;
  return os;
}
 1a2:	60a2                	ld	ra,8(sp)
 1a4:	6402                	ld	s0,0(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e406                	sd	ra,8(sp)
 1ae:	e022                	sd	s0,0(sp)
 1b0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cb91                	beqz	a5,1ca <strcmp+0x20>
 1b8:	0005c703          	lbu	a4,0(a1)
 1bc:	00f71763          	bne	a4,a5,1ca <strcmp+0x20>
    p++, q++;
 1c0:	0505                	addi	a0,a0,1
 1c2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	fbe5                	bnez	a5,1b8 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1ca:	0005c503          	lbu	a0,0(a1)
}
 1ce:	40a7853b          	subw	a0,a5,a0
 1d2:	60a2                	ld	ra,8(sp)
 1d4:	6402                	ld	s0,0(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret

00000000000001da <strlen>:

uint
strlen(const char *s)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e406                	sd	ra,8(sp)
 1de:	e022                	sd	s0,0(sp)
 1e0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	cf91                	beqz	a5,202 <strlen+0x28>
 1e8:	00150793          	addi	a5,a0,1
 1ec:	86be                	mv	a3,a5
 1ee:	0785                	addi	a5,a5,1
 1f0:	fff7c703          	lbu	a4,-1(a5)
 1f4:	ff65                	bnez	a4,1ec <strlen+0x12>
 1f6:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1fa:	60a2                	ld	ra,8(sp)
 1fc:	6402                	ld	s0,0(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret
  for(n = 0; s[n]; n++)
 202:	4501                	li	a0,0
 204:	bfdd                	j	1fa <strlen+0x20>

0000000000000206 <memset>:

void*
memset(void *dst, int c, uint n)
{
 206:	1141                	addi	sp,sp,-16
 208:	e406                	sd	ra,8(sp)
 20a:	e022                	sd	s0,0(sp)
 20c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 20e:	ca19                	beqz	a2,224 <memset+0x1e>
 210:	87aa                	mv	a5,a0
 212:	1602                	slli	a2,a2,0x20
 214:	9201                	srli	a2,a2,0x20
 216:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 21a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21e:	0785                	addi	a5,a5,1
 220:	fee79de3          	bne	a5,a4,21a <memset+0x14>
  }
  return dst;
}
 224:	60a2                	ld	ra,8(sp)
 226:	6402                	ld	s0,0(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret

000000000000022c <strchr>:

char*
strchr(const char *s, char c)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e406                	sd	ra,8(sp)
 230:	e022                	sd	s0,0(sp)
 232:	0800                	addi	s0,sp,16
  for(; *s; s++)
 234:	00054783          	lbu	a5,0(a0)
 238:	cf81                	beqz	a5,250 <strchr+0x24>
    if(*s == c)
 23a:	00f58763          	beq	a1,a5,248 <strchr+0x1c>
  for(; *s; s++)
 23e:	0505                	addi	a0,a0,1
 240:	00054783          	lbu	a5,0(a0)
 244:	fbfd                	bnez	a5,23a <strchr+0xe>
      return (char*)s;
  return 0;
 246:	4501                	li	a0,0
}
 248:	60a2                	ld	ra,8(sp)
 24a:	6402                	ld	s0,0(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
  return 0;
 250:	4501                	li	a0,0
 252:	bfdd                	j	248 <strchr+0x1c>

0000000000000254 <gets>:

char*
gets(char *buf, int max)
{
 254:	711d                	addi	sp,sp,-96
 256:	ec86                	sd	ra,88(sp)
 258:	e8a2                	sd	s0,80(sp)
 25a:	e4a6                	sd	s1,72(sp)
 25c:	e0ca                	sd	s2,64(sp)
 25e:	fc4e                	sd	s3,56(sp)
 260:	f852                	sd	s4,48(sp)
 262:	f456                	sd	s5,40(sp)
 264:	f05a                	sd	s6,32(sp)
 266:	ec5e                	sd	s7,24(sp)
 268:	e862                	sd	s8,16(sp)
 26a:	1080                	addi	s0,sp,96
 26c:	8baa                	mv	s7,a0
 26e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 270:	892a                	mv	s2,a0
 272:	4481                	li	s1,0
    cc = read(0, &c, 1);
 274:	faf40b13          	addi	s6,s0,-81
 278:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 27a:	8c26                	mv	s8,s1
 27c:	0014899b          	addiw	s3,s1,1
 280:	84ce                	mv	s1,s3
 282:	0349d463          	bge	s3,s4,2aa <gets+0x56>
    cc = read(0, &c, 1);
 286:	8656                	mv	a2,s5
 288:	85da                	mv	a1,s6
 28a:	4501                	li	a0,0
 28c:	1bc000ef          	jal	448 <read>
    if(cc < 1)
 290:	00a05d63          	blez	a0,2aa <gets+0x56>
      break;
    buf[i++] = c;
 294:	faf44783          	lbu	a5,-81(s0)
 298:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 29c:	0905                	addi	s2,s2,1
 29e:	ff678713          	addi	a4,a5,-10
 2a2:	c319                	beqz	a4,2a8 <gets+0x54>
 2a4:	17cd                	addi	a5,a5,-13
 2a6:	fbf1                	bnez	a5,27a <gets+0x26>
    buf[i++] = c;
 2a8:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2aa:	9c5e                	add	s8,s8,s7
 2ac:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2b0:	855e                	mv	a0,s7
 2b2:	60e6                	ld	ra,88(sp)
 2b4:	6446                	ld	s0,80(sp)
 2b6:	64a6                	ld	s1,72(sp)
 2b8:	6906                	ld	s2,64(sp)
 2ba:	79e2                	ld	s3,56(sp)
 2bc:	7a42                	ld	s4,48(sp)
 2be:	7aa2                	ld	s5,40(sp)
 2c0:	7b02                	ld	s6,32(sp)
 2c2:	6be2                	ld	s7,24(sp)
 2c4:	6c42                	ld	s8,16(sp)
 2c6:	6125                	addi	sp,sp,96
 2c8:	8082                	ret

00000000000002ca <stat>:

int
stat(const char *n, struct stat *st)
{
 2ca:	1101                	addi	sp,sp,-32
 2cc:	ec06                	sd	ra,24(sp)
 2ce:	e822                	sd	s0,16(sp)
 2d0:	e04a                	sd	s2,0(sp)
 2d2:	1000                	addi	s0,sp,32
 2d4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d6:	4581                	li	a1,0
 2d8:	198000ef          	jal	470 <open>
  if(fd < 0)
 2dc:	02054263          	bltz	a0,300 <stat+0x36>
 2e0:	e426                	sd	s1,8(sp)
 2e2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2e4:	85ca                	mv	a1,s2
 2e6:	1a2000ef          	jal	488 <fstat>
 2ea:	892a                	mv	s2,a0
  close(fd);
 2ec:	8526                	mv	a0,s1
 2ee:	16a000ef          	jal	458 <close>
  return r;
 2f2:	64a2                	ld	s1,8(sp)
}
 2f4:	854a                	mv	a0,s2
 2f6:	60e2                	ld	ra,24(sp)
 2f8:	6442                	ld	s0,16(sp)
 2fa:	6902                	ld	s2,0(sp)
 2fc:	6105                	addi	sp,sp,32
 2fe:	8082                	ret
    return -1;
 300:	57fd                	li	a5,-1
 302:	893e                	mv	s2,a5
 304:	bfc5                	j	2f4 <stat+0x2a>

0000000000000306 <atoi>:

int
atoi(const char *s)
{
 306:	1141                	addi	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30e:	00054683          	lbu	a3,0(a0)
 312:	fd06879b          	addiw	a5,a3,-48
 316:	0ff7f793          	zext.b	a5,a5
 31a:	4625                	li	a2,9
 31c:	02f66963          	bltu	a2,a5,34e <atoi+0x48>
 320:	872a                	mv	a4,a0
  n = 0;
 322:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 324:	0705                	addi	a4,a4,1
 326:	0025179b          	slliw	a5,a0,0x2
 32a:	9fa9                	addw	a5,a5,a0
 32c:	0017979b          	slliw	a5,a5,0x1
 330:	9fb5                	addw	a5,a5,a3
 332:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 336:	00074683          	lbu	a3,0(a4)
 33a:	fd06879b          	addiw	a5,a3,-48
 33e:	0ff7f793          	zext.b	a5,a5
 342:	fef671e3          	bgeu	a2,a5,324 <atoi+0x1e>
  return n;
}
 346:	60a2                	ld	ra,8(sp)
 348:	6402                	ld	s0,0(sp)
 34a:	0141                	addi	sp,sp,16
 34c:	8082                	ret
  n = 0;
 34e:	4501                	li	a0,0
 350:	bfdd                	j	346 <atoi+0x40>

0000000000000352 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 352:	1141                	addi	sp,sp,-16
 354:	e406                	sd	ra,8(sp)
 356:	e022                	sd	s0,0(sp)
 358:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 35a:	02b57563          	bgeu	a0,a1,384 <memmove+0x32>
    while(n-- > 0)
 35e:	00c05f63          	blez	a2,37c <memmove+0x2a>
 362:	1602                	slli	a2,a2,0x20
 364:	9201                	srli	a2,a2,0x20
 366:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 36a:	872a                	mv	a4,a0
      *dst++ = *src++;
 36c:	0585                	addi	a1,a1,1
 36e:	0705                	addi	a4,a4,1
 370:	fff5c683          	lbu	a3,-1(a1)
 374:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 378:	fee79ae3          	bne	a5,a4,36c <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 37c:	60a2                	ld	ra,8(sp)
 37e:	6402                	ld	s0,0(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret
    while(n-- > 0)
 384:	fec05ce3          	blez	a2,37c <memmove+0x2a>
    dst += n;
 388:	00c50733          	add	a4,a0,a2
    src += n;
 38c:	95b2                	add	a1,a1,a2
 38e:	fff6079b          	addiw	a5,a2,-1
 392:	1782                	slli	a5,a5,0x20
 394:	9381                	srli	a5,a5,0x20
 396:	fff7c793          	not	a5,a5
 39a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 39c:	15fd                	addi	a1,a1,-1
 39e:	177d                	addi	a4,a4,-1
 3a0:	0005c683          	lbu	a3,0(a1)
 3a4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3a8:	fef71ae3          	bne	a4,a5,39c <memmove+0x4a>
 3ac:	bfc1                	j	37c <memmove+0x2a>

00000000000003ae <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e406                	sd	ra,8(sp)
 3b2:	e022                	sd	s0,0(sp)
 3b4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b6:	c61d                	beqz	a2,3e4 <memcmp+0x36>
 3b8:	1602                	slli	a2,a2,0x20
 3ba:	9201                	srli	a2,a2,0x20
 3bc:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3c0:	00054783          	lbu	a5,0(a0)
 3c4:	0005c703          	lbu	a4,0(a1)
 3c8:	00e79863          	bne	a5,a4,3d8 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3cc:	0505                	addi	a0,a0,1
    p2++;
 3ce:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3d0:	fed518e3          	bne	a0,a3,3c0 <memcmp+0x12>
  }
  return 0;
 3d4:	4501                	li	a0,0
 3d6:	a019                	j	3dc <memcmp+0x2e>
      return *p1 - *p2;
 3d8:	40e7853b          	subw	a0,a5,a4
}
 3dc:	60a2                	ld	ra,8(sp)
 3de:	6402                	ld	s0,0(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret
  return 0;
 3e4:	4501                	li	a0,0
 3e6:	bfdd                	j	3dc <memcmp+0x2e>

00000000000003e8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e406                	sd	ra,8(sp)
 3ec:	e022                	sd	s0,0(sp)
 3ee:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3f0:	f63ff0ef          	jal	352 <memmove>
}
 3f4:	60a2                	ld	ra,8(sp)
 3f6:	6402                	ld	s0,0(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret

00000000000003fc <sbrk>:

char *
sbrk(int n) {
 3fc:	1141                	addi	sp,sp,-16
 3fe:	e406                	sd	ra,8(sp)
 400:	e022                	sd	s0,0(sp)
 402:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 404:	4585                	li	a1,1
 406:	0b2000ef          	jal	4b8 <sys_sbrk>
}
 40a:	60a2                	ld	ra,8(sp)
 40c:	6402                	ld	s0,0(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret

0000000000000412 <sbrklazy>:

char *
sbrklazy(int n) {
 412:	1141                	addi	sp,sp,-16
 414:	e406                	sd	ra,8(sp)
 416:	e022                	sd	s0,0(sp)
 418:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 41a:	4589                	li	a1,2
 41c:	09c000ef          	jal	4b8 <sys_sbrk>
}
 420:	60a2                	ld	ra,8(sp)
 422:	6402                	ld	s0,0(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret

0000000000000428 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 428:	4885                	li	a7,1
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <exit>:
.global exit
exit:
 li a7, SYS_exit
 430:	4889                	li	a7,2
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <wait>:
.global wait
wait:
 li a7, SYS_wait
 438:	488d                	li	a7,3
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 440:	4891                	li	a7,4
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <read>:
.global read
read:
 li a7, SYS_read
 448:	4895                	li	a7,5
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <write>:
.global write
write:
 li a7, SYS_write
 450:	48c1                	li	a7,16
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <close>:
.global close
close:
 li a7, SYS_close
 458:	48d5                	li	a7,21
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <kill>:
.global kill
kill:
 li a7, SYS_kill
 460:	4899                	li	a7,6
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <exec>:
.global exec
exec:
 li a7, SYS_exec
 468:	489d                	li	a7,7
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <open>:
.global open
open:
 li a7, SYS_open
 470:	48bd                	li	a7,15
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 478:	48c5                	li	a7,17
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 480:	48c9                	li	a7,18
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 488:	48a1                	li	a7,8
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <link>:
.global link
link:
 li a7, SYS_link
 490:	48cd                	li	a7,19
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 498:	48d1                	li	a7,20
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a0:	48a5                	li	a7,9
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4a8:	48a9                	li	a7,10
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b0:	48ad                	li	a7,11
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4b8:	48b1                	li	a7,12
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4c0:	48b5                	li	a7,13
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4c8:	48b9                	li	a7,14
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <csread>:
.global csread
csread:
 li a7, SYS_csread
 4d0:	48d9                	li	a7,22
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 4d8:	48dd                	li	a7,23
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 4e0:	48e1                	li	a7,24
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <memread>:
.global memread
memread:
 li a7, SYS_memread
 4e8:	48e5                	li	a7,25
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4f0:	1101                	addi	sp,sp,-32
 4f2:	ec06                	sd	ra,24(sp)
 4f4:	e822                	sd	s0,16(sp)
 4f6:	1000                	addi	s0,sp,32
 4f8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4fc:	4605                	li	a2,1
 4fe:	fef40593          	addi	a1,s0,-17
 502:	f4fff0ef          	jal	450 <write>
}
 506:	60e2                	ld	ra,24(sp)
 508:	6442                	ld	s0,16(sp)
 50a:	6105                	addi	sp,sp,32
 50c:	8082                	ret

000000000000050e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 50e:	715d                	addi	sp,sp,-80
 510:	e486                	sd	ra,72(sp)
 512:	e0a2                	sd	s0,64(sp)
 514:	f84a                	sd	s2,48(sp)
 516:	f44e                	sd	s3,40(sp)
 518:	0880                	addi	s0,sp,80
 51a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 51c:	c6d1                	beqz	a3,5a8 <printint+0x9a>
 51e:	0805d563          	bgez	a1,5a8 <printint+0x9a>
    neg = 1;
    x = -xx;
 522:	40b005b3          	neg	a1,a1
    neg = 1;
 526:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 528:	fb840993          	addi	s3,s0,-72
  neg = 0;
 52c:	86ce                	mv	a3,s3
  i = 0;
 52e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 530:	00000817          	auipc	a6,0x0
 534:	64880813          	addi	a6,a6,1608 # b78 <digits>
 538:	88ba                	mv	a7,a4
 53a:	0017051b          	addiw	a0,a4,1
 53e:	872a                	mv	a4,a0
 540:	02c5f7b3          	remu	a5,a1,a2
 544:	97c2                	add	a5,a5,a6
 546:	0007c783          	lbu	a5,0(a5)
 54a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 54e:	87ae                	mv	a5,a1
 550:	02c5d5b3          	divu	a1,a1,a2
 554:	0685                	addi	a3,a3,1
 556:	fec7f1e3          	bgeu	a5,a2,538 <printint+0x2a>
  if(neg)
 55a:	00030c63          	beqz	t1,572 <printint+0x64>
    buf[i++] = '-';
 55e:	fd050793          	addi	a5,a0,-48
 562:	00878533          	add	a0,a5,s0
 566:	02d00793          	li	a5,45
 56a:	fef50423          	sb	a5,-24(a0)
 56e:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 572:	02e05563          	blez	a4,59c <printint+0x8e>
 576:	fc26                	sd	s1,56(sp)
 578:	377d                	addiw	a4,a4,-1
 57a:	00e984b3          	add	s1,s3,a4
 57e:	19fd                	addi	s3,s3,-1
 580:	99ba                	add	s3,s3,a4
 582:	1702                	slli	a4,a4,0x20
 584:	9301                	srli	a4,a4,0x20
 586:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 58a:	0004c583          	lbu	a1,0(s1)
 58e:	854a                	mv	a0,s2
 590:	f61ff0ef          	jal	4f0 <putc>
  while(--i >= 0)
 594:	14fd                	addi	s1,s1,-1
 596:	ff349ae3          	bne	s1,s3,58a <printint+0x7c>
 59a:	74e2                	ld	s1,56(sp)
}
 59c:	60a6                	ld	ra,72(sp)
 59e:	6406                	ld	s0,64(sp)
 5a0:	7942                	ld	s2,48(sp)
 5a2:	79a2                	ld	s3,40(sp)
 5a4:	6161                	addi	sp,sp,80
 5a6:	8082                	ret
  neg = 0;
 5a8:	4301                	li	t1,0
 5aa:	bfbd                	j	528 <printint+0x1a>

00000000000005ac <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ac:	711d                	addi	sp,sp,-96
 5ae:	ec86                	sd	ra,88(sp)
 5b0:	e8a2                	sd	s0,80(sp)
 5b2:	e4a6                	sd	s1,72(sp)
 5b4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b6:	0005c483          	lbu	s1,0(a1)
 5ba:	22048363          	beqz	s1,7e0 <vprintf+0x234>
 5be:	e0ca                	sd	s2,64(sp)
 5c0:	fc4e                	sd	s3,56(sp)
 5c2:	f852                	sd	s4,48(sp)
 5c4:	f456                	sd	s5,40(sp)
 5c6:	f05a                	sd	s6,32(sp)
 5c8:	ec5e                	sd	s7,24(sp)
 5ca:	e862                	sd	s8,16(sp)
 5cc:	8b2a                	mv	s6,a0
 5ce:	8a2e                	mv	s4,a1
 5d0:	8bb2                	mv	s7,a2
  state = 0;
 5d2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5d4:	4901                	li	s2,0
 5d6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5d8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5dc:	06400c13          	li	s8,100
 5e0:	a00d                	j	602 <vprintf+0x56>
        putc(fd, c0);
 5e2:	85a6                	mv	a1,s1
 5e4:	855a                	mv	a0,s6
 5e6:	f0bff0ef          	jal	4f0 <putc>
 5ea:	a019                	j	5f0 <vprintf+0x44>
    } else if(state == '%'){
 5ec:	03598363          	beq	s3,s5,612 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5f0:	0019079b          	addiw	a5,s2,1
 5f4:	893e                	mv	s2,a5
 5f6:	873e                	mv	a4,a5
 5f8:	97d2                	add	a5,a5,s4
 5fa:	0007c483          	lbu	s1,0(a5)
 5fe:	1c048a63          	beqz	s1,7d2 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 602:	0004879b          	sext.w	a5,s1
    if(state == 0){
 606:	fe0993e3          	bnez	s3,5ec <vprintf+0x40>
      if(c0 == '%'){
 60a:	fd579ce3          	bne	a5,s5,5e2 <vprintf+0x36>
        state = '%';
 60e:	89be                	mv	s3,a5
 610:	b7c5                	j	5f0 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 612:	00ea06b3          	add	a3,s4,a4
 616:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 61a:	1c060863          	beqz	a2,7ea <vprintf+0x23e>
      if(c0 == 'd'){
 61e:	03878763          	beq	a5,s8,64c <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 622:	f9478693          	addi	a3,a5,-108
 626:	0016b693          	seqz	a3,a3
 62a:	f9c60593          	addi	a1,a2,-100
 62e:	e99d                	bnez	a1,664 <vprintf+0xb8>
 630:	ca95                	beqz	a3,664 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 632:	008b8493          	addi	s1,s7,8
 636:	4685                	li	a3,1
 638:	4629                	li	a2,10
 63a:	000bb583          	ld	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	ecfff0ef          	jal	50e <printint>
        i += 1;
 644:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 646:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 648:	4981                	li	s3,0
 64a:	b75d                	j	5f0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 64c:	008b8493          	addi	s1,s7,8
 650:	4685                	li	a3,1
 652:	4629                	li	a2,10
 654:	000ba583          	lw	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	eb5ff0ef          	jal	50e <printint>
 65e:	8ba6                	mv	s7,s1
      state = 0;
 660:	4981                	li	s3,0
 662:	b779                	j	5f0 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 664:	9752                	add	a4,a4,s4
 666:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 66a:	f9460713          	addi	a4,a2,-108
 66e:	00173713          	seqz	a4,a4
 672:	8f75                	and	a4,a4,a3
 674:	f9c58513          	addi	a0,a1,-100
 678:	18051363          	bnez	a0,7fe <vprintf+0x252>
 67c:	18070163          	beqz	a4,7fe <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 680:	008b8493          	addi	s1,s7,8
 684:	4685                	li	a3,1
 686:	4629                	li	a2,10
 688:	000bb583          	ld	a1,0(s7)
 68c:	855a                	mv	a0,s6
 68e:	e81ff0ef          	jal	50e <printint>
        i += 2;
 692:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 694:	8ba6                	mv	s7,s1
      state = 0;
 696:	4981                	li	s3,0
        i += 2;
 698:	bfa1                	j	5f0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 69a:	008b8493          	addi	s1,s7,8
 69e:	4681                	li	a3,0
 6a0:	4629                	li	a2,10
 6a2:	000be583          	lwu	a1,0(s7)
 6a6:	855a                	mv	a0,s6
 6a8:	e67ff0ef          	jal	50e <printint>
 6ac:	8ba6                	mv	s7,s1
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	b781                	j	5f0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b2:	008b8493          	addi	s1,s7,8
 6b6:	4681                	li	a3,0
 6b8:	4629                	li	a2,10
 6ba:	000bb583          	ld	a1,0(s7)
 6be:	855a                	mv	a0,s6
 6c0:	e4fff0ef          	jal	50e <printint>
        i += 1;
 6c4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c6:	8ba6                	mv	s7,s1
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	b71d                	j	5f0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6cc:	008b8493          	addi	s1,s7,8
 6d0:	4681                	li	a3,0
 6d2:	4629                	li	a2,10
 6d4:	000bb583          	ld	a1,0(s7)
 6d8:	855a                	mv	a0,s6
 6da:	e35ff0ef          	jal	50e <printint>
        i += 2;
 6de:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e0:	8ba6                	mv	s7,s1
      state = 0;
 6e2:	4981                	li	s3,0
        i += 2;
 6e4:	b731                	j	5f0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6e6:	008b8493          	addi	s1,s7,8
 6ea:	4681                	li	a3,0
 6ec:	4641                	li	a2,16
 6ee:	000be583          	lwu	a1,0(s7)
 6f2:	855a                	mv	a0,s6
 6f4:	e1bff0ef          	jal	50e <printint>
 6f8:	8ba6                	mv	s7,s1
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	bdd5                	j	5f0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fe:	008b8493          	addi	s1,s7,8
 702:	4681                	li	a3,0
 704:	4641                	li	a2,16
 706:	000bb583          	ld	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	e03ff0ef          	jal	50e <printint>
        i += 1;
 710:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 712:	8ba6                	mv	s7,s1
      state = 0;
 714:	4981                	li	s3,0
 716:	bde9                	j	5f0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 718:	008b8493          	addi	s1,s7,8
 71c:	4681                	li	a3,0
 71e:	4641                	li	a2,16
 720:	000bb583          	ld	a1,0(s7)
 724:	855a                	mv	a0,s6
 726:	de9ff0ef          	jal	50e <printint>
        i += 2;
 72a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 72c:	8ba6                	mv	s7,s1
      state = 0;
 72e:	4981                	li	s3,0
        i += 2;
 730:	b5c1                	j	5f0 <vprintf+0x44>
 732:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 734:	008b8793          	addi	a5,s7,8
 738:	8cbe                	mv	s9,a5
 73a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 73e:	03000593          	li	a1,48
 742:	855a                	mv	a0,s6
 744:	dadff0ef          	jal	4f0 <putc>
  putc(fd, 'x');
 748:	07800593          	li	a1,120
 74c:	855a                	mv	a0,s6
 74e:	da3ff0ef          	jal	4f0 <putc>
 752:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 754:	00000b97          	auipc	s7,0x0
 758:	424b8b93          	addi	s7,s7,1060 # b78 <digits>
 75c:	03c9d793          	srli	a5,s3,0x3c
 760:	97de                	add	a5,a5,s7
 762:	0007c583          	lbu	a1,0(a5)
 766:	855a                	mv	a0,s6
 768:	d89ff0ef          	jal	4f0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 76c:	0992                	slli	s3,s3,0x4
 76e:	34fd                	addiw	s1,s1,-1
 770:	f4f5                	bnez	s1,75c <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 772:	8be6                	mv	s7,s9
      state = 0;
 774:	4981                	li	s3,0
 776:	6ca2                	ld	s9,8(sp)
 778:	bda5                	j	5f0 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 77a:	008b8493          	addi	s1,s7,8
 77e:	000bc583          	lbu	a1,0(s7)
 782:	855a                	mv	a0,s6
 784:	d6dff0ef          	jal	4f0 <putc>
 788:	8ba6                	mv	s7,s1
      state = 0;
 78a:	4981                	li	s3,0
 78c:	b595                	j	5f0 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 78e:	008b8993          	addi	s3,s7,8
 792:	000bb483          	ld	s1,0(s7)
 796:	cc91                	beqz	s1,7b2 <vprintf+0x206>
        for(; *s; s++)
 798:	0004c583          	lbu	a1,0(s1)
 79c:	c985                	beqz	a1,7cc <vprintf+0x220>
          putc(fd, *s);
 79e:	855a                	mv	a0,s6
 7a0:	d51ff0ef          	jal	4f0 <putc>
        for(; *s; s++)
 7a4:	0485                	addi	s1,s1,1
 7a6:	0004c583          	lbu	a1,0(s1)
 7aa:	f9f5                	bnez	a1,79e <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7ac:	8bce                	mv	s7,s3
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b581                	j	5f0 <vprintf+0x44>
          s = "(null)";
 7b2:	00000497          	auipc	s1,0x0
 7b6:	37e48493          	addi	s1,s1,894 # b30 <malloc+0x1e2>
        for(; *s; s++)
 7ba:	02800593          	li	a1,40
 7be:	b7c5                	j	79e <vprintf+0x1f2>
        putc(fd, '%');
 7c0:	85be                	mv	a1,a5
 7c2:	855a                	mv	a0,s6
 7c4:	d2dff0ef          	jal	4f0 <putc>
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	b51d                	j	5f0 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7cc:	8bce                	mv	s7,s3
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	b505                	j	5f0 <vprintf+0x44>
 7d2:	6906                	ld	s2,64(sp)
 7d4:	79e2                	ld	s3,56(sp)
 7d6:	7a42                	ld	s4,48(sp)
 7d8:	7aa2                	ld	s5,40(sp)
 7da:	7b02                	ld	s6,32(sp)
 7dc:	6be2                	ld	s7,24(sp)
 7de:	6c42                	ld	s8,16(sp)
    }
  }
}
 7e0:	60e6                	ld	ra,88(sp)
 7e2:	6446                	ld	s0,80(sp)
 7e4:	64a6                	ld	s1,72(sp)
 7e6:	6125                	addi	sp,sp,96
 7e8:	8082                	ret
      if(c0 == 'd'){
 7ea:	06400713          	li	a4,100
 7ee:	e4e78fe3          	beq	a5,a4,64c <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7f2:	f9478693          	addi	a3,a5,-108
 7f6:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7fa:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7fc:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7fe:	07500513          	li	a0,117
 802:	e8a78ce3          	beq	a5,a0,69a <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 806:	f8b60513          	addi	a0,a2,-117
 80a:	e119                	bnez	a0,810 <vprintf+0x264>
 80c:	ea0693e3          	bnez	a3,6b2 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 810:	f8b58513          	addi	a0,a1,-117
 814:	e119                	bnez	a0,81a <vprintf+0x26e>
 816:	ea071be3          	bnez	a4,6cc <vprintf+0x120>
      } else if(c0 == 'x'){
 81a:	07800513          	li	a0,120
 81e:	eca784e3          	beq	a5,a0,6e6 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 822:	f8860613          	addi	a2,a2,-120
 826:	e219                	bnez	a2,82c <vprintf+0x280>
 828:	ec069be3          	bnez	a3,6fe <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 82c:	f8858593          	addi	a1,a1,-120
 830:	e199                	bnez	a1,836 <vprintf+0x28a>
 832:	ee0713e3          	bnez	a4,718 <vprintf+0x16c>
      } else if(c0 == 'p'){
 836:	07000713          	li	a4,112
 83a:	eee78ce3          	beq	a5,a4,732 <vprintf+0x186>
      } else if(c0 == 'c'){
 83e:	06300713          	li	a4,99
 842:	f2e78ce3          	beq	a5,a4,77a <vprintf+0x1ce>
      } else if(c0 == 's'){
 846:	07300713          	li	a4,115
 84a:	f4e782e3          	beq	a5,a4,78e <vprintf+0x1e2>
      } else if(c0 == '%'){
 84e:	02500713          	li	a4,37
 852:	f6e787e3          	beq	a5,a4,7c0 <vprintf+0x214>
        putc(fd, '%');
 856:	02500593          	li	a1,37
 85a:	855a                	mv	a0,s6
 85c:	c95ff0ef          	jal	4f0 <putc>
        putc(fd, c0);
 860:	85a6                	mv	a1,s1
 862:	855a                	mv	a0,s6
 864:	c8dff0ef          	jal	4f0 <putc>
      state = 0;
 868:	4981                	li	s3,0
 86a:	b359                	j	5f0 <vprintf+0x44>

000000000000086c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 86c:	715d                	addi	sp,sp,-80
 86e:	ec06                	sd	ra,24(sp)
 870:	e822                	sd	s0,16(sp)
 872:	1000                	addi	s0,sp,32
 874:	e010                	sd	a2,0(s0)
 876:	e414                	sd	a3,8(s0)
 878:	e818                	sd	a4,16(s0)
 87a:	ec1c                	sd	a5,24(s0)
 87c:	03043023          	sd	a6,32(s0)
 880:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 884:	8622                	mv	a2,s0
 886:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 88a:	d23ff0ef          	jal	5ac <vprintf>
}
 88e:	60e2                	ld	ra,24(sp)
 890:	6442                	ld	s0,16(sp)
 892:	6161                	addi	sp,sp,80
 894:	8082                	ret

0000000000000896 <printf>:

void
printf(const char *fmt, ...)
{
 896:	711d                	addi	sp,sp,-96
 898:	ec06                	sd	ra,24(sp)
 89a:	e822                	sd	s0,16(sp)
 89c:	1000                	addi	s0,sp,32
 89e:	e40c                	sd	a1,8(s0)
 8a0:	e810                	sd	a2,16(s0)
 8a2:	ec14                	sd	a3,24(s0)
 8a4:	f018                	sd	a4,32(s0)
 8a6:	f41c                	sd	a5,40(s0)
 8a8:	03043823          	sd	a6,48(s0)
 8ac:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8b0:	00840613          	addi	a2,s0,8
 8b4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8b8:	85aa                	mv	a1,a0
 8ba:	4505                	li	a0,1
 8bc:	cf1ff0ef          	jal	5ac <vprintf>
}
 8c0:	60e2                	ld	ra,24(sp)
 8c2:	6442                	ld	s0,16(sp)
 8c4:	6125                	addi	sp,sp,96
 8c6:	8082                	ret

00000000000008c8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c8:	1141                	addi	sp,sp,-16
 8ca:	e406                	sd	ra,8(sp)
 8cc:	e022                	sd	s0,0(sp)
 8ce:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8d0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d4:	00001797          	auipc	a5,0x1
 8d8:	72c7b783          	ld	a5,1836(a5) # 2000 <freep>
 8dc:	a039                	j	8ea <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8de:	6398                	ld	a4,0(a5)
 8e0:	00e7e463          	bltu	a5,a4,8e8 <free+0x20>
 8e4:	00e6ea63          	bltu	a3,a4,8f8 <free+0x30>
{
 8e8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ea:	fed7fae3          	bgeu	a5,a3,8de <free+0x16>
 8ee:	6398                	ld	a4,0(a5)
 8f0:	00e6e463          	bltu	a3,a4,8f8 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f4:	fee7eae3          	bltu	a5,a4,8e8 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8f8:	ff852583          	lw	a1,-8(a0)
 8fc:	6390                	ld	a2,0(a5)
 8fe:	02059813          	slli	a6,a1,0x20
 902:	01c85713          	srli	a4,a6,0x1c
 906:	9736                	add	a4,a4,a3
 908:	02e60563          	beq	a2,a4,932 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 90c:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 910:	4790                	lw	a2,8(a5)
 912:	02061593          	slli	a1,a2,0x20
 916:	01c5d713          	srli	a4,a1,0x1c
 91a:	973e                	add	a4,a4,a5
 91c:	02e68263          	beq	a3,a4,940 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 920:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 922:	00001717          	auipc	a4,0x1
 926:	6cf73f23          	sd	a5,1758(a4) # 2000 <freep>
}
 92a:	60a2                	ld	ra,8(sp)
 92c:	6402                	ld	s0,0(sp)
 92e:	0141                	addi	sp,sp,16
 930:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 932:	4618                	lw	a4,8(a2)
 934:	9f2d                	addw	a4,a4,a1
 936:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 93a:	6398                	ld	a4,0(a5)
 93c:	6310                	ld	a2,0(a4)
 93e:	b7f9                	j	90c <free+0x44>
    p->s.size += bp->s.size;
 940:	ff852703          	lw	a4,-8(a0)
 944:	9f31                	addw	a4,a4,a2
 946:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 948:	ff053683          	ld	a3,-16(a0)
 94c:	bfd1                	j	920 <free+0x58>

000000000000094e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 94e:	7139                	addi	sp,sp,-64
 950:	fc06                	sd	ra,56(sp)
 952:	f822                	sd	s0,48(sp)
 954:	f04a                	sd	s2,32(sp)
 956:	ec4e                	sd	s3,24(sp)
 958:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95a:	02051993          	slli	s3,a0,0x20
 95e:	0209d993          	srli	s3,s3,0x20
 962:	09bd                	addi	s3,s3,15
 964:	0049d993          	srli	s3,s3,0x4
 968:	2985                	addiw	s3,s3,1
 96a:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 96c:	00001517          	auipc	a0,0x1
 970:	69453503          	ld	a0,1684(a0) # 2000 <freep>
 974:	c905                	beqz	a0,9a4 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 976:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 978:	4798                	lw	a4,8(a5)
 97a:	09377663          	bgeu	a4,s3,a06 <malloc+0xb8>
 97e:	f426                	sd	s1,40(sp)
 980:	e852                	sd	s4,16(sp)
 982:	e456                	sd	s5,8(sp)
 984:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 986:	8a4e                	mv	s4,s3
 988:	6705                	lui	a4,0x1
 98a:	00e9f363          	bgeu	s3,a4,990 <malloc+0x42>
 98e:	6a05                	lui	s4,0x1
 990:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 994:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 998:	00001497          	auipc	s1,0x1
 99c:	66848493          	addi	s1,s1,1640 # 2000 <freep>
  if(p == SBRK_ERROR)
 9a0:	5afd                	li	s5,-1
 9a2:	a83d                	j	9e0 <malloc+0x92>
 9a4:	f426                	sd	s1,40(sp)
 9a6:	e852                	sd	s4,16(sp)
 9a8:	e456                	sd	s5,8(sp)
 9aa:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9ac:	00001797          	auipc	a5,0x1
 9b0:	66478793          	addi	a5,a5,1636 # 2010 <base>
 9b4:	00001717          	auipc	a4,0x1
 9b8:	64f73623          	sd	a5,1612(a4) # 2000 <freep>
 9bc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9be:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9c2:	b7d1                	j	986 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9c4:	6398                	ld	a4,0(a5)
 9c6:	e118                	sd	a4,0(a0)
 9c8:	a899                	j	a1e <malloc+0xd0>
  hp->s.size = nu;
 9ca:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9ce:	0541                	addi	a0,a0,16
 9d0:	ef9ff0ef          	jal	8c8 <free>
  return freep;
 9d4:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9d6:	c125                	beqz	a0,a36 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9da:	4798                	lw	a4,8(a5)
 9dc:	03277163          	bgeu	a4,s2,9fe <malloc+0xb0>
    if(p == freep)
 9e0:	6098                	ld	a4,0(s1)
 9e2:	853e                	mv	a0,a5
 9e4:	fef71ae3          	bne	a4,a5,9d8 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9e8:	8552                	mv	a0,s4
 9ea:	a13ff0ef          	jal	3fc <sbrk>
  if(p == SBRK_ERROR)
 9ee:	fd551ee3          	bne	a0,s5,9ca <malloc+0x7c>
        return 0;
 9f2:	4501                	li	a0,0
 9f4:	74a2                	ld	s1,40(sp)
 9f6:	6a42                	ld	s4,16(sp)
 9f8:	6aa2                	ld	s5,8(sp)
 9fa:	6b02                	ld	s6,0(sp)
 9fc:	a03d                	j	a2a <malloc+0xdc>
 9fe:	74a2                	ld	s1,40(sp)
 a00:	6a42                	ld	s4,16(sp)
 a02:	6aa2                	ld	s5,8(sp)
 a04:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a06:	fae90fe3          	beq	s2,a4,9c4 <malloc+0x76>
        p->s.size -= nunits;
 a0a:	4137073b          	subw	a4,a4,s3
 a0e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a10:	02071693          	slli	a3,a4,0x20
 a14:	01c6d713          	srli	a4,a3,0x1c
 a18:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a1a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a1e:	00001717          	auipc	a4,0x1
 a22:	5ea73123          	sd	a0,1506(a4) # 2000 <freep>
      return (void*)(p + 1);
 a26:	01078513          	addi	a0,a5,16
  }
}
 a2a:	70e2                	ld	ra,56(sp)
 a2c:	7442                	ld	s0,48(sp)
 a2e:	7902                	ld	s2,32(sp)
 a30:	69e2                	ld	s3,24(sp)
 a32:	6121                	addi	sp,sp,64
 a34:	8082                	ret
 a36:	74a2                	ld	s1,40(sp)
 a38:	6a42                	ld	s4,16(sp)
 a3a:	6aa2                	ld	s5,8(sp)
 a3c:	6b02                	ld	s6,0(sp)
 a3e:	b7f5                	j	a2a <malloc+0xdc>
