
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
 120:	4e2000ef          	jal	602 <memset>

    append_str(buf, &pos, "EV {\"seq\":");
 124:	00001617          	auipc	a2,0x1
 128:	cfc60613          	addi	a2,a2,-772 # e20 <malloc+0x100>
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
 14a:	cea60613          	addi	a2,a2,-790 # e30 <malloc+0x110>
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
 16c:	cd860613          	addi	a2,a2,-808 # e40 <malloc+0x120>
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
 18e:	cbe60613          	addi	a2,a2,-834 # e48 <malloc+0x128>
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
 1b0:	ca460613          	addi	a2,a2,-860 # e50 <malloc+0x130>
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
 1d4:	c9060613          	addi	a2,a2,-880 # e60 <malloc+0x140>
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
 1f6:	c7e60613          	addi	a2,a2,-898 # e70 <malloc+0x150>
 1fa:	bdc40593          	addi	a1,s0,-1060
 1fe:	be040513          	addi	a0,s0,-1056
 202:	dffff0ef          	jal	0 <append_str>

    write(1, buf, pos);
 206:	bdc42603          	lw	a2,-1060(s0)
 20a:	be040593          	addi	a1,s0,-1056
 20e:	4505                	li	a0,1
 210:	624000ef          	jal	834 <write>
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
 24a:	3b8000ef          	jal	602 <memset>
    append_str(buf, &pos, "EV {\"seq\":");
 24e:	00001617          	auipc	a2,0x1
 252:	bd260613          	addi	a2,a2,-1070 # e20 <malloc+0x100>
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
 274:	bc060613          	addi	a2,a2,-1088 # e30 <malloc+0x110>
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
 296:	bf660613          	addi	a2,a2,-1034 # e88 <malloc+0x168>
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
 2b8:	b9460613          	addi	a2,a2,-1132 # e48 <malloc+0x128>
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
 2da:	bd260613          	addi	a2,a2,-1070 # ea8 <malloc+0x188>
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
 2fe:	bbe60613          	addi	a2,a2,-1090 # eb8 <malloc+0x198>
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
 322:	baa60613          	addi	a2,a2,-1110 # ec8 <malloc+0x1a8>
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
 346:	b0e60613          	addi	a2,a2,-1266 # e50 <malloc+0x130>
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
 36a:	b7260613          	addi	a2,a2,-1166 # ed8 <malloc+0x1b8>
 36e:	bdc40593          	addi	a1,s0,-1060
 372:	be040513          	addi	a0,s0,-1056
 376:	c8bff0ef          	jal	0 <append_str>
    write(1, buf, pos);
 37a:	bdc42603          	lw	a2,-1060(s0)
 37e:	be040593          	addi	a1,s0,-1056
 382:	4505                	li	a0,1
 384:	4b0000ef          	jal	834 <write>
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
 39a:	7159                	addi	sp,sp,-112
 39c:	f486                	sd	ra,104(sp)
 39e:	f0a2                	sd	s0,96(sp)
 3a0:	eca6                	sd	s1,88(sp)
 3a2:	e4ce                	sd	s3,72(sp)
 3a4:	1880                	addi	s0,sp,112
    int n;

    memset(cpus, 0, sizeof(cpus));
 3a6:	00002497          	auipc	s1,0x2
 3aa:	c6a48493          	addi	s1,s1,-918 # 2010 <cpus>
 3ae:	24000613          	li	a2,576
 3b2:	4581                	li	a1,0
 3b4:	8526                	mv	a0,s1
 3b6:	24c000ef          	jal	602 <memset>
    memset(&stats, 0, sizeof(stats));
 3ba:	07000613          	li	a2,112
 3be:	4581                	li	a1,0
 3c0:	00002517          	auipc	a0,0x2
 3c4:	e9050513          	addi	a0,a0,-368 # 2250 <stats>
 3c8:	23a000ef          	jal	602 <memset>

    n = getcpuinfo(cpus, NCPU);
 3cc:	45a1                	li	a1,8
 3ce:	8526                	mv	a0,s1
 3d0:	504000ef          	jal	8d4 <getcpuinfo>
    if (n < 0 || getprocstats(&stats) < 0) {
 3d4:	00054b63          	bltz	a0,3ea <main+0x50>
 3d8:	89aa                	mv	s3,a0
 3da:	00002517          	auipc	a0,0x2
 3de:	e7650513          	addi	a0,a0,-394 # 2250 <stats>
 3e2:	4fa000ef          	jal	8dc <getprocstats>
 3e6:	02055263          	bgez	a0,40a <main+0x70>
 3ea:	e8ca                	sd	s2,80(sp)
 3ec:	e0d2                	sd	s4,64(sp)
 3ee:	fc56                	sd	s5,56(sp)
 3f0:	f85a                	sd	s6,48(sp)
 3f2:	f45e                	sd	s7,40(sp)
 3f4:	f062                	sd	s8,32(sp)
 3f6:	ec66                	sd	s9,24(sp)
        printf("Error fetching system info\n");
 3f8:	00001517          	auipc	a0,0x1
 3fc:	af050513          	addi	a0,a0,-1296 # ee8 <malloc+0x1c8>
 400:	06d000ef          	jal	c6c <printf>
        exit(1);
 404:	4505                	li	a0,1
 406:	40e000ef          	jal	814 <exit>
 40a:	e8ca                	sd	s2,80(sp)
 40c:	e0d2                	sd	s4,64(sp)
 40e:	fc56                	sd	s5,56(sp)
 410:	f85a                	sd	s6,48(sp)
 412:	f45e                	sd	s7,40(sp)
 414:	f062                	sd	s8,32(sp)
 416:	ec66                	sd	s9,24(sp)
    }
    
    // DEBUG: Print number of CPUs returned
    printf("[DEBUG] getcpuinfo returned %d CPUs\n", n);
 418:	85ce                	mv	a1,s3
 41a:	00001517          	auipc	a0,0x1
 41e:	aee50513          	addi	a0,a0,-1298 # f08 <malloc+0x1e8>
 422:	04b000ef          	jal	c6c <printf>

    // 1. طباعة حالة المعالجات الحالية
    printf("CPU {\"timestamp\":\"now\",\"system\":{");
 426:	00001517          	auipc	a0,0x1
 42a:	b0a50513          	addi	a0,a0,-1270 # f30 <malloc+0x210>
 42e:	03f000ef          	jal	c6c <printf>
    printf("\"total_created\":%lu,\"total_exited\":%lu,", stats.total_created, stats.total_exited);
 432:	00002497          	auipc	s1,0x2
 436:	bde48493          	addi	s1,s1,-1058 # 2010 <cpus>
 43a:	2a84b603          	ld	a2,680(s1)
 43e:	2a04b583          	ld	a1,672(s1)
 442:	00001517          	auipc	a0,0x1
 446:	b1650513          	addi	a0,a0,-1258 # f58 <malloc+0x238>
 44a:	023000ef          	jal	c6c <printf>
    printf("\"ever_running\":%lu,\"ever_sleeping\":%lu,\"ever_zombie\":%lu},", 
 44e:	2984b683          	ld	a3,664(s1)
 452:	2804b603          	ld	a2,640(s1)
 456:	2904b583          	ld	a1,656(s1)
 45a:	00001517          	auipc	a0,0x1
 45e:	b2650513          	addi	a0,a0,-1242 # f80 <malloc+0x260>
 462:	00b000ef          	jal	c6c <printf>
            stats.unique_count[4], stats.unique_count[2], stats.unique_count[5]);

    printf("\"cpus\":[");
 466:	00001517          	auipc	a0,0x1
 46a:	b5a50513          	addi	a0,a0,-1190 # fc0 <malloc+0x2a0>
 46e:	7fe000ef          	jal	c6c <printf>
    for (int i = 0; i < n; i++) {
 472:	09305163          	blez	s3,4f4 <main+0x15a>
 476:	00002917          	auipc	s2,0x2
 47a:	ba690913          	addi	s2,s2,-1114 # 201c <cpus+0xc>
 47e:	4481                	li	s1,0
        int state_idx = cpus[i].current_state;
        const char *st_name = "UNK";
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 480:	4b95                	li	s7,5
        const char *st_name = "UNK";
 482:	00001b17          	auipc	s6,0x1
 486:	a5eb0b13          	addi	s6,s6,-1442 # ee0 <malloc+0x1c0>
            st_name = state_names[state_idx];
 48a:	00001c17          	auipc	s8,0x1
 48e:	c36c0c13          	addi	s8,s8,-970 # 10c0 <state_names>
        }

        printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"proc_name\":\"%s\",\"current_state\":\"%s\",\"context_eip\":\"0x%lx\",\"context_esp\":\"0x%lx\",\"busy_percent\":%d}",
 492:	00001a97          	auipc	s5,0x1
 496:	b3ea8a93          	addi	s5,s5,-1218 # fd0 <malloc+0x2b0>
               cpus[i].cpu, cpus[i].active, cpus[i].current_pid, cpus[i].proc_name, st_name, cpus[i].context_eip, cpus[i].context_esp, cpus[i].busy_percent);
        
        if (i < n - 1) printf(",");
 49a:	fff98a1b          	addiw	s4,s3,-1
 49e:	00001c97          	auipc	s9,0x1
 4a2:	bcac8c93          	addi	s9,s9,-1078 # 1068 <malloc+0x348>
 4a6:	a03d                	j	4d4 <main+0x13a>
        printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"proc_name\":\"%s\",\"current_state\":\"%s\",\"context_eip\":\"0x%lx\",\"context_esp\":\"0x%lx\",\"busy_percent\":%d}",
 4a8:	5b54                	lw	a3,52(a4)
 4aa:	e036                	sd	a3,0(sp)
 4ac:	02c73883          	ld	a7,44(a4)
 4b0:	02473803          	ld	a6,36(a4)
 4b4:	ffc72683          	lw	a3,-4(a4)
 4b8:	ff872603          	lw	a2,-8(a4)
 4bc:	ff472583          	lw	a1,-12(a4)
 4c0:	8556                	mv	a0,s5
 4c2:	7aa000ef          	jal	c6c <printf>
        if (i < n - 1) printf(",");
 4c6:	0344c363          	blt	s1,s4,4ec <main+0x152>
    for (int i = 0; i < n; i++) {
 4ca:	2485                	addiw	s1,s1,1
 4cc:	04890913          	addi	s2,s2,72
 4d0:	02998263          	beq	s3,s1,4f4 <main+0x15a>
        int state_idx = cpus[i].current_state;
 4d4:	874a                	mv	a4,s2
 4d6:	01092683          	lw	a3,16(s2)
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 4da:	0006861b          	sext.w	a2,a3
        const char *st_name = "UNK";
 4de:	87da                	mv	a5,s6
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 4e0:	fccbe4e3          	bltu	s7,a2,4a8 <main+0x10e>
            st_name = state_names[state_idx];
 4e4:	068e                	slli	a3,a3,0x3
 4e6:	96e2                	add	a3,a3,s8
 4e8:	629c                	ld	a5,0(a3)
 4ea:	bf7d                	j	4a8 <main+0x10e>
        if (i < n - 1) printf(",");
 4ec:	8566                	mv	a0,s9
 4ee:	77e000ef          	jal	c6c <printf>
 4f2:	bfe1                	j	4ca <main+0x130>
    }
    printf("]}\n");
 4f4:	00001517          	auipc	a0,0x1
 4f8:	b7c50513          	addi	a0,a0,-1156 # 1070 <malloc+0x350>
 4fc:	770000ef          	jal	c6c <printf>

   // 2. قراءة أحداث المعالج المتوفرة في البفر حالياً
    int n_cs = csread(cs_ev, 32);
 500:	02000593          	li	a1,32
 504:	00002517          	auipc	a0,0x2
 508:	dbc50513          	addi	a0,a0,-580 # 22c0 <cs_ev>
 50c:	3a8000ef          	jal	8b4 <csread>
    for (int i = 0; i < n_cs; i++) { // الدوران فقط حتى n_cs الحقيقية
 510:	02a05963          	blez	a0,542 <main+0x1a8>
 514:	00002497          	auipc	s1,0x2
 518:	dac48493          	addi	s1,s1,-596 # 22c0 <cs_ev>
 51c:	03000793          	li	a5,48
 520:	02f50533          	mul	a0,a0,a5
 524:	00950933          	add	s2,a0,s1
        if (cs_ev[i].type == 1) 
 528:	4985                	li	s3,1
 52a:	a029                	j	534 <main+0x19a>
    for (int i = 0; i < n_cs; i++) { // الدوران فقط حتى n_cs الحقيقية
 52c:	03048493          	addi	s1,s1,48
 530:	01248963          	beq	s1,s2,542 <main+0x1a8>
        if (cs_ev[i].type == 1) 
 534:	489c                	lw	a5,16(s1)
 536:	ff379be3          	bne	a5,s3,52c <main+0x192>
            print_cs_event(&cs_ev[i]);
 53a:	8526                	mv	a0,s1
 53c:	bc1ff0ef          	jal	fc <print_cs_event>
 540:	b7f5                	j	52c <main+0x192>
    }

    
// 3. قراءة أحداث نظام الملفات المتوفرة في البفر حالياً
    int n_fs = fsread(fs_ev, 32);
 542:	02000593          	li	a1,32
 546:	00002517          	auipc	a0,0x2
 54a:	37a50513          	addi	a0,a0,890 # 28c0 <fs_ev>
 54e:	36e000ef          	jal	8bc <fsread>
    for (int i = 0; i < n_fs; i++) { 
 552:	02a05463          	blez	a0,57a <main+0x1e0>
 556:	00002497          	auipc	s1,0x2
 55a:	36a48493          	addi	s1,s1,874 # 28c0 <fs_ev>
 55e:	0526                	slli	a0,a0,0x9
 560:	00950933          	add	s2,a0,s1
 564:	a029                	j	56e <main+0x1d4>
 566:	20048493          	addi	s1,s1,512
 56a:	01248863          	beq	s1,s2,57a <main+0x1e0>
        // إذا كان الـ seq مصفراً، فهذا مخلفات بافر، لا تطبعه
        if (fs_ev[i].seq != 0) {
 56e:	609c                	ld	a5,0(s1)
 570:	dbfd                	beqz	a5,566 <main+0x1cc>
            print_fs_event(&fs_ev[i]);
 572:	8526                	mv	a0,s1
 574:	cb3ff0ef          	jal	226 <print_fs_event>
 578:	b7fd                	j	566 <main+0x1cc>
        }
    }
    // الخروج وإنهاء البرنامج فوراً دون الدخول في حلقة لانهائية
    exit(0); 
 57a:	4501                	li	a0,0
 57c:	298000ef          	jal	814 <exit>

0000000000000580 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 580:	1141                	addi	sp,sp,-16
 582:	e406                	sd	ra,8(sp)
 584:	e022                	sd	s0,0(sp)
 586:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 588:	e13ff0ef          	jal	39a <main>
  exit(r);
 58c:	288000ef          	jal	814 <exit>

0000000000000590 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 590:	1141                	addi	sp,sp,-16
 592:	e422                	sd	s0,8(sp)
 594:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 596:	87aa                	mv	a5,a0
 598:	0585                	addi	a1,a1,1
 59a:	0785                	addi	a5,a5,1
 59c:	fff5c703          	lbu	a4,-1(a1)
 5a0:	fee78fa3          	sb	a4,-1(a5)
 5a4:	fb75                	bnez	a4,598 <strcpy+0x8>
    ;
  return os;
}
 5a6:	6422                	ld	s0,8(sp)
 5a8:	0141                	addi	sp,sp,16
 5aa:	8082                	ret

00000000000005ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5ac:	1141                	addi	sp,sp,-16
 5ae:	e422                	sd	s0,8(sp)
 5b0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 5b2:	00054783          	lbu	a5,0(a0)
 5b6:	cb91                	beqz	a5,5ca <strcmp+0x1e>
 5b8:	0005c703          	lbu	a4,0(a1)
 5bc:	00f71763          	bne	a4,a5,5ca <strcmp+0x1e>
    p++, q++;
 5c0:	0505                	addi	a0,a0,1
 5c2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 5c4:	00054783          	lbu	a5,0(a0)
 5c8:	fbe5                	bnez	a5,5b8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 5ca:	0005c503          	lbu	a0,0(a1)
}
 5ce:	40a7853b          	subw	a0,a5,a0
 5d2:	6422                	ld	s0,8(sp)
 5d4:	0141                	addi	sp,sp,16
 5d6:	8082                	ret

00000000000005d8 <strlen>:

uint
strlen(const char *s)
{
 5d8:	1141                	addi	sp,sp,-16
 5da:	e422                	sd	s0,8(sp)
 5dc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 5de:	00054783          	lbu	a5,0(a0)
 5e2:	cf91                	beqz	a5,5fe <strlen+0x26>
 5e4:	0505                	addi	a0,a0,1
 5e6:	87aa                	mv	a5,a0
 5e8:	86be                	mv	a3,a5
 5ea:	0785                	addi	a5,a5,1
 5ec:	fff7c703          	lbu	a4,-1(a5)
 5f0:	ff65                	bnez	a4,5e8 <strlen+0x10>
 5f2:	40a6853b          	subw	a0,a3,a0
 5f6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 5f8:	6422                	ld	s0,8(sp)
 5fa:	0141                	addi	sp,sp,16
 5fc:	8082                	ret
  for(n = 0; s[n]; n++)
 5fe:	4501                	li	a0,0
 600:	bfe5                	j	5f8 <strlen+0x20>

0000000000000602 <memset>:

void*
memset(void *dst, int c, uint n)
{
 602:	1141                	addi	sp,sp,-16
 604:	e422                	sd	s0,8(sp)
 606:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 608:	ca19                	beqz	a2,61e <memset+0x1c>
 60a:	87aa                	mv	a5,a0
 60c:	1602                	slli	a2,a2,0x20
 60e:	9201                	srli	a2,a2,0x20
 610:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 614:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 618:	0785                	addi	a5,a5,1
 61a:	fee79de3          	bne	a5,a4,614 <memset+0x12>
  }
  return dst;
}
 61e:	6422                	ld	s0,8(sp)
 620:	0141                	addi	sp,sp,16
 622:	8082                	ret

0000000000000624 <strchr>:

char*
strchr(const char *s, char c)
{
 624:	1141                	addi	sp,sp,-16
 626:	e422                	sd	s0,8(sp)
 628:	0800                	addi	s0,sp,16
  for(; *s; s++)
 62a:	00054783          	lbu	a5,0(a0)
 62e:	cb99                	beqz	a5,644 <strchr+0x20>
    if(*s == c)
 630:	00f58763          	beq	a1,a5,63e <strchr+0x1a>
  for(; *s; s++)
 634:	0505                	addi	a0,a0,1
 636:	00054783          	lbu	a5,0(a0)
 63a:	fbfd                	bnez	a5,630 <strchr+0xc>
      return (char*)s;
  return 0;
 63c:	4501                	li	a0,0
}
 63e:	6422                	ld	s0,8(sp)
 640:	0141                	addi	sp,sp,16
 642:	8082                	ret
  return 0;
 644:	4501                	li	a0,0
 646:	bfe5                	j	63e <strchr+0x1a>

0000000000000648 <gets>:

char*
gets(char *buf, int max)
{
 648:	711d                	addi	sp,sp,-96
 64a:	ec86                	sd	ra,88(sp)
 64c:	e8a2                	sd	s0,80(sp)
 64e:	e4a6                	sd	s1,72(sp)
 650:	e0ca                	sd	s2,64(sp)
 652:	fc4e                	sd	s3,56(sp)
 654:	f852                	sd	s4,48(sp)
 656:	f456                	sd	s5,40(sp)
 658:	f05a                	sd	s6,32(sp)
 65a:	ec5e                	sd	s7,24(sp)
 65c:	1080                	addi	s0,sp,96
 65e:	8baa                	mv	s7,a0
 660:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 662:	892a                	mv	s2,a0
 664:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 666:	4aa9                	li	s5,10
 668:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 66a:	89a6                	mv	s3,s1
 66c:	2485                	addiw	s1,s1,1
 66e:	0344d663          	bge	s1,s4,69a <gets+0x52>
    cc = read(0, &c, 1);
 672:	4605                	li	a2,1
 674:	faf40593          	addi	a1,s0,-81
 678:	4501                	li	a0,0
 67a:	1b2000ef          	jal	82c <read>
    if(cc < 1)
 67e:	00a05e63          	blez	a0,69a <gets+0x52>
    buf[i++] = c;
 682:	faf44783          	lbu	a5,-81(s0)
 686:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 68a:	01578763          	beq	a5,s5,698 <gets+0x50>
 68e:	0905                	addi	s2,s2,1
 690:	fd679de3          	bne	a5,s6,66a <gets+0x22>
    buf[i++] = c;
 694:	89a6                	mv	s3,s1
 696:	a011                	j	69a <gets+0x52>
 698:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 69a:	99de                	add	s3,s3,s7
 69c:	00098023          	sb	zero,0(s3)
  return buf;
}
 6a0:	855e                	mv	a0,s7
 6a2:	60e6                	ld	ra,88(sp)
 6a4:	6446                	ld	s0,80(sp)
 6a6:	64a6                	ld	s1,72(sp)
 6a8:	6906                	ld	s2,64(sp)
 6aa:	79e2                	ld	s3,56(sp)
 6ac:	7a42                	ld	s4,48(sp)
 6ae:	7aa2                	ld	s5,40(sp)
 6b0:	7b02                	ld	s6,32(sp)
 6b2:	6be2                	ld	s7,24(sp)
 6b4:	6125                	addi	sp,sp,96
 6b6:	8082                	ret

00000000000006b8 <stat>:

int
stat(const char *n, struct stat *st)
{
 6b8:	1101                	addi	sp,sp,-32
 6ba:	ec06                	sd	ra,24(sp)
 6bc:	e822                	sd	s0,16(sp)
 6be:	e04a                	sd	s2,0(sp)
 6c0:	1000                	addi	s0,sp,32
 6c2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6c4:	4581                	li	a1,0
 6c6:	18e000ef          	jal	854 <open>
  if(fd < 0)
 6ca:	02054263          	bltz	a0,6ee <stat+0x36>
 6ce:	e426                	sd	s1,8(sp)
 6d0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 6d2:	85ca                	mv	a1,s2
 6d4:	198000ef          	jal	86c <fstat>
 6d8:	892a                	mv	s2,a0
  close(fd);
 6da:	8526                	mv	a0,s1
 6dc:	160000ef          	jal	83c <close>
  return r;
 6e0:	64a2                	ld	s1,8(sp)
}
 6e2:	854a                	mv	a0,s2
 6e4:	60e2                	ld	ra,24(sp)
 6e6:	6442                	ld	s0,16(sp)
 6e8:	6902                	ld	s2,0(sp)
 6ea:	6105                	addi	sp,sp,32
 6ec:	8082                	ret
    return -1;
 6ee:	597d                	li	s2,-1
 6f0:	bfcd                	j	6e2 <stat+0x2a>

00000000000006f2 <atoi>:

int
atoi(const char *s)
{
 6f2:	1141                	addi	sp,sp,-16
 6f4:	e422                	sd	s0,8(sp)
 6f6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6f8:	00054683          	lbu	a3,0(a0)
 6fc:	fd06879b          	addiw	a5,a3,-48
 700:	0ff7f793          	zext.b	a5,a5
 704:	4625                	li	a2,9
 706:	02f66863          	bltu	a2,a5,736 <atoi+0x44>
 70a:	872a                	mv	a4,a0
  n = 0;
 70c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 70e:	0705                	addi	a4,a4,1
 710:	0025179b          	slliw	a5,a0,0x2
 714:	9fa9                	addw	a5,a5,a0
 716:	0017979b          	slliw	a5,a5,0x1
 71a:	9fb5                	addw	a5,a5,a3
 71c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 720:	00074683          	lbu	a3,0(a4)
 724:	fd06879b          	addiw	a5,a3,-48
 728:	0ff7f793          	zext.b	a5,a5
 72c:	fef671e3          	bgeu	a2,a5,70e <atoi+0x1c>
  return n;
}
 730:	6422                	ld	s0,8(sp)
 732:	0141                	addi	sp,sp,16
 734:	8082                	ret
  n = 0;
 736:	4501                	li	a0,0
 738:	bfe5                	j	730 <atoi+0x3e>

000000000000073a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 73a:	1141                	addi	sp,sp,-16
 73c:	e422                	sd	s0,8(sp)
 73e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 740:	02b57463          	bgeu	a0,a1,768 <memmove+0x2e>
    while(n-- > 0)
 744:	00c05f63          	blez	a2,762 <memmove+0x28>
 748:	1602                	slli	a2,a2,0x20
 74a:	9201                	srli	a2,a2,0x20
 74c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 750:	872a                	mv	a4,a0
      *dst++ = *src++;
 752:	0585                	addi	a1,a1,1
 754:	0705                	addi	a4,a4,1
 756:	fff5c683          	lbu	a3,-1(a1)
 75a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 75e:	fef71ae3          	bne	a4,a5,752 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 762:	6422                	ld	s0,8(sp)
 764:	0141                	addi	sp,sp,16
 766:	8082                	ret
    dst += n;
 768:	00c50733          	add	a4,a0,a2
    src += n;
 76c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 76e:	fec05ae3          	blez	a2,762 <memmove+0x28>
 772:	fff6079b          	addiw	a5,a2,-1
 776:	1782                	slli	a5,a5,0x20
 778:	9381                	srli	a5,a5,0x20
 77a:	fff7c793          	not	a5,a5
 77e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 780:	15fd                	addi	a1,a1,-1
 782:	177d                	addi	a4,a4,-1
 784:	0005c683          	lbu	a3,0(a1)
 788:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 78c:	fee79ae3          	bne	a5,a4,780 <memmove+0x46>
 790:	bfc9                	j	762 <memmove+0x28>

0000000000000792 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 792:	1141                	addi	sp,sp,-16
 794:	e422                	sd	s0,8(sp)
 796:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 798:	ca05                	beqz	a2,7c8 <memcmp+0x36>
 79a:	fff6069b          	addiw	a3,a2,-1
 79e:	1682                	slli	a3,a3,0x20
 7a0:	9281                	srli	a3,a3,0x20
 7a2:	0685                	addi	a3,a3,1
 7a4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 7a6:	00054783          	lbu	a5,0(a0)
 7aa:	0005c703          	lbu	a4,0(a1)
 7ae:	00e79863          	bne	a5,a4,7be <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 7b2:	0505                	addi	a0,a0,1
    p2++;
 7b4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 7b6:	fed518e3          	bne	a0,a3,7a6 <memcmp+0x14>
  }
  return 0;
 7ba:	4501                	li	a0,0
 7bc:	a019                	j	7c2 <memcmp+0x30>
      return *p1 - *p2;
 7be:	40e7853b          	subw	a0,a5,a4
}
 7c2:	6422                	ld	s0,8(sp)
 7c4:	0141                	addi	sp,sp,16
 7c6:	8082                	ret
  return 0;
 7c8:	4501                	li	a0,0
 7ca:	bfe5                	j	7c2 <memcmp+0x30>

00000000000007cc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 7cc:	1141                	addi	sp,sp,-16
 7ce:	e406                	sd	ra,8(sp)
 7d0:	e022                	sd	s0,0(sp)
 7d2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 7d4:	f67ff0ef          	jal	73a <memmove>
}
 7d8:	60a2                	ld	ra,8(sp)
 7da:	6402                	ld	s0,0(sp)
 7dc:	0141                	addi	sp,sp,16
 7de:	8082                	ret

00000000000007e0 <sbrk>:

char *
sbrk(int n) {
 7e0:	1141                	addi	sp,sp,-16
 7e2:	e406                	sd	ra,8(sp)
 7e4:	e022                	sd	s0,0(sp)
 7e6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 7e8:	4585                	li	a1,1
 7ea:	0b2000ef          	jal	89c <sys_sbrk>
}
 7ee:	60a2                	ld	ra,8(sp)
 7f0:	6402                	ld	s0,0(sp)
 7f2:	0141                	addi	sp,sp,16
 7f4:	8082                	ret

00000000000007f6 <sbrklazy>:

char *
sbrklazy(int n) {
 7f6:	1141                	addi	sp,sp,-16
 7f8:	e406                	sd	ra,8(sp)
 7fa:	e022                	sd	s0,0(sp)
 7fc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 7fe:	4589                	li	a1,2
 800:	09c000ef          	jal	89c <sys_sbrk>
}
 804:	60a2                	ld	ra,8(sp)
 806:	6402                	ld	s0,0(sp)
 808:	0141                	addi	sp,sp,16
 80a:	8082                	ret

000000000000080c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 80c:	4885                	li	a7,1
 ecall
 80e:	00000073          	ecall
 ret
 812:	8082                	ret

0000000000000814 <exit>:
.global exit
exit:
 li a7, SYS_exit
 814:	4889                	li	a7,2
 ecall
 816:	00000073          	ecall
 ret
 81a:	8082                	ret

000000000000081c <wait>:
.global wait
wait:
 li a7, SYS_wait
 81c:	488d                	li	a7,3
 ecall
 81e:	00000073          	ecall
 ret
 822:	8082                	ret

0000000000000824 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 824:	4891                	li	a7,4
 ecall
 826:	00000073          	ecall
 ret
 82a:	8082                	ret

000000000000082c <read>:
.global read
read:
 li a7, SYS_read
 82c:	4895                	li	a7,5
 ecall
 82e:	00000073          	ecall
 ret
 832:	8082                	ret

0000000000000834 <write>:
.global write
write:
 li a7, SYS_write
 834:	48c1                	li	a7,16
 ecall
 836:	00000073          	ecall
 ret
 83a:	8082                	ret

000000000000083c <close>:
.global close
close:
 li a7, SYS_close
 83c:	48d5                	li	a7,21
 ecall
 83e:	00000073          	ecall
 ret
 842:	8082                	ret

0000000000000844 <kill>:
.global kill
kill:
 li a7, SYS_kill
 844:	4899                	li	a7,6
 ecall
 846:	00000073          	ecall
 ret
 84a:	8082                	ret

000000000000084c <exec>:
.global exec
exec:
 li a7, SYS_exec
 84c:	489d                	li	a7,7
 ecall
 84e:	00000073          	ecall
 ret
 852:	8082                	ret

0000000000000854 <open>:
.global open
open:
 li a7, SYS_open
 854:	48bd                	li	a7,15
 ecall
 856:	00000073          	ecall
 ret
 85a:	8082                	ret

000000000000085c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 85c:	48c5                	li	a7,17
 ecall
 85e:	00000073          	ecall
 ret
 862:	8082                	ret

0000000000000864 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 864:	48c9                	li	a7,18
 ecall
 866:	00000073          	ecall
 ret
 86a:	8082                	ret

000000000000086c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 86c:	48a1                	li	a7,8
 ecall
 86e:	00000073          	ecall
 ret
 872:	8082                	ret

0000000000000874 <link>:
.global link
link:
 li a7, SYS_link
 874:	48cd                	li	a7,19
 ecall
 876:	00000073          	ecall
 ret
 87a:	8082                	ret

000000000000087c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 87c:	48d1                	li	a7,20
 ecall
 87e:	00000073          	ecall
 ret
 882:	8082                	ret

0000000000000884 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 884:	48a5                	li	a7,9
 ecall
 886:	00000073          	ecall
 ret
 88a:	8082                	ret

000000000000088c <dup>:
.global dup
dup:
 li a7, SYS_dup
 88c:	48a9                	li	a7,10
 ecall
 88e:	00000073          	ecall
 ret
 892:	8082                	ret

0000000000000894 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 894:	48ad                	li	a7,11
 ecall
 896:	00000073          	ecall
 ret
 89a:	8082                	ret

000000000000089c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 89c:	48b1                	li	a7,12
 ecall
 89e:	00000073          	ecall
 ret
 8a2:	8082                	ret

00000000000008a4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 8a4:	48b5                	li	a7,13
 ecall
 8a6:	00000073          	ecall
 ret
 8aa:	8082                	ret

00000000000008ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 8ac:	48b9                	li	a7,14
 ecall
 8ae:	00000073          	ecall
 ret
 8b2:	8082                	ret

00000000000008b4 <csread>:
.global csread
csread:
 li a7, SYS_csread
 8b4:	48d9                	li	a7,22
 ecall
 8b6:	00000073          	ecall
 ret
 8ba:	8082                	ret

00000000000008bc <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 8bc:	48dd                	li	a7,23
 ecall
 8be:	00000073          	ecall
 ret
 8c2:	8082                	ret

00000000000008c4 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 8c4:	48e1                	li	a7,24
 ecall
 8c6:	00000073          	ecall
 ret
 8ca:	8082                	ret

00000000000008cc <memread>:
.global memread
memread:
 li a7, SYS_memread
 8cc:	48e5                	li	a7,25
 ecall
 8ce:	00000073          	ecall
 ret
 8d2:	8082                	ret

00000000000008d4 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 8d4:	48e9                	li	a7,26
 ecall
 8d6:	00000073          	ecall
 ret
 8da:	8082                	ret

00000000000008dc <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 8dc:	48ed                	li	a7,27
 ecall
 8de:	00000073          	ecall
 ret
 8e2:	8082                	ret

00000000000008e4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 8e4:	1101                	addi	sp,sp,-32
 8e6:	ec06                	sd	ra,24(sp)
 8e8:	e822                	sd	s0,16(sp)
 8ea:	1000                	addi	s0,sp,32
 8ec:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 8f0:	4605                	li	a2,1
 8f2:	fef40593          	addi	a1,s0,-17
 8f6:	f3fff0ef          	jal	834 <write>
}
 8fa:	60e2                	ld	ra,24(sp)
 8fc:	6442                	ld	s0,16(sp)
 8fe:	6105                	addi	sp,sp,32
 900:	8082                	ret

0000000000000902 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 902:	715d                	addi	sp,sp,-80
 904:	e486                	sd	ra,72(sp)
 906:	e0a2                	sd	s0,64(sp)
 908:	f84a                	sd	s2,48(sp)
 90a:	0880                	addi	s0,sp,80
 90c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 90e:	c299                	beqz	a3,914 <printint+0x12>
 910:	0805c363          	bltz	a1,996 <printint+0x94>
  neg = 0;
 914:	4881                	li	a7,0
 916:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 91a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 91c:	00000517          	auipc	a0,0x0
 920:	7d450513          	addi	a0,a0,2004 # 10f0 <digits>
 924:	883e                	mv	a6,a5
 926:	2785                	addiw	a5,a5,1
 928:	02c5f733          	remu	a4,a1,a2
 92c:	972a                	add	a4,a4,a0
 92e:	00074703          	lbu	a4,0(a4)
 932:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 936:	872e                	mv	a4,a1
 938:	02c5d5b3          	divu	a1,a1,a2
 93c:	0685                	addi	a3,a3,1
 93e:	fec773e3          	bgeu	a4,a2,924 <printint+0x22>
  if(neg)
 942:	00088b63          	beqz	a7,958 <printint+0x56>
    buf[i++] = '-';
 946:	fd078793          	addi	a5,a5,-48
 94a:	97a2                	add	a5,a5,s0
 94c:	02d00713          	li	a4,45
 950:	fee78423          	sb	a4,-24(a5)
 954:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 958:	02f05a63          	blez	a5,98c <printint+0x8a>
 95c:	fc26                	sd	s1,56(sp)
 95e:	f44e                	sd	s3,40(sp)
 960:	fb840713          	addi	a4,s0,-72
 964:	00f704b3          	add	s1,a4,a5
 968:	fff70993          	addi	s3,a4,-1
 96c:	99be                	add	s3,s3,a5
 96e:	37fd                	addiw	a5,a5,-1
 970:	1782                	slli	a5,a5,0x20
 972:	9381                	srli	a5,a5,0x20
 974:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 978:	fff4c583          	lbu	a1,-1(s1)
 97c:	854a                	mv	a0,s2
 97e:	f67ff0ef          	jal	8e4 <putc>
  while(--i >= 0)
 982:	14fd                	addi	s1,s1,-1
 984:	ff349ae3          	bne	s1,s3,978 <printint+0x76>
 988:	74e2                	ld	s1,56(sp)
 98a:	79a2                	ld	s3,40(sp)
}
 98c:	60a6                	ld	ra,72(sp)
 98e:	6406                	ld	s0,64(sp)
 990:	7942                	ld	s2,48(sp)
 992:	6161                	addi	sp,sp,80
 994:	8082                	ret
    x = -xx;
 996:	40b005b3          	neg	a1,a1
    neg = 1;
 99a:	4885                	li	a7,1
    x = -xx;
 99c:	bfad                	j	916 <printint+0x14>

000000000000099e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 99e:	711d                	addi	sp,sp,-96
 9a0:	ec86                	sd	ra,88(sp)
 9a2:	e8a2                	sd	s0,80(sp)
 9a4:	e0ca                	sd	s2,64(sp)
 9a6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 9a8:	0005c903          	lbu	s2,0(a1)
 9ac:	28090663          	beqz	s2,c38 <vprintf+0x29a>
 9b0:	e4a6                	sd	s1,72(sp)
 9b2:	fc4e                	sd	s3,56(sp)
 9b4:	f852                	sd	s4,48(sp)
 9b6:	f456                	sd	s5,40(sp)
 9b8:	f05a                	sd	s6,32(sp)
 9ba:	ec5e                	sd	s7,24(sp)
 9bc:	e862                	sd	s8,16(sp)
 9be:	e466                	sd	s9,8(sp)
 9c0:	8b2a                	mv	s6,a0
 9c2:	8a2e                	mv	s4,a1
 9c4:	8bb2                	mv	s7,a2
  state = 0;
 9c6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 9c8:	4481                	li	s1,0
 9ca:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 9cc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 9d0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 9d4:	06c00c93          	li	s9,108
 9d8:	a005                	j	9f8 <vprintf+0x5a>
        putc(fd, c0);
 9da:	85ca                	mv	a1,s2
 9dc:	855a                	mv	a0,s6
 9de:	f07ff0ef          	jal	8e4 <putc>
 9e2:	a019                	j	9e8 <vprintf+0x4a>
    } else if(state == '%'){
 9e4:	03598263          	beq	s3,s5,a08 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 9e8:	2485                	addiw	s1,s1,1
 9ea:	8726                	mv	a4,s1
 9ec:	009a07b3          	add	a5,s4,s1
 9f0:	0007c903          	lbu	s2,0(a5)
 9f4:	22090a63          	beqz	s2,c28 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 9f8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 9fc:	fe0994e3          	bnez	s3,9e4 <vprintf+0x46>
      if(c0 == '%'){
 a00:	fd579de3          	bne	a5,s5,9da <vprintf+0x3c>
        state = '%';
 a04:	89be                	mv	s3,a5
 a06:	b7cd                	j	9e8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 a08:	00ea06b3          	add	a3,s4,a4
 a0c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 a10:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 a12:	c681                	beqz	a3,a1a <vprintf+0x7c>
 a14:	9752                	add	a4,a4,s4
 a16:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 a1a:	05878363          	beq	a5,s8,a60 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 a1e:	05978d63          	beq	a5,s9,a78 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 a22:	07500713          	li	a4,117
 a26:	0ee78763          	beq	a5,a4,b14 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 a2a:	07800713          	li	a4,120
 a2e:	12e78963          	beq	a5,a4,b60 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 a32:	07000713          	li	a4,112
 a36:	14e78e63          	beq	a5,a4,b92 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 a3a:	06300713          	li	a4,99
 a3e:	18e78e63          	beq	a5,a4,bda <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 a42:	07300713          	li	a4,115
 a46:	1ae78463          	beq	a5,a4,bee <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 a4a:	02500713          	li	a4,37
 a4e:	04e79563          	bne	a5,a4,a98 <vprintf+0xfa>
        putc(fd, '%');
 a52:	02500593          	li	a1,37
 a56:	855a                	mv	a0,s6
 a58:	e8dff0ef          	jal	8e4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 a5c:	4981                	li	s3,0
 a5e:	b769                	j	9e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 a60:	008b8913          	addi	s2,s7,8
 a64:	4685                	li	a3,1
 a66:	4629                	li	a2,10
 a68:	000ba583          	lw	a1,0(s7)
 a6c:	855a                	mv	a0,s6
 a6e:	e95ff0ef          	jal	902 <printint>
 a72:	8bca                	mv	s7,s2
      state = 0;
 a74:	4981                	li	s3,0
 a76:	bf8d                	j	9e8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 a78:	06400793          	li	a5,100
 a7c:	02f68963          	beq	a3,a5,aae <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 a80:	06c00793          	li	a5,108
 a84:	04f68263          	beq	a3,a5,ac8 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 a88:	07500793          	li	a5,117
 a8c:	0af68063          	beq	a3,a5,b2c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 a90:	07800793          	li	a5,120
 a94:	0ef68263          	beq	a3,a5,b78 <vprintf+0x1da>
        putc(fd, '%');
 a98:	02500593          	li	a1,37
 a9c:	855a                	mv	a0,s6
 a9e:	e47ff0ef          	jal	8e4 <putc>
        putc(fd, c0);
 aa2:	85ca                	mv	a1,s2
 aa4:	855a                	mv	a0,s6
 aa6:	e3fff0ef          	jal	8e4 <putc>
      state = 0;
 aaa:	4981                	li	s3,0
 aac:	bf35                	j	9e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 aae:	008b8913          	addi	s2,s7,8
 ab2:	4685                	li	a3,1
 ab4:	4629                	li	a2,10
 ab6:	000bb583          	ld	a1,0(s7)
 aba:	855a                	mv	a0,s6
 abc:	e47ff0ef          	jal	902 <printint>
        i += 1;
 ac0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 ac2:	8bca                	mv	s7,s2
      state = 0;
 ac4:	4981                	li	s3,0
        i += 1;
 ac6:	b70d                	j	9e8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 ac8:	06400793          	li	a5,100
 acc:	02f60763          	beq	a2,a5,afa <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 ad0:	07500793          	li	a5,117
 ad4:	06f60963          	beq	a2,a5,b46 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 ad8:	07800793          	li	a5,120
 adc:	faf61ee3          	bne	a2,a5,a98 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 ae0:	008b8913          	addi	s2,s7,8
 ae4:	4681                	li	a3,0
 ae6:	4641                	li	a2,16
 ae8:	000bb583          	ld	a1,0(s7)
 aec:	855a                	mv	a0,s6
 aee:	e15ff0ef          	jal	902 <printint>
        i += 2;
 af2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 af4:	8bca                	mv	s7,s2
      state = 0;
 af6:	4981                	li	s3,0
        i += 2;
 af8:	bdc5                	j	9e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 afa:	008b8913          	addi	s2,s7,8
 afe:	4685                	li	a3,1
 b00:	4629                	li	a2,10
 b02:	000bb583          	ld	a1,0(s7)
 b06:	855a                	mv	a0,s6
 b08:	dfbff0ef          	jal	902 <printint>
        i += 2;
 b0c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 b0e:	8bca                	mv	s7,s2
      state = 0;
 b10:	4981                	li	s3,0
        i += 2;
 b12:	bdd9                	j	9e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 b14:	008b8913          	addi	s2,s7,8
 b18:	4681                	li	a3,0
 b1a:	4629                	li	a2,10
 b1c:	000be583          	lwu	a1,0(s7)
 b20:	855a                	mv	a0,s6
 b22:	de1ff0ef          	jal	902 <printint>
 b26:	8bca                	mv	s7,s2
      state = 0;
 b28:	4981                	li	s3,0
 b2a:	bd7d                	j	9e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b2c:	008b8913          	addi	s2,s7,8
 b30:	4681                	li	a3,0
 b32:	4629                	li	a2,10
 b34:	000bb583          	ld	a1,0(s7)
 b38:	855a                	mv	a0,s6
 b3a:	dc9ff0ef          	jal	902 <printint>
        i += 1;
 b3e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 b40:	8bca                	mv	s7,s2
      state = 0;
 b42:	4981                	li	s3,0
        i += 1;
 b44:	b555                	j	9e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b46:	008b8913          	addi	s2,s7,8
 b4a:	4681                	li	a3,0
 b4c:	4629                	li	a2,10
 b4e:	000bb583          	ld	a1,0(s7)
 b52:	855a                	mv	a0,s6
 b54:	dafff0ef          	jal	902 <printint>
        i += 2;
 b58:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 b5a:	8bca                	mv	s7,s2
      state = 0;
 b5c:	4981                	li	s3,0
        i += 2;
 b5e:	b569                	j	9e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 b60:	008b8913          	addi	s2,s7,8
 b64:	4681                	li	a3,0
 b66:	4641                	li	a2,16
 b68:	000be583          	lwu	a1,0(s7)
 b6c:	855a                	mv	a0,s6
 b6e:	d95ff0ef          	jal	902 <printint>
 b72:	8bca                	mv	s7,s2
      state = 0;
 b74:	4981                	li	s3,0
 b76:	bd8d                	j	9e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 b78:	008b8913          	addi	s2,s7,8
 b7c:	4681                	li	a3,0
 b7e:	4641                	li	a2,16
 b80:	000bb583          	ld	a1,0(s7)
 b84:	855a                	mv	a0,s6
 b86:	d7dff0ef          	jal	902 <printint>
        i += 1;
 b8a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 b8c:	8bca                	mv	s7,s2
      state = 0;
 b8e:	4981                	li	s3,0
        i += 1;
 b90:	bda1                	j	9e8 <vprintf+0x4a>
 b92:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 b94:	008b8d13          	addi	s10,s7,8
 b98:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 b9c:	03000593          	li	a1,48
 ba0:	855a                	mv	a0,s6
 ba2:	d43ff0ef          	jal	8e4 <putc>
  putc(fd, 'x');
 ba6:	07800593          	li	a1,120
 baa:	855a                	mv	a0,s6
 bac:	d39ff0ef          	jal	8e4 <putc>
 bb0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bb2:	00000b97          	auipc	s7,0x0
 bb6:	53eb8b93          	addi	s7,s7,1342 # 10f0 <digits>
 bba:	03c9d793          	srli	a5,s3,0x3c
 bbe:	97de                	add	a5,a5,s7
 bc0:	0007c583          	lbu	a1,0(a5)
 bc4:	855a                	mv	a0,s6
 bc6:	d1fff0ef          	jal	8e4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bca:	0992                	slli	s3,s3,0x4
 bcc:	397d                	addiw	s2,s2,-1
 bce:	fe0916e3          	bnez	s2,bba <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 bd2:	8bea                	mv	s7,s10
      state = 0;
 bd4:	4981                	li	s3,0
 bd6:	6d02                	ld	s10,0(sp)
 bd8:	bd01                	j	9e8 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 bda:	008b8913          	addi	s2,s7,8
 bde:	000bc583          	lbu	a1,0(s7)
 be2:	855a                	mv	a0,s6
 be4:	d01ff0ef          	jal	8e4 <putc>
 be8:	8bca                	mv	s7,s2
      state = 0;
 bea:	4981                	li	s3,0
 bec:	bbf5                	j	9e8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 bee:	008b8993          	addi	s3,s7,8
 bf2:	000bb903          	ld	s2,0(s7)
 bf6:	00090f63          	beqz	s2,c14 <vprintf+0x276>
        for(; *s; s++)
 bfa:	00094583          	lbu	a1,0(s2)
 bfe:	c195                	beqz	a1,c22 <vprintf+0x284>
          putc(fd, *s);
 c00:	855a                	mv	a0,s6
 c02:	ce3ff0ef          	jal	8e4 <putc>
        for(; *s; s++)
 c06:	0905                	addi	s2,s2,1
 c08:	00094583          	lbu	a1,0(s2)
 c0c:	f9f5                	bnez	a1,c00 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 c0e:	8bce                	mv	s7,s3
      state = 0;
 c10:	4981                	li	s3,0
 c12:	bbd9                	j	9e8 <vprintf+0x4a>
          s = "(null)";
 c14:	00000917          	auipc	s2,0x0
 c18:	4a490913          	addi	s2,s2,1188 # 10b8 <malloc+0x398>
        for(; *s; s++)
 c1c:	02800593          	li	a1,40
 c20:	b7c5                	j	c00 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 c22:	8bce                	mv	s7,s3
      state = 0;
 c24:	4981                	li	s3,0
 c26:	b3c9                	j	9e8 <vprintf+0x4a>
 c28:	64a6                	ld	s1,72(sp)
 c2a:	79e2                	ld	s3,56(sp)
 c2c:	7a42                	ld	s4,48(sp)
 c2e:	7aa2                	ld	s5,40(sp)
 c30:	7b02                	ld	s6,32(sp)
 c32:	6be2                	ld	s7,24(sp)
 c34:	6c42                	ld	s8,16(sp)
 c36:	6ca2                	ld	s9,8(sp)
    }
  }
}
 c38:	60e6                	ld	ra,88(sp)
 c3a:	6446                	ld	s0,80(sp)
 c3c:	6906                	ld	s2,64(sp)
 c3e:	6125                	addi	sp,sp,96
 c40:	8082                	ret

0000000000000c42 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c42:	715d                	addi	sp,sp,-80
 c44:	ec06                	sd	ra,24(sp)
 c46:	e822                	sd	s0,16(sp)
 c48:	1000                	addi	s0,sp,32
 c4a:	e010                	sd	a2,0(s0)
 c4c:	e414                	sd	a3,8(s0)
 c4e:	e818                	sd	a4,16(s0)
 c50:	ec1c                	sd	a5,24(s0)
 c52:	03043023          	sd	a6,32(s0)
 c56:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c5a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c5e:	8622                	mv	a2,s0
 c60:	d3fff0ef          	jal	99e <vprintf>
}
 c64:	60e2                	ld	ra,24(sp)
 c66:	6442                	ld	s0,16(sp)
 c68:	6161                	addi	sp,sp,80
 c6a:	8082                	ret

0000000000000c6c <printf>:

void
printf(const char *fmt, ...)
{
 c6c:	711d                	addi	sp,sp,-96
 c6e:	ec06                	sd	ra,24(sp)
 c70:	e822                	sd	s0,16(sp)
 c72:	1000                	addi	s0,sp,32
 c74:	e40c                	sd	a1,8(s0)
 c76:	e810                	sd	a2,16(s0)
 c78:	ec14                	sd	a3,24(s0)
 c7a:	f018                	sd	a4,32(s0)
 c7c:	f41c                	sd	a5,40(s0)
 c7e:	03043823          	sd	a6,48(s0)
 c82:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 c86:	00840613          	addi	a2,s0,8
 c8a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 c8e:	85aa                	mv	a1,a0
 c90:	4505                	li	a0,1
 c92:	d0dff0ef          	jal	99e <vprintf>
}
 c96:	60e2                	ld	ra,24(sp)
 c98:	6442                	ld	s0,16(sp)
 c9a:	6125                	addi	sp,sp,96
 c9c:	8082                	ret

0000000000000c9e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c9e:	1141                	addi	sp,sp,-16
 ca0:	e422                	sd	s0,8(sp)
 ca2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ca4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ca8:	00001797          	auipc	a5,0x1
 cac:	3587b783          	ld	a5,856(a5) # 2000 <freep>
 cb0:	a02d                	j	cda <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cb2:	4618                	lw	a4,8(a2)
 cb4:	9f2d                	addw	a4,a4,a1
 cb6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 cba:	6398                	ld	a4,0(a5)
 cbc:	6310                	ld	a2,0(a4)
 cbe:	a83d                	j	cfc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 cc0:	ff852703          	lw	a4,-8(a0)
 cc4:	9f31                	addw	a4,a4,a2
 cc6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 cc8:	ff053683          	ld	a3,-16(a0)
 ccc:	a091                	j	d10 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cce:	6398                	ld	a4,0(a5)
 cd0:	00e7e463          	bltu	a5,a4,cd8 <free+0x3a>
 cd4:	00e6ea63          	bltu	a3,a4,ce8 <free+0x4a>
{
 cd8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cda:	fed7fae3          	bgeu	a5,a3,cce <free+0x30>
 cde:	6398                	ld	a4,0(a5)
 ce0:	00e6e463          	bltu	a3,a4,ce8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ce4:	fee7eae3          	bltu	a5,a4,cd8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 ce8:	ff852583          	lw	a1,-8(a0)
 cec:	6390                	ld	a2,0(a5)
 cee:	02059813          	slli	a6,a1,0x20
 cf2:	01c85713          	srli	a4,a6,0x1c
 cf6:	9736                	add	a4,a4,a3
 cf8:	fae60de3          	beq	a2,a4,cb2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 cfc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d00:	4790                	lw	a2,8(a5)
 d02:	02061593          	slli	a1,a2,0x20
 d06:	01c5d713          	srli	a4,a1,0x1c
 d0a:	973e                	add	a4,a4,a5
 d0c:	fae68ae3          	beq	a3,a4,cc0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 d10:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d12:	00001717          	auipc	a4,0x1
 d16:	2ef73723          	sd	a5,750(a4) # 2000 <freep>
}
 d1a:	6422                	ld	s0,8(sp)
 d1c:	0141                	addi	sp,sp,16
 d1e:	8082                	ret

0000000000000d20 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d20:	7139                	addi	sp,sp,-64
 d22:	fc06                	sd	ra,56(sp)
 d24:	f822                	sd	s0,48(sp)
 d26:	f426                	sd	s1,40(sp)
 d28:	ec4e                	sd	s3,24(sp)
 d2a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d2c:	02051493          	slli	s1,a0,0x20
 d30:	9081                	srli	s1,s1,0x20
 d32:	04bd                	addi	s1,s1,15
 d34:	8091                	srli	s1,s1,0x4
 d36:	0014899b          	addiw	s3,s1,1
 d3a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d3c:	00001517          	auipc	a0,0x1
 d40:	2c453503          	ld	a0,708(a0) # 2000 <freep>
 d44:	c915                	beqz	a0,d78 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d46:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d48:	4798                	lw	a4,8(a5)
 d4a:	08977a63          	bgeu	a4,s1,dde <malloc+0xbe>
 d4e:	f04a                	sd	s2,32(sp)
 d50:	e852                	sd	s4,16(sp)
 d52:	e456                	sd	s5,8(sp)
 d54:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 d56:	8a4e                	mv	s4,s3
 d58:	0009871b          	sext.w	a4,s3
 d5c:	6685                	lui	a3,0x1
 d5e:	00d77363          	bgeu	a4,a3,d64 <malloc+0x44>
 d62:	6a05                	lui	s4,0x1
 d64:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d68:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 d6c:	00001917          	auipc	s2,0x1
 d70:	29490913          	addi	s2,s2,660 # 2000 <freep>
  if(p == SBRK_ERROR)
 d74:	5afd                	li	s5,-1
 d76:	a081                	j	db6 <malloc+0x96>
 d78:	f04a                	sd	s2,32(sp)
 d7a:	e852                	sd	s4,16(sp)
 d7c:	e456                	sd	s5,8(sp)
 d7e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 d80:	00006797          	auipc	a5,0x6
 d84:	b4078793          	addi	a5,a5,-1216 # 68c0 <base>
 d88:	00001717          	auipc	a4,0x1
 d8c:	26f73c23          	sd	a5,632(a4) # 2000 <freep>
 d90:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 d92:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 d96:	b7c1                	j	d56 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 d98:	6398                	ld	a4,0(a5)
 d9a:	e118                	sd	a4,0(a0)
 d9c:	a8a9                	j	df6 <malloc+0xd6>
  hp->s.size = nu;
 d9e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 da2:	0541                	addi	a0,a0,16
 da4:	efbff0ef          	jal	c9e <free>
  return freep;
 da8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 dac:	c12d                	beqz	a0,e0e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 db0:	4798                	lw	a4,8(a5)
 db2:	02977263          	bgeu	a4,s1,dd6 <malloc+0xb6>
    if(p == freep)
 db6:	00093703          	ld	a4,0(s2)
 dba:	853e                	mv	a0,a5
 dbc:	fef719e3          	bne	a4,a5,dae <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 dc0:	8552                	mv	a0,s4
 dc2:	a1fff0ef          	jal	7e0 <sbrk>
  if(p == SBRK_ERROR)
 dc6:	fd551ce3          	bne	a0,s5,d9e <malloc+0x7e>
        return 0;
 dca:	4501                	li	a0,0
 dcc:	7902                	ld	s2,32(sp)
 dce:	6a42                	ld	s4,16(sp)
 dd0:	6aa2                	ld	s5,8(sp)
 dd2:	6b02                	ld	s6,0(sp)
 dd4:	a03d                	j	e02 <malloc+0xe2>
 dd6:	7902                	ld	s2,32(sp)
 dd8:	6a42                	ld	s4,16(sp)
 dda:	6aa2                	ld	s5,8(sp)
 ddc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 dde:	fae48de3          	beq	s1,a4,d98 <malloc+0x78>
        p->s.size -= nunits;
 de2:	4137073b          	subw	a4,a4,s3
 de6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 de8:	02071693          	slli	a3,a4,0x20
 dec:	01c6d713          	srli	a4,a3,0x1c
 df0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 df2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 df6:	00001717          	auipc	a4,0x1
 dfa:	20a73523          	sd	a0,522(a4) # 2000 <freep>
      return (void*)(p + 1);
 dfe:	01078513          	addi	a0,a5,16
  }
}
 e02:	70e2                	ld	ra,56(sp)
 e04:	7442                	ld	s0,48(sp)
 e06:	74a2                	ld	s1,40(sp)
 e08:	69e2                	ld	s3,24(sp)
 e0a:	6121                	addi	sp,sp,64
 e0c:	8082                	ret
 e0e:	7902                	ld	s2,32(sp)
 e10:	6a42                	ld	s4,16(sp)
 e12:	6aa2                	ld	s5,8(sp)
 e14:	6b02                	ld	s6,0(sp)
 e16:	b7f5                	j	e02 <malloc+0xe2>
