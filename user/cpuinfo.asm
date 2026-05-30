
user/_cpuinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <append_str>:
static const char *state_names[PROC_STATE_COUNT] = {
  "UNUSED", "USED", "SLEEPING", "RUNNABLE", "RUNNING", "ZOMBIE"
};

// دوال المساعدة للـ JSON
static void append_str(char *buf, int *pos, const char *s) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    while (*s && *pos < OUTBUF_SZ - 50) { 
   6:	00064783          	lbu	a5,0(a2)
   a:	3cd00693          	li	a3,973
   e:	c385                	beqz	a5,2e <append_str+0x2e>
  10:	419c                	lw	a5,0(a1)
  12:	00f6ce63          	blt	a3,a5,2e <append_str+0x2e>
        buf[(*pos)++] = *s++;
  16:	0605                	addi	a2,a2,1
  18:	0017871b          	addiw	a4,a5,1
  1c:	c198                	sw	a4,0(a1)
  1e:	fff64703          	lbu	a4,-1(a2)
  22:	97aa                	add	a5,a5,a0
  24:	00e78023          	sb	a4,0(a5)
    while (*s && *pos < OUTBUF_SZ - 50) { 
  28:	00064783          	lbu	a5,0(a2)
  2c:	f3f5                	bnez	a5,10 <append_str+0x10>
    }
}
  2e:	6422                	ld	s0,8(sp)
  30:	0141                	addi	sp,sp,16
  32:	8082                	ret

0000000000000034 <append_uint>:

static void append_uint(char *buf, int *pos, uint x) {
    char tmp[16]; 
    int n = 0;
    if (*pos >= OUTBUF_SZ - 20) return; 
  34:	4198                	lw	a4,0(a1)
  36:	3eb00793          	li	a5,1003
  3a:	08e7c363          	blt	a5,a4,c0 <append_uint+0x8c>
static void append_uint(char *buf, int *pos, uint x) {
  3e:	1101                	addi	sp,sp,-32
  40:	ec22                	sd	s0,24(sp)
  42:	1000                	addi	s0,sp,32
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  44:	fe040813          	addi	a6,s0,-32
  48:	87c2                	mv	a5,a6
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
  4a:	46a9                	li	a3,10
  4c:	4325                	li	t1,9
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  4e:	c225                	beqz	a2,ae <append_uint+0x7a>
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
  50:	02d6773b          	remuw	a4,a2,a3
  54:	0307071b          	addiw	a4,a4,48
  58:	00e78023          	sb	a4,0(a5)
  5c:	0006089b          	sext.w	a7,a2
  60:	02d6563b          	divuw	a2,a2,a3
  64:	873e                	mv	a4,a5
  66:	0785                	addi	a5,a5,1
  68:	ff1364e3          	bltu	t1,a7,50 <append_uint+0x1c>
  6c:	4107073b          	subw	a4,a4,a6
  70:	0017079b          	addiw	a5,a4,1
  74:	0007861b          	sext.w	a2,a5
    while (n > 0) buf[(*pos)++] = tmp[--n];
  78:	02c05863          	blez	a2,a8 <append_uint+0x74>
  7c:	fe040713          	addi	a4,s0,-32
  80:	9732                	add	a4,a4,a2
  82:	fff80693          	addi	a3,a6,-1
  86:	96b2                	add	a3,a3,a2
  88:	37fd                	addiw	a5,a5,-1
  8a:	1782                	slli	a5,a5,0x20
  8c:	9381                	srli	a5,a5,0x20
  8e:	8e9d                	sub	a3,a3,a5
  90:	419c                	lw	a5,0(a1)
  92:	0017861b          	addiw	a2,a5,1
  96:	c190                	sw	a2,0(a1)
  98:	97aa                	add	a5,a5,a0
  9a:	fff74603          	lbu	a2,-1(a4)
  9e:	00c78023          	sb	a2,0(a5)
  a2:	177d                	addi	a4,a4,-1
  a4:	fed716e3          	bne	a4,a3,90 <append_uint+0x5c>
}
  a8:	6462                	ld	s0,24(sp)
  aa:	6105                	addi	sp,sp,32
  ac:	8082                	ret
    if (x == 0) { buf[(*pos)++] = '0'; return; }
  ae:	0017079b          	addiw	a5,a4,1
  b2:	c19c                	sw	a5,0(a1)
  b4:	972a                	add	a4,a4,a0
  b6:	03000793          	li	a5,48
  ba:	00f70023          	sb	a5,0(a4)
  be:	b7ed                	j	a8 <append_uint+0x74>
  c0:	8082                	ret

00000000000000c2 <append_int>:

static void append_int(char *buf, int *pos, int x) {
    if (*pos >= OUTBUF_SZ - 20) return;
  c2:	419c                	lw	a5,0(a1)
  c4:	3eb00713          	li	a4,1003
  c8:	02f74963          	blt	a4,a5,fa <append_int+0x38>
static void append_int(char *buf, int *pos, int x) {
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
    if (x < 0) {
  d4:	00064863          	bltz	a2,e4 <append_int+0x22>
        buf[(*pos)++] = '-';
        x = -x;
    }
    append_uint(buf, pos, (uint)x);
  d8:	f5dff0ef          	jal	34 <append_uint>
}
  dc:	60a2                	ld	ra,8(sp)
  de:	6402                	ld	s0,0(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret
        buf[(*pos)++] = '-';
  e4:	0017871b          	addiw	a4,a5,1
  e8:	c198                	sw	a4,0(a1)
  ea:	97aa                	add	a5,a5,a0
  ec:	02d00713          	li	a4,45
  f0:	00e78023          	sb	a4,0(a5)
        x = -x;
  f4:	40c0063b          	negw	a2,a2
  f8:	b7c5                	j	d8 <append_int+0x16>
  fa:	8082                	ret

00000000000000fc <print_cs_event>:
    append_str(buf, &pos, "\"}\n");

    write(1, buf, pos);
}

static void print_cs_event(const struct cs_event *e) {
  fc:	bd010113          	addi	sp,sp,-1072
 100:	42113423          	sd	ra,1064(sp)
 104:	42813023          	sd	s0,1056(sp)
 108:	40913c23          	sd	s1,1048(sp)
 10c:	43010413          	addi	s0,sp,1072
 110:	84aa                	mv	s1,a0
    char buf[OUTBUF_SZ];
    int pos = 0;
 112:	bc042e23          	sw	zero,-1060(s0)
    memset(buf, 0, OUTBUF_SZ);
 116:	40000613          	li	a2,1024
 11a:	4581                	li	a1,0
 11c:	be040513          	addi	a0,s0,-1056
 120:	4be000ef          	jal	5de <memset>

    append_str(buf, &pos, "EV {\"seq\":");
 124:	00001617          	auipc	a2,0x1
 128:	d0c60613          	addi	a2,a2,-756 # e30 <malloc+0x106>
 12c:	bdc40593          	addi	a1,s0,-1060
 130:	be040513          	addi	a0,s0,-1056
 134:	ecdff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, (uint)e->seq);
 138:	4090                	lw	a2,0(s1)
 13a:	bdc40593          	addi	a1,s0,-1060
 13e:	be040513          	addi	a0,s0,-1056
 142:	ef3ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"tick\":");
 146:	00001617          	auipc	a2,0x1
 14a:	cfa60613          	addi	a2,a2,-774 # e40 <malloc+0x116>
 14e:	bdc40593          	addi	a1,s0,-1060
 152:	be040513          	addi	a0,s0,-1056
 156:	eabff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->ticks);
 15a:	4490                	lw	a2,8(s1)
 15c:	bdc40593          	addi	a1,s0,-1060
 160:	be040513          	addi	a0,s0,-1056
 164:	ed1ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"cpu\":");
 168:	00001617          	auipc	a2,0x1
 16c:	ce860613          	addi	a2,a2,-792 # e50 <malloc+0x126>
 170:	bdc40593          	addi	a1,s0,-1060
 174:	be040513          	addi	a0,s0,-1056
 178:	e89ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->cpu);
 17c:	44d0                	lw	a2,12(s1)
 17e:	bdc40593          	addi	a1,s0,-1060
 182:	be040513          	addi	a0,s0,-1056
 186:	f3dff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"pid\":");
 18a:	00001617          	auipc	a2,0x1
 18e:	cce60613          	addi	a2,a2,-818 # e58 <malloc+0x12e>
 192:	bdc40593          	addi	a1,s0,-1060
 196:	be040513          	addi	a0,s0,-1056
 19a:	e67ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->pid);
 19e:	48d0                	lw	a2,20(s1)
 1a0:	bdc40593          	addi	a1,s0,-1060
 1a4:	be040513          	addi	a0,s0,-1056
 1a8:	f1bff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"name\":\"");
 1ac:	00001617          	auipc	a2,0x1
 1b0:	cb460613          	addi	a2,a2,-844 # e60 <malloc+0x136>
 1b4:	bdc40593          	addi	a1,s0,-1060
 1b8:	be040513          	addi	a0,s0,-1056
 1bc:	e45ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
 1c0:	01c48613          	addi	a2,s1,28
 1c4:	bdc40593          	addi	a1,s0,-1060
 1c8:	be040513          	addi	a0,s0,-1056
 1cc:	e35ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\",\"state\":");
 1d0:	00001617          	auipc	a2,0x1
 1d4:	ca060613          	addi	a2,a2,-864 # e70 <malloc+0x146>
 1d8:	bdc40593          	addi	a1,s0,-1060
 1dc:	be040513          	addi	a0,s0,-1056
 1e0:	e21ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->state);
 1e4:	4c90                	lw	a2,24(s1)
 1e6:	bdc40593          	addi	a1,s0,-1060
 1ea:	be040513          	addi	a0,s0,-1056
 1ee:	ed5ff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"type\":\"ON_CPU\"}\n");
 1f2:	00001617          	auipc	a2,0x1
 1f6:	c8e60613          	addi	a2,a2,-882 # e80 <malloc+0x156>
 1fa:	bdc40593          	addi	a1,s0,-1060
 1fe:	be040513          	addi	a0,s0,-1056
 202:	dffff0ef          	jal	0 <append_str>

    write(1, buf, pos);
 206:	bdc42603          	lw	a2,-1060(s0)
 20a:	be040593          	addi	a1,s0,-1056
 20e:	4505                	li	a0,1
 210:	63e000ef          	jal	84e <write>
}
 214:	42813083          	ld	ra,1064(sp)
 218:	42013403          	ld	s0,1056(sp)
 21c:	41813483          	ld	s1,1048(sp)
 220:	43010113          	addi	sp,sp,1072
 224:	8082                	ret

0000000000000226 <print_fs_event>:
static void print_fs_event(const struct fs_event *e) {
 226:	bd010113          	addi	sp,sp,-1072
 22a:	42113423          	sd	ra,1064(sp)
 22e:	42813023          	sd	s0,1056(sp)
 232:	40913c23          	sd	s1,1048(sp)
 236:	43010413          	addi	s0,sp,1072
 23a:	84aa                	mv	s1,a0
    int pos = 0;
 23c:	bc042e23          	sw	zero,-1060(s0)
    memset(buf, 0, OUTBUF_SZ);
 240:	40000613          	li	a2,1024
 244:	4581                	li	a1,0
 246:	be040513          	addi	a0,s0,-1056
 24a:	394000ef          	jal	5de <memset>
    append_str(buf, &pos, "EV {\"seq\":");
 24e:	00001617          	auipc	a2,0x1
 252:	be260613          	addi	a2,a2,-1054 # e30 <malloc+0x106>
 256:	bdc40593          	addi	a1,s0,-1060
 25a:	be040513          	addi	a0,s0,-1056
 25e:	da3ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, (uint)e->seq);
 262:	4090                	lw	a2,0(s1)
 264:	bdc40593          	addi	a1,s0,-1060
 268:	be040513          	addi	a0,s0,-1056
 26c:	dc9ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"tick\":");
 270:	00001617          	auipc	a2,0x1
 274:	bd060613          	addi	a2,a2,-1072 # e40 <malloc+0x116>
 278:	bdc40593          	addi	a1,s0,-1060
 27c:	be040513          	addi	a0,s0,-1056
 280:	d81ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->ticks);
 284:	4490                	lw	a2,8(s1)
 286:	bdc40593          	addi	a1,s0,-1060
 28a:	be040513          	addi	a0,s0,-1056
 28e:	da7ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"type\":\"FS\",\"fs_event_type\":"); 
 292:	00001617          	auipc	a2,0x1
 296:	c0660613          	addi	a2,a2,-1018 # e98 <malloc+0x16e>
 29a:	bdc40593          	addi	a1,s0,-1060
 29e:	be040513          	addi	a0,s0,-1056
 2a2:	d5fff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->type); 
 2a6:	4890                	lw	a2,16(s1)
 2a8:	bdc40593          	addi	a1,s0,-1060
 2ac:	be040513          	addi	a0,s0,-1056
 2b0:	e13ff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"pid\":");
 2b4:	00001617          	auipc	a2,0x1
 2b8:	ba460613          	addi	a2,a2,-1116 # e58 <malloc+0x12e>
 2bc:	bdc40593          	addi	a1,s0,-1060
 2c0:	be040513          	addi	a0,s0,-1056
 2c4:	d3dff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->pid);
 2c8:	44d0                	lw	a2,12(s1)
 2ca:	bdc40593          	addi	a1,s0,-1060
 2ce:	be040513          	addi	a0,s0,-1056
 2d2:	df1ff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"inum\":");
 2d6:	00001617          	auipc	a2,0x1
 2da:	be260613          	addi	a2,a2,-1054 # eb8 <malloc+0x18e>
 2de:	bdc40593          	addi	a1,s0,-1060
 2e2:	be040513          	addi	a0,s0,-1056
 2e6:	d1bff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->inum);
 2ea:	0cc4a603          	lw	a2,204(s1)
 2ee:	bdc40593          	addi	a1,s0,-1060
 2f2:	be040513          	addi	a0,s0,-1056
 2f6:	dcdff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"block\":");
 2fa:	00001617          	auipc	a2,0x1
 2fe:	bce60613          	addi	a2,a2,-1074 # ec8 <malloc+0x19e>
 302:	bdc40593          	addi	a1,s0,-1060
 306:	be040513          	addi	a0,s0,-1056
 30a:	cf7ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->blockno);
 30e:	0c44a603          	lw	a2,196(s1)
 312:	bdc40593          	addi	a1,s0,-1060
 316:	be040513          	addi	a0,s0,-1056
 31a:	da9ff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"size\":");         
 31e:	00001617          	auipc	a2,0x1
 322:	bba60613          	addi	a2,a2,-1094 # ed8 <malloc+0x1ae>
 326:	bdc40593          	addi	a1,s0,-1060
 32a:	be040513          	addi	a0,s0,-1056
 32e:	cd3ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->i_size);
 332:	0e04a603          	lw	a2,224(s1)
 336:	bdc40593          	addi	a1,s0,-1060
 33a:	be040513          	addi	a0,s0,-1056
 33e:	cf7ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"name\":\"");
 342:	00001617          	auipc	a2,0x1
 346:	b1e60613          	addi	a2,a2,-1250 # e60 <malloc+0x136>
 34a:	bdc40593          	addi	a1,s0,-1060
 34e:	be040513          	addi	a0,s0,-1056
 352:	cafff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
 356:	0a448613          	addi	a2,s1,164
 35a:	bdc40593          	addi	a1,s0,-1060
 35e:	be040513          	addi	a0,s0,-1056
 362:	c9fff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"}\n");
 366:	00001617          	auipc	a2,0x1
 36a:	b8260613          	addi	a2,a2,-1150 # ee8 <malloc+0x1be>
 36e:	bdc40593          	addi	a1,s0,-1060
 372:	be040513          	addi	a0,s0,-1056
 376:	c8bff0ef          	jal	0 <append_str>
    write(1, buf, pos);
 37a:	bdc42603          	lw	a2,-1060(s0)
 37e:	be040593          	addi	a1,s0,-1056
 382:	4505                	li	a0,1
 384:	4ca000ef          	jal	84e <write>
}
 388:	42813083          	ld	ra,1064(sp)
 38c:	42013403          	ld	s0,1056(sp)
 390:	41813483          	ld	s1,1048(sp)
 394:	43010113          	addi	sp,sp,1072
 398:	8082                	ret

000000000000039a <main>:

int
main(void)
{
 39a:	711d                	addi	sp,sp,-96
 39c:	ec86                	sd	ra,88(sp)
 39e:	e8a2                	sd	s0,80(sp)
 3a0:	e4a6                	sd	s1,72(sp)
 3a2:	fc4e                	sd	s3,56(sp)
 3a4:	1080                	addi	s0,sp,96
    int n;

    memset(cpus, 0, sizeof(cpus));
 3a6:	00002497          	auipc	s1,0x2
 3aa:	c6a48493          	addi	s1,s1,-918 # 2010 <cpus>
 3ae:	14000613          	li	a2,320
 3b2:	4581                	li	a1,0
 3b4:	8526                	mv	a0,s1
 3b6:	228000ef          	jal	5de <memset>
    memset(&stats, 0, sizeof(stats));
 3ba:	07000613          	li	a2,112
 3be:	4581                	li	a1,0
 3c0:	00002517          	auipc	a0,0x2
 3c4:	d9050513          	addi	a0,a0,-624 # 2150 <stats>
 3c8:	216000ef          	jal	5de <memset>

    n = getcpuinfo(cpus, NCPU);
 3cc:	45a1                	li	a1,8
 3ce:	8526                	mv	a0,s1
 3d0:	418000ef          	jal	7e8 <getcpuinfo>
    if (n < 0 || getprocstats(&stats) < 0) {
 3d4:	00054b63          	bltz	a0,3ea <main+0x50>
 3d8:	89aa                	mv	s3,a0
 3da:	00002517          	auipc	a0,0x2
 3de:	d7650513          	addi	a0,a0,-650 # 2150 <stats>
 3e2:	428000ef          	jal	80a <getprocstats>
 3e6:	02055263          	bgez	a0,40a <main+0x70>
 3ea:	e0ca                	sd	s2,64(sp)
 3ec:	f852                	sd	s4,48(sp)
 3ee:	f456                	sd	s5,40(sp)
 3f0:	f05a                	sd	s6,32(sp)
 3f2:	ec5e                	sd	s7,24(sp)
 3f4:	e862                	sd	s8,16(sp)
 3f6:	e466                	sd	s9,8(sp)
        printf("Error fetching system info\n");
 3f8:	00001517          	auipc	a0,0x1
 3fc:	b0050513          	addi	a0,a0,-1280 # ef8 <malloc+0x1ce>
 400:	077000ef          	jal	c76 <printf>
        exit(1);
 404:	4505                	li	a0,1
 406:	428000ef          	jal	82e <exit>
 40a:	e0ca                	sd	s2,64(sp)
 40c:	f852                	sd	s4,48(sp)
 40e:	f456                	sd	s5,40(sp)
 410:	f05a                	sd	s6,32(sp)
 412:	ec5e                	sd	s7,24(sp)
 414:	e862                	sd	s8,16(sp)
 416:	e466                	sd	s9,8(sp)
    }

    // 1. طباعة حالة المعالجات الحالية
    printf("CPU {\"timestamp\":\"now\",\"system\":{");
 418:	00001517          	auipc	a0,0x1
 41c:	b0050513          	addi	a0,a0,-1280 # f18 <malloc+0x1ee>
 420:	057000ef          	jal	c76 <printf>
    printf("\"total_created\":%lu,\"total_exited\":%lu,", stats.total_created, stats.total_exited);
 424:	00002497          	auipc	s1,0x2
 428:	bec48493          	addi	s1,s1,-1044 # 2010 <cpus>
 42c:	1a84b603          	ld	a2,424(s1)
 430:	1a04b583          	ld	a1,416(s1)
 434:	00001517          	auipc	a0,0x1
 438:	b0c50513          	addi	a0,a0,-1268 # f40 <malloc+0x216>
 43c:	03b000ef          	jal	c76 <printf>
    printf("\"ever_running\":%lu,\"ever_sleeping\":%lu,\"ever_zombie\":%lu},", 
 440:	1984b683          	ld	a3,408(s1)
 444:	1804b603          	ld	a2,384(s1)
 448:	1904b583          	ld	a1,400(s1)
 44c:	00001517          	auipc	a0,0x1
 450:	b1c50513          	addi	a0,a0,-1252 # f68 <malloc+0x23e>
 454:	023000ef          	jal	c76 <printf>
            stats.unique_count[4], stats.unique_count[2], stats.unique_count[5]);

    printf("\"cpus\":[");
 458:	00001517          	auipc	a0,0x1
 45c:	b5050513          	addi	a0,a0,-1200 # fa8 <malloc+0x27e>
 460:	017000ef          	jal	c76 <printf>
    for (int i = 0; i < n; i++) {
 464:	07305663          	blez	s3,4d0 <main+0x136>
 468:	8926                	mv	s2,s1
 46a:	4481                	li	s1,0
        int state_idx = cpus[i].current_state;
        const char *st_name = "UNK";
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 46c:	4b95                	li	s7,5
        const char *st_name = "UNK";
 46e:	00001b17          	auipc	s6,0x1
 472:	a82b0b13          	addi	s6,s6,-1406 # ef0 <malloc+0x1c6>
            st_name = state_names[state_idx];
 476:	00001c17          	auipc	s8,0x1
 47a:	bf2c0c13          	addi	s8,s8,-1038 # 1068 <state_names>
        }

        printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"busy_percent\":%d}",
 47e:	00001a97          	auipc	s5,0x1
 482:	b3aa8a93          	addi	s5,s5,-1222 # fb8 <malloc+0x28e>
               cpus[i].cpu, cpus[i].active, cpus[i].current_pid, st_name, cpus[i].busy_percent);
        
        if (i < n - 1) printf(",");
 486:	fff98a1b          	addiw	s4,s3,-1
 48a:	00001c97          	auipc	s9,0x1
 48e:	b86c8c93          	addi	s9,s9,-1146 # 1010 <malloc+0x2e6>
 492:	a839                	j	4b0 <main+0x116>
        printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"busy_percent\":%d}",
 494:	519c                	lw	a5,32(a1)
 496:	4594                	lw	a3,8(a1)
 498:	41d0                	lw	a2,4(a1)
 49a:	418c                	lw	a1,0(a1)
 49c:	8556                	mv	a0,s5
 49e:	7d8000ef          	jal	c76 <printf>
        if (i < n - 1) printf(",");
 4a2:	0344c363          	blt	s1,s4,4c8 <main+0x12e>
    for (int i = 0; i < n; i++) {
 4a6:	2485                	addiw	s1,s1,1
 4a8:	02890913          	addi	s2,s2,40
 4ac:	02998263          	beq	s3,s1,4d0 <main+0x136>
        int state_idx = cpus[i].current_state;
 4b0:	85ca                	mv	a1,s2
 4b2:	00c92783          	lw	a5,12(s2)
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 4b6:	0007869b          	sext.w	a3,a5
        const char *st_name = "UNK";
 4ba:	875a                	mv	a4,s6
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 4bc:	fcdbece3          	bltu	s7,a3,494 <main+0xfa>
            st_name = state_names[state_idx];
 4c0:	078e                	slli	a5,a5,0x3
 4c2:	97e2                	add	a5,a5,s8
 4c4:	6398                	ld	a4,0(a5)
 4c6:	b7f9                	j	494 <main+0xfa>
        if (i < n - 1) printf(",");
 4c8:	8566                	mv	a0,s9
 4ca:	7ac000ef          	jal	c76 <printf>
 4ce:	bfe1                	j	4a6 <main+0x10c>
    }
    printf("]}\n");
 4d0:	00001517          	auipc	a0,0x1
 4d4:	b4850513          	addi	a0,a0,-1208 # 1018 <malloc+0x2ee>
 4d8:	79e000ef          	jal	c76 <printf>

   // 2. قراءة أحداث المعالج المتوفرة في البفر حالياً
    int n_cs = csread(cs_ev, 32);
 4dc:	02000593          	li	a1,32
 4e0:	00002517          	auipc	a0,0x2
 4e4:	ce050513          	addi	a0,a0,-800 # 21c0 <cs_ev>
 4e8:	3e6000ef          	jal	8ce <csread>
    for (int i = 0; i < n_cs; i++) { // الدوران فقط حتى n_cs الحقيقية
 4ec:	02a05963          	blez	a0,51e <main+0x184>
 4f0:	00002497          	auipc	s1,0x2
 4f4:	cd048493          	addi	s1,s1,-816 # 21c0 <cs_ev>
 4f8:	03000793          	li	a5,48
 4fc:	02f50533          	mul	a0,a0,a5
 500:	00950933          	add	s2,a0,s1
        if (cs_ev[i].type == 1) 
 504:	4985                	li	s3,1
 506:	a029                	j	510 <main+0x176>
    for (int i = 0; i < n_cs; i++) { // الدوران فقط حتى n_cs الحقيقية
 508:	03048493          	addi	s1,s1,48
 50c:	01248963          	beq	s1,s2,51e <main+0x184>
        if (cs_ev[i].type == 1) 
 510:	489c                	lw	a5,16(s1)
 512:	ff379be3          	bne	a5,s3,508 <main+0x16e>
            print_cs_event(&cs_ev[i]);
 516:	8526                	mv	a0,s1
 518:	be5ff0ef          	jal	fc <print_cs_event>
 51c:	b7f5                	j	508 <main+0x16e>
    }

    
// 3. قراءة أحداث نظام الملفات المتوفرة في البفر حالياً
    int n_fs = fsread(fs_ev, 32);
 51e:	02000593          	li	a1,32
 522:	00002517          	auipc	a0,0x2
 526:	29e50513          	addi	a0,a0,670 # 27c0 <fs_ev>
 52a:	3ac000ef          	jal	8d6 <fsread>
    for (int i = 0; i < n_fs; i++) { 
 52e:	02a05463          	blez	a0,556 <main+0x1bc>
 532:	00002497          	auipc	s1,0x2
 536:	28e48493          	addi	s1,s1,654 # 27c0 <fs_ev>
 53a:	0526                	slli	a0,a0,0x9
 53c:	00950933          	add	s2,a0,s1
 540:	a029                	j	54a <main+0x1b0>
 542:	20048493          	addi	s1,s1,512
 546:	01248863          	beq	s1,s2,556 <main+0x1bc>
        // إذا كان الـ seq مصفراً، فهذا مخلفات بافر، لا تطبعه
        if (fs_ev[i].seq != 0) {
 54a:	609c                	ld	a5,0(s1)
 54c:	dbfd                	beqz	a5,542 <main+0x1a8>
            print_fs_event(&fs_ev[i]);
 54e:	8526                	mv	a0,s1
 550:	cd7ff0ef          	jal	226 <print_fs_event>
 554:	b7fd                	j	542 <main+0x1a8>
        }
    }
    // الخروج وإنهاء البرنامج فوراً دون الدخول في حلقة لانهائية
    exit(0); 
 556:	4501                	li	a0,0
 558:	2d6000ef          	jal	82e <exit>

000000000000055c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 55c:	1141                	addi	sp,sp,-16
 55e:	e406                	sd	ra,8(sp)
 560:	e022                	sd	s0,0(sp)
 562:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 564:	e37ff0ef          	jal	39a <main>
  exit(r);
 568:	2c6000ef          	jal	82e <exit>

000000000000056c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 56c:	1141                	addi	sp,sp,-16
 56e:	e422                	sd	s0,8(sp)
 570:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 572:	87aa                	mv	a5,a0
 574:	0585                	addi	a1,a1,1
 576:	0785                	addi	a5,a5,1
 578:	fff5c703          	lbu	a4,-1(a1)
 57c:	fee78fa3          	sb	a4,-1(a5)
 580:	fb75                	bnez	a4,574 <strcpy+0x8>
    ;
  return os;
}
 582:	6422                	ld	s0,8(sp)
 584:	0141                	addi	sp,sp,16
 586:	8082                	ret

0000000000000588 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 588:	1141                	addi	sp,sp,-16
 58a:	e422                	sd	s0,8(sp)
 58c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 58e:	00054783          	lbu	a5,0(a0)
 592:	cb91                	beqz	a5,5a6 <strcmp+0x1e>
 594:	0005c703          	lbu	a4,0(a1)
 598:	00f71763          	bne	a4,a5,5a6 <strcmp+0x1e>
    p++, q++;
 59c:	0505                	addi	a0,a0,1
 59e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 5a0:	00054783          	lbu	a5,0(a0)
 5a4:	fbe5                	bnez	a5,594 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 5a6:	0005c503          	lbu	a0,0(a1)
}
 5aa:	40a7853b          	subw	a0,a5,a0
 5ae:	6422                	ld	s0,8(sp)
 5b0:	0141                	addi	sp,sp,16
 5b2:	8082                	ret

00000000000005b4 <strlen>:

uint
strlen(const char *s)
{
 5b4:	1141                	addi	sp,sp,-16
 5b6:	e422                	sd	s0,8(sp)
 5b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 5ba:	00054783          	lbu	a5,0(a0)
 5be:	cf91                	beqz	a5,5da <strlen+0x26>
 5c0:	0505                	addi	a0,a0,1
 5c2:	87aa                	mv	a5,a0
 5c4:	86be                	mv	a3,a5
 5c6:	0785                	addi	a5,a5,1
 5c8:	fff7c703          	lbu	a4,-1(a5)
 5cc:	ff65                	bnez	a4,5c4 <strlen+0x10>
 5ce:	40a6853b          	subw	a0,a3,a0
 5d2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 5d4:	6422                	ld	s0,8(sp)
 5d6:	0141                	addi	sp,sp,16
 5d8:	8082                	ret
  for(n = 0; s[n]; n++)
 5da:	4501                	li	a0,0
 5dc:	bfe5                	j	5d4 <strlen+0x20>

00000000000005de <memset>:

void*
memset(void *dst, int c, uint n)
{
 5de:	1141                	addi	sp,sp,-16
 5e0:	e422                	sd	s0,8(sp)
 5e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 5e4:	ca19                	beqz	a2,5fa <memset+0x1c>
 5e6:	87aa                	mv	a5,a0
 5e8:	1602                	slli	a2,a2,0x20
 5ea:	9201                	srli	a2,a2,0x20
 5ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 5f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 5f4:	0785                	addi	a5,a5,1
 5f6:	fee79de3          	bne	a5,a4,5f0 <memset+0x12>
  }
  return dst;
}
 5fa:	6422                	ld	s0,8(sp)
 5fc:	0141                	addi	sp,sp,16
 5fe:	8082                	ret

0000000000000600 <strchr>:

char*
strchr(const char *s, char c)
{
 600:	1141                	addi	sp,sp,-16
 602:	e422                	sd	s0,8(sp)
 604:	0800                	addi	s0,sp,16
  for(; *s; s++)
 606:	00054783          	lbu	a5,0(a0)
 60a:	cb99                	beqz	a5,620 <strchr+0x20>
    if(*s == c)
 60c:	00f58763          	beq	a1,a5,61a <strchr+0x1a>
  for(; *s; s++)
 610:	0505                	addi	a0,a0,1
 612:	00054783          	lbu	a5,0(a0)
 616:	fbfd                	bnez	a5,60c <strchr+0xc>
      return (char*)s;
  return 0;
 618:	4501                	li	a0,0
}
 61a:	6422                	ld	s0,8(sp)
 61c:	0141                	addi	sp,sp,16
 61e:	8082                	ret
  return 0;
 620:	4501                	li	a0,0
 622:	bfe5                	j	61a <strchr+0x1a>

0000000000000624 <gets>:

char*
gets(char *buf, int max)
{
 624:	711d                	addi	sp,sp,-96
 626:	ec86                	sd	ra,88(sp)
 628:	e8a2                	sd	s0,80(sp)
 62a:	e4a6                	sd	s1,72(sp)
 62c:	e0ca                	sd	s2,64(sp)
 62e:	fc4e                	sd	s3,56(sp)
 630:	f852                	sd	s4,48(sp)
 632:	f456                	sd	s5,40(sp)
 634:	f05a                	sd	s6,32(sp)
 636:	ec5e                	sd	s7,24(sp)
 638:	1080                	addi	s0,sp,96
 63a:	8baa                	mv	s7,a0
 63c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 63e:	892a                	mv	s2,a0
 640:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 642:	4aa9                	li	s5,10
 644:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 646:	89a6                	mv	s3,s1
 648:	2485                	addiw	s1,s1,1
 64a:	0344d663          	bge	s1,s4,676 <gets+0x52>
    cc = read(0, &c, 1);
 64e:	4605                	li	a2,1
 650:	faf40593          	addi	a1,s0,-81
 654:	4501                	li	a0,0
 656:	1f0000ef          	jal	846 <read>
    if(cc < 1)
 65a:	00a05e63          	blez	a0,676 <gets+0x52>
    buf[i++] = c;
 65e:	faf44783          	lbu	a5,-81(s0)
 662:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 666:	01578763          	beq	a5,s5,674 <gets+0x50>
 66a:	0905                	addi	s2,s2,1
 66c:	fd679de3          	bne	a5,s6,646 <gets+0x22>
    buf[i++] = c;
 670:	89a6                	mv	s3,s1
 672:	a011                	j	676 <gets+0x52>
 674:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 676:	99de                	add	s3,s3,s7
 678:	00098023          	sb	zero,0(s3)
  return buf;
}
 67c:	855e                	mv	a0,s7
 67e:	60e6                	ld	ra,88(sp)
 680:	6446                	ld	s0,80(sp)
 682:	64a6                	ld	s1,72(sp)
 684:	6906                	ld	s2,64(sp)
 686:	79e2                	ld	s3,56(sp)
 688:	7a42                	ld	s4,48(sp)
 68a:	7aa2                	ld	s5,40(sp)
 68c:	7b02                	ld	s6,32(sp)
 68e:	6be2                	ld	s7,24(sp)
 690:	6125                	addi	sp,sp,96
 692:	8082                	ret

0000000000000694 <stat>:

int
stat(const char *n, struct stat *st)
{
 694:	1101                	addi	sp,sp,-32
 696:	ec06                	sd	ra,24(sp)
 698:	e822                	sd	s0,16(sp)
 69a:	e04a                	sd	s2,0(sp)
 69c:	1000                	addi	s0,sp,32
 69e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6a0:	4581                	li	a1,0
 6a2:	1cc000ef          	jal	86e <open>
  if(fd < 0)
 6a6:	02054263          	bltz	a0,6ca <stat+0x36>
 6aa:	e426                	sd	s1,8(sp)
 6ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 6ae:	85ca                	mv	a1,s2
 6b0:	1d6000ef          	jal	886 <fstat>
 6b4:	892a                	mv	s2,a0
  close(fd);
 6b6:	8526                	mv	a0,s1
 6b8:	19e000ef          	jal	856 <close>
  return r;
 6bc:	64a2                	ld	s1,8(sp)
}
 6be:	854a                	mv	a0,s2
 6c0:	60e2                	ld	ra,24(sp)
 6c2:	6442                	ld	s0,16(sp)
 6c4:	6902                	ld	s2,0(sp)
 6c6:	6105                	addi	sp,sp,32
 6c8:	8082                	ret
    return -1;
 6ca:	597d                	li	s2,-1
 6cc:	bfcd                	j	6be <stat+0x2a>

00000000000006ce <atoi>:

int
atoi(const char *s)
{
 6ce:	1141                	addi	sp,sp,-16
 6d0:	e422                	sd	s0,8(sp)
 6d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6d4:	00054683          	lbu	a3,0(a0)
 6d8:	fd06879b          	addiw	a5,a3,-48
 6dc:	0ff7f793          	zext.b	a5,a5
 6e0:	4625                	li	a2,9
 6e2:	02f66863          	bltu	a2,a5,712 <atoi+0x44>
 6e6:	872a                	mv	a4,a0
  n = 0;
 6e8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 6ea:	0705                	addi	a4,a4,1
 6ec:	0025179b          	slliw	a5,a0,0x2
 6f0:	9fa9                	addw	a5,a5,a0
 6f2:	0017979b          	slliw	a5,a5,0x1
 6f6:	9fb5                	addw	a5,a5,a3
 6f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 6fc:	00074683          	lbu	a3,0(a4)
 700:	fd06879b          	addiw	a5,a3,-48
 704:	0ff7f793          	zext.b	a5,a5
 708:	fef671e3          	bgeu	a2,a5,6ea <atoi+0x1c>
  return n;
}
 70c:	6422                	ld	s0,8(sp)
 70e:	0141                	addi	sp,sp,16
 710:	8082                	ret
  n = 0;
 712:	4501                	li	a0,0
 714:	bfe5                	j	70c <atoi+0x3e>

0000000000000716 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 716:	1141                	addi	sp,sp,-16
 718:	e422                	sd	s0,8(sp)
 71a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 71c:	02b57463          	bgeu	a0,a1,744 <memmove+0x2e>
    while(n-- > 0)
 720:	00c05f63          	blez	a2,73e <memmove+0x28>
 724:	1602                	slli	a2,a2,0x20
 726:	9201                	srli	a2,a2,0x20
 728:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 72c:	872a                	mv	a4,a0
      *dst++ = *src++;
 72e:	0585                	addi	a1,a1,1
 730:	0705                	addi	a4,a4,1
 732:	fff5c683          	lbu	a3,-1(a1)
 736:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 73a:	fef71ae3          	bne	a4,a5,72e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 73e:	6422                	ld	s0,8(sp)
 740:	0141                	addi	sp,sp,16
 742:	8082                	ret
    dst += n;
 744:	00c50733          	add	a4,a0,a2
    src += n;
 748:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 74a:	fec05ae3          	blez	a2,73e <memmove+0x28>
 74e:	fff6079b          	addiw	a5,a2,-1
 752:	1782                	slli	a5,a5,0x20
 754:	9381                	srli	a5,a5,0x20
 756:	fff7c793          	not	a5,a5
 75a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 75c:	15fd                	addi	a1,a1,-1
 75e:	177d                	addi	a4,a4,-1
 760:	0005c683          	lbu	a3,0(a1)
 764:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 768:	fee79ae3          	bne	a5,a4,75c <memmove+0x46>
 76c:	bfc9                	j	73e <memmove+0x28>

000000000000076e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 76e:	1141                	addi	sp,sp,-16
 770:	e422                	sd	s0,8(sp)
 772:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 774:	ca05                	beqz	a2,7a4 <memcmp+0x36>
 776:	fff6069b          	addiw	a3,a2,-1
 77a:	1682                	slli	a3,a3,0x20
 77c:	9281                	srli	a3,a3,0x20
 77e:	0685                	addi	a3,a3,1
 780:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 782:	00054783          	lbu	a5,0(a0)
 786:	0005c703          	lbu	a4,0(a1)
 78a:	00e79863          	bne	a5,a4,79a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 78e:	0505                	addi	a0,a0,1
    p2++;
 790:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 792:	fed518e3          	bne	a0,a3,782 <memcmp+0x14>
  }
  return 0;
 796:	4501                	li	a0,0
 798:	a019                	j	79e <memcmp+0x30>
      return *p1 - *p2;
 79a:	40e7853b          	subw	a0,a5,a4
}
 79e:	6422                	ld	s0,8(sp)
 7a0:	0141                	addi	sp,sp,16
 7a2:	8082                	ret
  return 0;
 7a4:	4501                	li	a0,0
 7a6:	bfe5                	j	79e <memcmp+0x30>

00000000000007a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 7a8:	1141                	addi	sp,sp,-16
 7aa:	e406                	sd	ra,8(sp)
 7ac:	e022                	sd	s0,0(sp)
 7ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 7b0:	f67ff0ef          	jal	716 <memmove>
}
 7b4:	60a2                	ld	ra,8(sp)
 7b6:	6402                	ld	s0,0(sp)
 7b8:	0141                	addi	sp,sp,16
 7ba:	8082                	ret

00000000000007bc <sbrk>:

char *
sbrk(int n) {
 7bc:	1141                	addi	sp,sp,-16
 7be:	e406                	sd	ra,8(sp)
 7c0:	e022                	sd	s0,0(sp)
 7c2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 7c4:	4585                	li	a1,1
 7c6:	0f0000ef          	jal	8b6 <sys_sbrk>
}
 7ca:	60a2                	ld	ra,8(sp)
 7cc:	6402                	ld	s0,0(sp)
 7ce:	0141                	addi	sp,sp,16
 7d0:	8082                	ret

00000000000007d2 <sbrklazy>:

char *
sbrklazy(int n) {
 7d2:	1141                	addi	sp,sp,-16
 7d4:	e406                	sd	ra,8(sp)
 7d6:	e022                	sd	s0,0(sp)
 7d8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 7da:	4589                	li	a1,2
 7dc:	0da000ef          	jal	8b6 <sys_sbrk>
}
 7e0:	60a2                	ld	ra,8(sp)
 7e2:	6402                	ld	s0,0(sp)
 7e4:	0141                	addi	sp,sp,16
 7e6:	8082                	ret

00000000000007e8 <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
 7e8:	1141                	addi	sp,sp,-16
 7ea:	e406                	sd	ra,8(sp)
 7ec:	e022                	sd	s0,0(sp)
 7ee:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
 7f0:	0025961b          	slliw	a2,a1,0x2
 7f4:	9e2d                	addw	a2,a2,a1
 7f6:	0036161b          	slliw	a2,a2,0x3
 7fa:	4581                	li	a1,0
 7fc:	de3ff0ef          	jal	5de <memset>
  return 0;
}
 800:	4501                	li	a0,0
 802:	60a2                	ld	ra,8(sp)
 804:	6402                	ld	s0,0(sp)
 806:	0141                	addi	sp,sp,16
 808:	8082                	ret

000000000000080a <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
 80a:	1141                	addi	sp,sp,-16
 80c:	e406                	sd	ra,8(sp)
 80e:	e022                	sd	s0,0(sp)
 810:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
 812:	07000613          	li	a2,112
 816:	4581                	li	a1,0
 818:	dc7ff0ef          	jal	5de <memset>
  return 0;
}
 81c:	4501                	li	a0,0
 81e:	60a2                	ld	ra,8(sp)
 820:	6402                	ld	s0,0(sp)
 822:	0141                	addi	sp,sp,16
 824:	8082                	ret

0000000000000826 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 826:	4885                	li	a7,1
 ecall
 828:	00000073          	ecall
 ret
 82c:	8082                	ret

000000000000082e <exit>:
.global exit
exit:
 li a7, SYS_exit
 82e:	4889                	li	a7,2
 ecall
 830:	00000073          	ecall
 ret
 834:	8082                	ret

0000000000000836 <wait>:
.global wait
wait:
 li a7, SYS_wait
 836:	488d                	li	a7,3
 ecall
 838:	00000073          	ecall
 ret
 83c:	8082                	ret

000000000000083e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 83e:	4891                	li	a7,4
 ecall
 840:	00000073          	ecall
 ret
 844:	8082                	ret

0000000000000846 <read>:
.global read
read:
 li a7, SYS_read
 846:	4895                	li	a7,5
 ecall
 848:	00000073          	ecall
 ret
 84c:	8082                	ret

000000000000084e <write>:
.global write
write:
 li a7, SYS_write
 84e:	48c1                	li	a7,16
 ecall
 850:	00000073          	ecall
 ret
 854:	8082                	ret

0000000000000856 <close>:
.global close
close:
 li a7, SYS_close
 856:	48d5                	li	a7,21
 ecall
 858:	00000073          	ecall
 ret
 85c:	8082                	ret

000000000000085e <kill>:
.global kill
kill:
 li a7, SYS_kill
 85e:	4899                	li	a7,6
 ecall
 860:	00000073          	ecall
 ret
 864:	8082                	ret

0000000000000866 <exec>:
.global exec
exec:
 li a7, SYS_exec
 866:	489d                	li	a7,7
 ecall
 868:	00000073          	ecall
 ret
 86c:	8082                	ret

000000000000086e <open>:
.global open
open:
 li a7, SYS_open
 86e:	48bd                	li	a7,15
 ecall
 870:	00000073          	ecall
 ret
 874:	8082                	ret

0000000000000876 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 876:	48c5                	li	a7,17
 ecall
 878:	00000073          	ecall
 ret
 87c:	8082                	ret

000000000000087e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 87e:	48c9                	li	a7,18
 ecall
 880:	00000073          	ecall
 ret
 884:	8082                	ret

0000000000000886 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 886:	48a1                	li	a7,8
 ecall
 888:	00000073          	ecall
 ret
 88c:	8082                	ret

000000000000088e <link>:
.global link
link:
 li a7, SYS_link
 88e:	48cd                	li	a7,19
 ecall
 890:	00000073          	ecall
 ret
 894:	8082                	ret

0000000000000896 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 896:	48d1                	li	a7,20
 ecall
 898:	00000073          	ecall
 ret
 89c:	8082                	ret

000000000000089e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 89e:	48a5                	li	a7,9
 ecall
 8a0:	00000073          	ecall
 ret
 8a4:	8082                	ret

00000000000008a6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 8a6:	48a9                	li	a7,10
 ecall
 8a8:	00000073          	ecall
 ret
 8ac:	8082                	ret

00000000000008ae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 8ae:	48ad                	li	a7,11
 ecall
 8b0:	00000073          	ecall
 ret
 8b4:	8082                	ret

00000000000008b6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 8b6:	48b1                	li	a7,12
 ecall
 8b8:	00000073          	ecall
 ret
 8bc:	8082                	ret

00000000000008be <pause>:
.global pause
pause:
 li a7, SYS_pause
 8be:	48b5                	li	a7,13
 ecall
 8c0:	00000073          	ecall
 ret
 8c4:	8082                	ret

00000000000008c6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 8c6:	48b9                	li	a7,14
 ecall
 8c8:	00000073          	ecall
 ret
 8cc:	8082                	ret

00000000000008ce <csread>:
.global csread
csread:
 li a7, SYS_csread
 8ce:	48d9                	li	a7,22
 ecall
 8d0:	00000073          	ecall
 ret
 8d4:	8082                	ret

00000000000008d6 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 8d6:	48dd                	li	a7,23
 ecall
 8d8:	00000073          	ecall
 ret
 8dc:	8082                	ret

00000000000008de <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 8de:	48e1                	li	a7,24
 ecall
 8e0:	00000073          	ecall
 ret
 8e4:	8082                	ret

00000000000008e6 <memread>:
.global memread
memread:
 li a7, SYS_memread
 8e6:	48e5                	li	a7,25
 ecall
 8e8:	00000073          	ecall
 ret
 8ec:	8082                	ret

00000000000008ee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 8ee:	1101                	addi	sp,sp,-32
 8f0:	ec06                	sd	ra,24(sp)
 8f2:	e822                	sd	s0,16(sp)
 8f4:	1000                	addi	s0,sp,32
 8f6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 8fa:	4605                	li	a2,1
 8fc:	fef40593          	addi	a1,s0,-17
 900:	f4fff0ef          	jal	84e <write>
}
 904:	60e2                	ld	ra,24(sp)
 906:	6442                	ld	s0,16(sp)
 908:	6105                	addi	sp,sp,32
 90a:	8082                	ret

000000000000090c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 90c:	715d                	addi	sp,sp,-80
 90e:	e486                	sd	ra,72(sp)
 910:	e0a2                	sd	s0,64(sp)
 912:	f84a                	sd	s2,48(sp)
 914:	0880                	addi	s0,sp,80
 916:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 918:	c299                	beqz	a3,91e <printint+0x12>
 91a:	0805c363          	bltz	a1,9a0 <printint+0x94>
  neg = 0;
 91e:	4881                	li	a7,0
 920:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 924:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 926:	00000517          	auipc	a0,0x0
 92a:	77250513          	addi	a0,a0,1906 # 1098 <digits>
 92e:	883e                	mv	a6,a5
 930:	2785                	addiw	a5,a5,1
 932:	02c5f733          	remu	a4,a1,a2
 936:	972a                	add	a4,a4,a0
 938:	00074703          	lbu	a4,0(a4)
 93c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 940:	872e                	mv	a4,a1
 942:	02c5d5b3          	divu	a1,a1,a2
 946:	0685                	addi	a3,a3,1
 948:	fec773e3          	bgeu	a4,a2,92e <printint+0x22>
  if(neg)
 94c:	00088b63          	beqz	a7,962 <printint+0x56>
    buf[i++] = '-';
 950:	fd078793          	addi	a5,a5,-48
 954:	97a2                	add	a5,a5,s0
 956:	02d00713          	li	a4,45
 95a:	fee78423          	sb	a4,-24(a5)
 95e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 962:	02f05a63          	blez	a5,996 <printint+0x8a>
 966:	fc26                	sd	s1,56(sp)
 968:	f44e                	sd	s3,40(sp)
 96a:	fb840713          	addi	a4,s0,-72
 96e:	00f704b3          	add	s1,a4,a5
 972:	fff70993          	addi	s3,a4,-1
 976:	99be                	add	s3,s3,a5
 978:	37fd                	addiw	a5,a5,-1
 97a:	1782                	slli	a5,a5,0x20
 97c:	9381                	srli	a5,a5,0x20
 97e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 982:	fff4c583          	lbu	a1,-1(s1)
 986:	854a                	mv	a0,s2
 988:	f67ff0ef          	jal	8ee <putc>
  while(--i >= 0)
 98c:	14fd                	addi	s1,s1,-1
 98e:	ff349ae3          	bne	s1,s3,982 <printint+0x76>
 992:	74e2                	ld	s1,56(sp)
 994:	79a2                	ld	s3,40(sp)
}
 996:	60a6                	ld	ra,72(sp)
 998:	6406                	ld	s0,64(sp)
 99a:	7942                	ld	s2,48(sp)
 99c:	6161                	addi	sp,sp,80
 99e:	8082                	ret
    x = -xx;
 9a0:	40b005b3          	neg	a1,a1
    neg = 1;
 9a4:	4885                	li	a7,1
    x = -xx;
 9a6:	bfad                	j	920 <printint+0x14>

00000000000009a8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 9a8:	711d                	addi	sp,sp,-96
 9aa:	ec86                	sd	ra,88(sp)
 9ac:	e8a2                	sd	s0,80(sp)
 9ae:	e0ca                	sd	s2,64(sp)
 9b0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 9b2:	0005c903          	lbu	s2,0(a1)
 9b6:	28090663          	beqz	s2,c42 <vprintf+0x29a>
 9ba:	e4a6                	sd	s1,72(sp)
 9bc:	fc4e                	sd	s3,56(sp)
 9be:	f852                	sd	s4,48(sp)
 9c0:	f456                	sd	s5,40(sp)
 9c2:	f05a                	sd	s6,32(sp)
 9c4:	ec5e                	sd	s7,24(sp)
 9c6:	e862                	sd	s8,16(sp)
 9c8:	e466                	sd	s9,8(sp)
 9ca:	8b2a                	mv	s6,a0
 9cc:	8a2e                	mv	s4,a1
 9ce:	8bb2                	mv	s7,a2
  state = 0;
 9d0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 9d2:	4481                	li	s1,0
 9d4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 9d6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 9da:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 9de:	06c00c93          	li	s9,108
 9e2:	a005                	j	a02 <vprintf+0x5a>
        putc(fd, c0);
 9e4:	85ca                	mv	a1,s2
 9e6:	855a                	mv	a0,s6
 9e8:	f07ff0ef          	jal	8ee <putc>
 9ec:	a019                	j	9f2 <vprintf+0x4a>
    } else if(state == '%'){
 9ee:	03598263          	beq	s3,s5,a12 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 9f2:	2485                	addiw	s1,s1,1
 9f4:	8726                	mv	a4,s1
 9f6:	009a07b3          	add	a5,s4,s1
 9fa:	0007c903          	lbu	s2,0(a5)
 9fe:	22090a63          	beqz	s2,c32 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 a02:	0009079b          	sext.w	a5,s2
    if(state == 0){
 a06:	fe0994e3          	bnez	s3,9ee <vprintf+0x46>
      if(c0 == '%'){
 a0a:	fd579de3          	bne	a5,s5,9e4 <vprintf+0x3c>
        state = '%';
 a0e:	89be                	mv	s3,a5
 a10:	b7cd                	j	9f2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 a12:	00ea06b3          	add	a3,s4,a4
 a16:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 a1a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 a1c:	c681                	beqz	a3,a24 <vprintf+0x7c>
 a1e:	9752                	add	a4,a4,s4
 a20:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 a24:	05878363          	beq	a5,s8,a6a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 a28:	05978d63          	beq	a5,s9,a82 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 a2c:	07500713          	li	a4,117
 a30:	0ee78763          	beq	a5,a4,b1e <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 a34:	07800713          	li	a4,120
 a38:	12e78963          	beq	a5,a4,b6a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 a3c:	07000713          	li	a4,112
 a40:	14e78e63          	beq	a5,a4,b9c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 a44:	06300713          	li	a4,99
 a48:	18e78e63          	beq	a5,a4,be4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 a4c:	07300713          	li	a4,115
 a50:	1ae78463          	beq	a5,a4,bf8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 a54:	02500713          	li	a4,37
 a58:	04e79563          	bne	a5,a4,aa2 <vprintf+0xfa>
        putc(fd, '%');
 a5c:	02500593          	li	a1,37
 a60:	855a                	mv	a0,s6
 a62:	e8dff0ef          	jal	8ee <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 a66:	4981                	li	s3,0
 a68:	b769                	j	9f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 a6a:	008b8913          	addi	s2,s7,8
 a6e:	4685                	li	a3,1
 a70:	4629                	li	a2,10
 a72:	000ba583          	lw	a1,0(s7)
 a76:	855a                	mv	a0,s6
 a78:	e95ff0ef          	jal	90c <printint>
 a7c:	8bca                	mv	s7,s2
      state = 0;
 a7e:	4981                	li	s3,0
 a80:	bf8d                	j	9f2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 a82:	06400793          	li	a5,100
 a86:	02f68963          	beq	a3,a5,ab8 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 a8a:	06c00793          	li	a5,108
 a8e:	04f68263          	beq	a3,a5,ad2 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 a92:	07500793          	li	a5,117
 a96:	0af68063          	beq	a3,a5,b36 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 a9a:	07800793          	li	a5,120
 a9e:	0ef68263          	beq	a3,a5,b82 <vprintf+0x1da>
        putc(fd, '%');
 aa2:	02500593          	li	a1,37
 aa6:	855a                	mv	a0,s6
 aa8:	e47ff0ef          	jal	8ee <putc>
        putc(fd, c0);
 aac:	85ca                	mv	a1,s2
 aae:	855a                	mv	a0,s6
 ab0:	e3fff0ef          	jal	8ee <putc>
      state = 0;
 ab4:	4981                	li	s3,0
 ab6:	bf35                	j	9f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 ab8:	008b8913          	addi	s2,s7,8
 abc:	4685                	li	a3,1
 abe:	4629                	li	a2,10
 ac0:	000bb583          	ld	a1,0(s7)
 ac4:	855a                	mv	a0,s6
 ac6:	e47ff0ef          	jal	90c <printint>
        i += 1;
 aca:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 acc:	8bca                	mv	s7,s2
      state = 0;
 ace:	4981                	li	s3,0
        i += 1;
 ad0:	b70d                	j	9f2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 ad2:	06400793          	li	a5,100
 ad6:	02f60763          	beq	a2,a5,b04 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 ada:	07500793          	li	a5,117
 ade:	06f60963          	beq	a2,a5,b50 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 ae2:	07800793          	li	a5,120
 ae6:	faf61ee3          	bne	a2,a5,aa2 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 aea:	008b8913          	addi	s2,s7,8
 aee:	4681                	li	a3,0
 af0:	4641                	li	a2,16
 af2:	000bb583          	ld	a1,0(s7)
 af6:	855a                	mv	a0,s6
 af8:	e15ff0ef          	jal	90c <printint>
        i += 2;
 afc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 afe:	8bca                	mv	s7,s2
      state = 0;
 b00:	4981                	li	s3,0
        i += 2;
 b02:	bdc5                	j	9f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 b04:	008b8913          	addi	s2,s7,8
 b08:	4685                	li	a3,1
 b0a:	4629                	li	a2,10
 b0c:	000bb583          	ld	a1,0(s7)
 b10:	855a                	mv	a0,s6
 b12:	dfbff0ef          	jal	90c <printint>
        i += 2;
 b16:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 b18:	8bca                	mv	s7,s2
      state = 0;
 b1a:	4981                	li	s3,0
        i += 2;
 b1c:	bdd9                	j	9f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 b1e:	008b8913          	addi	s2,s7,8
 b22:	4681                	li	a3,0
 b24:	4629                	li	a2,10
 b26:	000be583          	lwu	a1,0(s7)
 b2a:	855a                	mv	a0,s6
 b2c:	de1ff0ef          	jal	90c <printint>
 b30:	8bca                	mv	s7,s2
      state = 0;
 b32:	4981                	li	s3,0
 b34:	bd7d                	j	9f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b36:	008b8913          	addi	s2,s7,8
 b3a:	4681                	li	a3,0
 b3c:	4629                	li	a2,10
 b3e:	000bb583          	ld	a1,0(s7)
 b42:	855a                	mv	a0,s6
 b44:	dc9ff0ef          	jal	90c <printint>
        i += 1;
 b48:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 b4a:	8bca                	mv	s7,s2
      state = 0;
 b4c:	4981                	li	s3,0
        i += 1;
 b4e:	b555                	j	9f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b50:	008b8913          	addi	s2,s7,8
 b54:	4681                	li	a3,0
 b56:	4629                	li	a2,10
 b58:	000bb583          	ld	a1,0(s7)
 b5c:	855a                	mv	a0,s6
 b5e:	dafff0ef          	jal	90c <printint>
        i += 2;
 b62:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 b64:	8bca                	mv	s7,s2
      state = 0;
 b66:	4981                	li	s3,0
        i += 2;
 b68:	b569                	j	9f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 b6a:	008b8913          	addi	s2,s7,8
 b6e:	4681                	li	a3,0
 b70:	4641                	li	a2,16
 b72:	000be583          	lwu	a1,0(s7)
 b76:	855a                	mv	a0,s6
 b78:	d95ff0ef          	jal	90c <printint>
 b7c:	8bca                	mv	s7,s2
      state = 0;
 b7e:	4981                	li	s3,0
 b80:	bd8d                	j	9f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 b82:	008b8913          	addi	s2,s7,8
 b86:	4681                	li	a3,0
 b88:	4641                	li	a2,16
 b8a:	000bb583          	ld	a1,0(s7)
 b8e:	855a                	mv	a0,s6
 b90:	d7dff0ef          	jal	90c <printint>
        i += 1;
 b94:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 b96:	8bca                	mv	s7,s2
      state = 0;
 b98:	4981                	li	s3,0
        i += 1;
 b9a:	bda1                	j	9f2 <vprintf+0x4a>
 b9c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 b9e:	008b8d13          	addi	s10,s7,8
 ba2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 ba6:	03000593          	li	a1,48
 baa:	855a                	mv	a0,s6
 bac:	d43ff0ef          	jal	8ee <putc>
  putc(fd, 'x');
 bb0:	07800593          	li	a1,120
 bb4:	855a                	mv	a0,s6
 bb6:	d39ff0ef          	jal	8ee <putc>
 bba:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bbc:	00000b97          	auipc	s7,0x0
 bc0:	4dcb8b93          	addi	s7,s7,1244 # 1098 <digits>
 bc4:	03c9d793          	srli	a5,s3,0x3c
 bc8:	97de                	add	a5,a5,s7
 bca:	0007c583          	lbu	a1,0(a5)
 bce:	855a                	mv	a0,s6
 bd0:	d1fff0ef          	jal	8ee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bd4:	0992                	slli	s3,s3,0x4
 bd6:	397d                	addiw	s2,s2,-1
 bd8:	fe0916e3          	bnez	s2,bc4 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 bdc:	8bea                	mv	s7,s10
      state = 0;
 bde:	4981                	li	s3,0
 be0:	6d02                	ld	s10,0(sp)
 be2:	bd01                	j	9f2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 be4:	008b8913          	addi	s2,s7,8
 be8:	000bc583          	lbu	a1,0(s7)
 bec:	855a                	mv	a0,s6
 bee:	d01ff0ef          	jal	8ee <putc>
 bf2:	8bca                	mv	s7,s2
      state = 0;
 bf4:	4981                	li	s3,0
 bf6:	bbf5                	j	9f2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 bf8:	008b8993          	addi	s3,s7,8
 bfc:	000bb903          	ld	s2,0(s7)
 c00:	00090f63          	beqz	s2,c1e <vprintf+0x276>
        for(; *s; s++)
 c04:	00094583          	lbu	a1,0(s2)
 c08:	c195                	beqz	a1,c2c <vprintf+0x284>
          putc(fd, *s);
 c0a:	855a                	mv	a0,s6
 c0c:	ce3ff0ef          	jal	8ee <putc>
        for(; *s; s++)
 c10:	0905                	addi	s2,s2,1
 c12:	00094583          	lbu	a1,0(s2)
 c16:	f9f5                	bnez	a1,c0a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 c18:	8bce                	mv	s7,s3
      state = 0;
 c1a:	4981                	li	s3,0
 c1c:	bbd9                	j	9f2 <vprintf+0x4a>
          s = "(null)";
 c1e:	00000917          	auipc	s2,0x0
 c22:	44290913          	addi	s2,s2,1090 # 1060 <malloc+0x336>
        for(; *s; s++)
 c26:	02800593          	li	a1,40
 c2a:	b7c5                	j	c0a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 c2c:	8bce                	mv	s7,s3
      state = 0;
 c2e:	4981                	li	s3,0
 c30:	b3c9                	j	9f2 <vprintf+0x4a>
 c32:	64a6                	ld	s1,72(sp)
 c34:	79e2                	ld	s3,56(sp)
 c36:	7a42                	ld	s4,48(sp)
 c38:	7aa2                	ld	s5,40(sp)
 c3a:	7b02                	ld	s6,32(sp)
 c3c:	6be2                	ld	s7,24(sp)
 c3e:	6c42                	ld	s8,16(sp)
 c40:	6ca2                	ld	s9,8(sp)
    }
  }
}
 c42:	60e6                	ld	ra,88(sp)
 c44:	6446                	ld	s0,80(sp)
 c46:	6906                	ld	s2,64(sp)
 c48:	6125                	addi	sp,sp,96
 c4a:	8082                	ret

0000000000000c4c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c4c:	715d                	addi	sp,sp,-80
 c4e:	ec06                	sd	ra,24(sp)
 c50:	e822                	sd	s0,16(sp)
 c52:	1000                	addi	s0,sp,32
 c54:	e010                	sd	a2,0(s0)
 c56:	e414                	sd	a3,8(s0)
 c58:	e818                	sd	a4,16(s0)
 c5a:	ec1c                	sd	a5,24(s0)
 c5c:	03043023          	sd	a6,32(s0)
 c60:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c64:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c68:	8622                	mv	a2,s0
 c6a:	d3fff0ef          	jal	9a8 <vprintf>
}
 c6e:	60e2                	ld	ra,24(sp)
 c70:	6442                	ld	s0,16(sp)
 c72:	6161                	addi	sp,sp,80
 c74:	8082                	ret

0000000000000c76 <printf>:

void
printf(const char *fmt, ...)
{
 c76:	711d                	addi	sp,sp,-96
 c78:	ec06                	sd	ra,24(sp)
 c7a:	e822                	sd	s0,16(sp)
 c7c:	1000                	addi	s0,sp,32
 c7e:	e40c                	sd	a1,8(s0)
 c80:	e810                	sd	a2,16(s0)
 c82:	ec14                	sd	a3,24(s0)
 c84:	f018                	sd	a4,32(s0)
 c86:	f41c                	sd	a5,40(s0)
 c88:	03043823          	sd	a6,48(s0)
 c8c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 c90:	00840613          	addi	a2,s0,8
 c94:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 c98:	85aa                	mv	a1,a0
 c9a:	4505                	li	a0,1
 c9c:	d0dff0ef          	jal	9a8 <vprintf>
}
 ca0:	60e2                	ld	ra,24(sp)
 ca2:	6442                	ld	s0,16(sp)
 ca4:	6125                	addi	sp,sp,96
 ca6:	8082                	ret

0000000000000ca8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ca8:	1141                	addi	sp,sp,-16
 caa:	e422                	sd	s0,8(sp)
 cac:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cae:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cb2:	00001797          	auipc	a5,0x1
 cb6:	34e7b783          	ld	a5,846(a5) # 2000 <freep>
 cba:	a02d                	j	ce4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cbc:	4618                	lw	a4,8(a2)
 cbe:	9f2d                	addw	a4,a4,a1
 cc0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 cc4:	6398                	ld	a4,0(a5)
 cc6:	6310                	ld	a2,0(a4)
 cc8:	a83d                	j	d06 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 cca:	ff852703          	lw	a4,-8(a0)
 cce:	9f31                	addw	a4,a4,a2
 cd0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 cd2:	ff053683          	ld	a3,-16(a0)
 cd6:	a091                	j	d1a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cd8:	6398                	ld	a4,0(a5)
 cda:	00e7e463          	bltu	a5,a4,ce2 <free+0x3a>
 cde:	00e6ea63          	bltu	a3,a4,cf2 <free+0x4a>
{
 ce2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ce4:	fed7fae3          	bgeu	a5,a3,cd8 <free+0x30>
 ce8:	6398                	ld	a4,0(a5)
 cea:	00e6e463          	bltu	a3,a4,cf2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cee:	fee7eae3          	bltu	a5,a4,ce2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 cf2:	ff852583          	lw	a1,-8(a0)
 cf6:	6390                	ld	a2,0(a5)
 cf8:	02059813          	slli	a6,a1,0x20
 cfc:	01c85713          	srli	a4,a6,0x1c
 d00:	9736                	add	a4,a4,a3
 d02:	fae60de3          	beq	a2,a4,cbc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 d06:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d0a:	4790                	lw	a2,8(a5)
 d0c:	02061593          	slli	a1,a2,0x20
 d10:	01c5d713          	srli	a4,a1,0x1c
 d14:	973e                	add	a4,a4,a5
 d16:	fae68ae3          	beq	a3,a4,cca <free+0x22>
    p->s.ptr = bp->s.ptr;
 d1a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d1c:	00001717          	auipc	a4,0x1
 d20:	2ef73223          	sd	a5,740(a4) # 2000 <freep>
}
 d24:	6422                	ld	s0,8(sp)
 d26:	0141                	addi	sp,sp,16
 d28:	8082                	ret

0000000000000d2a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d2a:	7139                	addi	sp,sp,-64
 d2c:	fc06                	sd	ra,56(sp)
 d2e:	f822                	sd	s0,48(sp)
 d30:	f426                	sd	s1,40(sp)
 d32:	ec4e                	sd	s3,24(sp)
 d34:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d36:	02051493          	slli	s1,a0,0x20
 d3a:	9081                	srli	s1,s1,0x20
 d3c:	04bd                	addi	s1,s1,15
 d3e:	8091                	srli	s1,s1,0x4
 d40:	0014899b          	addiw	s3,s1,1
 d44:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d46:	00001517          	auipc	a0,0x1
 d4a:	2ba53503          	ld	a0,698(a0) # 2000 <freep>
 d4e:	c915                	beqz	a0,d82 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d50:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d52:	4798                	lw	a4,8(a5)
 d54:	08977a63          	bgeu	a4,s1,de8 <malloc+0xbe>
 d58:	f04a                	sd	s2,32(sp)
 d5a:	e852                	sd	s4,16(sp)
 d5c:	e456                	sd	s5,8(sp)
 d5e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 d60:	8a4e                	mv	s4,s3
 d62:	0009871b          	sext.w	a4,s3
 d66:	6685                	lui	a3,0x1
 d68:	00d77363          	bgeu	a4,a3,d6e <malloc+0x44>
 d6c:	6a05                	lui	s4,0x1
 d6e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d72:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 d76:	00001917          	auipc	s2,0x1
 d7a:	28a90913          	addi	s2,s2,650 # 2000 <freep>
  if(p == SBRK_ERROR)
 d7e:	5afd                	li	s5,-1
 d80:	a081                	j	dc0 <malloc+0x96>
 d82:	f04a                	sd	s2,32(sp)
 d84:	e852                	sd	s4,16(sp)
 d86:	e456                	sd	s5,8(sp)
 d88:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 d8a:	00006797          	auipc	a5,0x6
 d8e:	a3678793          	addi	a5,a5,-1482 # 67c0 <base>
 d92:	00001717          	auipc	a4,0x1
 d96:	26f73723          	sd	a5,622(a4) # 2000 <freep>
 d9a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 d9c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 da0:	b7c1                	j	d60 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 da2:	6398                	ld	a4,0(a5)
 da4:	e118                	sd	a4,0(a0)
 da6:	a8a9                	j	e00 <malloc+0xd6>
  hp->s.size = nu;
 da8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 dac:	0541                	addi	a0,a0,16
 dae:	efbff0ef          	jal	ca8 <free>
  return freep;
 db2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 db6:	c12d                	beqz	a0,e18 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 db8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 dba:	4798                	lw	a4,8(a5)
 dbc:	02977263          	bgeu	a4,s1,de0 <malloc+0xb6>
    if(p == freep)
 dc0:	00093703          	ld	a4,0(s2)
 dc4:	853e                	mv	a0,a5
 dc6:	fef719e3          	bne	a4,a5,db8 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 dca:	8552                	mv	a0,s4
 dcc:	9f1ff0ef          	jal	7bc <sbrk>
  if(p == SBRK_ERROR)
 dd0:	fd551ce3          	bne	a0,s5,da8 <malloc+0x7e>
        return 0;
 dd4:	4501                	li	a0,0
 dd6:	7902                	ld	s2,32(sp)
 dd8:	6a42                	ld	s4,16(sp)
 dda:	6aa2                	ld	s5,8(sp)
 ddc:	6b02                	ld	s6,0(sp)
 dde:	a03d                	j	e0c <malloc+0xe2>
 de0:	7902                	ld	s2,32(sp)
 de2:	6a42                	ld	s4,16(sp)
 de4:	6aa2                	ld	s5,8(sp)
 de6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 de8:	fae48de3          	beq	s1,a4,da2 <malloc+0x78>
        p->s.size -= nunits;
 dec:	4137073b          	subw	a4,a4,s3
 df0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 df2:	02071693          	slli	a3,a4,0x20
 df6:	01c6d713          	srli	a4,a3,0x1c
 dfa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 dfc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e00:	00001717          	auipc	a4,0x1
 e04:	20a73023          	sd	a0,512(a4) # 2000 <freep>
      return (void*)(p + 1);
 e08:	01078513          	addi	a0,a5,16
  }
}
 e0c:	70e2                	ld	ra,56(sp)
 e0e:	7442                	ld	s0,48(sp)
 e10:	74a2                	ld	s1,40(sp)
 e12:	69e2                	ld	s3,24(sp)
 e14:	6121                	addi	sp,sp,64
 e16:	8082                	ret
 e18:	7902                	ld	s2,32(sp)
 e1a:	6a42                	ld	s4,16(sp)
 e1c:	6aa2                	ld	s5,8(sp)
 e1e:	6b02                	ld	s6,0(sp)
 e20:	b7f5                	j	e0c <malloc+0xe2>
