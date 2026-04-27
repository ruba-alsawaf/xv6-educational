
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
  40:	a24b0b13          	addi	s6,s6,-1500 # a60 <malloc+0x146>
  switch(t){
  44:	00001a17          	auipc	s4,0x1
  48:	af4a0a13          	addi	s4,s4,-1292 # b38 <malloc+0x21e>
  4c:	00001d17          	auipc	s10,0x1
  50:	9e4d0d13          	addi	s10,s10,-1564 # a30 <malloc+0x116>
    case MEM_FREE:   return "FREE";
  54:	00001d97          	auipc	s11,0x1
  58:	a04d8d93          	addi	s11,s11,-1532 # a58 <malloc+0x13e>
  struct mem_event ev[16];
  int n, i;

  for(;;){
    n = memread(ev, 16);
  5c:	45c1                	li	a1,16
  5e:	91040513          	addi	a0,s0,-1776
  62:	474000ef          	jal	4d6 <memread>
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
  78:	9dcc8c93          	addi	s9,s9,-1572 # a50 <malloc+0x136>
    case MEM_UNMAP:  return "UNMAP";
  7c:	00001c17          	auipc	s8,0x1
  80:	9ccc0c13          	addi	s8,s8,-1588 # a48 <malloc+0x12e>
    case MEM_MAP:    return "MAP";
  84:	00001b97          	auipc	s7,0x1
  88:	9bcb8b93          	addi	s7,s7,-1604 # a40 <malloc+0x126>
  8c:	a89d                	j	102 <main+0x102>
    case MEM_GROW:   return "GROW";
  8e:	00001817          	auipc	a6,0x1
  92:	99280813          	addi	a6,a6,-1646 # a20 <malloc+0x106>
  switch(s){
  96:	41a8                	lw	a0,64(a1)
  98:	0ca9e763          	bltu	s3,a0,166 <main+0x166>
  9c:	0405e503          	lwu	a0,64(a1)
  a0:	050a                	slli	a0,a0,0x2
  a2:	00001897          	auipc	a7,0x1
  a6:	a7688893          	addi	a7,a7,-1418 # b18 <malloc+0x1fe>
  aa:	9546                	add	a0,a0,a7
  ac:	4108                	lw	a0,0(a0)
  ae:	9546                	add	a0,a0,a7
  b0:	8502                	jr	a0
    case MEM_FAULT:  return "FAULT";
  b2:	00001817          	auipc	a6,0x1
  b6:	98680813          	addi	a6,a6,-1658 # a38 <malloc+0x11e>
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
  d8:	99488893          	addi	a7,a7,-1644 # a68 <malloc+0x14e>
     
    
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s name=%s old=%p new=%p\n",
  dc:	02c5b503          	ld	a0,44(a1)
  e0:	e82a                	sd	a0,16(sp)
  e2:	0245b503          	ld	a0,36(a1)
  e6:	e42a                	sd	a0,8(sp)
  e8:	e02e                	sd	a1,0(sp)
  ea:	85ca                	mv	a1,s2
  ec:	00001517          	auipc	a0,0x1
  f0:	9dc50513          	addi	a0,a0,-1572 # ac8 <malloc+0x1ae>
  f4:	772000ef          	jal	866 <printf>
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
 12e:	94e88893          	addi	a7,a7,-1714 # a78 <malloc+0x15e>
 132:	b76d                	j	dc <main+0xdc>
    case SRC_MAPPAGES:   return "MAPPAGES";
 134:	00001897          	auipc	a7,0x1
 138:	94c88893          	addi	a7,a7,-1716 # a80 <malloc+0x166>
 13c:	b745                	j	dc <main+0xdc>
    case SRC_UVMUNMAP:   return "UVMUNMAP";
 13e:	00001897          	auipc	a7,0x1
 142:	95288893          	addi	a7,a7,-1710 # a90 <malloc+0x176>
 146:	bf59                	j	dc <main+0xdc>
    case SRC_UVMALLOC:   return "UVMALLOC";
 148:	00001897          	auipc	a7,0x1
 14c:	95888893          	addi	a7,a7,-1704 # aa0 <malloc+0x186>
 150:	b771                	j	dc <main+0xdc>
    case SRC_UVMDEALLOC: return "UVMDEALLOC";
 152:	00001897          	auipc	a7,0x1
 156:	95e88893          	addi	a7,a7,-1698 # ab0 <malloc+0x196>
 15a:	b749                	j	dc <main+0xdc>
    case SRC_VMFAULT:    return "VMFAULT";
 15c:	00001897          	auipc	a7,0x1
 160:	96488893          	addi	a7,a7,-1692 # ac0 <malloc+0x1a6>
 164:	bfa5                	j	dc <main+0xdc>
    default:             return "UNKNOWN";
 166:	88da                	mv	a7,s6
 168:	bf95                	j	dc <main+0xdc>
  switch(s){
 16a:	00001897          	auipc	a7,0x1
 16e:	90688893          	addi	a7,a7,-1786 # a70 <malloc+0x156>
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
 3e4:	0c2000ef          	jal	4a6 <sys_sbrk>
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
 3fa:	0ac000ef          	jal	4a6 <sys_sbrk>
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

0000000000000496 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 496:	48e9                	li	a7,26
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 49e:	48ed                	li	a7,27
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4a6:	48b1                	li	a7,12
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <pause>:
.global pause
pause:
 li a7, SYS_pause
 4ae:	48b5                	li	a7,13
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b6:	48b9                	li	a7,14
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <csread>:
.global csread
csread:
 li a7, SYS_csread
 4be:	48d9                	li	a7,22
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 4c6:	48dd                	li	a7,23
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 4ce:	48e1                	li	a7,24
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <memread>:
.global memread
memread:
 li a7, SYS_memread
 4d6:	48e5                	li	a7,25
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4de:	1101                	addi	sp,sp,-32
 4e0:	ec06                	sd	ra,24(sp)
 4e2:	e822                	sd	s0,16(sp)
 4e4:	1000                	addi	s0,sp,32
 4e6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ea:	4605                	li	a2,1
 4ec:	fef40593          	addi	a1,s0,-17
 4f0:	f3fff0ef          	jal	42e <write>
}
 4f4:	60e2                	ld	ra,24(sp)
 4f6:	6442                	ld	s0,16(sp)
 4f8:	6105                	addi	sp,sp,32
 4fa:	8082                	ret

00000000000004fc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4fc:	715d                	addi	sp,sp,-80
 4fe:	e486                	sd	ra,72(sp)
 500:	e0a2                	sd	s0,64(sp)
 502:	f84a                	sd	s2,48(sp)
 504:	0880                	addi	s0,sp,80
 506:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 508:	c299                	beqz	a3,50e <printint+0x12>
 50a:	0805c363          	bltz	a1,590 <printint+0x94>
  neg = 0;
 50e:	4881                	li	a7,0
 510:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 514:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 516:	00000517          	auipc	a0,0x0
 51a:	64250513          	addi	a0,a0,1602 # b58 <digits>
 51e:	883e                	mv	a6,a5
 520:	2785                	addiw	a5,a5,1
 522:	02c5f733          	remu	a4,a1,a2
 526:	972a                	add	a4,a4,a0
 528:	00074703          	lbu	a4,0(a4)
 52c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 530:	872e                	mv	a4,a1
 532:	02c5d5b3          	divu	a1,a1,a2
 536:	0685                	addi	a3,a3,1
 538:	fec773e3          	bgeu	a4,a2,51e <printint+0x22>
  if(neg)
 53c:	00088b63          	beqz	a7,552 <printint+0x56>
    buf[i++] = '-';
 540:	fd078793          	addi	a5,a5,-48
 544:	97a2                	add	a5,a5,s0
 546:	02d00713          	li	a4,45
 54a:	fee78423          	sb	a4,-24(a5)
 54e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 552:	02f05a63          	blez	a5,586 <printint+0x8a>
 556:	fc26                	sd	s1,56(sp)
 558:	f44e                	sd	s3,40(sp)
 55a:	fb840713          	addi	a4,s0,-72
 55e:	00f704b3          	add	s1,a4,a5
 562:	fff70993          	addi	s3,a4,-1
 566:	99be                	add	s3,s3,a5
 568:	37fd                	addiw	a5,a5,-1
 56a:	1782                	slli	a5,a5,0x20
 56c:	9381                	srli	a5,a5,0x20
 56e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 572:	fff4c583          	lbu	a1,-1(s1)
 576:	854a                	mv	a0,s2
 578:	f67ff0ef          	jal	4de <putc>
  while(--i >= 0)
 57c:	14fd                	addi	s1,s1,-1
 57e:	ff349ae3          	bne	s1,s3,572 <printint+0x76>
 582:	74e2                	ld	s1,56(sp)
 584:	79a2                	ld	s3,40(sp)
}
 586:	60a6                	ld	ra,72(sp)
 588:	6406                	ld	s0,64(sp)
 58a:	7942                	ld	s2,48(sp)
 58c:	6161                	addi	sp,sp,80
 58e:	8082                	ret
    x = -xx;
 590:	40b005b3          	neg	a1,a1
    neg = 1;
 594:	4885                	li	a7,1
    x = -xx;
 596:	bfad                	j	510 <printint+0x14>

0000000000000598 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 598:	711d                	addi	sp,sp,-96
 59a:	ec86                	sd	ra,88(sp)
 59c:	e8a2                	sd	s0,80(sp)
 59e:	e0ca                	sd	s2,64(sp)
 5a0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a2:	0005c903          	lbu	s2,0(a1)
 5a6:	28090663          	beqz	s2,832 <vprintf+0x29a>
 5aa:	e4a6                	sd	s1,72(sp)
 5ac:	fc4e                	sd	s3,56(sp)
 5ae:	f852                	sd	s4,48(sp)
 5b0:	f456                	sd	s5,40(sp)
 5b2:	f05a                	sd	s6,32(sp)
 5b4:	ec5e                	sd	s7,24(sp)
 5b6:	e862                	sd	s8,16(sp)
 5b8:	e466                	sd	s9,8(sp)
 5ba:	8b2a                	mv	s6,a0
 5bc:	8a2e                	mv	s4,a1
 5be:	8bb2                	mv	s7,a2
  state = 0;
 5c0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5c2:	4481                	li	s1,0
 5c4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5c6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5ca:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5ce:	06c00c93          	li	s9,108
 5d2:	a005                	j	5f2 <vprintf+0x5a>
        putc(fd, c0);
 5d4:	85ca                	mv	a1,s2
 5d6:	855a                	mv	a0,s6
 5d8:	f07ff0ef          	jal	4de <putc>
 5dc:	a019                	j	5e2 <vprintf+0x4a>
    } else if(state == '%'){
 5de:	03598263          	beq	s3,s5,602 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5e2:	2485                	addiw	s1,s1,1
 5e4:	8726                	mv	a4,s1
 5e6:	009a07b3          	add	a5,s4,s1
 5ea:	0007c903          	lbu	s2,0(a5)
 5ee:	22090a63          	beqz	s2,822 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5f2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5f6:	fe0994e3          	bnez	s3,5de <vprintf+0x46>
      if(c0 == '%'){
 5fa:	fd579de3          	bne	a5,s5,5d4 <vprintf+0x3c>
        state = '%';
 5fe:	89be                	mv	s3,a5
 600:	b7cd                	j	5e2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 602:	00ea06b3          	add	a3,s4,a4
 606:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 60a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 60c:	c681                	beqz	a3,614 <vprintf+0x7c>
 60e:	9752                	add	a4,a4,s4
 610:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 614:	05878363          	beq	a5,s8,65a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 618:	05978d63          	beq	a5,s9,672 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 61c:	07500713          	li	a4,117
 620:	0ee78763          	beq	a5,a4,70e <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 624:	07800713          	li	a4,120
 628:	12e78963          	beq	a5,a4,75a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 62c:	07000713          	li	a4,112
 630:	14e78e63          	beq	a5,a4,78c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 634:	06300713          	li	a4,99
 638:	18e78e63          	beq	a5,a4,7d4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 63c:	07300713          	li	a4,115
 640:	1ae78463          	beq	a5,a4,7e8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 644:	02500713          	li	a4,37
 648:	04e79563          	bne	a5,a4,692 <vprintf+0xfa>
        putc(fd, '%');
 64c:	02500593          	li	a1,37
 650:	855a                	mv	a0,s6
 652:	e8dff0ef          	jal	4de <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 656:	4981                	li	s3,0
 658:	b769                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4685                	li	a3,1
 660:	4629                	li	a2,10
 662:	000ba583          	lw	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	e95ff0ef          	jal	4fc <printint>
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
 670:	bf8d                	j	5e2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 672:	06400793          	li	a5,100
 676:	02f68963          	beq	a3,a5,6a8 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 67a:	06c00793          	li	a5,108
 67e:	04f68263          	beq	a3,a5,6c2 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 682:	07500793          	li	a5,117
 686:	0af68063          	beq	a3,a5,726 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 68a:	07800793          	li	a5,120
 68e:	0ef68263          	beq	a3,a5,772 <vprintf+0x1da>
        putc(fd, '%');
 692:	02500593          	li	a1,37
 696:	855a                	mv	a0,s6
 698:	e47ff0ef          	jal	4de <putc>
        putc(fd, c0);
 69c:	85ca                	mv	a1,s2
 69e:	855a                	mv	a0,s6
 6a0:	e3fff0ef          	jal	4de <putc>
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bf35                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	4685                	li	a3,1
 6ae:	4629                	li	a2,10
 6b0:	000bb583          	ld	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	e47ff0ef          	jal	4fc <printint>
        i += 1;
 6ba:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
        i += 1;
 6c0:	b70d                	j	5e2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6c2:	06400793          	li	a5,100
 6c6:	02f60763          	beq	a2,a5,6f4 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6ca:	07500793          	li	a5,117
 6ce:	06f60963          	beq	a2,a5,740 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6d2:	07800793          	li	a5,120
 6d6:	faf61ee3          	bne	a2,a5,692 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4681                	li	a3,0
 6e0:	4641                	li	a2,16
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	e15ff0ef          	jal	4fc <printint>
        i += 2;
 6ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 2;
 6f2:	bdc5                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4685                	li	a3,1
 6fa:	4629                	li	a2,10
 6fc:	000bb583          	ld	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	dfbff0ef          	jal	4fc <printint>
        i += 2;
 706:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 708:	8bca                	mv	s7,s2
      state = 0;
 70a:	4981                	li	s3,0
        i += 2;
 70c:	bdd9                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 70e:	008b8913          	addi	s2,s7,8
 712:	4681                	li	a3,0
 714:	4629                	li	a2,10
 716:	000be583          	lwu	a1,0(s7)
 71a:	855a                	mv	a0,s6
 71c:	de1ff0ef          	jal	4fc <printint>
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	bd7d                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4629                	li	a2,10
 72e:	000bb583          	ld	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	dc9ff0ef          	jal	4fc <printint>
        i += 1;
 738:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
        i += 1;
 73e:	b555                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 740:	008b8913          	addi	s2,s7,8
 744:	4681                	li	a3,0
 746:	4629                	li	a2,10
 748:	000bb583          	ld	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	dafff0ef          	jal	4fc <printint>
        i += 2;
 752:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 754:	8bca                	mv	s7,s2
      state = 0;
 756:	4981                	li	s3,0
        i += 2;
 758:	b569                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 75a:	008b8913          	addi	s2,s7,8
 75e:	4681                	li	a3,0
 760:	4641                	li	a2,16
 762:	000be583          	lwu	a1,0(s7)
 766:	855a                	mv	a0,s6
 768:	d95ff0ef          	jal	4fc <printint>
 76c:	8bca                	mv	s7,s2
      state = 0;
 76e:	4981                	li	s3,0
 770:	bd8d                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 772:	008b8913          	addi	s2,s7,8
 776:	4681                	li	a3,0
 778:	4641                	li	a2,16
 77a:	000bb583          	ld	a1,0(s7)
 77e:	855a                	mv	a0,s6
 780:	d7dff0ef          	jal	4fc <printint>
        i += 1;
 784:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 786:	8bca                	mv	s7,s2
      state = 0;
 788:	4981                	li	s3,0
        i += 1;
 78a:	bda1                	j	5e2 <vprintf+0x4a>
 78c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 78e:	008b8d13          	addi	s10,s7,8
 792:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 796:	03000593          	li	a1,48
 79a:	855a                	mv	a0,s6
 79c:	d43ff0ef          	jal	4de <putc>
  putc(fd, 'x');
 7a0:	07800593          	li	a1,120
 7a4:	855a                	mv	a0,s6
 7a6:	d39ff0ef          	jal	4de <putc>
 7aa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ac:	00000b97          	auipc	s7,0x0
 7b0:	3acb8b93          	addi	s7,s7,940 # b58 <digits>
 7b4:	03c9d793          	srli	a5,s3,0x3c
 7b8:	97de                	add	a5,a5,s7
 7ba:	0007c583          	lbu	a1,0(a5)
 7be:	855a                	mv	a0,s6
 7c0:	d1fff0ef          	jal	4de <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7c4:	0992                	slli	s3,s3,0x4
 7c6:	397d                	addiw	s2,s2,-1
 7c8:	fe0916e3          	bnez	s2,7b4 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7cc:	8bea                	mv	s7,s10
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	6d02                	ld	s10,0(sp)
 7d2:	bd01                	j	5e2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7d4:	008b8913          	addi	s2,s7,8
 7d8:	000bc583          	lbu	a1,0(s7)
 7dc:	855a                	mv	a0,s6
 7de:	d01ff0ef          	jal	4de <putc>
 7e2:	8bca                	mv	s7,s2
      state = 0;
 7e4:	4981                	li	s3,0
 7e6:	bbf5                	j	5e2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7e8:	008b8993          	addi	s3,s7,8
 7ec:	000bb903          	ld	s2,0(s7)
 7f0:	00090f63          	beqz	s2,80e <vprintf+0x276>
        for(; *s; s++)
 7f4:	00094583          	lbu	a1,0(s2)
 7f8:	c195                	beqz	a1,81c <vprintf+0x284>
          putc(fd, *s);
 7fa:	855a                	mv	a0,s6
 7fc:	ce3ff0ef          	jal	4de <putc>
        for(; *s; s++)
 800:	0905                	addi	s2,s2,1
 802:	00094583          	lbu	a1,0(s2)
 806:	f9f5                	bnez	a1,7fa <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 808:	8bce                	mv	s7,s3
      state = 0;
 80a:	4981                	li	s3,0
 80c:	bbd9                	j	5e2 <vprintf+0x4a>
          s = "(null)";
 80e:	00000917          	auipc	s2,0x0
 812:	30290913          	addi	s2,s2,770 # b10 <malloc+0x1f6>
        for(; *s; s++)
 816:	02800593          	li	a1,40
 81a:	b7c5                	j	7fa <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 81c:	8bce                	mv	s7,s3
      state = 0;
 81e:	4981                	li	s3,0
 820:	b3c9                	j	5e2 <vprintf+0x4a>
 822:	64a6                	ld	s1,72(sp)
 824:	79e2                	ld	s3,56(sp)
 826:	7a42                	ld	s4,48(sp)
 828:	7aa2                	ld	s5,40(sp)
 82a:	7b02                	ld	s6,32(sp)
 82c:	6be2                	ld	s7,24(sp)
 82e:	6c42                	ld	s8,16(sp)
 830:	6ca2                	ld	s9,8(sp)
    }
  }
}
 832:	60e6                	ld	ra,88(sp)
 834:	6446                	ld	s0,80(sp)
 836:	6906                	ld	s2,64(sp)
 838:	6125                	addi	sp,sp,96
 83a:	8082                	ret

000000000000083c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 83c:	715d                	addi	sp,sp,-80
 83e:	ec06                	sd	ra,24(sp)
 840:	e822                	sd	s0,16(sp)
 842:	1000                	addi	s0,sp,32
 844:	e010                	sd	a2,0(s0)
 846:	e414                	sd	a3,8(s0)
 848:	e818                	sd	a4,16(s0)
 84a:	ec1c                	sd	a5,24(s0)
 84c:	03043023          	sd	a6,32(s0)
 850:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 854:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 858:	8622                	mv	a2,s0
 85a:	d3fff0ef          	jal	598 <vprintf>
}
 85e:	60e2                	ld	ra,24(sp)
 860:	6442                	ld	s0,16(sp)
 862:	6161                	addi	sp,sp,80
 864:	8082                	ret

0000000000000866 <printf>:

void
printf(const char *fmt, ...)
{
 866:	711d                	addi	sp,sp,-96
 868:	ec06                	sd	ra,24(sp)
 86a:	e822                	sd	s0,16(sp)
 86c:	1000                	addi	s0,sp,32
 86e:	e40c                	sd	a1,8(s0)
 870:	e810                	sd	a2,16(s0)
 872:	ec14                	sd	a3,24(s0)
 874:	f018                	sd	a4,32(s0)
 876:	f41c                	sd	a5,40(s0)
 878:	03043823          	sd	a6,48(s0)
 87c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 880:	00840613          	addi	a2,s0,8
 884:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 888:	85aa                	mv	a1,a0
 88a:	4505                	li	a0,1
 88c:	d0dff0ef          	jal	598 <vprintf>
}
 890:	60e2                	ld	ra,24(sp)
 892:	6442                	ld	s0,16(sp)
 894:	6125                	addi	sp,sp,96
 896:	8082                	ret

0000000000000898 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 898:	1141                	addi	sp,sp,-16
 89a:	e422                	sd	s0,8(sp)
 89c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 89e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a2:	00000797          	auipc	a5,0x0
 8a6:	75e7b783          	ld	a5,1886(a5) # 1000 <freep>
 8aa:	a02d                	j	8d4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8ac:	4618                	lw	a4,8(a2)
 8ae:	9f2d                	addw	a4,a4,a1
 8b0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8b4:	6398                	ld	a4,0(a5)
 8b6:	6310                	ld	a2,0(a4)
 8b8:	a83d                	j	8f6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ba:	ff852703          	lw	a4,-8(a0)
 8be:	9f31                	addw	a4,a4,a2
 8c0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8c2:	ff053683          	ld	a3,-16(a0)
 8c6:	a091                	j	90a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c8:	6398                	ld	a4,0(a5)
 8ca:	00e7e463          	bltu	a5,a4,8d2 <free+0x3a>
 8ce:	00e6ea63          	bltu	a3,a4,8e2 <free+0x4a>
{
 8d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d4:	fed7fae3          	bgeu	a5,a3,8c8 <free+0x30>
 8d8:	6398                	ld	a4,0(a5)
 8da:	00e6e463          	bltu	a3,a4,8e2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8de:	fee7eae3          	bltu	a5,a4,8d2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8e2:	ff852583          	lw	a1,-8(a0)
 8e6:	6390                	ld	a2,0(a5)
 8e8:	02059813          	slli	a6,a1,0x20
 8ec:	01c85713          	srli	a4,a6,0x1c
 8f0:	9736                	add	a4,a4,a3
 8f2:	fae60de3          	beq	a2,a4,8ac <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8fa:	4790                	lw	a2,8(a5)
 8fc:	02061593          	slli	a1,a2,0x20
 900:	01c5d713          	srli	a4,a1,0x1c
 904:	973e                	add	a4,a4,a5
 906:	fae68ae3          	beq	a3,a4,8ba <free+0x22>
    p->s.ptr = bp->s.ptr;
 90a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 90c:	00000717          	auipc	a4,0x0
 910:	6ef73a23          	sd	a5,1780(a4) # 1000 <freep>
}
 914:	6422                	ld	s0,8(sp)
 916:	0141                	addi	sp,sp,16
 918:	8082                	ret

000000000000091a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 91a:	7139                	addi	sp,sp,-64
 91c:	fc06                	sd	ra,56(sp)
 91e:	f822                	sd	s0,48(sp)
 920:	f426                	sd	s1,40(sp)
 922:	ec4e                	sd	s3,24(sp)
 924:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 926:	02051493          	slli	s1,a0,0x20
 92a:	9081                	srli	s1,s1,0x20
 92c:	04bd                	addi	s1,s1,15
 92e:	8091                	srli	s1,s1,0x4
 930:	0014899b          	addiw	s3,s1,1
 934:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 936:	00000517          	auipc	a0,0x0
 93a:	6ca53503          	ld	a0,1738(a0) # 1000 <freep>
 93e:	c915                	beqz	a0,972 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 940:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 942:	4798                	lw	a4,8(a5)
 944:	08977a63          	bgeu	a4,s1,9d8 <malloc+0xbe>
 948:	f04a                	sd	s2,32(sp)
 94a:	e852                	sd	s4,16(sp)
 94c:	e456                	sd	s5,8(sp)
 94e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 950:	8a4e                	mv	s4,s3
 952:	0009871b          	sext.w	a4,s3
 956:	6685                	lui	a3,0x1
 958:	00d77363          	bgeu	a4,a3,95e <malloc+0x44>
 95c:	6a05                	lui	s4,0x1
 95e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 962:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 966:	00000917          	auipc	s2,0x0
 96a:	69a90913          	addi	s2,s2,1690 # 1000 <freep>
  if(p == SBRK_ERROR)
 96e:	5afd                	li	s5,-1
 970:	a081                	j	9b0 <malloc+0x96>
 972:	f04a                	sd	s2,32(sp)
 974:	e852                	sd	s4,16(sp)
 976:	e456                	sd	s5,8(sp)
 978:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 97a:	00000797          	auipc	a5,0x0
 97e:	69678793          	addi	a5,a5,1686 # 1010 <base>
 982:	00000717          	auipc	a4,0x0
 986:	66f73f23          	sd	a5,1662(a4) # 1000 <freep>
 98a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 98c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 990:	b7c1                	j	950 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 992:	6398                	ld	a4,0(a5)
 994:	e118                	sd	a4,0(a0)
 996:	a8a9                	j	9f0 <malloc+0xd6>
  hp->s.size = nu;
 998:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 99c:	0541                	addi	a0,a0,16
 99e:	efbff0ef          	jal	898 <free>
  return freep;
 9a2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a6:	c12d                	beqz	a0,a08 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9aa:	4798                	lw	a4,8(a5)
 9ac:	02977263          	bgeu	a4,s1,9d0 <malloc+0xb6>
    if(p == freep)
 9b0:	00093703          	ld	a4,0(s2)
 9b4:	853e                	mv	a0,a5
 9b6:	fef719e3          	bne	a4,a5,9a8 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9ba:	8552                	mv	a0,s4
 9bc:	a1fff0ef          	jal	3da <sbrk>
  if(p == SBRK_ERROR)
 9c0:	fd551ce3          	bne	a0,s5,998 <malloc+0x7e>
        return 0;
 9c4:	4501                	li	a0,0
 9c6:	7902                	ld	s2,32(sp)
 9c8:	6a42                	ld	s4,16(sp)
 9ca:	6aa2                	ld	s5,8(sp)
 9cc:	6b02                	ld	s6,0(sp)
 9ce:	a03d                	j	9fc <malloc+0xe2>
 9d0:	7902                	ld	s2,32(sp)
 9d2:	6a42                	ld	s4,16(sp)
 9d4:	6aa2                	ld	s5,8(sp)
 9d6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9d8:	fae48de3          	beq	s1,a4,992 <malloc+0x78>
        p->s.size -= nunits;
 9dc:	4137073b          	subw	a4,a4,s3
 9e0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9e2:	02071693          	slli	a3,a4,0x20
 9e6:	01c6d713          	srli	a4,a3,0x1c
 9ea:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9ec:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9f0:	00000717          	auipc	a4,0x0
 9f4:	60a73823          	sd	a0,1552(a4) # 1000 <freep>
      return (void*)(p + 1);
 9f8:	01078513          	addi	a0,a5,16
  }
}
 9fc:	70e2                	ld	ra,56(sp)
 9fe:	7442                	ld	s0,48(sp)
 a00:	74a2                	ld	s1,40(sp)
 a02:	69e2                	ld	s3,24(sp)
 a04:	6121                	addi	sp,sp,64
 a06:	8082                	ret
 a08:	7902                	ld	s2,32(sp)
 a0a:	6a42                	ld	s4,16(sp)
 a0c:	6aa2                	ld	s5,8(sp)
 a0e:	6b02                	ld	s6,0(sp)
 a10:	b7f5                	j	9fc <malloc+0xe2>
