
user/_memcat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  }
}

int
main(void)
{
   0:	8d010113          	addi	sp,sp,-1840
   4:	72113423          	sd	ra,1832(sp)
   8:	72813023          	sd	s0,1824(sp)
   c:	70913c23          	sd	s1,1816(sp)
  10:	71213823          	sd	s2,1808(sp)
  14:	71313423          	sd	s3,1800(sp)
  18:	71413023          	sd	s4,1792(sp)
  1c:	6f513c23          	sd	s5,1784(sp)
  20:	6f613823          	sd	s6,1776(sp)
  24:	6f713423          	sd	s7,1768(sp)
  28:	6f813023          	sd	s8,1760(sp)
  2c:	6d913c23          	sd	s9,1752(sp)
  30:	6da13823          	sd	s10,1744(sp)
  34:	6db13423          	sd	s11,1736(sp)
  38:	73010413          	addi	s0,sp,1840
    default:         return "UNKNOWN";
  3c:	00001b97          	auipc	s7,0x1
  40:	ac4b8b93          	addi	s7,s7,-1340 # b00 <malloc+0x144>
  switch(t){
  44:	00001a97          	auipc	s5,0x1
  48:	bd4a8a93          	addi	s5,s5,-1068 # c18 <malloc+0x25c>
  4c:	00001d17          	auipc	s10,0x1
  50:	a84d0d13          	addi	s10,s10,-1404 # ad0 <malloc+0x114>
    case MEM_FREE:   return "FREE";
  54:	00001d97          	auipc	s11,0x1
  58:	aa4d8d93          	addi	s11,s11,-1372 # af8 <malloc+0x13c>
  struct mem_event ev[16];
  int n, i;

  for(;;){
    n = memread(ev, 16);
  5c:	45c1                	li	a1,16
  5e:	91040513          	addi	a0,s0,-1776
  62:	516000ef          	jal	578 <memread>
  66:	8b2a                	mv	s6,a0
    if(n <= 0)
  68:	1aa05763          	blez	a0,216 <main+0x216>
  6c:	92c40493          	addi	s1,s0,-1748
      break;

    for(i = 0; i < n; i++){
  70:	4981                	li	s3,0
  switch(t){
  72:	4a1d                	li	s4,7
    case MEM_ALLOC:  return "ALLOC";
  74:	00001c97          	auipc	s9,0x1
  78:	a7cc8c93          	addi	s9,s9,-1412 # af0 <malloc+0x134>
    case MEM_UNMAP:  return "UNMAP";
  7c:	00001c17          	auipc	s8,0x1
  80:	a6cc0c13          	addi	s8,s8,-1428 # ae8 <malloc+0x12c>
  if(perm & (1 << 1)) buf[i++] = 'R';
  84:	00001917          	auipc	s2,0x1
  88:	f7c90913          	addi	s2,s2,-132 # 1000 <buf.0>
  8c:	aa21                	j	1a4 <main+0x1a4>
    case MEM_GROW:   return "GROW";
  8e:	00001817          	auipc	a6,0x1
  92:	a3280813          	addi	a6,a6,-1486 # ac0 <malloc+0x104>
  switch(s){
  96:	41a8                	lw	a0,64(a1)
  98:	16aa6863          	bltu	s4,a0,208 <main+0x208>
  9c:	0405e503          	lwu	a0,64(a1)
  a0:	050a                	slli	a0,a0,0x2
  a2:	00001897          	auipc	a7,0x1
  a6:	b5688893          	addi	a7,a7,-1194 # bf8 <malloc+0x23c>
  aa:	9546                	add	a0,a0,a7
  ac:	4108                	lw	a0,0(a0)
  ae:	9546                	add	a0,a0,a7
  b0:	8502                	jr	a0
    case MEM_FAULT:  return "FAULT";
  b2:	00001817          	auipc	a6,0x1
  b6:	a2680813          	addi	a6,a6,-1498 # ad8 <malloc+0x11c>
  ba:	bff1                	j	96 <main+0x96>
    case MEM_MAP:    return "MAP";
  bc:	00001817          	auipc	a6,0x1
  c0:	a2480813          	addi	a6,a6,-1500 # ae0 <malloc+0x124>
  c4:	bfc9                	j	96 <main+0x96>
    case MEM_UNMAP:  return "UNMAP";
  c6:	8862                	mv	a6,s8
  c8:	b7f9                	j	96 <main+0x96>
    case MEM_ALLOC:  return "ALLOC";
  ca:	8866                	mv	a6,s9
  cc:	b7e9                	j	96 <main+0x96>
    case MEM_FREE:   return "FREE";
  ce:	886e                	mv	a6,s11
  d0:	b7d9                	j	96 <main+0x96>
    default:         return "UNKNOWN";
  d2:	885e                	mv	a6,s7
  d4:	b7c9                	j	96 <main+0x96>
  switch(t){
  d6:	886a                	mv	a6,s10
  d8:	bf7d                	j	96 <main+0x96>
    case SRC_NONE:       return "NONE";
  da:	00001897          	auipc	a7,0x1
  de:	a2e88893          	addi	a7,a7,-1490 # b08 <malloc+0x14c>
     
    
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s va=%p pa=%p perm=%s kind=%s name=%s old=%p new=%p\n",
  e2:	0145be03          	ld	t3,20(a1)
  e6:	01c5be83          	ld	t4,28(a1)
  ea:	03c5a303          	lw	t1,60(a1)
  if(perm & (1 << 1)) buf[i++] = 'R';
  ee:	00237513          	andi	a0,t1,2
  f2:	c511                	beqz	a0,fe <main+0xfe>
  f4:	05200513          	li	a0,82
  f8:	00a90023          	sb	a0,0(s2)
  fc:	4505                	li	a0,1
  if(perm & (1 << 2)) buf[i++] = 'W';
  fe:	00437f13          	andi	t5,t1,4
 102:	000f0963          	beqz	t5,114 <main+0x114>
 106:	00a90f33          	add	t5,s2,a0
 10a:	05700f93          	li	t6,87
 10e:	01ff0023          	sb	t6,0(t5)
 112:	2505                	addiw	a0,a0,1
  if(perm & (1 << 3)) buf[i++] = 'X';
 114:	00837f13          	andi	t5,t1,8
 118:	000f0963          	beqz	t5,12a <main+0x12a>
 11c:	00a90f33          	add	t5,s2,a0
 120:	05800f93          	li	t6,88
 124:	01ff0023          	sb	t6,0(t5)
 128:	2505                	addiw	a0,a0,1
  if(perm & (1 << 4)) buf[i++] = 'U';
 12a:	01037313          	andi	t1,t1,16
 12e:	00030963          	beqz	t1,140 <main+0x140>
 132:	00a90333          	add	t1,s2,a0
 136:	05500f13          	li	t5,85
 13a:	01e30023          	sb	t5,0(t1)
 13e:	2505                	addiw	a0,a0,1
  buf[i] = '\0';
 140:	954a                	add	a0,a0,s2
 142:	00050023          	sb	zero,0(a0)
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s va=%p pa=%p perm=%s kind=%s name=%s old=%p new=%p\n",
 146:	0445a303          	lw	t1,68(a1)
  switch(kind){
 14a:	4f09                	li	t5,2
 14c:	00001517          	auipc	a0,0x1
 150:	a2450513          	addi	a0,a0,-1500 # b70 <malloc+0x1b4>
 154:	03e30163          	beq	t1,t5,176 <main+0x176>
 158:	4f0d                	li	t5,3
    case PAGE_KERNEL:    return "KERNEL";
 15a:	00001517          	auipc	a0,0x1
 15e:	a2650513          	addi	a0,a0,-1498 # b80 <malloc+0x1c4>
  switch(kind){
 162:	01e30a63          	beq	t1,t5,176 <main+0x176>
 166:	4f05                	li	t5,1
    case PAGE_USER:      return "USER";
 168:	00001517          	auipc	a0,0x1
 16c:	a0050513          	addi	a0,a0,-1536 # b68 <malloc+0x1ac>
  switch(kind){
 170:	01e30363          	beq	t1,t5,176 <main+0x176>
    default:             return "UNKNOWN";
 174:	855e                	mv	a0,s7
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s va=%p pa=%p perm=%s kind=%s name=%s old=%p new=%p\n",
 176:	02c5b303          	ld	t1,44(a1)
 17a:	f81a                	sd	t1,48(sp)
 17c:	0245b303          	ld	t1,36(a1)
 180:	f41a                	sd	t1,40(sp)
 182:	f02e                	sd	a1,32(sp)
 184:	ec2a                	sd	a0,24(sp)
 186:	e84a                	sd	s2,16(sp)
 188:	e476                	sd	t4,8(sp)
 18a:	e072                	sd	t3,0(sp)
 18c:	85ce                	mv	a1,s3
 18e:	00001517          	auipc	a0,0x1
 192:	9fa50513          	addi	a0,a0,-1542 # b88 <malloc+0x1cc>
 196:	772000ef          	jal	908 <printf>
    for(i = 0; i < n; i++){
 19a:	2985                	addiw	s3,s3,1
 19c:	06848493          	addi	s1,s1,104
 1a0:	eb3b0ee3          	beq	s6,s3,5c <main+0x5c>
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s va=%p pa=%p perm=%s kind=%s name=%s old=%p new=%p\n",
 1a4:	85a6                	mv	a1,s1
 1a6:	fe44a603          	lw	a2,-28(s1)
 1aa:	fec4a683          	lw	a3,-20(s1)
 1ae:	ff04a703          	lw	a4,-16(s1)
 1b2:	ff84a783          	lw	a5,-8(s1)
  switch(t){
 1b6:	ff44a503          	lw	a0,-12(s1)
 1ba:	f0aa6ce3          	bltu	s4,a0,d2 <main+0xd2>
 1be:	ff44e503          	lwu	a0,-12(s1)
 1c2:	050a                	slli	a0,a0,0x2
 1c4:	9556                	add	a0,a0,s5
 1c6:	4108                	lw	a0,0(a0)
 1c8:	9556                	add	a0,a0,s5
 1ca:	8502                	jr	a0
    case SRC_KFREE:      return "KFREE";
 1cc:	00001897          	auipc	a7,0x1
 1d0:	94c88893          	addi	a7,a7,-1716 # b18 <malloc+0x15c>
 1d4:	b739                	j	e2 <main+0xe2>
    case SRC_MAPPAGES:   return "MAPPAGES";
 1d6:	00001897          	auipc	a7,0x1
 1da:	94a88893          	addi	a7,a7,-1718 # b20 <malloc+0x164>
 1de:	b711                	j	e2 <main+0xe2>
    case SRC_UVMUNMAP:   return "UVMUNMAP";
 1e0:	00001897          	auipc	a7,0x1
 1e4:	95088893          	addi	a7,a7,-1712 # b30 <malloc+0x174>
 1e8:	bded                	j	e2 <main+0xe2>
    case SRC_UVMALLOC:   return "UVMALLOC";
 1ea:	00001897          	auipc	a7,0x1
 1ee:	95688893          	addi	a7,a7,-1706 # b40 <malloc+0x184>
 1f2:	bdc5                	j	e2 <main+0xe2>
    case SRC_UVMDEALLOC: return "UVMDEALLOC";
 1f4:	00001897          	auipc	a7,0x1
 1f8:	95c88893          	addi	a7,a7,-1700 # b50 <malloc+0x194>
 1fc:	b5dd                	j	e2 <main+0xe2>
    case SRC_VMFAULT:    return "VMFAULT";
 1fe:	00001897          	auipc	a7,0x1
 202:	96288893          	addi	a7,a7,-1694 # b60 <malloc+0x1a4>
 206:	bdf1                	j	e2 <main+0xe2>
    default:             return "UNKNOWN";
 208:	88de                	mv	a7,s7
 20a:	bde1                	j	e2 <main+0xe2>
  switch(s){
 20c:	00001897          	auipc	a7,0x1
 210:	90488893          	addi	a7,a7,-1788 # b10 <malloc+0x154>
 214:	b5f9                	j	e2 <main+0xe2>
    }
  }

 

  exit(0);
 216:	4501                	li	a0,0
 218:	298000ef          	jal	4b0 <exit>

000000000000021c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e406                	sd	ra,8(sp)
 220:	e022                	sd	s0,0(sp)
 222:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 224:	dddff0ef          	jal	0 <main>
  exit(r);
 228:	288000ef          	jal	4b0 <exit>

000000000000022c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 232:	87aa                	mv	a5,a0
 234:	0585                	addi	a1,a1,1
 236:	0785                	addi	a5,a5,1
 238:	fff5c703          	lbu	a4,-1(a1)
 23c:	fee78fa3          	sb	a4,-1(a5)
 240:	fb75                	bnez	a4,234 <strcpy+0x8>
    ;
  return os;
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret

0000000000000248 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 24e:	00054783          	lbu	a5,0(a0)
 252:	cb91                	beqz	a5,266 <strcmp+0x1e>
 254:	0005c703          	lbu	a4,0(a1)
 258:	00f71763          	bne	a4,a5,266 <strcmp+0x1e>
    p++, q++;
 25c:	0505                	addi	a0,a0,1
 25e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 260:	00054783          	lbu	a5,0(a0)
 264:	fbe5                	bnez	a5,254 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 266:	0005c503          	lbu	a0,0(a1)
}
 26a:	40a7853b          	subw	a0,a5,a0
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <strlen>:

uint
strlen(const char *s)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	cf91                	beqz	a5,29a <strlen+0x26>
 280:	0505                	addi	a0,a0,1
 282:	87aa                	mv	a5,a0
 284:	86be                	mv	a3,a5
 286:	0785                	addi	a5,a5,1
 288:	fff7c703          	lbu	a4,-1(a5)
 28c:	ff65                	bnez	a4,284 <strlen+0x10>
 28e:	40a6853b          	subw	a0,a3,a0
 292:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  for(n = 0; s[n]; n++)
 29a:	4501                	li	a0,0
 29c:	bfe5                	j	294 <strlen+0x20>

000000000000029e <memset>:

void*
memset(void *dst, int c, uint n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2a4:	ca19                	beqz	a2,2ba <memset+0x1c>
 2a6:	87aa                	mv	a5,a0
 2a8:	1602                	slli	a2,a2,0x20
 2aa:	9201                	srli	a2,a2,0x20
 2ac:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2b0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2b4:	0785                	addi	a5,a5,1
 2b6:	fee79de3          	bne	a5,a4,2b0 <memset+0x12>
  }
  return dst;
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <strchr>:

char*
strchr(const char *s, char c)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cb99                	beqz	a5,2e0 <strchr+0x20>
    if(*s == c)
 2cc:	00f58763          	beq	a1,a5,2da <strchr+0x1a>
  for(; *s; s++)
 2d0:	0505                	addi	a0,a0,1
 2d2:	00054783          	lbu	a5,0(a0)
 2d6:	fbfd                	bnez	a5,2cc <strchr+0xc>
      return (char*)s;
  return 0;
 2d8:	4501                	li	a0,0
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
  return 0;
 2e0:	4501                	li	a0,0
 2e2:	bfe5                	j	2da <strchr+0x1a>

00000000000002e4 <gets>:

char*
gets(char *buf, int max)
{
 2e4:	711d                	addi	sp,sp,-96
 2e6:	ec86                	sd	ra,88(sp)
 2e8:	e8a2                	sd	s0,80(sp)
 2ea:	e4a6                	sd	s1,72(sp)
 2ec:	e0ca                	sd	s2,64(sp)
 2ee:	fc4e                	sd	s3,56(sp)
 2f0:	f852                	sd	s4,48(sp)
 2f2:	f456                	sd	s5,40(sp)
 2f4:	f05a                	sd	s6,32(sp)
 2f6:	ec5e                	sd	s7,24(sp)
 2f8:	1080                	addi	s0,sp,96
 2fa:	8baa                	mv	s7,a0
 2fc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2fe:	892a                	mv	s2,a0
 300:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 302:	4aa9                	li	s5,10
 304:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 306:	89a6                	mv	s3,s1
 308:	2485                	addiw	s1,s1,1
 30a:	0344d663          	bge	s1,s4,336 <gets+0x52>
    cc = read(0, &c, 1);
 30e:	4605                	li	a2,1
 310:	faf40593          	addi	a1,s0,-81
 314:	4501                	li	a0,0
 316:	1b2000ef          	jal	4c8 <read>
    if(cc < 1)
 31a:	00a05e63          	blez	a0,336 <gets+0x52>
    buf[i++] = c;
 31e:	faf44783          	lbu	a5,-81(s0)
 322:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 326:	01578763          	beq	a5,s5,334 <gets+0x50>
 32a:	0905                	addi	s2,s2,1
 32c:	fd679de3          	bne	a5,s6,306 <gets+0x22>
    buf[i++] = c;
 330:	89a6                	mv	s3,s1
 332:	a011                	j	336 <gets+0x52>
 334:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 336:	99de                	add	s3,s3,s7
 338:	00098023          	sb	zero,0(s3)
  return buf;
}
 33c:	855e                	mv	a0,s7
 33e:	60e6                	ld	ra,88(sp)
 340:	6446                	ld	s0,80(sp)
 342:	64a6                	ld	s1,72(sp)
 344:	6906                	ld	s2,64(sp)
 346:	79e2                	ld	s3,56(sp)
 348:	7a42                	ld	s4,48(sp)
 34a:	7aa2                	ld	s5,40(sp)
 34c:	7b02                	ld	s6,32(sp)
 34e:	6be2                	ld	s7,24(sp)
 350:	6125                	addi	sp,sp,96
 352:	8082                	ret

0000000000000354 <stat>:

int
stat(const char *n, struct stat *st)
{
 354:	1101                	addi	sp,sp,-32
 356:	ec06                	sd	ra,24(sp)
 358:	e822                	sd	s0,16(sp)
 35a:	e04a                	sd	s2,0(sp)
 35c:	1000                	addi	s0,sp,32
 35e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 360:	4581                	li	a1,0
 362:	18e000ef          	jal	4f0 <open>
  if(fd < 0)
 366:	02054263          	bltz	a0,38a <stat+0x36>
 36a:	e426                	sd	s1,8(sp)
 36c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 36e:	85ca                	mv	a1,s2
 370:	198000ef          	jal	508 <fstat>
 374:	892a                	mv	s2,a0
  close(fd);
 376:	8526                	mv	a0,s1
 378:	160000ef          	jal	4d8 <close>
  return r;
 37c:	64a2                	ld	s1,8(sp)
}
 37e:	854a                	mv	a0,s2
 380:	60e2                	ld	ra,24(sp)
 382:	6442                	ld	s0,16(sp)
 384:	6902                	ld	s2,0(sp)
 386:	6105                	addi	sp,sp,32
 388:	8082                	ret
    return -1;
 38a:	597d                	li	s2,-1
 38c:	bfcd                	j	37e <stat+0x2a>

000000000000038e <atoi>:

int
atoi(const char *s)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 394:	00054683          	lbu	a3,0(a0)
 398:	fd06879b          	addiw	a5,a3,-48
 39c:	0ff7f793          	zext.b	a5,a5
 3a0:	4625                	li	a2,9
 3a2:	02f66863          	bltu	a2,a5,3d2 <atoi+0x44>
 3a6:	872a                	mv	a4,a0
  n = 0;
 3a8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3aa:	0705                	addi	a4,a4,1
 3ac:	0025179b          	slliw	a5,a0,0x2
 3b0:	9fa9                	addw	a5,a5,a0
 3b2:	0017979b          	slliw	a5,a5,0x1
 3b6:	9fb5                	addw	a5,a5,a3
 3b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3bc:	00074683          	lbu	a3,0(a4)
 3c0:	fd06879b          	addiw	a5,a3,-48
 3c4:	0ff7f793          	zext.b	a5,a5
 3c8:	fef671e3          	bgeu	a2,a5,3aa <atoi+0x1c>
  return n;
}
 3cc:	6422                	ld	s0,8(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret
  n = 0;
 3d2:	4501                	li	a0,0
 3d4:	bfe5                	j	3cc <atoi+0x3e>

00000000000003d6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e422                	sd	s0,8(sp)
 3da:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3dc:	02b57463          	bgeu	a0,a1,404 <memmove+0x2e>
    while(n-- > 0)
 3e0:	00c05f63          	blez	a2,3fe <memmove+0x28>
 3e4:	1602                	slli	a2,a2,0x20
 3e6:	9201                	srli	a2,a2,0x20
 3e8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ec:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ee:	0585                	addi	a1,a1,1
 3f0:	0705                	addi	a4,a4,1
 3f2:	fff5c683          	lbu	a3,-1(a1)
 3f6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3fa:	fef71ae3          	bne	a4,a5,3ee <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3fe:	6422                	ld	s0,8(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret
    dst += n;
 404:	00c50733          	add	a4,a0,a2
    src += n;
 408:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 40a:	fec05ae3          	blez	a2,3fe <memmove+0x28>
 40e:	fff6079b          	addiw	a5,a2,-1
 412:	1782                	slli	a5,a5,0x20
 414:	9381                	srli	a5,a5,0x20
 416:	fff7c793          	not	a5,a5
 41a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 41c:	15fd                	addi	a1,a1,-1
 41e:	177d                	addi	a4,a4,-1
 420:	0005c683          	lbu	a3,0(a1)
 424:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 428:	fee79ae3          	bne	a5,a4,41c <memmove+0x46>
 42c:	bfc9                	j	3fe <memmove+0x28>

000000000000042e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 42e:	1141                	addi	sp,sp,-16
 430:	e422                	sd	s0,8(sp)
 432:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 434:	ca05                	beqz	a2,464 <memcmp+0x36>
 436:	fff6069b          	addiw	a3,a2,-1
 43a:	1682                	slli	a3,a3,0x20
 43c:	9281                	srli	a3,a3,0x20
 43e:	0685                	addi	a3,a3,1
 440:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 442:	00054783          	lbu	a5,0(a0)
 446:	0005c703          	lbu	a4,0(a1)
 44a:	00e79863          	bne	a5,a4,45a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 44e:	0505                	addi	a0,a0,1
    p2++;
 450:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 452:	fed518e3          	bne	a0,a3,442 <memcmp+0x14>
  }
  return 0;
 456:	4501                	li	a0,0
 458:	a019                	j	45e <memcmp+0x30>
      return *p1 - *p2;
 45a:	40e7853b          	subw	a0,a5,a4
}
 45e:	6422                	ld	s0,8(sp)
 460:	0141                	addi	sp,sp,16
 462:	8082                	ret
  return 0;
 464:	4501                	li	a0,0
 466:	bfe5                	j	45e <memcmp+0x30>

0000000000000468 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 468:	1141                	addi	sp,sp,-16
 46a:	e406                	sd	ra,8(sp)
 46c:	e022                	sd	s0,0(sp)
 46e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 470:	f67ff0ef          	jal	3d6 <memmove>
}
 474:	60a2                	ld	ra,8(sp)
 476:	6402                	ld	s0,0(sp)
 478:	0141                	addi	sp,sp,16
 47a:	8082                	ret

000000000000047c <sbrk>:

char *
sbrk(int n) {
 47c:	1141                	addi	sp,sp,-16
 47e:	e406                	sd	ra,8(sp)
 480:	e022                	sd	s0,0(sp)
 482:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 484:	4585                	li	a1,1
 486:	0c2000ef          	jal	548 <sys_sbrk>
}
 48a:	60a2                	ld	ra,8(sp)
 48c:	6402                	ld	s0,0(sp)
 48e:	0141                	addi	sp,sp,16
 490:	8082                	ret

0000000000000492 <sbrklazy>:

char *
sbrklazy(int n) {
 492:	1141                	addi	sp,sp,-16
 494:	e406                	sd	ra,8(sp)
 496:	e022                	sd	s0,0(sp)
 498:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 49a:	4589                	li	a1,2
 49c:	0ac000ef          	jal	548 <sys_sbrk>
}
 4a0:	60a2                	ld	ra,8(sp)
 4a2:	6402                	ld	s0,0(sp)
 4a4:	0141                	addi	sp,sp,16
 4a6:	8082                	ret

00000000000004a8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a8:	4885                	li	a7,1
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4b0:	4889                	li	a7,2
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b8:	488d                	li	a7,3
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4c0:	4891                	li	a7,4
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <read>:
.global read
read:
 li a7, SYS_read
 4c8:	4895                	li	a7,5
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <write>:
.global write
write:
 li a7, SYS_write
 4d0:	48c1                	li	a7,16
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <close>:
.global close
close:
 li a7, SYS_close
 4d8:	48d5                	li	a7,21
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4e0:	4899                	li	a7,6
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e8:	489d                	li	a7,7
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <open>:
.global open
open:
 li a7, SYS_open
 4f0:	48bd                	li	a7,15
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f8:	48c5                	li	a7,17
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 500:	48c9                	li	a7,18
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 508:	48a1                	li	a7,8
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <link>:
.global link
link:
 li a7, SYS_link
 510:	48cd                	li	a7,19
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 518:	48d1                	li	a7,20
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 520:	48a5                	li	a7,9
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <dup>:
.global dup
dup:
 li a7, SYS_dup
 528:	48a9                	li	a7,10
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 530:	48ad                	li	a7,11
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 538:	48e9                	li	a7,26
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 540:	48ed                	li	a7,27
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 548:	48b1                	li	a7,12
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <pause>:
.global pause
pause:
 li a7, SYS_pause
 550:	48b5                	li	a7,13
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 558:	48b9                	li	a7,14
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <csread>:
.global csread
csread:
 li a7, SYS_csread
 560:	48d9                	li	a7,22
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 568:	48dd                	li	a7,23
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 570:	48e1                	li	a7,24
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <memread>:
.global memread
memread:
 li a7, SYS_memread
 578:	48e5                	li	a7,25
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 580:	1101                	addi	sp,sp,-32
 582:	ec06                	sd	ra,24(sp)
 584:	e822                	sd	s0,16(sp)
 586:	1000                	addi	s0,sp,32
 588:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 58c:	4605                	li	a2,1
 58e:	fef40593          	addi	a1,s0,-17
 592:	f3fff0ef          	jal	4d0 <write>
}
 596:	60e2                	ld	ra,24(sp)
 598:	6442                	ld	s0,16(sp)
 59a:	6105                	addi	sp,sp,32
 59c:	8082                	ret

000000000000059e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 59e:	715d                	addi	sp,sp,-80
 5a0:	e486                	sd	ra,72(sp)
 5a2:	e0a2                	sd	s0,64(sp)
 5a4:	f84a                	sd	s2,48(sp)
 5a6:	0880                	addi	s0,sp,80
 5a8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5aa:	c299                	beqz	a3,5b0 <printint+0x12>
 5ac:	0805c363          	bltz	a1,632 <printint+0x94>
  neg = 0;
 5b0:	4881                	li	a7,0
 5b2:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5b6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5b8:	00000517          	auipc	a0,0x0
 5bc:	68050513          	addi	a0,a0,1664 # c38 <digits>
 5c0:	883e                	mv	a6,a5
 5c2:	2785                	addiw	a5,a5,1
 5c4:	02c5f733          	remu	a4,a1,a2
 5c8:	972a                	add	a4,a4,a0
 5ca:	00074703          	lbu	a4,0(a4)
 5ce:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5d2:	872e                	mv	a4,a1
 5d4:	02c5d5b3          	divu	a1,a1,a2
 5d8:	0685                	addi	a3,a3,1
 5da:	fec773e3          	bgeu	a4,a2,5c0 <printint+0x22>
  if(neg)
 5de:	00088b63          	beqz	a7,5f4 <printint+0x56>
    buf[i++] = '-';
 5e2:	fd078793          	addi	a5,a5,-48
 5e6:	97a2                	add	a5,a5,s0
 5e8:	02d00713          	li	a4,45
 5ec:	fee78423          	sb	a4,-24(a5)
 5f0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5f4:	02f05a63          	blez	a5,628 <printint+0x8a>
 5f8:	fc26                	sd	s1,56(sp)
 5fa:	f44e                	sd	s3,40(sp)
 5fc:	fb840713          	addi	a4,s0,-72
 600:	00f704b3          	add	s1,a4,a5
 604:	fff70993          	addi	s3,a4,-1
 608:	99be                	add	s3,s3,a5
 60a:	37fd                	addiw	a5,a5,-1
 60c:	1782                	slli	a5,a5,0x20
 60e:	9381                	srli	a5,a5,0x20
 610:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 614:	fff4c583          	lbu	a1,-1(s1)
 618:	854a                	mv	a0,s2
 61a:	f67ff0ef          	jal	580 <putc>
  while(--i >= 0)
 61e:	14fd                	addi	s1,s1,-1
 620:	ff349ae3          	bne	s1,s3,614 <printint+0x76>
 624:	74e2                	ld	s1,56(sp)
 626:	79a2                	ld	s3,40(sp)
}
 628:	60a6                	ld	ra,72(sp)
 62a:	6406                	ld	s0,64(sp)
 62c:	7942                	ld	s2,48(sp)
 62e:	6161                	addi	sp,sp,80
 630:	8082                	ret
    x = -xx;
 632:	40b005b3          	neg	a1,a1
    neg = 1;
 636:	4885                	li	a7,1
    x = -xx;
 638:	bfad                	j	5b2 <printint+0x14>

000000000000063a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 63a:	711d                	addi	sp,sp,-96
 63c:	ec86                	sd	ra,88(sp)
 63e:	e8a2                	sd	s0,80(sp)
 640:	e0ca                	sd	s2,64(sp)
 642:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 644:	0005c903          	lbu	s2,0(a1)
 648:	28090663          	beqz	s2,8d4 <vprintf+0x29a>
 64c:	e4a6                	sd	s1,72(sp)
 64e:	fc4e                	sd	s3,56(sp)
 650:	f852                	sd	s4,48(sp)
 652:	f456                	sd	s5,40(sp)
 654:	f05a                	sd	s6,32(sp)
 656:	ec5e                	sd	s7,24(sp)
 658:	e862                	sd	s8,16(sp)
 65a:	e466                	sd	s9,8(sp)
 65c:	8b2a                	mv	s6,a0
 65e:	8a2e                	mv	s4,a1
 660:	8bb2                	mv	s7,a2
  state = 0;
 662:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 664:	4481                	li	s1,0
 666:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 668:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 66c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 670:	06c00c93          	li	s9,108
 674:	a005                	j	694 <vprintf+0x5a>
        putc(fd, c0);
 676:	85ca                	mv	a1,s2
 678:	855a                	mv	a0,s6
 67a:	f07ff0ef          	jal	580 <putc>
 67e:	a019                	j	684 <vprintf+0x4a>
    } else if(state == '%'){
 680:	03598263          	beq	s3,s5,6a4 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 684:	2485                	addiw	s1,s1,1
 686:	8726                	mv	a4,s1
 688:	009a07b3          	add	a5,s4,s1
 68c:	0007c903          	lbu	s2,0(a5)
 690:	22090a63          	beqz	s2,8c4 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 694:	0009079b          	sext.w	a5,s2
    if(state == 0){
 698:	fe0994e3          	bnez	s3,680 <vprintf+0x46>
      if(c0 == '%'){
 69c:	fd579de3          	bne	a5,s5,676 <vprintf+0x3c>
        state = '%';
 6a0:	89be                	mv	s3,a5
 6a2:	b7cd                	j	684 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6a4:	00ea06b3          	add	a3,s4,a4
 6a8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6ac:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6ae:	c681                	beqz	a3,6b6 <vprintf+0x7c>
 6b0:	9752                	add	a4,a4,s4
 6b2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6b6:	05878363          	beq	a5,s8,6fc <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 6ba:	05978d63          	beq	a5,s9,714 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6be:	07500713          	li	a4,117
 6c2:	0ee78763          	beq	a5,a4,7b0 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6c6:	07800713          	li	a4,120
 6ca:	12e78963          	beq	a5,a4,7fc <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6ce:	07000713          	li	a4,112
 6d2:	14e78e63          	beq	a5,a4,82e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6d6:	06300713          	li	a4,99
 6da:	18e78e63          	beq	a5,a4,876 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6de:	07300713          	li	a4,115
 6e2:	1ae78463          	beq	a5,a4,88a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6e6:	02500713          	li	a4,37
 6ea:	04e79563          	bne	a5,a4,734 <vprintf+0xfa>
        putc(fd, '%');
 6ee:	02500593          	li	a1,37
 6f2:	855a                	mv	a0,s6
 6f4:	e8dff0ef          	jal	580 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b769                	j	684 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6fc:	008b8913          	addi	s2,s7,8
 700:	4685                	li	a3,1
 702:	4629                	li	a2,10
 704:	000ba583          	lw	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	e95ff0ef          	jal	59e <printint>
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
 712:	bf8d                	j	684 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 714:	06400793          	li	a5,100
 718:	02f68963          	beq	a3,a5,74a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 71c:	06c00793          	li	a5,108
 720:	04f68263          	beq	a3,a5,764 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 724:	07500793          	li	a5,117
 728:	0af68063          	beq	a3,a5,7c8 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 72c:	07800793          	li	a5,120
 730:	0ef68263          	beq	a3,a5,814 <vprintf+0x1da>
        putc(fd, '%');
 734:	02500593          	li	a1,37
 738:	855a                	mv	a0,s6
 73a:	e47ff0ef          	jal	580 <putc>
        putc(fd, c0);
 73e:	85ca                	mv	a1,s2
 740:	855a                	mv	a0,s6
 742:	e3fff0ef          	jal	580 <putc>
      state = 0;
 746:	4981                	li	s3,0
 748:	bf35                	j	684 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 74a:	008b8913          	addi	s2,s7,8
 74e:	4685                	li	a3,1
 750:	4629                	li	a2,10
 752:	000bb583          	ld	a1,0(s7)
 756:	855a                	mv	a0,s6
 758:	e47ff0ef          	jal	59e <printint>
        i += 1;
 75c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 75e:	8bca                	mv	s7,s2
      state = 0;
 760:	4981                	li	s3,0
        i += 1;
 762:	b70d                	j	684 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 764:	06400793          	li	a5,100
 768:	02f60763          	beq	a2,a5,796 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 76c:	07500793          	li	a5,117
 770:	06f60963          	beq	a2,a5,7e2 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 774:	07800793          	li	a5,120
 778:	faf61ee3          	bne	a2,a5,734 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 77c:	008b8913          	addi	s2,s7,8
 780:	4681                	li	a3,0
 782:	4641                	li	a2,16
 784:	000bb583          	ld	a1,0(s7)
 788:	855a                	mv	a0,s6
 78a:	e15ff0ef          	jal	59e <printint>
        i += 2;
 78e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 790:	8bca                	mv	s7,s2
      state = 0;
 792:	4981                	li	s3,0
        i += 2;
 794:	bdc5                	j	684 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 796:	008b8913          	addi	s2,s7,8
 79a:	4685                	li	a3,1
 79c:	4629                	li	a2,10
 79e:	000bb583          	ld	a1,0(s7)
 7a2:	855a                	mv	a0,s6
 7a4:	dfbff0ef          	jal	59e <printint>
        i += 2;
 7a8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7aa:	8bca                	mv	s7,s2
      state = 0;
 7ac:	4981                	li	s3,0
        i += 2;
 7ae:	bdd9                	j	684 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7b0:	008b8913          	addi	s2,s7,8
 7b4:	4681                	li	a3,0
 7b6:	4629                	li	a2,10
 7b8:	000be583          	lwu	a1,0(s7)
 7bc:	855a                	mv	a0,s6
 7be:	de1ff0ef          	jal	59e <printint>
 7c2:	8bca                	mv	s7,s2
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	bd7d                	j	684 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c8:	008b8913          	addi	s2,s7,8
 7cc:	4681                	li	a3,0
 7ce:	4629                	li	a2,10
 7d0:	000bb583          	ld	a1,0(s7)
 7d4:	855a                	mv	a0,s6
 7d6:	dc9ff0ef          	jal	59e <printint>
        i += 1;
 7da:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7dc:	8bca                	mv	s7,s2
      state = 0;
 7de:	4981                	li	s3,0
        i += 1;
 7e0:	b555                	j	684 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e2:	008b8913          	addi	s2,s7,8
 7e6:	4681                	li	a3,0
 7e8:	4629                	li	a2,10
 7ea:	000bb583          	ld	a1,0(s7)
 7ee:	855a                	mv	a0,s6
 7f0:	dafff0ef          	jal	59e <printint>
        i += 2;
 7f4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f6:	8bca                	mv	s7,s2
      state = 0;
 7f8:	4981                	li	s3,0
        i += 2;
 7fa:	b569                	j	684 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7fc:	008b8913          	addi	s2,s7,8
 800:	4681                	li	a3,0
 802:	4641                	li	a2,16
 804:	000be583          	lwu	a1,0(s7)
 808:	855a                	mv	a0,s6
 80a:	d95ff0ef          	jal	59e <printint>
 80e:	8bca                	mv	s7,s2
      state = 0;
 810:	4981                	li	s3,0
 812:	bd8d                	j	684 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 814:	008b8913          	addi	s2,s7,8
 818:	4681                	li	a3,0
 81a:	4641                	li	a2,16
 81c:	000bb583          	ld	a1,0(s7)
 820:	855a                	mv	a0,s6
 822:	d7dff0ef          	jal	59e <printint>
        i += 1;
 826:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 828:	8bca                	mv	s7,s2
      state = 0;
 82a:	4981                	li	s3,0
        i += 1;
 82c:	bda1                	j	684 <vprintf+0x4a>
 82e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 830:	008b8d13          	addi	s10,s7,8
 834:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 838:	03000593          	li	a1,48
 83c:	855a                	mv	a0,s6
 83e:	d43ff0ef          	jal	580 <putc>
  putc(fd, 'x');
 842:	07800593          	li	a1,120
 846:	855a                	mv	a0,s6
 848:	d39ff0ef          	jal	580 <putc>
 84c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 84e:	00000b97          	auipc	s7,0x0
 852:	3eab8b93          	addi	s7,s7,1002 # c38 <digits>
 856:	03c9d793          	srli	a5,s3,0x3c
 85a:	97de                	add	a5,a5,s7
 85c:	0007c583          	lbu	a1,0(a5)
 860:	855a                	mv	a0,s6
 862:	d1fff0ef          	jal	580 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 866:	0992                	slli	s3,s3,0x4
 868:	397d                	addiw	s2,s2,-1
 86a:	fe0916e3          	bnez	s2,856 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 86e:	8bea                	mv	s7,s10
      state = 0;
 870:	4981                	li	s3,0
 872:	6d02                	ld	s10,0(sp)
 874:	bd01                	j	684 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 876:	008b8913          	addi	s2,s7,8
 87a:	000bc583          	lbu	a1,0(s7)
 87e:	855a                	mv	a0,s6
 880:	d01ff0ef          	jal	580 <putc>
 884:	8bca                	mv	s7,s2
      state = 0;
 886:	4981                	li	s3,0
 888:	bbf5                	j	684 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 88a:	008b8993          	addi	s3,s7,8
 88e:	000bb903          	ld	s2,0(s7)
 892:	00090f63          	beqz	s2,8b0 <vprintf+0x276>
        for(; *s; s++)
 896:	00094583          	lbu	a1,0(s2)
 89a:	c195                	beqz	a1,8be <vprintf+0x284>
          putc(fd, *s);
 89c:	855a                	mv	a0,s6
 89e:	ce3ff0ef          	jal	580 <putc>
        for(; *s; s++)
 8a2:	0905                	addi	s2,s2,1
 8a4:	00094583          	lbu	a1,0(s2)
 8a8:	f9f5                	bnez	a1,89c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8aa:	8bce                	mv	s7,s3
      state = 0;
 8ac:	4981                	li	s3,0
 8ae:	bbd9                	j	684 <vprintf+0x4a>
          s = "(null)";
 8b0:	00000917          	auipc	s2,0x0
 8b4:	34090913          	addi	s2,s2,832 # bf0 <malloc+0x234>
        for(; *s; s++)
 8b8:	02800593          	li	a1,40
 8bc:	b7c5                	j	89c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8be:	8bce                	mv	s7,s3
      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	b3c9                	j	684 <vprintf+0x4a>
 8c4:	64a6                	ld	s1,72(sp)
 8c6:	79e2                	ld	s3,56(sp)
 8c8:	7a42                	ld	s4,48(sp)
 8ca:	7aa2                	ld	s5,40(sp)
 8cc:	7b02                	ld	s6,32(sp)
 8ce:	6be2                	ld	s7,24(sp)
 8d0:	6c42                	ld	s8,16(sp)
 8d2:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8d4:	60e6                	ld	ra,88(sp)
 8d6:	6446                	ld	s0,80(sp)
 8d8:	6906                	ld	s2,64(sp)
 8da:	6125                	addi	sp,sp,96
 8dc:	8082                	ret

00000000000008de <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8de:	715d                	addi	sp,sp,-80
 8e0:	ec06                	sd	ra,24(sp)
 8e2:	e822                	sd	s0,16(sp)
 8e4:	1000                	addi	s0,sp,32
 8e6:	e010                	sd	a2,0(s0)
 8e8:	e414                	sd	a3,8(s0)
 8ea:	e818                	sd	a4,16(s0)
 8ec:	ec1c                	sd	a5,24(s0)
 8ee:	03043023          	sd	a6,32(s0)
 8f2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8f6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8fa:	8622                	mv	a2,s0
 8fc:	d3fff0ef          	jal	63a <vprintf>
}
 900:	60e2                	ld	ra,24(sp)
 902:	6442                	ld	s0,16(sp)
 904:	6161                	addi	sp,sp,80
 906:	8082                	ret

0000000000000908 <printf>:

void
printf(const char *fmt, ...)
{
 908:	711d                	addi	sp,sp,-96
 90a:	ec06                	sd	ra,24(sp)
 90c:	e822                	sd	s0,16(sp)
 90e:	1000                	addi	s0,sp,32
 910:	e40c                	sd	a1,8(s0)
 912:	e810                	sd	a2,16(s0)
 914:	ec14                	sd	a3,24(s0)
 916:	f018                	sd	a4,32(s0)
 918:	f41c                	sd	a5,40(s0)
 91a:	03043823          	sd	a6,48(s0)
 91e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 922:	00840613          	addi	a2,s0,8
 926:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 92a:	85aa                	mv	a1,a0
 92c:	4505                	li	a0,1
 92e:	d0dff0ef          	jal	63a <vprintf>
}
 932:	60e2                	ld	ra,24(sp)
 934:	6442                	ld	s0,16(sp)
 936:	6125                	addi	sp,sp,96
 938:	8082                	ret

000000000000093a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 93a:	1141                	addi	sp,sp,-16
 93c:	e422                	sd	s0,8(sp)
 93e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 940:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 944:	00000797          	auipc	a5,0x0
 948:	6c47b783          	ld	a5,1732(a5) # 1008 <freep>
 94c:	a02d                	j	976 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 94e:	4618                	lw	a4,8(a2)
 950:	9f2d                	addw	a4,a4,a1
 952:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 956:	6398                	ld	a4,0(a5)
 958:	6310                	ld	a2,0(a4)
 95a:	a83d                	j	998 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 95c:	ff852703          	lw	a4,-8(a0)
 960:	9f31                	addw	a4,a4,a2
 962:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 964:	ff053683          	ld	a3,-16(a0)
 968:	a091                	j	9ac <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 96a:	6398                	ld	a4,0(a5)
 96c:	00e7e463          	bltu	a5,a4,974 <free+0x3a>
 970:	00e6ea63          	bltu	a3,a4,984 <free+0x4a>
{
 974:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 976:	fed7fae3          	bgeu	a5,a3,96a <free+0x30>
 97a:	6398                	ld	a4,0(a5)
 97c:	00e6e463          	bltu	a3,a4,984 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 980:	fee7eae3          	bltu	a5,a4,974 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 984:	ff852583          	lw	a1,-8(a0)
 988:	6390                	ld	a2,0(a5)
 98a:	02059813          	slli	a6,a1,0x20
 98e:	01c85713          	srli	a4,a6,0x1c
 992:	9736                	add	a4,a4,a3
 994:	fae60de3          	beq	a2,a4,94e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 998:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 99c:	4790                	lw	a2,8(a5)
 99e:	02061593          	slli	a1,a2,0x20
 9a2:	01c5d713          	srli	a4,a1,0x1c
 9a6:	973e                	add	a4,a4,a5
 9a8:	fae68ae3          	beq	a3,a4,95c <free+0x22>
    p->s.ptr = bp->s.ptr;
 9ac:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9ae:	00000717          	auipc	a4,0x0
 9b2:	64f73d23          	sd	a5,1626(a4) # 1008 <freep>
}
 9b6:	6422                	ld	s0,8(sp)
 9b8:	0141                	addi	sp,sp,16
 9ba:	8082                	ret

00000000000009bc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9bc:	7139                	addi	sp,sp,-64
 9be:	fc06                	sd	ra,56(sp)
 9c0:	f822                	sd	s0,48(sp)
 9c2:	f426                	sd	s1,40(sp)
 9c4:	ec4e                	sd	s3,24(sp)
 9c6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c8:	02051493          	slli	s1,a0,0x20
 9cc:	9081                	srli	s1,s1,0x20
 9ce:	04bd                	addi	s1,s1,15
 9d0:	8091                	srli	s1,s1,0x4
 9d2:	0014899b          	addiw	s3,s1,1
 9d6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9d8:	00000517          	auipc	a0,0x0
 9dc:	63053503          	ld	a0,1584(a0) # 1008 <freep>
 9e0:	c915                	beqz	a0,a14 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e4:	4798                	lw	a4,8(a5)
 9e6:	08977a63          	bgeu	a4,s1,a7a <malloc+0xbe>
 9ea:	f04a                	sd	s2,32(sp)
 9ec:	e852                	sd	s4,16(sp)
 9ee:	e456                	sd	s5,8(sp)
 9f0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9f2:	8a4e                	mv	s4,s3
 9f4:	0009871b          	sext.w	a4,s3
 9f8:	6685                	lui	a3,0x1
 9fa:	00d77363          	bgeu	a4,a3,a00 <malloc+0x44>
 9fe:	6a05                	lui	s4,0x1
 a00:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a04:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a08:	00000917          	auipc	s2,0x0
 a0c:	60090913          	addi	s2,s2,1536 # 1008 <freep>
  if(p == SBRK_ERROR)
 a10:	5afd                	li	s5,-1
 a12:	a081                	j	a52 <malloc+0x96>
 a14:	f04a                	sd	s2,32(sp)
 a16:	e852                	sd	s4,16(sp)
 a18:	e456                	sd	s5,8(sp)
 a1a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a1c:	00000797          	auipc	a5,0x0
 a20:	5f478793          	addi	a5,a5,1524 # 1010 <base>
 a24:	00000717          	auipc	a4,0x0
 a28:	5ef73223          	sd	a5,1508(a4) # 1008 <freep>
 a2c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a2e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a32:	b7c1                	j	9f2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a34:	6398                	ld	a4,0(a5)
 a36:	e118                	sd	a4,0(a0)
 a38:	a8a9                	j	a92 <malloc+0xd6>
  hp->s.size = nu;
 a3a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a3e:	0541                	addi	a0,a0,16
 a40:	efbff0ef          	jal	93a <free>
  return freep;
 a44:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a48:	c12d                	beqz	a0,aaa <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a4c:	4798                	lw	a4,8(a5)
 a4e:	02977263          	bgeu	a4,s1,a72 <malloc+0xb6>
    if(p == freep)
 a52:	00093703          	ld	a4,0(s2)
 a56:	853e                	mv	a0,a5
 a58:	fef719e3          	bne	a4,a5,a4a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a5c:	8552                	mv	a0,s4
 a5e:	a1fff0ef          	jal	47c <sbrk>
  if(p == SBRK_ERROR)
 a62:	fd551ce3          	bne	a0,s5,a3a <malloc+0x7e>
        return 0;
 a66:	4501                	li	a0,0
 a68:	7902                	ld	s2,32(sp)
 a6a:	6a42                	ld	s4,16(sp)
 a6c:	6aa2                	ld	s5,8(sp)
 a6e:	6b02                	ld	s6,0(sp)
 a70:	a03d                	j	a9e <malloc+0xe2>
 a72:	7902                	ld	s2,32(sp)
 a74:	6a42                	ld	s4,16(sp)
 a76:	6aa2                	ld	s5,8(sp)
 a78:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a7a:	fae48de3          	beq	s1,a4,a34 <malloc+0x78>
        p->s.size -= nunits;
 a7e:	4137073b          	subw	a4,a4,s3
 a82:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a84:	02071693          	slli	a3,a4,0x20
 a88:	01c6d713          	srli	a4,a3,0x1c
 a8c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a8e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a92:	00000717          	auipc	a4,0x0
 a96:	56a73b23          	sd	a0,1398(a4) # 1008 <freep>
      return (void*)(p + 1);
 a9a:	01078513          	addi	a0,a5,16
  }
}
 a9e:	70e2                	ld	ra,56(sp)
 aa0:	7442                	ld	s0,48(sp)
 aa2:	74a2                	ld	s1,40(sp)
 aa4:	69e2                	ld	s3,24(sp)
 aa6:	6121                	addi	sp,sp,64
 aa8:	8082                	ret
 aaa:	7902                	ld	s2,32(sp)
 aac:	6a42                	ld	s4,16(sp)
 aae:	6aa2                	ld	s5,8(sp)
 ab0:	6b02                	ld	s6,0(sp)
 ab2:	b7f5                	j	a9e <malloc+0xe2>
