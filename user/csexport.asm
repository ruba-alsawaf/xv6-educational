
user/_csexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <append_str>:
static struct fs_event fs_ev[8];
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

00000000000000f0 <fs_type_name>:
    } else if (c >= 32 && c < 127) {
      append_char(buf, pos, c);
    }
  }
}
const char* fs_type_name(int t){
      f0:	1141                	addi	sp,sp,-16
      f2:	e422                	sd	s0,8(sp)
      f4:	0800                	addi	s0,sp,16
  switch(t){
      f6:	3531                	addiw	a0,a0,-20
      f8:	0005071b          	sext.w	a4,a0
      fc:	47ad                	li	a5,11
      fe:	06e7e363          	bltu	a5,a4,164 <fs_type_name+0x74>
     102:	02051793          	slli	a5,a0,0x20
     106:	01e7d513          	srli	a0,a5,0x1e
     10a:	00001717          	auipc	a4,0x1
     10e:	32e70713          	addi	a4,a4,814 # 1438 <malloc+0x374>
     112:	953a                	add	a0,a0,a4
     114:	411c                	lw	a5,0(a0)
     116:	97ba                	add	a5,a5,a4
     118:	8782                	jr	a5
    case FS_LOG_BEGIN: return "BEGIN_OP";
     11a:	00001517          	auipc	a0,0x1
     11e:	0a650513          	addi	a0,a0,166 # 11c0 <malloc+0xfc>
     122:	a029                	j	12c <fs_type_name+0x3c>
    case FS_LOG_WRITE: return "LOG_WRITE";
    case FS_LOG_END:   return "END_OP";
     124:	00001517          	auipc	a0,0x1
     128:	0bc50513          	addi	a0,a0,188 # 11e0 <malloc+0x11c>
    case FS_LOG_INSTALL: return "INSTALL";
    case FS_BLOCK_ALLOC: return "BALLOC";
    case FS_BLOCK_FREE:  return "BFREE";
    default: return "FS";
  }
}
     12c:	6422                	ld	s0,8(sp)
     12e:	0141                	addi	sp,sp,16
     130:	8082                	ret
    case FS_LOG_WLOG:  return "WRITE_LOG";
     132:	00001517          	auipc	a0,0x1
     136:	0b650513          	addi	a0,a0,182 # 11e8 <malloc+0x124>
     13a:	bfcd                	j	12c <fs_type_name+0x3c>
    case FS_LOG_WHEAD: return "COMMIT";
     13c:	00001517          	auipc	a0,0x1
     140:	0bc50513          	addi	a0,a0,188 # 11f8 <malloc+0x134>
     144:	b7e5                	j	12c <fs_type_name+0x3c>
    case FS_LOG_INSTALL: return "INSTALL";
     146:	00001517          	auipc	a0,0x1
     14a:	0ba50513          	addi	a0,a0,186 # 1200 <malloc+0x13c>
     14e:	bff9                	j	12c <fs_type_name+0x3c>
    case FS_BLOCK_ALLOC: return "BALLOC";
     150:	00001517          	auipc	a0,0x1
     154:	0b850513          	addi	a0,a0,184 # 1208 <malloc+0x144>
     158:	bfd1                	j	12c <fs_type_name+0x3c>
    case FS_BLOCK_FREE:  return "BFREE";
     15a:	00001517          	auipc	a0,0x1
     15e:	0b650513          	addi	a0,a0,182 # 1210 <malloc+0x14c>
     162:	b7e9                	j	12c <fs_type_name+0x3c>
    default: return "FS";
     164:	00001517          	auipc	a0,0x1
     168:	0b450513          	addi	a0,a0,180 # 1218 <malloc+0x154>
     16c:	b7c1                	j	12c <fs_type_name+0x3c>
  switch(t){
     16e:	00001517          	auipc	a0,0x1
     172:	06250513          	addi	a0,a0,98 # 11d0 <malloc+0x10c>
     176:	bf5d                	j	12c <fs_type_name+0x3c>

0000000000000178 <print_fs_event>:
static void print_fs_event(const struct fs_event *e) {
     178:	7119                	addi	sp,sp,-128
     17a:	fc86                	sd	ra,120(sp)
     17c:	f8a2                	sd	s0,112(sp)
     17e:	f4a6                	sd	s1,104(sp)
     180:	f0ca                	sd	s2,96(sp)
     182:	ecce                	sd	s3,88(sp)
     184:	e8d2                	sd	s4,80(sp)
     186:	e4d6                	sd	s5,72(sp)
     188:	e0da                	sd	s6,64(sp)
     18a:	fc5e                	sd	s7,56(sp)
     18c:	f862                	sd	s8,48(sp)
     18e:	0100                	addi	s0,sp,128
     190:	81010113          	addi	sp,sp,-2032
     194:	892a                	mv	s2,a0
  char buf[OUTBUF_SZ];
  int pos = 0;
     196:	77fd                	lui	a5,0xfffff
     198:	fb078793          	addi	a5,a5,-80 # ffffffffffffefb0 <base+0xffffffffffffc860>
     19c:	97a2                	add	a5,a5,s0
     19e:	7e07ae23          	sw	zero,2044(a5)
  memset(buf, 0, sizeof(buf));
     1a2:	6605                	lui	a2,0x1
     1a4:	80060613          	addi	a2,a2,-2048 # 800 <print_fs_event+0x688>
     1a8:	4581                	li	a1,0
     1aa:	74fd                	lui	s1,0xfffff
     1ac:	7b048513          	addi	a0,s1,1968 # fffffffffffff7b0 <base+0xffffffffffffd060>
     1b0:	9522                	add	a0,a0,s0
     1b2:	015000ef          	jal	9c6 <memset>
  append_str(buf, &pos, "EV {\"type\":\"FS\"");
     1b6:	77fd                	lui	a5,0xfffff
     1b8:	7ac78793          	addi	a5,a5,1964 # fffffffffffff7ac <base+0xffffffffffffd05c>
     1bc:	97a2                	add	a5,a5,s0
     1be:	79fd                	lui	s3,0xfffff
     1c0:	79898713          	addi	a4,s3,1944 # fffffffffffff798 <base+0xffffffffffffd048>
     1c4:	9722                	add	a4,a4,s0
     1c6:	e31c                	sd	a5,0(a4)
     1c8:	00001617          	auipc	a2,0x1
     1cc:	05860613          	addi	a2,a2,88 # 1220 <malloc+0x15c>
     1d0:	630c                	ld	a1,0(a4)
     1d2:	7b048513          	addi	a0,s1,1968
     1d6:	9522                	add	a0,a0,s0
     1d8:	e29ff0ef          	jal	0 <append_str>
  append_str(buf, &pos, ",\"seq\":"); append_uint(buf, &pos, (uint)e->seq);
     1dc:	00001617          	auipc	a2,0x1
     1e0:	05460613          	addi	a2,a2,84 # 1230 <malloc+0x16c>
     1e4:	79898793          	addi	a5,s3,1944
     1e8:	97a2                	add	a5,a5,s0
     1ea:	638c                	ld	a1,0(a5)
     1ec:	7b048513          	addi	a0,s1,1968
     1f0:	9522                	add	a0,a0,s0
     1f2:	e0fff0ef          	jal	0 <append_str>
     1f6:	00092603          	lw	a2,0(s2)
     1fa:	79898793          	addi	a5,s3,1944
     1fe:	97a2                	add	a5,a5,s0
     200:	638c                	ld	a1,0(a5)
     202:	7b048513          	addi	a0,s1,1968
     206:	9522                	add	a0,a0,s0
     208:	e2dff0ef          	jal	34 <append_uint>
  append_str(buf, &pos, ",\"tick\":"); append_uint(buf, &pos, e->ticks);
     20c:	00001617          	auipc	a2,0x1
     210:	02c60613          	addi	a2,a2,44 # 1238 <malloc+0x174>
     214:	79898793          	addi	a5,s3,1944
     218:	97a2                	add	a5,a5,s0
     21a:	638c                	ld	a1,0(a5)
     21c:	7b048513          	addi	a0,s1,1968
     220:	9522                	add	a0,a0,s0
     222:	ddfff0ef          	jal	0 <append_str>
     226:	00892603          	lw	a2,8(s2)
     22a:	79898793          	addi	a5,s3,1944
     22e:	97a2                	add	a5,a5,s0
     230:	638c                	ld	a1,0(a5)
     232:	7b048513          	addi	a0,s1,1968
     236:	9522                	add	a0,a0,s0
     238:	dfdff0ef          	jal	34 <append_uint>
  append_str(buf, &pos, ",\"fs_type\":"); append_int(buf, &pos, e->type);
     23c:	00001617          	auipc	a2,0x1
     240:	00c60613          	addi	a2,a2,12 # 1248 <malloc+0x184>
     244:	79898793          	addi	a5,s3,1944
     248:	97a2                	add	a5,a5,s0
     24a:	638c                	ld	a1,0(a5)
     24c:	7b048513          	addi	a0,s1,1968
     250:	9522                	add	a0,a0,s0
     252:	dafff0ef          	jal	0 <append_str>
     256:	00c92a03          	lw	s4,12(s2)
     25a:	8652                	mv	a2,s4
     25c:	79898793          	addi	a5,s3,1944
     260:	97a2                	add	a5,a5,s0
     262:	638c                	ld	a1,0(a5)
     264:	7b048513          	addi	a0,s1,1968
     268:	9522                	add	a0,a0,s0
     26a:	e4fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"pid\":"); append_int(buf, &pos, e->pid);
     26e:	00001617          	auipc	a2,0x1
     272:	fea60613          	addi	a2,a2,-22 # 1258 <malloc+0x194>
     276:	79898793          	addi	a5,s3,1944
     27a:	97a2                	add	a5,a5,s0
     27c:	638c                	ld	a1,0(a5)
     27e:	7b048513          	addi	a0,s1,1968
     282:	9522                	add	a0,a0,s0
     284:	d7dff0ef          	jal	0 <append_str>
     288:	01092603          	lw	a2,16(s2)
     28c:	79898793          	addi	a5,s3,1944
     290:	97a2                	add	a5,a5,s0
     292:	638c                	ld	a1,0(a5)
     294:	7b048513          	addi	a0,s1,1968
     298:	9522                	add	a0,a0,s0
     29a:	e1fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"dev\":"); append_int(buf, &pos, e->dev);
     29e:	00001617          	auipc	a2,0x1
     2a2:	fc260613          	addi	a2,a2,-62 # 1260 <malloc+0x19c>
     2a6:	79898793          	addi	a5,s3,1944
     2aa:	97a2                	add	a5,a5,s0
     2ac:	638c                	ld	a1,0(a5)
     2ae:	7b048513          	addi	a0,s1,1968
     2b2:	9522                	add	a0,a0,s0
     2b4:	d4dff0ef          	jal	0 <append_str>
     2b8:	01492603          	lw	a2,20(s2)
     2bc:	79898793          	addi	a5,s3,1944
     2c0:	97a2                	add	a5,a5,s0
     2c2:	638c                	ld	a1,0(a5)
     2c4:	7b048513          	addi	a0,s1,1968
     2c8:	9522                	add	a0,a0,s0
     2ca:	defff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"block\":"); append_int(buf, &pos, e->blockno);
     2ce:	00001617          	auipc	a2,0x1
     2d2:	f9a60613          	addi	a2,a2,-102 # 1268 <malloc+0x1a4>
     2d6:	79898793          	addi	a5,s3,1944
     2da:	97a2                	add	a5,a5,s0
     2dc:	638c                	ld	a1,0(a5)
     2de:	7b048513          	addi	a0,s1,1968
     2e2:	9522                	add	a0,a0,s0
     2e4:	d1dff0ef          	jal	0 <append_str>
     2e8:	01892603          	lw	a2,24(s2)
     2ec:	79898793          	addi	a5,s3,1944
     2f0:	97a2                	add	a5,a5,s0
     2f2:	638c                	ld	a1,0(a5)
     2f4:	7b048513          	addi	a0,s1,1968
     2f8:	9522                	add	a0,a0,s0
     2fa:	dbfff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"old_block\":"); append_int(buf, &pos, e->old_blockno);
     2fe:	00001617          	auipc	a2,0x1
     302:	f7a60613          	addi	a2,a2,-134 # 1278 <malloc+0x1b4>
     306:	79898793          	addi	a5,s3,1944
     30a:	97a2                	add	a5,a5,s0
     30c:	638c                	ld	a1,0(a5)
     30e:	7b048513          	addi	a0,s1,1968
     312:	9522                	add	a0,a0,s0
     314:	cedff0ef          	jal	0 <append_str>
     318:	01c92603          	lw	a2,28(s2)
     31c:	79898793          	addi	a5,s3,1944
     320:	97a2                	add	a5,a5,s0
     322:	638c                	ld	a1,0(a5)
     324:	7b048513          	addi	a0,s1,1968
     328:	9522                	add	a0,a0,s0
     32a:	d8fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"buf_id\":"); append_int(buf, &pos, e->buf_id);
     32e:	00001617          	auipc	a2,0x1
     332:	f5a60613          	addi	a2,a2,-166 # 1288 <malloc+0x1c4>
     336:	79898793          	addi	a5,s3,1944
     33a:	97a2                	add	a5,a5,s0
     33c:	638c                	ld	a1,0(a5)
     33e:	7b048513          	addi	a0,s1,1968
     342:	9522                	add	a0,a0,s0
     344:	cbdff0ef          	jal	0 <append_str>
     348:	02092603          	lw	a2,32(s2)
     34c:	79898793          	addi	a5,s3,1944
     350:	97a2                	add	a5,a5,s0
     352:	638c                	ld	a1,0(a5)
     354:	7b048513          	addi	a0,s1,1968
     358:	9522                	add	a0,a0,s0
     35a:	d5fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"ref_before\":"); append_int(buf, &pos, e->ref_before);
     35e:	00001617          	auipc	a2,0x1
     362:	f3a60613          	addi	a2,a2,-198 # 1298 <malloc+0x1d4>
     366:	79898793          	addi	a5,s3,1944
     36a:	97a2                	add	a5,a5,s0
     36c:	638c                	ld	a1,0(a5)
     36e:	7b048513          	addi	a0,s1,1968
     372:	9522                	add	a0,a0,s0
     374:	c8dff0ef          	jal	0 <append_str>
     378:	02492603          	lw	a2,36(s2)
     37c:	79898793          	addi	a5,s3,1944
     380:	97a2                	add	a5,a5,s0
     382:	638c                	ld	a1,0(a5)
     384:	7b048513          	addi	a0,s1,1968
     388:	9522                	add	a0,a0,s0
     38a:	d2fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"ref_after\":"); append_int(buf, &pos, e->ref_after);
     38e:	00001617          	auipc	a2,0x1
     392:	f1a60613          	addi	a2,a2,-230 # 12a8 <malloc+0x1e4>
     396:	79898793          	addi	a5,s3,1944
     39a:	97a2                	add	a5,a5,s0
     39c:	638c                	ld	a1,0(a5)
     39e:	7b048513          	addi	a0,s1,1968
     3a2:	9522                	add	a0,a0,s0
     3a4:	c5dff0ef          	jal	0 <append_str>
     3a8:	02892603          	lw	a2,40(s2)
     3ac:	79898793          	addi	a5,s3,1944
     3b0:	97a2                	add	a5,a5,s0
     3b2:	638c                	ld	a1,0(a5)
     3b4:	7b048513          	addi	a0,s1,1968
     3b8:	9522                	add	a0,a0,s0
     3ba:	cffff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"valid_before\":"); append_int(buf, &pos, e->valid_before);
     3be:	00001617          	auipc	a2,0x1
     3c2:	efa60613          	addi	a2,a2,-262 # 12b8 <malloc+0x1f4>
     3c6:	79898793          	addi	a5,s3,1944
     3ca:	97a2                	add	a5,a5,s0
     3cc:	638c                	ld	a1,0(a5)
     3ce:	7b048513          	addi	a0,s1,1968
     3d2:	9522                	add	a0,a0,s0
     3d4:	c2dff0ef          	jal	0 <append_str>
     3d8:	02c92603          	lw	a2,44(s2)
     3dc:	79898793          	addi	a5,s3,1944
     3e0:	97a2                	add	a5,a5,s0
     3e2:	638c                	ld	a1,0(a5)
     3e4:	7b048513          	addi	a0,s1,1968
     3e8:	9522                	add	a0,a0,s0
     3ea:	ccfff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"valid_after\":"); append_int(buf, &pos, e->valid_after);
     3ee:	00001617          	auipc	a2,0x1
     3f2:	ee260613          	addi	a2,a2,-286 # 12d0 <malloc+0x20c>
     3f6:	79898793          	addi	a5,s3,1944
     3fa:	97a2                	add	a5,a5,s0
     3fc:	638c                	ld	a1,0(a5)
     3fe:	7b048513          	addi	a0,s1,1968
     402:	9522                	add	a0,a0,s0
     404:	bfdff0ef          	jal	0 <append_str>
     408:	03092603          	lw	a2,48(s2)
     40c:	79898793          	addi	a5,s3,1944
     410:	97a2                	add	a5,a5,s0
     412:	638c                	ld	a1,0(a5)
     414:	7b048513          	addi	a0,s1,1968
     418:	9522                	add	a0,a0,s0
     41a:	c9fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"locked_before\":"); append_int(buf, &pos, e->locked_before);
     41e:	00001617          	auipc	a2,0x1
     422:	ec260613          	addi	a2,a2,-318 # 12e0 <malloc+0x21c>
     426:	79898793          	addi	a5,s3,1944
     42a:	97a2                	add	a5,a5,s0
     42c:	638c                	ld	a1,0(a5)
     42e:	7b048513          	addi	a0,s1,1968
     432:	9522                	add	a0,a0,s0
     434:	bcdff0ef          	jal	0 <append_str>
     438:	03492603          	lw	a2,52(s2)
     43c:	79898793          	addi	a5,s3,1944
     440:	97a2                	add	a5,a5,s0
     442:	638c                	ld	a1,0(a5)
     444:	7b048513          	addi	a0,s1,1968
     448:	9522                	add	a0,a0,s0
     44a:	c6fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"locked_after\":"); append_int(buf, &pos, e->locked_after);
     44e:	00001617          	auipc	a2,0x1
     452:	eaa60613          	addi	a2,a2,-342 # 12f8 <malloc+0x234>
     456:	79898793          	addi	a5,s3,1944
     45a:	97a2                	add	a5,a5,s0
     45c:	638c                	ld	a1,0(a5)
     45e:	7b048513          	addi	a0,s1,1968
     462:	9522                	add	a0,a0,s0
     464:	b9dff0ef          	jal	0 <append_str>
     468:	03892603          	lw	a2,56(s2)
     46c:	79898793          	addi	a5,s3,1944
     470:	97a2                	add	a5,a5,s0
     472:	638c                	ld	a1,0(a5)
     474:	7b048513          	addi	a0,s1,1968
     478:	9522                	add	a0,a0,s0
     47a:	c3fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"lru_before\":"); append_int(buf, &pos, e->lru_before);
     47e:	00001617          	auipc	a2,0x1
     482:	e9260613          	addi	a2,a2,-366 # 1310 <malloc+0x24c>
     486:	79898793          	addi	a5,s3,1944
     48a:	97a2                	add	a5,a5,s0
     48c:	638c                	ld	a1,0(a5)
     48e:	7b048513          	addi	a0,s1,1968
     492:	9522                	add	a0,a0,s0
     494:	b6dff0ef          	jal	0 <append_str>
     498:	03c92603          	lw	a2,60(s2)
     49c:	79898793          	addi	a5,s3,1944
     4a0:	97a2                	add	a5,a5,s0
     4a2:	638c                	ld	a1,0(a5)
     4a4:	7b048513          	addi	a0,s1,1968
     4a8:	9522                	add	a0,a0,s0
     4aa:	c0fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"lru_after\":"); append_int(buf, &pos, e->lru_after);
     4ae:	00001617          	auipc	a2,0x1
     4b2:	e7260613          	addi	a2,a2,-398 # 1320 <malloc+0x25c>
     4b6:	79898793          	addi	a5,s3,1944
     4ba:	97a2                	add	a5,a5,s0
     4bc:	638c                	ld	a1,0(a5)
     4be:	7b048513          	addi	a0,s1,1968
     4c2:	9522                	add	a0,a0,s0
     4c4:	b3dff0ef          	jal	0 <append_str>
     4c8:	04092603          	lw	a2,64(s2)
     4cc:	79898793          	addi	a5,s3,1944
     4d0:	97a2                	add	a5,a5,s0
     4d2:	638c                	ld	a1,0(a5)
     4d4:	7b048513          	addi	a0,s1,1968
     4d8:	9522                	add	a0,a0,s0
     4da:	bdfff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"scan_dir\":"); append_int(buf, &pos, e->scan_dir);
     4de:	00001617          	auipc	a2,0x1
     4e2:	e5260613          	addi	a2,a2,-430 # 1330 <malloc+0x26c>
     4e6:	79898793          	addi	a5,s3,1944
     4ea:	97a2                	add	a5,a5,s0
     4ec:	638c                	ld	a1,0(a5)
     4ee:	7b048513          	addi	a0,s1,1968
     4f2:	9522                	add	a0,a0,s0
     4f4:	b0dff0ef          	jal	0 <append_str>
     4f8:	04492603          	lw	a2,68(s2)
     4fc:	79898793          	addi	a5,s3,1944
     500:	97a2                	add	a5,a5,s0
     502:	638c                	ld	a1,0(a5)
     504:	7b048513          	addi	a0,s1,1968
     508:	9522                	add	a0,a0,s0
     50a:	bafff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"scan_step\":"); append_int(buf, &pos, e->scan_step);
     50e:	00001617          	auipc	a2,0x1
     512:	e3260613          	addi	a2,a2,-462 # 1340 <malloc+0x27c>
     516:	79898793          	addi	a5,s3,1944
     51a:	97a2                	add	a5,a5,s0
     51c:	638c                	ld	a1,0(a5)
     51e:	7b048513          	addi	a0,s1,1968
     522:	9522                	add	a0,a0,s0
     524:	addff0ef          	jal	0 <append_str>
     528:	04892603          	lw	a2,72(s2)
     52c:	79898793          	addi	a5,s3,1944
     530:	97a2                	add	a5,a5,s0
     532:	638c                	ld	a1,0(a5)
     534:	7b048513          	addi	a0,s1,1968
     538:	9522                	add	a0,a0,s0
     53a:	b7fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"found\":"); append_int(buf, &pos, e->found);
     53e:	00001617          	auipc	a2,0x1
     542:	e1260613          	addi	a2,a2,-494 # 1350 <malloc+0x28c>
     546:	79898793          	addi	a5,s3,1944
     54a:	97a2                	add	a5,a5,s0
     54c:	638c                	ld	a1,0(a5)
     54e:	7b048513          	addi	a0,s1,1968
     552:	9522                	add	a0,a0,s0
     554:	aadff0ef          	jal	0 <append_str>
     558:	04c92603          	lw	a2,76(s2)
     55c:	79898793          	addi	a5,s3,1944
     560:	97a2                	add	a5,a5,s0
     562:	638c                	ld	a1,0(a5)
     564:	7b048513          	addi	a0,s1,1968
     568:	9522                	add	a0,a0,s0
     56a:	b4fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"size\":"); append_uint(buf, &pos, e->size);
     56e:	00001617          	auipc	a2,0x1
     572:	df260613          	addi	a2,a2,-526 # 1360 <malloc+0x29c>
     576:	79898793          	addi	a5,s3,1944
     57a:	97a2                	add	a5,a5,s0
     57c:	638c                	ld	a1,0(a5)
     57e:	7b048513          	addi	a0,s1,1968
     582:	9522                	add	a0,a0,s0
     584:	a7dff0ef          	jal	0 <append_str>
     588:	05092603          	lw	a2,80(s2)
     58c:	79898793          	addi	a5,s3,1944
     590:	97a2                	add	a5,a5,s0
     592:	638c                	ld	a1,0(a5)
     594:	7b048513          	addi	a0,s1,1968
     598:	9522                	add	a0,a0,s0
     59a:	a9bff0ef          	jal	34 <append_uint>
  append_str(buf, &pos, ",\"inum\":"); append_int(buf, &pos, e->inum);
     59e:	00001617          	auipc	a2,0x1
     5a2:	dd260613          	addi	a2,a2,-558 # 1370 <malloc+0x2ac>
     5a6:	79898793          	addi	a5,s3,1944
     5aa:	97a2                	add	a5,a5,s0
     5ac:	638c                	ld	a1,0(a5)
     5ae:	7b048513          	addi	a0,s1,1968
     5b2:	9522                	add	a0,a0,s0
     5b4:	a4dff0ef          	jal	0 <append_str>
     5b8:	07092603          	lw	a2,112(s2)
     5bc:	79898793          	addi	a5,s3,1944
     5c0:	97a2                	add	a5,a5,s0
     5c2:	638c                	ld	a1,0(a5)
     5c4:	7b048513          	addi	a0,s1,1968
     5c8:	9522                	add	a0,a0,s0
     5ca:	aefff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"i_type\":"); append_int(buf, &pos, e->i_type);
     5ce:	00001617          	auipc	a2,0x1
     5d2:	db260613          	addi	a2,a2,-590 # 1380 <malloc+0x2bc>
     5d6:	79898793          	addi	a5,s3,1944
     5da:	97a2                	add	a5,a5,s0
     5dc:	638c                	ld	a1,0(a5)
     5de:	7b048513          	addi	a0,s1,1968
     5e2:	9522                	add	a0,a0,s0
     5e4:	a1dff0ef          	jal	0 <append_str>
     5e8:	07491603          	lh	a2,116(s2)
     5ec:	79898793          	addi	a5,s3,1944
     5f0:	97a2                	add	a5,a5,s0
     5f2:	638c                	ld	a1,0(a5)
     5f4:	7b048513          	addi	a0,s1,1968
     5f8:	9522                	add	a0,a0,s0
     5fa:	abfff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"nlink\":"); append_int(buf, &pos, e->nlink);
     5fe:	00001617          	auipc	a2,0x1
     602:	d9260613          	addi	a2,a2,-622 # 1390 <malloc+0x2cc>
     606:	79898793          	addi	a5,s3,1944
     60a:	97a2                	add	a5,a5,s0
     60c:	638c                	ld	a1,0(a5)
     60e:	7b048513          	addi	a0,s1,1968
     612:	9522                	add	a0,a0,s0
     614:	9edff0ef          	jal	0 <append_str>
     618:	07892603          	lw	a2,120(s2)
     61c:	79898793          	addi	a5,s3,1944
     620:	97a2                	add	a5,a5,s0
     622:	638c                	ld	a1,0(a5)
     624:	7b048513          	addi	a0,s1,1968
     628:	9522                	add	a0,a0,s0
     62a:	a8fff0ef          	jal	b8 <append_int>
  append_str(buf, &pos, ",\"i_size\":"); append_uint(buf, &pos, e->i_size);
     62e:	00001617          	auipc	a2,0x1
     632:	d7260613          	addi	a2,a2,-654 # 13a0 <malloc+0x2dc>
     636:	79898793          	addi	a5,s3,1944
     63a:	97a2                	add	a5,a5,s0
     63c:	638c                	ld	a1,0(a5)
     63e:	7b048513          	addi	a0,s1,1968
     642:	9522                	add	a0,a0,s0
     644:	9bdff0ef          	jal	0 <append_str>
     648:	07c92603          	lw	a2,124(s2)
     64c:	79898793          	addi	a5,s3,1944
     650:	97a2                	add	a5,a5,s0
     652:	638c                	ld	a1,0(a5)
     654:	7b048513          	addi	a0,s1,1968
     658:	9522                	add	a0,a0,s0
     65a:	9dbff0ef          	jal	34 <append_uint>
  append_str(buf, &pos, ",\"addrs\":\"");
     65e:	00001617          	auipc	a2,0x1
     662:	d5260613          	addi	a2,a2,-686 # 13b0 <malloc+0x2ec>
     666:	79898793          	addi	a5,s3,1944
     66a:	97a2                	add	a5,a5,s0
     66c:	638c                	ld	a1,0(a5)
     66e:	7b048513          	addi	a0,s1,1968
     672:	9522                	add	a0,a0,s0
     674:	98dff0ef          	jal	0 <append_str>
for(int i=0; i<13; i++){
     678:	08090493          	addi	s1,s2,128
     67c:	0b090a93          	addi	s5,s2,176
     680:	0b490b13          	addi	s6,s2,180
    append_uint(buf, &pos, e->addrs[i]);
     684:	77fd                	lui	a5,0xfffff
     686:	7ac78793          	addi	a5,a5,1964 # fffffffffffff7ac <base+0xffffffffffffd05c>
     68a:	97a2                	add	a5,a5,s0
     68c:	79898713          	addi	a4,s3,1944
     690:	9722                	add	a4,a4,s0
     692:	e31c                	sd	a5,0(a4)
  if (*pos < OUTBUF_SZ - 1)
     694:	fb098793          	addi	a5,s3,-80
     698:	008789b3          	add	s3,a5,s0
     69c:	7fe00b93          	li	s7,2046
    buf[(*pos)++] = c;
     6a0:	02c00c13          	li	s8,44
     6a4:	a021                	j	6ac <print_fs_event+0x534>
for(int i=0; i<13; i++){
     6a6:	0491                	addi	s1,s1,4
     6a8:	03648e63          	beq	s1,s6,6e4 <print_fs_event+0x56c>
    append_uint(buf, &pos, e->addrs[i]);
     6ac:	4090                	lw	a2,0(s1)
     6ae:	77fd                	lui	a5,0xfffff
     6b0:	79878793          	addi	a5,a5,1944 # fffffffffffff798 <base+0xffffffffffffd048>
     6b4:	97a2                	add	a5,a5,s0
     6b6:	638c                	ld	a1,0(a5)
     6b8:	77fd                	lui	a5,0xfffff
     6ba:	7b078513          	addi	a0,a5,1968 # fffffffffffff7b0 <base+0xffffffffffffd060>
     6be:	9522                	add	a0,a0,s0
     6c0:	975ff0ef          	jal	34 <append_uint>
    if(i < 12) append_char(buf, &pos, ',');
     6c4:	03548063          	beq	s1,s5,6e4 <print_fs_event+0x56c>
  if (*pos < OUTBUF_SZ - 1)
     6c8:	7fc9a783          	lw	a5,2044(s3)
     6cc:	fcfbcde3          	blt	s7,a5,6a6 <print_fs_event+0x52e>
    buf[(*pos)++] = c;
     6d0:	0017871b          	addiw	a4,a5,1
     6d4:	7ee9ae23          	sw	a4,2044(s3)
     6d8:	fb078793          	addi	a5,a5,-80
     6dc:	97a2                	add	a5,a5,s0
     6de:	81878023          	sb	s8,-2048(a5)
     6e2:	b7d1                	j	6a6 <print_fs_event+0x52e>
}
  append_str(buf, &pos, "\"");
     6e4:	77fd                	lui	a5,0xfffff
     6e6:	7ac78793          	addi	a5,a5,1964 # fffffffffffff7ac <base+0xffffffffffffd05c>
     6ea:	97a2                	add	a5,a5,s0
     6ec:	79fd                	lui	s3,0xfffff
     6ee:	79898713          	addi	a4,s3,1944 # fffffffffffff798 <base+0xffffffffffffd048>
     6f2:	9722                	add	a4,a4,s0
     6f4:	e31c                	sd	a5,0(a4)
     6f6:	00001617          	auipc	a2,0x1
     6fa:	cd260613          	addi	a2,a2,-814 # 13c8 <malloc+0x304>
     6fe:	630c                	ld	a1,0(a4)
     700:	74fd                	lui	s1,0xfffff
     702:	7b048513          	addi	a0,s1,1968 # fffffffffffff7b0 <base+0xffffffffffffd060>
     706:	9522                	add	a0,a0,s0
     708:	8f9ff0ef          	jal	0 <append_str>
  append_str(buf, &pos, ",\"name\":\"");
     70c:	00001617          	auipc	a2,0x1
     710:	cb460613          	addi	a2,a2,-844 # 13c0 <malloc+0x2fc>
     714:	79898793          	addi	a5,s3,1944
     718:	97a2                	add	a5,a5,s0
     71a:	638c                	ld	a1,0(a5)
     71c:	7b048513          	addi	a0,s1,1968
     720:	9522                	add	a0,a0,s0
     722:	8dfff0ef          	jal	0 <append_str>
  append_json_string(buf, &pos, e->name);
     726:	05490693          	addi	a3,s2,84
  while (*s && *pos < OUTBUF_SZ - 1) {
     72a:	05494783          	lbu	a5,84(s2)
     72e:	cfd9                	beqz	a5,7cc <print_fs_event+0x654>
     730:	777d                	lui	a4,0xfffff
     732:	fb070713          	addi	a4,a4,-80 # ffffffffffffefb0 <base+0xffffffffffffc860>
     736:	9722                	add	a4,a4,s0
     738:	7fc72703          	lw	a4,2044(a4)
     73c:	4881                	li	a7,0
     73e:	7fe00593          	li	a1,2046
    if (c == '"' || c == '\\') {
     742:	02200813          	li	a6,34
    buf[(*pos)++] = c;
     746:	05c00513          	li	a0,92
     74a:	4305                	li	t1,1
    } else if (c >= 32 && c < 127) {
     74c:	05e00e13          	li	t3,94
     750:	a02d                	j	77a <print_fs_event+0x602>
    buf[(*pos)++] = c;
     752:	0017061b          	addiw	a2,a4,1
     756:	fb070493          	addi	s1,a4,-80
     75a:	008488b3          	add	a7,s1,s0
     75e:	80a88023          	sb	a0,-2048(a7)
  if (*pos < OUTBUF_SZ - 1)
     762:	04c5c163          	blt	a1,a2,7a4 <print_fs_event+0x62c>
    buf[(*pos)++] = c;
     766:	2709                	addiw	a4,a4,2
     768:	fb060613          	addi	a2,a2,-80
     76c:	9622                	add	a2,a2,s0
     76e:	80f60023          	sb	a5,-2048(a2)
     772:	889a                	mv	a7,t1
  while (*s && *pos < OUTBUF_SZ - 1) {
     774:	0006c783          	lbu	a5,0(a3)
     778:	cb8d                	beqz	a5,7aa <print_fs_event+0x632>
     77a:	04e5c163          	blt	a1,a4,7bc <print_fs_event+0x644>
    char c = *s++;
     77e:	0685                	addi	a3,a3,1
    if (c == '"' || c == '\\') {
     780:	fd0789e3          	beq	a5,a6,752 <print_fs_event+0x5da>
     784:	fca787e3          	beq	a5,a0,752 <print_fs_event+0x5da>
    } else if (c >= 32 && c < 127) {
     788:	fe07861b          	addiw	a2,a5,-32
     78c:	0ff67613          	zext.b	a2,a2
     790:	fece62e3          	bltu	t3,a2,774 <print_fs_event+0x5fc>
    buf[(*pos)++] = c;
     794:	fb070613          	addi	a2,a4,-80
     798:	9622                	add	a2,a2,s0
     79a:	80f60023          	sb	a5,-2048(a2)
     79e:	2705                	addiw	a4,a4,1
}
     7a0:	889a                	mv	a7,t1
     7a2:	bfc9                	j	774 <print_fs_event+0x5fc>
    buf[(*pos)++] = c;
     7a4:	8732                	mv	a4,a2
     7a6:	889a                	mv	a7,t1
     7a8:	b7f1                	j	774 <print_fs_event+0x5fc>
     7aa:	02088163          	beqz	a7,7cc <print_fs_event+0x654>
     7ae:	77fd                	lui	a5,0xfffff
     7b0:	fb078793          	addi	a5,a5,-80 # ffffffffffffefb0 <base+0xffffffffffffc860>
     7b4:	97a2                	add	a5,a5,s0
     7b6:	7ee7ae23          	sw	a4,2044(a5)
     7ba:	a809                	j	7cc <print_fs_event+0x654>
     7bc:	00088863          	beqz	a7,7cc <print_fs_event+0x654>
     7c0:	77fd                	lui	a5,0xfffff
     7c2:	fb078793          	addi	a5,a5,-80 # ffffffffffffefb0 <base+0xffffffffffffc860>
     7c6:	97a2                	add	a5,a5,s0
     7c8:	7ee7ae23          	sw	a4,2044(a5)
  append_str(buf, &pos, "\"");
     7cc:	77fd                	lui	a5,0xfffff
     7ce:	7ac78793          	addi	a5,a5,1964 # fffffffffffff7ac <base+0xffffffffffffd05c>
     7d2:	97a2                	add	a5,a5,s0
     7d4:	797d                	lui	s2,0xfffff
     7d6:	79890713          	addi	a4,s2,1944 # fffffffffffff798 <base+0xffffffffffffd048>
     7da:	9722                	add	a4,a4,s0
     7dc:	e31c                	sd	a5,0(a4)
     7de:	00001617          	auipc	a2,0x1
     7e2:	bea60613          	addi	a2,a2,-1046 # 13c8 <malloc+0x304>
     7e6:	630c                	ld	a1,0(a4)
     7e8:	74fd                	lui	s1,0xfffff
     7ea:	7b048513          	addi	a0,s1,1968 # fffffffffffff7b0 <base+0xffffffffffffd060>
     7ee:	9522                	add	a0,a0,s0
     7f0:	811ff0ef          	jal	0 <append_str>
  append_str(buf, &pos, ",\"op\":\"");
     7f4:	00001617          	auipc	a2,0x1
     7f8:	bdc60613          	addi	a2,a2,-1060 # 13d0 <malloc+0x30c>
     7fc:	79890793          	addi	a5,s2,1944
     800:	97a2                	add	a5,a5,s0
     802:	638c                	ld	a1,0(a5)
     804:	7b048513          	addi	a0,s1,1968
     808:	9522                	add	a0,a0,s0
     80a:	ff6ff0ef          	jal	0 <append_str>
  append_str(buf, &pos, fs_type_name(e->type));
     80e:	8552                	mv	a0,s4
     810:	8e1ff0ef          	jal	f0 <fs_type_name>
     814:	862a                	mv	a2,a0
     816:	79890793          	addi	a5,s2,1944
     81a:	97a2                	add	a5,a5,s0
     81c:	638c                	ld	a1,0(a5)
     81e:	7b048513          	addi	a0,s1,1968
     822:	9522                	add	a0,a0,s0
     824:	fdcff0ef          	jal	0 <append_str>
  append_str(buf, &pos, "\"");
     828:	00001617          	auipc	a2,0x1
     82c:	ba060613          	addi	a2,a2,-1120 # 13c8 <malloc+0x304>
     830:	79890793          	addi	a5,s2,1944
     834:	97a2                	add	a5,a5,s0
     836:	638c                	ld	a1,0(a5)
     838:	7b048513          	addi	a0,s1,1968
     83c:	9522                	add	a0,a0,s0
     83e:	fc2ff0ef          	jal	0 <append_str>
  append_str(buf, &pos, "}\n"); // إغلاق الكائن بشكل صحيح
     842:	00001617          	auipc	a2,0x1
     846:	be660613          	addi	a2,a2,-1050 # 1428 <malloc+0x364>
     84a:	79890793          	addi	a5,s2,1944
     84e:	97a2                	add	a5,a5,s0
     850:	638c                	ld	a1,0(a5)
     852:	7b048513          	addi	a0,s1,1968
     856:	9522                	add	a0,a0,s0
     858:	fa8ff0ef          	jal	0 <append_str>
  write(1, buf, pos);
     85c:	77fd                	lui	a5,0xfffff
     85e:	fb078793          	addi	a5,a5,-80 # ffffffffffffefb0 <base+0xffffffffffffc860>
     862:	97a2                	add	a5,a5,s0
     864:	7fc7a603          	lw	a2,2044(a5)
     868:	7b048593          	addi	a1,s1,1968
     86c:	95a2                	add	a1,a1,s0
     86e:	4505                	li	a0,1
     870:	388000ef          	jal	bf8 <write>
}
     874:	7f010113          	addi	sp,sp,2032
     878:	70e6                	ld	ra,120(sp)
     87a:	7446                	ld	s0,112(sp)
     87c:	74a6                	ld	s1,104(sp)
     87e:	7906                	ld	s2,96(sp)
     880:	69e6                	ld	s3,88(sp)
     882:	6a46                	ld	s4,80(sp)
     884:	6aa6                	ld	s5,72(sp)
     886:	6b06                	ld	s6,64(sp)
     888:	7be2                	ld	s7,56(sp)
     88a:	7c42                	ld	s8,48(sp)
     88c:	6109                	addi	sp,sp,128
     88e:	8082                	ret

0000000000000890 <main>:

static void print_cs_event(const struct cs_event *e) {
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
           e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
}
int main(void) {
     890:	715d                	addi	sp,sp,-80
     892:	e486                	sd	ra,72(sp)
     894:	e0a2                	sd	s0,64(sp)
     896:	fc26                	sd	s1,56(sp)
     898:	f84a                	sd	s2,48(sp)
     89a:	f44e                	sd	s3,40(sp)
     89c:	f052                	sd	s4,32(sp)
     89e:	ec56                	sd	s5,24(sp)
     8a0:	e85a                	sd	s6,16(sp)
     8a2:	e45e                	sd	s7,8(sp)
     8a4:	0880                	addi	s0,sp,80
    while (1) {
        int n_cs = csread(cs_ev, 8);
     8a6:	00001b17          	auipc	s6,0x1
     8aa:	76ab0b13          	addi	s6,s6,1898 # 2010 <cs_ev>
        for (int i = 0; i < n_cs; i++) {
            if (cs_ev[i].type == 1)
     8ae:	4985                	li	s3,1
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
     8b0:	00001a17          	auipc	s4,0x1
     8b4:	b28a0a13          	addi	s4,s4,-1240 # 13d8 <malloc+0x314>
                print_cs_event(&cs_ev[i]);
        }
        int n_fs = fsread(fs_ev, 8);
     8b8:	00002a97          	auipc	s5,0x2
     8bc:	8d8a8a93          	addi	s5,s5,-1832 # 2190 <fs_ev>
     8c0:	0b800b93          	li	s7,184
     8c4:	a085                	j	924 <main+0x94>
        for (int i = 0; i < n_cs; i++) {
     8c6:	03048493          	addi	s1,s1,48
     8ca:	03248563          	beq	s1,s2,8f4 <main+0x64>
            if (cs_ev[i].type == 1)
     8ce:	ff44a783          	lw	a5,-12(s1)
     8d2:	ff379ae3          	bne	a5,s3,8c6 <main+0x36>
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
     8d6:	ffc4a803          	lw	a6,-4(s1)
     8da:	87a6                	mv	a5,s1
     8dc:	ff84a703          	lw	a4,-8(s1)
     8e0:	ff04a683          	lw	a3,-16(s1)
     8e4:	fec4a603          	lw	a2,-20(s1)
     8e8:	fe44b583          	ld	a1,-28(s1)
     8ec:	8552                	mv	a0,s4
     8ee:	722000ef          	jal	1010 <printf>
}
     8f2:	bfd1                	j	8c6 <main+0x36>
        int n_fs = fsread(fs_ev, 8);
     8f4:	45a1                	li	a1,8
     8f6:	8556                	mv	a0,s5
     8f8:	388000ef          	jal	c80 <fsread>
        for (int i = 0; i < n_fs; i++) {
     8fc:	02a05163          	blez	a0,91e <main+0x8e>
     900:	00002917          	auipc	s2,0x2
     904:	89090913          	addi	s2,s2,-1904 # 2190 <fs_ev>
     908:	03750533          	mul	a0,a0,s7
     90c:	012504b3          	add	s1,a0,s2
            print_fs_event(&fs_ev[i]);
     910:	854a                	mv	a0,s2
     912:	867ff0ef          	jal	178 <print_fs_event>
        for (int i = 0; i < n_fs; i++) {
     916:	0b890913          	addi	s2,s2,184
     91a:	fe991be3          	bne	s2,s1,910 <main+0x80>
        }
        pause(2);
     91e:	4509                	li	a0,2
     920:	348000ef          	jal	c68 <pause>
        int n_cs = csread(cs_ev, 8);
     924:	45a1                	li	a1,8
     926:	855a                	mv	a0,s6
     928:	350000ef          	jal	c78 <csread>
        for (int i = 0; i < n_cs; i++) {
     92c:	fca054e3          	blez	a0,8f4 <main+0x64>
     930:	00001497          	auipc	s1,0x1
     934:	6fc48493          	addi	s1,s1,1788 # 202c <cs_ev+0x1c>
     938:	00151913          	slli	s2,a0,0x1
     93c:	992a                	add	s2,s2,a0
     93e:	0912                	slli	s2,s2,0x4
     940:	9926                	add	s2,s2,s1
     942:	b771                	j	8ce <main+0x3e>

0000000000000944 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     944:	1141                	addi	sp,sp,-16
     946:	e406                	sd	ra,8(sp)
     948:	e022                	sd	s0,0(sp)
     94a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     94c:	f45ff0ef          	jal	890 <main>
  exit(r);
     950:	288000ef          	jal	bd8 <exit>

0000000000000954 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     954:	1141                	addi	sp,sp,-16
     956:	e422                	sd	s0,8(sp)
     958:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     95a:	87aa                	mv	a5,a0
     95c:	0585                	addi	a1,a1,1
     95e:	0785                	addi	a5,a5,1
     960:	fff5c703          	lbu	a4,-1(a1)
     964:	fee78fa3          	sb	a4,-1(a5)
     968:	fb75                	bnez	a4,95c <strcpy+0x8>
    ;
  return os;
}
     96a:	6422                	ld	s0,8(sp)
     96c:	0141                	addi	sp,sp,16
     96e:	8082                	ret

0000000000000970 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     970:	1141                	addi	sp,sp,-16
     972:	e422                	sd	s0,8(sp)
     974:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     976:	00054783          	lbu	a5,0(a0)
     97a:	cb91                	beqz	a5,98e <strcmp+0x1e>
     97c:	0005c703          	lbu	a4,0(a1)
     980:	00f71763          	bne	a4,a5,98e <strcmp+0x1e>
    p++, q++;
     984:	0505                	addi	a0,a0,1
     986:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     988:	00054783          	lbu	a5,0(a0)
     98c:	fbe5                	bnez	a5,97c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     98e:	0005c503          	lbu	a0,0(a1)
}
     992:	40a7853b          	subw	a0,a5,a0
     996:	6422                	ld	s0,8(sp)
     998:	0141                	addi	sp,sp,16
     99a:	8082                	ret

000000000000099c <strlen>:

uint
strlen(const char *s)
{
     99c:	1141                	addi	sp,sp,-16
     99e:	e422                	sd	s0,8(sp)
     9a0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     9a2:	00054783          	lbu	a5,0(a0)
     9a6:	cf91                	beqz	a5,9c2 <strlen+0x26>
     9a8:	0505                	addi	a0,a0,1
     9aa:	87aa                	mv	a5,a0
     9ac:	86be                	mv	a3,a5
     9ae:	0785                	addi	a5,a5,1
     9b0:	fff7c703          	lbu	a4,-1(a5)
     9b4:	ff65                	bnez	a4,9ac <strlen+0x10>
     9b6:	40a6853b          	subw	a0,a3,a0
     9ba:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     9bc:	6422                	ld	s0,8(sp)
     9be:	0141                	addi	sp,sp,16
     9c0:	8082                	ret
  for(n = 0; s[n]; n++)
     9c2:	4501                	li	a0,0
     9c4:	bfe5                	j	9bc <strlen+0x20>

00000000000009c6 <memset>:

void*
memset(void *dst, int c, uint n)
{
     9c6:	1141                	addi	sp,sp,-16
     9c8:	e422                	sd	s0,8(sp)
     9ca:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     9cc:	ca19                	beqz	a2,9e2 <memset+0x1c>
     9ce:	87aa                	mv	a5,a0
     9d0:	1602                	slli	a2,a2,0x20
     9d2:	9201                	srli	a2,a2,0x20
     9d4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     9d8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     9dc:	0785                	addi	a5,a5,1
     9de:	fee79de3          	bne	a5,a4,9d8 <memset+0x12>
  }
  return dst;
}
     9e2:	6422                	ld	s0,8(sp)
     9e4:	0141                	addi	sp,sp,16
     9e6:	8082                	ret

00000000000009e8 <strchr>:

char*
strchr(const char *s, char c)
{
     9e8:	1141                	addi	sp,sp,-16
     9ea:	e422                	sd	s0,8(sp)
     9ec:	0800                	addi	s0,sp,16
  for(; *s; s++)
     9ee:	00054783          	lbu	a5,0(a0)
     9f2:	cb99                	beqz	a5,a08 <strchr+0x20>
    if(*s == c)
     9f4:	00f58763          	beq	a1,a5,a02 <strchr+0x1a>
  for(; *s; s++)
     9f8:	0505                	addi	a0,a0,1
     9fa:	00054783          	lbu	a5,0(a0)
     9fe:	fbfd                	bnez	a5,9f4 <strchr+0xc>
      return (char*)s;
  return 0;
     a00:	4501                	li	a0,0
}
     a02:	6422                	ld	s0,8(sp)
     a04:	0141                	addi	sp,sp,16
     a06:	8082                	ret
  return 0;
     a08:	4501                	li	a0,0
     a0a:	bfe5                	j	a02 <strchr+0x1a>

0000000000000a0c <gets>:

char*
gets(char *buf, int max)
{
     a0c:	711d                	addi	sp,sp,-96
     a0e:	ec86                	sd	ra,88(sp)
     a10:	e8a2                	sd	s0,80(sp)
     a12:	e4a6                	sd	s1,72(sp)
     a14:	e0ca                	sd	s2,64(sp)
     a16:	fc4e                	sd	s3,56(sp)
     a18:	f852                	sd	s4,48(sp)
     a1a:	f456                	sd	s5,40(sp)
     a1c:	f05a                	sd	s6,32(sp)
     a1e:	ec5e                	sd	s7,24(sp)
     a20:	1080                	addi	s0,sp,96
     a22:	8baa                	mv	s7,a0
     a24:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a26:	892a                	mv	s2,a0
     a28:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     a2a:	4aa9                	li	s5,10
     a2c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     a2e:	89a6                	mv	s3,s1
     a30:	2485                	addiw	s1,s1,1
     a32:	0344d663          	bge	s1,s4,a5e <gets+0x52>
    cc = read(0, &c, 1);
     a36:	4605                	li	a2,1
     a38:	faf40593          	addi	a1,s0,-81
     a3c:	4501                	li	a0,0
     a3e:	1b2000ef          	jal	bf0 <read>
    if(cc < 1)
     a42:	00a05e63          	blez	a0,a5e <gets+0x52>
    buf[i++] = c;
     a46:	faf44783          	lbu	a5,-81(s0)
     a4a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     a4e:	01578763          	beq	a5,s5,a5c <gets+0x50>
     a52:	0905                	addi	s2,s2,1
     a54:	fd679de3          	bne	a5,s6,a2e <gets+0x22>
    buf[i++] = c;
     a58:	89a6                	mv	s3,s1
     a5a:	a011                	j	a5e <gets+0x52>
     a5c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     a5e:	99de                	add	s3,s3,s7
     a60:	00098023          	sb	zero,0(s3)
  return buf;
}
     a64:	855e                	mv	a0,s7
     a66:	60e6                	ld	ra,88(sp)
     a68:	6446                	ld	s0,80(sp)
     a6a:	64a6                	ld	s1,72(sp)
     a6c:	6906                	ld	s2,64(sp)
     a6e:	79e2                	ld	s3,56(sp)
     a70:	7a42                	ld	s4,48(sp)
     a72:	7aa2                	ld	s5,40(sp)
     a74:	7b02                	ld	s6,32(sp)
     a76:	6be2                	ld	s7,24(sp)
     a78:	6125                	addi	sp,sp,96
     a7a:	8082                	ret

0000000000000a7c <stat>:

int
stat(const char *n, struct stat *st)
{
     a7c:	1101                	addi	sp,sp,-32
     a7e:	ec06                	sd	ra,24(sp)
     a80:	e822                	sd	s0,16(sp)
     a82:	e04a                	sd	s2,0(sp)
     a84:	1000                	addi	s0,sp,32
     a86:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a88:	4581                	li	a1,0
     a8a:	18e000ef          	jal	c18 <open>
  if(fd < 0)
     a8e:	02054263          	bltz	a0,ab2 <stat+0x36>
     a92:	e426                	sd	s1,8(sp)
     a94:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a96:	85ca                	mv	a1,s2
     a98:	198000ef          	jal	c30 <fstat>
     a9c:	892a                	mv	s2,a0
  close(fd);
     a9e:	8526                	mv	a0,s1
     aa0:	160000ef          	jal	c00 <close>
  return r;
     aa4:	64a2                	ld	s1,8(sp)
}
     aa6:	854a                	mv	a0,s2
     aa8:	60e2                	ld	ra,24(sp)
     aaa:	6442                	ld	s0,16(sp)
     aac:	6902                	ld	s2,0(sp)
     aae:	6105                	addi	sp,sp,32
     ab0:	8082                	ret
    return -1;
     ab2:	597d                	li	s2,-1
     ab4:	bfcd                	j	aa6 <stat+0x2a>

0000000000000ab6 <atoi>:

int
atoi(const char *s)
{
     ab6:	1141                	addi	sp,sp,-16
     ab8:	e422                	sd	s0,8(sp)
     aba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     abc:	00054683          	lbu	a3,0(a0)
     ac0:	fd06879b          	addiw	a5,a3,-48
     ac4:	0ff7f793          	zext.b	a5,a5
     ac8:	4625                	li	a2,9
     aca:	02f66863          	bltu	a2,a5,afa <atoi+0x44>
     ace:	872a                	mv	a4,a0
  n = 0;
     ad0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     ad2:	0705                	addi	a4,a4,1
     ad4:	0025179b          	slliw	a5,a0,0x2
     ad8:	9fa9                	addw	a5,a5,a0
     ada:	0017979b          	slliw	a5,a5,0x1
     ade:	9fb5                	addw	a5,a5,a3
     ae0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     ae4:	00074683          	lbu	a3,0(a4)
     ae8:	fd06879b          	addiw	a5,a3,-48
     aec:	0ff7f793          	zext.b	a5,a5
     af0:	fef671e3          	bgeu	a2,a5,ad2 <atoi+0x1c>
  return n;
}
     af4:	6422                	ld	s0,8(sp)
     af6:	0141                	addi	sp,sp,16
     af8:	8082                	ret
  n = 0;
     afa:	4501                	li	a0,0
     afc:	bfe5                	j	af4 <atoi+0x3e>

0000000000000afe <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     afe:	1141                	addi	sp,sp,-16
     b00:	e422                	sd	s0,8(sp)
     b02:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     b04:	02b57463          	bgeu	a0,a1,b2c <memmove+0x2e>
    while(n-- > 0)
     b08:	00c05f63          	blez	a2,b26 <memmove+0x28>
     b0c:	1602                	slli	a2,a2,0x20
     b0e:	9201                	srli	a2,a2,0x20
     b10:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     b14:	872a                	mv	a4,a0
      *dst++ = *src++;
     b16:	0585                	addi	a1,a1,1
     b18:	0705                	addi	a4,a4,1
     b1a:	fff5c683          	lbu	a3,-1(a1)
     b1e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     b22:	fef71ae3          	bne	a4,a5,b16 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     b26:	6422                	ld	s0,8(sp)
     b28:	0141                	addi	sp,sp,16
     b2a:	8082                	ret
    dst += n;
     b2c:	00c50733          	add	a4,a0,a2
    src += n;
     b30:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     b32:	fec05ae3          	blez	a2,b26 <memmove+0x28>
     b36:	fff6079b          	addiw	a5,a2,-1
     b3a:	1782                	slli	a5,a5,0x20
     b3c:	9381                	srli	a5,a5,0x20
     b3e:	fff7c793          	not	a5,a5
     b42:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     b44:	15fd                	addi	a1,a1,-1
     b46:	177d                	addi	a4,a4,-1
     b48:	0005c683          	lbu	a3,0(a1)
     b4c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     b50:	fee79ae3          	bne	a5,a4,b44 <memmove+0x46>
     b54:	bfc9                	j	b26 <memmove+0x28>

0000000000000b56 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     b56:	1141                	addi	sp,sp,-16
     b58:	e422                	sd	s0,8(sp)
     b5a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     b5c:	ca05                	beqz	a2,b8c <memcmp+0x36>
     b5e:	fff6069b          	addiw	a3,a2,-1
     b62:	1682                	slli	a3,a3,0x20
     b64:	9281                	srli	a3,a3,0x20
     b66:	0685                	addi	a3,a3,1
     b68:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     b6a:	00054783          	lbu	a5,0(a0)
     b6e:	0005c703          	lbu	a4,0(a1)
     b72:	00e79863          	bne	a5,a4,b82 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     b76:	0505                	addi	a0,a0,1
    p2++;
     b78:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b7a:	fed518e3          	bne	a0,a3,b6a <memcmp+0x14>
  }
  return 0;
     b7e:	4501                	li	a0,0
     b80:	a019                	j	b86 <memcmp+0x30>
      return *p1 - *p2;
     b82:	40e7853b          	subw	a0,a5,a4
}
     b86:	6422                	ld	s0,8(sp)
     b88:	0141                	addi	sp,sp,16
     b8a:	8082                	ret
  return 0;
     b8c:	4501                	li	a0,0
     b8e:	bfe5                	j	b86 <memcmp+0x30>

0000000000000b90 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b90:	1141                	addi	sp,sp,-16
     b92:	e406                	sd	ra,8(sp)
     b94:	e022                	sd	s0,0(sp)
     b96:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b98:	f67ff0ef          	jal	afe <memmove>
}
     b9c:	60a2                	ld	ra,8(sp)
     b9e:	6402                	ld	s0,0(sp)
     ba0:	0141                	addi	sp,sp,16
     ba2:	8082                	ret

0000000000000ba4 <sbrk>:

char *
sbrk(int n) {
     ba4:	1141                	addi	sp,sp,-16
     ba6:	e406                	sd	ra,8(sp)
     ba8:	e022                	sd	s0,0(sp)
     baa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     bac:	4585                	li	a1,1
     bae:	0b2000ef          	jal	c60 <sys_sbrk>
}
     bb2:	60a2                	ld	ra,8(sp)
     bb4:	6402                	ld	s0,0(sp)
     bb6:	0141                	addi	sp,sp,16
     bb8:	8082                	ret

0000000000000bba <sbrklazy>:

char *
sbrklazy(int n) {
     bba:	1141                	addi	sp,sp,-16
     bbc:	e406                	sd	ra,8(sp)
     bbe:	e022                	sd	s0,0(sp)
     bc0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     bc2:	4589                	li	a1,2
     bc4:	09c000ef          	jal	c60 <sys_sbrk>
}
     bc8:	60a2                	ld	ra,8(sp)
     bca:	6402                	ld	s0,0(sp)
     bcc:	0141                	addi	sp,sp,16
     bce:	8082                	ret

0000000000000bd0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     bd0:	4885                	li	a7,1
 ecall
     bd2:	00000073          	ecall
 ret
     bd6:	8082                	ret

0000000000000bd8 <exit>:
.global exit
exit:
 li a7, SYS_exit
     bd8:	4889                	li	a7,2
 ecall
     bda:	00000073          	ecall
 ret
     bde:	8082                	ret

0000000000000be0 <wait>:
.global wait
wait:
 li a7, SYS_wait
     be0:	488d                	li	a7,3
 ecall
     be2:	00000073          	ecall
 ret
     be6:	8082                	ret

0000000000000be8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     be8:	4891                	li	a7,4
 ecall
     bea:	00000073          	ecall
 ret
     bee:	8082                	ret

0000000000000bf0 <read>:
.global read
read:
 li a7, SYS_read
     bf0:	4895                	li	a7,5
 ecall
     bf2:	00000073          	ecall
 ret
     bf6:	8082                	ret

0000000000000bf8 <write>:
.global write
write:
 li a7, SYS_write
     bf8:	48c1                	li	a7,16
 ecall
     bfa:	00000073          	ecall
 ret
     bfe:	8082                	ret

0000000000000c00 <close>:
.global close
close:
 li a7, SYS_close
     c00:	48d5                	li	a7,21
 ecall
     c02:	00000073          	ecall
 ret
     c06:	8082                	ret

0000000000000c08 <kill>:
.global kill
kill:
 li a7, SYS_kill
     c08:	4899                	li	a7,6
 ecall
     c0a:	00000073          	ecall
 ret
     c0e:	8082                	ret

0000000000000c10 <exec>:
.global exec
exec:
 li a7, SYS_exec
     c10:	489d                	li	a7,7
 ecall
     c12:	00000073          	ecall
 ret
     c16:	8082                	ret

0000000000000c18 <open>:
.global open
open:
 li a7, SYS_open
     c18:	48bd                	li	a7,15
 ecall
     c1a:	00000073          	ecall
 ret
     c1e:	8082                	ret

0000000000000c20 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     c20:	48c5                	li	a7,17
 ecall
     c22:	00000073          	ecall
 ret
     c26:	8082                	ret

0000000000000c28 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c28:	48c9                	li	a7,18
 ecall
     c2a:	00000073          	ecall
 ret
     c2e:	8082                	ret

0000000000000c30 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     c30:	48a1                	li	a7,8
 ecall
     c32:	00000073          	ecall
 ret
     c36:	8082                	ret

0000000000000c38 <link>:
.global link
link:
 li a7, SYS_link
     c38:	48cd                	li	a7,19
 ecall
     c3a:	00000073          	ecall
 ret
     c3e:	8082                	ret

0000000000000c40 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c40:	48d1                	li	a7,20
 ecall
     c42:	00000073          	ecall
 ret
     c46:	8082                	ret

0000000000000c48 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c48:	48a5                	li	a7,9
 ecall
     c4a:	00000073          	ecall
 ret
     c4e:	8082                	ret

0000000000000c50 <dup>:
.global dup
dup:
 li a7, SYS_dup
     c50:	48a9                	li	a7,10
 ecall
     c52:	00000073          	ecall
 ret
     c56:	8082                	ret

0000000000000c58 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     c58:	48ad                	li	a7,11
 ecall
     c5a:	00000073          	ecall
 ret
     c5e:	8082                	ret

0000000000000c60 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     c60:	48b1                	li	a7,12
 ecall
     c62:	00000073          	ecall
 ret
     c66:	8082                	ret

0000000000000c68 <pause>:
.global pause
pause:
 li a7, SYS_pause
     c68:	48b5                	li	a7,13
 ecall
     c6a:	00000073          	ecall
 ret
     c6e:	8082                	ret

0000000000000c70 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     c70:	48b9                	li	a7,14
 ecall
     c72:	00000073          	ecall
 ret
     c76:	8082                	ret

0000000000000c78 <csread>:
.global csread
csread:
 li a7, SYS_csread
     c78:	48d9                	li	a7,22
 ecall
     c7a:	00000073          	ecall
 ret
     c7e:	8082                	ret

0000000000000c80 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
     c80:	48dd                	li	a7,23
 ecall
     c82:	00000073          	ecall
 ret
     c86:	8082                	ret

0000000000000c88 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c88:	1101                	addi	sp,sp,-32
     c8a:	ec06                	sd	ra,24(sp)
     c8c:	e822                	sd	s0,16(sp)
     c8e:	1000                	addi	s0,sp,32
     c90:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c94:	4605                	li	a2,1
     c96:	fef40593          	addi	a1,s0,-17
     c9a:	f5fff0ef          	jal	bf8 <write>
}
     c9e:	60e2                	ld	ra,24(sp)
     ca0:	6442                	ld	s0,16(sp)
     ca2:	6105                	addi	sp,sp,32
     ca4:	8082                	ret

0000000000000ca6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     ca6:	715d                	addi	sp,sp,-80
     ca8:	e486                	sd	ra,72(sp)
     caa:	e0a2                	sd	s0,64(sp)
     cac:	f84a                	sd	s2,48(sp)
     cae:	0880                	addi	s0,sp,80
     cb0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     cb2:	c299                	beqz	a3,cb8 <printint+0x12>
     cb4:	0805c363          	bltz	a1,d3a <printint+0x94>
  neg = 0;
     cb8:	4881                	li	a7,0
     cba:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     cbe:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     cc0:	00000517          	auipc	a0,0x0
     cc4:	7a850513          	addi	a0,a0,1960 # 1468 <digits>
     cc8:	883e                	mv	a6,a5
     cca:	2785                	addiw	a5,a5,1
     ccc:	02c5f733          	remu	a4,a1,a2
     cd0:	972a                	add	a4,a4,a0
     cd2:	00074703          	lbu	a4,0(a4)
     cd6:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     cda:	872e                	mv	a4,a1
     cdc:	02c5d5b3          	divu	a1,a1,a2
     ce0:	0685                	addi	a3,a3,1
     ce2:	fec773e3          	bgeu	a4,a2,cc8 <printint+0x22>
  if(neg)
     ce6:	00088b63          	beqz	a7,cfc <printint+0x56>
    buf[i++] = '-';
     cea:	fd078793          	addi	a5,a5,-48
     cee:	97a2                	add	a5,a5,s0
     cf0:	02d00713          	li	a4,45
     cf4:	fee78423          	sb	a4,-24(a5)
     cf8:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     cfc:	02f05a63          	blez	a5,d30 <printint+0x8a>
     d00:	fc26                	sd	s1,56(sp)
     d02:	f44e                	sd	s3,40(sp)
     d04:	fb840713          	addi	a4,s0,-72
     d08:	00f704b3          	add	s1,a4,a5
     d0c:	fff70993          	addi	s3,a4,-1
     d10:	99be                	add	s3,s3,a5
     d12:	37fd                	addiw	a5,a5,-1
     d14:	1782                	slli	a5,a5,0x20
     d16:	9381                	srli	a5,a5,0x20
     d18:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     d1c:	fff4c583          	lbu	a1,-1(s1)
     d20:	854a                	mv	a0,s2
     d22:	f67ff0ef          	jal	c88 <putc>
  while(--i >= 0)
     d26:	14fd                	addi	s1,s1,-1
     d28:	ff349ae3          	bne	s1,s3,d1c <printint+0x76>
     d2c:	74e2                	ld	s1,56(sp)
     d2e:	79a2                	ld	s3,40(sp)
}
     d30:	60a6                	ld	ra,72(sp)
     d32:	6406                	ld	s0,64(sp)
     d34:	7942                	ld	s2,48(sp)
     d36:	6161                	addi	sp,sp,80
     d38:	8082                	ret
    x = -xx;
     d3a:	40b005b3          	neg	a1,a1
    neg = 1;
     d3e:	4885                	li	a7,1
    x = -xx;
     d40:	bfad                	j	cba <printint+0x14>

0000000000000d42 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     d42:	711d                	addi	sp,sp,-96
     d44:	ec86                	sd	ra,88(sp)
     d46:	e8a2                	sd	s0,80(sp)
     d48:	e0ca                	sd	s2,64(sp)
     d4a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     d4c:	0005c903          	lbu	s2,0(a1)
     d50:	28090663          	beqz	s2,fdc <vprintf+0x29a>
     d54:	e4a6                	sd	s1,72(sp)
     d56:	fc4e                	sd	s3,56(sp)
     d58:	f852                	sd	s4,48(sp)
     d5a:	f456                	sd	s5,40(sp)
     d5c:	f05a                	sd	s6,32(sp)
     d5e:	ec5e                	sd	s7,24(sp)
     d60:	e862                	sd	s8,16(sp)
     d62:	e466                	sd	s9,8(sp)
     d64:	8b2a                	mv	s6,a0
     d66:	8a2e                	mv	s4,a1
     d68:	8bb2                	mv	s7,a2
  state = 0;
     d6a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     d6c:	4481                	li	s1,0
     d6e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d70:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d74:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d78:	06c00c93          	li	s9,108
     d7c:	a005                	j	d9c <vprintf+0x5a>
        putc(fd, c0);
     d7e:	85ca                	mv	a1,s2
     d80:	855a                	mv	a0,s6
     d82:	f07ff0ef          	jal	c88 <putc>
     d86:	a019                	j	d8c <vprintf+0x4a>
    } else if(state == '%'){
     d88:	03598263          	beq	s3,s5,dac <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     d8c:	2485                	addiw	s1,s1,1
     d8e:	8726                	mv	a4,s1
     d90:	009a07b3          	add	a5,s4,s1
     d94:	0007c903          	lbu	s2,0(a5)
     d98:	22090a63          	beqz	s2,fcc <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
     d9c:	0009079b          	sext.w	a5,s2
    if(state == 0){
     da0:	fe0994e3          	bnez	s3,d88 <vprintf+0x46>
      if(c0 == '%'){
     da4:	fd579de3          	bne	a5,s5,d7e <vprintf+0x3c>
        state = '%';
     da8:	89be                	mv	s3,a5
     daa:	b7cd                	j	d8c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     dac:	00ea06b3          	add	a3,s4,a4
     db0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     db4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     db6:	c681                	beqz	a3,dbe <vprintf+0x7c>
     db8:	9752                	add	a4,a4,s4
     dba:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     dbe:	05878363          	beq	a5,s8,e04 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
     dc2:	05978d63          	beq	a5,s9,e1c <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     dc6:	07500713          	li	a4,117
     dca:	0ee78763          	beq	a5,a4,eb8 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     dce:	07800713          	li	a4,120
     dd2:	12e78963          	beq	a5,a4,f04 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     dd6:	07000713          	li	a4,112
     dda:	14e78e63          	beq	a5,a4,f36 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     dde:	06300713          	li	a4,99
     de2:	18e78e63          	beq	a5,a4,f7e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     de6:	07300713          	li	a4,115
     dea:	1ae78463          	beq	a5,a4,f92 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     dee:	02500713          	li	a4,37
     df2:	04e79563          	bne	a5,a4,e3c <vprintf+0xfa>
        putc(fd, '%');
     df6:	02500593          	li	a1,37
     dfa:	855a                	mv	a0,s6
     dfc:	e8dff0ef          	jal	c88 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     e00:	4981                	li	s3,0
     e02:	b769                	j	d8c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     e04:	008b8913          	addi	s2,s7,8
     e08:	4685                	li	a3,1
     e0a:	4629                	li	a2,10
     e0c:	000ba583          	lw	a1,0(s7)
     e10:	855a                	mv	a0,s6
     e12:	e95ff0ef          	jal	ca6 <printint>
     e16:	8bca                	mv	s7,s2
      state = 0;
     e18:	4981                	li	s3,0
     e1a:	bf8d                	j	d8c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     e1c:	06400793          	li	a5,100
     e20:	02f68963          	beq	a3,a5,e52 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e24:	06c00793          	li	a5,108
     e28:	04f68263          	beq	a3,a5,e6c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
     e2c:	07500793          	li	a5,117
     e30:	0af68063          	beq	a3,a5,ed0 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
     e34:	07800793          	li	a5,120
     e38:	0ef68263          	beq	a3,a5,f1c <vprintf+0x1da>
        putc(fd, '%');
     e3c:	02500593          	li	a1,37
     e40:	855a                	mv	a0,s6
     e42:	e47ff0ef          	jal	c88 <putc>
        putc(fd, c0);
     e46:	85ca                	mv	a1,s2
     e48:	855a                	mv	a0,s6
     e4a:	e3fff0ef          	jal	c88 <putc>
      state = 0;
     e4e:	4981                	li	s3,0
     e50:	bf35                	j	d8c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e52:	008b8913          	addi	s2,s7,8
     e56:	4685                	li	a3,1
     e58:	4629                	li	a2,10
     e5a:	000bb583          	ld	a1,0(s7)
     e5e:	855a                	mv	a0,s6
     e60:	e47ff0ef          	jal	ca6 <printint>
        i += 1;
     e64:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     e66:	8bca                	mv	s7,s2
      state = 0;
     e68:	4981                	li	s3,0
        i += 1;
     e6a:	b70d                	j	d8c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e6c:	06400793          	li	a5,100
     e70:	02f60763          	beq	a2,a5,e9e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e74:	07500793          	li	a5,117
     e78:	06f60963          	beq	a2,a5,eea <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e7c:	07800793          	li	a5,120
     e80:	faf61ee3          	bne	a2,a5,e3c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e84:	008b8913          	addi	s2,s7,8
     e88:	4681                	li	a3,0
     e8a:	4641                	li	a2,16
     e8c:	000bb583          	ld	a1,0(s7)
     e90:	855a                	mv	a0,s6
     e92:	e15ff0ef          	jal	ca6 <printint>
        i += 2;
     e96:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e98:	8bca                	mv	s7,s2
      state = 0;
     e9a:	4981                	li	s3,0
        i += 2;
     e9c:	bdc5                	j	d8c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e9e:	008b8913          	addi	s2,s7,8
     ea2:	4685                	li	a3,1
     ea4:	4629                	li	a2,10
     ea6:	000bb583          	ld	a1,0(s7)
     eaa:	855a                	mv	a0,s6
     eac:	dfbff0ef          	jal	ca6 <printint>
        i += 2;
     eb0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     eb2:	8bca                	mv	s7,s2
      state = 0;
     eb4:	4981                	li	s3,0
        i += 2;
     eb6:	bdd9                	j	d8c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     eb8:	008b8913          	addi	s2,s7,8
     ebc:	4681                	li	a3,0
     ebe:	4629                	li	a2,10
     ec0:	000be583          	lwu	a1,0(s7)
     ec4:	855a                	mv	a0,s6
     ec6:	de1ff0ef          	jal	ca6 <printint>
     eca:	8bca                	mv	s7,s2
      state = 0;
     ecc:	4981                	li	s3,0
     ece:	bd7d                	j	d8c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     ed0:	008b8913          	addi	s2,s7,8
     ed4:	4681                	li	a3,0
     ed6:	4629                	li	a2,10
     ed8:	000bb583          	ld	a1,0(s7)
     edc:	855a                	mv	a0,s6
     ede:	dc9ff0ef          	jal	ca6 <printint>
        i += 1;
     ee2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     ee4:	8bca                	mv	s7,s2
      state = 0;
     ee6:	4981                	li	s3,0
        i += 1;
     ee8:	b555                	j	d8c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     eea:	008b8913          	addi	s2,s7,8
     eee:	4681                	li	a3,0
     ef0:	4629                	li	a2,10
     ef2:	000bb583          	ld	a1,0(s7)
     ef6:	855a                	mv	a0,s6
     ef8:	dafff0ef          	jal	ca6 <printint>
        i += 2;
     efc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     efe:	8bca                	mv	s7,s2
      state = 0;
     f00:	4981                	li	s3,0
        i += 2;
     f02:	b569                	j	d8c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     f04:	008b8913          	addi	s2,s7,8
     f08:	4681                	li	a3,0
     f0a:	4641                	li	a2,16
     f0c:	000be583          	lwu	a1,0(s7)
     f10:	855a                	mv	a0,s6
     f12:	d95ff0ef          	jal	ca6 <printint>
     f16:	8bca                	mv	s7,s2
      state = 0;
     f18:	4981                	li	s3,0
     f1a:	bd8d                	j	d8c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     f1c:	008b8913          	addi	s2,s7,8
     f20:	4681                	li	a3,0
     f22:	4641                	li	a2,16
     f24:	000bb583          	ld	a1,0(s7)
     f28:	855a                	mv	a0,s6
     f2a:	d7dff0ef          	jal	ca6 <printint>
        i += 1;
     f2e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     f30:	8bca                	mv	s7,s2
      state = 0;
     f32:	4981                	li	s3,0
        i += 1;
     f34:	bda1                	j	d8c <vprintf+0x4a>
     f36:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
     f38:	008b8d13          	addi	s10,s7,8
     f3c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     f40:	03000593          	li	a1,48
     f44:	855a                	mv	a0,s6
     f46:	d43ff0ef          	jal	c88 <putc>
  putc(fd, 'x');
     f4a:	07800593          	li	a1,120
     f4e:	855a                	mv	a0,s6
     f50:	d39ff0ef          	jal	c88 <putc>
     f54:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f56:	00000b97          	auipc	s7,0x0
     f5a:	512b8b93          	addi	s7,s7,1298 # 1468 <digits>
     f5e:	03c9d793          	srli	a5,s3,0x3c
     f62:	97de                	add	a5,a5,s7
     f64:	0007c583          	lbu	a1,0(a5)
     f68:	855a                	mv	a0,s6
     f6a:	d1fff0ef          	jal	c88 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f6e:	0992                	slli	s3,s3,0x4
     f70:	397d                	addiw	s2,s2,-1
     f72:	fe0916e3          	bnez	s2,f5e <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
     f76:	8bea                	mv	s7,s10
      state = 0;
     f78:	4981                	li	s3,0
     f7a:	6d02                	ld	s10,0(sp)
     f7c:	bd01                	j	d8c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
     f7e:	008b8913          	addi	s2,s7,8
     f82:	000bc583          	lbu	a1,0(s7)
     f86:	855a                	mv	a0,s6
     f88:	d01ff0ef          	jal	c88 <putc>
     f8c:	8bca                	mv	s7,s2
      state = 0;
     f8e:	4981                	li	s3,0
     f90:	bbf5                	j	d8c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
     f92:	008b8993          	addi	s3,s7,8
     f96:	000bb903          	ld	s2,0(s7)
     f9a:	00090f63          	beqz	s2,fb8 <vprintf+0x276>
        for(; *s; s++)
     f9e:	00094583          	lbu	a1,0(s2)
     fa2:	c195                	beqz	a1,fc6 <vprintf+0x284>
          putc(fd, *s);
     fa4:	855a                	mv	a0,s6
     fa6:	ce3ff0ef          	jal	c88 <putc>
        for(; *s; s++)
     faa:	0905                	addi	s2,s2,1
     fac:	00094583          	lbu	a1,0(s2)
     fb0:	f9f5                	bnez	a1,fa4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
     fb2:	8bce                	mv	s7,s3
      state = 0;
     fb4:	4981                	li	s3,0
     fb6:	bbd9                	j	d8c <vprintf+0x4a>
          s = "(null)";
     fb8:	00000917          	auipc	s2,0x0
     fbc:	47890913          	addi	s2,s2,1144 # 1430 <malloc+0x36c>
        for(; *s; s++)
     fc0:	02800593          	li	a1,40
     fc4:	b7c5                	j	fa4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
     fc6:	8bce                	mv	s7,s3
      state = 0;
     fc8:	4981                	li	s3,0
     fca:	b3c9                	j	d8c <vprintf+0x4a>
     fcc:	64a6                	ld	s1,72(sp)
     fce:	79e2                	ld	s3,56(sp)
     fd0:	7a42                	ld	s4,48(sp)
     fd2:	7aa2                	ld	s5,40(sp)
     fd4:	7b02                	ld	s6,32(sp)
     fd6:	6be2                	ld	s7,24(sp)
     fd8:	6c42                	ld	s8,16(sp)
     fda:	6ca2                	ld	s9,8(sp)
    }
  }
}
     fdc:	60e6                	ld	ra,88(sp)
     fde:	6446                	ld	s0,80(sp)
     fe0:	6906                	ld	s2,64(sp)
     fe2:	6125                	addi	sp,sp,96
     fe4:	8082                	ret

0000000000000fe6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     fe6:	715d                	addi	sp,sp,-80
     fe8:	ec06                	sd	ra,24(sp)
     fea:	e822                	sd	s0,16(sp)
     fec:	1000                	addi	s0,sp,32
     fee:	e010                	sd	a2,0(s0)
     ff0:	e414                	sd	a3,8(s0)
     ff2:	e818                	sd	a4,16(s0)
     ff4:	ec1c                	sd	a5,24(s0)
     ff6:	03043023          	sd	a6,32(s0)
     ffa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     ffe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1002:	8622                	mv	a2,s0
    1004:	d3fff0ef          	jal	d42 <vprintf>
}
    1008:	60e2                	ld	ra,24(sp)
    100a:	6442                	ld	s0,16(sp)
    100c:	6161                	addi	sp,sp,80
    100e:	8082                	ret

0000000000001010 <printf>:

void
printf(const char *fmt, ...)
{
    1010:	711d                	addi	sp,sp,-96
    1012:	ec06                	sd	ra,24(sp)
    1014:	e822                	sd	s0,16(sp)
    1016:	1000                	addi	s0,sp,32
    1018:	e40c                	sd	a1,8(s0)
    101a:	e810                	sd	a2,16(s0)
    101c:	ec14                	sd	a3,24(s0)
    101e:	f018                	sd	a4,32(s0)
    1020:	f41c                	sd	a5,40(s0)
    1022:	03043823          	sd	a6,48(s0)
    1026:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    102a:	00840613          	addi	a2,s0,8
    102e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1032:	85aa                	mv	a1,a0
    1034:	4505                	li	a0,1
    1036:	d0dff0ef          	jal	d42 <vprintf>
}
    103a:	60e2                	ld	ra,24(sp)
    103c:	6442                	ld	s0,16(sp)
    103e:	6125                	addi	sp,sp,96
    1040:	8082                	ret

0000000000001042 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1042:	1141                	addi	sp,sp,-16
    1044:	e422                	sd	s0,8(sp)
    1046:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1048:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    104c:	00001797          	auipc	a5,0x1
    1050:	fb47b783          	ld	a5,-76(a5) # 2000 <freep>
    1054:	a02d                	j	107e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1056:	4618                	lw	a4,8(a2)
    1058:	9f2d                	addw	a4,a4,a1
    105a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    105e:	6398                	ld	a4,0(a5)
    1060:	6310                	ld	a2,0(a4)
    1062:	a83d                	j	10a0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1064:	ff852703          	lw	a4,-8(a0)
    1068:	9f31                	addw	a4,a4,a2
    106a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    106c:	ff053683          	ld	a3,-16(a0)
    1070:	a091                	j	10b4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1072:	6398                	ld	a4,0(a5)
    1074:	00e7e463          	bltu	a5,a4,107c <free+0x3a>
    1078:	00e6ea63          	bltu	a3,a4,108c <free+0x4a>
{
    107c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    107e:	fed7fae3          	bgeu	a5,a3,1072 <free+0x30>
    1082:	6398                	ld	a4,0(a5)
    1084:	00e6e463          	bltu	a3,a4,108c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1088:	fee7eae3          	bltu	a5,a4,107c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    108c:	ff852583          	lw	a1,-8(a0)
    1090:	6390                	ld	a2,0(a5)
    1092:	02059813          	slli	a6,a1,0x20
    1096:	01c85713          	srli	a4,a6,0x1c
    109a:	9736                	add	a4,a4,a3
    109c:	fae60de3          	beq	a2,a4,1056 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    10a0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    10a4:	4790                	lw	a2,8(a5)
    10a6:	02061593          	slli	a1,a2,0x20
    10aa:	01c5d713          	srli	a4,a1,0x1c
    10ae:	973e                	add	a4,a4,a5
    10b0:	fae68ae3          	beq	a3,a4,1064 <free+0x22>
    p->s.ptr = bp->s.ptr;
    10b4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    10b6:	00001717          	auipc	a4,0x1
    10ba:	f4f73523          	sd	a5,-182(a4) # 2000 <freep>
}
    10be:	6422                	ld	s0,8(sp)
    10c0:	0141                	addi	sp,sp,16
    10c2:	8082                	ret

00000000000010c4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    10c4:	7139                	addi	sp,sp,-64
    10c6:	fc06                	sd	ra,56(sp)
    10c8:	f822                	sd	s0,48(sp)
    10ca:	f426                	sd	s1,40(sp)
    10cc:	ec4e                	sd	s3,24(sp)
    10ce:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    10d0:	02051493          	slli	s1,a0,0x20
    10d4:	9081                	srli	s1,s1,0x20
    10d6:	04bd                	addi	s1,s1,15
    10d8:	8091                	srli	s1,s1,0x4
    10da:	0014899b          	addiw	s3,s1,1
    10de:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    10e0:	00001517          	auipc	a0,0x1
    10e4:	f2053503          	ld	a0,-224(a0) # 2000 <freep>
    10e8:	c915                	beqz	a0,111c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10ec:	4798                	lw	a4,8(a5)
    10ee:	08977a63          	bgeu	a4,s1,1182 <malloc+0xbe>
    10f2:	f04a                	sd	s2,32(sp)
    10f4:	e852                	sd	s4,16(sp)
    10f6:	e456                	sd	s5,8(sp)
    10f8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    10fa:	8a4e                	mv	s4,s3
    10fc:	0009871b          	sext.w	a4,s3
    1100:	6685                	lui	a3,0x1
    1102:	00d77363          	bgeu	a4,a3,1108 <malloc+0x44>
    1106:	6a05                	lui	s4,0x1
    1108:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    110c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1110:	00001917          	auipc	s2,0x1
    1114:	ef090913          	addi	s2,s2,-272 # 2000 <freep>
  if(p == SBRK_ERROR)
    1118:	5afd                	li	s5,-1
    111a:	a081                	j	115a <malloc+0x96>
    111c:	f04a                	sd	s2,32(sp)
    111e:	e852                	sd	s4,16(sp)
    1120:	e456                	sd	s5,8(sp)
    1122:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    1124:	00001797          	auipc	a5,0x1
    1128:	62c78793          	addi	a5,a5,1580 # 2750 <base>
    112c:	00001717          	auipc	a4,0x1
    1130:	ecf73a23          	sd	a5,-300(a4) # 2000 <freep>
    1134:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1136:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    113a:	b7c1                	j	10fa <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    113c:	6398                	ld	a4,0(a5)
    113e:	e118                	sd	a4,0(a0)
    1140:	a8a9                	j	119a <malloc+0xd6>
  hp->s.size = nu;
    1142:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1146:	0541                	addi	a0,a0,16
    1148:	efbff0ef          	jal	1042 <free>
  return freep;
    114c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1150:	c12d                	beqz	a0,11b2 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1152:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1154:	4798                	lw	a4,8(a5)
    1156:	02977263          	bgeu	a4,s1,117a <malloc+0xb6>
    if(p == freep)
    115a:	00093703          	ld	a4,0(s2)
    115e:	853e                	mv	a0,a5
    1160:	fef719e3          	bne	a4,a5,1152 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    1164:	8552                	mv	a0,s4
    1166:	a3fff0ef          	jal	ba4 <sbrk>
  if(p == SBRK_ERROR)
    116a:	fd551ce3          	bne	a0,s5,1142 <malloc+0x7e>
        return 0;
    116e:	4501                	li	a0,0
    1170:	7902                	ld	s2,32(sp)
    1172:	6a42                	ld	s4,16(sp)
    1174:	6aa2                	ld	s5,8(sp)
    1176:	6b02                	ld	s6,0(sp)
    1178:	a03d                	j	11a6 <malloc+0xe2>
    117a:	7902                	ld	s2,32(sp)
    117c:	6a42                	ld	s4,16(sp)
    117e:	6aa2                	ld	s5,8(sp)
    1180:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1182:	fae48de3          	beq	s1,a4,113c <malloc+0x78>
        p->s.size -= nunits;
    1186:	4137073b          	subw	a4,a4,s3
    118a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    118c:	02071693          	slli	a3,a4,0x20
    1190:	01c6d713          	srli	a4,a3,0x1c
    1194:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1196:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    119a:	00001717          	auipc	a4,0x1
    119e:	e6a73323          	sd	a0,-410(a4) # 2000 <freep>
      return (void*)(p + 1);
    11a2:	01078513          	addi	a0,a5,16
  }
}
    11a6:	70e2                	ld	ra,56(sp)
    11a8:	7442                	ld	s0,48(sp)
    11aa:	74a2                	ld	s1,40(sp)
    11ac:	69e2                	ld	s3,24(sp)
    11ae:	6121                	addi	sp,sp,64
    11b0:	8082                	ret
    11b2:	7902                	ld	s2,32(sp)
    11b4:	6a42                	ld	s4,16(sp)
    11b6:	6aa2                	ld	s5,8(sp)
    11b8:	6b02                	ld	s6,0(sp)
    11ba:	b7f5                	j	11a6 <malloc+0xe2>
