
user/_csexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <append_str>:
static void append_char(char *buf, int *pos, char c) {
  if (*pos < OUTBUF_SZ - 1)
    buf[(*pos)++] = c;
}

static void append_str(char *buf, int *pos, const char *s) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    while (*s && *pos < OUTBUF_SZ - 1) buf[(*pos)++] = *s++;
   6:	00064783          	lbu	a5,0(a2)
   a:	7fe00693          	li	a3,2046
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

00000000000000b8 <append_int>:

static void append_int(char *buf, int *pos, int x) {
  b8:	1141                	addi	sp,sp,-16
  ba:	e406                	sd	ra,8(sp)
  bc:	e022                	sd	s0,0(sp)
  be:	0800                	addi	s0,sp,16
  if (x < 0) {
  c0:	00064863          	bltz	a2,d0 <append_int+0x18>
    append_char(buf, pos, '-');
    x = -x;
  }
  append_uint(buf, pos, (uint)x);
  c4:	f71ff0ef          	jal	34 <append_uint>
}
  c8:	60a2                	ld	ra,8(sp)
  ca:	6402                	ld	s0,0(sp)
  cc:	0141                	addi	sp,sp,16
  ce:	8082                	ret
  if (*pos < OUTBUF_SZ - 1)
  d0:	419c                	lw	a5,0(a1)
  d2:	7fe00713          	li	a4,2046
  d6:	00f74a63          	blt	a4,a5,ea <append_int+0x32>
    buf[(*pos)++] = c;
  da:	0017871b          	addiw	a4,a5,1
  de:	c198                	sw	a4,0(a1)
  e0:	97aa                	add	a5,a5,a0
  e2:	02d00713          	li	a4,45
  e6:	00e78023          	sb	a4,0(a5)
    x = -x;
  ea:	40c0063b          	negw	a2,a2
  ee:	bfd9                	j	c4 <append_int+0xc>

00000000000000f0 <print_fs_event>:
    }
  }
}

// دالة طباعة أحداث الفايل سستم
static void print_fs_event(const struct fs_event *e) {
  f0:	711d                	addi	sp,sp,-96
  f2:	ec86                	sd	ra,88(sp)
  f4:	e8a2                	sd	s0,80(sp)
  f6:	e4a6                	sd	s1,72(sp)
  f8:	e0ca                	sd	s2,64(sp)
  fa:	fc4e                	sd	s3,56(sp)
  fc:	1080                	addi	s0,sp,96
  fe:	81010113          	addi	sp,sp,-2032
 102:	84aa                	mv	s1,a0
  char buf[OUTBUF_SZ];
  int pos = 0;
 104:	77fd                	lui	a5,0xfffff
 106:	1781                	addi	a5,a5,-32 # ffffffffffffefe0 <base+0xffffffffffffcb10>
 108:	ff040713          	addi	a4,s0,-16
 10c:	97ba                	add	a5,a5,a4
 10e:	7e07ae23          	sw	zero,2044(a5)
  memset(buf, 0, sizeof(buf));
 112:	6605                	lui	a2,0x1
 114:	80060613          	addi	a2,a2,-2048 # 800 <memset+0x18>
 118:	4581                	li	a1,0
 11a:	797d                	lui	s2,0xfffff
 11c:	7e090513          	addi	a0,s2,2016 # fffffffffffff7e0 <base+0xffffffffffffd310>
 120:	953a                	add	a0,a0,a4
 122:	6c6000ef          	jal	7e8 <memset>

  append_str(buf, &pos, "EV {\"type\":\"FS\"");
 126:	77fd                	lui	a5,0xfffff
 128:	7dc78793          	addi	a5,a5,2012 # fffffffffffff7dc <base+0xffffffffffffd30c>
 12c:	ff040713          	addi	a4,s0,-16
 130:	97ba                	add	a5,a5,a4
 132:	79fd                	lui	s3,0xfffff
 134:	7c898713          	addi	a4,s3,1992 # fffffffffffff7c8 <base+0xffffffffffffd2f8>
 138:	ff040693          	addi	a3,s0,-16
 13c:	9736                	add	a4,a4,a3
 13e:	e31c                	sd	a5,0(a4)
 140:	00001617          	auipc	a2,0x1
 144:	ea060613          	addi	a2,a2,-352 # fe0 <malloc+0xfa>
 148:	7c898793          	addi	a5,s3,1992
 14c:	97b6                	add	a5,a5,a3
 14e:	638c                	ld	a1,0(a5)
 150:	7e090513          	addi	a0,s2,2016
 154:	9536                	add	a0,a0,a3
 156:	eabff0ef          	jal	0 <append_str>
  append_str(buf, &pos, ",\"seq\":"); append_uint(buf, &pos, (uint)e->seq);
 15a:	00001617          	auipc	a2,0x1
 15e:	e9660613          	addi	a2,a2,-362 # ff0 <malloc+0x10a>
 162:	7c898793          	addi	a5,s3,1992
 166:	ff040713          	addi	a4,s0,-16
 16a:	97ba                	add	a5,a5,a4
 16c:	638c                	ld	a1,0(a5)
 16e:	7e090513          	addi	a0,s2,2016
 172:	953a                	add	a0,a0,a4
 174:	e8dff0ef          	jal	0 <append_str>
 178:	4090                	lw	a2,0(s1)
 17a:	7c898793          	addi	a5,s3,1992
 17e:	ff040713          	addi	a4,s0,-16
 182:	97ba                	add	a5,a5,a4
 184:	638c                	ld	a1,0(a5)
 186:	7e090513          	addi	a0,s2,2016
 18a:	953a                	add	a0,a0,a4
 18c:	ea9ff0ef          	jal	34 <append_uint>
  append_str(buf, &pos, ",\"tick\":"); append_uint(buf, &pos, e->ticks);
 190:	00001617          	auipc	a2,0x1
 194:	e6860613          	addi	a2,a2,-408 # ff8 <malloc+0x112>
 198:	7c898793          	addi	a5,s3,1992
 19c:	ff040713          	addi	a4,s0,-16
 1a0:	97ba                	add	a5,a5,a4
 1a2:	638c                	ld	a1,0(a5)
 1a4:	7e090513          	addi	a0,s2,2016
 1a8:	953a                	add	a0,a0,a4
 1aa:	e57ff0ef          	jal	0 <append_str>
 1ae:	4490                	lw	a2,8(s1)
 1b0:	7c898793          	addi	a5,s3,1992
 1b4:	ff040713          	addi	a4,s0,-16
 1b8:	97ba                	add	a5,a5,a4
 1ba:	638c                	ld	a1,0(a5)
 1bc:	7e090513          	addi	a0,s2,2016
 1c0:	953a                	add	a0,a0,a4
 1c2:	e73ff0ef          	jal	34 <append_uint>
  append_str(buf, &pos, ",\"fs_type\":"); append_int(buf, &pos, e->type);
 1c6:	00001617          	auipc	a2,0x1
 1ca:	e4260613          	addi	a2,a2,-446 # 1008 <malloc+0x122>
 1ce:	7c898793          	addi	a5,s3,1992
 1d2:	ff040713          	addi	a4,s0,-16
 1d6:	97ba                	add	a5,a5,a4
 1d8:	638c                	ld	a1,0(a5)
 1da:	7e090513          	addi	a0,s2,2016
 1de:	953a                	add	a0,a0,a4
 1e0:	e21ff0ef          	jal	0 <append_str>
 1e4:	44d0                	lw	a2,12(s1)
 1e6:	7c898793          	addi	a5,s3,1992
 1ea:	ff040713          	addi	a4,s0,-16
 1ee:	97ba                	add	a5,a5,a4
 1f0:	638c                	ld	a1,0(a5)
 1f2:	7e090513          	addi	a0,s2,2016
 1f6:	953a                	add	a0,a0,a4
 1f8:	ec1ff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"pid\":"); append_int(buf, &pos, e->pid);
 1fc:	00001617          	auipc	a2,0x1
 200:	e1c60613          	addi	a2,a2,-484 # 1018 <malloc+0x132>
 204:	7c898793          	addi	a5,s3,1992
 208:	ff040713          	addi	a4,s0,-16
 20c:	97ba                	add	a5,a5,a4
 20e:	638c                	ld	a1,0(a5)
 210:	7e090513          	addi	a0,s2,2016
 214:	953a                	add	a0,a0,a4
 216:	debff0ef          	jal	0 <append_str>
 21a:	4890                	lw	a2,16(s1)
 21c:	7c898793          	addi	a5,s3,1992
 220:	ff040713          	addi	a4,s0,-16
 224:	97ba                	add	a5,a5,a4
 226:	638c                	ld	a1,0(a5)
 228:	7e090513          	addi	a0,s2,2016
 22c:	953a                	add	a0,a0,a4
 22e:	e8bff0ef          	jal	b8 <append_int>

  append_str(buf, &pos, ",\"dev\":"); append_int(buf, &pos, e->dev);
 232:	00001617          	auipc	a2,0x1
 236:	dee60613          	addi	a2,a2,-530 # 1020 <malloc+0x13a>
 23a:	7c898793          	addi	a5,s3,1992
 23e:	ff040713          	addi	a4,s0,-16
 242:	97ba                	add	a5,a5,a4
 244:	638c                	ld	a1,0(a5)
 246:	7e090513          	addi	a0,s2,2016
 24a:	953a                	add	a0,a0,a4
 24c:	db5ff0ef          	jal	0 <append_str>
 250:	48d0                	lw	a2,20(s1)
 252:	7c898793          	addi	a5,s3,1992
 256:	ff040713          	addi	a4,s0,-16
 25a:	97ba                	add	a5,a5,a4
 25c:	638c                	ld	a1,0(a5)
 25e:	7e090513          	addi	a0,s2,2016
 262:	953a                	add	a0,a0,a4
 264:	e55ff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"block\":"); append_int(buf, &pos, e->blockno);
 268:	00001617          	auipc	a2,0x1
 26c:	dc060613          	addi	a2,a2,-576 # 1028 <malloc+0x142>
 270:	7c898793          	addi	a5,s3,1992
 274:	ff040713          	addi	a4,s0,-16
 278:	97ba                	add	a5,a5,a4
 27a:	638c                	ld	a1,0(a5)
 27c:	7e090513          	addi	a0,s2,2016
 280:	953a                	add	a0,a0,a4
 282:	d7fff0ef          	jal	0 <append_str>
 286:	4c90                	lw	a2,24(s1)
 288:	7c898793          	addi	a5,s3,1992
 28c:	ff040713          	addi	a4,s0,-16
 290:	97ba                	add	a5,a5,a4
 292:	638c                	ld	a1,0(a5)
 294:	7e090513          	addi	a0,s2,2016
 298:	953a                	add	a0,a0,a4
 29a:	e1fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"old_block\":"); append_int(buf, &pos, e->old_blockno);
 29e:	00001617          	auipc	a2,0x1
 2a2:	d9a60613          	addi	a2,a2,-614 # 1038 <malloc+0x152>
 2a6:	7c898793          	addi	a5,s3,1992
 2aa:	ff040713          	addi	a4,s0,-16
 2ae:	97ba                	add	a5,a5,a4
 2b0:	638c                	ld	a1,0(a5)
 2b2:	7e090513          	addi	a0,s2,2016
 2b6:	953a                	add	a0,a0,a4
 2b8:	d49ff0ef          	jal	0 <append_str>
 2bc:	4cd0                	lw	a2,28(s1)
 2be:	7c898793          	addi	a5,s3,1992
 2c2:	ff040713          	addi	a4,s0,-16
 2c6:	97ba                	add	a5,a5,a4
 2c8:	638c                	ld	a1,0(a5)
 2ca:	7e090513          	addi	a0,s2,2016
 2ce:	953a                	add	a0,a0,a4
 2d0:	de9ff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"buf_id\":"); append_int(buf, &pos, e->buf_id);
 2d4:	00001617          	auipc	a2,0x1
 2d8:	d7460613          	addi	a2,a2,-652 # 1048 <malloc+0x162>
 2dc:	7c898793          	addi	a5,s3,1992
 2e0:	ff040713          	addi	a4,s0,-16
 2e4:	97ba                	add	a5,a5,a4
 2e6:	638c                	ld	a1,0(a5)
 2e8:	7e090513          	addi	a0,s2,2016
 2ec:	953a                	add	a0,a0,a4
 2ee:	d13ff0ef          	jal	0 <append_str>
 2f2:	5090                	lw	a2,32(s1)
 2f4:	7c898793          	addi	a5,s3,1992
 2f8:	ff040713          	addi	a4,s0,-16
 2fc:	97ba                	add	a5,a5,a4
 2fe:	638c                	ld	a1,0(a5)
 300:	7e090513          	addi	a0,s2,2016
 304:	953a                	add	a0,a0,a4
 306:	db3ff0ef          	jal	b8 <append_int>

  append_str(buf, &pos, ",\"ref_before\":"); append_int(buf, &pos, e->ref_before);
 30a:	00001617          	auipc	a2,0x1
 30e:	d4e60613          	addi	a2,a2,-690 # 1058 <malloc+0x172>
 312:	7c898793          	addi	a5,s3,1992
 316:	ff040713          	addi	a4,s0,-16
 31a:	97ba                	add	a5,a5,a4
 31c:	638c                	ld	a1,0(a5)
 31e:	7e090513          	addi	a0,s2,2016
 322:	953a                	add	a0,a0,a4
 324:	cddff0ef          	jal	0 <append_str>
 328:	50d0                	lw	a2,36(s1)
 32a:	7c898793          	addi	a5,s3,1992
 32e:	ff040713          	addi	a4,s0,-16
 332:	97ba                	add	a5,a5,a4
 334:	638c                	ld	a1,0(a5)
 336:	7e090513          	addi	a0,s2,2016
 33a:	953a                	add	a0,a0,a4
 33c:	d7dff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"ref_after\":"); append_int(buf, &pos, e->ref_after);
 340:	00001617          	auipc	a2,0x1
 344:	d2860613          	addi	a2,a2,-728 # 1068 <malloc+0x182>
 348:	7c898793          	addi	a5,s3,1992
 34c:	ff040713          	addi	a4,s0,-16
 350:	97ba                	add	a5,a5,a4
 352:	638c                	ld	a1,0(a5)
 354:	7e090513          	addi	a0,s2,2016
 358:	953a                	add	a0,a0,a4
 35a:	ca7ff0ef          	jal	0 <append_str>
 35e:	5490                	lw	a2,40(s1)
 360:	7c898793          	addi	a5,s3,1992
 364:	ff040713          	addi	a4,s0,-16
 368:	97ba                	add	a5,a5,a4
 36a:	638c                	ld	a1,0(a5)
 36c:	7e090513          	addi	a0,s2,2016
 370:	953a                	add	a0,a0,a4
 372:	d47ff0ef          	jal	b8 <append_int>

  append_str(buf, &pos, ",\"valid_before\":"); append_int(buf, &pos, e->valid_before);
 376:	00001617          	auipc	a2,0x1
 37a:	d0260613          	addi	a2,a2,-766 # 1078 <malloc+0x192>
 37e:	7c898793          	addi	a5,s3,1992
 382:	ff040713          	addi	a4,s0,-16
 386:	97ba                	add	a5,a5,a4
 388:	638c                	ld	a1,0(a5)
 38a:	7e090513          	addi	a0,s2,2016
 38e:	953a                	add	a0,a0,a4
 390:	c71ff0ef          	jal	0 <append_str>
 394:	54d0                	lw	a2,44(s1)
 396:	7c898793          	addi	a5,s3,1992
 39a:	ff040713          	addi	a4,s0,-16
 39e:	97ba                	add	a5,a5,a4
 3a0:	638c                	ld	a1,0(a5)
 3a2:	7e090513          	addi	a0,s2,2016
 3a6:	953a                	add	a0,a0,a4
 3a8:	d11ff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"valid_after\":"); append_int(buf, &pos, e->valid_after);
 3ac:	00001617          	auipc	a2,0x1
 3b0:	ce460613          	addi	a2,a2,-796 # 1090 <malloc+0x1aa>
 3b4:	7c898793          	addi	a5,s3,1992
 3b8:	ff040713          	addi	a4,s0,-16
 3bc:	97ba                	add	a5,a5,a4
 3be:	638c                	ld	a1,0(a5)
 3c0:	7e090513          	addi	a0,s2,2016
 3c4:	953a                	add	a0,a0,a4
 3c6:	c3bff0ef          	jal	0 <append_str>
 3ca:	5890                	lw	a2,48(s1)
 3cc:	7c898793          	addi	a5,s3,1992
 3d0:	ff040713          	addi	a4,s0,-16
 3d4:	97ba                	add	a5,a5,a4
 3d6:	638c                	ld	a1,0(a5)
 3d8:	7e090513          	addi	a0,s2,2016
 3dc:	953a                	add	a0,a0,a4
 3de:	cdbff0ef          	jal	b8 <append_int>

  append_str(buf, &pos, ",\"locked_before\":"); append_int(buf, &pos, e->locked_before);
 3e2:	00001617          	auipc	a2,0x1
 3e6:	cbe60613          	addi	a2,a2,-834 # 10a0 <malloc+0x1ba>
 3ea:	7c898793          	addi	a5,s3,1992
 3ee:	ff040713          	addi	a4,s0,-16
 3f2:	97ba                	add	a5,a5,a4
 3f4:	638c                	ld	a1,0(a5)
 3f6:	7e090513          	addi	a0,s2,2016
 3fa:	953a                	add	a0,a0,a4
 3fc:	c05ff0ef          	jal	0 <append_str>
 400:	58d0                	lw	a2,52(s1)
 402:	7c898793          	addi	a5,s3,1992
 406:	ff040713          	addi	a4,s0,-16
 40a:	97ba                	add	a5,a5,a4
 40c:	638c                	ld	a1,0(a5)
 40e:	7e090513          	addi	a0,s2,2016
 412:	953a                	add	a0,a0,a4
 414:	ca5ff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"locked_after\":"); append_int(buf, &pos, e->locked_after);
 418:	00001617          	auipc	a2,0x1
 41c:	ca060613          	addi	a2,a2,-864 # 10b8 <malloc+0x1d2>
 420:	7c898793          	addi	a5,s3,1992
 424:	ff040713          	addi	a4,s0,-16
 428:	97ba                	add	a5,a5,a4
 42a:	638c                	ld	a1,0(a5)
 42c:	7e090513          	addi	a0,s2,2016
 430:	953a                	add	a0,a0,a4
 432:	bcfff0ef          	jal	0 <append_str>
 436:	5c90                	lw	a2,56(s1)
 438:	7c898793          	addi	a5,s3,1992
 43c:	ff040713          	addi	a4,s0,-16
 440:	97ba                	add	a5,a5,a4
 442:	638c                	ld	a1,0(a5)
 444:	7e090513          	addi	a0,s2,2016
 448:	953a                	add	a0,a0,a4
 44a:	c6fff0ef          	jal	b8 <append_int>

  append_str(buf, &pos, ",\"lru_before\":"); append_int(buf, &pos, e->lru_before);
 44e:	00001617          	auipc	a2,0x1
 452:	c8260613          	addi	a2,a2,-894 # 10d0 <malloc+0x1ea>
 456:	7c898793          	addi	a5,s3,1992
 45a:	ff040713          	addi	a4,s0,-16
 45e:	97ba                	add	a5,a5,a4
 460:	638c                	ld	a1,0(a5)
 462:	7e090513          	addi	a0,s2,2016
 466:	953a                	add	a0,a0,a4
 468:	b99ff0ef          	jal	0 <append_str>
 46c:	5cd0                	lw	a2,60(s1)
 46e:	7c898793          	addi	a5,s3,1992
 472:	ff040713          	addi	a4,s0,-16
 476:	97ba                	add	a5,a5,a4
 478:	638c                	ld	a1,0(a5)
 47a:	7e090513          	addi	a0,s2,2016
 47e:	953a                	add	a0,a0,a4
 480:	c39ff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"lru_after\":"); append_int(buf, &pos, e->lru_after);
 484:	00001617          	auipc	a2,0x1
 488:	c5c60613          	addi	a2,a2,-932 # 10e0 <malloc+0x1fa>
 48c:	7c898793          	addi	a5,s3,1992
 490:	ff040713          	addi	a4,s0,-16
 494:	97ba                	add	a5,a5,a4
 496:	638c                	ld	a1,0(a5)
 498:	7e090513          	addi	a0,s2,2016
 49c:	953a                	add	a0,a0,a4
 49e:	b63ff0ef          	jal	0 <append_str>
 4a2:	40b0                	lw	a2,64(s1)
 4a4:	7c898793          	addi	a5,s3,1992
 4a8:	ff040713          	addi	a4,s0,-16
 4ac:	97ba                	add	a5,a5,a4
 4ae:	638c                	ld	a1,0(a5)
 4b0:	7e090513          	addi	a0,s2,2016
 4b4:	953a                	add	a0,a0,a4
 4b6:	c03ff0ef          	jal	b8 <append_int>

  append_str(buf, &pos, ",\"scan_dir\":"); append_int(buf, &pos, e->scan_dir);
 4ba:	00001617          	auipc	a2,0x1
 4be:	c3660613          	addi	a2,a2,-970 # 10f0 <malloc+0x20a>
 4c2:	7c898793          	addi	a5,s3,1992
 4c6:	ff040713          	addi	a4,s0,-16
 4ca:	97ba                	add	a5,a5,a4
 4cc:	638c                	ld	a1,0(a5)
 4ce:	7e090513          	addi	a0,s2,2016
 4d2:	953a                	add	a0,a0,a4
 4d4:	b2dff0ef          	jal	0 <append_str>
 4d8:	40f0                	lw	a2,68(s1)
 4da:	7c898793          	addi	a5,s3,1992
 4de:	ff040713          	addi	a4,s0,-16
 4e2:	97ba                	add	a5,a5,a4
 4e4:	638c                	ld	a1,0(a5)
 4e6:	7e090513          	addi	a0,s2,2016
 4ea:	953a                	add	a0,a0,a4
 4ec:	bcdff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"scan_step\":"); append_int(buf, &pos, e->scan_step);
 4f0:	00001617          	auipc	a2,0x1
 4f4:	c1060613          	addi	a2,a2,-1008 # 1100 <malloc+0x21a>
 4f8:	7c898793          	addi	a5,s3,1992
 4fc:	ff040713          	addi	a4,s0,-16
 500:	97ba                	add	a5,a5,a4
 502:	638c                	ld	a1,0(a5)
 504:	7e090513          	addi	a0,s2,2016
 508:	953a                	add	a0,a0,a4
 50a:	af7ff0ef          	jal	0 <append_str>
 50e:	44b0                	lw	a2,72(s1)
 510:	7c898793          	addi	a5,s3,1992
 514:	ff040713          	addi	a4,s0,-16
 518:	97ba                	add	a5,a5,a4
 51a:	638c                	ld	a1,0(a5)
 51c:	7e090513          	addi	a0,s2,2016
 520:	953a                	add	a0,a0,a4
 522:	b97ff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"found\":"); append_int(buf, &pos, e->found);
 526:	00001617          	auipc	a2,0x1
 52a:	bea60613          	addi	a2,a2,-1046 # 1110 <malloc+0x22a>
 52e:	7c898793          	addi	a5,s3,1992
 532:	ff040713          	addi	a4,s0,-16
 536:	97ba                	add	a5,a5,a4
 538:	638c                	ld	a1,0(a5)
 53a:	7e090513          	addi	a0,s2,2016
 53e:	953a                	add	a0,a0,a4
 540:	ac1ff0ef          	jal	0 <append_str>
 544:	44f0                	lw	a2,76(s1)
 546:	7c898793          	addi	a5,s3,1992
 54a:	ff040713          	addi	a4,s0,-16
 54e:	97ba                	add	a5,a5,a4
 550:	638c                	ld	a1,0(a5)
 552:	7e090513          	addi	a0,s2,2016
 556:	953a                	add	a0,a0,a4
 558:	b61ff0ef          	jal	b8 <append_int>

  append_str(buf, &pos, ",\"size\":"); append_uint(buf, &pos, e->size);
 55c:	00001617          	auipc	a2,0x1
 560:	bc460613          	addi	a2,a2,-1084 # 1120 <malloc+0x23a>
 564:	7c898793          	addi	a5,s3,1992
 568:	ff040713          	addi	a4,s0,-16
 56c:	97ba                	add	a5,a5,a4
 56e:	638c                	ld	a1,0(a5)
 570:	7e090513          	addi	a0,s2,2016
 574:	953a                	add	a0,a0,a4
 576:	a8bff0ef          	jal	0 <append_str>
 57a:	48b0                	lw	a2,80(s1)
 57c:	7c898793          	addi	a5,s3,1992
 580:	ff040713          	addi	a4,s0,-16
 584:	97ba                	add	a5,a5,a4
 586:	638c                	ld	a1,0(a5)
 588:	7e090513          	addi	a0,s2,2016
 58c:	953a                	add	a0,a0,a4
 58e:	aa7ff0ef          	jal	34 <append_uint>

  append_str(buf, &pos, ",\"name\":\"");
 592:	00001617          	auipc	a2,0x1
 596:	b9e60613          	addi	a2,a2,-1122 # 1130 <malloc+0x24a>
 59a:	7c898793          	addi	a5,s3,1992
 59e:	ff040713          	addi	a4,s0,-16
 5a2:	97ba                	add	a5,a5,a4
 5a4:	638c                	ld	a1,0(a5)
 5a6:	7e090513          	addi	a0,s2,2016
 5aa:	953a                	add	a0,a0,a4
 5ac:	a55ff0ef          	jal	0 <append_str>
  while (*s && *pos < OUTBUF_SZ - 1) {
 5b0:	0544c783          	lbu	a5,84(s1)
 5b4:	cbc5                	beqz	a5,664 <print_fs_event+0x574>
 5b6:	05448693          	addi	a3,s1,84
 5ba:	777d                	lui	a4,0xfffff
 5bc:	1701                	addi	a4,a4,-32 # ffffffffffffefe0 <base+0xffffffffffffcb10>
 5be:	ff040613          	addi	a2,s0,-16
 5c2:	9732                	add	a4,a4,a2
 5c4:	7fc72703          	lw	a4,2044(a4)
 5c8:	4881                	li	a7,0
 5ca:	7fe00593          	li	a1,2046
    if (c == '"' || c == '\\') {
 5ce:	02200813          	li	a6,34
    buf[(*pos)++] = c;
 5d2:	05c00513          	li	a0,92
 5d6:	4305                	li	t1,1
    } else if (c >= 32 && c < 127) {
 5d8:	05e00e13          	li	t3,94
 5dc:	a815                	j	610 <print_fs_event+0x520>
    buf[(*pos)++] = c;
 5de:	0017061b          	addiw	a2,a4,1
 5e2:	fe070493          	addi	s1,a4,-32
 5e6:	ff040893          	addi	a7,s0,-16
 5ea:	98a6                	add	a7,a7,s1
 5ec:	80a88023          	sb	a0,-2048(a7)
  if (*pos < OUTBUF_SZ - 1)
 5f0:	00c5cb63          	blt	a1,a2,606 <print_fs_event+0x516>
    buf[(*pos)++] = c;
 5f4:	2709                	addiw	a4,a4,2
 5f6:	1601                	addi	a2,a2,-32
 5f8:	ff040493          	addi	s1,s0,-16
 5fc:	9626                	add	a2,a2,s1
 5fe:	80f60023          	sb	a5,-2048(a2)
 602:	889a                	mv	a7,t1
 604:	a019                	j	60a <print_fs_event+0x51a>
 606:	8732                	mv	a4,a2
 608:	889a                	mv	a7,t1
  while (*s && *pos < OUTBUF_SZ - 1) {
 60a:	0006c783          	lbu	a5,0(a3)
 60e:	cb85                	beqz	a5,63e <print_fs_event+0x54e>
 610:	04e5c163          	blt	a1,a4,652 <print_fs_event+0x562>
    char c = *s++;
 614:	0685                	addi	a3,a3,1
    if (c == '"' || c == '\\') {
 616:	fd0784e3          	beq	a5,a6,5de <print_fs_event+0x4ee>
 61a:	fca782e3          	beq	a5,a0,5de <print_fs_event+0x4ee>
    } else if (c >= 32 && c < 127) {
 61e:	fe07861b          	addiw	a2,a5,-32
 622:	0ff67613          	zext.b	a2,a2
 626:	fece62e3          	bltu	t3,a2,60a <print_fs_event+0x51a>
    buf[(*pos)++] = c;
 62a:	fe070613          	addi	a2,a4,-32
 62e:	ff040493          	addi	s1,s0,-16
 632:	9626                	add	a2,a2,s1
 634:	80f60023          	sb	a5,-2048(a2)
 638:	2705                	addiw	a4,a4,1
}
 63a:	889a                	mv	a7,t1
 63c:	b7f9                	j	60a <print_fs_event+0x51a>
 63e:	02088363          	beqz	a7,664 <print_fs_event+0x574>
 642:	77fd                	lui	a5,0xfffff
 644:	1781                	addi	a5,a5,-32 # ffffffffffffefe0 <base+0xffffffffffffcb10>
 646:	ff040693          	addi	a3,s0,-16
 64a:	97b6                	add	a5,a5,a3
 64c:	7ee7ae23          	sw	a4,2044(a5)
 650:	a811                	j	664 <print_fs_event+0x574>
 652:	00088963          	beqz	a7,664 <print_fs_event+0x574>
 656:	77fd                	lui	a5,0xfffff
 658:	1781                	addi	a5,a5,-32 # ffffffffffffefe0 <base+0xffffffffffffcb10>
 65a:	ff040693          	addi	a3,s0,-16
 65e:	97b6                	add	a5,a5,a3
 660:	7ee7ae23          	sw	a4,2044(a5)
  append_json_string(buf, &pos, e->name);
  append_str(buf, &pos, "\"}\n");
 664:	75fd                	lui	a1,0xfffff
 666:	00001617          	auipc	a2,0x1
 66a:	ada60613          	addi	a2,a2,-1318 # 1140 <malloc+0x25a>
 66e:	7dc58793          	addi	a5,a1,2012 # fffffffffffff7dc <base+0xffffffffffffd30c>
 672:	ff040713          	addi	a4,s0,-16
 676:	00e785b3          	add	a1,a5,a4
 67a:	74fd                	lui	s1,0xfffff
 67c:	7e048513          	addi	a0,s1,2016 # fffffffffffff7e0 <base+0xffffffffffffd310>
 680:	953a                	add	a0,a0,a4
 682:	97fff0ef          	jal	0 <append_str>

  write(1, buf, pos);
 686:	77fd                	lui	a5,0xfffff
 688:	1781                	addi	a5,a5,-32 # ffffffffffffefe0 <base+0xffffffffffffcb10>
 68a:	ff040713          	addi	a4,s0,-16
 68e:	97ba                	add	a5,a5,a4
 690:	7fc7a603          	lw	a2,2044(a5)
 694:	7e048593          	addi	a1,s1,2016
 698:	95ba                	add	a1,a1,a4
 69a:	4505                	li	a0,1
 69c:	37e000ef          	jal	a1a <write>
}
 6a0:	7f010113          	addi	sp,sp,2032
 6a4:	60e6                	ld	ra,88(sp)
 6a6:	6446                	ld	s0,80(sp)
 6a8:	64a6                	ld	s1,72(sp)
 6aa:	6906                	ld	s2,64(sp)
 6ac:	79e2                	ld	s3,56(sp)
 6ae:	6125                	addi	sp,sp,96
 6b0:	8082                	ret

00000000000006b2 <main>:
static void print_cs_event(const struct cs_event *e) {
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
           e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
}

int main(void) {
 6b2:	715d                	addi	sp,sp,-80
 6b4:	e486                	sd	ra,72(sp)
 6b6:	e0a2                	sd	s0,64(sp)
 6b8:	fc26                	sd	s1,56(sp)
 6ba:	f84a                	sd	s2,48(sp)
 6bc:	f44e                	sd	s3,40(sp)
 6be:	f052                	sd	s4,32(sp)
 6c0:	ec56                	sd	s5,24(sp)
 6c2:	e85a                	sd	s6,16(sp)
 6c4:	e45e                	sd	s7,8(sp)
 6c6:	0880                	addi	s0,sp,80

    while (1) {

        int n_cs = csread(cs_ev, 8);
 6c8:	00002b17          	auipc	s6,0x2
 6cc:	948b0b13          	addi	s6,s6,-1720 # 2010 <cs_ev>
        for (int i = 0; i < n_cs; i++) {
            if (cs_ev[i].type == 1)
 6d0:	4985                	li	s3,1
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
 6d2:	00001a17          	auipc	s4,0x1
 6d6:	a76a0a13          	addi	s4,s4,-1418 # 1148 <malloc+0x262>
                print_cs_event(&cs_ev[i]);
        }

        int n_fs = fsread(fs_ev, 8);
 6da:	00002a97          	auipc	s5,0x2
 6de:	ab6a8a93          	addi	s5,s5,-1354 # 2190 <fs_ev>
 6e2:	06800b93          	li	s7,104
 6e6:	a085                	j	746 <main+0x94>
        for (int i = 0; i < n_cs; i++) {
 6e8:	03048493          	addi	s1,s1,48
 6ec:	03248563          	beq	s1,s2,716 <main+0x64>
            if (cs_ev[i].type == 1)
 6f0:	ff44a783          	lw	a5,-12(s1)
 6f4:	ff379ae3          	bne	a5,s3,6e8 <main+0x36>
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
 6f8:	ffc4a803          	lw	a6,-4(s1)
 6fc:	87a6                	mv	a5,s1
 6fe:	ff84a703          	lw	a4,-8(s1)
 702:	ff04a683          	lw	a3,-16(s1)
 706:	fec4a603          	lw	a2,-20(s1)
 70a:	fe44b583          	ld	a1,-28(s1)
 70e:	8552                	mv	a0,s4
 710:	722000ef          	jal	e32 <printf>
}
 714:	bfd1                	j	6e8 <main+0x36>
        int n_fs = fsread(fs_ev, 8);
 716:	45a1                	li	a1,8
 718:	8556                	mv	a0,s5
 71a:	388000ef          	jal	aa2 <fsread>
        for (int i = 0; i < n_fs; i++) {
 71e:	02a05163          	blez	a0,740 <main+0x8e>
 722:	00002917          	auipc	s2,0x2
 726:	a6e90913          	addi	s2,s2,-1426 # 2190 <fs_ev>
 72a:	03750533          	mul	a0,a0,s7
 72e:	012504b3          	add	s1,a0,s2
            print_fs_event(&fs_ev[i]);
 732:	854a                	mv	a0,s2
 734:	9bdff0ef          	jal	f0 <print_fs_event>
        for (int i = 0; i < n_fs; i++) {
 738:	06890913          	addi	s2,s2,104
 73c:	fe991be3          	bne	s2,s1,732 <main+0x80>
        }

        pause(2);
 740:	4509                	li	a0,2
 742:	348000ef          	jal	a8a <pause>
        int n_cs = csread(cs_ev, 8);
 746:	45a1                	li	a1,8
 748:	855a                	mv	a0,s6
 74a:	350000ef          	jal	a9a <csread>
        for (int i = 0; i < n_cs; i++) {
 74e:	fca054e3          	blez	a0,716 <main+0x64>
 752:	00002497          	auipc	s1,0x2
 756:	8da48493          	addi	s1,s1,-1830 # 202c <cs_ev+0x1c>
 75a:	00151913          	slli	s2,a0,0x1
 75e:	992a                	add	s2,s2,a0
 760:	0912                	slli	s2,s2,0x4
 762:	9926                	add	s2,s2,s1
 764:	b771                	j	6f0 <main+0x3e>

0000000000000766 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 766:	1141                	addi	sp,sp,-16
 768:	e406                	sd	ra,8(sp)
 76a:	e022                	sd	s0,0(sp)
 76c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 76e:	f45ff0ef          	jal	6b2 <main>
  exit(r);
 772:	288000ef          	jal	9fa <exit>

0000000000000776 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 776:	1141                	addi	sp,sp,-16
 778:	e422                	sd	s0,8(sp)
 77a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 77c:	87aa                	mv	a5,a0
 77e:	0585                	addi	a1,a1,1
 780:	0785                	addi	a5,a5,1
 782:	fff5c703          	lbu	a4,-1(a1)
 786:	fee78fa3          	sb	a4,-1(a5)
 78a:	fb75                	bnez	a4,77e <strcpy+0x8>
    ;
  return os;
}
 78c:	6422                	ld	s0,8(sp)
 78e:	0141                	addi	sp,sp,16
 790:	8082                	ret

0000000000000792 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 792:	1141                	addi	sp,sp,-16
 794:	e422                	sd	s0,8(sp)
 796:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 798:	00054783          	lbu	a5,0(a0)
 79c:	cb91                	beqz	a5,7b0 <strcmp+0x1e>
 79e:	0005c703          	lbu	a4,0(a1)
 7a2:	00f71763          	bne	a4,a5,7b0 <strcmp+0x1e>
    p++, q++;
 7a6:	0505                	addi	a0,a0,1
 7a8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 7aa:	00054783          	lbu	a5,0(a0)
 7ae:	fbe5                	bnez	a5,79e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 7b0:	0005c503          	lbu	a0,0(a1)
}
 7b4:	40a7853b          	subw	a0,a5,a0
 7b8:	6422                	ld	s0,8(sp)
 7ba:	0141                	addi	sp,sp,16
 7bc:	8082                	ret

00000000000007be <strlen>:

uint
strlen(const char *s)
{
 7be:	1141                	addi	sp,sp,-16
 7c0:	e422                	sd	s0,8(sp)
 7c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 7c4:	00054783          	lbu	a5,0(a0)
 7c8:	cf91                	beqz	a5,7e4 <strlen+0x26>
 7ca:	0505                	addi	a0,a0,1
 7cc:	87aa                	mv	a5,a0
 7ce:	86be                	mv	a3,a5
 7d0:	0785                	addi	a5,a5,1
 7d2:	fff7c703          	lbu	a4,-1(a5)
 7d6:	ff65                	bnez	a4,7ce <strlen+0x10>
 7d8:	40a6853b          	subw	a0,a3,a0
 7dc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 7de:	6422                	ld	s0,8(sp)
 7e0:	0141                	addi	sp,sp,16
 7e2:	8082                	ret
  for(n = 0; s[n]; n++)
 7e4:	4501                	li	a0,0
 7e6:	bfe5                	j	7de <strlen+0x20>

00000000000007e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 7e8:	1141                	addi	sp,sp,-16
 7ea:	e422                	sd	s0,8(sp)
 7ec:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 7ee:	ca19                	beqz	a2,804 <memset+0x1c>
 7f0:	87aa                	mv	a5,a0
 7f2:	1602                	slli	a2,a2,0x20
 7f4:	9201                	srli	a2,a2,0x20
 7f6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 7fa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 7fe:	0785                	addi	a5,a5,1
 800:	fee79de3          	bne	a5,a4,7fa <memset+0x12>
  }
  return dst;
}
 804:	6422                	ld	s0,8(sp)
 806:	0141                	addi	sp,sp,16
 808:	8082                	ret

000000000000080a <strchr>:

char*
strchr(const char *s, char c)
{
 80a:	1141                	addi	sp,sp,-16
 80c:	e422                	sd	s0,8(sp)
 80e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 810:	00054783          	lbu	a5,0(a0)
 814:	cb99                	beqz	a5,82a <strchr+0x20>
    if(*s == c)
 816:	00f58763          	beq	a1,a5,824 <strchr+0x1a>
  for(; *s; s++)
 81a:	0505                	addi	a0,a0,1
 81c:	00054783          	lbu	a5,0(a0)
 820:	fbfd                	bnez	a5,816 <strchr+0xc>
      return (char*)s;
  return 0;
 822:	4501                	li	a0,0
}
 824:	6422                	ld	s0,8(sp)
 826:	0141                	addi	sp,sp,16
 828:	8082                	ret
  return 0;
 82a:	4501                	li	a0,0
 82c:	bfe5                	j	824 <strchr+0x1a>

000000000000082e <gets>:

char*
gets(char *buf, int max)
{
 82e:	711d                	addi	sp,sp,-96
 830:	ec86                	sd	ra,88(sp)
 832:	e8a2                	sd	s0,80(sp)
 834:	e4a6                	sd	s1,72(sp)
 836:	e0ca                	sd	s2,64(sp)
 838:	fc4e                	sd	s3,56(sp)
 83a:	f852                	sd	s4,48(sp)
 83c:	f456                	sd	s5,40(sp)
 83e:	f05a                	sd	s6,32(sp)
 840:	ec5e                	sd	s7,24(sp)
 842:	1080                	addi	s0,sp,96
 844:	8baa                	mv	s7,a0
 846:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 848:	892a                	mv	s2,a0
 84a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 84c:	4aa9                	li	s5,10
 84e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 850:	89a6                	mv	s3,s1
 852:	2485                	addiw	s1,s1,1
 854:	0344d663          	bge	s1,s4,880 <gets+0x52>
    cc = read(0, &c, 1);
 858:	4605                	li	a2,1
 85a:	faf40593          	addi	a1,s0,-81
 85e:	4501                	li	a0,0
 860:	1b2000ef          	jal	a12 <read>
    if(cc < 1)
 864:	00a05e63          	blez	a0,880 <gets+0x52>
    buf[i++] = c;
 868:	faf44783          	lbu	a5,-81(s0)
 86c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 870:	01578763          	beq	a5,s5,87e <gets+0x50>
 874:	0905                	addi	s2,s2,1
 876:	fd679de3          	bne	a5,s6,850 <gets+0x22>
    buf[i++] = c;
 87a:	89a6                	mv	s3,s1
 87c:	a011                	j	880 <gets+0x52>
 87e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 880:	99de                	add	s3,s3,s7
 882:	00098023          	sb	zero,0(s3)
  return buf;
}
 886:	855e                	mv	a0,s7
 888:	60e6                	ld	ra,88(sp)
 88a:	6446                	ld	s0,80(sp)
 88c:	64a6                	ld	s1,72(sp)
 88e:	6906                	ld	s2,64(sp)
 890:	79e2                	ld	s3,56(sp)
 892:	7a42                	ld	s4,48(sp)
 894:	7aa2                	ld	s5,40(sp)
 896:	7b02                	ld	s6,32(sp)
 898:	6be2                	ld	s7,24(sp)
 89a:	6125                	addi	sp,sp,96
 89c:	8082                	ret

000000000000089e <stat>:

int
stat(const char *n, struct stat *st)
{
 89e:	1101                	addi	sp,sp,-32
 8a0:	ec06                	sd	ra,24(sp)
 8a2:	e822                	sd	s0,16(sp)
 8a4:	e04a                	sd	s2,0(sp)
 8a6:	1000                	addi	s0,sp,32
 8a8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 8aa:	4581                	li	a1,0
 8ac:	18e000ef          	jal	a3a <open>
  if(fd < 0)
 8b0:	02054263          	bltz	a0,8d4 <stat+0x36>
 8b4:	e426                	sd	s1,8(sp)
 8b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 8b8:	85ca                	mv	a1,s2
 8ba:	198000ef          	jal	a52 <fstat>
 8be:	892a                	mv	s2,a0
  close(fd);
 8c0:	8526                	mv	a0,s1
 8c2:	160000ef          	jal	a22 <close>
  return r;
 8c6:	64a2                	ld	s1,8(sp)
}
 8c8:	854a                	mv	a0,s2
 8ca:	60e2                	ld	ra,24(sp)
 8cc:	6442                	ld	s0,16(sp)
 8ce:	6902                	ld	s2,0(sp)
 8d0:	6105                	addi	sp,sp,32
 8d2:	8082                	ret
    return -1;
 8d4:	597d                	li	s2,-1
 8d6:	bfcd                	j	8c8 <stat+0x2a>

00000000000008d8 <atoi>:

int
atoi(const char *s)
{
 8d8:	1141                	addi	sp,sp,-16
 8da:	e422                	sd	s0,8(sp)
 8dc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 8de:	00054683          	lbu	a3,0(a0)
 8e2:	fd06879b          	addiw	a5,a3,-48
 8e6:	0ff7f793          	zext.b	a5,a5
 8ea:	4625                	li	a2,9
 8ec:	02f66863          	bltu	a2,a5,91c <atoi+0x44>
 8f0:	872a                	mv	a4,a0
  n = 0;
 8f2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 8f4:	0705                	addi	a4,a4,1
 8f6:	0025179b          	slliw	a5,a0,0x2
 8fa:	9fa9                	addw	a5,a5,a0
 8fc:	0017979b          	slliw	a5,a5,0x1
 900:	9fb5                	addw	a5,a5,a3
 902:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 906:	00074683          	lbu	a3,0(a4)
 90a:	fd06879b          	addiw	a5,a3,-48
 90e:	0ff7f793          	zext.b	a5,a5
 912:	fef671e3          	bgeu	a2,a5,8f4 <atoi+0x1c>
  return n;
}
 916:	6422                	ld	s0,8(sp)
 918:	0141                	addi	sp,sp,16
 91a:	8082                	ret
  n = 0;
 91c:	4501                	li	a0,0
 91e:	bfe5                	j	916 <atoi+0x3e>

0000000000000920 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 920:	1141                	addi	sp,sp,-16
 922:	e422                	sd	s0,8(sp)
 924:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 926:	02b57463          	bgeu	a0,a1,94e <memmove+0x2e>
    while(n-- > 0)
 92a:	00c05f63          	blez	a2,948 <memmove+0x28>
 92e:	1602                	slli	a2,a2,0x20
 930:	9201                	srli	a2,a2,0x20
 932:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 936:	872a                	mv	a4,a0
      *dst++ = *src++;
 938:	0585                	addi	a1,a1,1
 93a:	0705                	addi	a4,a4,1
 93c:	fff5c683          	lbu	a3,-1(a1)
 940:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 944:	fef71ae3          	bne	a4,a5,938 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 948:	6422                	ld	s0,8(sp)
 94a:	0141                	addi	sp,sp,16
 94c:	8082                	ret
    dst += n;
 94e:	00c50733          	add	a4,a0,a2
    src += n;
 952:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 954:	fec05ae3          	blez	a2,948 <memmove+0x28>
 958:	fff6079b          	addiw	a5,a2,-1
 95c:	1782                	slli	a5,a5,0x20
 95e:	9381                	srli	a5,a5,0x20
 960:	fff7c793          	not	a5,a5
 964:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 966:	15fd                	addi	a1,a1,-1
 968:	177d                	addi	a4,a4,-1
 96a:	0005c683          	lbu	a3,0(a1)
 96e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 972:	fee79ae3          	bne	a5,a4,966 <memmove+0x46>
 976:	bfc9                	j	948 <memmove+0x28>

0000000000000978 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 978:	1141                	addi	sp,sp,-16
 97a:	e422                	sd	s0,8(sp)
 97c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 97e:	ca05                	beqz	a2,9ae <memcmp+0x36>
 980:	fff6069b          	addiw	a3,a2,-1
 984:	1682                	slli	a3,a3,0x20
 986:	9281                	srli	a3,a3,0x20
 988:	0685                	addi	a3,a3,1
 98a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 98c:	00054783          	lbu	a5,0(a0)
 990:	0005c703          	lbu	a4,0(a1)
 994:	00e79863          	bne	a5,a4,9a4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 998:	0505                	addi	a0,a0,1
    p2++;
 99a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 99c:	fed518e3          	bne	a0,a3,98c <memcmp+0x14>
  }
  return 0;
 9a0:	4501                	li	a0,0
 9a2:	a019                	j	9a8 <memcmp+0x30>
      return *p1 - *p2;
 9a4:	40e7853b          	subw	a0,a5,a4
}
 9a8:	6422                	ld	s0,8(sp)
 9aa:	0141                	addi	sp,sp,16
 9ac:	8082                	ret
  return 0;
 9ae:	4501                	li	a0,0
 9b0:	bfe5                	j	9a8 <memcmp+0x30>

00000000000009b2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 9b2:	1141                	addi	sp,sp,-16
 9b4:	e406                	sd	ra,8(sp)
 9b6:	e022                	sd	s0,0(sp)
 9b8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 9ba:	f67ff0ef          	jal	920 <memmove>
}
 9be:	60a2                	ld	ra,8(sp)
 9c0:	6402                	ld	s0,0(sp)
 9c2:	0141                	addi	sp,sp,16
 9c4:	8082                	ret

00000000000009c6 <sbrk>:

char *
sbrk(int n) {
 9c6:	1141                	addi	sp,sp,-16
 9c8:	e406                	sd	ra,8(sp)
 9ca:	e022                	sd	s0,0(sp)
 9cc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 9ce:	4585                	li	a1,1
 9d0:	0b2000ef          	jal	a82 <sys_sbrk>
}
 9d4:	60a2                	ld	ra,8(sp)
 9d6:	6402                	ld	s0,0(sp)
 9d8:	0141                	addi	sp,sp,16
 9da:	8082                	ret

00000000000009dc <sbrklazy>:

char *
sbrklazy(int n) {
 9dc:	1141                	addi	sp,sp,-16
 9de:	e406                	sd	ra,8(sp)
 9e0:	e022                	sd	s0,0(sp)
 9e2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 9e4:	4589                	li	a1,2
 9e6:	09c000ef          	jal	a82 <sys_sbrk>
}
 9ea:	60a2                	ld	ra,8(sp)
 9ec:	6402                	ld	s0,0(sp)
 9ee:	0141                	addi	sp,sp,16
 9f0:	8082                	ret

00000000000009f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 9f2:	4885                	li	a7,1
 ecall
 9f4:	00000073          	ecall
 ret
 9f8:	8082                	ret

00000000000009fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 9fa:	4889                	li	a7,2
 ecall
 9fc:	00000073          	ecall
 ret
 a00:	8082                	ret

0000000000000a02 <wait>:
.global wait
wait:
 li a7, SYS_wait
 a02:	488d                	li	a7,3
 ecall
 a04:	00000073          	ecall
 ret
 a08:	8082                	ret

0000000000000a0a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 a0a:	4891                	li	a7,4
 ecall
 a0c:	00000073          	ecall
 ret
 a10:	8082                	ret

0000000000000a12 <read>:
.global read
read:
 li a7, SYS_read
 a12:	4895                	li	a7,5
 ecall
 a14:	00000073          	ecall
 ret
 a18:	8082                	ret

0000000000000a1a <write>:
.global write
write:
 li a7, SYS_write
 a1a:	48c1                	li	a7,16
 ecall
 a1c:	00000073          	ecall
 ret
 a20:	8082                	ret

0000000000000a22 <close>:
.global close
close:
 li a7, SYS_close
 a22:	48d5                	li	a7,21
 ecall
 a24:	00000073          	ecall
 ret
 a28:	8082                	ret

0000000000000a2a <kill>:
.global kill
kill:
 li a7, SYS_kill
 a2a:	4899                	li	a7,6
 ecall
 a2c:	00000073          	ecall
 ret
 a30:	8082                	ret

0000000000000a32 <exec>:
.global exec
exec:
 li a7, SYS_exec
 a32:	489d                	li	a7,7
 ecall
 a34:	00000073          	ecall
 ret
 a38:	8082                	ret

0000000000000a3a <open>:
.global open
open:
 li a7, SYS_open
 a3a:	48bd                	li	a7,15
 ecall
 a3c:	00000073          	ecall
 ret
 a40:	8082                	ret

0000000000000a42 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 a42:	48c5                	li	a7,17
 ecall
 a44:	00000073          	ecall
 ret
 a48:	8082                	ret

0000000000000a4a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 a4a:	48c9                	li	a7,18
 ecall
 a4c:	00000073          	ecall
 ret
 a50:	8082                	ret

0000000000000a52 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 a52:	48a1                	li	a7,8
 ecall
 a54:	00000073          	ecall
 ret
 a58:	8082                	ret

0000000000000a5a <link>:
.global link
link:
 li a7, SYS_link
 a5a:	48cd                	li	a7,19
 ecall
 a5c:	00000073          	ecall
 ret
 a60:	8082                	ret

0000000000000a62 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 a62:	48d1                	li	a7,20
 ecall
 a64:	00000073          	ecall
 ret
 a68:	8082                	ret

0000000000000a6a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 a6a:	48a5                	li	a7,9
 ecall
 a6c:	00000073          	ecall
 ret
 a70:	8082                	ret

0000000000000a72 <dup>:
.global dup
dup:
 li a7, SYS_dup
 a72:	48a9                	li	a7,10
 ecall
 a74:	00000073          	ecall
 ret
 a78:	8082                	ret

0000000000000a7a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 a7a:	48ad                	li	a7,11
 ecall
 a7c:	00000073          	ecall
 ret
 a80:	8082                	ret

0000000000000a82 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 a82:	48b1                	li	a7,12
 ecall
 a84:	00000073          	ecall
 ret
 a88:	8082                	ret

0000000000000a8a <pause>:
.global pause
pause:
 li a7, SYS_pause
 a8a:	48b5                	li	a7,13
 ecall
 a8c:	00000073          	ecall
 ret
 a90:	8082                	ret

0000000000000a92 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 a92:	48b9                	li	a7,14
 ecall
 a94:	00000073          	ecall
 ret
 a98:	8082                	ret

0000000000000a9a <csread>:
.global csread
csread:
 li a7, SYS_csread
 a9a:	48d9                	li	a7,22
 ecall
 a9c:	00000073          	ecall
 ret
 aa0:	8082                	ret

0000000000000aa2 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 aa2:	48dd                	li	a7,23
 ecall
 aa4:	00000073          	ecall
 ret
 aa8:	8082                	ret

0000000000000aaa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 aaa:	1101                	addi	sp,sp,-32
 aac:	ec06                	sd	ra,24(sp)
 aae:	e822                	sd	s0,16(sp)
 ab0:	1000                	addi	s0,sp,32
 ab2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 ab6:	4605                	li	a2,1
 ab8:	fef40593          	addi	a1,s0,-17
 abc:	f5fff0ef          	jal	a1a <write>
}
 ac0:	60e2                	ld	ra,24(sp)
 ac2:	6442                	ld	s0,16(sp)
 ac4:	6105                	addi	sp,sp,32
 ac6:	8082                	ret

0000000000000ac8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 ac8:	715d                	addi	sp,sp,-80
 aca:	e486                	sd	ra,72(sp)
 acc:	e0a2                	sd	s0,64(sp)
 ace:	f84a                	sd	s2,48(sp)
 ad0:	0880                	addi	s0,sp,80
 ad2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 ad4:	c299                	beqz	a3,ada <printint+0x12>
 ad6:	0805c363          	bltz	a1,b5c <printint+0x94>
  neg = 0;
 ada:	4881                	li	a7,0
 adc:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 ae0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 ae2:	00000517          	auipc	a0,0x0
 ae6:	6c650513          	addi	a0,a0,1734 # 11a8 <digits>
 aea:	883e                	mv	a6,a5
 aec:	2785                	addiw	a5,a5,1
 aee:	02c5f733          	remu	a4,a1,a2
 af2:	972a                	add	a4,a4,a0
 af4:	00074703          	lbu	a4,0(a4)
 af8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 afc:	872e                	mv	a4,a1
 afe:	02c5d5b3          	divu	a1,a1,a2
 b02:	0685                	addi	a3,a3,1
 b04:	fec773e3          	bgeu	a4,a2,aea <printint+0x22>
  if(neg)
 b08:	00088b63          	beqz	a7,b1e <printint+0x56>
    buf[i++] = '-';
 b0c:	fd078793          	addi	a5,a5,-48
 b10:	97a2                	add	a5,a5,s0
 b12:	02d00713          	li	a4,45
 b16:	fee78423          	sb	a4,-24(a5)
 b1a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 b1e:	02f05a63          	blez	a5,b52 <printint+0x8a>
 b22:	fc26                	sd	s1,56(sp)
 b24:	f44e                	sd	s3,40(sp)
 b26:	fb840713          	addi	a4,s0,-72
 b2a:	00f704b3          	add	s1,a4,a5
 b2e:	fff70993          	addi	s3,a4,-1
 b32:	99be                	add	s3,s3,a5
 b34:	37fd                	addiw	a5,a5,-1
 b36:	1782                	slli	a5,a5,0x20
 b38:	9381                	srli	a5,a5,0x20
 b3a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 b3e:	fff4c583          	lbu	a1,-1(s1)
 b42:	854a                	mv	a0,s2
 b44:	f67ff0ef          	jal	aaa <putc>
  while(--i >= 0)
 b48:	14fd                	addi	s1,s1,-1
 b4a:	ff349ae3          	bne	s1,s3,b3e <printint+0x76>
 b4e:	74e2                	ld	s1,56(sp)
 b50:	79a2                	ld	s3,40(sp)
}
 b52:	60a6                	ld	ra,72(sp)
 b54:	6406                	ld	s0,64(sp)
 b56:	7942                	ld	s2,48(sp)
 b58:	6161                	addi	sp,sp,80
 b5a:	8082                	ret
    x = -xx;
 b5c:	40b005b3          	neg	a1,a1
    neg = 1;
 b60:	4885                	li	a7,1
    x = -xx;
 b62:	bfad                	j	adc <printint+0x14>

0000000000000b64 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 b64:	711d                	addi	sp,sp,-96
 b66:	ec86                	sd	ra,88(sp)
 b68:	e8a2                	sd	s0,80(sp)
 b6a:	e0ca                	sd	s2,64(sp)
 b6c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 b6e:	0005c903          	lbu	s2,0(a1)
 b72:	28090663          	beqz	s2,dfe <vprintf+0x29a>
 b76:	e4a6                	sd	s1,72(sp)
 b78:	fc4e                	sd	s3,56(sp)
 b7a:	f852                	sd	s4,48(sp)
 b7c:	f456                	sd	s5,40(sp)
 b7e:	f05a                	sd	s6,32(sp)
 b80:	ec5e                	sd	s7,24(sp)
 b82:	e862                	sd	s8,16(sp)
 b84:	e466                	sd	s9,8(sp)
 b86:	8b2a                	mv	s6,a0
 b88:	8a2e                	mv	s4,a1
 b8a:	8bb2                	mv	s7,a2
  state = 0;
 b8c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 b8e:	4481                	li	s1,0
 b90:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 b92:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 b96:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 b9a:	06c00c93          	li	s9,108
 b9e:	a005                	j	bbe <vprintf+0x5a>
        putc(fd, c0);
 ba0:	85ca                	mv	a1,s2
 ba2:	855a                	mv	a0,s6
 ba4:	f07ff0ef          	jal	aaa <putc>
 ba8:	a019                	j	bae <vprintf+0x4a>
    } else if(state == '%'){
 baa:	03598263          	beq	s3,s5,bce <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 bae:	2485                	addiw	s1,s1,1
 bb0:	8726                	mv	a4,s1
 bb2:	009a07b3          	add	a5,s4,s1
 bb6:	0007c903          	lbu	s2,0(a5)
 bba:	22090a63          	beqz	s2,dee <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 bbe:	0009079b          	sext.w	a5,s2
    if(state == 0){
 bc2:	fe0994e3          	bnez	s3,baa <vprintf+0x46>
      if(c0 == '%'){
 bc6:	fd579de3          	bne	a5,s5,ba0 <vprintf+0x3c>
        state = '%';
 bca:	89be                	mv	s3,a5
 bcc:	b7cd                	j	bae <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 bce:	00ea06b3          	add	a3,s4,a4
 bd2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 bd6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 bd8:	c681                	beqz	a3,be0 <vprintf+0x7c>
 bda:	9752                	add	a4,a4,s4
 bdc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 be0:	05878363          	beq	a5,s8,c26 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 be4:	05978d63          	beq	a5,s9,c3e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 be8:	07500713          	li	a4,117
 bec:	0ee78763          	beq	a5,a4,cda <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 bf0:	07800713          	li	a4,120
 bf4:	12e78963          	beq	a5,a4,d26 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 bf8:	07000713          	li	a4,112
 bfc:	14e78e63          	beq	a5,a4,d58 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 c00:	06300713          	li	a4,99
 c04:	18e78e63          	beq	a5,a4,da0 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 c08:	07300713          	li	a4,115
 c0c:	1ae78463          	beq	a5,a4,db4 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 c10:	02500713          	li	a4,37
 c14:	04e79563          	bne	a5,a4,c5e <vprintf+0xfa>
        putc(fd, '%');
 c18:	02500593          	li	a1,37
 c1c:	855a                	mv	a0,s6
 c1e:	e8dff0ef          	jal	aaa <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 c22:	4981                	li	s3,0
 c24:	b769                	j	bae <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 c26:	008b8913          	addi	s2,s7,8
 c2a:	4685                	li	a3,1
 c2c:	4629                	li	a2,10
 c2e:	000ba583          	lw	a1,0(s7)
 c32:	855a                	mv	a0,s6
 c34:	e95ff0ef          	jal	ac8 <printint>
 c38:	8bca                	mv	s7,s2
      state = 0;
 c3a:	4981                	li	s3,0
 c3c:	bf8d                	j	bae <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 c3e:	06400793          	li	a5,100
 c42:	02f68963          	beq	a3,a5,c74 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 c46:	06c00793          	li	a5,108
 c4a:	04f68263          	beq	a3,a5,c8e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 c4e:	07500793          	li	a5,117
 c52:	0af68063          	beq	a3,a5,cf2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 c56:	07800793          	li	a5,120
 c5a:	0ef68263          	beq	a3,a5,d3e <vprintf+0x1da>
        putc(fd, '%');
 c5e:	02500593          	li	a1,37
 c62:	855a                	mv	a0,s6
 c64:	e47ff0ef          	jal	aaa <putc>
        putc(fd, c0);
 c68:	85ca                	mv	a1,s2
 c6a:	855a                	mv	a0,s6
 c6c:	e3fff0ef          	jal	aaa <putc>
      state = 0;
 c70:	4981                	li	s3,0
 c72:	bf35                	j	bae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 c74:	008b8913          	addi	s2,s7,8
 c78:	4685                	li	a3,1
 c7a:	4629                	li	a2,10
 c7c:	000bb583          	ld	a1,0(s7)
 c80:	855a                	mv	a0,s6
 c82:	e47ff0ef          	jal	ac8 <printint>
        i += 1;
 c86:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 c88:	8bca                	mv	s7,s2
      state = 0;
 c8a:	4981                	li	s3,0
        i += 1;
 c8c:	b70d                	j	bae <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 c8e:	06400793          	li	a5,100
 c92:	02f60763          	beq	a2,a5,cc0 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 c96:	07500793          	li	a5,117
 c9a:	06f60963          	beq	a2,a5,d0c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 c9e:	07800793          	li	a5,120
 ca2:	faf61ee3          	bne	a2,a5,c5e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 ca6:	008b8913          	addi	s2,s7,8
 caa:	4681                	li	a3,0
 cac:	4641                	li	a2,16
 cae:	000bb583          	ld	a1,0(s7)
 cb2:	855a                	mv	a0,s6
 cb4:	e15ff0ef          	jal	ac8 <printint>
        i += 2;
 cb8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 cba:	8bca                	mv	s7,s2
      state = 0;
 cbc:	4981                	li	s3,0
        i += 2;
 cbe:	bdc5                	j	bae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 cc0:	008b8913          	addi	s2,s7,8
 cc4:	4685                	li	a3,1
 cc6:	4629                	li	a2,10
 cc8:	000bb583          	ld	a1,0(s7)
 ccc:	855a                	mv	a0,s6
 cce:	dfbff0ef          	jal	ac8 <printint>
        i += 2;
 cd2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 cd4:	8bca                	mv	s7,s2
      state = 0;
 cd6:	4981                	li	s3,0
        i += 2;
 cd8:	bdd9                	j	bae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 cda:	008b8913          	addi	s2,s7,8
 cde:	4681                	li	a3,0
 ce0:	4629                	li	a2,10
 ce2:	000be583          	lwu	a1,0(s7)
 ce6:	855a                	mv	a0,s6
 ce8:	de1ff0ef          	jal	ac8 <printint>
 cec:	8bca                	mv	s7,s2
      state = 0;
 cee:	4981                	li	s3,0
 cf0:	bd7d                	j	bae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 cf2:	008b8913          	addi	s2,s7,8
 cf6:	4681                	li	a3,0
 cf8:	4629                	li	a2,10
 cfa:	000bb583          	ld	a1,0(s7)
 cfe:	855a                	mv	a0,s6
 d00:	dc9ff0ef          	jal	ac8 <printint>
        i += 1;
 d04:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 d06:	8bca                	mv	s7,s2
      state = 0;
 d08:	4981                	li	s3,0
        i += 1;
 d0a:	b555                	j	bae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 d0c:	008b8913          	addi	s2,s7,8
 d10:	4681                	li	a3,0
 d12:	4629                	li	a2,10
 d14:	000bb583          	ld	a1,0(s7)
 d18:	855a                	mv	a0,s6
 d1a:	dafff0ef          	jal	ac8 <printint>
        i += 2;
 d1e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 d20:	8bca                	mv	s7,s2
      state = 0;
 d22:	4981                	li	s3,0
        i += 2;
 d24:	b569                	j	bae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 d26:	008b8913          	addi	s2,s7,8
 d2a:	4681                	li	a3,0
 d2c:	4641                	li	a2,16
 d2e:	000be583          	lwu	a1,0(s7)
 d32:	855a                	mv	a0,s6
 d34:	d95ff0ef          	jal	ac8 <printint>
 d38:	8bca                	mv	s7,s2
      state = 0;
 d3a:	4981                	li	s3,0
 d3c:	bd8d                	j	bae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 d3e:	008b8913          	addi	s2,s7,8
 d42:	4681                	li	a3,0
 d44:	4641                	li	a2,16
 d46:	000bb583          	ld	a1,0(s7)
 d4a:	855a                	mv	a0,s6
 d4c:	d7dff0ef          	jal	ac8 <printint>
        i += 1;
 d50:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 d52:	8bca                	mv	s7,s2
      state = 0;
 d54:	4981                	li	s3,0
        i += 1;
 d56:	bda1                	j	bae <vprintf+0x4a>
 d58:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 d5a:	008b8d13          	addi	s10,s7,8
 d5e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 d62:	03000593          	li	a1,48
 d66:	855a                	mv	a0,s6
 d68:	d43ff0ef          	jal	aaa <putc>
  putc(fd, 'x');
 d6c:	07800593          	li	a1,120
 d70:	855a                	mv	a0,s6
 d72:	d39ff0ef          	jal	aaa <putc>
 d76:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 d78:	00000b97          	auipc	s7,0x0
 d7c:	430b8b93          	addi	s7,s7,1072 # 11a8 <digits>
 d80:	03c9d793          	srli	a5,s3,0x3c
 d84:	97de                	add	a5,a5,s7
 d86:	0007c583          	lbu	a1,0(a5)
 d8a:	855a                	mv	a0,s6
 d8c:	d1fff0ef          	jal	aaa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 d90:	0992                	slli	s3,s3,0x4
 d92:	397d                	addiw	s2,s2,-1
 d94:	fe0916e3          	bnez	s2,d80 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 d98:	8bea                	mv	s7,s10
      state = 0;
 d9a:	4981                	li	s3,0
 d9c:	6d02                	ld	s10,0(sp)
 d9e:	bd01                	j	bae <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 da0:	008b8913          	addi	s2,s7,8
 da4:	000bc583          	lbu	a1,0(s7)
 da8:	855a                	mv	a0,s6
 daa:	d01ff0ef          	jal	aaa <putc>
 dae:	8bca                	mv	s7,s2
      state = 0;
 db0:	4981                	li	s3,0
 db2:	bbf5                	j	bae <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 db4:	008b8993          	addi	s3,s7,8
 db8:	000bb903          	ld	s2,0(s7)
 dbc:	00090f63          	beqz	s2,dda <vprintf+0x276>
        for(; *s; s++)
 dc0:	00094583          	lbu	a1,0(s2)
 dc4:	c195                	beqz	a1,de8 <vprintf+0x284>
          putc(fd, *s);
 dc6:	855a                	mv	a0,s6
 dc8:	ce3ff0ef          	jal	aaa <putc>
        for(; *s; s++)
 dcc:	0905                	addi	s2,s2,1
 dce:	00094583          	lbu	a1,0(s2)
 dd2:	f9f5                	bnez	a1,dc6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 dd4:	8bce                	mv	s7,s3
      state = 0;
 dd6:	4981                	li	s3,0
 dd8:	bbd9                	j	bae <vprintf+0x4a>
          s = "(null)";
 dda:	00000917          	auipc	s2,0x0
 dde:	3c690913          	addi	s2,s2,966 # 11a0 <malloc+0x2ba>
        for(; *s; s++)
 de2:	02800593          	li	a1,40
 de6:	b7c5                	j	dc6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 de8:	8bce                	mv	s7,s3
      state = 0;
 dea:	4981                	li	s3,0
 dec:	b3c9                	j	bae <vprintf+0x4a>
 dee:	64a6                	ld	s1,72(sp)
 df0:	79e2                	ld	s3,56(sp)
 df2:	7a42                	ld	s4,48(sp)
 df4:	7aa2                	ld	s5,40(sp)
 df6:	7b02                	ld	s6,32(sp)
 df8:	6be2                	ld	s7,24(sp)
 dfa:	6c42                	ld	s8,16(sp)
 dfc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 dfe:	60e6                	ld	ra,88(sp)
 e00:	6446                	ld	s0,80(sp)
 e02:	6906                	ld	s2,64(sp)
 e04:	6125                	addi	sp,sp,96
 e06:	8082                	ret

0000000000000e08 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 e08:	715d                	addi	sp,sp,-80
 e0a:	ec06                	sd	ra,24(sp)
 e0c:	e822                	sd	s0,16(sp)
 e0e:	1000                	addi	s0,sp,32
 e10:	e010                	sd	a2,0(s0)
 e12:	e414                	sd	a3,8(s0)
 e14:	e818                	sd	a4,16(s0)
 e16:	ec1c                	sd	a5,24(s0)
 e18:	03043023          	sd	a6,32(s0)
 e1c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 e20:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 e24:	8622                	mv	a2,s0
 e26:	d3fff0ef          	jal	b64 <vprintf>
}
 e2a:	60e2                	ld	ra,24(sp)
 e2c:	6442                	ld	s0,16(sp)
 e2e:	6161                	addi	sp,sp,80
 e30:	8082                	ret

0000000000000e32 <printf>:

void
printf(const char *fmt, ...)
{
 e32:	711d                	addi	sp,sp,-96
 e34:	ec06                	sd	ra,24(sp)
 e36:	e822                	sd	s0,16(sp)
 e38:	1000                	addi	s0,sp,32
 e3a:	e40c                	sd	a1,8(s0)
 e3c:	e810                	sd	a2,16(s0)
 e3e:	ec14                	sd	a3,24(s0)
 e40:	f018                	sd	a4,32(s0)
 e42:	f41c                	sd	a5,40(s0)
 e44:	03043823          	sd	a6,48(s0)
 e48:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 e4c:	00840613          	addi	a2,s0,8
 e50:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 e54:	85aa                	mv	a1,a0
 e56:	4505                	li	a0,1
 e58:	d0dff0ef          	jal	b64 <vprintf>
}
 e5c:	60e2                	ld	ra,24(sp)
 e5e:	6442                	ld	s0,16(sp)
 e60:	6125                	addi	sp,sp,96
 e62:	8082                	ret

0000000000000e64 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e64:	1141                	addi	sp,sp,-16
 e66:	e422                	sd	s0,8(sp)
 e68:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e6a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e6e:	00001797          	auipc	a5,0x1
 e72:	1927b783          	ld	a5,402(a5) # 2000 <freep>
 e76:	a02d                	j	ea0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e78:	4618                	lw	a4,8(a2)
 e7a:	9f2d                	addw	a4,a4,a1
 e7c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e80:	6398                	ld	a4,0(a5)
 e82:	6310                	ld	a2,0(a4)
 e84:	a83d                	j	ec2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e86:	ff852703          	lw	a4,-8(a0)
 e8a:	9f31                	addw	a4,a4,a2
 e8c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 e8e:	ff053683          	ld	a3,-16(a0)
 e92:	a091                	j	ed6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e94:	6398                	ld	a4,0(a5)
 e96:	00e7e463          	bltu	a5,a4,e9e <free+0x3a>
 e9a:	00e6ea63          	bltu	a3,a4,eae <free+0x4a>
{
 e9e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ea0:	fed7fae3          	bgeu	a5,a3,e94 <free+0x30>
 ea4:	6398                	ld	a4,0(a5)
 ea6:	00e6e463          	bltu	a3,a4,eae <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 eaa:	fee7eae3          	bltu	a5,a4,e9e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 eae:	ff852583          	lw	a1,-8(a0)
 eb2:	6390                	ld	a2,0(a5)
 eb4:	02059813          	slli	a6,a1,0x20
 eb8:	01c85713          	srli	a4,a6,0x1c
 ebc:	9736                	add	a4,a4,a3
 ebe:	fae60de3          	beq	a2,a4,e78 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 ec2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ec6:	4790                	lw	a2,8(a5)
 ec8:	02061593          	slli	a1,a2,0x20
 ecc:	01c5d713          	srli	a4,a1,0x1c
 ed0:	973e                	add	a4,a4,a5
 ed2:	fae68ae3          	beq	a3,a4,e86 <free+0x22>
    p->s.ptr = bp->s.ptr;
 ed6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 ed8:	00001717          	auipc	a4,0x1
 edc:	12f73423          	sd	a5,296(a4) # 2000 <freep>
}
 ee0:	6422                	ld	s0,8(sp)
 ee2:	0141                	addi	sp,sp,16
 ee4:	8082                	ret

0000000000000ee6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ee6:	7139                	addi	sp,sp,-64
 ee8:	fc06                	sd	ra,56(sp)
 eea:	f822                	sd	s0,48(sp)
 eec:	f426                	sd	s1,40(sp)
 eee:	ec4e                	sd	s3,24(sp)
 ef0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ef2:	02051493          	slli	s1,a0,0x20
 ef6:	9081                	srli	s1,s1,0x20
 ef8:	04bd                	addi	s1,s1,15
 efa:	8091                	srli	s1,s1,0x4
 efc:	0014899b          	addiw	s3,s1,1
 f00:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 f02:	00001517          	auipc	a0,0x1
 f06:	0fe53503          	ld	a0,254(a0) # 2000 <freep>
 f0a:	c915                	beqz	a0,f3e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f0c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f0e:	4798                	lw	a4,8(a5)
 f10:	08977a63          	bgeu	a4,s1,fa4 <malloc+0xbe>
 f14:	f04a                	sd	s2,32(sp)
 f16:	e852                	sd	s4,16(sp)
 f18:	e456                	sd	s5,8(sp)
 f1a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 f1c:	8a4e                	mv	s4,s3
 f1e:	0009871b          	sext.w	a4,s3
 f22:	6685                	lui	a3,0x1
 f24:	00d77363          	bgeu	a4,a3,f2a <malloc+0x44>
 f28:	6a05                	lui	s4,0x1
 f2a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 f2e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 f32:	00001917          	auipc	s2,0x1
 f36:	0ce90913          	addi	s2,s2,206 # 2000 <freep>
  if(p == SBRK_ERROR)
 f3a:	5afd                	li	s5,-1
 f3c:	a081                	j	f7c <malloc+0x96>
 f3e:	f04a                	sd	s2,32(sp)
 f40:	e852                	sd	s4,16(sp)
 f42:	e456                	sd	s5,8(sp)
 f44:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 f46:	00001797          	auipc	a5,0x1
 f4a:	58a78793          	addi	a5,a5,1418 # 24d0 <base>
 f4e:	00001717          	auipc	a4,0x1
 f52:	0af73923          	sd	a5,178(a4) # 2000 <freep>
 f56:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 f58:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 f5c:	b7c1                	j	f1c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 f5e:	6398                	ld	a4,0(a5)
 f60:	e118                	sd	a4,0(a0)
 f62:	a8a9                	j	fbc <malloc+0xd6>
  hp->s.size = nu;
 f64:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f68:	0541                	addi	a0,a0,16
 f6a:	efbff0ef          	jal	e64 <free>
  return freep;
 f6e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f72:	c12d                	beqz	a0,fd4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f74:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f76:	4798                	lw	a4,8(a5)
 f78:	02977263          	bgeu	a4,s1,f9c <malloc+0xb6>
    if(p == freep)
 f7c:	00093703          	ld	a4,0(s2)
 f80:	853e                	mv	a0,a5
 f82:	fef719e3          	bne	a4,a5,f74 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 f86:	8552                	mv	a0,s4
 f88:	a3fff0ef          	jal	9c6 <sbrk>
  if(p == SBRK_ERROR)
 f8c:	fd551ce3          	bne	a0,s5,f64 <malloc+0x7e>
        return 0;
 f90:	4501                	li	a0,0
 f92:	7902                	ld	s2,32(sp)
 f94:	6a42                	ld	s4,16(sp)
 f96:	6aa2                	ld	s5,8(sp)
 f98:	6b02                	ld	s6,0(sp)
 f9a:	a03d                	j	fc8 <malloc+0xe2>
 f9c:	7902                	ld	s2,32(sp)
 f9e:	6a42                	ld	s4,16(sp)
 fa0:	6aa2                	ld	s5,8(sp)
 fa2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 fa4:	fae48de3          	beq	s1,a4,f5e <malloc+0x78>
        p->s.size -= nunits;
 fa8:	4137073b          	subw	a4,a4,s3
 fac:	c798                	sw	a4,8(a5)
        p += p->s.size;
 fae:	02071693          	slli	a3,a4,0x20
 fb2:	01c6d713          	srli	a4,a3,0x1c
 fb6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 fb8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 fbc:	00001717          	auipc	a4,0x1
 fc0:	04a73223          	sd	a0,68(a4) # 2000 <freep>
      return (void*)(p + 1);
 fc4:	01078513          	addi	a0,a5,16
  }
}
 fc8:	70e2                	ld	ra,56(sp)
 fca:	7442                	ld	s0,48(sp)
 fcc:	74a2                	ld	s1,40(sp)
 fce:	69e2                	ld	s3,24(sp)
 fd0:	6121                	addi	sp,sp,64
 fd2:	8082                	ret
 fd4:	7902                	ld	s2,32(sp)
 fd6:	6a42                	ld	s4,16(sp)
 fd8:	6aa2                	ld	s5,8(sp)
 fda:	6b02                	ld	s6,0(sp)
 fdc:	b7f5                	j	fc8 <malloc+0xe2>
