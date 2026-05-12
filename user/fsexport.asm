
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
     116:	5de60613          	addi	a2,a2,1502 # 16f0 <malloc+0xfc>
     11a:	ee7ff0ef          	jal	0 <append_str>
        append_str(buf, pos, name);
     11e:	8656                	mv	a2,s5
     120:	85ca                	mv	a1,s2
     122:	8526                	mv	a0,s1
     124:	eddff0ef          	jal	0 <append_str>
        append_str(buf, pos, "\":\"");
     128:	00001617          	auipc	a2,0x1
     12c:	5d060613          	addi	a2,a2,1488 # 16f8 <malloc+0x104>
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
     146:	5be60613          	addi	a2,a2,1470 # 1700 <malloc+0x10c>
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
     160:	5ac60613          	addi	a2,a2,1452 # 1708 <malloc+0x114>
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
     1a0:	57460613          	addi	a2,a2,1396 # 1710 <malloc+0x11c>
     1a4:	bbc40593          	addi	a1,s0,-1092
     1a8:	bc040513          	addi	a0,s0,-1088
     1ac:	e55ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"seq\":");
     1b0:	00001617          	auipc	a2,0x1
     1b4:	56860613          	addi	a2,a2,1384 # 1718 <malloc+0x124>
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
     1d6:	54e60613          	addi	a2,a2,1358 # 1720 <malloc+0x12c>
     1da:	bbc40593          	addi	a1,s0,-1092
     1de:	bc040513          	addi	a0,s0,-1088
     1e2:	e1fff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "\"tick\":"); append_uint(buf, &pos, e->ticks);
     1e6:	00001617          	auipc	a2,0x1
     1ea:	54260613          	addi	a2,a2,1346 # 1728 <malloc+0x134>
     1ee:	bbc40593          	addi	a1,s0,-1092
     1f2:	bc040513          	addi	a0,s0,-1088
     1f6:	e0bff0ef          	jal	0 <append_str>
     1fa:	4490                	lw	a2,8(s1)
     1fc:	bbc40593          	addi	a1,s0,-1092
     200:	bc040513          	addi	a0,s0,-1088
     204:	e31ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"pid\":"); append_int(buf, &pos, e->pid);
     208:	00001617          	auipc	a2,0x1
     20c:	52860613          	addi	a2,a2,1320 # 1730 <malloc+0x13c>
     210:	bbc40593          	addi	a1,s0,-1092
     214:	bc040513          	addi	a0,s0,-1088
     218:	de9ff0ef          	jal	0 <append_str>
     21c:	44d0                	lw	a2,12(s1)
     21e:	bbc40593          	addi	a1,s0,-1092
     222:	bc040513          	addi	a0,s0,-1088
     226:	e93ff0ef          	jal	b8 <append_int>

    append_str(buf, &pos, ",\"layer\":\"");
     22a:	00001617          	auipc	a2,0x1
     22e:	50e60613          	addi	a2,a2,1294 # 1738 <malloc+0x144>
     232:	bbc40593          	addi	a1,s0,-1092
     236:	bc040513          	addi	a0,s0,-1088
     23a:	dc7ff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE)
     23e:	0104a903          	lw	s2,16(s1)
     242:	479d                	li	a5,7
     244:	3127e4e3          	bltu	a5,s2,d4c <print_fs_event+0xbce>
     248:	00291793          	slli	a5,s2,0x2
     24c:	00001717          	auipc	a4,0x1
     250:	78470713          	addi	a4,a4,1924 # 19d0 <malloc+0x3dc>
     254:	97ba                	add	a5,a5,a4
     256:	439c                	lw	a5,0(a5)
     258:	97ba                	add	a5,a5,a4
     25a:	8782                	jr	a5
     25c:	43313423          	sd	s3,1064(sp)
    append_str(buf, &pos, "BCACHE");
     260:	00001617          	auipc	a2,0x1
     264:	4e860613          	addi	a2,a2,1256 # 1748 <malloc+0x154>
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
     278:	47c60613          	addi	a2,a2,1148 # 16f0 <malloc+0xfc>
     27c:	bbc40593          	addi	a1,s0,-1092
     280:	bc040513          	addi	a0,s0,-1088
     284:	d7dff0ef          	jal	0 <append_str>

    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     288:	00001617          	auipc	a2,0x1
     28c:	4c860613          	addi	a2,a2,1224 # 1750 <malloc+0x15c>
     290:	bbc40593          	addi	a1,s0,-1092
     294:	bc040513          	addi	a0,s0,-1088
     298:	d69ff0ef          	jal	0 <append_str>
     29c:	01448613          	addi	a2,s1,20
     2a0:	bbc40593          	addi	a1,s0,-1092
     2a4:	bc040513          	addi	a0,s0,-1088
     2a8:	d59ff0ef          	jal	0 <append_str>
     2ac:	00001617          	auipc	a2,0x1
     2b0:	44460613          	addi	a2,a2,1092 # 16f0 <malloc+0xfc>
     2b4:	bbc40593          	addi	a1,s0,-1092
     2b8:	bc040513          	addi	a0,s0,-1088
     2bc:	d45ff0ef          	jal	0 <append_str>

    // ===== BCACHE =====
    if(e->type == LAYER_BCACHE){

        append_str(buf, &pos, ",\"buf\":{");
     2c0:	00001617          	auipc	a2,0x1
     2c4:	4c860613          	addi	a2,a2,1224 # 1788 <malloc+0x194>
     2c8:	bbc40593          	addi	a1,s0,-1092
     2cc:	bc040513          	addi	a0,s0,-1088
     2d0:	d31ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"id\":"); append_int(buf, &pos, e->buf_id);
     2d4:	00001617          	auipc	a2,0x1
     2d8:	4c460613          	addi	a2,a2,1220 # 1798 <malloc+0x1a4>
     2dc:	bbc40593          	addi	a1,s0,-1092
     2e0:	bc040513          	addi	a0,s0,-1088
     2e4:	d1dff0ef          	jal	0 <append_str>
     2e8:	5490                	lw	a2,40(s1)
     2ea:	bbc40593          	addi	a1,s0,-1092
     2ee:	bc040513          	addi	a0,s0,-1088
     2f2:	dc7ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"block\":"); append_int(buf, &pos, e->blockno);
     2f6:	00001617          	auipc	a2,0x1
     2fa:	4aa60613          	addi	a2,a2,1194 # 17a0 <malloc+0x1ac>
     2fe:	bbc40593          	addi	a1,s0,-1092
     302:	bc040513          	addi	a0,s0,-1088
     306:	cfbff0ef          	jal	0 <append_str>
     30a:	50d0                	lw	a2,36(s1)
     30c:	bbc40593          	addi	a1,s0,-1092
     310:	bc040513          	addi	a0,s0,-1088
     314:	da5ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, "}");
     318:	00001617          	auipc	a2,0x1
     31c:	49860613          	addi	a2,a2,1176 # 17b0 <malloc+0x1bc>
     320:	bbc40593          	addi	a1,s0,-1092
     324:	bc040513          	addi	a0,s0,-1088
     328:	cd9ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"state\":{");
     32c:	00001617          	auipc	a2,0x1
     330:	48c60613          	addi	a2,a2,1164 # 17b8 <malloc+0x1c4>
     334:	bbc40593          	addi	a1,s0,-1092
     338:	bc040513          	addi	a0,s0,-1088
     33c:	cc5ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->refcnt);
     340:	00001617          	auipc	a2,0x1
     344:	48860613          	addi	a2,a2,1160 # 17c8 <malloc+0x1d4>
     348:	bbc40593          	addi	a1,s0,-1092
     34c:	bc040513          	addi	a0,s0,-1088
     350:	cb1ff0ef          	jal	0 <append_str>
     354:	02c4a983          	lw	s3,44(s1)
     358:	864e                	mv	a2,s3
     35a:	bbc40593          	addi	a1,s0,-1092
     35e:	bc040513          	addi	a0,s0,-1088
     362:	d57ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"valid\":"); append_int(buf, &pos, e->valid);
     366:	00001617          	auipc	a2,0x1
     36a:	46a60613          	addi	a2,a2,1130 # 17d0 <malloc+0x1dc>
     36e:	bbc40593          	addi	a1,s0,-1092
     372:	bc040513          	addi	a0,s0,-1088
     376:	c8bff0ef          	jal	0 <append_str>
     37a:	0344a903          	lw	s2,52(s1)
     37e:	864a                	mv	a2,s2
     380:	bbc40593          	addi	a1,s0,-1092
     384:	bc040513          	addi	a0,s0,-1088
     388:	d31ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, "}");
     38c:	00001617          	auipc	a2,0x1
     390:	42460613          	addi	a2,a2,1060 # 17b0 <malloc+0x1bc>
     394:	bbc40593          	addi	a1,s0,-1092
     398:	bc040513          	addi	a0,s0,-1088
     39c:	c65ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"changes\":{");
     3a0:	00001617          	auipc	a2,0x1
     3a4:	44060613          	addi	a2,a2,1088 # 17e0 <malloc+0x1ec>
     3a8:	bbc40593          	addi	a1,s0,-1092
     3ac:	bc040513          	addi	a0,s0,-1088
     3b0:	c51ff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "ref", e->old_refcnt, e->refcnt);
     3b4:	874e                	mv	a4,s3
     3b6:	5894                	lw	a3,48(s1)
     3b8:	00001617          	auipc	a2,0x1
     3bc:	43860613          	addi	a2,a2,1080 # 17f0 <malloc+0x1fc>
     3c0:	bbc40593          	addi	a1,s0,-1092
     3c4:	bc040513          	addi	a0,s0,-1088
     3c8:	d29ff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "valid", e->old_valid, e->valid);
     3cc:	874a                	mv	a4,s2
     3ce:	5c94                	lw	a3,56(s1)
     3d0:	00001617          	auipc	a2,0x1
     3d4:	42860613          	addi	a2,a2,1064 # 17f8 <malloc+0x204>
     3d8:	bbc40593          	addi	a1,s0,-1092
     3dc:	bc040513          	addi	a0,s0,-1088
     3e0:	d11ff0ef          	jal	f0 <print_change>

        if(buf[pos-1] == ',') pos--; // remove last comma
     3e4:	bbc42783          	lw	a5,-1092(s0)
     3e8:	37fd                	addiw	a5,a5,-1
     3ea:	0007871b          	sext.w	a4,a5
     3ee:	fc070713          	addi	a4,a4,-64
     3f2:	9722                	add	a4,a4,s0
     3f4:	c0074683          	lbu	a3,-1024(a4)
     3f8:	02c00713          	li	a4,44
     3fc:	1ae68fe3          	beq	a3,a4,dba <print_fs_event+0xc3c>
        append_str(buf, &pos, "}");
     400:	00001617          	auipc	a2,0x1
     404:	3b060613          	addi	a2,a2,944 # 17b0 <malloc+0x1bc>
     408:	bbc40593          	addi	a1,s0,-1092
     40c:	bc040513          	addi	a0,s0,-1088
     410:	bf1ff0ef          	jal	0 <append_str>
     414:	42813983          	ld	s3,1064(sp)
    if(buf[pos-1] == ',')
        pos--;

    append_str(buf, &pos, "}");
}
    append_str(buf, &pos, ",\"desc\":\"");
     418:	00001617          	auipc	a2,0x1
     41c:	55060613          	addi	a2,a2,1360 # 1968 <malloc+0x374>
     420:	bbc40593          	addi	a1,s0,-1092
     424:	bc040513          	addi	a0,s0,-1088
     428:	bd9ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->details);
     42c:	14848613          	addi	a2,s1,328
     430:	bbc40593          	addi	a1,s0,-1092
     434:	bc040513          	addi	a0,s0,-1088
     438:	bc9ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     43c:	00001617          	auipc	a2,0x1
     440:	2b460613          	addi	a2,a2,692 # 16f0 <malloc+0xfc>
     444:	bbc40593          	addi	a1,s0,-1092
     448:	bc040513          	addi	a0,s0,-1088
     44c:	bb5ff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "}\n");
     450:	00001617          	auipc	a2,0x1
     454:	52860613          	addi	a2,a2,1320 # 1978 <malloc+0x384>
     458:	bbc40593          	addi	a1,s0,-1092
     45c:	bc040513          	addi	a0,s0,-1088
     460:	ba1ff0ef          	jal	0 <append_str>

    write(1, buf, pos);
     464:	bbc42603          	lw	a2,-1092(s0)
     468:	bc040593          	addi	a1,s0,-1088
     46c:	4505                	li	a0,1
     46e:	4bb000ef          	jal	1128 <write>
}
     472:	44813083          	ld	ra,1096(sp)
     476:	44013403          	ld	s0,1088(sp)
     47a:	43813483          	ld	s1,1080(sp)
     47e:	43013903          	ld	s2,1072(sp)
     482:	45010113          	addi	sp,sp,1104
     486:	8082                	ret
     488:	43313423          	sd	s3,1064(sp)
     48c:	43413023          	sd	s4,1056(sp)
    append_str(buf, &pos, "LOG");
     490:	00001617          	auipc	a2,0x1
     494:	2c860613          	addi	a2,a2,712 # 1758 <malloc+0x164>
     498:	bbc40593          	addi	a1,s0,-1092
     49c:	bc040513          	addi	a0,s0,-1088
     4a0:	b61ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     4a4:	00001617          	auipc	a2,0x1
     4a8:	24c60613          	addi	a2,a2,588 # 16f0 <malloc+0xfc>
     4ac:	bbc40593          	addi	a1,s0,-1092
     4b0:	bc040513          	addi	a0,s0,-1088
     4b4:	b4dff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     4b8:	00001617          	auipc	a2,0x1
     4bc:	29860613          	addi	a2,a2,664 # 1750 <malloc+0x15c>
     4c0:	bbc40593          	addi	a1,s0,-1092
     4c4:	bc040513          	addi	a0,s0,-1088
     4c8:	b39ff0ef          	jal	0 <append_str>
     4cc:	01448613          	addi	a2,s1,20
     4d0:	bbc40593          	addi	a1,s0,-1092
     4d4:	bc040513          	addi	a0,s0,-1088
     4d8:	b29ff0ef          	jal	0 <append_str>
     4dc:	00001617          	auipc	a2,0x1
     4e0:	21460613          	addi	a2,a2,532 # 16f0 <malloc+0xfc>
     4e4:	bbc40593          	addi	a1,s0,-1092
     4e8:	bc040513          	addi	a0,s0,-1088
     4ec:	b15ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"state\":{");
     4f0:	00001617          	auipc	a2,0x1
     4f4:	2c860613          	addi	a2,a2,712 # 17b8 <malloc+0x1c4>
     4f8:	bbc40593          	addi	a1,s0,-1092
     4fc:	bc040513          	addi	a0,s0,-1088
     500:	b01ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"log_n\":"); append_int(buf, &pos, e->log_n);
     504:	00001617          	auipc	a2,0x1
     508:	2fc60613          	addi	a2,a2,764 # 1800 <malloc+0x20c>
     50c:	bbc40593          	addi	a1,s0,-1092
     510:	bc040513          	addi	a0,s0,-1088
     514:	aedff0ef          	jal	0 <append_str>
     518:	03c4aa03          	lw	s4,60(s1)
     51c:	8652                	mv	a2,s4
     51e:	bbc40593          	addi	a1,s0,-1092
     522:	bc040513          	addi	a0,s0,-1088
     526:	b93ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"outstanding\":"); append_int(buf, &pos, e->outstanding);
     52a:	00001617          	auipc	a2,0x1
     52e:	2e660613          	addi	a2,a2,742 # 1810 <malloc+0x21c>
     532:	bbc40593          	addi	a1,s0,-1092
     536:	bc040513          	addi	a0,s0,-1088
     53a:	ac7ff0ef          	jal	0 <append_str>
     53e:	0444a983          	lw	s3,68(s1)
     542:	864e                	mv	a2,s3
     544:	bbc40593          	addi	a1,s0,-1092
     548:	bc040513          	addi	a0,s0,-1088
     54c:	b6dff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"committing\":"); append_int(buf, &pos, e->committing);
     550:	00001617          	auipc	a2,0x1
     554:	2d060613          	addi	a2,a2,720 # 1820 <malloc+0x22c>
     558:	bbc40593          	addi	a1,s0,-1092
     55c:	bc040513          	addi	a0,s0,-1088
     560:	aa1ff0ef          	jal	0 <append_str>
     564:	04c4a903          	lw	s2,76(s1)
     568:	864a                	mv	a2,s2
     56a:	bbc40593          	addi	a1,s0,-1092
     56e:	bc040513          	addi	a0,s0,-1088
     572:	b47ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, "}");
     576:	00001617          	auipc	a2,0x1
     57a:	23a60613          	addi	a2,a2,570 # 17b0 <malloc+0x1bc>
     57e:	bbc40593          	addi	a1,s0,-1092
     582:	bc040513          	addi	a0,s0,-1088
     586:	a7bff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"changes\":{");
     58a:	00001617          	auipc	a2,0x1
     58e:	25660613          	addi	a2,a2,598 # 17e0 <malloc+0x1ec>
     592:	bbc40593          	addi	a1,s0,-1092
     596:	bc040513          	addi	a0,s0,-1088
     59a:	a67ff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "log_n", e->old_log_n, e->log_n);
     59e:	8752                	mv	a4,s4
     5a0:	40b4                	lw	a3,64(s1)
     5a2:	00001617          	auipc	a2,0x1
     5a6:	28e60613          	addi	a2,a2,654 # 1830 <malloc+0x23c>
     5aa:	bbc40593          	addi	a1,s0,-1092
     5ae:	bc040513          	addi	a0,s0,-1088
     5b2:	b3fff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "outstanding", e->old_outstanding, e->outstanding);
     5b6:	874e                	mv	a4,s3
     5b8:	44b4                	lw	a3,72(s1)
     5ba:	00001617          	auipc	a2,0x1
     5be:	27e60613          	addi	a2,a2,638 # 1838 <malloc+0x244>
     5c2:	bbc40593          	addi	a1,s0,-1092
     5c6:	bc040513          	addi	a0,s0,-1088
     5ca:	b27ff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "committing", e->old_committing, e->committing);
     5ce:	874a                	mv	a4,s2
     5d0:	48b4                	lw	a3,80(s1)
     5d2:	00001617          	auipc	a2,0x1
     5d6:	27660613          	addi	a2,a2,630 # 1848 <malloc+0x254>
     5da:	bbc40593          	addi	a1,s0,-1092
     5de:	bc040513          	addi	a0,s0,-1088
     5e2:	b0fff0ef          	jal	f0 <print_change>
        if(buf[pos-1] == ',') pos--;
     5e6:	bbc42783          	lw	a5,-1092(s0)
     5ea:	37fd                	addiw	a5,a5,-1
     5ec:	0007871b          	sext.w	a4,a5
     5f0:	fc070713          	addi	a4,a4,-64
     5f4:	9722                	add	a4,a4,s0
     5f6:	c0074683          	lbu	a3,-1024(a4)
     5fa:	02c00713          	li	a4,44
     5fe:	7ce68863          	beq	a3,a4,dce <print_fs_event+0xc50>
        append_str(buf, &pos, "}");
     602:	00001617          	auipc	a2,0x1
     606:	1ae60613          	addi	a2,a2,430 # 17b0 <malloc+0x1bc>
     60a:	bbc40593          	addi	a1,s0,-1092
     60e:	bc040513          	addi	a0,s0,-1088
     612:	9efff0ef          	jal	0 <append_str>
     616:	42813983          	ld	s3,1064(sp)
     61a:	42013a03          	ld	s4,1056(sp)
     61e:	bbed                	j	418 <print_fs_event+0x29a>
    append_str(buf, &pos, "BALLOC");
     620:	00001617          	auipc	a2,0x1
     624:	14060613          	addi	a2,a2,320 # 1760 <malloc+0x16c>
     628:	bbc40593          	addi	a1,s0,-1092
     62c:	bc040513          	addi	a0,s0,-1088
     630:	9d1ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     634:	00001617          	auipc	a2,0x1
     638:	0bc60613          	addi	a2,a2,188 # 16f0 <malloc+0xfc>
     63c:	bbc40593          	addi	a1,s0,-1092
     640:	bc040513          	addi	a0,s0,-1088
     644:	9bdff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     648:	00001617          	auipc	a2,0x1
     64c:	10860613          	addi	a2,a2,264 # 1750 <malloc+0x15c>
     650:	bbc40593          	addi	a1,s0,-1092
     654:	bc040513          	addi	a0,s0,-1088
     658:	9a9ff0ef          	jal	0 <append_str>
     65c:	01448613          	addi	a2,s1,20
     660:	bbc40593          	addi	a1,s0,-1092
     664:	bc040513          	addi	a0,s0,-1088
     668:	999ff0ef          	jal	0 <append_str>
     66c:	00001617          	auipc	a2,0x1
     670:	08460613          	addi	a2,a2,132 # 16f0 <malloc+0xfc>
     674:	bbc40593          	addi	a1,s0,-1092
     678:	bc040513          	addi	a0,s0,-1088
     67c:	985ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"block\":");
     680:	00001617          	auipc	a2,0x1
     684:	12060613          	addi	a2,a2,288 # 17a0 <malloc+0x1ac>
     688:	bbc40593          	addi	a1,s0,-1092
     68c:	bc040513          	addi	a0,s0,-1088
     690:	971ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->blockno);
     694:	50d0                	lw	a2,36(s1)
     696:	bbc40593          	addi	a1,s0,-1092
     69a:	bc040513          	addi	a0,s0,-1088
     69e:	a1bff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"state\":{");
     6a2:	00001617          	auipc	a2,0x1
     6a6:	11660613          	addi	a2,a2,278 # 17b8 <malloc+0x1c4>
     6aa:	bbc40593          	addi	a1,s0,-1092
     6ae:	bc040513          	addi	a0,s0,-1088
     6b2:	94fff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"bit\":");
     6b6:	00001617          	auipc	a2,0x1
     6ba:	1a260613          	addi	a2,a2,418 # 1858 <malloc+0x264>
     6be:	bbc40593          	addi	a1,s0,-1092
     6c2:	bc040513          	addi	a0,s0,-1088
     6c6:	93bff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->bit);
     6ca:	0544a903          	lw	s2,84(s1)
     6ce:	864a                	mv	a2,s2
     6d0:	bbc40593          	addi	a1,s0,-1092
     6d4:	bc040513          	addi	a0,s0,-1088
     6d8:	9e1ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     6dc:	00001617          	auipc	a2,0x1
     6e0:	0d460613          	addi	a2,a2,212 # 17b0 <malloc+0x1bc>
     6e4:	bbc40593          	addi	a1,s0,-1092
     6e8:	bc040513          	addi	a0,s0,-1088
     6ec:	915ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     6f0:	00001617          	auipc	a2,0x1
     6f4:	0f060613          	addi	a2,a2,240 # 17e0 <malloc+0x1ec>
     6f8:	bbc40593          	addi	a1,s0,-1092
     6fc:	bc040513          	addi	a0,s0,-1088
     700:	901ff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "bit", e->old_bit, e->bit);
     704:	874a                	mv	a4,s2
     706:	4cb4                	lw	a3,88(s1)
     708:	00001617          	auipc	a2,0x1
     70c:	15860613          	addi	a2,a2,344 # 1860 <malloc+0x26c>
     710:	bbc40593          	addi	a1,s0,-1092
     714:	bc040513          	addi	a0,s0,-1088
     718:	9d9ff0ef          	jal	f0 <print_change>
    if(buf[pos-1] == ',') pos--;
     71c:	bbc42783          	lw	a5,-1092(s0)
     720:	37fd                	addiw	a5,a5,-1
     722:	0007871b          	sext.w	a4,a5
     726:	fc070713          	addi	a4,a4,-64
     72a:	9722                	add	a4,a4,s0
     72c:	c0074683          	lbu	a3,-1024(a4)
     730:	02c00713          	li	a4,44
     734:	6ae68163          	beq	a3,a4,dd6 <print_fs_event+0xc58>
    append_str(buf, &pos, "}");
     738:	00001617          	auipc	a2,0x1
     73c:	07860613          	addi	a2,a2,120 # 17b0 <malloc+0x1bc>
     740:	bbc40593          	addi	a1,s0,-1092
     744:	bc040513          	addi	a0,s0,-1088
     748:	8b9ff0ef          	jal	0 <append_str>
     74c:	b1f1                	j	418 <print_fs_event+0x29a>
     74e:	43313423          	sd	s3,1064(sp)
     752:	43413023          	sd	s4,1056(sp)
     756:	41513c23          	sd	s5,1048(sp)
     75a:	41613823          	sd	s6,1040(sp)
    append_str(buf, &pos, "INODE");
     75e:	00001617          	auipc	a2,0x1
     762:	00a60613          	addi	a2,a2,10 # 1768 <malloc+0x174>
     766:	bbc40593          	addi	a1,s0,-1092
     76a:	bc040513          	addi	a0,s0,-1088
     76e:	893ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     772:	00001617          	auipc	a2,0x1
     776:	f7e60613          	addi	a2,a2,-130 # 16f0 <malloc+0xfc>
     77a:	bbc40593          	addi	a1,s0,-1092
     77e:	bc040513          	addi	a0,s0,-1088
     782:	87fff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     786:	00001617          	auipc	a2,0x1
     78a:	fca60613          	addi	a2,a2,-54 # 1750 <malloc+0x15c>
     78e:	bbc40593          	addi	a1,s0,-1092
     792:	bc040513          	addi	a0,s0,-1088
     796:	86bff0ef          	jal	0 <append_str>
     79a:	01448613          	addi	a2,s1,20
     79e:	bbc40593          	addi	a1,s0,-1092
     7a2:	bc040513          	addi	a0,s0,-1088
     7a6:	85bff0ef          	jal	0 <append_str>
     7aa:	00001617          	auipc	a2,0x1
     7ae:	f4660613          	addi	a2,a2,-186 # 16f0 <malloc+0xfc>
     7b2:	bbc40593          	addi	a1,s0,-1092
     7b6:	bc040513          	addi	a0,s0,-1088
     7ba:	847ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"inode\":{");
     7be:	00001617          	auipc	a2,0x1
     7c2:	0aa60613          	addi	a2,a2,170 # 1868 <malloc+0x274>
     7c6:	bbc40593          	addi	a1,s0,-1092
     7ca:	bc040513          	addi	a0,s0,-1088
     7ce:	833ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"inum\":"); append_int(buf, &pos, e->inum);
     7d2:	00001617          	auipc	a2,0x1
     7d6:	0a660613          	addi	a2,a2,166 # 1878 <malloc+0x284>
     7da:	bbc40593          	addi	a1,s0,-1092
     7de:	bc040513          	addi	a0,s0,-1088
     7e2:	81fff0ef          	jal	0 <append_str>
     7e6:	4cf0                	lw	a2,92(s1)
     7e8:	bbc40593          	addi	a1,s0,-1092
     7ec:	bc040513          	addi	a0,s0,-1088
     7f0:	8c9ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     7f4:	00001617          	auipc	a2,0x1
     7f8:	fbc60613          	addi	a2,a2,-68 # 17b0 <malloc+0x1bc>
     7fc:	bbc40593          	addi	a1,s0,-1092
     800:	bc040513          	addi	a0,s0,-1088
     804:	ffcff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"state\":{");
     808:	00001617          	auipc	a2,0x1
     80c:	fb060613          	addi	a2,a2,-80 # 17b8 <malloc+0x1c4>
     810:	bbc40593          	addi	a1,s0,-1092
     814:	bc040513          	addi	a0,s0,-1088
     818:	fe8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->ref);
     81c:	00001617          	auipc	a2,0x1
     820:	fac60613          	addi	a2,a2,-84 # 17c8 <malloc+0x1d4>
     824:	bbc40593          	addi	a1,s0,-1092
     828:	bc040513          	addi	a0,s0,-1088
     82c:	fd4ff0ef          	jal	0 <append_str>
     830:	0604ab03          	lw	s6,96(s1)
     834:	865a                	mv	a2,s6
     836:	bbc40593          	addi	a1,s0,-1092
     83a:	bc040513          	addi	a0,s0,-1088
     83e:	87bff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"valid\":"); append_int(buf, &pos, e->valid_inode);
     842:	00001617          	auipc	a2,0x1
     846:	f8e60613          	addi	a2,a2,-114 # 17d0 <malloc+0x1dc>
     84a:	bbc40593          	addi	a1,s0,-1092
     84e:	bc040513          	addi	a0,s0,-1088
     852:	faeff0ef          	jal	0 <append_str>
     856:	0684aa83          	lw	s5,104(s1)
     85a:	8656                	mv	a2,s5
     85c:	bbc40593          	addi	a1,s0,-1092
     860:	bc040513          	addi	a0,s0,-1088
     864:	855ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"type\":"); append_int(buf, &pos, e->type_inode);
     868:	00001617          	auipc	a2,0x1
     86c:	01860613          	addi	a2,a2,24 # 1880 <malloc+0x28c>
     870:	bbc40593          	addi	a1,s0,-1092
     874:	bc040513          	addi	a0,s0,-1088
     878:	f88ff0ef          	jal	0 <append_str>
     87c:	0704aa03          	lw	s4,112(s1)
     880:	8652                	mv	a2,s4
     882:	bbc40593          	addi	a1,s0,-1092
     886:	bc040513          	addi	a0,s0,-1088
     88a:	82fff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"size\":"); append_int(buf, &pos, e->size);
     88e:	00001617          	auipc	a2,0x1
     892:	00260613          	addi	a2,a2,2 # 1890 <malloc+0x29c>
     896:	bbc40593          	addi	a1,s0,-1092
     89a:	bc040513          	addi	a0,s0,-1088
     89e:	f62ff0ef          	jal	0 <append_str>
     8a2:	0784a983          	lw	s3,120(s1)
     8a6:	864e                	mv	a2,s3
     8a8:	bbc40593          	addi	a1,s0,-1092
     8ac:	bc040513          	addi	a0,s0,-1088
     8b0:	809ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"locked\":"); append_int(buf, &pos, e->locked);
     8b4:	00001617          	auipc	a2,0x1
     8b8:	fec60613          	addi	a2,a2,-20 # 18a0 <malloc+0x2ac>
     8bc:	bbc40593          	addi	a1,s0,-1092
     8c0:	bc040513          	addi	a0,s0,-1088
     8c4:	f3cff0ef          	jal	0 <append_str>
     8c8:	0804a903          	lw	s2,128(s1)
     8cc:	864a                	mv	a2,s2
     8ce:	bbc40593          	addi	a1,s0,-1092
     8d2:	bc040513          	addi	a0,s0,-1088
     8d6:	fe2ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     8da:	00001617          	auipc	a2,0x1
     8de:	ed660613          	addi	a2,a2,-298 # 17b0 <malloc+0x1bc>
     8e2:	bbc40593          	addi	a1,s0,-1092
     8e6:	bc040513          	addi	a0,s0,-1088
     8ea:	f16ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     8ee:	00001617          	auipc	a2,0x1
     8f2:	ef260613          	addi	a2,a2,-270 # 17e0 <malloc+0x1ec>
     8f6:	bbc40593          	addi	a1,s0,-1092
     8fa:	bc040513          	addi	a0,s0,-1088
     8fe:	f02ff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "ref", e->old_ref, e->ref);
     902:	875a                	mv	a4,s6
     904:	50f4                	lw	a3,100(s1)
     906:	00001617          	auipc	a2,0x1
     90a:	eea60613          	addi	a2,a2,-278 # 17f0 <malloc+0x1fc>
     90e:	bbc40593          	addi	a1,s0,-1092
     912:	bc040513          	addi	a0,s0,-1088
     916:	fdaff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "valid", e->old_valid_inode, e->valid_inode);
     91a:	8756                	mv	a4,s5
     91c:	54f4                	lw	a3,108(s1)
     91e:	00001617          	auipc	a2,0x1
     922:	eda60613          	addi	a2,a2,-294 # 17f8 <malloc+0x204>
     926:	bbc40593          	addi	a1,s0,-1092
     92a:	bc040513          	addi	a0,s0,-1088
     92e:	fc2ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "type", e->old_type_inode, e->type_inode);
     932:	8752                	mv	a4,s4
     934:	58f4                	lw	a3,116(s1)
     936:	00001617          	auipc	a2,0x1
     93a:	f7a60613          	addi	a2,a2,-134 # 18b0 <malloc+0x2bc>
     93e:	bbc40593          	addi	a1,s0,-1092
     942:	bc040513          	addi	a0,s0,-1088
     946:	faaff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "size", e->old_size, e->size);
     94a:	874e                	mv	a4,s3
     94c:	5cf4                	lw	a3,124(s1)
     94e:	00001617          	auipc	a2,0x1
     952:	f6a60613          	addi	a2,a2,-150 # 18b8 <malloc+0x2c4>
     956:	bbc40593          	addi	a1,s0,-1092
     95a:	bc040513          	addi	a0,s0,-1088
     95e:	f92ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "locked", e->old_locked, e->locked);
     962:	874a                	mv	a4,s2
     964:	0844a683          	lw	a3,132(s1)
     968:	00001617          	auipc	a2,0x1
     96c:	f5860613          	addi	a2,a2,-168 # 18c0 <malloc+0x2cc>
     970:	bbc40593          	addi	a1,s0,-1092
     974:	bc040513          	addi	a0,s0,-1088
     978:	f78ff0ef          	jal	f0 <print_change>
    if(buf[pos-1] == ',') pos--;
     97c:	bbc42783          	lw	a5,-1092(s0)
     980:	37fd                	addiw	a5,a5,-1
     982:	0007871b          	sext.w	a4,a5
     986:	fc070713          	addi	a4,a4,-64
     98a:	9722                	add	a4,a4,s0
     98c:	c0074683          	lbu	a3,-1024(a4)
     990:	02c00713          	li	a4,44
     994:	44e68d63          	beq	a3,a4,dee <print_fs_event+0xc70>
    append_str(buf, &pos, "}");
     998:	00001617          	auipc	a2,0x1
     99c:	e1860613          	addi	a2,a2,-488 # 17b0 <malloc+0x1bc>
     9a0:	bbc40593          	addi	a1,s0,-1092
     9a4:	bc040513          	addi	a0,s0,-1088
     9a8:	e58ff0ef          	jal	0 <append_str>
     9ac:	42813983          	ld	s3,1064(sp)
     9b0:	42013a03          	ld	s4,1056(sp)
     9b4:	41813a83          	ld	s5,1048(sp)
     9b8:	41013b03          	ld	s6,1040(sp)
     9bc:	bcb1                	j	418 <print_fs_event+0x29a>
    append_str(buf, &pos, "DIR");
     9be:	00001617          	auipc	a2,0x1
     9c2:	db260613          	addi	a2,a2,-590 # 1770 <malloc+0x17c>
     9c6:	bbc40593          	addi	a1,s0,-1092
     9ca:	bc040513          	addi	a0,s0,-1088
     9ce:	e32ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     9d2:	00001617          	auipc	a2,0x1
     9d6:	d1e60613          	addi	a2,a2,-738 # 16f0 <malloc+0xfc>
     9da:	bbc40593          	addi	a1,s0,-1092
     9de:	bc040513          	addi	a0,s0,-1088
     9e2:	e1eff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     9e6:	00001617          	auipc	a2,0x1
     9ea:	d6a60613          	addi	a2,a2,-662 # 1750 <malloc+0x15c>
     9ee:	bbc40593          	addi	a1,s0,-1092
     9f2:	bc040513          	addi	a0,s0,-1088
     9f6:	e0aff0ef          	jal	0 <append_str>
     9fa:	01448613          	addi	a2,s1,20
     9fe:	bbc40593          	addi	a1,s0,-1092
     a02:	bc040513          	addi	a0,s0,-1088
     a06:	dfaff0ef          	jal	0 <append_str>
     a0a:	00001617          	auipc	a2,0x1
     a0e:	ce660613          	addi	a2,a2,-794 # 16f0 <malloc+0xfc>
     a12:	bbc40593          	addi	a1,s0,-1092
     a16:	bc040513          	addi	a0,s0,-1088
     a1a:	de6ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"dir\":{");
     a1e:	00001617          	auipc	a2,0x1
     a22:	eaa60613          	addi	a2,a2,-342 # 18c8 <malloc+0x2d4>
     a26:	bbc40593          	addi	a1,s0,-1092
     a2a:	bc040513          	addi	a0,s0,-1088
     a2e:	dd2ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"parent\":");
     a32:	00001617          	auipc	a2,0x1
     a36:	ea660613          	addi	a2,a2,-346 # 18d8 <malloc+0x2e4>
     a3a:	bbc40593          	addi	a1,s0,-1092
     a3e:	bc040513          	addi	a0,s0,-1088
     a42:	dbeff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->parent_inum);
     a46:	11c4a603          	lw	a2,284(s1)
     a4a:	bbc40593          	addi	a1,s0,-1092
     a4e:	bc040513          	addi	a0,s0,-1088
     a52:	e66ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"target\":");
     a56:	00001617          	auipc	a2,0x1
     a5a:	e9260613          	addi	a2,a2,-366 # 18e8 <malloc+0x2f4>
     a5e:	bbc40593          	addi	a1,s0,-1092
     a62:	bc040513          	addi	a0,s0,-1088
     a66:	d9aff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->target_inum);
     a6a:	1204a603          	lw	a2,288(s1)
     a6e:	bbc40593          	addi	a1,s0,-1092
     a72:	bc040513          	addi	a0,s0,-1088
     a76:	e42ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"offset\":");
     a7a:	00001617          	auipc	a2,0x1
     a7e:	e7e60613          	addi	a2,a2,-386 # 18f8 <malloc+0x304>
     a82:	bbc40593          	addi	a1,s0,-1092
     a86:	bc040513          	addi	a0,s0,-1088
     a8a:	d76ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->offset);
     a8e:	1244a603          	lw	a2,292(s1)
     a92:	bbc40593          	addi	a1,s0,-1092
     a96:	bc040513          	addi	a0,s0,-1088
     a9a:	e1eff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"name\":\"");
     a9e:	00001617          	auipc	a2,0x1
     aa2:	e6a60613          	addi	a2,a2,-406 # 1908 <malloc+0x314>
     aa6:	bbc40593          	addi	a1,s0,-1092
     aaa:	bc040513          	addi	a0,s0,-1088
     aae:	d52ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
     ab2:	10848613          	addi	a2,s1,264
     ab6:	bbc40593          	addi	a1,s0,-1092
     aba:	bc040513          	addi	a0,s0,-1088
     abe:	d42ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"}");
     ac2:	00001617          	auipc	a2,0x1
     ac6:	e5660613          	addi	a2,a2,-426 # 1918 <malloc+0x324>
     aca:	bbc40593          	addi	a1,s0,-1092
     ace:	bc040513          	addi	a0,s0,-1088
     ad2:	d2eff0ef          	jal	0 <append_str>
     ad6:	b289                	j	418 <print_fs_event+0x29a>
    append_str(buf, &pos, "PATH");
     ad8:	00001617          	auipc	a2,0x1
     adc:	ca060613          	addi	a2,a2,-864 # 1778 <malloc+0x184>
     ae0:	bbc40593          	addi	a1,s0,-1092
     ae4:	bc040513          	addi	a0,s0,-1088
     ae8:	d18ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     aec:	00001617          	auipc	a2,0x1
     af0:	c0460613          	addi	a2,a2,-1020 # 16f0 <malloc+0xfc>
     af4:	bbc40593          	addi	a1,s0,-1092
     af8:	bc040513          	addi	a0,s0,-1088
     afc:	d04ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     b00:	00001617          	auipc	a2,0x1
     b04:	c5060613          	addi	a2,a2,-944 # 1750 <malloc+0x15c>
     b08:	bbc40593          	addi	a1,s0,-1092
     b0c:	bc040513          	addi	a0,s0,-1088
     b10:	cf0ff0ef          	jal	0 <append_str>
     b14:	01448613          	addi	a2,s1,20
     b18:	bbc40593          	addi	a1,s0,-1092
     b1c:	bc040513          	addi	a0,s0,-1088
     b20:	ce0ff0ef          	jal	0 <append_str>
     b24:	00001617          	auipc	a2,0x1
     b28:	bcc60613          	addi	a2,a2,-1076 # 16f0 <malloc+0xfc>
     b2c:	bbc40593          	addi	a1,s0,-1092
     b30:	bc040513          	addi	a0,s0,-1088
     b34:	cccff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"path\":\"");
     b38:	00001617          	auipc	a2,0x1
     b3c:	de860613          	addi	a2,a2,-536 # 1920 <malloc+0x32c>
     b40:	bbc40593          	addi	a1,s0,-1092
     b44:	bc040513          	addi	a0,s0,-1088
     b48:	cb8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->path);
     b4c:	08848613          	addi	a2,s1,136
     b50:	bbc40593          	addi	a1,s0,-1092
     b54:	bc040513          	addi	a0,s0,-1088
     b58:	ca8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     b5c:	00001617          	auipc	a2,0x1
     b60:	b9460613          	addi	a2,a2,-1132 # 16f0 <malloc+0xfc>
     b64:	bbc40593          	addi	a1,s0,-1092
     b68:	bc040513          	addi	a0,s0,-1088
     b6c:	c94ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"elem\":\"");
     b70:	00001617          	auipc	a2,0x1
     b74:	dc060613          	addi	a2,a2,-576 # 1930 <malloc+0x33c>
     b78:	bbc40593          	addi	a1,s0,-1092
     b7c:	bc040513          	addi	a0,s0,-1088
     b80:	c80ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
     b84:	10848613          	addi	a2,s1,264
     b88:	bbc40593          	addi	a1,s0,-1092
     b8c:	bc040513          	addi	a0,s0,-1088
     b90:	c70ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     b94:	00001617          	auipc	a2,0x1
     b98:	b5c60613          	addi	a2,a2,-1188 # 16f0 <malloc+0xfc>
     b9c:	bbc40593          	addi	a1,s0,-1092
     ba0:	bc040513          	addi	a0,s0,-1088
     ba4:	c5cff0ef          	jal	0 <append_str>
     ba8:	871ff06f          	j	418 <print_fs_event+0x29a>
     bac:	43313423          	sd	s3,1064(sp)
    append_str(buf, &pos, "FILE");
     bb0:	00001617          	auipc	a2,0x1
     bb4:	bd060613          	addi	a2,a2,-1072 # 1780 <malloc+0x18c>
     bb8:	bbc40593          	addi	a1,s0,-1092
     bbc:	bc040513          	addi	a0,s0,-1088
     bc0:	c40ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     bc4:	00001617          	auipc	a2,0x1
     bc8:	b2c60613          	addi	a2,a2,-1236 # 16f0 <malloc+0xfc>
     bcc:	bbc40593          	addi	a1,s0,-1092
     bd0:	bc040513          	addi	a0,s0,-1088
     bd4:	c2cff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     bd8:	00001617          	auipc	a2,0x1
     bdc:	b7860613          	addi	a2,a2,-1160 # 1750 <malloc+0x15c>
     be0:	bbc40593          	addi	a1,s0,-1092
     be4:	bc040513          	addi	a0,s0,-1088
     be8:	c18ff0ef          	jal	0 <append_str>
     bec:	01448613          	addi	a2,s1,20
     bf0:	bbc40593          	addi	a1,s0,-1092
     bf4:	bc040513          	addi	a0,s0,-1088
     bf8:	c08ff0ef          	jal	0 <append_str>
     bfc:	00001617          	auipc	a2,0x1
     c00:	af460613          	addi	a2,a2,-1292 # 16f0 <malloc+0xfc>
     c04:	bbc40593          	addi	a1,s0,-1092
     c08:	bc040513          	addi	a0,s0,-1088
     c0c:	bf4ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"state\":{");
     c10:	00001617          	auipc	a2,0x1
     c14:	ba860613          	addi	a2,a2,-1112 # 17b8 <malloc+0x1c4>
     c18:	bbc40593          	addi	a1,s0,-1092
     c1c:	bc040513          	addi	a0,s0,-1088
     c20:	be0ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":");
     c24:	00001617          	auipc	a2,0x1
     c28:	ba460613          	addi	a2,a2,-1116 # 17c8 <malloc+0x1d4>
     c2c:	bbc40593          	addi	a1,s0,-1092
     c30:	bc040513          	addi	a0,s0,-1088
     c34:	bccff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file_ref);
     c38:	1384a983          	lw	s3,312(s1)
     c3c:	864e                	mv	a2,s3
     c3e:	bbc40593          	addi	a1,s0,-1092
     c42:	bc040513          	addi	a0,s0,-1088
     c46:	c72ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"offset\":");
     c4a:	00001617          	auipc	a2,0x1
     c4e:	cae60613          	addi	a2,a2,-850 # 18f8 <malloc+0x304>
     c52:	bbc40593          	addi	a1,s0,-1092
     c56:	bc040513          	addi	a0,s0,-1088
     c5a:	ba6ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file_off);
     c5e:	1404a903          	lw	s2,320(s1)
     c62:	864a                	mv	a2,s2
     c64:	bbc40593          	addi	a1,s0,-1092
     c68:	bc040513          	addi	a0,s0,-1088
     c6c:	c4cff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"readable\":");
     c70:	00001617          	auipc	a2,0x1
     c74:	cd060613          	addi	a2,a2,-816 # 1940 <malloc+0x34c>
     c78:	bbc40593          	addi	a1,s0,-1092
     c7c:	bc040513          	addi	a0,s0,-1088
     c80:	b80ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->readable);
     c84:	1304a603          	lw	a2,304(s1)
     c88:	bbc40593          	addi	a1,s0,-1092
     c8c:	bc040513          	addi	a0,s0,-1088
     c90:	c28ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"writable\":");
     c94:	00001617          	auipc	a2,0x1
     c98:	cbc60613          	addi	a2,a2,-836 # 1950 <malloc+0x35c>
     c9c:	bbc40593          	addi	a1,s0,-1092
     ca0:	bc040513          	addi	a0,s0,-1088
     ca4:	b5cff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->writable);
     ca8:	1344a603          	lw	a2,308(s1)
     cac:	bbc40593          	addi	a1,s0,-1092
     cb0:	bc040513          	addi	a0,s0,-1088
     cb4:	c04ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     cb8:	00001617          	auipc	a2,0x1
     cbc:	af860613          	addi	a2,a2,-1288 # 17b0 <malloc+0x1bc>
     cc0:	bbc40593          	addi	a1,s0,-1092
     cc4:	bc040513          	addi	a0,s0,-1088
     cc8:	b38ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     ccc:	00001617          	auipc	a2,0x1
     cd0:	b1460613          	addi	a2,a2,-1260 # 17e0 <malloc+0x1ec>
     cd4:	bbc40593          	addi	a1,s0,-1092
     cd8:	bc040513          	addi	a0,s0,-1088
     cdc:	b24ff0ef          	jal	0 <append_str>
    print_change(buf, &pos,
     ce0:	874e                	mv	a4,s3
     ce2:	13c4a683          	lw	a3,316(s1)
     ce6:	00001617          	auipc	a2,0x1
     cea:	b0a60613          	addi	a2,a2,-1270 # 17f0 <malloc+0x1fc>
     cee:	bbc40593          	addi	a1,s0,-1092
     cf2:	bc040513          	addi	a0,s0,-1088
     cf6:	bfaff0ef          	jal	f0 <print_change>
    print_change(buf, &pos,
     cfa:	874a                	mv	a4,s2
     cfc:	1444a683          	lw	a3,324(s1)
     d00:	00001617          	auipc	a2,0x1
     d04:	c6060613          	addi	a2,a2,-928 # 1960 <malloc+0x36c>
     d08:	bbc40593          	addi	a1,s0,-1092
     d0c:	bc040513          	addi	a0,s0,-1088
     d10:	be0ff0ef          	jal	f0 <print_change>
    if(buf[pos-1] == ',')
     d14:	bbc42783          	lw	a5,-1092(s0)
     d18:	37fd                	addiw	a5,a5,-1
     d1a:	0007871b          	sext.w	a4,a5
     d1e:	fc070713          	addi	a4,a4,-64
     d22:	9722                	add	a4,a4,s0
     d24:	c0074683          	lbu	a3,-1024(a4)
     d28:	02c00713          	li	a4,44
     d2c:	0ce68763          	beq	a3,a4,dfa <print_fs_event+0xc7c>
    append_str(buf, &pos, "}");
     d30:	00001617          	auipc	a2,0x1
     d34:	a8060613          	addi	a2,a2,-1408 # 17b0 <malloc+0x1bc>
     d38:	bbc40593          	addi	a1,s0,-1092
     d3c:	bc040513          	addi	a0,s0,-1088
     d40:	ac0ff0ef          	jal	0 <append_str>
     d44:	42813983          	ld	s3,1064(sp)
     d48:	ed0ff06f          	j	418 <print_fs_event+0x29a>
    append_str(buf, &pos, "\"");
     d4c:	00001617          	auipc	a2,0x1
     d50:	9a460613          	addi	a2,a2,-1628 # 16f0 <malloc+0xfc>
     d54:	bbc40593          	addi	a1,s0,-1092
     d58:	bc040513          	addi	a0,s0,-1088
     d5c:	aa4ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     d60:	00001617          	auipc	a2,0x1
     d64:	9f060613          	addi	a2,a2,-1552 # 1750 <malloc+0x15c>
     d68:	bbc40593          	addi	a1,s0,-1092
     d6c:	bc040513          	addi	a0,s0,-1088
     d70:	a90ff0ef          	jal	0 <append_str>
     d74:	01448613          	addi	a2,s1,20
     d78:	bbc40593          	addi	a1,s0,-1092
     d7c:	bc040513          	addi	a0,s0,-1088
     d80:	a80ff0ef          	jal	0 <append_str>
     d84:	00001617          	auipc	a2,0x1
     d88:	96c60613          	addi	a2,a2,-1684 # 16f0 <malloc+0xfc>
     d8c:	bbc40593          	addi	a1,s0,-1092
     d90:	bc040513          	addi	a0,s0,-1088
     d94:	a6cff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE){
     d98:	479d                	li	a5,7
     d9a:	e727ef63          	bltu	a5,s2,418 <print_fs_event+0x29a>
     d9e:	090a                	slli	s2,s2,0x2
     da0:	00001717          	auipc	a4,0x1
     da4:	c5070713          	addi	a4,a4,-944 # 19f0 <malloc+0x3fc>
     da8:	993a                	add	s2,s2,a4
     daa:	00092783          	lw	a5,0(s2)
     dae:	97ba                	add	a5,a5,a4
     db0:	8782                	jr	a5
     db2:	43313423          	sd	s3,1064(sp)
     db6:	d0aff06f          	j	2c0 <print_fs_event+0x142>
        if(buf[pos-1] == ',') pos--; // remove last comma
     dba:	baf42e23          	sw	a5,-1092(s0)
     dbe:	e42ff06f          	j	400 <print_fs_event+0x282>
     dc2:	43313423          	sd	s3,1064(sp)
     dc6:	43413023          	sd	s4,1056(sp)
     dca:	f26ff06f          	j	4f0 <print_fs_event+0x372>
        if(buf[pos-1] == ',') pos--;
     dce:	baf42e23          	sw	a5,-1092(s0)
     dd2:	831ff06f          	j	602 <print_fs_event+0x484>
    if(buf[pos-1] == ',') pos--;
     dd6:	baf42e23          	sw	a5,-1092(s0)
     dda:	bab9                	j	738 <print_fs_event+0x5ba>
     ddc:	43313423          	sd	s3,1064(sp)
     de0:	43413023          	sd	s4,1056(sp)
     de4:	41513c23          	sd	s5,1048(sp)
     de8:	41613823          	sd	s6,1040(sp)
     dec:	bac9                	j	7be <print_fs_event+0x640>
    if(buf[pos-1] == ',') pos--;
     dee:	baf42e23          	sw	a5,-1092(s0)
     df2:	b65d                	j	998 <print_fs_event+0x81a>
     df4:	43313423          	sd	s3,1064(sp)
     df8:	bd21                	j	c10 <print_fs_event+0xa92>
        pos--;
     dfa:	baf42e23          	sw	a5,-1092(s0)
     dfe:	bf0d                	j	d30 <print_fs_event+0xbb2>

0000000000000e00 <main>:

int main(void) {
     e00:	7179                	addi	sp,sp,-48
     e02:	f406                	sd	ra,40(sp)
     e04:	f022                	sd	s0,32(sp)
     e06:	ec26                	sd	s1,24(sp)
     e08:	e84a                	sd	s2,16(sp)
     e0a:	e44e                	sd	s3,8(sp)
     e0c:	e052                	sd	s4,0(sp)
     e0e:	1800                	addi	s0,sp,48
    printf("FS Buffer Cache Export starting...\n");
     e10:	00001517          	auipc	a0,0x1
     e14:	b7050513          	addi	a0,a0,-1168 # 1980 <malloc+0x38c>
     e18:	728000ef          	jal	1540 <printf>
    
    while (1) {
        int n_fs = fsread(fs_ev, 16);
     e1c:	00001997          	auipc	s3,0x1
     e20:	1f498993          	addi	s3,s3,500 # 2010 <fs_ev>
     e24:	1c800a13          	li	s4,456
     e28:	a831                	j	e44 <main+0x44>
        if (n_fs < 0) {
            fprintf(2, "fsexport: error reading fslog\n");
     e2a:	00001597          	auipc	a1,0x1
     e2e:	b7e58593          	addi	a1,a1,-1154 # 19a8 <malloc+0x3b4>
     e32:	4509                	li	a0,2
     e34:	6e2000ef          	jal	1516 <fprintf>
            exit(1);
     e38:	4505                	li	a0,1
     e3a:	2ce000ef          	jal	1108 <exit>
        for (int i = 0; i < n_fs; i++) {
            print_fs_event(&fs_ev[i]);
        }

        // استخدام sleep(2) بدلاً من pause في xv6 لضمان استمرار الحلقة
        pause(2); 
     e3e:	4509                	li	a0,2
     e40:	358000ef          	jal	1198 <pause>
        int n_fs = fsread(fs_ev, 16);
     e44:	45c1                	li	a1,16
     e46:	854e                	mv	a0,s3
     e48:	368000ef          	jal	11b0 <fsread>
        if (n_fs < 0) {
     e4c:	fc054fe3          	bltz	a0,e2a <main+0x2a>
        for (int i = 0; i < n_fs; i++) {
     e50:	fea057e3          	blez	a0,e3e <main+0x3e>
     e54:	00001497          	auipc	s1,0x1
     e58:	1bc48493          	addi	s1,s1,444 # 2010 <fs_ev>
     e5c:	03450533          	mul	a0,a0,s4
     e60:	00950933          	add	s2,a0,s1
            print_fs_event(&fs_ev[i]);
     e64:	8526                	mv	a0,s1
     e66:	b18ff0ef          	jal	17e <print_fs_event>
        for (int i = 0; i < n_fs; i++) {
     e6a:	1c848493          	addi	s1,s1,456
     e6e:	ff249be3          	bne	s1,s2,e64 <main+0x64>
     e72:	b7f1                	j	e3e <main+0x3e>

0000000000000e74 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     e74:	1141                	addi	sp,sp,-16
     e76:	e406                	sd	ra,8(sp)
     e78:	e022                	sd	s0,0(sp)
     e7a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     e7c:	f85ff0ef          	jal	e00 <main>
  exit(r);
     e80:	288000ef          	jal	1108 <exit>

0000000000000e84 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     e84:	1141                	addi	sp,sp,-16
     e86:	e422                	sd	s0,8(sp)
     e88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     e8a:	87aa                	mv	a5,a0
     e8c:	0585                	addi	a1,a1,1
     e8e:	0785                	addi	a5,a5,1
     e90:	fff5c703          	lbu	a4,-1(a1)
     e94:	fee78fa3          	sb	a4,-1(a5)
     e98:	fb75                	bnez	a4,e8c <strcpy+0x8>
    ;
  return os;
}
     e9a:	6422                	ld	s0,8(sp)
     e9c:	0141                	addi	sp,sp,16
     e9e:	8082                	ret

0000000000000ea0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     ea0:	1141                	addi	sp,sp,-16
     ea2:	e422                	sd	s0,8(sp)
     ea4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     ea6:	00054783          	lbu	a5,0(a0)
     eaa:	cb91                	beqz	a5,ebe <strcmp+0x1e>
     eac:	0005c703          	lbu	a4,0(a1)
     eb0:	00f71763          	bne	a4,a5,ebe <strcmp+0x1e>
    p++, q++;
     eb4:	0505                	addi	a0,a0,1
     eb6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     eb8:	00054783          	lbu	a5,0(a0)
     ebc:	fbe5                	bnez	a5,eac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     ebe:	0005c503          	lbu	a0,0(a1)
}
     ec2:	40a7853b          	subw	a0,a5,a0
     ec6:	6422                	ld	s0,8(sp)
     ec8:	0141                	addi	sp,sp,16
     eca:	8082                	ret

0000000000000ecc <strlen>:

uint
strlen(const char *s)
{
     ecc:	1141                	addi	sp,sp,-16
     ece:	e422                	sd	s0,8(sp)
     ed0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     ed2:	00054783          	lbu	a5,0(a0)
     ed6:	cf91                	beqz	a5,ef2 <strlen+0x26>
     ed8:	0505                	addi	a0,a0,1
     eda:	87aa                	mv	a5,a0
     edc:	86be                	mv	a3,a5
     ede:	0785                	addi	a5,a5,1
     ee0:	fff7c703          	lbu	a4,-1(a5)
     ee4:	ff65                	bnez	a4,edc <strlen+0x10>
     ee6:	40a6853b          	subw	a0,a3,a0
     eea:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     eec:	6422                	ld	s0,8(sp)
     eee:	0141                	addi	sp,sp,16
     ef0:	8082                	ret
  for(n = 0; s[n]; n++)
     ef2:	4501                	li	a0,0
     ef4:	bfe5                	j	eec <strlen+0x20>

0000000000000ef6 <memset>:

void*
memset(void *dst, int c, uint n)
{
     ef6:	1141                	addi	sp,sp,-16
     ef8:	e422                	sd	s0,8(sp)
     efa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     efc:	ca19                	beqz	a2,f12 <memset+0x1c>
     efe:	87aa                	mv	a5,a0
     f00:	1602                	slli	a2,a2,0x20
     f02:	9201                	srli	a2,a2,0x20
     f04:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     f08:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     f0c:	0785                	addi	a5,a5,1
     f0e:	fee79de3          	bne	a5,a4,f08 <memset+0x12>
  }
  return dst;
}
     f12:	6422                	ld	s0,8(sp)
     f14:	0141                	addi	sp,sp,16
     f16:	8082                	ret

0000000000000f18 <strchr>:

char*
strchr(const char *s, char c)
{
     f18:	1141                	addi	sp,sp,-16
     f1a:	e422                	sd	s0,8(sp)
     f1c:	0800                	addi	s0,sp,16
  for(; *s; s++)
     f1e:	00054783          	lbu	a5,0(a0)
     f22:	cb99                	beqz	a5,f38 <strchr+0x20>
    if(*s == c)
     f24:	00f58763          	beq	a1,a5,f32 <strchr+0x1a>
  for(; *s; s++)
     f28:	0505                	addi	a0,a0,1
     f2a:	00054783          	lbu	a5,0(a0)
     f2e:	fbfd                	bnez	a5,f24 <strchr+0xc>
      return (char*)s;
  return 0;
     f30:	4501                	li	a0,0
}
     f32:	6422                	ld	s0,8(sp)
     f34:	0141                	addi	sp,sp,16
     f36:	8082                	ret
  return 0;
     f38:	4501                	li	a0,0
     f3a:	bfe5                	j	f32 <strchr+0x1a>

0000000000000f3c <gets>:

char*
gets(char *buf, int max)
{
     f3c:	711d                	addi	sp,sp,-96
     f3e:	ec86                	sd	ra,88(sp)
     f40:	e8a2                	sd	s0,80(sp)
     f42:	e4a6                	sd	s1,72(sp)
     f44:	e0ca                	sd	s2,64(sp)
     f46:	fc4e                	sd	s3,56(sp)
     f48:	f852                	sd	s4,48(sp)
     f4a:	f456                	sd	s5,40(sp)
     f4c:	f05a                	sd	s6,32(sp)
     f4e:	ec5e                	sd	s7,24(sp)
     f50:	1080                	addi	s0,sp,96
     f52:	8baa                	mv	s7,a0
     f54:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     f56:	892a                	mv	s2,a0
     f58:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     f5a:	4aa9                	li	s5,10
     f5c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     f5e:	89a6                	mv	s3,s1
     f60:	2485                	addiw	s1,s1,1
     f62:	0344d663          	bge	s1,s4,f8e <gets+0x52>
    cc = read(0, &c, 1);
     f66:	4605                	li	a2,1
     f68:	faf40593          	addi	a1,s0,-81
     f6c:	4501                	li	a0,0
     f6e:	1b2000ef          	jal	1120 <read>
    if(cc < 1)
     f72:	00a05e63          	blez	a0,f8e <gets+0x52>
    buf[i++] = c;
     f76:	faf44783          	lbu	a5,-81(s0)
     f7a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     f7e:	01578763          	beq	a5,s5,f8c <gets+0x50>
     f82:	0905                	addi	s2,s2,1
     f84:	fd679de3          	bne	a5,s6,f5e <gets+0x22>
    buf[i++] = c;
     f88:	89a6                	mv	s3,s1
     f8a:	a011                	j	f8e <gets+0x52>
     f8c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     f8e:	99de                	add	s3,s3,s7
     f90:	00098023          	sb	zero,0(s3)
  return buf;
}
     f94:	855e                	mv	a0,s7
     f96:	60e6                	ld	ra,88(sp)
     f98:	6446                	ld	s0,80(sp)
     f9a:	64a6                	ld	s1,72(sp)
     f9c:	6906                	ld	s2,64(sp)
     f9e:	79e2                	ld	s3,56(sp)
     fa0:	7a42                	ld	s4,48(sp)
     fa2:	7aa2                	ld	s5,40(sp)
     fa4:	7b02                	ld	s6,32(sp)
     fa6:	6be2                	ld	s7,24(sp)
     fa8:	6125                	addi	sp,sp,96
     faa:	8082                	ret

0000000000000fac <stat>:

int
stat(const char *n, struct stat *st)
{
     fac:	1101                	addi	sp,sp,-32
     fae:	ec06                	sd	ra,24(sp)
     fb0:	e822                	sd	s0,16(sp)
     fb2:	e04a                	sd	s2,0(sp)
     fb4:	1000                	addi	s0,sp,32
     fb6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     fb8:	4581                	li	a1,0
     fba:	18e000ef          	jal	1148 <open>
  if(fd < 0)
     fbe:	02054263          	bltz	a0,fe2 <stat+0x36>
     fc2:	e426                	sd	s1,8(sp)
     fc4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     fc6:	85ca                	mv	a1,s2
     fc8:	198000ef          	jal	1160 <fstat>
     fcc:	892a                	mv	s2,a0
  close(fd);
     fce:	8526                	mv	a0,s1
     fd0:	160000ef          	jal	1130 <close>
  return r;
     fd4:	64a2                	ld	s1,8(sp)
}
     fd6:	854a                	mv	a0,s2
     fd8:	60e2                	ld	ra,24(sp)
     fda:	6442                	ld	s0,16(sp)
     fdc:	6902                	ld	s2,0(sp)
     fde:	6105                	addi	sp,sp,32
     fe0:	8082                	ret
    return -1;
     fe2:	597d                	li	s2,-1
     fe4:	bfcd                	j	fd6 <stat+0x2a>

0000000000000fe6 <atoi>:

int
atoi(const char *s)
{
     fe6:	1141                	addi	sp,sp,-16
     fe8:	e422                	sd	s0,8(sp)
     fea:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     fec:	00054683          	lbu	a3,0(a0)
     ff0:	fd06879b          	addiw	a5,a3,-48
     ff4:	0ff7f793          	zext.b	a5,a5
     ff8:	4625                	li	a2,9
     ffa:	02f66863          	bltu	a2,a5,102a <atoi+0x44>
     ffe:	872a                	mv	a4,a0
  n = 0;
    1000:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    1002:	0705                	addi	a4,a4,1
    1004:	0025179b          	slliw	a5,a0,0x2
    1008:	9fa9                	addw	a5,a5,a0
    100a:	0017979b          	slliw	a5,a5,0x1
    100e:	9fb5                	addw	a5,a5,a3
    1010:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    1014:	00074683          	lbu	a3,0(a4)
    1018:	fd06879b          	addiw	a5,a3,-48
    101c:	0ff7f793          	zext.b	a5,a5
    1020:	fef671e3          	bgeu	a2,a5,1002 <atoi+0x1c>
  return n;
}
    1024:	6422                	ld	s0,8(sp)
    1026:	0141                	addi	sp,sp,16
    1028:	8082                	ret
  n = 0;
    102a:	4501                	li	a0,0
    102c:	bfe5                	j	1024 <atoi+0x3e>

000000000000102e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    102e:	1141                	addi	sp,sp,-16
    1030:	e422                	sd	s0,8(sp)
    1032:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    1034:	02b57463          	bgeu	a0,a1,105c <memmove+0x2e>
    while(n-- > 0)
    1038:	00c05f63          	blez	a2,1056 <memmove+0x28>
    103c:	1602                	slli	a2,a2,0x20
    103e:	9201                	srli	a2,a2,0x20
    1040:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    1044:	872a                	mv	a4,a0
      *dst++ = *src++;
    1046:	0585                	addi	a1,a1,1
    1048:	0705                	addi	a4,a4,1
    104a:	fff5c683          	lbu	a3,-1(a1)
    104e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    1052:	fef71ae3          	bne	a4,a5,1046 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    1056:	6422                	ld	s0,8(sp)
    1058:	0141                	addi	sp,sp,16
    105a:	8082                	ret
    dst += n;
    105c:	00c50733          	add	a4,a0,a2
    src += n;
    1060:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    1062:	fec05ae3          	blez	a2,1056 <memmove+0x28>
    1066:	fff6079b          	addiw	a5,a2,-1
    106a:	1782                	slli	a5,a5,0x20
    106c:	9381                	srli	a5,a5,0x20
    106e:	fff7c793          	not	a5,a5
    1072:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    1074:	15fd                	addi	a1,a1,-1
    1076:	177d                	addi	a4,a4,-1
    1078:	0005c683          	lbu	a3,0(a1)
    107c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    1080:	fee79ae3          	bne	a5,a4,1074 <memmove+0x46>
    1084:	bfc9                	j	1056 <memmove+0x28>

0000000000001086 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    1086:	1141                	addi	sp,sp,-16
    1088:	e422                	sd	s0,8(sp)
    108a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    108c:	ca05                	beqz	a2,10bc <memcmp+0x36>
    108e:	fff6069b          	addiw	a3,a2,-1
    1092:	1682                	slli	a3,a3,0x20
    1094:	9281                	srli	a3,a3,0x20
    1096:	0685                	addi	a3,a3,1
    1098:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    109a:	00054783          	lbu	a5,0(a0)
    109e:	0005c703          	lbu	a4,0(a1)
    10a2:	00e79863          	bne	a5,a4,10b2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    10a6:	0505                	addi	a0,a0,1
    p2++;
    10a8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    10aa:	fed518e3          	bne	a0,a3,109a <memcmp+0x14>
  }
  return 0;
    10ae:	4501                	li	a0,0
    10b0:	a019                	j	10b6 <memcmp+0x30>
      return *p1 - *p2;
    10b2:	40e7853b          	subw	a0,a5,a4
}
    10b6:	6422                	ld	s0,8(sp)
    10b8:	0141                	addi	sp,sp,16
    10ba:	8082                	ret
  return 0;
    10bc:	4501                	li	a0,0
    10be:	bfe5                	j	10b6 <memcmp+0x30>

00000000000010c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    10c0:	1141                	addi	sp,sp,-16
    10c2:	e406                	sd	ra,8(sp)
    10c4:	e022                	sd	s0,0(sp)
    10c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    10c8:	f67ff0ef          	jal	102e <memmove>
}
    10cc:	60a2                	ld	ra,8(sp)
    10ce:	6402                	ld	s0,0(sp)
    10d0:	0141                	addi	sp,sp,16
    10d2:	8082                	ret

00000000000010d4 <sbrk>:

char *
sbrk(int n) {
    10d4:	1141                	addi	sp,sp,-16
    10d6:	e406                	sd	ra,8(sp)
    10d8:	e022                	sd	s0,0(sp)
    10da:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
    10dc:	4585                	li	a1,1
    10de:	0b2000ef          	jal	1190 <sys_sbrk>
}
    10e2:	60a2                	ld	ra,8(sp)
    10e4:	6402                	ld	s0,0(sp)
    10e6:	0141                	addi	sp,sp,16
    10e8:	8082                	ret

00000000000010ea <sbrklazy>:

char *
sbrklazy(int n) {
    10ea:	1141                	addi	sp,sp,-16
    10ec:	e406                	sd	ra,8(sp)
    10ee:	e022                	sd	s0,0(sp)
    10f0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    10f2:	4589                	li	a1,2
    10f4:	09c000ef          	jal	1190 <sys_sbrk>
}
    10f8:	60a2                	ld	ra,8(sp)
    10fa:	6402                	ld	s0,0(sp)
    10fc:	0141                	addi	sp,sp,16
    10fe:	8082                	ret

0000000000001100 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    1100:	4885                	li	a7,1
 ecall
    1102:	00000073          	ecall
 ret
    1106:	8082                	ret

0000000000001108 <exit>:
.global exit
exit:
 li a7, SYS_exit
    1108:	4889                	li	a7,2
 ecall
    110a:	00000073          	ecall
 ret
    110e:	8082                	ret

0000000000001110 <wait>:
.global wait
wait:
 li a7, SYS_wait
    1110:	488d                	li	a7,3
 ecall
    1112:	00000073          	ecall
 ret
    1116:	8082                	ret

0000000000001118 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    1118:	4891                	li	a7,4
 ecall
    111a:	00000073          	ecall
 ret
    111e:	8082                	ret

0000000000001120 <read>:
.global read
read:
 li a7, SYS_read
    1120:	4895                	li	a7,5
 ecall
    1122:	00000073          	ecall
 ret
    1126:	8082                	ret

0000000000001128 <write>:
.global write
write:
 li a7, SYS_write
    1128:	48c1                	li	a7,16
 ecall
    112a:	00000073          	ecall
 ret
    112e:	8082                	ret

0000000000001130 <close>:
.global close
close:
 li a7, SYS_close
    1130:	48d5                	li	a7,21
 ecall
    1132:	00000073          	ecall
 ret
    1136:	8082                	ret

0000000000001138 <kill>:
.global kill
kill:
 li a7, SYS_kill
    1138:	4899                	li	a7,6
 ecall
    113a:	00000073          	ecall
 ret
    113e:	8082                	ret

0000000000001140 <exec>:
.global exec
exec:
 li a7, SYS_exec
    1140:	489d                	li	a7,7
 ecall
    1142:	00000073          	ecall
 ret
    1146:	8082                	ret

0000000000001148 <open>:
.global open
open:
 li a7, SYS_open
    1148:	48bd                	li	a7,15
 ecall
    114a:	00000073          	ecall
 ret
    114e:	8082                	ret

0000000000001150 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    1150:	48c5                	li	a7,17
 ecall
    1152:	00000073          	ecall
 ret
    1156:	8082                	ret

0000000000001158 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    1158:	48c9                	li	a7,18
 ecall
    115a:	00000073          	ecall
 ret
    115e:	8082                	ret

0000000000001160 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    1160:	48a1                	li	a7,8
 ecall
    1162:	00000073          	ecall
 ret
    1166:	8082                	ret

0000000000001168 <link>:
.global link
link:
 li a7, SYS_link
    1168:	48cd                	li	a7,19
 ecall
    116a:	00000073          	ecall
 ret
    116e:	8082                	ret

0000000000001170 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    1170:	48d1                	li	a7,20
 ecall
    1172:	00000073          	ecall
 ret
    1176:	8082                	ret

0000000000001178 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    1178:	48a5                	li	a7,9
 ecall
    117a:	00000073          	ecall
 ret
    117e:	8082                	ret

0000000000001180 <dup>:
.global dup
dup:
 li a7, SYS_dup
    1180:	48a9                	li	a7,10
 ecall
    1182:	00000073          	ecall
 ret
    1186:	8082                	ret

0000000000001188 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    1188:	48ad                	li	a7,11
 ecall
    118a:	00000073          	ecall
 ret
    118e:	8082                	ret

0000000000001190 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    1190:	48b1                	li	a7,12
 ecall
    1192:	00000073          	ecall
 ret
    1196:	8082                	ret

0000000000001198 <pause>:
.global pause
pause:
 li a7, SYS_pause
    1198:	48b5                	li	a7,13
 ecall
    119a:	00000073          	ecall
 ret
    119e:	8082                	ret

00000000000011a0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    11a0:	48b9                	li	a7,14
 ecall
    11a2:	00000073          	ecall
 ret
    11a6:	8082                	ret

00000000000011a8 <csread>:
.global csread
csread:
 li a7, SYS_csread
    11a8:	48d9                	li	a7,22
 ecall
    11aa:	00000073          	ecall
 ret
    11ae:	8082                	ret

00000000000011b0 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
    11b0:	48dd                	li	a7,23
 ecall
    11b2:	00000073          	ecall
 ret
    11b6:	8082                	ret

00000000000011b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    11b8:	1101                	addi	sp,sp,-32
    11ba:	ec06                	sd	ra,24(sp)
    11bc:	e822                	sd	s0,16(sp)
    11be:	1000                	addi	s0,sp,32
    11c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    11c4:	4605                	li	a2,1
    11c6:	fef40593          	addi	a1,s0,-17
    11ca:	f5fff0ef          	jal	1128 <write>
}
    11ce:	60e2                	ld	ra,24(sp)
    11d0:	6442                	ld	s0,16(sp)
    11d2:	6105                	addi	sp,sp,32
    11d4:	8082                	ret

00000000000011d6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    11d6:	715d                	addi	sp,sp,-80
    11d8:	e486                	sd	ra,72(sp)
    11da:	e0a2                	sd	s0,64(sp)
    11dc:	f84a                	sd	s2,48(sp)
    11de:	0880                	addi	s0,sp,80
    11e0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    11e2:	c299                	beqz	a3,11e8 <printint+0x12>
    11e4:	0805c363          	bltz	a1,126a <printint+0x94>
  neg = 0;
    11e8:	4881                	li	a7,0
    11ea:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    11ee:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    11f0:	00001517          	auipc	a0,0x1
    11f4:	82050513          	addi	a0,a0,-2016 # 1a10 <digits>
    11f8:	883e                	mv	a6,a5
    11fa:	2785                	addiw	a5,a5,1
    11fc:	02c5f733          	remu	a4,a1,a2
    1200:	972a                	add	a4,a4,a0
    1202:	00074703          	lbu	a4,0(a4)
    1206:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    120a:	872e                	mv	a4,a1
    120c:	02c5d5b3          	divu	a1,a1,a2
    1210:	0685                	addi	a3,a3,1
    1212:	fec773e3          	bgeu	a4,a2,11f8 <printint+0x22>
  if(neg)
    1216:	00088b63          	beqz	a7,122c <printint+0x56>
    buf[i++] = '-';
    121a:	fd078793          	addi	a5,a5,-48
    121e:	97a2                	add	a5,a5,s0
    1220:	02d00713          	li	a4,45
    1224:	fee78423          	sb	a4,-24(a5)
    1228:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    122c:	02f05a63          	blez	a5,1260 <printint+0x8a>
    1230:	fc26                	sd	s1,56(sp)
    1232:	f44e                	sd	s3,40(sp)
    1234:	fb840713          	addi	a4,s0,-72
    1238:	00f704b3          	add	s1,a4,a5
    123c:	fff70993          	addi	s3,a4,-1
    1240:	99be                	add	s3,s3,a5
    1242:	37fd                	addiw	a5,a5,-1
    1244:	1782                	slli	a5,a5,0x20
    1246:	9381                	srli	a5,a5,0x20
    1248:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    124c:	fff4c583          	lbu	a1,-1(s1)
    1250:	854a                	mv	a0,s2
    1252:	f67ff0ef          	jal	11b8 <putc>
  while(--i >= 0)
    1256:	14fd                	addi	s1,s1,-1
    1258:	ff349ae3          	bne	s1,s3,124c <printint+0x76>
    125c:	74e2                	ld	s1,56(sp)
    125e:	79a2                	ld	s3,40(sp)
}
    1260:	60a6                	ld	ra,72(sp)
    1262:	6406                	ld	s0,64(sp)
    1264:	7942                	ld	s2,48(sp)
    1266:	6161                	addi	sp,sp,80
    1268:	8082                	ret
    x = -xx;
    126a:	40b005b3          	neg	a1,a1
    neg = 1;
    126e:	4885                	li	a7,1
    x = -xx;
    1270:	bfad                	j	11ea <printint+0x14>

0000000000001272 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1272:	711d                	addi	sp,sp,-96
    1274:	ec86                	sd	ra,88(sp)
    1276:	e8a2                	sd	s0,80(sp)
    1278:	e0ca                	sd	s2,64(sp)
    127a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    127c:	0005c903          	lbu	s2,0(a1)
    1280:	28090663          	beqz	s2,150c <vprintf+0x29a>
    1284:	e4a6                	sd	s1,72(sp)
    1286:	fc4e                	sd	s3,56(sp)
    1288:	f852                	sd	s4,48(sp)
    128a:	f456                	sd	s5,40(sp)
    128c:	f05a                	sd	s6,32(sp)
    128e:	ec5e                	sd	s7,24(sp)
    1290:	e862                	sd	s8,16(sp)
    1292:	e466                	sd	s9,8(sp)
    1294:	8b2a                	mv	s6,a0
    1296:	8a2e                	mv	s4,a1
    1298:	8bb2                	mv	s7,a2
  state = 0;
    129a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    129c:	4481                	li	s1,0
    129e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    12a0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    12a4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    12a8:	06c00c93          	li	s9,108
    12ac:	a005                	j	12cc <vprintf+0x5a>
        putc(fd, c0);
    12ae:	85ca                	mv	a1,s2
    12b0:	855a                	mv	a0,s6
    12b2:	f07ff0ef          	jal	11b8 <putc>
    12b6:	a019                	j	12bc <vprintf+0x4a>
    } else if(state == '%'){
    12b8:	03598263          	beq	s3,s5,12dc <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
    12bc:	2485                	addiw	s1,s1,1
    12be:	8726                	mv	a4,s1
    12c0:	009a07b3          	add	a5,s4,s1
    12c4:	0007c903          	lbu	s2,0(a5)
    12c8:	22090a63          	beqz	s2,14fc <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
    12cc:	0009079b          	sext.w	a5,s2
    if(state == 0){
    12d0:	fe0994e3          	bnez	s3,12b8 <vprintf+0x46>
      if(c0 == '%'){
    12d4:	fd579de3          	bne	a5,s5,12ae <vprintf+0x3c>
        state = '%';
    12d8:	89be                	mv	s3,a5
    12da:	b7cd                	j	12bc <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    12dc:	00ea06b3          	add	a3,s4,a4
    12e0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    12e4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    12e6:	c681                	beqz	a3,12ee <vprintf+0x7c>
    12e8:	9752                	add	a4,a4,s4
    12ea:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    12ee:	05878363          	beq	a5,s8,1334 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
    12f2:	05978d63          	beq	a5,s9,134c <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    12f6:	07500713          	li	a4,117
    12fa:	0ee78763          	beq	a5,a4,13e8 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    12fe:	07800713          	li	a4,120
    1302:	12e78963          	beq	a5,a4,1434 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    1306:	07000713          	li	a4,112
    130a:	14e78e63          	beq	a5,a4,1466 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
    130e:	06300713          	li	a4,99
    1312:	18e78e63          	beq	a5,a4,14ae <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
    1316:	07300713          	li	a4,115
    131a:	1ae78463          	beq	a5,a4,14c2 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    131e:	02500713          	li	a4,37
    1322:	04e79563          	bne	a5,a4,136c <vprintf+0xfa>
        putc(fd, '%');
    1326:	02500593          	li	a1,37
    132a:	855a                	mv	a0,s6
    132c:	e8dff0ef          	jal	11b8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    1330:	4981                	li	s3,0
    1332:	b769                	j	12bc <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    1334:	008b8913          	addi	s2,s7,8
    1338:	4685                	li	a3,1
    133a:	4629                	li	a2,10
    133c:	000ba583          	lw	a1,0(s7)
    1340:	855a                	mv	a0,s6
    1342:	e95ff0ef          	jal	11d6 <printint>
    1346:	8bca                	mv	s7,s2
      state = 0;
    1348:	4981                	li	s3,0
    134a:	bf8d                	j	12bc <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    134c:	06400793          	li	a5,100
    1350:	02f68963          	beq	a3,a5,1382 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    1354:	06c00793          	li	a5,108
    1358:	04f68263          	beq	a3,a5,139c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
    135c:	07500793          	li	a5,117
    1360:	0af68063          	beq	a3,a5,1400 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
    1364:	07800793          	li	a5,120
    1368:	0ef68263          	beq	a3,a5,144c <vprintf+0x1da>
        putc(fd, '%');
    136c:	02500593          	li	a1,37
    1370:	855a                	mv	a0,s6
    1372:	e47ff0ef          	jal	11b8 <putc>
        putc(fd, c0);
    1376:	85ca                	mv	a1,s2
    1378:	855a                	mv	a0,s6
    137a:	e3fff0ef          	jal	11b8 <putc>
      state = 0;
    137e:	4981                	li	s3,0
    1380:	bf35                	j	12bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1382:	008b8913          	addi	s2,s7,8
    1386:	4685                	li	a3,1
    1388:	4629                	li	a2,10
    138a:	000bb583          	ld	a1,0(s7)
    138e:	855a                	mv	a0,s6
    1390:	e47ff0ef          	jal	11d6 <printint>
        i += 1;
    1394:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    1396:	8bca                	mv	s7,s2
      state = 0;
    1398:	4981                	li	s3,0
        i += 1;
    139a:	b70d                	j	12bc <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    139c:	06400793          	li	a5,100
    13a0:	02f60763          	beq	a2,a5,13ce <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    13a4:	07500793          	li	a5,117
    13a8:	06f60963          	beq	a2,a5,141a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    13ac:	07800793          	li	a5,120
    13b0:	faf61ee3          	bne	a2,a5,136c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    13b4:	008b8913          	addi	s2,s7,8
    13b8:	4681                	li	a3,0
    13ba:	4641                	li	a2,16
    13bc:	000bb583          	ld	a1,0(s7)
    13c0:	855a                	mv	a0,s6
    13c2:	e15ff0ef          	jal	11d6 <printint>
        i += 2;
    13c6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    13c8:	8bca                	mv	s7,s2
      state = 0;
    13ca:	4981                	li	s3,0
        i += 2;
    13cc:	bdc5                	j	12bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    13ce:	008b8913          	addi	s2,s7,8
    13d2:	4685                	li	a3,1
    13d4:	4629                	li	a2,10
    13d6:	000bb583          	ld	a1,0(s7)
    13da:	855a                	mv	a0,s6
    13dc:	dfbff0ef          	jal	11d6 <printint>
        i += 2;
    13e0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    13e2:	8bca                	mv	s7,s2
      state = 0;
    13e4:	4981                	li	s3,0
        i += 2;
    13e6:	bdd9                	j	12bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    13e8:	008b8913          	addi	s2,s7,8
    13ec:	4681                	li	a3,0
    13ee:	4629                	li	a2,10
    13f0:	000be583          	lwu	a1,0(s7)
    13f4:	855a                	mv	a0,s6
    13f6:	de1ff0ef          	jal	11d6 <printint>
    13fa:	8bca                	mv	s7,s2
      state = 0;
    13fc:	4981                	li	s3,0
    13fe:	bd7d                	j	12bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1400:	008b8913          	addi	s2,s7,8
    1404:	4681                	li	a3,0
    1406:	4629                	li	a2,10
    1408:	000bb583          	ld	a1,0(s7)
    140c:	855a                	mv	a0,s6
    140e:	dc9ff0ef          	jal	11d6 <printint>
        i += 1;
    1412:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    1414:	8bca                	mv	s7,s2
      state = 0;
    1416:	4981                	li	s3,0
        i += 1;
    1418:	b555                	j	12bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    141a:	008b8913          	addi	s2,s7,8
    141e:	4681                	li	a3,0
    1420:	4629                	li	a2,10
    1422:	000bb583          	ld	a1,0(s7)
    1426:	855a                	mv	a0,s6
    1428:	dafff0ef          	jal	11d6 <printint>
        i += 2;
    142c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    142e:	8bca                	mv	s7,s2
      state = 0;
    1430:	4981                	li	s3,0
        i += 2;
    1432:	b569                	j	12bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    1434:	008b8913          	addi	s2,s7,8
    1438:	4681                	li	a3,0
    143a:	4641                	li	a2,16
    143c:	000be583          	lwu	a1,0(s7)
    1440:	855a                	mv	a0,s6
    1442:	d95ff0ef          	jal	11d6 <printint>
    1446:	8bca                	mv	s7,s2
      state = 0;
    1448:	4981                	li	s3,0
    144a:	bd8d                	j	12bc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    144c:	008b8913          	addi	s2,s7,8
    1450:	4681                	li	a3,0
    1452:	4641                	li	a2,16
    1454:	000bb583          	ld	a1,0(s7)
    1458:	855a                	mv	a0,s6
    145a:	d7dff0ef          	jal	11d6 <printint>
        i += 1;
    145e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    1460:	8bca                	mv	s7,s2
      state = 0;
    1462:	4981                	li	s3,0
        i += 1;
    1464:	bda1                	j	12bc <vprintf+0x4a>
    1466:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    1468:	008b8d13          	addi	s10,s7,8
    146c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    1470:	03000593          	li	a1,48
    1474:	855a                	mv	a0,s6
    1476:	d43ff0ef          	jal	11b8 <putc>
  putc(fd, 'x');
    147a:	07800593          	li	a1,120
    147e:	855a                	mv	a0,s6
    1480:	d39ff0ef          	jal	11b8 <putc>
    1484:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1486:	00000b97          	auipc	s7,0x0
    148a:	58ab8b93          	addi	s7,s7,1418 # 1a10 <digits>
    148e:	03c9d793          	srli	a5,s3,0x3c
    1492:	97de                	add	a5,a5,s7
    1494:	0007c583          	lbu	a1,0(a5)
    1498:	855a                	mv	a0,s6
    149a:	d1fff0ef          	jal	11b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    149e:	0992                	slli	s3,s3,0x4
    14a0:	397d                	addiw	s2,s2,-1
    14a2:	fe0916e3          	bnez	s2,148e <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
    14a6:	8bea                	mv	s7,s10
      state = 0;
    14a8:	4981                	li	s3,0
    14aa:	6d02                	ld	s10,0(sp)
    14ac:	bd01                	j	12bc <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
    14ae:	008b8913          	addi	s2,s7,8
    14b2:	000bc583          	lbu	a1,0(s7)
    14b6:	855a                	mv	a0,s6
    14b8:	d01ff0ef          	jal	11b8 <putc>
    14bc:	8bca                	mv	s7,s2
      state = 0;
    14be:	4981                	li	s3,0
    14c0:	bbf5                	j	12bc <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    14c2:	008b8993          	addi	s3,s7,8
    14c6:	000bb903          	ld	s2,0(s7)
    14ca:	00090f63          	beqz	s2,14e8 <vprintf+0x276>
        for(; *s; s++)
    14ce:	00094583          	lbu	a1,0(s2)
    14d2:	c195                	beqz	a1,14f6 <vprintf+0x284>
          putc(fd, *s);
    14d4:	855a                	mv	a0,s6
    14d6:	ce3ff0ef          	jal	11b8 <putc>
        for(; *s; s++)
    14da:	0905                	addi	s2,s2,1
    14dc:	00094583          	lbu	a1,0(s2)
    14e0:	f9f5                	bnez	a1,14d4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    14e2:	8bce                	mv	s7,s3
      state = 0;
    14e4:	4981                	li	s3,0
    14e6:	bbd9                	j	12bc <vprintf+0x4a>
          s = "(null)";
    14e8:	00000917          	auipc	s2,0x0
    14ec:	4e090913          	addi	s2,s2,1248 # 19c8 <malloc+0x3d4>
        for(; *s; s++)
    14f0:	02800593          	li	a1,40
    14f4:	b7c5                	j	14d4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    14f6:	8bce                	mv	s7,s3
      state = 0;
    14f8:	4981                	li	s3,0
    14fa:	b3c9                	j	12bc <vprintf+0x4a>
    14fc:	64a6                	ld	s1,72(sp)
    14fe:	79e2                	ld	s3,56(sp)
    1500:	7a42                	ld	s4,48(sp)
    1502:	7aa2                	ld	s5,40(sp)
    1504:	7b02                	ld	s6,32(sp)
    1506:	6be2                	ld	s7,24(sp)
    1508:	6c42                	ld	s8,16(sp)
    150a:	6ca2                	ld	s9,8(sp)
    }
  }
}
    150c:	60e6                	ld	ra,88(sp)
    150e:	6446                	ld	s0,80(sp)
    1510:	6906                	ld	s2,64(sp)
    1512:	6125                	addi	sp,sp,96
    1514:	8082                	ret

0000000000001516 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1516:	715d                	addi	sp,sp,-80
    1518:	ec06                	sd	ra,24(sp)
    151a:	e822                	sd	s0,16(sp)
    151c:	1000                	addi	s0,sp,32
    151e:	e010                	sd	a2,0(s0)
    1520:	e414                	sd	a3,8(s0)
    1522:	e818                	sd	a4,16(s0)
    1524:	ec1c                	sd	a5,24(s0)
    1526:	03043023          	sd	a6,32(s0)
    152a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    152e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1532:	8622                	mv	a2,s0
    1534:	d3fff0ef          	jal	1272 <vprintf>
}
    1538:	60e2                	ld	ra,24(sp)
    153a:	6442                	ld	s0,16(sp)
    153c:	6161                	addi	sp,sp,80
    153e:	8082                	ret

0000000000001540 <printf>:

void
printf(const char *fmt, ...)
{
    1540:	711d                	addi	sp,sp,-96
    1542:	ec06                	sd	ra,24(sp)
    1544:	e822                	sd	s0,16(sp)
    1546:	1000                	addi	s0,sp,32
    1548:	e40c                	sd	a1,8(s0)
    154a:	e810                	sd	a2,16(s0)
    154c:	ec14                	sd	a3,24(s0)
    154e:	f018                	sd	a4,32(s0)
    1550:	f41c                	sd	a5,40(s0)
    1552:	03043823          	sd	a6,48(s0)
    1556:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    155a:	00840613          	addi	a2,s0,8
    155e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1562:	85aa                	mv	a1,a0
    1564:	4505                	li	a0,1
    1566:	d0dff0ef          	jal	1272 <vprintf>
}
    156a:	60e2                	ld	ra,24(sp)
    156c:	6442                	ld	s0,16(sp)
    156e:	6125                	addi	sp,sp,96
    1570:	8082                	ret

0000000000001572 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1572:	1141                	addi	sp,sp,-16
    1574:	e422                	sd	s0,8(sp)
    1576:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1578:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    157c:	00001797          	auipc	a5,0x1
    1580:	a847b783          	ld	a5,-1404(a5) # 2000 <freep>
    1584:	a02d                	j	15ae <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1586:	4618                	lw	a4,8(a2)
    1588:	9f2d                	addw	a4,a4,a1
    158a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    158e:	6398                	ld	a4,0(a5)
    1590:	6310                	ld	a2,0(a4)
    1592:	a83d                	j	15d0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1594:	ff852703          	lw	a4,-8(a0)
    1598:	9f31                	addw	a4,a4,a2
    159a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    159c:	ff053683          	ld	a3,-16(a0)
    15a0:	a091                	j	15e4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15a2:	6398                	ld	a4,0(a5)
    15a4:	00e7e463          	bltu	a5,a4,15ac <free+0x3a>
    15a8:	00e6ea63          	bltu	a3,a4,15bc <free+0x4a>
{
    15ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15ae:	fed7fae3          	bgeu	a5,a3,15a2 <free+0x30>
    15b2:	6398                	ld	a4,0(a5)
    15b4:	00e6e463          	bltu	a3,a4,15bc <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15b8:	fee7eae3          	bltu	a5,a4,15ac <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    15bc:	ff852583          	lw	a1,-8(a0)
    15c0:	6390                	ld	a2,0(a5)
    15c2:	02059813          	slli	a6,a1,0x20
    15c6:	01c85713          	srli	a4,a6,0x1c
    15ca:	9736                	add	a4,a4,a3
    15cc:	fae60de3          	beq	a2,a4,1586 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    15d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    15d4:	4790                	lw	a2,8(a5)
    15d6:	02061593          	slli	a1,a2,0x20
    15da:	01c5d713          	srli	a4,a1,0x1c
    15de:	973e                	add	a4,a4,a5
    15e0:	fae68ae3          	beq	a3,a4,1594 <free+0x22>
    p->s.ptr = bp->s.ptr;
    15e4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    15e6:	00001717          	auipc	a4,0x1
    15ea:	a0f73d23          	sd	a5,-1510(a4) # 2000 <freep>
}
    15ee:	6422                	ld	s0,8(sp)
    15f0:	0141                	addi	sp,sp,16
    15f2:	8082                	ret

00000000000015f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    15f4:	7139                	addi	sp,sp,-64
    15f6:	fc06                	sd	ra,56(sp)
    15f8:	f822                	sd	s0,48(sp)
    15fa:	f426                	sd	s1,40(sp)
    15fc:	ec4e                	sd	s3,24(sp)
    15fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1600:	02051493          	slli	s1,a0,0x20
    1604:	9081                	srli	s1,s1,0x20
    1606:	04bd                	addi	s1,s1,15
    1608:	8091                	srli	s1,s1,0x4
    160a:	0014899b          	addiw	s3,s1,1
    160e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1610:	00001517          	auipc	a0,0x1
    1614:	9f053503          	ld	a0,-1552(a0) # 2000 <freep>
    1618:	c915                	beqz	a0,164c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    161a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    161c:	4798                	lw	a4,8(a5)
    161e:	08977a63          	bgeu	a4,s1,16b2 <malloc+0xbe>
    1622:	f04a                	sd	s2,32(sp)
    1624:	e852                	sd	s4,16(sp)
    1626:	e456                	sd	s5,8(sp)
    1628:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    162a:	8a4e                	mv	s4,s3
    162c:	0009871b          	sext.w	a4,s3
    1630:	6685                	lui	a3,0x1
    1632:	00d77363          	bgeu	a4,a3,1638 <malloc+0x44>
    1636:	6a05                	lui	s4,0x1
    1638:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    163c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1640:	00001917          	auipc	s2,0x1
    1644:	9c090913          	addi	s2,s2,-1600 # 2000 <freep>
  if(p == SBRK_ERROR)
    1648:	5afd                	li	s5,-1
    164a:	a081                	j	168a <malloc+0x96>
    164c:	f04a                	sd	s2,32(sp)
    164e:	e852                	sd	s4,16(sp)
    1650:	e456                	sd	s5,8(sp)
    1652:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    1654:	00002797          	auipc	a5,0x2
    1658:	63c78793          	addi	a5,a5,1596 # 3c90 <base>
    165c:	00001717          	auipc	a4,0x1
    1660:	9af73223          	sd	a5,-1628(a4) # 2000 <freep>
    1664:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1666:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    166a:	b7c1                	j	162a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    166c:	6398                	ld	a4,0(a5)
    166e:	e118                	sd	a4,0(a0)
    1670:	a8a9                	j	16ca <malloc+0xd6>
  hp->s.size = nu;
    1672:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1676:	0541                	addi	a0,a0,16
    1678:	efbff0ef          	jal	1572 <free>
  return freep;
    167c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1680:	c12d                	beqz	a0,16e2 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1682:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1684:	4798                	lw	a4,8(a5)
    1686:	02977263          	bgeu	a4,s1,16aa <malloc+0xb6>
    if(p == freep)
    168a:	00093703          	ld	a4,0(s2)
    168e:	853e                	mv	a0,a5
    1690:	fef719e3          	bne	a4,a5,1682 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    1694:	8552                	mv	a0,s4
    1696:	a3fff0ef          	jal	10d4 <sbrk>
  if(p == SBRK_ERROR)
    169a:	fd551ce3          	bne	a0,s5,1672 <malloc+0x7e>
        return 0;
    169e:	4501                	li	a0,0
    16a0:	7902                	ld	s2,32(sp)
    16a2:	6a42                	ld	s4,16(sp)
    16a4:	6aa2                	ld	s5,8(sp)
    16a6:	6b02                	ld	s6,0(sp)
    16a8:	a03d                	j	16d6 <malloc+0xe2>
    16aa:	7902                	ld	s2,32(sp)
    16ac:	6a42                	ld	s4,16(sp)
    16ae:	6aa2                	ld	s5,8(sp)
    16b0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    16b2:	fae48de3          	beq	s1,a4,166c <malloc+0x78>
        p->s.size -= nunits;
    16b6:	4137073b          	subw	a4,a4,s3
    16ba:	c798                	sw	a4,8(a5)
        p += p->s.size;
    16bc:	02071693          	slli	a3,a4,0x20
    16c0:	01c6d713          	srli	a4,a3,0x1c
    16c4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    16c6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    16ca:	00001717          	auipc	a4,0x1
    16ce:	92a73b23          	sd	a0,-1738(a4) # 2000 <freep>
      return (void*)(p + 1);
    16d2:	01078513          	addi	a0,a5,16
  }
}
    16d6:	70e2                	ld	ra,56(sp)
    16d8:	7442                	ld	s0,48(sp)
    16da:	74a2                	ld	s1,40(sp)
    16dc:	69e2                	ld	s3,24(sp)
    16de:	6121                	addi	sp,sp,64
    16e0:	8082                	ret
    16e2:	7902                	ld	s2,32(sp)
    16e4:	6a42                	ld	s4,16(sp)
    16e6:	6aa2                	ld	s5,8(sp)
    16e8:	6b02                	ld	s6,0(sp)
    16ea:	b7f5                	j	16d6 <malloc+0xe2>
