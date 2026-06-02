
user/_cpuinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <append_str>:
static const char *state_names[PROC_STATE_COUNT] = {
  "UNUSED", "USED", "SLEEPING", "RUNNABLE", "RUNNING", "ZOMBIE"
};

// دوال المساعدة للـ JSON
static void append_str(char *buf, int *pos, const char *s) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    while (*s && *pos < OUTBUF_SZ - 50) { 
   8:	00064783          	lbu	a5,0(a2)
   c:	3cd00693          	li	a3,973
  10:	c385                	beqz	a5,30 <append_str+0x30>
  12:	419c                	lw	a5,0(a1)
  14:	00f6ce63          	blt	a3,a5,30 <append_str+0x30>
        buf[(*pos)++] = *s++;
  18:	0605                	addi	a2,a2,1
  1a:	0017871b          	addiw	a4,a5,1
  1e:	c198                	sw	a4,0(a1)
  20:	fff64703          	lbu	a4,-1(a2)
  24:	97aa                	add	a5,a5,a0
  26:	00e78023          	sb	a4,0(a5)
    while (*s && *pos < OUTBUF_SZ - 50) { 
  2a:	00064783          	lbu	a5,0(a2)
  2e:	f3f5                	bnez	a5,12 <append_str+0x12>
    }
}
  30:	60a2                	ld	ra,8(sp)
  32:	6402                	ld	s0,0(sp)
  34:	0141                	addi	sp,sp,16
  36:	8082                	ret

0000000000000038 <append_uint>:

static void append_uint(char *buf, int *pos, uint x) {
    char tmp[16]; 
    int n = 0;
    if (*pos >= OUTBUF_SZ - 20) return; 
  38:	419c                	lw	a5,0(a1)
  3a:	3eb00713          	li	a4,1003
  3e:	0af74063          	blt	a4,a5,de <append_uint+0xa6>
static void append_uint(char *buf, int *pos, uint x) {
  42:	1101                	addi	sp,sp,-32
  44:	ec06                	sd	ra,24(sp)
  46:	e822                	sd	s0,16(sp)
  48:	1000                	addi	s0,sp,32
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  4a:	fe040813          	addi	a6,s0,-32
  4e:	86c2                	mv	a3,a6
  50:	ce35                	beqz	a2,cc <append_uint+0x94>
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
  52:	000cd337          	lui	t1,0xcd
  56:	ccd30313          	addi	t1,t1,-819 # ccccd <base+0xc640d>
  5a:	0332                	slli	t1,t1,0xc
  5c:	ccd30313          	addi	t1,t1,-819
  60:	4e25                	li	t3,9
  62:	02061713          	slli	a4,a2,0x20
  66:	9301                	srli	a4,a4,0x20
  68:	02670733          	mul	a4,a4,t1
  6c:	930d                	srli	a4,a4,0x23
  6e:	0027179b          	slliw	a5,a4,0x2
  72:	9fb9                	addw	a5,a5,a4
  74:	0017979b          	slliw	a5,a5,0x1
  78:	40f607bb          	subw	a5,a2,a5
  7c:	0307879b          	addiw	a5,a5,48
  80:	00f68023          	sb	a5,0(a3)
  84:	88b2                	mv	a7,a2
  86:	863a                	mv	a2,a4
  88:	87b6                	mv	a5,a3
  8a:	0685                	addi	a3,a3,1
  8c:	fd1e6be3          	bltu	t3,a7,62 <append_uint+0x2a>
  90:	410787bb          	subw	a5,a5,a6
  94:	2785                	addiw	a5,a5,1
    while (n > 0) buf[(*pos)++] = tmp[--n];
  96:	02f05763          	blez	a5,c4 <append_uint+0x8c>
  9a:	37fd                	addiw	a5,a5,-1
  9c:	00f80733          	add	a4,a6,a5
  a0:	fff80693          	addi	a3,a6,-1
  a4:	96be                	add	a3,a3,a5
  a6:	1782                	slli	a5,a5,0x20
  a8:	9381                	srli	a5,a5,0x20
  aa:	8e9d                	sub	a3,a3,a5
  ac:	419c                	lw	a5,0(a1)
  ae:	0017861b          	addiw	a2,a5,1
  b2:	c190                	sw	a2,0(a1)
  b4:	97aa                	add	a5,a5,a0
  b6:	00074603          	lbu	a2,0(a4)
  ba:	00c78023          	sb	a2,0(a5)
  be:	177d                	addi	a4,a4,-1
  c0:	fed716e3          	bne	a4,a3,ac <append_uint+0x74>
}
  c4:	60e2                	ld	ra,24(sp)
  c6:	6442                	ld	s0,16(sp)
  c8:	6105                	addi	sp,sp,32
  ca:	8082                	ret
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  cc:	0017871b          	addiw	a4,a5,1
  d0:	c198                	sw	a4,0(a1)
  d2:	97aa                	add	a5,a5,a0
  d4:	03000713          	li	a4,48
  d8:	00e78023          	sb	a4,0(a5)
  dc:	b7e5                	j	c4 <append_uint+0x8c>
  de:	8082                	ret

00000000000000e0 <append_int>:

static void append_int(char *buf, int *pos, int x) {
    if (*pos >= OUTBUF_SZ - 20) return;
  e0:	419c                	lw	a5,0(a1)
  e2:	3eb00713          	li	a4,1003
  e6:	02f74963          	blt	a4,a5,118 <append_int+0x38>
static void append_int(char *buf, int *pos, int x) {
  ea:	1141                	addi	sp,sp,-16
  ec:	e406                	sd	ra,8(sp)
  ee:	e022                	sd	s0,0(sp)
  f0:	0800                	addi	s0,sp,16
    if (x < 0) {
  f2:	00064863          	bltz	a2,102 <append_int+0x22>
        buf[(*pos)++] = '-';
        x = -x;
    }
    append_uint(buf, pos, (uint)x);
  f6:	f43ff0ef          	jal	38 <append_uint>
}
  fa:	60a2                	ld	ra,8(sp)
  fc:	6402                	ld	s0,0(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret
        buf[(*pos)++] = '-';
 102:	0017871b          	addiw	a4,a5,1
 106:	c198                	sw	a4,0(a1)
 108:	97aa                	add	a5,a5,a0
 10a:	02d00713          	li	a4,45
 10e:	00e78023          	sb	a4,0(a5)
        x = -x;
 112:	40c0063b          	negw	a2,a2
 116:	b7c5                	j	f6 <append_int+0x16>
 118:	8082                	ret

000000000000011a <print_cs_event>:
    append_str(buf, &pos, "\"}\n");

    write(1, buf, pos);
}

static void print_cs_event(const struct cs_event *e) {
 11a:	bc010113          	addi	sp,sp,-1088
 11e:	42113c23          	sd	ra,1080(sp)
 122:	42813823          	sd	s0,1072(sp)
 126:	42913423          	sd	s1,1064(sp)
 12a:	43213023          	sd	s2,1056(sp)
 12e:	41313c23          	sd	s3,1048(sp)
 132:	44010413          	addi	s0,sp,1088
 136:	89aa                	mv	s3,a0
    char buf[OUTBUF_SZ];
    int pos = 0;
 138:	bc042623          	sw	zero,-1076(s0)
    memset(buf, 0, OUTBUF_SZ);
 13c:	bd040493          	addi	s1,s0,-1072
 140:	40000613          	li	a2,1024
 144:	4581                	li	a1,0
 146:	8526                	mv	a0,s1
 148:	49a000ef          	jal	5e2 <memset>

    append_str(buf, &pos, "EV {\"seq\":");
 14c:	bcc40913          	addi	s2,s0,-1076
 150:	00001617          	auipc	a2,0x1
 154:	ce060613          	addi	a2,a2,-800 # e30 <malloc+0xf6>
 158:	85ca                	mv	a1,s2
 15a:	8526                	mv	a0,s1
 15c:	ea5ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, (uint)e->seq);
 160:	0009a603          	lw	a2,0(s3)
 164:	85ca                	mv	a1,s2
 166:	8526                	mv	a0,s1
 168:	ed1ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"tick\":");
 16c:	00001617          	auipc	a2,0x1
 170:	cd460613          	addi	a2,a2,-812 # e40 <malloc+0x106>
 174:	85ca                	mv	a1,s2
 176:	8526                	mv	a0,s1
 178:	e89ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->ticks);
 17c:	0089a603          	lw	a2,8(s3)
 180:	85ca                	mv	a1,s2
 182:	8526                	mv	a0,s1
 184:	eb5ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"cpu\":");
 188:	00001617          	auipc	a2,0x1
 18c:	cc860613          	addi	a2,a2,-824 # e50 <malloc+0x116>
 190:	85ca                	mv	a1,s2
 192:	8526                	mv	a0,s1
 194:	e6dff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->cpu);
 198:	00c9a603          	lw	a2,12(s3)
 19c:	85ca                	mv	a1,s2
 19e:	8526                	mv	a0,s1
 1a0:	f41ff0ef          	jal	e0 <append_int>
    append_str(buf, &pos, ",\"pid\":");
 1a4:	00001617          	auipc	a2,0x1
 1a8:	cb460613          	addi	a2,a2,-844 # e58 <malloc+0x11e>
 1ac:	85ca                	mv	a1,s2
 1ae:	8526                	mv	a0,s1
 1b0:	e51ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->pid);
 1b4:	0149a603          	lw	a2,20(s3)
 1b8:	85ca                	mv	a1,s2
 1ba:	8526                	mv	a0,s1
 1bc:	f25ff0ef          	jal	e0 <append_int>
    append_str(buf, &pos, ",\"name\":\"");
 1c0:	00001617          	auipc	a2,0x1
 1c4:	ca060613          	addi	a2,a2,-864 # e60 <malloc+0x126>
 1c8:	85ca                	mv	a1,s2
 1ca:	8526                	mv	a0,s1
 1cc:	e35ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
 1d0:	01c98613          	addi	a2,s3,28
 1d4:	85ca                	mv	a1,s2
 1d6:	8526                	mv	a0,s1
 1d8:	e29ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\",\"state\":");
 1dc:	00001617          	auipc	a2,0x1
 1e0:	c9460613          	addi	a2,a2,-876 # e70 <malloc+0x136>
 1e4:	85ca                	mv	a1,s2
 1e6:	8526                	mv	a0,s1
 1e8:	e19ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->state);
 1ec:	0189a603          	lw	a2,24(s3)
 1f0:	85ca                	mv	a1,s2
 1f2:	8526                	mv	a0,s1
 1f4:	eedff0ef          	jal	e0 <append_int>
    append_str(buf, &pos, ",\"type\":\"ON_CPU\"}\n");
 1f8:	00001617          	auipc	a2,0x1
 1fc:	c8860613          	addi	a2,a2,-888 # e80 <malloc+0x146>
 200:	85ca                	mv	a1,s2
 202:	8526                	mv	a0,s1
 204:	dfdff0ef          	jal	0 <append_str>

    write(1, buf, pos);
 208:	bcc42603          	lw	a2,-1076(s0)
 20c:	85a6                	mv	a1,s1
 20e:	4505                	li	a0,1
 210:	61c000ef          	jal	82c <write>
}
 214:	43813083          	ld	ra,1080(sp)
 218:	43013403          	ld	s0,1072(sp)
 21c:	42813483          	ld	s1,1064(sp)
 220:	42013903          	ld	s2,1056(sp)
 224:	41813983          	ld	s3,1048(sp)
 228:	44010113          	addi	sp,sp,1088
 22c:	8082                	ret

000000000000022e <print_fs_event>:
static void print_fs_event(const struct fs_event *e) {
 22e:	bc010113          	addi	sp,sp,-1088
 232:	42113c23          	sd	ra,1080(sp)
 236:	42813823          	sd	s0,1072(sp)
 23a:	42913423          	sd	s1,1064(sp)
 23e:	43213023          	sd	s2,1056(sp)
 242:	41313c23          	sd	s3,1048(sp)
 246:	44010413          	addi	s0,sp,1088
 24a:	89aa                	mv	s3,a0
    int pos = 0;
 24c:	bc042623          	sw	zero,-1076(s0)
    memset(buf, 0, OUTBUF_SZ);
 250:	bd040493          	addi	s1,s0,-1072
 254:	40000613          	li	a2,1024
 258:	4581                	li	a1,0
 25a:	8526                	mv	a0,s1
 25c:	386000ef          	jal	5e2 <memset>
    append_str(buf, &pos, "EV {\"seq\":");
 260:	bcc40913          	addi	s2,s0,-1076
 264:	00001617          	auipc	a2,0x1
 268:	bcc60613          	addi	a2,a2,-1076 # e30 <malloc+0xf6>
 26c:	85ca                	mv	a1,s2
 26e:	8526                	mv	a0,s1
 270:	d91ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, (uint)e->seq);
 274:	0009a603          	lw	a2,0(s3)
 278:	85ca                	mv	a1,s2
 27a:	8526                	mv	a0,s1
 27c:	dbdff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"tick\":");
 280:	00001617          	auipc	a2,0x1
 284:	bc060613          	addi	a2,a2,-1088 # e40 <malloc+0x106>
 288:	85ca                	mv	a1,s2
 28a:	8526                	mv	a0,s1
 28c:	d75ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->ticks);
 290:	0089a603          	lw	a2,8(s3)
 294:	85ca                	mv	a1,s2
 296:	8526                	mv	a0,s1
 298:	da1ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"type\":\"FS\",\"fs_event_type\":"); 
 29c:	00001617          	auipc	a2,0x1
 2a0:	bfc60613          	addi	a2,a2,-1028 # e98 <malloc+0x15e>
 2a4:	85ca                	mv	a1,s2
 2a6:	8526                	mv	a0,s1
 2a8:	d59ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->type); 
 2ac:	0109a603          	lw	a2,16(s3)
 2b0:	85ca                	mv	a1,s2
 2b2:	8526                	mv	a0,s1
 2b4:	e2dff0ef          	jal	e0 <append_int>
    append_str(buf, &pos, ",\"pid\":");
 2b8:	00001617          	auipc	a2,0x1
 2bc:	ba060613          	addi	a2,a2,-1120 # e58 <malloc+0x11e>
 2c0:	85ca                	mv	a1,s2
 2c2:	8526                	mv	a0,s1
 2c4:	d3dff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->pid);
 2c8:	00c9a603          	lw	a2,12(s3)
 2cc:	85ca                	mv	a1,s2
 2ce:	8526                	mv	a0,s1
 2d0:	e11ff0ef          	jal	e0 <append_int>
    append_str(buf, &pos, ",\"inum\":");
 2d4:	00001617          	auipc	a2,0x1
 2d8:	be460613          	addi	a2,a2,-1052 # eb8 <malloc+0x17e>
 2dc:	85ca                	mv	a1,s2
 2de:	8526                	mv	a0,s1
 2e0:	d21ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->inum);
 2e4:	0cc9a603          	lw	a2,204(s3)
 2e8:	85ca                	mv	a1,s2
 2ea:	8526                	mv	a0,s1
 2ec:	df5ff0ef          	jal	e0 <append_int>
    append_str(buf, &pos, ",\"block\":");
 2f0:	00001617          	auipc	a2,0x1
 2f4:	bd860613          	addi	a2,a2,-1064 # ec8 <malloc+0x18e>
 2f8:	85ca                	mv	a1,s2
 2fa:	8526                	mv	a0,s1
 2fc:	d05ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->blockno);
 300:	0c49a603          	lw	a2,196(s3)
 304:	85ca                	mv	a1,s2
 306:	8526                	mv	a0,s1
 308:	dd9ff0ef          	jal	e0 <append_int>
    append_str(buf, &pos, ",\"size\":");         
 30c:	00001617          	auipc	a2,0x1
 310:	bcc60613          	addi	a2,a2,-1076 # ed8 <malloc+0x19e>
 314:	85ca                	mv	a1,s2
 316:	8526                	mv	a0,s1
 318:	ce9ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->i_size);
 31c:	0e09a603          	lw	a2,224(s3)
 320:	85ca                	mv	a1,s2
 322:	8526                	mv	a0,s1
 324:	d15ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"name\":\"");
 328:	00001617          	auipc	a2,0x1
 32c:	b3860613          	addi	a2,a2,-1224 # e60 <malloc+0x126>
 330:	85ca                	mv	a1,s2
 332:	8526                	mv	a0,s1
 334:	ccdff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
 338:	0a498613          	addi	a2,s3,164
 33c:	85ca                	mv	a1,s2
 33e:	8526                	mv	a0,s1
 340:	cc1ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"}\n");
 344:	00001617          	auipc	a2,0x1
 348:	ba460613          	addi	a2,a2,-1116 # ee8 <malloc+0x1ae>
 34c:	85ca                	mv	a1,s2
 34e:	8526                	mv	a0,s1
 350:	cb1ff0ef          	jal	0 <append_str>
    write(1, buf, pos);
 354:	bcc42603          	lw	a2,-1076(s0)
 358:	85a6                	mv	a1,s1
 35a:	4505                	li	a0,1
 35c:	4d0000ef          	jal	82c <write>
}
 360:	43813083          	ld	ra,1080(sp)
 364:	43013403          	ld	s0,1072(sp)
 368:	42813483          	ld	s1,1064(sp)
 36c:	42013903          	ld	s2,1056(sp)
 370:	41813983          	ld	s3,1048(sp)
 374:	44010113          	addi	sp,sp,1088
 378:	8082                	ret

000000000000037a <main>:

int
main(void)
{
 37a:	711d                	addi	sp,sp,-96
 37c:	ec86                	sd	ra,88(sp)
 37e:	e8a2                	sd	s0,80(sp)
 380:	fc4e                	sd	s3,56(sp)
 382:	1080                	addi	s0,sp,96
    int n;

    memset(cpus, 0, sizeof(cpus));
 384:	24000613          	li	a2,576
 388:	4581                	li	a1,0
 38a:	00002517          	auipc	a0,0x2
 38e:	c8650513          	addi	a0,a0,-890 # 2010 <cpus>
 392:	250000ef          	jal	5e2 <memset>
    memset(&stats, 0, sizeof(stats));
 396:	07000613          	li	a2,112
 39a:	4581                	li	a1,0
 39c:	00002517          	auipc	a0,0x2
 3a0:	eb450513          	addi	a0,a0,-332 # 2250 <stats>
 3a4:	23e000ef          	jal	5e2 <memset>

    n = getcpuinfo(cpus, NCPU);
 3a8:	45a1                	li	a1,8
 3aa:	00002517          	auipc	a0,0x2
 3ae:	c6650513          	addi	a0,a0,-922 # 2010 <cpus>
 3b2:	51a000ef          	jal	8cc <getcpuinfo>
    if (n < 0 || getprocstats(&stats) < 0) {
 3b6:	00054b63          	bltz	a0,3cc <main+0x52>
 3ba:	89aa                	mv	s3,a0
 3bc:	00002517          	auipc	a0,0x2
 3c0:	e9450513          	addi	a0,a0,-364 # 2250 <stats>
 3c4:	510000ef          	jal	8d4 <getprocstats>
 3c8:	02055163          	bgez	a0,3ea <main+0x70>
 3cc:	e4a6                	sd	s1,72(sp)
 3ce:	e0ca                	sd	s2,64(sp)
 3d0:	f852                	sd	s4,48(sp)
 3d2:	f456                	sd	s5,40(sp)
 3d4:	f05a                	sd	s6,32(sp)
 3d6:	ec5e                	sd	s7,24(sp)
        printf("Error fetching system info\n");
 3d8:	00001517          	auipc	a0,0x1
 3dc:	b2050513          	addi	a0,a0,-1248 # ef8 <malloc+0x1be>
 3e0:	0a3000ef          	jal	c82 <printf>
        exit(1);
 3e4:	4505                	li	a0,1
 3e6:	426000ef          	jal	80c <exit>
 3ea:	e4a6                	sd	s1,72(sp)
 3ec:	e0ca                	sd	s2,64(sp)
 3ee:	f852                	sd	s4,48(sp)
 3f0:	f456                	sd	s5,40(sp)
 3f2:	f05a                	sd	s6,32(sp)
 3f4:	ec5e                	sd	s7,24(sp)
    }
    
    // DEBUG: Print number of CPUs returned
    printf("[DEBUG] getcpuinfo returned %d CPUs\n", n);
 3f6:	85ce                	mv	a1,s3
 3f8:	00001517          	auipc	a0,0x1
 3fc:	b2050513          	addi	a0,a0,-1248 # f18 <malloc+0x1de>
 400:	083000ef          	jal	c82 <printf>

    // 1. طباعة حالة المعالجات الحالية
    printf("CPU {\"timestamp\":\"now\",\"system\":{");
 404:	00001517          	auipc	a0,0x1
 408:	b3c50513          	addi	a0,a0,-1220 # f40 <malloc+0x206>
 40c:	077000ef          	jal	c82 <printf>
    printf("\"total_created\":%lu,\"total_exited\":%lu,", stats.total_created, stats.total_exited);
 410:	00002497          	auipc	s1,0x2
 414:	c0048493          	addi	s1,s1,-1024 # 2010 <cpus>
 418:	2a84b603          	ld	a2,680(s1)
 41c:	2a04b583          	ld	a1,672(s1)
 420:	00001517          	auipc	a0,0x1
 424:	b4850513          	addi	a0,a0,-1208 # f68 <malloc+0x22e>
 428:	05b000ef          	jal	c82 <printf>
    printf("\"ever_running\":%lu,\"ever_sleeping\":%lu,\"ever_zombie\":%lu},", 
 42c:	2984b683          	ld	a3,664(s1)
 430:	2804b603          	ld	a2,640(s1)
 434:	2904b583          	ld	a1,656(s1)
 438:	00001517          	auipc	a0,0x1
 43c:	b5850513          	addi	a0,a0,-1192 # f90 <malloc+0x256>
 440:	043000ef          	jal	c82 <printf>
            stats.unique_count[4], stats.unique_count[2], stats.unique_count[5]);

    printf("\"cpus\":[");
 444:	00001517          	auipc	a0,0x1
 448:	b8c50513          	addi	a0,a0,-1140 # fd0 <malloc+0x296>
 44c:	037000ef          	jal	c82 <printf>
    for (int i = 0; i < n; i++) {
 450:	07305d63          	blez	s3,4ca <main+0x150>
 454:	00002917          	auipc	s2,0x2
 458:	bc890913          	addi	s2,s2,-1080 # 201c <cpus+0xc>
 45c:	4481                	li	s1,0
        int state_idx = cpus[i].current_state;
        const char *st_name = "UNK";
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 45e:	4b15                	li	s6,5
            st_name = state_names[state_idx];
 460:	00001b97          	auipc	s7,0x1
 464:	c70b8b93          	addi	s7,s7,-912 # 10d0 <state_names>
        }

        printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"proc_name\":\"%s\",\"current_state\":\"%s\",\"context_eip\":\"0x%lx\",\"context_esp\":\"0x%lx\",\"busy_percent\":%d}",
 468:	00001a97          	auipc	s5,0x1
 46c:	b78a8a93          	addi	s5,s5,-1160 # fe0 <malloc+0x2a6>
               cpus[i].cpu, cpus[i].active, cpus[i].current_pid, cpus[i].proc_name, st_name, cpus[i].context_eip, cpus[i].context_esp, cpus[i].busy_percent);
        
        if (i < n - 1) printf(",");
 470:	fff98a1b          	addiw	s4,s3,-1
 474:	a03d                	j	4a2 <main+0x128>
        printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"proc_name\":\"%s\",\"current_state\":\"%s\",\"context_eip\":\"0x%lx\",\"context_esp\":\"0x%lx\",\"busy_percent\":%d}",
 476:	5b54                	lw	a3,52(a4)
 478:	e036                	sd	a3,0(sp)
 47a:	02c73883          	ld	a7,44(a4)
 47e:	02473803          	ld	a6,36(a4)
 482:	ffc72683          	lw	a3,-4(a4)
 486:	ff872603          	lw	a2,-8(a4)
 48a:	ff472583          	lw	a1,-12(a4)
 48e:	8556                	mv	a0,s5
 490:	7f2000ef          	jal	c82 <printf>
        if (i < n - 1) printf(",");
 494:	0344c463          	blt	s1,s4,4bc <main+0x142>
    for (int i = 0; i < n; i++) {
 498:	2485                	addiw	s1,s1,1
 49a:	04890913          	addi	s2,s2,72
 49e:	02998663          	beq	s3,s1,4ca <main+0x150>
        int state_idx = cpus[i].current_state;
 4a2:	874a                	mv	a4,s2
 4a4:	01092683          	lw	a3,16(s2)
        const char *st_name = "UNK";
 4a8:	00001797          	auipc	a5,0x1
 4ac:	a4878793          	addi	a5,a5,-1464 # ef0 <malloc+0x1b6>
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 4b0:	fcdb63e3          	bltu	s6,a3,476 <main+0xfc>
            st_name = state_names[state_idx];
 4b4:	068e                	slli	a3,a3,0x3
 4b6:	96de                	add	a3,a3,s7
 4b8:	629c                	ld	a5,0(a3)
 4ba:	bf75                	j	476 <main+0xfc>
        if (i < n - 1) printf(",");
 4bc:	00001517          	auipc	a0,0x1
 4c0:	bbc50513          	addi	a0,a0,-1092 # 1078 <malloc+0x33e>
 4c4:	7be000ef          	jal	c82 <printf>
 4c8:	bfc1                	j	498 <main+0x11e>
    }
    printf("]}\n");
 4ca:	00001517          	auipc	a0,0x1
 4ce:	bb650513          	addi	a0,a0,-1098 # 1080 <malloc+0x346>
 4d2:	7b0000ef          	jal	c82 <printf>

   // 2. قراءة أحداث المعالج المتوفرة في البفر حالياً
    int n_cs = csread(cs_ev, 32);
 4d6:	02000593          	li	a1,32
 4da:	00002517          	auipc	a0,0x2
 4de:	de650513          	addi	a0,a0,-538 # 22c0 <cs_ev>
 4e2:	3ca000ef          	jal	8ac <csread>
    for (int i = 0; i < n_cs; i++) { // الدوران فقط حتى n_cs الحقيقية
 4e6:	02a05963          	blez	a0,518 <main+0x19e>
 4ea:	00002497          	auipc	s1,0x2
 4ee:	dd648493          	addi	s1,s1,-554 # 22c0 <cs_ev>
 4f2:	03000793          	li	a5,48
 4f6:	02f50533          	mul	a0,a0,a5
 4fa:	00950933          	add	s2,a0,s1
        if (cs_ev[i].type == 1) 
 4fe:	4985                	li	s3,1
 500:	a029                	j	50a <main+0x190>
    for (int i = 0; i < n_cs; i++) { // الدوران فقط حتى n_cs الحقيقية
 502:	03048493          	addi	s1,s1,48
 506:	01248963          	beq	s1,s2,518 <main+0x19e>
        if (cs_ev[i].type == 1) 
 50a:	489c                	lw	a5,16(s1)
 50c:	ff379be3          	bne	a5,s3,502 <main+0x188>
            print_cs_event(&cs_ev[i]);
 510:	8526                	mv	a0,s1
 512:	c09ff0ef          	jal	11a <print_cs_event>
 516:	b7f5                	j	502 <main+0x188>
    }

    
// 3. قراءة أحداث نظام الملفات المتوفرة في البفر حالياً
    int n_fs = fsread(fs_ev, 32);
 518:	02000593          	li	a1,32
 51c:	00002517          	auipc	a0,0x2
 520:	3a450513          	addi	a0,a0,932 # 28c0 <fs_ev>
 524:	390000ef          	jal	8b4 <fsread>
    for (int i = 0; i < n_fs; i++) { 
 528:	02a05463          	blez	a0,550 <main+0x1d6>
 52c:	00002497          	auipc	s1,0x2
 530:	39448493          	addi	s1,s1,916 # 28c0 <fs_ev>
 534:	0526                	slli	a0,a0,0x9
 536:	00950933          	add	s2,a0,s1
 53a:	a029                	j	544 <main+0x1ca>
 53c:	20048493          	addi	s1,s1,512
 540:	01248863          	beq	s1,s2,550 <main+0x1d6>
        // إذا كان الـ seq مصفراً، فهذا مخلفات بافر، لا تطبعه
        if (fs_ev[i].seq != 0) {
 544:	609c                	ld	a5,0(s1)
 546:	dbfd                	beqz	a5,53c <main+0x1c2>
            print_fs_event(&fs_ev[i]);
 548:	8526                	mv	a0,s1
 54a:	ce5ff0ef          	jal	22e <print_fs_event>
 54e:	b7fd                	j	53c <main+0x1c2>
        }
    }
    // الخروج وإنهاء البرنامج فوراً دون الدخول في حلقة لانهائية
    exit(0); 
 550:	4501                	li	a0,0
 552:	2ba000ef          	jal	80c <exit>

0000000000000556 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 556:	1141                	addi	sp,sp,-16
 558:	e406                	sd	ra,8(sp)
 55a:	e022                	sd	s0,0(sp)
 55c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 55e:	e1dff0ef          	jal	37a <main>
  exit(r);
 562:	2aa000ef          	jal	80c <exit>

0000000000000566 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 566:	1141                	addi	sp,sp,-16
 568:	e406                	sd	ra,8(sp)
 56a:	e022                	sd	s0,0(sp)
 56c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 56e:	87aa                	mv	a5,a0
 570:	0585                	addi	a1,a1,1
 572:	0785                	addi	a5,a5,1
 574:	fff5c703          	lbu	a4,-1(a1)
 578:	fee78fa3          	sb	a4,-1(a5)
 57c:	fb75                	bnez	a4,570 <strcpy+0xa>
    ;
  return os;
}
 57e:	60a2                	ld	ra,8(sp)
 580:	6402                	ld	s0,0(sp)
 582:	0141                	addi	sp,sp,16
 584:	8082                	ret

0000000000000586 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 586:	1141                	addi	sp,sp,-16
 588:	e406                	sd	ra,8(sp)
 58a:	e022                	sd	s0,0(sp)
 58c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 58e:	00054783          	lbu	a5,0(a0)
 592:	cb91                	beqz	a5,5a6 <strcmp+0x20>
 594:	0005c703          	lbu	a4,0(a1)
 598:	00f71763          	bne	a4,a5,5a6 <strcmp+0x20>
    p++, q++;
 59c:	0505                	addi	a0,a0,1
 59e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 5a0:	00054783          	lbu	a5,0(a0)
 5a4:	fbe5                	bnez	a5,594 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 5a6:	0005c503          	lbu	a0,0(a1)
}
 5aa:	40a7853b          	subw	a0,a5,a0
 5ae:	60a2                	ld	ra,8(sp)
 5b0:	6402                	ld	s0,0(sp)
 5b2:	0141                	addi	sp,sp,16
 5b4:	8082                	ret

00000000000005b6 <strlen>:

uint
strlen(const char *s)
{
 5b6:	1141                	addi	sp,sp,-16
 5b8:	e406                	sd	ra,8(sp)
 5ba:	e022                	sd	s0,0(sp)
 5bc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 5be:	00054783          	lbu	a5,0(a0)
 5c2:	cf91                	beqz	a5,5de <strlen+0x28>
 5c4:	00150793          	addi	a5,a0,1
 5c8:	86be                	mv	a3,a5
 5ca:	0785                	addi	a5,a5,1
 5cc:	fff7c703          	lbu	a4,-1(a5)
 5d0:	ff65                	bnez	a4,5c8 <strlen+0x12>
 5d2:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 5d6:	60a2                	ld	ra,8(sp)
 5d8:	6402                	ld	s0,0(sp)
 5da:	0141                	addi	sp,sp,16
 5dc:	8082                	ret
  for(n = 0; s[n]; n++)
 5de:	4501                	li	a0,0
 5e0:	bfdd                	j	5d6 <strlen+0x20>

00000000000005e2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 5e2:	1141                	addi	sp,sp,-16
 5e4:	e406                	sd	ra,8(sp)
 5e6:	e022                	sd	s0,0(sp)
 5e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 5ea:	ca19                	beqz	a2,600 <memset+0x1e>
 5ec:	87aa                	mv	a5,a0
 5ee:	1602                	slli	a2,a2,0x20
 5f0:	9201                	srli	a2,a2,0x20
 5f2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 5f6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 5fa:	0785                	addi	a5,a5,1
 5fc:	fee79de3          	bne	a5,a4,5f6 <memset+0x14>
  }
  return dst;
}
 600:	60a2                	ld	ra,8(sp)
 602:	6402                	ld	s0,0(sp)
 604:	0141                	addi	sp,sp,16
 606:	8082                	ret

0000000000000608 <strchr>:

char*
strchr(const char *s, char c)
{
 608:	1141                	addi	sp,sp,-16
 60a:	e406                	sd	ra,8(sp)
 60c:	e022                	sd	s0,0(sp)
 60e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 610:	00054783          	lbu	a5,0(a0)
 614:	cf81                	beqz	a5,62c <strchr+0x24>
    if(*s == c)
 616:	00f58763          	beq	a1,a5,624 <strchr+0x1c>
  for(; *s; s++)
 61a:	0505                	addi	a0,a0,1
 61c:	00054783          	lbu	a5,0(a0)
 620:	fbfd                	bnez	a5,616 <strchr+0xe>
      return (char*)s;
  return 0;
 622:	4501                	li	a0,0
}
 624:	60a2                	ld	ra,8(sp)
 626:	6402                	ld	s0,0(sp)
 628:	0141                	addi	sp,sp,16
 62a:	8082                	ret
  return 0;
 62c:	4501                	li	a0,0
 62e:	bfdd                	j	624 <strchr+0x1c>

0000000000000630 <gets>:

char*
gets(char *buf, int max)
{
 630:	711d                	addi	sp,sp,-96
 632:	ec86                	sd	ra,88(sp)
 634:	e8a2                	sd	s0,80(sp)
 636:	e4a6                	sd	s1,72(sp)
 638:	e0ca                	sd	s2,64(sp)
 63a:	fc4e                	sd	s3,56(sp)
 63c:	f852                	sd	s4,48(sp)
 63e:	f456                	sd	s5,40(sp)
 640:	f05a                	sd	s6,32(sp)
 642:	ec5e                	sd	s7,24(sp)
 644:	e862                	sd	s8,16(sp)
 646:	1080                	addi	s0,sp,96
 648:	8baa                	mv	s7,a0
 64a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 64c:	892a                	mv	s2,a0
 64e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 650:	faf40b13          	addi	s6,s0,-81
 654:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 656:	8c26                	mv	s8,s1
 658:	0014899b          	addiw	s3,s1,1
 65c:	84ce                	mv	s1,s3
 65e:	0349d463          	bge	s3,s4,686 <gets+0x56>
    cc = read(0, &c, 1);
 662:	8656                	mv	a2,s5
 664:	85da                	mv	a1,s6
 666:	4501                	li	a0,0
 668:	1bc000ef          	jal	824 <read>
    if(cc < 1)
 66c:	00a05d63          	blez	a0,686 <gets+0x56>
      break;
    buf[i++] = c;
 670:	faf44783          	lbu	a5,-81(s0)
 674:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 678:	0905                	addi	s2,s2,1
 67a:	ff678713          	addi	a4,a5,-10
 67e:	c319                	beqz	a4,684 <gets+0x54>
 680:	17cd                	addi	a5,a5,-13
 682:	fbf1                	bnez	a5,656 <gets+0x26>
    buf[i++] = c;
 684:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 686:	9c5e                	add	s8,s8,s7
 688:	000c0023          	sb	zero,0(s8)
  return buf;
}
 68c:	855e                	mv	a0,s7
 68e:	60e6                	ld	ra,88(sp)
 690:	6446                	ld	s0,80(sp)
 692:	64a6                	ld	s1,72(sp)
 694:	6906                	ld	s2,64(sp)
 696:	79e2                	ld	s3,56(sp)
 698:	7a42                	ld	s4,48(sp)
 69a:	7aa2                	ld	s5,40(sp)
 69c:	7b02                	ld	s6,32(sp)
 69e:	6be2                	ld	s7,24(sp)
 6a0:	6c42                	ld	s8,16(sp)
 6a2:	6125                	addi	sp,sp,96
 6a4:	8082                	ret

00000000000006a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 6a6:	1101                	addi	sp,sp,-32
 6a8:	ec06                	sd	ra,24(sp)
 6aa:	e822                	sd	s0,16(sp)
 6ac:	e04a                	sd	s2,0(sp)
 6ae:	1000                	addi	s0,sp,32
 6b0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6b2:	4581                	li	a1,0
 6b4:	198000ef          	jal	84c <open>
  if(fd < 0)
 6b8:	02054263          	bltz	a0,6dc <stat+0x36>
 6bc:	e426                	sd	s1,8(sp)
 6be:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 6c0:	85ca                	mv	a1,s2
 6c2:	1a2000ef          	jal	864 <fstat>
 6c6:	892a                	mv	s2,a0
  close(fd);
 6c8:	8526                	mv	a0,s1
 6ca:	16a000ef          	jal	834 <close>
  return r;
 6ce:	64a2                	ld	s1,8(sp)
}
 6d0:	854a                	mv	a0,s2
 6d2:	60e2                	ld	ra,24(sp)
 6d4:	6442                	ld	s0,16(sp)
 6d6:	6902                	ld	s2,0(sp)
 6d8:	6105                	addi	sp,sp,32
 6da:	8082                	ret
    return -1;
 6dc:	57fd                	li	a5,-1
 6de:	893e                	mv	s2,a5
 6e0:	bfc5                	j	6d0 <stat+0x2a>

00000000000006e2 <atoi>:

int
atoi(const char *s)
{
 6e2:	1141                	addi	sp,sp,-16
 6e4:	e406                	sd	ra,8(sp)
 6e6:	e022                	sd	s0,0(sp)
 6e8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6ea:	00054683          	lbu	a3,0(a0)
 6ee:	fd06879b          	addiw	a5,a3,-48
 6f2:	0ff7f793          	zext.b	a5,a5
 6f6:	4625                	li	a2,9
 6f8:	02f66963          	bltu	a2,a5,72a <atoi+0x48>
 6fc:	872a                	mv	a4,a0
  n = 0;
 6fe:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 700:	0705                	addi	a4,a4,1
 702:	0025179b          	slliw	a5,a0,0x2
 706:	9fa9                	addw	a5,a5,a0
 708:	0017979b          	slliw	a5,a5,0x1
 70c:	9fb5                	addw	a5,a5,a3
 70e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 712:	00074683          	lbu	a3,0(a4)
 716:	fd06879b          	addiw	a5,a3,-48
 71a:	0ff7f793          	zext.b	a5,a5
 71e:	fef671e3          	bgeu	a2,a5,700 <atoi+0x1e>
  return n;
}
 722:	60a2                	ld	ra,8(sp)
 724:	6402                	ld	s0,0(sp)
 726:	0141                	addi	sp,sp,16
 728:	8082                	ret
  n = 0;
 72a:	4501                	li	a0,0
 72c:	bfdd                	j	722 <atoi+0x40>

000000000000072e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 72e:	1141                	addi	sp,sp,-16
 730:	e406                	sd	ra,8(sp)
 732:	e022                	sd	s0,0(sp)
 734:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 736:	02b57563          	bgeu	a0,a1,760 <memmove+0x32>
    while(n-- > 0)
 73a:	00c05f63          	blez	a2,758 <memmove+0x2a>
 73e:	1602                	slli	a2,a2,0x20
 740:	9201                	srli	a2,a2,0x20
 742:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 746:	872a                	mv	a4,a0
      *dst++ = *src++;
 748:	0585                	addi	a1,a1,1
 74a:	0705                	addi	a4,a4,1
 74c:	fff5c683          	lbu	a3,-1(a1)
 750:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 754:	fee79ae3          	bne	a5,a4,748 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 758:	60a2                	ld	ra,8(sp)
 75a:	6402                	ld	s0,0(sp)
 75c:	0141                	addi	sp,sp,16
 75e:	8082                	ret
    while(n-- > 0)
 760:	fec05ce3          	blez	a2,758 <memmove+0x2a>
    dst += n;
 764:	00c50733          	add	a4,a0,a2
    src += n;
 768:	95b2                	add	a1,a1,a2
 76a:	fff6079b          	addiw	a5,a2,-1
 76e:	1782                	slli	a5,a5,0x20
 770:	9381                	srli	a5,a5,0x20
 772:	fff7c793          	not	a5,a5
 776:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 778:	15fd                	addi	a1,a1,-1
 77a:	177d                	addi	a4,a4,-1
 77c:	0005c683          	lbu	a3,0(a1)
 780:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 784:	fef71ae3          	bne	a4,a5,778 <memmove+0x4a>
 788:	bfc1                	j	758 <memmove+0x2a>

000000000000078a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 78a:	1141                	addi	sp,sp,-16
 78c:	e406                	sd	ra,8(sp)
 78e:	e022                	sd	s0,0(sp)
 790:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 792:	c61d                	beqz	a2,7c0 <memcmp+0x36>
 794:	1602                	slli	a2,a2,0x20
 796:	9201                	srli	a2,a2,0x20
 798:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 79c:	00054783          	lbu	a5,0(a0)
 7a0:	0005c703          	lbu	a4,0(a1)
 7a4:	00e79863          	bne	a5,a4,7b4 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 7a8:	0505                	addi	a0,a0,1
    p2++;
 7aa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 7ac:	fed518e3          	bne	a0,a3,79c <memcmp+0x12>
  }
  return 0;
 7b0:	4501                	li	a0,0
 7b2:	a019                	j	7b8 <memcmp+0x2e>
      return *p1 - *p2;
 7b4:	40e7853b          	subw	a0,a5,a4
}
 7b8:	60a2                	ld	ra,8(sp)
 7ba:	6402                	ld	s0,0(sp)
 7bc:	0141                	addi	sp,sp,16
 7be:	8082                	ret
  return 0;
 7c0:	4501                	li	a0,0
 7c2:	bfdd                	j	7b8 <memcmp+0x2e>

00000000000007c4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 7c4:	1141                	addi	sp,sp,-16
 7c6:	e406                	sd	ra,8(sp)
 7c8:	e022                	sd	s0,0(sp)
 7ca:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 7cc:	f63ff0ef          	jal	72e <memmove>
}
 7d0:	60a2                	ld	ra,8(sp)
 7d2:	6402                	ld	s0,0(sp)
 7d4:	0141                	addi	sp,sp,16
 7d6:	8082                	ret

00000000000007d8 <sbrk>:

char *
sbrk(int n) {
 7d8:	1141                	addi	sp,sp,-16
 7da:	e406                	sd	ra,8(sp)
 7dc:	e022                	sd	s0,0(sp)
 7de:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 7e0:	4585                	li	a1,1
 7e2:	0b2000ef          	jal	894 <sys_sbrk>
}
 7e6:	60a2                	ld	ra,8(sp)
 7e8:	6402                	ld	s0,0(sp)
 7ea:	0141                	addi	sp,sp,16
 7ec:	8082                	ret

00000000000007ee <sbrklazy>:

char *
sbrklazy(int n) {
 7ee:	1141                	addi	sp,sp,-16
 7f0:	e406                	sd	ra,8(sp)
 7f2:	e022                	sd	s0,0(sp)
 7f4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 7f6:	4589                	li	a1,2
 7f8:	09c000ef          	jal	894 <sys_sbrk>
}
 7fc:	60a2                	ld	ra,8(sp)
 7fe:	6402                	ld	s0,0(sp)
 800:	0141                	addi	sp,sp,16
 802:	8082                	ret

0000000000000804 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 804:	4885                	li	a7,1
 ecall
 806:	00000073          	ecall
 ret
 80a:	8082                	ret

000000000000080c <exit>:
.global exit
exit:
 li a7, SYS_exit
 80c:	4889                	li	a7,2
 ecall
 80e:	00000073          	ecall
 ret
 812:	8082                	ret

0000000000000814 <wait>:
.global wait
wait:
 li a7, SYS_wait
 814:	488d                	li	a7,3
 ecall
 816:	00000073          	ecall
 ret
 81a:	8082                	ret

000000000000081c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 81c:	4891                	li	a7,4
 ecall
 81e:	00000073          	ecall
 ret
 822:	8082                	ret

0000000000000824 <read>:
.global read
read:
 li a7, SYS_read
 824:	4895                	li	a7,5
 ecall
 826:	00000073          	ecall
 ret
 82a:	8082                	ret

000000000000082c <write>:
.global write
write:
 li a7, SYS_write
 82c:	48c1                	li	a7,16
 ecall
 82e:	00000073          	ecall
 ret
 832:	8082                	ret

0000000000000834 <close>:
.global close
close:
 li a7, SYS_close
 834:	48d5                	li	a7,21
 ecall
 836:	00000073          	ecall
 ret
 83a:	8082                	ret

000000000000083c <kill>:
.global kill
kill:
 li a7, SYS_kill
 83c:	4899                	li	a7,6
 ecall
 83e:	00000073          	ecall
 ret
 842:	8082                	ret

0000000000000844 <exec>:
.global exec
exec:
 li a7, SYS_exec
 844:	489d                	li	a7,7
 ecall
 846:	00000073          	ecall
 ret
 84a:	8082                	ret

000000000000084c <open>:
.global open
open:
 li a7, SYS_open
 84c:	48bd                	li	a7,15
 ecall
 84e:	00000073          	ecall
 ret
 852:	8082                	ret

0000000000000854 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 854:	48c5                	li	a7,17
 ecall
 856:	00000073          	ecall
 ret
 85a:	8082                	ret

000000000000085c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 85c:	48c9                	li	a7,18
 ecall
 85e:	00000073          	ecall
 ret
 862:	8082                	ret

0000000000000864 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 864:	48a1                	li	a7,8
 ecall
 866:	00000073          	ecall
 ret
 86a:	8082                	ret

000000000000086c <link>:
.global link
link:
 li a7, SYS_link
 86c:	48cd                	li	a7,19
 ecall
 86e:	00000073          	ecall
 ret
 872:	8082                	ret

0000000000000874 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 874:	48d1                	li	a7,20
 ecall
 876:	00000073          	ecall
 ret
 87a:	8082                	ret

000000000000087c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 87c:	48a5                	li	a7,9
 ecall
 87e:	00000073          	ecall
 ret
 882:	8082                	ret

0000000000000884 <dup>:
.global dup
dup:
 li a7, SYS_dup
 884:	48a9                	li	a7,10
 ecall
 886:	00000073          	ecall
 ret
 88a:	8082                	ret

000000000000088c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 88c:	48ad                	li	a7,11
 ecall
 88e:	00000073          	ecall
 ret
 892:	8082                	ret

0000000000000894 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 894:	48b1                	li	a7,12
 ecall
 896:	00000073          	ecall
 ret
 89a:	8082                	ret

000000000000089c <pause>:
.global pause
pause:
 li a7, SYS_pause
 89c:	48b5                	li	a7,13
 ecall
 89e:	00000073          	ecall
 ret
 8a2:	8082                	ret

00000000000008a4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 8a4:	48b9                	li	a7,14
 ecall
 8a6:	00000073          	ecall
 ret
 8aa:	8082                	ret

00000000000008ac <csread>:
.global csread
csread:
 li a7, SYS_csread
 8ac:	48d9                	li	a7,22
 ecall
 8ae:	00000073          	ecall
 ret
 8b2:	8082                	ret

00000000000008b4 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 8b4:	48dd                	li	a7,23
 ecall
 8b6:	00000073          	ecall
 ret
 8ba:	8082                	ret

00000000000008bc <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 8bc:	48e1                	li	a7,24
 ecall
 8be:	00000073          	ecall
 ret
 8c2:	8082                	ret

00000000000008c4 <memread>:
.global memread
memread:
 li a7, SYS_memread
 8c4:	48e5                	li	a7,25
 ecall
 8c6:	00000073          	ecall
 ret
 8ca:	8082                	ret

00000000000008cc <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 8cc:	48e9                	li	a7,26
 ecall
 8ce:	00000073          	ecall
 ret
 8d2:	8082                	ret

00000000000008d4 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 8d4:	48ed                	li	a7,27
 ecall
 8d6:	00000073          	ecall
 ret
 8da:	8082                	ret

00000000000008dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 8dc:	1101                	addi	sp,sp,-32
 8de:	ec06                	sd	ra,24(sp)
 8e0:	e822                	sd	s0,16(sp)
 8e2:	1000                	addi	s0,sp,32
 8e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 8e8:	4605                	li	a2,1
 8ea:	fef40593          	addi	a1,s0,-17
 8ee:	f3fff0ef          	jal	82c <write>
}
 8f2:	60e2                	ld	ra,24(sp)
 8f4:	6442                	ld	s0,16(sp)
 8f6:	6105                	addi	sp,sp,32
 8f8:	8082                	ret

00000000000008fa <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 8fa:	715d                	addi	sp,sp,-80
 8fc:	e486                	sd	ra,72(sp)
 8fe:	e0a2                	sd	s0,64(sp)
 900:	f84a                	sd	s2,48(sp)
 902:	f44e                	sd	s3,40(sp)
 904:	0880                	addi	s0,sp,80
 906:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 908:	c6d1                	beqz	a3,994 <printint+0x9a>
 90a:	0805d563          	bgez	a1,994 <printint+0x9a>
    neg = 1;
    x = -xx;
 90e:	40b005b3          	neg	a1,a1
    neg = 1;
 912:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 914:	fb840993          	addi	s3,s0,-72
  neg = 0;
 918:	86ce                	mv	a3,s3
  i = 0;
 91a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 91c:	00000817          	auipc	a6,0x0
 920:	7e480813          	addi	a6,a6,2020 # 1100 <digits>
 924:	88ba                	mv	a7,a4
 926:	0017051b          	addiw	a0,a4,1
 92a:	872a                	mv	a4,a0
 92c:	02c5f7b3          	remu	a5,a1,a2
 930:	97c2                	add	a5,a5,a6
 932:	0007c783          	lbu	a5,0(a5)
 936:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 93a:	87ae                	mv	a5,a1
 93c:	02c5d5b3          	divu	a1,a1,a2
 940:	0685                	addi	a3,a3,1
 942:	fec7f1e3          	bgeu	a5,a2,924 <printint+0x2a>
  if(neg)
 946:	00030c63          	beqz	t1,95e <printint+0x64>
    buf[i++] = '-';
 94a:	fd050793          	addi	a5,a0,-48
 94e:	00878533          	add	a0,a5,s0
 952:	02d00793          	li	a5,45
 956:	fef50423          	sb	a5,-24(a0)
 95a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 95e:	02e05563          	blez	a4,988 <printint+0x8e>
 962:	fc26                	sd	s1,56(sp)
 964:	377d                	addiw	a4,a4,-1
 966:	00e984b3          	add	s1,s3,a4
 96a:	19fd                	addi	s3,s3,-1
 96c:	99ba                	add	s3,s3,a4
 96e:	1702                	slli	a4,a4,0x20
 970:	9301                	srli	a4,a4,0x20
 972:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 976:	0004c583          	lbu	a1,0(s1)
 97a:	854a                	mv	a0,s2
 97c:	f61ff0ef          	jal	8dc <putc>
  while(--i >= 0)
 980:	14fd                	addi	s1,s1,-1
 982:	ff349ae3          	bne	s1,s3,976 <printint+0x7c>
 986:	74e2                	ld	s1,56(sp)
}
 988:	60a6                	ld	ra,72(sp)
 98a:	6406                	ld	s0,64(sp)
 98c:	7942                	ld	s2,48(sp)
 98e:	79a2                	ld	s3,40(sp)
 990:	6161                	addi	sp,sp,80
 992:	8082                	ret
  neg = 0;
 994:	4301                	li	t1,0
 996:	bfbd                	j	914 <printint+0x1a>

0000000000000998 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 998:	711d                	addi	sp,sp,-96
 99a:	ec86                	sd	ra,88(sp)
 99c:	e8a2                	sd	s0,80(sp)
 99e:	e4a6                	sd	s1,72(sp)
 9a0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 9a2:	0005c483          	lbu	s1,0(a1)
 9a6:	22048363          	beqz	s1,bcc <vprintf+0x234>
 9aa:	e0ca                	sd	s2,64(sp)
 9ac:	fc4e                	sd	s3,56(sp)
 9ae:	f852                	sd	s4,48(sp)
 9b0:	f456                	sd	s5,40(sp)
 9b2:	f05a                	sd	s6,32(sp)
 9b4:	ec5e                	sd	s7,24(sp)
 9b6:	e862                	sd	s8,16(sp)
 9b8:	8b2a                	mv	s6,a0
 9ba:	8a2e                	mv	s4,a1
 9bc:	8bb2                	mv	s7,a2
  state = 0;
 9be:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 9c0:	4901                	li	s2,0
 9c2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 9c4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 9c8:	06400c13          	li	s8,100
 9cc:	a00d                	j	9ee <vprintf+0x56>
        putc(fd, c0);
 9ce:	85a6                	mv	a1,s1
 9d0:	855a                	mv	a0,s6
 9d2:	f0bff0ef          	jal	8dc <putc>
 9d6:	a019                	j	9dc <vprintf+0x44>
    } else if(state == '%'){
 9d8:	03598363          	beq	s3,s5,9fe <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 9dc:	0019079b          	addiw	a5,s2,1
 9e0:	893e                	mv	s2,a5
 9e2:	873e                	mv	a4,a5
 9e4:	97d2                	add	a5,a5,s4
 9e6:	0007c483          	lbu	s1,0(a5)
 9ea:	1c048a63          	beqz	s1,bbe <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 9ee:	0004879b          	sext.w	a5,s1
    if(state == 0){
 9f2:	fe0993e3          	bnez	s3,9d8 <vprintf+0x40>
      if(c0 == '%'){
 9f6:	fd579ce3          	bne	a5,s5,9ce <vprintf+0x36>
        state = '%';
 9fa:	89be                	mv	s3,a5
 9fc:	b7c5                	j	9dc <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 9fe:	00ea06b3          	add	a3,s4,a4
 a02:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 a06:	1c060863          	beqz	a2,bd6 <vprintf+0x23e>
      if(c0 == 'd'){
 a0a:	03878763          	beq	a5,s8,a38 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 a0e:	f9478693          	addi	a3,a5,-108
 a12:	0016b693          	seqz	a3,a3
 a16:	f9c60593          	addi	a1,a2,-100
 a1a:	e99d                	bnez	a1,a50 <vprintf+0xb8>
 a1c:	ca95                	beqz	a3,a50 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 a1e:	008b8493          	addi	s1,s7,8
 a22:	4685                	li	a3,1
 a24:	4629                	li	a2,10
 a26:	000bb583          	ld	a1,0(s7)
 a2a:	855a                	mv	a0,s6
 a2c:	ecfff0ef          	jal	8fa <printint>
        i += 1;
 a30:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 a32:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 a34:	4981                	li	s3,0
 a36:	b75d                	j	9dc <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 a38:	008b8493          	addi	s1,s7,8
 a3c:	4685                	li	a3,1
 a3e:	4629                	li	a2,10
 a40:	000ba583          	lw	a1,0(s7)
 a44:	855a                	mv	a0,s6
 a46:	eb5ff0ef          	jal	8fa <printint>
 a4a:	8ba6                	mv	s7,s1
      state = 0;
 a4c:	4981                	li	s3,0
 a4e:	b779                	j	9dc <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 a50:	9752                	add	a4,a4,s4
 a52:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 a56:	f9460713          	addi	a4,a2,-108
 a5a:	00173713          	seqz	a4,a4
 a5e:	8f75                	and	a4,a4,a3
 a60:	f9c58513          	addi	a0,a1,-100
 a64:	18051363          	bnez	a0,bea <vprintf+0x252>
 a68:	18070163          	beqz	a4,bea <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 a6c:	008b8493          	addi	s1,s7,8
 a70:	4685                	li	a3,1
 a72:	4629                	li	a2,10
 a74:	000bb583          	ld	a1,0(s7)
 a78:	855a                	mv	a0,s6
 a7a:	e81ff0ef          	jal	8fa <printint>
        i += 2;
 a7e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 a80:	8ba6                	mv	s7,s1
      state = 0;
 a82:	4981                	li	s3,0
        i += 2;
 a84:	bfa1                	j	9dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 a86:	008b8493          	addi	s1,s7,8
 a8a:	4681                	li	a3,0
 a8c:	4629                	li	a2,10
 a8e:	000be583          	lwu	a1,0(s7)
 a92:	855a                	mv	a0,s6
 a94:	e67ff0ef          	jal	8fa <printint>
 a98:	8ba6                	mv	s7,s1
      state = 0;
 a9a:	4981                	li	s3,0
 a9c:	b781                	j	9dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a9e:	008b8493          	addi	s1,s7,8
 aa2:	4681                	li	a3,0
 aa4:	4629                	li	a2,10
 aa6:	000bb583          	ld	a1,0(s7)
 aaa:	855a                	mv	a0,s6
 aac:	e4fff0ef          	jal	8fa <printint>
        i += 1;
 ab0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 ab2:	8ba6                	mv	s7,s1
      state = 0;
 ab4:	4981                	li	s3,0
 ab6:	b71d                	j	9dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 ab8:	008b8493          	addi	s1,s7,8
 abc:	4681                	li	a3,0
 abe:	4629                	li	a2,10
 ac0:	000bb583          	ld	a1,0(s7)
 ac4:	855a                	mv	a0,s6
 ac6:	e35ff0ef          	jal	8fa <printint>
        i += 2;
 aca:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 acc:	8ba6                	mv	s7,s1
      state = 0;
 ace:	4981                	li	s3,0
        i += 2;
 ad0:	b731                	j	9dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 ad2:	008b8493          	addi	s1,s7,8
 ad6:	4681                	li	a3,0
 ad8:	4641                	li	a2,16
 ada:	000be583          	lwu	a1,0(s7)
 ade:	855a                	mv	a0,s6
 ae0:	e1bff0ef          	jal	8fa <printint>
 ae4:	8ba6                	mv	s7,s1
      state = 0;
 ae6:	4981                	li	s3,0
 ae8:	bdd5                	j	9dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 aea:	008b8493          	addi	s1,s7,8
 aee:	4681                	li	a3,0
 af0:	4641                	li	a2,16
 af2:	000bb583          	ld	a1,0(s7)
 af6:	855a                	mv	a0,s6
 af8:	e03ff0ef          	jal	8fa <printint>
        i += 1;
 afc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 afe:	8ba6                	mv	s7,s1
      state = 0;
 b00:	4981                	li	s3,0
 b02:	bde9                	j	9dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 b04:	008b8493          	addi	s1,s7,8
 b08:	4681                	li	a3,0
 b0a:	4641                	li	a2,16
 b0c:	000bb583          	ld	a1,0(s7)
 b10:	855a                	mv	a0,s6
 b12:	de9ff0ef          	jal	8fa <printint>
        i += 2;
 b16:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 b18:	8ba6                	mv	s7,s1
      state = 0;
 b1a:	4981                	li	s3,0
        i += 2;
 b1c:	b5c1                	j	9dc <vprintf+0x44>
 b1e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 b20:	008b8793          	addi	a5,s7,8
 b24:	8cbe                	mv	s9,a5
 b26:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 b2a:	03000593          	li	a1,48
 b2e:	855a                	mv	a0,s6
 b30:	dadff0ef          	jal	8dc <putc>
  putc(fd, 'x');
 b34:	07800593          	li	a1,120
 b38:	855a                	mv	a0,s6
 b3a:	da3ff0ef          	jal	8dc <putc>
 b3e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b40:	00000b97          	auipc	s7,0x0
 b44:	5c0b8b93          	addi	s7,s7,1472 # 1100 <digits>
 b48:	03c9d793          	srli	a5,s3,0x3c
 b4c:	97de                	add	a5,a5,s7
 b4e:	0007c583          	lbu	a1,0(a5)
 b52:	855a                	mv	a0,s6
 b54:	d89ff0ef          	jal	8dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 b58:	0992                	slli	s3,s3,0x4
 b5a:	34fd                	addiw	s1,s1,-1
 b5c:	f4f5                	bnez	s1,b48 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 b5e:	8be6                	mv	s7,s9
      state = 0;
 b60:	4981                	li	s3,0
 b62:	6ca2                	ld	s9,8(sp)
 b64:	bda5                	j	9dc <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 b66:	008b8493          	addi	s1,s7,8
 b6a:	000bc583          	lbu	a1,0(s7)
 b6e:	855a                	mv	a0,s6
 b70:	d6dff0ef          	jal	8dc <putc>
 b74:	8ba6                	mv	s7,s1
      state = 0;
 b76:	4981                	li	s3,0
 b78:	b595                	j	9dc <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 b7a:	008b8993          	addi	s3,s7,8
 b7e:	000bb483          	ld	s1,0(s7)
 b82:	cc91                	beqz	s1,b9e <vprintf+0x206>
        for(; *s; s++)
 b84:	0004c583          	lbu	a1,0(s1)
 b88:	c985                	beqz	a1,bb8 <vprintf+0x220>
          putc(fd, *s);
 b8a:	855a                	mv	a0,s6
 b8c:	d51ff0ef          	jal	8dc <putc>
        for(; *s; s++)
 b90:	0485                	addi	s1,s1,1
 b92:	0004c583          	lbu	a1,0(s1)
 b96:	f9f5                	bnez	a1,b8a <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 b98:	8bce                	mv	s7,s3
      state = 0;
 b9a:	4981                	li	s3,0
 b9c:	b581                	j	9dc <vprintf+0x44>
          s = "(null)";
 b9e:	00000497          	auipc	s1,0x0
 ba2:	52a48493          	addi	s1,s1,1322 # 10c8 <malloc+0x38e>
        for(; *s; s++)
 ba6:	02800593          	li	a1,40
 baa:	b7c5                	j	b8a <vprintf+0x1f2>
        putc(fd, '%');
 bac:	85be                	mv	a1,a5
 bae:	855a                	mv	a0,s6
 bb0:	d2dff0ef          	jal	8dc <putc>
      state = 0;
 bb4:	4981                	li	s3,0
 bb6:	b51d                	j	9dc <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 bb8:	8bce                	mv	s7,s3
      state = 0;
 bba:	4981                	li	s3,0
 bbc:	b505                	j	9dc <vprintf+0x44>
 bbe:	6906                	ld	s2,64(sp)
 bc0:	79e2                	ld	s3,56(sp)
 bc2:	7a42                	ld	s4,48(sp)
 bc4:	7aa2                	ld	s5,40(sp)
 bc6:	7b02                	ld	s6,32(sp)
 bc8:	6be2                	ld	s7,24(sp)
 bca:	6c42                	ld	s8,16(sp)
    }
  }
}
 bcc:	60e6                	ld	ra,88(sp)
 bce:	6446                	ld	s0,80(sp)
 bd0:	64a6                	ld	s1,72(sp)
 bd2:	6125                	addi	sp,sp,96
 bd4:	8082                	ret
      if(c0 == 'd'){
 bd6:	06400713          	li	a4,100
 bda:	e4e78fe3          	beq	a5,a4,a38 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 bde:	f9478693          	addi	a3,a5,-108
 be2:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 be6:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 be8:	4701                	li	a4,0
      } else if(c0 == 'u'){
 bea:	07500513          	li	a0,117
 bee:	e8a78ce3          	beq	a5,a0,a86 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 bf2:	f8b60513          	addi	a0,a2,-117
 bf6:	e119                	bnez	a0,bfc <vprintf+0x264>
 bf8:	ea0693e3          	bnez	a3,a9e <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 bfc:	f8b58513          	addi	a0,a1,-117
 c00:	e119                	bnez	a0,c06 <vprintf+0x26e>
 c02:	ea071be3          	bnez	a4,ab8 <vprintf+0x120>
      } else if(c0 == 'x'){
 c06:	07800513          	li	a0,120
 c0a:	eca784e3          	beq	a5,a0,ad2 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 c0e:	f8860613          	addi	a2,a2,-120
 c12:	e219                	bnez	a2,c18 <vprintf+0x280>
 c14:	ec069be3          	bnez	a3,aea <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 c18:	f8858593          	addi	a1,a1,-120
 c1c:	e199                	bnez	a1,c22 <vprintf+0x28a>
 c1e:	ee0713e3          	bnez	a4,b04 <vprintf+0x16c>
      } else if(c0 == 'p'){
 c22:	07000713          	li	a4,112
 c26:	eee78ce3          	beq	a5,a4,b1e <vprintf+0x186>
      } else if(c0 == 'c'){
 c2a:	06300713          	li	a4,99
 c2e:	f2e78ce3          	beq	a5,a4,b66 <vprintf+0x1ce>
      } else if(c0 == 's'){
 c32:	07300713          	li	a4,115
 c36:	f4e782e3          	beq	a5,a4,b7a <vprintf+0x1e2>
      } else if(c0 == '%'){
 c3a:	02500713          	li	a4,37
 c3e:	f6e787e3          	beq	a5,a4,bac <vprintf+0x214>
        putc(fd, '%');
 c42:	02500593          	li	a1,37
 c46:	855a                	mv	a0,s6
 c48:	c95ff0ef          	jal	8dc <putc>
        putc(fd, c0);
 c4c:	85a6                	mv	a1,s1
 c4e:	855a                	mv	a0,s6
 c50:	c8dff0ef          	jal	8dc <putc>
      state = 0;
 c54:	4981                	li	s3,0
 c56:	b359                	j	9dc <vprintf+0x44>

0000000000000c58 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c58:	715d                	addi	sp,sp,-80
 c5a:	ec06                	sd	ra,24(sp)
 c5c:	e822                	sd	s0,16(sp)
 c5e:	1000                	addi	s0,sp,32
 c60:	e010                	sd	a2,0(s0)
 c62:	e414                	sd	a3,8(s0)
 c64:	e818                	sd	a4,16(s0)
 c66:	ec1c                	sd	a5,24(s0)
 c68:	03043023          	sd	a6,32(s0)
 c6c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c70:	8622                	mv	a2,s0
 c72:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c76:	d23ff0ef          	jal	998 <vprintf>
}
 c7a:	60e2                	ld	ra,24(sp)
 c7c:	6442                	ld	s0,16(sp)
 c7e:	6161                	addi	sp,sp,80
 c80:	8082                	ret

0000000000000c82 <printf>:

void
printf(const char *fmt, ...)
{
 c82:	711d                	addi	sp,sp,-96
 c84:	ec06                	sd	ra,24(sp)
 c86:	e822                	sd	s0,16(sp)
 c88:	1000                	addi	s0,sp,32
 c8a:	e40c                	sd	a1,8(s0)
 c8c:	e810                	sd	a2,16(s0)
 c8e:	ec14                	sd	a3,24(s0)
 c90:	f018                	sd	a4,32(s0)
 c92:	f41c                	sd	a5,40(s0)
 c94:	03043823          	sd	a6,48(s0)
 c98:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 c9c:	00840613          	addi	a2,s0,8
 ca0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ca4:	85aa                	mv	a1,a0
 ca6:	4505                	li	a0,1
 ca8:	cf1ff0ef          	jal	998 <vprintf>
}
 cac:	60e2                	ld	ra,24(sp)
 cae:	6442                	ld	s0,16(sp)
 cb0:	6125                	addi	sp,sp,96
 cb2:	8082                	ret

0000000000000cb4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cb4:	1141                	addi	sp,sp,-16
 cb6:	e406                	sd	ra,8(sp)
 cb8:	e022                	sd	s0,0(sp)
 cba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cbc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cc0:	00001797          	auipc	a5,0x1
 cc4:	3407b783          	ld	a5,832(a5) # 2000 <freep>
 cc8:	a039                	j	cd6 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cca:	6398                	ld	a4,0(a5)
 ccc:	00e7e463          	bltu	a5,a4,cd4 <free+0x20>
 cd0:	00e6ea63          	bltu	a3,a4,ce4 <free+0x30>
{
 cd4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cd6:	fed7fae3          	bgeu	a5,a3,cca <free+0x16>
 cda:	6398                	ld	a4,0(a5)
 cdc:	00e6e463          	bltu	a3,a4,ce4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ce0:	fee7eae3          	bltu	a5,a4,cd4 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 ce4:	ff852583          	lw	a1,-8(a0)
 ce8:	6390                	ld	a2,0(a5)
 cea:	02059813          	slli	a6,a1,0x20
 cee:	01c85713          	srli	a4,a6,0x1c
 cf2:	9736                	add	a4,a4,a3
 cf4:	02e60563          	beq	a2,a4,d1e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 cf8:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 cfc:	4790                	lw	a2,8(a5)
 cfe:	02061593          	slli	a1,a2,0x20
 d02:	01c5d713          	srli	a4,a1,0x1c
 d06:	973e                	add	a4,a4,a5
 d08:	02e68263          	beq	a3,a4,d2c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 d0c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d0e:	00001717          	auipc	a4,0x1
 d12:	2ef73923          	sd	a5,754(a4) # 2000 <freep>
}
 d16:	60a2                	ld	ra,8(sp)
 d18:	6402                	ld	s0,0(sp)
 d1a:	0141                	addi	sp,sp,16
 d1c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 d1e:	4618                	lw	a4,8(a2)
 d20:	9f2d                	addw	a4,a4,a1
 d22:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 d26:	6398                	ld	a4,0(a5)
 d28:	6310                	ld	a2,0(a4)
 d2a:	b7f9                	j	cf8 <free+0x44>
    p->s.size += bp->s.size;
 d2c:	ff852703          	lw	a4,-8(a0)
 d30:	9f31                	addw	a4,a4,a2
 d32:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 d34:	ff053683          	ld	a3,-16(a0)
 d38:	bfd1                	j	d0c <free+0x58>

0000000000000d3a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d3a:	7139                	addi	sp,sp,-64
 d3c:	fc06                	sd	ra,56(sp)
 d3e:	f822                	sd	s0,48(sp)
 d40:	f04a                	sd	s2,32(sp)
 d42:	ec4e                	sd	s3,24(sp)
 d44:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d46:	02051993          	slli	s3,a0,0x20
 d4a:	0209d993          	srli	s3,s3,0x20
 d4e:	09bd                	addi	s3,s3,15
 d50:	0049d993          	srli	s3,s3,0x4
 d54:	2985                	addiw	s3,s3,1
 d56:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 d58:	00001517          	auipc	a0,0x1
 d5c:	2a853503          	ld	a0,680(a0) # 2000 <freep>
 d60:	c905                	beqz	a0,d90 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d62:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d64:	4798                	lw	a4,8(a5)
 d66:	09377663          	bgeu	a4,s3,df2 <malloc+0xb8>
 d6a:	f426                	sd	s1,40(sp)
 d6c:	e852                	sd	s4,16(sp)
 d6e:	e456                	sd	s5,8(sp)
 d70:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 d72:	8a4e                	mv	s4,s3
 d74:	6705                	lui	a4,0x1
 d76:	00e9f363          	bgeu	s3,a4,d7c <malloc+0x42>
 d7a:	6a05                	lui	s4,0x1
 d7c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d80:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 d84:	00001497          	auipc	s1,0x1
 d88:	27c48493          	addi	s1,s1,636 # 2000 <freep>
  if(p == SBRK_ERROR)
 d8c:	5afd                	li	s5,-1
 d8e:	a83d                	j	dcc <malloc+0x92>
 d90:	f426                	sd	s1,40(sp)
 d92:	e852                	sd	s4,16(sp)
 d94:	e456                	sd	s5,8(sp)
 d96:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 d98:	00006797          	auipc	a5,0x6
 d9c:	b2878793          	addi	a5,a5,-1240 # 68c0 <base>
 da0:	00001717          	auipc	a4,0x1
 da4:	26f73023          	sd	a5,608(a4) # 2000 <freep>
 da8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 daa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 dae:	b7d1                	j	d72 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 db0:	6398                	ld	a4,0(a5)
 db2:	e118                	sd	a4,0(a0)
 db4:	a899                	j	e0a <malloc+0xd0>
  hp->s.size = nu;
 db6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 dba:	0541                	addi	a0,a0,16
 dbc:	ef9ff0ef          	jal	cb4 <free>
  return freep;
 dc0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 dc2:	c125                	beqz	a0,e22 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dc4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 dc6:	4798                	lw	a4,8(a5)
 dc8:	03277163          	bgeu	a4,s2,dea <malloc+0xb0>
    if(p == freep)
 dcc:	6098                	ld	a4,0(s1)
 dce:	853e                	mv	a0,a5
 dd0:	fef71ae3          	bne	a4,a5,dc4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 dd4:	8552                	mv	a0,s4
 dd6:	a03ff0ef          	jal	7d8 <sbrk>
  if(p == SBRK_ERROR)
 dda:	fd551ee3          	bne	a0,s5,db6 <malloc+0x7c>
        return 0;
 dde:	4501                	li	a0,0
 de0:	74a2                	ld	s1,40(sp)
 de2:	6a42                	ld	s4,16(sp)
 de4:	6aa2                	ld	s5,8(sp)
 de6:	6b02                	ld	s6,0(sp)
 de8:	a03d                	j	e16 <malloc+0xdc>
 dea:	74a2                	ld	s1,40(sp)
 dec:	6a42                	ld	s4,16(sp)
 dee:	6aa2                	ld	s5,8(sp)
 df0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 df2:	fae90fe3          	beq	s2,a4,db0 <malloc+0x76>
        p->s.size -= nunits;
 df6:	4137073b          	subw	a4,a4,s3
 dfa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 dfc:	02071693          	slli	a3,a4,0x20
 e00:	01c6d713          	srli	a4,a3,0x1c
 e04:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 e06:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e0a:	00001717          	auipc	a4,0x1
 e0e:	1ea73b23          	sd	a0,502(a4) # 2000 <freep>
      return (void*)(p + 1);
 e12:	01078513          	addi	a0,a5,16
  }
}
 e16:	70e2                	ld	ra,56(sp)
 e18:	7442                	ld	s0,48(sp)
 e1a:	7902                	ld	s2,32(sp)
 e1c:	69e2                	ld	s3,24(sp)
 e1e:	6121                	addi	sp,sp,64
 e20:	8082                	ret
 e22:	74a2                	ld	s1,40(sp)
 e24:	6a42                	ld	s4,16(sp)
 e26:	6aa2                	ld	s5,8(sp)
 e28:	6b02                	ld	s6,0(sp)
 e2a:	b7f5                	j	e16 <malloc+0xdc>
