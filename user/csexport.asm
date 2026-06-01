
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
  16:	90e50513          	addi	a0,a0,-1778 # 920 <malloc+0xfa>
  1a:	758000ef          	jal	772 <printf>

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
  2c:	920a8a93          	addi	s5,s5,-1760 # 948 <malloc+0x122>
  30:	a01d                	j	56 <main+0x56>
  32:	ffc4a803          	lw	a6,-4(s1)
  36:	87a6                	mv	a5,s1
  38:	ff84a703          	lw	a4,-8(s1)
  3c:	ff04a683          	lw	a3,-16(s1)
  40:	fec4a603          	lw	a2,-20(s1)
  44:	fe44b583          	ld	a1,-28(s1)
  48:	8556                	mv	a0,s5
  4a:	728000ef          	jal	772 <printf>
}
  4e:	a03d                	j	7c <main+0x7c>
                print_cs_event(&cs_ev[i]);
        }
        
        // استخدام sleep أو pause لتقليل استهلاك المعالج
        pause(2); 
  50:	4509                	li	a0,2
  52:	358000ef          	jal	3aa <pause>
        int n_cs = csread(cs_ev, 8);
  56:	45a1                	li	a1,8
  58:	8552                	mv	a0,s4
  5a:	360000ef          	jal	3ba <csread>
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
  92:	288000ef          	jal	31a <exit>

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
 180:	1b2000ef          	jal	332 <read>
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
 1cc:	18e000ef          	jal	35a <open>
  if(fd < 0)
 1d0:	02054263          	bltz	a0,1f4 <stat+0x36>
 1d4:	e426                	sd	s1,8(sp)
 1d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d8:	85ca                	mv	a1,s2
 1da:	198000ef          	jal	372 <fstat>
 1de:	892a                	mv	s2,a0
  close(fd);
 1e0:	8526                	mv	a0,s1
 1e2:	160000ef          	jal	342 <close>
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
 2f0:	0b2000ef          	jal	3a2 <sys_sbrk>
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
 306:	09c000ef          	jal	3a2 <sys_sbrk>
}
 30a:	60a2                	ld	ra,8(sp)
 30c:	6402                	ld	s0,0(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret

0000000000000312 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 312:	4885                	li	a7,1
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <exit>:
.global exit
exit:
 li a7, SYS_exit
 31a:	4889                	li	a7,2
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <wait>:
.global wait
wait:
 li a7, SYS_wait
 322:	488d                	li	a7,3
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 32a:	4891                	li	a7,4
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <read>:
.global read
read:
 li a7, SYS_read
 332:	4895                	li	a7,5
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <write>:
.global write
write:
 li a7, SYS_write
 33a:	48c1                	li	a7,16
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <close>:
.global close
close:
 li a7, SYS_close
 342:	48d5                	li	a7,21
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <kill>:
.global kill
kill:
 li a7, SYS_kill
 34a:	4899                	li	a7,6
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <exec>:
.global exec
exec:
 li a7, SYS_exec
 352:	489d                	li	a7,7
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <open>:
.global open
open:
 li a7, SYS_open
 35a:	48bd                	li	a7,15
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 362:	48c5                	li	a7,17
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 36a:	48c9                	li	a7,18
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 372:	48a1                	li	a7,8
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <link>:
.global link
link:
 li a7, SYS_link
 37a:	48cd                	li	a7,19
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 382:	48d1                	li	a7,20
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 38a:	48a5                	li	a7,9
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <dup>:
.global dup
dup:
 li a7, SYS_dup
 392:	48a9                	li	a7,10
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 39a:	48ad                	li	a7,11
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3a2:	48b1                	li	a7,12
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <pause>:
.global pause
pause:
 li a7, SYS_pause
 3aa:	48b5                	li	a7,13
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b2:	48b9                	li	a7,14
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <csread>:
.global csread
csread:
 li a7, SYS_csread
 3ba:	48d9                	li	a7,22
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 3c2:	48dd                	li	a7,23
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 3ca:	48e1                	li	a7,24
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <memread>:
.global memread
memread:
 li a7, SYS_memread
 3d2:	48e5                	li	a7,25
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 3da:	48e9                	li	a7,26
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 3e2:	48ed                	li	a7,27
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ea:	1101                	addi	sp,sp,-32
 3ec:	ec06                	sd	ra,24(sp)
 3ee:	e822                	sd	s0,16(sp)
 3f0:	1000                	addi	s0,sp,32
 3f2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f6:	4605                	li	a2,1
 3f8:	fef40593          	addi	a1,s0,-17
 3fc:	f3fff0ef          	jal	33a <write>
}
 400:	60e2                	ld	ra,24(sp)
 402:	6442                	ld	s0,16(sp)
 404:	6105                	addi	sp,sp,32
 406:	8082                	ret

0000000000000408 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 408:	715d                	addi	sp,sp,-80
 40a:	e486                	sd	ra,72(sp)
 40c:	e0a2                	sd	s0,64(sp)
 40e:	f84a                	sd	s2,48(sp)
 410:	0880                	addi	s0,sp,80
 412:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 414:	c299                	beqz	a3,41a <printint+0x12>
 416:	0805c363          	bltz	a1,49c <printint+0x94>
  neg = 0;
 41a:	4881                	li	a7,0
 41c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 420:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 422:	00000517          	auipc	a0,0x0
 426:	58650513          	addi	a0,a0,1414 # 9a8 <digits>
 42a:	883e                	mv	a6,a5
 42c:	2785                	addiw	a5,a5,1
 42e:	02c5f733          	remu	a4,a1,a2
 432:	972a                	add	a4,a4,a0
 434:	00074703          	lbu	a4,0(a4)
 438:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 43c:	872e                	mv	a4,a1
 43e:	02c5d5b3          	divu	a1,a1,a2
 442:	0685                	addi	a3,a3,1
 444:	fec773e3          	bgeu	a4,a2,42a <printint+0x22>
  if(neg)
 448:	00088b63          	beqz	a7,45e <printint+0x56>
    buf[i++] = '-';
 44c:	fd078793          	addi	a5,a5,-48
 450:	97a2                	add	a5,a5,s0
 452:	02d00713          	li	a4,45
 456:	fee78423          	sb	a4,-24(a5)
 45a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 45e:	02f05a63          	blez	a5,492 <printint+0x8a>
 462:	fc26                	sd	s1,56(sp)
 464:	f44e                	sd	s3,40(sp)
 466:	fb840713          	addi	a4,s0,-72
 46a:	00f704b3          	add	s1,a4,a5
 46e:	fff70993          	addi	s3,a4,-1
 472:	99be                	add	s3,s3,a5
 474:	37fd                	addiw	a5,a5,-1
 476:	1782                	slli	a5,a5,0x20
 478:	9381                	srli	a5,a5,0x20
 47a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 47e:	fff4c583          	lbu	a1,-1(s1)
 482:	854a                	mv	a0,s2
 484:	f67ff0ef          	jal	3ea <putc>
  while(--i >= 0)
 488:	14fd                	addi	s1,s1,-1
 48a:	ff349ae3          	bne	s1,s3,47e <printint+0x76>
 48e:	74e2                	ld	s1,56(sp)
 490:	79a2                	ld	s3,40(sp)
}
 492:	60a6                	ld	ra,72(sp)
 494:	6406                	ld	s0,64(sp)
 496:	7942                	ld	s2,48(sp)
 498:	6161                	addi	sp,sp,80
 49a:	8082                	ret
    x = -xx;
 49c:	40b005b3          	neg	a1,a1
    neg = 1;
 4a0:	4885                	li	a7,1
    x = -xx;
 4a2:	bfad                	j	41c <printint+0x14>

00000000000004a4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a4:	711d                	addi	sp,sp,-96
 4a6:	ec86                	sd	ra,88(sp)
 4a8:	e8a2                	sd	s0,80(sp)
 4aa:	e0ca                	sd	s2,64(sp)
 4ac:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ae:	0005c903          	lbu	s2,0(a1)
 4b2:	28090663          	beqz	s2,73e <vprintf+0x29a>
 4b6:	e4a6                	sd	s1,72(sp)
 4b8:	fc4e                	sd	s3,56(sp)
 4ba:	f852                	sd	s4,48(sp)
 4bc:	f456                	sd	s5,40(sp)
 4be:	f05a                	sd	s6,32(sp)
 4c0:	ec5e                	sd	s7,24(sp)
 4c2:	e862                	sd	s8,16(sp)
 4c4:	e466                	sd	s9,8(sp)
 4c6:	8b2a                	mv	s6,a0
 4c8:	8a2e                	mv	s4,a1
 4ca:	8bb2                	mv	s7,a2
  state = 0;
 4cc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4ce:	4481                	li	s1,0
 4d0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4d2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4d6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4da:	06c00c93          	li	s9,108
 4de:	a005                	j	4fe <vprintf+0x5a>
        putc(fd, c0);
 4e0:	85ca                	mv	a1,s2
 4e2:	855a                	mv	a0,s6
 4e4:	f07ff0ef          	jal	3ea <putc>
 4e8:	a019                	j	4ee <vprintf+0x4a>
    } else if(state == '%'){
 4ea:	03598263          	beq	s3,s5,50e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4ee:	2485                	addiw	s1,s1,1
 4f0:	8726                	mv	a4,s1
 4f2:	009a07b3          	add	a5,s4,s1
 4f6:	0007c903          	lbu	s2,0(a5)
 4fa:	22090a63          	beqz	s2,72e <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4fe:	0009079b          	sext.w	a5,s2
    if(state == 0){
 502:	fe0994e3          	bnez	s3,4ea <vprintf+0x46>
      if(c0 == '%'){
 506:	fd579de3          	bne	a5,s5,4e0 <vprintf+0x3c>
        state = '%';
 50a:	89be                	mv	s3,a5
 50c:	b7cd                	j	4ee <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 50e:	00ea06b3          	add	a3,s4,a4
 512:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 516:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 518:	c681                	beqz	a3,520 <vprintf+0x7c>
 51a:	9752                	add	a4,a4,s4
 51c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 520:	05878363          	beq	a5,s8,566 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 524:	05978d63          	beq	a5,s9,57e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 528:	07500713          	li	a4,117
 52c:	0ee78763          	beq	a5,a4,61a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 530:	07800713          	li	a4,120
 534:	12e78963          	beq	a5,a4,666 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 538:	07000713          	li	a4,112
 53c:	14e78e63          	beq	a5,a4,698 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 540:	06300713          	li	a4,99
 544:	18e78e63          	beq	a5,a4,6e0 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 548:	07300713          	li	a4,115
 54c:	1ae78463          	beq	a5,a4,6f4 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 550:	02500713          	li	a4,37
 554:	04e79563          	bne	a5,a4,59e <vprintf+0xfa>
        putc(fd, '%');
 558:	02500593          	li	a1,37
 55c:	855a                	mv	a0,s6
 55e:	e8dff0ef          	jal	3ea <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 562:	4981                	li	s3,0
 564:	b769                	j	4ee <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 566:	008b8913          	addi	s2,s7,8
 56a:	4685                	li	a3,1
 56c:	4629                	li	a2,10
 56e:	000ba583          	lw	a1,0(s7)
 572:	855a                	mv	a0,s6
 574:	e95ff0ef          	jal	408 <printint>
 578:	8bca                	mv	s7,s2
      state = 0;
 57a:	4981                	li	s3,0
 57c:	bf8d                	j	4ee <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 57e:	06400793          	li	a5,100
 582:	02f68963          	beq	a3,a5,5b4 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 586:	06c00793          	li	a5,108
 58a:	04f68263          	beq	a3,a5,5ce <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 58e:	07500793          	li	a5,117
 592:	0af68063          	beq	a3,a5,632 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 596:	07800793          	li	a5,120
 59a:	0ef68263          	beq	a3,a5,67e <vprintf+0x1da>
        putc(fd, '%');
 59e:	02500593          	li	a1,37
 5a2:	855a                	mv	a0,s6
 5a4:	e47ff0ef          	jal	3ea <putc>
        putc(fd, c0);
 5a8:	85ca                	mv	a1,s2
 5aa:	855a                	mv	a0,s6
 5ac:	e3fff0ef          	jal	3ea <putc>
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	bf35                	j	4ee <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4685                	li	a3,1
 5ba:	4629                	li	a2,10
 5bc:	000bb583          	ld	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	e47ff0ef          	jal	408 <printint>
        i += 1;
 5c6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
        i += 1;
 5cc:	b70d                	j	4ee <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ce:	06400793          	li	a5,100
 5d2:	02f60763          	beq	a2,a5,600 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5d6:	07500793          	li	a5,117
 5da:	06f60963          	beq	a2,a5,64c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5de:	07800793          	li	a5,120
 5e2:	faf61ee3          	bne	a2,a5,59e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4681                	li	a3,0
 5ec:	4641                	li	a2,16
 5ee:	000bb583          	ld	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	e15ff0ef          	jal	408 <printint>
        i += 2;
 5f8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fa:	8bca                	mv	s7,s2
      state = 0;
 5fc:	4981                	li	s3,0
        i += 2;
 5fe:	bdc5                	j	4ee <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 600:	008b8913          	addi	s2,s7,8
 604:	4685                	li	a3,1
 606:	4629                	li	a2,10
 608:	000bb583          	ld	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	dfbff0ef          	jal	408 <printint>
        i += 2;
 612:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
        i += 2;
 618:	bdd9                	j	4ee <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4681                	li	a3,0
 620:	4629                	li	a2,10
 622:	000be583          	lwu	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	de1ff0ef          	jal	408 <printint>
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
 630:	bd7d                	j	4ee <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	008b8913          	addi	s2,s7,8
 636:	4681                	li	a3,0
 638:	4629                	li	a2,10
 63a:	000bb583          	ld	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	dc9ff0ef          	jal	408 <printint>
        i += 1;
 644:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
        i += 1;
 64a:	b555                	j	4ee <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	008b8913          	addi	s2,s7,8
 650:	4681                	li	a3,0
 652:	4629                	li	a2,10
 654:	000bb583          	ld	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	dafff0ef          	jal	408 <printint>
        i += 2;
 65e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 660:	8bca                	mv	s7,s2
      state = 0;
 662:	4981                	li	s3,0
        i += 2;
 664:	b569                	j	4ee <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 666:	008b8913          	addi	s2,s7,8
 66a:	4681                	li	a3,0
 66c:	4641                	li	a2,16
 66e:	000be583          	lwu	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	d95ff0ef          	jal	408 <printint>
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bd8d                	j	4ee <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	008b8913          	addi	s2,s7,8
 682:	4681                	li	a3,0
 684:	4641                	li	a2,16
 686:	000bb583          	ld	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	d7dff0ef          	jal	408 <printint>
        i += 1;
 690:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 692:	8bca                	mv	s7,s2
      state = 0;
 694:	4981                	li	s3,0
        i += 1;
 696:	bda1                	j	4ee <vprintf+0x4a>
 698:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 69a:	008b8d13          	addi	s10,s7,8
 69e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6a2:	03000593          	li	a1,48
 6a6:	855a                	mv	a0,s6
 6a8:	d43ff0ef          	jal	3ea <putc>
  putc(fd, 'x');
 6ac:	07800593          	li	a1,120
 6b0:	855a                	mv	a0,s6
 6b2:	d39ff0ef          	jal	3ea <putc>
 6b6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b8:	00000b97          	auipc	s7,0x0
 6bc:	2f0b8b93          	addi	s7,s7,752 # 9a8 <digits>
 6c0:	03c9d793          	srli	a5,s3,0x3c
 6c4:	97de                	add	a5,a5,s7
 6c6:	0007c583          	lbu	a1,0(a5)
 6ca:	855a                	mv	a0,s6
 6cc:	d1fff0ef          	jal	3ea <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6d0:	0992                	slli	s3,s3,0x4
 6d2:	397d                	addiw	s2,s2,-1
 6d4:	fe0916e3          	bnez	s2,6c0 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6d8:	8bea                	mv	s7,s10
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	6d02                	ld	s10,0(sp)
 6de:	bd01                	j	4ee <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	000bc583          	lbu	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	d01ff0ef          	jal	3ea <putc>
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	bbf5                	j	4ee <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6f4:	008b8993          	addi	s3,s7,8
 6f8:	000bb903          	ld	s2,0(s7)
 6fc:	00090f63          	beqz	s2,71a <vprintf+0x276>
        for(; *s; s++)
 700:	00094583          	lbu	a1,0(s2)
 704:	c195                	beqz	a1,728 <vprintf+0x284>
          putc(fd, *s);
 706:	855a                	mv	a0,s6
 708:	ce3ff0ef          	jal	3ea <putc>
        for(; *s; s++)
 70c:	0905                	addi	s2,s2,1
 70e:	00094583          	lbu	a1,0(s2)
 712:	f9f5                	bnez	a1,706 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 714:	8bce                	mv	s7,s3
      state = 0;
 716:	4981                	li	s3,0
 718:	bbd9                	j	4ee <vprintf+0x4a>
          s = "(null)";
 71a:	00000917          	auipc	s2,0x0
 71e:	28690913          	addi	s2,s2,646 # 9a0 <malloc+0x17a>
        for(; *s; s++)
 722:	02800593          	li	a1,40
 726:	b7c5                	j	706 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 728:	8bce                	mv	s7,s3
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b3c9                	j	4ee <vprintf+0x4a>
 72e:	64a6                	ld	s1,72(sp)
 730:	79e2                	ld	s3,56(sp)
 732:	7a42                	ld	s4,48(sp)
 734:	7aa2                	ld	s5,40(sp)
 736:	7b02                	ld	s6,32(sp)
 738:	6be2                	ld	s7,24(sp)
 73a:	6c42                	ld	s8,16(sp)
 73c:	6ca2                	ld	s9,8(sp)
    }
  }
}
 73e:	60e6                	ld	ra,88(sp)
 740:	6446                	ld	s0,80(sp)
 742:	6906                	ld	s2,64(sp)
 744:	6125                	addi	sp,sp,96
 746:	8082                	ret

0000000000000748 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 748:	715d                	addi	sp,sp,-80
 74a:	ec06                	sd	ra,24(sp)
 74c:	e822                	sd	s0,16(sp)
 74e:	1000                	addi	s0,sp,32
 750:	e010                	sd	a2,0(s0)
 752:	e414                	sd	a3,8(s0)
 754:	e818                	sd	a4,16(s0)
 756:	ec1c                	sd	a5,24(s0)
 758:	03043023          	sd	a6,32(s0)
 75c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 760:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 764:	8622                	mv	a2,s0
 766:	d3fff0ef          	jal	4a4 <vprintf>
}
 76a:	60e2                	ld	ra,24(sp)
 76c:	6442                	ld	s0,16(sp)
 76e:	6161                	addi	sp,sp,80
 770:	8082                	ret

0000000000000772 <printf>:

void
printf(const char *fmt, ...)
{
 772:	711d                	addi	sp,sp,-96
 774:	ec06                	sd	ra,24(sp)
 776:	e822                	sd	s0,16(sp)
 778:	1000                	addi	s0,sp,32
 77a:	e40c                	sd	a1,8(s0)
 77c:	e810                	sd	a2,16(s0)
 77e:	ec14                	sd	a3,24(s0)
 780:	f018                	sd	a4,32(s0)
 782:	f41c                	sd	a5,40(s0)
 784:	03043823          	sd	a6,48(s0)
 788:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 78c:	00840613          	addi	a2,s0,8
 790:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 794:	85aa                	mv	a1,a0
 796:	4505                	li	a0,1
 798:	d0dff0ef          	jal	4a4 <vprintf>
}
 79c:	60e2                	ld	ra,24(sp)
 79e:	6442                	ld	s0,16(sp)
 7a0:	6125                	addi	sp,sp,96
 7a2:	8082                	ret

00000000000007a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a4:	1141                	addi	sp,sp,-16
 7a6:	e422                	sd	s0,8(sp)
 7a8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7aa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ae:	00001797          	auipc	a5,0x1
 7b2:	8527b783          	ld	a5,-1966(a5) # 1000 <freep>
 7b6:	a02d                	j	7e0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b8:	4618                	lw	a4,8(a2)
 7ba:	9f2d                	addw	a4,a4,a1
 7bc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c0:	6398                	ld	a4,0(a5)
 7c2:	6310                	ld	a2,0(a4)
 7c4:	a83d                	j	802 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c6:	ff852703          	lw	a4,-8(a0)
 7ca:	9f31                	addw	a4,a4,a2
 7cc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ce:	ff053683          	ld	a3,-16(a0)
 7d2:	a091                	j	816 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d4:	6398                	ld	a4,0(a5)
 7d6:	00e7e463          	bltu	a5,a4,7de <free+0x3a>
 7da:	00e6ea63          	bltu	a3,a4,7ee <free+0x4a>
{
 7de:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e0:	fed7fae3          	bgeu	a5,a3,7d4 <free+0x30>
 7e4:	6398                	ld	a4,0(a5)
 7e6:	00e6e463          	bltu	a3,a4,7ee <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ea:	fee7eae3          	bltu	a5,a4,7de <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7ee:	ff852583          	lw	a1,-8(a0)
 7f2:	6390                	ld	a2,0(a5)
 7f4:	02059813          	slli	a6,a1,0x20
 7f8:	01c85713          	srli	a4,a6,0x1c
 7fc:	9736                	add	a4,a4,a3
 7fe:	fae60de3          	beq	a2,a4,7b8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 802:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 806:	4790                	lw	a2,8(a5)
 808:	02061593          	slli	a1,a2,0x20
 80c:	01c5d713          	srli	a4,a1,0x1c
 810:	973e                	add	a4,a4,a5
 812:	fae68ae3          	beq	a3,a4,7c6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 816:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 818:	00000717          	auipc	a4,0x0
 81c:	7ef73423          	sd	a5,2024(a4) # 1000 <freep>
}
 820:	6422                	ld	s0,8(sp)
 822:	0141                	addi	sp,sp,16
 824:	8082                	ret

0000000000000826 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 826:	7139                	addi	sp,sp,-64
 828:	fc06                	sd	ra,56(sp)
 82a:	f822                	sd	s0,48(sp)
 82c:	f426                	sd	s1,40(sp)
 82e:	ec4e                	sd	s3,24(sp)
 830:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 832:	02051493          	slli	s1,a0,0x20
 836:	9081                	srli	s1,s1,0x20
 838:	04bd                	addi	s1,s1,15
 83a:	8091                	srli	s1,s1,0x4
 83c:	0014899b          	addiw	s3,s1,1
 840:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 842:	00000517          	auipc	a0,0x0
 846:	7be53503          	ld	a0,1982(a0) # 1000 <freep>
 84a:	c915                	beqz	a0,87e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84e:	4798                	lw	a4,8(a5)
 850:	08977a63          	bgeu	a4,s1,8e4 <malloc+0xbe>
 854:	f04a                	sd	s2,32(sp)
 856:	e852                	sd	s4,16(sp)
 858:	e456                	sd	s5,8(sp)
 85a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 85c:	8a4e                	mv	s4,s3
 85e:	0009871b          	sext.w	a4,s3
 862:	6685                	lui	a3,0x1
 864:	00d77363          	bgeu	a4,a3,86a <malloc+0x44>
 868:	6a05                	lui	s4,0x1
 86a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 86e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 872:	00000917          	auipc	s2,0x0
 876:	78e90913          	addi	s2,s2,1934 # 1000 <freep>
  if(p == SBRK_ERROR)
 87a:	5afd                	li	s5,-1
 87c:	a081                	j	8bc <malloc+0x96>
 87e:	f04a                	sd	s2,32(sp)
 880:	e852                	sd	s4,16(sp)
 882:	e456                	sd	s5,8(sp)
 884:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 886:	00001797          	auipc	a5,0x1
 88a:	90a78793          	addi	a5,a5,-1782 # 1190 <base>
 88e:	00000717          	auipc	a4,0x0
 892:	76f73923          	sd	a5,1906(a4) # 1000 <freep>
 896:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 898:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 89c:	b7c1                	j	85c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 89e:	6398                	ld	a4,0(a5)
 8a0:	e118                	sd	a4,0(a0)
 8a2:	a8a9                	j	8fc <malloc+0xd6>
  hp->s.size = nu;
 8a4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a8:	0541                	addi	a0,a0,16
 8aa:	efbff0ef          	jal	7a4 <free>
  return freep;
 8ae:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8b2:	c12d                	beqz	a0,914 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b6:	4798                	lw	a4,8(a5)
 8b8:	02977263          	bgeu	a4,s1,8dc <malloc+0xb6>
    if(p == freep)
 8bc:	00093703          	ld	a4,0(s2)
 8c0:	853e                	mv	a0,a5
 8c2:	fef719e3          	bne	a4,a5,8b4 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8c6:	8552                	mv	a0,s4
 8c8:	a1fff0ef          	jal	2e6 <sbrk>
  if(p == SBRK_ERROR)
 8cc:	fd551ce3          	bne	a0,s5,8a4 <malloc+0x7e>
        return 0;
 8d0:	4501                	li	a0,0
 8d2:	7902                	ld	s2,32(sp)
 8d4:	6a42                	ld	s4,16(sp)
 8d6:	6aa2                	ld	s5,8(sp)
 8d8:	6b02                	ld	s6,0(sp)
 8da:	a03d                	j	908 <malloc+0xe2>
 8dc:	7902                	ld	s2,32(sp)
 8de:	6a42                	ld	s4,16(sp)
 8e0:	6aa2                	ld	s5,8(sp)
 8e2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8e4:	fae48de3          	beq	s1,a4,89e <malloc+0x78>
        p->s.size -= nunits;
 8e8:	4137073b          	subw	a4,a4,s3
 8ec:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ee:	02071693          	slli	a3,a4,0x20
 8f2:	01c6d713          	srli	a4,a3,0x1c
 8f6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8fc:	00000717          	auipc	a4,0x0
 900:	70a73223          	sd	a0,1796(a4) # 1000 <freep>
      return (void*)(p + 1);
 904:	01078513          	addi	a0,a5,16
  }
}
 908:	70e2                	ld	ra,56(sp)
 90a:	7442                	ld	s0,48(sp)
 90c:	74a2                	ld	s1,40(sp)
 90e:	69e2                	ld	s3,24(sp)
 910:	6121                	addi	sp,sp,64
 912:	8082                	ret
 914:	7902                	ld	s2,32(sp)
 916:	6a42                	ld	s4,16(sp)
 918:	6aa2                	ld	s5,8(sp)
 91a:	6b02                	ld	s6,0(sp)
 91c:	b7f5                	j	908 <malloc+0xe2>
