
user/_fsexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <append_str>:

static void append_char(char *buf, int *pos, char c) {
    if (*pos < OUTBUF_SZ - 1) buf[(*pos)++] = c;
}

static void append_str(char *buf, int *pos, const char *s) {
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
    while (*s && *pos < OUTBUF_SZ - 1) buf[(*pos)++] = *s++;
       6:	00064783          	lbu	a5,0(a2)
       a:	3fe00693          	li	a3,1022
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
    if (x < 0) { append_char(buf, pos, '-'); x = -x; }
      c0:	00064863          	bltz	a2,d0 <append_int+0x18>
    append_uint(buf, pos, (uint)x);
      c4:	f71ff0ef          	jal	34 <append_uint>
}
      c8:	60a2                	ld	ra,8(sp)
      ca:	6402                	ld	s0,0(sp)
      cc:	0141                	addi	sp,sp,16
      ce:	8082                	ret
    if (*pos < OUTBUF_SZ - 1) buf[(*pos)++] = c;
      d0:	419c                	lw	a5,0(a1)
      d2:	3fe00713          	li	a4,1022
      d6:	00f74a63          	blt	a4,a5,ea <append_int+0x32>
      da:	0017871b          	addiw	a4,a5,1
      de:	c198                	sw	a4,0(a1)
      e0:	97aa                	add	a5,a5,a0
      e2:	02d00713          	li	a4,45
      e6:	00e78023          	sb	a4,0(a5)
    if (x < 0) { append_char(buf, pos, '-'); x = -x; }
      ea:	40c0063b          	negw	a2,a2
      ee:	bfd9                	j	c4 <append_int+0xc>

00000000000000f0 <print_change>:

static void print_change(char *buf, int *pos, const char *name, int oldv, int newv) {
    if(oldv != newv){
      f0:	00e69363          	bne	a3,a4,f6 <print_change+0x6>
      f4:	8082                	ret
static void print_change(char *buf, int *pos, const char *name, int oldv, int newv) {
      f6:	7139                	addi	sp,sp,-64
      f8:	fc06                	sd	ra,56(sp)
      fa:	f822                	sd	s0,48(sp)
      fc:	f426                	sd	s1,40(sp)
      fe:	f04a                	sd	s2,32(sp)
     100:	ec4e                	sd	s3,24(sp)
     102:	e852                	sd	s4,16(sp)
     104:	e456                	sd	s5,8(sp)
     106:	0080                	addi	s0,sp,64
     108:	84aa                	mv	s1,a0
     10a:	892e                	mv	s2,a1
     10c:	8ab2                	mv	s5,a2
     10e:	8a36                	mv	s4,a3
     110:	89ba                	mv	s3,a4
        append_str(buf, pos, "\"");
     112:	00001617          	auipc	a2,0x1
     116:	61e60613          	addi	a2,a2,1566 # 1730 <malloc+0x106>
     11a:	ee7ff0ef          	jal	0 <append_str>
        append_str(buf, pos, name);
     11e:	8656                	mv	a2,s5
     120:	85ca                	mv	a1,s2
     122:	8526                	mv	a0,s1
     124:	eddff0ef          	jal	0 <append_str>
        append_str(buf, pos, "\":\"");
     128:	00001617          	auipc	a2,0x1
     12c:	61060613          	addi	a2,a2,1552 # 1738 <malloc+0x10e>
     130:	85ca                	mv	a1,s2
     132:	8526                	mv	a0,s1
     134:	ecdff0ef          	jal	0 <append_str>
        append_int(buf, pos, oldv);
     138:	8652                	mv	a2,s4
     13a:	85ca                	mv	a1,s2
     13c:	8526                	mv	a0,s1
     13e:	f7bff0ef          	jal	b8 <append_int>
        append_str(buf, pos, "->");
     142:	00001617          	auipc	a2,0x1
     146:	5fe60613          	addi	a2,a2,1534 # 1740 <malloc+0x116>
     14a:	85ca                	mv	a1,s2
     14c:	8526                	mv	a0,s1
     14e:	eb3ff0ef          	jal	0 <append_str>
        append_int(buf, pos, newv);
     152:	864e                	mv	a2,s3
     154:	85ca                	mv	a1,s2
     156:	8526                	mv	a0,s1
     158:	f61ff0ef          	jal	b8 <append_int>
        append_str(buf, pos, "\",");
     15c:	00001617          	auipc	a2,0x1
     160:	5ec60613          	addi	a2,a2,1516 # 1748 <malloc+0x11e>
     164:	85ca                	mv	a1,s2
     166:	8526                	mv	a0,s1
     168:	e99ff0ef          	jal	0 <append_str>
    }
}
     16c:	70e2                	ld	ra,56(sp)
     16e:	7442                	ld	s0,48(sp)
     170:	74a2                	ld	s1,40(sp)
     172:	7902                	ld	s2,32(sp)
     174:	69e2                	ld	s3,24(sp)
     176:	6a42                	ld	s4,16(sp)
     178:	6aa2                	ld	s5,8(sp)
     17a:	6121                	addi	sp,sp,64
     17c:	8082                	ret

000000000000017e <print_fs_event>:
static void print_fs_event(const struct fs_event *e) {
     17e:	bb010113          	addi	sp,sp,-1104
     182:	44113423          	sd	ra,1096(sp)
     186:	44813023          	sd	s0,1088(sp)
     18a:	42913c23          	sd	s1,1080(sp)
     18e:	43213823          	sd	s2,1072(sp)
     192:	45010413          	addi	s0,sp,1104
     196:	84aa                	mv	s1,a0
    char buf[OUTBUF_SZ];
    int pos = 0;
     198:	ba042e23          	sw	zero,-1092(s0)

    append_str(buf, &pos, "{");
     19c:	00001617          	auipc	a2,0x1
     1a0:	5b460613          	addi	a2,a2,1460 # 1750 <malloc+0x126>
     1a4:	bbc40593          	addi	a1,s0,-1092
     1a8:	bc040513          	addi	a0,s0,-1088
     1ac:	e55ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"seq\":");
     1b0:	00001617          	auipc	a2,0x1
     1b4:	5a860613          	addi	a2,a2,1448 # 1758 <malloc+0x12e>
     1b8:	bbc40593          	addi	a1,s0,-1092
     1bc:	bc040513          	addi	a0,s0,-1088
     1c0:	e41ff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->seq);
     1c4:	4090                	lw	a2,0(s1)
     1c6:	bbc40593          	addi	a1,s0,-1092
     1ca:	bc040513          	addi	a0,s0,-1088
     1ce:	e67ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",");
     1d2:	00001617          	auipc	a2,0x1
     1d6:	58e60613          	addi	a2,a2,1422 # 1760 <malloc+0x136>
     1da:	bbc40593          	addi	a1,s0,-1092
     1de:	bc040513          	addi	a0,s0,-1088
     1e2:	e1fff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "\"tick\":"); append_uint(buf, &pos, e->ticks);
     1e6:	00001617          	auipc	a2,0x1
     1ea:	58260613          	addi	a2,a2,1410 # 1768 <malloc+0x13e>
     1ee:	bbc40593          	addi	a1,s0,-1092
     1f2:	bc040513          	addi	a0,s0,-1088
     1f6:	e0bff0ef          	jal	0 <append_str>
     1fa:	4490                	lw	a2,8(s1)
     1fc:	bbc40593          	addi	a1,s0,-1092
     200:	bc040513          	addi	a0,s0,-1088
     204:	e31ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"pid\":"); append_int(buf, &pos, e->pid);
     208:	00001617          	auipc	a2,0x1
     20c:	56860613          	addi	a2,a2,1384 # 1770 <malloc+0x146>
     210:	bbc40593          	addi	a1,s0,-1092
     214:	bc040513          	addi	a0,s0,-1088
     218:	de9ff0ef          	jal	0 <append_str>
     21c:	44d0                	lw	a2,12(s1)
     21e:	bbc40593          	addi	a1,s0,-1092
     222:	bc040513          	addi	a0,s0,-1088
     226:	e93ff0ef          	jal	b8 <append_int>

    append_str(buf, &pos, ",\"layer\":\"");
     22a:	00001617          	auipc	a2,0x1
     22e:	54e60613          	addi	a2,a2,1358 # 1778 <malloc+0x14e>
     232:	bbc40593          	addi	a1,s0,-1092
     236:	bc040513          	addi	a0,s0,-1088
     23a:	dc7ff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE)
     23e:	0104a903          	lw	s2,16(s1)
     242:	479d                	li	a5,7
     244:	3327e3e3          	bltu	a5,s2,d6a <print_fs_event+0xbec>
     248:	00291793          	slli	a5,s2,0x2
     24c:	00001717          	auipc	a4,0x1
     250:	7c470713          	addi	a4,a4,1988 # 1a10 <malloc+0x3e6>
     254:	97ba                	add	a5,a5,a4
     256:	439c                	lw	a5,0(a5)
     258:	97ba                	add	a5,a5,a4
     25a:	8782                	jr	a5
     25c:	43313423          	sd	s3,1064(sp)
    append_str(buf, &pos, "BCACHE");
     260:	00001617          	auipc	a2,0x1
     264:	52860613          	addi	a2,a2,1320 # 1788 <malloc+0x15e>
     268:	bbc40593          	addi	a1,s0,-1092
     26c:	bc040513          	addi	a0,s0,-1088
     270:	d91ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "DIR");
    else if(e->type == LAYER_PATH)
    append_str(buf, &pos, "PATH");
    else if(e->type == LAYER_FILE)
    append_str(buf, &pos, "FILE");
    append_str(buf, &pos, "\"");
     274:	00001617          	auipc	a2,0x1
     278:	4bc60613          	addi	a2,a2,1212 # 1730 <malloc+0x106>
     27c:	bbc40593          	addi	a1,s0,-1092
     280:	bc040513          	addi	a0,s0,-1088
     284:	d7dff0ef          	jal	0 <append_str>

    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     288:	00001617          	auipc	a2,0x1
     28c:	50860613          	addi	a2,a2,1288 # 1790 <malloc+0x166>
     290:	bbc40593          	addi	a1,s0,-1092
     294:	bc040513          	addi	a0,s0,-1088
     298:	d69ff0ef          	jal	0 <append_str>
     29c:	01448613          	addi	a2,s1,20
     2a0:	bbc40593          	addi	a1,s0,-1092
     2a4:	bc040513          	addi	a0,s0,-1088
     2a8:	d59ff0ef          	jal	0 <append_str>
     2ac:	00001617          	auipc	a2,0x1
     2b0:	48460613          	addi	a2,a2,1156 # 1730 <malloc+0x106>
     2b4:	bbc40593          	addi	a1,s0,-1092
     2b8:	bc040513          	addi	a0,s0,-1088
     2bc:	d45ff0ef          	jal	0 <append_str>

    // ===== BCACHE =====
    if(e->type == LAYER_BCACHE){

        append_str(buf, &pos, ",\"buf\":{");
     2c0:	00001617          	auipc	a2,0x1
     2c4:	50860613          	addi	a2,a2,1288 # 17c8 <malloc+0x19e>
     2c8:	bbc40593          	addi	a1,s0,-1092
     2cc:	bc040513          	addi	a0,s0,-1088
     2d0:	d31ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"id\":"); append_int(buf, &pos, e->bcache.buf_id);
     2d4:	00001617          	auipc	a2,0x1
     2d8:	50460613          	addi	a2,a2,1284 # 17d8 <malloc+0x1ae>
     2dc:	bbc40593          	addi	a1,s0,-1092
     2e0:	bc040513          	addi	a0,s0,-1088
     2e4:	d1dff0ef          	jal	0 <append_str>
     2e8:	1604a603          	lw	a2,352(s1)
     2ec:	bbc40593          	addi	a1,s0,-1092
     2f0:	bc040513          	addi	a0,s0,-1088
     2f4:	dc5ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"block\":"); append_int(buf, &pos, e->bcache.blockno);
     2f8:	00001617          	auipc	a2,0x1
     2fc:	4e860613          	addi	a2,a2,1256 # 17e0 <malloc+0x1b6>
     300:	bbc40593          	addi	a1,s0,-1092
     304:	bc040513          	addi	a0,s0,-1088
     308:	cf9ff0ef          	jal	0 <append_str>
     30c:	1644a603          	lw	a2,356(s1)
     310:	bbc40593          	addi	a1,s0,-1092
     314:	bc040513          	addi	a0,s0,-1088
     318:	da1ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, "}");
     31c:	00001617          	auipc	a2,0x1
     320:	4d460613          	addi	a2,a2,1236 # 17f0 <malloc+0x1c6>
     324:	bbc40593          	addi	a1,s0,-1092
     328:	bc040513          	addi	a0,s0,-1088
     32c:	cd5ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"state\":{" );
     330:	00001617          	auipc	a2,0x1
     334:	4c860613          	addi	a2,a2,1224 # 17f8 <malloc+0x1ce>
     338:	bbc40593          	addi	a1,s0,-1092
     33c:	bc040513          	addi	a0,s0,-1088
     340:	cc1ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->bcache.refcnt);
     344:	00001617          	auipc	a2,0x1
     348:	4c460613          	addi	a2,a2,1220 # 1808 <malloc+0x1de>
     34c:	bbc40593          	addi	a1,s0,-1092
     350:	bc040513          	addi	a0,s0,-1088
     354:	cadff0ef          	jal	0 <append_str>
     358:	1684a983          	lw	s3,360(s1)
     35c:	864e                	mv	a2,s3
     35e:	bbc40593          	addi	a1,s0,-1092
     362:	bc040513          	addi	a0,s0,-1088
     366:	d53ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"valid\":"); append_int(buf, &pos, e->bcache.valid);
     36a:	00001617          	auipc	a2,0x1
     36e:	4a660613          	addi	a2,a2,1190 # 1810 <malloc+0x1e6>
     372:	bbc40593          	addi	a1,s0,-1092
     376:	bc040513          	addi	a0,s0,-1088
     37a:	c87ff0ef          	jal	0 <append_str>
     37e:	1704a903          	lw	s2,368(s1)
     382:	864a                	mv	a2,s2
     384:	bbc40593          	addi	a1,s0,-1092
     388:	bc040513          	addi	a0,s0,-1088
     38c:	d2dff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, "}");
     390:	00001617          	auipc	a2,0x1
     394:	46060613          	addi	a2,a2,1120 # 17f0 <malloc+0x1c6>
     398:	bbc40593          	addi	a1,s0,-1092
     39c:	bc040513          	addi	a0,s0,-1088
     3a0:	c61ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"changes\":{" );
     3a4:	00001617          	auipc	a2,0x1
     3a8:	47c60613          	addi	a2,a2,1148 # 1820 <malloc+0x1f6>
     3ac:	bbc40593          	addi	a1,s0,-1092
     3b0:	bc040513          	addi	a0,s0,-1088
     3b4:	c4dff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "ref", e->bcache.old_refcnt, e->bcache.refcnt);
     3b8:	874e                	mv	a4,s3
     3ba:	16c4a683          	lw	a3,364(s1)
     3be:	00001617          	auipc	a2,0x1
     3c2:	47260613          	addi	a2,a2,1138 # 1830 <malloc+0x206>
     3c6:	bbc40593          	addi	a1,s0,-1092
     3ca:	bc040513          	addi	a0,s0,-1088
     3ce:	d23ff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "valid", e->bcache.old_valid, e->bcache.valid);
     3d2:	874a                	mv	a4,s2
     3d4:	1744a683          	lw	a3,372(s1)
     3d8:	00001617          	auipc	a2,0x1
     3dc:	46060613          	addi	a2,a2,1120 # 1838 <malloc+0x20e>
     3e0:	bbc40593          	addi	a1,s0,-1092
     3e4:	bc040513          	addi	a0,s0,-1088
     3e8:	d09ff0ef          	jal	f0 <print_change>

        if(buf[pos-1] == ',') pos--; // remove last comma
     3ec:	bbc42783          	lw	a5,-1092(s0)
     3f0:	37fd                	addiw	a5,a5,-1
     3f2:	0007871b          	sext.w	a4,a5
     3f6:	fc070713          	addi	a4,a4,-64
     3fa:	9722                	add	a4,a4,s0
     3fc:	c0074683          	lbu	a3,-1024(a4)
     400:	02c00713          	li	a4,44
     404:	1ce68ae3          	beq	a3,a4,dd8 <print_fs_event+0xc5a>
        append_str(buf, &pos, "}");
     408:	00001617          	auipc	a2,0x1
     40c:	3e860613          	addi	a2,a2,1000 # 17f0 <malloc+0x1c6>
     410:	bbc40593          	addi	a1,s0,-1092
     414:	bc040513          	addi	a0,s0,-1088
     418:	be9ff0ef          	jal	0 <append_str>
     41c:	42813983          	ld	s3,1064(sp)
    if(buf[pos-1] == ',')
        pos--;

    append_str(buf, &pos, "}");
}
    append_str(buf, &pos, ",\"desc\":\"");
     420:	00001617          	auipc	a2,0x1
     424:	58860613          	addi	a2,a2,1416 # 19a8 <malloc+0x37e>
     428:	bbc40593          	addi	a1,s0,-1092
     42c:	bc040513          	addi	a0,s0,-1088
     430:	bd1ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->details);
     434:	02448613          	addi	a2,s1,36
     438:	bbc40593          	addi	a1,s0,-1092
     43c:	bc040513          	addi	a0,s0,-1088
     440:	bc1ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     444:	00001617          	auipc	a2,0x1
     448:	2ec60613          	addi	a2,a2,748 # 1730 <malloc+0x106>
     44c:	bbc40593          	addi	a1,s0,-1092
     450:	bc040513          	addi	a0,s0,-1088
     454:	badff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "}\n");
     458:	00001617          	auipc	a2,0x1
     45c:	56060613          	addi	a2,a2,1376 # 19b8 <malloc+0x38e>
     460:	bbc40593          	addi	a1,s0,-1092
     464:	bc040513          	addi	a0,s0,-1088
     468:	b99ff0ef          	jal	0 <append_str>

    write(1, buf, pos);
     46c:	bbc42603          	lw	a2,-1092(s0)
     470:	bc040593          	addi	a1,s0,-1088
     474:	4505                	li	a0,1
     476:	4c9000ef          	jal	113e <write>
}
     47a:	44813083          	ld	ra,1096(sp)
     47e:	44013403          	ld	s0,1088(sp)
     482:	43813483          	ld	s1,1080(sp)
     486:	43013903          	ld	s2,1072(sp)
     48a:	45010113          	addi	sp,sp,1104
     48e:	8082                	ret
     490:	43313423          	sd	s3,1064(sp)
     494:	43413023          	sd	s4,1056(sp)
    append_str(buf, &pos, "LOG");
     498:	00001617          	auipc	a2,0x1
     49c:	30060613          	addi	a2,a2,768 # 1798 <malloc+0x16e>
     4a0:	bbc40593          	addi	a1,s0,-1092
     4a4:	bc040513          	addi	a0,s0,-1088
     4a8:	b59ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     4ac:	00001617          	auipc	a2,0x1
     4b0:	28460613          	addi	a2,a2,644 # 1730 <malloc+0x106>
     4b4:	bbc40593          	addi	a1,s0,-1092
     4b8:	bc040513          	addi	a0,s0,-1088
     4bc:	b45ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     4c0:	00001617          	auipc	a2,0x1
     4c4:	2d060613          	addi	a2,a2,720 # 1790 <malloc+0x166>
     4c8:	bbc40593          	addi	a1,s0,-1092
     4cc:	bc040513          	addi	a0,s0,-1088
     4d0:	b31ff0ef          	jal	0 <append_str>
     4d4:	01448613          	addi	a2,s1,20
     4d8:	bbc40593          	addi	a1,s0,-1092
     4dc:	bc040513          	addi	a0,s0,-1088
     4e0:	b21ff0ef          	jal	0 <append_str>
     4e4:	00001617          	auipc	a2,0x1
     4e8:	24c60613          	addi	a2,a2,588 # 1730 <malloc+0x106>
     4ec:	bbc40593          	addi	a1,s0,-1092
     4f0:	bc040513          	addi	a0,s0,-1088
     4f4:	b0dff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"state\":{");
     4f8:	00001617          	auipc	a2,0x1
     4fc:	30060613          	addi	a2,a2,768 # 17f8 <malloc+0x1ce>
     500:	bbc40593          	addi	a1,s0,-1092
     504:	bc040513          	addi	a0,s0,-1088
     508:	af9ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"log_n\":"); append_int(buf, &pos, e->log_n);
     50c:	00001617          	auipc	a2,0x1
     510:	33460613          	addi	a2,a2,820 # 1840 <malloc+0x216>
     514:	bbc40593          	addi	a1,s0,-1092
     518:	bc040513          	addi	a0,s0,-1088
     51c:	ae5ff0ef          	jal	0 <append_str>
     520:	1204aa03          	lw	s4,288(s1)
     524:	8652                	mv	a2,s4
     526:	bbc40593          	addi	a1,s0,-1092
     52a:	bc040513          	addi	a0,s0,-1088
     52e:	b8bff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"outstanding\":"); append_int(buf, &pos, e->outstanding);
     532:	00001617          	auipc	a2,0x1
     536:	31e60613          	addi	a2,a2,798 # 1850 <malloc+0x226>
     53a:	bbc40593          	addi	a1,s0,-1092
     53e:	bc040513          	addi	a0,s0,-1088
     542:	abfff0ef          	jal	0 <append_str>
     546:	1244a983          	lw	s3,292(s1)
     54a:	864e                	mv	a2,s3
     54c:	bbc40593          	addi	a1,s0,-1092
     550:	bc040513          	addi	a0,s0,-1088
     554:	b65ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"committing\":"); append_int(buf, &pos, e->committing);
     558:	00001617          	auipc	a2,0x1
     55c:	30860613          	addi	a2,a2,776 # 1860 <malloc+0x236>
     560:	bbc40593          	addi	a1,s0,-1092
     564:	bc040513          	addi	a0,s0,-1088
     568:	a99ff0ef          	jal	0 <append_str>
     56c:	1284a903          	lw	s2,296(s1)
     570:	864a                	mv	a2,s2
     572:	bbc40593          	addi	a1,s0,-1092
     576:	bc040513          	addi	a0,s0,-1088
     57a:	b3fff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, "}");
     57e:	00001617          	auipc	a2,0x1
     582:	27260613          	addi	a2,a2,626 # 17f0 <malloc+0x1c6>
     586:	bbc40593          	addi	a1,s0,-1092
     58a:	bc040513          	addi	a0,s0,-1088
     58e:	a73ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"changes\":{");
     592:	00001617          	auipc	a2,0x1
     596:	28e60613          	addi	a2,a2,654 # 1820 <malloc+0x1f6>
     59a:	bbc40593          	addi	a1,s0,-1092
     59e:	bc040513          	addi	a0,s0,-1088
     5a2:	a5fff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "log_n", e->old_log_n, e->log_n);
     5a6:	8752                	mv	a4,s4
     5a8:	1144a683          	lw	a3,276(s1)
     5ac:	00001617          	auipc	a2,0x1
     5b0:	2c460613          	addi	a2,a2,708 # 1870 <malloc+0x246>
     5b4:	bbc40593          	addi	a1,s0,-1092
     5b8:	bc040513          	addi	a0,s0,-1088
     5bc:	b35ff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "outstanding", e->old_outstanding, e->outstanding);
     5c0:	874e                	mv	a4,s3
     5c2:	1184a683          	lw	a3,280(s1)
     5c6:	00001617          	auipc	a2,0x1
     5ca:	2b260613          	addi	a2,a2,690 # 1878 <malloc+0x24e>
     5ce:	bbc40593          	addi	a1,s0,-1092
     5d2:	bc040513          	addi	a0,s0,-1088
     5d6:	b1bff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "committing", e->old_committing, e->committing);
     5da:	874a                	mv	a4,s2
     5dc:	11c4a683          	lw	a3,284(s1)
     5e0:	00001617          	auipc	a2,0x1
     5e4:	2a860613          	addi	a2,a2,680 # 1888 <malloc+0x25e>
     5e8:	bbc40593          	addi	a1,s0,-1092
     5ec:	bc040513          	addi	a0,s0,-1088
     5f0:	b01ff0ef          	jal	f0 <print_change>
        if(buf[pos-1] == ',') pos--;
     5f4:	bbc42783          	lw	a5,-1092(s0)
     5f8:	37fd                	addiw	a5,a5,-1
     5fa:	0007871b          	sext.w	a4,a5
     5fe:	fc070713          	addi	a4,a4,-64
     602:	9722                	add	a4,a4,s0
     604:	c0074683          	lbu	a3,-1024(a4)
     608:	02c00713          	li	a4,44
     60c:	7ee68063          	beq	a3,a4,dec <print_fs_event+0xc6e>
        append_str(buf, &pos, "}");
     610:	00001617          	auipc	a2,0x1
     614:	1e060613          	addi	a2,a2,480 # 17f0 <malloc+0x1c6>
     618:	bbc40593          	addi	a1,s0,-1092
     61c:	bc040513          	addi	a0,s0,-1088
     620:	9e1ff0ef          	jal	0 <append_str>
     624:	42813983          	ld	s3,1064(sp)
     628:	42013a03          	ld	s4,1056(sp)
     62c:	bbd5                	j	420 <print_fs_event+0x2a2>
    append_str(buf, &pos, "BALLOC");
     62e:	00001617          	auipc	a2,0x1
     632:	17260613          	addi	a2,a2,370 # 17a0 <malloc+0x176>
     636:	bbc40593          	addi	a1,s0,-1092
     63a:	bc040513          	addi	a0,s0,-1088
     63e:	9c3ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     642:	00001617          	auipc	a2,0x1
     646:	0ee60613          	addi	a2,a2,238 # 1730 <malloc+0x106>
     64a:	bbc40593          	addi	a1,s0,-1092
     64e:	bc040513          	addi	a0,s0,-1088
     652:	9afff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     656:	00001617          	auipc	a2,0x1
     65a:	13a60613          	addi	a2,a2,314 # 1790 <malloc+0x166>
     65e:	bbc40593          	addi	a1,s0,-1092
     662:	bc040513          	addi	a0,s0,-1088
     666:	99bff0ef          	jal	0 <append_str>
     66a:	01448613          	addi	a2,s1,20
     66e:	bbc40593          	addi	a1,s0,-1092
     672:	bc040513          	addi	a0,s0,-1088
     676:	98bff0ef          	jal	0 <append_str>
     67a:	00001617          	auipc	a2,0x1
     67e:	0b660613          	addi	a2,a2,182 # 1730 <malloc+0x106>
     682:	bbc40593          	addi	a1,s0,-1092
     686:	bc040513          	addi	a0,s0,-1088
     68a:	977ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"block\":");
     68e:	00001617          	auipc	a2,0x1
     692:	15260613          	addi	a2,a2,338 # 17e0 <malloc+0x1b6>
     696:	bbc40593          	addi	a1,s0,-1092
     69a:	bc040513          	addi	a0,s0,-1088
     69e:	963ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->balloc.blockno);
     6a2:	1604a603          	lw	a2,352(s1)
     6a6:	bbc40593          	addi	a1,s0,-1092
     6aa:	bc040513          	addi	a0,s0,-1088
     6ae:	a0bff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"state\":{" );
     6b2:	00001617          	auipc	a2,0x1
     6b6:	14660613          	addi	a2,a2,326 # 17f8 <malloc+0x1ce>
     6ba:	bbc40593          	addi	a1,s0,-1092
     6be:	bc040513          	addi	a0,s0,-1088
     6c2:	93fff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"bit\":");
     6c6:	00001617          	auipc	a2,0x1
     6ca:	1d260613          	addi	a2,a2,466 # 1898 <malloc+0x26e>
     6ce:	bbc40593          	addi	a1,s0,-1092
     6d2:	bc040513          	addi	a0,s0,-1088
     6d6:	92bff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->balloc.bit);
     6da:	1644a903          	lw	s2,356(s1)
     6de:	864a                	mv	a2,s2
     6e0:	bbc40593          	addi	a1,s0,-1092
     6e4:	bc040513          	addi	a0,s0,-1088
     6e8:	9d1ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     6ec:	00001617          	auipc	a2,0x1
     6f0:	10460613          	addi	a2,a2,260 # 17f0 <malloc+0x1c6>
     6f4:	bbc40593          	addi	a1,s0,-1092
     6f8:	bc040513          	addi	a0,s0,-1088
     6fc:	905ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{" );
     700:	00001617          	auipc	a2,0x1
     704:	12060613          	addi	a2,a2,288 # 1820 <malloc+0x1f6>
     708:	bbc40593          	addi	a1,s0,-1092
     70c:	bc040513          	addi	a0,s0,-1088
     710:	8f1ff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "bit", e->balloc.old_bit, e->balloc.bit);
     714:	874a                	mv	a4,s2
     716:	1684a683          	lw	a3,360(s1)
     71a:	00001617          	auipc	a2,0x1
     71e:	18660613          	addi	a2,a2,390 # 18a0 <malloc+0x276>
     722:	bbc40593          	addi	a1,s0,-1092
     726:	bc040513          	addi	a0,s0,-1088
     72a:	9c7ff0ef          	jal	f0 <print_change>
    if(buf[pos-1] == ',') pos--;
     72e:	bbc42783          	lw	a5,-1092(s0)
     732:	37fd                	addiw	a5,a5,-1
     734:	0007871b          	sext.w	a4,a5
     738:	fc070713          	addi	a4,a4,-64
     73c:	9722                	add	a4,a4,s0
     73e:	c0074683          	lbu	a3,-1024(a4)
     742:	02c00713          	li	a4,44
     746:	6ae68763          	beq	a3,a4,df4 <print_fs_event+0xc76>
    append_str(buf, &pos, "}");
     74a:	00001617          	auipc	a2,0x1
     74e:	0a660613          	addi	a2,a2,166 # 17f0 <malloc+0x1c6>
     752:	bbc40593          	addi	a1,s0,-1092
     756:	bc040513          	addi	a0,s0,-1088
     75a:	8a7ff0ef          	jal	0 <append_str>
     75e:	b1c9                	j	420 <print_fs_event+0x2a2>
     760:	43313423          	sd	s3,1064(sp)
     764:	43413023          	sd	s4,1056(sp)
     768:	41513c23          	sd	s5,1048(sp)
     76c:	41613823          	sd	s6,1040(sp)
    append_str(buf, &pos, "INODE");
     770:	00001617          	auipc	a2,0x1
     774:	03860613          	addi	a2,a2,56 # 17a8 <malloc+0x17e>
     778:	bbc40593          	addi	a1,s0,-1092
     77c:	bc040513          	addi	a0,s0,-1088
     780:	881ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     784:	00001617          	auipc	a2,0x1
     788:	fac60613          	addi	a2,a2,-84 # 1730 <malloc+0x106>
     78c:	bbc40593          	addi	a1,s0,-1092
     790:	bc040513          	addi	a0,s0,-1088
     794:	86dff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     798:	00001617          	auipc	a2,0x1
     79c:	ff860613          	addi	a2,a2,-8 # 1790 <malloc+0x166>
     7a0:	bbc40593          	addi	a1,s0,-1092
     7a4:	bc040513          	addi	a0,s0,-1088
     7a8:	859ff0ef          	jal	0 <append_str>
     7ac:	01448613          	addi	a2,s1,20
     7b0:	bbc40593          	addi	a1,s0,-1092
     7b4:	bc040513          	addi	a0,s0,-1088
     7b8:	849ff0ef          	jal	0 <append_str>
     7bc:	00001617          	auipc	a2,0x1
     7c0:	f7460613          	addi	a2,a2,-140 # 1730 <malloc+0x106>
     7c4:	bbc40593          	addi	a1,s0,-1092
     7c8:	bc040513          	addi	a0,s0,-1088
     7cc:	835ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"inode\":{");
     7d0:	00001617          	auipc	a2,0x1
     7d4:	0d860613          	addi	a2,a2,216 # 18a8 <malloc+0x27e>
     7d8:	bbc40593          	addi	a1,s0,-1092
     7dc:	bc040513          	addi	a0,s0,-1088
     7e0:	821ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"inum\":"); append_int(buf, &pos, e->inode.inum);
     7e4:	00001617          	auipc	a2,0x1
     7e8:	0d460613          	addi	a2,a2,212 # 18b8 <malloc+0x28e>
     7ec:	bbc40593          	addi	a1,s0,-1092
     7f0:	bc040513          	addi	a0,s0,-1088
     7f4:	80dff0ef          	jal	0 <append_str>
     7f8:	1604a603          	lw	a2,352(s1)
     7fc:	bbc40593          	addi	a1,s0,-1092
     800:	bc040513          	addi	a0,s0,-1088
     804:	8b5ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     808:	00001617          	auipc	a2,0x1
     80c:	fe860613          	addi	a2,a2,-24 # 17f0 <malloc+0x1c6>
     810:	bbc40593          	addi	a1,s0,-1092
     814:	bc040513          	addi	a0,s0,-1088
     818:	fe8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"state\":{");
     81c:	00001617          	auipc	a2,0x1
     820:	fdc60613          	addi	a2,a2,-36 # 17f8 <malloc+0x1ce>
     824:	bbc40593          	addi	a1,s0,-1092
     828:	bc040513          	addi	a0,s0,-1088
     82c:	fd4ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->inode.ref);
     830:	00001617          	auipc	a2,0x1
     834:	fd860613          	addi	a2,a2,-40 # 1808 <malloc+0x1de>
     838:	bbc40593          	addi	a1,s0,-1092
     83c:	bc040513          	addi	a0,s0,-1088
     840:	fc0ff0ef          	jal	0 <append_str>
     844:	1644ab03          	lw	s6,356(s1)
     848:	865a                	mv	a2,s6
     84a:	bbc40593          	addi	a1,s0,-1092
     84e:	bc040513          	addi	a0,s0,-1088
     852:	867ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"valid\":"); append_int(buf, &pos, e->inode.valid_inode);
     856:	00001617          	auipc	a2,0x1
     85a:	fba60613          	addi	a2,a2,-70 # 1810 <malloc+0x1e6>
     85e:	bbc40593          	addi	a1,s0,-1092
     862:	bc040513          	addi	a0,s0,-1088
     866:	f9aff0ef          	jal	0 <append_str>
     86a:	16c4aa83          	lw	s5,364(s1)
     86e:	8656                	mv	a2,s5
     870:	bbc40593          	addi	a1,s0,-1092
     874:	bc040513          	addi	a0,s0,-1088
     878:	841ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"type\":"); append_int(buf, &pos, e->inode.type_inode);
     87c:	00001617          	auipc	a2,0x1
     880:	04460613          	addi	a2,a2,68 # 18c0 <malloc+0x296>
     884:	bbc40593          	addi	a1,s0,-1092
     888:	bc040513          	addi	a0,s0,-1088
     88c:	f74ff0ef          	jal	0 <append_str>
     890:	1744aa03          	lw	s4,372(s1)
     894:	8652                	mv	a2,s4
     896:	bbc40593          	addi	a1,s0,-1092
     89a:	bc040513          	addi	a0,s0,-1088
     89e:	81bff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"size\":"); append_int(buf, &pos, e->inode.size);
     8a2:	00001617          	auipc	a2,0x1
     8a6:	02e60613          	addi	a2,a2,46 # 18d0 <malloc+0x2a6>
     8aa:	bbc40593          	addi	a1,s0,-1092
     8ae:	bc040513          	addi	a0,s0,-1088
     8b2:	f4eff0ef          	jal	0 <append_str>
     8b6:	17c4a983          	lw	s3,380(s1)
     8ba:	864e                	mv	a2,s3
     8bc:	bbc40593          	addi	a1,s0,-1092
     8c0:	bc040513          	addi	a0,s0,-1088
     8c4:	ff4ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"locked\":"); append_int(buf, &pos, e->inode.locked);
     8c8:	00001617          	auipc	a2,0x1
     8cc:	01860613          	addi	a2,a2,24 # 18e0 <malloc+0x2b6>
     8d0:	bbc40593          	addi	a1,s0,-1092
     8d4:	bc040513          	addi	a0,s0,-1088
     8d8:	f28ff0ef          	jal	0 <append_str>
     8dc:	1844a903          	lw	s2,388(s1)
     8e0:	864a                	mv	a2,s2
     8e2:	bbc40593          	addi	a1,s0,-1092
     8e6:	bc040513          	addi	a0,s0,-1088
     8ea:	fceff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     8ee:	00001617          	auipc	a2,0x1
     8f2:	f0260613          	addi	a2,a2,-254 # 17f0 <malloc+0x1c6>
     8f6:	bbc40593          	addi	a1,s0,-1092
     8fa:	bc040513          	addi	a0,s0,-1088
     8fe:	f02ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     902:	00001617          	auipc	a2,0x1
     906:	f1e60613          	addi	a2,a2,-226 # 1820 <malloc+0x1f6>
     90a:	bbc40593          	addi	a1,s0,-1092
     90e:	bc040513          	addi	a0,s0,-1088
     912:	eeeff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "ref", e->inode.old_ref, e->inode.ref);
     916:	875a                	mv	a4,s6
     918:	1684a683          	lw	a3,360(s1)
     91c:	00001617          	auipc	a2,0x1
     920:	f1460613          	addi	a2,a2,-236 # 1830 <malloc+0x206>
     924:	bbc40593          	addi	a1,s0,-1092
     928:	bc040513          	addi	a0,s0,-1088
     92c:	fc4ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "valid", e->inode.old_valid_inode, e->inode.valid_inode);
     930:	8756                	mv	a4,s5
     932:	1704a683          	lw	a3,368(s1)
     936:	00001617          	auipc	a2,0x1
     93a:	f0260613          	addi	a2,a2,-254 # 1838 <malloc+0x20e>
     93e:	bbc40593          	addi	a1,s0,-1092
     942:	bc040513          	addi	a0,s0,-1088
     946:	faaff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "type", e->inode.old_type_inode, e->inode.type_inode);
     94a:	8752                	mv	a4,s4
     94c:	1784a683          	lw	a3,376(s1)
     950:	00001617          	auipc	a2,0x1
     954:	fa060613          	addi	a2,a2,-96 # 18f0 <malloc+0x2c6>
     958:	bbc40593          	addi	a1,s0,-1092
     95c:	bc040513          	addi	a0,s0,-1088
     960:	f90ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "size", e->inode.old_size, e->inode.size);
     964:	874e                	mv	a4,s3
     966:	1804a683          	lw	a3,384(s1)
     96a:	00001617          	auipc	a2,0x1
     96e:	f8e60613          	addi	a2,a2,-114 # 18f8 <malloc+0x2ce>
     972:	bbc40593          	addi	a1,s0,-1092
     976:	bc040513          	addi	a0,s0,-1088
     97a:	f76ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "locked", e->inode.old_locked, e->inode.locked);
     97e:	874a                	mv	a4,s2
     980:	1884a683          	lw	a3,392(s1)
     984:	00001617          	auipc	a2,0x1
     988:	f7c60613          	addi	a2,a2,-132 # 1900 <malloc+0x2d6>
     98c:	bbc40593          	addi	a1,s0,-1092
     990:	bc040513          	addi	a0,s0,-1088
     994:	f5cff0ef          	jal	f0 <print_change>
    if(buf[pos-1] == ',') pos--;
     998:	bbc42783          	lw	a5,-1092(s0)
     99c:	37fd                	addiw	a5,a5,-1
     99e:	0007871b          	sext.w	a4,a5
     9a2:	fc070713          	addi	a4,a4,-64
     9a6:	9722                	add	a4,a4,s0
     9a8:	c0074683          	lbu	a3,-1024(a4)
     9ac:	02c00713          	li	a4,44
     9b0:	44e68e63          	beq	a3,a4,e0c <print_fs_event+0xc8e>
    append_str(buf, &pos, "}");
     9b4:	00001617          	auipc	a2,0x1
     9b8:	e3c60613          	addi	a2,a2,-452 # 17f0 <malloc+0x1c6>
     9bc:	bbc40593          	addi	a1,s0,-1092
     9c0:	bc040513          	addi	a0,s0,-1088
     9c4:	e3cff0ef          	jal	0 <append_str>
     9c8:	42813983          	ld	s3,1064(sp)
     9cc:	42013a03          	ld	s4,1056(sp)
     9d0:	41813a83          	ld	s5,1048(sp)
     9d4:	41013b03          	ld	s6,1040(sp)
     9d8:	b4a1                	j	420 <print_fs_event+0x2a2>
    append_str(buf, &pos, "DIR");
     9da:	00001617          	auipc	a2,0x1
     9de:	dd660613          	addi	a2,a2,-554 # 17b0 <malloc+0x186>
     9e2:	bbc40593          	addi	a1,s0,-1092
     9e6:	bc040513          	addi	a0,s0,-1088
     9ea:	e16ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     9ee:	00001617          	auipc	a2,0x1
     9f2:	d4260613          	addi	a2,a2,-702 # 1730 <malloc+0x106>
     9f6:	bbc40593          	addi	a1,s0,-1092
     9fa:	bc040513          	addi	a0,s0,-1088
     9fe:	e02ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     a02:	00001617          	auipc	a2,0x1
     a06:	d8e60613          	addi	a2,a2,-626 # 1790 <malloc+0x166>
     a0a:	bbc40593          	addi	a1,s0,-1092
     a0e:	bc040513          	addi	a0,s0,-1088
     a12:	deeff0ef          	jal	0 <append_str>
     a16:	01448613          	addi	a2,s1,20
     a1a:	bbc40593          	addi	a1,s0,-1092
     a1e:	bc040513          	addi	a0,s0,-1088
     a22:	ddeff0ef          	jal	0 <append_str>
     a26:	00001617          	auipc	a2,0x1
     a2a:	d0a60613          	addi	a2,a2,-758 # 1730 <malloc+0x106>
     a2e:	bbc40593          	addi	a1,s0,-1092
     a32:	bc040513          	addi	a0,s0,-1088
     a36:	dcaff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"dir\":{");
     a3a:	00001617          	auipc	a2,0x1
     a3e:	ece60613          	addi	a2,a2,-306 # 1908 <malloc+0x2de>
     a42:	bbc40593          	addi	a1,s0,-1092
     a46:	bc040513          	addi	a0,s0,-1088
     a4a:	db6ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"parent\":");
     a4e:	00001617          	auipc	a2,0x1
     a52:	eca60613          	addi	a2,a2,-310 # 1918 <malloc+0x2ee>
     a56:	bbc40593          	addi	a1,s0,-1092
     a5a:	bc040513          	addi	a0,s0,-1088
     a5e:	da2ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->dir.parent_inum);
     a62:	1f44a603          	lw	a2,500(s1)
     a66:	bbc40593          	addi	a1,s0,-1092
     a6a:	bc040513          	addi	a0,s0,-1088
     a6e:	e4aff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"target\":");
     a72:	00001617          	auipc	a2,0x1
     a76:	eb660613          	addi	a2,a2,-330 # 1928 <malloc+0x2fe>
     a7a:	bbc40593          	addi	a1,s0,-1092
     a7e:	bc040513          	addi	a0,s0,-1088
     a82:	d7eff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->dir.target_inum);
     a86:	1f84a603          	lw	a2,504(s1)
     a8a:	bbc40593          	addi	a1,s0,-1092
     a8e:	bc040513          	addi	a0,s0,-1088
     a92:	e26ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"offset\":");
     a96:	00001617          	auipc	a2,0x1
     a9a:	ea260613          	addi	a2,a2,-350 # 1938 <malloc+0x30e>
     a9e:	bbc40593          	addi	a1,s0,-1092
     aa2:	bc040513          	addi	a0,s0,-1088
     aa6:	d5aff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->dir.offset);
     aaa:	1fc4a603          	lw	a2,508(s1)
     aae:	bbc40593          	addi	a1,s0,-1092
     ab2:	bc040513          	addi	a0,s0,-1088
     ab6:	e02ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"name\":\"");
     aba:	00001617          	auipc	a2,0x1
     abe:	e8e60613          	addi	a2,a2,-370 # 1948 <malloc+0x31e>
     ac2:	bbc40593          	addi	a1,s0,-1092
     ac6:	bc040513          	addi	a0,s0,-1088
     aca:	d36ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->dir.name);
     ace:	1e048613          	addi	a2,s1,480
     ad2:	bbc40593          	addi	a1,s0,-1092
     ad6:	bc040513          	addi	a0,s0,-1088
     ada:	d26ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"}");
     ade:	00001617          	auipc	a2,0x1
     ae2:	e7a60613          	addi	a2,a2,-390 # 1958 <malloc+0x32e>
     ae6:	bbc40593          	addi	a1,s0,-1092
     aea:	bc040513          	addi	a0,s0,-1088
     aee:	d12ff0ef          	jal	0 <append_str>
     af2:	92fff06f          	j	420 <print_fs_event+0x2a2>
    append_str(buf, &pos, "PATH");
     af6:	00001617          	auipc	a2,0x1
     afa:	cc260613          	addi	a2,a2,-830 # 17b8 <malloc+0x18e>
     afe:	bbc40593          	addi	a1,s0,-1092
     b02:	bc040513          	addi	a0,s0,-1088
     b06:	cfaff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     b0a:	00001617          	auipc	a2,0x1
     b0e:	c2660613          	addi	a2,a2,-986 # 1730 <malloc+0x106>
     b12:	bbc40593          	addi	a1,s0,-1092
     b16:	bc040513          	addi	a0,s0,-1088
     b1a:	ce6ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     b1e:	00001617          	auipc	a2,0x1
     b22:	c7260613          	addi	a2,a2,-910 # 1790 <malloc+0x166>
     b26:	bbc40593          	addi	a1,s0,-1092
     b2a:	bc040513          	addi	a0,s0,-1088
     b2e:	cd2ff0ef          	jal	0 <append_str>
     b32:	01448613          	addi	a2,s1,20
     b36:	bbc40593          	addi	a1,s0,-1092
     b3a:	bc040513          	addi	a0,s0,-1088
     b3e:	cc2ff0ef          	jal	0 <append_str>
     b42:	00001617          	auipc	a2,0x1
     b46:	bee60613          	addi	a2,a2,-1042 # 1730 <malloc+0x106>
     b4a:	bbc40593          	addi	a1,s0,-1092
     b4e:	bc040513          	addi	a0,s0,-1088
     b52:	caeff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"path\":\"");
     b56:	00001617          	auipc	a2,0x1
     b5a:	e0a60613          	addi	a2,a2,-502 # 1960 <malloc+0x336>
     b5e:	bbc40593          	addi	a1,s0,-1092
     b62:	bc040513          	addi	a0,s0,-1088
     b66:	c9aff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->dir.path);
     b6a:	16048613          	addi	a2,s1,352
     b6e:	bbc40593          	addi	a1,s0,-1092
     b72:	bc040513          	addi	a0,s0,-1088
     b76:	c8aff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     b7a:	00001617          	auipc	a2,0x1
     b7e:	bb660613          	addi	a2,a2,-1098 # 1730 <malloc+0x106>
     b82:	bbc40593          	addi	a1,s0,-1092
     b86:	bc040513          	addi	a0,s0,-1088
     b8a:	c76ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"elem\":\"");
     b8e:	00001617          	auipc	a2,0x1
     b92:	de260613          	addi	a2,a2,-542 # 1970 <malloc+0x346>
     b96:	bbc40593          	addi	a1,s0,-1092
     b9a:	bc040513          	addi	a0,s0,-1088
     b9e:	c62ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->dir.name);
     ba2:	1e048613          	addi	a2,s1,480
     ba6:	bbc40593          	addi	a1,s0,-1092
     baa:	bc040513          	addi	a0,s0,-1088
     bae:	c52ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     bb2:	00001617          	auipc	a2,0x1
     bb6:	b7e60613          	addi	a2,a2,-1154 # 1730 <malloc+0x106>
     bba:	bbc40593          	addi	a1,s0,-1092
     bbe:	bc040513          	addi	a0,s0,-1088
     bc2:	c3eff0ef          	jal	0 <append_str>
     bc6:	85bff06f          	j	420 <print_fs_event+0x2a2>
     bca:	43313423          	sd	s3,1064(sp)
    append_str(buf, &pos, "FILE");
     bce:	00001617          	auipc	a2,0x1
     bd2:	bf260613          	addi	a2,a2,-1038 # 17c0 <malloc+0x196>
     bd6:	bbc40593          	addi	a1,s0,-1092
     bda:	bc040513          	addi	a0,s0,-1088
     bde:	c22ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     be2:	00001617          	auipc	a2,0x1
     be6:	b4e60613          	addi	a2,a2,-1202 # 1730 <malloc+0x106>
     bea:	bbc40593          	addi	a1,s0,-1092
     bee:	bc040513          	addi	a0,s0,-1088
     bf2:	c0eff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     bf6:	00001617          	auipc	a2,0x1
     bfa:	b9a60613          	addi	a2,a2,-1126 # 1790 <malloc+0x166>
     bfe:	bbc40593          	addi	a1,s0,-1092
     c02:	bc040513          	addi	a0,s0,-1088
     c06:	bfaff0ef          	jal	0 <append_str>
     c0a:	01448613          	addi	a2,s1,20
     c0e:	bbc40593          	addi	a1,s0,-1092
     c12:	bc040513          	addi	a0,s0,-1088
     c16:	beaff0ef          	jal	0 <append_str>
     c1a:	00001617          	auipc	a2,0x1
     c1e:	b1660613          	addi	a2,a2,-1258 # 1730 <malloc+0x106>
     c22:	bbc40593          	addi	a1,s0,-1092
     c26:	bc040513          	addi	a0,s0,-1088
     c2a:	bd6ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"state\":{");
     c2e:	00001617          	auipc	a2,0x1
     c32:	bca60613          	addi	a2,a2,-1078 # 17f8 <malloc+0x1ce>
     c36:	bbc40593          	addi	a1,s0,-1092
     c3a:	bc040513          	addi	a0,s0,-1088
     c3e:	bc2ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":");
     c42:	00001617          	auipc	a2,0x1
     c46:	bc660613          	addi	a2,a2,-1082 # 1808 <malloc+0x1de>
     c4a:	bbc40593          	addi	a1,s0,-1092
     c4e:	bc040513          	addi	a0,s0,-1088
     c52:	baeff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file.file_ref);
     c56:	1704a983          	lw	s3,368(s1)
     c5a:	864e                	mv	a2,s3
     c5c:	bbc40593          	addi	a1,s0,-1092
     c60:	bc040513          	addi	a0,s0,-1088
     c64:	c54ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"offset\":");
     c68:	00001617          	auipc	a2,0x1
     c6c:	cd060613          	addi	a2,a2,-816 # 1938 <malloc+0x30e>
     c70:	bbc40593          	addi	a1,s0,-1092
     c74:	bc040513          	addi	a0,s0,-1088
     c78:	b88ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file.file_off);
     c7c:	1784a903          	lw	s2,376(s1)
     c80:	864a                	mv	a2,s2
     c82:	bbc40593          	addi	a1,s0,-1092
     c86:	bc040513          	addi	a0,s0,-1088
     c8a:	c2eff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"readable\":");
     c8e:	00001617          	auipc	a2,0x1
     c92:	cf260613          	addi	a2,a2,-782 # 1980 <malloc+0x356>
     c96:	bbc40593          	addi	a1,s0,-1092
     c9a:	bc040513          	addi	a0,s0,-1088
     c9e:	b62ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file.readable);
     ca2:	1684a603          	lw	a2,360(s1)
     ca6:	bbc40593          	addi	a1,s0,-1092
     caa:	bc040513          	addi	a0,s0,-1088
     cae:	c0aff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"writable\":");
     cb2:	00001617          	auipc	a2,0x1
     cb6:	cde60613          	addi	a2,a2,-802 # 1990 <malloc+0x366>
     cba:	bbc40593          	addi	a1,s0,-1092
     cbe:	bc040513          	addi	a0,s0,-1088
     cc2:	b3eff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file.writable);
     cc6:	16c4a603          	lw	a2,364(s1)
     cca:	bbc40593          	addi	a1,s0,-1092
     cce:	bc040513          	addi	a0,s0,-1088
     cd2:	be6ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     cd6:	00001617          	auipc	a2,0x1
     cda:	b1a60613          	addi	a2,a2,-1254 # 17f0 <malloc+0x1c6>
     cde:	bbc40593          	addi	a1,s0,-1092
     ce2:	bc040513          	addi	a0,s0,-1088
     ce6:	b1aff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     cea:	00001617          	auipc	a2,0x1
     cee:	b3660613          	addi	a2,a2,-1226 # 1820 <malloc+0x1f6>
     cf2:	bbc40593          	addi	a1,s0,-1092
     cf6:	bc040513          	addi	a0,s0,-1088
     cfa:	b06ff0ef          	jal	0 <append_str>
    print_change(buf, &pos,
     cfe:	874e                	mv	a4,s3
     d00:	1744a683          	lw	a3,372(s1)
     d04:	00001617          	auipc	a2,0x1
     d08:	b2c60613          	addi	a2,a2,-1236 # 1830 <malloc+0x206>
     d0c:	bbc40593          	addi	a1,s0,-1092
     d10:	bc040513          	addi	a0,s0,-1088
     d14:	bdcff0ef          	jal	f0 <print_change>
    print_change(buf, &pos,
     d18:	874a                	mv	a4,s2
     d1a:	17c4a683          	lw	a3,380(s1)
     d1e:	00001617          	auipc	a2,0x1
     d22:	c8260613          	addi	a2,a2,-894 # 19a0 <malloc+0x376>
     d26:	bbc40593          	addi	a1,s0,-1092
     d2a:	bc040513          	addi	a0,s0,-1088
     d2e:	bc2ff0ef          	jal	f0 <print_change>
    if(buf[pos-1] == ',')
     d32:	bbc42783          	lw	a5,-1092(s0)
     d36:	37fd                	addiw	a5,a5,-1
     d38:	0007871b          	sext.w	a4,a5
     d3c:	fc070713          	addi	a4,a4,-64
     d40:	9722                	add	a4,a4,s0
     d42:	c0074683          	lbu	a3,-1024(a4)
     d46:	02c00713          	li	a4,44
     d4a:	0ce68763          	beq	a3,a4,e18 <print_fs_event+0xc9a>
    append_str(buf, &pos, "}");
     d4e:	00001617          	auipc	a2,0x1
     d52:	aa260613          	addi	a2,a2,-1374 # 17f0 <malloc+0x1c6>
     d56:	bbc40593          	addi	a1,s0,-1092
     d5a:	bc040513          	addi	a0,s0,-1088
     d5e:	aa2ff0ef          	jal	0 <append_str>
     d62:	42813983          	ld	s3,1064(sp)
     d66:	ebaff06f          	j	420 <print_fs_event+0x2a2>
    append_str(buf, &pos, "\"");
     d6a:	00001617          	auipc	a2,0x1
     d6e:	9c660613          	addi	a2,a2,-1594 # 1730 <malloc+0x106>
     d72:	bbc40593          	addi	a1,s0,-1092
     d76:	bc040513          	addi	a0,s0,-1088
     d7a:	a86ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     d7e:	00001617          	auipc	a2,0x1
     d82:	a1260613          	addi	a2,a2,-1518 # 1790 <malloc+0x166>
     d86:	bbc40593          	addi	a1,s0,-1092
     d8a:	bc040513          	addi	a0,s0,-1088
     d8e:	a72ff0ef          	jal	0 <append_str>
     d92:	01448613          	addi	a2,s1,20
     d96:	bbc40593          	addi	a1,s0,-1092
     d9a:	bc040513          	addi	a0,s0,-1088
     d9e:	a62ff0ef          	jal	0 <append_str>
     da2:	00001617          	auipc	a2,0x1
     da6:	98e60613          	addi	a2,a2,-1650 # 1730 <malloc+0x106>
     daa:	bbc40593          	addi	a1,s0,-1092
     dae:	bc040513          	addi	a0,s0,-1088
     db2:	a4eff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE){
     db6:	479d                	li	a5,7
     db8:	e727e463          	bltu	a5,s2,420 <print_fs_event+0x2a2>
     dbc:	090a                	slli	s2,s2,0x2
     dbe:	00001717          	auipc	a4,0x1
     dc2:	c7270713          	addi	a4,a4,-910 # 1a30 <malloc+0x406>
     dc6:	993a                	add	s2,s2,a4
     dc8:	00092783          	lw	a5,0(s2)
     dcc:	97ba                	add	a5,a5,a4
     dce:	8782                	jr	a5
     dd0:	43313423          	sd	s3,1064(sp)
     dd4:	cecff06f          	j	2c0 <print_fs_event+0x142>
        if(buf[pos-1] == ',') pos--; // remove last comma
     dd8:	baf42e23          	sw	a5,-1092(s0)
     ddc:	e2cff06f          	j	408 <print_fs_event+0x28a>
     de0:	43313423          	sd	s3,1064(sp)
     de4:	43413023          	sd	s4,1056(sp)
     de8:	f10ff06f          	j	4f8 <print_fs_event+0x37a>
        if(buf[pos-1] == ',') pos--;
     dec:	baf42e23          	sw	a5,-1092(s0)
     df0:	821ff06f          	j	610 <print_fs_event+0x492>
    if(buf[pos-1] == ',') pos--;
     df4:	baf42e23          	sw	a5,-1092(s0)
     df8:	ba89                	j	74a <print_fs_event+0x5cc>
     dfa:	43313423          	sd	s3,1064(sp)
     dfe:	43413023          	sd	s4,1056(sp)
     e02:	41513c23          	sd	s5,1048(sp)
     e06:	41613823          	sd	s6,1040(sp)
     e0a:	b2d9                	j	7d0 <print_fs_event+0x652>
    if(buf[pos-1] == ',') pos--;
     e0c:	baf42e23          	sw	a5,-1092(s0)
     e10:	b655                	j	9b4 <print_fs_event+0x836>
     e12:	43313423          	sd	s3,1064(sp)
     e16:	bd21                	j	c2e <print_fs_event+0xab0>
        pos--;
     e18:	baf42e23          	sw	a5,-1092(s0)
     e1c:	bf0d                	j	d4e <print_fs_event+0xbd0>

0000000000000e1e <main>:

int main(void) {
     e1e:	7179                	addi	sp,sp,-48
     e20:	f406                	sd	ra,40(sp)
     e22:	f022                	sd	s0,32(sp)
     e24:	ec26                	sd	s1,24(sp)
     e26:	e84a                	sd	s2,16(sp)
     e28:	e44e                	sd	s3,8(sp)
     e2a:	1800                	addi	s0,sp,48
    printf("FS Buffer Cache Export starting...\n");
     e2c:	00001517          	auipc	a0,0x1
     e30:	b9450513          	addi	a0,a0,-1132 # 19c0 <malloc+0x396>
     e34:	742000ef          	jal	1576 <printf>
    
    while (1) {
        int n_fs = fsread(fs_ev, 16);
     e38:	00001997          	auipc	s3,0x1
     e3c:	1d898993          	addi	s3,s3,472 # 2010 <fs_ev>
     e40:	a831                	j	e5c <main+0x3e>
        if (n_fs < 0) {
            fprintf(2, "fsexport: error reading fslog\n");
     e42:	00001597          	auipc	a1,0x1
     e46:	ba658593          	addi	a1,a1,-1114 # 19e8 <malloc+0x3be>
     e4a:	4509                	li	a0,2
     e4c:	700000ef          	jal	154c <fprintf>
            exit(1);
     e50:	4505                	li	a0,1
     e52:	2cc000ef          	jal	111e <exit>
        for (int i = 0; i < n_fs; i++) {
            print_fs_event(&fs_ev[i]);
        }

        // استخدام sleep(2) بدلاً من pause في xv6 لضمان استمرار الحلقة
        pause(2); 
     e56:	4509                	li	a0,2
     e58:	356000ef          	jal	11ae <pause>
        int n_fs = fsread(fs_ev, 16);
     e5c:	45c1                	li	a1,16
     e5e:	854e                	mv	a0,s3
     e60:	366000ef          	jal	11c6 <fsread>
        if (n_fs < 0) {
     e64:	fc054fe3          	bltz	a0,e42 <main+0x24>
        for (int i = 0; i < n_fs; i++) {
     e68:	00001497          	auipc	s1,0x1
     e6c:	1a848493          	addi	s1,s1,424 # 2010 <fs_ev>
     e70:	00951913          	slli	s2,a0,0x9
     e74:	9926                	add	s2,s2,s1
     e76:	fea050e3          	blez	a0,e56 <main+0x38>
            print_fs_event(&fs_ev[i]);
     e7a:	8526                	mv	a0,s1
     e7c:	b02ff0ef          	jal	17e <print_fs_event>
        for (int i = 0; i < n_fs; i++) {
     e80:	20048493          	addi	s1,s1,512
     e84:	ff249be3          	bne	s1,s2,e7a <main+0x5c>
     e88:	b7f9                	j	e56 <main+0x38>

0000000000000e8a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     e8a:	1141                	addi	sp,sp,-16
     e8c:	e406                	sd	ra,8(sp)
     e8e:	e022                	sd	s0,0(sp)
     e90:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     e92:	f8dff0ef          	jal	e1e <main>
  exit(r);
     e96:	288000ef          	jal	111e <exit>

0000000000000e9a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     e9a:	1141                	addi	sp,sp,-16
     e9c:	e422                	sd	s0,8(sp)
     e9e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     ea0:	87aa                	mv	a5,a0
     ea2:	0585                	addi	a1,a1,1
     ea4:	0785                	addi	a5,a5,1
     ea6:	fff5c703          	lbu	a4,-1(a1)
     eaa:	fee78fa3          	sb	a4,-1(a5)
     eae:	fb75                	bnez	a4,ea2 <strcpy+0x8>
    ;
  return os;
}
     eb0:	6422                	ld	s0,8(sp)
     eb2:	0141                	addi	sp,sp,16
     eb4:	8082                	ret

0000000000000eb6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     eb6:	1141                	addi	sp,sp,-16
     eb8:	e422                	sd	s0,8(sp)
     eba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     ebc:	00054783          	lbu	a5,0(a0)
     ec0:	cb91                	beqz	a5,ed4 <strcmp+0x1e>
     ec2:	0005c703          	lbu	a4,0(a1)
     ec6:	00f71763          	bne	a4,a5,ed4 <strcmp+0x1e>
    p++, q++;
     eca:	0505                	addi	a0,a0,1
     ecc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     ece:	00054783          	lbu	a5,0(a0)
     ed2:	fbe5                	bnez	a5,ec2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     ed4:	0005c503          	lbu	a0,0(a1)
}
     ed8:	40a7853b          	subw	a0,a5,a0
     edc:	6422                	ld	s0,8(sp)
     ede:	0141                	addi	sp,sp,16
     ee0:	8082                	ret

0000000000000ee2 <strlen>:

uint
strlen(const char *s)
{
     ee2:	1141                	addi	sp,sp,-16
     ee4:	e422                	sd	s0,8(sp)
     ee6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     ee8:	00054783          	lbu	a5,0(a0)
     eec:	cf91                	beqz	a5,f08 <strlen+0x26>
     eee:	0505                	addi	a0,a0,1
     ef0:	87aa                	mv	a5,a0
     ef2:	86be                	mv	a3,a5
     ef4:	0785                	addi	a5,a5,1
     ef6:	fff7c703          	lbu	a4,-1(a5)
     efa:	ff65                	bnez	a4,ef2 <strlen+0x10>
     efc:	40a6853b          	subw	a0,a3,a0
     f00:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     f02:	6422                	ld	s0,8(sp)
     f04:	0141                	addi	sp,sp,16
     f06:	8082                	ret
  for(n = 0; s[n]; n++)
     f08:	4501                	li	a0,0
     f0a:	bfe5                	j	f02 <strlen+0x20>

0000000000000f0c <memset>:

void*
memset(void *dst, int c, uint n)
{
     f0c:	1141                	addi	sp,sp,-16
     f0e:	e422                	sd	s0,8(sp)
     f10:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     f12:	ca19                	beqz	a2,f28 <memset+0x1c>
     f14:	87aa                	mv	a5,a0
     f16:	1602                	slli	a2,a2,0x20
     f18:	9201                	srli	a2,a2,0x20
     f1a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     f1e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     f22:	0785                	addi	a5,a5,1
     f24:	fee79de3          	bne	a5,a4,f1e <memset+0x12>
  }
  return dst;
}
     f28:	6422                	ld	s0,8(sp)
     f2a:	0141                	addi	sp,sp,16
     f2c:	8082                	ret

0000000000000f2e <strchr>:

char*
strchr(const char *s, char c)
{
     f2e:	1141                	addi	sp,sp,-16
     f30:	e422                	sd	s0,8(sp)
     f32:	0800                	addi	s0,sp,16
  for(; *s; s++)
     f34:	00054783          	lbu	a5,0(a0)
     f38:	cb99                	beqz	a5,f4e <strchr+0x20>
    if(*s == c)
     f3a:	00f58763          	beq	a1,a5,f48 <strchr+0x1a>
  for(; *s; s++)
     f3e:	0505                	addi	a0,a0,1
     f40:	00054783          	lbu	a5,0(a0)
     f44:	fbfd                	bnez	a5,f3a <strchr+0xc>
      return (char*)s;
  return 0;
     f46:	4501                	li	a0,0
}
     f48:	6422                	ld	s0,8(sp)
     f4a:	0141                	addi	sp,sp,16
     f4c:	8082                	ret
  return 0;
     f4e:	4501                	li	a0,0
     f50:	bfe5                	j	f48 <strchr+0x1a>

0000000000000f52 <gets>:

char*
gets(char *buf, int max)
{
     f52:	711d                	addi	sp,sp,-96
     f54:	ec86                	sd	ra,88(sp)
     f56:	e8a2                	sd	s0,80(sp)
     f58:	e4a6                	sd	s1,72(sp)
     f5a:	e0ca                	sd	s2,64(sp)
     f5c:	fc4e                	sd	s3,56(sp)
     f5e:	f852                	sd	s4,48(sp)
     f60:	f456                	sd	s5,40(sp)
     f62:	f05a                	sd	s6,32(sp)
     f64:	ec5e                	sd	s7,24(sp)
     f66:	1080                	addi	s0,sp,96
     f68:	8baa                	mv	s7,a0
     f6a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     f6c:	892a                	mv	s2,a0
     f6e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     f70:	4aa9                	li	s5,10
     f72:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     f74:	89a6                	mv	s3,s1
     f76:	2485                	addiw	s1,s1,1
     f78:	0344d663          	bge	s1,s4,fa4 <gets+0x52>
    cc = read(0, &c, 1);
     f7c:	4605                	li	a2,1
     f7e:	faf40593          	addi	a1,s0,-81
     f82:	4501                	li	a0,0
     f84:	1b2000ef          	jal	1136 <read>
    if(cc < 1)
     f88:	00a05e63          	blez	a0,fa4 <gets+0x52>
    buf[i++] = c;
     f8c:	faf44783          	lbu	a5,-81(s0)
     f90:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     f94:	01578763          	beq	a5,s5,fa2 <gets+0x50>
     f98:	0905                	addi	s2,s2,1
     f9a:	fd679de3          	bne	a5,s6,f74 <gets+0x22>
    buf[i++] = c;
     f9e:	89a6                	mv	s3,s1
     fa0:	a011                	j	fa4 <gets+0x52>
     fa2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     fa4:	99de                	add	s3,s3,s7
     fa6:	00098023          	sb	zero,0(s3)
  return buf;
}
     faa:	855e                	mv	a0,s7
     fac:	60e6                	ld	ra,88(sp)
     fae:	6446                	ld	s0,80(sp)
     fb0:	64a6                	ld	s1,72(sp)
     fb2:	6906                	ld	s2,64(sp)
     fb4:	79e2                	ld	s3,56(sp)
     fb6:	7a42                	ld	s4,48(sp)
     fb8:	7aa2                	ld	s5,40(sp)
     fba:	7b02                	ld	s6,32(sp)
     fbc:	6be2                	ld	s7,24(sp)
     fbe:	6125                	addi	sp,sp,96
     fc0:	8082                	ret

0000000000000fc2 <stat>:

int
stat(const char *n, struct stat *st)
{
     fc2:	1101                	addi	sp,sp,-32
     fc4:	ec06                	sd	ra,24(sp)
     fc6:	e822                	sd	s0,16(sp)
     fc8:	e04a                	sd	s2,0(sp)
     fca:	1000                	addi	s0,sp,32
     fcc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     fce:	4581                	li	a1,0
     fd0:	18e000ef          	jal	115e <open>
  if(fd < 0)
     fd4:	02054263          	bltz	a0,ff8 <stat+0x36>
     fd8:	e426                	sd	s1,8(sp)
     fda:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     fdc:	85ca                	mv	a1,s2
     fde:	198000ef          	jal	1176 <fstat>
     fe2:	892a                	mv	s2,a0
  close(fd);
     fe4:	8526                	mv	a0,s1
     fe6:	160000ef          	jal	1146 <close>
  return r;
     fea:	64a2                	ld	s1,8(sp)
}
     fec:	854a                	mv	a0,s2
     fee:	60e2                	ld	ra,24(sp)
     ff0:	6442                	ld	s0,16(sp)
     ff2:	6902                	ld	s2,0(sp)
     ff4:	6105                	addi	sp,sp,32
     ff6:	8082                	ret
    return -1;
     ff8:	597d                	li	s2,-1
     ffa:	bfcd                	j	fec <stat+0x2a>

0000000000000ffc <atoi>:

int
atoi(const char *s)
{
     ffc:	1141                	addi	sp,sp,-16
     ffe:	e422                	sd	s0,8(sp)
    1000:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1002:	00054683          	lbu	a3,0(a0)
    1006:	fd06879b          	addiw	a5,a3,-48
    100a:	0ff7f793          	zext.b	a5,a5
    100e:	4625                	li	a2,9
    1010:	02f66863          	bltu	a2,a5,1040 <atoi+0x44>
    1014:	872a                	mv	a4,a0
  n = 0;
    1016:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    1018:	0705                	addi	a4,a4,1
    101a:	0025179b          	slliw	a5,a0,0x2
    101e:	9fa9                	addw	a5,a5,a0
    1020:	0017979b          	slliw	a5,a5,0x1
    1024:	9fb5                	addw	a5,a5,a3
    1026:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    102a:	00074683          	lbu	a3,0(a4)
    102e:	fd06879b          	addiw	a5,a3,-48
    1032:	0ff7f793          	zext.b	a5,a5
    1036:	fef671e3          	bgeu	a2,a5,1018 <atoi+0x1c>
  return n;
}
    103a:	6422                	ld	s0,8(sp)
    103c:	0141                	addi	sp,sp,16
    103e:	8082                	ret
  n = 0;
    1040:	4501                	li	a0,0
    1042:	bfe5                	j	103a <atoi+0x3e>

0000000000001044 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    1044:	1141                	addi	sp,sp,-16
    1046:	e422                	sd	s0,8(sp)
    1048:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    104a:	02b57463          	bgeu	a0,a1,1072 <memmove+0x2e>
    while(n-- > 0)
    104e:	00c05f63          	blez	a2,106c <memmove+0x28>
    1052:	1602                	slli	a2,a2,0x20
    1054:	9201                	srli	a2,a2,0x20
    1056:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    105a:	872a                	mv	a4,a0
      *dst++ = *src++;
    105c:	0585                	addi	a1,a1,1
    105e:	0705                	addi	a4,a4,1
    1060:	fff5c683          	lbu	a3,-1(a1)
    1064:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    1068:	fef71ae3          	bne	a4,a5,105c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    106c:	6422                	ld	s0,8(sp)
    106e:	0141                	addi	sp,sp,16
    1070:	8082                	ret
    dst += n;
    1072:	00c50733          	add	a4,a0,a2
    src += n;
    1076:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    1078:	fec05ae3          	blez	a2,106c <memmove+0x28>
    107c:	fff6079b          	addiw	a5,a2,-1
    1080:	1782                	slli	a5,a5,0x20
    1082:	9381                	srli	a5,a5,0x20
    1084:	fff7c793          	not	a5,a5
    1088:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    108a:	15fd                	addi	a1,a1,-1
    108c:	177d                	addi	a4,a4,-1
    108e:	0005c683          	lbu	a3,0(a1)
    1092:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    1096:	fee79ae3          	bne	a5,a4,108a <memmove+0x46>
    109a:	bfc9                	j	106c <memmove+0x28>

000000000000109c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    109c:	1141                	addi	sp,sp,-16
    109e:	e422                	sd	s0,8(sp)
    10a0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    10a2:	ca05                	beqz	a2,10d2 <memcmp+0x36>
    10a4:	fff6069b          	addiw	a3,a2,-1
    10a8:	1682                	slli	a3,a3,0x20
    10aa:	9281                	srli	a3,a3,0x20
    10ac:	0685                	addi	a3,a3,1
    10ae:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    10b0:	00054783          	lbu	a5,0(a0)
    10b4:	0005c703          	lbu	a4,0(a1)
    10b8:	00e79863          	bne	a5,a4,10c8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    10bc:	0505                	addi	a0,a0,1
    p2++;
    10be:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    10c0:	fed518e3          	bne	a0,a3,10b0 <memcmp+0x14>
  }
  return 0;
    10c4:	4501                	li	a0,0
    10c6:	a019                	j	10cc <memcmp+0x30>
      return *p1 - *p2;
    10c8:	40e7853b          	subw	a0,a5,a4
}
    10cc:	6422                	ld	s0,8(sp)
    10ce:	0141                	addi	sp,sp,16
    10d0:	8082                	ret
  return 0;
    10d2:	4501                	li	a0,0
    10d4:	bfe5                	j	10cc <memcmp+0x30>

00000000000010d6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    10d6:	1141                	addi	sp,sp,-16
    10d8:	e406                	sd	ra,8(sp)
    10da:	e022                	sd	s0,0(sp)
    10dc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    10de:	f67ff0ef          	jal	1044 <memmove>
}
    10e2:	60a2                	ld	ra,8(sp)
    10e4:	6402                	ld	s0,0(sp)
    10e6:	0141                	addi	sp,sp,16
    10e8:	8082                	ret

00000000000010ea <sbrk>:

char *
sbrk(int n) {
    10ea:	1141                	addi	sp,sp,-16
    10ec:	e406                	sd	ra,8(sp)
    10ee:	e022                	sd	s0,0(sp)
    10f0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
    10f2:	4585                	li	a1,1
    10f4:	0b2000ef          	jal	11a6 <sys_sbrk>
}
    10f8:	60a2                	ld	ra,8(sp)
    10fa:	6402                	ld	s0,0(sp)
    10fc:	0141                	addi	sp,sp,16
    10fe:	8082                	ret

0000000000001100 <sbrklazy>:

char *
sbrklazy(int n) {
    1100:	1141                	addi	sp,sp,-16
    1102:	e406                	sd	ra,8(sp)
    1104:	e022                	sd	s0,0(sp)
    1106:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    1108:	4589                	li	a1,2
    110a:	09c000ef          	jal	11a6 <sys_sbrk>
}
    110e:	60a2                	ld	ra,8(sp)
    1110:	6402                	ld	s0,0(sp)
    1112:	0141                	addi	sp,sp,16
    1114:	8082                	ret

0000000000001116 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    1116:	4885                	li	a7,1
 ecall
    1118:	00000073          	ecall
 ret
    111c:	8082                	ret

000000000000111e <exit>:
.global exit
exit:
 li a7, SYS_exit
    111e:	4889                	li	a7,2
 ecall
    1120:	00000073          	ecall
 ret
    1124:	8082                	ret

0000000000001126 <wait>:
.global wait
wait:
 li a7, SYS_wait
    1126:	488d                	li	a7,3
 ecall
    1128:	00000073          	ecall
 ret
    112c:	8082                	ret

000000000000112e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    112e:	4891                	li	a7,4
 ecall
    1130:	00000073          	ecall
 ret
    1134:	8082                	ret

0000000000001136 <read>:
.global read
read:
 li a7, SYS_read
    1136:	4895                	li	a7,5
 ecall
    1138:	00000073          	ecall
 ret
    113c:	8082                	ret

000000000000113e <write>:
.global write
write:
 li a7, SYS_write
    113e:	48c1                	li	a7,16
 ecall
    1140:	00000073          	ecall
 ret
    1144:	8082                	ret

0000000000001146 <close>:
.global close
close:
 li a7, SYS_close
    1146:	48d5                	li	a7,21
 ecall
    1148:	00000073          	ecall
 ret
    114c:	8082                	ret

000000000000114e <kill>:
.global kill
kill:
 li a7, SYS_kill
    114e:	4899                	li	a7,6
 ecall
    1150:	00000073          	ecall
 ret
    1154:	8082                	ret

0000000000001156 <exec>:
.global exec
exec:
 li a7, SYS_exec
    1156:	489d                	li	a7,7
 ecall
    1158:	00000073          	ecall
 ret
    115c:	8082                	ret

000000000000115e <open>:
.global open
open:
 li a7, SYS_open
    115e:	48bd                	li	a7,15
 ecall
    1160:	00000073          	ecall
 ret
    1164:	8082                	ret

0000000000001166 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    1166:	48c5                	li	a7,17
 ecall
    1168:	00000073          	ecall
 ret
    116c:	8082                	ret

000000000000116e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    116e:	48c9                	li	a7,18
 ecall
    1170:	00000073          	ecall
 ret
    1174:	8082                	ret

0000000000001176 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    1176:	48a1                	li	a7,8
 ecall
    1178:	00000073          	ecall
 ret
    117c:	8082                	ret

000000000000117e <link>:
.global link
link:
 li a7, SYS_link
    117e:	48cd                	li	a7,19
 ecall
    1180:	00000073          	ecall
 ret
    1184:	8082                	ret

0000000000001186 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    1186:	48d1                	li	a7,20
 ecall
    1188:	00000073          	ecall
 ret
    118c:	8082                	ret

000000000000118e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    118e:	48a5                	li	a7,9
 ecall
    1190:	00000073          	ecall
 ret
    1194:	8082                	ret

0000000000001196 <dup>:
.global dup
dup:
 li a7, SYS_dup
    1196:	48a9                	li	a7,10
 ecall
    1198:	00000073          	ecall
 ret
    119c:	8082                	ret

000000000000119e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    119e:	48ad                	li	a7,11
 ecall
    11a0:	00000073          	ecall
 ret
    11a4:	8082                	ret

00000000000011a6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    11a6:	48b1                	li	a7,12
 ecall
    11a8:	00000073          	ecall
 ret
    11ac:	8082                	ret

00000000000011ae <pause>:
.global pause
pause:
 li a7, SYS_pause
    11ae:	48b5                	li	a7,13
 ecall
    11b0:	00000073          	ecall
 ret
    11b4:	8082                	ret

00000000000011b6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    11b6:	48b9                	li	a7,14
 ecall
    11b8:	00000073          	ecall
 ret
    11bc:	8082                	ret

00000000000011be <csread>:
.global csread
csread:
 li a7, SYS_csread
    11be:	48d9                	li	a7,22
 ecall
    11c0:	00000073          	ecall
 ret
    11c4:	8082                	ret

00000000000011c6 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
    11c6:	48dd                	li	a7,23
 ecall
    11c8:	00000073          	ecall
 ret
    11cc:	8082                	ret

00000000000011ce <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
    11ce:	48e1                	li	a7,24
 ecall
    11d0:	00000073          	ecall
 ret
    11d4:	8082                	ret

00000000000011d6 <memread>:
.global memread
memread:
 li a7, SYS_memread
    11d6:	48e5                	li	a7,25
 ecall
    11d8:	00000073          	ecall
 ret
    11dc:	8082                	ret

00000000000011de <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
    11de:	48e9                	li	a7,26
 ecall
    11e0:	00000073          	ecall
 ret
    11e4:	8082                	ret

00000000000011e6 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
    11e6:	48ed                	li	a7,27
 ecall
    11e8:	00000073          	ecall
 ret
    11ec:	8082                	ret

00000000000011ee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    11ee:	1101                	addi	sp,sp,-32
    11f0:	ec06                	sd	ra,24(sp)
    11f2:	e822                	sd	s0,16(sp)
    11f4:	1000                	addi	s0,sp,32
    11f6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    11fa:	4605                	li	a2,1
    11fc:	fef40593          	addi	a1,s0,-17
    1200:	f3fff0ef          	jal	113e <write>
}
    1204:	60e2                	ld	ra,24(sp)
    1206:	6442                	ld	s0,16(sp)
    1208:	6105                	addi	sp,sp,32
    120a:	8082                	ret

000000000000120c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    120c:	715d                	addi	sp,sp,-80
    120e:	e486                	sd	ra,72(sp)
    1210:	e0a2                	sd	s0,64(sp)
    1212:	f84a                	sd	s2,48(sp)
    1214:	0880                	addi	s0,sp,80
    1216:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    1218:	c299                	beqz	a3,121e <printint+0x12>
    121a:	0805c363          	bltz	a1,12a0 <printint+0x94>
  neg = 0;
    121e:	4881                	li	a7,0
    1220:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    1224:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    1226:	00001517          	auipc	a0,0x1
    122a:	82a50513          	addi	a0,a0,-2006 # 1a50 <digits>
    122e:	883e                	mv	a6,a5
    1230:	2785                	addiw	a5,a5,1
    1232:	02c5f733          	remu	a4,a1,a2
    1236:	972a                	add	a4,a4,a0
    1238:	00074703          	lbu	a4,0(a4)
    123c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    1240:	872e                	mv	a4,a1
    1242:	02c5d5b3          	divu	a1,a1,a2
    1246:	0685                	addi	a3,a3,1
    1248:	fec773e3          	bgeu	a4,a2,122e <printint+0x22>
  if(neg)
    124c:	00088b63          	beqz	a7,1262 <printint+0x56>
    buf[i++] = '-';
    1250:	fd078793          	addi	a5,a5,-48
    1254:	97a2                	add	a5,a5,s0
    1256:	02d00713          	li	a4,45
    125a:	fee78423          	sb	a4,-24(a5)
    125e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    1262:	02f05a63          	blez	a5,1296 <printint+0x8a>
    1266:	fc26                	sd	s1,56(sp)
    1268:	f44e                	sd	s3,40(sp)
    126a:	fb840713          	addi	a4,s0,-72
    126e:	00f704b3          	add	s1,a4,a5
    1272:	fff70993          	addi	s3,a4,-1
    1276:	99be                	add	s3,s3,a5
    1278:	37fd                	addiw	a5,a5,-1
    127a:	1782                	slli	a5,a5,0x20
    127c:	9381                	srli	a5,a5,0x20
    127e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    1282:	fff4c583          	lbu	a1,-1(s1)
    1286:	854a                	mv	a0,s2
    1288:	f67ff0ef          	jal	11ee <putc>
  while(--i >= 0)
    128c:	14fd                	addi	s1,s1,-1
    128e:	ff349ae3          	bne	s1,s3,1282 <printint+0x76>
    1292:	74e2                	ld	s1,56(sp)
    1294:	79a2                	ld	s3,40(sp)
}
    1296:	60a6                	ld	ra,72(sp)
    1298:	6406                	ld	s0,64(sp)
    129a:	7942                	ld	s2,48(sp)
    129c:	6161                	addi	sp,sp,80
    129e:	8082                	ret
    x = -xx;
    12a0:	40b005b3          	neg	a1,a1
    neg = 1;
    12a4:	4885                	li	a7,1
    x = -xx;
    12a6:	bfad                	j	1220 <printint+0x14>

00000000000012a8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    12a8:	711d                	addi	sp,sp,-96
    12aa:	ec86                	sd	ra,88(sp)
    12ac:	e8a2                	sd	s0,80(sp)
    12ae:	e0ca                	sd	s2,64(sp)
    12b0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    12b2:	0005c903          	lbu	s2,0(a1)
    12b6:	28090663          	beqz	s2,1542 <vprintf+0x29a>
    12ba:	e4a6                	sd	s1,72(sp)
    12bc:	fc4e                	sd	s3,56(sp)
    12be:	f852                	sd	s4,48(sp)
    12c0:	f456                	sd	s5,40(sp)
    12c2:	f05a                	sd	s6,32(sp)
    12c4:	ec5e                	sd	s7,24(sp)
    12c6:	e862                	sd	s8,16(sp)
    12c8:	e466                	sd	s9,8(sp)
    12ca:	8b2a                	mv	s6,a0
    12cc:	8a2e                	mv	s4,a1
    12ce:	8bb2                	mv	s7,a2
  state = 0;
    12d0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    12d2:	4481                	li	s1,0
    12d4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    12d6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    12da:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    12de:	06c00c93          	li	s9,108
    12e2:	a005                	j	1302 <vprintf+0x5a>
        putc(fd, c0);
    12e4:	85ca                	mv	a1,s2
    12e6:	855a                	mv	a0,s6
    12e8:	f07ff0ef          	jal	11ee <putc>
    12ec:	a019                	j	12f2 <vprintf+0x4a>
    } else if(state == '%'){
    12ee:	03598263          	beq	s3,s5,1312 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
    12f2:	2485                	addiw	s1,s1,1
    12f4:	8726                	mv	a4,s1
    12f6:	009a07b3          	add	a5,s4,s1
    12fa:	0007c903          	lbu	s2,0(a5)
    12fe:	22090a63          	beqz	s2,1532 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
    1302:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1306:	fe0994e3          	bnez	s3,12ee <vprintf+0x46>
      if(c0 == '%'){
    130a:	fd579de3          	bne	a5,s5,12e4 <vprintf+0x3c>
        state = '%';
    130e:	89be                	mv	s3,a5
    1310:	b7cd                	j	12f2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    1312:	00ea06b3          	add	a3,s4,a4
    1316:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    131a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    131c:	c681                	beqz	a3,1324 <vprintf+0x7c>
    131e:	9752                	add	a4,a4,s4
    1320:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    1324:	05878363          	beq	a5,s8,136a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
    1328:	05978d63          	beq	a5,s9,1382 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    132c:	07500713          	li	a4,117
    1330:	0ee78763          	beq	a5,a4,141e <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    1334:	07800713          	li	a4,120
    1338:	12e78963          	beq	a5,a4,146a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    133c:	07000713          	li	a4,112
    1340:	14e78e63          	beq	a5,a4,149c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
    1344:	06300713          	li	a4,99
    1348:	18e78e63          	beq	a5,a4,14e4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
    134c:	07300713          	li	a4,115
    1350:	1ae78463          	beq	a5,a4,14f8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    1354:	02500713          	li	a4,37
    1358:	04e79563          	bne	a5,a4,13a2 <vprintf+0xfa>
        putc(fd, '%');
    135c:	02500593          	li	a1,37
    1360:	855a                	mv	a0,s6
    1362:	e8dff0ef          	jal	11ee <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    1366:	4981                	li	s3,0
    1368:	b769                	j	12f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    136a:	008b8913          	addi	s2,s7,8
    136e:	4685                	li	a3,1
    1370:	4629                	li	a2,10
    1372:	000ba583          	lw	a1,0(s7)
    1376:	855a                	mv	a0,s6
    1378:	e95ff0ef          	jal	120c <printint>
    137c:	8bca                	mv	s7,s2
      state = 0;
    137e:	4981                	li	s3,0
    1380:	bf8d                	j	12f2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    1382:	06400793          	li	a5,100
    1386:	02f68963          	beq	a3,a5,13b8 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    138a:	06c00793          	li	a5,108
    138e:	04f68263          	beq	a3,a5,13d2 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
    1392:	07500793          	li	a5,117
    1396:	0af68063          	beq	a3,a5,1436 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
    139a:	07800793          	li	a5,120
    139e:	0ef68263          	beq	a3,a5,1482 <vprintf+0x1da>
        putc(fd, '%');
    13a2:	02500593          	li	a1,37
    13a6:	855a                	mv	a0,s6
    13a8:	e47ff0ef          	jal	11ee <putc>
        putc(fd, c0);
    13ac:	85ca                	mv	a1,s2
    13ae:	855a                	mv	a0,s6
    13b0:	e3fff0ef          	jal	11ee <putc>
      state = 0;
    13b4:	4981                	li	s3,0
    13b6:	bf35                	j	12f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    13b8:	008b8913          	addi	s2,s7,8
    13bc:	4685                	li	a3,1
    13be:	4629                	li	a2,10
    13c0:	000bb583          	ld	a1,0(s7)
    13c4:	855a                	mv	a0,s6
    13c6:	e47ff0ef          	jal	120c <printint>
        i += 1;
    13ca:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    13cc:	8bca                	mv	s7,s2
      state = 0;
    13ce:	4981                	li	s3,0
        i += 1;
    13d0:	b70d                	j	12f2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    13d2:	06400793          	li	a5,100
    13d6:	02f60763          	beq	a2,a5,1404 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    13da:	07500793          	li	a5,117
    13de:	06f60963          	beq	a2,a5,1450 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    13e2:	07800793          	li	a5,120
    13e6:	faf61ee3          	bne	a2,a5,13a2 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    13ea:	008b8913          	addi	s2,s7,8
    13ee:	4681                	li	a3,0
    13f0:	4641                	li	a2,16
    13f2:	000bb583          	ld	a1,0(s7)
    13f6:	855a                	mv	a0,s6
    13f8:	e15ff0ef          	jal	120c <printint>
        i += 2;
    13fc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    13fe:	8bca                	mv	s7,s2
      state = 0;
    1400:	4981                	li	s3,0
        i += 2;
    1402:	bdc5                	j	12f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1404:	008b8913          	addi	s2,s7,8
    1408:	4685                	li	a3,1
    140a:	4629                	li	a2,10
    140c:	000bb583          	ld	a1,0(s7)
    1410:	855a                	mv	a0,s6
    1412:	dfbff0ef          	jal	120c <printint>
        i += 2;
    1416:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    1418:	8bca                	mv	s7,s2
      state = 0;
    141a:	4981                	li	s3,0
        i += 2;
    141c:	bdd9                	j	12f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    141e:	008b8913          	addi	s2,s7,8
    1422:	4681                	li	a3,0
    1424:	4629                	li	a2,10
    1426:	000be583          	lwu	a1,0(s7)
    142a:	855a                	mv	a0,s6
    142c:	de1ff0ef          	jal	120c <printint>
    1430:	8bca                	mv	s7,s2
      state = 0;
    1432:	4981                	li	s3,0
    1434:	bd7d                	j	12f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1436:	008b8913          	addi	s2,s7,8
    143a:	4681                	li	a3,0
    143c:	4629                	li	a2,10
    143e:	000bb583          	ld	a1,0(s7)
    1442:	855a                	mv	a0,s6
    1444:	dc9ff0ef          	jal	120c <printint>
        i += 1;
    1448:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    144a:	8bca                	mv	s7,s2
      state = 0;
    144c:	4981                	li	s3,0
        i += 1;
    144e:	b555                	j	12f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1450:	008b8913          	addi	s2,s7,8
    1454:	4681                	li	a3,0
    1456:	4629                	li	a2,10
    1458:	000bb583          	ld	a1,0(s7)
    145c:	855a                	mv	a0,s6
    145e:	dafff0ef          	jal	120c <printint>
        i += 2;
    1462:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    1464:	8bca                	mv	s7,s2
      state = 0;
    1466:	4981                	li	s3,0
        i += 2;
    1468:	b569                	j	12f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    146a:	008b8913          	addi	s2,s7,8
    146e:	4681                	li	a3,0
    1470:	4641                	li	a2,16
    1472:	000be583          	lwu	a1,0(s7)
    1476:	855a                	mv	a0,s6
    1478:	d95ff0ef          	jal	120c <printint>
    147c:	8bca                	mv	s7,s2
      state = 0;
    147e:	4981                	li	s3,0
    1480:	bd8d                	j	12f2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    1482:	008b8913          	addi	s2,s7,8
    1486:	4681                	li	a3,0
    1488:	4641                	li	a2,16
    148a:	000bb583          	ld	a1,0(s7)
    148e:	855a                	mv	a0,s6
    1490:	d7dff0ef          	jal	120c <printint>
        i += 1;
    1494:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    1496:	8bca                	mv	s7,s2
      state = 0;
    1498:	4981                	li	s3,0
        i += 1;
    149a:	bda1                	j	12f2 <vprintf+0x4a>
    149c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    149e:	008b8d13          	addi	s10,s7,8
    14a2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    14a6:	03000593          	li	a1,48
    14aa:	855a                	mv	a0,s6
    14ac:	d43ff0ef          	jal	11ee <putc>
  putc(fd, 'x');
    14b0:	07800593          	li	a1,120
    14b4:	855a                	mv	a0,s6
    14b6:	d39ff0ef          	jal	11ee <putc>
    14ba:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    14bc:	00000b97          	auipc	s7,0x0
    14c0:	594b8b93          	addi	s7,s7,1428 # 1a50 <digits>
    14c4:	03c9d793          	srli	a5,s3,0x3c
    14c8:	97de                	add	a5,a5,s7
    14ca:	0007c583          	lbu	a1,0(a5)
    14ce:	855a                	mv	a0,s6
    14d0:	d1fff0ef          	jal	11ee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    14d4:	0992                	slli	s3,s3,0x4
    14d6:	397d                	addiw	s2,s2,-1
    14d8:	fe0916e3          	bnez	s2,14c4 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
    14dc:	8bea                	mv	s7,s10
      state = 0;
    14de:	4981                	li	s3,0
    14e0:	6d02                	ld	s10,0(sp)
    14e2:	bd01                	j	12f2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
    14e4:	008b8913          	addi	s2,s7,8
    14e8:	000bc583          	lbu	a1,0(s7)
    14ec:	855a                	mv	a0,s6
    14ee:	d01ff0ef          	jal	11ee <putc>
    14f2:	8bca                	mv	s7,s2
      state = 0;
    14f4:	4981                	li	s3,0
    14f6:	bbf5                	j	12f2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    14f8:	008b8993          	addi	s3,s7,8
    14fc:	000bb903          	ld	s2,0(s7)
    1500:	00090f63          	beqz	s2,151e <vprintf+0x276>
        for(; *s; s++)
    1504:	00094583          	lbu	a1,0(s2)
    1508:	c195                	beqz	a1,152c <vprintf+0x284>
          putc(fd, *s);
    150a:	855a                	mv	a0,s6
    150c:	ce3ff0ef          	jal	11ee <putc>
        for(; *s; s++)
    1510:	0905                	addi	s2,s2,1
    1512:	00094583          	lbu	a1,0(s2)
    1516:	f9f5                	bnez	a1,150a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    1518:	8bce                	mv	s7,s3
      state = 0;
    151a:	4981                	li	s3,0
    151c:	bbd9                	j	12f2 <vprintf+0x4a>
          s = "(null)";
    151e:	00000917          	auipc	s2,0x0
    1522:	4ea90913          	addi	s2,s2,1258 # 1a08 <malloc+0x3de>
        for(; *s; s++)
    1526:	02800593          	li	a1,40
    152a:	b7c5                	j	150a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    152c:	8bce                	mv	s7,s3
      state = 0;
    152e:	4981                	li	s3,0
    1530:	b3c9                	j	12f2 <vprintf+0x4a>
    1532:	64a6                	ld	s1,72(sp)
    1534:	79e2                	ld	s3,56(sp)
    1536:	7a42                	ld	s4,48(sp)
    1538:	7aa2                	ld	s5,40(sp)
    153a:	7b02                	ld	s6,32(sp)
    153c:	6be2                	ld	s7,24(sp)
    153e:	6c42                	ld	s8,16(sp)
    1540:	6ca2                	ld	s9,8(sp)
    }
  }
}
    1542:	60e6                	ld	ra,88(sp)
    1544:	6446                	ld	s0,80(sp)
    1546:	6906                	ld	s2,64(sp)
    1548:	6125                	addi	sp,sp,96
    154a:	8082                	ret

000000000000154c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    154c:	715d                	addi	sp,sp,-80
    154e:	ec06                	sd	ra,24(sp)
    1550:	e822                	sd	s0,16(sp)
    1552:	1000                	addi	s0,sp,32
    1554:	e010                	sd	a2,0(s0)
    1556:	e414                	sd	a3,8(s0)
    1558:	e818                	sd	a4,16(s0)
    155a:	ec1c                	sd	a5,24(s0)
    155c:	03043023          	sd	a6,32(s0)
    1560:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1564:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1568:	8622                	mv	a2,s0
    156a:	d3fff0ef          	jal	12a8 <vprintf>
}
    156e:	60e2                	ld	ra,24(sp)
    1570:	6442                	ld	s0,16(sp)
    1572:	6161                	addi	sp,sp,80
    1574:	8082                	ret

0000000000001576 <printf>:

void
printf(const char *fmt, ...)
{
    1576:	711d                	addi	sp,sp,-96
    1578:	ec06                	sd	ra,24(sp)
    157a:	e822                	sd	s0,16(sp)
    157c:	1000                	addi	s0,sp,32
    157e:	e40c                	sd	a1,8(s0)
    1580:	e810                	sd	a2,16(s0)
    1582:	ec14                	sd	a3,24(s0)
    1584:	f018                	sd	a4,32(s0)
    1586:	f41c                	sd	a5,40(s0)
    1588:	03043823          	sd	a6,48(s0)
    158c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1590:	00840613          	addi	a2,s0,8
    1594:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1598:	85aa                	mv	a1,a0
    159a:	4505                	li	a0,1
    159c:	d0dff0ef          	jal	12a8 <vprintf>
}
    15a0:	60e2                	ld	ra,24(sp)
    15a2:	6442                	ld	s0,16(sp)
    15a4:	6125                	addi	sp,sp,96
    15a6:	8082                	ret

00000000000015a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15a8:	1141                	addi	sp,sp,-16
    15aa:	e422                	sd	s0,8(sp)
    15ac:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15ae:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15b2:	00001797          	auipc	a5,0x1
    15b6:	a4e7b783          	ld	a5,-1458(a5) # 2000 <freep>
    15ba:	a02d                	j	15e4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    15bc:	4618                	lw	a4,8(a2)
    15be:	9f2d                	addw	a4,a4,a1
    15c0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    15c4:	6398                	ld	a4,0(a5)
    15c6:	6310                	ld	a2,0(a4)
    15c8:	a83d                	j	1606 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    15ca:	ff852703          	lw	a4,-8(a0)
    15ce:	9f31                	addw	a4,a4,a2
    15d0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    15d2:	ff053683          	ld	a3,-16(a0)
    15d6:	a091                	j	161a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15d8:	6398                	ld	a4,0(a5)
    15da:	00e7e463          	bltu	a5,a4,15e2 <free+0x3a>
    15de:	00e6ea63          	bltu	a3,a4,15f2 <free+0x4a>
{
    15e2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15e4:	fed7fae3          	bgeu	a5,a3,15d8 <free+0x30>
    15e8:	6398                	ld	a4,0(a5)
    15ea:	00e6e463          	bltu	a3,a4,15f2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15ee:	fee7eae3          	bltu	a5,a4,15e2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    15f2:	ff852583          	lw	a1,-8(a0)
    15f6:	6390                	ld	a2,0(a5)
    15f8:	02059813          	slli	a6,a1,0x20
    15fc:	01c85713          	srli	a4,a6,0x1c
    1600:	9736                	add	a4,a4,a3
    1602:	fae60de3          	beq	a2,a4,15bc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1606:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    160a:	4790                	lw	a2,8(a5)
    160c:	02061593          	slli	a1,a2,0x20
    1610:	01c5d713          	srli	a4,a1,0x1c
    1614:	973e                	add	a4,a4,a5
    1616:	fae68ae3          	beq	a3,a4,15ca <free+0x22>
    p->s.ptr = bp->s.ptr;
    161a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    161c:	00001717          	auipc	a4,0x1
    1620:	9ef73223          	sd	a5,-1564(a4) # 2000 <freep>
}
    1624:	6422                	ld	s0,8(sp)
    1626:	0141                	addi	sp,sp,16
    1628:	8082                	ret

000000000000162a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    162a:	7139                	addi	sp,sp,-64
    162c:	fc06                	sd	ra,56(sp)
    162e:	f822                	sd	s0,48(sp)
    1630:	f426                	sd	s1,40(sp)
    1632:	ec4e                	sd	s3,24(sp)
    1634:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1636:	02051493          	slli	s1,a0,0x20
    163a:	9081                	srli	s1,s1,0x20
    163c:	04bd                	addi	s1,s1,15
    163e:	8091                	srli	s1,s1,0x4
    1640:	0014899b          	addiw	s3,s1,1
    1644:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1646:	00001517          	auipc	a0,0x1
    164a:	9ba53503          	ld	a0,-1606(a0) # 2000 <freep>
    164e:	c915                	beqz	a0,1682 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1650:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1652:	4798                	lw	a4,8(a5)
    1654:	08977a63          	bgeu	a4,s1,16e8 <malloc+0xbe>
    1658:	f04a                	sd	s2,32(sp)
    165a:	e852                	sd	s4,16(sp)
    165c:	e456                	sd	s5,8(sp)
    165e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1660:	8a4e                	mv	s4,s3
    1662:	0009871b          	sext.w	a4,s3
    1666:	6685                	lui	a3,0x1
    1668:	00d77363          	bgeu	a4,a3,166e <malloc+0x44>
    166c:	6a05                	lui	s4,0x1
    166e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1672:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1676:	00001917          	auipc	s2,0x1
    167a:	98a90913          	addi	s2,s2,-1654 # 2000 <freep>
  if(p == SBRK_ERROR)
    167e:	5afd                	li	s5,-1
    1680:	a081                	j	16c0 <malloc+0x96>
    1682:	f04a                	sd	s2,32(sp)
    1684:	e852                	sd	s4,16(sp)
    1686:	e456                	sd	s5,8(sp)
    1688:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    168a:	00003797          	auipc	a5,0x3
    168e:	98678793          	addi	a5,a5,-1658 # 4010 <base>
    1692:	00001717          	auipc	a4,0x1
    1696:	96f73723          	sd	a5,-1682(a4) # 2000 <freep>
    169a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    169c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    16a0:	b7c1                	j	1660 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    16a2:	6398                	ld	a4,0(a5)
    16a4:	e118                	sd	a4,0(a0)
    16a6:	a8a9                	j	1700 <malloc+0xd6>
  hp->s.size = nu;
    16a8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    16ac:	0541                	addi	a0,a0,16
    16ae:	efbff0ef          	jal	15a8 <free>
  return freep;
    16b2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    16b6:	c12d                	beqz	a0,1718 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    16b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    16ba:	4798                	lw	a4,8(a5)
    16bc:	02977263          	bgeu	a4,s1,16e0 <malloc+0xb6>
    if(p == freep)
    16c0:	00093703          	ld	a4,0(s2)
    16c4:	853e                	mv	a0,a5
    16c6:	fef719e3          	bne	a4,a5,16b8 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    16ca:	8552                	mv	a0,s4
    16cc:	a1fff0ef          	jal	10ea <sbrk>
  if(p == SBRK_ERROR)
    16d0:	fd551ce3          	bne	a0,s5,16a8 <malloc+0x7e>
        return 0;
    16d4:	4501                	li	a0,0
    16d6:	7902                	ld	s2,32(sp)
    16d8:	6a42                	ld	s4,16(sp)
    16da:	6aa2                	ld	s5,8(sp)
    16dc:	6b02                	ld	s6,0(sp)
    16de:	a03d                	j	170c <malloc+0xe2>
    16e0:	7902                	ld	s2,32(sp)
    16e2:	6a42                	ld	s4,16(sp)
    16e4:	6aa2                	ld	s5,8(sp)
    16e6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    16e8:	fae48de3          	beq	s1,a4,16a2 <malloc+0x78>
        p->s.size -= nunits;
    16ec:	4137073b          	subw	a4,a4,s3
    16f0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    16f2:	02071693          	slli	a3,a4,0x20
    16f6:	01c6d713          	srli	a4,a3,0x1c
    16fa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    16fc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1700:	00001717          	auipc	a4,0x1
    1704:	90a73023          	sd	a0,-1792(a4) # 2000 <freep>
      return (void*)(p + 1);
    1708:	01078513          	addi	a0,a5,16
  }
}
    170c:	70e2                	ld	ra,56(sp)
    170e:	7442                	ld	s0,48(sp)
    1710:	74a2                	ld	s1,40(sp)
    1712:	69e2                	ld	s3,24(sp)
    1714:	6121                	addi	sp,sp,64
    1716:	8082                	ret
    1718:	7902                	ld	s2,32(sp)
    171a:	6a42                	ld	s4,16(sp)
    171c:	6aa2                	ld	s5,8(sp)
    171e:	6b02                	ld	s6,0(sp)
    1720:	b7f5                	j	170c <malloc+0xe2>
