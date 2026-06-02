
user/_csexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
    // نستخدم printf العادية هنا لأن أحداث المعالج ليست بكثافة أحداث الـ FS
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
           e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
}

int main(void) {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	e45e                	sd	s7,8(sp)
  14:	0880                	addi	s0,sp,80
    // تنبيه لبدء البرنامج
    printf("CS Export (Context Switch) starting...\n");
  16:	00001517          	auipc	a0,0x1
  1a:	95a50513          	addi	a0,a0,-1702 # 970 <malloc+0xfe>
  1e:	79c000ef          	jal	7ba <printf>

    while (1) {
        // قراءة أحداث المعالج فقط
        int n_cs = csread(cs_ev, 8);
  22:	4b21                	li	s6,8
  24:	00001a97          	auipc	s5,0x1
  28:	feca8a93          	addi	s5,s5,-20 # 1010 <cs_ev>
        for (int i = 0; i < n_cs; i++) {
            // نوع الحدث 1 عادة ما يرمز لتغيير السياق (Context Switch)
            if (cs_ev[i].type == 1)
  2c:	4985                	li	s3,1
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
  2e:	00001b97          	auipc	s7,0x1
  32:	96ab8b93          	addi	s7,s7,-1686 # 998 <malloc+0x126>
                print_cs_event(&cs_ev[i]);
        }
        
        // استخدام sleep أو pause لتقليل استهلاك المعالج
        pause(2); 
  36:	4a09                	li	s4,2
  38:	a01d                	j	5e <main+0x5e>
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
  3a:	ffc4a803          	lw	a6,-4(s1)
  3e:	87a6                	mv	a5,s1
  40:	ff84a703          	lw	a4,-8(s1)
  44:	ff04a683          	lw	a3,-16(s1)
  48:	fec4a603          	lw	a2,-20(s1)
  4c:	fe44b583          	ld	a1,-28(s1)
  50:	855e                	mv	a0,s7
  52:	768000ef          	jal	7ba <printf>
}
  56:	a03d                	j	84 <main+0x84>
        pause(2); 
  58:	8552                	mv	a0,s4
  5a:	37a000ef          	jal	3d4 <pause>
        int n_cs = csread(cs_ev, 8);
  5e:	85da                	mv	a1,s6
  60:	8556                	mv	a0,s5
  62:	382000ef          	jal	3e4 <csread>
        for (int i = 0; i < n_cs; i++) {
  66:	fea059e3          	blez	a0,58 <main+0x58>
  6a:	00001497          	auipc	s1,0x1
  6e:	fc248493          	addi	s1,s1,-62 # 102c <cs_ev+0x1c>
  72:	00151913          	slli	s2,a0,0x1
  76:	992a                	add	s2,s2,a0
  78:	0912                	slli	s2,s2,0x4
  7a:	9926                	add	s2,s2,s1
            if (cs_ev[i].type == 1)
  7c:	ff44a783          	lw	a5,-12(s1)
  80:	fb378de3          	beq	a5,s3,3a <main+0x3a>
        for (int i = 0; i < n_cs; i++) {
  84:	03048493          	addi	s1,s1,48
  88:	ff249ae3          	bne	s1,s2,7c <main+0x7c>
  8c:	b7f1                	j	58 <main+0x58>

000000000000008e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e406                	sd	ra,8(sp)
  92:	e022                	sd	s0,0(sp)
  94:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  96:	f6bff0ef          	jal	0 <main>
  exit(r);
  9a:	2aa000ef          	jal	344 <exit>

000000000000009e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e406                	sd	ra,8(sp)
  a2:	e022                	sd	s0,0(sp)
  a4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a6:	87aa                	mv	a5,a0
  a8:	0585                	addi	a1,a1,1
  aa:	0785                	addi	a5,a5,1
  ac:	fff5c703          	lbu	a4,-1(a1)
  b0:	fee78fa3          	sb	a4,-1(a5)
  b4:	fb75                	bnez	a4,a8 <strcpy+0xa>
    ;
  return os;
}
  b6:	60a2                	ld	ra,8(sp)
  b8:	6402                	ld	s0,0(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret

00000000000000be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e406                	sd	ra,8(sp)
  c2:	e022                	sd	s0,0(sp)
  c4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	cb91                	beqz	a5,de <strcmp+0x20>
  cc:	0005c703          	lbu	a4,0(a1)
  d0:	00f71763          	bne	a4,a5,de <strcmp+0x20>
    p++, q++;
  d4:	0505                	addi	a0,a0,1
  d6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d8:	00054783          	lbu	a5,0(a0)
  dc:	fbe5                	bnez	a5,cc <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  de:	0005c503          	lbu	a0,0(a1)
}
  e2:	40a7853b          	subw	a0,a5,a0
  e6:	60a2                	ld	ra,8(sp)
  e8:	6402                	ld	s0,0(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret

00000000000000ee <strlen>:

uint
strlen(const char *s)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e406                	sd	ra,8(sp)
  f2:	e022                	sd	s0,0(sp)
  f4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cf91                	beqz	a5,116 <strlen+0x28>
  fc:	00150793          	addi	a5,a0,1
 100:	86be                	mv	a3,a5
 102:	0785                	addi	a5,a5,1
 104:	fff7c703          	lbu	a4,-1(a5)
 108:	ff65                	bnez	a4,100 <strlen+0x12>
 10a:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 10e:	60a2                	ld	ra,8(sp)
 110:	6402                	ld	s0,0(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret
  for(n = 0; s[n]; n++)
 116:	4501                	li	a0,0
 118:	bfdd                	j	10e <strlen+0x20>

000000000000011a <memset>:

void*
memset(void *dst, int c, uint n)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e406                	sd	ra,8(sp)
 11e:	e022                	sd	s0,0(sp)
 120:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 122:	ca19                	beqz	a2,138 <memset+0x1e>
 124:	87aa                	mv	a5,a0
 126:	1602                	slli	a2,a2,0x20
 128:	9201                	srli	a2,a2,0x20
 12a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 12e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 132:	0785                	addi	a5,a5,1
 134:	fee79de3          	bne	a5,a4,12e <memset+0x14>
  }
  return dst;
}
 138:	60a2                	ld	ra,8(sp)
 13a:	6402                	ld	s0,0(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret

0000000000000140 <strchr>:

char*
strchr(const char *s, char c)
{
 140:	1141                	addi	sp,sp,-16
 142:	e406                	sd	ra,8(sp)
 144:	e022                	sd	s0,0(sp)
 146:	0800                	addi	s0,sp,16
  for(; *s; s++)
 148:	00054783          	lbu	a5,0(a0)
 14c:	cf81                	beqz	a5,164 <strchr+0x24>
    if(*s == c)
 14e:	00f58763          	beq	a1,a5,15c <strchr+0x1c>
  for(; *s; s++)
 152:	0505                	addi	a0,a0,1
 154:	00054783          	lbu	a5,0(a0)
 158:	fbfd                	bnez	a5,14e <strchr+0xe>
      return (char*)s;
  return 0;
 15a:	4501                	li	a0,0
}
 15c:	60a2                	ld	ra,8(sp)
 15e:	6402                	ld	s0,0(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret
  return 0;
 164:	4501                	li	a0,0
 166:	bfdd                	j	15c <strchr+0x1c>

0000000000000168 <gets>:

char*
gets(char *buf, int max)
{
 168:	711d                	addi	sp,sp,-96
 16a:	ec86                	sd	ra,88(sp)
 16c:	e8a2                	sd	s0,80(sp)
 16e:	e4a6                	sd	s1,72(sp)
 170:	e0ca                	sd	s2,64(sp)
 172:	fc4e                	sd	s3,56(sp)
 174:	f852                	sd	s4,48(sp)
 176:	f456                	sd	s5,40(sp)
 178:	f05a                	sd	s6,32(sp)
 17a:	ec5e                	sd	s7,24(sp)
 17c:	e862                	sd	s8,16(sp)
 17e:	1080                	addi	s0,sp,96
 180:	8baa                	mv	s7,a0
 182:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 184:	892a                	mv	s2,a0
 186:	4481                	li	s1,0
    cc = read(0, &c, 1);
 188:	faf40b13          	addi	s6,s0,-81
 18c:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 18e:	8c26                	mv	s8,s1
 190:	0014899b          	addiw	s3,s1,1
 194:	84ce                	mv	s1,s3
 196:	0349d463          	bge	s3,s4,1be <gets+0x56>
    cc = read(0, &c, 1);
 19a:	8656                	mv	a2,s5
 19c:	85da                	mv	a1,s6
 19e:	4501                	li	a0,0
 1a0:	1bc000ef          	jal	35c <read>
    if(cc < 1)
 1a4:	00a05d63          	blez	a0,1be <gets+0x56>
      break;
    buf[i++] = c;
 1a8:	faf44783          	lbu	a5,-81(s0)
 1ac:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b0:	0905                	addi	s2,s2,1
 1b2:	ff678713          	addi	a4,a5,-10
 1b6:	c319                	beqz	a4,1bc <gets+0x54>
 1b8:	17cd                	addi	a5,a5,-13
 1ba:	fbf1                	bnez	a5,18e <gets+0x26>
    buf[i++] = c;
 1bc:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1be:	9c5e                	add	s8,s8,s7
 1c0:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1c4:	855e                	mv	a0,s7
 1c6:	60e6                	ld	ra,88(sp)
 1c8:	6446                	ld	s0,80(sp)
 1ca:	64a6                	ld	s1,72(sp)
 1cc:	6906                	ld	s2,64(sp)
 1ce:	79e2                	ld	s3,56(sp)
 1d0:	7a42                	ld	s4,48(sp)
 1d2:	7aa2                	ld	s5,40(sp)
 1d4:	7b02                	ld	s6,32(sp)
 1d6:	6be2                	ld	s7,24(sp)
 1d8:	6c42                	ld	s8,16(sp)
 1da:	6125                	addi	sp,sp,96
 1dc:	8082                	ret

00000000000001de <stat>:

int
stat(const char *n, struct stat *st)
{
 1de:	1101                	addi	sp,sp,-32
 1e0:	ec06                	sd	ra,24(sp)
 1e2:	e822                	sd	s0,16(sp)
 1e4:	e04a                	sd	s2,0(sp)
 1e6:	1000                	addi	s0,sp,32
 1e8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ea:	4581                	li	a1,0
 1ec:	198000ef          	jal	384 <open>
  if(fd < 0)
 1f0:	02054263          	bltz	a0,214 <stat+0x36>
 1f4:	e426                	sd	s1,8(sp)
 1f6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f8:	85ca                	mv	a1,s2
 1fa:	1a2000ef          	jal	39c <fstat>
 1fe:	892a                	mv	s2,a0
  close(fd);
 200:	8526                	mv	a0,s1
 202:	16a000ef          	jal	36c <close>
  return r;
 206:	64a2                	ld	s1,8(sp)
}
 208:	854a                	mv	a0,s2
 20a:	60e2                	ld	ra,24(sp)
 20c:	6442                	ld	s0,16(sp)
 20e:	6902                	ld	s2,0(sp)
 210:	6105                	addi	sp,sp,32
 212:	8082                	ret
    return -1;
 214:	57fd                	li	a5,-1
 216:	893e                	mv	s2,a5
 218:	bfc5                	j	208 <stat+0x2a>

000000000000021a <atoi>:

int
atoi(const char *s)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e406                	sd	ra,8(sp)
 21e:	e022                	sd	s0,0(sp)
 220:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 222:	00054683          	lbu	a3,0(a0)
 226:	fd06879b          	addiw	a5,a3,-48
 22a:	0ff7f793          	zext.b	a5,a5
 22e:	4625                	li	a2,9
 230:	02f66963          	bltu	a2,a5,262 <atoi+0x48>
 234:	872a                	mv	a4,a0
  n = 0;
 236:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 238:	0705                	addi	a4,a4,1
 23a:	0025179b          	slliw	a5,a0,0x2
 23e:	9fa9                	addw	a5,a5,a0
 240:	0017979b          	slliw	a5,a5,0x1
 244:	9fb5                	addw	a5,a5,a3
 246:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 24a:	00074683          	lbu	a3,0(a4)
 24e:	fd06879b          	addiw	a5,a3,-48
 252:	0ff7f793          	zext.b	a5,a5
 256:	fef671e3          	bgeu	a2,a5,238 <atoi+0x1e>
  return n;
}
 25a:	60a2                	ld	ra,8(sp)
 25c:	6402                	ld	s0,0(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
  n = 0;
 262:	4501                	li	a0,0
 264:	bfdd                	j	25a <atoi+0x40>

0000000000000266 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e406                	sd	ra,8(sp)
 26a:	e022                	sd	s0,0(sp)
 26c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 26e:	02b57563          	bgeu	a0,a1,298 <memmove+0x32>
    while(n-- > 0)
 272:	00c05f63          	blez	a2,290 <memmove+0x2a>
 276:	1602                	slli	a2,a2,0x20
 278:	9201                	srli	a2,a2,0x20
 27a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 27e:	872a                	mv	a4,a0
      *dst++ = *src++;
 280:	0585                	addi	a1,a1,1
 282:	0705                	addi	a4,a4,1
 284:	fff5c683          	lbu	a3,-1(a1)
 288:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28c:	fee79ae3          	bne	a5,a4,280 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 290:	60a2                	ld	ra,8(sp)
 292:	6402                	ld	s0,0(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret
    while(n-- > 0)
 298:	fec05ce3          	blez	a2,290 <memmove+0x2a>
    dst += n;
 29c:	00c50733          	add	a4,a0,a2
    src += n;
 2a0:	95b2                	add	a1,a1,a2
 2a2:	fff6079b          	addiw	a5,a2,-1
 2a6:	1782                	slli	a5,a5,0x20
 2a8:	9381                	srli	a5,a5,0x20
 2aa:	fff7c793          	not	a5,a5
 2ae:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b0:	15fd                	addi	a1,a1,-1
 2b2:	177d                	addi	a4,a4,-1
 2b4:	0005c683          	lbu	a3,0(a1)
 2b8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2bc:	fef71ae3          	bne	a4,a5,2b0 <memmove+0x4a>
 2c0:	bfc1                	j	290 <memmove+0x2a>

00000000000002c2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e406                	sd	ra,8(sp)
 2c6:	e022                	sd	s0,0(sp)
 2c8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ca:	c61d                	beqz	a2,2f8 <memcmp+0x36>
 2cc:	1602                	slli	a2,a2,0x20
 2ce:	9201                	srli	a2,a2,0x20
 2d0:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2d4:	00054783          	lbu	a5,0(a0)
 2d8:	0005c703          	lbu	a4,0(a1)
 2dc:	00e79863          	bne	a5,a4,2ec <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2e0:	0505                	addi	a0,a0,1
    p2++;
 2e2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e4:	fed518e3          	bne	a0,a3,2d4 <memcmp+0x12>
  }
  return 0;
 2e8:	4501                	li	a0,0
 2ea:	a019                	j	2f0 <memcmp+0x2e>
      return *p1 - *p2;
 2ec:	40e7853b          	subw	a0,a5,a4
}
 2f0:	60a2                	ld	ra,8(sp)
 2f2:	6402                	ld	s0,0(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret
  return 0;
 2f8:	4501                	li	a0,0
 2fa:	bfdd                	j	2f0 <memcmp+0x2e>

00000000000002fc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e406                	sd	ra,8(sp)
 300:	e022                	sd	s0,0(sp)
 302:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 304:	f63ff0ef          	jal	266 <memmove>
}
 308:	60a2                	ld	ra,8(sp)
 30a:	6402                	ld	s0,0(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <sbrk>:

char *
sbrk(int n) {
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 318:	4585                	li	a1,1
 31a:	0b2000ef          	jal	3cc <sys_sbrk>
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <sbrklazy>:

char *
sbrklazy(int n) {
 326:	1141                	addi	sp,sp,-16
 328:	e406                	sd	ra,8(sp)
 32a:	e022                	sd	s0,0(sp)
 32c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 32e:	4589                	li	a1,2
 330:	09c000ef          	jal	3cc <sys_sbrk>
}
 334:	60a2                	ld	ra,8(sp)
 336:	6402                	ld	s0,0(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret

000000000000033c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 33c:	4885                	li	a7,1
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <exit>:
.global exit
exit:
 li a7, SYS_exit
 344:	4889                	li	a7,2
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <wait>:
.global wait
wait:
 li a7, SYS_wait
 34c:	488d                	li	a7,3
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 354:	4891                	li	a7,4
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <read>:
.global read
read:
 li a7, SYS_read
 35c:	4895                	li	a7,5
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <write>:
.global write
write:
 li a7, SYS_write
 364:	48c1                	li	a7,16
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <close>:
.global close
close:
 li a7, SYS_close
 36c:	48d5                	li	a7,21
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <kill>:
.global kill
kill:
 li a7, SYS_kill
 374:	4899                	li	a7,6
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <exec>:
.global exec
exec:
 li a7, SYS_exec
 37c:	489d                	li	a7,7
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <open>:
.global open
open:
 li a7, SYS_open
 384:	48bd                	li	a7,15
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 38c:	48c5                	li	a7,17
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 394:	48c9                	li	a7,18
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 39c:	48a1                	li	a7,8
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <link>:
.global link
link:
 li a7, SYS_link
 3a4:	48cd                	li	a7,19
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ac:	48d1                	li	a7,20
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b4:	48a5                	li	a7,9
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3bc:	48a9                	li	a7,10
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c4:	48ad                	li	a7,11
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3cc:	48b1                	li	a7,12
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3d4:	48b5                	li	a7,13
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3dc:	48b9                	li	a7,14
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <csread>:
.global csread
csread:
 li a7, SYS_csread
 3e4:	48d9                	li	a7,22
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 3ec:	48dd                	li	a7,23
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 3f4:	48e1                	li	a7,24
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <memread>:
.global memread
memread:
 li a7, SYS_memread
 3fc:	48e5                	li	a7,25
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 404:	48e9                	li	a7,26
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 40c:	48ed                	li	a7,27
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 414:	1101                	addi	sp,sp,-32
 416:	ec06                	sd	ra,24(sp)
 418:	e822                	sd	s0,16(sp)
 41a:	1000                	addi	s0,sp,32
 41c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 420:	4605                	li	a2,1
 422:	fef40593          	addi	a1,s0,-17
 426:	f3fff0ef          	jal	364 <write>
}
 42a:	60e2                	ld	ra,24(sp)
 42c:	6442                	ld	s0,16(sp)
 42e:	6105                	addi	sp,sp,32
 430:	8082                	ret

0000000000000432 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 432:	715d                	addi	sp,sp,-80
 434:	e486                	sd	ra,72(sp)
 436:	e0a2                	sd	s0,64(sp)
 438:	f84a                	sd	s2,48(sp)
 43a:	f44e                	sd	s3,40(sp)
 43c:	0880                	addi	s0,sp,80
 43e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 440:	c6d1                	beqz	a3,4cc <printint+0x9a>
 442:	0805d563          	bgez	a1,4cc <printint+0x9a>
    neg = 1;
    x = -xx;
 446:	40b005b3          	neg	a1,a1
    neg = 1;
 44a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 44c:	fb840993          	addi	s3,s0,-72
  neg = 0;
 450:	86ce                	mv	a3,s3
  i = 0;
 452:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 454:	00000817          	auipc	a6,0x0
 458:	5a480813          	addi	a6,a6,1444 # 9f8 <digits>
 45c:	88ba                	mv	a7,a4
 45e:	0017051b          	addiw	a0,a4,1
 462:	872a                	mv	a4,a0
 464:	02c5f7b3          	remu	a5,a1,a2
 468:	97c2                	add	a5,a5,a6
 46a:	0007c783          	lbu	a5,0(a5)
 46e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 472:	87ae                	mv	a5,a1
 474:	02c5d5b3          	divu	a1,a1,a2
 478:	0685                	addi	a3,a3,1
 47a:	fec7f1e3          	bgeu	a5,a2,45c <printint+0x2a>
  if(neg)
 47e:	00030c63          	beqz	t1,496 <printint+0x64>
    buf[i++] = '-';
 482:	fd050793          	addi	a5,a0,-48
 486:	00878533          	add	a0,a5,s0
 48a:	02d00793          	li	a5,45
 48e:	fef50423          	sb	a5,-24(a0)
 492:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 496:	02e05563          	blez	a4,4c0 <printint+0x8e>
 49a:	fc26                	sd	s1,56(sp)
 49c:	377d                	addiw	a4,a4,-1
 49e:	00e984b3          	add	s1,s3,a4
 4a2:	19fd                	addi	s3,s3,-1
 4a4:	99ba                	add	s3,s3,a4
 4a6:	1702                	slli	a4,a4,0x20
 4a8:	9301                	srli	a4,a4,0x20
 4aa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ae:	0004c583          	lbu	a1,0(s1)
 4b2:	854a                	mv	a0,s2
 4b4:	f61ff0ef          	jal	414 <putc>
  while(--i >= 0)
 4b8:	14fd                	addi	s1,s1,-1
 4ba:	ff349ae3          	bne	s1,s3,4ae <printint+0x7c>
 4be:	74e2                	ld	s1,56(sp)
}
 4c0:	60a6                	ld	ra,72(sp)
 4c2:	6406                	ld	s0,64(sp)
 4c4:	7942                	ld	s2,48(sp)
 4c6:	79a2                	ld	s3,40(sp)
 4c8:	6161                	addi	sp,sp,80
 4ca:	8082                	ret
  neg = 0;
 4cc:	4301                	li	t1,0
 4ce:	bfbd                	j	44c <printint+0x1a>

00000000000004d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d0:	711d                	addi	sp,sp,-96
 4d2:	ec86                	sd	ra,88(sp)
 4d4:	e8a2                	sd	s0,80(sp)
 4d6:	e4a6                	sd	s1,72(sp)
 4d8:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4da:	0005c483          	lbu	s1,0(a1)
 4de:	22048363          	beqz	s1,704 <vprintf+0x234>
 4e2:	e0ca                	sd	s2,64(sp)
 4e4:	fc4e                	sd	s3,56(sp)
 4e6:	f852                	sd	s4,48(sp)
 4e8:	f456                	sd	s5,40(sp)
 4ea:	f05a                	sd	s6,32(sp)
 4ec:	ec5e                	sd	s7,24(sp)
 4ee:	e862                	sd	s8,16(sp)
 4f0:	8b2a                	mv	s6,a0
 4f2:	8a2e                	mv	s4,a1
 4f4:	8bb2                	mv	s7,a2
  state = 0;
 4f6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4f8:	4901                	li	s2,0
 4fa:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4fc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 500:	06400c13          	li	s8,100
 504:	a00d                	j	526 <vprintf+0x56>
        putc(fd, c0);
 506:	85a6                	mv	a1,s1
 508:	855a                	mv	a0,s6
 50a:	f0bff0ef          	jal	414 <putc>
 50e:	a019                	j	514 <vprintf+0x44>
    } else if(state == '%'){
 510:	03598363          	beq	s3,s5,536 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 514:	0019079b          	addiw	a5,s2,1
 518:	893e                	mv	s2,a5
 51a:	873e                	mv	a4,a5
 51c:	97d2                	add	a5,a5,s4
 51e:	0007c483          	lbu	s1,0(a5)
 522:	1c048a63          	beqz	s1,6f6 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 526:	0004879b          	sext.w	a5,s1
    if(state == 0){
 52a:	fe0993e3          	bnez	s3,510 <vprintf+0x40>
      if(c0 == '%'){
 52e:	fd579ce3          	bne	a5,s5,506 <vprintf+0x36>
        state = '%';
 532:	89be                	mv	s3,a5
 534:	b7c5                	j	514 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 536:	00ea06b3          	add	a3,s4,a4
 53a:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 53e:	1c060863          	beqz	a2,70e <vprintf+0x23e>
      if(c0 == 'd'){
 542:	03878763          	beq	a5,s8,570 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 546:	f9478693          	addi	a3,a5,-108
 54a:	0016b693          	seqz	a3,a3
 54e:	f9c60593          	addi	a1,a2,-100
 552:	e99d                	bnez	a1,588 <vprintf+0xb8>
 554:	ca95                	beqz	a3,588 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 556:	008b8493          	addi	s1,s7,8
 55a:	4685                	li	a3,1
 55c:	4629                	li	a2,10
 55e:	000bb583          	ld	a1,0(s7)
 562:	855a                	mv	a0,s6
 564:	ecfff0ef          	jal	432 <printint>
        i += 1;
 568:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 56a:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 56c:	4981                	li	s3,0
 56e:	b75d                	j	514 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 570:	008b8493          	addi	s1,s7,8
 574:	4685                	li	a3,1
 576:	4629                	li	a2,10
 578:	000ba583          	lw	a1,0(s7)
 57c:	855a                	mv	a0,s6
 57e:	eb5ff0ef          	jal	432 <printint>
 582:	8ba6                	mv	s7,s1
      state = 0;
 584:	4981                	li	s3,0
 586:	b779                	j	514 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 588:	9752                	add	a4,a4,s4
 58a:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 58e:	f9460713          	addi	a4,a2,-108
 592:	00173713          	seqz	a4,a4
 596:	8f75                	and	a4,a4,a3
 598:	f9c58513          	addi	a0,a1,-100
 59c:	18051363          	bnez	a0,722 <vprintf+0x252>
 5a0:	18070163          	beqz	a4,722 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a4:	008b8493          	addi	s1,s7,8
 5a8:	4685                	li	a3,1
 5aa:	4629                	li	a2,10
 5ac:	000bb583          	ld	a1,0(s7)
 5b0:	855a                	mv	a0,s6
 5b2:	e81ff0ef          	jal	432 <printint>
        i += 2;
 5b6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b8:	8ba6                	mv	s7,s1
      state = 0;
 5ba:	4981                	li	s3,0
        i += 2;
 5bc:	bfa1                	j	514 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5be:	008b8493          	addi	s1,s7,8
 5c2:	4681                	li	a3,0
 5c4:	4629                	li	a2,10
 5c6:	000be583          	lwu	a1,0(s7)
 5ca:	855a                	mv	a0,s6
 5cc:	e67ff0ef          	jal	432 <printint>
 5d0:	8ba6                	mv	s7,s1
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b781                	j	514 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d6:	008b8493          	addi	s1,s7,8
 5da:	4681                	li	a3,0
 5dc:	4629                	li	a2,10
 5de:	000bb583          	ld	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	e4fff0ef          	jal	432 <printint>
        i += 1;
 5e8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ea:	8ba6                	mv	s7,s1
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b71d                	j	514 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f0:	008b8493          	addi	s1,s7,8
 5f4:	4681                	li	a3,0
 5f6:	4629                	li	a2,10
 5f8:	000bb583          	ld	a1,0(s7)
 5fc:	855a                	mv	a0,s6
 5fe:	e35ff0ef          	jal	432 <printint>
        i += 2;
 602:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 604:	8ba6                	mv	s7,s1
      state = 0;
 606:	4981                	li	s3,0
        i += 2;
 608:	b731                	j	514 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 60a:	008b8493          	addi	s1,s7,8
 60e:	4681                	li	a3,0
 610:	4641                	li	a2,16
 612:	000be583          	lwu	a1,0(s7)
 616:	855a                	mv	a0,s6
 618:	e1bff0ef          	jal	432 <printint>
 61c:	8ba6                	mv	s7,s1
      state = 0;
 61e:	4981                	li	s3,0
 620:	bdd5                	j	514 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 622:	008b8493          	addi	s1,s7,8
 626:	4681                	li	a3,0
 628:	4641                	li	a2,16
 62a:	000bb583          	ld	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	e03ff0ef          	jal	432 <printint>
        i += 1;
 634:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 636:	8ba6                	mv	s7,s1
      state = 0;
 638:	4981                	li	s3,0
 63a:	bde9                	j	514 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 63c:	008b8493          	addi	s1,s7,8
 640:	4681                	li	a3,0
 642:	4641                	li	a2,16
 644:	000bb583          	ld	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	de9ff0ef          	jal	432 <printint>
        i += 2;
 64e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 650:	8ba6                	mv	s7,s1
      state = 0;
 652:	4981                	li	s3,0
        i += 2;
 654:	b5c1                	j	514 <vprintf+0x44>
 656:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 658:	008b8793          	addi	a5,s7,8
 65c:	8cbe                	mv	s9,a5
 65e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 662:	03000593          	li	a1,48
 666:	855a                	mv	a0,s6
 668:	dadff0ef          	jal	414 <putc>
  putc(fd, 'x');
 66c:	07800593          	li	a1,120
 670:	855a                	mv	a0,s6
 672:	da3ff0ef          	jal	414 <putc>
 676:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 678:	00000b97          	auipc	s7,0x0
 67c:	380b8b93          	addi	s7,s7,896 # 9f8 <digits>
 680:	03c9d793          	srli	a5,s3,0x3c
 684:	97de                	add	a5,a5,s7
 686:	0007c583          	lbu	a1,0(a5)
 68a:	855a                	mv	a0,s6
 68c:	d89ff0ef          	jal	414 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 690:	0992                	slli	s3,s3,0x4
 692:	34fd                	addiw	s1,s1,-1
 694:	f4f5                	bnez	s1,680 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 696:	8be6                	mv	s7,s9
      state = 0;
 698:	4981                	li	s3,0
 69a:	6ca2                	ld	s9,8(sp)
 69c:	bda5                	j	514 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 69e:	008b8493          	addi	s1,s7,8
 6a2:	000bc583          	lbu	a1,0(s7)
 6a6:	855a                	mv	a0,s6
 6a8:	d6dff0ef          	jal	414 <putc>
 6ac:	8ba6                	mv	s7,s1
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	b595                	j	514 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6b2:	008b8993          	addi	s3,s7,8
 6b6:	000bb483          	ld	s1,0(s7)
 6ba:	cc91                	beqz	s1,6d6 <vprintf+0x206>
        for(; *s; s++)
 6bc:	0004c583          	lbu	a1,0(s1)
 6c0:	c985                	beqz	a1,6f0 <vprintf+0x220>
          putc(fd, *s);
 6c2:	855a                	mv	a0,s6
 6c4:	d51ff0ef          	jal	414 <putc>
        for(; *s; s++)
 6c8:	0485                	addi	s1,s1,1
 6ca:	0004c583          	lbu	a1,0(s1)
 6ce:	f9f5                	bnez	a1,6c2 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6d0:	8bce                	mv	s7,s3
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	b581                	j	514 <vprintf+0x44>
          s = "(null)";
 6d6:	00000497          	auipc	s1,0x0
 6da:	31a48493          	addi	s1,s1,794 # 9f0 <malloc+0x17e>
        for(; *s; s++)
 6de:	02800593          	li	a1,40
 6e2:	b7c5                	j	6c2 <vprintf+0x1f2>
        putc(fd, '%');
 6e4:	85be                	mv	a1,a5
 6e6:	855a                	mv	a0,s6
 6e8:	d2dff0ef          	jal	414 <putc>
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b51d                	j	514 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6f0:	8bce                	mv	s7,s3
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	b505                	j	514 <vprintf+0x44>
 6f6:	6906                	ld	s2,64(sp)
 6f8:	79e2                	ld	s3,56(sp)
 6fa:	7a42                	ld	s4,48(sp)
 6fc:	7aa2                	ld	s5,40(sp)
 6fe:	7b02                	ld	s6,32(sp)
 700:	6be2                	ld	s7,24(sp)
 702:	6c42                	ld	s8,16(sp)
    }
  }
}
 704:	60e6                	ld	ra,88(sp)
 706:	6446                	ld	s0,80(sp)
 708:	64a6                	ld	s1,72(sp)
 70a:	6125                	addi	sp,sp,96
 70c:	8082                	ret
      if(c0 == 'd'){
 70e:	06400713          	li	a4,100
 712:	e4e78fe3          	beq	a5,a4,570 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 716:	f9478693          	addi	a3,a5,-108
 71a:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 71e:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 720:	4701                	li	a4,0
      } else if(c0 == 'u'){
 722:	07500513          	li	a0,117
 726:	e8a78ce3          	beq	a5,a0,5be <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 72a:	f8b60513          	addi	a0,a2,-117
 72e:	e119                	bnez	a0,734 <vprintf+0x264>
 730:	ea0693e3          	bnez	a3,5d6 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 734:	f8b58513          	addi	a0,a1,-117
 738:	e119                	bnez	a0,73e <vprintf+0x26e>
 73a:	ea071be3          	bnez	a4,5f0 <vprintf+0x120>
      } else if(c0 == 'x'){
 73e:	07800513          	li	a0,120
 742:	eca784e3          	beq	a5,a0,60a <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 746:	f8860613          	addi	a2,a2,-120
 74a:	e219                	bnez	a2,750 <vprintf+0x280>
 74c:	ec069be3          	bnez	a3,622 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 750:	f8858593          	addi	a1,a1,-120
 754:	e199                	bnez	a1,75a <vprintf+0x28a>
 756:	ee0713e3          	bnez	a4,63c <vprintf+0x16c>
      } else if(c0 == 'p'){
 75a:	07000713          	li	a4,112
 75e:	eee78ce3          	beq	a5,a4,656 <vprintf+0x186>
      } else if(c0 == 'c'){
 762:	06300713          	li	a4,99
 766:	f2e78ce3          	beq	a5,a4,69e <vprintf+0x1ce>
      } else if(c0 == 's'){
 76a:	07300713          	li	a4,115
 76e:	f4e782e3          	beq	a5,a4,6b2 <vprintf+0x1e2>
      } else if(c0 == '%'){
 772:	02500713          	li	a4,37
 776:	f6e787e3          	beq	a5,a4,6e4 <vprintf+0x214>
        putc(fd, '%');
 77a:	02500593          	li	a1,37
 77e:	855a                	mv	a0,s6
 780:	c95ff0ef          	jal	414 <putc>
        putc(fd, c0);
 784:	85a6                	mv	a1,s1
 786:	855a                	mv	a0,s6
 788:	c8dff0ef          	jal	414 <putc>
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b359                	j	514 <vprintf+0x44>

0000000000000790 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 790:	715d                	addi	sp,sp,-80
 792:	ec06                	sd	ra,24(sp)
 794:	e822                	sd	s0,16(sp)
 796:	1000                	addi	s0,sp,32
 798:	e010                	sd	a2,0(s0)
 79a:	e414                	sd	a3,8(s0)
 79c:	e818                	sd	a4,16(s0)
 79e:	ec1c                	sd	a5,24(s0)
 7a0:	03043023          	sd	a6,32(s0)
 7a4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a8:	8622                	mv	a2,s0
 7aa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ae:	d23ff0ef          	jal	4d0 <vprintf>
}
 7b2:	60e2                	ld	ra,24(sp)
 7b4:	6442                	ld	s0,16(sp)
 7b6:	6161                	addi	sp,sp,80
 7b8:	8082                	ret

00000000000007ba <printf>:

void
printf(const char *fmt, ...)
{
 7ba:	711d                	addi	sp,sp,-96
 7bc:	ec06                	sd	ra,24(sp)
 7be:	e822                	sd	s0,16(sp)
 7c0:	1000                	addi	s0,sp,32
 7c2:	e40c                	sd	a1,8(s0)
 7c4:	e810                	sd	a2,16(s0)
 7c6:	ec14                	sd	a3,24(s0)
 7c8:	f018                	sd	a4,32(s0)
 7ca:	f41c                	sd	a5,40(s0)
 7cc:	03043823          	sd	a6,48(s0)
 7d0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d4:	00840613          	addi	a2,s0,8
 7d8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7dc:	85aa                	mv	a1,a0
 7de:	4505                	li	a0,1
 7e0:	cf1ff0ef          	jal	4d0 <vprintf>
}
 7e4:	60e2                	ld	ra,24(sp)
 7e6:	6442                	ld	s0,16(sp)
 7e8:	6125                	addi	sp,sp,96
 7ea:	8082                	ret

00000000000007ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e406                	sd	ra,8(sp)
 7f0:	e022                	sd	s0,0(sp)
 7f2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f8:	00001797          	auipc	a5,0x1
 7fc:	8087b783          	ld	a5,-2040(a5) # 1000 <freep>
 800:	a039                	j	80e <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 802:	6398                	ld	a4,0(a5)
 804:	00e7e463          	bltu	a5,a4,80c <free+0x20>
 808:	00e6ea63          	bltu	a3,a4,81c <free+0x30>
{
 80c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80e:	fed7fae3          	bgeu	a5,a3,802 <free+0x16>
 812:	6398                	ld	a4,0(a5)
 814:	00e6e463          	bltu	a3,a4,81c <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 818:	fee7eae3          	bltu	a5,a4,80c <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 81c:	ff852583          	lw	a1,-8(a0)
 820:	6390                	ld	a2,0(a5)
 822:	02059813          	slli	a6,a1,0x20
 826:	01c85713          	srli	a4,a6,0x1c
 82a:	9736                	add	a4,a4,a3
 82c:	02e60563          	beq	a2,a4,856 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 834:	4790                	lw	a2,8(a5)
 836:	02061593          	slli	a1,a2,0x20
 83a:	01c5d713          	srli	a4,a1,0x1c
 83e:	973e                	add	a4,a4,a5
 840:	02e68263          	beq	a3,a4,864 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 844:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 846:	00000717          	auipc	a4,0x0
 84a:	7af73d23          	sd	a5,1978(a4) # 1000 <freep>
}
 84e:	60a2                	ld	ra,8(sp)
 850:	6402                	ld	s0,0(sp)
 852:	0141                	addi	sp,sp,16
 854:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 856:	4618                	lw	a4,8(a2)
 858:	9f2d                	addw	a4,a4,a1
 85a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 85e:	6398                	ld	a4,0(a5)
 860:	6310                	ld	a2,0(a4)
 862:	b7f9                	j	830 <free+0x44>
    p->s.size += bp->s.size;
 864:	ff852703          	lw	a4,-8(a0)
 868:	9f31                	addw	a4,a4,a2
 86a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 86c:	ff053683          	ld	a3,-16(a0)
 870:	bfd1                	j	844 <free+0x58>

0000000000000872 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 872:	7139                	addi	sp,sp,-64
 874:	fc06                	sd	ra,56(sp)
 876:	f822                	sd	s0,48(sp)
 878:	f04a                	sd	s2,32(sp)
 87a:	ec4e                	sd	s3,24(sp)
 87c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 87e:	02051993          	slli	s3,a0,0x20
 882:	0209d993          	srli	s3,s3,0x20
 886:	09bd                	addi	s3,s3,15
 888:	0049d993          	srli	s3,s3,0x4
 88c:	2985                	addiw	s3,s3,1
 88e:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 890:	00000517          	auipc	a0,0x0
 894:	77053503          	ld	a0,1904(a0) # 1000 <freep>
 898:	c905                	beqz	a0,8c8 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89c:	4798                	lw	a4,8(a5)
 89e:	09377663          	bgeu	a4,s3,92a <malloc+0xb8>
 8a2:	f426                	sd	s1,40(sp)
 8a4:	e852                	sd	s4,16(sp)
 8a6:	e456                	sd	s5,8(sp)
 8a8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8aa:	8a4e                	mv	s4,s3
 8ac:	6705                	lui	a4,0x1
 8ae:	00e9f363          	bgeu	s3,a4,8b4 <malloc+0x42>
 8b2:	6a05                	lui	s4,0x1
 8b4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8bc:	00000497          	auipc	s1,0x0
 8c0:	74448493          	addi	s1,s1,1860 # 1000 <freep>
  if(p == SBRK_ERROR)
 8c4:	5afd                	li	s5,-1
 8c6:	a83d                	j	904 <malloc+0x92>
 8c8:	f426                	sd	s1,40(sp)
 8ca:	e852                	sd	s4,16(sp)
 8cc:	e456                	sd	s5,8(sp)
 8ce:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8d0:	00001797          	auipc	a5,0x1
 8d4:	8c078793          	addi	a5,a5,-1856 # 1190 <base>
 8d8:	00000717          	auipc	a4,0x0
 8dc:	72f73423          	sd	a5,1832(a4) # 1000 <freep>
 8e0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e6:	b7d1                	j	8aa <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8e8:	6398                	ld	a4,0(a5)
 8ea:	e118                	sd	a4,0(a0)
 8ec:	a899                	j	942 <malloc+0xd0>
  hp->s.size = nu;
 8ee:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f2:	0541                	addi	a0,a0,16
 8f4:	ef9ff0ef          	jal	7ec <free>
  return freep;
 8f8:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8fa:	c125                	beqz	a0,95a <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8fe:	4798                	lw	a4,8(a5)
 900:	03277163          	bgeu	a4,s2,922 <malloc+0xb0>
    if(p == freep)
 904:	6098                	ld	a4,0(s1)
 906:	853e                	mv	a0,a5
 908:	fef71ae3          	bne	a4,a5,8fc <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 90c:	8552                	mv	a0,s4
 90e:	a03ff0ef          	jal	310 <sbrk>
  if(p == SBRK_ERROR)
 912:	fd551ee3          	bne	a0,s5,8ee <malloc+0x7c>
        return 0;
 916:	4501                	li	a0,0
 918:	74a2                	ld	s1,40(sp)
 91a:	6a42                	ld	s4,16(sp)
 91c:	6aa2                	ld	s5,8(sp)
 91e:	6b02                	ld	s6,0(sp)
 920:	a03d                	j	94e <malloc+0xdc>
 922:	74a2                	ld	s1,40(sp)
 924:	6a42                	ld	s4,16(sp)
 926:	6aa2                	ld	s5,8(sp)
 928:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 92a:	fae90fe3          	beq	s2,a4,8e8 <malloc+0x76>
        p->s.size -= nunits;
 92e:	4137073b          	subw	a4,a4,s3
 932:	c798                	sw	a4,8(a5)
        p += p->s.size;
 934:	02071693          	slli	a3,a4,0x20
 938:	01c6d713          	srli	a4,a3,0x1c
 93c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 93e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 942:	00000717          	auipc	a4,0x0
 946:	6aa73f23          	sd	a0,1726(a4) # 1000 <freep>
      return (void*)(p + 1);
 94a:	01078513          	addi	a0,a5,16
  }
}
 94e:	70e2                	ld	ra,56(sp)
 950:	7442                	ld	s0,48(sp)
 952:	7902                	ld	s2,32(sp)
 954:	69e2                	ld	s3,24(sp)
 956:	6121                	addi	sp,sp,64
 958:	8082                	ret
 95a:	74a2                	ld	s1,40(sp)
 95c:	6a42                	ld	s4,16(sp)
 95e:	6aa2                	ld	s5,8(sp)
 960:	6b02                	ld	s6,0(sp)
 962:	b7f5                	j	94e <malloc+0xdc>
