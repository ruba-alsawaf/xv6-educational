
user/_csexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
    // نستخدم printf العادية هنا لأن أحداث المعالج ليست بكثافة أحداث الـ FS
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
           e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
}

int main(void) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
    // تنبيه لبدء البرنامج
    printf("CS Export (Context Switch) starting...\n");
  12:	00001517          	auipc	a0,0x1
  16:	93e50513          	addi	a0,a0,-1730 # 950 <malloc+0xfc>
  1a:	786000ef          	jal	7a0 <printf>

    while (1) {
        // قراءة أحداث المعالج فقط
        int n_cs = csread(cs_ev, 8);
  1e:	00001a17          	auipc	s4,0x1
  22:	ff2a0a13          	addi	s4,s4,-14 # 1010 <cs_ev>
        for (int i = 0; i < n_cs; i++) {
            // نوع الحدث 1 عادة ما يرمز لتغيير السياق (Context Switch)
            if (cs_ev[i].type == 1)
  26:	4985                	li	s3,1
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
  28:	00001a97          	auipc	s5,0x1
  2c:	950a8a93          	addi	s5,s5,-1712 # 978 <malloc+0x124>
  30:	a01d                	j	56 <main+0x56>
  32:	ffc4a803          	lw	a6,-4(s1)
  36:	87a6                	mv	a5,s1
  38:	ff84a703          	lw	a4,-8(s1)
  3c:	ff04a683          	lw	a3,-16(s1)
  40:	fec4a603          	lw	a2,-20(s1)
  44:	fe44b583          	ld	a1,-28(s1)
  48:	8556                	mv	a0,s5
  4a:	756000ef          	jal	7a0 <printf>
}
  4e:	a03d                	j	7c <main+0x7c>
                print_cs_event(&cs_ev[i]);
        }
        
        // استخدام sleep أو pause لتقليل استهلاك المعالج
        pause(2); 
  50:	4509                	li	a0,2
  52:	396000ef          	jal	3e8 <pause>
        int n_cs = csread(cs_ev, 8);
  56:	45a1                	li	a1,8
  58:	8552                	mv	a0,s4
  5a:	39e000ef          	jal	3f8 <csread>
        for (int i = 0; i < n_cs; i++) {
  5e:	fea059e3          	blez	a0,50 <main+0x50>
  62:	00001497          	auipc	s1,0x1
  66:	fca48493          	addi	s1,s1,-54 # 102c <cs_ev+0x1c>
  6a:	00151913          	slli	s2,a0,0x1
  6e:	992a                	add	s2,s2,a0
  70:	0912                	slli	s2,s2,0x4
  72:	9926                	add	s2,s2,s1
            if (cs_ev[i].type == 1)
  74:	ff44a783          	lw	a5,-12(s1)
  78:	fb378de3          	beq	a5,s3,32 <main+0x32>
        for (int i = 0; i < n_cs; i++) {
  7c:	03048493          	addi	s1,s1,48
  80:	ff249ae3          	bne	s1,s2,74 <main+0x74>
  84:	b7f1                	j	50 <main+0x50>

0000000000000086 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  86:	1141                	addi	sp,sp,-16
  88:	e406                	sd	ra,8(sp)
  8a:	e022                	sd	s0,0(sp)
  8c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  8e:	f73ff0ef          	jal	0 <main>
  exit(r);
  92:	2c6000ef          	jal	358 <exit>

0000000000000096 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9c:	87aa                	mv	a5,a0
  9e:	0585                	addi	a1,a1,1
  a0:	0785                	addi	a5,a5,1
  a2:	fff5c703          	lbu	a4,-1(a1)
  a6:	fee78fa3          	sb	a4,-1(a5)
  aa:	fb75                	bnez	a4,9e <strcpy+0x8>
    ;
  return os;
}
  ac:	6422                	ld	s0,8(sp)
  ae:	0141                	addi	sp,sp,16
  b0:	8082                	ret

00000000000000b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e422                	sd	s0,8(sp)
  b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	cb91                	beqz	a5,d0 <strcmp+0x1e>
  be:	0005c703          	lbu	a4,0(a1)
  c2:	00f71763          	bne	a4,a5,d0 <strcmp+0x1e>
    p++, q++;
  c6:	0505                	addi	a0,a0,1
  c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	fbe5                	bnez	a5,be <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  d0:	0005c503          	lbu	a0,0(a1)
}
  d4:	40a7853b          	subw	a0,a5,a0
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret

00000000000000de <strlen>:

uint
strlen(const char *s)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	cf91                	beqz	a5,104 <strlen+0x26>
  ea:	0505                	addi	a0,a0,1
  ec:	87aa                	mv	a5,a0
  ee:	86be                	mv	a3,a5
  f0:	0785                	addi	a5,a5,1
  f2:	fff7c703          	lbu	a4,-1(a5)
  f6:	ff65                	bnez	a4,ee <strlen+0x10>
  f8:	40a6853b          	subw	a0,a3,a0
  fc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret
  for(n = 0; s[n]; n++)
 104:	4501                	li	a0,0
 106:	bfe5                	j	fe <strlen+0x20>

0000000000000108 <memset>:

void*
memset(void *dst, int c, uint n)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 10e:	ca19                	beqz	a2,124 <memset+0x1c>
 110:	87aa                	mv	a5,a0
 112:	1602                	slli	a2,a2,0x20
 114:	9201                	srli	a2,a2,0x20
 116:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 11a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 11e:	0785                	addi	a5,a5,1
 120:	fee79de3          	bne	a5,a4,11a <memset+0x12>
  }
  return dst;
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret

000000000000012a <strchr>:

char*
strchr(const char *s, char c)
{
 12a:	1141                	addi	sp,sp,-16
 12c:	e422                	sd	s0,8(sp)
 12e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 130:	00054783          	lbu	a5,0(a0)
 134:	cb99                	beqz	a5,14a <strchr+0x20>
    if(*s == c)
 136:	00f58763          	beq	a1,a5,144 <strchr+0x1a>
  for(; *s; s++)
 13a:	0505                	addi	a0,a0,1
 13c:	00054783          	lbu	a5,0(a0)
 140:	fbfd                	bnez	a5,136 <strchr+0xc>
      return (char*)s;
  return 0;
 142:	4501                	li	a0,0
}
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret
  return 0;
 14a:	4501                	li	a0,0
 14c:	bfe5                	j	144 <strchr+0x1a>

000000000000014e <gets>:

char*
gets(char *buf, int max)
{
 14e:	711d                	addi	sp,sp,-96
 150:	ec86                	sd	ra,88(sp)
 152:	e8a2                	sd	s0,80(sp)
 154:	e4a6                	sd	s1,72(sp)
 156:	e0ca                	sd	s2,64(sp)
 158:	fc4e                	sd	s3,56(sp)
 15a:	f852                	sd	s4,48(sp)
 15c:	f456                	sd	s5,40(sp)
 15e:	f05a                	sd	s6,32(sp)
 160:	ec5e                	sd	s7,24(sp)
 162:	1080                	addi	s0,sp,96
 164:	8baa                	mv	s7,a0
 166:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 168:	892a                	mv	s2,a0
 16a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 16c:	4aa9                	li	s5,10
 16e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 170:	89a6                	mv	s3,s1
 172:	2485                	addiw	s1,s1,1
 174:	0344d663          	bge	s1,s4,1a0 <gets+0x52>
    cc = read(0, &c, 1);
 178:	4605                	li	a2,1
 17a:	faf40593          	addi	a1,s0,-81
 17e:	4501                	li	a0,0
 180:	1f0000ef          	jal	370 <read>
    if(cc < 1)
 184:	00a05e63          	blez	a0,1a0 <gets+0x52>
    buf[i++] = c;
 188:	faf44783          	lbu	a5,-81(s0)
 18c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 190:	01578763          	beq	a5,s5,19e <gets+0x50>
 194:	0905                	addi	s2,s2,1
 196:	fd679de3          	bne	a5,s6,170 <gets+0x22>
    buf[i++] = c;
 19a:	89a6                	mv	s3,s1
 19c:	a011                	j	1a0 <gets+0x52>
 19e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1a0:	99de                	add	s3,s3,s7
 1a2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a6:	855e                	mv	a0,s7
 1a8:	60e6                	ld	ra,88(sp)
 1aa:	6446                	ld	s0,80(sp)
 1ac:	64a6                	ld	s1,72(sp)
 1ae:	6906                	ld	s2,64(sp)
 1b0:	79e2                	ld	s3,56(sp)
 1b2:	7a42                	ld	s4,48(sp)
 1b4:	7aa2                	ld	s5,40(sp)
 1b6:	7b02                	ld	s6,32(sp)
 1b8:	6be2                	ld	s7,24(sp)
 1ba:	6125                	addi	sp,sp,96
 1bc:	8082                	ret

00000000000001be <stat>:

int
stat(const char *n, struct stat *st)
{
 1be:	1101                	addi	sp,sp,-32
 1c0:	ec06                	sd	ra,24(sp)
 1c2:	e822                	sd	s0,16(sp)
 1c4:	e04a                	sd	s2,0(sp)
 1c6:	1000                	addi	s0,sp,32
 1c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ca:	4581                	li	a1,0
 1cc:	1cc000ef          	jal	398 <open>
  if(fd < 0)
 1d0:	02054263          	bltz	a0,1f4 <stat+0x36>
 1d4:	e426                	sd	s1,8(sp)
 1d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d8:	85ca                	mv	a1,s2
 1da:	1d6000ef          	jal	3b0 <fstat>
 1de:	892a                	mv	s2,a0
  close(fd);
 1e0:	8526                	mv	a0,s1
 1e2:	19e000ef          	jal	380 <close>
  return r;
 1e6:	64a2                	ld	s1,8(sp)
}
 1e8:	854a                	mv	a0,s2
 1ea:	60e2                	ld	ra,24(sp)
 1ec:	6442                	ld	s0,16(sp)
 1ee:	6902                	ld	s2,0(sp)
 1f0:	6105                	addi	sp,sp,32
 1f2:	8082                	ret
    return -1;
 1f4:	597d                	li	s2,-1
 1f6:	bfcd                	j	1e8 <stat+0x2a>

00000000000001f8 <atoi>:

int
atoi(const char *s)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fe:	00054683          	lbu	a3,0(a0)
 202:	fd06879b          	addiw	a5,a3,-48
 206:	0ff7f793          	zext.b	a5,a5
 20a:	4625                	li	a2,9
 20c:	02f66863          	bltu	a2,a5,23c <atoi+0x44>
 210:	872a                	mv	a4,a0
  n = 0;
 212:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 214:	0705                	addi	a4,a4,1
 216:	0025179b          	slliw	a5,a0,0x2
 21a:	9fa9                	addw	a5,a5,a0
 21c:	0017979b          	slliw	a5,a5,0x1
 220:	9fb5                	addw	a5,a5,a3
 222:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 226:	00074683          	lbu	a3,0(a4)
 22a:	fd06879b          	addiw	a5,a3,-48
 22e:	0ff7f793          	zext.b	a5,a5
 232:	fef671e3          	bgeu	a2,a5,214 <atoi+0x1c>
  return n;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
  n = 0;
 23c:	4501                	li	a0,0
 23e:	bfe5                	j	236 <atoi+0x3e>

0000000000000240 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 246:	02b57463          	bgeu	a0,a1,26e <memmove+0x2e>
    while(n-- > 0)
 24a:	00c05f63          	blez	a2,268 <memmove+0x28>
 24e:	1602                	slli	a2,a2,0x20
 250:	9201                	srli	a2,a2,0x20
 252:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 256:	872a                	mv	a4,a0
      *dst++ = *src++;
 258:	0585                	addi	a1,a1,1
 25a:	0705                	addi	a4,a4,1
 25c:	fff5c683          	lbu	a3,-1(a1)
 260:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 264:	fef71ae3          	bne	a4,a5,258 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret
    dst += n;
 26e:	00c50733          	add	a4,a0,a2
    src += n;
 272:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 274:	fec05ae3          	blez	a2,268 <memmove+0x28>
 278:	fff6079b          	addiw	a5,a2,-1
 27c:	1782                	slli	a5,a5,0x20
 27e:	9381                	srli	a5,a5,0x20
 280:	fff7c793          	not	a5,a5
 284:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 286:	15fd                	addi	a1,a1,-1
 288:	177d                	addi	a4,a4,-1
 28a:	0005c683          	lbu	a3,0(a1)
 28e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 292:	fee79ae3          	bne	a5,a4,286 <memmove+0x46>
 296:	bfc9                	j	268 <memmove+0x28>

0000000000000298 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 29e:	ca05                	beqz	a2,2ce <memcmp+0x36>
 2a0:	fff6069b          	addiw	a3,a2,-1
 2a4:	1682                	slli	a3,a3,0x20
 2a6:	9281                	srli	a3,a3,0x20
 2a8:	0685                	addi	a3,a3,1
 2aa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	0005c703          	lbu	a4,0(a1)
 2b4:	00e79863          	bne	a5,a4,2c4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b8:	0505                	addi	a0,a0,1
    p2++;
 2ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2bc:	fed518e3          	bne	a0,a3,2ac <memcmp+0x14>
  }
  return 0;
 2c0:	4501                	li	a0,0
 2c2:	a019                	j	2c8 <memcmp+0x30>
      return *p1 - *p2;
 2c4:	40e7853b          	subw	a0,a5,a4
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  return 0;
 2ce:	4501                	li	a0,0
 2d0:	bfe5                	j	2c8 <memcmp+0x30>

00000000000002d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2da:	f67ff0ef          	jal	240 <memmove>
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret

00000000000002e6 <sbrk>:

char *
sbrk(int n) {
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e406                	sd	ra,8(sp)
 2ea:	e022                	sd	s0,0(sp)
 2ec:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2ee:	4585                	li	a1,1
 2f0:	0f0000ef          	jal	3e0 <sys_sbrk>
}
 2f4:	60a2                	ld	ra,8(sp)
 2f6:	6402                	ld	s0,0(sp)
 2f8:	0141                	addi	sp,sp,16
 2fa:	8082                	ret

00000000000002fc <sbrklazy>:

char *
sbrklazy(int n) {
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e406                	sd	ra,8(sp)
 300:	e022                	sd	s0,0(sp)
 302:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 304:	4589                	li	a1,2
 306:	0da000ef          	jal	3e0 <sys_sbrk>
}
 30a:	60a2                	ld	ra,8(sp)
 30c:	6402                	ld	s0,0(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret

0000000000000312 <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
 312:	1141                	addi	sp,sp,-16
 314:	e406                	sd	ra,8(sp)
 316:	e022                	sd	s0,0(sp)
 318:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
 31a:	0025961b          	slliw	a2,a1,0x2
 31e:	9e2d                	addw	a2,a2,a1
 320:	0036161b          	slliw	a2,a2,0x3
 324:	4581                	li	a1,0
 326:	de3ff0ef          	jal	108 <memset>
  return 0;
}
 32a:	4501                	li	a0,0
 32c:	60a2                	ld	ra,8(sp)
 32e:	6402                	ld	s0,0(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret

0000000000000334 <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
 33c:	07000613          	li	a2,112
 340:	4581                	li	a1,0
 342:	dc7ff0ef          	jal	108 <memset>
  return 0;
}
 346:	4501                	li	a0,0
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret

0000000000000350 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 350:	4885                	li	a7,1
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exit>:
.global exit
exit:
 li a7, SYS_exit
 358:	4889                	li	a7,2
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <wait>:
.global wait
wait:
 li a7, SYS_wait
 360:	488d                	li	a7,3
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 368:	4891                	li	a7,4
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <read>:
.global read
read:
 li a7, SYS_read
 370:	4895                	li	a7,5
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <write>:
.global write
write:
 li a7, SYS_write
 378:	48c1                	li	a7,16
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <close>:
.global close
close:
 li a7, SYS_close
 380:	48d5                	li	a7,21
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <kill>:
.global kill
kill:
 li a7, SYS_kill
 388:	4899                	li	a7,6
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exec>:
.global exec
exec:
 li a7, SYS_exec
 390:	489d                	li	a7,7
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <open>:
.global open
open:
 li a7, SYS_open
 398:	48bd                	li	a7,15
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a0:	48c5                	li	a7,17
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a8:	48c9                	li	a7,18
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b0:	48a1                	li	a7,8
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <link>:
.global link
link:
 li a7, SYS_link
 3b8:	48cd                	li	a7,19
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c0:	48d1                	li	a7,20
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c8:	48a5                	li	a7,9
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d0:	48a9                	li	a7,10
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d8:	48ad                	li	a7,11
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e0:	48b1                	li	a7,12
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3e8:	48b5                	li	a7,13
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f0:	48b9                	li	a7,14
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <csread>:
.global csread
csread:
 li a7, SYS_csread
 3f8:	48d9                	li	a7,22
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 400:	48dd                	li	a7,23
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 408:	48e1                	li	a7,24
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <memread>:
.global memread
memread:
 li a7, SYS_memread
 410:	48e5                	li	a7,25
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 418:	1101                	addi	sp,sp,-32
 41a:	ec06                	sd	ra,24(sp)
 41c:	e822                	sd	s0,16(sp)
 41e:	1000                	addi	s0,sp,32
 420:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 424:	4605                	li	a2,1
 426:	fef40593          	addi	a1,s0,-17
 42a:	f4fff0ef          	jal	378 <write>
}
 42e:	60e2                	ld	ra,24(sp)
 430:	6442                	ld	s0,16(sp)
 432:	6105                	addi	sp,sp,32
 434:	8082                	ret

0000000000000436 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 436:	715d                	addi	sp,sp,-80
 438:	e486                	sd	ra,72(sp)
 43a:	e0a2                	sd	s0,64(sp)
 43c:	f84a                	sd	s2,48(sp)
 43e:	0880                	addi	s0,sp,80
 440:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 442:	c299                	beqz	a3,448 <printint+0x12>
 444:	0805c363          	bltz	a1,4ca <printint+0x94>
  neg = 0;
 448:	4881                	li	a7,0
 44a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 44e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 450:	00000517          	auipc	a0,0x0
 454:	58850513          	addi	a0,a0,1416 # 9d8 <digits>
 458:	883e                	mv	a6,a5
 45a:	2785                	addiw	a5,a5,1
 45c:	02c5f733          	remu	a4,a1,a2
 460:	972a                	add	a4,a4,a0
 462:	00074703          	lbu	a4,0(a4)
 466:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 46a:	872e                	mv	a4,a1
 46c:	02c5d5b3          	divu	a1,a1,a2
 470:	0685                	addi	a3,a3,1
 472:	fec773e3          	bgeu	a4,a2,458 <printint+0x22>
  if(neg)
 476:	00088b63          	beqz	a7,48c <printint+0x56>
    buf[i++] = '-';
 47a:	fd078793          	addi	a5,a5,-48
 47e:	97a2                	add	a5,a5,s0
 480:	02d00713          	li	a4,45
 484:	fee78423          	sb	a4,-24(a5)
 488:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 48c:	02f05a63          	blez	a5,4c0 <printint+0x8a>
 490:	fc26                	sd	s1,56(sp)
 492:	f44e                	sd	s3,40(sp)
 494:	fb840713          	addi	a4,s0,-72
 498:	00f704b3          	add	s1,a4,a5
 49c:	fff70993          	addi	s3,a4,-1
 4a0:	99be                	add	s3,s3,a5
 4a2:	37fd                	addiw	a5,a5,-1
 4a4:	1782                	slli	a5,a5,0x20
 4a6:	9381                	srli	a5,a5,0x20
 4a8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4ac:	fff4c583          	lbu	a1,-1(s1)
 4b0:	854a                	mv	a0,s2
 4b2:	f67ff0ef          	jal	418 <putc>
  while(--i >= 0)
 4b6:	14fd                	addi	s1,s1,-1
 4b8:	ff349ae3          	bne	s1,s3,4ac <printint+0x76>
 4bc:	74e2                	ld	s1,56(sp)
 4be:	79a2                	ld	s3,40(sp)
}
 4c0:	60a6                	ld	ra,72(sp)
 4c2:	6406                	ld	s0,64(sp)
 4c4:	7942                	ld	s2,48(sp)
 4c6:	6161                	addi	sp,sp,80
 4c8:	8082                	ret
    x = -xx;
 4ca:	40b005b3          	neg	a1,a1
    neg = 1;
 4ce:	4885                	li	a7,1
    x = -xx;
 4d0:	bfad                	j	44a <printint+0x14>

00000000000004d2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d2:	711d                	addi	sp,sp,-96
 4d4:	ec86                	sd	ra,88(sp)
 4d6:	e8a2                	sd	s0,80(sp)
 4d8:	e0ca                	sd	s2,64(sp)
 4da:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4dc:	0005c903          	lbu	s2,0(a1)
 4e0:	28090663          	beqz	s2,76c <vprintf+0x29a>
 4e4:	e4a6                	sd	s1,72(sp)
 4e6:	fc4e                	sd	s3,56(sp)
 4e8:	f852                	sd	s4,48(sp)
 4ea:	f456                	sd	s5,40(sp)
 4ec:	f05a                	sd	s6,32(sp)
 4ee:	ec5e                	sd	s7,24(sp)
 4f0:	e862                	sd	s8,16(sp)
 4f2:	e466                	sd	s9,8(sp)
 4f4:	8b2a                	mv	s6,a0
 4f6:	8a2e                	mv	s4,a1
 4f8:	8bb2                	mv	s7,a2
  state = 0;
 4fa:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4fc:	4481                	li	s1,0
 4fe:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 500:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 504:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 508:	06c00c93          	li	s9,108
 50c:	a005                	j	52c <vprintf+0x5a>
        putc(fd, c0);
 50e:	85ca                	mv	a1,s2
 510:	855a                	mv	a0,s6
 512:	f07ff0ef          	jal	418 <putc>
 516:	a019                	j	51c <vprintf+0x4a>
    } else if(state == '%'){
 518:	03598263          	beq	s3,s5,53c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 51c:	2485                	addiw	s1,s1,1
 51e:	8726                	mv	a4,s1
 520:	009a07b3          	add	a5,s4,s1
 524:	0007c903          	lbu	s2,0(a5)
 528:	22090a63          	beqz	s2,75c <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 52c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 530:	fe0994e3          	bnez	s3,518 <vprintf+0x46>
      if(c0 == '%'){
 534:	fd579de3          	bne	a5,s5,50e <vprintf+0x3c>
        state = '%';
 538:	89be                	mv	s3,a5
 53a:	b7cd                	j	51c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 53c:	00ea06b3          	add	a3,s4,a4
 540:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 544:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 546:	c681                	beqz	a3,54e <vprintf+0x7c>
 548:	9752                	add	a4,a4,s4
 54a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 54e:	05878363          	beq	a5,s8,594 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 552:	05978d63          	beq	a5,s9,5ac <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 556:	07500713          	li	a4,117
 55a:	0ee78763          	beq	a5,a4,648 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 55e:	07800713          	li	a4,120
 562:	12e78963          	beq	a5,a4,694 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 566:	07000713          	li	a4,112
 56a:	14e78e63          	beq	a5,a4,6c6 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 56e:	06300713          	li	a4,99
 572:	18e78e63          	beq	a5,a4,70e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 576:	07300713          	li	a4,115
 57a:	1ae78463          	beq	a5,a4,722 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 57e:	02500713          	li	a4,37
 582:	04e79563          	bne	a5,a4,5cc <vprintf+0xfa>
        putc(fd, '%');
 586:	02500593          	li	a1,37
 58a:	855a                	mv	a0,s6
 58c:	e8dff0ef          	jal	418 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 590:	4981                	li	s3,0
 592:	b769                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 594:	008b8913          	addi	s2,s7,8
 598:	4685                	li	a3,1
 59a:	4629                	li	a2,10
 59c:	000ba583          	lw	a1,0(s7)
 5a0:	855a                	mv	a0,s6
 5a2:	e95ff0ef          	jal	436 <printint>
 5a6:	8bca                	mv	s7,s2
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	bf8d                	j	51c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ac:	06400793          	li	a5,100
 5b0:	02f68963          	beq	a3,a5,5e2 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5b4:	06c00793          	li	a5,108
 5b8:	04f68263          	beq	a3,a5,5fc <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5bc:	07500793          	li	a5,117
 5c0:	0af68063          	beq	a3,a5,660 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5c4:	07800793          	li	a5,120
 5c8:	0ef68263          	beq	a3,a5,6ac <vprintf+0x1da>
        putc(fd, '%');
 5cc:	02500593          	li	a1,37
 5d0:	855a                	mv	a0,s6
 5d2:	e47ff0ef          	jal	418 <putc>
        putc(fd, c0);
 5d6:	85ca                	mv	a1,s2
 5d8:	855a                	mv	a0,s6
 5da:	e3fff0ef          	jal	418 <putc>
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bf35                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4685                	li	a3,1
 5e8:	4629                	li	a2,10
 5ea:	000bb583          	ld	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	e47ff0ef          	jal	436 <printint>
        i += 1;
 5f4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f6:	8bca                	mv	s7,s2
      state = 0;
 5f8:	4981                	li	s3,0
        i += 1;
 5fa:	b70d                	j	51c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5fc:	06400793          	li	a5,100
 600:	02f60763          	beq	a2,a5,62e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 604:	07500793          	li	a5,117
 608:	06f60963          	beq	a2,a5,67a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 60c:	07800793          	li	a5,120
 610:	faf61ee3          	bne	a2,a5,5cc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 614:	008b8913          	addi	s2,s7,8
 618:	4681                	li	a3,0
 61a:	4641                	li	a2,16
 61c:	000bb583          	ld	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	e15ff0ef          	jal	436 <printint>
        i += 2;
 626:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 628:	8bca                	mv	s7,s2
      state = 0;
 62a:	4981                	li	s3,0
        i += 2;
 62c:	bdc5                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62e:	008b8913          	addi	s2,s7,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	dfbff0ef          	jal	436 <printint>
        i += 2;
 640:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 2;
 646:	bdd9                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4629                	li	a2,10
 650:	000be583          	lwu	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	de1ff0ef          	jal	436 <printint>
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bd7d                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 660:	008b8913          	addi	s2,s7,8
 664:	4681                	li	a3,0
 666:	4629                	li	a2,10
 668:	000bb583          	ld	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	dc9ff0ef          	jal	436 <printint>
        i += 1;
 672:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
        i += 1;
 678:	b555                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4629                	li	a2,10
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	dafff0ef          	jal	436 <printint>
        i += 2;
 68c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 2;
 692:	b569                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4641                	li	a2,16
 69c:	000be583          	lwu	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	d95ff0ef          	jal	436 <printint>
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bd8d                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4681                	li	a3,0
 6b2:	4641                	li	a2,16
 6b4:	000bb583          	ld	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	d7dff0ef          	jal	436 <printint>
        i += 1;
 6be:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
        i += 1;
 6c4:	bda1                	j	51c <vprintf+0x4a>
 6c6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6c8:	008b8d13          	addi	s10,s7,8
 6cc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d0:	03000593          	li	a1,48
 6d4:	855a                	mv	a0,s6
 6d6:	d43ff0ef          	jal	418 <putc>
  putc(fd, 'x');
 6da:	07800593          	li	a1,120
 6de:	855a                	mv	a0,s6
 6e0:	d39ff0ef          	jal	418 <putc>
 6e4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e6:	00000b97          	auipc	s7,0x0
 6ea:	2f2b8b93          	addi	s7,s7,754 # 9d8 <digits>
 6ee:	03c9d793          	srli	a5,s3,0x3c
 6f2:	97de                	add	a5,a5,s7
 6f4:	0007c583          	lbu	a1,0(a5)
 6f8:	855a                	mv	a0,s6
 6fa:	d1fff0ef          	jal	418 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6fe:	0992                	slli	s3,s3,0x4
 700:	397d                	addiw	s2,s2,-1
 702:	fe0916e3          	bnez	s2,6ee <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 706:	8bea                	mv	s7,s10
      state = 0;
 708:	4981                	li	s3,0
 70a:	6d02                	ld	s10,0(sp)
 70c:	bd01                	j	51c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 70e:	008b8913          	addi	s2,s7,8
 712:	000bc583          	lbu	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	d01ff0ef          	jal	418 <putc>
 71c:	8bca                	mv	s7,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	bbf5                	j	51c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 722:	008b8993          	addi	s3,s7,8
 726:	000bb903          	ld	s2,0(s7)
 72a:	00090f63          	beqz	s2,748 <vprintf+0x276>
        for(; *s; s++)
 72e:	00094583          	lbu	a1,0(s2)
 732:	c195                	beqz	a1,756 <vprintf+0x284>
          putc(fd, *s);
 734:	855a                	mv	a0,s6
 736:	ce3ff0ef          	jal	418 <putc>
        for(; *s; s++)
 73a:	0905                	addi	s2,s2,1
 73c:	00094583          	lbu	a1,0(s2)
 740:	f9f5                	bnez	a1,734 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 742:	8bce                	mv	s7,s3
      state = 0;
 744:	4981                	li	s3,0
 746:	bbd9                	j	51c <vprintf+0x4a>
          s = "(null)";
 748:	00000917          	auipc	s2,0x0
 74c:	28890913          	addi	s2,s2,648 # 9d0 <malloc+0x17c>
        for(; *s; s++)
 750:	02800593          	li	a1,40
 754:	b7c5                	j	734 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 756:	8bce                	mv	s7,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	b3c9                	j	51c <vprintf+0x4a>
 75c:	64a6                	ld	s1,72(sp)
 75e:	79e2                	ld	s3,56(sp)
 760:	7a42                	ld	s4,48(sp)
 762:	7aa2                	ld	s5,40(sp)
 764:	7b02                	ld	s6,32(sp)
 766:	6be2                	ld	s7,24(sp)
 768:	6c42                	ld	s8,16(sp)
 76a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 76c:	60e6                	ld	ra,88(sp)
 76e:	6446                	ld	s0,80(sp)
 770:	6906                	ld	s2,64(sp)
 772:	6125                	addi	sp,sp,96
 774:	8082                	ret

0000000000000776 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 776:	715d                	addi	sp,sp,-80
 778:	ec06                	sd	ra,24(sp)
 77a:	e822                	sd	s0,16(sp)
 77c:	1000                	addi	s0,sp,32
 77e:	e010                	sd	a2,0(s0)
 780:	e414                	sd	a3,8(s0)
 782:	e818                	sd	a4,16(s0)
 784:	ec1c                	sd	a5,24(s0)
 786:	03043023          	sd	a6,32(s0)
 78a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 78e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 792:	8622                	mv	a2,s0
 794:	d3fff0ef          	jal	4d2 <vprintf>
}
 798:	60e2                	ld	ra,24(sp)
 79a:	6442                	ld	s0,16(sp)
 79c:	6161                	addi	sp,sp,80
 79e:	8082                	ret

00000000000007a0 <printf>:

void
printf(const char *fmt, ...)
{
 7a0:	711d                	addi	sp,sp,-96
 7a2:	ec06                	sd	ra,24(sp)
 7a4:	e822                	sd	s0,16(sp)
 7a6:	1000                	addi	s0,sp,32
 7a8:	e40c                	sd	a1,8(s0)
 7aa:	e810                	sd	a2,16(s0)
 7ac:	ec14                	sd	a3,24(s0)
 7ae:	f018                	sd	a4,32(s0)
 7b0:	f41c                	sd	a5,40(s0)
 7b2:	03043823          	sd	a6,48(s0)
 7b6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ba:	00840613          	addi	a2,s0,8
 7be:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c2:	85aa                	mv	a1,a0
 7c4:	4505                	li	a0,1
 7c6:	d0dff0ef          	jal	4d2 <vprintf>
}
 7ca:	60e2                	ld	ra,24(sp)
 7cc:	6442                	ld	s0,16(sp)
 7ce:	6125                	addi	sp,sp,96
 7d0:	8082                	ret

00000000000007d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d2:	1141                	addi	sp,sp,-16
 7d4:	e422                	sd	s0,8(sp)
 7d6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7dc:	00001797          	auipc	a5,0x1
 7e0:	8247b783          	ld	a5,-2012(a5) # 1000 <freep>
 7e4:	a02d                	j	80e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e6:	4618                	lw	a4,8(a2)
 7e8:	9f2d                	addw	a4,a4,a1
 7ea:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ee:	6398                	ld	a4,0(a5)
 7f0:	6310                	ld	a2,0(a4)
 7f2:	a83d                	j	830 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f4:	ff852703          	lw	a4,-8(a0)
 7f8:	9f31                	addw	a4,a4,a2
 7fa:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7fc:	ff053683          	ld	a3,-16(a0)
 800:	a091                	j	844 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 802:	6398                	ld	a4,0(a5)
 804:	00e7e463          	bltu	a5,a4,80c <free+0x3a>
 808:	00e6ea63          	bltu	a3,a4,81c <free+0x4a>
{
 80c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80e:	fed7fae3          	bgeu	a5,a3,802 <free+0x30>
 812:	6398                	ld	a4,0(a5)
 814:	00e6e463          	bltu	a3,a4,81c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 818:	fee7eae3          	bltu	a5,a4,80c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 81c:	ff852583          	lw	a1,-8(a0)
 820:	6390                	ld	a2,0(a5)
 822:	02059813          	slli	a6,a1,0x20
 826:	01c85713          	srli	a4,a6,0x1c
 82a:	9736                	add	a4,a4,a3
 82c:	fae60de3          	beq	a2,a4,7e6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 834:	4790                	lw	a2,8(a5)
 836:	02061593          	slli	a1,a2,0x20
 83a:	01c5d713          	srli	a4,a1,0x1c
 83e:	973e                	add	a4,a4,a5
 840:	fae68ae3          	beq	a3,a4,7f4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 844:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 846:	00000717          	auipc	a4,0x0
 84a:	7af73d23          	sd	a5,1978(a4) # 1000 <freep>
}
 84e:	6422                	ld	s0,8(sp)
 850:	0141                	addi	sp,sp,16
 852:	8082                	ret

0000000000000854 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 854:	7139                	addi	sp,sp,-64
 856:	fc06                	sd	ra,56(sp)
 858:	f822                	sd	s0,48(sp)
 85a:	f426                	sd	s1,40(sp)
 85c:	ec4e                	sd	s3,24(sp)
 85e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 860:	02051493          	slli	s1,a0,0x20
 864:	9081                	srli	s1,s1,0x20
 866:	04bd                	addi	s1,s1,15
 868:	8091                	srli	s1,s1,0x4
 86a:	0014899b          	addiw	s3,s1,1
 86e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 870:	00000517          	auipc	a0,0x0
 874:	79053503          	ld	a0,1936(a0) # 1000 <freep>
 878:	c915                	beqz	a0,8ac <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87c:	4798                	lw	a4,8(a5)
 87e:	08977a63          	bgeu	a4,s1,912 <malloc+0xbe>
 882:	f04a                	sd	s2,32(sp)
 884:	e852                	sd	s4,16(sp)
 886:	e456                	sd	s5,8(sp)
 888:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 88a:	8a4e                	mv	s4,s3
 88c:	0009871b          	sext.w	a4,s3
 890:	6685                	lui	a3,0x1
 892:	00d77363          	bgeu	a4,a3,898 <malloc+0x44>
 896:	6a05                	lui	s4,0x1
 898:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 89c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a0:	00000917          	auipc	s2,0x0
 8a4:	76090913          	addi	s2,s2,1888 # 1000 <freep>
  if(p == SBRK_ERROR)
 8a8:	5afd                	li	s5,-1
 8aa:	a081                	j	8ea <malloc+0x96>
 8ac:	f04a                	sd	s2,32(sp)
 8ae:	e852                	sd	s4,16(sp)
 8b0:	e456                	sd	s5,8(sp)
 8b2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8b4:	00001797          	auipc	a5,0x1
 8b8:	8dc78793          	addi	a5,a5,-1828 # 1190 <base>
 8bc:	00000717          	auipc	a4,0x0
 8c0:	74f73223          	sd	a5,1860(a4) # 1000 <freep>
 8c4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ca:	b7c1                	j	88a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8cc:	6398                	ld	a4,0(a5)
 8ce:	e118                	sd	a4,0(a0)
 8d0:	a8a9                	j	92a <malloc+0xd6>
  hp->s.size = nu;
 8d2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d6:	0541                	addi	a0,a0,16
 8d8:	efbff0ef          	jal	7d2 <free>
  return freep;
 8dc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e0:	c12d                	beqz	a0,942 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e4:	4798                	lw	a4,8(a5)
 8e6:	02977263          	bgeu	a4,s1,90a <malloc+0xb6>
    if(p == freep)
 8ea:	00093703          	ld	a4,0(s2)
 8ee:	853e                	mv	a0,a5
 8f0:	fef719e3          	bne	a4,a5,8e2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8f4:	8552                	mv	a0,s4
 8f6:	9f1ff0ef          	jal	2e6 <sbrk>
  if(p == SBRK_ERROR)
 8fa:	fd551ce3          	bne	a0,s5,8d2 <malloc+0x7e>
        return 0;
 8fe:	4501                	li	a0,0
 900:	7902                	ld	s2,32(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
 908:	a03d                	j	936 <malloc+0xe2>
 90a:	7902                	ld	s2,32(sp)
 90c:	6a42                	ld	s4,16(sp)
 90e:	6aa2                	ld	s5,8(sp)
 910:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 912:	fae48de3          	beq	s1,a4,8cc <malloc+0x78>
        p->s.size -= nunits;
 916:	4137073b          	subw	a4,a4,s3
 91a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 91c:	02071693          	slli	a3,a4,0x20
 920:	01c6d713          	srli	a4,a3,0x1c
 924:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 926:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 92a:	00000717          	auipc	a4,0x0
 92e:	6ca73b23          	sd	a0,1750(a4) # 1000 <freep>
      return (void*)(p + 1);
 932:	01078513          	addi	a0,a5,16
  }
}
 936:	70e2                	ld	ra,56(sp)
 938:	7442                	ld	s0,48(sp)
 93a:	74a2                	ld	s1,40(sp)
 93c:	69e2                	ld	s3,24(sp)
 93e:	6121                	addi	sp,sp,64
 940:	8082                	ret
 942:	7902                	ld	s2,32(sp)
 944:	6a42                	ld	s4,16(sp)
 946:	6aa2                	ld	s5,8(sp)
 948:	6b02                	ld	s6,0(sp)
 94a:	b7f5                	j	936 <malloc+0xe2>
