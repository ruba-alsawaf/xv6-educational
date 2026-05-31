
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
     116:	74e60613          	addi	a2,a2,1870 # 1860 <malloc+0xfa>
     11a:	ee7ff0ef          	jal	0 <append_str>
        append_str(buf, pos, name);
     11e:	8656                	mv	a2,s5
     120:	85ca                	mv	a1,s2
     122:	8526                	mv	a0,s1
     124:	eddff0ef          	jal	0 <append_str>
        append_str(buf, pos, "\":\"");
     128:	00001617          	auipc	a2,0x1
     12c:	74060613          	addi	a2,a2,1856 # 1868 <malloc+0x102>
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
     146:	72e60613          	addi	a2,a2,1838 # 1870 <malloc+0x10a>
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
     160:	71c60613          	addi	a2,a2,1820 # 1878 <malloc+0x112>
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
     1a0:	6e460613          	addi	a2,a2,1764 # 1880 <malloc+0x11a>
     1a4:	bbc40593          	addi	a1,s0,-1092
     1a8:	bc040513          	addi	a0,s0,-1088
     1ac:	e55ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"seq\":");
     1b0:	00001617          	auipc	a2,0x1
     1b4:	6d860613          	addi	a2,a2,1752 # 1888 <malloc+0x122>
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
     1d6:	6be60613          	addi	a2,a2,1726 # 1890 <malloc+0x12a>
     1da:	bbc40593          	addi	a1,s0,-1092
     1de:	bc040513          	addi	a0,s0,-1088
     1e2:	e1fff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "\"tick\":"); append_uint(buf, &pos, e->ticks);
     1e6:	00001617          	auipc	a2,0x1
     1ea:	6b260613          	addi	a2,a2,1714 # 1898 <malloc+0x132>
     1ee:	bbc40593          	addi	a1,s0,-1092
     1f2:	bc040513          	addi	a0,s0,-1088
     1f6:	e0bff0ef          	jal	0 <append_str>
     1fa:	4490                	lw	a2,8(s1)
     1fc:	bbc40593          	addi	a1,s0,-1092
     200:	bc040513          	addi	a0,s0,-1088
     204:	e31ff0ef          	jal	34 <append_uint>
    append_str(buf, &pos, ",\"pid\":"); append_int(buf, &pos, e->pid);
     208:	00001617          	auipc	a2,0x1
     20c:	69860613          	addi	a2,a2,1688 # 18a0 <malloc+0x13a>
     210:	bbc40593          	addi	a1,s0,-1092
     214:	bc040513          	addi	a0,s0,-1088
     218:	de9ff0ef          	jal	0 <append_str>
     21c:	44d0                	lw	a2,12(s1)
     21e:	bbc40593          	addi	a1,s0,-1092
     222:	bc040513          	addi	a0,s0,-1088
     226:	e93ff0ef          	jal	b8 <append_int>

    append_str(buf, &pos, ",\"layer\":\"");
     22a:	00001617          	auipc	a2,0x1
     22e:	67e60613          	addi	a2,a2,1662 # 18a8 <malloc+0x142>
     232:	bbc40593          	addi	a1,s0,-1092
     236:	bc040513          	addi	a0,s0,-1088
     23a:	dc7ff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE)
     23e:	0104a903          	lw	s2,16(s1)
     242:	479d                	li	a5,7
     244:	4727ebe3          	bltu	a5,s2,eba <print_fs_event+0xd3c>
     248:	00291793          	slli	a5,s2,0x2
     24c:	00002717          	auipc	a4,0x2
     250:	94c70713          	addi	a4,a4,-1716 # 1b98 <malloc+0x432>
     254:	97ba                	add	a5,a5,a4
     256:	439c                	lw	a5,0(a5)
     258:	97ba                	add	a5,a5,a4
     25a:	8782                	jr	a5
     25c:	43313423          	sd	s3,1064(sp)
    append_str(buf, &pos, "BCACHE");
     260:	00001617          	auipc	a2,0x1
     264:	65860613          	addi	a2,a2,1624 # 18b8 <malloc+0x152>
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
     278:	5ec60613          	addi	a2,a2,1516 # 1860 <malloc+0xfa>
     27c:	bbc40593          	addi	a1,s0,-1092
     280:	bc040513          	addi	a0,s0,-1088
     284:	d7dff0ef          	jal	0 <append_str>

    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     288:	00001617          	auipc	a2,0x1
     28c:	63860613          	addi	a2,a2,1592 # 18c0 <malloc+0x15a>
     290:	bbc40593          	addi	a1,s0,-1092
     294:	bc040513          	addi	a0,s0,-1088
     298:	d69ff0ef          	jal	0 <append_str>
     29c:	01448613          	addi	a2,s1,20
     2a0:	bbc40593          	addi	a1,s0,-1092
     2a4:	bc040513          	addi	a0,s0,-1088
     2a8:	d59ff0ef          	jal	0 <append_str>
     2ac:	00001617          	auipc	a2,0x1
     2b0:	5b460613          	addi	a2,a2,1460 # 1860 <malloc+0xfa>
     2b4:	bbc40593          	addi	a1,s0,-1092
     2b8:	bc040513          	addi	a0,s0,-1088
     2bc:	d45ff0ef          	jal	0 <append_str>

    // ===== BCACHE =====
    if(e->type == LAYER_BCACHE){

        append_str(buf, &pos, ",\"buf\":{");
     2c0:	00001617          	auipc	a2,0x1
     2c4:	63860613          	addi	a2,a2,1592 # 18f8 <malloc+0x192>
     2c8:	bbc40593          	addi	a1,s0,-1092
     2cc:	bc040513          	addi	a0,s0,-1088
     2d0:	d31ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"id\":"); append_int(buf, &pos, e->buf_id);
     2d4:	00001617          	auipc	a2,0x1
     2d8:	63460613          	addi	a2,a2,1588 # 1908 <malloc+0x1a2>
     2dc:	bbc40593          	addi	a1,s0,-1092
     2e0:	bc040513          	addi	a0,s0,-1088
     2e4:	d1dff0ef          	jal	0 <append_str>
     2e8:	5490                	lw	a2,40(s1)
     2ea:	bbc40593          	addi	a1,s0,-1092
     2ee:	bc040513          	addi	a0,s0,-1088
     2f2:	dc7ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, ",\"block\":"); append_int(buf, &pos, e->blockno);
     2f6:	00001617          	auipc	a2,0x1
     2fa:	61a60613          	addi	a2,a2,1562 # 1910 <malloc+0x1aa>
     2fe:	bbc40593          	addi	a1,s0,-1092
     302:	bc040513          	addi	a0,s0,-1088
     306:	cfbff0ef          	jal	0 <append_str>
     30a:	50d0                	lw	a2,36(s1)
     30c:	bbc40593          	addi	a1,s0,-1092
     310:	bc040513          	addi	a0,s0,-1088
     314:	da5ff0ef          	jal	b8 <append_int>
        append_str(buf, &pos, "}");
     318:	00001617          	auipc	a2,0x1
     31c:	60860613          	addi	a2,a2,1544 # 1920 <malloc+0x1ba>
     320:	bbc40593          	addi	a1,s0,-1092
     324:	bc040513          	addi	a0,s0,-1088
     328:	cd9ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"state\":{");
     32c:	00001617          	auipc	a2,0x1
     330:	5fc60613          	addi	a2,a2,1532 # 1928 <malloc+0x1c2>
     334:	bbc40593          	addi	a1,s0,-1092
     338:	bc040513          	addi	a0,s0,-1088
     33c:	cc5ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->refcnt);
     340:	00001617          	auipc	a2,0x1
     344:	5f860613          	addi	a2,a2,1528 # 1938 <malloc+0x1d2>
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
     36a:	5da60613          	addi	a2,a2,1498 # 1940 <malloc+0x1da>
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
     390:	59460613          	addi	a2,a2,1428 # 1920 <malloc+0x1ba>
     394:	bbc40593          	addi	a1,s0,-1092
     398:	bc040513          	addi	a0,s0,-1088
     39c:	c65ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"changes\":{");
     3a0:	00001617          	auipc	a2,0x1
     3a4:	5b060613          	addi	a2,a2,1456 # 1950 <malloc+0x1ea>
     3a8:	bbc40593          	addi	a1,s0,-1092
     3ac:	bc040513          	addi	a0,s0,-1088
     3b0:	c51ff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "ref", e->old_refcnt, e->refcnt);
     3b4:	874e                	mv	a4,s3
     3b6:	5894                	lw	a3,48(s1)
     3b8:	00001617          	auipc	a2,0x1
     3bc:	5a860613          	addi	a2,a2,1448 # 1960 <malloc+0x1fa>
     3c0:	bbc40593          	addi	a1,s0,-1092
     3c4:	bc040513          	addi	a0,s0,-1088
     3c8:	d29ff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "valid", e->old_valid, e->valid);
     3cc:	874a                	mv	a4,s2
     3ce:	5c94                	lw	a3,56(s1)
     3d0:	00001617          	auipc	a2,0x1
     3d4:	59860613          	addi	a2,a2,1432 # 1968 <malloc+0x202>
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
     3fc:	32e686e3          	beq	a3,a4,f28 <print_fs_event+0xdaa>
        append_str(buf, &pos, "}");
     400:	00001617          	auipc	a2,0x1
     404:	52060613          	addi	a2,a2,1312 # 1920 <malloc+0x1ba>
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
     41c:	71860613          	addi	a2,a2,1816 # 1b30 <malloc+0x3ca>
     420:	bbc40593          	addi	a1,s0,-1092
     424:	bc040513          	addi	a0,s0,-1088
     428:	bd9ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->details);
     42c:	28848613          	addi	a2,s1,648
     430:	bbc40593          	addi	a1,s0,-1092
     434:	bc040513          	addi	a0,s0,-1088
     438:	bc9ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     43c:	00001617          	auipc	a2,0x1
     440:	42460613          	addi	a2,a2,1060 # 1860 <malloc+0xfa>
     444:	bbc40593          	addi	a1,s0,-1092
     448:	bc040513          	addi	a0,s0,-1088
     44c:	bb5ff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "}\n");
     450:	00001617          	auipc	a2,0x1
     454:	6f060613          	addi	a2,a2,1776 # 1b40 <malloc+0x3da>
     458:	bbc40593          	addi	a1,s0,-1092
     45c:	bc040513          	addi	a0,s0,-1088
     460:	ba1ff0ef          	jal	0 <append_str>

    write(1, buf, pos);
     464:	bbc42603          	lw	a2,-1092(s0)
     468:	bc040593          	addi	a1,s0,-1088
     46c:	4505                	li	a0,1
     46e:	62d000ef          	jal	129a <write>
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
     494:	43860613          	addi	a2,a2,1080 # 18c8 <malloc+0x162>
     498:	bbc40593          	addi	a1,s0,-1092
     49c:	bc040513          	addi	a0,s0,-1088
     4a0:	b61ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     4a4:	00001617          	auipc	a2,0x1
     4a8:	3bc60613          	addi	a2,a2,956 # 1860 <malloc+0xfa>
     4ac:	bbc40593          	addi	a1,s0,-1092
     4b0:	bc040513          	addi	a0,s0,-1088
     4b4:	b4dff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     4b8:	00001617          	auipc	a2,0x1
     4bc:	40860613          	addi	a2,a2,1032 # 18c0 <malloc+0x15a>
     4c0:	bbc40593          	addi	a1,s0,-1092
     4c4:	bc040513          	addi	a0,s0,-1088
     4c8:	b39ff0ef          	jal	0 <append_str>
     4cc:	01448613          	addi	a2,s1,20
     4d0:	bbc40593          	addi	a1,s0,-1092
     4d4:	bc040513          	addi	a0,s0,-1088
     4d8:	b29ff0ef          	jal	0 <append_str>
     4dc:	00001617          	auipc	a2,0x1
     4e0:	38460613          	addi	a2,a2,900 # 1860 <malloc+0xfa>
     4e4:	bbc40593          	addi	a1,s0,-1092
     4e8:	bc040513          	addi	a0,s0,-1088
     4ec:	b15ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"state\":{");
     4f0:	00001617          	auipc	a2,0x1
     4f4:	43860613          	addi	a2,a2,1080 # 1928 <malloc+0x1c2>
     4f8:	bbc40593          	addi	a1,s0,-1092
     4fc:	bc040513          	addi	a0,s0,-1088
     500:	b01ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"log_n\":"); append_int(buf, &pos, e->log_n);
     504:	00001617          	auipc	a2,0x1
     508:	46c60613          	addi	a2,a2,1132 # 1970 <malloc+0x20a>
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
     52e:	45660613          	addi	a2,a2,1110 # 1980 <malloc+0x21a>
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
     554:	44060613          	addi	a2,a2,1088 # 1990 <malloc+0x22a>
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
     57a:	3aa60613          	addi	a2,a2,938 # 1920 <malloc+0x1ba>
     57e:	bbc40593          	addi	a1,s0,-1092
     582:	bc040513          	addi	a0,s0,-1088
     586:	a7bff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"changes\":{");
     58a:	00001617          	auipc	a2,0x1
     58e:	3c660613          	addi	a2,a2,966 # 1950 <malloc+0x1ea>
     592:	bbc40593          	addi	a1,s0,-1092
     596:	bc040513          	addi	a0,s0,-1088
     59a:	a67ff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "log_n", e->old_log_n, e->log_n);
     59e:	8752                	mv	a4,s4
     5a0:	40b4                	lw	a3,64(s1)
     5a2:	00001617          	auipc	a2,0x1
     5a6:	3fe60613          	addi	a2,a2,1022 # 19a0 <malloc+0x23a>
     5aa:	bbc40593          	addi	a1,s0,-1092
     5ae:	bc040513          	addi	a0,s0,-1088
     5b2:	b3fff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "outstanding", e->old_outstanding, e->outstanding);
     5b6:	874e                	mv	a4,s3
     5b8:	44b4                	lw	a3,72(s1)
     5ba:	00001617          	auipc	a2,0x1
     5be:	3ee60613          	addi	a2,a2,1006 # 19a8 <malloc+0x242>
     5c2:	bbc40593          	addi	a1,s0,-1092
     5c6:	bc040513          	addi	a0,s0,-1088
     5ca:	b27ff0ef          	jal	f0 <print_change>
        print_change(buf, &pos, "committing", e->old_committing, e->committing);
     5ce:	874a                	mv	a4,s2
     5d0:	48b4                	lw	a3,80(s1)
     5d2:	00001617          	auipc	a2,0x1
     5d6:	3e660613          	addi	a2,a2,998 # 19b8 <malloc+0x252>
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
     5fe:	12e68fe3          	beq	a3,a4,f3c <print_fs_event+0xdbe>
        append_str(buf, &pos, "}");
     602:	00001617          	auipc	a2,0x1
     606:	31e60613          	addi	a2,a2,798 # 1920 <malloc+0x1ba>
     60a:	bbc40593          	addi	a1,s0,-1092
     60e:	bc040513          	addi	a0,s0,-1088
     612:	9efff0ef          	jal	0 <append_str>
     616:	42813983          	ld	s3,1064(sp)
     61a:	42013a03          	ld	s4,1056(sp)
     61e:	bbed                	j	418 <print_fs_event+0x29a>
    append_str(buf, &pos, "BALLOC");
     620:	00001617          	auipc	a2,0x1
     624:	2b060613          	addi	a2,a2,688 # 18d0 <malloc+0x16a>
     628:	bbc40593          	addi	a1,s0,-1092
     62c:	bc040513          	addi	a0,s0,-1088
     630:	9d1ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     634:	00001617          	auipc	a2,0x1
     638:	22c60613          	addi	a2,a2,556 # 1860 <malloc+0xfa>
     63c:	bbc40593          	addi	a1,s0,-1092
     640:	bc040513          	addi	a0,s0,-1088
     644:	9bdff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     648:	00001617          	auipc	a2,0x1
     64c:	27860613          	addi	a2,a2,632 # 18c0 <malloc+0x15a>
     650:	bbc40593          	addi	a1,s0,-1092
     654:	bc040513          	addi	a0,s0,-1088
     658:	9a9ff0ef          	jal	0 <append_str>
     65c:	01448613          	addi	a2,s1,20
     660:	bbc40593          	addi	a1,s0,-1092
     664:	bc040513          	addi	a0,s0,-1088
     668:	999ff0ef          	jal	0 <append_str>
     66c:	00001617          	auipc	a2,0x1
     670:	1f460613          	addi	a2,a2,500 # 1860 <malloc+0xfa>
     674:	bbc40593          	addi	a1,s0,-1092
     678:	bc040513          	addi	a0,s0,-1088
     67c:	985ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"block\":");
     680:	00001617          	auipc	a2,0x1
     684:	29060613          	addi	a2,a2,656 # 1910 <malloc+0x1aa>
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
     6a6:	28660613          	addi	a2,a2,646 # 1928 <malloc+0x1c2>
     6aa:	bbc40593          	addi	a1,s0,-1092
     6ae:	bc040513          	addi	a0,s0,-1088
     6b2:	94fff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"bit\":");
     6b6:	00001617          	auipc	a2,0x1
     6ba:	31260613          	addi	a2,a2,786 # 19c8 <malloc+0x262>
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
     6e0:	24460613          	addi	a2,a2,580 # 1920 <malloc+0x1ba>
     6e4:	bbc40593          	addi	a1,s0,-1092
     6e8:	bc040513          	addi	a0,s0,-1088
     6ec:	915ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     6f0:	00001617          	auipc	a2,0x1
     6f4:	26060613          	addi	a2,a2,608 # 1950 <malloc+0x1ea>
     6f8:	bbc40593          	addi	a1,s0,-1092
     6fc:	bc040513          	addi	a0,s0,-1088
     700:	901ff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "bit", e->old_bit, e->bit);
     704:	874a                	mv	a4,s2
     706:	4cb4                	lw	a3,88(s1)
     708:	00001617          	auipc	a2,0x1
     70c:	2c860613          	addi	a2,a2,712 # 19d0 <malloc+0x26a>
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
     734:	00e688e3          	beq	a3,a4,f44 <print_fs_event+0xdc6>
    append_str(buf, &pos, "}");
     738:	00001617          	auipc	a2,0x1
     73c:	1e860613          	addi	a2,a2,488 # 1920 <malloc+0x1ba>
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
     762:	17a60613          	addi	a2,a2,378 # 18d8 <malloc+0x172>
     766:	bbc40593          	addi	a1,s0,-1092
     76a:	bc040513          	addi	a0,s0,-1088
     76e:	893ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     772:	00001617          	auipc	a2,0x1
     776:	0ee60613          	addi	a2,a2,238 # 1860 <malloc+0xfa>
     77a:	bbc40593          	addi	a1,s0,-1092
     77e:	bc040513          	addi	a0,s0,-1088
     782:	87fff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     786:	00001617          	auipc	a2,0x1
     78a:	13a60613          	addi	a2,a2,314 # 18c0 <malloc+0x15a>
     78e:	bbc40593          	addi	a1,s0,-1092
     792:	bc040513          	addi	a0,s0,-1088
     796:	86bff0ef          	jal	0 <append_str>
     79a:	01448613          	addi	a2,s1,20
     79e:	bbc40593          	addi	a1,s0,-1092
     7a2:	bc040513          	addi	a0,s0,-1088
     7a6:	85bff0ef          	jal	0 <append_str>
     7aa:	00001617          	auipc	a2,0x1
     7ae:	0b660613          	addi	a2,a2,182 # 1860 <malloc+0xfa>
     7b2:	bbc40593          	addi	a1,s0,-1092
     7b6:	bc040513          	addi	a0,s0,-1088
     7ba:	847ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"inode\":{");
     7be:	00001617          	auipc	a2,0x1
     7c2:	21a60613          	addi	a2,a2,538 # 19d8 <malloc+0x272>
     7c6:	bbc40593          	addi	a1,s0,-1092
     7ca:	bc040513          	addi	a0,s0,-1088
     7ce:	833ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"inum\":"); append_int(buf, &pos, e->inum);
     7d2:	00001617          	auipc	a2,0x1
     7d6:	21660613          	addi	a2,a2,534 # 19e8 <malloc+0x282>
     7da:	bbc40593          	addi	a1,s0,-1092
     7de:	bc040513          	addi	a0,s0,-1088
     7e2:	81fff0ef          	jal	0 <append_str>
     7e6:	4cf0                	lw	a2,92(s1)
     7e8:	bbc40593          	addi	a1,s0,-1092
     7ec:	bc040513          	addi	a0,s0,-1088
     7f0:	8c9ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     7f4:	00001617          	auipc	a2,0x1
     7f8:	12c60613          	addi	a2,a2,300 # 1920 <malloc+0x1ba>
     7fc:	bbc40593          	addi	a1,s0,-1092
     800:	bc040513          	addi	a0,s0,-1088
     804:	ffcff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"state\":{");
     808:	00001617          	auipc	a2,0x1
     80c:	12060613          	addi	a2,a2,288 # 1928 <malloc+0x1c2>
     810:	bbc40593          	addi	a1,s0,-1092
     814:	bc040513          	addi	a0,s0,-1088
     818:	fe8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->ref);
     81c:	00001617          	auipc	a2,0x1
     820:	11c60613          	addi	a2,a2,284 # 1938 <malloc+0x1d2>
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
     846:	0fe60613          	addi	a2,a2,254 # 1940 <malloc+0x1da>
     84a:	bbc40593          	addi	a1,s0,-1092
     84e:	bc040513          	addi	a0,s0,-1088
     852:	faeff0ef          	jal	0 <append_str>
     856:	0684aa83          	lw	s5,104(s1)
     85a:	8656                	mv	a2,s5
     85c:	bbc40593          	addi	a1,s0,-1092
     860:	bc040513          	addi	a0,s0,-1088
     864:	855ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"type\":"); append_int(buf, &pos, e->inode_type);
     868:	00001617          	auipc	a2,0x1
     86c:	18860613          	addi	a2,a2,392 # 19f0 <malloc+0x28a>
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
     892:	17260613          	addi	a2,a2,370 # 1a00 <malloc+0x29a>
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
     8b8:	15c60613          	addi	a2,a2,348 # 1a10 <malloc+0x2aa>
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
     8de:	04660613          	addi	a2,a2,70 # 1920 <malloc+0x1ba>
     8e2:	bbc40593          	addi	a1,s0,-1092
     8e6:	bc040513          	addi	a0,s0,-1088
     8ea:	f16ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     8ee:	00001617          	auipc	a2,0x1
     8f2:	06260613          	addi	a2,a2,98 # 1950 <malloc+0x1ea>
     8f6:	bbc40593          	addi	a1,s0,-1092
     8fa:	bc040513          	addi	a0,s0,-1088
     8fe:	f02ff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "ref", e->old_ref, e->ref);
     902:	875a                	mv	a4,s6
     904:	50f4                	lw	a3,100(s1)
     906:	00001617          	auipc	a2,0x1
     90a:	05a60613          	addi	a2,a2,90 # 1960 <malloc+0x1fa>
     90e:	bbc40593          	addi	a1,s0,-1092
     912:	bc040513          	addi	a0,s0,-1088
     916:	fdaff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "valid", e->old_valid_inode, e->valid_inode);
     91a:	8756                	mv	a4,s5
     91c:	54f4                	lw	a3,108(s1)
     91e:	00001617          	auipc	a2,0x1
     922:	04a60613          	addi	a2,a2,74 # 1968 <malloc+0x202>
     926:	bbc40593          	addi	a1,s0,-1092
     92a:	bc040513          	addi	a0,s0,-1088
     92e:	fc2ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "type", e->old_type_inode, e->inode_type);
     932:	8752                	mv	a4,s4
     934:	58f4                	lw	a3,116(s1)
     936:	00001617          	auipc	a2,0x1
     93a:	0ea60613          	addi	a2,a2,234 # 1a20 <malloc+0x2ba>
     93e:	bbc40593          	addi	a1,s0,-1092
     942:	bc040513          	addi	a0,s0,-1088
     946:	faaff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "size", e->old_size, e->size);
     94a:	874e                	mv	a4,s3
     94c:	5cf4                	lw	a3,124(s1)
     94e:	00001617          	auipc	a2,0x1
     952:	0da60613          	addi	a2,a2,218 # 1a28 <malloc+0x2c2>
     956:	bbc40593          	addi	a1,s0,-1092
     95a:	bc040513          	addi	a0,s0,-1088
     95e:	f92ff0ef          	jal	f0 <print_change>
    print_change(buf, &pos, "locked", e->old_locked, e->locked);
     962:	874a                	mv	a4,s2
     964:	0844a683          	lw	a3,132(s1)
     968:	00001617          	auipc	a2,0x1
     96c:	0c860613          	addi	a2,a2,200 # 1a30 <malloc+0x2ca>
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
     994:	5ce68663          	beq	a3,a4,f60 <print_fs_event+0xde2>
    append_str(buf, &pos, "}");
     998:	00001617          	auipc	a2,0x1
     99c:	f8860613          	addi	a2,a2,-120 # 1920 <malloc+0x1ba>
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
     9c2:	f2260613          	addi	a2,a2,-222 # 18e0 <malloc+0x17a>
     9c6:	bbc40593          	addi	a1,s0,-1092
     9ca:	bc040513          	addi	a0,s0,-1088
     9ce:	e32ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     9d2:	00001617          	auipc	a2,0x1
     9d6:	e8e60613          	addi	a2,a2,-370 # 1860 <malloc+0xfa>
     9da:	bbc40593          	addi	a1,s0,-1092
     9de:	bc040513          	addi	a0,s0,-1088
     9e2:	e1eff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     9e6:	00001617          	auipc	a2,0x1
     9ea:	eda60613          	addi	a2,a2,-294 # 18c0 <malloc+0x15a>
     9ee:	bbc40593          	addi	a1,s0,-1092
     9f2:	bc040513          	addi	a0,s0,-1088
     9f6:	e0aff0ef          	jal	0 <append_str>
     9fa:	01448613          	addi	a2,s1,20
     9fe:	bbc40593          	addi	a1,s0,-1092
     a02:	bc040513          	addi	a0,s0,-1088
     a06:	dfaff0ef          	jal	0 <append_str>
     a0a:	00001617          	auipc	a2,0x1
     a0e:	e5660613          	addi	a2,a2,-426 # 1860 <malloc+0xfa>
     a12:	bbc40593          	addi	a1,s0,-1092
     a16:	bc040513          	addi	a0,s0,-1088
     a1a:	de6ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"dir\":{");
     a1e:	00001617          	auipc	a2,0x1
     a22:	01a60613          	addi	a2,a2,26 # 1a38 <malloc+0x2d2>
     a26:	bbc40593          	addi	a1,s0,-1092
     a2a:	bc040513          	addi	a0,s0,-1088
     a2e:	dd2ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"parent\":");
     a32:	00001617          	auipc	a2,0x1
     a36:	01660613          	addi	a2,a2,22 # 1a48 <malloc+0x2e2>
     a3a:	bbc40593          	addi	a1,s0,-1092
     a3e:	bc040513          	addi	a0,s0,-1088
     a42:	dbeff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->parent_inum);
     a46:	1bc4a603          	lw	a2,444(s1)
     a4a:	bbc40593          	addi	a1,s0,-1092
     a4e:	bc040513          	addi	a0,s0,-1088
     a52:	e66ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"target\":");
     a56:	00001617          	auipc	a2,0x1
     a5a:	00260613          	addi	a2,a2,2 # 1a58 <malloc+0x2f2>
     a5e:	bbc40593          	addi	a1,s0,-1092
     a62:	bc040513          	addi	a0,s0,-1088
     a66:	d9aff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->target_inum);
     a6a:	1c04a603          	lw	a2,448(s1)
     a6e:	bbc40593          	addi	a1,s0,-1092
     a72:	bc040513          	addi	a0,s0,-1088
     a76:	e42ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"offset\":");
     a7a:	00001617          	auipc	a2,0x1
     a7e:	fee60613          	addi	a2,a2,-18 # 1a68 <malloc+0x302>
     a82:	bbc40593          	addi	a1,s0,-1092
     a86:	bc040513          	addi	a0,s0,-1088
     a8a:	d76ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->offset);
     a8e:	1c44a603          	lw	a2,452(s1)
     a92:	bbc40593          	addi	a1,s0,-1092
     a96:	bc040513          	addi	a0,s0,-1088
     a9a:	e1eff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"type\":");
     a9e:	00001617          	auipc	a2,0x1
     aa2:	f5260613          	addi	a2,a2,-174 # 19f0 <malloc+0x28a>
     aa6:	bbc40593          	addi	a1,s0,-1092
     aaa:	bc040513          	addi	a0,s0,-1088
     aae:	d52ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->inode_type);
     ab2:	58b0                	lw	a2,112(s1)
     ab4:	bbc40593          	addi	a1,s0,-1092
     ab8:	bc040513          	addi	a0,s0,-1088
     abc:	dfcff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"name\":\"");
     ac0:	00001617          	auipc	a2,0x1
     ac4:	fb860613          	addi	a2,a2,-72 # 1a78 <malloc+0x312>
     ac8:	bbc40593          	addi	a1,s0,-1092
     acc:	bc040513          	addi	a0,s0,-1088
     ad0:	d30ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
     ad4:	1a848613          	addi	a2,s1,424
     ad8:	bbc40593          	addi	a1,s0,-1092
     adc:	bc040513          	addi	a0,s0,-1088
     ae0:	d20ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"}");
     ae4:	00001617          	auipc	a2,0x1
     ae8:	fa460613          	addi	a2,a2,-92 # 1a88 <malloc+0x322>
     aec:	bbc40593          	addi	a1,s0,-1092
     af0:	bc040513          	addi	a0,s0,-1088
     af4:	d0cff0ef          	jal	0 <append_str>
     af8:	921ff06f          	j	418 <print_fs_event+0x29a>
    append_str(buf, &pos, "PATH");
     afc:	00001617          	auipc	a2,0x1
     b00:	dec60613          	addi	a2,a2,-532 # 18e8 <malloc+0x182>
     b04:	bbc40593          	addi	a1,s0,-1092
     b08:	bc040513          	addi	a0,s0,-1088
     b0c:	cf4ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     b10:	00001617          	auipc	a2,0x1
     b14:	d5060613          	addi	a2,a2,-688 # 1860 <malloc+0xfa>
     b18:	bbc40593          	addi	a1,s0,-1092
     b1c:	bc040513          	addi	a0,s0,-1088
     b20:	ce0ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     b24:	00001617          	auipc	a2,0x1
     b28:	d9c60613          	addi	a2,a2,-612 # 18c0 <malloc+0x15a>
     b2c:	bbc40593          	addi	a1,s0,-1092
     b30:	bc040513          	addi	a0,s0,-1088
     b34:	cccff0ef          	jal	0 <append_str>
     b38:	01448613          	addi	a2,s1,20
     b3c:	bbc40593          	addi	a1,s0,-1092
     b40:	bc040513          	addi	a0,s0,-1088
     b44:	cbcff0ef          	jal	0 <append_str>
     b48:	00001617          	auipc	a2,0x1
     b4c:	d1860613          	addi	a2,a2,-744 # 1860 <malloc+0xfa>
     b50:	bbc40593          	addi	a1,s0,-1092
     b54:	bc040513          	addi	a0,s0,-1088
     b58:	ca8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"syscall\":\"");
     b5c:	00001617          	auipc	a2,0x1
     b60:	f3460613          	addi	a2,a2,-204 # 1a90 <malloc+0x32a>
     b64:	bbc40593          	addi	a1,s0,-1092
     b68:	bc040513          	addi	a0,s0,-1088
     b6c:	c94ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->syscall);
     b70:	10848613          	addi	a2,s1,264
     b74:	bbc40593          	addi	a1,s0,-1092
     b78:	bc040513          	addi	a0,s0,-1088
     b7c:	c84ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     b80:	00001617          	auipc	a2,0x1
     b84:	ce060613          	addi	a2,a2,-800 # 1860 <malloc+0xfa>
     b88:	bbc40593          	addi	a1,s0,-1092
     b8c:	bc040513          	addi	a0,s0,-1088
     b90:	c70ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"cwd\":\"");
     b94:	00001617          	auipc	a2,0x1
     b98:	f0c60613          	addi	a2,a2,-244 # 1aa0 <malloc+0x33a>
     b9c:	bbc40593          	addi	a1,s0,-1092
     ba0:	bc040513          	addi	a0,s0,-1088
     ba4:	c5cff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->cwd);
     ba8:	08848613          	addi	a2,s1,136
     bac:	bbc40593          	addi	a1,s0,-1092
     bb0:	bc040513          	addi	a0,s0,-1088
     bb4:	c4cff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     bb8:	00001617          	auipc	a2,0x1
     bbc:	ca860613          	addi	a2,a2,-856 # 1860 <malloc+0xfa>
     bc0:	bbc40593          	addi	a1,s0,-1092
     bc4:	bc040513          	addi	a0,s0,-1088
     bc8:	c38ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"path\":\"");
     bcc:	00001617          	auipc	a2,0x1
     bd0:	ee460613          	addi	a2,a2,-284 # 1ab0 <malloc+0x34a>
     bd4:	bbc40593          	addi	a1,s0,-1092
     bd8:	bc040513          	addi	a0,s0,-1088
     bdc:	c24ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->path);
     be0:	12848613          	addi	a2,s1,296
     be4:	bbc40593          	addi	a1,s0,-1092
     be8:	bc040513          	addi	a0,s0,-1088
     bec:	c14ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     bf0:	00001617          	auipc	a2,0x1
     bf4:	c7060613          	addi	a2,a2,-912 # 1860 <malloc+0xfa>
     bf8:	bbc40593          	addi	a1,s0,-1092
     bfc:	bc040513          	addi	a0,s0,-1088
     c00:	c00ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"elem\":\"");
     c04:	00001617          	auipc	a2,0x1
     c08:	ebc60613          	addi	a2,a2,-324 # 1ac0 <malloc+0x35a>
     c0c:	bbc40593          	addi	a1,s0,-1092
     c10:	bc040513          	addi	a0,s0,-1088
     c14:	becff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->name);
     c18:	1a848613          	addi	a2,s1,424
     c1c:	bbc40593          	addi	a1,s0,-1092
     c20:	bc040513          	addi	a0,s0,-1088
     c24:	bdcff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     c28:	00001617          	auipc	a2,0x1
     c2c:	c3860613          	addi	a2,a2,-968 # 1860 <malloc+0xfa>
     c30:	bbc40593          	addi	a1,s0,-1092
     c34:	bc040513          	addi	a0,s0,-1088
     c38:	bc8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"inode\":");
     c3c:	00001617          	auipc	a2,0x1
     c40:	e9460613          	addi	a2,a2,-364 # 1ad0 <malloc+0x36a>
     c44:	bbc40593          	addi	a1,s0,-1092
     c48:	bc040513          	addi	a0,s0,-1088
     c4c:	bb4ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->parent_inum);
     c50:	1bc4a603          	lw	a2,444(s1)
     c54:	bbc40593          	addi	a1,s0,-1092
     c58:	bc040513          	addi	a0,s0,-1088
     c5c:	c5cff0ef          	jal	b8 <append_int>
     c60:	fb8ff06f          	j	418 <print_fs_event+0x29a>
     c64:	43313423          	sd	s3,1064(sp)
    append_str(buf, &pos, "FILE");
     c68:	00001617          	auipc	a2,0x1
     c6c:	c8860613          	addi	a2,a2,-888 # 18f0 <malloc+0x18a>
     c70:	bbc40593          	addi	a1,s0,-1092
     c74:	bc040513          	addi	a0,s0,-1088
     c78:	b88ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     c7c:	00001617          	auipc	a2,0x1
     c80:	be460613          	addi	a2,a2,-1052 # 1860 <malloc+0xfa>
     c84:	bbc40593          	addi	a1,s0,-1092
     c88:	bc040513          	addi	a0,s0,-1088
     c8c:	b74ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     c90:	00001617          	auipc	a2,0x1
     c94:	c3060613          	addi	a2,a2,-976 # 18c0 <malloc+0x15a>
     c98:	bbc40593          	addi	a1,s0,-1092
     c9c:	bc040513          	addi	a0,s0,-1088
     ca0:	b60ff0ef          	jal	0 <append_str>
     ca4:	01448613          	addi	a2,s1,20
     ca8:	bbc40593          	addi	a1,s0,-1092
     cac:	bc040513          	addi	a0,s0,-1088
     cb0:	b50ff0ef          	jal	0 <append_str>
     cb4:	00001617          	auipc	a2,0x1
     cb8:	bac60613          	addi	a2,a2,-1108 # 1860 <malloc+0xfa>
     cbc:	bbc40593          	addi	a1,s0,-1092
     cc0:	bc040513          	addi	a0,s0,-1088
     cc4:	b3cff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"fd\":");
     cc8:	00001617          	auipc	a2,0x1
     ccc:	e1860613          	addi	a2,a2,-488 # 1ae0 <malloc+0x37a>
     cd0:	bbc40593          	addi	a1,s0,-1092
     cd4:	bc040513          	addi	a0,s0,-1088
     cd8:	b28ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->fd);
     cdc:	1c84a603          	lw	a2,456(s1)
     ce0:	bbc40593          	addi	a1,s0,-1092
     ce4:	bc040513          	addi	a0,s0,-1088
     ce8:	bd0ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"file_type\":\"");
     cec:	00001617          	auipc	a2,0x1
     cf0:	dfc60613          	addi	a2,a2,-516 # 1ae8 <malloc+0x382>
     cf4:	bbc40593          	addi	a1,s0,-1092
     cf8:	bc040513          	addi	a0,s0,-1088
     cfc:	b04ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->file_type_str);
     d00:	1d048613          	addi	a2,s1,464
     d04:	bbc40593          	addi	a1,s0,-1092
     d08:	bc040513          	addi	a0,s0,-1088
     d0c:	af4ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     d10:	00001617          	auipc	a2,0x1
     d14:	b5060613          	addi	a2,a2,-1200 # 1860 <malloc+0xfa>
     d18:	bbc40593          	addi	a1,s0,-1092
     d1c:	bc040513          	addi	a0,s0,-1088
     d20:	ae0ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"path\":\"");
     d24:	00001617          	auipc	a2,0x1
     d28:	d8c60613          	addi	a2,a2,-628 # 1ab0 <malloc+0x34a>
     d2c:	bbc40593          	addi	a1,s0,-1092
     d30:	bc040513          	addi	a0,s0,-1088
     d34:	accff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->path);
     d38:	12848613          	addi	a2,s1,296
     d3c:	bbc40593          	addi	a1,s0,-1092
     d40:	bc040513          	addi	a0,s0,-1088
     d44:	abcff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     d48:	00001617          	auipc	a2,0x1
     d4c:	b1860613          	addi	a2,a2,-1256 # 1860 <malloc+0xfa>
     d50:	bbc40593          	addi	a1,s0,-1092
     d54:	bc040513          	addi	a0,s0,-1088
     d58:	aa8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"inum\":");
     d5c:	00001617          	auipc	a2,0x1
     d60:	d9c60613          	addi	a2,a2,-612 # 1af8 <malloc+0x392>
     d64:	bbc40593          	addi	a1,s0,-1092
     d68:	bc040513          	addi	a0,s0,-1088
     d6c:	a94ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->inum);
     d70:	4cf0                	lw	a2,92(s1)
     d72:	bbc40593          	addi	a1,s0,-1092
     d76:	bc040513          	addi	a0,s0,-1088
     d7a:	b3eff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"state\":{");
     d7e:	00001617          	auipc	a2,0x1
     d82:	baa60613          	addi	a2,a2,-1110 # 1928 <malloc+0x1c2>
     d86:	bbc40593          	addi	a1,s0,-1092
     d8a:	bc040513          	addi	a0,s0,-1088
     d8e:	a72ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":");
     d92:	00001617          	auipc	a2,0x1
     d96:	ba660613          	addi	a2,a2,-1114 # 1938 <malloc+0x1d2>
     d9a:	bbc40593          	addi	a1,s0,-1092
     d9e:	bc040513          	addi	a0,s0,-1088
     da2:	a5eff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file_ref);
     da6:	1e84a983          	lw	s3,488(s1)
     daa:	864e                	mv	a2,s3
     dac:	bbc40593          	addi	a1,s0,-1092
     db0:	bc040513          	addi	a0,s0,-1088
     db4:	b04ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"offset\":");
     db8:	00001617          	auipc	a2,0x1
     dbc:	cb060613          	addi	a2,a2,-848 # 1a68 <malloc+0x302>
     dc0:	bbc40593          	addi	a1,s0,-1092
     dc4:	bc040513          	addi	a0,s0,-1088
     dc8:	a38ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file_off);
     dcc:	1f04a903          	lw	s2,496(s1)
     dd0:	864a                	mv	a2,s2
     dd2:	bbc40593          	addi	a1,s0,-1092
     dd6:	bc040513          	addi	a0,s0,-1088
     dda:	adeff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"readable\":");
     dde:	00001617          	auipc	a2,0x1
     de2:	d2a60613          	addi	a2,a2,-726 # 1b08 <malloc+0x3a2>
     de6:	bbc40593          	addi	a1,s0,-1092
     dea:	bc040513          	addi	a0,s0,-1088
     dee:	a12ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->readable);
     df2:	1e04a603          	lw	a2,480(s1)
     df6:	bbc40593          	addi	a1,s0,-1092
     dfa:	bc040513          	addi	a0,s0,-1088
     dfe:	abaff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, ",\"writable\":");
     e02:	00001617          	auipc	a2,0x1
     e06:	d1660613          	addi	a2,a2,-746 # 1b18 <malloc+0x3b2>
     e0a:	bbc40593          	addi	a1,s0,-1092
     e0e:	bc040513          	addi	a0,s0,-1088
     e12:	9eeff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->writable);
     e16:	1e44a603          	lw	a2,484(s1)
     e1a:	bbc40593          	addi	a1,s0,-1092
     e1e:	bc040513          	addi	a0,s0,-1088
     e22:	a96ff0ef          	jal	b8 <append_int>
    append_str(buf, &pos, "}");
     e26:	00001617          	auipc	a2,0x1
     e2a:	afa60613          	addi	a2,a2,-1286 # 1920 <malloc+0x1ba>
     e2e:	bbc40593          	addi	a1,s0,-1092
     e32:	bc040513          	addi	a0,s0,-1088
     e36:	9caff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     e3a:	00001617          	auipc	a2,0x1
     e3e:	b1660613          	addi	a2,a2,-1258 # 1950 <malloc+0x1ea>
     e42:	bbc40593          	addi	a1,s0,-1092
     e46:	bc040513          	addi	a0,s0,-1088
     e4a:	9b6ff0ef          	jal	0 <append_str>
    print_change(buf, &pos,
     e4e:	874e                	mv	a4,s3
     e50:	1ec4a683          	lw	a3,492(s1)
     e54:	00001617          	auipc	a2,0x1
     e58:	b0c60613          	addi	a2,a2,-1268 # 1960 <malloc+0x1fa>
     e5c:	bbc40593          	addi	a1,s0,-1092
     e60:	bc040513          	addi	a0,s0,-1088
     e64:	a8cff0ef          	jal	f0 <print_change>
    print_change(buf, &pos,
     e68:	874a                	mv	a4,s2
     e6a:	1f44a683          	lw	a3,500(s1)
     e6e:	00001617          	auipc	a2,0x1
     e72:	cba60613          	addi	a2,a2,-838 # 1b28 <malloc+0x3c2>
     e76:	bbc40593          	addi	a1,s0,-1092
     e7a:	bc040513          	addi	a0,s0,-1088
     e7e:	a72ff0ef          	jal	f0 <print_change>
    if(buf[pos-1] == ',')
     e82:	bbc42783          	lw	a5,-1092(s0)
     e86:	37fd                	addiw	a5,a5,-1
     e88:	0007871b          	sext.w	a4,a5
     e8c:	fc070713          	addi	a4,a4,-64
     e90:	9722                	add	a4,a4,s0
     e92:	c0074683          	lbu	a3,-1024(a4)
     e96:	02c00713          	li	a4,44
     e9a:	0ce68963          	beq	a3,a4,f6c <print_fs_event+0xdee>
    append_str(buf, &pos, "}");
     e9e:	00001617          	auipc	a2,0x1
     ea2:	a8260613          	addi	a2,a2,-1406 # 1920 <malloc+0x1ba>
     ea6:	bbc40593          	addi	a1,s0,-1092
     eaa:	bc040513          	addi	a0,s0,-1088
     eae:	952ff0ef          	jal	0 <append_str>
     eb2:	42813983          	ld	s3,1064(sp)
     eb6:	d62ff06f          	j	418 <print_fs_event+0x29a>
    append_str(buf, &pos, "\"");
     eba:	00001617          	auipc	a2,0x1
     ebe:	9a660613          	addi	a2,a2,-1626 # 1860 <malloc+0xfa>
     ec2:	bbc40593          	addi	a1,s0,-1092
     ec6:	bc040513          	addi	a0,s0,-1088
     eca:	936ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     ece:	00001617          	auipc	a2,0x1
     ed2:	9f260613          	addi	a2,a2,-1550 # 18c0 <malloc+0x15a>
     ed6:	bbc40593          	addi	a1,s0,-1092
     eda:	bc040513          	addi	a0,s0,-1088
     ede:	922ff0ef          	jal	0 <append_str>
     ee2:	01448613          	addi	a2,s1,20
     ee6:	bbc40593          	addi	a1,s0,-1092
     eea:	bc040513          	addi	a0,s0,-1088
     eee:	912ff0ef          	jal	0 <append_str>
     ef2:	00001617          	auipc	a2,0x1
     ef6:	96e60613          	addi	a2,a2,-1682 # 1860 <malloc+0xfa>
     efa:	bbc40593          	addi	a1,s0,-1092
     efe:	bc040513          	addi	a0,s0,-1088
     f02:	8feff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE){
     f06:	479d                	li	a5,7
     f08:	d127e863          	bltu	a5,s2,418 <print_fs_event+0x29a>
     f0c:	090a                	slli	s2,s2,0x2
     f0e:	00001717          	auipc	a4,0x1
     f12:	caa70713          	addi	a4,a4,-854 # 1bb8 <malloc+0x452>
     f16:	993a                	add	s2,s2,a4
     f18:	00092783          	lw	a5,0(s2)
     f1c:	97ba                	add	a5,a5,a4
     f1e:	8782                	jr	a5
     f20:	43313423          	sd	s3,1064(sp)
     f24:	b9cff06f          	j	2c0 <print_fs_event+0x142>
        if(buf[pos-1] == ',') pos--; // remove last comma
     f28:	baf42e23          	sw	a5,-1092(s0)
     f2c:	cd4ff06f          	j	400 <print_fs_event+0x282>
     f30:	43313423          	sd	s3,1064(sp)
     f34:	43413023          	sd	s4,1056(sp)
     f38:	db8ff06f          	j	4f0 <print_fs_event+0x372>
        if(buf[pos-1] == ',') pos--;
     f3c:	baf42e23          	sw	a5,-1092(s0)
     f40:	ec2ff06f          	j	602 <print_fs_event+0x484>
    if(buf[pos-1] == ',') pos--;
     f44:	baf42e23          	sw	a5,-1092(s0)
     f48:	ff0ff06f          	j	738 <print_fs_event+0x5ba>
     f4c:	43313423          	sd	s3,1064(sp)
     f50:	43413023          	sd	s4,1056(sp)
     f54:	41513c23          	sd	s5,1048(sp)
     f58:	41613823          	sd	s6,1040(sp)
     f5c:	863ff06f          	j	7be <print_fs_event+0x640>
    if(buf[pos-1] == ',') pos--;
     f60:	baf42e23          	sw	a5,-1092(s0)
     f64:	bc15                	j	998 <print_fs_event+0x81a>
     f66:	43313423          	sd	s3,1064(sp)
     f6a:	bbb9                	j	cc8 <print_fs_event+0xb4a>
        pos--;
     f6c:	baf42e23          	sw	a5,-1092(s0)
     f70:	b73d                	j	e9e <print_fs_event+0xd20>

0000000000000f72 <main>:

int main(void) {
     f72:	7179                	addi	sp,sp,-48
     f74:	f406                	sd	ra,40(sp)
     f76:	f022                	sd	s0,32(sp)
     f78:	ec26                	sd	s1,24(sp)
     f7a:	e84a                	sd	s2,16(sp)
     f7c:	e44e                	sd	s3,8(sp)
     f7e:	e052                	sd	s4,0(sp)
     f80:	1800                	addi	s0,sp,48
    printf("FS Buffer Cache Export starting...\n");
     f82:	00001517          	auipc	a0,0x1
     f86:	bc650513          	addi	a0,a0,-1082 # 1b48 <malloc+0x3e2>
     f8a:	728000ef          	jal	16b2 <printf>
    
    while (1) {
        int n_fs = fsread(fs_ev, 16);
     f8e:	00001997          	auipc	s3,0x1
     f92:	08298993          	addi	s3,s3,130 # 2010 <fs_ev>
     f96:	30800a13          	li	s4,776
     f9a:	a831                	j	fb6 <main+0x44>
        if (n_fs < 0) {
            fprintf(2, "fsexport: error reading fslog\n");
     f9c:	00001597          	auipc	a1,0x1
     fa0:	bd458593          	addi	a1,a1,-1068 # 1b70 <malloc+0x40a>
     fa4:	4509                	li	a0,2
     fa6:	6e2000ef          	jal	1688 <fprintf>
            exit(1);
     faa:	4505                	li	a0,1
     fac:	2ce000ef          	jal	127a <exit>
        for (int i = 0; i < n_fs; i++) {
            print_fs_event(&fs_ev[i]);
        }

        // استخدام sleep(2) بدلاً من pause في xv6 لضمان استمرار الحلقة
        pause(2); 
     fb0:	4509                	li	a0,2
     fb2:	358000ef          	jal	130a <pause>
        int n_fs = fsread(fs_ev, 16);
     fb6:	45c1                	li	a1,16
     fb8:	854e                	mv	a0,s3
     fba:	368000ef          	jal	1322 <fsread>
        if (n_fs < 0) {
     fbe:	fc054fe3          	bltz	a0,f9c <main+0x2a>
        for (int i = 0; i < n_fs; i++) {
     fc2:	fea057e3          	blez	a0,fb0 <main+0x3e>
     fc6:	00001497          	auipc	s1,0x1
     fca:	04a48493          	addi	s1,s1,74 # 2010 <fs_ev>
     fce:	03450533          	mul	a0,a0,s4
     fd2:	00950933          	add	s2,a0,s1
            print_fs_event(&fs_ev[i]);
     fd6:	8526                	mv	a0,s1
     fd8:	9a6ff0ef          	jal	17e <print_fs_event>
        for (int i = 0; i < n_fs; i++) {
     fdc:	30848493          	addi	s1,s1,776
     fe0:	ff249be3          	bne	s1,s2,fd6 <main+0x64>
     fe4:	b7f1                	j	fb0 <main+0x3e>

0000000000000fe6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     fe6:	1141                	addi	sp,sp,-16
     fe8:	e406                	sd	ra,8(sp)
     fea:	e022                	sd	s0,0(sp)
     fec:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     fee:	f85ff0ef          	jal	f72 <main>
  exit(r);
     ff2:	288000ef          	jal	127a <exit>

0000000000000ff6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     ff6:	1141                	addi	sp,sp,-16
     ff8:	e422                	sd	s0,8(sp)
     ffa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     ffc:	87aa                	mv	a5,a0
     ffe:	0585                	addi	a1,a1,1
    1000:	0785                	addi	a5,a5,1
    1002:	fff5c703          	lbu	a4,-1(a1)
    1006:	fee78fa3          	sb	a4,-1(a5)
    100a:	fb75                	bnez	a4,ffe <strcpy+0x8>
    ;
  return os;
}
    100c:	6422                	ld	s0,8(sp)
    100e:	0141                	addi	sp,sp,16
    1010:	8082                	ret

0000000000001012 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1012:	1141                	addi	sp,sp,-16
    1014:	e422                	sd	s0,8(sp)
    1016:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    1018:	00054783          	lbu	a5,0(a0)
    101c:	cb91                	beqz	a5,1030 <strcmp+0x1e>
    101e:	0005c703          	lbu	a4,0(a1)
    1022:	00f71763          	bne	a4,a5,1030 <strcmp+0x1e>
    p++, q++;
    1026:	0505                	addi	a0,a0,1
    1028:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    102a:	00054783          	lbu	a5,0(a0)
    102e:	fbe5                	bnez	a5,101e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    1030:	0005c503          	lbu	a0,0(a1)
}
    1034:	40a7853b          	subw	a0,a5,a0
    1038:	6422                	ld	s0,8(sp)
    103a:	0141                	addi	sp,sp,16
    103c:	8082                	ret

000000000000103e <strlen>:

uint
strlen(const char *s)
{
    103e:	1141                	addi	sp,sp,-16
    1040:	e422                	sd	s0,8(sp)
    1042:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    1044:	00054783          	lbu	a5,0(a0)
    1048:	cf91                	beqz	a5,1064 <strlen+0x26>
    104a:	0505                	addi	a0,a0,1
    104c:	87aa                	mv	a5,a0
    104e:	86be                	mv	a3,a5
    1050:	0785                	addi	a5,a5,1
    1052:	fff7c703          	lbu	a4,-1(a5)
    1056:	ff65                	bnez	a4,104e <strlen+0x10>
    1058:	40a6853b          	subw	a0,a3,a0
    105c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    105e:	6422                	ld	s0,8(sp)
    1060:	0141                	addi	sp,sp,16
    1062:	8082                	ret
  for(n = 0; s[n]; n++)
    1064:	4501                	li	a0,0
    1066:	bfe5                	j	105e <strlen+0x20>

0000000000001068 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1068:	1141                	addi	sp,sp,-16
    106a:	e422                	sd	s0,8(sp)
    106c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    106e:	ca19                	beqz	a2,1084 <memset+0x1c>
    1070:	87aa                	mv	a5,a0
    1072:	1602                	slli	a2,a2,0x20
    1074:	9201                	srli	a2,a2,0x20
    1076:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    107a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    107e:	0785                	addi	a5,a5,1
    1080:	fee79de3          	bne	a5,a4,107a <memset+0x12>
  }
  return dst;
}
    1084:	6422                	ld	s0,8(sp)
    1086:	0141                	addi	sp,sp,16
    1088:	8082                	ret

000000000000108a <strchr>:

char*
strchr(const char *s, char c)
{
    108a:	1141                	addi	sp,sp,-16
    108c:	e422                	sd	s0,8(sp)
    108e:	0800                	addi	s0,sp,16
  for(; *s; s++)
    1090:	00054783          	lbu	a5,0(a0)
    1094:	cb99                	beqz	a5,10aa <strchr+0x20>
    if(*s == c)
    1096:	00f58763          	beq	a1,a5,10a4 <strchr+0x1a>
  for(; *s; s++)
    109a:	0505                	addi	a0,a0,1
    109c:	00054783          	lbu	a5,0(a0)
    10a0:	fbfd                	bnez	a5,1096 <strchr+0xc>
      return (char*)s;
  return 0;
    10a2:	4501                	li	a0,0
}
    10a4:	6422                	ld	s0,8(sp)
    10a6:	0141                	addi	sp,sp,16
    10a8:	8082                	ret
  return 0;
    10aa:	4501                	li	a0,0
    10ac:	bfe5                	j	10a4 <strchr+0x1a>

00000000000010ae <gets>:

char*
gets(char *buf, int max)
{
    10ae:	711d                	addi	sp,sp,-96
    10b0:	ec86                	sd	ra,88(sp)
    10b2:	e8a2                	sd	s0,80(sp)
    10b4:	e4a6                	sd	s1,72(sp)
    10b6:	e0ca                	sd	s2,64(sp)
    10b8:	fc4e                	sd	s3,56(sp)
    10ba:	f852                	sd	s4,48(sp)
    10bc:	f456                	sd	s5,40(sp)
    10be:	f05a                	sd	s6,32(sp)
    10c0:	ec5e                	sd	s7,24(sp)
    10c2:	1080                	addi	s0,sp,96
    10c4:	8baa                	mv	s7,a0
    10c6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    10c8:	892a                	mv	s2,a0
    10ca:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    10cc:	4aa9                	li	s5,10
    10ce:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    10d0:	89a6                	mv	s3,s1
    10d2:	2485                	addiw	s1,s1,1
    10d4:	0344d663          	bge	s1,s4,1100 <gets+0x52>
    cc = read(0, &c, 1);
    10d8:	4605                	li	a2,1
    10da:	faf40593          	addi	a1,s0,-81
    10de:	4501                	li	a0,0
    10e0:	1b2000ef          	jal	1292 <read>
    if(cc < 1)
    10e4:	00a05e63          	blez	a0,1100 <gets+0x52>
    buf[i++] = c;
    10e8:	faf44783          	lbu	a5,-81(s0)
    10ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    10f0:	01578763          	beq	a5,s5,10fe <gets+0x50>
    10f4:	0905                	addi	s2,s2,1
    10f6:	fd679de3          	bne	a5,s6,10d0 <gets+0x22>
    buf[i++] = c;
    10fa:	89a6                	mv	s3,s1
    10fc:	a011                	j	1100 <gets+0x52>
    10fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    1100:	99de                	add	s3,s3,s7
    1102:	00098023          	sb	zero,0(s3)
  return buf;
}
    1106:	855e                	mv	a0,s7
    1108:	60e6                	ld	ra,88(sp)
    110a:	6446                	ld	s0,80(sp)
    110c:	64a6                	ld	s1,72(sp)
    110e:	6906                	ld	s2,64(sp)
    1110:	79e2                	ld	s3,56(sp)
    1112:	7a42                	ld	s4,48(sp)
    1114:	7aa2                	ld	s5,40(sp)
    1116:	7b02                	ld	s6,32(sp)
    1118:	6be2                	ld	s7,24(sp)
    111a:	6125                	addi	sp,sp,96
    111c:	8082                	ret

000000000000111e <stat>:

int
stat(const char *n, struct stat *st)
{
    111e:	1101                	addi	sp,sp,-32
    1120:	ec06                	sd	ra,24(sp)
    1122:	e822                	sd	s0,16(sp)
    1124:	e04a                	sd	s2,0(sp)
    1126:	1000                	addi	s0,sp,32
    1128:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    112a:	4581                	li	a1,0
    112c:	18e000ef          	jal	12ba <open>
  if(fd < 0)
    1130:	02054263          	bltz	a0,1154 <stat+0x36>
    1134:	e426                	sd	s1,8(sp)
    1136:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    1138:	85ca                	mv	a1,s2
    113a:	198000ef          	jal	12d2 <fstat>
    113e:	892a                	mv	s2,a0
  close(fd);
    1140:	8526                	mv	a0,s1
    1142:	160000ef          	jal	12a2 <close>
  return r;
    1146:	64a2                	ld	s1,8(sp)
}
    1148:	854a                	mv	a0,s2
    114a:	60e2                	ld	ra,24(sp)
    114c:	6442                	ld	s0,16(sp)
    114e:	6902                	ld	s2,0(sp)
    1150:	6105                	addi	sp,sp,32
    1152:	8082                	ret
    return -1;
    1154:	597d                	li	s2,-1
    1156:	bfcd                	j	1148 <stat+0x2a>

0000000000001158 <atoi>:

int
atoi(const char *s)
{
    1158:	1141                	addi	sp,sp,-16
    115a:	e422                	sd	s0,8(sp)
    115c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    115e:	00054683          	lbu	a3,0(a0)
    1162:	fd06879b          	addiw	a5,a3,-48
    1166:	0ff7f793          	zext.b	a5,a5
    116a:	4625                	li	a2,9
    116c:	02f66863          	bltu	a2,a5,119c <atoi+0x44>
    1170:	872a                	mv	a4,a0
  n = 0;
    1172:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    1174:	0705                	addi	a4,a4,1
    1176:	0025179b          	slliw	a5,a0,0x2
    117a:	9fa9                	addw	a5,a5,a0
    117c:	0017979b          	slliw	a5,a5,0x1
    1180:	9fb5                	addw	a5,a5,a3
    1182:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    1186:	00074683          	lbu	a3,0(a4)
    118a:	fd06879b          	addiw	a5,a3,-48
    118e:	0ff7f793          	zext.b	a5,a5
    1192:	fef671e3          	bgeu	a2,a5,1174 <atoi+0x1c>
  return n;
}
    1196:	6422                	ld	s0,8(sp)
    1198:	0141                	addi	sp,sp,16
    119a:	8082                	ret
  n = 0;
    119c:	4501                	li	a0,0
    119e:	bfe5                	j	1196 <atoi+0x3e>

00000000000011a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    11a0:	1141                	addi	sp,sp,-16
    11a2:	e422                	sd	s0,8(sp)
    11a4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    11a6:	02b57463          	bgeu	a0,a1,11ce <memmove+0x2e>
    while(n-- > 0)
    11aa:	00c05f63          	blez	a2,11c8 <memmove+0x28>
    11ae:	1602                	slli	a2,a2,0x20
    11b0:	9201                	srli	a2,a2,0x20
    11b2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    11b6:	872a                	mv	a4,a0
      *dst++ = *src++;
    11b8:	0585                	addi	a1,a1,1
    11ba:	0705                	addi	a4,a4,1
    11bc:	fff5c683          	lbu	a3,-1(a1)
    11c0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    11c4:	fef71ae3          	bne	a4,a5,11b8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    11c8:	6422                	ld	s0,8(sp)
    11ca:	0141                	addi	sp,sp,16
    11cc:	8082                	ret
    dst += n;
    11ce:	00c50733          	add	a4,a0,a2
    src += n;
    11d2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    11d4:	fec05ae3          	blez	a2,11c8 <memmove+0x28>
    11d8:	fff6079b          	addiw	a5,a2,-1
    11dc:	1782                	slli	a5,a5,0x20
    11de:	9381                	srli	a5,a5,0x20
    11e0:	fff7c793          	not	a5,a5
    11e4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    11e6:	15fd                	addi	a1,a1,-1
    11e8:	177d                	addi	a4,a4,-1
    11ea:	0005c683          	lbu	a3,0(a1)
    11ee:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    11f2:	fee79ae3          	bne	a5,a4,11e6 <memmove+0x46>
    11f6:	bfc9                	j	11c8 <memmove+0x28>

00000000000011f8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    11f8:	1141                	addi	sp,sp,-16
    11fa:	e422                	sd	s0,8(sp)
    11fc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    11fe:	ca05                	beqz	a2,122e <memcmp+0x36>
    1200:	fff6069b          	addiw	a3,a2,-1
    1204:	1682                	slli	a3,a3,0x20
    1206:	9281                	srli	a3,a3,0x20
    1208:	0685                	addi	a3,a3,1
    120a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    120c:	00054783          	lbu	a5,0(a0)
    1210:	0005c703          	lbu	a4,0(a1)
    1214:	00e79863          	bne	a5,a4,1224 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    1218:	0505                	addi	a0,a0,1
    p2++;
    121a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    121c:	fed518e3          	bne	a0,a3,120c <memcmp+0x14>
  }
  return 0;
    1220:	4501                	li	a0,0
    1222:	a019                	j	1228 <memcmp+0x30>
      return *p1 - *p2;
    1224:	40e7853b          	subw	a0,a5,a4
}
    1228:	6422                	ld	s0,8(sp)
    122a:	0141                	addi	sp,sp,16
    122c:	8082                	ret
  return 0;
    122e:	4501                	li	a0,0
    1230:	bfe5                	j	1228 <memcmp+0x30>

0000000000001232 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    1232:	1141                	addi	sp,sp,-16
    1234:	e406                	sd	ra,8(sp)
    1236:	e022                	sd	s0,0(sp)
    1238:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    123a:	f67ff0ef          	jal	11a0 <memmove>
}
    123e:	60a2                	ld	ra,8(sp)
    1240:	6402                	ld	s0,0(sp)
    1242:	0141                	addi	sp,sp,16
    1244:	8082                	ret

0000000000001246 <sbrk>:

char *
sbrk(int n) {
    1246:	1141                	addi	sp,sp,-16
    1248:	e406                	sd	ra,8(sp)
    124a:	e022                	sd	s0,0(sp)
    124c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
    124e:	4585                	li	a1,1
    1250:	0b2000ef          	jal	1302 <sys_sbrk>
}
    1254:	60a2                	ld	ra,8(sp)
    1256:	6402                	ld	s0,0(sp)
    1258:	0141                	addi	sp,sp,16
    125a:	8082                	ret

000000000000125c <sbrklazy>:

char *
sbrklazy(int n) {
    125c:	1141                	addi	sp,sp,-16
    125e:	e406                	sd	ra,8(sp)
    1260:	e022                	sd	s0,0(sp)
    1262:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    1264:	4589                	li	a1,2
    1266:	09c000ef          	jal	1302 <sys_sbrk>
}
    126a:	60a2                	ld	ra,8(sp)
    126c:	6402                	ld	s0,0(sp)
    126e:	0141                	addi	sp,sp,16
    1270:	8082                	ret

0000000000001272 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    1272:	4885                	li	a7,1
 ecall
    1274:	00000073          	ecall
 ret
    1278:	8082                	ret

000000000000127a <exit>:
.global exit
exit:
 li a7, SYS_exit
    127a:	4889                	li	a7,2
 ecall
    127c:	00000073          	ecall
 ret
    1280:	8082                	ret

0000000000001282 <wait>:
.global wait
wait:
 li a7, SYS_wait
    1282:	488d                	li	a7,3
 ecall
    1284:	00000073          	ecall
 ret
    1288:	8082                	ret

000000000000128a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    128a:	4891                	li	a7,4
 ecall
    128c:	00000073          	ecall
 ret
    1290:	8082                	ret

0000000000001292 <read>:
.global read
read:
 li a7, SYS_read
    1292:	4895                	li	a7,5
 ecall
    1294:	00000073          	ecall
 ret
    1298:	8082                	ret

000000000000129a <write>:
.global write
write:
 li a7, SYS_write
    129a:	48c1                	li	a7,16
 ecall
    129c:	00000073          	ecall
 ret
    12a0:	8082                	ret

00000000000012a2 <close>:
.global close
close:
 li a7, SYS_close
    12a2:	48d5                	li	a7,21
 ecall
    12a4:	00000073          	ecall
 ret
    12a8:	8082                	ret

00000000000012aa <kill>:
.global kill
kill:
 li a7, SYS_kill
    12aa:	4899                	li	a7,6
 ecall
    12ac:	00000073          	ecall
 ret
    12b0:	8082                	ret

00000000000012b2 <exec>:
.global exec
exec:
 li a7, SYS_exec
    12b2:	489d                	li	a7,7
 ecall
    12b4:	00000073          	ecall
 ret
    12b8:	8082                	ret

00000000000012ba <open>:
.global open
open:
 li a7, SYS_open
    12ba:	48bd                	li	a7,15
 ecall
    12bc:	00000073          	ecall
 ret
    12c0:	8082                	ret

00000000000012c2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    12c2:	48c5                	li	a7,17
 ecall
    12c4:	00000073          	ecall
 ret
    12c8:	8082                	ret

00000000000012ca <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    12ca:	48c9                	li	a7,18
 ecall
    12cc:	00000073          	ecall
 ret
    12d0:	8082                	ret

00000000000012d2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    12d2:	48a1                	li	a7,8
 ecall
    12d4:	00000073          	ecall
 ret
    12d8:	8082                	ret

00000000000012da <link>:
.global link
link:
 li a7, SYS_link
    12da:	48cd                	li	a7,19
 ecall
    12dc:	00000073          	ecall
 ret
    12e0:	8082                	ret

00000000000012e2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    12e2:	48d1                	li	a7,20
 ecall
    12e4:	00000073          	ecall
 ret
    12e8:	8082                	ret

00000000000012ea <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    12ea:	48a5                	li	a7,9
 ecall
    12ec:	00000073          	ecall
 ret
    12f0:	8082                	ret

00000000000012f2 <dup>:
.global dup
dup:
 li a7, SYS_dup
    12f2:	48a9                	li	a7,10
 ecall
    12f4:	00000073          	ecall
 ret
    12f8:	8082                	ret

00000000000012fa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    12fa:	48ad                	li	a7,11
 ecall
    12fc:	00000073          	ecall
 ret
    1300:	8082                	ret

0000000000001302 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    1302:	48b1                	li	a7,12
 ecall
    1304:	00000073          	ecall
 ret
    1308:	8082                	ret

000000000000130a <pause>:
.global pause
pause:
 li a7, SYS_pause
    130a:	48b5                	li	a7,13
 ecall
    130c:	00000073          	ecall
 ret
    1310:	8082                	ret

0000000000001312 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    1312:	48b9                	li	a7,14
 ecall
    1314:	00000073          	ecall
 ret
    1318:	8082                	ret

000000000000131a <csread>:
.global csread
csread:
 li a7, SYS_csread
    131a:	48d9                	li	a7,22
 ecall
    131c:	00000073          	ecall
 ret
    1320:	8082                	ret

0000000000001322 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
    1322:	48dd                	li	a7,23
 ecall
    1324:	00000073          	ecall
 ret
    1328:	8082                	ret

000000000000132a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    132a:	1101                	addi	sp,sp,-32
    132c:	ec06                	sd	ra,24(sp)
    132e:	e822                	sd	s0,16(sp)
    1330:	1000                	addi	s0,sp,32
    1332:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    1336:	4605                	li	a2,1
    1338:	fef40593          	addi	a1,s0,-17
    133c:	f5fff0ef          	jal	129a <write>
}
    1340:	60e2                	ld	ra,24(sp)
    1342:	6442                	ld	s0,16(sp)
    1344:	6105                	addi	sp,sp,32
    1346:	8082                	ret

0000000000001348 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    1348:	715d                	addi	sp,sp,-80
    134a:	e486                	sd	ra,72(sp)
    134c:	e0a2                	sd	s0,64(sp)
    134e:	f84a                	sd	s2,48(sp)
    1350:	0880                	addi	s0,sp,80
    1352:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    1354:	c299                	beqz	a3,135a <printint+0x12>
    1356:	0805c363          	bltz	a1,13dc <printint+0x94>
  neg = 0;
    135a:	4881                	li	a7,0
    135c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    1360:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    1362:	00001517          	auipc	a0,0x1
    1366:	87650513          	addi	a0,a0,-1930 # 1bd8 <digits>
    136a:	883e                	mv	a6,a5
    136c:	2785                	addiw	a5,a5,1
    136e:	02c5f733          	remu	a4,a1,a2
    1372:	972a                	add	a4,a4,a0
    1374:	00074703          	lbu	a4,0(a4)
    1378:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    137c:	872e                	mv	a4,a1
    137e:	02c5d5b3          	divu	a1,a1,a2
    1382:	0685                	addi	a3,a3,1
    1384:	fec773e3          	bgeu	a4,a2,136a <printint+0x22>
  if(neg)
    1388:	00088b63          	beqz	a7,139e <printint+0x56>
    buf[i++] = '-';
    138c:	fd078793          	addi	a5,a5,-48
    1390:	97a2                	add	a5,a5,s0
    1392:	02d00713          	li	a4,45
    1396:	fee78423          	sb	a4,-24(a5)
    139a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    139e:	02f05a63          	blez	a5,13d2 <printint+0x8a>
    13a2:	fc26                	sd	s1,56(sp)
    13a4:	f44e                	sd	s3,40(sp)
    13a6:	fb840713          	addi	a4,s0,-72
    13aa:	00f704b3          	add	s1,a4,a5
    13ae:	fff70993          	addi	s3,a4,-1
    13b2:	99be                	add	s3,s3,a5
    13b4:	37fd                	addiw	a5,a5,-1
    13b6:	1782                	slli	a5,a5,0x20
    13b8:	9381                	srli	a5,a5,0x20
    13ba:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    13be:	fff4c583          	lbu	a1,-1(s1)
    13c2:	854a                	mv	a0,s2
    13c4:	f67ff0ef          	jal	132a <putc>
  while(--i >= 0)
    13c8:	14fd                	addi	s1,s1,-1
    13ca:	ff349ae3          	bne	s1,s3,13be <printint+0x76>
    13ce:	74e2                	ld	s1,56(sp)
    13d0:	79a2                	ld	s3,40(sp)
}
    13d2:	60a6                	ld	ra,72(sp)
    13d4:	6406                	ld	s0,64(sp)
    13d6:	7942                	ld	s2,48(sp)
    13d8:	6161                	addi	sp,sp,80
    13da:	8082                	ret
    x = -xx;
    13dc:	40b005b3          	neg	a1,a1
    neg = 1;
    13e0:	4885                	li	a7,1
    x = -xx;
    13e2:	bfad                	j	135c <printint+0x14>

00000000000013e4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    13e4:	711d                	addi	sp,sp,-96
    13e6:	ec86                	sd	ra,88(sp)
    13e8:	e8a2                	sd	s0,80(sp)
    13ea:	e0ca                	sd	s2,64(sp)
    13ec:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    13ee:	0005c903          	lbu	s2,0(a1)
    13f2:	28090663          	beqz	s2,167e <vprintf+0x29a>
    13f6:	e4a6                	sd	s1,72(sp)
    13f8:	fc4e                	sd	s3,56(sp)
    13fa:	f852                	sd	s4,48(sp)
    13fc:	f456                	sd	s5,40(sp)
    13fe:	f05a                	sd	s6,32(sp)
    1400:	ec5e                	sd	s7,24(sp)
    1402:	e862                	sd	s8,16(sp)
    1404:	e466                	sd	s9,8(sp)
    1406:	8b2a                	mv	s6,a0
    1408:	8a2e                	mv	s4,a1
    140a:	8bb2                	mv	s7,a2
  state = 0;
    140c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    140e:	4481                	li	s1,0
    1410:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    1412:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    1416:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    141a:	06c00c93          	li	s9,108
    141e:	a005                	j	143e <vprintf+0x5a>
        putc(fd, c0);
    1420:	85ca                	mv	a1,s2
    1422:	855a                	mv	a0,s6
    1424:	f07ff0ef          	jal	132a <putc>
    1428:	a019                	j	142e <vprintf+0x4a>
    } else if(state == '%'){
    142a:	03598263          	beq	s3,s5,144e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
    142e:	2485                	addiw	s1,s1,1
    1430:	8726                	mv	a4,s1
    1432:	009a07b3          	add	a5,s4,s1
    1436:	0007c903          	lbu	s2,0(a5)
    143a:	22090a63          	beqz	s2,166e <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
    143e:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1442:	fe0994e3          	bnez	s3,142a <vprintf+0x46>
      if(c0 == '%'){
    1446:	fd579de3          	bne	a5,s5,1420 <vprintf+0x3c>
        state = '%';
    144a:	89be                	mv	s3,a5
    144c:	b7cd                	j	142e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    144e:	00ea06b3          	add	a3,s4,a4
    1452:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    1456:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    1458:	c681                	beqz	a3,1460 <vprintf+0x7c>
    145a:	9752                	add	a4,a4,s4
    145c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    1460:	05878363          	beq	a5,s8,14a6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
    1464:	05978d63          	beq	a5,s9,14be <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    1468:	07500713          	li	a4,117
    146c:	0ee78763          	beq	a5,a4,155a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    1470:	07800713          	li	a4,120
    1474:	12e78963          	beq	a5,a4,15a6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    1478:	07000713          	li	a4,112
    147c:	14e78e63          	beq	a5,a4,15d8 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
    1480:	06300713          	li	a4,99
    1484:	18e78e63          	beq	a5,a4,1620 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
    1488:	07300713          	li	a4,115
    148c:	1ae78463          	beq	a5,a4,1634 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    1490:	02500713          	li	a4,37
    1494:	04e79563          	bne	a5,a4,14de <vprintf+0xfa>
        putc(fd, '%');
    1498:	02500593          	li	a1,37
    149c:	855a                	mv	a0,s6
    149e:	e8dff0ef          	jal	132a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    14a2:	4981                	li	s3,0
    14a4:	b769                	j	142e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    14a6:	008b8913          	addi	s2,s7,8
    14aa:	4685                	li	a3,1
    14ac:	4629                	li	a2,10
    14ae:	000ba583          	lw	a1,0(s7)
    14b2:	855a                	mv	a0,s6
    14b4:	e95ff0ef          	jal	1348 <printint>
    14b8:	8bca                	mv	s7,s2
      state = 0;
    14ba:	4981                	li	s3,0
    14bc:	bf8d                	j	142e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    14be:	06400793          	li	a5,100
    14c2:	02f68963          	beq	a3,a5,14f4 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    14c6:	06c00793          	li	a5,108
    14ca:	04f68263          	beq	a3,a5,150e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
    14ce:	07500793          	li	a5,117
    14d2:	0af68063          	beq	a3,a5,1572 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
    14d6:	07800793          	li	a5,120
    14da:	0ef68263          	beq	a3,a5,15be <vprintf+0x1da>
        putc(fd, '%');
    14de:	02500593          	li	a1,37
    14e2:	855a                	mv	a0,s6
    14e4:	e47ff0ef          	jal	132a <putc>
        putc(fd, c0);
    14e8:	85ca                	mv	a1,s2
    14ea:	855a                	mv	a0,s6
    14ec:	e3fff0ef          	jal	132a <putc>
      state = 0;
    14f0:	4981                	li	s3,0
    14f2:	bf35                	j	142e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    14f4:	008b8913          	addi	s2,s7,8
    14f8:	4685                	li	a3,1
    14fa:	4629                	li	a2,10
    14fc:	000bb583          	ld	a1,0(s7)
    1500:	855a                	mv	a0,s6
    1502:	e47ff0ef          	jal	1348 <printint>
        i += 1;
    1506:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    1508:	8bca                	mv	s7,s2
      state = 0;
    150a:	4981                	li	s3,0
        i += 1;
    150c:	b70d                	j	142e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    150e:	06400793          	li	a5,100
    1512:	02f60763          	beq	a2,a5,1540 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    1516:	07500793          	li	a5,117
    151a:	06f60963          	beq	a2,a5,158c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    151e:	07800793          	li	a5,120
    1522:	faf61ee3          	bne	a2,a5,14de <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    1526:	008b8913          	addi	s2,s7,8
    152a:	4681                	li	a3,0
    152c:	4641                	li	a2,16
    152e:	000bb583          	ld	a1,0(s7)
    1532:	855a                	mv	a0,s6
    1534:	e15ff0ef          	jal	1348 <printint>
        i += 2;
    1538:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    153a:	8bca                	mv	s7,s2
      state = 0;
    153c:	4981                	li	s3,0
        i += 2;
    153e:	bdc5                	j	142e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1540:	008b8913          	addi	s2,s7,8
    1544:	4685                	li	a3,1
    1546:	4629                	li	a2,10
    1548:	000bb583          	ld	a1,0(s7)
    154c:	855a                	mv	a0,s6
    154e:	dfbff0ef          	jal	1348 <printint>
        i += 2;
    1552:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    1554:	8bca                	mv	s7,s2
      state = 0;
    1556:	4981                	li	s3,0
        i += 2;
    1558:	bdd9                	j	142e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    155a:	008b8913          	addi	s2,s7,8
    155e:	4681                	li	a3,0
    1560:	4629                	li	a2,10
    1562:	000be583          	lwu	a1,0(s7)
    1566:	855a                	mv	a0,s6
    1568:	de1ff0ef          	jal	1348 <printint>
    156c:	8bca                	mv	s7,s2
      state = 0;
    156e:	4981                	li	s3,0
    1570:	bd7d                	j	142e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1572:	008b8913          	addi	s2,s7,8
    1576:	4681                	li	a3,0
    1578:	4629                	li	a2,10
    157a:	000bb583          	ld	a1,0(s7)
    157e:	855a                	mv	a0,s6
    1580:	dc9ff0ef          	jal	1348 <printint>
        i += 1;
    1584:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    1586:	8bca                	mv	s7,s2
      state = 0;
    1588:	4981                	li	s3,0
        i += 1;
    158a:	b555                	j	142e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    158c:	008b8913          	addi	s2,s7,8
    1590:	4681                	li	a3,0
    1592:	4629                	li	a2,10
    1594:	000bb583          	ld	a1,0(s7)
    1598:	855a                	mv	a0,s6
    159a:	dafff0ef          	jal	1348 <printint>
        i += 2;
    159e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    15a0:	8bca                	mv	s7,s2
      state = 0;
    15a2:	4981                	li	s3,0
        i += 2;
    15a4:	b569                	j	142e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    15a6:	008b8913          	addi	s2,s7,8
    15aa:	4681                	li	a3,0
    15ac:	4641                	li	a2,16
    15ae:	000be583          	lwu	a1,0(s7)
    15b2:	855a                	mv	a0,s6
    15b4:	d95ff0ef          	jal	1348 <printint>
    15b8:	8bca                	mv	s7,s2
      state = 0;
    15ba:	4981                	li	s3,0
    15bc:	bd8d                	j	142e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    15be:	008b8913          	addi	s2,s7,8
    15c2:	4681                	li	a3,0
    15c4:	4641                	li	a2,16
    15c6:	000bb583          	ld	a1,0(s7)
    15ca:	855a                	mv	a0,s6
    15cc:	d7dff0ef          	jal	1348 <printint>
        i += 1;
    15d0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    15d2:	8bca                	mv	s7,s2
      state = 0;
    15d4:	4981                	li	s3,0
        i += 1;
    15d6:	bda1                	j	142e <vprintf+0x4a>
    15d8:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    15da:	008b8d13          	addi	s10,s7,8
    15de:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    15e2:	03000593          	li	a1,48
    15e6:	855a                	mv	a0,s6
    15e8:	d43ff0ef          	jal	132a <putc>
  putc(fd, 'x');
    15ec:	07800593          	li	a1,120
    15f0:	855a                	mv	a0,s6
    15f2:	d39ff0ef          	jal	132a <putc>
    15f6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    15f8:	00000b97          	auipc	s7,0x0
    15fc:	5e0b8b93          	addi	s7,s7,1504 # 1bd8 <digits>
    1600:	03c9d793          	srli	a5,s3,0x3c
    1604:	97de                	add	a5,a5,s7
    1606:	0007c583          	lbu	a1,0(a5)
    160a:	855a                	mv	a0,s6
    160c:	d1fff0ef          	jal	132a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1610:	0992                	slli	s3,s3,0x4
    1612:	397d                	addiw	s2,s2,-1
    1614:	fe0916e3          	bnez	s2,1600 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
    1618:	8bea                	mv	s7,s10
      state = 0;
    161a:	4981                	li	s3,0
    161c:	6d02                	ld	s10,0(sp)
    161e:	bd01                	j	142e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
    1620:	008b8913          	addi	s2,s7,8
    1624:	000bc583          	lbu	a1,0(s7)
    1628:	855a                	mv	a0,s6
    162a:	d01ff0ef          	jal	132a <putc>
    162e:	8bca                	mv	s7,s2
      state = 0;
    1630:	4981                	li	s3,0
    1632:	bbf5                	j	142e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    1634:	008b8993          	addi	s3,s7,8
    1638:	000bb903          	ld	s2,0(s7)
    163c:	00090f63          	beqz	s2,165a <vprintf+0x276>
        for(; *s; s++)
    1640:	00094583          	lbu	a1,0(s2)
    1644:	c195                	beqz	a1,1668 <vprintf+0x284>
          putc(fd, *s);
    1646:	855a                	mv	a0,s6
    1648:	ce3ff0ef          	jal	132a <putc>
        for(; *s; s++)
    164c:	0905                	addi	s2,s2,1
    164e:	00094583          	lbu	a1,0(s2)
    1652:	f9f5                	bnez	a1,1646 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    1654:	8bce                	mv	s7,s3
      state = 0;
    1656:	4981                	li	s3,0
    1658:	bbd9                	j	142e <vprintf+0x4a>
          s = "(null)";
    165a:	00000917          	auipc	s2,0x0
    165e:	53690913          	addi	s2,s2,1334 # 1b90 <malloc+0x42a>
        for(; *s; s++)
    1662:	02800593          	li	a1,40
    1666:	b7c5                	j	1646 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    1668:	8bce                	mv	s7,s3
      state = 0;
    166a:	4981                	li	s3,0
    166c:	b3c9                	j	142e <vprintf+0x4a>
    166e:	64a6                	ld	s1,72(sp)
    1670:	79e2                	ld	s3,56(sp)
    1672:	7a42                	ld	s4,48(sp)
    1674:	7aa2                	ld	s5,40(sp)
    1676:	7b02                	ld	s6,32(sp)
    1678:	6be2                	ld	s7,24(sp)
    167a:	6c42                	ld	s8,16(sp)
    167c:	6ca2                	ld	s9,8(sp)
    }
  }
}
    167e:	60e6                	ld	ra,88(sp)
    1680:	6446                	ld	s0,80(sp)
    1682:	6906                	ld	s2,64(sp)
    1684:	6125                	addi	sp,sp,96
    1686:	8082                	ret

0000000000001688 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1688:	715d                	addi	sp,sp,-80
    168a:	ec06                	sd	ra,24(sp)
    168c:	e822                	sd	s0,16(sp)
    168e:	1000                	addi	s0,sp,32
    1690:	e010                	sd	a2,0(s0)
    1692:	e414                	sd	a3,8(s0)
    1694:	e818                	sd	a4,16(s0)
    1696:	ec1c                	sd	a5,24(s0)
    1698:	03043023          	sd	a6,32(s0)
    169c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    16a0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    16a4:	8622                	mv	a2,s0
    16a6:	d3fff0ef          	jal	13e4 <vprintf>
}
    16aa:	60e2                	ld	ra,24(sp)
    16ac:	6442                	ld	s0,16(sp)
    16ae:	6161                	addi	sp,sp,80
    16b0:	8082                	ret

00000000000016b2 <printf>:

void
printf(const char *fmt, ...)
{
    16b2:	711d                	addi	sp,sp,-96
    16b4:	ec06                	sd	ra,24(sp)
    16b6:	e822                	sd	s0,16(sp)
    16b8:	1000                	addi	s0,sp,32
    16ba:	e40c                	sd	a1,8(s0)
    16bc:	e810                	sd	a2,16(s0)
    16be:	ec14                	sd	a3,24(s0)
    16c0:	f018                	sd	a4,32(s0)
    16c2:	f41c                	sd	a5,40(s0)
    16c4:	03043823          	sd	a6,48(s0)
    16c8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    16cc:	00840613          	addi	a2,s0,8
    16d0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    16d4:	85aa                	mv	a1,a0
    16d6:	4505                	li	a0,1
    16d8:	d0dff0ef          	jal	13e4 <vprintf>
}
    16dc:	60e2                	ld	ra,24(sp)
    16de:	6442                	ld	s0,16(sp)
    16e0:	6125                	addi	sp,sp,96
    16e2:	8082                	ret

00000000000016e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    16e4:	1141                	addi	sp,sp,-16
    16e6:	e422                	sd	s0,8(sp)
    16e8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    16ea:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16ee:	00001797          	auipc	a5,0x1
    16f2:	9127b783          	ld	a5,-1774(a5) # 2000 <freep>
    16f6:	a02d                	j	1720 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    16f8:	4618                	lw	a4,8(a2)
    16fa:	9f2d                	addw	a4,a4,a1
    16fc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1700:	6398                	ld	a4,0(a5)
    1702:	6310                	ld	a2,0(a4)
    1704:	a83d                	j	1742 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1706:	ff852703          	lw	a4,-8(a0)
    170a:	9f31                	addw	a4,a4,a2
    170c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    170e:	ff053683          	ld	a3,-16(a0)
    1712:	a091                	j	1756 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1714:	6398                	ld	a4,0(a5)
    1716:	00e7e463          	bltu	a5,a4,171e <free+0x3a>
    171a:	00e6ea63          	bltu	a3,a4,172e <free+0x4a>
{
    171e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1720:	fed7fae3          	bgeu	a5,a3,1714 <free+0x30>
    1724:	6398                	ld	a4,0(a5)
    1726:	00e6e463          	bltu	a3,a4,172e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    172a:	fee7eae3          	bltu	a5,a4,171e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    172e:	ff852583          	lw	a1,-8(a0)
    1732:	6390                	ld	a2,0(a5)
    1734:	02059813          	slli	a6,a1,0x20
    1738:	01c85713          	srli	a4,a6,0x1c
    173c:	9736                	add	a4,a4,a3
    173e:	fae60de3          	beq	a2,a4,16f8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1742:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1746:	4790                	lw	a2,8(a5)
    1748:	02061593          	slli	a1,a2,0x20
    174c:	01c5d713          	srli	a4,a1,0x1c
    1750:	973e                	add	a4,a4,a5
    1752:	fae68ae3          	beq	a3,a4,1706 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1756:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1758:	00001717          	auipc	a4,0x1
    175c:	8af73423          	sd	a5,-1880(a4) # 2000 <freep>
}
    1760:	6422                	ld	s0,8(sp)
    1762:	0141                	addi	sp,sp,16
    1764:	8082                	ret

0000000000001766 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1766:	7139                	addi	sp,sp,-64
    1768:	fc06                	sd	ra,56(sp)
    176a:	f822                	sd	s0,48(sp)
    176c:	f426                	sd	s1,40(sp)
    176e:	ec4e                	sd	s3,24(sp)
    1770:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1772:	02051493          	slli	s1,a0,0x20
    1776:	9081                	srli	s1,s1,0x20
    1778:	04bd                	addi	s1,s1,15
    177a:	8091                	srli	s1,s1,0x4
    177c:	0014899b          	addiw	s3,s1,1
    1780:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1782:	00001517          	auipc	a0,0x1
    1786:	87e53503          	ld	a0,-1922(a0) # 2000 <freep>
    178a:	c915                	beqz	a0,17be <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    178c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    178e:	4798                	lw	a4,8(a5)
    1790:	08977a63          	bgeu	a4,s1,1824 <malloc+0xbe>
    1794:	f04a                	sd	s2,32(sp)
    1796:	e852                	sd	s4,16(sp)
    1798:	e456                	sd	s5,8(sp)
    179a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    179c:	8a4e                	mv	s4,s3
    179e:	0009871b          	sext.w	a4,s3
    17a2:	6685                	lui	a3,0x1
    17a4:	00d77363          	bgeu	a4,a3,17aa <malloc+0x44>
    17a8:	6a05                	lui	s4,0x1
    17aa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    17ae:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    17b2:	00001917          	auipc	s2,0x1
    17b6:	84e90913          	addi	s2,s2,-1970 # 2000 <freep>
  if(p == SBRK_ERROR)
    17ba:	5afd                	li	s5,-1
    17bc:	a081                	j	17fc <malloc+0x96>
    17be:	f04a                	sd	s2,32(sp)
    17c0:	e852                	sd	s4,16(sp)
    17c2:	e456                	sd	s5,8(sp)
    17c4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    17c6:	00004797          	auipc	a5,0x4
    17ca:	8ca78793          	addi	a5,a5,-1846 # 5090 <base>
    17ce:	00001717          	auipc	a4,0x1
    17d2:	82f73923          	sd	a5,-1998(a4) # 2000 <freep>
    17d6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    17d8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    17dc:	b7c1                	j	179c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    17de:	6398                	ld	a4,0(a5)
    17e0:	e118                	sd	a4,0(a0)
    17e2:	a8a9                	j	183c <malloc+0xd6>
  hp->s.size = nu;
    17e4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    17e8:	0541                	addi	a0,a0,16
    17ea:	efbff0ef          	jal	16e4 <free>
  return freep;
    17ee:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    17f2:	c12d                	beqz	a0,1854 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    17f6:	4798                	lw	a4,8(a5)
    17f8:	02977263          	bgeu	a4,s1,181c <malloc+0xb6>
    if(p == freep)
    17fc:	00093703          	ld	a4,0(s2)
    1800:	853e                	mv	a0,a5
    1802:	fef719e3          	bne	a4,a5,17f4 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    1806:	8552                	mv	a0,s4
    1808:	a3fff0ef          	jal	1246 <sbrk>
  if(p == SBRK_ERROR)
    180c:	fd551ce3          	bne	a0,s5,17e4 <malloc+0x7e>
        return 0;
    1810:	4501                	li	a0,0
    1812:	7902                	ld	s2,32(sp)
    1814:	6a42                	ld	s4,16(sp)
    1816:	6aa2                	ld	s5,8(sp)
    1818:	6b02                	ld	s6,0(sp)
    181a:	a03d                	j	1848 <malloc+0xe2>
    181c:	7902                	ld	s2,32(sp)
    181e:	6a42                	ld	s4,16(sp)
    1820:	6aa2                	ld	s5,8(sp)
    1822:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1824:	fae48de3          	beq	s1,a4,17de <malloc+0x78>
        p->s.size -= nunits;
    1828:	4137073b          	subw	a4,a4,s3
    182c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    182e:	02071693          	slli	a3,a4,0x20
    1832:	01c6d713          	srli	a4,a3,0x1c
    1836:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1838:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    183c:	00000717          	auipc	a4,0x0
    1840:	7ca73223          	sd	a0,1988(a4) # 2000 <freep>
      return (void*)(p + 1);
    1844:	01078513          	addi	a0,a5,16
  }
}
    1848:	70e2                	ld	ra,56(sp)
    184a:	7442                	ld	s0,48(sp)
    184c:	74a2                	ld	s1,40(sp)
    184e:	69e2                	ld	s3,24(sp)
    1850:	6121                	addi	sp,sp,64
    1852:	8082                	ret
    1854:	7902                	ld	s2,32(sp)
    1856:	6a42                	ld	s4,16(sp)
    1858:	6aa2                	ld	s5,8(sp)
    185a:	6b02                	ld	s6,0(sp)
    185c:	b7f5                	j	1848 <malloc+0xe2>
