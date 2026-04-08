
user/_csexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <append_str>:
#include "kernel/fslog.h" // لكي يعرف البرنامج هيكل fs_event

#define OUTBUF_SZ 512

// دوال المساعدة للـ JSON (نفس اللي عندك مع تعديلات طفيفة)
static void append_str(char *buf, int *pos, const char *s) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    while (*s && *pos < OUTBUF_SZ - 1) buf[(*pos)++] = *s++;
   6:	00064783          	lbu	a5,0(a2)
   a:	1fe00693          	li	a3,510
   e:	c385                	beqz	a5,2e <append_str+0x2e>
  10:	419c                	lw	a5,0(a1)
  12:	00f6ce63          	blt	a3,a5,2e <append_str+0x2e>
  16:	0605                	addi	a2,a2,1
  18:	0017871b          	addiw	a4,a5,1
  1c:	c198                	sw	a4,0(a1)
  1e:	fff64703          	lbu	a4,-1(a2)
  22:	97aa                	add	a5,a5,a0
  24:	00e78023          	sb	a4,0(a5)
  28:	00064783          	lbu	a5,0(a2)
  2c:	f3f5                	bnez	a5,10 <append_str+0x10>
}
  2e:	6422                	ld	s0,8(sp)
  30:	0141                	addi	sp,sp,16
  32:	8082                	ret

0000000000000034 <append_uint>:

static void append_uint(char *buf, int *pos, uint x) {
  34:	1101                	addi	sp,sp,-32
  36:	ec22                	sd	s0,24(sp)
  38:	1000                	addi	s0,sp,32
    char tmp[16]; int n = 0;
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  3a:	fe040813          	addi	a6,s0,-32
  3e:	87c2                	mv	a5,a6
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
  40:	46a9                	li	a3,10
  42:	4325                	li	t1,9
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  44:	c225                	beqz	a2,a4 <append_uint+0x70>
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
  46:	02d6773b          	remuw	a4,a2,a3
  4a:	0307071b          	addiw	a4,a4,48
  4e:	00e78023          	sb	a4,0(a5)
  52:	0006089b          	sext.w	a7,a2
  56:	02d6563b          	divuw	a2,a2,a3
  5a:	873e                	mv	a4,a5
  5c:	0785                	addi	a5,a5,1
  5e:	ff1364e3          	bltu	t1,a7,46 <append_uint+0x12>
  62:	4107073b          	subw	a4,a4,a6
  66:	0017079b          	addiw	a5,a4,1
  6a:	0007861b          	sext.w	a2,a5
    while (n > 0) buf[(*pos)++] = tmp[--n];
  6e:	02c05863          	blez	a2,9e <append_uint+0x6a>
  72:	fe040713          	addi	a4,s0,-32
  76:	9732                	add	a4,a4,a2
  78:	fff80693          	addi	a3,a6,-1
  7c:	96b2                	add	a3,a3,a2
  7e:	37fd                	addiw	a5,a5,-1
  80:	1782                	slli	a5,a5,0x20
  82:	9381                	srli	a5,a5,0x20
  84:	8e9d                	sub	a3,a3,a5
  86:	419c                	lw	a5,0(a1)
  88:	0017861b          	addiw	a2,a5,1
  8c:	c190                	sw	a2,0(a1)
  8e:	97aa                	add	a5,a5,a0
  90:	fff74603          	lbu	a2,-1(a4)
  94:	00c78023          	sb	a2,0(a5)
  98:	177d                	addi	a4,a4,-1
  9a:	fed716e3          	bne	a4,a3,86 <append_uint+0x52>
}
  9e:	6462                	ld	s0,24(sp)
  a0:	6105                	addi	sp,sp,32
  a2:	8082                	ret
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  a4:	419c                	lw	a5,0(a1)
  a6:	0017871b          	addiw	a4,a5,1
  aa:	c198                	sw	a4,0(a1)
  ac:	97aa                	add	a5,a5,a0
  ae:	03000713          	li	a4,48
  b2:	00e78023          	sb	a4,0(a5)
  b6:	b7e5                	j	9e <append_uint+0x6a>

00000000000000b8 <main>:
static void print_cs_event(const struct cs_event *e) {
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
           e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
}

int main(void) {
  b8:	81010113          	addi	sp,sp,-2032
  bc:	7e113423          	sd	ra,2024(sp)
  c0:	7e813023          	sd	s0,2016(sp)
  c4:	7c913c23          	sd	s1,2008(sp)
  c8:	7d213823          	sd	s2,2000(sp)
  cc:	7d313423          	sd	s3,1992(sp)
  d0:	7d413023          	sd	s4,1984(sp)
  d4:	7b513c23          	sd	s5,1976(sp)
  d8:	7b613823          	sd	s6,1968(sp)
  dc:	7b713423          	sd	s7,1960(sp)
  e0:	7b813023          	sd	s8,1952(sp)
  e4:	79913c23          	sd	s9,1944(sp)
  e8:	79a13823          	sd	s10,1936(sp)
  ec:	7f010413          	addi	s0,sp,2032
  f0:	97010113          	addi	sp,sp,-1680
            if (cs_ev[i].type == 1) // CS_RUN_START
                print_cs_event(&cs_ev[i]);
        }

        // 2. قراءة أحداث نظام الملفات (الجديدة)
        int n_fs = fsread(fs_ev, 32);
  f4:	77fd                	lui	a5,0xfffff
  f6:	3a078793          	addi	a5,a5,928 # fffffffffffff3a0 <base+0xffffffffffffd390>
  fa:	97a2                	add	a5,a5,s0
  fc:	777d                	lui	a4,0xfffff
  fe:	18870713          	addi	a4,a4,392 # fffffffffffff188 <base+0xffffffffffffd178>
 102:	9722                	add	a4,a4,s0
 104:	e31c                	sd	a5,0(a4)
    int pos = 0;
 106:	7b7d                	lui	s6,0xfffff
 108:	fa0b0793          	addi	a5,s6,-96 # ffffffffffffefa0 <base+0xffffffffffffcf90>
 10c:	00878b33          	add	s6,a5,s0
    memset(buf, 0, OUTBUF_SZ);
 110:	797d                	lui	s2,0xfffff
 112:	1a090793          	addi	a5,s2,416 # fffffffffffff1a0 <base+0xffffffffffffd190>
 116:	00878933          	add	s2,a5,s0
    append_str(buf, &pos, "EV {\"seq\":");
 11a:	79fd                	lui	s3,0xfffff
 11c:	19c98793          	addi	a5,s3,412 # fffffffffffff19c <base+0xffffffffffffd18c>
 120:	008789b3          	add	s3,a5,s0
 124:	a28d                	j	286 <main+0x1ce>
        for (int i = 0; i < n_cs; i++) {
 126:	03048493          	addi	s1,s1,48
 12a:	03448563          	beq	s1,s4,154 <main+0x9c>
            if (cs_ev[i].type == 1) // CS_RUN_START
 12e:	ff44a783          	lw	a5,-12(s1)
 132:	ff579ae3          	bne	a5,s5,126 <main+0x6e>
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
 136:	ffc4a803          	lw	a6,-4(s1)
 13a:	87a6                	mv	a5,s1
 13c:	ff84a703          	lw	a4,-8(s1)
 140:	ff04a683          	lw	a3,-16(s1)
 144:	fec4a603          	lw	a2,-20(s1)
 148:	fe44b583          	ld	a1,-28(s1)
 14c:	855e                	mv	a0,s7
 14e:	03f000ef          	jal	98c <printf>
}
 152:	bfd1                	j	126 <main+0x6e>
        int n_fs = fsread(fs_ev, 32);
 154:	02000593          	li	a1,32
 158:	74fd                	lui	s1,0xfffff
 15a:	18848793          	addi	a5,s1,392 # fffffffffffff188 <base+0xffffffffffffd178>
 15e:	97a2                	add	a5,a5,s0
 160:	6388                	ld	a0,0(a5)
 162:	48a000ef          	jal	5ec <fsread>
        for (int i = 0; i < n_fs; i++) {
 166:	10a05d63          	blez	a0,280 <main+0x1c8>
 16a:	18848793          	addi	a5,s1,392
 16e:	97a2                	add	a5,a5,s0
 170:	639c                	ld	a5,0(a5)
 172:	02078493          	addi	s1,a5,32
 176:	00151a13          	slli	s4,a0,0x1
 17a:	9a2a                	add	s4,s4,a0
 17c:	0a12                	slli	s4,s4,0x4
 17e:	9a26                	add	s4,s4,s1
    append_str(buf, &pos, "EV {\"seq\":");
 180:	00001d17          	auipc	s10,0x1
 184:	a18d0d13          	addi	s10,s10,-1512 # b98 <malloc+0x158>
    append_str(buf, &pos, ",\"tick\":");
 188:	00001c97          	auipc	s9,0x1
 18c:	a20c8c93          	addi	s9,s9,-1504 # ba8 <malloc+0x168>
    append_str(buf, &pos, ",\"type\":\"FS\",\"fs_type\":");
 190:	00001c17          	auipc	s8,0x1
 194:	a28c0c13          	addi	s8,s8,-1496 # bb8 <malloc+0x178>
    append_str(buf, &pos, ",\"pid\":");
 198:	00001b97          	auipc	s7,0x1
 19c:	a38b8b93          	addi	s7,s7,-1480 # bd0 <malloc+0x190>
    append_str(buf, &pos, ",\"inum\":");
 1a0:	00001a97          	auipc	s5,0x1
 1a4:	a38a8a93          	addi	s5,s5,-1480 # bd8 <malloc+0x198>
    int pos = 0;
 1a8:	1e0b2e23          	sw	zero,508(s6)
    memset(buf, 0, OUTBUF_SZ);
 1ac:	20000613          	li	a2,512
 1b0:	4581                	li	a1,0
 1b2:	854a                	mv	a0,s2
 1b4:	17e000ef          	jal	332 <memset>
    append_str(buf, &pos, "EV {\"seq\":");
 1b8:	866a                	mv	a2,s10
 1ba:	85ce                	mv	a1,s3
 1bc:	854a                	mv	a0,s2
 1be:	e43ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, (uint)e->seq);
 1c2:	fe04a603          	lw	a2,-32(s1)
 1c6:	85ce                	mv	a1,s3
 1c8:	854a                	mv	a0,s2
 1ca:	e6bff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"tick\":");
 1ce:	8666                	mv	a2,s9
 1d0:	85ce                	mv	a1,s3
 1d2:	854a                	mv	a0,s2
 1d4:	e2dff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->ticks);
 1d8:	fe84a603          	lw	a2,-24(s1)
 1dc:	85ce                	mv	a1,s3
 1de:	854a                	mv	a0,s2
 1e0:	e55ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"type\":\"FS\",\"fs_type\":");
 1e4:	8662                	mv	a2,s8
 1e6:	85ce                	mv	a1,s3
 1e8:	854a                	mv	a0,s2
 1ea:	e17ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->type);
 1ee:	fec4a603          	lw	a2,-20(s1)
 1f2:	85ce                	mv	a1,s3
 1f4:	854a                	mv	a0,s2
 1f6:	e3fff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"pid\":");
 1fa:	865e                	mv	a2,s7
 1fc:	85ce                	mv	a1,s3
 1fe:	854a                	mv	a0,s2
 200:	e01ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->pid);
 204:	ff04a603          	lw	a2,-16(s1)
 208:	85ce                	mv	a1,s3
 20a:	854a                	mv	a0,s2
 20c:	e29ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"inum\":");
 210:	8656                	mv	a2,s5
 212:	85ce                	mv	a1,s3
 214:	854a                	mv	a0,s2
 216:	debff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->inum);
 21a:	ff44a603          	lw	a2,-12(s1)
 21e:	85ce                	mv	a1,s3
 220:	854a                	mv	a0,s2
 222:	e13ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"block\":");
 226:	00001617          	auipc	a2,0x1
 22a:	9c260613          	addi	a2,a2,-1598 # be8 <malloc+0x1a8>
 22e:	85ce                	mv	a1,s3
 230:	854a                	mv	a0,s2
 232:	dcfff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->blockno);
 236:	ff84a603          	lw	a2,-8(s1)
 23a:	85ce                	mv	a1,s3
 23c:	854a                	mv	a0,s2
 23e:	df7ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"name\":\"");
 242:	00001617          	auipc	a2,0x1
 246:	9b660613          	addi	a2,a2,-1610 # bf8 <malloc+0x1b8>
 24a:	85ce                	mv	a1,s3
 24c:	854a                	mv	a0,s2
 24e:	db3ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
 252:	8626                	mv	a2,s1
 254:	85ce                	mv	a1,s3
 256:	854a                	mv	a0,s2
 258:	da9ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"}\n");
 25c:	00001617          	auipc	a2,0x1
 260:	9ac60613          	addi	a2,a2,-1620 # c08 <malloc+0x1c8>
 264:	85ce                	mv	a1,s3
 266:	854a                	mv	a0,s2
 268:	d99ff0ef          	jal	0 <append_str>
    write(1, buf, pos);
 26c:	1fcb2603          	lw	a2,508(s6)
 270:	85ca                	mv	a1,s2
 272:	4505                	li	a0,1
 274:	2f0000ef          	jal	564 <write>
        for (int i = 0; i < n_fs; i++) {
 278:	03048493          	addi	s1,s1,48
 27c:	f34496e3          	bne	s1,s4,1a8 <main+0xf0>
            print_fs_event(&fs_ev[i]);
        }

        pause(2); // تخفيف الضغط على النظام
 280:	4509                	li	a0,2
 282:	352000ef          	jal	5d4 <pause>
        int n_cs = csread(cs_ev, 32);
 286:	02000593          	li	a1,32
 28a:	9a040513          	addi	a0,s0,-1632
 28e:	356000ef          	jal	5e4 <csread>
        for (int i = 0; i < n_cs; i++) {
 292:	eca051e3          	blez	a0,154 <main+0x9c>
 296:	9bc40493          	addi	s1,s0,-1604
 29a:	00151a13          	slli	s4,a0,0x1
 29e:	9a2a                	add	s4,s4,a0
 2a0:	0a12                	slli	s4,s4,0x4
 2a2:	9a26                	add	s4,s4,s1
            if (cs_ev[i].type == 1) // CS_RUN_START
 2a4:	4a85                	li	s5,1
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
 2a6:	00001b97          	auipc	s7,0x1
 2aa:	89ab8b93          	addi	s7,s7,-1894 # b40 <malloc+0x100>
 2ae:	b541                	j	12e <main+0x76>

00000000000002b0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e406                	sd	ra,8(sp)
 2b4:	e022                	sd	s0,0(sp)
 2b6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 2b8:	e01ff0ef          	jal	b8 <main>
  exit(r);
 2bc:	288000ef          	jal	544 <exit>

00000000000002c0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2c6:	87aa                	mv	a5,a0
 2c8:	0585                	addi	a1,a1,1
 2ca:	0785                	addi	a5,a5,1
 2cc:	fff5c703          	lbu	a4,-1(a1)
 2d0:	fee78fa3          	sb	a4,-1(a5)
 2d4:	fb75                	bnez	a4,2c8 <strcpy+0x8>
    ;
  return os;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret

00000000000002dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e422                	sd	s0,8(sp)
 2e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2e2:	00054783          	lbu	a5,0(a0)
 2e6:	cb91                	beqz	a5,2fa <strcmp+0x1e>
 2e8:	0005c703          	lbu	a4,0(a1)
 2ec:	00f71763          	bne	a4,a5,2fa <strcmp+0x1e>
    p++, q++;
 2f0:	0505                	addi	a0,a0,1
 2f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2f4:	00054783          	lbu	a5,0(a0)
 2f8:	fbe5                	bnez	a5,2e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2fa:	0005c503          	lbu	a0,0(a1)
}
 2fe:	40a7853b          	subw	a0,a5,a0
 302:	6422                	ld	s0,8(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret

0000000000000308 <strlen>:

uint
strlen(const char *s)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 30e:	00054783          	lbu	a5,0(a0)
 312:	cf91                	beqz	a5,32e <strlen+0x26>
 314:	0505                	addi	a0,a0,1
 316:	87aa                	mv	a5,a0
 318:	86be                	mv	a3,a5
 31a:	0785                	addi	a5,a5,1
 31c:	fff7c703          	lbu	a4,-1(a5)
 320:	ff65                	bnez	a4,318 <strlen+0x10>
 322:	40a6853b          	subw	a0,a3,a0
 326:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 328:	6422                	ld	s0,8(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret
  for(n = 0; s[n]; n++)
 32e:	4501                	li	a0,0
 330:	bfe5                	j	328 <strlen+0x20>

0000000000000332 <memset>:

void*
memset(void *dst, int c, uint n)
{
 332:	1141                	addi	sp,sp,-16
 334:	e422                	sd	s0,8(sp)
 336:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 338:	ca19                	beqz	a2,34e <memset+0x1c>
 33a:	87aa                	mv	a5,a0
 33c:	1602                	slli	a2,a2,0x20
 33e:	9201                	srli	a2,a2,0x20
 340:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 344:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 348:	0785                	addi	a5,a5,1
 34a:	fee79de3          	bne	a5,a4,344 <memset+0x12>
  }
  return dst;
}
 34e:	6422                	ld	s0,8(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <strchr>:

char*
strchr(const char *s, char c)
{
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
  for(; *s; s++)
 35a:	00054783          	lbu	a5,0(a0)
 35e:	cb99                	beqz	a5,374 <strchr+0x20>
    if(*s == c)
 360:	00f58763          	beq	a1,a5,36e <strchr+0x1a>
  for(; *s; s++)
 364:	0505                	addi	a0,a0,1
 366:	00054783          	lbu	a5,0(a0)
 36a:	fbfd                	bnez	a5,360 <strchr+0xc>
      return (char*)s;
  return 0;
 36c:	4501                	li	a0,0
}
 36e:	6422                	ld	s0,8(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret
  return 0;
 374:	4501                	li	a0,0
 376:	bfe5                	j	36e <strchr+0x1a>

0000000000000378 <gets>:

char*
gets(char *buf, int max)
{
 378:	711d                	addi	sp,sp,-96
 37a:	ec86                	sd	ra,88(sp)
 37c:	e8a2                	sd	s0,80(sp)
 37e:	e4a6                	sd	s1,72(sp)
 380:	e0ca                	sd	s2,64(sp)
 382:	fc4e                	sd	s3,56(sp)
 384:	f852                	sd	s4,48(sp)
 386:	f456                	sd	s5,40(sp)
 388:	f05a                	sd	s6,32(sp)
 38a:	ec5e                	sd	s7,24(sp)
 38c:	1080                	addi	s0,sp,96
 38e:	8baa                	mv	s7,a0
 390:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 392:	892a                	mv	s2,a0
 394:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 396:	4aa9                	li	s5,10
 398:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 39a:	89a6                	mv	s3,s1
 39c:	2485                	addiw	s1,s1,1
 39e:	0344d663          	bge	s1,s4,3ca <gets+0x52>
    cc = read(0, &c, 1);
 3a2:	4605                	li	a2,1
 3a4:	faf40593          	addi	a1,s0,-81
 3a8:	4501                	li	a0,0
 3aa:	1b2000ef          	jal	55c <read>
    if(cc < 1)
 3ae:	00a05e63          	blez	a0,3ca <gets+0x52>
    buf[i++] = c;
 3b2:	faf44783          	lbu	a5,-81(s0)
 3b6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3ba:	01578763          	beq	a5,s5,3c8 <gets+0x50>
 3be:	0905                	addi	s2,s2,1
 3c0:	fd679de3          	bne	a5,s6,39a <gets+0x22>
    buf[i++] = c;
 3c4:	89a6                	mv	s3,s1
 3c6:	a011                	j	3ca <gets+0x52>
 3c8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3ca:	99de                	add	s3,s3,s7
 3cc:	00098023          	sb	zero,0(s3)
  return buf;
}
 3d0:	855e                	mv	a0,s7
 3d2:	60e6                	ld	ra,88(sp)
 3d4:	6446                	ld	s0,80(sp)
 3d6:	64a6                	ld	s1,72(sp)
 3d8:	6906                	ld	s2,64(sp)
 3da:	79e2                	ld	s3,56(sp)
 3dc:	7a42                	ld	s4,48(sp)
 3de:	7aa2                	ld	s5,40(sp)
 3e0:	7b02                	ld	s6,32(sp)
 3e2:	6be2                	ld	s7,24(sp)
 3e4:	6125                	addi	sp,sp,96
 3e6:	8082                	ret

00000000000003e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 3e8:	1101                	addi	sp,sp,-32
 3ea:	ec06                	sd	ra,24(sp)
 3ec:	e822                	sd	s0,16(sp)
 3ee:	e04a                	sd	s2,0(sp)
 3f0:	1000                	addi	s0,sp,32
 3f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3f4:	4581                	li	a1,0
 3f6:	18e000ef          	jal	584 <open>
  if(fd < 0)
 3fa:	02054263          	bltz	a0,41e <stat+0x36>
 3fe:	e426                	sd	s1,8(sp)
 400:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 402:	85ca                	mv	a1,s2
 404:	198000ef          	jal	59c <fstat>
 408:	892a                	mv	s2,a0
  close(fd);
 40a:	8526                	mv	a0,s1
 40c:	160000ef          	jal	56c <close>
  return r;
 410:	64a2                	ld	s1,8(sp)
}
 412:	854a                	mv	a0,s2
 414:	60e2                	ld	ra,24(sp)
 416:	6442                	ld	s0,16(sp)
 418:	6902                	ld	s2,0(sp)
 41a:	6105                	addi	sp,sp,32
 41c:	8082                	ret
    return -1;
 41e:	597d                	li	s2,-1
 420:	bfcd                	j	412 <stat+0x2a>

0000000000000422 <atoi>:

int
atoi(const char *s)
{
 422:	1141                	addi	sp,sp,-16
 424:	e422                	sd	s0,8(sp)
 426:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 428:	00054683          	lbu	a3,0(a0)
 42c:	fd06879b          	addiw	a5,a3,-48
 430:	0ff7f793          	zext.b	a5,a5
 434:	4625                	li	a2,9
 436:	02f66863          	bltu	a2,a5,466 <atoi+0x44>
 43a:	872a                	mv	a4,a0
  n = 0;
 43c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 43e:	0705                	addi	a4,a4,1
 440:	0025179b          	slliw	a5,a0,0x2
 444:	9fa9                	addw	a5,a5,a0
 446:	0017979b          	slliw	a5,a5,0x1
 44a:	9fb5                	addw	a5,a5,a3
 44c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 450:	00074683          	lbu	a3,0(a4)
 454:	fd06879b          	addiw	a5,a3,-48
 458:	0ff7f793          	zext.b	a5,a5
 45c:	fef671e3          	bgeu	a2,a5,43e <atoi+0x1c>
  return n;
}
 460:	6422                	ld	s0,8(sp)
 462:	0141                	addi	sp,sp,16
 464:	8082                	ret
  n = 0;
 466:	4501                	li	a0,0
 468:	bfe5                	j	460 <atoi+0x3e>

000000000000046a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 46a:	1141                	addi	sp,sp,-16
 46c:	e422                	sd	s0,8(sp)
 46e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 470:	02b57463          	bgeu	a0,a1,498 <memmove+0x2e>
    while(n-- > 0)
 474:	00c05f63          	blez	a2,492 <memmove+0x28>
 478:	1602                	slli	a2,a2,0x20
 47a:	9201                	srli	a2,a2,0x20
 47c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 480:	872a                	mv	a4,a0
      *dst++ = *src++;
 482:	0585                	addi	a1,a1,1
 484:	0705                	addi	a4,a4,1
 486:	fff5c683          	lbu	a3,-1(a1)
 48a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 48e:	fef71ae3          	bne	a4,a5,482 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 492:	6422                	ld	s0,8(sp)
 494:	0141                	addi	sp,sp,16
 496:	8082                	ret
    dst += n;
 498:	00c50733          	add	a4,a0,a2
    src += n;
 49c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 49e:	fec05ae3          	blez	a2,492 <memmove+0x28>
 4a2:	fff6079b          	addiw	a5,a2,-1
 4a6:	1782                	slli	a5,a5,0x20
 4a8:	9381                	srli	a5,a5,0x20
 4aa:	fff7c793          	not	a5,a5
 4ae:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4b0:	15fd                	addi	a1,a1,-1
 4b2:	177d                	addi	a4,a4,-1
 4b4:	0005c683          	lbu	a3,0(a1)
 4b8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4bc:	fee79ae3          	bne	a5,a4,4b0 <memmove+0x46>
 4c0:	bfc9                	j	492 <memmove+0x28>

00000000000004c2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4c2:	1141                	addi	sp,sp,-16
 4c4:	e422                	sd	s0,8(sp)
 4c6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4c8:	ca05                	beqz	a2,4f8 <memcmp+0x36>
 4ca:	fff6069b          	addiw	a3,a2,-1
 4ce:	1682                	slli	a3,a3,0x20
 4d0:	9281                	srli	a3,a3,0x20
 4d2:	0685                	addi	a3,a3,1
 4d4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4d6:	00054783          	lbu	a5,0(a0)
 4da:	0005c703          	lbu	a4,0(a1)
 4de:	00e79863          	bne	a5,a4,4ee <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4e2:	0505                	addi	a0,a0,1
    p2++;
 4e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4e6:	fed518e3          	bne	a0,a3,4d6 <memcmp+0x14>
  }
  return 0;
 4ea:	4501                	li	a0,0
 4ec:	a019                	j	4f2 <memcmp+0x30>
      return *p1 - *p2;
 4ee:	40e7853b          	subw	a0,a5,a4
}
 4f2:	6422                	ld	s0,8(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret
  return 0;
 4f8:	4501                	li	a0,0
 4fa:	bfe5                	j	4f2 <memcmp+0x30>

00000000000004fc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4fc:	1141                	addi	sp,sp,-16
 4fe:	e406                	sd	ra,8(sp)
 500:	e022                	sd	s0,0(sp)
 502:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 504:	f67ff0ef          	jal	46a <memmove>
}
 508:	60a2                	ld	ra,8(sp)
 50a:	6402                	ld	s0,0(sp)
 50c:	0141                	addi	sp,sp,16
 50e:	8082                	ret

0000000000000510 <sbrk>:

char *
sbrk(int n) {
 510:	1141                	addi	sp,sp,-16
 512:	e406                	sd	ra,8(sp)
 514:	e022                	sd	s0,0(sp)
 516:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 518:	4585                	li	a1,1
 51a:	0b2000ef          	jal	5cc <sys_sbrk>
}
 51e:	60a2                	ld	ra,8(sp)
 520:	6402                	ld	s0,0(sp)
 522:	0141                	addi	sp,sp,16
 524:	8082                	ret

0000000000000526 <sbrklazy>:

char *
sbrklazy(int n) {
 526:	1141                	addi	sp,sp,-16
 528:	e406                	sd	ra,8(sp)
 52a:	e022                	sd	s0,0(sp)
 52c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 52e:	4589                	li	a1,2
 530:	09c000ef          	jal	5cc <sys_sbrk>
}
 534:	60a2                	ld	ra,8(sp)
 536:	6402                	ld	s0,0(sp)
 538:	0141                	addi	sp,sp,16
 53a:	8082                	ret

000000000000053c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 53c:	4885                	li	a7,1
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <exit>:
.global exit
exit:
 li a7, SYS_exit
 544:	4889                	li	a7,2
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <wait>:
.global wait
wait:
 li a7, SYS_wait
 54c:	488d                	li	a7,3
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 554:	4891                	li	a7,4
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <read>:
.global read
read:
 li a7, SYS_read
 55c:	4895                	li	a7,5
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <write>:
.global write
write:
 li a7, SYS_write
 564:	48c1                	li	a7,16
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <close>:
.global close
close:
 li a7, SYS_close
 56c:	48d5                	li	a7,21
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <kill>:
.global kill
kill:
 li a7, SYS_kill
 574:	4899                	li	a7,6
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <exec>:
.global exec
exec:
 li a7, SYS_exec
 57c:	489d                	li	a7,7
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <open>:
.global open
open:
 li a7, SYS_open
 584:	48bd                	li	a7,15
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 58c:	48c5                	li	a7,17
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 594:	48c9                	li	a7,18
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 59c:	48a1                	li	a7,8
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <link>:
.global link
link:
 li a7, SYS_link
 5a4:	48cd                	li	a7,19
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5ac:	48d1                	li	a7,20
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5b4:	48a5                	li	a7,9
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 5bc:	48a9                	li	a7,10
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5c4:	48ad                	li	a7,11
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 5cc:	48b1                	li	a7,12
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 5d4:	48b5                	li	a7,13
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5dc:	48b9                	li	a7,14
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <csread>:
.global csread
csread:
 li a7, SYS_csread
 5e4:	48d9                	li	a7,22
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 5ec:	48dd                	li	a7,23
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 5f4:	48e1                	li	a7,24
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <memread>:
.global memread
memread:
 li a7, SYS_memread
 5fc:	48e5                	li	a7,25
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 604:	1101                	addi	sp,sp,-32
 606:	ec06                	sd	ra,24(sp)
 608:	e822                	sd	s0,16(sp)
 60a:	1000                	addi	s0,sp,32
 60c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 610:	4605                	li	a2,1
 612:	fef40593          	addi	a1,s0,-17
 616:	f4fff0ef          	jal	564 <write>
}
 61a:	60e2                	ld	ra,24(sp)
 61c:	6442                	ld	s0,16(sp)
 61e:	6105                	addi	sp,sp,32
 620:	8082                	ret

0000000000000622 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 622:	715d                	addi	sp,sp,-80
 624:	e486                	sd	ra,72(sp)
 626:	e0a2                	sd	s0,64(sp)
 628:	f84a                	sd	s2,48(sp)
 62a:	0880                	addi	s0,sp,80
 62c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 62e:	c299                	beqz	a3,634 <printint+0x12>
 630:	0805c363          	bltz	a1,6b6 <printint+0x94>
  neg = 0;
 634:	4881                	li	a7,0
 636:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 63a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 63c:	00000517          	auipc	a0,0x0
 640:	5dc50513          	addi	a0,a0,1500 # c18 <digits>
 644:	883e                	mv	a6,a5
 646:	2785                	addiw	a5,a5,1
 648:	02c5f733          	remu	a4,a1,a2
 64c:	972a                	add	a4,a4,a0
 64e:	00074703          	lbu	a4,0(a4)
 652:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 656:	872e                	mv	a4,a1
 658:	02c5d5b3          	divu	a1,a1,a2
 65c:	0685                	addi	a3,a3,1
 65e:	fec773e3          	bgeu	a4,a2,644 <printint+0x22>
  if(neg)
 662:	00088b63          	beqz	a7,678 <printint+0x56>
    buf[i++] = '-';
 666:	fd078793          	addi	a5,a5,-48
 66a:	97a2                	add	a5,a5,s0
 66c:	02d00713          	li	a4,45
 670:	fee78423          	sb	a4,-24(a5)
 674:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 678:	02f05a63          	blez	a5,6ac <printint+0x8a>
 67c:	fc26                	sd	s1,56(sp)
 67e:	f44e                	sd	s3,40(sp)
 680:	fb840713          	addi	a4,s0,-72
 684:	00f704b3          	add	s1,a4,a5
 688:	fff70993          	addi	s3,a4,-1
 68c:	99be                	add	s3,s3,a5
 68e:	37fd                	addiw	a5,a5,-1
 690:	1782                	slli	a5,a5,0x20
 692:	9381                	srli	a5,a5,0x20
 694:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 698:	fff4c583          	lbu	a1,-1(s1)
 69c:	854a                	mv	a0,s2
 69e:	f67ff0ef          	jal	604 <putc>
  while(--i >= 0)
 6a2:	14fd                	addi	s1,s1,-1
 6a4:	ff349ae3          	bne	s1,s3,698 <printint+0x76>
 6a8:	74e2                	ld	s1,56(sp)
 6aa:	79a2                	ld	s3,40(sp)
}
 6ac:	60a6                	ld	ra,72(sp)
 6ae:	6406                	ld	s0,64(sp)
 6b0:	7942                	ld	s2,48(sp)
 6b2:	6161                	addi	sp,sp,80
 6b4:	8082                	ret
    x = -xx;
 6b6:	40b005b3          	neg	a1,a1
    neg = 1;
 6ba:	4885                	li	a7,1
    x = -xx;
 6bc:	bfad                	j	636 <printint+0x14>

00000000000006be <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6be:	711d                	addi	sp,sp,-96
 6c0:	ec86                	sd	ra,88(sp)
 6c2:	e8a2                	sd	s0,80(sp)
 6c4:	e0ca                	sd	s2,64(sp)
 6c6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6c8:	0005c903          	lbu	s2,0(a1)
 6cc:	28090663          	beqz	s2,958 <vprintf+0x29a>
 6d0:	e4a6                	sd	s1,72(sp)
 6d2:	fc4e                	sd	s3,56(sp)
 6d4:	f852                	sd	s4,48(sp)
 6d6:	f456                	sd	s5,40(sp)
 6d8:	f05a                	sd	s6,32(sp)
 6da:	ec5e                	sd	s7,24(sp)
 6dc:	e862                	sd	s8,16(sp)
 6de:	e466                	sd	s9,8(sp)
 6e0:	8b2a                	mv	s6,a0
 6e2:	8a2e                	mv	s4,a1
 6e4:	8bb2                	mv	s7,a2
  state = 0;
 6e6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6e8:	4481                	li	s1,0
 6ea:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6ec:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6f0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6f4:	06c00c93          	li	s9,108
 6f8:	a005                	j	718 <vprintf+0x5a>
        putc(fd, c0);
 6fa:	85ca                	mv	a1,s2
 6fc:	855a                	mv	a0,s6
 6fe:	f07ff0ef          	jal	604 <putc>
 702:	a019                	j	708 <vprintf+0x4a>
    } else if(state == '%'){
 704:	03598263          	beq	s3,s5,728 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 708:	2485                	addiw	s1,s1,1
 70a:	8726                	mv	a4,s1
 70c:	009a07b3          	add	a5,s4,s1
 710:	0007c903          	lbu	s2,0(a5)
 714:	22090a63          	beqz	s2,948 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 718:	0009079b          	sext.w	a5,s2
    if(state == 0){
 71c:	fe0994e3          	bnez	s3,704 <vprintf+0x46>
      if(c0 == '%'){
 720:	fd579de3          	bne	a5,s5,6fa <vprintf+0x3c>
        state = '%';
 724:	89be                	mv	s3,a5
 726:	b7cd                	j	708 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 728:	00ea06b3          	add	a3,s4,a4
 72c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 730:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 732:	c681                	beqz	a3,73a <vprintf+0x7c>
 734:	9752                	add	a4,a4,s4
 736:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 73a:	05878363          	beq	a5,s8,780 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 73e:	05978d63          	beq	a5,s9,798 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 742:	07500713          	li	a4,117
 746:	0ee78763          	beq	a5,a4,834 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 74a:	07800713          	li	a4,120
 74e:	12e78963          	beq	a5,a4,880 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 752:	07000713          	li	a4,112
 756:	14e78e63          	beq	a5,a4,8b2 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 75a:	06300713          	li	a4,99
 75e:	18e78e63          	beq	a5,a4,8fa <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 762:	07300713          	li	a4,115
 766:	1ae78463          	beq	a5,a4,90e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 76a:	02500713          	li	a4,37
 76e:	04e79563          	bne	a5,a4,7b8 <vprintf+0xfa>
        putc(fd, '%');
 772:	02500593          	li	a1,37
 776:	855a                	mv	a0,s6
 778:	e8dff0ef          	jal	604 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 77c:	4981                	li	s3,0
 77e:	b769                	j	708 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 780:	008b8913          	addi	s2,s7,8
 784:	4685                	li	a3,1
 786:	4629                	li	a2,10
 788:	000ba583          	lw	a1,0(s7)
 78c:	855a                	mv	a0,s6
 78e:	e95ff0ef          	jal	622 <printint>
 792:	8bca                	mv	s7,s2
      state = 0;
 794:	4981                	li	s3,0
 796:	bf8d                	j	708 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 798:	06400793          	li	a5,100
 79c:	02f68963          	beq	a3,a5,7ce <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7a0:	06c00793          	li	a5,108
 7a4:	04f68263          	beq	a3,a5,7e8 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 7a8:	07500793          	li	a5,117
 7ac:	0af68063          	beq	a3,a5,84c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 7b0:	07800793          	li	a5,120
 7b4:	0ef68263          	beq	a3,a5,898 <vprintf+0x1da>
        putc(fd, '%');
 7b8:	02500593          	li	a1,37
 7bc:	855a                	mv	a0,s6
 7be:	e47ff0ef          	jal	604 <putc>
        putc(fd, c0);
 7c2:	85ca                	mv	a1,s2
 7c4:	855a                	mv	a0,s6
 7c6:	e3fff0ef          	jal	604 <putc>
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	bf35                	j	708 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ce:	008b8913          	addi	s2,s7,8
 7d2:	4685                	li	a3,1
 7d4:	4629                	li	a2,10
 7d6:	000bb583          	ld	a1,0(s7)
 7da:	855a                	mv	a0,s6
 7dc:	e47ff0ef          	jal	622 <printint>
        i += 1;
 7e0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7e2:	8bca                	mv	s7,s2
      state = 0;
 7e4:	4981                	li	s3,0
        i += 1;
 7e6:	b70d                	j	708 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7e8:	06400793          	li	a5,100
 7ec:	02f60763          	beq	a2,a5,81a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7f0:	07500793          	li	a5,117
 7f4:	06f60963          	beq	a2,a5,866 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7f8:	07800793          	li	a5,120
 7fc:	faf61ee3          	bne	a2,a5,7b8 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 800:	008b8913          	addi	s2,s7,8
 804:	4681                	li	a3,0
 806:	4641                	li	a2,16
 808:	000bb583          	ld	a1,0(s7)
 80c:	855a                	mv	a0,s6
 80e:	e15ff0ef          	jal	622 <printint>
        i += 2;
 812:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 814:	8bca                	mv	s7,s2
      state = 0;
 816:	4981                	li	s3,0
        i += 2;
 818:	bdc5                	j	708 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 81a:	008b8913          	addi	s2,s7,8
 81e:	4685                	li	a3,1
 820:	4629                	li	a2,10
 822:	000bb583          	ld	a1,0(s7)
 826:	855a                	mv	a0,s6
 828:	dfbff0ef          	jal	622 <printint>
        i += 2;
 82c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 82e:	8bca                	mv	s7,s2
      state = 0;
 830:	4981                	li	s3,0
        i += 2;
 832:	bdd9                	j	708 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 834:	008b8913          	addi	s2,s7,8
 838:	4681                	li	a3,0
 83a:	4629                	li	a2,10
 83c:	000be583          	lwu	a1,0(s7)
 840:	855a                	mv	a0,s6
 842:	de1ff0ef          	jal	622 <printint>
 846:	8bca                	mv	s7,s2
      state = 0;
 848:	4981                	li	s3,0
 84a:	bd7d                	j	708 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 84c:	008b8913          	addi	s2,s7,8
 850:	4681                	li	a3,0
 852:	4629                	li	a2,10
 854:	000bb583          	ld	a1,0(s7)
 858:	855a                	mv	a0,s6
 85a:	dc9ff0ef          	jal	622 <printint>
        i += 1;
 85e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 860:	8bca                	mv	s7,s2
      state = 0;
 862:	4981                	li	s3,0
        i += 1;
 864:	b555                	j	708 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 866:	008b8913          	addi	s2,s7,8
 86a:	4681                	li	a3,0
 86c:	4629                	li	a2,10
 86e:	000bb583          	ld	a1,0(s7)
 872:	855a                	mv	a0,s6
 874:	dafff0ef          	jal	622 <printint>
        i += 2;
 878:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 87a:	8bca                	mv	s7,s2
      state = 0;
 87c:	4981                	li	s3,0
        i += 2;
 87e:	b569                	j	708 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 880:	008b8913          	addi	s2,s7,8
 884:	4681                	li	a3,0
 886:	4641                	li	a2,16
 888:	000be583          	lwu	a1,0(s7)
 88c:	855a                	mv	a0,s6
 88e:	d95ff0ef          	jal	622 <printint>
 892:	8bca                	mv	s7,s2
      state = 0;
 894:	4981                	li	s3,0
 896:	bd8d                	j	708 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 898:	008b8913          	addi	s2,s7,8
 89c:	4681                	li	a3,0
 89e:	4641                	li	a2,16
 8a0:	000bb583          	ld	a1,0(s7)
 8a4:	855a                	mv	a0,s6
 8a6:	d7dff0ef          	jal	622 <printint>
        i += 1;
 8aa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 8ac:	8bca                	mv	s7,s2
      state = 0;
 8ae:	4981                	li	s3,0
        i += 1;
 8b0:	bda1                	j	708 <vprintf+0x4a>
 8b2:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 8b4:	008b8d13          	addi	s10,s7,8
 8b8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8bc:	03000593          	li	a1,48
 8c0:	855a                	mv	a0,s6
 8c2:	d43ff0ef          	jal	604 <putc>
  putc(fd, 'x');
 8c6:	07800593          	li	a1,120
 8ca:	855a                	mv	a0,s6
 8cc:	d39ff0ef          	jal	604 <putc>
 8d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8d2:	00000b97          	auipc	s7,0x0
 8d6:	346b8b93          	addi	s7,s7,838 # c18 <digits>
 8da:	03c9d793          	srli	a5,s3,0x3c
 8de:	97de                	add	a5,a5,s7
 8e0:	0007c583          	lbu	a1,0(a5)
 8e4:	855a                	mv	a0,s6
 8e6:	d1fff0ef          	jal	604 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8ea:	0992                	slli	s3,s3,0x4
 8ec:	397d                	addiw	s2,s2,-1
 8ee:	fe0916e3          	bnez	s2,8da <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 8f2:	8bea                	mv	s7,s10
      state = 0;
 8f4:	4981                	li	s3,0
 8f6:	6d02                	ld	s10,0(sp)
 8f8:	bd01                	j	708 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 8fa:	008b8913          	addi	s2,s7,8
 8fe:	000bc583          	lbu	a1,0(s7)
 902:	855a                	mv	a0,s6
 904:	d01ff0ef          	jal	604 <putc>
 908:	8bca                	mv	s7,s2
      state = 0;
 90a:	4981                	li	s3,0
 90c:	bbf5                	j	708 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 90e:	008b8993          	addi	s3,s7,8
 912:	000bb903          	ld	s2,0(s7)
 916:	00090f63          	beqz	s2,934 <vprintf+0x276>
        for(; *s; s++)
 91a:	00094583          	lbu	a1,0(s2)
 91e:	c195                	beqz	a1,942 <vprintf+0x284>
          putc(fd, *s);
 920:	855a                	mv	a0,s6
 922:	ce3ff0ef          	jal	604 <putc>
        for(; *s; s++)
 926:	0905                	addi	s2,s2,1
 928:	00094583          	lbu	a1,0(s2)
 92c:	f9f5                	bnez	a1,920 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 92e:	8bce                	mv	s7,s3
      state = 0;
 930:	4981                	li	s3,0
 932:	bbd9                	j	708 <vprintf+0x4a>
          s = "(null)";
 934:	00000917          	auipc	s2,0x0
 938:	2dc90913          	addi	s2,s2,732 # c10 <malloc+0x1d0>
        for(; *s; s++)
 93c:	02800593          	li	a1,40
 940:	b7c5                	j	920 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 942:	8bce                	mv	s7,s3
      state = 0;
 944:	4981                	li	s3,0
 946:	b3c9                	j	708 <vprintf+0x4a>
 948:	64a6                	ld	s1,72(sp)
 94a:	79e2                	ld	s3,56(sp)
 94c:	7a42                	ld	s4,48(sp)
 94e:	7aa2                	ld	s5,40(sp)
 950:	7b02                	ld	s6,32(sp)
 952:	6be2                	ld	s7,24(sp)
 954:	6c42                	ld	s8,16(sp)
 956:	6ca2                	ld	s9,8(sp)
    }
  }
}
 958:	60e6                	ld	ra,88(sp)
 95a:	6446                	ld	s0,80(sp)
 95c:	6906                	ld	s2,64(sp)
 95e:	6125                	addi	sp,sp,96
 960:	8082                	ret

0000000000000962 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 962:	715d                	addi	sp,sp,-80
 964:	ec06                	sd	ra,24(sp)
 966:	e822                	sd	s0,16(sp)
 968:	1000                	addi	s0,sp,32
 96a:	e010                	sd	a2,0(s0)
 96c:	e414                	sd	a3,8(s0)
 96e:	e818                	sd	a4,16(s0)
 970:	ec1c                	sd	a5,24(s0)
 972:	03043023          	sd	a6,32(s0)
 976:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 97a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 97e:	8622                	mv	a2,s0
 980:	d3fff0ef          	jal	6be <vprintf>
}
 984:	60e2                	ld	ra,24(sp)
 986:	6442                	ld	s0,16(sp)
 988:	6161                	addi	sp,sp,80
 98a:	8082                	ret

000000000000098c <printf>:

void
printf(const char *fmt, ...)
{
 98c:	711d                	addi	sp,sp,-96
 98e:	ec06                	sd	ra,24(sp)
 990:	e822                	sd	s0,16(sp)
 992:	1000                	addi	s0,sp,32
 994:	e40c                	sd	a1,8(s0)
 996:	e810                	sd	a2,16(s0)
 998:	ec14                	sd	a3,24(s0)
 99a:	f018                	sd	a4,32(s0)
 99c:	f41c                	sd	a5,40(s0)
 99e:	03043823          	sd	a6,48(s0)
 9a2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9a6:	00840613          	addi	a2,s0,8
 9aa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9ae:	85aa                	mv	a1,a0
 9b0:	4505                	li	a0,1
 9b2:	d0dff0ef          	jal	6be <vprintf>
}
 9b6:	60e2                	ld	ra,24(sp)
 9b8:	6442                	ld	s0,16(sp)
 9ba:	6125                	addi	sp,sp,96
 9bc:	8082                	ret

00000000000009be <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9be:	1141                	addi	sp,sp,-16
 9c0:	e422                	sd	s0,8(sp)
 9c2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9c4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c8:	00001797          	auipc	a5,0x1
 9cc:	6387b783          	ld	a5,1592(a5) # 2000 <freep>
 9d0:	a02d                	j	9fa <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9d2:	4618                	lw	a4,8(a2)
 9d4:	9f2d                	addw	a4,a4,a1
 9d6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9da:	6398                	ld	a4,0(a5)
 9dc:	6310                	ld	a2,0(a4)
 9de:	a83d                	j	a1c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9e0:	ff852703          	lw	a4,-8(a0)
 9e4:	9f31                	addw	a4,a4,a2
 9e6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9e8:	ff053683          	ld	a3,-16(a0)
 9ec:	a091                	j	a30 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ee:	6398                	ld	a4,0(a5)
 9f0:	00e7e463          	bltu	a5,a4,9f8 <free+0x3a>
 9f4:	00e6ea63          	bltu	a3,a4,a08 <free+0x4a>
{
 9f8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9fa:	fed7fae3          	bgeu	a5,a3,9ee <free+0x30>
 9fe:	6398                	ld	a4,0(a5)
 a00:	00e6e463          	bltu	a3,a4,a08 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a04:	fee7eae3          	bltu	a5,a4,9f8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a08:	ff852583          	lw	a1,-8(a0)
 a0c:	6390                	ld	a2,0(a5)
 a0e:	02059813          	slli	a6,a1,0x20
 a12:	01c85713          	srli	a4,a6,0x1c
 a16:	9736                	add	a4,a4,a3
 a18:	fae60de3          	beq	a2,a4,9d2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a1c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a20:	4790                	lw	a2,8(a5)
 a22:	02061593          	slli	a1,a2,0x20
 a26:	01c5d713          	srli	a4,a1,0x1c
 a2a:	973e                	add	a4,a4,a5
 a2c:	fae68ae3          	beq	a3,a4,9e0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a30:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a32:	00001717          	auipc	a4,0x1
 a36:	5cf73723          	sd	a5,1486(a4) # 2000 <freep>
}
 a3a:	6422                	ld	s0,8(sp)
 a3c:	0141                	addi	sp,sp,16
 a3e:	8082                	ret

0000000000000a40 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a40:	7139                	addi	sp,sp,-64
 a42:	fc06                	sd	ra,56(sp)
 a44:	f822                	sd	s0,48(sp)
 a46:	f426                	sd	s1,40(sp)
 a48:	ec4e                	sd	s3,24(sp)
 a4a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a4c:	02051493          	slli	s1,a0,0x20
 a50:	9081                	srli	s1,s1,0x20
 a52:	04bd                	addi	s1,s1,15
 a54:	8091                	srli	s1,s1,0x4
 a56:	0014899b          	addiw	s3,s1,1
 a5a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a5c:	00001517          	auipc	a0,0x1
 a60:	5a453503          	ld	a0,1444(a0) # 2000 <freep>
 a64:	c915                	beqz	a0,a98 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a66:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a68:	4798                	lw	a4,8(a5)
 a6a:	08977a63          	bgeu	a4,s1,afe <malloc+0xbe>
 a6e:	f04a                	sd	s2,32(sp)
 a70:	e852                	sd	s4,16(sp)
 a72:	e456                	sd	s5,8(sp)
 a74:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a76:	8a4e                	mv	s4,s3
 a78:	0009871b          	sext.w	a4,s3
 a7c:	6685                	lui	a3,0x1
 a7e:	00d77363          	bgeu	a4,a3,a84 <malloc+0x44>
 a82:	6a05                	lui	s4,0x1
 a84:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a88:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a8c:	00001917          	auipc	s2,0x1
 a90:	57490913          	addi	s2,s2,1396 # 2000 <freep>
  if(p == SBRK_ERROR)
 a94:	5afd                	li	s5,-1
 a96:	a081                	j	ad6 <malloc+0x96>
 a98:	f04a                	sd	s2,32(sp)
 a9a:	e852                	sd	s4,16(sp)
 a9c:	e456                	sd	s5,8(sp)
 a9e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 aa0:	00001797          	auipc	a5,0x1
 aa4:	57078793          	addi	a5,a5,1392 # 2010 <base>
 aa8:	00001717          	auipc	a4,0x1
 aac:	54f73c23          	sd	a5,1368(a4) # 2000 <freep>
 ab0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ab2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ab6:	b7c1                	j	a76 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 ab8:	6398                	ld	a4,0(a5)
 aba:	e118                	sd	a4,0(a0)
 abc:	a8a9                	j	b16 <malloc+0xd6>
  hp->s.size = nu;
 abe:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ac2:	0541                	addi	a0,a0,16
 ac4:	efbff0ef          	jal	9be <free>
  return freep;
 ac8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 acc:	c12d                	beqz	a0,b2e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ace:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ad0:	4798                	lw	a4,8(a5)
 ad2:	02977263          	bgeu	a4,s1,af6 <malloc+0xb6>
    if(p == freep)
 ad6:	00093703          	ld	a4,0(s2)
 ada:	853e                	mv	a0,a5
 adc:	fef719e3          	bne	a4,a5,ace <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 ae0:	8552                	mv	a0,s4
 ae2:	a2fff0ef          	jal	510 <sbrk>
  if(p == SBRK_ERROR)
 ae6:	fd551ce3          	bne	a0,s5,abe <malloc+0x7e>
        return 0;
 aea:	4501                	li	a0,0
 aec:	7902                	ld	s2,32(sp)
 aee:	6a42                	ld	s4,16(sp)
 af0:	6aa2                	ld	s5,8(sp)
 af2:	6b02                	ld	s6,0(sp)
 af4:	a03d                	j	b22 <malloc+0xe2>
 af6:	7902                	ld	s2,32(sp)
 af8:	6a42                	ld	s4,16(sp)
 afa:	6aa2                	ld	s5,8(sp)
 afc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 afe:	fae48de3          	beq	s1,a4,ab8 <malloc+0x78>
        p->s.size -= nunits;
 b02:	4137073b          	subw	a4,a4,s3
 b06:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b08:	02071693          	slli	a3,a4,0x20
 b0c:	01c6d713          	srli	a4,a3,0x1c
 b10:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b12:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b16:	00001717          	auipc	a4,0x1
 b1a:	4ea73523          	sd	a0,1258(a4) # 2000 <freep>
      return (void*)(p + 1);
 b1e:	01078513          	addi	a0,a5,16
  }
}
 b22:	70e2                	ld	ra,56(sp)
 b24:	7442                	ld	s0,48(sp)
 b26:	74a2                	ld	s1,40(sp)
 b28:	69e2                	ld	s3,24(sp)
 b2a:	6121                	addi	sp,sp,64
 b2c:	8082                	ret
 b2e:	7902                	ld	s2,32(sp)
 b30:	6a42                	ld	s4,16(sp)
 b32:	6aa2                	ld	s5,8(sp)
 b34:	6b02                	ld	s6,0(sp)
 b36:	b7f5                	j	b22 <malloc+0xe2>
