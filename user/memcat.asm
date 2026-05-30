
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
  40:	af4b8b93          	addi	s7,s7,-1292 # b30 <malloc+0x146>
  switch(t){
  44:	00001a97          	auipc	s5,0x1
  48:	c04a8a93          	addi	s5,s5,-1020 # c48 <malloc+0x25e>
  4c:	00001d17          	auipc	s10,0x1
  50:	ab4d0d13          	addi	s10,s10,-1356 # b00 <malloc+0x116>
    case MEM_FREE:   return "FREE";
  54:	00001d97          	auipc	s11,0x1
  58:	ad4d8d93          	addi	s11,s11,-1324 # b28 <malloc+0x13e>
  struct mem_event ev[16];
  int n, i;

  for(;;){
    n = memread(ev, 16);
  5c:	45c1                	li	a1,16
  5e:	91040513          	addi	a0,s0,-1776
  62:	544000ef          	jal	5a6 <memread>
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
  78:	aacc8c93          	addi	s9,s9,-1364 # b20 <malloc+0x136>
    case MEM_UNMAP:  return "UNMAP";
  7c:	00001c17          	auipc	s8,0x1
  80:	a9cc0c13          	addi	s8,s8,-1380 # b18 <malloc+0x12e>
  if(perm & (1 << 1)) buf[i++] = 'R';
  84:	00001917          	auipc	s2,0x1
  88:	f7c90913          	addi	s2,s2,-132 # 1000 <buf.0>
  8c:	aa21                	j	1a4 <main+0x1a4>
    case MEM_GROW:   return "GROW";
  8e:	00001817          	auipc	a6,0x1
  92:	a6280813          	addi	a6,a6,-1438 # af0 <malloc+0x106>
  switch(s){
  96:	41a8                	lw	a0,64(a1)
  98:	16aa6863          	bltu	s4,a0,208 <main+0x208>
  9c:	0405e503          	lwu	a0,64(a1)
  a0:	050a                	slli	a0,a0,0x2
  a2:	00001897          	auipc	a7,0x1
  a6:	b8688893          	addi	a7,a7,-1146 # c28 <malloc+0x23e>
  aa:	9546                	add	a0,a0,a7
  ac:	4108                	lw	a0,0(a0)
  ae:	9546                	add	a0,a0,a7
  b0:	8502                	jr	a0
    case MEM_FAULT:  return "FAULT";
  b2:	00001817          	auipc	a6,0x1
  b6:	a5680813          	addi	a6,a6,-1450 # b08 <malloc+0x11e>
  ba:	bff1                	j	96 <main+0x96>
    case MEM_MAP:    return "MAP";
  bc:	00001817          	auipc	a6,0x1
  c0:	a5480813          	addi	a6,a6,-1452 # b10 <malloc+0x126>
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
  de:	a5e88893          	addi	a7,a7,-1442 # b38 <malloc+0x14e>
     
    
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
 150:	a5450513          	addi	a0,a0,-1452 # ba0 <malloc+0x1b6>
 154:	03e30163          	beq	t1,t5,176 <main+0x176>
 158:	4f0d                	li	t5,3
    case PAGE_KERNEL:    return "KERNEL";
 15a:	00001517          	auipc	a0,0x1
 15e:	a5650513          	addi	a0,a0,-1450 # bb0 <malloc+0x1c6>
  switch(kind){
 162:	01e30a63          	beq	t1,t5,176 <main+0x176>
 166:	4f05                	li	t5,1
    case PAGE_USER:      return "USER";
 168:	00001517          	auipc	a0,0x1
 16c:	a3050513          	addi	a0,a0,-1488 # b98 <malloc+0x1ae>
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
 192:	a2a50513          	addi	a0,a0,-1494 # bb8 <malloc+0x1ce>
 196:	7a0000ef          	jal	936 <printf>
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
 1d0:	97c88893          	addi	a7,a7,-1668 # b48 <malloc+0x15e>
 1d4:	b739                	j	e2 <main+0xe2>
    case SRC_MAPPAGES:   return "MAPPAGES";
 1d6:	00001897          	auipc	a7,0x1
 1da:	97a88893          	addi	a7,a7,-1670 # b50 <malloc+0x166>
 1de:	b711                	j	e2 <main+0xe2>
    case SRC_UVMUNMAP:   return "UVMUNMAP";
 1e0:	00001897          	auipc	a7,0x1
 1e4:	98088893          	addi	a7,a7,-1664 # b60 <malloc+0x176>
 1e8:	bded                	j	e2 <main+0xe2>
    case SRC_UVMALLOC:   return "UVMALLOC";
 1ea:	00001897          	auipc	a7,0x1
 1ee:	98688893          	addi	a7,a7,-1658 # b70 <malloc+0x186>
 1f2:	bdc5                	j	e2 <main+0xe2>
    case SRC_UVMDEALLOC: return "UVMDEALLOC";
 1f4:	00001897          	auipc	a7,0x1
 1f8:	98c88893          	addi	a7,a7,-1652 # b80 <malloc+0x196>
 1fc:	b5dd                	j	e2 <main+0xe2>
    case SRC_VMFAULT:    return "VMFAULT";
 1fe:	00001897          	auipc	a7,0x1
 202:	99288893          	addi	a7,a7,-1646 # b90 <malloc+0x1a6>
 206:	bdf1                	j	e2 <main+0xe2>
    default:             return "UNKNOWN";
 208:	88de                	mv	a7,s7
 20a:	bde1                	j	e2 <main+0xe2>
  switch(s){
 20c:	00001897          	auipc	a7,0x1
 210:	93488893          	addi	a7,a7,-1740 # b40 <malloc+0x156>
 214:	b5f9                	j	e2 <main+0xe2>
    }
  }

 

  exit(0);
 216:	4501                	li	a0,0
 218:	2d6000ef          	jal	4ee <exit>

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
 228:	2c6000ef          	jal	4ee <exit>

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
 316:	1f0000ef          	jal	506 <read>
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
 362:	1cc000ef          	jal	52e <open>
  if(fd < 0)
 366:	02054263          	bltz	a0,38a <stat+0x36>
 36a:	e426                	sd	s1,8(sp)
 36c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 36e:	85ca                	mv	a1,s2
 370:	1d6000ef          	jal	546 <fstat>
 374:	892a                	mv	s2,a0
  close(fd);
 376:	8526                	mv	a0,s1
 378:	19e000ef          	jal	516 <close>
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
 486:	0f0000ef          	jal	576 <sys_sbrk>
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
 49c:	0da000ef          	jal	576 <sys_sbrk>
}
 4a0:	60a2                	ld	ra,8(sp)
 4a2:	6402                	ld	s0,0(sp)
 4a4:	0141                	addi	sp,sp,16
 4a6:	8082                	ret

00000000000004a8 <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
 4a8:	1141                	addi	sp,sp,-16
 4aa:	e406                	sd	ra,8(sp)
 4ac:	e022                	sd	s0,0(sp)
 4ae:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
 4b0:	0025961b          	slliw	a2,a1,0x2
 4b4:	9e2d                	addw	a2,a2,a1
 4b6:	0036161b          	slliw	a2,a2,0x3
 4ba:	4581                	li	a1,0
 4bc:	de3ff0ef          	jal	29e <memset>
  return 0;
}
 4c0:	4501                	li	a0,0
 4c2:	60a2                	ld	ra,8(sp)
 4c4:	6402                	ld	s0,0(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret

00000000000004ca <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
 4ca:	1141                	addi	sp,sp,-16
 4cc:	e406                	sd	ra,8(sp)
 4ce:	e022                	sd	s0,0(sp)
 4d0:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
 4d2:	07000613          	li	a2,112
 4d6:	4581                	li	a1,0
 4d8:	dc7ff0ef          	jal	29e <memset>
  return 0;
}
 4dc:	4501                	li	a0,0
 4de:	60a2                	ld	ra,8(sp)
 4e0:	6402                	ld	s0,0(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret

00000000000004e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4e6:	4885                	li	a7,1
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ee:	4889                	li	a7,2
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4f6:	488d                	li	a7,3
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4fe:	4891                	li	a7,4
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <read>:
.global read
read:
 li a7, SYS_read
 506:	4895                	li	a7,5
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <write>:
.global write
write:
 li a7, SYS_write
 50e:	48c1                	li	a7,16
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <close>:
.global close
close:
 li a7, SYS_close
 516:	48d5                	li	a7,21
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <kill>:
.global kill
kill:
 li a7, SYS_kill
 51e:	4899                	li	a7,6
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <exec>:
.global exec
exec:
 li a7, SYS_exec
 526:	489d                	li	a7,7
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <open>:
.global open
open:
 li a7, SYS_open
 52e:	48bd                	li	a7,15
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 536:	48c5                	li	a7,17
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 53e:	48c9                	li	a7,18
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 546:	48a1                	li	a7,8
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <link>:
.global link
link:
 li a7, SYS_link
 54e:	48cd                	li	a7,19
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 556:	48d1                	li	a7,20
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 55e:	48a5                	li	a7,9
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <dup>:
.global dup
dup:
 li a7, SYS_dup
 566:	48a9                	li	a7,10
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 56e:	48ad                	li	a7,11
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 576:	48b1                	li	a7,12
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <pause>:
.global pause
pause:
 li a7, SYS_pause
 57e:	48b5                	li	a7,13
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 586:	48b9                	li	a7,14
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <csread>:
.global csread
csread:
 li a7, SYS_csread
 58e:	48d9                	li	a7,22
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 596:	48dd                	li	a7,23
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 59e:	48e1                	li	a7,24
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <memread>:
.global memread
memread:
 li a7, SYS_memread
 5a6:	48e5                	li	a7,25
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5ae:	1101                	addi	sp,sp,-32
 5b0:	ec06                	sd	ra,24(sp)
 5b2:	e822                	sd	s0,16(sp)
 5b4:	1000                	addi	s0,sp,32
 5b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ba:	4605                	li	a2,1
 5bc:	fef40593          	addi	a1,s0,-17
 5c0:	f4fff0ef          	jal	50e <write>
}
 5c4:	60e2                	ld	ra,24(sp)
 5c6:	6442                	ld	s0,16(sp)
 5c8:	6105                	addi	sp,sp,32
 5ca:	8082                	ret

00000000000005cc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5cc:	715d                	addi	sp,sp,-80
 5ce:	e486                	sd	ra,72(sp)
 5d0:	e0a2                	sd	s0,64(sp)
 5d2:	f84a                	sd	s2,48(sp)
 5d4:	0880                	addi	s0,sp,80
 5d6:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5d8:	c299                	beqz	a3,5de <printint+0x12>
 5da:	0805c363          	bltz	a1,660 <printint+0x94>
  neg = 0;
 5de:	4881                	li	a7,0
 5e0:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5e4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5e6:	00000517          	auipc	a0,0x0
 5ea:	68250513          	addi	a0,a0,1666 # c68 <digits>
 5ee:	883e                	mv	a6,a5
 5f0:	2785                	addiw	a5,a5,1
 5f2:	02c5f733          	remu	a4,a1,a2
 5f6:	972a                	add	a4,a4,a0
 5f8:	00074703          	lbu	a4,0(a4)
 5fc:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 600:	872e                	mv	a4,a1
 602:	02c5d5b3          	divu	a1,a1,a2
 606:	0685                	addi	a3,a3,1
 608:	fec773e3          	bgeu	a4,a2,5ee <printint+0x22>
  if(neg)
 60c:	00088b63          	beqz	a7,622 <printint+0x56>
    buf[i++] = '-';
 610:	fd078793          	addi	a5,a5,-48
 614:	97a2                	add	a5,a5,s0
 616:	02d00713          	li	a4,45
 61a:	fee78423          	sb	a4,-24(a5)
 61e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 622:	02f05a63          	blez	a5,656 <printint+0x8a>
 626:	fc26                	sd	s1,56(sp)
 628:	f44e                	sd	s3,40(sp)
 62a:	fb840713          	addi	a4,s0,-72
 62e:	00f704b3          	add	s1,a4,a5
 632:	fff70993          	addi	s3,a4,-1
 636:	99be                	add	s3,s3,a5
 638:	37fd                	addiw	a5,a5,-1
 63a:	1782                	slli	a5,a5,0x20
 63c:	9381                	srli	a5,a5,0x20
 63e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 642:	fff4c583          	lbu	a1,-1(s1)
 646:	854a                	mv	a0,s2
 648:	f67ff0ef          	jal	5ae <putc>
  while(--i >= 0)
 64c:	14fd                	addi	s1,s1,-1
 64e:	ff349ae3          	bne	s1,s3,642 <printint+0x76>
 652:	74e2                	ld	s1,56(sp)
 654:	79a2                	ld	s3,40(sp)
}
 656:	60a6                	ld	ra,72(sp)
 658:	6406                	ld	s0,64(sp)
 65a:	7942                	ld	s2,48(sp)
 65c:	6161                	addi	sp,sp,80
 65e:	8082                	ret
    x = -xx;
 660:	40b005b3          	neg	a1,a1
    neg = 1;
 664:	4885                	li	a7,1
    x = -xx;
 666:	bfad                	j	5e0 <printint+0x14>

0000000000000668 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 668:	711d                	addi	sp,sp,-96
 66a:	ec86                	sd	ra,88(sp)
 66c:	e8a2                	sd	s0,80(sp)
 66e:	e0ca                	sd	s2,64(sp)
 670:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 672:	0005c903          	lbu	s2,0(a1)
 676:	28090663          	beqz	s2,902 <vprintf+0x29a>
 67a:	e4a6                	sd	s1,72(sp)
 67c:	fc4e                	sd	s3,56(sp)
 67e:	f852                	sd	s4,48(sp)
 680:	f456                	sd	s5,40(sp)
 682:	f05a                	sd	s6,32(sp)
 684:	ec5e                	sd	s7,24(sp)
 686:	e862                	sd	s8,16(sp)
 688:	e466                	sd	s9,8(sp)
 68a:	8b2a                	mv	s6,a0
 68c:	8a2e                	mv	s4,a1
 68e:	8bb2                	mv	s7,a2
  state = 0;
 690:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 692:	4481                	li	s1,0
 694:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 696:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 69a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 69e:	06c00c93          	li	s9,108
 6a2:	a005                	j	6c2 <vprintf+0x5a>
        putc(fd, c0);
 6a4:	85ca                	mv	a1,s2
 6a6:	855a                	mv	a0,s6
 6a8:	f07ff0ef          	jal	5ae <putc>
 6ac:	a019                	j	6b2 <vprintf+0x4a>
    } else if(state == '%'){
 6ae:	03598263          	beq	s3,s5,6d2 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 6b2:	2485                	addiw	s1,s1,1
 6b4:	8726                	mv	a4,s1
 6b6:	009a07b3          	add	a5,s4,s1
 6ba:	0007c903          	lbu	s2,0(a5)
 6be:	22090a63          	beqz	s2,8f2 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 6c2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6c6:	fe0994e3          	bnez	s3,6ae <vprintf+0x46>
      if(c0 == '%'){
 6ca:	fd579de3          	bne	a5,s5,6a4 <vprintf+0x3c>
        state = '%';
 6ce:	89be                	mv	s3,a5
 6d0:	b7cd                	j	6b2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6d2:	00ea06b3          	add	a3,s4,a4
 6d6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6da:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6dc:	c681                	beqz	a3,6e4 <vprintf+0x7c>
 6de:	9752                	add	a4,a4,s4
 6e0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6e4:	05878363          	beq	a5,s8,72a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 6e8:	05978d63          	beq	a5,s9,742 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6ec:	07500713          	li	a4,117
 6f0:	0ee78763          	beq	a5,a4,7de <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6f4:	07800713          	li	a4,120
 6f8:	12e78963          	beq	a5,a4,82a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6fc:	07000713          	li	a4,112
 700:	14e78e63          	beq	a5,a4,85c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 704:	06300713          	li	a4,99
 708:	18e78e63          	beq	a5,a4,8a4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 70c:	07300713          	li	a4,115
 710:	1ae78463          	beq	a5,a4,8b8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 714:	02500713          	li	a4,37
 718:	04e79563          	bne	a5,a4,762 <vprintf+0xfa>
        putc(fd, '%');
 71c:	02500593          	li	a1,37
 720:	855a                	mv	a0,s6
 722:	e8dff0ef          	jal	5ae <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 726:	4981                	li	s3,0
 728:	b769                	j	6b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 72a:	008b8913          	addi	s2,s7,8
 72e:	4685                	li	a3,1
 730:	4629                	li	a2,10
 732:	000ba583          	lw	a1,0(s7)
 736:	855a                	mv	a0,s6
 738:	e95ff0ef          	jal	5cc <printint>
 73c:	8bca                	mv	s7,s2
      state = 0;
 73e:	4981                	li	s3,0
 740:	bf8d                	j	6b2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 742:	06400793          	li	a5,100
 746:	02f68963          	beq	a3,a5,778 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 74a:	06c00793          	li	a5,108
 74e:	04f68263          	beq	a3,a5,792 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 752:	07500793          	li	a5,117
 756:	0af68063          	beq	a3,a5,7f6 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 75a:	07800793          	li	a5,120
 75e:	0ef68263          	beq	a3,a5,842 <vprintf+0x1da>
        putc(fd, '%');
 762:	02500593          	li	a1,37
 766:	855a                	mv	a0,s6
 768:	e47ff0ef          	jal	5ae <putc>
        putc(fd, c0);
 76c:	85ca                	mv	a1,s2
 76e:	855a                	mv	a0,s6
 770:	e3fff0ef          	jal	5ae <putc>
      state = 0;
 774:	4981                	li	s3,0
 776:	bf35                	j	6b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 778:	008b8913          	addi	s2,s7,8
 77c:	4685                	li	a3,1
 77e:	4629                	li	a2,10
 780:	000bb583          	ld	a1,0(s7)
 784:	855a                	mv	a0,s6
 786:	e47ff0ef          	jal	5cc <printint>
        i += 1;
 78a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 78c:	8bca                	mv	s7,s2
      state = 0;
 78e:	4981                	li	s3,0
        i += 1;
 790:	b70d                	j	6b2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 792:	06400793          	li	a5,100
 796:	02f60763          	beq	a2,a5,7c4 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 79a:	07500793          	li	a5,117
 79e:	06f60963          	beq	a2,a5,810 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7a2:	07800793          	li	a5,120
 7a6:	faf61ee3          	bne	a2,a5,762 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7aa:	008b8913          	addi	s2,s7,8
 7ae:	4681                	li	a3,0
 7b0:	4641                	li	a2,16
 7b2:	000bb583          	ld	a1,0(s7)
 7b6:	855a                	mv	a0,s6
 7b8:	e15ff0ef          	jal	5cc <printint>
        i += 2;
 7bc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7be:	8bca                	mv	s7,s2
      state = 0;
 7c0:	4981                	li	s3,0
        i += 2;
 7c2:	bdc5                	j	6b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7c4:	008b8913          	addi	s2,s7,8
 7c8:	4685                	li	a3,1
 7ca:	4629                	li	a2,10
 7cc:	000bb583          	ld	a1,0(s7)
 7d0:	855a                	mv	a0,s6
 7d2:	dfbff0ef          	jal	5cc <printint>
        i += 2;
 7d6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d8:	8bca                	mv	s7,s2
      state = 0;
 7da:	4981                	li	s3,0
        i += 2;
 7dc:	bdd9                	j	6b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7de:	008b8913          	addi	s2,s7,8
 7e2:	4681                	li	a3,0
 7e4:	4629                	li	a2,10
 7e6:	000be583          	lwu	a1,0(s7)
 7ea:	855a                	mv	a0,s6
 7ec:	de1ff0ef          	jal	5cc <printint>
 7f0:	8bca                	mv	s7,s2
      state = 0;
 7f2:	4981                	li	s3,0
 7f4:	bd7d                	j	6b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f6:	008b8913          	addi	s2,s7,8
 7fa:	4681                	li	a3,0
 7fc:	4629                	li	a2,10
 7fe:	000bb583          	ld	a1,0(s7)
 802:	855a                	mv	a0,s6
 804:	dc9ff0ef          	jal	5cc <printint>
        i += 1;
 808:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 80a:	8bca                	mv	s7,s2
      state = 0;
 80c:	4981                	li	s3,0
        i += 1;
 80e:	b555                	j	6b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 810:	008b8913          	addi	s2,s7,8
 814:	4681                	li	a3,0
 816:	4629                	li	a2,10
 818:	000bb583          	ld	a1,0(s7)
 81c:	855a                	mv	a0,s6
 81e:	dafff0ef          	jal	5cc <printint>
        i += 2;
 822:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 824:	8bca                	mv	s7,s2
      state = 0;
 826:	4981                	li	s3,0
        i += 2;
 828:	b569                	j	6b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 82a:	008b8913          	addi	s2,s7,8
 82e:	4681                	li	a3,0
 830:	4641                	li	a2,16
 832:	000be583          	lwu	a1,0(s7)
 836:	855a                	mv	a0,s6
 838:	d95ff0ef          	jal	5cc <printint>
 83c:	8bca                	mv	s7,s2
      state = 0;
 83e:	4981                	li	s3,0
 840:	bd8d                	j	6b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 842:	008b8913          	addi	s2,s7,8
 846:	4681                	li	a3,0
 848:	4641                	li	a2,16
 84a:	000bb583          	ld	a1,0(s7)
 84e:	855a                	mv	a0,s6
 850:	d7dff0ef          	jal	5cc <printint>
        i += 1;
 854:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 856:	8bca                	mv	s7,s2
      state = 0;
 858:	4981                	li	s3,0
        i += 1;
 85a:	bda1                	j	6b2 <vprintf+0x4a>
 85c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 85e:	008b8d13          	addi	s10,s7,8
 862:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 866:	03000593          	li	a1,48
 86a:	855a                	mv	a0,s6
 86c:	d43ff0ef          	jal	5ae <putc>
  putc(fd, 'x');
 870:	07800593          	li	a1,120
 874:	855a                	mv	a0,s6
 876:	d39ff0ef          	jal	5ae <putc>
 87a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 87c:	00000b97          	auipc	s7,0x0
 880:	3ecb8b93          	addi	s7,s7,1004 # c68 <digits>
 884:	03c9d793          	srli	a5,s3,0x3c
 888:	97de                	add	a5,a5,s7
 88a:	0007c583          	lbu	a1,0(a5)
 88e:	855a                	mv	a0,s6
 890:	d1fff0ef          	jal	5ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 894:	0992                	slli	s3,s3,0x4
 896:	397d                	addiw	s2,s2,-1
 898:	fe0916e3          	bnez	s2,884 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 89c:	8bea                	mv	s7,s10
      state = 0;
 89e:	4981                	li	s3,0
 8a0:	6d02                	ld	s10,0(sp)
 8a2:	bd01                	j	6b2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 8a4:	008b8913          	addi	s2,s7,8
 8a8:	000bc583          	lbu	a1,0(s7)
 8ac:	855a                	mv	a0,s6
 8ae:	d01ff0ef          	jal	5ae <putc>
 8b2:	8bca                	mv	s7,s2
      state = 0;
 8b4:	4981                	li	s3,0
 8b6:	bbf5                	j	6b2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8b8:	008b8993          	addi	s3,s7,8
 8bc:	000bb903          	ld	s2,0(s7)
 8c0:	00090f63          	beqz	s2,8de <vprintf+0x276>
        for(; *s; s++)
 8c4:	00094583          	lbu	a1,0(s2)
 8c8:	c195                	beqz	a1,8ec <vprintf+0x284>
          putc(fd, *s);
 8ca:	855a                	mv	a0,s6
 8cc:	ce3ff0ef          	jal	5ae <putc>
        for(; *s; s++)
 8d0:	0905                	addi	s2,s2,1
 8d2:	00094583          	lbu	a1,0(s2)
 8d6:	f9f5                	bnez	a1,8ca <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8d8:	8bce                	mv	s7,s3
      state = 0;
 8da:	4981                	li	s3,0
 8dc:	bbd9                	j	6b2 <vprintf+0x4a>
          s = "(null)";
 8de:	00000917          	auipc	s2,0x0
 8e2:	34290913          	addi	s2,s2,834 # c20 <malloc+0x236>
        for(; *s; s++)
 8e6:	02800593          	li	a1,40
 8ea:	b7c5                	j	8ca <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8ec:	8bce                	mv	s7,s3
      state = 0;
 8ee:	4981                	li	s3,0
 8f0:	b3c9                	j	6b2 <vprintf+0x4a>
 8f2:	64a6                	ld	s1,72(sp)
 8f4:	79e2                	ld	s3,56(sp)
 8f6:	7a42                	ld	s4,48(sp)
 8f8:	7aa2                	ld	s5,40(sp)
 8fa:	7b02                	ld	s6,32(sp)
 8fc:	6be2                	ld	s7,24(sp)
 8fe:	6c42                	ld	s8,16(sp)
 900:	6ca2                	ld	s9,8(sp)
    }
  }
}
 902:	60e6                	ld	ra,88(sp)
 904:	6446                	ld	s0,80(sp)
 906:	6906                	ld	s2,64(sp)
 908:	6125                	addi	sp,sp,96
 90a:	8082                	ret

000000000000090c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 90c:	715d                	addi	sp,sp,-80
 90e:	ec06                	sd	ra,24(sp)
 910:	e822                	sd	s0,16(sp)
 912:	1000                	addi	s0,sp,32
 914:	e010                	sd	a2,0(s0)
 916:	e414                	sd	a3,8(s0)
 918:	e818                	sd	a4,16(s0)
 91a:	ec1c                	sd	a5,24(s0)
 91c:	03043023          	sd	a6,32(s0)
 920:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 924:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 928:	8622                	mv	a2,s0
 92a:	d3fff0ef          	jal	668 <vprintf>
}
 92e:	60e2                	ld	ra,24(sp)
 930:	6442                	ld	s0,16(sp)
 932:	6161                	addi	sp,sp,80
 934:	8082                	ret

0000000000000936 <printf>:

void
printf(const char *fmt, ...)
{
 936:	711d                	addi	sp,sp,-96
 938:	ec06                	sd	ra,24(sp)
 93a:	e822                	sd	s0,16(sp)
 93c:	1000                	addi	s0,sp,32
 93e:	e40c                	sd	a1,8(s0)
 940:	e810                	sd	a2,16(s0)
 942:	ec14                	sd	a3,24(s0)
 944:	f018                	sd	a4,32(s0)
 946:	f41c                	sd	a5,40(s0)
 948:	03043823          	sd	a6,48(s0)
 94c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 950:	00840613          	addi	a2,s0,8
 954:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 958:	85aa                	mv	a1,a0
 95a:	4505                	li	a0,1
 95c:	d0dff0ef          	jal	668 <vprintf>
}
 960:	60e2                	ld	ra,24(sp)
 962:	6442                	ld	s0,16(sp)
 964:	6125                	addi	sp,sp,96
 966:	8082                	ret

0000000000000968 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 968:	1141                	addi	sp,sp,-16
 96a:	e422                	sd	s0,8(sp)
 96c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 96e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 972:	00000797          	auipc	a5,0x0
 976:	6967b783          	ld	a5,1686(a5) # 1008 <freep>
 97a:	a02d                	j	9a4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 97c:	4618                	lw	a4,8(a2)
 97e:	9f2d                	addw	a4,a4,a1
 980:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 984:	6398                	ld	a4,0(a5)
 986:	6310                	ld	a2,0(a4)
 988:	a83d                	j	9c6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 98a:	ff852703          	lw	a4,-8(a0)
 98e:	9f31                	addw	a4,a4,a2
 990:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 992:	ff053683          	ld	a3,-16(a0)
 996:	a091                	j	9da <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 998:	6398                	ld	a4,0(a5)
 99a:	00e7e463          	bltu	a5,a4,9a2 <free+0x3a>
 99e:	00e6ea63          	bltu	a3,a4,9b2 <free+0x4a>
{
 9a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a4:	fed7fae3          	bgeu	a5,a3,998 <free+0x30>
 9a8:	6398                	ld	a4,0(a5)
 9aa:	00e6e463          	bltu	a3,a4,9b2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ae:	fee7eae3          	bltu	a5,a4,9a2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9b2:	ff852583          	lw	a1,-8(a0)
 9b6:	6390                	ld	a2,0(a5)
 9b8:	02059813          	slli	a6,a1,0x20
 9bc:	01c85713          	srli	a4,a6,0x1c
 9c0:	9736                	add	a4,a4,a3
 9c2:	fae60de3          	beq	a2,a4,97c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9ca:	4790                	lw	a2,8(a5)
 9cc:	02061593          	slli	a1,a2,0x20
 9d0:	01c5d713          	srli	a4,a1,0x1c
 9d4:	973e                	add	a4,a4,a5
 9d6:	fae68ae3          	beq	a3,a4,98a <free+0x22>
    p->s.ptr = bp->s.ptr;
 9da:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9dc:	00000717          	auipc	a4,0x0
 9e0:	62f73623          	sd	a5,1580(a4) # 1008 <freep>
}
 9e4:	6422                	ld	s0,8(sp)
 9e6:	0141                	addi	sp,sp,16
 9e8:	8082                	ret

00000000000009ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ea:	7139                	addi	sp,sp,-64
 9ec:	fc06                	sd	ra,56(sp)
 9ee:	f822                	sd	s0,48(sp)
 9f0:	f426                	sd	s1,40(sp)
 9f2:	ec4e                	sd	s3,24(sp)
 9f4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f6:	02051493          	slli	s1,a0,0x20
 9fa:	9081                	srli	s1,s1,0x20
 9fc:	04bd                	addi	s1,s1,15
 9fe:	8091                	srli	s1,s1,0x4
 a00:	0014899b          	addiw	s3,s1,1
 a04:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a06:	00000517          	auipc	a0,0x0
 a0a:	60253503          	ld	a0,1538(a0) # 1008 <freep>
 a0e:	c915                	beqz	a0,a42 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a10:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a12:	4798                	lw	a4,8(a5)
 a14:	08977a63          	bgeu	a4,s1,aa8 <malloc+0xbe>
 a18:	f04a                	sd	s2,32(sp)
 a1a:	e852                	sd	s4,16(sp)
 a1c:	e456                	sd	s5,8(sp)
 a1e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a20:	8a4e                	mv	s4,s3
 a22:	0009871b          	sext.w	a4,s3
 a26:	6685                	lui	a3,0x1
 a28:	00d77363          	bgeu	a4,a3,a2e <malloc+0x44>
 a2c:	6a05                	lui	s4,0x1
 a2e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a32:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a36:	00000917          	auipc	s2,0x0
 a3a:	5d290913          	addi	s2,s2,1490 # 1008 <freep>
  if(p == SBRK_ERROR)
 a3e:	5afd                	li	s5,-1
 a40:	a081                	j	a80 <malloc+0x96>
 a42:	f04a                	sd	s2,32(sp)
 a44:	e852                	sd	s4,16(sp)
 a46:	e456                	sd	s5,8(sp)
 a48:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a4a:	00000797          	auipc	a5,0x0
 a4e:	5c678793          	addi	a5,a5,1478 # 1010 <base>
 a52:	00000717          	auipc	a4,0x0
 a56:	5af73b23          	sd	a5,1462(a4) # 1008 <freep>
 a5a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a5c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a60:	b7c1                	j	a20 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a62:	6398                	ld	a4,0(a5)
 a64:	e118                	sd	a4,0(a0)
 a66:	a8a9                	j	ac0 <malloc+0xd6>
  hp->s.size = nu;
 a68:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a6c:	0541                	addi	a0,a0,16
 a6e:	efbff0ef          	jal	968 <free>
  return freep;
 a72:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a76:	c12d                	beqz	a0,ad8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a7a:	4798                	lw	a4,8(a5)
 a7c:	02977263          	bgeu	a4,s1,aa0 <malloc+0xb6>
    if(p == freep)
 a80:	00093703          	ld	a4,0(s2)
 a84:	853e                	mv	a0,a5
 a86:	fef719e3          	bne	a4,a5,a78 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a8a:	8552                	mv	a0,s4
 a8c:	9f1ff0ef          	jal	47c <sbrk>
  if(p == SBRK_ERROR)
 a90:	fd551ce3          	bne	a0,s5,a68 <malloc+0x7e>
        return 0;
 a94:	4501                	li	a0,0
 a96:	7902                	ld	s2,32(sp)
 a98:	6a42                	ld	s4,16(sp)
 a9a:	6aa2                	ld	s5,8(sp)
 a9c:	6b02                	ld	s6,0(sp)
 a9e:	a03d                	j	acc <malloc+0xe2>
 aa0:	7902                	ld	s2,32(sp)
 aa2:	6a42                	ld	s4,16(sp)
 aa4:	6aa2                	ld	s5,8(sp)
 aa6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aa8:	fae48de3          	beq	s1,a4,a62 <malloc+0x78>
        p->s.size -= nunits;
 aac:	4137073b          	subw	a4,a4,s3
 ab0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ab2:	02071693          	slli	a3,a4,0x20
 ab6:	01c6d713          	srli	a4,a3,0x1c
 aba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 abc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ac0:	00000717          	auipc	a4,0x0
 ac4:	54a73423          	sd	a0,1352(a4) # 1008 <freep>
      return (void*)(p + 1);
 ac8:	01078513          	addi	a0,a5,16
  }
}
 acc:	70e2                	ld	ra,56(sp)
 ace:	7442                	ld	s0,48(sp)
 ad0:	74a2                	ld	s1,40(sp)
 ad2:	69e2                	ld	s3,24(sp)
 ad4:	6121                	addi	sp,sp,64
 ad6:	8082                	ret
 ad8:	7902                	ld	s2,32(sp)
 ada:	6a42                	ld	s4,16(sp)
 adc:	6aa2                	ld	s5,8(sp)
 ade:	6b02                	ld	s6,0(sp)
 ae0:	b7f5                	j	acc <malloc+0xe2>
