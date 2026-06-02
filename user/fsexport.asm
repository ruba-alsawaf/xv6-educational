
user/_fsexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <append_str>:

static void append_char(char *buf, int *pos, char c) {
    if (*pos < OUTBUF_SZ - 1) buf[(*pos)++] = c;
}

static void append_str(char *buf, int *pos, const char *s) {
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
    while (*s && *pos < OUTBUF_SZ - 1) buf[(*pos)++] = *s++;
       8:	00064783          	lbu	a5,0(a2)
       c:	3fe00693          	li	a3,1022
      10:	c385                	beqz	a5,30 <append_str+0x30>
      12:	419c                	lw	a5,0(a1)
      14:	00f6ce63          	blt	a3,a5,30 <append_str+0x30>
      18:	0605                	addi	a2,a2,1
      1a:	0017871b          	addiw	a4,a5,1
      1e:	c198                	sw	a4,0(a1)
      20:	fff64703          	lbu	a4,-1(a2)
      24:	97aa                	add	a5,a5,a0
      26:	00e78023          	sb	a4,0(a5)
      2a:	00064783          	lbu	a5,0(a2)
      2e:	f3f5                	bnez	a5,12 <append_str+0x12>
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret

0000000000000038 <append_uint>:

static void append_uint(char *buf, int *pos, uint x) {
    char tmp[16]; int n = 0;
    if (x == 0) { buf[(*pos)++] = '0'; return; }
      38:	c649                	beqz	a2,c2 <append_uint+0x8a>
static void append_uint(char *buf, int *pos, uint x) {
      3a:	1101                	addi	sp,sp,-32
      3c:	ec06                	sd	ra,24(sp)
      3e:	e822                	sd	s0,16(sp)
      40:	1000                	addi	s0,sp,32
      42:	fe040813          	addi	a6,s0,-32
      46:	86c2                	mv	a3,a6
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
      48:	000cd337          	lui	t1,0xcd
      4c:	ccd30313          	addi	t1,t1,-819 # ccccd <base+0xc8cbd>
      50:	0332                	slli	t1,t1,0xc
      52:	ccd30313          	addi	t1,t1,-819
      56:	4e25                	li	t3,9
      58:	02061713          	slli	a4,a2,0x20
      5c:	9301                	srli	a4,a4,0x20
      5e:	02670733          	mul	a4,a4,t1
      62:	930d                	srli	a4,a4,0x23
      64:	0027179b          	slliw	a5,a4,0x2
      68:	9fb9                	addw	a5,a5,a4
      6a:	0017979b          	slliw	a5,a5,0x1
      6e:	40f607bb          	subw	a5,a2,a5
      72:	0307879b          	addiw	a5,a5,48
      76:	00f68023          	sb	a5,0(a3)
      7a:	88b2                	mv	a7,a2
      7c:	863a                	mv	a2,a4
      7e:	87b6                	mv	a5,a3
      80:	0685                	addi	a3,a3,1
      82:	fd1e6be3          	bltu	t3,a7,58 <append_uint+0x20>
      86:	410787bb          	subw	a5,a5,a6
      8a:	2785                	addiw	a5,a5,1
    while (n > 0) buf[(*pos)++] = tmp[--n];
      8c:	02f05763          	blez	a5,ba <append_uint+0x82>
      90:	37fd                	addiw	a5,a5,-1
      92:	00f80733          	add	a4,a6,a5
      96:	fff80693          	addi	a3,a6,-1
      9a:	96be                	add	a3,a3,a5
      9c:	1782                	slli	a5,a5,0x20
      9e:	9381                	srli	a5,a5,0x20
      a0:	8e9d                	sub	a3,a3,a5
      a2:	419c                	lw	a5,0(a1)
      a4:	0017861b          	addiw	a2,a5,1
      a8:	c190                	sw	a2,0(a1)
      aa:	97aa                	add	a5,a5,a0
      ac:	00074603          	lbu	a2,0(a4)
      b0:	00c78023          	sb	a2,0(a5)
      b4:	177d                	addi	a4,a4,-1
      b6:	fed716e3          	bne	a4,a3,a2 <append_uint+0x6a>
}
      ba:	60e2                	ld	ra,24(sp)
      bc:	6442                	ld	s0,16(sp)
      be:	6105                	addi	sp,sp,32
      c0:	8082                	ret
    if (x == 0) { buf[(*pos)++] = '0'; return; }
      c2:	419c                	lw	a5,0(a1)
      c4:	0017871b          	addiw	a4,a5,1
      c8:	c198                	sw	a4,0(a1)
      ca:	97aa                	add	a5,a5,a0
      cc:	03000713          	li	a4,48
      d0:	00e78023          	sb	a4,0(a5)
      d4:	8082                	ret

00000000000000d6 <append_int>:

static void append_int(char *buf, int *pos, int x) {
      d6:	1141                	addi	sp,sp,-16
      d8:	e406                	sd	ra,8(sp)
      da:	e022                	sd	s0,0(sp)
      dc:	0800                	addi	s0,sp,16
    if (x < 0) { append_char(buf, pos, '-'); x = -x; }
      de:	00064863          	bltz	a2,ee <append_int+0x18>
    append_uint(buf, pos, (uint)x);
      e2:	f57ff0ef          	jal	38 <append_uint>
}
      e6:	60a2                	ld	ra,8(sp)
      e8:	6402                	ld	s0,0(sp)
      ea:	0141                	addi	sp,sp,16
      ec:	8082                	ret
    if (*pos < OUTBUF_SZ - 1) buf[(*pos)++] = c;
      ee:	419c                	lw	a5,0(a1)
      f0:	3fe00713          	li	a4,1022
      f4:	00f74a63          	blt	a4,a5,108 <append_int+0x32>
      f8:	0017871b          	addiw	a4,a5,1
      fc:	c198                	sw	a4,0(a1)
      fe:	97aa                	add	a5,a5,a0
     100:	02d00713          	li	a4,45
     104:	00e78023          	sb	a4,0(a5)
    if (x < 0) { append_char(buf, pos, '-'); x = -x; }
     108:	40c0063b          	negw	a2,a2
     10c:	bfd9                	j	e2 <append_int+0xc>

000000000000010e <print_change>:

static void print_change(char *buf, int *pos, const char *name, int oldv, int newv) {
    if(oldv != newv){
     10e:	00e69363          	bne	a3,a4,114 <print_change+0x6>
     112:	8082                	ret
static void print_change(char *buf, int *pos, const char *name, int oldv, int newv) {
     114:	7139                	addi	sp,sp,-64
     116:	fc06                	sd	ra,56(sp)
     118:	f822                	sd	s0,48(sp)
     11a:	f426                	sd	s1,40(sp)
     11c:	f04a                	sd	s2,32(sp)
     11e:	ec4e                	sd	s3,24(sp)
     120:	e852                	sd	s4,16(sp)
     122:	e456                	sd	s5,8(sp)
     124:	0080                	addi	s0,sp,64
     126:	84aa                	mv	s1,a0
     128:	892e                	mv	s2,a1
     12a:	8ab2                	mv	s5,a2
     12c:	89b6                	mv	s3,a3
     12e:	8a3a                	mv	s4,a4
        append_str(buf, pos, "\"");
     130:	00001617          	auipc	a2,0x1
     134:	51060613          	addi	a2,a2,1296 # 1640 <malloc+0xfc>
     138:	ec9ff0ef          	jal	0 <append_str>
        append_str(buf, pos, name);
     13c:	8656                	mv	a2,s5
     13e:	85ca                	mv	a1,s2
     140:	8526                	mv	a0,s1
     142:	ebfff0ef          	jal	0 <append_str>
        append_str(buf, pos, "\":\"");
     146:	00001617          	auipc	a2,0x1
     14a:	50260613          	addi	a2,a2,1282 # 1648 <malloc+0x104>
     14e:	85ca                	mv	a1,s2
     150:	8526                	mv	a0,s1
     152:	eafff0ef          	jal	0 <append_str>
        append_int(buf, pos, oldv);
     156:	864e                	mv	a2,s3
     158:	85ca                	mv	a1,s2
     15a:	8526                	mv	a0,s1
     15c:	f7bff0ef          	jal	d6 <append_int>
        append_str(buf, pos, "->");
     160:	00001617          	auipc	a2,0x1
     164:	4f060613          	addi	a2,a2,1264 # 1650 <malloc+0x10c>
     168:	85ca                	mv	a1,s2
     16a:	8526                	mv	a0,s1
     16c:	e95ff0ef          	jal	0 <append_str>
        append_int(buf, pos, newv);
     170:	8652                	mv	a2,s4
     172:	85ca                	mv	a1,s2
     174:	8526                	mv	a0,s1
     176:	f61ff0ef          	jal	d6 <append_int>
        append_str(buf, pos, "\",");
     17a:	00001617          	auipc	a2,0x1
     17e:	4de60613          	addi	a2,a2,1246 # 1658 <malloc+0x114>
     182:	85ca                	mv	a1,s2
     184:	8526                	mv	a0,s1
     186:	e7bff0ef          	jal	0 <append_str>
    }
}
     18a:	70e2                	ld	ra,56(sp)
     18c:	7442                	ld	s0,48(sp)
     18e:	74a2                	ld	s1,40(sp)
     190:	7902                	ld	s2,32(sp)
     192:	69e2                	ld	s3,24(sp)
     194:	6a42                	ld	s4,16(sp)
     196:	6aa2                	ld	s5,8(sp)
     198:	6121                	addi	sp,sp,64
     19a:	8082                	ret

000000000000019c <print_fs_event>:
static void print_fs_event(const struct fs_event *e) {
     19c:	ba010113          	addi	sp,sp,-1120
     1a0:	44113c23          	sd	ra,1112(sp)
     1a4:	44813823          	sd	s0,1104(sp)
     1a8:	44913423          	sd	s1,1096(sp)
     1ac:	45213023          	sd	s2,1088(sp)
     1b0:	43313c23          	sd	s3,1080(sp)
     1b4:	46010413          	addi	s0,sp,1120
     1b8:	84aa                	mv	s1,a0
    char buf[OUTBUF_SZ];
    int pos = 0;
     1ba:	ba042623          	sw	zero,-1108(s0)

    append_str(buf, &pos, "{");
     1be:	bac40993          	addi	s3,s0,-1108
     1c2:	bb040913          	addi	s2,s0,-1104
     1c6:	00001617          	auipc	a2,0x1
     1ca:	49a60613          	addi	a2,a2,1178 # 1660 <malloc+0x11c>
     1ce:	85ce                	mv	a1,s3
     1d0:	854a                	mv	a0,s2
     1d2:	e2fff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"seq\":");
     1d6:	00001617          	auipc	a2,0x1
     1da:	49260613          	addi	a2,a2,1170 # 1668 <malloc+0x124>
     1de:	85ce                	mv	a1,s3
     1e0:	854a                	mv	a0,s2
     1e2:	e1fff0ef          	jal	0 <append_str>
    append_uint(buf, &pos, e->seq);
     1e6:	4090                	lw	a2,0(s1)
     1e8:	85ce                	mv	a1,s3
     1ea:	854a                	mv	a0,s2
     1ec:	e4dff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",");
     1f0:	00001617          	auipc	a2,0x1
     1f4:	48060613          	addi	a2,a2,1152 # 1670 <malloc+0x12c>
     1f8:	85ce                	mv	a1,s3
     1fa:	854a                	mv	a0,s2
     1fc:	e05ff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "\"tick\":"); append_uint(buf, &pos, e->ticks);
     200:	00001617          	auipc	a2,0x1
     204:	47860613          	addi	a2,a2,1144 # 1678 <malloc+0x134>
     208:	85ce                	mv	a1,s3
     20a:	854a                	mv	a0,s2
     20c:	df5ff0ef          	jal	0 <append_str>
     210:	4490                	lw	a2,8(s1)
     212:	85ce                	mv	a1,s3
     214:	854a                	mv	a0,s2
     216:	e23ff0ef          	jal	38 <append_uint>
    append_str(buf, &pos, ",\"pid\":"); append_int(buf, &pos, e->pid);
     21a:	00001617          	auipc	a2,0x1
     21e:	46660613          	addi	a2,a2,1126 # 1680 <malloc+0x13c>
     222:	85ce                	mv	a1,s3
     224:	854a                	mv	a0,s2
     226:	ddbff0ef          	jal	0 <append_str>
     22a:	44d0                	lw	a2,12(s1)
     22c:	85ce                	mv	a1,s3
     22e:	854a                	mv	a0,s2
     230:	ea7ff0ef          	jal	d6 <append_int>

    append_str(buf, &pos, ",\"layer\":\"");
     234:	00001617          	auipc	a2,0x1
     238:	45460613          	addi	a2,a2,1108 # 1688 <malloc+0x144>
     23c:	85ce                	mv	a1,s3
     23e:	854a                	mv	a0,s2
     240:	dc1ff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE)
     244:	0104a903          	lw	s2,16(s1)
     248:	479d                	li	a5,7
     24a:	1d27eee3          	bltu	a5,s2,c26 <print_fs_event+0xa8a>
     24e:	00291793          	slli	a5,s2,0x2
     252:	00001717          	auipc	a4,0x1
     256:	6ce70713          	addi	a4,a4,1742 # 1920 <malloc+0x3dc>
     25a:	97ba                	add	a5,a5,a4
     25c:	439c                	lw	a5,0(a5)
     25e:	97ba                	add	a5,a5,a4
     260:	8782                	jr	a5
     262:	43413823          	sd	s4,1072(sp)
     266:	43513423          	sd	s5,1064(sp)
    append_str(buf, &pos, "BCACHE");
     26a:	bac40993          	addi	s3,s0,-1108
     26e:	bb040913          	addi	s2,s0,-1104
     272:	00001617          	auipc	a2,0x1
     276:	42660613          	addi	a2,a2,1062 # 1698 <malloc+0x154>
     27a:	85ce                	mv	a1,s3
     27c:	854a                	mv	a0,s2
     27e:	d83ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "DIR");
    else if(e->type == LAYER_PATH)
    append_str(buf, &pos, "PATH");
    else if(e->type == LAYER_FILE)
    append_str(buf, &pos, "FILE");
    append_str(buf, &pos, "\"");
     282:	00001617          	auipc	a2,0x1
     286:	3be60613          	addi	a2,a2,958 # 1640 <malloc+0xfc>
     28a:	85ce                	mv	a1,s3
     28c:	854a                	mv	a0,s2
     28e:	d73ff0ef          	jal	0 <append_str>

    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     292:	00001617          	auipc	a2,0x1
     296:	40e60613          	addi	a2,a2,1038 # 16a0 <malloc+0x15c>
     29a:	85ce                	mv	a1,s3
     29c:	854a                	mv	a0,s2
     29e:	d63ff0ef          	jal	0 <append_str>
     2a2:	01448613          	addi	a2,s1,20
     2a6:	85ce                	mv	a1,s3
     2a8:	854a                	mv	a0,s2
     2aa:	d57ff0ef          	jal	0 <append_str>
     2ae:	00001617          	auipc	a2,0x1
     2b2:	39260613          	addi	a2,a2,914 # 1640 <malloc+0xfc>
     2b6:	85ce                	mv	a1,s3
     2b8:	854a                	mv	a0,s2
     2ba:	d47ff0ef          	jal	0 <append_str>

    // ===== BCACHE =====
    if(e->type == LAYER_BCACHE){

        append_str(buf, &pos, ",\"buf\":{");
     2be:	bac40993          	addi	s3,s0,-1108
     2c2:	bb040913          	addi	s2,s0,-1104
     2c6:	00001617          	auipc	a2,0x1
     2ca:	41260613          	addi	a2,a2,1042 # 16d8 <malloc+0x194>
     2ce:	85ce                	mv	a1,s3
     2d0:	854a                	mv	a0,s2
     2d2:	d2fff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"id\":"); append_int(buf, &pos, e->bcache.buf_id);
     2d6:	00001617          	auipc	a2,0x1
     2da:	41260613          	addi	a2,a2,1042 # 16e8 <malloc+0x1a4>
     2de:	85ce                	mv	a1,s3
     2e0:	854a                	mv	a0,s2
     2e2:	d1fff0ef          	jal	0 <append_str>
     2e6:	1604a603          	lw	a2,352(s1)
     2ea:	85ce                	mv	a1,s3
     2ec:	854a                	mv	a0,s2
     2ee:	de9ff0ef          	jal	d6 <append_int>
        append_str(buf, &pos, ",\"block\":"); append_int(buf, &pos, e->bcache.blockno);
     2f2:	00001617          	auipc	a2,0x1
     2f6:	3fe60613          	addi	a2,a2,1022 # 16f0 <malloc+0x1ac>
     2fa:	85ce                	mv	a1,s3
     2fc:	854a                	mv	a0,s2
     2fe:	d03ff0ef          	jal	0 <append_str>
     302:	1644a603          	lw	a2,356(s1)
     306:	85ce                	mv	a1,s3
     308:	854a                	mv	a0,s2
     30a:	dcdff0ef          	jal	d6 <append_int>
        append_str(buf, &pos, "}");
     30e:	00001617          	auipc	a2,0x1
     312:	3f260613          	addi	a2,a2,1010 # 1700 <malloc+0x1bc>
     316:	85ce                	mv	a1,s3
     318:	854a                	mv	a0,s2
     31a:	ce7ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"state\":{" );
     31e:	00001617          	auipc	a2,0x1
     322:	3ea60613          	addi	a2,a2,1002 # 1708 <malloc+0x1c4>
     326:	85ce                	mv	a1,s3
     328:	854a                	mv	a0,s2
     32a:	cd7ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->bcache.refcnt);
     32e:	00001617          	auipc	a2,0x1
     332:	3ea60613          	addi	a2,a2,1002 # 1718 <malloc+0x1d4>
     336:	85ce                	mv	a1,s3
     338:	854a                	mv	a0,s2
     33a:	cc7ff0ef          	jal	0 <append_str>
     33e:	1684aa03          	lw	s4,360(s1)
     342:	8652                	mv	a2,s4
     344:	85ce                	mv	a1,s3
     346:	854a                	mv	a0,s2
     348:	d8fff0ef          	jal	d6 <append_int>
        append_str(buf, &pos, ",\"valid\":"); append_int(buf, &pos, e->bcache.valid);
     34c:	00001617          	auipc	a2,0x1
     350:	3d460613          	addi	a2,a2,980 # 1720 <malloc+0x1dc>
     354:	85ce                	mv	a1,s3
     356:	854a                	mv	a0,s2
     358:	ca9ff0ef          	jal	0 <append_str>
     35c:	1704a783          	lw	a5,368(s1)
     360:	8abe                	mv	s5,a5
     362:	863e                	mv	a2,a5
     364:	85ce                	mv	a1,s3
     366:	854a                	mv	a0,s2
     368:	d6fff0ef          	jal	d6 <append_int>
        append_str(buf, &pos, "}");
     36c:	00001617          	auipc	a2,0x1
     370:	39460613          	addi	a2,a2,916 # 1700 <malloc+0x1bc>
     374:	85ce                	mv	a1,s3
     376:	854a                	mv	a0,s2
     378:	c89ff0ef          	jal	0 <append_str>

        append_str(buf, &pos, ",\"changes\":{" );
     37c:	00001617          	auipc	a2,0x1
     380:	3b460613          	addi	a2,a2,948 # 1730 <malloc+0x1ec>
     384:	85ce                	mv	a1,s3
     386:	854a                	mv	a0,s2
     388:	c79ff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "ref", e->bcache.old_refcnt, e->bcache.refcnt);
     38c:	8752                	mv	a4,s4
     38e:	16c4a683          	lw	a3,364(s1)
     392:	00001617          	auipc	a2,0x1
     396:	3ae60613          	addi	a2,a2,942 # 1740 <malloc+0x1fc>
     39a:	85ce                	mv	a1,s3
     39c:	854a                	mv	a0,s2
     39e:	d71ff0ef          	jal	10e <print_change>
        print_change(buf, &pos, "valid", e->bcache.old_valid, e->bcache.valid);
     3a2:	8756                	mv	a4,s5
     3a4:	1744a683          	lw	a3,372(s1)
     3a8:	00001617          	auipc	a2,0x1
     3ac:	3a060613          	addi	a2,a2,928 # 1748 <malloc+0x204>
     3b0:	85ce                	mv	a1,s3
     3b2:	854a                	mv	a0,s2
     3b4:	d5bff0ef          	jal	10e <print_change>

        if(buf[pos-1] == ',') pos--; // remove last comma
     3b8:	bac42783          	lw	a5,-1108(s0)
     3bc:	37fd                	addiw	a5,a5,-1
     3be:	fd078713          	addi	a4,a5,-48
     3c2:	fe040693          	addi	a3,s0,-32
     3c6:	9736                	add	a4,a4,a3
     3c8:	c0074683          	lbu	a3,-1024(a4)
     3cc:	02c00713          	li	a4,44
     3d0:	0ce682e3          	beq	a3,a4,c94 <print_fs_event+0xaf8>
        append_str(buf, &pos, "}");
     3d4:	00001617          	auipc	a2,0x1
     3d8:	32c60613          	addi	a2,a2,812 # 1700 <malloc+0x1bc>
     3dc:	bac40593          	addi	a1,s0,-1108
     3e0:	bb040513          	addi	a0,s0,-1104
     3e4:	c1dff0ef          	jal	0 <append_str>
     3e8:	43013a03          	ld	s4,1072(sp)
     3ec:	42813a83          	ld	s5,1064(sp)
    if(buf[pos-1] == ',')
        pos--;

    append_str(buf, &pos, "}");
}
    append_str(buf, &pos, ",\"desc\":\"");
     3f0:	bac40993          	addi	s3,s0,-1108
     3f4:	bb040913          	addi	s2,s0,-1104
     3f8:	00001617          	auipc	a2,0x1
     3fc:	4c060613          	addi	a2,a2,1216 # 18b8 <malloc+0x374>
     400:	85ce                	mv	a1,s3
     402:	854a                	mv	a0,s2
     404:	bfdff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->details);
     408:	02448613          	addi	a2,s1,36
     40c:	85ce                	mv	a1,s3
     40e:	854a                	mv	a0,s2
     410:	bf1ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     414:	00001617          	auipc	a2,0x1
     418:	22c60613          	addi	a2,a2,556 # 1640 <malloc+0xfc>
     41c:	85ce                	mv	a1,s3
     41e:	854a                	mv	a0,s2
     420:	be1ff0ef          	jal	0 <append_str>

    append_str(buf, &pos, "}\n");
     424:	00001617          	auipc	a2,0x1
     428:	4a460613          	addi	a2,a2,1188 # 18c8 <malloc+0x384>
     42c:	85ce                	mv	a1,s3
     42e:	854a                	mv	a0,s2
     430:	bd1ff0ef          	jal	0 <append_str>

    write(1, buf, pos);
     434:	bac42603          	lw	a2,-1108(s0)
     438:	85ca                	mv	a1,s2
     43a:	4505                	li	a0,1
     43c:	3fb000ef          	jal	1036 <write>
}
     440:	45813083          	ld	ra,1112(sp)
     444:	45013403          	ld	s0,1104(sp)
     448:	44813483          	ld	s1,1096(sp)
     44c:	44013903          	ld	s2,1088(sp)
     450:	43813983          	ld	s3,1080(sp)
     454:	46010113          	addi	sp,sp,1120
     458:	8082                	ret
     45a:	43413823          	sd	s4,1072(sp)
     45e:	43513423          	sd	s5,1064(sp)
     462:	43613023          	sd	s6,1056(sp)
    append_str(buf, &pos, "LOG");
     466:	bac40993          	addi	s3,s0,-1108
     46a:	bb040913          	addi	s2,s0,-1104
     46e:	00001617          	auipc	a2,0x1
     472:	23a60613          	addi	a2,a2,570 # 16a8 <malloc+0x164>
     476:	85ce                	mv	a1,s3
     478:	854a                	mv	a0,s2
     47a:	b87ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     47e:	00001617          	auipc	a2,0x1
     482:	1c260613          	addi	a2,a2,450 # 1640 <malloc+0xfc>
     486:	85ce                	mv	a1,s3
     488:	854a                	mv	a0,s2
     48a:	b77ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     48e:	00001617          	auipc	a2,0x1
     492:	21260613          	addi	a2,a2,530 # 16a0 <malloc+0x15c>
     496:	85ce                	mv	a1,s3
     498:	854a                	mv	a0,s2
     49a:	b67ff0ef          	jal	0 <append_str>
     49e:	01448613          	addi	a2,s1,20
     4a2:	85ce                	mv	a1,s3
     4a4:	854a                	mv	a0,s2
     4a6:	b5bff0ef          	jal	0 <append_str>
     4aa:	00001617          	auipc	a2,0x1
     4ae:	19660613          	addi	a2,a2,406 # 1640 <malloc+0xfc>
     4b2:	85ce                	mv	a1,s3
     4b4:	854a                	mv	a0,s2
     4b6:	b4bff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"state\":{");
     4ba:	bac40993          	addi	s3,s0,-1108
     4be:	bb040913          	addi	s2,s0,-1104
     4c2:	00001617          	auipc	a2,0x1
     4c6:	24660613          	addi	a2,a2,582 # 1708 <malloc+0x1c4>
     4ca:	85ce                	mv	a1,s3
     4cc:	854a                	mv	a0,s2
     4ce:	b33ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, "\"log_n\":"); append_int(buf, &pos, e->log_n);
     4d2:	00001617          	auipc	a2,0x1
     4d6:	27e60613          	addi	a2,a2,638 # 1750 <malloc+0x20c>
     4da:	85ce                	mv	a1,s3
     4dc:	854a                	mv	a0,s2
     4de:	b23ff0ef          	jal	0 <append_str>
     4e2:	1204aa03          	lw	s4,288(s1)
     4e6:	8652                	mv	a2,s4
     4e8:	85ce                	mv	a1,s3
     4ea:	854a                	mv	a0,s2
     4ec:	bebff0ef          	jal	d6 <append_int>
        append_str(buf, &pos, ",\"outstanding\":"); append_int(buf, &pos, e->outstanding);
     4f0:	00001617          	auipc	a2,0x1
     4f4:	27060613          	addi	a2,a2,624 # 1760 <malloc+0x21c>
     4f8:	85ce                	mv	a1,s3
     4fa:	854a                	mv	a0,s2
     4fc:	b05ff0ef          	jal	0 <append_str>
     500:	1244aa83          	lw	s5,292(s1)
     504:	8656                	mv	a2,s5
     506:	85ce                	mv	a1,s3
     508:	854a                	mv	a0,s2
     50a:	bcdff0ef          	jal	d6 <append_int>
        append_str(buf, &pos, ",\"committing\":"); append_int(buf, &pos, e->committing);
     50e:	00001617          	auipc	a2,0x1
     512:	26260613          	addi	a2,a2,610 # 1770 <malloc+0x22c>
     516:	85ce                	mv	a1,s3
     518:	854a                	mv	a0,s2
     51a:	ae7ff0ef          	jal	0 <append_str>
     51e:	1284a783          	lw	a5,296(s1)
     522:	8b3e                	mv	s6,a5
     524:	863e                	mv	a2,a5
     526:	85ce                	mv	a1,s3
     528:	854a                	mv	a0,s2
     52a:	badff0ef          	jal	d6 <append_int>
        append_str(buf, &pos, "}");
     52e:	00001617          	auipc	a2,0x1
     532:	1d260613          	addi	a2,a2,466 # 1700 <malloc+0x1bc>
     536:	85ce                	mv	a1,s3
     538:	854a                	mv	a0,s2
     53a:	ac7ff0ef          	jal	0 <append_str>
        append_str(buf, &pos, ",\"changes\":{");
     53e:	00001617          	auipc	a2,0x1
     542:	1f260613          	addi	a2,a2,498 # 1730 <malloc+0x1ec>
     546:	85ce                	mv	a1,s3
     548:	854a                	mv	a0,s2
     54a:	ab7ff0ef          	jal	0 <append_str>
        print_change(buf, &pos, "log_n", e->old_log_n, e->log_n);
     54e:	8752                	mv	a4,s4
     550:	1144a683          	lw	a3,276(s1)
     554:	00001617          	auipc	a2,0x1
     558:	22c60613          	addi	a2,a2,556 # 1780 <malloc+0x23c>
     55c:	85ce                	mv	a1,s3
     55e:	854a                	mv	a0,s2
     560:	bafff0ef          	jal	10e <print_change>
        print_change(buf, &pos, "outstanding", e->old_outstanding, e->outstanding);
     564:	8756                	mv	a4,s5
     566:	1184a683          	lw	a3,280(s1)
     56a:	00001617          	auipc	a2,0x1
     56e:	21e60613          	addi	a2,a2,542 # 1788 <malloc+0x244>
     572:	85ce                	mv	a1,s3
     574:	854a                	mv	a0,s2
     576:	b99ff0ef          	jal	10e <print_change>
        print_change(buf, &pos, "committing", e->old_committing, e->committing);
     57a:	875a                	mv	a4,s6
     57c:	11c4a683          	lw	a3,284(s1)
     580:	00001617          	auipc	a2,0x1
     584:	21860613          	addi	a2,a2,536 # 1798 <malloc+0x254>
     588:	85ce                	mv	a1,s3
     58a:	854a                	mv	a0,s2
     58c:	b83ff0ef          	jal	10e <print_change>
        if(buf[pos-1] == ',') pos--;
     590:	bac42783          	lw	a5,-1108(s0)
     594:	37fd                	addiw	a5,a5,-1
     596:	fd078713          	addi	a4,a5,-48
     59a:	fe040693          	addi	a3,s0,-32
     59e:	9736                	add	a4,a4,a3
     5a0:	c0074683          	lbu	a3,-1024(a4)
     5a4:	02c00713          	li	a4,44
     5a8:	70e68263          	beq	a3,a4,cac <print_fs_event+0xb10>
        append_str(buf, &pos, "}");
     5ac:	00001617          	auipc	a2,0x1
     5b0:	15460613          	addi	a2,a2,340 # 1700 <malloc+0x1bc>
     5b4:	bac40593          	addi	a1,s0,-1108
     5b8:	bb040513          	addi	a0,s0,-1104
     5bc:	a45ff0ef          	jal	0 <append_str>
     5c0:	43013a03          	ld	s4,1072(sp)
     5c4:	42813a83          	ld	s5,1064(sp)
     5c8:	42013b03          	ld	s6,1056(sp)
     5cc:	b515                	j	3f0 <print_fs_event+0x254>
     5ce:	43413823          	sd	s4,1072(sp)
    append_str(buf, &pos, "BALLOC");
     5d2:	bac40993          	addi	s3,s0,-1108
     5d6:	bb040913          	addi	s2,s0,-1104
     5da:	00001617          	auipc	a2,0x1
     5de:	0d660613          	addi	a2,a2,214 # 16b0 <malloc+0x16c>
     5e2:	85ce                	mv	a1,s3
     5e4:	854a                	mv	a0,s2
     5e6:	a1bff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     5ea:	00001617          	auipc	a2,0x1
     5ee:	05660613          	addi	a2,a2,86 # 1640 <malloc+0xfc>
     5f2:	85ce                	mv	a1,s3
     5f4:	854a                	mv	a0,s2
     5f6:	a0bff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     5fa:	00001617          	auipc	a2,0x1
     5fe:	0a660613          	addi	a2,a2,166 # 16a0 <malloc+0x15c>
     602:	85ce                	mv	a1,s3
     604:	854a                	mv	a0,s2
     606:	9fbff0ef          	jal	0 <append_str>
     60a:	01448613          	addi	a2,s1,20
     60e:	85ce                	mv	a1,s3
     610:	854a                	mv	a0,s2
     612:	9efff0ef          	jal	0 <append_str>
     616:	00001617          	auipc	a2,0x1
     61a:	02a60613          	addi	a2,a2,42 # 1640 <malloc+0xfc>
     61e:	85ce                	mv	a1,s3
     620:	854a                	mv	a0,s2
     622:	9dfff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"block\":");
     626:	bac40993          	addi	s3,s0,-1108
     62a:	bb040913          	addi	s2,s0,-1104
     62e:	00001617          	auipc	a2,0x1
     632:	0c260613          	addi	a2,a2,194 # 16f0 <malloc+0x1ac>
     636:	85ce                	mv	a1,s3
     638:	854a                	mv	a0,s2
     63a:	9c7ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->balloc.blockno);
     63e:	1604a603          	lw	a2,352(s1)
     642:	85ce                	mv	a1,s3
     644:	854a                	mv	a0,s2
     646:	a91ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"state\":{" );
     64a:	00001617          	auipc	a2,0x1
     64e:	0be60613          	addi	a2,a2,190 # 1708 <malloc+0x1c4>
     652:	85ce                	mv	a1,s3
     654:	854a                	mv	a0,s2
     656:	9abff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"bit\":");
     65a:	00001617          	auipc	a2,0x1
     65e:	14e60613          	addi	a2,a2,334 # 17a8 <malloc+0x264>
     662:	85ce                	mv	a1,s3
     664:	854a                	mv	a0,s2
     666:	99bff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->balloc.bit);
     66a:	1644a783          	lw	a5,356(s1)
     66e:	8a3e                	mv	s4,a5
     670:	863e                	mv	a2,a5
     672:	85ce                	mv	a1,s3
     674:	854a                	mv	a0,s2
     676:	a61ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, "}");
     67a:	00001617          	auipc	a2,0x1
     67e:	08660613          	addi	a2,a2,134 # 1700 <malloc+0x1bc>
     682:	85ce                	mv	a1,s3
     684:	854a                	mv	a0,s2
     686:	97bff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{" );
     68a:	00001617          	auipc	a2,0x1
     68e:	0a660613          	addi	a2,a2,166 # 1730 <malloc+0x1ec>
     692:	85ce                	mv	a1,s3
     694:	854a                	mv	a0,s2
     696:	96bff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "bit", e->balloc.old_bit, e->balloc.bit);
     69a:	8752                	mv	a4,s4
     69c:	1684a683          	lw	a3,360(s1)
     6a0:	00001617          	auipc	a2,0x1
     6a4:	11060613          	addi	a2,a2,272 # 17b0 <malloc+0x26c>
     6a8:	85ce                	mv	a1,s3
     6aa:	854a                	mv	a0,s2
     6ac:	a63ff0ef          	jal	10e <print_change>
    if(buf[pos-1] == ',') pos--;
     6b0:	bac42783          	lw	a5,-1108(s0)
     6b4:	37fd                	addiw	a5,a5,-1
     6b6:	fd078713          	addi	a4,a5,-48
     6ba:	fe040693          	addi	a3,s0,-32
     6be:	9736                	add	a4,a4,a3
     6c0:	c0074683          	lbu	a3,-1024(a4)
     6c4:	02c00713          	li	a4,44
     6c8:	5ee68963          	beq	a3,a4,cba <print_fs_event+0xb1e>
    append_str(buf, &pos, "}");
     6cc:	00001617          	auipc	a2,0x1
     6d0:	03460613          	addi	a2,a2,52 # 1700 <malloc+0x1bc>
     6d4:	bac40593          	addi	a1,s0,-1108
     6d8:	bb040513          	addi	a0,s0,-1104
     6dc:	925ff0ef          	jal	0 <append_str>
     6e0:	43013a03          	ld	s4,1072(sp)
     6e4:	b331                	j	3f0 <print_fs_event+0x254>
     6e6:	43413823          	sd	s4,1072(sp)
     6ea:	43513423          	sd	s5,1064(sp)
     6ee:	43613023          	sd	s6,1056(sp)
     6f2:	41713c23          	sd	s7,1048(sp)
     6f6:	41813823          	sd	s8,1040(sp)
    append_str(buf, &pos, "INODE");
     6fa:	bac40993          	addi	s3,s0,-1108
     6fe:	bb040913          	addi	s2,s0,-1104
     702:	00001617          	auipc	a2,0x1
     706:	fb660613          	addi	a2,a2,-74 # 16b8 <malloc+0x174>
     70a:	85ce                	mv	a1,s3
     70c:	854a                	mv	a0,s2
     70e:	8f3ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     712:	00001617          	auipc	a2,0x1
     716:	f2e60613          	addi	a2,a2,-210 # 1640 <malloc+0xfc>
     71a:	85ce                	mv	a1,s3
     71c:	854a                	mv	a0,s2
     71e:	8e3ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     722:	00001617          	auipc	a2,0x1
     726:	f7e60613          	addi	a2,a2,-130 # 16a0 <malloc+0x15c>
     72a:	85ce                	mv	a1,s3
     72c:	854a                	mv	a0,s2
     72e:	8d3ff0ef          	jal	0 <append_str>
     732:	01448613          	addi	a2,s1,20
     736:	85ce                	mv	a1,s3
     738:	854a                	mv	a0,s2
     73a:	8c7ff0ef          	jal	0 <append_str>
     73e:	00001617          	auipc	a2,0x1
     742:	f0260613          	addi	a2,a2,-254 # 1640 <malloc+0xfc>
     746:	85ce                	mv	a1,s3
     748:	854a                	mv	a0,s2
     74a:	8b7ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"inode\":{");
     74e:	bac40993          	addi	s3,s0,-1108
     752:	bb040913          	addi	s2,s0,-1104
     756:	00001617          	auipc	a2,0x1
     75a:	06260613          	addi	a2,a2,98 # 17b8 <malloc+0x274>
     75e:	85ce                	mv	a1,s3
     760:	854a                	mv	a0,s2
     762:	89fff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"inum\":"); append_int(buf, &pos, e->inode.inum);
     766:	00001617          	auipc	a2,0x1
     76a:	06260613          	addi	a2,a2,98 # 17c8 <malloc+0x284>
     76e:	85ce                	mv	a1,s3
     770:	854a                	mv	a0,s2
     772:	88fff0ef          	jal	0 <append_str>
     776:	1604a603          	lw	a2,352(s1)
     77a:	85ce                	mv	a1,s3
     77c:	854a                	mv	a0,s2
     77e:	959ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, "}");
     782:	00001617          	auipc	a2,0x1
     786:	f7e60613          	addi	a2,a2,-130 # 1700 <malloc+0x1bc>
     78a:	85ce                	mv	a1,s3
     78c:	854a                	mv	a0,s2
     78e:	873ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"state\":{");
     792:	00001617          	auipc	a2,0x1
     796:	f7660613          	addi	a2,a2,-138 # 1708 <malloc+0x1c4>
     79a:	85ce                	mv	a1,s3
     79c:	854a                	mv	a0,s2
     79e:	863ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":"); append_int(buf, &pos, e->inode.ref);
     7a2:	00001617          	auipc	a2,0x1
     7a6:	f7660613          	addi	a2,a2,-138 # 1718 <malloc+0x1d4>
     7aa:	85ce                	mv	a1,s3
     7ac:	854a                	mv	a0,s2
     7ae:	853ff0ef          	jal	0 <append_str>
     7b2:	1644aa03          	lw	s4,356(s1)
     7b6:	8652                	mv	a2,s4
     7b8:	85ce                	mv	a1,s3
     7ba:	854a                	mv	a0,s2
     7bc:	91bff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"valid\":"); append_int(buf, &pos, e->inode.valid_inode);
     7c0:	00001617          	auipc	a2,0x1
     7c4:	f6060613          	addi	a2,a2,-160 # 1720 <malloc+0x1dc>
     7c8:	85ce                	mv	a1,s3
     7ca:	854a                	mv	a0,s2
     7cc:	835ff0ef          	jal	0 <append_str>
     7d0:	16c4aa83          	lw	s5,364(s1)
     7d4:	8656                	mv	a2,s5
     7d6:	85ce                	mv	a1,s3
     7d8:	854a                	mv	a0,s2
     7da:	8fdff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"type\":"); append_int(buf, &pos, e->inode.type_inode);
     7de:	00001617          	auipc	a2,0x1
     7e2:	ff260613          	addi	a2,a2,-14 # 17d0 <malloc+0x28c>
     7e6:	85ce                	mv	a1,s3
     7e8:	854a                	mv	a0,s2
     7ea:	817ff0ef          	jal	0 <append_str>
     7ee:	1744ab03          	lw	s6,372(s1)
     7f2:	865a                	mv	a2,s6
     7f4:	85ce                	mv	a1,s3
     7f6:	854a                	mv	a0,s2
     7f8:	8dfff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"size\":"); append_int(buf, &pos, e->inode.size);
     7fc:	00001617          	auipc	a2,0x1
     800:	fe460613          	addi	a2,a2,-28 # 17e0 <malloc+0x29c>
     804:	85ce                	mv	a1,s3
     806:	854a                	mv	a0,s2
     808:	ff8ff0ef          	jal	0 <append_str>
     80c:	17c4ab83          	lw	s7,380(s1)
     810:	865e                	mv	a2,s7
     812:	85ce                	mv	a1,s3
     814:	854a                	mv	a0,s2
     816:	8c1ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"locked\":"); append_int(buf, &pos, e->inode.locked);
     81a:	00001617          	auipc	a2,0x1
     81e:	fd660613          	addi	a2,a2,-42 # 17f0 <malloc+0x2ac>
     822:	85ce                	mv	a1,s3
     824:	854a                	mv	a0,s2
     826:	fdaff0ef          	jal	0 <append_str>
     82a:	1844a783          	lw	a5,388(s1)
     82e:	8c3e                	mv	s8,a5
     830:	863e                	mv	a2,a5
     832:	85ce                	mv	a1,s3
     834:	854a                	mv	a0,s2
     836:	8a1ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, "}");
     83a:	00001617          	auipc	a2,0x1
     83e:	ec660613          	addi	a2,a2,-314 # 1700 <malloc+0x1bc>
     842:	85ce                	mv	a1,s3
     844:	854a                	mv	a0,s2
     846:	fbaff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     84a:	00001617          	auipc	a2,0x1
     84e:	ee660613          	addi	a2,a2,-282 # 1730 <malloc+0x1ec>
     852:	85ce                	mv	a1,s3
     854:	854a                	mv	a0,s2
     856:	faaff0ef          	jal	0 <append_str>
    print_change(buf, &pos, "ref", e->inode.old_ref, e->inode.ref);
     85a:	8752                	mv	a4,s4
     85c:	1684a683          	lw	a3,360(s1)
     860:	00001617          	auipc	a2,0x1
     864:	ee060613          	addi	a2,a2,-288 # 1740 <malloc+0x1fc>
     868:	85ce                	mv	a1,s3
     86a:	854a                	mv	a0,s2
     86c:	8a3ff0ef          	jal	10e <print_change>
    print_change(buf, &pos, "valid", e->inode.old_valid_inode, e->inode.valid_inode);
     870:	8756                	mv	a4,s5
     872:	1704a683          	lw	a3,368(s1)
     876:	00001617          	auipc	a2,0x1
     87a:	ed260613          	addi	a2,a2,-302 # 1748 <malloc+0x204>
     87e:	85ce                	mv	a1,s3
     880:	854a                	mv	a0,s2
     882:	88dff0ef          	jal	10e <print_change>
    print_change(buf, &pos, "type", e->inode.old_type_inode, e->inode.type_inode);
     886:	875a                	mv	a4,s6
     888:	1784a683          	lw	a3,376(s1)
     88c:	00001617          	auipc	a2,0x1
     890:	f7460613          	addi	a2,a2,-140 # 1800 <malloc+0x2bc>
     894:	85ce                	mv	a1,s3
     896:	854a                	mv	a0,s2
     898:	877ff0ef          	jal	10e <print_change>
    print_change(buf, &pos, "size", e->inode.old_size, e->inode.size);
     89c:	875e                	mv	a4,s7
     89e:	1804a683          	lw	a3,384(s1)
     8a2:	00001617          	auipc	a2,0x1
     8a6:	f6660613          	addi	a2,a2,-154 # 1808 <malloc+0x2c4>
     8aa:	85ce                	mv	a1,s3
     8ac:	854a                	mv	a0,s2
     8ae:	861ff0ef          	jal	10e <print_change>
    print_change(buf, &pos, "locked", e->inode.old_locked, e->inode.locked);
     8b2:	8762                	mv	a4,s8
     8b4:	1884a683          	lw	a3,392(s1)
     8b8:	00001617          	auipc	a2,0x1
     8bc:	f5860613          	addi	a2,a2,-168 # 1810 <malloc+0x2cc>
     8c0:	85ce                	mv	a1,s3
     8c2:	854a                	mv	a0,s2
     8c4:	84bff0ef          	jal	10e <print_change>
    if(buf[pos-1] == ',') pos--;
     8c8:	bac42783          	lw	a5,-1108(s0)
     8cc:	37fd                	addiw	a5,a5,-1
     8ce:	fd078713          	addi	a4,a5,-48
     8d2:	fe040693          	addi	a3,s0,-32
     8d6:	9736                	add	a4,a4,a3
     8d8:	c0074683          	lbu	a3,-1024(a4)
     8dc:	02c00713          	li	a4,44
     8e0:	3ee68b63          	beq	a3,a4,cd6 <print_fs_event+0xb3a>
    append_str(buf, &pos, "}");
     8e4:	00001617          	auipc	a2,0x1
     8e8:	e1c60613          	addi	a2,a2,-484 # 1700 <malloc+0x1bc>
     8ec:	bac40593          	addi	a1,s0,-1108
     8f0:	bb040513          	addi	a0,s0,-1104
     8f4:	f0cff0ef          	jal	0 <append_str>
     8f8:	43013a03          	ld	s4,1072(sp)
     8fc:	42813a83          	ld	s5,1064(sp)
     900:	42013b03          	ld	s6,1056(sp)
     904:	41813b83          	ld	s7,1048(sp)
     908:	41013c03          	ld	s8,1040(sp)
     90c:	b4d5                	j	3f0 <print_fs_event+0x254>
    append_str(buf, &pos, "DIR");
     90e:	bac40993          	addi	s3,s0,-1108
     912:	bb040913          	addi	s2,s0,-1104
     916:	00001617          	auipc	a2,0x1
     91a:	daa60613          	addi	a2,a2,-598 # 16c0 <malloc+0x17c>
     91e:	85ce                	mv	a1,s3
     920:	854a                	mv	a0,s2
     922:	edeff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     926:	00001617          	auipc	a2,0x1
     92a:	d1a60613          	addi	a2,a2,-742 # 1640 <malloc+0xfc>
     92e:	85ce                	mv	a1,s3
     930:	854a                	mv	a0,s2
     932:	eceff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     936:	00001617          	auipc	a2,0x1
     93a:	d6a60613          	addi	a2,a2,-662 # 16a0 <malloc+0x15c>
     93e:	85ce                	mv	a1,s3
     940:	854a                	mv	a0,s2
     942:	ebeff0ef          	jal	0 <append_str>
     946:	01448613          	addi	a2,s1,20
     94a:	85ce                	mv	a1,s3
     94c:	854a                	mv	a0,s2
     94e:	eb2ff0ef          	jal	0 <append_str>
     952:	00001617          	auipc	a2,0x1
     956:	cee60613          	addi	a2,a2,-786 # 1640 <malloc+0xfc>
     95a:	85ce                	mv	a1,s3
     95c:	854a                	mv	a0,s2
     95e:	ea2ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"dir\":{");
     962:	bac40993          	addi	s3,s0,-1108
     966:	bb040913          	addi	s2,s0,-1104
     96a:	00001617          	auipc	a2,0x1
     96e:	eae60613          	addi	a2,a2,-338 # 1818 <malloc+0x2d4>
     972:	85ce                	mv	a1,s3
     974:	854a                	mv	a0,s2
     976:	e8aff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"parent\":");
     97a:	00001617          	auipc	a2,0x1
     97e:	eae60613          	addi	a2,a2,-338 # 1828 <malloc+0x2e4>
     982:	85ce                	mv	a1,s3
     984:	854a                	mv	a0,s2
     986:	e7aff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->dir.parent_inum);
     98a:	1f44a603          	lw	a2,500(s1)
     98e:	85ce                	mv	a1,s3
     990:	854a                	mv	a0,s2
     992:	f44ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"target\":");
     996:	00001617          	auipc	a2,0x1
     99a:	ea260613          	addi	a2,a2,-350 # 1838 <malloc+0x2f4>
     99e:	85ce                	mv	a1,s3
     9a0:	854a                	mv	a0,s2
     9a2:	e5eff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->dir.target_inum);
     9a6:	1f84a603          	lw	a2,504(s1)
     9aa:	85ce                	mv	a1,s3
     9ac:	854a                	mv	a0,s2
     9ae:	f28ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"offset\":");
     9b2:	00001617          	auipc	a2,0x1
     9b6:	e9660613          	addi	a2,a2,-362 # 1848 <malloc+0x304>
     9ba:	85ce                	mv	a1,s3
     9bc:	854a                	mv	a0,s2
     9be:	e42ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->dir.offset);
     9c2:	1fc4a603          	lw	a2,508(s1)
     9c6:	85ce                	mv	a1,s3
     9c8:	854a                	mv	a0,s2
     9ca:	f0cff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"name\":\"");
     9ce:	00001617          	auipc	a2,0x1
     9d2:	e8a60613          	addi	a2,a2,-374 # 1858 <malloc+0x314>
     9d6:	85ce                	mv	a1,s3
     9d8:	854a                	mv	a0,s2
     9da:	e26ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->dir.name);
     9de:	1e048613          	addi	a2,s1,480
     9e2:	85ce                	mv	a1,s3
     9e4:	854a                	mv	a0,s2
     9e6:	e1aff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"}");
     9ea:	00001617          	auipc	a2,0x1
     9ee:	e7e60613          	addi	a2,a2,-386 # 1868 <malloc+0x324>
     9f2:	85ce                	mv	a1,s3
     9f4:	854a                	mv	a0,s2
     9f6:	e0aff0ef          	jal	0 <append_str>
     9fa:	badd                	j	3f0 <print_fs_event+0x254>
    append_str(buf, &pos, "PATH");
     9fc:	bac40993          	addi	s3,s0,-1108
     a00:	bb040913          	addi	s2,s0,-1104
     a04:	00001617          	auipc	a2,0x1
     a08:	cc460613          	addi	a2,a2,-828 # 16c8 <malloc+0x184>
     a0c:	85ce                	mv	a1,s3
     a0e:	854a                	mv	a0,s2
     a10:	df0ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     a14:	00001617          	auipc	a2,0x1
     a18:	c2c60613          	addi	a2,a2,-980 # 1640 <malloc+0xfc>
     a1c:	85ce                	mv	a1,s3
     a1e:	854a                	mv	a0,s2
     a20:	de0ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     a24:	00001617          	auipc	a2,0x1
     a28:	c7c60613          	addi	a2,a2,-900 # 16a0 <malloc+0x15c>
     a2c:	85ce                	mv	a1,s3
     a2e:	854a                	mv	a0,s2
     a30:	dd0ff0ef          	jal	0 <append_str>
     a34:	01448613          	addi	a2,s1,20
     a38:	85ce                	mv	a1,s3
     a3a:	854a                	mv	a0,s2
     a3c:	dc4ff0ef          	jal	0 <append_str>
     a40:	00001617          	auipc	a2,0x1
     a44:	c0060613          	addi	a2,a2,-1024 # 1640 <malloc+0xfc>
     a48:	85ce                	mv	a1,s3
     a4a:	854a                	mv	a0,s2
     a4c:	db4ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"path\":\"");
     a50:	bac40993          	addi	s3,s0,-1108
     a54:	bb040913          	addi	s2,s0,-1104
     a58:	00001617          	auipc	a2,0x1
     a5c:	e1860613          	addi	a2,a2,-488 # 1870 <malloc+0x32c>
     a60:	85ce                	mv	a1,s3
     a62:	854a                	mv	a0,s2
     a64:	d9cff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->dir.path);
     a68:	16048613          	addi	a2,s1,352
     a6c:	85ce                	mv	a1,s3
     a6e:	854a                	mv	a0,s2
     a70:	d90ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     a74:	00001617          	auipc	a2,0x1
     a78:	bcc60613          	addi	a2,a2,-1076 # 1640 <malloc+0xfc>
     a7c:	85ce                	mv	a1,s3
     a7e:	854a                	mv	a0,s2
     a80:	d80ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"elem\":\"");
     a84:	00001617          	auipc	a2,0x1
     a88:	dfc60613          	addi	a2,a2,-516 # 1880 <malloc+0x33c>
     a8c:	85ce                	mv	a1,s3
     a8e:	854a                	mv	a0,s2
     a90:	d70ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, e->dir.name);
     a94:	1e048613          	addi	a2,s1,480
     a98:	85ce                	mv	a1,s3
     a9a:	854a                	mv	a0,s2
     a9c:	d64ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     aa0:	00001617          	auipc	a2,0x1
     aa4:	ba060613          	addi	a2,a2,-1120 # 1640 <malloc+0xfc>
     aa8:	85ce                	mv	a1,s3
     aaa:	854a                	mv	a0,s2
     aac:	d54ff0ef          	jal	0 <append_str>
     ab0:	941ff06f          	j	3f0 <print_fs_event+0x254>
     ab4:	43413823          	sd	s4,1072(sp)
     ab8:	43513423          	sd	s5,1064(sp)
    append_str(buf, &pos, "FILE");
     abc:	bac40993          	addi	s3,s0,-1108
     ac0:	bb040913          	addi	s2,s0,-1104
     ac4:	00001617          	auipc	a2,0x1
     ac8:	c0c60613          	addi	a2,a2,-1012 # 16d0 <malloc+0x18c>
     acc:	85ce                	mv	a1,s3
     ace:	854a                	mv	a0,s2
     ad0:	d30ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"");
     ad4:	00001617          	auipc	a2,0x1
     ad8:	b6c60613          	addi	a2,a2,-1172 # 1640 <malloc+0xfc>
     adc:	85ce                	mv	a1,s3
     ade:	854a                	mv	a0,s2
     ae0:	d20ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     ae4:	00001617          	auipc	a2,0x1
     ae8:	bbc60613          	addi	a2,a2,-1092 # 16a0 <malloc+0x15c>
     aec:	85ce                	mv	a1,s3
     aee:	854a                	mv	a0,s2
     af0:	d10ff0ef          	jal	0 <append_str>
     af4:	01448613          	addi	a2,s1,20
     af8:	85ce                	mv	a1,s3
     afa:	854a                	mv	a0,s2
     afc:	d04ff0ef          	jal	0 <append_str>
     b00:	00001617          	auipc	a2,0x1
     b04:	b4060613          	addi	a2,a2,-1216 # 1640 <malloc+0xfc>
     b08:	85ce                	mv	a1,s3
     b0a:	854a                	mv	a0,s2
     b0c:	cf4ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"state\":{");
     b10:	bac40993          	addi	s3,s0,-1108
     b14:	bb040913          	addi	s2,s0,-1104
     b18:	00001617          	auipc	a2,0x1
     b1c:	bf060613          	addi	a2,a2,-1040 # 1708 <malloc+0x1c4>
     b20:	85ce                	mv	a1,s3
     b22:	854a                	mv	a0,s2
     b24:	cdcff0ef          	jal	0 <append_str>
    append_str(buf, &pos, "\"ref\":");
     b28:	00001617          	auipc	a2,0x1
     b2c:	bf060613          	addi	a2,a2,-1040 # 1718 <malloc+0x1d4>
     b30:	85ce                	mv	a1,s3
     b32:	854a                	mv	a0,s2
     b34:	cccff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file.file_ref);
     b38:	1704aa03          	lw	s4,368(s1)
     b3c:	8652                	mv	a2,s4
     b3e:	85ce                	mv	a1,s3
     b40:	854a                	mv	a0,s2
     b42:	d94ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"offset\":");
     b46:	00001617          	auipc	a2,0x1
     b4a:	d0260613          	addi	a2,a2,-766 # 1848 <malloc+0x304>
     b4e:	85ce                	mv	a1,s3
     b50:	854a                	mv	a0,s2
     b52:	caeff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file.file_off);
     b56:	1784a783          	lw	a5,376(s1)
     b5a:	8abe                	mv	s5,a5
     b5c:	863e                	mv	a2,a5
     b5e:	85ce                	mv	a1,s3
     b60:	854a                	mv	a0,s2
     b62:	d74ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"readable\":");
     b66:	00001617          	auipc	a2,0x1
     b6a:	d2a60613          	addi	a2,a2,-726 # 1890 <malloc+0x34c>
     b6e:	85ce                	mv	a1,s3
     b70:	854a                	mv	a0,s2
     b72:	c8eff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file.readable);
     b76:	1684a603          	lw	a2,360(s1)
     b7a:	85ce                	mv	a1,s3
     b7c:	854a                	mv	a0,s2
     b7e:	d58ff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, ",\"writable\":");
     b82:	00001617          	auipc	a2,0x1
     b86:	d1e60613          	addi	a2,a2,-738 # 18a0 <malloc+0x35c>
     b8a:	85ce                	mv	a1,s3
     b8c:	854a                	mv	a0,s2
     b8e:	c72ff0ef          	jal	0 <append_str>
    append_int(buf, &pos, e->file.writable);
     b92:	16c4a603          	lw	a2,364(s1)
     b96:	85ce                	mv	a1,s3
     b98:	854a                	mv	a0,s2
     b9a:	d3cff0ef          	jal	d6 <append_int>
    append_str(buf, &pos, "}");
     b9e:	00001617          	auipc	a2,0x1
     ba2:	b6260613          	addi	a2,a2,-1182 # 1700 <malloc+0x1bc>
     ba6:	85ce                	mv	a1,s3
     ba8:	854a                	mv	a0,s2
     baa:	c56ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"changes\":{");
     bae:	00001617          	auipc	a2,0x1
     bb2:	b8260613          	addi	a2,a2,-1150 # 1730 <malloc+0x1ec>
     bb6:	85ce                	mv	a1,s3
     bb8:	854a                	mv	a0,s2
     bba:	c46ff0ef          	jal	0 <append_str>
    print_change(buf, &pos,
     bbe:	8752                	mv	a4,s4
     bc0:	1744a683          	lw	a3,372(s1)
     bc4:	00001617          	auipc	a2,0x1
     bc8:	b7c60613          	addi	a2,a2,-1156 # 1740 <malloc+0x1fc>
     bcc:	85ce                	mv	a1,s3
     bce:	854a                	mv	a0,s2
     bd0:	d3eff0ef          	jal	10e <print_change>
    print_change(buf, &pos,
     bd4:	8756                	mv	a4,s5
     bd6:	17c4a683          	lw	a3,380(s1)
     bda:	00001617          	auipc	a2,0x1
     bde:	cd660613          	addi	a2,a2,-810 # 18b0 <malloc+0x36c>
     be2:	85ce                	mv	a1,s3
     be4:	854a                	mv	a0,s2
     be6:	d28ff0ef          	jal	10e <print_change>
    if(buf[pos-1] == ',')
     bea:	bac42783          	lw	a5,-1108(s0)
     bee:	37fd                	addiw	a5,a5,-1
     bf0:	fd078713          	addi	a4,a5,-48
     bf4:	fe040693          	addi	a3,s0,-32
     bf8:	9736                	add	a4,a4,a3
     bfa:	c0074683          	lbu	a3,-1024(a4)
     bfe:	02c00713          	li	a4,44
     c02:	0ee68263          	beq	a3,a4,ce6 <print_fs_event+0xb4a>
    append_str(buf, &pos, "}");
     c06:	00001617          	auipc	a2,0x1
     c0a:	afa60613          	addi	a2,a2,-1286 # 1700 <malloc+0x1bc>
     c0e:	bac40593          	addi	a1,s0,-1108
     c12:	bb040513          	addi	a0,s0,-1104
     c16:	beaff0ef          	jal	0 <append_str>
     c1a:	43013a03          	ld	s4,1072(sp)
     c1e:	42813a83          	ld	s5,1064(sp)
     c22:	fceff06f          	j	3f0 <print_fs_event+0x254>
    append_str(buf, &pos, "\"");
     c26:	bb040993          	addi	s3,s0,-1104
     c2a:	00001617          	auipc	a2,0x1
     c2e:	a1660613          	addi	a2,a2,-1514 # 1640 <malloc+0xfc>
     c32:	bac40593          	addi	a1,s0,-1108
     c36:	854e                	mv	a0,s3
     c38:	bc8ff0ef          	jal	0 <append_str>
    append_str(buf, &pos, ",\"op\":\""); append_str(buf, &pos, e->op_name); append_str(buf, &pos, "\"");
     c3c:	00001617          	auipc	a2,0x1
     c40:	a6460613          	addi	a2,a2,-1436 # 16a0 <malloc+0x15c>
     c44:	bac40593          	addi	a1,s0,-1108
     c48:	854e                	mv	a0,s3
     c4a:	bb6ff0ef          	jal	0 <append_str>
     c4e:	01448613          	addi	a2,s1,20
     c52:	bac40593          	addi	a1,s0,-1108
     c56:	854e                	mv	a0,s3
     c58:	ba8ff0ef          	jal	0 <append_str>
     c5c:	00001617          	auipc	a2,0x1
     c60:	9e460613          	addi	a2,a2,-1564 # 1640 <malloc+0xfc>
     c64:	bac40593          	addi	a1,s0,-1108
     c68:	854e                	mv	a0,s3
     c6a:	b96ff0ef          	jal	0 <append_str>
    if(e->type == LAYER_BCACHE){
     c6e:	479d                	li	a5,7
     c70:	f927e063          	bltu	a5,s2,3f0 <print_fs_event+0x254>
     c74:	090a                	slli	s2,s2,0x2
     c76:	00001717          	auipc	a4,0x1
     c7a:	cca70713          	addi	a4,a4,-822 # 1940 <malloc+0x3fc>
     c7e:	993a                	add	s2,s2,a4
     c80:	00092783          	lw	a5,0(s2)
     c84:	97ba                	add	a5,a5,a4
     c86:	8782                	jr	a5
     c88:	43413823          	sd	s4,1072(sp)
     c8c:	43513423          	sd	s5,1064(sp)
     c90:	e2eff06f          	j	2be <print_fs_event+0x122>
        if(buf[pos-1] == ',') pos--; // remove last comma
     c94:	baf42623          	sw	a5,-1108(s0)
     c98:	f3cff06f          	j	3d4 <print_fs_event+0x238>
     c9c:	43413823          	sd	s4,1072(sp)
     ca0:	43513423          	sd	s5,1064(sp)
     ca4:	43613023          	sd	s6,1056(sp)
     ca8:	813ff06f          	j	4ba <print_fs_event+0x31e>
        if(buf[pos-1] == ',') pos--;
     cac:	baf42623          	sw	a5,-1108(s0)
     cb0:	8fdff06f          	j	5ac <print_fs_event+0x410>
     cb4:	43413823          	sd	s4,1072(sp)
     cb8:	b2bd                	j	626 <print_fs_event+0x48a>
    if(buf[pos-1] == ',') pos--;
     cba:	baf42623          	sw	a5,-1108(s0)
     cbe:	b439                	j	6cc <print_fs_event+0x530>
     cc0:	43413823          	sd	s4,1072(sp)
     cc4:	43513423          	sd	s5,1064(sp)
     cc8:	43613023          	sd	s6,1056(sp)
     ccc:	41713c23          	sd	s7,1048(sp)
     cd0:	41813823          	sd	s8,1040(sp)
     cd4:	bcad                	j	74e <print_fs_event+0x5b2>
    if(buf[pos-1] == ',') pos--;
     cd6:	baf42623          	sw	a5,-1108(s0)
     cda:	b129                	j	8e4 <print_fs_event+0x748>
     cdc:	43413823          	sd	s4,1072(sp)
     ce0:	43513423          	sd	s5,1064(sp)
     ce4:	b535                	j	b10 <print_fs_event+0x974>
        pos--;
     ce6:	baf42623          	sw	a5,-1108(s0)
     cea:	bf31                	j	c06 <print_fs_event+0xa6a>

0000000000000cec <main>:

int main(void) {
     cec:	7139                	addi	sp,sp,-64
     cee:	fc06                	sd	ra,56(sp)
     cf0:	f822                	sd	s0,48(sp)
     cf2:	f426                	sd	s1,40(sp)
     cf4:	f04a                	sd	s2,32(sp)
     cf6:	ec4e                	sd	s3,24(sp)
     cf8:	e852                	sd	s4,16(sp)
     cfa:	e456                	sd	s5,8(sp)
     cfc:	0080                	addi	s0,sp,64
    printf("FS Buffer Cache Export starting...\n");
     cfe:	00001517          	auipc	a0,0x1
     d02:	bd250513          	addi	a0,a0,-1070 # 18d0 <malloc+0x38c>
     d06:	786000ef          	jal	148c <printf>
    
    while (1) {
        int n_fs = fsread(fs_ev, 16);
     d0a:	4a41                	li	s4,16
     d0c:	00001997          	auipc	s3,0x1
     d10:	30498993          	addi	s3,s3,772 # 2010 <fs_ev>
        for (int i = 0; i < n_fs; i++) {
            print_fs_event(&fs_ev[i]);
        }

        // استخدام sleep(2) بدلاً من pause في xv6 لضمان استمرار الحلقة
        pause(2); 
     d14:	4a89                	li	s5,2
     d16:	a831                	j	d32 <main+0x46>
            fprintf(2, "fsexport: error reading fslog\n");
     d18:	00001597          	auipc	a1,0x1
     d1c:	be058593          	addi	a1,a1,-1056 # 18f8 <malloc+0x3b4>
     d20:	4509                	li	a0,2
     d22:	740000ef          	jal	1462 <fprintf>
            exit(1);
     d26:	4505                	li	a0,1
     d28:	2ee000ef          	jal	1016 <exit>
        pause(2); 
     d2c:	8556                	mv	a0,s5
     d2e:	378000ef          	jal	10a6 <pause>
        int n_fs = fsread(fs_ev, 16);
     d32:	85d2                	mv	a1,s4
     d34:	854e                	mv	a0,s3
     d36:	388000ef          	jal	10be <fsread>
        if (n_fs < 0) {
     d3a:	fc054fe3          	bltz	a0,d18 <main+0x2c>
        for (int i = 0; i < n_fs; i++) {
     d3e:	00001497          	auipc	s1,0x1
     d42:	2d248493          	addi	s1,s1,722 # 2010 <fs_ev>
     d46:	00951913          	slli	s2,a0,0x9
     d4a:	9926                	add	s2,s2,s1
     d4c:	fea050e3          	blez	a0,d2c <main+0x40>
            print_fs_event(&fs_ev[i]);
     d50:	8526                	mv	a0,s1
     d52:	c4aff0ef          	jal	19c <print_fs_event>
        for (int i = 0; i < n_fs; i++) {
     d56:	20048493          	addi	s1,s1,512
     d5a:	ff249be3          	bne	s1,s2,d50 <main+0x64>
     d5e:	b7f9                	j	d2c <main+0x40>

0000000000000d60 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     d60:	1141                	addi	sp,sp,-16
     d62:	e406                	sd	ra,8(sp)
     d64:	e022                	sd	s0,0(sp)
     d66:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     d68:	f85ff0ef          	jal	cec <main>
  exit(r);
     d6c:	2aa000ef          	jal	1016 <exit>

0000000000000d70 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     d70:	1141                	addi	sp,sp,-16
     d72:	e406                	sd	ra,8(sp)
     d74:	e022                	sd	s0,0(sp)
     d76:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     d78:	87aa                	mv	a5,a0
     d7a:	0585                	addi	a1,a1,1
     d7c:	0785                	addi	a5,a5,1
     d7e:	fff5c703          	lbu	a4,-1(a1)
     d82:	fee78fa3          	sb	a4,-1(a5)
     d86:	fb75                	bnez	a4,d7a <strcpy+0xa>
    ;
  return os;
}
     d88:	60a2                	ld	ra,8(sp)
     d8a:	6402                	ld	s0,0(sp)
     d8c:	0141                	addi	sp,sp,16
     d8e:	8082                	ret

0000000000000d90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d90:	1141                	addi	sp,sp,-16
     d92:	e406                	sd	ra,8(sp)
     d94:	e022                	sd	s0,0(sp)
     d96:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     d98:	00054783          	lbu	a5,0(a0)
     d9c:	cb91                	beqz	a5,db0 <strcmp+0x20>
     d9e:	0005c703          	lbu	a4,0(a1)
     da2:	00f71763          	bne	a4,a5,db0 <strcmp+0x20>
    p++, q++;
     da6:	0505                	addi	a0,a0,1
     da8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     daa:	00054783          	lbu	a5,0(a0)
     dae:	fbe5                	bnez	a5,d9e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     db0:	0005c503          	lbu	a0,0(a1)
}
     db4:	40a7853b          	subw	a0,a5,a0
     db8:	60a2                	ld	ra,8(sp)
     dba:	6402                	ld	s0,0(sp)
     dbc:	0141                	addi	sp,sp,16
     dbe:	8082                	ret

0000000000000dc0 <strlen>:

uint
strlen(const char *s)
{
     dc0:	1141                	addi	sp,sp,-16
     dc2:	e406                	sd	ra,8(sp)
     dc4:	e022                	sd	s0,0(sp)
     dc6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     dc8:	00054783          	lbu	a5,0(a0)
     dcc:	cf91                	beqz	a5,de8 <strlen+0x28>
     dce:	00150793          	addi	a5,a0,1
     dd2:	86be                	mv	a3,a5
     dd4:	0785                	addi	a5,a5,1
     dd6:	fff7c703          	lbu	a4,-1(a5)
     dda:	ff65                	bnez	a4,dd2 <strlen+0x12>
     ddc:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     de0:	60a2                	ld	ra,8(sp)
     de2:	6402                	ld	s0,0(sp)
     de4:	0141                	addi	sp,sp,16
     de6:	8082                	ret
  for(n = 0; s[n]; n++)
     de8:	4501                	li	a0,0
     dea:	bfdd                	j	de0 <strlen+0x20>

0000000000000dec <memset>:

void*
memset(void *dst, int c, uint n)
{
     dec:	1141                	addi	sp,sp,-16
     dee:	e406                	sd	ra,8(sp)
     df0:	e022                	sd	s0,0(sp)
     df2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     df4:	ca19                	beqz	a2,e0a <memset+0x1e>
     df6:	87aa                	mv	a5,a0
     df8:	1602                	slli	a2,a2,0x20
     dfa:	9201                	srli	a2,a2,0x20
     dfc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     e00:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     e04:	0785                	addi	a5,a5,1
     e06:	fee79de3          	bne	a5,a4,e00 <memset+0x14>
  }
  return dst;
}
     e0a:	60a2                	ld	ra,8(sp)
     e0c:	6402                	ld	s0,0(sp)
     e0e:	0141                	addi	sp,sp,16
     e10:	8082                	ret

0000000000000e12 <strchr>:

char*
strchr(const char *s, char c)
{
     e12:	1141                	addi	sp,sp,-16
     e14:	e406                	sd	ra,8(sp)
     e16:	e022                	sd	s0,0(sp)
     e18:	0800                	addi	s0,sp,16
  for(; *s; s++)
     e1a:	00054783          	lbu	a5,0(a0)
     e1e:	cf81                	beqz	a5,e36 <strchr+0x24>
    if(*s == c)
     e20:	00f58763          	beq	a1,a5,e2e <strchr+0x1c>
  for(; *s; s++)
     e24:	0505                	addi	a0,a0,1
     e26:	00054783          	lbu	a5,0(a0)
     e2a:	fbfd                	bnez	a5,e20 <strchr+0xe>
      return (char*)s;
  return 0;
     e2c:	4501                	li	a0,0
}
     e2e:	60a2                	ld	ra,8(sp)
     e30:	6402                	ld	s0,0(sp)
     e32:	0141                	addi	sp,sp,16
     e34:	8082                	ret
  return 0;
     e36:	4501                	li	a0,0
     e38:	bfdd                	j	e2e <strchr+0x1c>

0000000000000e3a <gets>:

char*
gets(char *buf, int max)
{
     e3a:	711d                	addi	sp,sp,-96
     e3c:	ec86                	sd	ra,88(sp)
     e3e:	e8a2                	sd	s0,80(sp)
     e40:	e4a6                	sd	s1,72(sp)
     e42:	e0ca                	sd	s2,64(sp)
     e44:	fc4e                	sd	s3,56(sp)
     e46:	f852                	sd	s4,48(sp)
     e48:	f456                	sd	s5,40(sp)
     e4a:	f05a                	sd	s6,32(sp)
     e4c:	ec5e                	sd	s7,24(sp)
     e4e:	e862                	sd	s8,16(sp)
     e50:	1080                	addi	s0,sp,96
     e52:	8baa                	mv	s7,a0
     e54:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e56:	892a                	mv	s2,a0
     e58:	4481                	li	s1,0
    cc = read(0, &c, 1);
     e5a:	faf40b13          	addi	s6,s0,-81
     e5e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
     e60:	8c26                	mv	s8,s1
     e62:	0014899b          	addiw	s3,s1,1
     e66:	84ce                	mv	s1,s3
     e68:	0349d463          	bge	s3,s4,e90 <gets+0x56>
    cc = read(0, &c, 1);
     e6c:	8656                	mv	a2,s5
     e6e:	85da                	mv	a1,s6
     e70:	4501                	li	a0,0
     e72:	1bc000ef          	jal	102e <read>
    if(cc < 1)
     e76:	00a05d63          	blez	a0,e90 <gets+0x56>
      break;
    buf[i++] = c;
     e7a:	faf44783          	lbu	a5,-81(s0)
     e7e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     e82:	0905                	addi	s2,s2,1
     e84:	ff678713          	addi	a4,a5,-10
     e88:	c319                	beqz	a4,e8e <gets+0x54>
     e8a:	17cd                	addi	a5,a5,-13
     e8c:	fbf1                	bnez	a5,e60 <gets+0x26>
    buf[i++] = c;
     e8e:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     e90:	9c5e                	add	s8,s8,s7
     e92:	000c0023          	sb	zero,0(s8)
  return buf;
}
     e96:	855e                	mv	a0,s7
     e98:	60e6                	ld	ra,88(sp)
     e9a:	6446                	ld	s0,80(sp)
     e9c:	64a6                	ld	s1,72(sp)
     e9e:	6906                	ld	s2,64(sp)
     ea0:	79e2                	ld	s3,56(sp)
     ea2:	7a42                	ld	s4,48(sp)
     ea4:	7aa2                	ld	s5,40(sp)
     ea6:	7b02                	ld	s6,32(sp)
     ea8:	6be2                	ld	s7,24(sp)
     eaa:	6c42                	ld	s8,16(sp)
     eac:	6125                	addi	sp,sp,96
     eae:	8082                	ret

0000000000000eb0 <stat>:

int
stat(const char *n, struct stat *st)
{
     eb0:	1101                	addi	sp,sp,-32
     eb2:	ec06                	sd	ra,24(sp)
     eb4:	e822                	sd	s0,16(sp)
     eb6:	e04a                	sd	s2,0(sp)
     eb8:	1000                	addi	s0,sp,32
     eba:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     ebc:	4581                	li	a1,0
     ebe:	198000ef          	jal	1056 <open>
  if(fd < 0)
     ec2:	02054263          	bltz	a0,ee6 <stat+0x36>
     ec6:	e426                	sd	s1,8(sp)
     ec8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     eca:	85ca                	mv	a1,s2
     ecc:	1a2000ef          	jal	106e <fstat>
     ed0:	892a                	mv	s2,a0
  close(fd);
     ed2:	8526                	mv	a0,s1
     ed4:	16a000ef          	jal	103e <close>
  return r;
     ed8:	64a2                	ld	s1,8(sp)
}
     eda:	854a                	mv	a0,s2
     edc:	60e2                	ld	ra,24(sp)
     ede:	6442                	ld	s0,16(sp)
     ee0:	6902                	ld	s2,0(sp)
     ee2:	6105                	addi	sp,sp,32
     ee4:	8082                	ret
    return -1;
     ee6:	57fd                	li	a5,-1
     ee8:	893e                	mv	s2,a5
     eea:	bfc5                	j	eda <stat+0x2a>

0000000000000eec <atoi>:

int
atoi(const char *s)
{
     eec:	1141                	addi	sp,sp,-16
     eee:	e406                	sd	ra,8(sp)
     ef0:	e022                	sd	s0,0(sp)
     ef2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     ef4:	00054683          	lbu	a3,0(a0)
     ef8:	fd06879b          	addiw	a5,a3,-48
     efc:	0ff7f793          	zext.b	a5,a5
     f00:	4625                	li	a2,9
     f02:	02f66963          	bltu	a2,a5,f34 <atoi+0x48>
     f06:	872a                	mv	a4,a0
  n = 0;
     f08:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     f0a:	0705                	addi	a4,a4,1
     f0c:	0025179b          	slliw	a5,a0,0x2
     f10:	9fa9                	addw	a5,a5,a0
     f12:	0017979b          	slliw	a5,a5,0x1
     f16:	9fb5                	addw	a5,a5,a3
     f18:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     f1c:	00074683          	lbu	a3,0(a4)
     f20:	fd06879b          	addiw	a5,a3,-48
     f24:	0ff7f793          	zext.b	a5,a5
     f28:	fef671e3          	bgeu	a2,a5,f0a <atoi+0x1e>
  return n;
}
     f2c:	60a2                	ld	ra,8(sp)
     f2e:	6402                	ld	s0,0(sp)
     f30:	0141                	addi	sp,sp,16
     f32:	8082                	ret
  n = 0;
     f34:	4501                	li	a0,0
     f36:	bfdd                	j	f2c <atoi+0x40>

0000000000000f38 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     f38:	1141                	addi	sp,sp,-16
     f3a:	e406                	sd	ra,8(sp)
     f3c:	e022                	sd	s0,0(sp)
     f3e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     f40:	02b57563          	bgeu	a0,a1,f6a <memmove+0x32>
    while(n-- > 0)
     f44:	00c05f63          	blez	a2,f62 <memmove+0x2a>
     f48:	1602                	slli	a2,a2,0x20
     f4a:	9201                	srli	a2,a2,0x20
     f4c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     f50:	872a                	mv	a4,a0
      *dst++ = *src++;
     f52:	0585                	addi	a1,a1,1
     f54:	0705                	addi	a4,a4,1
     f56:	fff5c683          	lbu	a3,-1(a1)
     f5a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     f5e:	fee79ae3          	bne	a5,a4,f52 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     f62:	60a2                	ld	ra,8(sp)
     f64:	6402                	ld	s0,0(sp)
     f66:	0141                	addi	sp,sp,16
     f68:	8082                	ret
    while(n-- > 0)
     f6a:	fec05ce3          	blez	a2,f62 <memmove+0x2a>
    dst += n;
     f6e:	00c50733          	add	a4,a0,a2
    src += n;
     f72:	95b2                	add	a1,a1,a2
     f74:	fff6079b          	addiw	a5,a2,-1
     f78:	1782                	slli	a5,a5,0x20
     f7a:	9381                	srli	a5,a5,0x20
     f7c:	fff7c793          	not	a5,a5
     f80:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     f82:	15fd                	addi	a1,a1,-1
     f84:	177d                	addi	a4,a4,-1
     f86:	0005c683          	lbu	a3,0(a1)
     f8a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     f8e:	fef71ae3          	bne	a4,a5,f82 <memmove+0x4a>
     f92:	bfc1                	j	f62 <memmove+0x2a>

0000000000000f94 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     f94:	1141                	addi	sp,sp,-16
     f96:	e406                	sd	ra,8(sp)
     f98:	e022                	sd	s0,0(sp)
     f9a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     f9c:	c61d                	beqz	a2,fca <memcmp+0x36>
     f9e:	1602                	slli	a2,a2,0x20
     fa0:	9201                	srli	a2,a2,0x20
     fa2:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     fa6:	00054783          	lbu	a5,0(a0)
     faa:	0005c703          	lbu	a4,0(a1)
     fae:	00e79863          	bne	a5,a4,fbe <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     fb2:	0505                	addi	a0,a0,1
    p2++;
     fb4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     fb6:	fed518e3          	bne	a0,a3,fa6 <memcmp+0x12>
  }
  return 0;
     fba:	4501                	li	a0,0
     fbc:	a019                	j	fc2 <memcmp+0x2e>
      return *p1 - *p2;
     fbe:	40e7853b          	subw	a0,a5,a4
}
     fc2:	60a2                	ld	ra,8(sp)
     fc4:	6402                	ld	s0,0(sp)
     fc6:	0141                	addi	sp,sp,16
     fc8:	8082                	ret
  return 0;
     fca:	4501                	li	a0,0
     fcc:	bfdd                	j	fc2 <memcmp+0x2e>

0000000000000fce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     fce:	1141                	addi	sp,sp,-16
     fd0:	e406                	sd	ra,8(sp)
     fd2:	e022                	sd	s0,0(sp)
     fd4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     fd6:	f63ff0ef          	jal	f38 <memmove>
}
     fda:	60a2                	ld	ra,8(sp)
     fdc:	6402                	ld	s0,0(sp)
     fde:	0141                	addi	sp,sp,16
     fe0:	8082                	ret

0000000000000fe2 <sbrk>:

char *
sbrk(int n) {
     fe2:	1141                	addi	sp,sp,-16
     fe4:	e406                	sd	ra,8(sp)
     fe6:	e022                	sd	s0,0(sp)
     fe8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     fea:	4585                	li	a1,1
     fec:	0b2000ef          	jal	109e <sys_sbrk>
}
     ff0:	60a2                	ld	ra,8(sp)
     ff2:	6402                	ld	s0,0(sp)
     ff4:	0141                	addi	sp,sp,16
     ff6:	8082                	ret

0000000000000ff8 <sbrklazy>:

char *
sbrklazy(int n) {
     ff8:	1141                	addi	sp,sp,-16
     ffa:	e406                	sd	ra,8(sp)
     ffc:	e022                	sd	s0,0(sp)
     ffe:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    1000:	4589                	li	a1,2
    1002:	09c000ef          	jal	109e <sys_sbrk>
}
    1006:	60a2                	ld	ra,8(sp)
    1008:	6402                	ld	s0,0(sp)
    100a:	0141                	addi	sp,sp,16
    100c:	8082                	ret

000000000000100e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    100e:	4885                	li	a7,1
 ecall
    1010:	00000073          	ecall
 ret
    1014:	8082                	ret

0000000000001016 <exit>:
.global exit
exit:
 li a7, SYS_exit
    1016:	4889                	li	a7,2
 ecall
    1018:	00000073          	ecall
 ret
    101c:	8082                	ret

000000000000101e <wait>:
.global wait
wait:
 li a7, SYS_wait
    101e:	488d                	li	a7,3
 ecall
    1020:	00000073          	ecall
 ret
    1024:	8082                	ret

0000000000001026 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    1026:	4891                	li	a7,4
 ecall
    1028:	00000073          	ecall
 ret
    102c:	8082                	ret

000000000000102e <read>:
.global read
read:
 li a7, SYS_read
    102e:	4895                	li	a7,5
 ecall
    1030:	00000073          	ecall
 ret
    1034:	8082                	ret

0000000000001036 <write>:
.global write
write:
 li a7, SYS_write
    1036:	48c1                	li	a7,16
 ecall
    1038:	00000073          	ecall
 ret
    103c:	8082                	ret

000000000000103e <close>:
.global close
close:
 li a7, SYS_close
    103e:	48d5                	li	a7,21
 ecall
    1040:	00000073          	ecall
 ret
    1044:	8082                	ret

0000000000001046 <kill>:
.global kill
kill:
 li a7, SYS_kill
    1046:	4899                	li	a7,6
 ecall
    1048:	00000073          	ecall
 ret
    104c:	8082                	ret

000000000000104e <exec>:
.global exec
exec:
 li a7, SYS_exec
    104e:	489d                	li	a7,7
 ecall
    1050:	00000073          	ecall
 ret
    1054:	8082                	ret

0000000000001056 <open>:
.global open
open:
 li a7, SYS_open
    1056:	48bd                	li	a7,15
 ecall
    1058:	00000073          	ecall
 ret
    105c:	8082                	ret

000000000000105e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    105e:	48c5                	li	a7,17
 ecall
    1060:	00000073          	ecall
 ret
    1064:	8082                	ret

0000000000001066 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    1066:	48c9                	li	a7,18
 ecall
    1068:	00000073          	ecall
 ret
    106c:	8082                	ret

000000000000106e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    106e:	48a1                	li	a7,8
 ecall
    1070:	00000073          	ecall
 ret
    1074:	8082                	ret

0000000000001076 <link>:
.global link
link:
 li a7, SYS_link
    1076:	48cd                	li	a7,19
 ecall
    1078:	00000073          	ecall
 ret
    107c:	8082                	ret

000000000000107e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    107e:	48d1                	li	a7,20
 ecall
    1080:	00000073          	ecall
 ret
    1084:	8082                	ret

0000000000001086 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    1086:	48a5                	li	a7,9
 ecall
    1088:	00000073          	ecall
 ret
    108c:	8082                	ret

000000000000108e <dup>:
.global dup
dup:
 li a7, SYS_dup
    108e:	48a9                	li	a7,10
 ecall
    1090:	00000073          	ecall
 ret
    1094:	8082                	ret

0000000000001096 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    1096:	48ad                	li	a7,11
 ecall
    1098:	00000073          	ecall
 ret
    109c:	8082                	ret

000000000000109e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    109e:	48b1                	li	a7,12
 ecall
    10a0:	00000073          	ecall
 ret
    10a4:	8082                	ret

00000000000010a6 <pause>:
.global pause
pause:
 li a7, SYS_pause
    10a6:	48b5                	li	a7,13
 ecall
    10a8:	00000073          	ecall
 ret
    10ac:	8082                	ret

00000000000010ae <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    10ae:	48b9                	li	a7,14
 ecall
    10b0:	00000073          	ecall
 ret
    10b4:	8082                	ret

00000000000010b6 <csread>:
.global csread
csread:
 li a7, SYS_csread
    10b6:	48d9                	li	a7,22
 ecall
    10b8:	00000073          	ecall
 ret
    10bc:	8082                	ret

00000000000010be <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
    10be:	48dd                	li	a7,23
 ecall
    10c0:	00000073          	ecall
 ret
    10c4:	8082                	ret

00000000000010c6 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
    10c6:	48e1                	li	a7,24
 ecall
    10c8:	00000073          	ecall
 ret
    10cc:	8082                	ret

00000000000010ce <memread>:
.global memread
memread:
 li a7, SYS_memread
    10ce:	48e5                	li	a7,25
 ecall
    10d0:	00000073          	ecall
 ret
    10d4:	8082                	ret

00000000000010d6 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
    10d6:	48e9                	li	a7,26
 ecall
    10d8:	00000073          	ecall
 ret
    10dc:	8082                	ret

00000000000010de <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
    10de:	48ed                	li	a7,27
 ecall
    10e0:	00000073          	ecall
 ret
    10e4:	8082                	ret

00000000000010e6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    10e6:	1101                	addi	sp,sp,-32
    10e8:	ec06                	sd	ra,24(sp)
    10ea:	e822                	sd	s0,16(sp)
    10ec:	1000                	addi	s0,sp,32
    10ee:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    10f2:	4605                	li	a2,1
    10f4:	fef40593          	addi	a1,s0,-17
    10f8:	f3fff0ef          	jal	1036 <write>
}
    10fc:	60e2                	ld	ra,24(sp)
    10fe:	6442                	ld	s0,16(sp)
    1100:	6105                	addi	sp,sp,32
    1102:	8082                	ret

0000000000001104 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    1104:	715d                	addi	sp,sp,-80
    1106:	e486                	sd	ra,72(sp)
    1108:	e0a2                	sd	s0,64(sp)
    110a:	f84a                	sd	s2,48(sp)
    110c:	f44e                	sd	s3,40(sp)
    110e:	0880                	addi	s0,sp,80
    1110:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    1112:	c6d1                	beqz	a3,119e <printint+0x9a>
    1114:	0805d563          	bgez	a1,119e <printint+0x9a>
    neg = 1;
    x = -xx;
    1118:	40b005b3          	neg	a1,a1
    neg = 1;
    111c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
    111e:	fb840993          	addi	s3,s0,-72
  neg = 0;
    1122:	86ce                	mv	a3,s3
  i = 0;
    1124:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    1126:	00001817          	auipc	a6,0x1
    112a:	83a80813          	addi	a6,a6,-1990 # 1960 <digits>
    112e:	88ba                	mv	a7,a4
    1130:	0017051b          	addiw	a0,a4,1
    1134:	872a                	mv	a4,a0
    1136:	02c5f7b3          	remu	a5,a1,a2
    113a:	97c2                	add	a5,a5,a6
    113c:	0007c783          	lbu	a5,0(a5)
    1140:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    1144:	87ae                	mv	a5,a1
    1146:	02c5d5b3          	divu	a1,a1,a2
    114a:	0685                	addi	a3,a3,1
    114c:	fec7f1e3          	bgeu	a5,a2,112e <printint+0x2a>
  if(neg)
    1150:	00030c63          	beqz	t1,1168 <printint+0x64>
    buf[i++] = '-';
    1154:	fd050793          	addi	a5,a0,-48
    1158:	00878533          	add	a0,a5,s0
    115c:	02d00793          	li	a5,45
    1160:	fef50423          	sb	a5,-24(a0)
    1164:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    1168:	02e05563          	blez	a4,1192 <printint+0x8e>
    116c:	fc26                	sd	s1,56(sp)
    116e:	377d                	addiw	a4,a4,-1
    1170:	00e984b3          	add	s1,s3,a4
    1174:	19fd                	addi	s3,s3,-1
    1176:	99ba                	add	s3,s3,a4
    1178:	1702                	slli	a4,a4,0x20
    117a:	9301                	srli	a4,a4,0x20
    117c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1180:	0004c583          	lbu	a1,0(s1)
    1184:	854a                	mv	a0,s2
    1186:	f61ff0ef          	jal	10e6 <putc>
  while(--i >= 0)
    118a:	14fd                	addi	s1,s1,-1
    118c:	ff349ae3          	bne	s1,s3,1180 <printint+0x7c>
    1190:	74e2                	ld	s1,56(sp)
}
    1192:	60a6                	ld	ra,72(sp)
    1194:	6406                	ld	s0,64(sp)
    1196:	7942                	ld	s2,48(sp)
    1198:	79a2                	ld	s3,40(sp)
    119a:	6161                	addi	sp,sp,80
    119c:	8082                	ret
  neg = 0;
    119e:	4301                	li	t1,0
    11a0:	bfbd                	j	111e <printint+0x1a>

00000000000011a2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    11a2:	711d                	addi	sp,sp,-96
    11a4:	ec86                	sd	ra,88(sp)
    11a6:	e8a2                	sd	s0,80(sp)
    11a8:	e4a6                	sd	s1,72(sp)
    11aa:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    11ac:	0005c483          	lbu	s1,0(a1)
    11b0:	22048363          	beqz	s1,13d6 <vprintf+0x234>
    11b4:	e0ca                	sd	s2,64(sp)
    11b6:	fc4e                	sd	s3,56(sp)
    11b8:	f852                	sd	s4,48(sp)
    11ba:	f456                	sd	s5,40(sp)
    11bc:	f05a                	sd	s6,32(sp)
    11be:	ec5e                	sd	s7,24(sp)
    11c0:	e862                	sd	s8,16(sp)
    11c2:	8b2a                	mv	s6,a0
    11c4:	8a2e                	mv	s4,a1
    11c6:	8bb2                	mv	s7,a2
  state = 0;
    11c8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    11ca:	4901                	li	s2,0
    11cc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    11ce:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    11d2:	06400c13          	li	s8,100
    11d6:	a00d                	j	11f8 <vprintf+0x56>
        putc(fd, c0);
    11d8:	85a6                	mv	a1,s1
    11da:	855a                	mv	a0,s6
    11dc:	f0bff0ef          	jal	10e6 <putc>
    11e0:	a019                	j	11e6 <vprintf+0x44>
    } else if(state == '%'){
    11e2:	03598363          	beq	s3,s5,1208 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
    11e6:	0019079b          	addiw	a5,s2,1
    11ea:	893e                	mv	s2,a5
    11ec:	873e                	mv	a4,a5
    11ee:	97d2                	add	a5,a5,s4
    11f0:	0007c483          	lbu	s1,0(a5)
    11f4:	1c048a63          	beqz	s1,13c8 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
    11f8:	0004879b          	sext.w	a5,s1
    if(state == 0){
    11fc:	fe0993e3          	bnez	s3,11e2 <vprintf+0x40>
      if(c0 == '%'){
    1200:	fd579ce3          	bne	a5,s5,11d8 <vprintf+0x36>
        state = '%';
    1204:	89be                	mv	s3,a5
    1206:	b7c5                	j	11e6 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
    1208:	00ea06b3          	add	a3,s4,a4
    120c:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
    1210:	1c060863          	beqz	a2,13e0 <vprintf+0x23e>
      if(c0 == 'd'){
    1214:	03878763          	beq	a5,s8,1242 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    1218:	f9478693          	addi	a3,a5,-108
    121c:	0016b693          	seqz	a3,a3
    1220:	f9c60593          	addi	a1,a2,-100
    1224:	e99d                	bnez	a1,125a <vprintf+0xb8>
    1226:	ca95                	beqz	a3,125a <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1228:	008b8493          	addi	s1,s7,8
    122c:	4685                	li	a3,1
    122e:	4629                	li	a2,10
    1230:	000bb583          	ld	a1,0(s7)
    1234:	855a                	mv	a0,s6
    1236:	ecfff0ef          	jal	1104 <printint>
        i += 1;
    123a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    123c:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    123e:	4981                	li	s3,0
    1240:	b75d                	j	11e6 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
    1242:	008b8493          	addi	s1,s7,8
    1246:	4685                	li	a3,1
    1248:	4629                	li	a2,10
    124a:	000ba583          	lw	a1,0(s7)
    124e:	855a                	mv	a0,s6
    1250:	eb5ff0ef          	jal	1104 <printint>
    1254:	8ba6                	mv	s7,s1
      state = 0;
    1256:	4981                	li	s3,0
    1258:	b779                	j	11e6 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
    125a:	9752                	add	a4,a4,s4
    125c:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    1260:	f9460713          	addi	a4,a2,-108
    1264:	00173713          	seqz	a4,a4
    1268:	8f75                	and	a4,a4,a3
    126a:	f9c58513          	addi	a0,a1,-100
    126e:	18051363          	bnez	a0,13f4 <vprintf+0x252>
    1272:	18070163          	beqz	a4,13f4 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1276:	008b8493          	addi	s1,s7,8
    127a:	4685                	li	a3,1
    127c:	4629                	li	a2,10
    127e:	000bb583          	ld	a1,0(s7)
    1282:	855a                	mv	a0,s6
    1284:	e81ff0ef          	jal	1104 <printint>
        i += 2;
    1288:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    128a:	8ba6                	mv	s7,s1
      state = 0;
    128c:	4981                	li	s3,0
        i += 2;
    128e:	bfa1                	j	11e6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
    1290:	008b8493          	addi	s1,s7,8
    1294:	4681                	li	a3,0
    1296:	4629                	li	a2,10
    1298:	000be583          	lwu	a1,0(s7)
    129c:	855a                	mv	a0,s6
    129e:	e67ff0ef          	jal	1104 <printint>
    12a2:	8ba6                	mv	s7,s1
      state = 0;
    12a4:	4981                	li	s3,0
    12a6:	b781                	j	11e6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    12a8:	008b8493          	addi	s1,s7,8
    12ac:	4681                	li	a3,0
    12ae:	4629                	li	a2,10
    12b0:	000bb583          	ld	a1,0(s7)
    12b4:	855a                	mv	a0,s6
    12b6:	e4fff0ef          	jal	1104 <printint>
        i += 1;
    12ba:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    12bc:	8ba6                	mv	s7,s1
      state = 0;
    12be:	4981                	li	s3,0
    12c0:	b71d                	j	11e6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    12c2:	008b8493          	addi	s1,s7,8
    12c6:	4681                	li	a3,0
    12c8:	4629                	li	a2,10
    12ca:	000bb583          	ld	a1,0(s7)
    12ce:	855a                	mv	a0,s6
    12d0:	e35ff0ef          	jal	1104 <printint>
        i += 2;
    12d4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    12d6:	8ba6                	mv	s7,s1
      state = 0;
    12d8:	4981                	li	s3,0
        i += 2;
    12da:	b731                	j	11e6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
    12dc:	008b8493          	addi	s1,s7,8
    12e0:	4681                	li	a3,0
    12e2:	4641                	li	a2,16
    12e4:	000be583          	lwu	a1,0(s7)
    12e8:	855a                	mv	a0,s6
    12ea:	e1bff0ef          	jal	1104 <printint>
    12ee:	8ba6                	mv	s7,s1
      state = 0;
    12f0:	4981                	li	s3,0
    12f2:	bdd5                	j	11e6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
    12f4:	008b8493          	addi	s1,s7,8
    12f8:	4681                	li	a3,0
    12fa:	4641                	li	a2,16
    12fc:	000bb583          	ld	a1,0(s7)
    1300:	855a                	mv	a0,s6
    1302:	e03ff0ef          	jal	1104 <printint>
        i += 1;
    1306:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    1308:	8ba6                	mv	s7,s1
      state = 0;
    130a:	4981                	li	s3,0
    130c:	bde9                	j	11e6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
    130e:	008b8493          	addi	s1,s7,8
    1312:	4681                	li	a3,0
    1314:	4641                	li	a2,16
    1316:	000bb583          	ld	a1,0(s7)
    131a:	855a                	mv	a0,s6
    131c:	de9ff0ef          	jal	1104 <printint>
        i += 2;
    1320:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    1322:	8ba6                	mv	s7,s1
      state = 0;
    1324:	4981                	li	s3,0
        i += 2;
    1326:	b5c1                	j	11e6 <vprintf+0x44>
    1328:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
    132a:	008b8793          	addi	a5,s7,8
    132e:	8cbe                	mv	s9,a5
    1330:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    1334:	03000593          	li	a1,48
    1338:	855a                	mv	a0,s6
    133a:	dadff0ef          	jal	10e6 <putc>
  putc(fd, 'x');
    133e:	07800593          	li	a1,120
    1342:	855a                	mv	a0,s6
    1344:	da3ff0ef          	jal	10e6 <putc>
    1348:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    134a:	00000b97          	auipc	s7,0x0
    134e:	616b8b93          	addi	s7,s7,1558 # 1960 <digits>
    1352:	03c9d793          	srli	a5,s3,0x3c
    1356:	97de                	add	a5,a5,s7
    1358:	0007c583          	lbu	a1,0(a5)
    135c:	855a                	mv	a0,s6
    135e:	d89ff0ef          	jal	10e6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1362:	0992                	slli	s3,s3,0x4
    1364:	34fd                	addiw	s1,s1,-1
    1366:	f4f5                	bnez	s1,1352 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
    1368:	8be6                	mv	s7,s9
      state = 0;
    136a:	4981                	li	s3,0
    136c:	6ca2                	ld	s9,8(sp)
    136e:	bda5                	j	11e6 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
    1370:	008b8493          	addi	s1,s7,8
    1374:	000bc583          	lbu	a1,0(s7)
    1378:	855a                	mv	a0,s6
    137a:	d6dff0ef          	jal	10e6 <putc>
    137e:	8ba6                	mv	s7,s1
      state = 0;
    1380:	4981                	li	s3,0
    1382:	b595                	j	11e6 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
    1384:	008b8993          	addi	s3,s7,8
    1388:	000bb483          	ld	s1,0(s7)
    138c:	cc91                	beqz	s1,13a8 <vprintf+0x206>
        for(; *s; s++)
    138e:	0004c583          	lbu	a1,0(s1)
    1392:	c985                	beqz	a1,13c2 <vprintf+0x220>
          putc(fd, *s);
    1394:	855a                	mv	a0,s6
    1396:	d51ff0ef          	jal	10e6 <putc>
        for(; *s; s++)
    139a:	0485                	addi	s1,s1,1
    139c:	0004c583          	lbu	a1,0(s1)
    13a0:	f9f5                	bnez	a1,1394 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
    13a2:	8bce                	mv	s7,s3
      state = 0;
    13a4:	4981                	li	s3,0
    13a6:	b581                	j	11e6 <vprintf+0x44>
          s = "(null)";
    13a8:	00000497          	auipc	s1,0x0
    13ac:	57048493          	addi	s1,s1,1392 # 1918 <malloc+0x3d4>
        for(; *s; s++)
    13b0:	02800593          	li	a1,40
    13b4:	b7c5                	j	1394 <vprintf+0x1f2>
        putc(fd, '%');
    13b6:	85be                	mv	a1,a5
    13b8:	855a                	mv	a0,s6
    13ba:	d2dff0ef          	jal	10e6 <putc>
      state = 0;
    13be:	4981                	li	s3,0
    13c0:	b51d                	j	11e6 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
    13c2:	8bce                	mv	s7,s3
      state = 0;
    13c4:	4981                	li	s3,0
    13c6:	b505                	j	11e6 <vprintf+0x44>
    13c8:	6906                	ld	s2,64(sp)
    13ca:	79e2                	ld	s3,56(sp)
    13cc:	7a42                	ld	s4,48(sp)
    13ce:	7aa2                	ld	s5,40(sp)
    13d0:	7b02                	ld	s6,32(sp)
    13d2:	6be2                	ld	s7,24(sp)
    13d4:	6c42                	ld	s8,16(sp)
    }
  }
}
    13d6:	60e6                	ld	ra,88(sp)
    13d8:	6446                	ld	s0,80(sp)
    13da:	64a6                	ld	s1,72(sp)
    13dc:	6125                	addi	sp,sp,96
    13de:	8082                	ret
      if(c0 == 'd'){
    13e0:	06400713          	li	a4,100
    13e4:	e4e78fe3          	beq	a5,a4,1242 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
    13e8:	f9478693          	addi	a3,a5,-108
    13ec:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
    13f0:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    13f2:	4701                	li	a4,0
      } else if(c0 == 'u'){
    13f4:	07500513          	li	a0,117
    13f8:	e8a78ce3          	beq	a5,a0,1290 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
    13fc:	f8b60513          	addi	a0,a2,-117
    1400:	e119                	bnez	a0,1406 <vprintf+0x264>
    1402:	ea0693e3          	bnez	a3,12a8 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    1406:	f8b58513          	addi	a0,a1,-117
    140a:	e119                	bnez	a0,1410 <vprintf+0x26e>
    140c:	ea071be3          	bnez	a4,12c2 <vprintf+0x120>
      } else if(c0 == 'x'){
    1410:	07800513          	li	a0,120
    1414:	eca784e3          	beq	a5,a0,12dc <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
    1418:	f8860613          	addi	a2,a2,-120
    141c:	e219                	bnez	a2,1422 <vprintf+0x280>
    141e:	ec069be3          	bnez	a3,12f4 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    1422:	f8858593          	addi	a1,a1,-120
    1426:	e199                	bnez	a1,142c <vprintf+0x28a>
    1428:	ee0713e3          	bnez	a4,130e <vprintf+0x16c>
      } else if(c0 == 'p'){
    142c:	07000713          	li	a4,112
    1430:	eee78ce3          	beq	a5,a4,1328 <vprintf+0x186>
      } else if(c0 == 'c'){
    1434:	06300713          	li	a4,99
    1438:	f2e78ce3          	beq	a5,a4,1370 <vprintf+0x1ce>
      } else if(c0 == 's'){
    143c:	07300713          	li	a4,115
    1440:	f4e782e3          	beq	a5,a4,1384 <vprintf+0x1e2>
      } else if(c0 == '%'){
    1444:	02500713          	li	a4,37
    1448:	f6e787e3          	beq	a5,a4,13b6 <vprintf+0x214>
        putc(fd, '%');
    144c:	02500593          	li	a1,37
    1450:	855a                	mv	a0,s6
    1452:	c95ff0ef          	jal	10e6 <putc>
        putc(fd, c0);
    1456:	85a6                	mv	a1,s1
    1458:	855a                	mv	a0,s6
    145a:	c8dff0ef          	jal	10e6 <putc>
      state = 0;
    145e:	4981                	li	s3,0
    1460:	b359                	j	11e6 <vprintf+0x44>

0000000000001462 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1462:	715d                	addi	sp,sp,-80
    1464:	ec06                	sd	ra,24(sp)
    1466:	e822                	sd	s0,16(sp)
    1468:	1000                	addi	s0,sp,32
    146a:	e010                	sd	a2,0(s0)
    146c:	e414                	sd	a3,8(s0)
    146e:	e818                	sd	a4,16(s0)
    1470:	ec1c                	sd	a5,24(s0)
    1472:	03043023          	sd	a6,32(s0)
    1476:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    147a:	8622                	mv	a2,s0
    147c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1480:	d23ff0ef          	jal	11a2 <vprintf>
}
    1484:	60e2                	ld	ra,24(sp)
    1486:	6442                	ld	s0,16(sp)
    1488:	6161                	addi	sp,sp,80
    148a:	8082                	ret

000000000000148c <printf>:

void
printf(const char *fmt, ...)
{
    148c:	711d                	addi	sp,sp,-96
    148e:	ec06                	sd	ra,24(sp)
    1490:	e822                	sd	s0,16(sp)
    1492:	1000                	addi	s0,sp,32
    1494:	e40c                	sd	a1,8(s0)
    1496:	e810                	sd	a2,16(s0)
    1498:	ec14                	sd	a3,24(s0)
    149a:	f018                	sd	a4,32(s0)
    149c:	f41c                	sd	a5,40(s0)
    149e:	03043823          	sd	a6,48(s0)
    14a2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    14a6:	00840613          	addi	a2,s0,8
    14aa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    14ae:	85aa                	mv	a1,a0
    14b0:	4505                	li	a0,1
    14b2:	cf1ff0ef          	jal	11a2 <vprintf>
}
    14b6:	60e2                	ld	ra,24(sp)
    14b8:	6442                	ld	s0,16(sp)
    14ba:	6125                	addi	sp,sp,96
    14bc:	8082                	ret

00000000000014be <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    14be:	1141                	addi	sp,sp,-16
    14c0:	e406                	sd	ra,8(sp)
    14c2:	e022                	sd	s0,0(sp)
    14c4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    14c6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    14ca:	00001797          	auipc	a5,0x1
    14ce:	b367b783          	ld	a5,-1226(a5) # 2000 <freep>
    14d2:	a039                	j	14e0 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    14d4:	6398                	ld	a4,0(a5)
    14d6:	00e7e463          	bltu	a5,a4,14de <free+0x20>
    14da:	00e6ea63          	bltu	a3,a4,14ee <free+0x30>
{
    14de:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    14e0:	fed7fae3          	bgeu	a5,a3,14d4 <free+0x16>
    14e4:	6398                	ld	a4,0(a5)
    14e6:	00e6e463          	bltu	a3,a4,14ee <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    14ea:	fee7eae3          	bltu	a5,a4,14de <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
    14ee:	ff852583          	lw	a1,-8(a0)
    14f2:	6390                	ld	a2,0(a5)
    14f4:	02059813          	slli	a6,a1,0x20
    14f8:	01c85713          	srli	a4,a6,0x1c
    14fc:	9736                	add	a4,a4,a3
    14fe:	02e60563          	beq	a2,a4,1528 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
    1502:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    1506:	4790                	lw	a2,8(a5)
    1508:	02061593          	slli	a1,a2,0x20
    150c:	01c5d713          	srli	a4,a1,0x1c
    1510:	973e                	add	a4,a4,a5
    1512:	02e68263          	beq	a3,a4,1536 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
    1516:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1518:	00001717          	auipc	a4,0x1
    151c:	aef73423          	sd	a5,-1304(a4) # 2000 <freep>
}
    1520:	60a2                	ld	ra,8(sp)
    1522:	6402                	ld	s0,0(sp)
    1524:	0141                	addi	sp,sp,16
    1526:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
    1528:	4618                	lw	a4,8(a2)
    152a:	9f2d                	addw	a4,a4,a1
    152c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1530:	6398                	ld	a4,0(a5)
    1532:	6310                	ld	a2,0(a4)
    1534:	b7f9                	j	1502 <free+0x44>
    p->s.size += bp->s.size;
    1536:	ff852703          	lw	a4,-8(a0)
    153a:	9f31                	addw	a4,a4,a2
    153c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    153e:	ff053683          	ld	a3,-16(a0)
    1542:	bfd1                	j	1516 <free+0x58>

0000000000001544 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1544:	7139                	addi	sp,sp,-64
    1546:	fc06                	sd	ra,56(sp)
    1548:	f822                	sd	s0,48(sp)
    154a:	f04a                	sd	s2,32(sp)
    154c:	ec4e                	sd	s3,24(sp)
    154e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1550:	02051993          	slli	s3,a0,0x20
    1554:	0209d993          	srli	s3,s3,0x20
    1558:	09bd                	addi	s3,s3,15
    155a:	0049d993          	srli	s3,s3,0x4
    155e:	2985                	addiw	s3,s3,1
    1560:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
    1562:	00001517          	auipc	a0,0x1
    1566:	a9e53503          	ld	a0,-1378(a0) # 2000 <freep>
    156a:	c905                	beqz	a0,159a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    156c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    156e:	4798                	lw	a4,8(a5)
    1570:	09377663          	bgeu	a4,s3,15fc <malloc+0xb8>
    1574:	f426                	sd	s1,40(sp)
    1576:	e852                	sd	s4,16(sp)
    1578:	e456                	sd	s5,8(sp)
    157a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    157c:	8a4e                	mv	s4,s3
    157e:	6705                	lui	a4,0x1
    1580:	00e9f363          	bgeu	s3,a4,1586 <malloc+0x42>
    1584:	6a05                	lui	s4,0x1
    1586:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    158a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    158e:	00001497          	auipc	s1,0x1
    1592:	a7248493          	addi	s1,s1,-1422 # 2000 <freep>
  if(p == SBRK_ERROR)
    1596:	5afd                	li	s5,-1
    1598:	a83d                	j	15d6 <malloc+0x92>
    159a:	f426                	sd	s1,40(sp)
    159c:	e852                	sd	s4,16(sp)
    159e:	e456                	sd	s5,8(sp)
    15a0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    15a2:	00003797          	auipc	a5,0x3
    15a6:	a6e78793          	addi	a5,a5,-1426 # 4010 <base>
    15aa:	00001717          	auipc	a4,0x1
    15ae:	a4f73b23          	sd	a5,-1450(a4) # 2000 <freep>
    15b2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    15b4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    15b8:	b7d1                	j	157c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    15ba:	6398                	ld	a4,0(a5)
    15bc:	e118                	sd	a4,0(a0)
    15be:	a899                	j	1614 <malloc+0xd0>
  hp->s.size = nu;
    15c0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    15c4:	0541                	addi	a0,a0,16
    15c6:	ef9ff0ef          	jal	14be <free>
  return freep;
    15ca:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    15cc:	c125                	beqz	a0,162c <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    15ce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    15d0:	4798                	lw	a4,8(a5)
    15d2:	03277163          	bgeu	a4,s2,15f4 <malloc+0xb0>
    if(p == freep)
    15d6:	6098                	ld	a4,0(s1)
    15d8:	853e                	mv	a0,a5
    15da:	fef71ae3          	bne	a4,a5,15ce <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
    15de:	8552                	mv	a0,s4
    15e0:	a03ff0ef          	jal	fe2 <sbrk>
  if(p == SBRK_ERROR)
    15e4:	fd551ee3          	bne	a0,s5,15c0 <malloc+0x7c>
        return 0;
    15e8:	4501                	li	a0,0
    15ea:	74a2                	ld	s1,40(sp)
    15ec:	6a42                	ld	s4,16(sp)
    15ee:	6aa2                	ld	s5,8(sp)
    15f0:	6b02                	ld	s6,0(sp)
    15f2:	a03d                	j	1620 <malloc+0xdc>
    15f4:	74a2                	ld	s1,40(sp)
    15f6:	6a42                	ld	s4,16(sp)
    15f8:	6aa2                	ld	s5,8(sp)
    15fa:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    15fc:	fae90fe3          	beq	s2,a4,15ba <malloc+0x76>
        p->s.size -= nunits;
    1600:	4137073b          	subw	a4,a4,s3
    1604:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1606:	02071693          	slli	a3,a4,0x20
    160a:	01c6d713          	srli	a4,a3,0x1c
    160e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1610:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1614:	00001717          	auipc	a4,0x1
    1618:	9ea73623          	sd	a0,-1556(a4) # 2000 <freep>
      return (void*)(p + 1);
    161c:	01078513          	addi	a0,a5,16
  }
}
    1620:	70e2                	ld	ra,56(sp)
    1622:	7442                	ld	s0,48(sp)
    1624:	7902                	ld	s2,32(sp)
    1626:	69e2                	ld	s3,24(sp)
    1628:	6121                	addi	sp,sp,64
    162a:	8082                	ret
    162c:	74a2                	ld	s1,40(sp)
    162e:	6a42                	ld	s4,16(sp)
    1630:	6aa2                	ld	s5,8(sp)
    1632:	6b02                	ld	s6,0(sp)
    1634:	b7f5                	j	1620 <malloc+0xdc>
