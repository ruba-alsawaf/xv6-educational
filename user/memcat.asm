
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
    default:         return "UNKNOWN";
  3c:	00001b17          	auipc	s6,0x1
  40:	a14b0b13          	addi	s6,s6,-1516 # a50 <malloc+0x146>
  switch(t){
  44:	00001a17          	auipc	s4,0x1
  48:	ae4a0a13          	addi	s4,s4,-1308 # b28 <malloc+0x21e>
  4c:	00001d17          	auipc	s10,0x1
  50:	9d4d0d13          	addi	s10,s10,-1580 # a20 <malloc+0x116>
    case MEM_FREE:   return "FREE";
  54:	00001d97          	auipc	s11,0x1
  58:	9f4d8d93          	addi	s11,s11,-1548 # a48 <malloc+0x13e>
  struct mem_event ev[16];
  int n, i;

  for(;;){
    n = memread(ev, 16);
  5c:	45c1                	li	a1,16
  5e:	91040513          	addi	a0,s0,-1776
  62:	464000ef          	jal	4c6 <memread>
  66:	8aaa                	mv	s5,a0
    if(n <= 0)
  68:	10a05663          	blez	a0,174 <main+0x174>
  6c:	92c40493          	addi	s1,s0,-1748
      break;

    for(i = 0; i < n; i++){
  70:	4901                	li	s2,0
  switch(t){
  72:	499d                	li	s3,7
    case MEM_ALLOC:  return "ALLOC";
  74:	00001c97          	auipc	s9,0x1
  78:	9ccc8c93          	addi	s9,s9,-1588 # a40 <malloc+0x136>
    case MEM_UNMAP:  return "UNMAP";
  7c:	00001c17          	auipc	s8,0x1
  80:	9bcc0c13          	addi	s8,s8,-1604 # a38 <malloc+0x12e>
    case MEM_MAP:    return "MAP";
  84:	00001b97          	auipc	s7,0x1
  88:	9acb8b93          	addi	s7,s7,-1620 # a30 <malloc+0x126>
  8c:	a89d                	j	102 <main+0x102>
    case MEM_GROW:   return "GROW";
  8e:	00001817          	auipc	a6,0x1
  92:	98280813          	addi	a6,a6,-1662 # a10 <malloc+0x106>
  switch(s){
  96:	41a8                	lw	a0,64(a1)
  98:	0ca9e763          	bltu	s3,a0,166 <main+0x166>
  9c:	0405e503          	lwu	a0,64(a1)
  a0:	050a                	slli	a0,a0,0x2
  a2:	00001897          	auipc	a7,0x1
  a6:	a6688893          	addi	a7,a7,-1434 # b08 <malloc+0x1fe>
  aa:	9546                	add	a0,a0,a7
  ac:	4108                	lw	a0,0(a0)
  ae:	9546                	add	a0,a0,a7
  b0:	8502                	jr	a0
    case MEM_FAULT:  return "FAULT";
  b2:	00001817          	auipc	a6,0x1
  b6:	97680813          	addi	a6,a6,-1674 # a28 <malloc+0x11e>
  ba:	bff1                	j	96 <main+0x96>
    case MEM_MAP:    return "MAP";
  bc:	885e                	mv	a6,s7
  be:	bfe1                	j	96 <main+0x96>
    case MEM_UNMAP:  return "UNMAP";
  c0:	8862                	mv	a6,s8
  c2:	bfd1                	j	96 <main+0x96>
    case MEM_ALLOC:  return "ALLOC";
  c4:	8866                	mv	a6,s9
  c6:	bfc1                	j	96 <main+0x96>
    case MEM_FREE:   return "FREE";
  c8:	886e                	mv	a6,s11
  ca:	b7f1                	j	96 <main+0x96>
    default:         return "UNKNOWN";
  cc:	885a                	mv	a6,s6
  ce:	b7e1                	j	96 <main+0x96>
  switch(t){
  d0:	886a                	mv	a6,s10
  d2:	b7d1                	j	96 <main+0x96>
    case SRC_NONE:       return "NONE";
  d4:	00001897          	auipc	a7,0x1
  d8:	98488893          	addi	a7,a7,-1660 # a58 <malloc+0x14e>
     
    
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s name=%s old=%p new=%p\n",
  dc:	02c5b503          	ld	a0,44(a1)
  e0:	e82a                	sd	a0,16(sp)
  e2:	0245b503          	ld	a0,36(a1)
  e6:	e42a                	sd	a0,8(sp)
  e8:	e02e                	sd	a1,0(sp)
  ea:	85ca                	mv	a1,s2
  ec:	00001517          	auipc	a0,0x1
  f0:	9cc50513          	addi	a0,a0,-1588 # ab8 <malloc+0x1ae>
  f4:	762000ef          	jal	856 <printf>
    for(i = 0; i < n; i++){
  f8:	2905                	addiw	s2,s2,1
  fa:	06848493          	addi	s1,s1,104
  fe:	f52a8fe3          	beq	s5,s2,5c <main+0x5c>
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
 12e:	93e88893          	addi	a7,a7,-1730 # a68 <malloc+0x15e>
 132:	b76d                	j	dc <main+0xdc>
    case SRC_MAPPAGES:   return "MAPPAGES";
 134:	00001897          	auipc	a7,0x1
 138:	93c88893          	addi	a7,a7,-1732 # a70 <malloc+0x166>
 13c:	b745                	j	dc <main+0xdc>
    case SRC_UVMUNMAP:   return "UVMUNMAP";
 13e:	00001897          	auipc	a7,0x1
 142:	94288893          	addi	a7,a7,-1726 # a80 <malloc+0x176>
 146:	bf59                	j	dc <main+0xdc>
    case SRC_UVMALLOC:   return "UVMALLOC";
 148:	00001897          	auipc	a7,0x1
 14c:	94888893          	addi	a7,a7,-1720 # a90 <malloc+0x186>
 150:	b771                	j	dc <main+0xdc>
    case SRC_UVMDEALLOC: return "UVMDEALLOC";
 152:	00001897          	auipc	a7,0x1
 156:	94e88893          	addi	a7,a7,-1714 # aa0 <malloc+0x196>
 15a:	b749                	j	dc <main+0xdc>
    case SRC_VMFAULT:    return "VMFAULT";
 15c:	00001897          	auipc	a7,0x1
 160:	95488893          	addi	a7,a7,-1708 # ab0 <malloc+0x1a6>
 164:	bfa5                	j	dc <main+0xdc>
    default:             return "UNKNOWN";
 166:	88da                	mv	a7,s6
 168:	bf95                	j	dc <main+0xdc>
  switch(s){
 16a:	00001897          	auipc	a7,0x1
 16e:	8f688893          	addi	a7,a7,-1802 # a60 <malloc+0x156>
 172:	b7ad                	j	dc <main+0xdc>
    }
  }

 

  exit(0);
 174:	4501                	li	a0,0
 176:	298000ef          	jal	40e <exit>

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
 186:	288000ef          	jal	40e <exit>

000000000000018a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 190:	87aa                	mv	a5,a0
 192:	0585                	addi	a1,a1,1
 194:	0785                	addi	a5,a5,1
 196:	fff5c703          	lbu	a4,-1(a1)
 19a:	fee78fa3          	sb	a4,-1(a5)
 19e:	fb75                	bnez	a4,192 <strcpy+0x8>
    ;
  return os;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cb91                	beqz	a5,1c4 <strcmp+0x1e>
 1b2:	0005c703          	lbu	a4,0(a1)
 1b6:	00f71763          	bne	a4,a5,1c4 <strcmp+0x1e>
    p++, q++;
 1ba:	0505                	addi	a0,a0,1
 1bc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	fbe5                	bnez	a5,1b2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1c4:	0005c503          	lbu	a0,0(a1)
}
 1c8:	40a7853b          	subw	a0,a5,a0
 1cc:	6422                	ld	s0,8(sp)
 1ce:	0141                	addi	sp,sp,16
 1d0:	8082                	ret

00000000000001d2 <strlen>:

uint
strlen(const char *s)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e422                	sd	s0,8(sp)
 1d6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	cf91                	beqz	a5,1f8 <strlen+0x26>
 1de:	0505                	addi	a0,a0,1
 1e0:	87aa                	mv	a5,a0
 1e2:	86be                	mv	a3,a5
 1e4:	0785                	addi	a5,a5,1
 1e6:	fff7c703          	lbu	a4,-1(a5)
 1ea:	ff65                	bnez	a4,1e2 <strlen+0x10>
 1ec:	40a6853b          	subw	a0,a3,a0
 1f0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret
  for(n = 0; s[n]; n++)
 1f8:	4501                	li	a0,0
 1fa:	bfe5                	j	1f2 <strlen+0x20>

00000000000001fc <memset>:

void*
memset(void *dst, int c, uint n)
{
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e422                	sd	s0,8(sp)
 200:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 202:	ca19                	beqz	a2,218 <memset+0x1c>
 204:	87aa                	mv	a5,a0
 206:	1602                	slli	a2,a2,0x20
 208:	9201                	srli	a2,a2,0x20
 20a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 20e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 212:	0785                	addi	a5,a5,1
 214:	fee79de3          	bne	a5,a4,20e <memset+0x12>
  }
  return dst;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret

000000000000021e <strchr>:

char*
strchr(const char *s, char c)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  for(; *s; s++)
 224:	00054783          	lbu	a5,0(a0)
 228:	cb99                	beqz	a5,23e <strchr+0x20>
    if(*s == c)
 22a:	00f58763          	beq	a1,a5,238 <strchr+0x1a>
  for(; *s; s++)
 22e:	0505                	addi	a0,a0,1
 230:	00054783          	lbu	a5,0(a0)
 234:	fbfd                	bnez	a5,22a <strchr+0xc>
      return (char*)s;
  return 0;
 236:	4501                	li	a0,0
}
 238:	6422                	ld	s0,8(sp)
 23a:	0141                	addi	sp,sp,16
 23c:	8082                	ret
  return 0;
 23e:	4501                	li	a0,0
 240:	bfe5                	j	238 <strchr+0x1a>

0000000000000242 <gets>:

char*
gets(char *buf, int max)
{
 242:	711d                	addi	sp,sp,-96
 244:	ec86                	sd	ra,88(sp)
 246:	e8a2                	sd	s0,80(sp)
 248:	e4a6                	sd	s1,72(sp)
 24a:	e0ca                	sd	s2,64(sp)
 24c:	fc4e                	sd	s3,56(sp)
 24e:	f852                	sd	s4,48(sp)
 250:	f456                	sd	s5,40(sp)
 252:	f05a                	sd	s6,32(sp)
 254:	ec5e                	sd	s7,24(sp)
 256:	1080                	addi	s0,sp,96
 258:	8baa                	mv	s7,a0
 25a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 25c:	892a                	mv	s2,a0
 25e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 260:	4aa9                	li	s5,10
 262:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 264:	89a6                	mv	s3,s1
 266:	2485                	addiw	s1,s1,1
 268:	0344d663          	bge	s1,s4,294 <gets+0x52>
    cc = read(0, &c, 1);
 26c:	4605                	li	a2,1
 26e:	faf40593          	addi	a1,s0,-81
 272:	4501                	li	a0,0
 274:	1b2000ef          	jal	426 <read>
    if(cc < 1)
 278:	00a05e63          	blez	a0,294 <gets+0x52>
    buf[i++] = c;
 27c:	faf44783          	lbu	a5,-81(s0)
 280:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 284:	01578763          	beq	a5,s5,292 <gets+0x50>
 288:	0905                	addi	s2,s2,1
 28a:	fd679de3          	bne	a5,s6,264 <gets+0x22>
    buf[i++] = c;
 28e:	89a6                	mv	s3,s1
 290:	a011                	j	294 <gets+0x52>
 292:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 294:	99de                	add	s3,s3,s7
 296:	00098023          	sb	zero,0(s3)
  return buf;
}
 29a:	855e                	mv	a0,s7
 29c:	60e6                	ld	ra,88(sp)
 29e:	6446                	ld	s0,80(sp)
 2a0:	64a6                	ld	s1,72(sp)
 2a2:	6906                	ld	s2,64(sp)
 2a4:	79e2                	ld	s3,56(sp)
 2a6:	7a42                	ld	s4,48(sp)
 2a8:	7aa2                	ld	s5,40(sp)
 2aa:	7b02                	ld	s6,32(sp)
 2ac:	6be2                	ld	s7,24(sp)
 2ae:	6125                	addi	sp,sp,96
 2b0:	8082                	ret

00000000000002b2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2b2:	1101                	addi	sp,sp,-32
 2b4:	ec06                	sd	ra,24(sp)
 2b6:	e822                	sd	s0,16(sp)
 2b8:	e04a                	sd	s2,0(sp)
 2ba:	1000                	addi	s0,sp,32
 2bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2be:	4581                	li	a1,0
 2c0:	18e000ef          	jal	44e <open>
  if(fd < 0)
 2c4:	02054263          	bltz	a0,2e8 <stat+0x36>
 2c8:	e426                	sd	s1,8(sp)
 2ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2cc:	85ca                	mv	a1,s2
 2ce:	198000ef          	jal	466 <fstat>
 2d2:	892a                	mv	s2,a0
  close(fd);
 2d4:	8526                	mv	a0,s1
 2d6:	160000ef          	jal	436 <close>
  return r;
 2da:	64a2                	ld	s1,8(sp)
}
 2dc:	854a                	mv	a0,s2
 2de:	60e2                	ld	ra,24(sp)
 2e0:	6442                	ld	s0,16(sp)
 2e2:	6902                	ld	s2,0(sp)
 2e4:	6105                	addi	sp,sp,32
 2e6:	8082                	ret
    return -1;
 2e8:	597d                	li	s2,-1
 2ea:	bfcd                	j	2dc <stat+0x2a>

00000000000002ec <atoi>:

int
atoi(const char *s)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f2:	00054683          	lbu	a3,0(a0)
 2f6:	fd06879b          	addiw	a5,a3,-48
 2fa:	0ff7f793          	zext.b	a5,a5
 2fe:	4625                	li	a2,9
 300:	02f66863          	bltu	a2,a5,330 <atoi+0x44>
 304:	872a                	mv	a4,a0
  n = 0;
 306:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 308:	0705                	addi	a4,a4,1
 30a:	0025179b          	slliw	a5,a0,0x2
 30e:	9fa9                	addw	a5,a5,a0
 310:	0017979b          	slliw	a5,a5,0x1
 314:	9fb5                	addw	a5,a5,a3
 316:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 31a:	00074683          	lbu	a3,0(a4)
 31e:	fd06879b          	addiw	a5,a3,-48
 322:	0ff7f793          	zext.b	a5,a5
 326:	fef671e3          	bgeu	a2,a5,308 <atoi+0x1c>
  return n;
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  n = 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <atoi+0x3e>

0000000000000334 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e422                	sd	s0,8(sp)
 338:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33a:	02b57463          	bgeu	a0,a1,362 <memmove+0x2e>
    while(n-- > 0)
 33e:	00c05f63          	blez	a2,35c <memmove+0x28>
 342:	1602                	slli	a2,a2,0x20
 344:	9201                	srli	a2,a2,0x20
 346:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34a:	872a                	mv	a4,a0
      *dst++ = *src++;
 34c:	0585                	addi	a1,a1,1
 34e:	0705                	addi	a4,a4,1
 350:	fff5c683          	lbu	a3,-1(a1)
 354:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 358:	fef71ae3          	bne	a4,a5,34c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35c:	6422                	ld	s0,8(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret
    dst += n;
 362:	00c50733          	add	a4,a0,a2
    src += n;
 366:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 368:	fec05ae3          	blez	a2,35c <memmove+0x28>
 36c:	fff6079b          	addiw	a5,a2,-1
 370:	1782                	slli	a5,a5,0x20
 372:	9381                	srli	a5,a5,0x20
 374:	fff7c793          	not	a5,a5
 378:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37a:	15fd                	addi	a1,a1,-1
 37c:	177d                	addi	a4,a4,-1
 37e:	0005c683          	lbu	a3,0(a1)
 382:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 386:	fee79ae3          	bne	a5,a4,37a <memmove+0x46>
 38a:	bfc9                	j	35c <memmove+0x28>

000000000000038c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 38c:	1141                	addi	sp,sp,-16
 38e:	e422                	sd	s0,8(sp)
 390:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 392:	ca05                	beqz	a2,3c2 <memcmp+0x36>
 394:	fff6069b          	addiw	a3,a2,-1
 398:	1682                	slli	a3,a3,0x20
 39a:	9281                	srli	a3,a3,0x20
 39c:	0685                	addi	a3,a3,1
 39e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a0:	00054783          	lbu	a5,0(a0)
 3a4:	0005c703          	lbu	a4,0(a1)
 3a8:	00e79863          	bne	a5,a4,3b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ac:	0505                	addi	a0,a0,1
    p2++;
 3ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b0:	fed518e3          	bne	a0,a3,3a0 <memcmp+0x14>
  }
  return 0;
 3b4:	4501                	li	a0,0
 3b6:	a019                	j	3bc <memcmp+0x30>
      return *p1 - *p2;
 3b8:	40e7853b          	subw	a0,a5,a4
}
 3bc:	6422                	ld	s0,8(sp)
 3be:	0141                	addi	sp,sp,16
 3c0:	8082                	ret
  return 0;
 3c2:	4501                	li	a0,0
 3c4:	bfe5                	j	3bc <memcmp+0x30>

00000000000003c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c6:	1141                	addi	sp,sp,-16
 3c8:	e406                	sd	ra,8(sp)
 3ca:	e022                	sd	s0,0(sp)
 3cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ce:	f67ff0ef          	jal	334 <memmove>
}
 3d2:	60a2                	ld	ra,8(sp)
 3d4:	6402                	ld	s0,0(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret

00000000000003da <sbrk>:

char *
sbrk(int n) {
 3da:	1141                	addi	sp,sp,-16
 3dc:	e406                	sd	ra,8(sp)
 3de:	e022                	sd	s0,0(sp)
 3e0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3e2:	4585                	li	a1,1
 3e4:	0b2000ef          	jal	496 <sys_sbrk>
}
 3e8:	60a2                	ld	ra,8(sp)
 3ea:	6402                	ld	s0,0(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret

00000000000003f0 <sbrklazy>:

char *
sbrklazy(int n) {
 3f0:	1141                	addi	sp,sp,-16
 3f2:	e406                	sd	ra,8(sp)
 3f4:	e022                	sd	s0,0(sp)
 3f6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3f8:	4589                	li	a1,2
 3fa:	09c000ef          	jal	496 <sys_sbrk>
}
 3fe:	60a2                	ld	ra,8(sp)
 400:	6402                	ld	s0,0(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret

0000000000000406 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 406:	4885                	li	a7,1
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <exit>:
.global exit
exit:
 li a7, SYS_exit
 40e:	4889                	li	a7,2
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <wait>:
.global wait
wait:
 li a7, SYS_wait
 416:	488d                	li	a7,3
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 41e:	4891                	li	a7,4
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <read>:
.global read
read:
 li a7, SYS_read
 426:	4895                	li	a7,5
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <write>:
.global write
write:
 li a7, SYS_write
 42e:	48c1                	li	a7,16
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <close>:
.global close
close:
 li a7, SYS_close
 436:	48d5                	li	a7,21
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <kill>:
.global kill
kill:
 li a7, SYS_kill
 43e:	4899                	li	a7,6
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <exec>:
.global exec
exec:
 li a7, SYS_exec
 446:	489d                	li	a7,7
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <open>:
.global open
open:
 li a7, SYS_open
 44e:	48bd                	li	a7,15
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 456:	48c5                	li	a7,17
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 45e:	48c9                	li	a7,18
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 466:	48a1                	li	a7,8
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <link>:
.global link
link:
 li a7, SYS_link
 46e:	48cd                	li	a7,19
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 476:	48d1                	li	a7,20
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 47e:	48a5                	li	a7,9
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <dup>:
.global dup
dup:
 li a7, SYS_dup
 486:	48a9                	li	a7,10
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 48e:	48ad                	li	a7,11
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 496:	48b1                	li	a7,12
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <pause>:
.global pause
pause:
 li a7, SYS_pause
 49e:	48b5                	li	a7,13
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4a6:	48b9                	li	a7,14
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <csread>:
.global csread
csread:
 li a7, SYS_csread
 4ae:	48d9                	li	a7,22
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 4b6:	48dd                	li	a7,23
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 4be:	48e1                	li	a7,24
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <memread>:
.global memread
memread:
 li a7, SYS_memread
 4c6:	48e5                	li	a7,25
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ce:	1101                	addi	sp,sp,-32
 4d0:	ec06                	sd	ra,24(sp)
 4d2:	e822                	sd	s0,16(sp)
 4d4:	1000                	addi	s0,sp,32
 4d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4da:	4605                	li	a2,1
 4dc:	fef40593          	addi	a1,s0,-17
 4e0:	f4fff0ef          	jal	42e <write>
}
 4e4:	60e2                	ld	ra,24(sp)
 4e6:	6442                	ld	s0,16(sp)
 4e8:	6105                	addi	sp,sp,32
 4ea:	8082                	ret

00000000000004ec <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ec:	715d                	addi	sp,sp,-80
 4ee:	e486                	sd	ra,72(sp)
 4f0:	e0a2                	sd	s0,64(sp)
 4f2:	f84a                	sd	s2,48(sp)
 4f4:	0880                	addi	s0,sp,80
 4f6:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4f8:	c299                	beqz	a3,4fe <printint+0x12>
 4fa:	0805c363          	bltz	a1,580 <printint+0x94>
  neg = 0;
 4fe:	4881                	li	a7,0
 500:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 504:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 506:	00000517          	auipc	a0,0x0
 50a:	64250513          	addi	a0,a0,1602 # b48 <digits>
 50e:	883e                	mv	a6,a5
 510:	2785                	addiw	a5,a5,1
 512:	02c5f733          	remu	a4,a1,a2
 516:	972a                	add	a4,a4,a0
 518:	00074703          	lbu	a4,0(a4)
 51c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 520:	872e                	mv	a4,a1
 522:	02c5d5b3          	divu	a1,a1,a2
 526:	0685                	addi	a3,a3,1
 528:	fec773e3          	bgeu	a4,a2,50e <printint+0x22>
  if(neg)
 52c:	00088b63          	beqz	a7,542 <printint+0x56>
    buf[i++] = '-';
 530:	fd078793          	addi	a5,a5,-48
 534:	97a2                	add	a5,a5,s0
 536:	02d00713          	li	a4,45
 53a:	fee78423          	sb	a4,-24(a5)
 53e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 542:	02f05a63          	blez	a5,576 <printint+0x8a>
 546:	fc26                	sd	s1,56(sp)
 548:	f44e                	sd	s3,40(sp)
 54a:	fb840713          	addi	a4,s0,-72
 54e:	00f704b3          	add	s1,a4,a5
 552:	fff70993          	addi	s3,a4,-1
 556:	99be                	add	s3,s3,a5
 558:	37fd                	addiw	a5,a5,-1
 55a:	1782                	slli	a5,a5,0x20
 55c:	9381                	srli	a5,a5,0x20
 55e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 562:	fff4c583          	lbu	a1,-1(s1)
 566:	854a                	mv	a0,s2
 568:	f67ff0ef          	jal	4ce <putc>
  while(--i >= 0)
 56c:	14fd                	addi	s1,s1,-1
 56e:	ff349ae3          	bne	s1,s3,562 <printint+0x76>
 572:	74e2                	ld	s1,56(sp)
 574:	79a2                	ld	s3,40(sp)
}
 576:	60a6                	ld	ra,72(sp)
 578:	6406                	ld	s0,64(sp)
 57a:	7942                	ld	s2,48(sp)
 57c:	6161                	addi	sp,sp,80
 57e:	8082                	ret
    x = -xx;
 580:	40b005b3          	neg	a1,a1
    neg = 1;
 584:	4885                	li	a7,1
    x = -xx;
 586:	bfad                	j	500 <printint+0x14>

0000000000000588 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 588:	711d                	addi	sp,sp,-96
 58a:	ec86                	sd	ra,88(sp)
 58c:	e8a2                	sd	s0,80(sp)
 58e:	e0ca                	sd	s2,64(sp)
 590:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 592:	0005c903          	lbu	s2,0(a1)
 596:	28090663          	beqz	s2,822 <vprintf+0x29a>
 59a:	e4a6                	sd	s1,72(sp)
 59c:	fc4e                	sd	s3,56(sp)
 59e:	f852                	sd	s4,48(sp)
 5a0:	f456                	sd	s5,40(sp)
 5a2:	f05a                	sd	s6,32(sp)
 5a4:	ec5e                	sd	s7,24(sp)
 5a6:	e862                	sd	s8,16(sp)
 5a8:	e466                	sd	s9,8(sp)
 5aa:	8b2a                	mv	s6,a0
 5ac:	8a2e                	mv	s4,a1
 5ae:	8bb2                	mv	s7,a2
  state = 0;
 5b0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5b2:	4481                	li	s1,0
 5b4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5b6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5ba:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5be:	06c00c93          	li	s9,108
 5c2:	a005                	j	5e2 <vprintf+0x5a>
        putc(fd, c0);
 5c4:	85ca                	mv	a1,s2
 5c6:	855a                	mv	a0,s6
 5c8:	f07ff0ef          	jal	4ce <putc>
 5cc:	a019                	j	5d2 <vprintf+0x4a>
    } else if(state == '%'){
 5ce:	03598263          	beq	s3,s5,5f2 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5d2:	2485                	addiw	s1,s1,1
 5d4:	8726                	mv	a4,s1
 5d6:	009a07b3          	add	a5,s4,s1
 5da:	0007c903          	lbu	s2,0(a5)
 5de:	22090a63          	beqz	s2,812 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5e2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e6:	fe0994e3          	bnez	s3,5ce <vprintf+0x46>
      if(c0 == '%'){
 5ea:	fd579de3          	bne	a5,s5,5c4 <vprintf+0x3c>
        state = '%';
 5ee:	89be                	mv	s3,a5
 5f0:	b7cd                	j	5d2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5f2:	00ea06b3          	add	a3,s4,a4
 5f6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5fa:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5fc:	c681                	beqz	a3,604 <vprintf+0x7c>
 5fe:	9752                	add	a4,a4,s4
 600:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 604:	05878363          	beq	a5,s8,64a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 608:	05978d63          	beq	a5,s9,662 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 60c:	07500713          	li	a4,117
 610:	0ee78763          	beq	a5,a4,6fe <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 614:	07800713          	li	a4,120
 618:	12e78963          	beq	a5,a4,74a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 61c:	07000713          	li	a4,112
 620:	14e78e63          	beq	a5,a4,77c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 624:	06300713          	li	a4,99
 628:	18e78e63          	beq	a5,a4,7c4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 62c:	07300713          	li	a4,115
 630:	1ae78463          	beq	a5,a4,7d8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 634:	02500713          	li	a4,37
 638:	04e79563          	bne	a5,a4,682 <vprintf+0xfa>
        putc(fd, '%');
 63c:	02500593          	li	a1,37
 640:	855a                	mv	a0,s6
 642:	e8dff0ef          	jal	4ce <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 646:	4981                	li	s3,0
 648:	b769                	j	5d2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4685                	li	a3,1
 650:	4629                	li	a2,10
 652:	000ba583          	lw	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	e95ff0ef          	jal	4ec <printint>
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
 660:	bf8d                	j	5d2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 662:	06400793          	li	a5,100
 666:	02f68963          	beq	a3,a5,698 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 66a:	06c00793          	li	a5,108
 66e:	04f68263          	beq	a3,a5,6b2 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 672:	07500793          	li	a5,117
 676:	0af68063          	beq	a3,a5,716 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 67a:	07800793          	li	a5,120
 67e:	0ef68263          	beq	a3,a5,762 <vprintf+0x1da>
        putc(fd, '%');
 682:	02500593          	li	a1,37
 686:	855a                	mv	a0,s6
 688:	e47ff0ef          	jal	4ce <putc>
        putc(fd, c0);
 68c:	85ca                	mv	a1,s2
 68e:	855a                	mv	a0,s6
 690:	e3fff0ef          	jal	4ce <putc>
      state = 0;
 694:	4981                	li	s3,0
 696:	bf35                	j	5d2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 698:	008b8913          	addi	s2,s7,8
 69c:	4685                	li	a3,1
 69e:	4629                	li	a2,10
 6a0:	000bb583          	ld	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	e47ff0ef          	jal	4ec <printint>
        i += 1;
 6aa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ac:	8bca                	mv	s7,s2
      state = 0;
 6ae:	4981                	li	s3,0
        i += 1;
 6b0:	b70d                	j	5d2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b2:	06400793          	li	a5,100
 6b6:	02f60763          	beq	a2,a5,6e4 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6ba:	07500793          	li	a5,117
 6be:	06f60963          	beq	a2,a5,730 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6c2:	07800793          	li	a5,120
 6c6:	faf61ee3          	bne	a2,a5,682 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ca:	008b8913          	addi	s2,s7,8
 6ce:	4681                	li	a3,0
 6d0:	4641                	li	a2,16
 6d2:	000bb583          	ld	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	e15ff0ef          	jal	4ec <printint>
        i += 2;
 6dc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6de:	8bca                	mv	s7,s2
      state = 0;
 6e0:	4981                	li	s3,0
        i += 2;
 6e2:	bdc5                	j	5d2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e4:	008b8913          	addi	s2,s7,8
 6e8:	4685                	li	a3,1
 6ea:	4629                	li	a2,10
 6ec:	000bb583          	ld	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	dfbff0ef          	jal	4ec <printint>
        i += 2;
 6f6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f8:	8bca                	mv	s7,s2
      state = 0;
 6fa:	4981                	li	s3,0
        i += 2;
 6fc:	bdd9                	j	5d2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6fe:	008b8913          	addi	s2,s7,8
 702:	4681                	li	a3,0
 704:	4629                	li	a2,10
 706:	000be583          	lwu	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	de1ff0ef          	jal	4ec <printint>
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
 714:	bd7d                	j	5d2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 716:	008b8913          	addi	s2,s7,8
 71a:	4681                	li	a3,0
 71c:	4629                	li	a2,10
 71e:	000bb583          	ld	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	dc9ff0ef          	jal	4ec <printint>
        i += 1;
 728:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 72a:	8bca                	mv	s7,s2
      state = 0;
 72c:	4981                	li	s3,0
        i += 1;
 72e:	b555                	j	5d2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 730:	008b8913          	addi	s2,s7,8
 734:	4681                	li	a3,0
 736:	4629                	li	a2,10
 738:	000bb583          	ld	a1,0(s7)
 73c:	855a                	mv	a0,s6
 73e:	dafff0ef          	jal	4ec <printint>
        i += 2;
 742:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 744:	8bca                	mv	s7,s2
      state = 0;
 746:	4981                	li	s3,0
        i += 2;
 748:	b569                	j	5d2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 74a:	008b8913          	addi	s2,s7,8
 74e:	4681                	li	a3,0
 750:	4641                	li	a2,16
 752:	000be583          	lwu	a1,0(s7)
 756:	855a                	mv	a0,s6
 758:	d95ff0ef          	jal	4ec <printint>
 75c:	8bca                	mv	s7,s2
      state = 0;
 75e:	4981                	li	s3,0
 760:	bd8d                	j	5d2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 762:	008b8913          	addi	s2,s7,8
 766:	4681                	li	a3,0
 768:	4641                	li	a2,16
 76a:	000bb583          	ld	a1,0(s7)
 76e:	855a                	mv	a0,s6
 770:	d7dff0ef          	jal	4ec <printint>
        i += 1;
 774:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 776:	8bca                	mv	s7,s2
      state = 0;
 778:	4981                	li	s3,0
        i += 1;
 77a:	bda1                	j	5d2 <vprintf+0x4a>
 77c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 77e:	008b8d13          	addi	s10,s7,8
 782:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 786:	03000593          	li	a1,48
 78a:	855a                	mv	a0,s6
 78c:	d43ff0ef          	jal	4ce <putc>
  putc(fd, 'x');
 790:	07800593          	li	a1,120
 794:	855a                	mv	a0,s6
 796:	d39ff0ef          	jal	4ce <putc>
 79a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 79c:	00000b97          	auipc	s7,0x0
 7a0:	3acb8b93          	addi	s7,s7,940 # b48 <digits>
 7a4:	03c9d793          	srli	a5,s3,0x3c
 7a8:	97de                	add	a5,a5,s7
 7aa:	0007c583          	lbu	a1,0(a5)
 7ae:	855a                	mv	a0,s6
 7b0:	d1fff0ef          	jal	4ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7b4:	0992                	slli	s3,s3,0x4
 7b6:	397d                	addiw	s2,s2,-1
 7b8:	fe0916e3          	bnez	s2,7a4 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7bc:	8bea                	mv	s7,s10
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	6d02                	ld	s10,0(sp)
 7c2:	bd01                	j	5d2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7c4:	008b8913          	addi	s2,s7,8
 7c8:	000bc583          	lbu	a1,0(s7)
 7cc:	855a                	mv	a0,s6
 7ce:	d01ff0ef          	jal	4ce <putc>
 7d2:	8bca                	mv	s7,s2
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	bbf5                	j	5d2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7d8:	008b8993          	addi	s3,s7,8
 7dc:	000bb903          	ld	s2,0(s7)
 7e0:	00090f63          	beqz	s2,7fe <vprintf+0x276>
        for(; *s; s++)
 7e4:	00094583          	lbu	a1,0(s2)
 7e8:	c195                	beqz	a1,80c <vprintf+0x284>
          putc(fd, *s);
 7ea:	855a                	mv	a0,s6
 7ec:	ce3ff0ef          	jal	4ce <putc>
        for(; *s; s++)
 7f0:	0905                	addi	s2,s2,1
 7f2:	00094583          	lbu	a1,0(s2)
 7f6:	f9f5                	bnez	a1,7ea <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7f8:	8bce                	mv	s7,s3
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	bbd9                	j	5d2 <vprintf+0x4a>
          s = "(null)";
 7fe:	00000917          	auipc	s2,0x0
 802:	30290913          	addi	s2,s2,770 # b00 <malloc+0x1f6>
        for(; *s; s++)
 806:	02800593          	li	a1,40
 80a:	b7c5                	j	7ea <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 80c:	8bce                	mv	s7,s3
      state = 0;
 80e:	4981                	li	s3,0
 810:	b3c9                	j	5d2 <vprintf+0x4a>
 812:	64a6                	ld	s1,72(sp)
 814:	79e2                	ld	s3,56(sp)
 816:	7a42                	ld	s4,48(sp)
 818:	7aa2                	ld	s5,40(sp)
 81a:	7b02                	ld	s6,32(sp)
 81c:	6be2                	ld	s7,24(sp)
 81e:	6c42                	ld	s8,16(sp)
 820:	6ca2                	ld	s9,8(sp)
    }
  }
}
 822:	60e6                	ld	ra,88(sp)
 824:	6446                	ld	s0,80(sp)
 826:	6906                	ld	s2,64(sp)
 828:	6125                	addi	sp,sp,96
 82a:	8082                	ret

000000000000082c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 82c:	715d                	addi	sp,sp,-80
 82e:	ec06                	sd	ra,24(sp)
 830:	e822                	sd	s0,16(sp)
 832:	1000                	addi	s0,sp,32
 834:	e010                	sd	a2,0(s0)
 836:	e414                	sd	a3,8(s0)
 838:	e818                	sd	a4,16(s0)
 83a:	ec1c                	sd	a5,24(s0)
 83c:	03043023          	sd	a6,32(s0)
 840:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 844:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 848:	8622                	mv	a2,s0
 84a:	d3fff0ef          	jal	588 <vprintf>
}
 84e:	60e2                	ld	ra,24(sp)
 850:	6442                	ld	s0,16(sp)
 852:	6161                	addi	sp,sp,80
 854:	8082                	ret

0000000000000856 <printf>:

void
printf(const char *fmt, ...)
{
 856:	711d                	addi	sp,sp,-96
 858:	ec06                	sd	ra,24(sp)
 85a:	e822                	sd	s0,16(sp)
 85c:	1000                	addi	s0,sp,32
 85e:	e40c                	sd	a1,8(s0)
 860:	e810                	sd	a2,16(s0)
 862:	ec14                	sd	a3,24(s0)
 864:	f018                	sd	a4,32(s0)
 866:	f41c                	sd	a5,40(s0)
 868:	03043823          	sd	a6,48(s0)
 86c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 870:	00840613          	addi	a2,s0,8
 874:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 878:	85aa                	mv	a1,a0
 87a:	4505                	li	a0,1
 87c:	d0dff0ef          	jal	588 <vprintf>
}
 880:	60e2                	ld	ra,24(sp)
 882:	6442                	ld	s0,16(sp)
 884:	6125                	addi	sp,sp,96
 886:	8082                	ret

0000000000000888 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 888:	1141                	addi	sp,sp,-16
 88a:	e422                	sd	s0,8(sp)
 88c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 892:	00000797          	auipc	a5,0x0
 896:	76e7b783          	ld	a5,1902(a5) # 1000 <freep>
 89a:	a02d                	j	8c4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 89c:	4618                	lw	a4,8(a2)
 89e:	9f2d                	addw	a4,a4,a1
 8a0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a4:	6398                	ld	a4,0(a5)
 8a6:	6310                	ld	a2,0(a4)
 8a8:	a83d                	j	8e6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8aa:	ff852703          	lw	a4,-8(a0)
 8ae:	9f31                	addw	a4,a4,a2
 8b0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8b2:	ff053683          	ld	a3,-16(a0)
 8b6:	a091                	j	8fa <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b8:	6398                	ld	a4,0(a5)
 8ba:	00e7e463          	bltu	a5,a4,8c2 <free+0x3a>
 8be:	00e6ea63          	bltu	a3,a4,8d2 <free+0x4a>
{
 8c2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c4:	fed7fae3          	bgeu	a5,a3,8b8 <free+0x30>
 8c8:	6398                	ld	a4,0(a5)
 8ca:	00e6e463          	bltu	a3,a4,8d2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ce:	fee7eae3          	bltu	a5,a4,8c2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8d2:	ff852583          	lw	a1,-8(a0)
 8d6:	6390                	ld	a2,0(a5)
 8d8:	02059813          	slli	a6,a1,0x20
 8dc:	01c85713          	srli	a4,a6,0x1c
 8e0:	9736                	add	a4,a4,a3
 8e2:	fae60de3          	beq	a2,a4,89c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8e6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ea:	4790                	lw	a2,8(a5)
 8ec:	02061593          	slli	a1,a2,0x20
 8f0:	01c5d713          	srli	a4,a1,0x1c
 8f4:	973e                	add	a4,a4,a5
 8f6:	fae68ae3          	beq	a3,a4,8aa <free+0x22>
    p->s.ptr = bp->s.ptr;
 8fa:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8fc:	00000717          	auipc	a4,0x0
 900:	70f73223          	sd	a5,1796(a4) # 1000 <freep>
}
 904:	6422                	ld	s0,8(sp)
 906:	0141                	addi	sp,sp,16
 908:	8082                	ret

000000000000090a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 90a:	7139                	addi	sp,sp,-64
 90c:	fc06                	sd	ra,56(sp)
 90e:	f822                	sd	s0,48(sp)
 910:	f426                	sd	s1,40(sp)
 912:	ec4e                	sd	s3,24(sp)
 914:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 916:	02051493          	slli	s1,a0,0x20
 91a:	9081                	srli	s1,s1,0x20
 91c:	04bd                	addi	s1,s1,15
 91e:	8091                	srli	s1,s1,0x4
 920:	0014899b          	addiw	s3,s1,1
 924:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 926:	00000517          	auipc	a0,0x0
 92a:	6da53503          	ld	a0,1754(a0) # 1000 <freep>
 92e:	c915                	beqz	a0,962 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 930:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 932:	4798                	lw	a4,8(a5)
 934:	08977a63          	bgeu	a4,s1,9c8 <malloc+0xbe>
 938:	f04a                	sd	s2,32(sp)
 93a:	e852                	sd	s4,16(sp)
 93c:	e456                	sd	s5,8(sp)
 93e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 940:	8a4e                	mv	s4,s3
 942:	0009871b          	sext.w	a4,s3
 946:	6685                	lui	a3,0x1
 948:	00d77363          	bgeu	a4,a3,94e <malloc+0x44>
 94c:	6a05                	lui	s4,0x1
 94e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 952:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 956:	00000917          	auipc	s2,0x0
 95a:	6aa90913          	addi	s2,s2,1706 # 1000 <freep>
  if(p == SBRK_ERROR)
 95e:	5afd                	li	s5,-1
 960:	a081                	j	9a0 <malloc+0x96>
 962:	f04a                	sd	s2,32(sp)
 964:	e852                	sd	s4,16(sp)
 966:	e456                	sd	s5,8(sp)
 968:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 96a:	00000797          	auipc	a5,0x0
 96e:	6a678793          	addi	a5,a5,1702 # 1010 <base>
 972:	00000717          	auipc	a4,0x0
 976:	68f73723          	sd	a5,1678(a4) # 1000 <freep>
 97a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 97c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 980:	b7c1                	j	940 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 982:	6398                	ld	a4,0(a5)
 984:	e118                	sd	a4,0(a0)
 986:	a8a9                	j	9e0 <malloc+0xd6>
  hp->s.size = nu;
 988:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 98c:	0541                	addi	a0,a0,16
 98e:	efbff0ef          	jal	888 <free>
  return freep;
 992:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 996:	c12d                	beqz	a0,9f8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 998:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 99a:	4798                	lw	a4,8(a5)
 99c:	02977263          	bgeu	a4,s1,9c0 <malloc+0xb6>
    if(p == freep)
 9a0:	00093703          	ld	a4,0(s2)
 9a4:	853e                	mv	a0,a5
 9a6:	fef719e3          	bne	a4,a5,998 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9aa:	8552                	mv	a0,s4
 9ac:	a2fff0ef          	jal	3da <sbrk>
  if(p == SBRK_ERROR)
 9b0:	fd551ce3          	bne	a0,s5,988 <malloc+0x7e>
        return 0;
 9b4:	4501                	li	a0,0
 9b6:	7902                	ld	s2,32(sp)
 9b8:	6a42                	ld	s4,16(sp)
 9ba:	6aa2                	ld	s5,8(sp)
 9bc:	6b02                	ld	s6,0(sp)
 9be:	a03d                	j	9ec <malloc+0xe2>
 9c0:	7902                	ld	s2,32(sp)
 9c2:	6a42                	ld	s4,16(sp)
 9c4:	6aa2                	ld	s5,8(sp)
 9c6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9c8:	fae48de3          	beq	s1,a4,982 <malloc+0x78>
        p->s.size -= nunits;
 9cc:	4137073b          	subw	a4,a4,s3
 9d0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d2:	02071693          	slli	a3,a4,0x20
 9d6:	01c6d713          	srli	a4,a3,0x1c
 9da:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9dc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e0:	00000717          	auipc	a4,0x0
 9e4:	62a73023          	sd	a0,1568(a4) # 1000 <freep>
      return (void*)(p + 1);
 9e8:	01078513          	addi	a0,a5,16
  }
}
 9ec:	70e2                	ld	ra,56(sp)
 9ee:	7442                	ld	s0,48(sp)
 9f0:	74a2                	ld	s1,40(sp)
 9f2:	69e2                	ld	s3,24(sp)
 9f4:	6121                	addi	sp,sp,64
 9f6:	8082                	ret
 9f8:	7902                	ld	s2,32(sp)
 9fa:	6a42                	ld	s4,16(sp)
 9fc:	6aa2                	ld	s5,8(sp)
 9fe:	6b02                	ld	s6,0(sp)
 a00:	b7f5                	j	9ec <malloc+0xe2>
