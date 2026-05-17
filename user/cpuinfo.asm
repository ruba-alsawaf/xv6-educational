
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
 120:	582000ef          	jal	6a2 <memset>

    append_str(buf, &pos, "EV {\"seq\":");
 124:	00001617          	auipc	a2,0x1
 128:	d9c60613          	addi	a2,a2,-612 # ec0 <malloc+0x100>
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
 14a:	d8a60613          	addi	a2,a2,-630 # ed0 <malloc+0x110>
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
 16c:	d7860613          	addi	a2,a2,-648 # ee0 <malloc+0x120>
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
 18e:	d5e60613          	addi	a2,a2,-674 # ee8 <malloc+0x128>
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
 1b0:	d4460613          	addi	a2,a2,-700 # ef0 <malloc+0x130>
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
 1d4:	d3060613          	addi	a2,a2,-720 # f00 <malloc+0x140>
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
 1f6:	d1e60613          	addi	a2,a2,-738 # f10 <malloc+0x150>
 1fa:	bdc40593          	addi	a1,s0,-1060
 1fe:	be040513          	addi	a0,s0,-1056
 202:	dffff0ef          	jal	0 <append_str>

    write(1, buf, pos);
 206:	bdc42603          	lw	a2,-1060(s0)
 20a:	be040593          	addi	a1,s0,-1056
 20e:	4505                	li	a0,1
 210:	6c4000ef          	jal	8d4 <write>
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
 24a:	458000ef          	jal	6a2 <memset>
    append_str(buf, &pos, "EV {\"seq\":");
 24e:	00001617          	auipc	a2,0x1
 252:	c7260613          	addi	a2,a2,-910 # ec0 <malloc+0x100>
 256:	bdc40593          	addi	a1,s0,-1060
 25a:	be040513          	addi	a0,s0,-1056
 25e:	da3ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, (uint)e->seq);
 262:	0004c783          	lbu	a5,0(s1)
 266:	0014c703          	lbu	a4,1(s1)
 26a:	0722                	slli	a4,a4,0x8
 26c:	8f5d                	or	a4,a4,a5
 26e:	0024c783          	lbu	a5,2(s1)
 272:	07c2                	slli	a5,a5,0x10
 274:	8fd9                	or	a5,a5,a4
 276:	0034c603          	lbu	a2,3(s1)
 27a:	0662                	slli	a2,a2,0x18
 27c:	8e5d                	or	a2,a2,a5
 27e:	2601                	sext.w	a2,a2
 280:	bdc40593          	addi	a1,s0,-1060
 284:	be040513          	addi	a0,s0,-1056
 288:	dadff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"tick\":");
 28c:	00001617          	auipc	a2,0x1
 290:	c4460613          	addi	a2,a2,-956 # ed0 <malloc+0x110>
 294:	bdc40593          	addi	a1,s0,-1060
 298:	be040513          	addi	a0,s0,-1056
 29c:	d65ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->ticks);
 2a0:	0084c783          	lbu	a5,8(s1)
 2a4:	0094c703          	lbu	a4,9(s1)
 2a8:	0722                	slli	a4,a4,0x8
 2aa:	8f5d                	or	a4,a4,a5
 2ac:	00a4c783          	lbu	a5,10(s1)
 2b0:	07c2                	slli	a5,a5,0x10
 2b2:	8fd9                	or	a5,a5,a4
 2b4:	00b4c603          	lbu	a2,11(s1)
 2b8:	0662                	slli	a2,a2,0x18
 2ba:	8e5d                	or	a2,a2,a5
 2bc:	2601                	sext.w	a2,a2
 2be:	bdc40593          	addi	a1,s0,-1060
 2c2:	be040513          	addi	a0,s0,-1056
 2c6:	d6fff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"type\":\"FS\",\"fs_event_type\":"); 
 2ca:	00001617          	auipc	a2,0x1
 2ce:	c5e60613          	addi	a2,a2,-930 # f28 <malloc+0x168>
 2d2:	bdc40593          	addi	a1,s0,-1060
 2d6:	be040513          	addi	a0,s0,-1056
 2da:	d27ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->type); 
 2de:	00c4c783          	lbu	a5,12(s1)
 2e2:	00d4c703          	lbu	a4,13(s1)
 2e6:	0722                	slli	a4,a4,0x8
 2e8:	8f5d                	or	a4,a4,a5
 2ea:	00e4c783          	lbu	a5,14(s1)
 2ee:	07c2                	slli	a5,a5,0x10
 2f0:	8fd9                	or	a5,a5,a4
 2f2:	00f4c603          	lbu	a2,15(s1)
 2f6:	0662                	slli	a2,a2,0x18
 2f8:	8e5d                	or	a2,a2,a5
 2fa:	2601                	sext.w	a2,a2
 2fc:	bdc40593          	addi	a1,s0,-1060
 300:	be040513          	addi	a0,s0,-1056
 304:	dbfff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"pid\":");
 308:	00001617          	auipc	a2,0x1
 30c:	be060613          	addi	a2,a2,-1056 # ee8 <malloc+0x128>
 310:	bdc40593          	addi	a1,s0,-1060
 314:	be040513          	addi	a0,s0,-1056
 318:	ce9ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->pid);
 31c:	0104c783          	lbu	a5,16(s1)
 320:	0114c703          	lbu	a4,17(s1)
 324:	0722                	slli	a4,a4,0x8
 326:	8f5d                	or	a4,a4,a5
 328:	0124c783          	lbu	a5,18(s1)
 32c:	07c2                	slli	a5,a5,0x10
 32e:	8fd9                	or	a5,a5,a4
 330:	0134c603          	lbu	a2,19(s1)
 334:	0662                	slli	a2,a2,0x18
 336:	8e5d                	or	a2,a2,a5
 338:	2601                	sext.w	a2,a2
 33a:	bdc40593          	addi	a1,s0,-1060
 33e:	be040513          	addi	a0,s0,-1056
 342:	d81ff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"inum\":");
 346:	00001617          	auipc	a2,0x1
 34a:	c0260613          	addi	a2,a2,-1022 # f48 <malloc+0x188>
 34e:	bdc40593          	addi	a1,s0,-1060
 352:	be040513          	addi	a0,s0,-1056
 356:	cabff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->inum);
 35a:	0144c783          	lbu	a5,20(s1)
 35e:	0154c703          	lbu	a4,21(s1)
 362:	0722                	slli	a4,a4,0x8
 364:	8f5d                	or	a4,a4,a5
 366:	0164c783          	lbu	a5,22(s1)
 36a:	07c2                	slli	a5,a5,0x10
 36c:	8fd9                	or	a5,a5,a4
 36e:	0174c603          	lbu	a2,23(s1)
 372:	0662                	slli	a2,a2,0x18
 374:	8e5d                	or	a2,a2,a5
 376:	2601                	sext.w	a2,a2
 378:	bdc40593          	addi	a1,s0,-1060
 37c:	be040513          	addi	a0,s0,-1056
 380:	d43ff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"block\":");
 384:	00001617          	auipc	a2,0x1
 388:	bd460613          	addi	a2,a2,-1068 # f58 <malloc+0x198>
 38c:	bdc40593          	addi	a1,s0,-1060
 390:	be040513          	addi	a0,s0,-1056
 394:	c6dff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->blockno);
 398:	0184c783          	lbu	a5,24(s1)
 39c:	0194c703          	lbu	a4,25(s1)
 3a0:	0722                	slli	a4,a4,0x8
 3a2:	8f5d                	or	a4,a4,a5
 3a4:	01a4c783          	lbu	a5,26(s1)
 3a8:	07c2                	slli	a5,a5,0x10
 3aa:	8fd9                	or	a5,a5,a4
 3ac:	01b4c603          	lbu	a2,27(s1)
 3b0:	0662                	slli	a2,a2,0x18
 3b2:	8e5d                	or	a2,a2,a5
 3b4:	2601                	sext.w	a2,a2
 3b6:	bdc40593          	addi	a1,s0,-1060
 3ba:	be040513          	addi	a0,s0,-1056
 3be:	d05ff0ef          	jal	c2 <append_int>
    append_str(buf, &pos, ",\"size\":");         
 3c2:	00001617          	auipc	a2,0x1
 3c6:	ba660613          	addi	a2,a2,-1114 # f68 <malloc+0x1a8>
 3ca:	bdc40593          	addi	a1,s0,-1060
 3ce:	be040513          	addi	a0,s0,-1056
 3d2:	c2fff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->size);
 3d6:	01c4c783          	lbu	a5,28(s1)
 3da:	01d4c703          	lbu	a4,29(s1)
 3de:	0722                	slli	a4,a4,0x8
 3e0:	8f5d                	or	a4,a4,a5
 3e2:	01e4c783          	lbu	a5,30(s1)
 3e6:	07c2                	slli	a5,a5,0x10
 3e8:	8fd9                	or	a5,a5,a4
 3ea:	01f4c603          	lbu	a2,31(s1)
 3ee:	0662                	slli	a2,a2,0x18
 3f0:	8e5d                	or	a2,a2,a5
 3f2:	2601                	sext.w	a2,a2
 3f4:	bdc40593          	addi	a1,s0,-1060
 3f8:	be040513          	addi	a0,s0,-1056
 3fc:	c39ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"name\":\"");
 400:	00001617          	auipc	a2,0x1
 404:	af060613          	addi	a2,a2,-1296 # ef0 <malloc+0x130>
 408:	bdc40593          	addi	a1,s0,-1060
 40c:	be040513          	addi	a0,s0,-1056
 410:	bf1ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
 414:	02048613          	addi	a2,s1,32
 418:	bdc40593          	addi	a1,s0,-1060
 41c:	be040513          	addi	a0,s0,-1056
 420:	be1ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"}\n");
 424:	00001617          	auipc	a2,0x1
 428:	b5460613          	addi	a2,a2,-1196 # f78 <malloc+0x1b8>
 42c:	bdc40593          	addi	a1,s0,-1060
 430:	be040513          	addi	a0,s0,-1056
 434:	bcdff0ef          	jal	0 <append_str>
    write(1, buf, pos);
 438:	bdc42603          	lw	a2,-1060(s0)
 43c:	be040593          	addi	a1,s0,-1056
 440:	4505                	li	a0,1
 442:	492000ef          	jal	8d4 <write>
}
 446:	42813083          	ld	ra,1064(sp)
 44a:	42013403          	ld	s0,1056(sp)
 44e:	41813483          	ld	s1,1048(sp)
 452:	43010113          	addi	sp,sp,1072
 456:	8082                	ret

0000000000000458 <main>:

int
main(void)
{
 458:	711d                	addi	sp,sp,-96
 45a:	ec86                	sd	ra,88(sp)
 45c:	e8a2                	sd	s0,80(sp)
 45e:	e4a6                	sd	s1,72(sp)
 460:	fc4e                	sd	s3,56(sp)
 462:	1080                	addi	s0,sp,96
    int n;

    memset(cpus, 0, sizeof(cpus));
 464:	00002497          	auipc	s1,0x2
 468:	bac48493          	addi	s1,s1,-1108 # 2010 <cpus>
 46c:	14000613          	li	a2,320
 470:	4581                	li	a1,0
 472:	8526                	mv	a0,s1
 474:	22e000ef          	jal	6a2 <memset>
    memset(&stats, 0, sizeof(stats));
 478:	07000613          	li	a2,112
 47c:	4581                	li	a1,0
 47e:	00002517          	auipc	a0,0x2
 482:	cd250513          	addi	a0,a0,-814 # 2150 <stats>
 486:	21c000ef          	jal	6a2 <memset>

    n = getcpuinfo(cpus, NCPU);
 48a:	45a1                	li	a1,8
 48c:	8526                	mv	a0,s1
 48e:	4ae000ef          	jal	93c <getcpuinfo>
    if (n < 0 || getprocstats(&stats) < 0) {
 492:	00054b63          	bltz	a0,4a8 <main+0x50>
 496:	89aa                	mv	s3,a0
 498:	00002517          	auipc	a0,0x2
 49c:	cb850513          	addi	a0,a0,-840 # 2150 <stats>
 4a0:	4a4000ef          	jal	944 <getprocstats>
 4a4:	02055263          	bgez	a0,4c8 <main+0x70>
 4a8:	e0ca                	sd	s2,64(sp)
 4aa:	f852                	sd	s4,48(sp)
 4ac:	f456                	sd	s5,40(sp)
 4ae:	f05a                	sd	s6,32(sp)
 4b0:	ec5e                	sd	s7,24(sp)
 4b2:	e862                	sd	s8,16(sp)
 4b4:	e466                	sd	s9,8(sp)
        printf("Error fetching system info\n");
 4b6:	00001517          	auipc	a0,0x1
 4ba:	ad250513          	addi	a0,a0,-1326 # f88 <malloc+0x1c8>
 4be:	04f000ef          	jal	d0c <printf>
        exit(1);
 4c2:	4505                	li	a0,1
 4c4:	3f0000ef          	jal	8b4 <exit>
 4c8:	e0ca                	sd	s2,64(sp)
 4ca:	f852                	sd	s4,48(sp)
 4cc:	f456                	sd	s5,40(sp)
 4ce:	f05a                	sd	s6,32(sp)
 4d0:	ec5e                	sd	s7,24(sp)
 4d2:	e862                	sd	s8,16(sp)
 4d4:	e466                	sd	s9,8(sp)
    }

    // 1. طباعة حالة المعالجات الحالية
    printf("CPU {\"timestamp\":\"now\",\"system\":{");
 4d6:	00001517          	auipc	a0,0x1
 4da:	ad250513          	addi	a0,a0,-1326 # fa8 <malloc+0x1e8>
 4de:	02f000ef          	jal	d0c <printf>
    printf("\"total_created\":%lu,\"total_exited\":%lu,", stats.total_created, stats.total_exited);
 4e2:	00002497          	auipc	s1,0x2
 4e6:	b2e48493          	addi	s1,s1,-1234 # 2010 <cpus>
 4ea:	1a84b603          	ld	a2,424(s1)
 4ee:	1a04b583          	ld	a1,416(s1)
 4f2:	00001517          	auipc	a0,0x1
 4f6:	ade50513          	addi	a0,a0,-1314 # fd0 <malloc+0x210>
 4fa:	013000ef          	jal	d0c <printf>
    printf("\"ever_running\":%lu,\"ever_sleeping\":%lu,\"ever_zombie\":%lu},", 
 4fe:	1984b683          	ld	a3,408(s1)
 502:	1804b603          	ld	a2,384(s1)
 506:	1904b583          	ld	a1,400(s1)
 50a:	00001517          	auipc	a0,0x1
 50e:	aee50513          	addi	a0,a0,-1298 # ff8 <malloc+0x238>
 512:	7fa000ef          	jal	d0c <printf>
            stats.unique_count[4], stats.unique_count[2], stats.unique_count[5]);

    printf("\"cpus\":[");
 516:	00001517          	auipc	a0,0x1
 51a:	b2250513          	addi	a0,a0,-1246 # 1038 <malloc+0x278>
 51e:	7ee000ef          	jal	d0c <printf>
    for (int i = 0; i < n; i++) {
 522:	07305663          	blez	s3,58e <main+0x136>
 526:	8926                	mv	s2,s1
 528:	4481                	li	s1,0
        int state_idx = cpus[i].current_state;
        const char *st_name = "UNK";
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 52a:	4b95                	li	s7,5
        const char *st_name = "UNK";
 52c:	00001b17          	auipc	s6,0x1
 530:	a54b0b13          	addi	s6,s6,-1452 # f80 <malloc+0x1c0>
            st_name = state_names[state_idx];
 534:	00001c17          	auipc	s8,0x1
 538:	bc4c0c13          	addi	s8,s8,-1084 # 10f8 <state_names>
        }

        printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"busy_percent\":%d}",
 53c:	00001a97          	auipc	s5,0x1
 540:	b0ca8a93          	addi	s5,s5,-1268 # 1048 <malloc+0x288>
               cpus[i].cpu, cpus[i].active, cpus[i].current_pid, st_name, cpus[i].busy_percent);
        
        if (i < n - 1) printf(",");
 544:	fff98a1b          	addiw	s4,s3,-1
 548:	00001c97          	auipc	s9,0x1
 54c:	b58c8c93          	addi	s9,s9,-1192 # 10a0 <malloc+0x2e0>
 550:	a839                	j	56e <main+0x116>
        printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"busy_percent\":%d}",
 552:	519c                	lw	a5,32(a1)
 554:	4594                	lw	a3,8(a1)
 556:	41d0                	lw	a2,4(a1)
 558:	418c                	lw	a1,0(a1)
 55a:	8556                	mv	a0,s5
 55c:	7b0000ef          	jal	d0c <printf>
        if (i < n - 1) printf(",");
 560:	0344c363          	blt	s1,s4,586 <main+0x12e>
    for (int i = 0; i < n; i++) {
 564:	2485                	addiw	s1,s1,1
 566:	02890913          	addi	s2,s2,40
 56a:	02998263          	beq	s3,s1,58e <main+0x136>
        int state_idx = cpus[i].current_state;
 56e:	85ca                	mv	a1,s2
 570:	00c92783          	lw	a5,12(s2)
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 574:	0007869b          	sext.w	a3,a5
        const char *st_name = "UNK";
 578:	875a                	mv	a4,s6
        if (state_idx >= 0 && state_idx < PROC_STATE_COUNT) {
 57a:	fcdbece3          	bltu	s7,a3,552 <main+0xfa>
            st_name = state_names[state_idx];
 57e:	078e                	slli	a5,a5,0x3
 580:	97e2                	add	a5,a5,s8
 582:	6398                	ld	a4,0(a5)
 584:	b7f9                	j	552 <main+0xfa>
        if (i < n - 1) printf(",");
 586:	8566                	mv	a0,s9
 588:	784000ef          	jal	d0c <printf>
 58c:	bfe1                	j	564 <main+0x10c>
    }
    printf("]}\n");
 58e:	00001517          	auipc	a0,0x1
 592:	b1a50513          	addi	a0,a0,-1254 # 10a8 <malloc+0x2e8>
 596:	776000ef          	jal	d0c <printf>

   // 2. قراءة أحداث المعالج المتوفرة في البفر حالياً
    int n_cs = csread(cs_ev, 32);
 59a:	02000593          	li	a1,32
 59e:	00002517          	auipc	a0,0x2
 5a2:	c2250513          	addi	a0,a0,-990 # 21c0 <cs_ev>
 5a6:	3be000ef          	jal	964 <csread>
    for (int i = 0; i < n_cs; i++) { // الدوران فقط حتى n_cs الحقيقية
 5aa:	02a05963          	blez	a0,5dc <main+0x184>
 5ae:	00002497          	auipc	s1,0x2
 5b2:	c1248493          	addi	s1,s1,-1006 # 21c0 <cs_ev>
 5b6:	03000793          	li	a5,48
 5ba:	02f50533          	mul	a0,a0,a5
 5be:	00950933          	add	s2,a0,s1
        if (cs_ev[i].type == 1) 
 5c2:	4985                	li	s3,1
 5c4:	a029                	j	5ce <main+0x176>
    for (int i = 0; i < n_cs; i++) { // الدوران فقط حتى n_cs الحقيقية
 5c6:	03048493          	addi	s1,s1,48
 5ca:	01248963          	beq	s1,s2,5dc <main+0x184>
        if (cs_ev[i].type == 1) 
 5ce:	489c                	lw	a5,16(s1)
 5d0:	ff379be3          	bne	a5,s3,5c6 <main+0x16e>
            print_cs_event(&cs_ev[i]);
 5d4:	8526                	mv	a0,s1
 5d6:	b27ff0ef          	jal	fc <print_cs_event>
 5da:	b7f5                	j	5c6 <main+0x16e>
    }

    
// 3. قراءة أحداث نظام الملفات المتوفرة في البفر حالياً
    int n_fs = fsread(fs_ev, 32);
 5dc:	02000593          	li	a1,32
 5e0:	00002517          	auipc	a0,0x2
 5e4:	1e050513          	addi	a0,a0,480 # 27c0 <fs_ev>
 5e8:	384000ef          	jal	96c <fsread>
    for (int i = 0; i < n_fs; i++) { 
 5ec:	02a05763          	blez	a0,61a <main+0x1c2>
 5f0:	00002497          	auipc	s1,0x2
 5f4:	1d048493          	addi	s1,s1,464 # 27c0 <fs_ev>
 5f8:	03000793          	li	a5,48
 5fc:	02f50533          	mul	a0,a0,a5
 600:	00950933          	add	s2,a0,s1
 604:	a029                	j	60e <main+0x1b6>
 606:	03048493          	addi	s1,s1,48
 60a:	01248863          	beq	s1,s2,61a <main+0x1c2>
        // إذا كان الـ seq مصفراً، فهذا مخلفات بافر، لا تطبعه
        if (fs_ev[i].seq != 0) {
 60e:	609c                	ld	a5,0(s1)
 610:	dbfd                	beqz	a5,606 <main+0x1ae>
            print_fs_event(&fs_ev[i]);
 612:	8526                	mv	a0,s1
 614:	c13ff0ef          	jal	226 <print_fs_event>
 618:	b7fd                	j	606 <main+0x1ae>
        }
    }
    // الخروج وإنهاء البرنامج فوراً دون الدخول في حلقة لانهائية
    exit(0); 
 61a:	4501                	li	a0,0
 61c:	298000ef          	jal	8b4 <exit>

0000000000000620 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 620:	1141                	addi	sp,sp,-16
 622:	e406                	sd	ra,8(sp)
 624:	e022                	sd	s0,0(sp)
 626:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 628:	e31ff0ef          	jal	458 <main>
  exit(r);
 62c:	288000ef          	jal	8b4 <exit>

0000000000000630 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 630:	1141                	addi	sp,sp,-16
 632:	e422                	sd	s0,8(sp)
 634:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 636:	87aa                	mv	a5,a0
 638:	0585                	addi	a1,a1,1
 63a:	0785                	addi	a5,a5,1
 63c:	fff5c703          	lbu	a4,-1(a1)
 640:	fee78fa3          	sb	a4,-1(a5)
 644:	fb75                	bnez	a4,638 <strcpy+0x8>
    ;
  return os;
}
 646:	6422                	ld	s0,8(sp)
 648:	0141                	addi	sp,sp,16
 64a:	8082                	ret

000000000000064c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 64c:	1141                	addi	sp,sp,-16
 64e:	e422                	sd	s0,8(sp)
 650:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 652:	00054783          	lbu	a5,0(a0)
 656:	cb91                	beqz	a5,66a <strcmp+0x1e>
 658:	0005c703          	lbu	a4,0(a1)
 65c:	00f71763          	bne	a4,a5,66a <strcmp+0x1e>
    p++, q++;
 660:	0505                	addi	a0,a0,1
 662:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 664:	00054783          	lbu	a5,0(a0)
 668:	fbe5                	bnez	a5,658 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 66a:	0005c503          	lbu	a0,0(a1)
}
 66e:	40a7853b          	subw	a0,a5,a0
 672:	6422                	ld	s0,8(sp)
 674:	0141                	addi	sp,sp,16
 676:	8082                	ret

0000000000000678 <strlen>:

uint
strlen(const char *s)
{
 678:	1141                	addi	sp,sp,-16
 67a:	e422                	sd	s0,8(sp)
 67c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 67e:	00054783          	lbu	a5,0(a0)
 682:	cf91                	beqz	a5,69e <strlen+0x26>
 684:	0505                	addi	a0,a0,1
 686:	87aa                	mv	a5,a0
 688:	86be                	mv	a3,a5
 68a:	0785                	addi	a5,a5,1
 68c:	fff7c703          	lbu	a4,-1(a5)
 690:	ff65                	bnez	a4,688 <strlen+0x10>
 692:	40a6853b          	subw	a0,a3,a0
 696:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 698:	6422                	ld	s0,8(sp)
 69a:	0141                	addi	sp,sp,16
 69c:	8082                	ret
  for(n = 0; s[n]; n++)
 69e:	4501                	li	a0,0
 6a0:	bfe5                	j	698 <strlen+0x20>

00000000000006a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 6a2:	1141                	addi	sp,sp,-16
 6a4:	e422                	sd	s0,8(sp)
 6a6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 6a8:	ca19                	beqz	a2,6be <memset+0x1c>
 6aa:	87aa                	mv	a5,a0
 6ac:	1602                	slli	a2,a2,0x20
 6ae:	9201                	srli	a2,a2,0x20
 6b0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 6b4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 6b8:	0785                	addi	a5,a5,1
 6ba:	fee79de3          	bne	a5,a4,6b4 <memset+0x12>
  }
  return dst;
}
 6be:	6422                	ld	s0,8(sp)
 6c0:	0141                	addi	sp,sp,16
 6c2:	8082                	ret

00000000000006c4 <strchr>:

char*
strchr(const char *s, char c)
{
 6c4:	1141                	addi	sp,sp,-16
 6c6:	e422                	sd	s0,8(sp)
 6c8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 6ca:	00054783          	lbu	a5,0(a0)
 6ce:	cb99                	beqz	a5,6e4 <strchr+0x20>
    if(*s == c)
 6d0:	00f58763          	beq	a1,a5,6de <strchr+0x1a>
  for(; *s; s++)
 6d4:	0505                	addi	a0,a0,1
 6d6:	00054783          	lbu	a5,0(a0)
 6da:	fbfd                	bnez	a5,6d0 <strchr+0xc>
      return (char*)s;
  return 0;
 6dc:	4501                	li	a0,0
}
 6de:	6422                	ld	s0,8(sp)
 6e0:	0141                	addi	sp,sp,16
 6e2:	8082                	ret
  return 0;
 6e4:	4501                	li	a0,0
 6e6:	bfe5                	j	6de <strchr+0x1a>

00000000000006e8 <gets>:

char*
gets(char *buf, int max)
{
 6e8:	711d                	addi	sp,sp,-96
 6ea:	ec86                	sd	ra,88(sp)
 6ec:	e8a2                	sd	s0,80(sp)
 6ee:	e4a6                	sd	s1,72(sp)
 6f0:	e0ca                	sd	s2,64(sp)
 6f2:	fc4e                	sd	s3,56(sp)
 6f4:	f852                	sd	s4,48(sp)
 6f6:	f456                	sd	s5,40(sp)
 6f8:	f05a                	sd	s6,32(sp)
 6fa:	ec5e                	sd	s7,24(sp)
 6fc:	1080                	addi	s0,sp,96
 6fe:	8baa                	mv	s7,a0
 700:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 702:	892a                	mv	s2,a0
 704:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 706:	4aa9                	li	s5,10
 708:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 70a:	89a6                	mv	s3,s1
 70c:	2485                	addiw	s1,s1,1
 70e:	0344d663          	bge	s1,s4,73a <gets+0x52>
    cc = read(0, &c, 1);
 712:	4605                	li	a2,1
 714:	faf40593          	addi	a1,s0,-81
 718:	4501                	li	a0,0
 71a:	1b2000ef          	jal	8cc <read>
    if(cc < 1)
 71e:	00a05e63          	blez	a0,73a <gets+0x52>
    buf[i++] = c;
 722:	faf44783          	lbu	a5,-81(s0)
 726:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 72a:	01578763          	beq	a5,s5,738 <gets+0x50>
 72e:	0905                	addi	s2,s2,1
 730:	fd679de3          	bne	a5,s6,70a <gets+0x22>
    buf[i++] = c;
 734:	89a6                	mv	s3,s1
 736:	a011                	j	73a <gets+0x52>
 738:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 73a:	99de                	add	s3,s3,s7
 73c:	00098023          	sb	zero,0(s3)
  return buf;
}
 740:	855e                	mv	a0,s7
 742:	60e6                	ld	ra,88(sp)
 744:	6446                	ld	s0,80(sp)
 746:	64a6                	ld	s1,72(sp)
 748:	6906                	ld	s2,64(sp)
 74a:	79e2                	ld	s3,56(sp)
 74c:	7a42                	ld	s4,48(sp)
 74e:	7aa2                	ld	s5,40(sp)
 750:	7b02                	ld	s6,32(sp)
 752:	6be2                	ld	s7,24(sp)
 754:	6125                	addi	sp,sp,96
 756:	8082                	ret

0000000000000758 <stat>:

int
stat(const char *n, struct stat *st)
{
 758:	1101                	addi	sp,sp,-32
 75a:	ec06                	sd	ra,24(sp)
 75c:	e822                	sd	s0,16(sp)
 75e:	e04a                	sd	s2,0(sp)
 760:	1000                	addi	s0,sp,32
 762:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 764:	4581                	li	a1,0
 766:	18e000ef          	jal	8f4 <open>
  if(fd < 0)
 76a:	02054263          	bltz	a0,78e <stat+0x36>
 76e:	e426                	sd	s1,8(sp)
 770:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 772:	85ca                	mv	a1,s2
 774:	198000ef          	jal	90c <fstat>
 778:	892a                	mv	s2,a0
  close(fd);
 77a:	8526                	mv	a0,s1
 77c:	160000ef          	jal	8dc <close>
  return r;
 780:	64a2                	ld	s1,8(sp)
}
 782:	854a                	mv	a0,s2
 784:	60e2                	ld	ra,24(sp)
 786:	6442                	ld	s0,16(sp)
 788:	6902                	ld	s2,0(sp)
 78a:	6105                	addi	sp,sp,32
 78c:	8082                	ret
    return -1;
 78e:	597d                	li	s2,-1
 790:	bfcd                	j	782 <stat+0x2a>

0000000000000792 <atoi>:

int
atoi(const char *s)
{
 792:	1141                	addi	sp,sp,-16
 794:	e422                	sd	s0,8(sp)
 796:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 798:	00054683          	lbu	a3,0(a0)
 79c:	fd06879b          	addiw	a5,a3,-48
 7a0:	0ff7f793          	zext.b	a5,a5
 7a4:	4625                	li	a2,9
 7a6:	02f66863          	bltu	a2,a5,7d6 <atoi+0x44>
 7aa:	872a                	mv	a4,a0
  n = 0;
 7ac:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 7ae:	0705                	addi	a4,a4,1
 7b0:	0025179b          	slliw	a5,a0,0x2
 7b4:	9fa9                	addw	a5,a5,a0
 7b6:	0017979b          	slliw	a5,a5,0x1
 7ba:	9fb5                	addw	a5,a5,a3
 7bc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 7c0:	00074683          	lbu	a3,0(a4)
 7c4:	fd06879b          	addiw	a5,a3,-48
 7c8:	0ff7f793          	zext.b	a5,a5
 7cc:	fef671e3          	bgeu	a2,a5,7ae <atoi+0x1c>
  return n;
}
 7d0:	6422                	ld	s0,8(sp)
 7d2:	0141                	addi	sp,sp,16
 7d4:	8082                	ret
  n = 0;
 7d6:	4501                	li	a0,0
 7d8:	bfe5                	j	7d0 <atoi+0x3e>

00000000000007da <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 7da:	1141                	addi	sp,sp,-16
 7dc:	e422                	sd	s0,8(sp)
 7de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 7e0:	02b57463          	bgeu	a0,a1,808 <memmove+0x2e>
    while(n-- > 0)
 7e4:	00c05f63          	blez	a2,802 <memmove+0x28>
 7e8:	1602                	slli	a2,a2,0x20
 7ea:	9201                	srli	a2,a2,0x20
 7ec:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 7f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 7f2:	0585                	addi	a1,a1,1
 7f4:	0705                	addi	a4,a4,1
 7f6:	fff5c683          	lbu	a3,-1(a1)
 7fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 7fe:	fef71ae3          	bne	a4,a5,7f2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 802:	6422                	ld	s0,8(sp)
 804:	0141                	addi	sp,sp,16
 806:	8082                	ret
    dst += n;
 808:	00c50733          	add	a4,a0,a2
    src += n;
 80c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 80e:	fec05ae3          	blez	a2,802 <memmove+0x28>
 812:	fff6079b          	addiw	a5,a2,-1
 816:	1782                	slli	a5,a5,0x20
 818:	9381                	srli	a5,a5,0x20
 81a:	fff7c793          	not	a5,a5
 81e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 820:	15fd                	addi	a1,a1,-1
 822:	177d                	addi	a4,a4,-1
 824:	0005c683          	lbu	a3,0(a1)
 828:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 82c:	fee79ae3          	bne	a5,a4,820 <memmove+0x46>
 830:	bfc9                	j	802 <memmove+0x28>

0000000000000832 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 832:	1141                	addi	sp,sp,-16
 834:	e422                	sd	s0,8(sp)
 836:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 838:	ca05                	beqz	a2,868 <memcmp+0x36>
 83a:	fff6069b          	addiw	a3,a2,-1
 83e:	1682                	slli	a3,a3,0x20
 840:	9281                	srli	a3,a3,0x20
 842:	0685                	addi	a3,a3,1
 844:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 846:	00054783          	lbu	a5,0(a0)
 84a:	0005c703          	lbu	a4,0(a1)
 84e:	00e79863          	bne	a5,a4,85e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 852:	0505                	addi	a0,a0,1
    p2++;
 854:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 856:	fed518e3          	bne	a0,a3,846 <memcmp+0x14>
  }
  return 0;
 85a:	4501                	li	a0,0
 85c:	a019                	j	862 <memcmp+0x30>
      return *p1 - *p2;
 85e:	40e7853b          	subw	a0,a5,a4
}
 862:	6422                	ld	s0,8(sp)
 864:	0141                	addi	sp,sp,16
 866:	8082                	ret
  return 0;
 868:	4501                	li	a0,0
 86a:	bfe5                	j	862 <memcmp+0x30>

000000000000086c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 86c:	1141                	addi	sp,sp,-16
 86e:	e406                	sd	ra,8(sp)
 870:	e022                	sd	s0,0(sp)
 872:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 874:	f67ff0ef          	jal	7da <memmove>
}
 878:	60a2                	ld	ra,8(sp)
 87a:	6402                	ld	s0,0(sp)
 87c:	0141                	addi	sp,sp,16
 87e:	8082                	ret

0000000000000880 <sbrk>:

char *
sbrk(int n) {
 880:	1141                	addi	sp,sp,-16
 882:	e406                	sd	ra,8(sp)
 884:	e022                	sd	s0,0(sp)
 886:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 888:	4585                	li	a1,1
 88a:	0c2000ef          	jal	94c <sys_sbrk>
}
 88e:	60a2                	ld	ra,8(sp)
 890:	6402                	ld	s0,0(sp)
 892:	0141                	addi	sp,sp,16
 894:	8082                	ret

0000000000000896 <sbrklazy>:

char *
sbrklazy(int n) {
 896:	1141                	addi	sp,sp,-16
 898:	e406                	sd	ra,8(sp)
 89a:	e022                	sd	s0,0(sp)
 89c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 89e:	4589                	li	a1,2
 8a0:	0ac000ef          	jal	94c <sys_sbrk>
}
 8a4:	60a2                	ld	ra,8(sp)
 8a6:	6402                	ld	s0,0(sp)
 8a8:	0141                	addi	sp,sp,16
 8aa:	8082                	ret

00000000000008ac <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 8ac:	4885                	li	a7,1
 ecall
 8ae:	00000073          	ecall
 ret
 8b2:	8082                	ret

00000000000008b4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 8b4:	4889                	li	a7,2
 ecall
 8b6:	00000073          	ecall
 ret
 8ba:	8082                	ret

00000000000008bc <wait>:
.global wait
wait:
 li a7, SYS_wait
 8bc:	488d                	li	a7,3
 ecall
 8be:	00000073          	ecall
 ret
 8c2:	8082                	ret

00000000000008c4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 8c4:	4891                	li	a7,4
 ecall
 8c6:	00000073          	ecall
 ret
 8ca:	8082                	ret

00000000000008cc <read>:
.global read
read:
 li a7, SYS_read
 8cc:	4895                	li	a7,5
 ecall
 8ce:	00000073          	ecall
 ret
 8d2:	8082                	ret

00000000000008d4 <write>:
.global write
write:
 li a7, SYS_write
 8d4:	48c1                	li	a7,16
 ecall
 8d6:	00000073          	ecall
 ret
 8da:	8082                	ret

00000000000008dc <close>:
.global close
close:
 li a7, SYS_close
 8dc:	48d5                	li	a7,21
 ecall
 8de:	00000073          	ecall
 ret
 8e2:	8082                	ret

00000000000008e4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 8e4:	4899                	li	a7,6
 ecall
 8e6:	00000073          	ecall
 ret
 8ea:	8082                	ret

00000000000008ec <exec>:
.global exec
exec:
 li a7, SYS_exec
 8ec:	489d                	li	a7,7
 ecall
 8ee:	00000073          	ecall
 ret
 8f2:	8082                	ret

00000000000008f4 <open>:
.global open
open:
 li a7, SYS_open
 8f4:	48bd                	li	a7,15
 ecall
 8f6:	00000073          	ecall
 ret
 8fa:	8082                	ret

00000000000008fc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 8fc:	48c5                	li	a7,17
 ecall
 8fe:	00000073          	ecall
 ret
 902:	8082                	ret

0000000000000904 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 904:	48c9                	li	a7,18
 ecall
 906:	00000073          	ecall
 ret
 90a:	8082                	ret

000000000000090c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 90c:	48a1                	li	a7,8
 ecall
 90e:	00000073          	ecall
 ret
 912:	8082                	ret

0000000000000914 <link>:
.global link
link:
 li a7, SYS_link
 914:	48cd                	li	a7,19
 ecall
 916:	00000073          	ecall
 ret
 91a:	8082                	ret

000000000000091c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 91c:	48d1                	li	a7,20
 ecall
 91e:	00000073          	ecall
 ret
 922:	8082                	ret

0000000000000924 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 924:	48a5                	li	a7,9
 ecall
 926:	00000073          	ecall
 ret
 92a:	8082                	ret

000000000000092c <dup>:
.global dup
dup:
 li a7, SYS_dup
 92c:	48a9                	li	a7,10
 ecall
 92e:	00000073          	ecall
 ret
 932:	8082                	ret

0000000000000934 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 934:	48ad                	li	a7,11
 ecall
 936:	00000073          	ecall
 ret
 93a:	8082                	ret

000000000000093c <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 93c:	48e9                	li	a7,26
 ecall
 93e:	00000073          	ecall
 ret
 942:	8082                	ret

0000000000000944 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 944:	48ed                	li	a7,27
 ecall
 946:	00000073          	ecall
 ret
 94a:	8082                	ret

000000000000094c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 94c:	48b1                	li	a7,12
 ecall
 94e:	00000073          	ecall
 ret
 952:	8082                	ret

0000000000000954 <pause>:
.global pause
pause:
 li a7, SYS_pause
 954:	48b5                	li	a7,13
 ecall
 956:	00000073          	ecall
 ret
 95a:	8082                	ret

000000000000095c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 95c:	48b9                	li	a7,14
 ecall
 95e:	00000073          	ecall
 ret
 962:	8082                	ret

0000000000000964 <csread>:
.global csread
csread:
 li a7, SYS_csread
 964:	48d9                	li	a7,22
 ecall
 966:	00000073          	ecall
 ret
 96a:	8082                	ret

000000000000096c <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 96c:	48dd                	li	a7,23
 ecall
 96e:	00000073          	ecall
 ret
 972:	8082                	ret

0000000000000974 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 974:	48e1                	li	a7,24
 ecall
 976:	00000073          	ecall
 ret
 97a:	8082                	ret

000000000000097c <memread>:
.global memread
memread:
 li a7, SYS_memread
 97c:	48e5                	li	a7,25
 ecall
 97e:	00000073          	ecall
 ret
 982:	8082                	ret

0000000000000984 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 984:	1101                	addi	sp,sp,-32
 986:	ec06                	sd	ra,24(sp)
 988:	e822                	sd	s0,16(sp)
 98a:	1000                	addi	s0,sp,32
 98c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 990:	4605                	li	a2,1
 992:	fef40593          	addi	a1,s0,-17
 996:	f3fff0ef          	jal	8d4 <write>
}
 99a:	60e2                	ld	ra,24(sp)
 99c:	6442                	ld	s0,16(sp)
 99e:	6105                	addi	sp,sp,32
 9a0:	8082                	ret

00000000000009a2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 9a2:	715d                	addi	sp,sp,-80
 9a4:	e486                	sd	ra,72(sp)
 9a6:	e0a2                	sd	s0,64(sp)
 9a8:	f84a                	sd	s2,48(sp)
 9aa:	0880                	addi	s0,sp,80
 9ac:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 9ae:	c299                	beqz	a3,9b4 <printint+0x12>
 9b0:	0805c363          	bltz	a1,a36 <printint+0x94>
  neg = 0;
 9b4:	4881                	li	a7,0
 9b6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 9ba:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 9bc:	00000517          	auipc	a0,0x0
 9c0:	76c50513          	addi	a0,a0,1900 # 1128 <digits>
 9c4:	883e                	mv	a6,a5
 9c6:	2785                	addiw	a5,a5,1
 9c8:	02c5f733          	remu	a4,a1,a2
 9cc:	972a                	add	a4,a4,a0
 9ce:	00074703          	lbu	a4,0(a4)
 9d2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 9d6:	872e                	mv	a4,a1
 9d8:	02c5d5b3          	divu	a1,a1,a2
 9dc:	0685                	addi	a3,a3,1
 9de:	fec773e3          	bgeu	a4,a2,9c4 <printint+0x22>
  if(neg)
 9e2:	00088b63          	beqz	a7,9f8 <printint+0x56>
    buf[i++] = '-';
 9e6:	fd078793          	addi	a5,a5,-48
 9ea:	97a2                	add	a5,a5,s0
 9ec:	02d00713          	li	a4,45
 9f0:	fee78423          	sb	a4,-24(a5)
 9f4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 9f8:	02f05a63          	blez	a5,a2c <printint+0x8a>
 9fc:	fc26                	sd	s1,56(sp)
 9fe:	f44e                	sd	s3,40(sp)
 a00:	fb840713          	addi	a4,s0,-72
 a04:	00f704b3          	add	s1,a4,a5
 a08:	fff70993          	addi	s3,a4,-1
 a0c:	99be                	add	s3,s3,a5
 a0e:	37fd                	addiw	a5,a5,-1
 a10:	1782                	slli	a5,a5,0x20
 a12:	9381                	srli	a5,a5,0x20
 a14:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 a18:	fff4c583          	lbu	a1,-1(s1)
 a1c:	854a                	mv	a0,s2
 a1e:	f67ff0ef          	jal	984 <putc>
  while(--i >= 0)
 a22:	14fd                	addi	s1,s1,-1
 a24:	ff349ae3          	bne	s1,s3,a18 <printint+0x76>
 a28:	74e2                	ld	s1,56(sp)
 a2a:	79a2                	ld	s3,40(sp)
}
 a2c:	60a6                	ld	ra,72(sp)
 a2e:	6406                	ld	s0,64(sp)
 a30:	7942                	ld	s2,48(sp)
 a32:	6161                	addi	sp,sp,80
 a34:	8082                	ret
    x = -xx;
 a36:	40b005b3          	neg	a1,a1
    neg = 1;
 a3a:	4885                	li	a7,1
    x = -xx;
 a3c:	bfad                	j	9b6 <printint+0x14>

0000000000000a3e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a3e:	711d                	addi	sp,sp,-96
 a40:	ec86                	sd	ra,88(sp)
 a42:	e8a2                	sd	s0,80(sp)
 a44:	e0ca                	sd	s2,64(sp)
 a46:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 a48:	0005c903          	lbu	s2,0(a1)
 a4c:	28090663          	beqz	s2,cd8 <vprintf+0x29a>
 a50:	e4a6                	sd	s1,72(sp)
 a52:	fc4e                	sd	s3,56(sp)
 a54:	f852                	sd	s4,48(sp)
 a56:	f456                	sd	s5,40(sp)
 a58:	f05a                	sd	s6,32(sp)
 a5a:	ec5e                	sd	s7,24(sp)
 a5c:	e862                	sd	s8,16(sp)
 a5e:	e466                	sd	s9,8(sp)
 a60:	8b2a                	mv	s6,a0
 a62:	8a2e                	mv	s4,a1
 a64:	8bb2                	mv	s7,a2
  state = 0;
 a66:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 a68:	4481                	li	s1,0
 a6a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 a6c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 a70:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 a74:	06c00c93          	li	s9,108
 a78:	a005                	j	a98 <vprintf+0x5a>
        putc(fd, c0);
 a7a:	85ca                	mv	a1,s2
 a7c:	855a                	mv	a0,s6
 a7e:	f07ff0ef          	jal	984 <putc>
 a82:	a019                	j	a88 <vprintf+0x4a>
    } else if(state == '%'){
 a84:	03598263          	beq	s3,s5,aa8 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 a88:	2485                	addiw	s1,s1,1
 a8a:	8726                	mv	a4,s1
 a8c:	009a07b3          	add	a5,s4,s1
 a90:	0007c903          	lbu	s2,0(a5)
 a94:	22090a63          	beqz	s2,cc8 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 a98:	0009079b          	sext.w	a5,s2
    if(state == 0){
 a9c:	fe0994e3          	bnez	s3,a84 <vprintf+0x46>
      if(c0 == '%'){
 aa0:	fd579de3          	bne	a5,s5,a7a <vprintf+0x3c>
        state = '%';
 aa4:	89be                	mv	s3,a5
 aa6:	b7cd                	j	a88 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 aa8:	00ea06b3          	add	a3,s4,a4
 aac:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 ab0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 ab2:	c681                	beqz	a3,aba <vprintf+0x7c>
 ab4:	9752                	add	a4,a4,s4
 ab6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 aba:	05878363          	beq	a5,s8,b00 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 abe:	05978d63          	beq	a5,s9,b18 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 ac2:	07500713          	li	a4,117
 ac6:	0ee78763          	beq	a5,a4,bb4 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 aca:	07800713          	li	a4,120
 ace:	12e78963          	beq	a5,a4,c00 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 ad2:	07000713          	li	a4,112
 ad6:	14e78e63          	beq	a5,a4,c32 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 ada:	06300713          	li	a4,99
 ade:	18e78e63          	beq	a5,a4,c7a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 ae2:	07300713          	li	a4,115
 ae6:	1ae78463          	beq	a5,a4,c8e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 aea:	02500713          	li	a4,37
 aee:	04e79563          	bne	a5,a4,b38 <vprintf+0xfa>
        putc(fd, '%');
 af2:	02500593          	li	a1,37
 af6:	855a                	mv	a0,s6
 af8:	e8dff0ef          	jal	984 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 afc:	4981                	li	s3,0
 afe:	b769                	j	a88 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 b00:	008b8913          	addi	s2,s7,8
 b04:	4685                	li	a3,1
 b06:	4629                	li	a2,10
 b08:	000ba583          	lw	a1,0(s7)
 b0c:	855a                	mv	a0,s6
 b0e:	e95ff0ef          	jal	9a2 <printint>
 b12:	8bca                	mv	s7,s2
      state = 0;
 b14:	4981                	li	s3,0
 b16:	bf8d                	j	a88 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 b18:	06400793          	li	a5,100
 b1c:	02f68963          	beq	a3,a5,b4e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 b20:	06c00793          	li	a5,108
 b24:	04f68263          	beq	a3,a5,b68 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 b28:	07500793          	li	a5,117
 b2c:	0af68063          	beq	a3,a5,bcc <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 b30:	07800793          	li	a5,120
 b34:	0ef68263          	beq	a3,a5,c18 <vprintf+0x1da>
        putc(fd, '%');
 b38:	02500593          	li	a1,37
 b3c:	855a                	mv	a0,s6
 b3e:	e47ff0ef          	jal	984 <putc>
        putc(fd, c0);
 b42:	85ca                	mv	a1,s2
 b44:	855a                	mv	a0,s6
 b46:	e3fff0ef          	jal	984 <putc>
      state = 0;
 b4a:	4981                	li	s3,0
 b4c:	bf35                	j	a88 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 b4e:	008b8913          	addi	s2,s7,8
 b52:	4685                	li	a3,1
 b54:	4629                	li	a2,10
 b56:	000bb583          	ld	a1,0(s7)
 b5a:	855a                	mv	a0,s6
 b5c:	e47ff0ef          	jal	9a2 <printint>
        i += 1;
 b60:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 b62:	8bca                	mv	s7,s2
      state = 0;
 b64:	4981                	li	s3,0
        i += 1;
 b66:	b70d                	j	a88 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 b68:	06400793          	li	a5,100
 b6c:	02f60763          	beq	a2,a5,b9a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 b70:	07500793          	li	a5,117
 b74:	06f60963          	beq	a2,a5,be6 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 b78:	07800793          	li	a5,120
 b7c:	faf61ee3          	bne	a2,a5,b38 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 b80:	008b8913          	addi	s2,s7,8
 b84:	4681                	li	a3,0
 b86:	4641                	li	a2,16
 b88:	000bb583          	ld	a1,0(s7)
 b8c:	855a                	mv	a0,s6
 b8e:	e15ff0ef          	jal	9a2 <printint>
        i += 2;
 b92:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 b94:	8bca                	mv	s7,s2
      state = 0;
 b96:	4981                	li	s3,0
        i += 2;
 b98:	bdc5                	j	a88 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 b9a:	008b8913          	addi	s2,s7,8
 b9e:	4685                	li	a3,1
 ba0:	4629                	li	a2,10
 ba2:	000bb583          	ld	a1,0(s7)
 ba6:	855a                	mv	a0,s6
 ba8:	dfbff0ef          	jal	9a2 <printint>
        i += 2;
 bac:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 bae:	8bca                	mv	s7,s2
      state = 0;
 bb0:	4981                	li	s3,0
        i += 2;
 bb2:	bdd9                	j	a88 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 bb4:	008b8913          	addi	s2,s7,8
 bb8:	4681                	li	a3,0
 bba:	4629                	li	a2,10
 bbc:	000be583          	lwu	a1,0(s7)
 bc0:	855a                	mv	a0,s6
 bc2:	de1ff0ef          	jal	9a2 <printint>
 bc6:	8bca                	mv	s7,s2
      state = 0;
 bc8:	4981                	li	s3,0
 bca:	bd7d                	j	a88 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 bcc:	008b8913          	addi	s2,s7,8
 bd0:	4681                	li	a3,0
 bd2:	4629                	li	a2,10
 bd4:	000bb583          	ld	a1,0(s7)
 bd8:	855a                	mv	a0,s6
 bda:	dc9ff0ef          	jal	9a2 <printint>
        i += 1;
 bde:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 be0:	8bca                	mv	s7,s2
      state = 0;
 be2:	4981                	li	s3,0
        i += 1;
 be4:	b555                	j	a88 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 be6:	008b8913          	addi	s2,s7,8
 bea:	4681                	li	a3,0
 bec:	4629                	li	a2,10
 bee:	000bb583          	ld	a1,0(s7)
 bf2:	855a                	mv	a0,s6
 bf4:	dafff0ef          	jal	9a2 <printint>
        i += 2;
 bf8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 bfa:	8bca                	mv	s7,s2
      state = 0;
 bfc:	4981                	li	s3,0
        i += 2;
 bfe:	b569                	j	a88 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 c00:	008b8913          	addi	s2,s7,8
 c04:	4681                	li	a3,0
 c06:	4641                	li	a2,16
 c08:	000be583          	lwu	a1,0(s7)
 c0c:	855a                	mv	a0,s6
 c0e:	d95ff0ef          	jal	9a2 <printint>
 c12:	8bca                	mv	s7,s2
      state = 0;
 c14:	4981                	li	s3,0
 c16:	bd8d                	j	a88 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 c18:	008b8913          	addi	s2,s7,8
 c1c:	4681                	li	a3,0
 c1e:	4641                	li	a2,16
 c20:	000bb583          	ld	a1,0(s7)
 c24:	855a                	mv	a0,s6
 c26:	d7dff0ef          	jal	9a2 <printint>
        i += 1;
 c2a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 c2c:	8bca                	mv	s7,s2
      state = 0;
 c2e:	4981                	li	s3,0
        i += 1;
 c30:	bda1                	j	a88 <vprintf+0x4a>
 c32:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 c34:	008b8d13          	addi	s10,s7,8
 c38:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 c3c:	03000593          	li	a1,48
 c40:	855a                	mv	a0,s6
 c42:	d43ff0ef          	jal	984 <putc>
  putc(fd, 'x');
 c46:	07800593          	li	a1,120
 c4a:	855a                	mv	a0,s6
 c4c:	d39ff0ef          	jal	984 <putc>
 c50:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c52:	00000b97          	auipc	s7,0x0
 c56:	4d6b8b93          	addi	s7,s7,1238 # 1128 <digits>
 c5a:	03c9d793          	srli	a5,s3,0x3c
 c5e:	97de                	add	a5,a5,s7
 c60:	0007c583          	lbu	a1,0(a5)
 c64:	855a                	mv	a0,s6
 c66:	d1fff0ef          	jal	984 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 c6a:	0992                	slli	s3,s3,0x4
 c6c:	397d                	addiw	s2,s2,-1
 c6e:	fe0916e3          	bnez	s2,c5a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 c72:	8bea                	mv	s7,s10
      state = 0;
 c74:	4981                	li	s3,0
 c76:	6d02                	ld	s10,0(sp)
 c78:	bd01                	j	a88 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 c7a:	008b8913          	addi	s2,s7,8
 c7e:	000bc583          	lbu	a1,0(s7)
 c82:	855a                	mv	a0,s6
 c84:	d01ff0ef          	jal	984 <putc>
 c88:	8bca                	mv	s7,s2
      state = 0;
 c8a:	4981                	li	s3,0
 c8c:	bbf5                	j	a88 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 c8e:	008b8993          	addi	s3,s7,8
 c92:	000bb903          	ld	s2,0(s7)
 c96:	00090f63          	beqz	s2,cb4 <vprintf+0x276>
        for(; *s; s++)
 c9a:	00094583          	lbu	a1,0(s2)
 c9e:	c195                	beqz	a1,cc2 <vprintf+0x284>
          putc(fd, *s);
 ca0:	855a                	mv	a0,s6
 ca2:	ce3ff0ef          	jal	984 <putc>
        for(; *s; s++)
 ca6:	0905                	addi	s2,s2,1
 ca8:	00094583          	lbu	a1,0(s2)
 cac:	f9f5                	bnez	a1,ca0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 cae:	8bce                	mv	s7,s3
      state = 0;
 cb0:	4981                	li	s3,0
 cb2:	bbd9                	j	a88 <vprintf+0x4a>
          s = "(null)";
 cb4:	00000917          	auipc	s2,0x0
 cb8:	43c90913          	addi	s2,s2,1084 # 10f0 <malloc+0x330>
        for(; *s; s++)
 cbc:	02800593          	li	a1,40
 cc0:	b7c5                	j	ca0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 cc2:	8bce                	mv	s7,s3
      state = 0;
 cc4:	4981                	li	s3,0
 cc6:	b3c9                	j	a88 <vprintf+0x4a>
 cc8:	64a6                	ld	s1,72(sp)
 cca:	79e2                	ld	s3,56(sp)
 ccc:	7a42                	ld	s4,48(sp)
 cce:	7aa2                	ld	s5,40(sp)
 cd0:	7b02                	ld	s6,32(sp)
 cd2:	6be2                	ld	s7,24(sp)
 cd4:	6c42                	ld	s8,16(sp)
 cd6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 cd8:	60e6                	ld	ra,88(sp)
 cda:	6446                	ld	s0,80(sp)
 cdc:	6906                	ld	s2,64(sp)
 cde:	6125                	addi	sp,sp,96
 ce0:	8082                	ret

0000000000000ce2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ce2:	715d                	addi	sp,sp,-80
 ce4:	ec06                	sd	ra,24(sp)
 ce6:	e822                	sd	s0,16(sp)
 ce8:	1000                	addi	s0,sp,32
 cea:	e010                	sd	a2,0(s0)
 cec:	e414                	sd	a3,8(s0)
 cee:	e818                	sd	a4,16(s0)
 cf0:	ec1c                	sd	a5,24(s0)
 cf2:	03043023          	sd	a6,32(s0)
 cf6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 cfa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 cfe:	8622                	mv	a2,s0
 d00:	d3fff0ef          	jal	a3e <vprintf>
}
 d04:	60e2                	ld	ra,24(sp)
 d06:	6442                	ld	s0,16(sp)
 d08:	6161                	addi	sp,sp,80
 d0a:	8082                	ret

0000000000000d0c <printf>:

void
printf(const char *fmt, ...)
{
 d0c:	711d                	addi	sp,sp,-96
 d0e:	ec06                	sd	ra,24(sp)
 d10:	e822                	sd	s0,16(sp)
 d12:	1000                	addi	s0,sp,32
 d14:	e40c                	sd	a1,8(s0)
 d16:	e810                	sd	a2,16(s0)
 d18:	ec14                	sd	a3,24(s0)
 d1a:	f018                	sd	a4,32(s0)
 d1c:	f41c                	sd	a5,40(s0)
 d1e:	03043823          	sd	a6,48(s0)
 d22:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 d26:	00840613          	addi	a2,s0,8
 d2a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 d2e:	85aa                	mv	a1,a0
 d30:	4505                	li	a0,1
 d32:	d0dff0ef          	jal	a3e <vprintf>
}
 d36:	60e2                	ld	ra,24(sp)
 d38:	6442                	ld	s0,16(sp)
 d3a:	6125                	addi	sp,sp,96
 d3c:	8082                	ret

0000000000000d3e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d3e:	1141                	addi	sp,sp,-16
 d40:	e422                	sd	s0,8(sp)
 d42:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d44:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d48:	00001797          	auipc	a5,0x1
 d4c:	2b87b783          	ld	a5,696(a5) # 2000 <freep>
 d50:	a02d                	j	d7a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 d52:	4618                	lw	a4,8(a2)
 d54:	9f2d                	addw	a4,a4,a1
 d56:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 d5a:	6398                	ld	a4,0(a5)
 d5c:	6310                	ld	a2,0(a4)
 d5e:	a83d                	j	d9c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 d60:	ff852703          	lw	a4,-8(a0)
 d64:	9f31                	addw	a4,a4,a2
 d66:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 d68:	ff053683          	ld	a3,-16(a0)
 d6c:	a091                	j	db0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d6e:	6398                	ld	a4,0(a5)
 d70:	00e7e463          	bltu	a5,a4,d78 <free+0x3a>
 d74:	00e6ea63          	bltu	a3,a4,d88 <free+0x4a>
{
 d78:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d7a:	fed7fae3          	bgeu	a5,a3,d6e <free+0x30>
 d7e:	6398                	ld	a4,0(a5)
 d80:	00e6e463          	bltu	a3,a4,d88 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d84:	fee7eae3          	bltu	a5,a4,d78 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 d88:	ff852583          	lw	a1,-8(a0)
 d8c:	6390                	ld	a2,0(a5)
 d8e:	02059813          	slli	a6,a1,0x20
 d92:	01c85713          	srli	a4,a6,0x1c
 d96:	9736                	add	a4,a4,a3
 d98:	fae60de3          	beq	a2,a4,d52 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 d9c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 da0:	4790                	lw	a2,8(a5)
 da2:	02061593          	slli	a1,a2,0x20
 da6:	01c5d713          	srli	a4,a1,0x1c
 daa:	973e                	add	a4,a4,a5
 dac:	fae68ae3          	beq	a3,a4,d60 <free+0x22>
    p->s.ptr = bp->s.ptr;
 db0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 db2:	00001717          	auipc	a4,0x1
 db6:	24f73723          	sd	a5,590(a4) # 2000 <freep>
}
 dba:	6422                	ld	s0,8(sp)
 dbc:	0141                	addi	sp,sp,16
 dbe:	8082                	ret

0000000000000dc0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 dc0:	7139                	addi	sp,sp,-64
 dc2:	fc06                	sd	ra,56(sp)
 dc4:	f822                	sd	s0,48(sp)
 dc6:	f426                	sd	s1,40(sp)
 dc8:	ec4e                	sd	s3,24(sp)
 dca:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 dcc:	02051493          	slli	s1,a0,0x20
 dd0:	9081                	srli	s1,s1,0x20
 dd2:	04bd                	addi	s1,s1,15
 dd4:	8091                	srli	s1,s1,0x4
 dd6:	0014899b          	addiw	s3,s1,1
 dda:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ddc:	00001517          	auipc	a0,0x1
 de0:	22453503          	ld	a0,548(a0) # 2000 <freep>
 de4:	c915                	beqz	a0,e18 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 de6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 de8:	4798                	lw	a4,8(a5)
 dea:	08977a63          	bgeu	a4,s1,e7e <malloc+0xbe>
 dee:	f04a                	sd	s2,32(sp)
 df0:	e852                	sd	s4,16(sp)
 df2:	e456                	sd	s5,8(sp)
 df4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 df6:	8a4e                	mv	s4,s3
 df8:	0009871b          	sext.w	a4,s3
 dfc:	6685                	lui	a3,0x1
 dfe:	00d77363          	bgeu	a4,a3,e04 <malloc+0x44>
 e02:	6a05                	lui	s4,0x1
 e04:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 e08:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 e0c:	00001917          	auipc	s2,0x1
 e10:	1f490913          	addi	s2,s2,500 # 2000 <freep>
  if(p == SBRK_ERROR)
 e14:	5afd                	li	s5,-1
 e16:	a081                	j	e56 <malloc+0x96>
 e18:	f04a                	sd	s2,32(sp)
 e1a:	e852                	sd	s4,16(sp)
 e1c:	e456                	sd	s5,8(sp)
 e1e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 e20:	00002797          	auipc	a5,0x2
 e24:	fa078793          	addi	a5,a5,-96 # 2dc0 <base>
 e28:	00001717          	auipc	a4,0x1
 e2c:	1cf73c23          	sd	a5,472(a4) # 2000 <freep>
 e30:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 e32:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 e36:	b7c1                	j	df6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 e38:	6398                	ld	a4,0(a5)
 e3a:	e118                	sd	a4,0(a0)
 e3c:	a8a9                	j	e96 <malloc+0xd6>
  hp->s.size = nu;
 e3e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 e42:	0541                	addi	a0,a0,16
 e44:	efbff0ef          	jal	d3e <free>
  return freep;
 e48:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 e4c:	c12d                	beqz	a0,eae <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e4e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e50:	4798                	lw	a4,8(a5)
 e52:	02977263          	bgeu	a4,s1,e76 <malloc+0xb6>
    if(p == freep)
 e56:	00093703          	ld	a4,0(s2)
 e5a:	853e                	mv	a0,a5
 e5c:	fef719e3          	bne	a4,a5,e4e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 e60:	8552                	mv	a0,s4
 e62:	a1fff0ef          	jal	880 <sbrk>
  if(p == SBRK_ERROR)
 e66:	fd551ce3          	bne	a0,s5,e3e <malloc+0x7e>
        return 0;
 e6a:	4501                	li	a0,0
 e6c:	7902                	ld	s2,32(sp)
 e6e:	6a42                	ld	s4,16(sp)
 e70:	6aa2                	ld	s5,8(sp)
 e72:	6b02                	ld	s6,0(sp)
 e74:	a03d                	j	ea2 <malloc+0xe2>
 e76:	7902                	ld	s2,32(sp)
 e78:	6a42                	ld	s4,16(sp)
 e7a:	6aa2                	ld	s5,8(sp)
 e7c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 e7e:	fae48de3          	beq	s1,a4,e38 <malloc+0x78>
        p->s.size -= nunits;
 e82:	4137073b          	subw	a4,a4,s3
 e86:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e88:	02071693          	slli	a3,a4,0x20
 e8c:	01c6d713          	srli	a4,a3,0x1c
 e90:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 e92:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e96:	00001717          	auipc	a4,0x1
 e9a:	16a73523          	sd	a0,362(a4) # 2000 <freep>
      return (void*)(p + 1);
 e9e:	01078513          	addi	a0,a5,16
  }
}
 ea2:	70e2                	ld	ra,56(sp)
 ea4:	7442                	ld	s0,48(sp)
 ea6:	74a2                	ld	s1,40(sp)
 ea8:	69e2                	ld	s3,24(sp)
 eaa:	6121                	addi	sp,sp,64
 eac:	8082                	ret
 eae:	7902                	ld	s2,32(sp)
 eb0:	6a42                	ld	s4,16(sp)
 eb2:	6aa2                	ld	s5,8(sp)
 eb4:	6b02                	ld	s6,0(sp)
 eb6:	b7f5                	j	ea2 <malloc+0xe2>
