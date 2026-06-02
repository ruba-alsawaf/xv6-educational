
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
  struct mem_event ev[16];
  int n, i;

  for(;;){
    n = memread(ev, 16);
  3c:	91040d93          	addi	s11,s0,-1776
    default:         return "UNKNOWN";
  40:	00001b97          	auipc	s7,0x1
  44:	b00b8b93          	addi	s7,s7,-1280 # b40 <malloc+0x140>
  switch(t){
  48:	00001a97          	auipc	s5,0x1
  4c:	c10a8a93          	addi	s5,s5,-1008 # c58 <malloc+0x258>
  50:	00001d17          	auipc	s10,0x1
  54:	ac0d0d13          	addi	s10,s10,-1344 # b10 <malloc+0x110>
    n = memread(ev, 16);
  58:	45c1                	li	a1,16
  5a:	856e                	mv	a0,s11
  5c:	52e000ef          	jal	58a <memread>
  60:	8b2a                	mv	s6,a0
    if(n <= 0)
  62:	1aa05a63          	blez	a0,216 <main+0x216>
  66:	92c40493          	addi	s1,s0,-1748
      break;

    for(i = 0; i < n; i++){
  6a:	4981                	li	s3,0
  switch(t){
  6c:	4a1d                	li	s4,7
    case MEM_FREE:   return "FREE";
  6e:	00001c97          	auipc	s9,0x1
  72:	acac8c93          	addi	s9,s9,-1334 # b38 <malloc+0x138>
    case MEM_ALLOC:  return "ALLOC";
  76:	00001c17          	auipc	s8,0x1
  7a:	abac0c13          	addi	s8,s8,-1350 # b30 <malloc+0x130>
  if(perm & (1 << 1)) buf[i++] = 'R';
  7e:	00001917          	auipc	s2,0x1
  82:	f8290913          	addi	s2,s2,-126 # 1000 <buf.0>
  86:	aa39                	j	1a4 <main+0x1a4>
    case MEM_GROW:   return "GROW";
  88:	00001817          	auipc	a6,0x1
  8c:	a7880813          	addi	a6,a6,-1416 # b00 <malloc+0x100>
  switch(s){
  90:	41a8                	lw	a0,64(a1)
  92:	16aa6b63          	bltu	s4,a0,208 <main+0x208>
  96:	0405e503          	lwu	a0,64(a1)
  9a:	050a                	slli	a0,a0,0x2
  9c:	00001897          	auipc	a7,0x1
  a0:	b9c88893          	addi	a7,a7,-1124 # c38 <malloc+0x238>
  a4:	9546                	add	a0,a0,a7
  a6:	4108                	lw	a0,0(a0)
  a8:	9546                	add	a0,a0,a7
  aa:	8502                	jr	a0
    case MEM_FAULT:  return "FAULT";
  ac:	00001817          	auipc	a6,0x1
  b0:	a6c80813          	addi	a6,a6,-1428 # b18 <malloc+0x118>
  b4:	bff1                	j	90 <main+0x90>
    case MEM_MAP:    return "MAP";
  b6:	00001817          	auipc	a6,0x1
  ba:	a6a80813          	addi	a6,a6,-1430 # b20 <malloc+0x120>
  be:	bfc9                	j	90 <main+0x90>
    case MEM_UNMAP:  return "UNMAP";
  c0:	00001817          	auipc	a6,0x1
  c4:	a6880813          	addi	a6,a6,-1432 # b28 <malloc+0x128>
  c8:	b7e1                	j	90 <main+0x90>
    case MEM_ALLOC:  return "ALLOC";
  ca:	8862                	mv	a6,s8
  cc:	b7d1                	j	90 <main+0x90>
    case MEM_FREE:   return "FREE";
  ce:	8866                	mv	a6,s9
  d0:	b7c1                	j	90 <main+0x90>
    default:         return "UNKNOWN";
  d2:	885e                	mv	a6,s7
  d4:	bf75                	j	90 <main+0x90>
  switch(t){
  d6:	886a                	mv	a6,s10
  d8:	bf65                	j	90 <main+0x90>
    case SRC_NONE:       return "NONE";
  da:	00001897          	auipc	a7,0x1
  de:	a6e88893          	addi	a7,a7,-1426 # b48 <malloc+0x148>
     
    
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
 150:	a6450513          	addi	a0,a0,-1436 # bb0 <malloc+0x1b0>
 154:	03e30163          	beq	t1,t5,176 <main+0x176>
 158:	4f0d                	li	t5,3
    case PAGE_KERNEL:    return "KERNEL";
 15a:	00001517          	auipc	a0,0x1
 15e:	a6650513          	addi	a0,a0,-1434 # bc0 <malloc+0x1c0>
  switch(kind){
 162:	01e30a63          	beq	t1,t5,176 <main+0x176>
 166:	4f05                	li	t5,1
    case PAGE_USER:      return "USER";
 168:	00001517          	auipc	a0,0x1
 16c:	a4050513          	addi	a0,a0,-1472 # ba8 <malloc+0x1a8>
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
 192:	a3a50513          	addi	a0,a0,-1478 # bc8 <malloc+0x1c8>
 196:	7b2000ef          	jal	948 <printf>
    for(i = 0; i < n; i++){
 19a:	2985                	addiw	s3,s3,1
 19c:	06848493          	addi	s1,s1,104
 1a0:	eb3b0ce3          	beq	s6,s3,58 <main+0x58>
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
 1d0:	98c88893          	addi	a7,a7,-1652 # b58 <malloc+0x158>
 1d4:	b739                	j	e2 <main+0xe2>
    case SRC_MAPPAGES:   return "MAPPAGES";
 1d6:	00001897          	auipc	a7,0x1
 1da:	98a88893          	addi	a7,a7,-1654 # b60 <malloc+0x160>
 1de:	b711                	j	e2 <main+0xe2>
    case SRC_UVMUNMAP:   return "UVMUNMAP";
 1e0:	00001897          	auipc	a7,0x1
 1e4:	99088893          	addi	a7,a7,-1648 # b70 <malloc+0x170>
 1e8:	bded                	j	e2 <main+0xe2>
    case SRC_UVMALLOC:   return "UVMALLOC";
 1ea:	00001897          	auipc	a7,0x1
 1ee:	99688893          	addi	a7,a7,-1642 # b80 <malloc+0x180>
 1f2:	bdc5                	j	e2 <main+0xe2>
    case SRC_UVMDEALLOC: return "UVMDEALLOC";
 1f4:	00001897          	auipc	a7,0x1
 1f8:	99c88893          	addi	a7,a7,-1636 # b90 <malloc+0x190>
 1fc:	b5dd                	j	e2 <main+0xe2>
    case SRC_VMFAULT:    return "VMFAULT";
 1fe:	00001897          	auipc	a7,0x1
 202:	9a288893          	addi	a7,a7,-1630 # ba0 <malloc+0x1a0>
 206:	bdf1                	j	e2 <main+0xe2>
    default:             return "UNKNOWN";
 208:	88de                	mv	a7,s7
 20a:	bde1                	j	e2 <main+0xe2>
  switch(s){
 20c:	00001897          	auipc	a7,0x1
 210:	94488893          	addi	a7,a7,-1724 # b50 <malloc+0x150>
 214:	b5f9                	j	e2 <main+0xe2>
    }
  }

 

  exit(0);
 216:	4501                	li	a0,0
 218:	2ba000ef          	jal	4d2 <exit>

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
 228:	2aa000ef          	jal	4d2 <exit>

000000000000022c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e406                	sd	ra,8(sp)
 230:	e022                	sd	s0,0(sp)
 232:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 234:	87aa                	mv	a5,a0
 236:	0585                	addi	a1,a1,1
 238:	0785                	addi	a5,a5,1
 23a:	fff5c703          	lbu	a4,-1(a1)
 23e:	fee78fa3          	sb	a4,-1(a5)
 242:	fb75                	bnez	a4,236 <strcpy+0xa>
    ;
  return os;
}
 244:	60a2                	ld	ra,8(sp)
 246:	6402                	ld	s0,0(sp)
 248:	0141                	addi	sp,sp,16
 24a:	8082                	ret

000000000000024c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e406                	sd	ra,8(sp)
 250:	e022                	sd	s0,0(sp)
 252:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 254:	00054783          	lbu	a5,0(a0)
 258:	cb91                	beqz	a5,26c <strcmp+0x20>
 25a:	0005c703          	lbu	a4,0(a1)
 25e:	00f71763          	bne	a4,a5,26c <strcmp+0x20>
    p++, q++;
 262:	0505                	addi	a0,a0,1
 264:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 266:	00054783          	lbu	a5,0(a0)
 26a:	fbe5                	bnez	a5,25a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 26c:	0005c503          	lbu	a0,0(a1)
}
 270:	40a7853b          	subw	a0,a5,a0
 274:	60a2                	ld	ra,8(sp)
 276:	6402                	ld	s0,0(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret

000000000000027c <strlen>:

uint
strlen(const char *s)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e406                	sd	ra,8(sp)
 280:	e022                	sd	s0,0(sp)
 282:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 284:	00054783          	lbu	a5,0(a0)
 288:	cf91                	beqz	a5,2a4 <strlen+0x28>
 28a:	00150793          	addi	a5,a0,1
 28e:	86be                	mv	a3,a5
 290:	0785                	addi	a5,a5,1
 292:	fff7c703          	lbu	a4,-1(a5)
 296:	ff65                	bnez	a4,28e <strlen+0x12>
 298:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 29c:	60a2                	ld	ra,8(sp)
 29e:	6402                	ld	s0,0(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
  for(n = 0; s[n]; n++)
 2a4:	4501                	li	a0,0
 2a6:	bfdd                	j	29c <strlen+0x20>

00000000000002a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e406                	sd	ra,8(sp)
 2ac:	e022                	sd	s0,0(sp)
 2ae:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2b0:	ca19                	beqz	a2,2c6 <memset+0x1e>
 2b2:	87aa                	mv	a5,a0
 2b4:	1602                	slli	a2,a2,0x20
 2b6:	9201                	srli	a2,a2,0x20
 2b8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2bc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2c0:	0785                	addi	a5,a5,1
 2c2:	fee79de3          	bne	a5,a4,2bc <memset+0x14>
  }
  return dst;
}
 2c6:	60a2                	ld	ra,8(sp)
 2c8:	6402                	ld	s0,0(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret

00000000000002ce <strchr>:

char*
strchr(const char *s, char c)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e406                	sd	ra,8(sp)
 2d2:	e022                	sd	s0,0(sp)
 2d4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2d6:	00054783          	lbu	a5,0(a0)
 2da:	cf81                	beqz	a5,2f2 <strchr+0x24>
    if(*s == c)
 2dc:	00f58763          	beq	a1,a5,2ea <strchr+0x1c>
  for(; *s; s++)
 2e0:	0505                	addi	a0,a0,1
 2e2:	00054783          	lbu	a5,0(a0)
 2e6:	fbfd                	bnez	a5,2dc <strchr+0xe>
      return (char*)s;
  return 0;
 2e8:	4501                	li	a0,0
}
 2ea:	60a2                	ld	ra,8(sp)
 2ec:	6402                	ld	s0,0(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
  return 0;
 2f2:	4501                	li	a0,0
 2f4:	bfdd                	j	2ea <strchr+0x1c>

00000000000002f6 <gets>:

char*
gets(char *buf, int max)
{
 2f6:	711d                	addi	sp,sp,-96
 2f8:	ec86                	sd	ra,88(sp)
 2fa:	e8a2                	sd	s0,80(sp)
 2fc:	e4a6                	sd	s1,72(sp)
 2fe:	e0ca                	sd	s2,64(sp)
 300:	fc4e                	sd	s3,56(sp)
 302:	f852                	sd	s4,48(sp)
 304:	f456                	sd	s5,40(sp)
 306:	f05a                	sd	s6,32(sp)
 308:	ec5e                	sd	s7,24(sp)
 30a:	e862                	sd	s8,16(sp)
 30c:	1080                	addi	s0,sp,96
 30e:	8baa                	mv	s7,a0
 310:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 312:	892a                	mv	s2,a0
 314:	4481                	li	s1,0
    cc = read(0, &c, 1);
 316:	faf40b13          	addi	s6,s0,-81
 31a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 31c:	8c26                	mv	s8,s1
 31e:	0014899b          	addiw	s3,s1,1
 322:	84ce                	mv	s1,s3
 324:	0349d463          	bge	s3,s4,34c <gets+0x56>
    cc = read(0, &c, 1);
 328:	8656                	mv	a2,s5
 32a:	85da                	mv	a1,s6
 32c:	4501                	li	a0,0
 32e:	1bc000ef          	jal	4ea <read>
    if(cc < 1)
 332:	00a05d63          	blez	a0,34c <gets+0x56>
      break;
    buf[i++] = c;
 336:	faf44783          	lbu	a5,-81(s0)
 33a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 33e:	0905                	addi	s2,s2,1
 340:	ff678713          	addi	a4,a5,-10
 344:	c319                	beqz	a4,34a <gets+0x54>
 346:	17cd                	addi	a5,a5,-13
 348:	fbf1                	bnez	a5,31c <gets+0x26>
    buf[i++] = c;
 34a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 34c:	9c5e                	add	s8,s8,s7
 34e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 352:	855e                	mv	a0,s7
 354:	60e6                	ld	ra,88(sp)
 356:	6446                	ld	s0,80(sp)
 358:	64a6                	ld	s1,72(sp)
 35a:	6906                	ld	s2,64(sp)
 35c:	79e2                	ld	s3,56(sp)
 35e:	7a42                	ld	s4,48(sp)
 360:	7aa2                	ld	s5,40(sp)
 362:	7b02                	ld	s6,32(sp)
 364:	6be2                	ld	s7,24(sp)
 366:	6c42                	ld	s8,16(sp)
 368:	6125                	addi	sp,sp,96
 36a:	8082                	ret

000000000000036c <stat>:

int
stat(const char *n, struct stat *st)
{
 36c:	1101                	addi	sp,sp,-32
 36e:	ec06                	sd	ra,24(sp)
 370:	e822                	sd	s0,16(sp)
 372:	e04a                	sd	s2,0(sp)
 374:	1000                	addi	s0,sp,32
 376:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 378:	4581                	li	a1,0
 37a:	198000ef          	jal	512 <open>
  if(fd < 0)
 37e:	02054263          	bltz	a0,3a2 <stat+0x36>
 382:	e426                	sd	s1,8(sp)
 384:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 386:	85ca                	mv	a1,s2
 388:	1a2000ef          	jal	52a <fstat>
 38c:	892a                	mv	s2,a0
  close(fd);
 38e:	8526                	mv	a0,s1
 390:	16a000ef          	jal	4fa <close>
  return r;
 394:	64a2                	ld	s1,8(sp)
}
 396:	854a                	mv	a0,s2
 398:	60e2                	ld	ra,24(sp)
 39a:	6442                	ld	s0,16(sp)
 39c:	6902                	ld	s2,0(sp)
 39e:	6105                	addi	sp,sp,32
 3a0:	8082                	ret
    return -1;
 3a2:	57fd                	li	a5,-1
 3a4:	893e                	mv	s2,a5
 3a6:	bfc5                	j	396 <stat+0x2a>

00000000000003a8 <atoi>:

int
atoi(const char *s)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e406                	sd	ra,8(sp)
 3ac:	e022                	sd	s0,0(sp)
 3ae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b0:	00054683          	lbu	a3,0(a0)
 3b4:	fd06879b          	addiw	a5,a3,-48
 3b8:	0ff7f793          	zext.b	a5,a5
 3bc:	4625                	li	a2,9
 3be:	02f66963          	bltu	a2,a5,3f0 <atoi+0x48>
 3c2:	872a                	mv	a4,a0
  n = 0;
 3c4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3c6:	0705                	addi	a4,a4,1
 3c8:	0025179b          	slliw	a5,a0,0x2
 3cc:	9fa9                	addw	a5,a5,a0
 3ce:	0017979b          	slliw	a5,a5,0x1
 3d2:	9fb5                	addw	a5,a5,a3
 3d4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3d8:	00074683          	lbu	a3,0(a4)
 3dc:	fd06879b          	addiw	a5,a3,-48
 3e0:	0ff7f793          	zext.b	a5,a5
 3e4:	fef671e3          	bgeu	a2,a5,3c6 <atoi+0x1e>
  return n;
}
 3e8:	60a2                	ld	ra,8(sp)
 3ea:	6402                	ld	s0,0(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret
  n = 0;
 3f0:	4501                	li	a0,0
 3f2:	bfdd                	j	3e8 <atoi+0x40>

00000000000003f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e406                	sd	ra,8(sp)
 3f8:	e022                	sd	s0,0(sp)
 3fa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3fc:	02b57563          	bgeu	a0,a1,426 <memmove+0x32>
    while(n-- > 0)
 400:	00c05f63          	blez	a2,41e <memmove+0x2a>
 404:	1602                	slli	a2,a2,0x20
 406:	9201                	srli	a2,a2,0x20
 408:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 40c:	872a                	mv	a4,a0
      *dst++ = *src++;
 40e:	0585                	addi	a1,a1,1
 410:	0705                	addi	a4,a4,1
 412:	fff5c683          	lbu	a3,-1(a1)
 416:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 41a:	fee79ae3          	bne	a5,a4,40e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 41e:	60a2                	ld	ra,8(sp)
 420:	6402                	ld	s0,0(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret
    while(n-- > 0)
 426:	fec05ce3          	blez	a2,41e <memmove+0x2a>
    dst += n;
 42a:	00c50733          	add	a4,a0,a2
    src += n;
 42e:	95b2                	add	a1,a1,a2
 430:	fff6079b          	addiw	a5,a2,-1
 434:	1782                	slli	a5,a5,0x20
 436:	9381                	srli	a5,a5,0x20
 438:	fff7c793          	not	a5,a5
 43c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 43e:	15fd                	addi	a1,a1,-1
 440:	177d                	addi	a4,a4,-1
 442:	0005c683          	lbu	a3,0(a1)
 446:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 44a:	fef71ae3          	bne	a4,a5,43e <memmove+0x4a>
 44e:	bfc1                	j	41e <memmove+0x2a>

0000000000000450 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 450:	1141                	addi	sp,sp,-16
 452:	e406                	sd	ra,8(sp)
 454:	e022                	sd	s0,0(sp)
 456:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 458:	c61d                	beqz	a2,486 <memcmp+0x36>
 45a:	1602                	slli	a2,a2,0x20
 45c:	9201                	srli	a2,a2,0x20
 45e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 462:	00054783          	lbu	a5,0(a0)
 466:	0005c703          	lbu	a4,0(a1)
 46a:	00e79863          	bne	a5,a4,47a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 46e:	0505                	addi	a0,a0,1
    p2++;
 470:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 472:	fed518e3          	bne	a0,a3,462 <memcmp+0x12>
  }
  return 0;
 476:	4501                	li	a0,0
 478:	a019                	j	47e <memcmp+0x2e>
      return *p1 - *p2;
 47a:	40e7853b          	subw	a0,a5,a4
}
 47e:	60a2                	ld	ra,8(sp)
 480:	6402                	ld	s0,0(sp)
 482:	0141                	addi	sp,sp,16
 484:	8082                	ret
  return 0;
 486:	4501                	li	a0,0
 488:	bfdd                	j	47e <memcmp+0x2e>

000000000000048a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 48a:	1141                	addi	sp,sp,-16
 48c:	e406                	sd	ra,8(sp)
 48e:	e022                	sd	s0,0(sp)
 490:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 492:	f63ff0ef          	jal	3f4 <memmove>
}
 496:	60a2                	ld	ra,8(sp)
 498:	6402                	ld	s0,0(sp)
 49a:	0141                	addi	sp,sp,16
 49c:	8082                	ret

000000000000049e <sbrk>:

char *
sbrk(int n) {
 49e:	1141                	addi	sp,sp,-16
 4a0:	e406                	sd	ra,8(sp)
 4a2:	e022                	sd	s0,0(sp)
 4a4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4a6:	4585                	li	a1,1
 4a8:	0b2000ef          	jal	55a <sys_sbrk>
}
 4ac:	60a2                	ld	ra,8(sp)
 4ae:	6402                	ld	s0,0(sp)
 4b0:	0141                	addi	sp,sp,16
 4b2:	8082                	ret

00000000000004b4 <sbrklazy>:

char *
sbrklazy(int n) {
 4b4:	1141                	addi	sp,sp,-16
 4b6:	e406                	sd	ra,8(sp)
 4b8:	e022                	sd	s0,0(sp)
 4ba:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4bc:	4589                	li	a1,2
 4be:	09c000ef          	jal	55a <sys_sbrk>
}
 4c2:	60a2                	ld	ra,8(sp)
 4c4:	6402                	ld	s0,0(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret

00000000000004ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4ca:	4885                	li	a7,1
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4d2:	4889                	li	a7,2
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <wait>:
.global wait
wait:
 li a7, SYS_wait
 4da:	488d                	li	a7,3
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4e2:	4891                	li	a7,4
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <read>:
.global read
read:
 li a7, SYS_read
 4ea:	4895                	li	a7,5
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <write>:
.global write
write:
 li a7, SYS_write
 4f2:	48c1                	li	a7,16
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <close>:
.global close
close:
 li a7, SYS_close
 4fa:	48d5                	li	a7,21
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <kill>:
.global kill
kill:
 li a7, SYS_kill
 502:	4899                	li	a7,6
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <exec>:
.global exec
exec:
 li a7, SYS_exec
 50a:	489d                	li	a7,7
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <open>:
.global open
open:
 li a7, SYS_open
 512:	48bd                	li	a7,15
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 51a:	48c5                	li	a7,17
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 522:	48c9                	li	a7,18
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 52a:	48a1                	li	a7,8
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <link>:
.global link
link:
 li a7, SYS_link
 532:	48cd                	li	a7,19
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 53a:	48d1                	li	a7,20
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 542:	48a5                	li	a7,9
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <dup>:
.global dup
dup:
 li a7, SYS_dup
 54a:	48a9                	li	a7,10
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 552:	48ad                	li	a7,11
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 55a:	48b1                	li	a7,12
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <pause>:
.global pause
pause:
 li a7, SYS_pause
 562:	48b5                	li	a7,13
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 56a:	48b9                	li	a7,14
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <csread>:
.global csread
csread:
 li a7, SYS_csread
 572:	48d9                	li	a7,22
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 57a:	48dd                	li	a7,23
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 582:	48e1                	li	a7,24
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <memread>:
.global memread
memread:
 li a7, SYS_memread
 58a:	48e5                	li	a7,25
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 592:	48e9                	li	a7,26
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 59a:	48ed                	li	a7,27
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5a2:	1101                	addi	sp,sp,-32
 5a4:	ec06                	sd	ra,24(sp)
 5a6:	e822                	sd	s0,16(sp)
 5a8:	1000                	addi	s0,sp,32
 5aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ae:	4605                	li	a2,1
 5b0:	fef40593          	addi	a1,s0,-17
 5b4:	f3fff0ef          	jal	4f2 <write>
}
 5b8:	60e2                	ld	ra,24(sp)
 5ba:	6442                	ld	s0,16(sp)
 5bc:	6105                	addi	sp,sp,32
 5be:	8082                	ret

00000000000005c0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5c0:	715d                	addi	sp,sp,-80
 5c2:	e486                	sd	ra,72(sp)
 5c4:	e0a2                	sd	s0,64(sp)
 5c6:	f84a                	sd	s2,48(sp)
 5c8:	f44e                	sd	s3,40(sp)
 5ca:	0880                	addi	s0,sp,80
 5cc:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5ce:	c6d1                	beqz	a3,65a <printint+0x9a>
 5d0:	0805d563          	bgez	a1,65a <printint+0x9a>
    neg = 1;
    x = -xx;
 5d4:	40b005b3          	neg	a1,a1
    neg = 1;
 5d8:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5da:	fb840993          	addi	s3,s0,-72
  neg = 0;
 5de:	86ce                	mv	a3,s3
  i = 0;
 5e0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5e2:	00000817          	auipc	a6,0x0
 5e6:	69680813          	addi	a6,a6,1686 # c78 <digits>
 5ea:	88ba                	mv	a7,a4
 5ec:	0017051b          	addiw	a0,a4,1
 5f0:	872a                	mv	a4,a0
 5f2:	02c5f7b3          	remu	a5,a1,a2
 5f6:	97c2                	add	a5,a5,a6
 5f8:	0007c783          	lbu	a5,0(a5)
 5fc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 600:	87ae                	mv	a5,a1
 602:	02c5d5b3          	divu	a1,a1,a2
 606:	0685                	addi	a3,a3,1
 608:	fec7f1e3          	bgeu	a5,a2,5ea <printint+0x2a>
  if(neg)
 60c:	00030c63          	beqz	t1,624 <printint+0x64>
    buf[i++] = '-';
 610:	fd050793          	addi	a5,a0,-48
 614:	00878533          	add	a0,a5,s0
 618:	02d00793          	li	a5,45
 61c:	fef50423          	sb	a5,-24(a0)
 620:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 624:	02e05563          	blez	a4,64e <printint+0x8e>
 628:	fc26                	sd	s1,56(sp)
 62a:	377d                	addiw	a4,a4,-1
 62c:	00e984b3          	add	s1,s3,a4
 630:	19fd                	addi	s3,s3,-1
 632:	99ba                	add	s3,s3,a4
 634:	1702                	slli	a4,a4,0x20
 636:	9301                	srli	a4,a4,0x20
 638:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 63c:	0004c583          	lbu	a1,0(s1)
 640:	854a                	mv	a0,s2
 642:	f61ff0ef          	jal	5a2 <putc>
  while(--i >= 0)
 646:	14fd                	addi	s1,s1,-1
 648:	ff349ae3          	bne	s1,s3,63c <printint+0x7c>
 64c:	74e2                	ld	s1,56(sp)
}
 64e:	60a6                	ld	ra,72(sp)
 650:	6406                	ld	s0,64(sp)
 652:	7942                	ld	s2,48(sp)
 654:	79a2                	ld	s3,40(sp)
 656:	6161                	addi	sp,sp,80
 658:	8082                	ret
  neg = 0;
 65a:	4301                	li	t1,0
 65c:	bfbd                	j	5da <printint+0x1a>

000000000000065e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 65e:	711d                	addi	sp,sp,-96
 660:	ec86                	sd	ra,88(sp)
 662:	e8a2                	sd	s0,80(sp)
 664:	e4a6                	sd	s1,72(sp)
 666:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 668:	0005c483          	lbu	s1,0(a1)
 66c:	22048363          	beqz	s1,892 <vprintf+0x234>
 670:	e0ca                	sd	s2,64(sp)
 672:	fc4e                	sd	s3,56(sp)
 674:	f852                	sd	s4,48(sp)
 676:	f456                	sd	s5,40(sp)
 678:	f05a                	sd	s6,32(sp)
 67a:	ec5e                	sd	s7,24(sp)
 67c:	e862                	sd	s8,16(sp)
 67e:	8b2a                	mv	s6,a0
 680:	8a2e                	mv	s4,a1
 682:	8bb2                	mv	s7,a2
  state = 0;
 684:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 686:	4901                	li	s2,0
 688:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 68a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 68e:	06400c13          	li	s8,100
 692:	a00d                	j	6b4 <vprintf+0x56>
        putc(fd, c0);
 694:	85a6                	mv	a1,s1
 696:	855a                	mv	a0,s6
 698:	f0bff0ef          	jal	5a2 <putc>
 69c:	a019                	j	6a2 <vprintf+0x44>
    } else if(state == '%'){
 69e:	03598363          	beq	s3,s5,6c4 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 6a2:	0019079b          	addiw	a5,s2,1
 6a6:	893e                	mv	s2,a5
 6a8:	873e                	mv	a4,a5
 6aa:	97d2                	add	a5,a5,s4
 6ac:	0007c483          	lbu	s1,0(a5)
 6b0:	1c048a63          	beqz	s1,884 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 6b4:	0004879b          	sext.w	a5,s1
    if(state == 0){
 6b8:	fe0993e3          	bnez	s3,69e <vprintf+0x40>
      if(c0 == '%'){
 6bc:	fd579ce3          	bne	a5,s5,694 <vprintf+0x36>
        state = '%';
 6c0:	89be                	mv	s3,a5
 6c2:	b7c5                	j	6a2 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 6c4:	00ea06b3          	add	a3,s4,a4
 6c8:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 6cc:	1c060863          	beqz	a2,89c <vprintf+0x23e>
      if(c0 == 'd'){
 6d0:	03878763          	beq	a5,s8,6fe <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6d4:	f9478693          	addi	a3,a5,-108
 6d8:	0016b693          	seqz	a3,a3
 6dc:	f9c60593          	addi	a1,a2,-100
 6e0:	e99d                	bnez	a1,716 <vprintf+0xb8>
 6e2:	ca95                	beqz	a3,716 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e4:	008b8493          	addi	s1,s7,8
 6e8:	4685                	li	a3,1
 6ea:	4629                	li	a2,10
 6ec:	000bb583          	ld	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	ecfff0ef          	jal	5c0 <printint>
        i += 1;
 6f6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f8:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b75d                	j	6a2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 6fe:	008b8493          	addi	s1,s7,8
 702:	4685                	li	a3,1
 704:	4629                	li	a2,10
 706:	000ba583          	lw	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	eb5ff0ef          	jal	5c0 <printint>
 710:	8ba6                	mv	s7,s1
      state = 0;
 712:	4981                	li	s3,0
 714:	b779                	j	6a2 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 716:	9752                	add	a4,a4,s4
 718:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 71c:	f9460713          	addi	a4,a2,-108
 720:	00173713          	seqz	a4,a4
 724:	8f75                	and	a4,a4,a3
 726:	f9c58513          	addi	a0,a1,-100
 72a:	18051363          	bnez	a0,8b0 <vprintf+0x252>
 72e:	18070163          	beqz	a4,8b0 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 732:	008b8493          	addi	s1,s7,8
 736:	4685                	li	a3,1
 738:	4629                	li	a2,10
 73a:	000bb583          	ld	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	e81ff0ef          	jal	5c0 <printint>
        i += 2;
 744:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 746:	8ba6                	mv	s7,s1
      state = 0;
 748:	4981                	li	s3,0
        i += 2;
 74a:	bfa1                	j	6a2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 74c:	008b8493          	addi	s1,s7,8
 750:	4681                	li	a3,0
 752:	4629                	li	a2,10
 754:	000be583          	lwu	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	e67ff0ef          	jal	5c0 <printint>
 75e:	8ba6                	mv	s7,s1
      state = 0;
 760:	4981                	li	s3,0
 762:	b781                	j	6a2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 764:	008b8493          	addi	s1,s7,8
 768:	4681                	li	a3,0
 76a:	4629                	li	a2,10
 76c:	000bb583          	ld	a1,0(s7)
 770:	855a                	mv	a0,s6
 772:	e4fff0ef          	jal	5c0 <printint>
        i += 1;
 776:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 778:	8ba6                	mv	s7,s1
      state = 0;
 77a:	4981                	li	s3,0
 77c:	b71d                	j	6a2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77e:	008b8493          	addi	s1,s7,8
 782:	4681                	li	a3,0
 784:	4629                	li	a2,10
 786:	000bb583          	ld	a1,0(s7)
 78a:	855a                	mv	a0,s6
 78c:	e35ff0ef          	jal	5c0 <printint>
        i += 2;
 790:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 792:	8ba6                	mv	s7,s1
      state = 0;
 794:	4981                	li	s3,0
        i += 2;
 796:	b731                	j	6a2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 798:	008b8493          	addi	s1,s7,8
 79c:	4681                	li	a3,0
 79e:	4641                	li	a2,16
 7a0:	000be583          	lwu	a1,0(s7)
 7a4:	855a                	mv	a0,s6
 7a6:	e1bff0ef          	jal	5c0 <printint>
 7aa:	8ba6                	mv	s7,s1
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	bdd5                	j	6a2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b0:	008b8493          	addi	s1,s7,8
 7b4:	4681                	li	a3,0
 7b6:	4641                	li	a2,16
 7b8:	000bb583          	ld	a1,0(s7)
 7bc:	855a                	mv	a0,s6
 7be:	e03ff0ef          	jal	5c0 <printint>
        i += 1;
 7c2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c4:	8ba6                	mv	s7,s1
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	bde9                	j	6a2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ca:	008b8493          	addi	s1,s7,8
 7ce:	4681                	li	a3,0
 7d0:	4641                	li	a2,16
 7d2:	000bb583          	ld	a1,0(s7)
 7d6:	855a                	mv	a0,s6
 7d8:	de9ff0ef          	jal	5c0 <printint>
        i += 2;
 7dc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7de:	8ba6                	mv	s7,s1
      state = 0;
 7e0:	4981                	li	s3,0
        i += 2;
 7e2:	b5c1                	j	6a2 <vprintf+0x44>
 7e4:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7e6:	008b8793          	addi	a5,s7,8
 7ea:	8cbe                	mv	s9,a5
 7ec:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7f0:	03000593          	li	a1,48
 7f4:	855a                	mv	a0,s6
 7f6:	dadff0ef          	jal	5a2 <putc>
  putc(fd, 'x');
 7fa:	07800593          	li	a1,120
 7fe:	855a                	mv	a0,s6
 800:	da3ff0ef          	jal	5a2 <putc>
 804:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 806:	00000b97          	auipc	s7,0x0
 80a:	472b8b93          	addi	s7,s7,1138 # c78 <digits>
 80e:	03c9d793          	srli	a5,s3,0x3c
 812:	97de                	add	a5,a5,s7
 814:	0007c583          	lbu	a1,0(a5)
 818:	855a                	mv	a0,s6
 81a:	d89ff0ef          	jal	5a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 81e:	0992                	slli	s3,s3,0x4
 820:	34fd                	addiw	s1,s1,-1
 822:	f4f5                	bnez	s1,80e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 824:	8be6                	mv	s7,s9
      state = 0;
 826:	4981                	li	s3,0
 828:	6ca2                	ld	s9,8(sp)
 82a:	bda5                	j	6a2 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 82c:	008b8493          	addi	s1,s7,8
 830:	000bc583          	lbu	a1,0(s7)
 834:	855a                	mv	a0,s6
 836:	d6dff0ef          	jal	5a2 <putc>
 83a:	8ba6                	mv	s7,s1
      state = 0;
 83c:	4981                	li	s3,0
 83e:	b595                	j	6a2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 840:	008b8993          	addi	s3,s7,8
 844:	000bb483          	ld	s1,0(s7)
 848:	cc91                	beqz	s1,864 <vprintf+0x206>
        for(; *s; s++)
 84a:	0004c583          	lbu	a1,0(s1)
 84e:	c985                	beqz	a1,87e <vprintf+0x220>
          putc(fd, *s);
 850:	855a                	mv	a0,s6
 852:	d51ff0ef          	jal	5a2 <putc>
        for(; *s; s++)
 856:	0485                	addi	s1,s1,1
 858:	0004c583          	lbu	a1,0(s1)
 85c:	f9f5                	bnez	a1,850 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 85e:	8bce                	mv	s7,s3
      state = 0;
 860:	4981                	li	s3,0
 862:	b581                	j	6a2 <vprintf+0x44>
          s = "(null)";
 864:	00000497          	auipc	s1,0x0
 868:	3cc48493          	addi	s1,s1,972 # c30 <malloc+0x230>
        for(; *s; s++)
 86c:	02800593          	li	a1,40
 870:	b7c5                	j	850 <vprintf+0x1f2>
        putc(fd, '%');
 872:	85be                	mv	a1,a5
 874:	855a                	mv	a0,s6
 876:	d2dff0ef          	jal	5a2 <putc>
      state = 0;
 87a:	4981                	li	s3,0
 87c:	b51d                	j	6a2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 87e:	8bce                	mv	s7,s3
      state = 0;
 880:	4981                	li	s3,0
 882:	b505                	j	6a2 <vprintf+0x44>
 884:	6906                	ld	s2,64(sp)
 886:	79e2                	ld	s3,56(sp)
 888:	7a42                	ld	s4,48(sp)
 88a:	7aa2                	ld	s5,40(sp)
 88c:	7b02                	ld	s6,32(sp)
 88e:	6be2                	ld	s7,24(sp)
 890:	6c42                	ld	s8,16(sp)
    }
  }
}
 892:	60e6                	ld	ra,88(sp)
 894:	6446                	ld	s0,80(sp)
 896:	64a6                	ld	s1,72(sp)
 898:	6125                	addi	sp,sp,96
 89a:	8082                	ret
      if(c0 == 'd'){
 89c:	06400713          	li	a4,100
 8a0:	e4e78fe3          	beq	a5,a4,6fe <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 8a4:	f9478693          	addi	a3,a5,-108
 8a8:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 8ac:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 8ae:	4701                	li	a4,0
      } else if(c0 == 'u'){
 8b0:	07500513          	li	a0,117
 8b4:	e8a78ce3          	beq	a5,a0,74c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 8b8:	f8b60513          	addi	a0,a2,-117
 8bc:	e119                	bnez	a0,8c2 <vprintf+0x264>
 8be:	ea0693e3          	bnez	a3,764 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 8c2:	f8b58513          	addi	a0,a1,-117
 8c6:	e119                	bnez	a0,8cc <vprintf+0x26e>
 8c8:	ea071be3          	bnez	a4,77e <vprintf+0x120>
      } else if(c0 == 'x'){
 8cc:	07800513          	li	a0,120
 8d0:	eca784e3          	beq	a5,a0,798 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 8d4:	f8860613          	addi	a2,a2,-120
 8d8:	e219                	bnez	a2,8de <vprintf+0x280>
 8da:	ec069be3          	bnez	a3,7b0 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 8de:	f8858593          	addi	a1,a1,-120
 8e2:	e199                	bnez	a1,8e8 <vprintf+0x28a>
 8e4:	ee0713e3          	bnez	a4,7ca <vprintf+0x16c>
      } else if(c0 == 'p'){
 8e8:	07000713          	li	a4,112
 8ec:	eee78ce3          	beq	a5,a4,7e4 <vprintf+0x186>
      } else if(c0 == 'c'){
 8f0:	06300713          	li	a4,99
 8f4:	f2e78ce3          	beq	a5,a4,82c <vprintf+0x1ce>
      } else if(c0 == 's'){
 8f8:	07300713          	li	a4,115
 8fc:	f4e782e3          	beq	a5,a4,840 <vprintf+0x1e2>
      } else if(c0 == '%'){
 900:	02500713          	li	a4,37
 904:	f6e787e3          	beq	a5,a4,872 <vprintf+0x214>
        putc(fd, '%');
 908:	02500593          	li	a1,37
 90c:	855a                	mv	a0,s6
 90e:	c95ff0ef          	jal	5a2 <putc>
        putc(fd, c0);
 912:	85a6                	mv	a1,s1
 914:	855a                	mv	a0,s6
 916:	c8dff0ef          	jal	5a2 <putc>
      state = 0;
 91a:	4981                	li	s3,0
 91c:	b359                	j	6a2 <vprintf+0x44>

000000000000091e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 91e:	715d                	addi	sp,sp,-80
 920:	ec06                	sd	ra,24(sp)
 922:	e822                	sd	s0,16(sp)
 924:	1000                	addi	s0,sp,32
 926:	e010                	sd	a2,0(s0)
 928:	e414                	sd	a3,8(s0)
 92a:	e818                	sd	a4,16(s0)
 92c:	ec1c                	sd	a5,24(s0)
 92e:	03043023          	sd	a6,32(s0)
 932:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 936:	8622                	mv	a2,s0
 938:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 93c:	d23ff0ef          	jal	65e <vprintf>
}
 940:	60e2                	ld	ra,24(sp)
 942:	6442                	ld	s0,16(sp)
 944:	6161                	addi	sp,sp,80
 946:	8082                	ret

0000000000000948 <printf>:

void
printf(const char *fmt, ...)
{
 948:	711d                	addi	sp,sp,-96
 94a:	ec06                	sd	ra,24(sp)
 94c:	e822                	sd	s0,16(sp)
 94e:	1000                	addi	s0,sp,32
 950:	e40c                	sd	a1,8(s0)
 952:	e810                	sd	a2,16(s0)
 954:	ec14                	sd	a3,24(s0)
 956:	f018                	sd	a4,32(s0)
 958:	f41c                	sd	a5,40(s0)
 95a:	03043823          	sd	a6,48(s0)
 95e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 962:	00840613          	addi	a2,s0,8
 966:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 96a:	85aa                	mv	a1,a0
 96c:	4505                	li	a0,1
 96e:	cf1ff0ef          	jal	65e <vprintf>
}
 972:	60e2                	ld	ra,24(sp)
 974:	6442                	ld	s0,16(sp)
 976:	6125                	addi	sp,sp,96
 978:	8082                	ret

000000000000097a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 97a:	1141                	addi	sp,sp,-16
 97c:	e406                	sd	ra,8(sp)
 97e:	e022                	sd	s0,0(sp)
 980:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 982:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 986:	00000797          	auipc	a5,0x0
 98a:	6827b783          	ld	a5,1666(a5) # 1008 <freep>
 98e:	a039                	j	99c <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 990:	6398                	ld	a4,0(a5)
 992:	00e7e463          	bltu	a5,a4,99a <free+0x20>
 996:	00e6ea63          	bltu	a3,a4,9aa <free+0x30>
{
 99a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99c:	fed7fae3          	bgeu	a5,a3,990 <free+0x16>
 9a0:	6398                	ld	a4,0(a5)
 9a2:	00e6e463          	bltu	a3,a4,9aa <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a6:	fee7eae3          	bltu	a5,a4,99a <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9aa:	ff852583          	lw	a1,-8(a0)
 9ae:	6390                	ld	a2,0(a5)
 9b0:	02059813          	slli	a6,a1,0x20
 9b4:	01c85713          	srli	a4,a6,0x1c
 9b8:	9736                	add	a4,a4,a3
 9ba:	02e60563          	beq	a2,a4,9e4 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 9be:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 9c2:	4790                	lw	a2,8(a5)
 9c4:	02061593          	slli	a1,a2,0x20
 9c8:	01c5d713          	srli	a4,a1,0x1c
 9cc:	973e                	add	a4,a4,a5
 9ce:	02e68263          	beq	a3,a4,9f2 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 9d2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9d4:	00000717          	auipc	a4,0x0
 9d8:	62f73a23          	sd	a5,1588(a4) # 1008 <freep>
}
 9dc:	60a2                	ld	ra,8(sp)
 9de:	6402                	ld	s0,0(sp)
 9e0:	0141                	addi	sp,sp,16
 9e2:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 9e4:	4618                	lw	a4,8(a2)
 9e6:	9f2d                	addw	a4,a4,a1
 9e8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ec:	6398                	ld	a4,0(a5)
 9ee:	6310                	ld	a2,0(a4)
 9f0:	b7f9                	j	9be <free+0x44>
    p->s.size += bp->s.size;
 9f2:	ff852703          	lw	a4,-8(a0)
 9f6:	9f31                	addw	a4,a4,a2
 9f8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9fa:	ff053683          	ld	a3,-16(a0)
 9fe:	bfd1                	j	9d2 <free+0x58>

0000000000000a00 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a00:	7139                	addi	sp,sp,-64
 a02:	fc06                	sd	ra,56(sp)
 a04:	f822                	sd	s0,48(sp)
 a06:	f04a                	sd	s2,32(sp)
 a08:	ec4e                	sd	s3,24(sp)
 a0a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a0c:	02051993          	slli	s3,a0,0x20
 a10:	0209d993          	srli	s3,s3,0x20
 a14:	09bd                	addi	s3,s3,15
 a16:	0049d993          	srli	s3,s3,0x4
 a1a:	2985                	addiw	s3,s3,1
 a1c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 a1e:	00000517          	auipc	a0,0x0
 a22:	5ea53503          	ld	a0,1514(a0) # 1008 <freep>
 a26:	c905                	beqz	a0,a56 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a28:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a2a:	4798                	lw	a4,8(a5)
 a2c:	09377663          	bgeu	a4,s3,ab8 <malloc+0xb8>
 a30:	f426                	sd	s1,40(sp)
 a32:	e852                	sd	s4,16(sp)
 a34:	e456                	sd	s5,8(sp)
 a36:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a38:	8a4e                	mv	s4,s3
 a3a:	6705                	lui	a4,0x1
 a3c:	00e9f363          	bgeu	s3,a4,a42 <malloc+0x42>
 a40:	6a05                	lui	s4,0x1
 a42:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a46:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a4a:	00000497          	auipc	s1,0x0
 a4e:	5be48493          	addi	s1,s1,1470 # 1008 <freep>
  if(p == SBRK_ERROR)
 a52:	5afd                	li	s5,-1
 a54:	a83d                	j	a92 <malloc+0x92>
 a56:	f426                	sd	s1,40(sp)
 a58:	e852                	sd	s4,16(sp)
 a5a:	e456                	sd	s5,8(sp)
 a5c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a5e:	00000797          	auipc	a5,0x0
 a62:	5b278793          	addi	a5,a5,1458 # 1010 <base>
 a66:	00000717          	auipc	a4,0x0
 a6a:	5af73123          	sd	a5,1442(a4) # 1008 <freep>
 a6e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a70:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a74:	b7d1                	j	a38 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a76:	6398                	ld	a4,0(a5)
 a78:	e118                	sd	a4,0(a0)
 a7a:	a899                	j	ad0 <malloc+0xd0>
  hp->s.size = nu;
 a7c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a80:	0541                	addi	a0,a0,16
 a82:	ef9ff0ef          	jal	97a <free>
  return freep;
 a86:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a88:	c125                	beqz	a0,ae8 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a8c:	4798                	lw	a4,8(a5)
 a8e:	03277163          	bgeu	a4,s2,ab0 <malloc+0xb0>
    if(p == freep)
 a92:	6098                	ld	a4,0(s1)
 a94:	853e                	mv	a0,a5
 a96:	fef71ae3          	bne	a4,a5,a8a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a9a:	8552                	mv	a0,s4
 a9c:	a03ff0ef          	jal	49e <sbrk>
  if(p == SBRK_ERROR)
 aa0:	fd551ee3          	bne	a0,s5,a7c <malloc+0x7c>
        return 0;
 aa4:	4501                	li	a0,0
 aa6:	74a2                	ld	s1,40(sp)
 aa8:	6a42                	ld	s4,16(sp)
 aaa:	6aa2                	ld	s5,8(sp)
 aac:	6b02                	ld	s6,0(sp)
 aae:	a03d                	j	adc <malloc+0xdc>
 ab0:	74a2                	ld	s1,40(sp)
 ab2:	6a42                	ld	s4,16(sp)
 ab4:	6aa2                	ld	s5,8(sp)
 ab6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ab8:	fae90fe3          	beq	s2,a4,a76 <malloc+0x76>
        p->s.size -= nunits;
 abc:	4137073b          	subw	a4,a4,s3
 ac0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ac2:	02071693          	slli	a3,a4,0x20
 ac6:	01c6d713          	srli	a4,a3,0x1c
 aca:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 acc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ad0:	00000717          	auipc	a4,0x0
 ad4:	52a73c23          	sd	a0,1336(a4) # 1008 <freep>
      return (void*)(p + 1);
 ad8:	01078513          	addi	a0,a5,16
  }
}
 adc:	70e2                	ld	ra,56(sp)
 ade:	7442                	ld	s0,48(sp)
 ae0:	7902                	ld	s2,32(sp)
 ae2:	69e2                	ld	s3,24(sp)
 ae4:	6121                	addi	sp,sp,64
 ae6:	8082                	ret
 ae8:	74a2                	ld	s1,40(sp)
 aea:	6a42                	ld	s4,16(sp)
 aec:	6aa2                	ld	s5,8(sp)
 aee:	6b02                	ld	s6,0(sp)
 af0:	b7f5                	j	adc <malloc+0xdc>
