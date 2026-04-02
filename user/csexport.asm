
user/_csexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <append_str>:
#include "kernel/fslog.h" // لكي يعرف البرنامج هيكل fs_event

#define OUTBUF_SZ 512

// دوال المساعدة للـ JSON (نفس اللي عندك مع تعديلات طفيفة)
static void append_str(char *buf, int *pos, const char *s) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    while (*s && *pos < OUTBUF_SZ - 1) buf[(*pos)++] = *s++;
   8:	00064783          	lbu	a5,0(a2)
   c:	1fe00693          	li	a3,510
  10:	c385                	beqz	a5,30 <append_str+0x30>
  12:	419c                	lw	a5,0(a1)
  14:	00f6ce63          	blt	a3,a5,30 <append_str+0x30>
  18:	0605                	addi	a2,a2,1
  1a:	0017871b          	addiw	a4,a5,1
  1e:	c198                	sw	a4,0(a1)
  20:	fff64703          	lbu	a4,-1(a2)
  24:	97aa                	add	a5,a5,a0
  26:	00e78023          	sb	a4,0(a5)
  2a:	00064783          	lbu	a5,0(a2)
  2e:	f3f5                	bnez	a5,12 <append_str+0x12>
}
  30:	60a2                	ld	ra,8(sp)
  32:	6402                	ld	s0,0(sp)
  34:	0141                	addi	sp,sp,16
  36:	8082                	ret

0000000000000038 <append_uint>:

static void append_uint(char *buf, int *pos, uint x) {
    char tmp[16]; int n = 0;
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  38:	c649                	beqz	a2,c2 <append_uint+0x8a>
static void append_uint(char *buf, int *pos, uint x) {
  3a:	1101                	addi	sp,sp,-32
  3c:	ec06                	sd	ra,24(sp)
  3e:	e822                	sd	s0,16(sp)
  40:	1000                	addi	s0,sp,32
  42:	fe040813          	addi	a6,s0,-32
  46:	86c2                	mv	a3,a6
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
  48:	000cd337          	lui	t1,0xcd
  4c:	ccd30313          	addi	t1,t1,-819 # ccccd <base+0xcacbd>
  50:	0332                	slli	t1,t1,0xc
  52:	ccd30313          	addi	t1,t1,-819
  56:	4e25                	li	t3,9
  58:	02061713          	slli	a4,a2,0x20
  5c:	9301                	srli	a4,a4,0x20
  5e:	02670733          	mul	a4,a4,t1
  62:	930d                	srli	a4,a4,0x23
  64:	0027179b          	slliw	a5,a4,0x2
  68:	9fb9                	addw	a5,a5,a4
  6a:	0017979b          	slliw	a5,a5,0x1
  6e:	40f607bb          	subw	a5,a2,a5
  72:	0307879b          	addiw	a5,a5,48
  76:	00f68023          	sb	a5,0(a3)
  7a:	88b2                	mv	a7,a2
  7c:	863a                	mv	a2,a4
  7e:	87b6                	mv	a5,a3
  80:	0685                	addi	a3,a3,1
  82:	fd1e6be3          	bltu	t3,a7,58 <append_uint+0x20>
  86:	410787bb          	subw	a5,a5,a6
  8a:	2785                	addiw	a5,a5,1
    while (n > 0) buf[(*pos)++] = tmp[--n];
  8c:	02f05763          	blez	a5,ba <append_uint+0x82>
  90:	37fd                	addiw	a5,a5,-1
  92:	00f80733          	add	a4,a6,a5
  96:	fff80693          	addi	a3,a6,-1
  9a:	96be                	add	a3,a3,a5
  9c:	1782                	slli	a5,a5,0x20
  9e:	9381                	srli	a5,a5,0x20
  a0:	8e9d                	sub	a3,a3,a5
  a2:	419c                	lw	a5,0(a1)
  a4:	0017861b          	addiw	a2,a5,1
  a8:	c190                	sw	a2,0(a1)
  aa:	97aa                	add	a5,a5,a0
  ac:	00074603          	lbu	a2,0(a4)
  b0:	00c78023          	sb	a2,0(a5)
  b4:	177d                	addi	a4,a4,-1
  b6:	fed716e3          	bne	a4,a3,a2 <append_uint+0x6a>
}
  ba:	60e2                	ld	ra,24(sp)
  bc:	6442                	ld	s0,16(sp)
  be:	6105                	addi	sp,sp,32
  c0:	8082                	ret
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  c2:	419c                	lw	a5,0(a1)
  c4:	0017871b          	addiw	a4,a5,1
  c8:	c198                	sw	a4,0(a1)
  ca:	97aa                	add	a5,a5,a0
  cc:	03000713          	li	a4,48
  d0:	00e78023          	sb	a4,0(a5)
  d4:	8082                	ret

00000000000000d6 <main>:
static void print_cs_event(const struct cs_event *e) {
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
           e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
}

int main(void) {
  d6:	81010113          	addi	sp,sp,-2032
  da:	7e113423          	sd	ra,2024(sp)
  de:	7e813023          	sd	s0,2016(sp)
  e2:	7c913c23          	sd	s1,2008(sp)
  e6:	7d213823          	sd	s2,2000(sp)
  ea:	7d313423          	sd	s3,1992(sp)
  ee:	7d413023          	sd	s4,1984(sp)
  f2:	7b513c23          	sd	s5,1976(sp)
  f6:	7b613823          	sd	s6,1968(sp)
  fa:	7b713423          	sd	s7,1960(sp)
  fe:	7b813023          	sd	s8,1952(sp)
 102:	79913c23          	sd	s9,1944(sp)
 106:	79a13823          	sd	s10,1936(sp)
 10a:	79b13423          	sd	s11,1928(sp)
 10e:	7f010413          	addi	s0,sp,2032
 112:	97010113          	addi	sp,sp,-1680
    struct cs_event cs_ev[32];
    struct fs_event fs_ev[32];

    while (1) {
        // 1. قراءة أحداث المعالج
        int n_cs = csread(cs_ev, 32);
 116:	02000b13          	li	s6,32
            if (cs_ev[i].type == 1) // CS_RUN_START
                print_cs_event(&cs_ev[i]);
        }

        // 2. قراءة أحداث نظام الملفات (الجديدة)
        int n_fs = fsread(fs_ev, 32);
 11a:	80040b93          	addi	s7,s0,-2048
 11e:	f90b8b93          	addi	s7,s7,-112
 122:	c00b8b93          	addi	s7,s7,-1024
    int pos = 0;
 126:	80040a93          	addi	s5,s0,-2048
 12a:	f90a8a93          	addi	s5,s5,-112
 12e:	800a8a93          	addi	s5,s5,-2048
    memset(buf, 0, OUTBUF_SZ);
 132:	80040493          	addi	s1,s0,-2048
 136:	f9048493          	addi	s1,s1,-112
 13a:	a0048493          	addi	s1,s1,-1536
 13e:	aaa9                	j	298 <main+0x1c2>
        for (int i = 0; i < n_cs; i++) {
 140:	03090913          	addi	s2,s2,48
 144:	03390563          	beq	s2,s3,16e <main+0x98>
            if (cs_ev[i].type == 1) // CS_RUN_START
 148:	ff492783          	lw	a5,-12(s2)
 14c:	ff479ae3          	bne	a5,s4,140 <main+0x6a>
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
 150:	ffc92803          	lw	a6,-4(s2)
 154:	87ca                	mv	a5,s2
 156:	ff892703          	lw	a4,-8(s2)
 15a:	ff092683          	lw	a3,-16(s2)
 15e:	fec92603          	lw	a2,-20(s2)
 162:	fe493583          	ld	a1,-28(s2)
 166:	8562                	mv	a0,s8
 168:	06d000ef          	jal	9d4 <printf>
}
 16c:	bfd1                	j	140 <main+0x6a>
        int n_fs = fsread(fs_ev, 32);
 16e:	85da                	mv	a1,s6
 170:	855e                	mv	a0,s7
 172:	4ac000ef          	jal	61e <fsread>
        for (int i = 0; i < n_fs; i++) {
 176:	10a05e63          	blez	a0,292 <main+0x1bc>
 17a:	020b8993          	addi	s3,s7,32
 17e:	00151a13          	slli	s4,a0,0x1
 182:	9a2a                	add	s4,s4,a0
 184:	0a12                	slli	s4,s4,0x4
 186:	9a4e                	add	s4,s4,s3
    memset(buf, 0, OUTBUF_SZ);
 188:	20000d93          	li	s11,512
    append_str(buf, &pos, "EV {\"seq\":");
 18c:	80040913          	addi	s2,s0,-2048
 190:	f9090913          	addi	s2,s2,-112
 194:	9fc90913          	addi	s2,s2,-1540
 198:	00001d17          	auipc	s10,0x1
 19c:	a40d0d13          	addi	s10,s10,-1472 # bd8 <malloc+0x14c>
    append_str(buf, &pos, ",\"tick\":");
 1a0:	00001c97          	auipc	s9,0x1
 1a4:	a48c8c93          	addi	s9,s9,-1464 # be8 <malloc+0x15c>
    append_str(buf, &pos, ",\"type\":\"FS\",\"fs_type\":");
 1a8:	00001c17          	auipc	s8,0x1
 1ac:	a50c0c13          	addi	s8,s8,-1456 # bf8 <malloc+0x16c>
    int pos = 0;
 1b0:	1e0aae23          	sw	zero,508(s5)
    memset(buf, 0, OUTBUF_SZ);
 1b4:	866e                	mv	a2,s11
 1b6:	4581                	li	a1,0
 1b8:	8526                	mv	a0,s1
 1ba:	192000ef          	jal	34c <memset>
    append_str(buf, &pos, "EV {\"seq\":");
 1be:	866a                	mv	a2,s10
 1c0:	85ca                	mv	a1,s2
 1c2:	8526                	mv	a0,s1
 1c4:	e3dff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, (uint)e->seq);
 1c8:	fe09a603          	lw	a2,-32(s3)
 1cc:	85ca                	mv	a1,s2
 1ce:	8526                	mv	a0,s1
 1d0:	e69ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"tick\":");
 1d4:	8666                	mv	a2,s9
 1d6:	85ca                	mv	a1,s2
 1d8:	8526                	mv	a0,s1
 1da:	e27ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->ticks);
 1de:	fe89a603          	lw	a2,-24(s3)
 1e2:	85ca                	mv	a1,s2
 1e4:	8526                	mv	a0,s1
 1e6:	e53ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"type\":\"FS\",\"fs_type\":");
 1ea:	8662                	mv	a2,s8
 1ec:	85ca                	mv	a1,s2
 1ee:	8526                	mv	a0,s1
 1f0:	e11ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->type);
 1f4:	fec9a603          	lw	a2,-20(s3)
 1f8:	85ca                	mv	a1,s2
 1fa:	8526                	mv	a0,s1
 1fc:	e3dff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"pid\":");
 200:	00001617          	auipc	a2,0x1
 204:	a1060613          	addi	a2,a2,-1520 # c10 <malloc+0x184>
 208:	85ca                	mv	a1,s2
 20a:	8526                	mv	a0,s1
 20c:	df5ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->pid);
 210:	ff09a603          	lw	a2,-16(s3)
 214:	85ca                	mv	a1,s2
 216:	8526                	mv	a0,s1
 218:	e21ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"inum\":");
 21c:	00001617          	auipc	a2,0x1
 220:	9fc60613          	addi	a2,a2,-1540 # c18 <malloc+0x18c>
 224:	85ca                	mv	a1,s2
 226:	8526                	mv	a0,s1
 228:	dd9ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->inum);
 22c:	ff49a603          	lw	a2,-12(s3)
 230:	85ca                	mv	a1,s2
 232:	8526                	mv	a0,s1
 234:	e05ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"block\":");
 238:	00001617          	auipc	a2,0x1
 23c:	9f060613          	addi	a2,a2,-1552 # c28 <malloc+0x19c>
 240:	85ca                	mv	a1,s2
 242:	8526                	mv	a0,s1
 244:	dbdff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->blockno);
 248:	ff89a603          	lw	a2,-8(s3)
 24c:	85ca                	mv	a1,s2
 24e:	8526                	mv	a0,s1
 250:	de9ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"name\":\"");
 254:	00001617          	auipc	a2,0x1
 258:	9e460613          	addi	a2,a2,-1564 # c38 <malloc+0x1ac>
 25c:	85ca                	mv	a1,s2
 25e:	8526                	mv	a0,s1
 260:	da1ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
 264:	864e                	mv	a2,s3
 266:	85ca                	mv	a1,s2
 268:	8526                	mv	a0,s1
 26a:	d97ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"}\n");
 26e:	00001617          	auipc	a2,0x1
 272:	9da60613          	addi	a2,a2,-1574 # c48 <malloc+0x1bc>
 276:	85ca                	mv	a1,s2
 278:	8526                	mv	a0,s1
 27a:	d87ff0ef          	jal	0 <append_str>
    write(1, buf, pos);
 27e:	1fcaa603          	lw	a2,508(s5)
 282:	85a6                	mv	a1,s1
 284:	4505                	li	a0,1
 286:	310000ef          	jal	596 <write>
        for (int i = 0; i < n_fs; i++) {
 28a:	03098993          	addi	s3,s3,48
 28e:	f34991e3          	bne	s3,s4,1b0 <main+0xda>
            print_fs_event(&fs_ev[i]);
        }

        pause(2); // تخفيف الضغط على النظام
 292:	4509                	li	a0,2
 294:	372000ef          	jal	606 <pause>
        int n_cs = csread(cs_ev, 32);
 298:	85da                	mv	a1,s6
 29a:	99040513          	addi	a0,s0,-1648
 29e:	378000ef          	jal	616 <csread>
        for (int i = 0; i < n_cs; i++) {
 2a2:	eca056e3          	blez	a0,16e <main+0x98>
 2a6:	9ac40913          	addi	s2,s0,-1620
 2aa:	00151993          	slli	s3,a0,0x1
 2ae:	99aa                	add	s3,s3,a0
 2b0:	0992                	slli	s3,s3,0x4
 2b2:	99ca                	add	s3,s3,s2
            if (cs_ev[i].type == 1) // CS_RUN_START
 2b4:	4a05                	li	s4,1
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
 2b6:	00001c17          	auipc	s8,0x1
 2ba:	8cac0c13          	addi	s8,s8,-1846 # b80 <malloc+0xf4>
 2be:	b569                	j	148 <main+0x72>

00000000000002c0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e406                	sd	ra,8(sp)
 2c4:	e022                	sd	s0,0(sp)
 2c6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 2c8:	e0fff0ef          	jal	d6 <main>
  exit(r);
 2cc:	2aa000ef          	jal	576 <exit>

00000000000002d0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e406                	sd	ra,8(sp)
 2d4:	e022                	sd	s0,0(sp)
 2d6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2d8:	87aa                	mv	a5,a0
 2da:	0585                	addi	a1,a1,1
 2dc:	0785                	addi	a5,a5,1
 2de:	fff5c703          	lbu	a4,-1(a1)
 2e2:	fee78fa3          	sb	a4,-1(a5)
 2e6:	fb75                	bnez	a4,2da <strcpy+0xa>
    ;
  return os;
}
 2e8:	60a2                	ld	ra,8(sp)
 2ea:	6402                	ld	s0,0(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	cb91                	beqz	a5,310 <strcmp+0x20>
 2fe:	0005c703          	lbu	a4,0(a1)
 302:	00f71763          	bne	a4,a5,310 <strcmp+0x20>
    p++, q++;
 306:	0505                	addi	a0,a0,1
 308:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 30a:	00054783          	lbu	a5,0(a0)
 30e:	fbe5                	bnez	a5,2fe <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 310:	0005c503          	lbu	a0,0(a1)
}
 314:	40a7853b          	subw	a0,a5,a0
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret

0000000000000320 <strlen>:

uint
strlen(const char *s)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 328:	00054783          	lbu	a5,0(a0)
 32c:	cf91                	beqz	a5,348 <strlen+0x28>
 32e:	00150793          	addi	a5,a0,1
 332:	86be                	mv	a3,a5
 334:	0785                	addi	a5,a5,1
 336:	fff7c703          	lbu	a4,-1(a5)
 33a:	ff65                	bnez	a4,332 <strlen+0x12>
 33c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret
  for(n = 0; s[n]; n++)
 348:	4501                	li	a0,0
 34a:	bfdd                	j	340 <strlen+0x20>

000000000000034c <memset>:

void*
memset(void *dst, int c, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e406                	sd	ra,8(sp)
 350:	e022                	sd	s0,0(sp)
 352:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 354:	ca19                	beqz	a2,36a <memset+0x1e>
 356:	87aa                	mv	a5,a0
 358:	1602                	slli	a2,a2,0x20
 35a:	9201                	srli	a2,a2,0x20
 35c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 360:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 364:	0785                	addi	a5,a5,1
 366:	fee79de3          	bne	a5,a4,360 <memset+0x14>
  }
  return dst;
}
 36a:	60a2                	ld	ra,8(sp)
 36c:	6402                	ld	s0,0(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <strchr>:

char*
strchr(const char *s, char c)
{
 372:	1141                	addi	sp,sp,-16
 374:	e406                	sd	ra,8(sp)
 376:	e022                	sd	s0,0(sp)
 378:	0800                	addi	s0,sp,16
  for(; *s; s++)
 37a:	00054783          	lbu	a5,0(a0)
 37e:	cf81                	beqz	a5,396 <strchr+0x24>
    if(*s == c)
 380:	00f58763          	beq	a1,a5,38e <strchr+0x1c>
  for(; *s; s++)
 384:	0505                	addi	a0,a0,1
 386:	00054783          	lbu	a5,0(a0)
 38a:	fbfd                	bnez	a5,380 <strchr+0xe>
      return (char*)s;
  return 0;
 38c:	4501                	li	a0,0
}
 38e:	60a2                	ld	ra,8(sp)
 390:	6402                	ld	s0,0(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret
  return 0;
 396:	4501                	li	a0,0
 398:	bfdd                	j	38e <strchr+0x1c>

000000000000039a <gets>:

char*
gets(char *buf, int max)
{
 39a:	711d                	addi	sp,sp,-96
 39c:	ec86                	sd	ra,88(sp)
 39e:	e8a2                	sd	s0,80(sp)
 3a0:	e4a6                	sd	s1,72(sp)
 3a2:	e0ca                	sd	s2,64(sp)
 3a4:	fc4e                	sd	s3,56(sp)
 3a6:	f852                	sd	s4,48(sp)
 3a8:	f456                	sd	s5,40(sp)
 3aa:	f05a                	sd	s6,32(sp)
 3ac:	ec5e                	sd	s7,24(sp)
 3ae:	e862                	sd	s8,16(sp)
 3b0:	1080                	addi	s0,sp,96
 3b2:	8baa                	mv	s7,a0
 3b4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b6:	892a                	mv	s2,a0
 3b8:	4481                	li	s1,0
    cc = read(0, &c, 1);
 3ba:	faf40b13          	addi	s6,s0,-81
 3be:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 3c0:	8c26                	mv	s8,s1
 3c2:	0014899b          	addiw	s3,s1,1
 3c6:	84ce                	mv	s1,s3
 3c8:	0349d463          	bge	s3,s4,3f0 <gets+0x56>
    cc = read(0, &c, 1);
 3cc:	8656                	mv	a2,s5
 3ce:	85da                	mv	a1,s6
 3d0:	4501                	li	a0,0
 3d2:	1bc000ef          	jal	58e <read>
    if(cc < 1)
 3d6:	00a05d63          	blez	a0,3f0 <gets+0x56>
      break;
    buf[i++] = c;
 3da:	faf44783          	lbu	a5,-81(s0)
 3de:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3e2:	0905                	addi	s2,s2,1
 3e4:	ff678713          	addi	a4,a5,-10
 3e8:	c319                	beqz	a4,3ee <gets+0x54>
 3ea:	17cd                	addi	a5,a5,-13
 3ec:	fbf1                	bnez	a5,3c0 <gets+0x26>
    buf[i++] = c;
 3ee:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 3f0:	9c5e                	add	s8,s8,s7
 3f2:	000c0023          	sb	zero,0(s8)
  return buf;
}
 3f6:	855e                	mv	a0,s7
 3f8:	60e6                	ld	ra,88(sp)
 3fa:	6446                	ld	s0,80(sp)
 3fc:	64a6                	ld	s1,72(sp)
 3fe:	6906                	ld	s2,64(sp)
 400:	79e2                	ld	s3,56(sp)
 402:	7a42                	ld	s4,48(sp)
 404:	7aa2                	ld	s5,40(sp)
 406:	7b02                	ld	s6,32(sp)
 408:	6be2                	ld	s7,24(sp)
 40a:	6c42                	ld	s8,16(sp)
 40c:	6125                	addi	sp,sp,96
 40e:	8082                	ret

0000000000000410 <stat>:

int
stat(const char *n, struct stat *st)
{
 410:	1101                	addi	sp,sp,-32
 412:	ec06                	sd	ra,24(sp)
 414:	e822                	sd	s0,16(sp)
 416:	e04a                	sd	s2,0(sp)
 418:	1000                	addi	s0,sp,32
 41a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 41c:	4581                	li	a1,0
 41e:	198000ef          	jal	5b6 <open>
  if(fd < 0)
 422:	02054263          	bltz	a0,446 <stat+0x36>
 426:	e426                	sd	s1,8(sp)
 428:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 42a:	85ca                	mv	a1,s2
 42c:	1a2000ef          	jal	5ce <fstat>
 430:	892a                	mv	s2,a0
  close(fd);
 432:	8526                	mv	a0,s1
 434:	16a000ef          	jal	59e <close>
  return r;
 438:	64a2                	ld	s1,8(sp)
}
 43a:	854a                	mv	a0,s2
 43c:	60e2                	ld	ra,24(sp)
 43e:	6442                	ld	s0,16(sp)
 440:	6902                	ld	s2,0(sp)
 442:	6105                	addi	sp,sp,32
 444:	8082                	ret
    return -1;
 446:	57fd                	li	a5,-1
 448:	893e                	mv	s2,a5
 44a:	bfc5                	j	43a <stat+0x2a>

000000000000044c <atoi>:

int
atoi(const char *s)
{
 44c:	1141                	addi	sp,sp,-16
 44e:	e406                	sd	ra,8(sp)
 450:	e022                	sd	s0,0(sp)
 452:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 454:	00054683          	lbu	a3,0(a0)
 458:	fd06879b          	addiw	a5,a3,-48
 45c:	0ff7f793          	zext.b	a5,a5
 460:	4625                	li	a2,9
 462:	02f66963          	bltu	a2,a5,494 <atoi+0x48>
 466:	872a                	mv	a4,a0
  n = 0;
 468:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 46a:	0705                	addi	a4,a4,1
 46c:	0025179b          	slliw	a5,a0,0x2
 470:	9fa9                	addw	a5,a5,a0
 472:	0017979b          	slliw	a5,a5,0x1
 476:	9fb5                	addw	a5,a5,a3
 478:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 47c:	00074683          	lbu	a3,0(a4)
 480:	fd06879b          	addiw	a5,a3,-48
 484:	0ff7f793          	zext.b	a5,a5
 488:	fef671e3          	bgeu	a2,a5,46a <atoi+0x1e>
  return n;
}
 48c:	60a2                	ld	ra,8(sp)
 48e:	6402                	ld	s0,0(sp)
 490:	0141                	addi	sp,sp,16
 492:	8082                	ret
  n = 0;
 494:	4501                	li	a0,0
 496:	bfdd                	j	48c <atoi+0x40>

0000000000000498 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 498:	1141                	addi	sp,sp,-16
 49a:	e406                	sd	ra,8(sp)
 49c:	e022                	sd	s0,0(sp)
 49e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4a0:	02b57563          	bgeu	a0,a1,4ca <memmove+0x32>
    while(n-- > 0)
 4a4:	00c05f63          	blez	a2,4c2 <memmove+0x2a>
 4a8:	1602                	slli	a2,a2,0x20
 4aa:	9201                	srli	a2,a2,0x20
 4ac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 4b2:	0585                	addi	a1,a1,1
 4b4:	0705                	addi	a4,a4,1
 4b6:	fff5c683          	lbu	a3,-1(a1)
 4ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4be:	fee79ae3          	bne	a5,a4,4b2 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4c2:	60a2                	ld	ra,8(sp)
 4c4:	6402                	ld	s0,0(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret
    while(n-- > 0)
 4ca:	fec05ce3          	blez	a2,4c2 <memmove+0x2a>
    dst += n;
 4ce:	00c50733          	add	a4,a0,a2
    src += n;
 4d2:	95b2                	add	a1,a1,a2
 4d4:	fff6079b          	addiw	a5,a2,-1
 4d8:	1782                	slli	a5,a5,0x20
 4da:	9381                	srli	a5,a5,0x20
 4dc:	fff7c793          	not	a5,a5
 4e0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4e2:	15fd                	addi	a1,a1,-1
 4e4:	177d                	addi	a4,a4,-1
 4e6:	0005c683          	lbu	a3,0(a1)
 4ea:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4ee:	fef71ae3          	bne	a4,a5,4e2 <memmove+0x4a>
 4f2:	bfc1                	j	4c2 <memmove+0x2a>

00000000000004f4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4f4:	1141                	addi	sp,sp,-16
 4f6:	e406                	sd	ra,8(sp)
 4f8:	e022                	sd	s0,0(sp)
 4fa:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4fc:	c61d                	beqz	a2,52a <memcmp+0x36>
 4fe:	1602                	slli	a2,a2,0x20
 500:	9201                	srli	a2,a2,0x20
 502:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 506:	00054783          	lbu	a5,0(a0)
 50a:	0005c703          	lbu	a4,0(a1)
 50e:	00e79863          	bne	a5,a4,51e <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 512:	0505                	addi	a0,a0,1
    p2++;
 514:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 516:	fed518e3          	bne	a0,a3,506 <memcmp+0x12>
  }
  return 0;
 51a:	4501                	li	a0,0
 51c:	a019                	j	522 <memcmp+0x2e>
      return *p1 - *p2;
 51e:	40e7853b          	subw	a0,a5,a4
}
 522:	60a2                	ld	ra,8(sp)
 524:	6402                	ld	s0,0(sp)
 526:	0141                	addi	sp,sp,16
 528:	8082                	ret
  return 0;
 52a:	4501                	li	a0,0
 52c:	bfdd                	j	522 <memcmp+0x2e>

000000000000052e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 52e:	1141                	addi	sp,sp,-16
 530:	e406                	sd	ra,8(sp)
 532:	e022                	sd	s0,0(sp)
 534:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 536:	f63ff0ef          	jal	498 <memmove>
}
 53a:	60a2                	ld	ra,8(sp)
 53c:	6402                	ld	s0,0(sp)
 53e:	0141                	addi	sp,sp,16
 540:	8082                	ret

0000000000000542 <sbrk>:

char *
sbrk(int n) {
 542:	1141                	addi	sp,sp,-16
 544:	e406                	sd	ra,8(sp)
 546:	e022                	sd	s0,0(sp)
 548:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 54a:	4585                	li	a1,1
 54c:	0b2000ef          	jal	5fe <sys_sbrk>
}
 550:	60a2                	ld	ra,8(sp)
 552:	6402                	ld	s0,0(sp)
 554:	0141                	addi	sp,sp,16
 556:	8082                	ret

0000000000000558 <sbrklazy>:

char *
sbrklazy(int n) {
 558:	1141                	addi	sp,sp,-16
 55a:	e406                	sd	ra,8(sp)
 55c:	e022                	sd	s0,0(sp)
 55e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 560:	4589                	li	a1,2
 562:	09c000ef          	jal	5fe <sys_sbrk>
}
 566:	60a2                	ld	ra,8(sp)
 568:	6402                	ld	s0,0(sp)
 56a:	0141                	addi	sp,sp,16
 56c:	8082                	ret

000000000000056e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 56e:	4885                	li	a7,1
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <exit>:
.global exit
exit:
 li a7, SYS_exit
 576:	4889                	li	a7,2
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <wait>:
.global wait
wait:
 li a7, SYS_wait
 57e:	488d                	li	a7,3
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 586:	4891                	li	a7,4
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <read>:
.global read
read:
 li a7, SYS_read
 58e:	4895                	li	a7,5
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <write>:
.global write
write:
 li a7, SYS_write
 596:	48c1                	li	a7,16
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <close>:
.global close
close:
 li a7, SYS_close
 59e:	48d5                	li	a7,21
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5a6:	4899                	li	a7,6
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <exec>:
.global exec
exec:
 li a7, SYS_exec
 5ae:	489d                	li	a7,7
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <open>:
.global open
open:
 li a7, SYS_open
 5b6:	48bd                	li	a7,15
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5be:	48c5                	li	a7,17
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5c6:	48c9                	li	a7,18
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5ce:	48a1                	li	a7,8
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <link>:
.global link
link:
 li a7, SYS_link
 5d6:	48cd                	li	a7,19
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5de:	48d1                	li	a7,20
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5e6:	48a5                	li	a7,9
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <dup>:
.global dup
dup:
 li a7, SYS_dup
 5ee:	48a9                	li	a7,10
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5f6:	48ad                	li	a7,11
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 5fe:	48b1                	li	a7,12
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <pause>:
.global pause
pause:
 li a7, SYS_pause
 606:	48b5                	li	a7,13
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 60e:	48b9                	li	a7,14
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <csread>:
.global csread
csread:
 li a7, SYS_csread
 616:	48d9                	li	a7,22
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 61e:	48dd                	li	a7,23
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 626:	48e1                	li	a7,24
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 62e:	1101                	addi	sp,sp,-32
 630:	ec06                	sd	ra,24(sp)
 632:	e822                	sd	s0,16(sp)
 634:	1000                	addi	s0,sp,32
 636:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 63a:	4605                	li	a2,1
 63c:	fef40593          	addi	a1,s0,-17
 640:	f57ff0ef          	jal	596 <write>
}
 644:	60e2                	ld	ra,24(sp)
 646:	6442                	ld	s0,16(sp)
 648:	6105                	addi	sp,sp,32
 64a:	8082                	ret

000000000000064c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 64c:	715d                	addi	sp,sp,-80
 64e:	e486                	sd	ra,72(sp)
 650:	e0a2                	sd	s0,64(sp)
 652:	f84a                	sd	s2,48(sp)
 654:	f44e                	sd	s3,40(sp)
 656:	0880                	addi	s0,sp,80
 658:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 65a:	c6d1                	beqz	a3,6e6 <printint+0x9a>
 65c:	0805d563          	bgez	a1,6e6 <printint+0x9a>
    neg = 1;
    x = -xx;
 660:	40b005b3          	neg	a1,a1
    neg = 1;
 664:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 666:	fb840993          	addi	s3,s0,-72
  neg = 0;
 66a:	86ce                	mv	a3,s3
  i = 0;
 66c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 66e:	00000817          	auipc	a6,0x0
 672:	5ea80813          	addi	a6,a6,1514 # c58 <digits>
 676:	88ba                	mv	a7,a4
 678:	0017051b          	addiw	a0,a4,1
 67c:	872a                	mv	a4,a0
 67e:	02c5f7b3          	remu	a5,a1,a2
 682:	97c2                	add	a5,a5,a6
 684:	0007c783          	lbu	a5,0(a5)
 688:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 68c:	87ae                	mv	a5,a1
 68e:	02c5d5b3          	divu	a1,a1,a2
 692:	0685                	addi	a3,a3,1
 694:	fec7f1e3          	bgeu	a5,a2,676 <printint+0x2a>
  if(neg)
 698:	00030c63          	beqz	t1,6b0 <printint+0x64>
    buf[i++] = '-';
 69c:	fd050793          	addi	a5,a0,-48
 6a0:	00878533          	add	a0,a5,s0
 6a4:	02d00793          	li	a5,45
 6a8:	fef50423          	sb	a5,-24(a0)
 6ac:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 6b0:	02e05563          	blez	a4,6da <printint+0x8e>
 6b4:	fc26                	sd	s1,56(sp)
 6b6:	377d                	addiw	a4,a4,-1
 6b8:	00e984b3          	add	s1,s3,a4
 6bc:	19fd                	addi	s3,s3,-1
 6be:	99ba                	add	s3,s3,a4
 6c0:	1702                	slli	a4,a4,0x20
 6c2:	9301                	srli	a4,a4,0x20
 6c4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6c8:	0004c583          	lbu	a1,0(s1)
 6cc:	854a                	mv	a0,s2
 6ce:	f61ff0ef          	jal	62e <putc>
  while(--i >= 0)
 6d2:	14fd                	addi	s1,s1,-1
 6d4:	ff349ae3          	bne	s1,s3,6c8 <printint+0x7c>
 6d8:	74e2                	ld	s1,56(sp)
}
 6da:	60a6                	ld	ra,72(sp)
 6dc:	6406                	ld	s0,64(sp)
 6de:	7942                	ld	s2,48(sp)
 6e0:	79a2                	ld	s3,40(sp)
 6e2:	6161                	addi	sp,sp,80
 6e4:	8082                	ret
  neg = 0;
 6e6:	4301                	li	t1,0
 6e8:	bfbd                	j	666 <printint+0x1a>

00000000000006ea <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6ea:	711d                	addi	sp,sp,-96
 6ec:	ec86                	sd	ra,88(sp)
 6ee:	e8a2                	sd	s0,80(sp)
 6f0:	e4a6                	sd	s1,72(sp)
 6f2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6f4:	0005c483          	lbu	s1,0(a1)
 6f8:	22048363          	beqz	s1,91e <vprintf+0x234>
 6fc:	e0ca                	sd	s2,64(sp)
 6fe:	fc4e                	sd	s3,56(sp)
 700:	f852                	sd	s4,48(sp)
 702:	f456                	sd	s5,40(sp)
 704:	f05a                	sd	s6,32(sp)
 706:	ec5e                	sd	s7,24(sp)
 708:	e862                	sd	s8,16(sp)
 70a:	8b2a                	mv	s6,a0
 70c:	8a2e                	mv	s4,a1
 70e:	8bb2                	mv	s7,a2
  state = 0;
 710:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 712:	4901                	li	s2,0
 714:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 716:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 71a:	06400c13          	li	s8,100
 71e:	a00d                	j	740 <vprintf+0x56>
        putc(fd, c0);
 720:	85a6                	mv	a1,s1
 722:	855a                	mv	a0,s6
 724:	f0bff0ef          	jal	62e <putc>
 728:	a019                	j	72e <vprintf+0x44>
    } else if(state == '%'){
 72a:	03598363          	beq	s3,s5,750 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 72e:	0019079b          	addiw	a5,s2,1
 732:	893e                	mv	s2,a5
 734:	873e                	mv	a4,a5
 736:	97d2                	add	a5,a5,s4
 738:	0007c483          	lbu	s1,0(a5)
 73c:	1c048a63          	beqz	s1,910 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 740:	0004879b          	sext.w	a5,s1
    if(state == 0){
 744:	fe0993e3          	bnez	s3,72a <vprintf+0x40>
      if(c0 == '%'){
 748:	fd579ce3          	bne	a5,s5,720 <vprintf+0x36>
        state = '%';
 74c:	89be                	mv	s3,a5
 74e:	b7c5                	j	72e <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 750:	00ea06b3          	add	a3,s4,a4
 754:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 758:	1c060863          	beqz	a2,928 <vprintf+0x23e>
      if(c0 == 'd'){
 75c:	03878763          	beq	a5,s8,78a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 760:	f9478693          	addi	a3,a5,-108
 764:	0016b693          	seqz	a3,a3
 768:	f9c60593          	addi	a1,a2,-100
 76c:	e99d                	bnez	a1,7a2 <vprintf+0xb8>
 76e:	ca95                	beqz	a3,7a2 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 770:	008b8493          	addi	s1,s7,8
 774:	4685                	li	a3,1
 776:	4629                	li	a2,10
 778:	000bb583          	ld	a1,0(s7)
 77c:	855a                	mv	a0,s6
 77e:	ecfff0ef          	jal	64c <printint>
        i += 1;
 782:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 784:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 786:	4981                	li	s3,0
 788:	b75d                	j	72e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 78a:	008b8493          	addi	s1,s7,8
 78e:	4685                	li	a3,1
 790:	4629                	li	a2,10
 792:	000ba583          	lw	a1,0(s7)
 796:	855a                	mv	a0,s6
 798:	eb5ff0ef          	jal	64c <printint>
 79c:	8ba6                	mv	s7,s1
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	b779                	j	72e <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 7a2:	9752                	add	a4,a4,s4
 7a4:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7a8:	f9460713          	addi	a4,a2,-108
 7ac:	00173713          	seqz	a4,a4
 7b0:	8f75                	and	a4,a4,a3
 7b2:	f9c58513          	addi	a0,a1,-100
 7b6:	18051363          	bnez	a0,93c <vprintf+0x252>
 7ba:	18070163          	beqz	a4,93c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7be:	008b8493          	addi	s1,s7,8
 7c2:	4685                	li	a3,1
 7c4:	4629                	li	a2,10
 7c6:	000bb583          	ld	a1,0(s7)
 7ca:	855a                	mv	a0,s6
 7cc:	e81ff0ef          	jal	64c <printint>
        i += 2;
 7d0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d2:	8ba6                	mv	s7,s1
      state = 0;
 7d4:	4981                	li	s3,0
        i += 2;
 7d6:	bfa1                	j	72e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7d8:	008b8493          	addi	s1,s7,8
 7dc:	4681                	li	a3,0
 7de:	4629                	li	a2,10
 7e0:	000be583          	lwu	a1,0(s7)
 7e4:	855a                	mv	a0,s6
 7e6:	e67ff0ef          	jal	64c <printint>
 7ea:	8ba6                	mv	s7,s1
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	b781                	j	72e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f0:	008b8493          	addi	s1,s7,8
 7f4:	4681                	li	a3,0
 7f6:	4629                	li	a2,10
 7f8:	000bb583          	ld	a1,0(s7)
 7fc:	855a                	mv	a0,s6
 7fe:	e4fff0ef          	jal	64c <printint>
        i += 1;
 802:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 804:	8ba6                	mv	s7,s1
      state = 0;
 806:	4981                	li	s3,0
 808:	b71d                	j	72e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 80a:	008b8493          	addi	s1,s7,8
 80e:	4681                	li	a3,0
 810:	4629                	li	a2,10
 812:	000bb583          	ld	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	e35ff0ef          	jal	64c <printint>
        i += 2;
 81c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 81e:	8ba6                	mv	s7,s1
      state = 0;
 820:	4981                	li	s3,0
        i += 2;
 822:	b731                	j	72e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 824:	008b8493          	addi	s1,s7,8
 828:	4681                	li	a3,0
 82a:	4641                	li	a2,16
 82c:	000be583          	lwu	a1,0(s7)
 830:	855a                	mv	a0,s6
 832:	e1bff0ef          	jal	64c <printint>
 836:	8ba6                	mv	s7,s1
      state = 0;
 838:	4981                	li	s3,0
 83a:	bdd5                	j	72e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 83c:	008b8493          	addi	s1,s7,8
 840:	4681                	li	a3,0
 842:	4641                	li	a2,16
 844:	000bb583          	ld	a1,0(s7)
 848:	855a                	mv	a0,s6
 84a:	e03ff0ef          	jal	64c <printint>
        i += 1;
 84e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 850:	8ba6                	mv	s7,s1
      state = 0;
 852:	4981                	li	s3,0
 854:	bde9                	j	72e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 856:	008b8493          	addi	s1,s7,8
 85a:	4681                	li	a3,0
 85c:	4641                	li	a2,16
 85e:	000bb583          	ld	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	de9ff0ef          	jal	64c <printint>
        i += 2;
 868:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 86a:	8ba6                	mv	s7,s1
      state = 0;
 86c:	4981                	li	s3,0
        i += 2;
 86e:	b5c1                	j	72e <vprintf+0x44>
 870:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 872:	008b8793          	addi	a5,s7,8
 876:	8cbe                	mv	s9,a5
 878:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 87c:	03000593          	li	a1,48
 880:	855a                	mv	a0,s6
 882:	dadff0ef          	jal	62e <putc>
  putc(fd, 'x');
 886:	07800593          	li	a1,120
 88a:	855a                	mv	a0,s6
 88c:	da3ff0ef          	jal	62e <putc>
 890:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 892:	00000b97          	auipc	s7,0x0
 896:	3c6b8b93          	addi	s7,s7,966 # c58 <digits>
 89a:	03c9d793          	srli	a5,s3,0x3c
 89e:	97de                	add	a5,a5,s7
 8a0:	0007c583          	lbu	a1,0(a5)
 8a4:	855a                	mv	a0,s6
 8a6:	d89ff0ef          	jal	62e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8aa:	0992                	slli	s3,s3,0x4
 8ac:	34fd                	addiw	s1,s1,-1
 8ae:	f4f5                	bnez	s1,89a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 8b0:	8be6                	mv	s7,s9
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	6ca2                	ld	s9,8(sp)
 8b6:	bda5                	j	72e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 8b8:	008b8493          	addi	s1,s7,8
 8bc:	000bc583          	lbu	a1,0(s7)
 8c0:	855a                	mv	a0,s6
 8c2:	d6dff0ef          	jal	62e <putc>
 8c6:	8ba6                	mv	s7,s1
      state = 0;
 8c8:	4981                	li	s3,0
 8ca:	b595                	j	72e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 8cc:	008b8993          	addi	s3,s7,8
 8d0:	000bb483          	ld	s1,0(s7)
 8d4:	cc91                	beqz	s1,8f0 <vprintf+0x206>
        for(; *s; s++)
 8d6:	0004c583          	lbu	a1,0(s1)
 8da:	c985                	beqz	a1,90a <vprintf+0x220>
          putc(fd, *s);
 8dc:	855a                	mv	a0,s6
 8de:	d51ff0ef          	jal	62e <putc>
        for(; *s; s++)
 8e2:	0485                	addi	s1,s1,1
 8e4:	0004c583          	lbu	a1,0(s1)
 8e8:	f9f5                	bnez	a1,8dc <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 8ea:	8bce                	mv	s7,s3
      state = 0;
 8ec:	4981                	li	s3,0
 8ee:	b581                	j	72e <vprintf+0x44>
          s = "(null)";
 8f0:	00000497          	auipc	s1,0x0
 8f4:	36048493          	addi	s1,s1,864 # c50 <malloc+0x1c4>
        for(; *s; s++)
 8f8:	02800593          	li	a1,40
 8fc:	b7c5                	j	8dc <vprintf+0x1f2>
        putc(fd, '%');
 8fe:	85be                	mv	a1,a5
 900:	855a                	mv	a0,s6
 902:	d2dff0ef          	jal	62e <putc>
      state = 0;
 906:	4981                	li	s3,0
 908:	b51d                	j	72e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 90a:	8bce                	mv	s7,s3
      state = 0;
 90c:	4981                	li	s3,0
 90e:	b505                	j	72e <vprintf+0x44>
 910:	6906                	ld	s2,64(sp)
 912:	79e2                	ld	s3,56(sp)
 914:	7a42                	ld	s4,48(sp)
 916:	7aa2                	ld	s5,40(sp)
 918:	7b02                	ld	s6,32(sp)
 91a:	6be2                	ld	s7,24(sp)
 91c:	6c42                	ld	s8,16(sp)
    }
  }
}
 91e:	60e6                	ld	ra,88(sp)
 920:	6446                	ld	s0,80(sp)
 922:	64a6                	ld	s1,72(sp)
 924:	6125                	addi	sp,sp,96
 926:	8082                	ret
      if(c0 == 'd'){
 928:	06400713          	li	a4,100
 92c:	e4e78fe3          	beq	a5,a4,78a <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 930:	f9478693          	addi	a3,a5,-108
 934:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 938:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 93a:	4701                	li	a4,0
      } else if(c0 == 'u'){
 93c:	07500513          	li	a0,117
 940:	e8a78ce3          	beq	a5,a0,7d8 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 944:	f8b60513          	addi	a0,a2,-117
 948:	e119                	bnez	a0,94e <vprintf+0x264>
 94a:	ea0693e3          	bnez	a3,7f0 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 94e:	f8b58513          	addi	a0,a1,-117
 952:	e119                	bnez	a0,958 <vprintf+0x26e>
 954:	ea071be3          	bnez	a4,80a <vprintf+0x120>
      } else if(c0 == 'x'){
 958:	07800513          	li	a0,120
 95c:	eca784e3          	beq	a5,a0,824 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 960:	f8860613          	addi	a2,a2,-120
 964:	e219                	bnez	a2,96a <vprintf+0x280>
 966:	ec069be3          	bnez	a3,83c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 96a:	f8858593          	addi	a1,a1,-120
 96e:	e199                	bnez	a1,974 <vprintf+0x28a>
 970:	ee0713e3          	bnez	a4,856 <vprintf+0x16c>
      } else if(c0 == 'p'){
 974:	07000713          	li	a4,112
 978:	eee78ce3          	beq	a5,a4,870 <vprintf+0x186>
      } else if(c0 == 'c'){
 97c:	06300713          	li	a4,99
 980:	f2e78ce3          	beq	a5,a4,8b8 <vprintf+0x1ce>
      } else if(c0 == 's'){
 984:	07300713          	li	a4,115
 988:	f4e782e3          	beq	a5,a4,8cc <vprintf+0x1e2>
      } else if(c0 == '%'){
 98c:	02500713          	li	a4,37
 990:	f6e787e3          	beq	a5,a4,8fe <vprintf+0x214>
        putc(fd, '%');
 994:	02500593          	li	a1,37
 998:	855a                	mv	a0,s6
 99a:	c95ff0ef          	jal	62e <putc>
        putc(fd, c0);
 99e:	85a6                	mv	a1,s1
 9a0:	855a                	mv	a0,s6
 9a2:	c8dff0ef          	jal	62e <putc>
      state = 0;
 9a6:	4981                	li	s3,0
 9a8:	b359                	j	72e <vprintf+0x44>

00000000000009aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9aa:	715d                	addi	sp,sp,-80
 9ac:	ec06                	sd	ra,24(sp)
 9ae:	e822                	sd	s0,16(sp)
 9b0:	1000                	addi	s0,sp,32
 9b2:	e010                	sd	a2,0(s0)
 9b4:	e414                	sd	a3,8(s0)
 9b6:	e818                	sd	a4,16(s0)
 9b8:	ec1c                	sd	a5,24(s0)
 9ba:	03043023          	sd	a6,32(s0)
 9be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9c2:	8622                	mv	a2,s0
 9c4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9c8:	d23ff0ef          	jal	6ea <vprintf>
}
 9cc:	60e2                	ld	ra,24(sp)
 9ce:	6442                	ld	s0,16(sp)
 9d0:	6161                	addi	sp,sp,80
 9d2:	8082                	ret

00000000000009d4 <printf>:

void
printf(const char *fmt, ...)
{
 9d4:	711d                	addi	sp,sp,-96
 9d6:	ec06                	sd	ra,24(sp)
 9d8:	e822                	sd	s0,16(sp)
 9da:	1000                	addi	s0,sp,32
 9dc:	e40c                	sd	a1,8(s0)
 9de:	e810                	sd	a2,16(s0)
 9e0:	ec14                	sd	a3,24(s0)
 9e2:	f018                	sd	a4,32(s0)
 9e4:	f41c                	sd	a5,40(s0)
 9e6:	03043823          	sd	a6,48(s0)
 9ea:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9ee:	00840613          	addi	a2,s0,8
 9f2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9f6:	85aa                	mv	a1,a0
 9f8:	4505                	li	a0,1
 9fa:	cf1ff0ef          	jal	6ea <vprintf>
}
 9fe:	60e2                	ld	ra,24(sp)
 a00:	6442                	ld	s0,16(sp)
 a02:	6125                	addi	sp,sp,96
 a04:	8082                	ret

0000000000000a06 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a06:	1141                	addi	sp,sp,-16
 a08:	e406                	sd	ra,8(sp)
 a0a:	e022                	sd	s0,0(sp)
 a0c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a0e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a12:	00001797          	auipc	a5,0x1
 a16:	5ee7b783          	ld	a5,1518(a5) # 2000 <freep>
 a1a:	a039                	j	a28 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a1c:	6398                	ld	a4,0(a5)
 a1e:	00e7e463          	bltu	a5,a4,a26 <free+0x20>
 a22:	00e6ea63          	bltu	a3,a4,a36 <free+0x30>
{
 a26:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a28:	fed7fae3          	bgeu	a5,a3,a1c <free+0x16>
 a2c:	6398                	ld	a4,0(a5)
 a2e:	00e6e463          	bltu	a3,a4,a36 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a32:	fee7eae3          	bltu	a5,a4,a26 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a36:	ff852583          	lw	a1,-8(a0)
 a3a:	6390                	ld	a2,0(a5)
 a3c:	02059813          	slli	a6,a1,0x20
 a40:	01c85713          	srli	a4,a6,0x1c
 a44:	9736                	add	a4,a4,a3
 a46:	02e60563          	beq	a2,a4,a70 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 a4a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 a4e:	4790                	lw	a2,8(a5)
 a50:	02061593          	slli	a1,a2,0x20
 a54:	01c5d713          	srli	a4,a1,0x1c
 a58:	973e                	add	a4,a4,a5
 a5a:	02e68263          	beq	a3,a4,a7e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 a5e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a60:	00001717          	auipc	a4,0x1
 a64:	5af73023          	sd	a5,1440(a4) # 2000 <freep>
}
 a68:	60a2                	ld	ra,8(sp)
 a6a:	6402                	ld	s0,0(sp)
 a6c:	0141                	addi	sp,sp,16
 a6e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 a70:	4618                	lw	a4,8(a2)
 a72:	9f2d                	addw	a4,a4,a1
 a74:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a78:	6398                	ld	a4,0(a5)
 a7a:	6310                	ld	a2,0(a4)
 a7c:	b7f9                	j	a4a <free+0x44>
    p->s.size += bp->s.size;
 a7e:	ff852703          	lw	a4,-8(a0)
 a82:	9f31                	addw	a4,a4,a2
 a84:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a86:	ff053683          	ld	a3,-16(a0)
 a8a:	bfd1                	j	a5e <free+0x58>

0000000000000a8c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a8c:	7139                	addi	sp,sp,-64
 a8e:	fc06                	sd	ra,56(sp)
 a90:	f822                	sd	s0,48(sp)
 a92:	f04a                	sd	s2,32(sp)
 a94:	ec4e                	sd	s3,24(sp)
 a96:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a98:	02051993          	slli	s3,a0,0x20
 a9c:	0209d993          	srli	s3,s3,0x20
 aa0:	09bd                	addi	s3,s3,15
 aa2:	0049d993          	srli	s3,s3,0x4
 aa6:	2985                	addiw	s3,s3,1
 aa8:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 aaa:	00001517          	auipc	a0,0x1
 aae:	55653503          	ld	a0,1366(a0) # 2000 <freep>
 ab2:	c905                	beqz	a0,ae2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ab6:	4798                	lw	a4,8(a5)
 ab8:	09377663          	bgeu	a4,s3,b44 <malloc+0xb8>
 abc:	f426                	sd	s1,40(sp)
 abe:	e852                	sd	s4,16(sp)
 ac0:	e456                	sd	s5,8(sp)
 ac2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 ac4:	8a4e                	mv	s4,s3
 ac6:	6705                	lui	a4,0x1
 ac8:	00e9f363          	bgeu	s3,a4,ace <malloc+0x42>
 acc:	6a05                	lui	s4,0x1
 ace:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ad2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ad6:	00001497          	auipc	s1,0x1
 ada:	52a48493          	addi	s1,s1,1322 # 2000 <freep>
  if(p == SBRK_ERROR)
 ade:	5afd                	li	s5,-1
 ae0:	a83d                	j	b1e <malloc+0x92>
 ae2:	f426                	sd	s1,40(sp)
 ae4:	e852                	sd	s4,16(sp)
 ae6:	e456                	sd	s5,8(sp)
 ae8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 aea:	00001797          	auipc	a5,0x1
 aee:	52678793          	addi	a5,a5,1318 # 2010 <base>
 af2:	00001717          	auipc	a4,0x1
 af6:	50f73723          	sd	a5,1294(a4) # 2000 <freep>
 afa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 afc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b00:	b7d1                	j	ac4 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 b02:	6398                	ld	a4,0(a5)
 b04:	e118                	sd	a4,0(a0)
 b06:	a899                	j	b5c <malloc+0xd0>
  hp->s.size = nu;
 b08:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b0c:	0541                	addi	a0,a0,16
 b0e:	ef9ff0ef          	jal	a06 <free>
  return freep;
 b12:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 b14:	c125                	beqz	a0,b74 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b16:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b18:	4798                	lw	a4,8(a5)
 b1a:	03277163          	bgeu	a4,s2,b3c <malloc+0xb0>
    if(p == freep)
 b1e:	6098                	ld	a4,0(s1)
 b20:	853e                	mv	a0,a5
 b22:	fef71ae3          	bne	a4,a5,b16 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 b26:	8552                	mv	a0,s4
 b28:	a1bff0ef          	jal	542 <sbrk>
  if(p == SBRK_ERROR)
 b2c:	fd551ee3          	bne	a0,s5,b08 <malloc+0x7c>
        return 0;
 b30:	4501                	li	a0,0
 b32:	74a2                	ld	s1,40(sp)
 b34:	6a42                	ld	s4,16(sp)
 b36:	6aa2                	ld	s5,8(sp)
 b38:	6b02                	ld	s6,0(sp)
 b3a:	a03d                	j	b68 <malloc+0xdc>
 b3c:	74a2                	ld	s1,40(sp)
 b3e:	6a42                	ld	s4,16(sp)
 b40:	6aa2                	ld	s5,8(sp)
 b42:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b44:	fae90fe3          	beq	s2,a4,b02 <malloc+0x76>
        p->s.size -= nunits;
 b48:	4137073b          	subw	a4,a4,s3
 b4c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b4e:	02071693          	slli	a3,a4,0x20
 b52:	01c6d713          	srli	a4,a3,0x1c
 b56:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b58:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b5c:	00001717          	auipc	a4,0x1
 b60:	4aa73223          	sd	a0,1188(a4) # 2000 <freep>
      return (void*)(p + 1);
 b64:	01078513          	addi	a0,a5,16
  }
}
 b68:	70e2                	ld	ra,56(sp)
 b6a:	7442                	ld	s0,48(sp)
 b6c:	7902                	ld	s2,32(sp)
 b6e:	69e2                	ld	s3,24(sp)
 b70:	6121                	addi	sp,sp,64
 b72:	8082                	ret
 b74:	74a2                	ld	s1,40(sp)
 b76:	6a42                	ld	s4,16(sp)
 b78:	6aa2                	ld	s5,8(sp)
 b7a:	6b02                	ld	s6,0(sp)
 b7c:	b7f5                	j	b68 <malloc+0xdc>
