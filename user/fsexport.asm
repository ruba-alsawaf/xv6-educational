
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
     116:	63e60613          	addi	a2,a2,1598 # 1750 <malloc+0xf8>
     11a:	ee7ff0ef          	jal	0 <append_str>
        append_str(buf, pos, name);
     11e:	8656                	mv	a2,s5
     120:	85ca                	mv	a1,s2
     122:	8526                	mv	a0,s1
     124:	eddff0ef          	jal	0 <append_str>
        append_str(buf, pos, "\":\"");
     128:	00001617          	auipc	a2,0x1
     12c:	63060613          	addi	a2,a2,1584 # 1758 <malloc+0x100>
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
     146:	61e60613          	addi	a2,a2,1566 # 1760 <malloc+0x108>
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
     160:	60c60613          	addi	a2,a2,1548 # 1768 <malloc+0x110>
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
     1a0:	5d460613          	addi	a2,a2,1492 # 1770 <malloc+0x118>
     1a4:	bbc40593          	addi	a1,s0,-1092
     1a8:	bc040513          	addi	a0,s0,-1088
     1ac:	e55ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"seq\":");
     1b0:	00001617          	auipc	a2,0x1
     1b4:	5c860613          	addi	a2,a2,1480 # 1778 <malloc+0x120>
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
     1d6:	5ae60613          	addi	a2,a2,1454 # 1780 <malloc+0x128>
     1da:	bbc40593          	addi	a1,s0,-1092
     1de:	bc040513          	addi	a0,s0,-1088
     1e2:	e1fff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "\"tick\":"); append_uint(buf, &pos, e->ticks);
     1e6:	00001617          	auipc	a2,0x1
     1ea:	5a260613          	addi	a2,a2,1442 # 1788 <malloc+0x130>
     1ee:	bbc40593          	addi	a1,s0,-1092
     1f2:	bc040513          	addi	a0,s0,-1088
     1f6:	e0bff0ef          	jal	0 <append_str>
     1fa:	4490                	lw	a2,8(s1)
     1fc:	bbc40593          	addi	a1,s0,-1092
     200:	bc040513          	addi	a0,s0,-1088
     204:	e31ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"pid\":"); append_int(buf, &pos, e->pid);
     208:	00001617          	auipc	a2,0x1
     20c:	58860613          	addi	a2,a2,1416 # 1790 <malloc+0x138>
     210:	bbc40593          	addi	a1,s0,-1092
     214:	bc040513          	addi	a0,s0,-1088
     218:	de9ff0ef          	jal	0 <append_str>
     21c:	44d0                	lw	a2,12(s1)
     21e:	bbc40593          	addi	a1,s0,-1092
     222:	bc040513          	addi	a0,s0,-1088
     226:	e93ff0ef          	jal	b8 <append_int>

    append_str(buf, &pos, ",\"layer\":\"");
     22a:	00001617          	auipc	a2,0x1
     22e:	56e60613          	addi	a2,a2,1390 # 1798 <malloc+0x140>
     232:	bbc40593          	addi	a1,s0,-1092
     236:	bc040513          	addi	a0,s0,-1088
     23a:	dc7ff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE)
     23e:	0104a903          	lw	s2,16(s1)
     242:	479d                	li	a5,7
     244:	3327e3e3          	bltu	a5,s2,d6a <print_fs_event+0xbec>
     248:	00291793          	slli	a5,s2,0x2
     24c:	00001717          	auipc	a4,0x1
     250:	7e470713          	addi	a4,a4,2020 # 1a30 <malloc+0x3d8>
     254:	97ba                	add	a5,a5,a4
     256:	439c                	lw	a5,0(a5)
     258:	97ba                	add	a5,a5,a4
     25a:	8782                	jr	a5
     25c:	43313423          	sd	s3,1064(sp)
    append_str(buf, &pos, "BCACHE");
     260:	00001617          	auipc	a2,0x1
     264:	54860613          	addi	a2,a2,1352 # 17a8 <malloc+0x150>
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
     278:	4dc60613          	addi	a2,a2,1244 # 1750 <malloc+0xf8>
     27c:	bbc40593          	addi	a1,s0,-1092
     280:	bc040513          	addi	a0,s0,-1088
     284:	d7dff0ef          	jal	0 <append_str>

    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     288:	00001617          	auipc	a2,0x1
     28c:	52860613          	addi	a2,a2,1320 # 17b0 <malloc+0x158>
     290:	bbc40593          	addi	a1,s0,-1092
     294:	bc040513          	addi	a0,s0,-1088
     298:	d69ff0ef          	jal	0 <append_str>
     29c:	01448613          	addi	a2,s1,20
     2a0:	bbc40593          	addi	a1,s0,-1092
     2a4:	bc040513          	addi	a0,s0,-1088
     2a8:	d59ff0ef          	jal	0 <append_str>
     2ac:	00001617          	auipc	a2,0x1
     2b0:	4a460613          	addi	a2,a2,1188 # 1750 <malloc+0xf8>
     2b4:	bbc40593          	addi	a1,s0,-1092
     2b8:	bc040513          	addi	a0,s0,-1088
     2bc:	d45ff0ef          	jal	0 <append_str>

    // ===== BCACHE =====
    if(e->type == LAYER_BCACHE){

        append_str(buf, &pos, ",\"buf\":{");
     2c0:	00001617          	auipc	a2,0x1
     2c4:	52860613          	addi	a2,a2,1320 # 17e8 <malloc+0x190>
     2c8:	bbc40593          	addi	a1,s0,-1092
     2cc:	bc040513          	addi	a0,s0,-1088
     2d0:	d31ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"id\":"); append_int(buf, &pos, e->bcache.buf_id);
     2d4:	00001617          	auipc	a2,0x1
     2d8:	52460613          	addi	a2,a2,1316 # 17f8 <malloc+0x1a0>
     2dc:	bbc40593          	addi	a1,s0,-1092
     2e0:	bc040513          	addi	a0,s0,-1088
     2e4:	d1dff0ef          	jal	0 <append_str>
     2e8:	1604a603          	lw	a2,352(s1)
     2ec:	bbc40593          	addi	a1,s0,-1092
     2f0:	bc040513          	addi	a0,s0,-1088
     2f4:	dc5ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"block\":"); append_int(buf, &pos, e->bcache.blockno);
     2f8:	00001617          	auipc	a2,0x1
     2fc:	50860613          	addi	a2,a2,1288 # 1800 <malloc+0x1a8>
     300:	bbc40593          	addi	a1,s0,-1092
     304:	bc040513          	addi	a0,s0,-1088
     308:	cf9ff0ef          	jal	0 <append_str>
     30c:	1644a603          	lw	a2,356(s1)
     310:	bbc40593          	addi	a1,s0,-1092
     314:	bc040513          	addi	a0,s0,-1088
     318:	da1ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, "}");
     31c:	00001617          	auipc	a2,0x1
     320:	4f460613          	addi	a2,a2,1268 # 1810 <malloc+0x1b8>
     324:	bbc40593          	addi	a1,s0,-1092
     328:	bc040513          	addi	a0,s0,-1088
     32c:	cd5ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"state\":{" );
     330:	00001617          	auipc	a2,0x1
     334:	4e860613          	addi	a2,a2,1256 # 1818 <malloc+0x1c0>
     338:	bbc40593          	addi	a1,s0,-1092
     33c:	bc040513          	addi	a0,s0,-1088
     340:	cc1ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->bcache.refcnt);
     344:	00001617          	auipc	a2,0x1
     348:	4e460613          	addi	a2,a2,1252 # 1828 <malloc+0x1d0>
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
     36e:	4c660613          	addi	a2,a2,1222 # 1830 <malloc+0x1d8>
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
     394:	48060613          	addi	a2,a2,1152 # 1810 <malloc+0x1b8>
     398:	bbc40593          	addi	a1,s0,-1092
     39c:	bc040513          	addi	a0,s0,-1088
     3a0:	c61ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"changes\":{" );
     3a4:	00001617          	auipc	a2,0x1
     3a8:	49c60613          	addi	a2,a2,1180 # 1840 <malloc+0x1e8>
     3ac:	bbc40593          	addi	a1,s0,-1092
     3b0:	bc040513          	addi	a0,s0,-1088
     3b4:	c4dff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "ref", e->bcache.old_refcnt, e->bcache.refcnt);
     3b8:	874e                	mv	a4,s3
     3ba:	16c4a683          	lw	a3,364(s1)
     3be:	00001617          	auipc	a2,0x1
     3c2:	49260613          	addi	a2,a2,1170 # 1850 <malloc+0x1f8>
     3c6:	bbc40593          	addi	a1,s0,-1092
     3ca:	bc040513          	addi	a0,s0,-1088
     3ce:	d23ff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "valid", e->bcache.old_valid, e->bcache.valid);
     3d2:	874a                	mv	a4,s2
     3d4:	1744a683          	lw	a3,372(s1)
     3d8:	00001617          	auipc	a2,0x1
     3dc:	48060613          	addi	a2,a2,1152 # 1858 <malloc+0x200>
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
     40c:	40860613          	addi	a2,a2,1032 # 1810 <malloc+0x1b8>
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
     424:	5a860613          	addi	a2,a2,1448 # 19c8 <malloc+0x370>
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
     448:	30c60613          	addi	a2,a2,780 # 1750 <malloc+0xf8>
     44c:	bbc40593          	addi	a1,s0,-1092
     450:	bc040513          	addi	a0,s0,-1088
     454:	badff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "}\n");
     458:	00001617          	auipc	a2,0x1
     45c:	58060613          	addi	a2,a2,1408 # 19d8 <malloc+0x380>
     460:	bbc40593          	addi	a1,s0,-1092
     464:	bc040513          	addi	a0,s0,-1088
     468:	b99ff0ef          	jal	0 <append_str>

    write(1, buf, pos);
     46c:	bbc42603          	lw	a2,-1092(s0)
     470:	bc040593          	addi	a1,s0,-1088
     474:	4505                	li	a0,1
     476:	507000ef          	jal	117c <write>
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
     49c:	32060613          	addi	a2,a2,800 # 17b8 <malloc+0x160>
     4a0:	bbc40593          	addi	a1,s0,-1092
     4a4:	bc040513          	addi	a0,s0,-1088
     4a8:	b59ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     4ac:	00001617          	auipc	a2,0x1
     4b0:	2a460613          	addi	a2,a2,676 # 1750 <malloc+0xf8>
     4b4:	bbc40593          	addi	a1,s0,-1092
     4b8:	bc040513          	addi	a0,s0,-1088
     4bc:	b45ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     4c0:	00001617          	auipc	a2,0x1
     4c4:	2f060613          	addi	a2,a2,752 # 17b0 <malloc+0x158>
     4c8:	bbc40593          	addi	a1,s0,-1092
     4cc:	bc040513          	addi	a0,s0,-1088
     4d0:	b31ff0ef          	jal	0 <append_str>
     4d4:	01448613          	addi	a2,s1,20
     4d8:	bbc40593          	addi	a1,s0,-1092
     4dc:	bc040513          	addi	a0,s0,-1088
     4e0:	b21ff0ef          	jal	0 <append_str>
     4e4:	00001617          	auipc	a2,0x1
     4e8:	26c60613          	addi	a2,a2,620 # 1750 <malloc+0xf8>
     4ec:	bbc40593          	addi	a1,s0,-1092
     4f0:	bc040513          	addi	a0,s0,-1088
     4f4:	b0dff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"state\":{");
     4f8:	00001617          	auipc	a2,0x1
     4fc:	32060613          	addi	a2,a2,800 # 1818 <malloc+0x1c0>
     500:	bbc40593          	addi	a1,s0,-1092
     504:	bc040513          	addi	a0,s0,-1088
     508:	af9ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"log_n\":"); append_int(buf, &pos, e->log_n);
     50c:	00001617          	auipc	a2,0x1
     510:	35460613          	addi	a2,a2,852 # 1860 <malloc+0x208>
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
     536:	33e60613          	addi	a2,a2,830 # 1870 <malloc+0x218>
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
     55c:	32860613          	addi	a2,a2,808 # 1880 <malloc+0x228>
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
     582:	29260613          	addi	a2,a2,658 # 1810 <malloc+0x1b8>
     586:	bbc40593          	addi	a1,s0,-1092
     58a:	bc040513          	addi	a0,s0,-1088
     58e:	a73ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"changes\":{");
     592:	00001617          	auipc	a2,0x1
     596:	2ae60613          	addi	a2,a2,686 # 1840 <malloc+0x1e8>
     59a:	bbc40593          	addi	a1,s0,-1092
     59e:	bc040513          	addi	a0,s0,-1088
     5a2:	a5fff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "log_n", e->old_log_n, e->log_n);
     5a6:	8752                	mv	a4,s4
     5a8:	1144a683          	lw	a3,276(s1)
     5ac:	00001617          	auipc	a2,0x1
     5b0:	2e460613          	addi	a2,a2,740 # 1890 <malloc+0x238>
     5b4:	bbc40593          	addi	a1,s0,-1092
     5b8:	bc040513          	addi	a0,s0,-1088
     5bc:	b35ff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "outstanding", e->old_outstanding, e->outstanding);
     5c0:	874e                	mv	a4,s3
     5c2:	1184a683          	lw	a3,280(s1)
     5c6:	00001617          	auipc	a2,0x1
     5ca:	2d260613          	addi	a2,a2,722 # 1898 <malloc+0x240>
     5ce:	bbc40593          	addi	a1,s0,-1092
     5d2:	bc040513          	addi	a0,s0,-1088
     5d6:	b1bff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "committing", e->old_committing, e->committing);
     5da:	874a                	mv	a4,s2
     5dc:	11c4a683          	lw	a3,284(s1)
     5e0:	00001617          	auipc	a2,0x1
     5e4:	2c860613          	addi	a2,a2,712 # 18a8 <malloc+0x250>
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
     614:	20060613          	addi	a2,a2,512 # 1810 <malloc+0x1b8>
     618:	bbc40593          	addi	a1,s0,-1092
     61c:	bc040513          	addi	a0,s0,-1088
     620:	9e1ff0ef          	jal	0 <append_str>
     624:	42813983          	ld	s3,1064(sp)
     628:	42013a03          	ld	s4,1056(sp)
     62c:	bbd5                	j	420 <print_fs_event+0x2a2>
    append_str(buf, &pos, "BALLOC");
     62e:	00001617          	auipc	a2,0x1
     632:	19260613          	addi	a2,a2,402 # 17c0 <malloc+0x168>
     636:	bbc40593          	addi	a1,s0,-1092
     63a:	bc040513          	addi	a0,s0,-1088
     63e:	9c3ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     642:	00001617          	auipc	a2,0x1
     646:	10e60613          	addi	a2,a2,270 # 1750 <malloc+0xf8>
     64a:	bbc40593          	addi	a1,s0,-1092
     64e:	bc040513          	addi	a0,s0,-1088
     652:	9afff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     656:	00001617          	auipc	a2,0x1
     65a:	15a60613          	addi	a2,a2,346 # 17b0 <malloc+0x158>
     65e:	bbc40593          	addi	a1,s0,-1092
     662:	bc040513          	addi	a0,s0,-1088
     666:	99bff0ef          	jal	0 <append_str>
     66a:	01448613          	addi	a2,s1,20
     66e:	bbc40593          	addi	a1,s0,-1092
     672:	bc040513          	addi	a0,s0,-1088
     676:	98bff0ef          	jal	0 <append_str>
     67a:	00001617          	auipc	a2,0x1
     67e:	0d660613          	addi	a2,a2,214 # 1750 <malloc+0xf8>
     682:	bbc40593          	addi	a1,s0,-1092
     686:	bc040513          	addi	a0,s0,-1088
     68a:	977ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"block\":");
     68e:	00001617          	auipc	a2,0x1
     692:	17260613          	addi	a2,a2,370 # 1800 <malloc+0x1a8>
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
     6b6:	16660613          	addi	a2,a2,358 # 1818 <malloc+0x1c0>
     6ba:	bbc40593          	addi	a1,s0,-1092
     6be:	bc040513          	addi	a0,s0,-1088
     6c2:	93fff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"bit\":");
     6c6:	00001617          	auipc	a2,0x1
     6ca:	1f260613          	addi	a2,a2,498 # 18b8 <malloc+0x260>
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
     6f0:	12460613          	addi	a2,a2,292 # 1810 <malloc+0x1b8>
     6f4:	bbc40593          	addi	a1,s0,-1092
     6f8:	bc040513          	addi	a0,s0,-1088
     6fc:	905ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{" );
     700:	00001617          	auipc	a2,0x1
     704:	14060613          	addi	a2,a2,320 # 1840 <malloc+0x1e8>
     708:	bbc40593          	addi	a1,s0,-1092
     70c:	bc040513          	addi	a0,s0,-1088
     710:	8f1ff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "bit", e->balloc.old_bit, e->balloc.bit);
     714:	874a                	mv	a4,s2
     716:	1684a683          	lw	a3,360(s1)
     71a:	00001617          	auipc	a2,0x1
     71e:	1a660613          	addi	a2,a2,422 # 18c0 <malloc+0x268>
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
     74e:	0c660613          	addi	a2,a2,198 # 1810 <malloc+0x1b8>
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
     774:	05860613          	addi	a2,a2,88 # 17c8 <malloc+0x170>
     778:	bbc40593          	addi	a1,s0,-1092
     77c:	bc040513          	addi	a0,s0,-1088
     780:	881ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     784:	00001617          	auipc	a2,0x1
     788:	fcc60613          	addi	a2,a2,-52 # 1750 <malloc+0xf8>
     78c:	bbc40593          	addi	a1,s0,-1092
     790:	bc040513          	addi	a0,s0,-1088
     794:	86dff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     798:	00001617          	auipc	a2,0x1
     79c:	01860613          	addi	a2,a2,24 # 17b0 <malloc+0x158>
     7a0:	bbc40593          	addi	a1,s0,-1092
     7a4:	bc040513          	addi	a0,s0,-1088
     7a8:	859ff0ef          	jal	0 <append_str>
     7ac:	01448613          	addi	a2,s1,20
     7b0:	bbc40593          	addi	a1,s0,-1092
     7b4:	bc040513          	addi	a0,s0,-1088
     7b8:	849ff0ef          	jal	0 <append_str>
     7bc:	00001617          	auipc	a2,0x1
     7c0:	f9460613          	addi	a2,a2,-108 # 1750 <malloc+0xf8>
     7c4:	bbc40593          	addi	a1,s0,-1092
     7c8:	bc040513          	addi	a0,s0,-1088
     7cc:	835ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"inode\":{");
     7d0:	00001617          	auipc	a2,0x1
     7d4:	0f860613          	addi	a2,a2,248 # 18c8 <malloc+0x270>
     7d8:	bbc40593          	addi	a1,s0,-1092
     7dc:	bc040513          	addi	a0,s0,-1088
     7e0:	821ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"inum\":"); append_int(buf, &pos, e->inode.inum);
     7e4:	00001617          	auipc	a2,0x1
     7e8:	0f460613          	addi	a2,a2,244 # 18d8 <malloc+0x280>
     7ec:	bbc40593          	addi	a1,s0,-1092
     7f0:	bc040513          	addi	a0,s0,-1088
     7f4:	80dff0ef          	jal	0 <append_str>
     7f8:	1604a603          	lw	a2,352(s1)
     7fc:	bbc40593          	addi	a1,s0,-1092
     800:	bc040513          	addi	a0,s0,-1088
     804:	8b5ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     808:	00001617          	auipc	a2,0x1
     80c:	00860613          	addi	a2,a2,8 # 1810 <malloc+0x1b8>
     810:	bbc40593          	addi	a1,s0,-1092
     814:	bc040513          	addi	a0,s0,-1088
     818:	fe8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"state\":{");
     81c:	00001617          	auipc	a2,0x1
     820:	ffc60613          	addi	a2,a2,-4 # 1818 <malloc+0x1c0>
     824:	bbc40593          	addi	a1,s0,-1092
     828:	bc040513          	addi	a0,s0,-1088
     82c:	fd4ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->inode.ref);
     830:	00001617          	auipc	a2,0x1
     834:	ff860613          	addi	a2,a2,-8 # 1828 <malloc+0x1d0>
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
     85a:	fda60613          	addi	a2,a2,-38 # 1830 <malloc+0x1d8>
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
     880:	06460613          	addi	a2,a2,100 # 18e0 <malloc+0x288>
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
     8a6:	04e60613          	addi	a2,a2,78 # 18f0 <malloc+0x298>
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
     8cc:	03860613          	addi	a2,a2,56 # 1900 <malloc+0x2a8>
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
     8f2:	f2260613          	addi	a2,a2,-222 # 1810 <malloc+0x1b8>
     8f6:	bbc40593          	addi	a1,s0,-1092
     8fa:	bc040513          	addi	a0,s0,-1088
     8fe:	f02ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     902:	00001617          	auipc	a2,0x1
     906:	f3e60613          	addi	a2,a2,-194 # 1840 <malloc+0x1e8>
     90a:	bbc40593          	addi	a1,s0,-1092
     90e:	bc040513          	addi	a0,s0,-1088
     912:	eeeff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "ref", e->inode.old_ref, e->inode.ref);
     916:	875a                	mv	a4,s6
     918:	1684a683          	lw	a3,360(s1)
     91c:	00001617          	auipc	a2,0x1
     920:	f3460613          	addi	a2,a2,-204 # 1850 <malloc+0x1f8>
     924:	bbc40593          	addi	a1,s0,-1092
     928:	bc040513          	addi	a0,s0,-1088
     92c:	fc4ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "valid", e->inode.old_valid_inode, e->inode.valid_inode);
     930:	8756                	mv	a4,s5
     932:	1704a683          	lw	a3,368(s1)
     936:	00001617          	auipc	a2,0x1
     93a:	f2260613          	addi	a2,a2,-222 # 1858 <malloc+0x200>
     93e:	bbc40593          	addi	a1,s0,-1092
     942:	bc040513          	addi	a0,s0,-1088
     946:	faaff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "type", e->inode.old_type_inode, e->inode.type_inode);
     94a:	8752                	mv	a4,s4
     94c:	1784a683          	lw	a3,376(s1)
     950:	00001617          	auipc	a2,0x1
     954:	fc060613          	addi	a2,a2,-64 # 1910 <malloc+0x2b8>
     958:	bbc40593          	addi	a1,s0,-1092
     95c:	bc040513          	addi	a0,s0,-1088
     960:	f90ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "size", e->inode.old_size, e->inode.size);
     964:	874e                	mv	a4,s3
     966:	1804a683          	lw	a3,384(s1)
     96a:	00001617          	auipc	a2,0x1
     96e:	fae60613          	addi	a2,a2,-82 # 1918 <malloc+0x2c0>
     972:	bbc40593          	addi	a1,s0,-1092
     976:	bc040513          	addi	a0,s0,-1088
     97a:	f76ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "locked", e->inode.old_locked, e->inode.locked);
     97e:	874a                	mv	a4,s2
     980:	1884a683          	lw	a3,392(s1)
     984:	00001617          	auipc	a2,0x1
     988:	f9c60613          	addi	a2,a2,-100 # 1920 <malloc+0x2c8>
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
     9b8:	e5c60613          	addi	a2,a2,-420 # 1810 <malloc+0x1b8>
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
     9de:	df660613          	addi	a2,a2,-522 # 17d0 <malloc+0x178>
     9e2:	bbc40593          	addi	a1,s0,-1092
     9e6:	bc040513          	addi	a0,s0,-1088
     9ea:	e16ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     9ee:	00001617          	auipc	a2,0x1
     9f2:	d6260613          	addi	a2,a2,-670 # 1750 <malloc+0xf8>
     9f6:	bbc40593          	addi	a1,s0,-1092
     9fa:	bc040513          	addi	a0,s0,-1088
     9fe:	e02ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     a02:	00001617          	auipc	a2,0x1
     a06:	dae60613          	addi	a2,a2,-594 # 17b0 <malloc+0x158>
     a0a:	bbc40593          	addi	a1,s0,-1092
     a0e:	bc040513          	addi	a0,s0,-1088
     a12:	deeff0ef          	jal	0 <append_str>
     a16:	01448613          	addi	a2,s1,20
     a1a:	bbc40593          	addi	a1,s0,-1092
     a1e:	bc040513          	addi	a0,s0,-1088
     a22:	ddeff0ef          	jal	0 <append_str>
     a26:	00001617          	auipc	a2,0x1
     a2a:	d2a60613          	addi	a2,a2,-726 # 1750 <malloc+0xf8>
     a2e:	bbc40593          	addi	a1,s0,-1092
     a32:	bc040513          	addi	a0,s0,-1088
     a36:	dcaff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"dir\":{");
     a3a:	00001617          	auipc	a2,0x1
     a3e:	eee60613          	addi	a2,a2,-274 # 1928 <malloc+0x2d0>
     a42:	bbc40593          	addi	a1,s0,-1092
     a46:	bc040513          	addi	a0,s0,-1088
     a4a:	db6ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"parent\":");
     a4e:	00001617          	auipc	a2,0x1
     a52:	eea60613          	addi	a2,a2,-278 # 1938 <malloc+0x2e0>
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
     a76:	ed660613          	addi	a2,a2,-298 # 1948 <malloc+0x2f0>
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
     a9a:	ec260613          	addi	a2,a2,-318 # 1958 <malloc+0x300>
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
     abe:	eae60613          	addi	a2,a2,-338 # 1968 <malloc+0x310>
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
     ae2:	e9a60613          	addi	a2,a2,-358 # 1978 <malloc+0x320>
     ae6:	bbc40593          	addi	a1,s0,-1092
     aea:	bc040513          	addi	a0,s0,-1088
     aee:	d12ff0ef          	jal	0 <append_str>
     af2:	92fff06f          	j	420 <print_fs_event+0x2a2>
    append_str(buf, &pos, "PATH");
     af6:	00001617          	auipc	a2,0x1
     afa:	ce260613          	addi	a2,a2,-798 # 17d8 <malloc+0x180>
     afe:	bbc40593          	addi	a1,s0,-1092
     b02:	bc040513          	addi	a0,s0,-1088
     b06:	cfaff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     b0a:	00001617          	auipc	a2,0x1
     b0e:	c4660613          	addi	a2,a2,-954 # 1750 <malloc+0xf8>
     b12:	bbc40593          	addi	a1,s0,-1092
     b16:	bc040513          	addi	a0,s0,-1088
     b1a:	ce6ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     b1e:	00001617          	auipc	a2,0x1
     b22:	c9260613          	addi	a2,a2,-878 # 17b0 <malloc+0x158>
     b26:	bbc40593          	addi	a1,s0,-1092
     b2a:	bc040513          	addi	a0,s0,-1088
     b2e:	cd2ff0ef          	jal	0 <append_str>
     b32:	01448613          	addi	a2,s1,20
     b36:	bbc40593          	addi	a1,s0,-1092
     b3a:	bc040513          	addi	a0,s0,-1088
     b3e:	cc2ff0ef          	jal	0 <append_str>
     b42:	00001617          	auipc	a2,0x1
     b46:	c0e60613          	addi	a2,a2,-1010 # 1750 <malloc+0xf8>
     b4a:	bbc40593          	addi	a1,s0,-1092
     b4e:	bc040513          	addi	a0,s0,-1088
     b52:	caeff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"path\":\"");
     b56:	00001617          	auipc	a2,0x1
     b5a:	e2a60613          	addi	a2,a2,-470 # 1980 <malloc+0x328>
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
     b7e:	bd660613          	addi	a2,a2,-1066 # 1750 <malloc+0xf8>
     b82:	bbc40593          	addi	a1,s0,-1092
     b86:	bc040513          	addi	a0,s0,-1088
     b8a:	c76ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"elem\":\"");
     b8e:	00001617          	auipc	a2,0x1
     b92:	e0260613          	addi	a2,a2,-510 # 1990 <malloc+0x338>
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
     bb6:	b9e60613          	addi	a2,a2,-1122 # 1750 <malloc+0xf8>
     bba:	bbc40593          	addi	a1,s0,-1092
     bbe:	bc040513          	addi	a0,s0,-1088
     bc2:	c3eff0ef          	jal	0 <append_str>
     bc6:	85bff06f          	j	420 <print_fs_event+0x2a2>
     bca:	43313423          	sd	s3,1064(sp)
    append_str(buf, &pos, "FILE");
     bce:	00001617          	auipc	a2,0x1
     bd2:	c1260613          	addi	a2,a2,-1006 # 17e0 <malloc+0x188>
     bd6:	bbc40593          	addi	a1,s0,-1092
     bda:	bc040513          	addi	a0,s0,-1088
     bde:	c22ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     be2:	00001617          	auipc	a2,0x1
     be6:	b6e60613          	addi	a2,a2,-1170 # 1750 <malloc+0xf8>
     bea:	bbc40593          	addi	a1,s0,-1092
     bee:	bc040513          	addi	a0,s0,-1088
     bf2:	c0eff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     bf6:	00001617          	auipc	a2,0x1
     bfa:	bba60613          	addi	a2,a2,-1094 # 17b0 <malloc+0x158>
     bfe:	bbc40593          	addi	a1,s0,-1092
     c02:	bc040513          	addi	a0,s0,-1088
     c06:	bfaff0ef          	jal	0 <append_str>
     c0a:	01448613          	addi	a2,s1,20
     c0e:	bbc40593          	addi	a1,s0,-1092
     c12:	bc040513          	addi	a0,s0,-1088
     c16:	beaff0ef          	jal	0 <append_str>
     c1a:	00001617          	auipc	a2,0x1
     c1e:	b3660613          	addi	a2,a2,-1226 # 1750 <malloc+0xf8>
     c22:	bbc40593          	addi	a1,s0,-1092
     c26:	bc040513          	addi	a0,s0,-1088
     c2a:	bd6ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"state\":{");
     c2e:	00001617          	auipc	a2,0x1
     c32:	bea60613          	addi	a2,a2,-1046 # 1818 <malloc+0x1c0>
     c36:	bbc40593          	addi	a1,s0,-1092
     c3a:	bc040513          	addi	a0,s0,-1088
     c3e:	bc2ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":");
     c42:	00001617          	auipc	a2,0x1
     c46:	be660613          	addi	a2,a2,-1050 # 1828 <malloc+0x1d0>
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
     c6c:	cf060613          	addi	a2,a2,-784 # 1958 <malloc+0x300>
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
     c92:	d1260613          	addi	a2,a2,-750 # 19a0 <malloc+0x348>
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
     cb6:	cfe60613          	addi	a2,a2,-770 # 19b0 <malloc+0x358>
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
     cda:	b3a60613          	addi	a2,a2,-1222 # 1810 <malloc+0x1b8>
     cde:	bbc40593          	addi	a1,s0,-1092
     ce2:	bc040513          	addi	a0,s0,-1088
     ce6:	b1aff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     cea:	00001617          	auipc	a2,0x1
     cee:	b5660613          	addi	a2,a2,-1194 # 1840 <malloc+0x1e8>
     cf2:	bbc40593          	addi	a1,s0,-1092
     cf6:	bc040513          	addi	a0,s0,-1088
     cfa:	b06ff0ef          	jal	0 <append_str>
    print_change(buf, &pos,
     cfe:	874e                	mv	a4,s3
     d00:	1744a683          	lw	a3,372(s1)
     d04:	00001617          	auipc	a2,0x1
     d08:	b4c60613          	addi	a2,a2,-1204 # 1850 <malloc+0x1f8>
     d0c:	bbc40593          	addi	a1,s0,-1092
     d10:	bc040513          	addi	a0,s0,-1088
     d14:	bdcff0ef          	jal	f0 <print_change>
    print_change(buf, &pos,
     d18:	874a                	mv	a4,s2
     d1a:	17c4a683          	lw	a3,380(s1)
     d1e:	00001617          	auipc	a2,0x1
     d22:	ca260613          	addi	a2,a2,-862 # 19c0 <malloc+0x368>
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
     d52:	ac260613          	addi	a2,a2,-1342 # 1810 <malloc+0x1b8>
     d56:	bbc40593          	addi	a1,s0,-1092
     d5a:	bc040513          	addi	a0,s0,-1088
     d5e:	aa2ff0ef          	jal	0 <append_str>
     d62:	42813983          	ld	s3,1064(sp)
     d66:	ebaff06f          	j	420 <print_fs_event+0x2a2>
    append_str(buf, &pos, "\"");
     d6a:	00001617          	auipc	a2,0x1
     d6e:	9e660613          	addi	a2,a2,-1562 # 1750 <malloc+0xf8>
     d72:	bbc40593          	addi	a1,s0,-1092
     d76:	bc040513          	addi	a0,s0,-1088
     d7a:	a86ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     d7e:	00001617          	auipc	a2,0x1
     d82:	a3260613          	addi	a2,a2,-1486 # 17b0 <malloc+0x158>
     d86:	bbc40593          	addi	a1,s0,-1092
     d8a:	bc040513          	addi	a0,s0,-1088
     d8e:	a72ff0ef          	jal	0 <append_str>
     d92:	01448613          	addi	a2,s1,20
     d96:	bbc40593          	addi	a1,s0,-1092
     d9a:	bc040513          	addi	a0,s0,-1088
     d9e:	a62ff0ef          	jal	0 <append_str>
     da2:	00001617          	auipc	a2,0x1
     da6:	9ae60613          	addi	a2,a2,-1618 # 1750 <malloc+0xf8>
     daa:	bbc40593          	addi	a1,s0,-1092
     dae:	bc040513          	addi	a0,s0,-1088
     db2:	a4eff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE){
     db6:	479d                	li	a5,7
     db8:	e727e463          	bltu	a5,s2,420 <print_fs_event+0x2a2>
     dbc:	090a                	slli	s2,s2,0x2
     dbe:	00001717          	auipc	a4,0x1
     dc2:	c9270713          	addi	a4,a4,-878 # 1a50 <malloc+0x3f8>
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
     e30:	bb450513          	addi	a0,a0,-1100 # 19e0 <malloc+0x388>
     e34:	770000ef          	jal	15a4 <printf>
    
    while (1) {
        int n_fs = fsread(fs_ev, 16);
     e38:	00001997          	auipc	s3,0x1
     e3c:	1d898993          	addi	s3,s3,472 # 2010 <fs_ev>
     e40:	a831                	j	e5c <main+0x3e>
        if (n_fs < 0) {
            fprintf(2, "fsexport: error reading fslog\n");
     e42:	00001597          	auipc	a1,0x1
     e46:	bc658593          	addi	a1,a1,-1082 # 1a08 <malloc+0x3b0>
     e4a:	4509                	li	a0,2
     e4c:	72e000ef          	jal	157a <fprintf>
            exit(1);
     e50:	4505                	li	a0,1
     e52:	30a000ef          	jal	115c <exit>
        for (int i = 0; i < n_fs; i++) {
            print_fs_event(&fs_ev[i]);
        }

        // استخدام sleep(2) بدلاً من pause في xv6 لضمان استمرار الحلقة
        pause(2); 
     e56:	4509                	li	a0,2
     e58:	394000ef          	jal	11ec <pause>
        int n_fs = fsread(fs_ev, 16);
     e5c:	45c1                	li	a1,16
     e5e:	854e                	mv	a0,s3
     e60:	3a4000ef          	jal	1204 <fsread>
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
     e96:	2c6000ef          	jal	115c <exit>

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
     f84:	1f0000ef          	jal	1174 <read>
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
     fd0:	1cc000ef          	jal	119c <open>
  if(fd < 0)
     fd4:	02054263          	bltz	a0,ff8 <stat+0x36>
     fd8:	e426                	sd	s1,8(sp)
     fda:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     fdc:	85ca                	mv	a1,s2
     fde:	1d6000ef          	jal	11b4 <fstat>
     fe2:	892a                	mv	s2,a0
  close(fd);
     fe4:	8526                	mv	a0,s1
     fe6:	19e000ef          	jal	1184 <close>
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
    10f4:	0f0000ef          	jal	11e4 <sys_sbrk>
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
    110a:	0da000ef          	jal	11e4 <sys_sbrk>
}
    110e:	60a2                	ld	ra,8(sp)
    1110:	6402                	ld	s0,0(sp)
    1112:	0141                	addi	sp,sp,16
    1114:	8082                	ret

0000000000001116 <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
    1116:	1141                	addi	sp,sp,-16
    1118:	e406                	sd	ra,8(sp)
    111a:	e022                	sd	s0,0(sp)
    111c:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
    111e:	0025961b          	slliw	a2,a1,0x2
    1122:	9e2d                	addw	a2,a2,a1
    1124:	0036161b          	slliw	a2,a2,0x3
    1128:	4581                	li	a1,0
    112a:	de3ff0ef          	jal	f0c <memset>
  return 0;
}
    112e:	4501                	li	a0,0
    1130:	60a2                	ld	ra,8(sp)
    1132:	6402                	ld	s0,0(sp)
    1134:	0141                	addi	sp,sp,16
    1136:	8082                	ret

0000000000001138 <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
    1138:	1141                	addi	sp,sp,-16
    113a:	e406                	sd	ra,8(sp)
    113c:	e022                	sd	s0,0(sp)
    113e:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
    1140:	07000613          	li	a2,112
    1144:	4581                	li	a1,0
    1146:	dc7ff0ef          	jal	f0c <memset>
  return 0;
}
    114a:	4501                	li	a0,0
    114c:	60a2                	ld	ra,8(sp)
    114e:	6402                	ld	s0,0(sp)
    1150:	0141                	addi	sp,sp,16
    1152:	8082                	ret

0000000000001154 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    1154:	4885                	li	a7,1
 ecall
    1156:	00000073          	ecall
 ret
    115a:	8082                	ret

000000000000115c <exit>:
.global exit
exit:
 li a7, SYS_exit
    115c:	4889                	li	a7,2
 ecall
    115e:	00000073          	ecall
 ret
    1162:	8082                	ret

0000000000001164 <wait>:
.global wait
wait:
 li a7, SYS_wait
    1164:	488d                	li	a7,3
 ecall
    1166:	00000073          	ecall
 ret
    116a:	8082                	ret

000000000000116c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    116c:	4891                	li	a7,4
 ecall
    116e:	00000073          	ecall
 ret
    1172:	8082                	ret

0000000000001174 <read>:
.global read
read:
 li a7, SYS_read
    1174:	4895                	li	a7,5
 ecall
    1176:	00000073          	ecall
 ret
    117a:	8082                	ret

000000000000117c <write>:
.global write
write:
 li a7, SYS_write
    117c:	48c1                	li	a7,16
 ecall
    117e:	00000073          	ecall
 ret
    1182:	8082                	ret

0000000000001184 <close>:
.global close
close:
 li a7, SYS_close
    1184:	48d5                	li	a7,21
 ecall
    1186:	00000073          	ecall
 ret
    118a:	8082                	ret

000000000000118c <kill>:
.global kill
kill:
 li a7, SYS_kill
    118c:	4899                	li	a7,6
 ecall
    118e:	00000073          	ecall
 ret
    1192:	8082                	ret

0000000000001194 <exec>:
.global exec
exec:
 li a7, SYS_exec
    1194:	489d                	li	a7,7
 ecall
    1196:	00000073          	ecall
 ret
    119a:	8082                	ret

000000000000119c <open>:
.global open
open:
 li a7, SYS_open
    119c:	48bd                	li	a7,15
 ecall
    119e:	00000073          	ecall
 ret
    11a2:	8082                	ret

00000000000011a4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    11a4:	48c5                	li	a7,17
 ecall
    11a6:	00000073          	ecall
 ret
    11aa:	8082                	ret

00000000000011ac <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    11ac:	48c9                	li	a7,18
 ecall
    11ae:	00000073          	ecall
 ret
    11b2:	8082                	ret

00000000000011b4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    11b4:	48a1                	li	a7,8
 ecall
    11b6:	00000073          	ecall
 ret
    11ba:	8082                	ret

00000000000011bc <link>:
.global link
link:
 li a7, SYS_link
    11bc:	48cd                	li	a7,19
 ecall
    11be:	00000073          	ecall
 ret
    11c2:	8082                	ret

00000000000011c4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    11c4:	48d1                	li	a7,20
 ecall
    11c6:	00000073          	ecall
 ret
    11ca:	8082                	ret

00000000000011cc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    11cc:	48a5                	li	a7,9
 ecall
    11ce:	00000073          	ecall
 ret
    11d2:	8082                	ret

00000000000011d4 <dup>:
.global dup
dup:
 li a7, SYS_dup
    11d4:	48a9                	li	a7,10
 ecall
    11d6:	00000073          	ecall
 ret
    11da:	8082                	ret

00000000000011dc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    11dc:	48ad                	li	a7,11
 ecall
    11de:	00000073          	ecall
 ret
    11e2:	8082                	ret

00000000000011e4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    11e4:	48b1                	li	a7,12
 ecall
    11e6:	00000073          	ecall
 ret
    11ea:	8082                	ret

00000000000011ec <pause>:
.global pause
pause:
 li a7, SYS_pause
    11ec:	48b5                	li	a7,13
 ecall
    11ee:	00000073          	ecall
 ret
    11f2:	8082                	ret

00000000000011f4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    11f4:	48b9                	li	a7,14
 ecall
    11f6:	00000073          	ecall
 ret
    11fa:	8082                	ret

00000000000011fc <csread>:
.global csread
csread:
 li a7, SYS_csread
    11fc:	48d9                	li	a7,22
 ecall
    11fe:	00000073          	ecall
 ret
    1202:	8082                	ret

0000000000001204 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
    1204:	48dd                	li	a7,23
 ecall
    1206:	00000073          	ecall
 ret
    120a:	8082                	ret

000000000000120c <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
    120c:	48e1                	li	a7,24
 ecall
    120e:	00000073          	ecall
 ret
    1212:	8082                	ret

0000000000001214 <memread>:
.global memread
memread:
 li a7, SYS_memread
    1214:	48e5                	li	a7,25
 ecall
    1216:	00000073          	ecall
 ret
    121a:	8082                	ret

000000000000121c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    121c:	1101                	addi	sp,sp,-32
    121e:	ec06                	sd	ra,24(sp)
    1220:	e822                	sd	s0,16(sp)
    1222:	1000                	addi	s0,sp,32
    1224:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    1228:	4605                	li	a2,1
    122a:	fef40593          	addi	a1,s0,-17
    122e:	f4fff0ef          	jal	117c <write>
}
    1232:	60e2                	ld	ra,24(sp)
    1234:	6442                	ld	s0,16(sp)
    1236:	6105                	addi	sp,sp,32
    1238:	8082                	ret

000000000000123a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    123a:	715d                	addi	sp,sp,-80
    123c:	e486                	sd	ra,72(sp)
    123e:	e0a2                	sd	s0,64(sp)
    1240:	f84a                	sd	s2,48(sp)
    1242:	0880                	addi	s0,sp,80
    1244:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    1246:	c299                	beqz	a3,124c <printint+0x12>
    1248:	0805c363          	bltz	a1,12ce <printint+0x94>
  neg = 0;
    124c:	4881                	li	a7,0
    124e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    1252:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    1254:	00001517          	auipc	a0,0x1
    1258:	81c50513          	addi	a0,a0,-2020 # 1a70 <digits>
    125c:	883e                	mv	a6,a5
    125e:	2785                	addiw	a5,a5,1
    1260:	02c5f733          	remu	a4,a1,a2
    1264:	972a                	add	a4,a4,a0
    1266:	00074703          	lbu	a4,0(a4)
    126a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    126e:	872e                	mv	a4,a1
    1270:	02c5d5b3          	divu	a1,a1,a2
    1274:	0685                	addi	a3,a3,1
    1276:	fec773e3          	bgeu	a4,a2,125c <printint+0x22>
  if(neg)
    127a:	00088b63          	beqz	a7,1290 <printint+0x56>
    buf[i++] = '-';
    127e:	fd078793          	addi	a5,a5,-48
    1282:	97a2                	add	a5,a5,s0
    1284:	02d00713          	li	a4,45
    1288:	fee78423          	sb	a4,-24(a5)
    128c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    1290:	02f05a63          	blez	a5,12c4 <printint+0x8a>
    1294:	fc26                	sd	s1,56(sp)
    1296:	f44e                	sd	s3,40(sp)
    1298:	fb840713          	addi	a4,s0,-72
    129c:	00f704b3          	add	s1,a4,a5
    12a0:	fff70993          	addi	s3,a4,-1
    12a4:	99be                	add	s3,s3,a5
    12a6:	37fd                	addiw	a5,a5,-1
    12a8:	1782                	slli	a5,a5,0x20
    12aa:	9381                	srli	a5,a5,0x20
    12ac:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    12b0:	fff4c583          	lbu	a1,-1(s1)
    12b4:	854a                	mv	a0,s2
    12b6:	f67ff0ef          	jal	121c <putc>
  while(--i >= 0)
    12ba:	14fd                	addi	s1,s1,-1
    12bc:	ff349ae3          	bne	s1,s3,12b0 <printint+0x76>
    12c0:	74e2                	ld	s1,56(sp)
    12c2:	79a2                	ld	s3,40(sp)
}
    12c4:	60a6                	ld	ra,72(sp)
    12c6:	6406                	ld	s0,64(sp)
    12c8:	7942                	ld	s2,48(sp)
    12ca:	6161                	addi	sp,sp,80
    12cc:	8082                	ret
    x = -xx;
    12ce:	40b005b3          	neg	a1,a1
    neg = 1;
    12d2:	4885                	li	a7,1
    x = -xx;
    12d4:	bfad                	j	124e <printint+0x14>

00000000000012d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    12d6:	711d                	addi	sp,sp,-96
    12d8:	ec86                	sd	ra,88(sp)
    12da:	e8a2                	sd	s0,80(sp)
    12dc:	e0ca                	sd	s2,64(sp)
    12de:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    12e0:	0005c903          	lbu	s2,0(a1)
    12e4:	28090663          	beqz	s2,1570 <vprintf+0x29a>
    12e8:	e4a6                	sd	s1,72(sp)
    12ea:	fc4e                	sd	s3,56(sp)
    12ec:	f852                	sd	s4,48(sp)
    12ee:	f456                	sd	s5,40(sp)
    12f0:	f05a                	sd	s6,32(sp)
    12f2:	ec5e                	sd	s7,24(sp)
    12f4:	e862                	sd	s8,16(sp)
    12f6:	e466                	sd	s9,8(sp)
    12f8:	8b2a                	mv	s6,a0
    12fa:	8a2e                	mv	s4,a1
    12fc:	8bb2                	mv	s7,a2
  state = 0;
    12fe:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    1300:	4481                	li	s1,0
    1302:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    1304:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    1308:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    130c:	06c00c93          	li	s9,108
    1310:	a005                	j	1330 <vprintf+0x5a>
        putc(fd, c0);
    1312:	85ca                	mv	a1,s2
    1314:	855a                	mv	a0,s6
    1316:	f07ff0ef          	jal	121c <putc>
    131a:	a019                	j	1320 <vprintf+0x4a>
    } else if(state == '%'){
    131c:	03598263          	beq	s3,s5,1340 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
    1320:	2485                	addiw	s1,s1,1
    1322:	8726                	mv	a4,s1
    1324:	009a07b3          	add	a5,s4,s1
    1328:	0007c903          	lbu	s2,0(a5)
    132c:	22090a63          	beqz	s2,1560 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
    1330:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1334:	fe0994e3          	bnez	s3,131c <vprintf+0x46>
      if(c0 == '%'){
    1338:	fd579de3          	bne	a5,s5,1312 <vprintf+0x3c>
        state = '%';
    133c:	89be                	mv	s3,a5
    133e:	b7cd                	j	1320 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    1340:	00ea06b3          	add	a3,s4,a4
    1344:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    1348:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    134a:	c681                	beqz	a3,1352 <vprintf+0x7c>
    134c:	9752                	add	a4,a4,s4
    134e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    1352:	05878363          	beq	a5,s8,1398 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
    1356:	05978d63          	beq	a5,s9,13b0 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    135a:	07500713          	li	a4,117
    135e:	0ee78763          	beq	a5,a4,144c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    1362:	07800713          	li	a4,120
    1366:	12e78963          	beq	a5,a4,1498 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    136a:	07000713          	li	a4,112
    136e:	14e78e63          	beq	a5,a4,14ca <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
    1372:	06300713          	li	a4,99
    1376:	18e78e63          	beq	a5,a4,1512 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
    137a:	07300713          	li	a4,115
    137e:	1ae78463          	beq	a5,a4,1526 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    1382:	02500713          	li	a4,37
    1386:	04e79563          	bne	a5,a4,13d0 <vprintf+0xfa>
        putc(fd, '%');
    138a:	02500593          	li	a1,37
    138e:	855a                	mv	a0,s6
    1390:	e8dff0ef          	jal	121c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    1394:	4981                	li	s3,0
    1396:	b769                	j	1320 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    1398:	008b8913          	addi	s2,s7,8
    139c:	4685                	li	a3,1
    139e:	4629                	li	a2,10
    13a0:	000ba583          	lw	a1,0(s7)
    13a4:	855a                	mv	a0,s6
    13a6:	e95ff0ef          	jal	123a <printint>
    13aa:	8bca                	mv	s7,s2
      state = 0;
    13ac:	4981                	li	s3,0
    13ae:	bf8d                	j	1320 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    13b0:	06400793          	li	a5,100
    13b4:	02f68963          	beq	a3,a5,13e6 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    13b8:	06c00793          	li	a5,108
    13bc:	04f68263          	beq	a3,a5,1400 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
    13c0:	07500793          	li	a5,117
    13c4:	0af68063          	beq	a3,a5,1464 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
    13c8:	07800793          	li	a5,120
    13cc:	0ef68263          	beq	a3,a5,14b0 <vprintf+0x1da>
        putc(fd, '%');
    13d0:	02500593          	li	a1,37
    13d4:	855a                	mv	a0,s6
    13d6:	e47ff0ef          	jal	121c <putc>
        putc(fd, c0);
    13da:	85ca                	mv	a1,s2
    13dc:	855a                	mv	a0,s6
    13de:	e3fff0ef          	jal	121c <putc>
      state = 0;
    13e2:	4981                	li	s3,0
    13e4:	bf35                	j	1320 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    13e6:	008b8913          	addi	s2,s7,8
    13ea:	4685                	li	a3,1
    13ec:	4629                	li	a2,10
    13ee:	000bb583          	ld	a1,0(s7)
    13f2:	855a                	mv	a0,s6
    13f4:	e47ff0ef          	jal	123a <printint>
        i += 1;
    13f8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    13fa:	8bca                	mv	s7,s2
      state = 0;
    13fc:	4981                	li	s3,0
        i += 1;
    13fe:	b70d                	j	1320 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    1400:	06400793          	li	a5,100
    1404:	02f60763          	beq	a2,a5,1432 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    1408:	07500793          	li	a5,117
    140c:	06f60963          	beq	a2,a5,147e <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    1410:	07800793          	li	a5,120
    1414:	faf61ee3          	bne	a2,a5,13d0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    1418:	008b8913          	addi	s2,s7,8
    141c:	4681                	li	a3,0
    141e:	4641                	li	a2,16
    1420:	000bb583          	ld	a1,0(s7)
    1424:	855a                	mv	a0,s6
    1426:	e15ff0ef          	jal	123a <printint>
        i += 2;
    142a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    142c:	8bca                	mv	s7,s2
      state = 0;
    142e:	4981                	li	s3,0
        i += 2;
    1430:	bdc5                	j	1320 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1432:	008b8913          	addi	s2,s7,8
    1436:	4685                	li	a3,1
    1438:	4629                	li	a2,10
    143a:	000bb583          	ld	a1,0(s7)
    143e:	855a                	mv	a0,s6
    1440:	dfbff0ef          	jal	123a <printint>
        i += 2;
    1444:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    1446:	8bca                	mv	s7,s2
      state = 0;
    1448:	4981                	li	s3,0
        i += 2;
    144a:	bdd9                	j	1320 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    144c:	008b8913          	addi	s2,s7,8
    1450:	4681                	li	a3,0
    1452:	4629                	li	a2,10
    1454:	000be583          	lwu	a1,0(s7)
    1458:	855a                	mv	a0,s6
    145a:	de1ff0ef          	jal	123a <printint>
    145e:	8bca                	mv	s7,s2
      state = 0;
    1460:	4981                	li	s3,0
    1462:	bd7d                	j	1320 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1464:	008b8913          	addi	s2,s7,8
    1468:	4681                	li	a3,0
    146a:	4629                	li	a2,10
    146c:	000bb583          	ld	a1,0(s7)
    1470:	855a                	mv	a0,s6
    1472:	dc9ff0ef          	jal	123a <printint>
        i += 1;
    1476:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    1478:	8bca                	mv	s7,s2
      state = 0;
    147a:	4981                	li	s3,0
        i += 1;
    147c:	b555                	j	1320 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    147e:	008b8913          	addi	s2,s7,8
    1482:	4681                	li	a3,0
    1484:	4629                	li	a2,10
    1486:	000bb583          	ld	a1,0(s7)
    148a:	855a                	mv	a0,s6
    148c:	dafff0ef          	jal	123a <printint>
        i += 2;
    1490:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    1492:	8bca                	mv	s7,s2
      state = 0;
    1494:	4981                	li	s3,0
        i += 2;
    1496:	b569                	j	1320 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    1498:	008b8913          	addi	s2,s7,8
    149c:	4681                	li	a3,0
    149e:	4641                	li	a2,16
    14a0:	000be583          	lwu	a1,0(s7)
    14a4:	855a                	mv	a0,s6
    14a6:	d95ff0ef          	jal	123a <printint>
    14aa:	8bca                	mv	s7,s2
      state = 0;
    14ac:	4981                	li	s3,0
    14ae:	bd8d                	j	1320 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    14b0:	008b8913          	addi	s2,s7,8
    14b4:	4681                	li	a3,0
    14b6:	4641                	li	a2,16
    14b8:	000bb583          	ld	a1,0(s7)
    14bc:	855a                	mv	a0,s6
    14be:	d7dff0ef          	jal	123a <printint>
        i += 1;
    14c2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    14c4:	8bca                	mv	s7,s2
      state = 0;
    14c6:	4981                	li	s3,0
        i += 1;
    14c8:	bda1                	j	1320 <vprintf+0x4a>
    14ca:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    14cc:	008b8d13          	addi	s10,s7,8
    14d0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    14d4:	03000593          	li	a1,48
    14d8:	855a                	mv	a0,s6
    14da:	d43ff0ef          	jal	121c <putc>
  putc(fd, 'x');
    14de:	07800593          	li	a1,120
    14e2:	855a                	mv	a0,s6
    14e4:	d39ff0ef          	jal	121c <putc>
    14e8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    14ea:	00000b97          	auipc	s7,0x0
    14ee:	586b8b93          	addi	s7,s7,1414 # 1a70 <digits>
    14f2:	03c9d793          	srli	a5,s3,0x3c
    14f6:	97de                	add	a5,a5,s7
    14f8:	0007c583          	lbu	a1,0(a5)
    14fc:	855a                	mv	a0,s6
    14fe:	d1fff0ef          	jal	121c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1502:	0992                	slli	s3,s3,0x4
    1504:	397d                	addiw	s2,s2,-1
    1506:	fe0916e3          	bnez	s2,14f2 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
    150a:	8bea                	mv	s7,s10
      state = 0;
    150c:	4981                	li	s3,0
    150e:	6d02                	ld	s10,0(sp)
    1510:	bd01                	j	1320 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
    1512:	008b8913          	addi	s2,s7,8
    1516:	000bc583          	lbu	a1,0(s7)
    151a:	855a                	mv	a0,s6
    151c:	d01ff0ef          	jal	121c <putc>
    1520:	8bca                	mv	s7,s2
      state = 0;
    1522:	4981                	li	s3,0
    1524:	bbf5                	j	1320 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    1526:	008b8993          	addi	s3,s7,8
    152a:	000bb903          	ld	s2,0(s7)
    152e:	00090f63          	beqz	s2,154c <vprintf+0x276>
        for(; *s; s++)
    1532:	00094583          	lbu	a1,0(s2)
    1536:	c195                	beqz	a1,155a <vprintf+0x284>
          putc(fd, *s);
    1538:	855a                	mv	a0,s6
    153a:	ce3ff0ef          	jal	121c <putc>
        for(; *s; s++)
    153e:	0905                	addi	s2,s2,1
    1540:	00094583          	lbu	a1,0(s2)
    1544:	f9f5                	bnez	a1,1538 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    1546:	8bce                	mv	s7,s3
      state = 0;
    1548:	4981                	li	s3,0
    154a:	bbd9                	j	1320 <vprintf+0x4a>
          s = "(null)";
    154c:	00000917          	auipc	s2,0x0
    1550:	4dc90913          	addi	s2,s2,1244 # 1a28 <malloc+0x3d0>
        for(; *s; s++)
    1554:	02800593          	li	a1,40
    1558:	b7c5                	j	1538 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    155a:	8bce                	mv	s7,s3
      state = 0;
    155c:	4981                	li	s3,0
    155e:	b3c9                	j	1320 <vprintf+0x4a>
    1560:	64a6                	ld	s1,72(sp)
    1562:	79e2                	ld	s3,56(sp)
    1564:	7a42                	ld	s4,48(sp)
    1566:	7aa2                	ld	s5,40(sp)
    1568:	7b02                	ld	s6,32(sp)
    156a:	6be2                	ld	s7,24(sp)
    156c:	6c42                	ld	s8,16(sp)
    156e:	6ca2                	ld	s9,8(sp)
    }
  }
}
    1570:	60e6                	ld	ra,88(sp)
    1572:	6446                	ld	s0,80(sp)
    1574:	6906                	ld	s2,64(sp)
    1576:	6125                	addi	sp,sp,96
    1578:	8082                	ret

000000000000157a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    157a:	715d                	addi	sp,sp,-80
    157c:	ec06                	sd	ra,24(sp)
    157e:	e822                	sd	s0,16(sp)
    1580:	1000                	addi	s0,sp,32
    1582:	e010                	sd	a2,0(s0)
    1584:	e414                	sd	a3,8(s0)
    1586:	e818                	sd	a4,16(s0)
    1588:	ec1c                	sd	a5,24(s0)
    158a:	03043023          	sd	a6,32(s0)
    158e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1592:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1596:	8622                	mv	a2,s0
    1598:	d3fff0ef          	jal	12d6 <vprintf>
}
    159c:	60e2                	ld	ra,24(sp)
    159e:	6442                	ld	s0,16(sp)
    15a0:	6161                	addi	sp,sp,80
    15a2:	8082                	ret

00000000000015a4 <printf>:

void
printf(const char *fmt, ...)
{
    15a4:	711d                	addi	sp,sp,-96
    15a6:	ec06                	sd	ra,24(sp)
    15a8:	e822                	sd	s0,16(sp)
    15aa:	1000                	addi	s0,sp,32
    15ac:	e40c                	sd	a1,8(s0)
    15ae:	e810                	sd	a2,16(s0)
    15b0:	ec14                	sd	a3,24(s0)
    15b2:	f018                	sd	a4,32(s0)
    15b4:	f41c                	sd	a5,40(s0)
    15b6:	03043823          	sd	a6,48(s0)
    15ba:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    15be:	00840613          	addi	a2,s0,8
    15c2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    15c6:	85aa                	mv	a1,a0
    15c8:	4505                	li	a0,1
    15ca:	d0dff0ef          	jal	12d6 <vprintf>
}
    15ce:	60e2                	ld	ra,24(sp)
    15d0:	6442                	ld	s0,16(sp)
    15d2:	6125                	addi	sp,sp,96
    15d4:	8082                	ret

00000000000015d6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15d6:	1141                	addi	sp,sp,-16
    15d8:	e422                	sd	s0,8(sp)
    15da:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15dc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15e0:	00001797          	auipc	a5,0x1
    15e4:	a207b783          	ld	a5,-1504(a5) # 2000 <freep>
    15e8:	a02d                	j	1612 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    15ea:	4618                	lw	a4,8(a2)
    15ec:	9f2d                	addw	a4,a4,a1
    15ee:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    15f2:	6398                	ld	a4,0(a5)
    15f4:	6310                	ld	a2,0(a4)
    15f6:	a83d                	j	1634 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    15f8:	ff852703          	lw	a4,-8(a0)
    15fc:	9f31                	addw	a4,a4,a2
    15fe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1600:	ff053683          	ld	a3,-16(a0)
    1604:	a091                	j	1648 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1606:	6398                	ld	a4,0(a5)
    1608:	00e7e463          	bltu	a5,a4,1610 <free+0x3a>
    160c:	00e6ea63          	bltu	a3,a4,1620 <free+0x4a>
{
    1610:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1612:	fed7fae3          	bgeu	a5,a3,1606 <free+0x30>
    1616:	6398                	ld	a4,0(a5)
    1618:	00e6e463          	bltu	a3,a4,1620 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    161c:	fee7eae3          	bltu	a5,a4,1610 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1620:	ff852583          	lw	a1,-8(a0)
    1624:	6390                	ld	a2,0(a5)
    1626:	02059813          	slli	a6,a1,0x20
    162a:	01c85713          	srli	a4,a6,0x1c
    162e:	9736                	add	a4,a4,a3
    1630:	fae60de3          	beq	a2,a4,15ea <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1634:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1638:	4790                	lw	a2,8(a5)
    163a:	02061593          	slli	a1,a2,0x20
    163e:	01c5d713          	srli	a4,a1,0x1c
    1642:	973e                	add	a4,a4,a5
    1644:	fae68ae3          	beq	a3,a4,15f8 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1648:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    164a:	00001717          	auipc	a4,0x1
    164e:	9af73b23          	sd	a5,-1610(a4) # 2000 <freep>
}
    1652:	6422                	ld	s0,8(sp)
    1654:	0141                	addi	sp,sp,16
    1656:	8082                	ret

0000000000001658 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1658:	7139                	addi	sp,sp,-64
    165a:	fc06                	sd	ra,56(sp)
    165c:	f822                	sd	s0,48(sp)
    165e:	f426                	sd	s1,40(sp)
    1660:	ec4e                	sd	s3,24(sp)
    1662:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1664:	02051493          	slli	s1,a0,0x20
    1668:	9081                	srli	s1,s1,0x20
    166a:	04bd                	addi	s1,s1,15
    166c:	8091                	srli	s1,s1,0x4
    166e:	0014899b          	addiw	s3,s1,1
    1672:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1674:	00001517          	auipc	a0,0x1
    1678:	98c53503          	ld	a0,-1652(a0) # 2000 <freep>
    167c:	c915                	beqz	a0,16b0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    167e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1680:	4798                	lw	a4,8(a5)
    1682:	08977a63          	bgeu	a4,s1,1716 <malloc+0xbe>
    1686:	f04a                	sd	s2,32(sp)
    1688:	e852                	sd	s4,16(sp)
    168a:	e456                	sd	s5,8(sp)
    168c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    168e:	8a4e                	mv	s4,s3
    1690:	0009871b          	sext.w	a4,s3
    1694:	6685                	lui	a3,0x1
    1696:	00d77363          	bgeu	a4,a3,169c <malloc+0x44>
    169a:	6a05                	lui	s4,0x1
    169c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    16a0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    16a4:	00001917          	auipc	s2,0x1
    16a8:	95c90913          	addi	s2,s2,-1700 # 2000 <freep>
  if(p == SBRK_ERROR)
    16ac:	5afd                	li	s5,-1
    16ae:	a081                	j	16ee <malloc+0x96>
    16b0:	f04a                	sd	s2,32(sp)
    16b2:	e852                	sd	s4,16(sp)
    16b4:	e456                	sd	s5,8(sp)
    16b6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    16b8:	00003797          	auipc	a5,0x3
    16bc:	95878793          	addi	a5,a5,-1704 # 4010 <base>
    16c0:	00001717          	auipc	a4,0x1
    16c4:	94f73023          	sd	a5,-1728(a4) # 2000 <freep>
    16c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    16ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    16ce:	b7c1                	j	168e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    16d0:	6398                	ld	a4,0(a5)
    16d2:	e118                	sd	a4,0(a0)
    16d4:	a8a9                	j	172e <malloc+0xd6>
  hp->s.size = nu;
    16d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    16da:	0541                	addi	a0,a0,16
    16dc:	efbff0ef          	jal	15d6 <free>
  return freep;
    16e0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    16e4:	c12d                	beqz	a0,1746 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    16e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    16e8:	4798                	lw	a4,8(a5)
    16ea:	02977263          	bgeu	a4,s1,170e <malloc+0xb6>
    if(p == freep)
    16ee:	00093703          	ld	a4,0(s2)
    16f2:	853e                	mv	a0,a5
    16f4:	fef719e3          	bne	a4,a5,16e6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    16f8:	8552                	mv	a0,s4
    16fa:	9f1ff0ef          	jal	10ea <sbrk>
  if(p == SBRK_ERROR)
    16fe:	fd551ce3          	bne	a0,s5,16d6 <malloc+0x7e>
        return 0;
    1702:	4501                	li	a0,0
    1704:	7902                	ld	s2,32(sp)
    1706:	6a42                	ld	s4,16(sp)
    1708:	6aa2                	ld	s5,8(sp)
    170a:	6b02                	ld	s6,0(sp)
    170c:	a03d                	j	173a <malloc+0xe2>
    170e:	7902                	ld	s2,32(sp)
    1710:	6a42                	ld	s4,16(sp)
    1712:	6aa2                	ld	s5,8(sp)
    1714:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1716:	fae48de3          	beq	s1,a4,16d0 <malloc+0x78>
        p->s.size -= nunits;
    171a:	4137073b          	subw	a4,a4,s3
    171e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1720:	02071693          	slli	a3,a4,0x20
    1724:	01c6d713          	srli	a4,a3,0x1c
    1728:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    172a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    172e:	00001717          	auipc	a4,0x1
    1732:	8ca73923          	sd	a0,-1838(a4) # 2000 <freep>
      return (void*)(p + 1);
    1736:	01078513          	addi	a0,a5,16
  }
}
    173a:	70e2                	ld	ra,56(sp)
    173c:	7442                	ld	s0,48(sp)
    173e:	74a2                	ld	s1,40(sp)
    1740:	69e2                	ld	s3,24(sp)
    1742:	6121                	addi	sp,sp,64
    1744:	8082                	ret
    1746:	7902                	ld	s2,32(sp)
    1748:	6a42                	ld	s4,16(sp)
    174a:	6aa2                	ld	s5,8(sp)
    174c:	6b02                	ld	s6,0(sp)
    174e:	b7f5                	j	173a <malloc+0xe2>
